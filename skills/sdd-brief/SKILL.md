---
name: sdd-brief
description: >
  Charge le contexte complet d'un projet SDD en début de session.
  Affiche l'état des livrables, la phase courante du pipeline, la
  progression des EPICs, et les outils disponibles.
argument-hint: (sans argument)
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Brief projet SDD

Version : 1.0.0
Date : 2026-04-03

## Instructions

### 1. Lecture du contexte projet

Lire les fichiers suivants (ignorer silencieusement ceux qui n'existent pas) :

- `CLAUDE.md` à la racine du projet
- Tous les fichiers markdown dans `docs/`
- Tous les fichiers `plan/*.md` (si le répertoire existe)

### 2. État des livrables SDD

Afficher un tableau synthétique de l'avancement des livrables. Pour chaque
fichier, détecter sa présence et extraire la version (ligne `Version :`) :

| Livrable | Fichier | Statut | Version |
|----------|---------|--------|---------|
| Spécification | `docs/SPEC.md` | ✅ Présent / ❌ Absent | vX.Y |
| Architecture | `docs/ARCHITECTURE.md` | ✅ / ❌ | vX.Y |
| Déploiement | `docs/DEPLOYMENT.md` | ✅ / ❌ | vX.Y |
| Sécurité | `docs/SECURITY.md` | ✅ / ❌ | vX.Y |
| Conformité | `docs/COMPLIANCE_MATRIX.md` | ✅ / ❌ / ⊘ Non requis | vX.Y |

### 3. Phase courante du projet

Déduire la phase actuelle du pipeline SDD et l'afficher :

```
Phase actuelle : [N. Nom de la phase]
```

Logique de détection :

1. **Pas de `docs/SPEC.md`** → `1. Spécification` — "Le SPEC.md n'existe pas encore. Lancer le skill sdd-uc-spec-write pour le produire."
2. **`docs/SPEC.md` présent mais pas de `docs/ARCHITECTURE.md`** → `2. Conception technique` — "La spec est prête. Lancer le skill sdd-uc-system-design pour produire les documents de conception."
3. **Documents de conception présents mais pas de `plan/*.md`** → `3. Planification` — "La conception est prête. Créer les fichiers plan/<epic>.md pour planifier les EPICs."
4. **`plan/*.md` présents avec des EPICs non terminés** → `4. Développement` — "EPICs en cours. Utiliser /sdd-dev-workflow <epic> pour continuer."
5. **EPICs terminés (AC 100%) mais pas de rapports QA** → `5. QA` — "Développement terminé. Utiliser /sdd-qa-workflow <epic> pour la recette."
6. **Rapports QA présents** → `6. Livraison` — "QA terminée. Le projet est prêt pour la livraison."

### 4. Progression des EPICs

Si des fichiers `plan/*.md` existent, afficher :

| EPIC | Fichier | AC complétés | Statut |
|------|---------|-------------|--------|
| [Nom] | `plan/xxx.md` | N/M (X%) | En cours / Terminé / Non démarré |

Si des rapports QA existent dans `qa/qa-results/`, les mentionner.

### 5. Outils SDD disponibles

Afficher deux tableaux :

**Skills :**

| Skill | Description | Quand l'utiliser |
|-------|-------------|-----------------|
| (lister les skills dont le nom contient `sdd` dans les skills disponibles, hors sdd-brief) | (synthèse 10 mots) | (phase du pipeline) |

**Commandes :**

| Commande | Description | Quand l'utiliser |
|----------|-------------|-----------------|
| (lister les skills sdd-* avec `disable-model-invocation: true`, hors sdd-brief) | (synthèse 10 mots) | (phase du pipeline) |

**Rules actives :**

| Rule | Se déclenche sur | Rôle |
|------|-----------------|------|
| (lister les fichiers `.claude/rules/sdd-*.md` et extraire `paths` et `description` du frontmatter) | (paths) | (description) |

### 6. Makefile

Si un fichier `Makefile` existe à la racine :
```
Makefile disponible — `make help` pour l'aide
```

### 7. Conclusion

Terminer par :
```
Prêt. Quelle est la prochaine étape ?
```
