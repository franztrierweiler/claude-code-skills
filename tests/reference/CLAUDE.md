# CLAUDE.md

Ce fichier fournit des instructions à Claude Code (claude.ai/code) pour travailler avec le code de ce dépôt.

## Processus global

```
docs/SPEC.md + fichiers annexes
       |
       v
[1. Spécification]──correction──> sdd-uc-spec-write
       |
       v
[2. Conception technique]───────> sdd-uc-system-design
       |                            ├─> docs/ARCHITECTURE.md
       |                            ├─> docs/DEPLOYMENT.md
       |                            ├─> docs/SECURITY.md
       |                            └─> docs/COMPLIANCE_MATRIX.md (si réglementaire)
       |
       v
[3. Planification]────────────> plan/<epic>.md
       |
       v
[4. Développement par EPIC]───> /sdd-dev-workflow <epic>
       |                          (boucle implémentation / AC / tests)
       |
       v
[5. QA par EPIC]─────────────> /sdd-qa-workflow <epic>
       |                          (plan de test, exécution, revue de code)
       |
       v
[6. Livraison]
```

## Vue d'ensemble du projet

**MaintiX** est une plateforme de coordination d'interventions de maintenance industrielle. Elle remplace partiellement une GMAO (IBM Maximo) vieillissante en apportant une couche de coordination terrain en temps réel.

**Problème résolu :** les techniciens reçoivent leurs ordres d'intervention par email/téléphone, remplissent des fiches papier sur le terrain, puis ressaisissent les données dans la GMAO au bureau. Ce processus génère des délais (24-48h), des erreurs de ressaisie et une absence de visibilité temps réel.

**Utilisateurs cibles :** sociétés de maintenance industrielle de 20 à 200 techniciens.

**Acteurs principaux :**
- **Technicien** : intervient sur le terrain via PWA mobile (mode offline supporté)
- **Dispatcher** : planifie et assigne les interventions, suit l'avancement en temps réel
- **Responsable site** : valide les interventions terminées, consulte les rapports
- **GMAO (IBM Maximo)** : référentiel des équipements, historique, contrats (synchronisation bidirectionnelle)
- **Capteurs IoT** : mesures machines via MQTT, déclenchement d'alertes

**Stack technique :**
- Backend : Python 3.12+ / FastAPI
- Base de données : PostgreSQL 16
- Frontend : PWA (Progressive Web App) avec capacité offline (Service Worker + IndexedDB)
- Intégration GMAO : API REST bidirectionnelle avec IBM Maximo
- Intégration capteurs : broker MQTT (Mosquitto)
- Déploiement : cloud, instance unique (pas de multi-tenants en v1)

**Contraintes clés :**
- Mode offline obligatoire pour les techniciens terrain
- Gestion des conflits d'assignation (multi-utilisateurs simultanés)
- Validation permis de travail pour équipements critiques
- Traçabilité 10 ans (sites classés ICPE)
- RGPD : géolocalisation limitée aux heures de travail, purge à 6 mois

# Structure de la documentation

- `docs/CDC-maintenance.md` : cahier des charges MaintiX (exigences fonctionnelles, acteurs, contraintes)

Toujours consulter ces documents avant d'implémenter ou de modifier une fonctionnalité. Les exigences ont des niveaux de priorité (Critique, Important) qui guident l'ordre d'implémentation.

La documentation évolue au fur et à mesure des phases d'exécution du projet.

## Méthode de travail pour ce projet

### Travail au sein de l'équipe
1- Le fichier SPEC.md et les premiers fichiers référencés par le fichier SPEC.md constituent les documents de référence. Ils sont utilisés en entrée du skill sdd-uc-system-design lors de la phase de mise au point. Si besoin, le skill sdd-uc-spec-write permet de corriger la spécification et les fichiers qu'elle référence.
2- Le skill sdd-uc-system-design est utilisé pour produire les fichiers de conception technique.
3- La planification est utilisée si et seulement si les fichiers de conception technique sont disponibles.

### Rôle de Claude Code
1- Claude Code agit en tant qu'ingénieur développeur qui collabore étroitement avec la personne qui pilote le projet
2- Non seulement Claude Code produit du code mais il assiste le pilote du projet dans ses tâches de conception et de déroulement du projet
3- Lorsque le pilote du projet propose des solutions techniques, des architectures, Claude Code le "challenge" en ayant en tête toutes les contraintes du projet
4- Claude Code propose des solutions techniques en les éclairant à travers le prisme des coûts de fonctionnement et de la pérennité

## Règles pour Claude Code

### Au démarrage
1- Ce projet suit la méthodologie **Spec Driven Development (SDD)**. Rappeler ce cadre méthodologique à l'utilisateur dès que la session démarre.
2- Inviter systématiquement l'utilisateur à lancer `/sdd-brief` avant toute autre action pour charger le contexte complet du projet.

### En cours d'utilisation
1- A chaque ajout d'un nouveau fichier MD structurant pour le projet, vérifier que CLAUDE.md est bien à jour.
2- Indiquer que le fichier CLAUDE.md a été mis à jour.

### En interaction avec le pilote de projet lors de la phase de conception, de planification, de tests locaux et de déploiement

#### Planification
1- Lors d'une demande de planification, documenter chaque EPIC dans un fichier spécifique : `plan/<nom-epic>.md` (incluant le numéro de l'EPIC)
2- Mettre à jour la progression des tâches dans les fichiers `plan/` correspondants après chaque implémentation
3- Mettre à jour les tableaux d'AC dans les fichiers `plan/` correspondants après chaque implémentation et test unitaire

#### Recettes de test (QA)
Le processus QA est piloté par la commande `/sdd-qa-workflow <epic>`. Les conventions sont rappelées par la rule `.claude/rules/sdd-qa.md` lors du travail sur `qa/**`.


#### Commandes
1- Utiliser toujours les commandes Makefile pour les instructions à l'utilisateur (`make test`, `make lint`, `make run`, etc.) plutôt que les commandes brutes (`python`, `pytest`, `ruff`)
2- Le fichier Makefile est la référence pour installer, tester, linter, exécuter, etc
3- Au démarrage, afficher qu'un Makefile existe avec la commande permettant d'afficher l'aide

### Workflow de développement
Le workflow de développement est piloté par la commande `/sdd-dev-workflow <epic>`. La rule `.claude/rules/sdd-dev-workflow.md` se charge automatiquement lors du travail sur `src/` et `tests/` pour rappeler le format attendu et suggérer de lancer la commande si nécessaire.

### Nommage des branches git
1- Développement sur la branche `main` avec Claude Code
2- le pilote du projet donne instruction s'il est nécessaire de "git branch" pour expérimenter sur une branche dédiée
3- Si une autre méthode que celle décrite ici est explicitement utilisée, proposer de basculer la production de code sur une branche expérimentale.

### Commits
1- Ne pas ajouter "Co-Authored-By: Claude" dans les messages de commit
2- Ne pas ajouter "Generated with Claude Code" dans les messages de commit
3- Ne jamais commiter des fichiers qui n'ont pas subi de tests unitaires avec une réussite à 100%
