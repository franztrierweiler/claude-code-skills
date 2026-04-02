#!/bin/bash
# =============================================================================
# Exécution des tests de régression des skills SDD
# Usage: ./tests/run-tests.sh [init|uc-spec|review|all]
# Appelé par le Makefile — ne pas exécuter directement avant test-setup.
# Requiert: claude, python3
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_OUT="$SCRIPT_DIR/output"
TEST_LOG="$SCRIPT_DIR/log"
PROMPTS="$SCRIPT_DIR/prompts"

# --- Fonctions ---------------------------------------------------------------

# Extrait le texte en temps réel depuis le flux stream-json de Claude.
# python3 -u désactive le buffering — chaque fragment s'affiche immédiatement.
STREAM_FILTER="$SCRIPT_DIR/stream_filter.py"

CYAN="\033[36m"
DIM="\033[2m"
RESET="\033[0m"

run_claude() {
    local prompt="$1"
    local logfile="$2"

    # Afficher le prompt complet avant d'invoquer Claude
    # Extraire le chemin du fichier prompt s'il est référencé
    local prompt_file
    prompt_file=$(echo "$prompt" | grep -oE '/[^ ]+\.md' | head -1 || true)

    echo -e "${CYAN}  \$ claude -p \"${prompt:0:80}...\"${RESET}"
    echo ""

    if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
        echo -e "${DIM}  ┌── Contenu du prompt : $prompt_file${RESET}"
        sed 's/^/  │ /' "$prompt_file" | while IFS= read -r line; do
            echo -e "${DIM}$line${RESET}"
        done
        echo -e "${DIM}  └──${RESET}"
        echo ""
    fi

    # HOME redirigé vers un répertoire temporaire pour isoler les skills.
    # Sans cela, Claude charge les skills globaux de ~/.claude/skills/
    # qui sont prioritaires sur ceux du projet (.claude/skills/).
    local FAKE_HOME
    FAKE_HOME=$(mktemp -d)
    HOME="$FAKE_HOME" claude -p --verbose --permission-mode bypassPermissions \
        --output-format stream-json \
        "$prompt" \
        2>/dev/null | tee "$logfile" | python3 -u "$STREAM_FILTER"
    rm -rf "$FAKE_HOME"
}

run_init() {
    echo ""
    echo "=== Test init — Génération du CLAUDE.md ==="
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-init.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/init.log"

    echo ""
    if [ -f "$TEST_OUT/CLAUDE.md" ]; then
        echo "  ✓ $TEST_OUT/CLAUDE.md généré"
    else
        echo "  ÉCHEC — CLAUDE.md non produit (voir $TEST_LOG/init.log)"
        exit 1
    fi
}

run_uc_spec() {
    echo ""
    echo "=== Test sdd-uc-spec-write — SPEC.md MaintiX ==="
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-uc-spec-write.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/uc-spec.log"

    echo ""
    if [ -f "$TEST_OUT/docs/SPEC.md" ]; then
        echo "  ✓ $TEST_OUT/docs/SPEC.md généré"
    else
        echo "  ÉCHEC — docs/SPEC.md non produit (voir $TEST_LOG/uc-spec.log)"
        exit 1
    fi
}

run_review() {
    echo ""
    echo "=== Review — Évaluation du SPEC.md par Claude ==="
    echo ""

    if [ ! -f "$TEST_OUT/docs/SPEC.md" ]; then
        echo "  ÉCHEC — docs/SPEC.md absent. Lancer 'make test-uc-spec' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-review-spec.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/review.log"
}

run_uc_system_design() {
    echo ""
    echo "=== Test sdd-uc-system-design — Documents de conception MaintiX ==="
    echo ""

    if [ ! -f "$TEST_OUT/docs/SPEC.md" ]; then
        echo "  ÉCHEC — docs/SPEC.md absent. Lancer 'make test-uc-spec' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-uc-system-design.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/uc-system-design.log"

    echo ""
    local fail=0
    for doc in ARCHITECTURE.md DEPLOYMENT.md SECURITY.md; do
        if [ -f "$TEST_OUT/docs/$doc" ]; then
            echo "  ✓ $TEST_OUT/docs/$doc généré"
        else
            echo "  ÉCHEC — docs/$doc non produit"
            fail=1
        fi
    done
    # COMPLIANCE_MATRIX.md est optionnel mais attendu pour MaintiX (RGPD)
    if [ -f "$TEST_OUT/docs/COMPLIANCE_MATRIX.md" ]; then
        echo "  ✓ $TEST_OUT/docs/COMPLIANCE_MATRIX.md généré"
    else
        echo "  ⚠ docs/COMPLIANCE_MATRIX.md absent (optionnel)"
    fi
    if [ "$fail" -eq 1 ]; then
        echo ""
        echo "  Voir $TEST_LOG/uc-system-design.log"
        exit 1
    fi
}

# --- Main --------------------------------------------------------------------

ACTION="${1:-all}"

case "$ACTION" in
    init)
        run_init
        ;;
    uc-spec)
        run_uc_spec
        ;;
    uc-system-design)
        run_uc_system_design
        ;;
    review)
        run_review
        ;;
    all)
        run_init
        run_uc_spec
        run_review
        run_uc_system_design
        echo ""
        echo "Tous les tests ont été exécutés."
        ;;
    *)
        echo "Usage: $0 [init|uc-spec|uc-system-design|review|all]"
        exit 1
        ;;
esac
