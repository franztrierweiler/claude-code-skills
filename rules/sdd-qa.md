---
description: Rappel du processus QA SDD lors du travail sur les fichiers de recette
paths:
  - "qa/**"
---

# Rappel — Processus QA SDD

Lors d'un travail structuré de recette de test sur un lot complet, suggérer au pilote du projet de lancer `/sdd-qa-workflow <nom-lot>` si ce n'est pas déjà fait.

Ne pas suggérer la commande pour des consultations ou modifications ponctuelles de fichiers QA.

## Conventions QA

- Plans de test : `qa/plan-test-<nom-lot>.md`
- Revues de code : `qa/code-review/<nom-lot>-review.md`
- Rapports finaux QA : `qa/qa-results/rapport-<nom-lot>.md`
- La QA ne s'exécute que sur un lot complet, testé unitairement et avec des AC à 100%
