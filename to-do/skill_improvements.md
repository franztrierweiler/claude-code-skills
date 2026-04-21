# Skill Improvements — État au 2026-04-21

## Résolu (session du 2026-04-03)

- ✅ Extraction des templates en `references/` (sdd-uc-system-design)
- ✅ Frontmatter YAML complet sur tous les skills
- ✅ Harmonisation des versions (metadata, en-tête, barre de progression)
- ✅ Suppression des variantes non-UC (sdd-spec-write, sdd-system-design)
- ✅ Conversion des commandes en skills (`disable-model-invocation: true`)
- ✅ Remplacement EPIC → lot dans toute la base
- ✅ Compatibilité complète sdd-uc-system-design avec sdd-uc-spec-write v2
- ✅ Templates ARCHITECTURE, SECURITY, DEPLOYMENT, COMPLIANCE enrichis
- ✅ Sous-templates DEPLOYMENT par type (SaaS, Desktop, Driver, Embarqué)
- ✅ Nouveau skill sdd-plan (planification en lots)
- ✅ Nouveau skill sdd-tuto (tutoriel interactif + HTML)
- ✅ sdd-dev-workflow refondu (garde, mode reprise QA, itérations numérotées)
- ✅ sdd-qa-workflow refondu (sévérités, revue sécurité, détection reprise)
- ✅ sdd-brief refondu (livrables, phase courante, tableau skills)
- ✅ Icônes distinctes par skill
- ✅ Tests end-to-end : spec → design → plan → dev → qa → brief

## Résolu (session du 2026-04-14 au 2026-04-21)

### sdd-uc-spec-write v2.4.0
- ✅ Cartouche blockquote avec UUID, Type, Généré par
- ✅ Convention de nommage dynamique (SPEC-racine-\<NomProjet\>.md / SPEC-extension-\<NomProjet\>-\<NomFonction\>.md)
- ✅ Mode 4 — Extension fonctionnelle (template, workflow, identifiants préfixés, checklist)
- ✅ Détection vocabulaire hybride (mode 3 modification vs mode 4 extension)
- ✅ Modes 2/3 polymorphes (racine et extension)
- ✅ UC-FORMAT.md adapté aux identifiants préfixés
- ✅ UPDATE-WORKFLOW.md : avertissement impacts sur extensions
- ✅ Renforcement de l'obligation de la barre de progression

### sdd-uc-system-design v3.3.0
- ✅ Cartouche blockquote sur les 4 templates (sans UUID, sans Type, sans Statut)

### Skills aval (brief 1.2.0, plan 1.1.0, dev-workflow 2.3.0, qa-workflow 2.1.0, tuto 1.1.0)
- ✅ Scan SPEC-racine-*.md / SPEC-extension-*.md au lieu de docs/SPEC.md
- ✅ Gardes d'entrée acceptent racine et/ou extension (sous-projets compatibles)
- ✅ Confirmation du fichier SPEC à traiter
- ✅ tuto.html : références mises à jour

### Tests
- ✅ check_cartouche.py : 8 champs racine + 3 champs extension
- ✅ check_uc_fields.py : regex préfixée UC-([A-Z]{3,4}-)?\d+
- ✅ check_skills_structure.sh : contrôle structurel générique de tous les skills
- ✅ check_plan_output.sh : regex préfixées + couverture extensions
- ✅ Prompt + cible test extension (test-uc-spec-extension)
- ✅ Prompt + cible review extension (test-uc-spec-extension-review-content)
- ✅ Renommage harmonisé de toutes les cibles make (test-*-check-structure, test-*-review-content)
- ✅ stream_filter.py : sortie Claude en orange, suppression doublon
- ✅ Fix bug grep -c || echo "0" dans check_plan_output.sh

## Reste à faire

### Adaptation sdd-uc-system-design pour les extensions
Les documents de conception (ARCHITECTURE, DEPLOYMENT, SECURITY, COMPLIANCE) sont
produits à partir de la spec racine uniquement. Quand des extensions existent, deux
approches possibles :
- A. Documents monolithiques (relire racine + extensions, mettre à jour)
- B. Documents de conception par extension (ARCHITECTURE-Alertes.md, etc.)
Décision reportée — pas bloquant pour le pipeline actuel.

### Taille des SKILL.md
sdd-uc-spec-write dépasse les 500 lignes recommandées par agentskills.io.
L'extraction en fichiers references/ a permis de contenir la croissance.
À surveiller si cela pose un problème en pratique (lecture tronquée sur claude.ai).
