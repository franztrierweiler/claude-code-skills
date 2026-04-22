---
name: sdd-tuto
description: >
  Guide interactivement l'apprentissage de la méthodologie Spec Driven
  Development (SDD) : étapes, pourquoi, comment, exemples concrets. Produit
  un artefact HTML animé sur claude.ai. Skill slash-command (/sdd-tuto).
disable-model-invocation: true
metadata:
  version: "1.1.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Tutoriel SDD — Spec Driven Development

Version : 1.1.0
Date : 2026-04-03

## Identification

Avant toute autre sortie, afficher :

```
🎓 sdd-tuto v1.1.0
```

## Détection du mode

Trois modes possibles, testés dans cet ordre :

1. **claude.ai** (présence d'artefacts) → Servir le fichier
   `references/tuto.html` comme artefact HTML (voir § Mode artefact).

2. **Claude Code CLI avec navigateur disponible** → Tenter d'ouvrir
   le fichier HTML dans un navigateur (voir § Mode navigateur).

3. **Claude Code CLI sans navigateur** → Afficher le tutoriel en texte
   dans le terminal (voir § Mode terminal).

## Mode navigateur

Si l'environnement est Claude Code CLI, tenter d'ouvrir le fichier
`references/tuto.html` dans un navigateur. Le fichier HTML se trouve
dans le répertoire du skill.

**Procédure :**

1. Localiser le fichier HTML du skill :
   ```bash
   TUTO_HTML=$(find .claude/skills/sdd-tuto -name "tuto.html" 2>/dev/null | head -1)
   ```

2. Si le fichier est trouvé, tenter de l'ouvrir :
   - Linux : `xdg-open "$TUTO_HTML"`
   - macOS : `open "$TUTO_HTML"`
   - WSL : `wslview "$TUTO_HTML"` ou `explorer.exe "$TUTO_HTML"`

3. Si l'ouverture réussit :
   ```
   🎓 Tutoriel SDD ouvert dans le navigateur.
   Fichier : $TUTO_HTML
   ```
   Ne pas afficher le mode terminal.

4. Si l'ouverture échoue (pas de navigateur, pas de display, SSH) :
   ```
   ⚠️ Impossible d'ouvrir le navigateur. Affichage en mode texte.
   ```
   Basculer vers le mode terminal.

## Mode terminal

Afficher le tutoriel étape par étape, avec une pause entre chaque section.
Utiliser le formatage Markdown (titres, tableaux, code blocks, emojis).

### Introduction

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🎓 Spec Driven Development (SDD)                          ║
║                                                              ║
║   Une méthodologie de développement logiciel où la           ║
║   spécification est le point de vérité unique du projet.     ║
║   Le code en découle et doit être traçable jusqu'à la spec.  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### Étape 1 — Pourquoi SDD ?

Expliquer le problème résolu par SDD :

- Le cahier des charges classique est ambigu, incomplet, interprétable.
- Un agent IA (ou un développeur) ne peut pas implémenter correctement
  sans poser des dizaines de questions.
- SDD produit un document **exécutable** : suffisamment précis pour qu'un
  agent IA implémente sans ambiguïté, suffisamment clair pour qu'un
  décideur non technique comprenne ce qui sera livré.

**Question test :** "Un agent IA qui lit uniquement ce document peut-il
implémenter correctement ce comportement, sans deviner ?" — Si non, la
spec est incomplète.

### Étape 2 — Le pipeline

Afficher le pipeline avec les icônes et une explication de chaque étape :

```
  🖊️ Spécification     Quoi faire ? (SPEC-racine + extensions — cas d'utilisation)
       │
       ▼
  📐 Conception         Comment le construire ? (Architecture, Sécurité, Déploiement)
       │
       ▼
  🗺️ Planification      Dans quel ordre ? (Lots de développement)
       │
       ▼
  🏗️ Développement      Construire (Code + Tests, lot par lot)
       │
       ▼
  🧪 QA                 Vérifier (Plan de test, Revue de code, Rapport)
       │
       ▼
  ✅ Livraison          Déployer
```

Pour chaque étape, expliquer :
1. **Ce qui entre** (inputs)
2. **Ce qui sort** (outputs)
3. **Qui fait quoi** (pilote du projet vs Claude)
4. **Le skill associé** (nom, icône, invocation)

### Étape 3 — La spécification par cas d'utilisation

Expliquer les concepts clés :
- **Cas d'utilisation (UC)** : un scénario complet acteur → système
- **Étapes Na/Nb** : alternance acteur (a) / système (b)
- **Exceptions** : ce qui peut mal tourner, rattaché à une étape
- **Règles de gestion (RG)** : contraintes métier à une étape
- **Critères d'acceptation (CA)** : Soit/Quand/Alors — vérifiables
- **Packages** : regroupement en niveau 2 (≈ Epic) et niveau 1 (≈ Feature)

Donner un **exemple concret** d'un UC simple (3-4 étapes, 1 exception,
1 RG, 2 CA) pour illustrer.

### Étape 4 — La conception technique

Expliquer les 4 documents et leur rôle :
- **ARCHITECTURE.md** : composants, stack, flux, données, décisions (ADR)
- **DEPLOYMENT.md** : comment déployer, CI/CD, monitoring, disaster recovery
- **SECURITY.md** : modèle de menaces, exigences, principes de code sécurisé
- **COMPLIANCE_MATRIX.md** : conformité réglementaire (si applicable)

Insister sur la **traçabilité** : chaque décision d'architecture est
rattachée à un UC, une RG ou une ENF de la spec.

### Étape 5 — La planification en lots

Expliquer :
- Un **lot** regroupe des UC liés, implémentables de bout en bout
- Les lots sont ordonnés par **dépendances** et **priorité**
- Chaque lot a ses **critères d'acceptation** (CA) issus de la spec
- Le fichier `plan/<lot>.md` est le contrat du lot

### Étape 6 — Le développement

Expliquer la boucle :
1. Tests d'abord (TDD à partir des CA)
2. Implémentation
3. Vérification des AC
4. Itération si nécessaire

Montrer le lien avec la **reprise après QA** (🔧) : si la QA échoue,
le dev-workflow relit le rapport et cible les corrections.

### Étape 7 — La QA

Expliquer :
- Plan de test (scénarios nominaux, limites, erreurs)
- Exécution automatisée + manuelle
- Revue de code
- Rapport avec verdict (✅ VALIDÉ / ❌ À CORRIGER)

### Étape 8 — Les outils SDD

Afficher le tableau récapitulatif des skills :

```
┌─────┬──────┬────────────────────────┬─────────────────────────────┬──────────────────┐
│  #  │ Icône│ Skill                  │ Invocation                  │ Phase            │
├─────┼──────┼────────────────────────┼─────────────────────────────┼──────────────────┤
│  1  │ 🖊️   │ sdd-uc-spec-write      │ Automatique                 │ Spécification    │
│  2  │ 📐   │ sdd-uc-system-design   │ Automatique                 │ Conception       │
│  3  │ 🗺️   │ sdd-plan               │ /sdd-plan                   │ Planification    │
│  4  │ 🏗️   │ sdd-dev-workflow       │ /sdd-dev-workflow <lot>     │ Développement    │
│  5  │ 🔧   │ sdd-dev-workflow       │ /sdd-dev-workflow <lot>     │ Reprise QA       │
│  6  │ 🧪   │ sdd-qa-workflow        │ /sdd-qa-workflow <lot>      │ QA               │
│  7  │ 💡   │ sdd-brief              │ /sdd-brief                  │ Tableau de bord  │
│  8  │ 🎓   │ sdd-tuto               │ /sdd-tuto                   │ Tutoriel         │
└─────┴──────┴────────────────────────┴─────────────────────────────┴──────────────────┘
```

Expliquer la distinction :
- **Automatique** : Claude active le skill quand la demande correspond.
  L'utilisateur n'a pas besoin de le lancer explicitement.
- **`/nom-skill`** : L'utilisateur lance le skill manuellement. Claude ne
  peut pas le déclencher de lui-même.
- **Reprise QA (🔧)** : Même skill que le développement, mais il détecte
  automatiquement un rapport QA en échec et bascule en mode correction.

### Conclusion

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   SDD = Spécifier → Concevoir → Planifier → Construire      ║
║          → Vérifier → Livrer                                 ║
║                                                              ║
║   Chaque étape produit un livrable traçable.                 ║
║   Chaque livrable est exploitable par un agent IA.           ║
║   Le code est la conséquence de la spec, pas l'inverse.      ║
║                                                              ║
║   Pour commencer : /sdd-brief                                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

## Mode artefact

Si l'environnement supporte les artefacts (claude.ai), servir le fichier
`references/tuto.html` comme artefact HTML. Ne pas le régénérer — utiliser
le fichier tel quel.

Le fichier HTML est autonome (CSS, JS, SVG inline, pas de dépendance
externe) et contient :

- Navigation par étapes (7 sections) avec boutons Précédent/Suivant
- Pipeline animé avec couleurs par étape
- Exemples interactifs dépliables (UC, plan, etc.)
- Design responsive fond sombre
- Palette de couleurs : 🖊️ bleu, 📐 orange, 🗺️ vert, 🏗️ rouge, 🧪 violet, 💡 jaune
