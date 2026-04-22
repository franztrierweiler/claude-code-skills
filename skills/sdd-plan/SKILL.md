---
name: sdd-plan
description: >
  Planifie le développement d'un projet SDD en lots à partir des
  SPEC-racine-*.md (+ extensions) et de l'ARCHITECTURE.md. Produit les
  fichiers plan/<lot>.md consommés par l'étape de développement. Skill
  slash-command (/sdd-plan).
disable-model-invocation: true
metadata:
  version: "1.1.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Planification du développement en lots

Version : 1.1.0
Date : 2026-04-03

## Identification

Avant toute autre sortie, afficher :

```
🗺️ sdd-plan v1.1.0
```

## 1. Garde à l'entrée

Vérifier que les fichiers requis existent :

1. **Documents SPEC** (`docs/SPEC-racine-*.md` et/ou `docs/SPEC-extension-*.md`) —
   au moins un document obligatoire. Si aucun trouvé :
   ```
   ❌ Aucun document de spécification trouvé dans docs/. Lancer 🖊️ sdd-uc-spec-write d'abord.
   ```
   Arrêter. Si trouvé(s), lister les documents et demander confirmation :
   ```
   📄 Documents SPEC détectés :
   - [liste des fichiers]
   Je les utilise comme référence. OK ?
   ```

2. **`docs/ARCHITECTURE.md`** — obligatoire. Si absent :
   ```
   ❌ docs/ARCHITECTURE.md introuvable. Lancer 📐 sdd-uc-system-design d'abord.
   ```
   Arrêter.

3. **`plan/*.md`** — si des fichiers de plan existent déjà :
   ```
   ⚠️ Des lots existent déjà dans plan/ :
   [liste des fichiers]
   Tu veux les remplacer, les compléter, ou annuler ?
   ```

## 2. Chargement du contexte

Lire les fichiers suivants :

| Fichier | Ce qu'on en extrait |
|---|---|
| `docs/SPEC-racine-*.md` | UC (identifiants, intitulés, priorité, relations include/extend), packages (niveau 2 / niveau 1), ENF (si présent) |
| `docs/SPEC-extension-*.md` | UC préfixés, dépendances racine, ENF spécifiques (si présent) |
| `docs/ARCHITECTURE.md` | Composants (§ 4.2), matrice UC → Composants, dépendances entre composants, stack technique (§ 3.1), structure du répertoire (§ 7) |
| `docs/SECURITY.md` | Exigences de sécurité impactant l'ordre de développement (ex: auth d'abord) |

## 3. Proposition de découpage

Activer le mode plan de Claude et proposer un découpage en respectant
ces contraintes :

### Principes de découpage

1. **Dépendances d'abord** — Les lots fondamentaux (modèle de données,
   authentification, infrastructure de base) viennent en premier.
2. **Cohérence fonctionnelle** — Un lot regroupe des UC liés (même package
   ou relations include/extend). Pas de UC isolé, pas de lot fourre-tout.
3. **Taille raisonnable** — 3 à 8 lots pour couvrir le périmètre. Un lot
   = 2 à 5 UC. Si un lot dépasse 5 UC, le découper.
4. **Priorité** — Les UC Critiques sont dans les premiers lots. Les UC
   Souhaités peuvent être dans les derniers lots (ou un lot "améliorations").
5. **Testabilité** — Chaque lot doit être testable de bout en bout une
   fois implémenté. Pas de lot qui ne compile pas seul.

### Présentation au pilote

Présenter le découpage sous cette forme :

```
🗺️ sdd-plan v1.1.0 [██░░] Proposition de découpage — N lots

Lot 1 : [Nom] (priorité: Critique)
  UC : UC-001, UC-002, UC-003
  Dépendances : aucune
  Composants : [composant_1], [composant_2]
  Justification : [pourquoi ce regroupement, pourquoi en premier]

Lot 2 : [Nom] (priorité: Critique)
  UC : UC-004, UC-005
  Dépendances : Lot 1
  Composants : [composant_3]
  Justification : [...]

...

Tu valides ce découpage ? Tu veux modifier, fusionner ou découper des lots ?
```

### Itération

Si le pilote demande des modifications :
- Ajuster le découpage
- Représenter la proposition modifiée
- Ne produire les fichiers qu'après validation explicite

## 4. Production des fichiers de plan

Après validation par le pilote, produire un fichier par lot dans `plan/` :

**Nommage :** `plan/lot-NN-nom-court.md` (ex: `plan/lot-01-auth.md`,
`plan/lot-02-interventions.md`)

**Format de chaque fichier :**

```markdown
# Lot [N] — [Nom du lot]

## Objectif

[Description en 2-3 phrases : ce que ce lot apporte au système]

## UC couverts

| UC | Intitulé | Priorité |
|---|---|---|
| UC-XXX | [Intitulé de la spec] | [Critique / Important / Souhaité] |

## Composants impactés

| Composant | Rôle dans ce lot |
|---|---|
| [Nom — issu de ARCHITECTURE.md § 4.2] | [Ce qui est implémenté/modifié] |

## Dépendances

- [Lots prérequis : lot-01-auth, lot-02-... — ou "Aucune"]

## Fonctionnalités

### F1 — [Nom de la fonctionnalité]

[Description : ce qui est implémenté, quels UC sont couverts]

### F2 — [Nom]

[Description]

## Critères d'acceptation

| AC | Description | Statut | Justification | Date |
|---|---|---|---|---|
| CA-UC-XXX-YY | [Description issue de la spec] | ⏳ | | |
| CA-UC-XXX-YY | [Description] | ⏳ | | |

## Prochaines actions

À implémenter via 🏗️ /sdd-dev-workflow lot-NN-nom-court
```

## 5. Synthèse

Après production de tous les fichiers, afficher :

```
🗺️ sdd-plan v1.1.0 [████] Planification terminée — N lots produits

| Lot | Fichier | UC | Dépendances | Priorité |
|-----|---------|-----|------------|----------|
| 1   | plan/lot-01-auth.md | UC-001, UC-002 | — | Critique |
| 2   | plan/lot-02-interventions.md | UC-003, UC-004, UC-005 | Lot 1 | Critique |
| ... | ... | ... | ... | ... |

Prochaine étape : 🏗️ /sdd-dev-workflow lot-01-auth
```
