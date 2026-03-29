#!/bin/bash
# =============================================================================
# Exécution des tests de régression des skills SDD
# Usage: ./tests/run-tests.sh [init|uc-spec|all]
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
RESET="\033[0m"

run_claude() {
    local prompt="$1"
    local logfile="$2"

    echo -e "${CYAN}  \$ claude -p \"${prompt:0:80}...\"${RESET}"
    echo ""

    claude -p --verbose --permission-mode bypassPermissions \
        --output-format stream-json \
        "$prompt" \
        2>/dev/null | tee "$logfile" | python3 -u "$STREAM_FILTER"
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

# --- Main --------------------------------------------------------------------

ACTION="${1:-all}"

case "$ACTION" in
    init)
        run_init
        ;;
    uc-spec)
        run_uc_spec
        ;;
    all)
        run_init
        run_uc_spec
        echo ""
        echo "Tous les tests ont été exécutés."
        echo "Lancer 'make test-check' pour comparer avec les références."
        ;;
    *)
        echo "Usage: $0 [init|uc-spec|all]"
        exit 1
        ;;
esac
