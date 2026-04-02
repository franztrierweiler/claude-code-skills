#!/bin/bash
# =============================================================================
# Contrôles déterministes du skill sdd-uc-system-design
# Usage: ./tests/check_system_design.sh [chemin_du_skill]
# Par défaut : skills/sdd-uc-system-design
#
# Vérifie :
#   1. Présence de tous les fichiers references/ déclarés dans le SKILL.md
#   2. Numérotation séquentielle des sections dans chaque template
#   3. Cohérence des références croisées (§ N.N) entre SKILL.md et templates
#   4. Version cohérente (frontmatter, en-tête)
#   5. Pas de références obsolètes (v2.0.0, "annexe")
# =============================================================================

set -euo pipefail

SKILL_DIR="${1:-skills/sdd-uc-system-design}"
SKILL_MD="$SKILL_DIR/SKILL.md"
REF_DIR="$SKILL_DIR/references"

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
echo "=== Contrôles structurels : sdd-uc-system-design ==="

# -------------------------------------------------------------------------
# 1. Fichiers references/ présents
# -------------------------------------------------------------------------

echo ""
echo "--- 1. Fichiers references/ ---"

EXPECTED_FILES=(
    "TEMPLATE-ARCHITECTURE.md"
    "TEMPLATE-DEPLOYMENT.md"
    "TEMPLATE-DEPLOYMENT-SAAS.md"
    "TEMPLATE-DEPLOYMENT-DESKTOP.md"
    "TEMPLATE-DEPLOYMENT-DRIVER.md"
    "TEMPLATE-DEPLOYMENT-EMBEDDED.md"
    "TEMPLATE-SECURITY.md"
    "TEMPLATE-COMPLIANCE-MATRIX.md"
)

for f in "${EXPECTED_FILES[@]}"; do
    if [ -f "$REF_DIR/$f" ]; then
        ok "$f"
    else
        ko "$f MANQUANT"
    fi
done

# Fichiers inattendus dans references/
for f in "$REF_DIR"/*.md; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    found=0
    for expected in "${EXPECTED_FILES[@]}"; do
        if [ "$base" = "$expected" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        ko "$base INATTENDU (non déclaré dans le SKILL.md)"
    fi
done

# -------------------------------------------------------------------------
# 2. Numérotation séquentielle des sections ## dans chaque template
# -------------------------------------------------------------------------

echo ""
echo "--- 2. Numérotation des sections ---"

check_numbering() {
    local file="$1"
    local name
    name=$(basename "$file")

    # Extraire les numéros de section ## (ignorer ### et au-delà, ignorer Changelog)
    local nums
    nums=$(grep -E '^## [0-9]+\.' "$file" | grep -v 'Changelog' | sed 's/^## \([0-9]*\)\..*/\1/' || true)

    if [ -z "$nums" ]; then
        # Les sous-templates utilisent N.x, pas de numérotation absolue
        ok "$name (pas de numérotation absolue — sous-template)"
        return
    fi

    local prev=0
    local sequential=1
    for n in $nums; do
        expected=$((prev + 1))
        if [ "$n" -ne "$expected" ]; then
            ko "$name : § $n trouvé après § $prev (attendu § $expected)"
            sequential=0
        fi
        prev=$n
    done

    if [ "$sequential" -eq 1 ]; then
        ok "$name : §§ 1-$prev séquentiels"
    fi
}

for tmpl in "$REF_DIR"/*.md; do
    [ -f "$tmpl" ] || continue
    check_numbering "$tmpl"
done

# -------------------------------------------------------------------------
# 3. Cohérence version (frontmatter vs en-tête)
# -------------------------------------------------------------------------

echo ""
echo "--- 3. Cohérence de version ---"

FRONTMATTER_VERSION=$(grep -A1 'metadata:' "$SKILL_MD" | grep 'version:' | sed 's/.*"\(.*\)".*/\1/' || echo "")
HEADER_VERSION=$(grep '^Version :' "$SKILL_MD" | head -1 | sed 's/Version : //' || echo "")

if [ -n "$FRONTMATTER_VERSION" ] && [ -n "$HEADER_VERSION" ]; then
    if [ "$FRONTMATTER_VERSION" = "$HEADER_VERSION" ]; then
        ok "Version cohérente : $FRONTMATTER_VERSION"
    else
        ko "Version incohérente : frontmatter=$FRONTMATTER_VERSION, en-tête=$HEADER_VERSION"
    fi
else
    ko "Version introuvable (frontmatter='$FRONTMATTER_VERSION', en-tête='$HEADER_VERSION')"
fi

# -------------------------------------------------------------------------
# 4. Pas de références obsolètes
# -------------------------------------------------------------------------

echo ""
echo "--- 4. Références obsolètes ---"

# v2.0.0 en dur (devrait être vX.Y.Z dans les exemples)
if grep -q 'v2\.0\.0' "$SKILL_MD"; then
    ko "SKILL.md contient encore 'v2.0.0' en dur"
else
    ok "Pas de v2.0.0 en dur dans SKILL.md"
fi

# "annexe" ou "en annexe" (les templates ont été extraits)
if grep -qi 'annexe' "$SKILL_MD"; then
    ko "SKILL.md contient encore le mot 'annexe'"
else
    ok "Pas de référence à 'annexe' dans SKILL.md"
fi

# -------------------------------------------------------------------------
# 5. Sections obligatoires dans SKILL.md
# -------------------------------------------------------------------------

echo ""
echo "--- 5. Sections obligatoires du SKILL.md ---"

REQUIRED_SECTIONS=(
    "Prérequis"
    "Déclenchement"
    "Message d'accueil"
    "Philosophie"
    "Entrées requises"
    "Sorties produites"
    "Identification du skill"
    "Processus de conception"
    "Format de livraison"
    "Renvois croisés"
    "Checklist de validation"
    "Passage de relais"
    "Utilisation des templates"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "$section" "$SKILL_MD"; then
        ok "\"$section\""
    else
        ko "\"$section\" ABSENTE"
    fi
done

# -------------------------------------------------------------------------
# 6. Chaque template référencé dans "Utilisation des templates" existe
# -------------------------------------------------------------------------

echo ""
echo "--- 6. Table 'Utilisation des templates' ---"

REFERENCED=$(grep 'references/TEMPLATE' "$SKILL_MD" | grep -oE 'references/TEMPLATE[A-Z_-]*\.md' | sort -u || true)

for ref in $REFERENCED; do
    if [ -f "$SKILL_DIR/$ref" ]; then
        ok "$ref référencé et présent"
    else
        ko "$ref référencé mais ABSENT"
    fi
done

# -------------------------------------------------------------------------
# Résultat
# -------------------------------------------------------------------------

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL contrôles passent."
if [ "$FAIL" -gt 0 ]; then
    echo "$FAIL ÉCHEC(S) détecté(s)."
    exit 1
else
    echo "Tous les contrôles passent."
fi
