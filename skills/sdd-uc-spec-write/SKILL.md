---
name: sdd-uc-spec-write
description: >
  Rédige et met à jour des spécifications logicielles structurées par cas d'utilisation (UC)
  selon la méthodologie SDD. Produit des SPEC.md exploitables par des agents IA.
metadata:
  version: "2.0.0"
  author: "Franz TRIERWEILER"
license: "MIT"
---

# Spec Driven Development (SDD) — Rédaction par cas d'utilisation

Version : 2.0.0
Date : 2026-04-02

## Prérequis — vérification au démarrage

Avant toute autre action, vérifie que les fichiers suivants existent dans le
répertoire `references/` du skill :

| Fichier | Rôle |
|---|---|
| `references/TEMPLATE-SPEC.md` | Template de référence pour la génération du SPEC.md |
| `references/UC-FORMAT.md` | Format et règles de rédaction des cas d'utilisation |
| `references/UPDATE-WORKFLOW.md` | Workflow de mise à jour d'une spec existante |
| `references/GLOSSARY-SDD.md` | Glossaire méthodologique SDD |

Si un ou plusieurs fichiers sont absents, **arrête immédiatement** et affiche :

```
⚠️ Fichier(s) manquant(s) dans references/ : [liste].
Le skill ne peut pas fonctionner sans ces fichiers. Vérifie que le skill
a été installé avec son répertoire references/ complet.
```

Ne tente pas de générer le SPEC.md de mémoire si un fichier de référence manque.

## Message d'accueil

Quand le skill est activé, Claude commence par vérifier si un SPEC.md existe
déjà dans `docs/`. Selon le résultat, il affiche l'un des trois messages
ci-dessous avant toute autre action :

**Rédaction initiale (aucun SPEC.md trouvé) :**
```
Ce skill produit des spécifications logicielles structurées par cas d'utilisation (UC),
selon la méthodologie Spec Driven Development (SDD). L'objectif est de produire un
document suffisamment précis pour qu'un agent IA implémente le logiciel sans ambiguïté,
et suffisamment clair pour qu'un décideur non technique comprenne ce qui sera livré.

Je vais te guider en trois étapes :
1. Cadrage — produire un cahier des charges introductif (contexte, acteurs, contraintes, périmètre).
2. Cas d'utilisation — détailler chaque UC avec ses étapes, exceptions, règles de gestion.
3. Compléments — objets participants, exigences non fonctionnelles, périmètre.

On commence par le cadrage.
```

**Reprise d'une rédaction en cours (SPEC.md incomplet détecté) :**

Un SPEC.md est considéré incomplet s'il contient des placeholders `[...]`,
des sections vides, des UC sans critères d'acceptation, ou si des sections
attendues du template sont absentes.

```
J'ai trouvé un SPEC.md existant mais incomplet. Sections manquantes ou
incomplètes :
- [liste des manques détectés]

Je te propose de reprendre la rédaction à partir de [étape détectée].
Tu préfères reprendre là où ça s'est arrêté, ou travailler sur une
section spécifique ?
```

**Modification d'un SPEC.md existant (SPEC.md complet détecté) :**
```
Ce skill permet de modifier une spécification SDD existante structurée par cas
d'utilisation. Je peux intervenir sur :
- Les cas d'utilisation (ajout, modification, dépréciation)
- Le glossaire
- Les exigences non fonctionnelles
- Les niveaux de support et le hors périmètre
- L'arborescence et les diagrammes
- Toute autre section du SPEC.md

Quelle section veux-tu modifier ?
```

## Critères de déclenchement

### Déclenchement primaire (haute confiance — active le skill directement)

- L'utilisateur demande explicitement une spec SDD, un SPEC.md, ou mentionne
  "Spec Driven Development" / "SDD" comme méthodologie.
- L'utilisateur demande de rédiger des cas d'utilisation (UC) pour un projet logiciel.
- L'utilisateur demande de rédiger une spécification par cas d'utilisation.
- L'utilisateur demande de produire une spécification structurée destinée
  à être implémentée par un agent IA.
- L'utilisateur fournit des notes informelles et demande de les transformer
  en spécification structurée par cas d'utilisation.
- L'utilisateur fournit un SPEC.md existant et demande de le modifier, compléter
  ou mettre à jour.

### Déclenchement secondaire (confiance moyenne — demande confirmation)

- L'utilisateur veut "formaliser" ou "structurer" un cahier des charges sans
  mentionner SDD → Demande : "Tu veux un cahier des charges classique ou une
  spec SDD structurée par cas d'utilisation ?"
- L'utilisateur veut documenter des règles métier sans contexte d'implémentation
  → Demande : "Ces règles doivent-elles aboutir à une implémentation logicielle ?"
- L'utilisateur mentionne "spécifier un comportement" ou "documenter des scénarios"
  sans contexte clair → Demande : "Tu veux intégrer ça dans une spec SDD complète
  ou juste documenter ce point isolément ?"

### Anti-triggers (ne pas déclencher)

- L'utilisateur demande de lire, analyser ou résumer une spec existante sans
  intention de produire ou modifier un SPEC.md.
- L'utilisateur rédige de la documentation utilisateur, un README, ou un guide
  d'utilisation.
- L'utilisateur écrit des tests, même s'il mentionne des critères d'acceptation
  (les tests consomment la spec, ils ne la produisent pas).
- L'utilisateur pose une question technique sur une API ou un format sans vouloir
  produire de spécification.
- L'utilisateur demande une revue de code ou un audit technique.

## Philosophie

Une spec SDD n'est pas un cahier des charges classique destiné à être interprété uniquement
par des humains. C'est un **document de référence exécutable**, construit pour une lecture
humaine mais aussi par un agent IA : suffisamment précis pour qu'un agent IA produise
une implémentation conforme sans poser de questions, et suffisamment clair pour qu'un décideur
non technique comprenne ce qui sera livré.

Une fois le SPEC.md produit, un autre agent (ou skill) l'utilise comme entrée pour construire
l'architecture technique, les consignes de sécurité et les plans de développement, en vue de
commencer l'implémentation. Le SPEC.md est donc le point d'entrée de toute la chaîne de
production logicielle.

Chaque phrase de la spec doit répondre à cette question : **"Un agent IA qui lit uniquement ce
document peut-il implémenter correctement ce comportement, sans deviner ?"** Si la réponse est
non, la spec est incomplète.

La spec est le contrat entre celui qui spécifie et celui qui implémente — qu'il soit humain ou IA.
Elle est le point de vérité unique du projet. Le code en découle et doit être traçable
jusqu'à la spec.

Les critères d'acceptation sont conçus pour être directement convertibles en tests automatisés.
Un agent IA peut générer une suite de tests à partir de la seule lecture des CA, sans
information supplémentaire. Cette propriété est intentionnelle : si un critère d'acceptation
n'est pas transformable en test, il est trop vague — reformule-le.

## Concepts clés

### Acteurs

Un acteur est un type d'utilisateur (un profil) qui **modifie l'état interne du système**.
Un acteur peut être :
- **Humain** : Client, Administrateur, Gestionnaire, Caissière, etc.
- **Système** : Cron, service externe, batch planifié, etc.

**Ne sont PAS des acteurs :**
- Les destinataires d'une action (ex : Imprimante, service de notification).
- Le système qu'on modélise lui-même.

### Relations entre cas d'utilisation

Trois types de relations peuvent exister entre UC :

| Relation | Description | Fréquence |
|---|---|---|
| **Include** | Un UC inclut obligatoirement un autre UC. Le UC inclus est toujours exécuté. | Courante |
| **Extend** | Un UC étend un autre UC de manière optionnelle, sous certaines conditions. | Courante |
| **Généralisation / Spécialisation** | Un UC hérite du comportement d'un UC parent et le spécialise. | Rare |

Chaque UC documente ses relations dans un champ dédié. Les diagrammes Mermaid
sont régénérés à chaque livraison pour refléter ces relations.

### Packages et arborescence

Les cas d'utilisation sont organisés en une arborescence à deux niveaux de packages :

| Niveau | Rôle | Équivalent Agile |
|---|---|---|
| **Package niveau 2** | Regroupement de haut niveau | Epic |
| **Package niveau 1** | Sous-regroupement fonctionnel | Feature |
| **UC** | Cas d'utilisation unitaire | ≈ User Story |

Un diagramme de cas d'utilisation ne doit pas dépasser **15 à 20 UC**. Au-delà,
découper en packages ou sous-diagrammes.

L'arborescence sert de cartographie du système et sera réutilisable pour le
lotissement et la priorisation du développement.

### Diagramme de contexte

Le diagramme de contexte est un **schéma informel** (pas de formalisme UML) dont
l'objectif est de permettre à une personne extérieure de comprendre le périmètre
du système **en 10 secondes**. C'est un objet de communication.

Caractéristiques :
- Schéma non formel, statique (aucun élément dynamique).
- Éléments qui doivent y apparaître :
  - Les acteurs.
  - Les structures organisationnelles (entreprise, fournisseur, etc.).
  - Les principaux objets (voiture, colis, livre, etc.).
  - Les éléments géographiques (usine, restaurant, bibliothèque, agence, etc.).
  - Les postes clients, les terminaux de consultation.
  - Les applications informatiques ou sites Web (placés dans les structures
    organisationnelles ou géographiques).

L'utilisateur peut fournir ce schéma sous forme d'image que Claude interprète.

## Identification du skill dans les réponses

Chaque réponse produite sous ce skill commence par une barre de progression
indiquant le skill actif, l'étape en cours et l'avancement. Cette ligne est
obligatoire, sans exception.

**Format :**

```
🪶 skill:sdd-uc-spec-write v2.0.0 · [Étape] [barre] sous-étape N/T — [Nom]
```

La version affichée est celle indiquée dans l'en-tête du skill (actuellement v2.0.0).

**Règles de la barre de progression :**

- Caractère plein : `█` — Caractère vide : `░`
- Largeur fixe : 4 caractères pour Cadrage (4 sous-étapes), variable pour
  Cas d'utilisation (1 caractère par package de niveau 1), 3 caractères pour Compléments.
- La barre reflète la sous-étape en cours (incluse).

**Découpage en sous-étapes :**

| Étape | Sous-étapes | Total |
|-------|-------------|-------|
| Cadrage | 1. Questions obligatoires · 2. Questions conditionnelles · 3. Diagramme de contexte · 4. Rédaction & validation sections initiales | 4 |
| Cas d'utilisation | 1. Arborescence & diagramme global · puis 1 sous-étape par package de niveau 1 (nombre variable, noté N/M) | 1+M |
| Compléments | 1. Objets participants · 2. Exigences non fonctionnelles · 3. Rédaction finale & passage de relais | 3 |

**Exemples :**

```
🪶 skill:sdd-uc-spec-write v2.0.0 · Cadrage [█░░░] 1/4 — Questions obligatoires
🪶 skill:sdd-uc-spec-write v2.0.0 · Cadrage [████] 4/4 — Rédaction & validation
🪶 skill:sdd-uc-spec-write v2.0.0 · Cas d'utilisation [█░░░░] arborescence — Structure des packages
🪶 skill:sdd-uc-spec-write v2.0.0 · Cas d'utilisation [████░] package 3/4 — Export
🪶 skill:sdd-uc-spec-write v2.0.0 · Compléments [███] 3/3 — Rédaction finale & passage de relais
```

**Cas particulier — Mise à jour d'une spec existante :**

```
🪶 skill:sdd-uc-spec-write v2.0.0 · Mise à jour [██░] 2/3 — Application des modifications
```

Sous-étapes de mise à jour : 1. Lecture & périmètre · 2. Application ·
3. Changelog & impacts.

Si plusieurs messages se succèdent au sein de la même sous-étape (ex :
clarifications, allers-retours), la barre reste identique. Elle avance
uniquement au passage à la sous-étape suivante.

## Processus de rédaction

La rédaction d'une spec SDD par cas d'utilisation est un dialogue, pas une génération
en un coup. Claude guide l'utilisateur à travers trois étapes successives, en posant
des questions ciblées pour collecter l'information nécessaire avant de rédiger chaque
section. L'objectif est d'extraire la connaissance métier que l'utilisateur possède
et que Claude ne peut pas deviner.

### Étape 1 — Cadrage

Avant de rédiger quoi que ce soit, pose ces questions pour remplir les sections
Contexte, Architecture et périmètre. Pose-les par petits groupes
(3 à 5 questions maximum à la fois) pour ne pas submerger l'utilisateur.

**Questions obligatoires :**

1. Que fait le logiciel en une phrase ?
2. Quel problème résout-il, et pour qui ?
3. Y a-t-il des contraintes techniques imposées (langage, plateforme, dépendances) ?
4. Y a-t-il des contraintes réglementaires ou normatives (RGPD, HDS, certification) ?
5. Qui sont les acteurs du système ? (rappel : un acteur est un profil qui modifie
   l'état interne du système — pas un destinataire d'action)

**Questions conditionnelles** (pose-les si le contexte le suggère) :

- Le logiciel interagit-il avec un système existant, du hardware, ou un environnement
  non contrôlé ? → Déclenche la section Niveaux de support.
- Y a-t-il un cadre réglementaire dont certaines obligations se traduisent en
  comportements implémentables ? → Déclenche des cas d'utilisation spécifiques.
- Y a-t-il des contraintes d'architecture technique à respecter (composants imposés,
  intégrations, flux de données) ? → Déclenche la section Architecture.
- Y a-t-il des contraintes de performance, de sécurité, de fiabilité ou de
  portabilité ? → Déclenche la section Exigences non-fonctionnelles.
- Qu'est-ce que le logiciel ne fait explicitement pas ? Quelles demandes prévisibles
  des utilisateurs doivent être refusées ? → Alimente la section Hors périmètre.
- As-tu un **diagramme de contexte** à fournir pour expliquer le périmètre du système ?
  Si tu n'en as pas, je peux en produire un à partir des informations du cadrage.

Quand les réponses sont suffisantes, rédige les sections initiales du SPEC.md
(en-tête, contexte, diagramme de contexte si fourni, architecture si applicable,
niveaux de support si applicable, hors périmètre) et présente-les à l'utilisateur
pour validation avant de poursuivre.

### Étape 2 — Cas d'utilisation

Avant de commencer la rédaction des UC, demande à l'utilisateur :

1. **"As-tu un diagramme des cas d'utilisation à fournir ?"** — Si oui, interprète
   le schéma fourni (image) pour identifier les UC, les acteurs et les relations.

2. **Propose l'arborescence des packages :** "Je vois N packages de niveau 2
   regroupant M packages de niveau 1. Voici la structure que je propose :
   [arborescence]. Tu valides, tu corriges, tu complètes ?"

Pour chaque package de niveau 1 :

1. **Propose** un lot de cas d'utilisation (2 à 4) avec leur structure complète.
   Consulte `references/UC-FORMAT.md` pour le format exact et les questions à poser.
2. **Demande validation** : "Tu valides, tu corriges, tu complètes ?"
3. **Intègre** les retours et passe au lot suivant.

Ne cherche pas l'exhaustivité dès le premier passage. Il vaut mieux couvrir les UC
principaux de chaque package, puis revenir affiner.

Si l'utilisateur fournit des informations que tu ne maîtrises pas entièrement,
demande des précisions plutôt que de deviner. Un UC faux est pire qu'un UC absent.

**Régénération des diagrammes :** À chaque livraison du SPEC.md, régénère les
diagrammes Mermaid des relations entre UC. Si > 15-20 UC, découpe par package.

### Étape 3 — Compléments

Une fois les UC principaux posés, aborde successivement :

1. **Objets participants** : "Veux-tu documenter une liste d'objets métier identifiés
   (entités, agrégats) ? Tu peux aussi fournir des diagrammes d'objets."
2. **Exigences non fonctionnelles** : "Y a-t-il des contraintes non fonctionnelles
   à documenter (performance, sécurité, fiabilité, portabilité, etc.) ?"
3. **Passage de relais** — Voir section dédiée.

### Format de livraison

Produis chaque document comme un fichier téléchargeable, pas comme du texte dans
le chat. Le chat sert au dialogue (questions, validations, arbitrages). Les fichiers
portent le contenu livrable.

**Création initiale :** Rédige le SPEC.md au fil des étapes en utilisant le template
défini dans `references/TEMPLATE-SPEC.md`. À chaque validation de section par
l'utilisateur, mets à jour le fichier. Livre les documents complémentaires
(DATA-MODEL.md, etc.) séparément.

**Mise à jour :** Produis le SPEC.md modifié complet, pas un diff. Régénère les
diagrammes Mermaid. Consulte `references/UPDATE-WORKFLOW.md` pour les règles
d'identifiants, le changelog et le workflow détaillé.

**Nommage :** Document principal : `SPEC.md`. Schéma de données : `DATA-MODEL.md`.
Ne préfixe pas les noms de fichiers avec le nom du projet ou une date.

### Passage de relais

Quand les trois étapes sont terminées et que le SPEC.md contient un cadrage validé,
des cas d'utilisation couvrant les packages principaux, et des compléments documentés,
informe l'utilisateur que le document est suffisamment structuré pour qu'il puisse le
compléter et l'enrichir lui-même.

Dis-le explicitement, par exemple : "Le SPEC.md a maintenant une structure solide avec
[N] cas d'utilisation répartis en [packages]. Tu peux désormais le compléter directement
— ajouter des UC, affiner les étapes et exceptions, préciser les règles de gestion —
en suivant le format et les conventions établis. Le glossaire et la structure des
identifiants (UC/RG/IHM/ENF/CA) te guident."

L'objectif du skill n'est pas de rédiger 100% de la spec. C'est d'amorcer le document
avec suffisamment de structure, de rigueur et d'exemples concrets pour que l'utilisateur
soit autonome pour la suite. La spec est un document vivant qui s'enrichit au fil du
projet.

Avant de remettre la spec à l'utilisateur, vérifie chaque point de la checklist et
signale les manques.

Le skill suivant dans la chaîne SDD est `sdd-uc-system-design`, qui prend le SPEC.md
comme entrée pour produire l'architecture technique, le déploiement, la sécurité et
la matrice de conformité.

### Mise à jour d'une spec existante

Pour le workflow complet de mise à jour (types de modifications, règles d'identifiants,
changelog, processus), consulte `references/UPDATE-WORKFLOW.md`.

## Structure d'un cas d'utilisation

Pour le format exact d'un UC, les règles de rédaction, le format des critères
d'acceptation Soit/Quand/Alors, et les questions à poser à l'utilisateur, consulte
`references/UC-FORMAT.md`.

## Glossaire SDD

Le glossaire SDD est défini dans `references/GLOSSARY-SDD.md`. Reproduis-le en
dernière section de chaque SPEC.md produite, tel quel. Ces termes sont imposés par
la méthodologie SDD et ne doivent pas être remplacés par des synonymes.

## Structure d'une SPEC.md

Le SPEC.md suit cet ordre de sections. Le template complet avec les exemples de
structure est dans `references/TEMPLATE-SPEC.md`.

1. **En-tête** — Nom, version, date, auteur, statut.
2. **Changelog** (à partir de la v1.1) — Entre l'en-tête et le contexte.
3. **Contexte et objectifs** — Ce que le projet fait, pourquoi, pour qui, contraintes, acteurs.
4. **Diagramme de contexte** (si fourni) — Schéma informel du périmètre.
5. **Architecture** (si applicable) — Contraintes techniques, composants imposés.
6. **Documents de référence** (si applicable) — Liens vers documents complémentaires.
7. **Niveaux de support** (si applicable) — Supporté / Ignoré / Erreur explicite.
8. **Hors périmètre** — Ce que le logiciel ne fait explicitement pas.
9. **Arborescence des cas d'utilisation** — Tableau hiérarchique packages → UC.
10. **Diagramme global des cas d'utilisation** — Mermaid, découper si > 15-20 UC.
11. **Cas d'utilisation détaillés** — Regroupés par package. Format : voir `references/UC-FORMAT.md`.
12. **Objets participants** (si applicable) — Entités métier, diagrammes d'objets/interaction.
13. **Exigences non fonctionnelles** — ENF-XXX avec CA au format Soit/Quand/Alors.
14. **Glossaire projet** — Termes spécifiques au domaine.
15. **Glossaire SDD** — Vocabulaire méthodologique. Voir `references/GLOSSARY-SDD.md`.

## Directives de rédaction

### Langue et registre

Rédige dans la langue de l'utilisateur. Utilise un registre professionnel accessible :
compréhensible par un directeur métier, exploitable par un développeur ou un agent IA.
Évite le jargon technique non défini dans le glossaire projet.

### Identifiants — convention de nommage

```
UC-001        Cas d'utilisation numéro 1
CA-UC-001-01  Premier critère d'acceptation du UC-001
RG-0001       Règle de gestion numéro 1
IHM-001       Écran / maquette numéro 1
ENF-001       Exigence non-fonctionnelle numéro 1
CA-ENF-001-01  Premier critère d'acceptation de ENF-001
```

Numérote séquentiellement. Ne réutilise jamais un identifiant supprimé.
Les identifiants sont référencés dans le code (commentaires) pour assurer la traçabilité.

### Complétude — checklist avant livraison

Avant de considérer la spec comme terminée, vérifie :

- [ ] Le glossaire SDD est présent et intact.
- [ ] Le glossaire projet couvre tous les termes spécifiques utilisés.
- [ ] L'arborescence des UC est complète et cohérente.
- [ ] Chaque UC a au moins un critère d'acceptation.
- [ ] Chaque critère d'acceptation est au format Soit/Quand/Alors.
- [ ] Les étapes de chaque UC suivent la convention Na/Nb (acteur/système).
- [ ] Les exceptions sont rattachées à un id d'étape précis.
- [ ] Les règles de gestion sont identifiées (RG-XXXX) et rattachées à une étape.
- [ ] Les relations entre UC (include, extend) sont documentées.
- [ ] Les diagrammes Mermaid des relations sont à jour.
- [ ] La section Hors périmètre est renseignée.
- [ ] Les niveaux de support sont documentés (si applicable).
- [ ] Les exigences non fonctionnelles pertinentes sont documentées.
- [ ] Un agent IA pourrait implémenter chaque UC sans poser de question.
