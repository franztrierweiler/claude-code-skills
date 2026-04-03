#!/bin/bash
# =============================================================================
# Contrôles déterministes de la sortie de /sdd-brief
# Usage: ./tests/check_brief_output.sh <fichier-log>
# Par défaut : tests/log/brief.log
#
# Vérifie que le brief contient les éléments attendus.
# Le brief est une sortie chat (pas un fichier produit), donc on vérifie
# le log de la session Claude.
# =============================================================================

set -euo pipefail

LOG_FILE="${1:-tests/log/brief.log}"

FAIL=0
PASS=0

ok() {
    echo "  ✓ $1"
    PASS=$((PASS + 1))
}

ko() {
    echo "  ✗ $1"
    FAIL=$((FAIL + 1))
}

echo ""
echo "=== Contrôles de la sortie /sdd-brief ==="
echo "    Log : $LOG_FILE"

if [ ! -f "$LOG_FILE" ]; then
    echo "  ❌ Fichier log absent. Lancer 'make test-brief' d'abord."
    exit 1
fi

echo ""
echo "--- Éléments attendus dans le brief ---"

# Tableau des livrables
if grep -qi "SPEC.md" "$LOG_FILE" && grep -qi "ARCHITECTURE.md" "$LOG_FILE"; then
    ok "Livrables SDD mentionnés (SPEC.md, ARCHITECTURE.md)"
else
    ko "Livrables SDD non mentionnés"
fi

# Statut des livrables (✅ ou ❌ ou Présent/Absent)
if grep -qE "✅|❌|Présent|Absent" "$LOG_FILE"; then
    ok "Statuts des livrables affichés"
else
    ko "Aucun statut de livrable détecté"
fi

# Phase courante
if grep -qi "Phase" "$LOG_FILE"; then
    ok "Phase courante mentionnée"
else
    ko "Phase courante absente"
fi

# Skills disponibles
if grep -qi "sdd-uc-spec-write" "$LOG_FILE" && grep -qi "sdd-uc-system-design" "$LOG_FILE"; then
    ok "Skills SDD listés"
else
    ko "Skills SDD non listés"
fi

# Commandes / skills invocables
if grep -qi "sdd-dev-workflow" "$LOG_FILE" && grep -qi "sdd-qa-workflow" "$LOG_FILE"; then
    ok "Commandes invocables listées (dev-workflow, qa-workflow)"
else
    ko "Commandes invocables non listées"
fi

# Makefile
if grep -qi "Makefile" "$LOG_FILE"; then
    ok "Makefile mentionné"
else
    ko "Makefile non mentionné"
fi

# Conclusion
if grep -qi "Prêt" "$LOG_FILE"; then
    ok "Message de conclusion présent"
else
    ko "Message de conclusion absent"
fi

# Lots / progression (si plan/ existait au moment du brief)
if grep -qi "lot\|plan/" "$LOG_FILE"; then
    ok "Lots ou plans mentionnés"
else
    echo "  ⊘ Lots non mentionnés (normal si exécuté avant la planification)"
fi

# =========================================================================
# Résultat
# =========================================================================

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL contrôles passent."
if [ "$FAIL" -gt 0 ]; then
    echo "$FAIL ÉCHEC(S) détecté(s)."
    exit 1
else
    echo "Tous les contrôles passent."
fi
