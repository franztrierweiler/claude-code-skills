# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.
Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Ce projet utilise le [Semantic Versioning](https://semver.org/lang/fr/).

## sdd-uc-spec-write

### [2.5.0] — 2026-04-28

- Modèle de paquetages : profondeur variable (recommandée 3, plafond pratique 4), enfants mixtes (paquetages + UCs dans un même parent), règle 7+10 (max 7 sous-paquetages par parent, max 10 UCs par paquetage feuille)
- Trois vues complémentaires pour l'arborescence : carte d'ensemble (liste imbriquée), fiches paquetage (tableau 2 colonnes), diagramme Mermaid avec `subgraph`
- Barre de progression : « 1 caractère par paquetage racine » remplace « 1 par package niveau 1 » (sémantique stable indépendamment de la profondeur)
- Templates SPEC-racine et SPEC-extension refondus : section *Arborescence* éclatée en trois sous-sections, diagrammes Mermaid avec `subgraph` par paquetage
- Glossaire : entrée *Package* remplacée par *Paquetage* avec règles structurelles
- Vocabulaire : « package » → « paquetage » dans tout le skill et ses références
- Nouvelle section optionnelle *Machines à états* dans les templates racine et extension : diagramme Mermaid + table des transitions (De / Vers / Déclencheur / Condition / RG-UC), pour centraliser les cycles de vie d'objets métier autrement éparpillés dans les RGs des UCs
- Étape *Compléments* étendue : 4 sous-étapes (Machines à états → Objets participants → ENF → Rédaction finale)
- Table des dépendances racine durcie : couvre désormais explicitement UC, RG, ENF, IHM et CA (et plus seulement UC/RG). Passe de consolidation finale obligatoire avant livraison d'une extension, pour détecter les références orphelines
- Nouvelle section optionnelle *Phases de livraison* dans les templates racine et extension : pour chaque phase, périmètre (UCs en scope), livrable, dépendances. La liste des UCs par phase fait office de matrice de traçabilité UC ↔ Phase et alimente le découpage en lots aval (`/sdd-plan`). Étape *Compléments* étendue à 5 sous-étapes (racine) et 4 (extension)

### [2.0.0] — 2026-03-30

- Restructuration progressive disclosure : extraction du template, glossaire, format UC et workflow de mise à jour dans `references/`
- Ajout metadata YAML
- Navigation cross-skill (passage de relais → sdd-uc-system-design)
- Structure SPEC.md condensée en index

### [1.2.0] — 2026-03-04

- Référence UC en gras dans les titres de UC (structure, template, dépréciation)
- Règle de rédaction "Visibilité de la référence UC" ajoutée

### [1.1.0] — 2026-03-03

- YAML allégé (description concise)
- Critères de déclenchement déplacés du YAML vers une section dédiée avant Philosophie

### [1.0.0] — 2026-02-25

- Version initiale
- Rédaction par cas d'utilisation (UC)
- Arborescence à deux niveaux de packages
- Relations include/extend/généralisation
- Diagramme de contexte
- Régénération automatique des diagrammes Mermaid

## sdd-spec-write

### [1.0.0] — 2026-02-18

- Version initiale
- Cadrage, exigences, limites
- Barre de progression avec versioning

## sdd-uc-system-design

### [1.1.0] — 2026-03-30

- Restructuration progressive disclosure : extraction des templates dans `references/`
- Ajout metadata YAML et licence
- Navigation cross-skill (passage de relais depuis sdd-uc-spec-write)

### [1.0.0] — 2026-02-18

- Version initiale
- Architecture, déploiement, sécurité, conformité
- Phase A avec réflexion profonde en 7 étapes et mode plan
- Barre de progression avec versioning

## sdd-system-design

### [1.0.0] — 2026-02-18

- Version initiale
- Architecture, déploiement, sécurité, conformité
- Phase A avec réflexion profonde en 7 étapes et mode plan
- Barre de progression avec versioning
