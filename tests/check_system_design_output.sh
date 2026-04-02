#!/bin/bash
# =============================================================================
# Contrôles déterministes des documents produits par sdd-uc-system-design
# Usage: ./tests/check_system_design_output.sh [chemin_du_projet]
# Par défaut : tests/output
#
# Vérifie la qualité structurelle de :
#   - docs/ARCHITECTURE.md
#   - docs/DEPLOYMENT.md
#   - docs/SECURITY.md
#   - docs/COMPLIANCE_MATRIX.md (optionnel)
#
# Ce script ne lance PAS Claude — il valide des documents déjà produits.
# =============================================================================

set -euo pipefail

PROJECT_DIR="${1:-tests/output}"
DOCS_DIR="$PROJECT_DIR/docs"

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

count_unique() {
    local pattern="$1"
    local file="$2"
    grep -oE "$pattern" "$file" 2>/dev/null | sort -u | wc -l
}

check_section() {
    local file="$1"
    local section="$2"
    if grep -qi "$section" "$file"; then
        ok "\"$section\""
    else
        ko "\"$section\" ABSENTE"
    fi
}

check_min_count() {
    local file="$1"
    local pattern="$2"
    local label="$3"
    local min="$4"
    local count
    count=$(count_unique "$pattern" "$file")
    if [ "$count" -ge "$min" ]; then
        ok "$label : $count (min $min)"
    else
        ko "$label : $count < $min"
    fi
}

echo ""
echo "=== Contrôles des documents produits par sdd-uc-system-design ==="
echo "    Répertoire : $DOCS_DIR"

# =========================================================================
# ARCHITECTURE.md
# =========================================================================

echo ""
echo "--- ARCHITECTURE.md ---"

ARCH="$DOCS_DIR/ARCHITECTURE.md"

if [ ! -f "$ARCH" ]; then
    skip "ARCHITECTURE.md absent — lancer le skill d'abord"
else
    echo "  Sections obligatoires :"
    for section in \
        "Vue d'ensemble" \
        "Principes d'architecture" \
        "Stack technique" \
        "Choix technologiques" \
        "Pérennité" \
        "Coût de fonctionnement" \
        "Architecture détaillée" \
        "Composants" \
        "Matrice de traçabilité" \
        "Diagrammes de flux" \
        "Diagrammes de séquence" \
        "Diagrammes de transition" \
        "Inventaire des données" \
        "Propriétés non-fonctionnelles" \
        "Décisions d'architecture" \
        "Structure du répertoire" \
        "Glossaire technique" \
        "Documents de référence"; do
        check_section "$ARCH" "$section"
    done

    echo "  Traçabilité SPEC.md :"
    check_min_count "$ARCH" "UC-[0-9]+" "Références UC" 3
    check_min_count "$ARCH" "RG-[0-9]+" "Références RG" 1
    check_min_count "$ARCH" "ENF-[0-9]+" "Références ENF" 1

    echo "  Diagrammes Mermaid :"
    MERMAID_COUNT=$(grep -c '```mermaid' "$ARCH" 2>/dev/null || echo "0")
    if [ "$MERMAID_COUNT" -ge 3 ]; then
        ok "Diagrammes Mermaid : $MERMAID_COUNT (min 3)"
    else
        ko "Diagrammes Mermaid : $MERMAID_COUNT < 3"
    fi

    echo "  Contenu structurel :"
    # Matrice UC → Composants (doit avoir au moins 2 lignes de données)
    UC_MATRIX_LINES=$(grep -cE '^\| UC-[0-9]+' "$ARCH" 2>/dev/null || echo "0")
    if [ "$UC_MATRIX_LINES" -ge 2 ]; then
        ok "Matrice UC → Composants : $UC_MATRIX_LINES lignes"
    else
        ko "Matrice UC → Composants : $UC_MATRIX_LINES lignes (min 2)"
    fi

    # ADR (au moins 1 décision)
    ADR_COUNT=$(grep -cE '^### ADR-[0-9]+' "$ARCH" 2>/dev/null || echo "0")
    if [ "$ADR_COUNT" -ge 1 ]; then
        ok "Décisions d'architecture (ADR) : $ADR_COUNT"
    else
        ko "Décisions d'architecture (ADR) : aucune trouvée"
    fi

    # Hors périmètre architectural
    if grep -qi "hors périmètre" "$ARCH"; then
        ok "Hors périmètre architectural documenté"
    else
        ko "Hors périmètre architectural absent"
    fi
fi

# =========================================================================
# DEPLOYMENT.md
# =========================================================================

echo ""
echo "--- DEPLOYMENT.md ---"

DEPL="$DOCS_DIR/DEPLOYMENT.md"

if [ ! -f "$DEPL" ]; then
    skip "DEPLOYMENT.md absent — lancer le skill d'abord"
else
    echo "  Sections obligatoires (tronc commun) :"
    for section in \
        "Vue d'ensemble" \
        "Prérequis" \
        "Environnements" \
        "Configuration par environnement" \
        "Procédure de build" \
        "Procédure de déploiement" \
        "Rollback" \
        "Pipeline CI/CD" \
        "Health check" \
        "Monitoring" \
        "Sauvegarde" \
        "Disaster recovery"; do
        check_section "$DEPL" "$section"
    done

    echo "  Contenu structurel :"
    # RPO/RTO
    if grep -qi "RPO" "$DEPL" && grep -qi "RTO" "$DEPL"; then
        ok "RPO et RTO documentés"
    else
        ko "RPO et/ou RTO absents"
    fi

    # Référence à ARCHITECTURE.md
    if grep -q "ARCHITECTURE.md" "$DEPL"; then
        ok "Renvoi vers ARCHITECTURE.md présent"
    else
        ko "Aucun renvoi vers ARCHITECTURE.md"
    fi
fi

# =========================================================================
# SECURITY.md
# =========================================================================

echo ""
echo "--- SECURITY.md ---"

SEC="$DOCS_DIR/SECURITY.md"

if [ ! -f "$SEC" ]; then
    skip "SECURITY.md absent — lancer le skill d'abord"
else
    echo "  Sections obligatoires :"
    for section in \
        "Vue d'ensemble" \
        "Modèle de menaces" \
        "Surface d'attaque" \
        "Frontières de confiance" \
        "Exigences de sécurité organisationnelles" \
        "Authentification" \
        "Gestion des sessions" \
        "Protection des données" \
        "Protection applicative" \
        "Gestion des erreurs" \
        "Sécurité des API" \
        "Journalisation" \
        "Principes de développement sécurisé" \
        "SDLC" \
        "Réponse à incident"; do
        check_section "$SEC" "$section"
    done

    echo "  Identifiants de sécurité :"
    check_min_count "$SEC" "SEC-[A-Z]+-[0-9]+" "Exigences SEC-*" 10

    echo "  Contenu structurel :"
    # Référence à ARCHITECTURE.md
    if grep -q "ARCHITECTURE.md" "$SEC"; then
        ok "Renvoi vers ARCHITECTURE.md présent"
    else
        ko "Aucun renvoi vers ARCHITECTURE.md"
    fi

    # Référence à OWASP ou ANSSI
    if grep -qi "OWASP\|ANSSI" "$SEC"; then
        ok "Référentiel de sécurité cité (OWASP/ANSSI)"
    else
        ko "Aucun référentiel de sécurité cité"
    fi
fi

# =========================================================================
# COMPLIANCE_MATRIX.md (optionnel)
# =========================================================================

echo ""
echo "--- COMPLIANCE_MATRIX.md (optionnel) ---"

COMP="$DOCS_DIR/COMPLIANCE_MATRIX.md"

if [ ! -f "$COMP" ]; then
    skip "COMPLIANCE_MATRIX.md absent (normal si pas de cadre réglementaire)"
else
    echo "  Sections obligatoires :"
    for section in \
        "Contexte réglementaire" \
        "Périmètre de conformité" \
        "Légende des statuts" \
        "Synthèse de conformité"; do
        check_section "$COMP" "$section"
    done

    echo "  Contenu structurel :"
    # Au moins un référentiel
    REF_COUNT=$(grep -cE '^\| .+-[0-9]+' "$COMP" 2>/dev/null || echo "0")
    if [ "$REF_COUNT" -ge 1 ]; then
        ok "Exigences de conformité : $REF_COUNT lignes"
    else
        ko "Aucune exigence de conformité trouvée"
    fi

    # Colonnes Responsable et Échéance
    if grep -qi "Responsable" "$COMP"; then
        ok "Colonne Responsable présente"
    else
        ko "Colonne Responsable absente"
    fi
    if grep -qi "Échéance" "$COMP"; then
        ok "Colonne Échéance présente"
    else
        ko "Colonne Échéance absente"
    fi

    # Renvoi vers SPEC.md
    if grep -qE "UC-[0-9]+|ENF-[0-9]+" "$COMP"; then
        ok "Références UC/ENF vers SPEC.md présentes"
    else
        ko "Aucune référence UC/ENF vers SPEC.md"
    fi
fi

# =========================================================================
# Résultat
# =========================================================================

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL contrôles passent."
if [ "$SKIP" -gt 0 ]; then
    echo "$SKIP document(s) absent(s) — non vérifié(s)."
fi
if [ "$FAIL" -gt 0 ]; then
    echo "$FAIL ÉCHEC(S) détecté(s)."
    exit 1
elif [ "$TOTAL" -eq 0 ]; then
    echo "Aucun document à vérifier."
    exit 1
else
    echo "Tous les contrôles passent."
fi
