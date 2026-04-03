# Rule Improvements — État au 2026-04-03

## Constat

Les deux rules (`sdd-dev-workflow.md`, `sdd-qa.md`) sont largement
redondantes avec les skills correspondants. Leur seule valeur ajoutée
est de **suggérer** à l'utilisateur de lancer le skill quand il
travaille sur `src/`, `tests/` ou `qa/`.

## Décision

Conserver les rules en l'état. Elles servent de rappel contextuel
(coût nul, légère valeur). Les supprimer si elles génèrent du bruit.

## Corrections appliquées (2026-04-03)

- ✅ EPIC → lot dans les deux fichiers
- ✅ Markdown malformé corrigé (bullet vide dans sdd-qa, code block non fermé dans sdd-dev-workflow)
