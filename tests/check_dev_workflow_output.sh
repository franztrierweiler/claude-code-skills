#!/bin/bash
# =============================================================================
# Contrôles déterministes des sorties du workflow de développement
# Usage: ./tests/check_dev_workflow_output.sh [chemin_du_projet]
# Par défaut : tests/output
#
# Vérifie :
#   1. Fichiers de plan (plan/*.md) présents avec contenu structuré
#   2. Code source produit (src/)
#   3. Tests unitaires produits (tests/)
#   4. Makefile avec cibles requises
#   5. Plan mis à jour avec statuts AC
#   6. Tests passent (make test)
# =============================================================================

set -euo pipefail

PROJECT_DIR="${1:-tests/output}"

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
echo "=== Contrôles du workflow de développement ==="
echo "    Répertoire : $PROJECT_DIR"

# =========================================================================
# 1. Fichiers de plan
# =========================================================================

echo ""
echo "--- 1. Planification ---"

PLAN_DIR="$PROJECT_DIR/plan"

if [ ! -d "$PLAN_DIR" ]; then
    ko "Répertoire plan/ absent"
else
    PLAN_COUNT=$(find "$PLAN_DIR" -name "*.md" -type f | wc -l)
    if [ "$PLAN_COUNT" -ge 1 ]; then
        ok "plan/ contient $PLAN_COUNT fichier(s)"
    else
        ko "plan/ est vide"
    fi

    # Vérifier que les plans contiennent des AC
    AC_IN_PLANS=$(grep -rl "CA-UC-[0-9]" "$PLAN_DIR" 2>/dev/null | wc -l)
    if [ "$AC_IN_PLANS" -ge 1 ]; then
        ok "$AC_IN_PLANS plan(s) contiennent des références AC (CA-UC-xxx-yy)"
    else
        ko "Aucun plan ne contient de références AC"
    fi

    # Vérifier que les plans contiennent des UC
    UC_IN_PLANS=$(grep -rl "UC-[0-9]" "$PLAN_DIR" 2>/dev/null | wc -l)
    if [ "$UC_IN_PLANS" -ge 1 ]; then
        ok "$UC_IN_PLANS plan(s) contiennent des références UC"
    else
        ko "Aucun plan ne contient de références UC"
    fi

    # Lister les lots trouvés
    echo "  Lots trouvés :"
    for plan in "$PLAN_DIR"/*.md; do
        [ -f "$plan" ] || continue
        name=$(basename "$plan" .md)
        ac_count=$(grep -cE "CA-UC-[0-9]+-[0-9]+" "$plan" 2>/dev/null || echo "0")
        echo "    - $name ($ac_count AC)"
    done
fi

# =========================================================================
# 2. Code source
# =========================================================================

echo ""
echo "--- 2. Code source ---"

SRC_DIR="$PROJECT_DIR/src"

if [ ! -d "$SRC_DIR" ]; then
    ko "Répertoire src/ absent — aucun code produit"
else
    PY_COUNT=$(find "$SRC_DIR" -name "*.py" -type f | wc -l)
    if [ "$PY_COUNT" -ge 1 ]; then
        ok "src/ contient $PY_COUNT fichier(s) Python"
    else
        ko "src/ ne contient aucun fichier Python"
    fi

    # Vérifier qu'au moins un fichier fait plus de 5 lignes (pas juste des __init__.py)
    SUBSTANTIAL=$(find "$SRC_DIR" -name "*.py" -type f -exec sh -c 'test $(wc -l < "$1") -gt 5' _ {} \; -print 2>/dev/null | wc -l)
    if [ "$SUBSTANTIAL" -ge 1 ]; then
        ok "$SUBSTANTIAL fichier(s) Python substantiel(s) (> 5 lignes)"
    else
        ko "Aucun fichier Python substantiel (tous ≤ 5 lignes)"
    fi
fi

# =========================================================================
# 3. Tests unitaires
# =========================================================================

echo ""
echo "--- 3. Tests unitaires ---"

TESTS_DIR="$PROJECT_DIR/tests"

if [ ! -d "$TESTS_DIR" ]; then
    ko "Répertoire tests/ absent — aucun test produit"
else
    TEST_COUNT=$(find "$TESTS_DIR" -name "test_*.py" -o -name "*_test.py" | wc -l)
    if [ "$TEST_COUNT" -ge 1 ]; then
        ok "tests/ contient $TEST_COUNT fichier(s) de test"
    else
        ko "tests/ ne contient aucun fichier test_*.py ou *_test.py"
    fi

    # Vérifier la traçabilité (noms de tests contenant ca_uc ou CA_UC)
    TRACEABLE=$(grep -rl "test_ca_uc\|test_CA_UC\|ca_uc_[0-9]" "$TESTS_DIR" 2>/dev/null | wc -l)
    if [ "$TRACEABLE" -ge 1 ]; then
        ok "$TRACEABLE fichier(s) de test avec traçabilité AC (test_ca_uc_*)"
    else
        ko "Aucun test avec traçabilité AC dans le nom"
    fi
fi

# =========================================================================
# 4. Makefile
# =========================================================================

echo ""
echo "--- 4. Makefile ---"

MAKEFILE="$PROJECT_DIR/Makefile"

if [ ! -f "$MAKEFILE" ]; then
    ko "Makefile absent à la racine du projet"
else
    ok "Makefile présent"

    for target in test install lint; do
        if grep -q "^${target}:" "$MAKEFILE" 2>/dev/null; then
            ok "Cible 'make $target' définie"
        else
            ko "Cible 'make $target' absente"
        fi
    done
fi

# =========================================================================
# 5. Plan mis à jour avec statuts AC
# =========================================================================

echo ""
echo "--- 5. Mise à jour du plan ---"

if [ -d "$PLAN_DIR" ]; then
    # Chercher le premier lot (celui implémenté)
    FIRST_PLAN=$(find "$PLAN_DIR" -name "*.md" -type f | sort | head -1)

    if [ -n "$FIRST_PLAN" ]; then
        name=$(basename "$FIRST_PLAN" .md)
        echo "  Plan vérifié : $name"

        # Vérifier que des AC ont un statut (✅ ou ❌, pas seulement ⏳)
        RESOLVED_AC=$(grep -cE "✅|❌" "$FIRST_PLAN" 2>/dev/null || echo "0")
        if [ "$RESOLVED_AC" -ge 1 ]; then
            ok "$RESOLVED_AC AC avec statut résolu (✅/❌) dans $name"
        else
            ko "Aucun AC résolu dans $name — le plan n'a pas été mis à jour"
        fi
    else
        skip "Aucun fichier de plan trouvé"
    fi
else
    skip "Répertoire plan/ absent"
fi

# =========================================================================
# 6. Exécution des tests
# =========================================================================

echo ""
echo "--- 6. Exécution des tests ---"

if [ -f "$MAKEFILE" ] && grep -q "^test:" "$MAKEFILE"; then
    echo "  Exécution de 'make test' dans $PROJECT_DIR..."
    if (cd "$PROJECT_DIR" && make test 2>&1); then
        ok "make test réussit"
    else
        ko "make test échoue"
    fi
else
    skip "Pas de Makefile ou pas de cible test — exécution impossible"
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
