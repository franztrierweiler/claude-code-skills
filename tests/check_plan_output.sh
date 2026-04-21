#!/bin/bash
# =============================================================================
# Contrôles déterministes des fichiers de plan produits par sdd-plan
# Usage: ./tests/check_plan_output.sh [chemin_du_projet]
# Par défaut : tests/output
#
# Vérifie :
#   1. Fichiers plan/*.md présents
#   2. Format de chaque fichier (sections obligatoires)
#   3. Références UC et AC traçables vers le SPEC.md
#   4. Dépendances entre lots cohérentes
#   5. Couverture des UC du SPEC.md
# =============================================================================

set -euo pipefail

PROJECT_DIR="${1:-tests/output}"
# Préfère le snapshot pris juste après run_plan (avant que sdd-dev-workflow
# ne modifie les AC). Fallback sur plan/ si le snapshot n'existe pas (ex :
# exécution isolée de 'make test-plan').
if [ -d "$PROJECT_DIR/plan-initial" ]; then
    PLAN_DIR="$PROJECT_DIR/plan-initial"
else
    PLAN_DIR="$PROJECT_DIR/plan"
fi
SPEC=$(find "$PROJECT_DIR/docs" -maxdepth 1 -name 'SPEC-racine-*.md' -type f 2>/dev/null | head -1)
if [ -z "$SPEC" ]; then
    # Fallback sur l'ancien nommage pour compatibilité
    SPEC="$PROJECT_DIR/docs/SPEC.md"
fi

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
echo "=== Contrôles des fichiers de plan (sdd-plan) ==="
echo "    Répertoire : $PLAN_DIR"

# =========================================================================
# 1. Fichiers présents
# =========================================================================

echo ""
echo "--- 1. Fichiers de plan ---"

if [ ! -d "$PLAN_DIR" ]; then
    ko "Répertoire plan/ absent"
    echo ""
    echo "0/0 contrôles passent."
    echo "Lancer 'make test-plan' d'abord."
    exit 1
fi

PLAN_COUNT=$(find "$PLAN_DIR" -name "*.md" -type f | wc -l)
if [ "$PLAN_COUNT" -ge 2 ]; then
    ok "$PLAN_COUNT lots trouvés (min 2)"
else
    ko "$PLAN_COUNT lot(s) trouvé(s) — minimum attendu : 2"
fi

if [ "$PLAN_COUNT" -le 8 ]; then
    ok "$PLAN_COUNT lots (max 8)"
else
    ko "$PLAN_COUNT lots — maximum recommandé : 8"
fi

echo "  Lots :"
for plan in "$PLAN_DIR"/*.md; do
    [ -f "$plan" ] || continue
    echo "    - $(basename "$plan")"
done

# =========================================================================
# 2. Format de chaque fichier
# =========================================================================

echo ""
echo "--- 2. Format des fichiers de plan ---"

REQUIRED_SECTIONS=(
    "Objectif"
    "UC couverts"
    "Dépendances"
    "Fonctionnalités"
    "Critères d'acceptation"
)

for plan in "$PLAN_DIR"/*.md; do
    [ -f "$plan" ] || continue
    name=$(basename "$plan" .md)
    missing=0

    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -qi "$section" "$plan"; then
            ko "$name : section \"$section\" absente"
            missing=1
        fi
    done

    if [ "$missing" -eq 0 ]; then
        ok "$name : toutes les sections obligatoires présentes"
    fi
done

# =========================================================================
# 3. Références UC et AC
# =========================================================================

echo ""
echo "--- 3. Traçabilité UC et AC ---"

for plan in "$PLAN_DIR"/*.md; do
    [ -f "$plan" ] || continue
    name=$(basename "$plan" .md)

    uc_count=$(grep -oE "UC-([A-Z]{3,4}-)?[0-9]+" "$plan" 2>/dev/null | sort -u | wc -l)
    ac_count=$(grep -oE "CA-UC-([A-Z]{3,4}-)?[0-9]+-[0-9]+" "$plan" 2>/dev/null | sort -u | wc -l)

    if [ "$uc_count" -ge 1 ]; then
        ok "$name : $uc_count UC référencés"
    else
        ko "$name : aucun UC référencé"
    fi

    if [ "$ac_count" -ge 1 ]; then
        ok "$name : $ac_count AC référencés"
    else
        ko "$name : aucun AC (CA-UC-xxx-yy) référencé"
    fi
done

# =========================================================================
# 4. Dépendances entre lots
# =========================================================================

echo ""
echo "--- 4. Dépendances ---"

# Le premier lot (trié par nom) ne doit pas avoir de dépendances
FIRST_PLAN=$(find "$PLAN_DIR" -name "*.md" -type f | sort | head -1)
if [ -n "$FIRST_PLAN" ]; then
    name=$(basename "$FIRST_PLAN" .md)
    if grep -qi "aucune\|—\|none" "$FIRST_PLAN" 2>/dev/null | head -1; then
        ok "$name (premier lot) : pas de dépendances"
    elif grep -qi "Dépendances" "$FIRST_PLAN"; then
        # Vérifier que la section dépendances contient "aucune" ou équivalent
        deps_section=$(sed -n '/^## Dépendances/,/^##/p' "$FIRST_PLAN" 2>/dev/null | grep -vi "^##")
        if echo "$deps_section" | grep -qi "aucune\|—\|none\|pas de"; then
            ok "$name (premier lot) : pas de dépendances"
        else
            ko "$name (premier lot) : a des dépendances — devrait être autonome"
        fi
    else
        skip "$name : section Dépendances non trouvée"
    fi
fi

# =========================================================================
# 5. Couverture des UC du SPEC.md
# =========================================================================

echo ""
echo "--- 5. Couverture des UC ---"

if [ ! -f "$SPEC" ]; then
    skip "SPEC.md absent — impossible de vérifier la couverture"
else
    # UC dans le SPEC (racine + extensions)
    SPEC_UCS=$(grep -oE "UC-([A-Z]{3,4}-)?[0-9]+" "$SPEC" 2>/dev/null | sort -u)
    # Ajouter les UC des extensions si présentes
    for ext in "$PROJECT_DIR/docs"/SPEC-extension-*.md; do
        [ -f "$ext" ] || continue
        ext_ucs=$(grep -oE "UC-([A-Z]{3,4}-)?[0-9]+" "$ext" 2>/dev/null | sort -u)
        SPEC_UCS=$(printf "%s\n%s" "$SPEC_UCS" "$ext_ucs" | sort -u)
    done
    SPEC_UC_COUNT=$(echo "$SPEC_UCS" | grep -c "UC-" || true)
    SPEC_UC_COUNT=${SPEC_UC_COUNT:-0}

    # UC dans tous les plans
    PLAN_UCS=$(cat "$PLAN_DIR"/*.md 2>/dev/null | grep -oE "UC-([A-Z]{3,4}-)?[0-9]+" | sort -u)
    PLAN_UC_COUNT=$(echo "$PLAN_UCS" | grep -c "UC-" || true)
    PLAN_UC_COUNT=${PLAN_UC_COUNT:-0}

    if [ "$PLAN_UC_COUNT" -ge 1 ]; then
        ok "$PLAN_UC_COUNT UC couverts par les lots (SPEC.md en contient $SPEC_UC_COUNT)"
    else
        ko "Aucun UC couvert par les lots"
    fi

    # UC du SPEC.md non couverts
    MISSING_UCS=$(comm -23 <(echo "$SPEC_UCS") <(echo "$PLAN_UCS") 2>/dev/null)
    MISSING_COUNT=$(echo "$MISSING_UCS" | grep -c "UC-" || true)
    MISSING_COUNT=${MISSING_COUNT:-0}

    if [ "$MISSING_COUNT" -eq 0 ]; then
        ok "Tous les UC du SPEC.md sont couverts"
    else
        ko "$MISSING_COUNT UC du SPEC.md non couverts : $(echo $MISSING_UCS | tr '\n' ' ')"
    fi
fi

# =========================================================================
# 6. Statut initial des AC
# =========================================================================

echo ""
echo "--- 6. Statut initial des AC ---"

# Tous les AC doivent être en ⏳ (pas encore implémentés)
RESOLVED=$(cat "$PLAN_DIR"/*.md 2>/dev/null | grep -cE "✅|❌" || true)
RESOLVED=${RESOLVED:-0}
PENDING=$(cat "$PLAN_DIR"/*.md 2>/dev/null | grep -c "⏳" || true)
PENDING=${PENDING:-0}

if [ "$PENDING" -ge 1 ]; then
    ok "$PENDING AC en statut ⏳ (à implémenter)"
else
    ko "Aucun AC en statut ⏳"
fi

if [ "$RESOLVED" -eq 0 ]; then
    ok "Aucun AC pré-résolu (normal pour un plan initial)"
else
    ko "$RESOLVED AC déjà résolus dans le plan initial — suspect"
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
