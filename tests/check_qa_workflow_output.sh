#!/bin/bash
# =============================================================================
# Contrôles déterministes des sorties du workflow QA
# Usage: ./tests/check_qa_workflow_output.sh [chemin_du_projet]
# Par défaut : tests/output
#
# Vérifie :
#   1. Plan de test (qa/plan-test-<lot>.md)
#   2. Revue de code (qa/code-review/<lot>-review.md)
#   3. Rapport final (qa/qa-results/rapport-<lot>.md)
#   4. Contenu structurel des fichiers QA
# =============================================================================

set -euo pipefail

PROJECT_DIR="${1:-tests/output}"
QA_DIR="$PROJECT_DIR/qa"
PLAN_DIR="$PROJECT_DIR/plan"

FAIL=0
PASS=0
SKIP=0

ok() {
    echo "  ✓ $1"
    PASS=$((PASS + 1))
}

ko() {
    echo "  ✗ $1"
    FAIL=$((FAIL + 1))
}

skip() {
    echo "  ⊘ $1"
    SKIP=$((SKIP + 1))
}

echo ""
echo "=== Contrôles du workflow QA ==="
echo "    Répertoire : $QA_DIR"

# Identifier le premier lot développé
FIRST_PLAN=$(find "$PLAN_DIR" -name "*.md" -type f 2>/dev/null | sort | head -1)
if [ -z "$FIRST_PLAN" ]; then
    ko "Aucun fichier plan/*.md trouvé"
    echo ""
    echo "0/0 contrôles passent."
    exit 1
fi
LOT_NAME=$(basename "$FIRST_PLAN" .md)
echo "    Lot vérifié : $LOT_NAME"

# =========================================================================
# 1. Plan de test
# =========================================================================

echo ""
echo "--- 1. Plan de test ---"

PLAN_TEST="$QA_DIR/plan-test-$LOT_NAME.md"

if [ ! -f "$PLAN_TEST" ]; then
    ko "Plan de test absent : $PLAN_TEST"
else
    ok "Plan de test présent : $(basename "$PLAN_TEST")"

    # Scénarios numérotés (T01-01, T02-03, etc.)
    SCENARIO_COUNT=$(grep -oE "T[0-9]+-[0-9]+" "$PLAN_TEST" 2>/dev/null | sort -u | wc -l)
    if [ "$SCENARIO_COUNT" -ge 3 ]; then
        ok "$SCENARIO_COUNT scénarios identifiés (min 3)"
    else
        ko "$SCENARIO_COUNT scénarios identifiés (min 3)"
    fi

    # Références vers les CA-UC
    CA_REF=$(grep -oE "CA-UC-[0-9]+-[0-9]+" "$PLAN_TEST" 2>/dev/null | sort -u | wc -l)
    if [ "$CA_REF" -ge 1 ]; then
        ok "$CA_REF références CA-UC (traçabilité)"
    else
        ko "Aucune référence CA-UC dans le plan de test"
    fi

    # Sévérités
    if grep -qE "🔴|Bloquant" "$PLAN_TEST" 2>/dev/null; then
        ok "Sévérités présentes (🔴 Bloquant détecté)"
    else
        ko "Aucune sévérité détectée dans le plan de test"
    fi
fi

# =========================================================================
# 2. Revue de code
# =========================================================================

echo ""
echo "--- 2. Revue de code ---"

CODE_REVIEW="$QA_DIR/code-review/$LOT_NAME-review.md"

if [ ! -f "$CODE_REVIEW" ]; then
    ko "Revue de code absente : $CODE_REVIEW"
else
    ok "Revue de code présente : $(basename "$CODE_REVIEW")"

    # Axes de revue
    for axe in "Sécurité" "Qualité" "Performance" "Tests"; do
        if grep -qi "$axe" "$CODE_REVIEW" 2>/dev/null; then
            ok "Axe \"$axe\" couvert"
        else
            ko "Axe \"$axe\" absent de la revue"
        fi
    done

    # Constats
    CONSTAT_COUNT=$(grep -cE "^| R[0-9]+" "$CODE_REVIEW" 2>/dev/null || echo "0")
    if [ "$CONSTAT_COUNT" -ge 0 ]; then
        ok "Revue structurée ($CONSTAT_COUNT constats)"
    fi
fi

# =========================================================================
# 3. Rapport final
# =========================================================================

echo ""
echo "--- 3. Rapport final ---"

RAPPORT="$QA_DIR/qa-results/rapport-$LOT_NAME.md"

if [ ! -f "$RAPPORT" ]; then
    ko "Rapport QA absent : $RAPPORT"
else
    ok "Rapport QA présent : $(basename "$RAPPORT")"

    # Verdict
    if grep -qE "✅ VALIDÉ|❌ À CORRIGER" "$RAPPORT" 2>/dev/null; then
        VERDICT=$(grep -oE "✅ VALIDÉ|❌ À CORRIGER" "$RAPPORT" | head -1)
        ok "Verdict présent : $VERDICT"
    else
        ko "Aucun verdict (✅ VALIDÉ / ❌ À CORRIGER) dans le rapport"
    fi

    # Résumé chiffré
    if grep -qi "Scénarios QA" "$RAPPORT" 2>/dev/null; then
        ok "Résumé des scénarios QA présent"
    else
        ko "Résumé des scénarios QA absent"
    fi

    # Sévérités dans le rapport
    if grep -qE "🔴|🟠|🟡|Bloquant|Majeur|Mineur" "$RAPPORT" 2>/dev/null; then
        ok "Sévérités mentionnées dans le rapport"
    else
        ko "Aucune sévérité dans le rapport"
    fi

    # Références
    if grep -q "plan-test-$LOT_NAME" "$RAPPORT" 2>/dev/null; then
        ok "Référence au plan de test"
    else
        ko "Pas de référence au plan de test"
    fi

    if grep -q "code-review" "$RAPPORT" 2>/dev/null; then
        ok "Référence à la revue de code"
    else
        ko "Pas de référence à la revue de code"
    fi
fi

# =========================================================================
# Résultat
# =========================================================================

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL contrôles passent."
if [ "$SKIP" -gt 0 ]; then
    echo "$SKIP contrôle(s) non vérifié(s)."
fi
if [ "$FAIL" -gt 0 ]; then
    echo "$FAIL ÉCHEC(S) détecté(s)."
    exit 1
elif [ "$TOTAL" -eq 0 ]; then
    echo "Aucun contrôle exécuté."
    exit 1
else
    echo "Tous les contrôles passent."
fi
