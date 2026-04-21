# Skill Testing — État au 2026-04-20

## Infrastructure en place

Tests end-to-end avec CDC MaintiX (maintenance industrielle).
Le `make test` couvre le pipeline complet :

| # | Étape | Cible make | Type | Statut |
|---|-------|-----------|------|--------|
| 1 | Structurel tous skills | test-skills-check-structure | Déterministe | ✅ En place |
| 2 | Génération CLAUDE.md | test-init | Claude | ✅ En place |
| 3 | Production SPEC racine | test-uc-spec-racine | Claude | ✅ En place |
| 4 | Production SPEC extension | test-uc-spec-extension | Claude | ✅ En place |
| 5 | Revue SPEC racine | test-uc-spec-racine-review-content | Claude | ✅ En place |
| 6 | Revue SPEC extension | test-uc-spec-extension-review-content | Claude | ✅ En place |
| 7 | Production docs conception | test-uc-system-design | Claude | ✅ En place |
| 8 | Planification en lots | test-plan | Claude | ✅ En place |
| 9 | Développement premier lot | test-dev-workflow | Claude | ✅ En place |
| 10 | QA premier lot | test-qa-workflow | Claude | ✅ En place |
| 11 | Brief projet | test-brief | Claude | ✅ En place |
| 12 | Tutoriel | test-tuto | Claude | ✅ En place (hors chaîne) |
| 13 | Contrôles SPEC racine | test-uc-spec-racine-check-structure | Déterministe | ✅ En place |
| 14 | Contrôles SPEC extension | test-uc-spec-extension-check-structure | Déterministe | ✅ En place |
| 15 | Contrôles conception | test-uc-system-design-check-structure | Déterministe | ✅ En place |
| 16 | Contrôles plan | test-plan-check-structure | Déterministe | ✅ En place |
| 17 | Contrôles dev | test-dev-workflow-check-structure | Déterministe | ✅ En place |
| 18 | Contrôles QA | test-qa-workflow-check-structure | Déterministe | ✅ En place |
| 19 | Contrôles brief | test-brief-check-structure | Déterministe | ✅ En place |

## Isolation des skills

`test-setup` sauvegarde `~/.claude/skills/` et le remplace par les skills
du repo. `clean-test` restaure. Garantit que les tests utilisent les
bonnes versions.

## Reste à faire

- Exécution complète du `make test` pour valider toute la chaîne
- Ajuster les seuils des contrôles déterministes après la première exécution
