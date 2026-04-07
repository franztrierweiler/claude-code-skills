---
name: sdd-brief
description: >
  Charge le contexte complet d'un projet SDD en début de session.
  Affiche l'état des livrables, la phase courante du pipeline, la
  progression des lots, et les outils disponibles.
argument-hint: (sans argument)
disable-model-invocation: true
metadata:
  version: "1.1.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Brief projet SDD

Version : 1.1.0
Date : 2026-04-03

## Identification

Avant toute autre sortie, afficher :

```
💡 sdd-brief v1.1.0
```

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
3. **Documents de conception présents mais pas de `plan/*.md`** → `3. Planification` — "La conception est prête. Créer les fichiers plan/<lot>.md pour planifier les lots."
4. **`plan/*.md` présents avec des lots non terminés** → `4. Développement` — "lots en cours. Utiliser /sdd-dev-workflow <lot> pour continuer."
5. **lots terminés (AC 100%) mais pas de rapports QA** → `5. QA` — "Développement terminé. Utiliser /sdd-qa-workflow <lot> pour la recette."
6. **Rapports QA présents** → `6. Livraison` — "QA terminée. Le projet est prêt pour la livraison."

### 4. Progression des lots

Si des fichiers `plan/*.md` existent, afficher :

| Lot | Fichier | AC complétés | Statut |
|-----|---------|-------------|--------|
| [Nom] | `plan/xxx.md` | N/M (X%) | (voir règles ci-dessous) |

Règles de statut :

- **AC 0 %** → `Non démarré`
- **AC partiel (entre 0 % et 100 %)** → `En cours`
- **AC 100 %** → vérifier l'existence de `qa/qa-results/rapport-<nom-lot>.md` :
  - Rapport absent → `Dev terminé — QA en attente`
  - Rapport présent et contient `❌ À CORRIGER` → `QA en échec — reprise dev`
  - Rapport présent sans `❌ À CORRIGER` → `QA validée`

### 5. Outils SDD disponibles

Afficher le tableau récapitulatif des skills SDD. Pour chaque skill,
lire son SKILL.md pour extraire la version (ligne `Version :`) et
l'icône (premier emoji dans le fichier).

| # | Icône | Skill | Version | Invocation | Phase |
|---|-------|-------|---------|-----------|-------|
| 1 | 🖊️ | sdd-uc-spec-write | (version lue) | Automatique | Spécification |
| 2 | 📐 | sdd-uc-system-design | (version lue) | Automatique | Conception technique |
| 3 | 🗺️ | sdd-plan | (version lue) | `/sdd-plan` | Planification |
| 4 | 🏗️ | sdd-dev-workflow | (version lue) | `/sdd-dev-workflow <lot>` | Développement |
| 5 | 🧪 | sdd-qa-workflow | (version lue) | `/sdd-qa-workflow <lot>` | QA |
| 6 | 💡 | sdd-brief | (version lue) | `/sdd-brief` | Tableau de bord |
| 7 | 🎓 | sdd-tuto | (version lue) | `/sdd-tuto` | Tutoriel |

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
