---
name: sdd-dev-workflow
description: >
  Pilote le développement d'un lot SDD : implémentation itérative,
  écriture des tests unitaires, vérification des critères d'acceptation,
  mise à jour du plan. Supporte la reprise après un échec QA.
argument-hint: <nom-lot>
disable-model-invocation: true
metadata:
  version: "2.1.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Workflow de développement d'un lot

Version : 2.1.0
Date : 2026-04-03

## Argument

$ARGUMENTS — nom du lot (ex: `lot-01-auth`, `lot-02-interventions`)

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
   ❌ docs/SPEC.md introuvable. Lancer sdd-uc-spec-write d'abord.
   ```
   Arrêter.

3. **`docs/ARCHITECTURE.md`** — obligatoire. Si absent :
   ```
   ❌ docs/ARCHITECTURE.md introuvable. Lancer sdd-uc-system-design d'abord.
   ```
   Arrêter.

## 2. Détection du mode

Chercher le fichier `qa/qa-results/rapport-$ARGUMENTS.md`.

**Si le rapport existe ET contient "❌ À CORRIGER" :**

→ **Mode reprise QA.** Lire en complément :
- `qa/qa-results/rapport-$ARGUMENTS.md` (scénarios en échec, verdict)
- `qa/plan-test-$ARGUMENTS.md` (détail des scénarios)
- `qa/code-review/$ARGUMENTS-review.md` (points de revue de code)

Afficher :
```
🔧 sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [░░░░░] — REPRISE QA

Rapport QA : N scénarios en échec, M points de revue de code à corriger.

Scénarios en échec :
- [T01-03] Description — problème identifié
- [T04-01] Description — problème identifié

Points de revue de code :
- [fichier:ligne] Description du problème

Je cible ces corrections uniquement.
```

**Sinon :**

→ **Mode développement initial.**

Afficher :
```
🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [░░░░░] — Développement initial
```

## 3. Chargement du contexte

Lire les fichiers suivants :

| Fichier | Ce qu'on en extrait |
|---|---|
| `plan/$ARGUMENTS.md` | Fonctionnalités du lot, critères d'acceptation (AC), dépendances |
| `docs/SPEC.md` | UC concernés, règles de gestion (RG), critères d'acceptation (CA-UC) |
| `docs/ARCHITECTURE.md` | Stack technique (§ 3), composants concernés (§ 4.2), structure du répertoire (§ 7), principes d'architecture (§ 2) |
| `docs/SECURITY.md` | Principes de développement sécurisé (§ 6), exigences pertinentes |
| `docs/DEPLOYMENT.md` | Configuration par environnement (§ 4) si pertinent |

Afficher un résumé :
```
Lot : $ARGUMENTS
Fonctionnalités : N
Critères d'acceptation : M
UC concernés : UC-001, UC-002, ...
Composants impactés : [composant_1], [composant_2]
```

En mode reprise QA, afficher en plus :
```
Corrections ciblées : P scénarios + Q points de revue
```

## 4. Boucle d'implémentation

### Mode développement initial

Pour chaque fonctionnalité du lot, afficher la progression et numéroter
les itérations :

```
🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [█░░░░] Fonctionnalité 1/M · Itération 1
```

1. **Écrire les tests unitaires d'abord** — Traduire les AC en tests.
   Les CA-UC du SPEC.md sont directement convertibles en assertions.
   Nommer les tests de manière traçable (ex: `test_ca_uc_001_01_...`).
2. **Implémenter** — Coder la fonctionnalité en respectant :
   - La structure du répertoire de ARCHITECTURE.md § 7
   - Les composants et interfaces de ARCHITECTURE.md § 4.2
   - Les principes de développement sécurisé de SECURITY.md § 6
3. **Exécuter les tests** — Via Makefile (`make test` ou équivalent).
4. **Vérifier chaque AC** — Lister explicitement :
   - ✅ AC satisfait (test passant + justification)
   - ❌ AC non satisfait (raison + action corrective)
5. **Si des AC ne sont pas satisfaits**, incrémenter le compteur et itérer :
   ```
   🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [█░░░░] Fonctionnalité 1/M · Itération 2
   AC non satisfaits : CA-UC-001-02 (raison), CA-UC-001-05 (raison)
   ```
   Reprendre à l'étape 2 avec les corrections ciblées.
6. **Signaler la fin de la fonctionnalité :**
   ```
   🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [█░░░░] ✅ Fonctionnalité 1/M — X/Y AC — 2 itérations
   ```

### Mode reprise QA

Pour chaque correction identifiée :

1. **Lire le scénario QA en échec** — Comprendre le problème exact.
2. **Corriger le code** — Appliquer la correction ciblée.
3. **Mettre à jour ou ajouter le test unitaire** — Le test doit couvrir
   le scénario qui a échoué.
4. **Exécuter les tests** — Vérifier que la correction n'introduit pas
   de régression.
5. **Signaler la correction :**
   ```
   🔧 sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [██░░░] Correction N/M — [T01-03] corrigé
   ```

Pour les points de revue de code : appliquer les corrections et signaler.

## 5. Vérification globale

Quand toutes les fonctionnalités (ou corrections) sont implémentées :

1. **Exécuter la suite de tests complète** — `make test`
2. **Vérifier que tous les tests passent** — 0 échec.
3. **Revoir le code** avec pour référence :
   - Les AC du lot
   - Les principes de développement sécurisé (SECURITY.md § 6)
   - Les conventions du projet (CLAUDE.md)
4. **Pour chaque AC**, démontrer concrètement qu'il est satisfait :
   - Test passant → citer le nom du test
   - Si non vérifiable automatiquement → expliquer la procédure manuelle

Afficher :
```
🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [████░] Vérification globale
Tests : X/Y passent
AC : M/M satisfaits (ou N non satisfaits)
```

## 6. Rapport et mise à jour du plan

Mettre à jour le fichier `plan/$ARGUMENTS.md` :

1. **Progression** — Marquer les fonctionnalités terminées.
2. **Tableau des AC** — Mettre à jour le statut de chaque AC avec :
   - Statut (✅ / ❌)
   - Justification (nom du test, preuve)
   - Date de validation

Format du rapport dans le plan :

```markdown
## Statut des critères d'acceptation

| AC | Description | Statut | Justification | Date |
|---|---|---|---|---|
| CA-UC-001-01 | [Description] | ✅ | test_ca_uc_001_01 passe | 2026-04-03 |

## Prochaines actions

[Actions restantes ou "Lot terminé — prêt pour QA"]
```

## 7. Clôture

**Si tous les AC sont satisfaits :**
```
🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [█████] ✅ Terminé — tous les AC satisfaits
Prochaine étape : 🧪 /sdd-qa-workflow $ARGUMENTS
```

**Si des AC restent non satisfaits :**
```
🏗️ sdd-dev-workflow v2.1.0 · Lot: $ARGUMENTS [████░] ⚠️ N AC non satisfaits
[Liste des AC en échec avec la raison]
Le plan a été mis à jour. Relancer 🏗️ /sdd-dev-workflow $ARGUMENTS pour continuer.
```
