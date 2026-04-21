#!/bin/bash
# =============================================================================
# Exécution des tests de régression des skills SDD
# Usage: ./tests/run-tests.sh [init|uc-spec|uc-spec-extension|uc-system-design|plan|dev-workflow|qa-workflow|brief|tuto|review|review-extension|all]
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
    echo "=== Test sdd-uc-spec-write — SPEC MaintiX ==="
    echo ""

    # Nettoyage des anciens SPEC pour forcer la regénération
    rm -f "$TEST_OUT/docs/SPEC.md" "$TEST_OUT"/docs/SPEC-*.md

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-uc-spec-write.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/uc-spec.log"

    echo ""
    local spec_file
    spec_file=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-*.md' -type f 2>/dev/null | head -1)
    if [ -n "$spec_file" ]; then
        echo "  ✓ $spec_file généré"
    else
        echo "  ÉCHEC — aucun docs/SPEC-*.md produit (voir $TEST_LOG/uc-spec.log)"
        exit 1
    fi
}

run_uc_spec_extension() {
    echo ""
    echo "=== Test sdd-uc-spec-write — Extension Alertes MaintiX ==="
    echo ""

    local spec_racine
    spec_racine=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-racine-*.md' -type f 2>/dev/null | head -1)
    if [ -z "$spec_racine" ]; then
        echo "  ÉCHEC — aucun docs/SPEC-racine-*.md trouvé. Lancer 'make test-uc-spec-racine' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-uc-spec-extension.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/uc-spec-extension.log"

    echo ""
    local ext_file
    ext_file=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-extension-*.md' -type f 2>/dev/null | head -1)
    if [ -n "$ext_file" ]; then
        echo "  ✓ $ext_file généré"
    else
        echo "  ÉCHEC — aucun docs/SPEC-extension-*.md produit (voir $TEST_LOG/uc-spec-extension.log)"
        exit 1
    fi
}

run_review() {
    echo ""
    echo "=== Review — Évaluation du SPEC par Claude ==="
    echo ""

    local spec_racine
    spec_racine=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-racine-*.md' -type f 2>/dev/null | head -1)
    if [ -z "$spec_racine" ]; then
        echo "  ÉCHEC — aucun docs/SPEC-racine-*.md trouvé. Lancer 'make test-uc-spec-racine' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-review-spec.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/review.log"
}

run_review_extension() {
    echo ""
    echo "=== Review — Évaluation du SPEC extension par Claude ==="
    echo ""

    local ext_count
    ext_count=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-extension-*.md' -type f 2>/dev/null | wc -l)
    if [ "$ext_count" -eq 0 ]; then
        echo "  ÉCHEC — aucun docs/SPEC-extension-*.md trouvé. Lancer 'make test-uc-spec-extension' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-review-spec-extension.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/review-extension.log"
}

run_uc_system_design() {
    echo ""
    echo "=== Test sdd-uc-system-design — Documents de conception MaintiX ==="
    echo ""

    local spec_racine
    spec_racine=$(find "$TEST_OUT/docs" -maxdepth 1 -name 'SPEC-racine-*.md' -type f 2>/dev/null | head -1)
    if [ -z "$spec_racine" ]; then
        echo "  ÉCHEC — aucun docs/SPEC-racine-*.md trouvé. Lancer 'make test-uc-spec-racine' d'abord."
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

run_qa_workflow() {
    echo ""
    echo "=== Test sdd-qa-workflow — QA du premier lot MaintiX ==="
    echo ""

    local plan_count
    plan_count=$(find "$TEST_OUT/plan" -name "*.md" -type f 2>/dev/null | wc -l)
    if [ "$plan_count" -eq 0 ]; then
        echo "  ÉCHEC — aucun fichier plan/*.md. Lancer 'make test-plan' d'abord."
        exit 1
    fi

    if [ ! -d "$TEST_OUT/src" ]; then
        echo "  ÉCHEC — src/ absent. Lancer 'make test-dev-workflow' d'abord."
        exit 1
    fi

    local first_lot
    first_lot=$(find "$TEST_OUT/plan" -name "*.md" -type f | sort | head -1)
    local lot_name
    lot_name=$(basename "$first_lot" .md)

    echo "  Lot détecté : $lot_name"
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-qa-workflow.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/qa-workflow.log"

    echo ""
    # Vérifications rapides
    if [ -d "$TEST_OUT/qa" ]; then
        echo "  ✓ qa/ créé"
        for f in "plan-test-$lot_name.md" "qa-results/rapport-$lot_name.md"; do
            if [ -f "$TEST_OUT/qa/$f" ]; then
                echo "  ✓ qa/$f"
            else
                echo "  ⚠ qa/$f absent"
            fi
        done
    else
        echo "  ÉCHEC — qa/ absent, aucun livrable QA produit"
        exit 1
    fi
}

run_brief() {
    echo ""
    echo "=== Test sdd-brief — Tableau de bord projet ==="
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-brief.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/brief.log"
}

run_tuto() {
    echo ""
    echo "=== Test sdd-tuto — Tutoriel SDD ==="
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-tuto.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/tuto.log"
}

run_plan() {
    echo ""
    echo "=== Test planification — Découpe en lots MaintiX ==="
    echo ""

    if [ ! -f "$TEST_OUT/docs/ARCHITECTURE.md" ]; then
        echo "  ÉCHEC — docs/ARCHITECTURE.md absent. Lancer 'make test-uc-system-design' d'abord."
        exit 1
    fi

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-plan.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/plan.log"

    echo ""
    local plan_count
    plan_count=$(find "$TEST_OUT/plan" -name "*.md" -type f 2>/dev/null | wc -l)
    if [ "$plan_count" -ge 1 ]; then
        echo "  ✓ $plan_count lot(s) planifié(s) dans plan/"
        find "$TEST_OUT/plan" -name "*.md" -type f | sort | while read -r f; do
            echo "    - $(basename "$f")"
        done
    else
        echo "  ÉCHEC — aucun fichier plan/*.md produit (voir $TEST_LOG/plan.log)"
        exit 1
    fi

    # Snapshot du plan initial avant que sdd-dev-workflow ne marque des AC comme résolus.
    # check_plan_output.sh consomme plan-initial/ quand il existe.
    rm -rf "$TEST_OUT/plan-initial"
    cp -r "$TEST_OUT/plan" "$TEST_OUT/plan-initial"
}

run_dev_workflow() {
    echo ""
    echo "=== Test sdd-dev-workflow — Développement du premier lot MaintiX ==="
    echo ""

    local plan_count
    plan_count=$(find "$TEST_OUT/plan" -name "*.md" -type f 2>/dev/null | wc -l)
    if [ "$plan_count" -eq 0 ]; then
        echo "  ÉCHEC — aucun fichier plan/*.md. Lancer 'make test-plan' d'abord."
        exit 1
    fi

    local first_lot
    first_lot=$(find "$TEST_OUT/plan" -name "*.md" -type f | sort | head -1)
    local lot_name
    lot_name=$(basename "$first_lot" .md)

    echo "  Premier lot détecté : $lot_name"
    echo ""

    mkdir -p "$TEST_LOG"
    cd "$TEST_OUT"

    run_claude \
        "Lis le fichier $PROMPTS/prompt-dev-workflow.md et exécute les instructions qu'il contient." \
        "$TEST_LOG/dev-workflow.log"

    echo ""
    # Vérifications rapides
    if [ -d "$TEST_OUT/src" ]; then
        local py_count
        py_count=$(find "$TEST_OUT/src" -name "*.py" -type f | wc -l)
        echo "  ✓ src/ contient $py_count fichier(s) Python"
    else
        echo "  ÉCHEC — src/ absent, aucun code produit"
        exit 1
    fi

    if [ -d "$TEST_OUT/tests" ]; then
        local test_count
        test_count=$(find "$TEST_OUT/tests" -name "test_*.py" -o -name "*_test.py" | wc -l)
        echo "  ✓ tests/ contient $test_count fichier(s) de test"
    else
        echo "  ⚠ tests/ absent"
    fi

    if [ -f "$TEST_OUT/Makefile" ]; then
        echo "  ✓ Makefile produit"
    else
        echo "  ⚠ Makefile absent"
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
    uc-spec-extension)
        run_uc_spec_extension
        ;;
    uc-system-design)
        run_uc_system_design
        ;;
    plan)
        run_plan
        ;;
    dev-workflow)
        run_dev_workflow
        ;;
    qa-workflow)
        run_qa_workflow
        ;;
    brief)
        run_brief
        ;;
    tuto)
        run_tuto
        ;;
    review)
        run_review
        ;;
    review-extension)
        run_review_extension
        ;;
    all)
        run_init
        run_uc_spec
        run_uc_spec_extension
        run_review
        run_review_extension
        run_uc_system_design
        run_plan
        run_dev_workflow
        run_qa_workflow
        run_brief
        echo ""
        echo "Tous les tests ont été exécutés."
        ;;
    *)
        echo "Usage: $0 [init|uc-spec|uc-spec-extension|uc-system-design|plan|dev-workflow|qa-workflow|brief|tuto|review|review-extension|all]"
        exit 1
        ;;
esac
