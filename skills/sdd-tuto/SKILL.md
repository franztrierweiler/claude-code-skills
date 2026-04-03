---
name: sdd-tuto
description: >
  Tutoriel interactif de la méthodologie Spec Driven Development (SDD).
  Explique les étapes, le pourquoi, le comment, avec des exemples concrets.
  En mode claude.ai, produit un artefact HTML animé.
argument-hint: (sans argument)
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Tutoriel SDD — Spec Driven Development

Version : 1.0.0
Date : 2026-04-03

## Identification

Avant toute autre sortie, afficher :

```
🎓 sdd-tuto v1.0.0
```

## Détection du mode

- **Si l'environnement est claude.ai** (présence d'artefacts) → Produire
  un artefact HTML interactif (voir § Mode artefact).
- **Sinon** (Claude Code CLI) → Afficher le tutoriel pas à pas dans le
  terminal (voir § Mode terminal).

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
  🖊️ Spécification     Quoi faire ? (SPEC.md — cas d'utilisation)
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
rattachée à un UC, une RG ou une ENF du SPEC.md.

### Étape 5 — La planification en lots

Expliquer :
- Un **lot** regroupe des UC liés, implémentables de bout en bout
- Les lots sont ordonnés par **dépendances** et **priorité**
- Chaque lot a ses **critères d'acceptation** (CA) issus du SPEC.md
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

Si l'environnement supporte les artefacts (claude.ai), produire un
**artefact HTML** autonome (single-file, pas de dépendances externes)
avec :

### Structure de l'artefact

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>SDD — Spec Driven Development</title>
    <style>/* styles inline */</style>
</head>
<body>
    <!-- Contenu du tutoriel -->
    <script>/* animations */</script>
</body>
</html>
```

### Contenu et design

- **Navigation par étapes** : 7 sections (les mêmes que le mode terminal),
  navigation par boutons Précédent/Suivant ou par clic sur l'étape.
- **Pipeline animé** : le schéma du pipeline s'affiche progressivement,
  chaque étape s'illumine quand on y arrive.
- **Exemples interactifs** : l'exemple de UC peut être
  déplié/replié pour voir la structure complète.
- **Style** : fond sombre, texte clair, accents de couleur par étape
  (une couleur par icône). Typographie monospace pour les identifiants
  (UC-xxx, RG-xxxx, CA-UC-xxx-yy).
- **Responsive** : lisible sur mobile et desktop.
- **Pas de dépendance externe** : tout en inline (CSS, JS, SVG).

### Palette de couleurs par étape

| Étape | Icône | Couleur |
|-------|-------|---------|
| Spécification | 🖊️ | `#4FC3F7` (bleu clair) |
| Conception | 📐 | `#FFB74D` (orange) |
| Planification | 🗺️ | `#81C784` (vert) |
| Développement | 🏗️ | `#E57373` (rouge clair) |
| QA | 🧪 | `#BA68C8` (violet) |
| Brief | 💡 | `#FFD54F` (jaune) |
