Le fichier docs/SPEC.md contient la spécification complète du projet MaintiX et
les fichiers docs/ARCHITECTURE.md, docs/DEPLOYMENT.md, docs/SECURITY.md contiennent
la conception technique.

Planifie le développement en lots. Chaque lot doit :
- Couvrir un ensemble cohérent de UC (pas un UC isolé, pas tout le projet)
- Être implémentable de bout en bout (du code au test)
- Avoir ses critères d'acceptation (AC) listés explicitement avec les identifiants
  CA-UC du SPEC.md
- Être ordonné par dépendances (un lot ne dépend que de lots précédents)

Contraintes :
- Le premier lot doit être le plus fondamental (modèle de données, auth, ou
  infrastructure de base selon l'architecture)
- 3 à 6 lots maximum pour couvrir le périmètre du SPEC.md
- Chaque lot dans un fichier séparé : plan/<nom-lot>.md

Format de chaque fichier plan :

```markdown
# Lot [N] — [Nom du lot]

## Objectif

[Description en 2-3 phrases]

## UC couverts

| UC | Intitulé | Priorité |
|---|---|---|
| UC-XXX | [Intitulé] | [Critique / Important / Souhaité] |

## Dépendances

- [Lots prérequis ou "Aucune"]

## Fonctionnalités

### F1 — [Nom]
[Description]

### F2 — [Nom]
[Description]

## Critères d'acceptation

| AC | Description | Statut | Justification | Date |
|---|---|---|---|---|
| CA-UC-XXX-YY | [Description] | ⏳ | | |

## Prochaines actions

[À implémenter]
```

Produis les fichiers de plan directement, sans poser de questions.
