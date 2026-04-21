#!/bin/bash
# =============================================================================
# Contrôles structurels de tous les skills SDD
# Usage: ./tests/check_skills_structure.sh [répertoire_skills]
# Par défaut : skills/
#
# Pour chaque skill, vérifie :
#   1. Présence du SKILL.md avec frontmatter valide
#   2. Cohérence de version (frontmatter vs en-tête)
#   3. Fichiers references/ déclarés dans le tableau prérequis existent
#   4. Pas de fichiers inattendus dans references/
# =============================================================================

set -euo pipefail

SKILLS_DIR="${1:-skills}"

FAIL=0
PASS=0
SKIP=0

ok() {
    echo "    ✓ $1"
    PASS=$((PASS + 1))
}

ko() {
    echo "    ✗ $1"
    FAIL=$((FAIL + 1))
}

skip() {
    echo "    ⊘ $1"
    SKIP=$((SKIP + 1))
}

echo ""
echo "=== Contrôles structurels de tous les skills ==="

for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"

    echo ""
    echo "--- $skill_name ---"

    # 1. Présence du SKILL.md
    if [ ! -f "$skill_md" ]; then
        ko "SKILL.md absent"
        continue
    fi
    ok "SKILL.md présent"

    # 2. Frontmatter valide (name et version)
    fm_name=$(grep -A1 '^name:' "$skill_md" | head -1 | sed 's/^name: *//' || true)
    if [ -n "$fm_name" ]; then
        ok "Frontmatter name: $fm_name"
    else
        ko "Frontmatter name absent"
    fi

    fm_version=$(grep -A1 'metadata:' "$skill_md" | grep 'version:' | sed 's/.*"\(.*\)".*/\1/' 2>/dev/null || true)
    header_version=$(grep '^Version :' "$skill_md" | head -1 | sed 's/Version : //' || true)

    if [ -n "$fm_version" ] && [ -n "$header_version" ]; then
        if [ "$fm_version" = "$header_version" ]; then
            ok "Version cohérente : $fm_version"
        else
            ko "Version incohérente : frontmatter=$fm_version, en-tête=$header_version"
        fi
    elif [ -n "$fm_version" ]; then
        ok "Version frontmatter : $fm_version (pas d'en-tête Version)"
    elif [ -n "$header_version" ]; then
        ok "Version en-tête : $header_version (pas de frontmatter version)"
    else
        skip "Aucune version détectée"
    fi

    # 3. Fichiers references/ déclarés dans le tableau prérequis
    ref_dir="$skill_dir/references"
    if [ ! -d "$ref_dir" ]; then
        skip "Pas de répertoire references/"
        continue
    fi

    # Extraire les fichiers référencés dans le SKILL.md (pattern: references/XXXXX.md ou .html)
    declared_refs=$(grep -oE 'references/[A-Za-z0-9_-]+\.(md|html)' "$skill_md" | sort -u || true)

    if [ -z "$declared_refs" ]; then
        skip "Aucune référence déclarée dans SKILL.md"
    else
        for ref in $declared_refs; do
            if [ -f "$skill_dir/$ref" ]; then
                ok "$ref présent"
            else
                ko "$ref déclaré mais ABSENT"
            fi
        done
    fi

    # 4. Fichiers inattendus dans references/
    for f in "$ref_dir"/*; do
        [ -f "$f" ] || continue
        base="references/$(basename "$f")"
        if ! echo "$declared_refs" | grep -qF "$base"; then
            ko "$(basename "$f") dans references/ mais non déclaré dans SKILL.md"
        fi
    done
done

# =========================================================================
# Résultat
# =========================================================================

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL contrôles passent."
if [ "$SKIP" -gt 0 ]; then
    echo "$SKIP contrôle(s) ignoré(s)."
fi
if [ "$FAIL" -gt 0 ]; then
    echo "$FAIL ÉCHEC(S) détecté(s)."
    exit 1
else
    echo "Tous les contrôles passent."
fi
