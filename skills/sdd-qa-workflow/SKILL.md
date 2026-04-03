---
name: sdd-qa-workflow
description: >
  Pilote la recette de test d'un lot SDD : plan de test, exécution,
  revue de code (incluant sécurité), rapport QA avec sévérités.
argument-hint: <nom-lot>
disable-model-invocation: true
metadata:
  version: "2.0.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Recette de test (QA) d'un lot

Version : 2.0.0
Date : 2026-04-03

## Argument

$ARGUMENTS — nom du lot (ex: `lot-01-auth`)

## Identification

Avant toute autre sortie, afficher :

```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS
```

## 1. Garde à l'entrée

Vérifier que les fichiers requis existent :

1. **`plan/$ARGUMENTS.md`** — obligatoire. Si absent :
   ```
   ❌ Fichier plan/$ARGUMENTS.md introuvable.
   Vérifier le nom du lot. Fichiers disponibles dans plan/ :
   [lister les fichiers plan/*.md]
   ```
   Arrêter.

2. **`docs/SPEC.md`** — obligatoire. Si absent :
   ```
   ❌ docs/SPEC.md introuvable.
   ```
   Arrêter.

3. **`docs/ARCHITECTURE.md`** — obligatoire. Si absent :
   ```
   ❌ docs/ARCHITECTURE.md introuvable.
   ```
   Arrêter.

4. **`docs/SECURITY.md`** — obligatoire. Si absent :
   ```
   ❌ docs/SECURITY.md introuvable.
   ```
   Arrêter.

5. **Vérification des AC à 100%** — Lire `plan/$ARGUMENTS.md` et vérifier
   que tous les AC ont le statut ✅. Si des AC sont ❌ ou ⏳ :
   ```
   ❌ Le lot $ARGUMENTS n'est pas complet :
   - CA-UC-001-02 : ⏳ (non démarré)
   - CA-UC-003-01 : ❌ (en échec)
   Lancer 🏗️ /sdd-dev-workflow $ARGUMENTS d'abord.
   ```
   Arrêter.

## 2. Détection du mode

Chercher le fichier `qa/qa-results/rapport-$ARGUMENTS.md`.

**Si le rapport existe déjà :**
```
⚠️ Un rapport QA existe déjà pour ce lot :
  qa/qa-results/rapport-$ARGUMENTS.md
  Verdict précédent : [✅ VALIDÉ / ❌ À CORRIGER]

Options :
  1. Relancer la QA complète (écrase le rapport existant)
  2. Annuler

Quel est ton choix ?
```

**Sinon :** continuer normalement.

## 3. Chargement du contexte

Lire les fichiers suivants :

| Fichier | Ce qu'on en extrait |
|---|---|
| `plan/$ARGUMENTS.md` | AC du lot, fonctionnalités, nombre d'itérations de dev |
| `docs/SPEC.md` | UC concernés (étapes, exceptions, RG), CA-UC détaillés, ENF |
| `docs/ARCHITECTURE.md` | Composants impactés (§ 4.2), structure du répertoire (§ 7), principes (§ 2) |
| `docs/SECURITY.md` | Principes de développement sécurisé (§ 6), exigences pertinentes |
| `src/` | Fichiers source implémentés pour ce lot |
| `tests/` | Tests unitaires existants |

Afficher un résumé :

```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS · Phase: chargement

Lot : $ARGUMENTS
UC couverts : UC-001, UC-002, ...
Critères d'acceptation : N (tous ✅)
Itérations de développement : M
Fichiers source : P
Tests unitaires existants : Q
```

## 4. Élaboration du plan de test

Afficher :
```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS · Phase: plan de test
```

### Sources pour les scénarios

Le plan de test s'appuie sur **trois sources** :

1. **CA-UC du SPEC.md** — Chaque critère d'acceptation (Soit/Quand/Alors)
   génère au minimum un scénario nominal.
2. **Exceptions des UC du SPEC.md** — Chaque exception documentée dans les
   étapes des UC génère un scénario d'erreur.
3. **ENF du SPEC.md** — Les exigences non fonctionnelles pertinentes
   (performance, sécurité) génèrent des scénarios spécifiques.

### Classification des scénarios

Chaque scénario a une **sévérité** qui détermine son impact sur le verdict :

| Sévérité | Signification | Impact sur le verdict |
|----------|--------------|----------------------|
| 🔴 Bloquant | Fonctionnalité inutilisable, perte de données, faille de sécurité | Verdict ❌ si au moins 1 bloquant en échec |
| 🟠 Majeur | Comportement incorrect mais contournable, dégradation significative | Verdict ❌ si > 2 majeurs en échec |
| 🟡 Mineur | Cosmétique, ergonomie, optimisation, convention de code | Ne bloque pas le verdict |

### Production du plan

Produire le plan de test dans `qa/plan-test-$ARGUMENTS.md` :

```markdown
# Plan de test — $ARGUMENTS

**Date :** [YYYY-MM-DD]
**UC couverts :** UC-001, UC-002, ...
**Nombre de scénarios :** N

## Scénarios

| # | Scénario | Type | Source | Sévérité | Test auto |
|---|----------|------|--------|----------|-----------|
| T01-01 | [Description] | Nominal | CA-UC-001-01 | 🔴 Bloquant | test_t01_01_... |
| T01-02 | [Description] | Limite | CA-UC-001-01 | 🟠 Majeur | test_t01_02_... |
| T01-03 | [Description] | Erreur | UC-001 exception 2b | 🔴 Bloquant | test_t01_03_... |
| T02-01 | [Description] | Performance | ENF-001 | 🟠 Majeur | test_t02_01_... |

## Tests manuels (si applicable)

| # | Scénario | Procédure | Critère de réussite |
|---|----------|-----------|-------------------|
| TM-01 | [Description] | [Étapes manuelles] | [Résultat attendu] |
```

**Traçabilité obligatoire :** chaque fonction de test inclut le numéro de
scénario QA dans son nom : `test_tXX_YY_description`.

**Soumettre le plan au pilote du projet pour validation avant de continuer.**

## 5. Exécution de la recette

Afficher :
```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS · Phase: exécution
```

Après validation du plan par le pilote :

1. **Écrire les tests QA** — Implémenter les scénarios du plan dans
   `tests/` (fichier dédié `tests/qa_$ARGUMENTS.py` ou dans les fichiers
   existants).
2. **Exécuter tous les tests** — Via Makefile (`make test`).
3. **Pour chaque scénario :**

   | Résultat | Affichage |
   |----------|-----------|
   | Passé | `✅ T01-01 [🔴] — [Description]` |
   | Échoué | `❌ T01-03 [🔴] — [Description] → [Problème constaté]` |

4. **Exécuter les tests manuels** (si applicable) et documenter les résultats.
5. **Synthèse d'exécution :**
   ```
   Exécution terminée — $ARGUMENTS
   Scénarios : X/Y passés
   🔴 Bloquants : A/B passés
   🟠 Majeurs : C/D passés
   🟡 Mineurs : E/F passés
   ```

## 6. Revue de code

Afficher :
```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS · Phase: revue de code
```

Effectuer une revue de code de tout le lot en vérifiant **5 axes** :

### 6.1 Conformité architecturale

- Le code respecte-t-il la structure du répertoire (ARCHITECTURE.md § 7) ?
- Les composants sont-ils dans les bons modules (ARCHITECTURE.md § 4.2) ?
- Les interfaces entre composants sont-elles respectées ?

### 6.2 Sécurité

Vérifier chaque principe de développement sécurisé (SECURITY.md § 6) :

| Principe | Vérifié |
|----------|---------|
| Effacement des données sensibles en mémoire | ✅ / ❌ / N/A |
| Pas de secrets en dur | ✅ / ❌ / N/A |
| Moindre privilège dans le code | ✅ / ❌ / N/A |
| Fail securely | ✅ / ❌ / N/A |
| Pas de désérialisation non fiable | ✅ / ❌ / N/A |
| Gestion sûre des fichiers temporaires | ✅ / ❌ / N/A |
| Comparaison en temps constant pour les secrets | ✅ / ❌ / N/A |
| Encodage des sorties contextualisé | ✅ / ❌ / N/A |

### 6.3 Qualité du code

- Lisibilité (nommage, structure, commentaires utiles)
- Duplication (code copié-collé, refactoring nécessaire)
- Complexité (fonctions trop longues, imbrications profondes)

### 6.4 Tests

- Couverture : chaque CA-UC a-t-il au moins un test ?
- Qualité des assertions (vérifient-elles le bon comportement ?)
- Nommage traçable (test_ca_uc_xxx_yy_...)

### 6.5 Performance

- Requêtes N+1 ou boucles coûteuses
- Données non paginées
- Ressources non libérées

Chaque constat de la revue a une **sévérité** (🔴/🟠/🟡).

Produire le rapport de revue dans `qa/code-review/$ARGUMENTS-review.md` :

```markdown
# Revue de code — $ARGUMENTS

**Date :** [YYYY-MM-DD]
**Fichiers revus :** N

## Constats

| # | Fichier | Ligne | Axe | Sévérité | Constat | Recommandation |
|---|---------|-------|-----|----------|---------|----------------|
| R01 | src/... | 42 | Sécurité | 🔴 | [Description] | [Correction proposée] |
| R02 | src/... | 15 | Qualité | 🟡 | [Description] | [Correction proposée] |

## Synthèse

- Conformité architecturale : ✅ / ⚠️ / ❌
- Sécurité : ✅ / ⚠️ / ❌
- Qualité du code : ✅ / ⚠️ / ❌
- Tests : ✅ / ⚠️ / ❌
- Performance : ✅ / ⚠️ / ❌
```

## 7. Rapport final

Afficher :
```
🧪 sdd-qa-workflow v2.0.0 · Lot: $ARGUMENTS · Phase: rapport
```

### Calcul du verdict

| Condition | Verdict |
|-----------|---------|
| Au moins 1 scénario 🔴 Bloquant en échec | ❌ À CORRIGER |
| Plus de 2 scénarios 🟠 Majeurs en échec | ❌ À CORRIGER |
| Au moins 1 constat de revue 🔴 Bloquant | ❌ À CORRIGER |
| Sinon | ✅ VALIDÉ |

### Production du rapport

Produire le rapport final dans `qa/qa-results/rapport-$ARGUMENTS.md` :

```markdown
# Rapport QA — $ARGUMENTS

**Date :** [YYYY-MM-DD]
**Lot :** $ARGUMENTS
**Verdict :** ✅ VALIDÉ / ❌ À CORRIGER

## Résumé

- Tests unitaires (dev) : X/Y passés
- Scénarios QA : X/Y passés
  - 🔴 Bloquants : A/B passés
  - 🟠 Majeurs : C/D passés
  - 🟡 Mineurs : E/F passés
- Revue de code : N constats (P 🔴, Q 🟠, R 🟡)
- Itérations de développement : M (lu depuis le plan)

## Scénarios en échec

| # | Scénario | Sévérité | Source | Problème | Correction suggérée |
|---|----------|----------|--------|----------|-------------------|
| T01-03 | [Description] | 🔴 | UC-001 exc. 2b | [Problème] | [Suggestion] |

## Constats de revue de code à corriger

| # | Fichier:ligne | Axe | Sévérité | Constat |
|---|--------------|-----|----------|---------|
| R01 | src/...:42 | Sécurité | 🔴 | [Description] |

## Points d'attention (🟡 mineurs)

[Points mineurs non bloquants — pour amélioration future]

## Références

- Plan de test : `qa/plan-test-$ARGUMENTS.md`
- Revue de code : `qa/code-review/$ARGUMENTS-review.md`
- Plan du lot : `plan/$ARGUMENTS.md`
```

## 8. Clôture

**Si le verdict est ✅ VALIDÉ :**
```
✅ QA $ARGUMENTS — validé.

Scénarios : X/Y passés
Revue de code : aucun bloquant
Prêt pour commit.
```
Attendre l'instruction du pilote pour le commit.

**Si le verdict est ❌ À CORRIGER :**
```
❌ QA $ARGUMENTS — à corriger.

Bloquants : N scénario(s) en échec + M constat(s) de revue
Le rapport détaillé est dans qa/qa-results/rapport-$ARGUMENTS.md

Prochaine étape : 🔧 /sdd-dev-workflow $ARGUMENTS (mode reprise QA)
```
