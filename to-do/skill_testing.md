# Skill Testing — État au 2026-04-03

## Infrastructure en place

Tests end-to-end avec CDC MaintiX (maintenance industrielle).
Le `make test` couvre le pipeline complet :

| # | Étape | Cible make | Type | Statut |
|---|-------|-----------|------|--------|
| 1 | Structurel system-design | test-system-design | Déterministe | ✅ En place |
| 2 | Génération CLAUDE.md | test-init | Claude | ✅ En place |
| 3 | Production SPEC.md | test-uc-spec | Claude | ✅ En place |
| 4 | Évaluation SPEC.md | test-review | Claude | ✅ En place |
| 5 | Production docs conception | test-uc-system-design | Claude | ✅ En place |
| 6 | Planification en lots | test-plan | Claude | ✅ En place |
| 7 | Développement premier lot | test-dev-workflow | Claude | ✅ En place |
| 8 | QA premier lot | test-qa-workflow | Claude | ✅ En place |
| 9 | Brief projet | test-brief | Claude | ✅ En place |
| 10 | Tutoriel | test-tuto | Claude | ✅ En place (hors chaîne) |
| 11 | Contrôles SPEC.md | test-check | Déterministe | ✅ En place |
| 12 | Contrôles conception | test-system-design-check | Déterministe | ✅ En place |
| 13 | Contrôles plan | test-plan-check | Déterministe | ✅ En place |
| 14 | Contrôles dev | test-dev-check | Déterministe | ✅ En place |
| 15 | Contrôles QA | test-qa-check | Déterministe | ✅ En place |
| 16 | Contrôles brief | test-brief-check | Déterministe | ✅ En place |

## Isolation des skills

`test-setup` sauvegarde `~/.claude/skills/` et le remplace par les skills
du repo. `clean-test` restaure. Garantit que les tests utilisent les
bonnes versions.

## Reste à faire

- Exécution complète du `make test` pour valider toute la chaîne
- Ajuster les seuils des contrôles déterministes après la première exécution
- Ajouter un contrôle structurel pour sdd-uc-spec-write (comme pour system-design)
