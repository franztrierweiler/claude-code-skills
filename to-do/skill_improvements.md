# Skill Improvements — État au 2026-04-03

## Résolu dans cette session

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

## Reste à faire

### Taille des SKILL.md

Les skills dépassent la recommandation agentskills.io (< 500 lignes).
L'extraction des templates a réduit sdd-uc-system-design mais le SKILL.md
principal reste volumineux. À évaluer si cela pose un problème en pratique.

### sdd-uc-spec-write

Le skill n'a pas été refondu dans cette session (seules la version et
l'icône ont été mises à jour). Des améliorations similaires à celles de
system-design pourraient être appliquées :
- Vérification plus fine de la compatibilité des entrées
- Enrichissement du template SPEC.md
