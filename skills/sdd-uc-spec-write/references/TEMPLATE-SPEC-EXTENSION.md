# Template SPEC-extension.md — Extension fonctionnelle

Ce fichier est le template de référence pour la génération d'un SPEC-extension.md.
Une extension documente une nouvelle fonction rattachée à une spec racine existante,
sans modifier le document racine. Ne génère jamais la structure du document de
mémoire — ce template est la référence. Remplis les sections au fil du dialogue,
supprime les sections marquées comme optionnelles si elles ne s'appliquent pas,
et retire les commentaires HTML avant livraison.

````markdown
# [Nom du projet] — Extension « [Nom de la fonction] »

> | | |
> |---|---|
> | **Document** | SPEC-extension-[NomProjet]-[NomFonction].md |
> | **UUID** | `[UUID v4 généré à la création]` |
> | **Version** | 1.0 |
> | **Date** | [YYYY-MM-DD] |
> | **Auteur** | [Nom] |
> | **Statut** | Brouillon |
> | **Type** | Document d'extension |
> | **Spec racine** | [SPEC-racine-NomProjet.md] |
> | **UUID racine** | `[UUID de la spec racine]` |
> | **Préfixe** | [ALR] |
> | **Généré par** | sdd-uc-spec-write v2.5.0 |

<!-- CHANGELOG — Ne pas inclure en v1.0. Décommenter à partir de la v1.1.
## Changelog

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 1.1 | YYYY-MM-DD | [Auteur] | [Description des modifications] |
| 1.0 | YYYY-MM-DD | [Auteur] | Version initiale. |
-->

## Contexte de la fonction

**Ce que la fonction fait :** [Une phrase.]

**Pourquoi elle est nécessaire :** [Le besoin couvert par cette extension.]

**Acteurs concernés :**

<!-- Acteurs déjà définis dans la spec racine. Documenter uniquement leur rôle
     spécifique dans cette fonction. Si la fonction introduit de nouveaux acteurs,
     les ajouter ici avec leur description complète. -->

| Acteur | Rôle dans cette fonction |
|---|---|
| [Nom — déjà défini dans la spec racine] | [Rôle spécifique dans cette fonction.] |

**Contraintes structurantes :** [Techniques, réglementaires, de performance propres à cette fonction. Supprimer si aucune.]

## Diagramme de contexte

<!-- Diagramme de contexte de la fonction (pas du projet entier).
     Schéma informel montrant comment cette fonction s'intègre dans le système
     existant : quels acteurs, quels systèmes adjacents, quels flux de données.
     Supprimer cette section si aucun diagramme n'est fourni. -->

[Diagramme fourni par l'utilisateur ou reproduit en Mermaid/ASCII.]

## Dépendances vers la spec racine

<!-- Table des UC et RG de la spec racine réutilisés ou étendus par cette extension.
     Maintenir à jour au fil de la rédaction des UC.
     Si aucune dépendance : écrire "Aucune dépendance identifiée." -->

| Identifiant racine | Intitulé | Nature de la dépendance |
|---|---|---|
| UC-XXX | [Intitulé du UC racine] | [Include / Extend / Donnée en entrée / Prérequis] |
| RG-XXXX | [Énoncé court de la RG racine] | [Réutilisée / Étendue] |

## Niveaux de support

<!-- Supprimer cette section si la fonction n'interagit pas avec un système existant,
     du hardware, ou un environnement non contrôlé. Chaque fonctionnalité doit
     apparaître dans exactement une des trois catégories. -->

### Supporté

| Fonctionnalité | Comportement | UC lié |
|---|---|---|
| [Fonction X] | [Comportement fidèle à l'original] | UC-[PFX]-XXX |

### Ignoré (no-op silencieux)

| Fonctionnalité | Raison |
|---|---|
| [Fonction Y] | [Pourquoi elle est ignorée sans erreur] |

### Erreur explicite

| Fonctionnalité | Message d'erreur | Raison |
|---|---|---|
| [Fonction Z] | "[Message exact]" | [Pourquoi elle est rejetée] |

## Hors périmètre

<!-- Ce que cette fonction ne fait explicitement pas. Chaque exclusion en une phrase. -->

- [Ce que cette fonction ne fait explicitement pas.]

## Arborescence des cas d'utilisation

<!-- Trois vues complémentaires. Identifiants préfixés par l'extension
     (UC-[PFX]-XXX). Mêmes règles structurelles que la spec racine :
     enfants mixtes, max 7 sous-paquetages par parent, max 10 UCs par
     paquetage feuille, profondeur recommandée 3, plafond pratique 4. -->

### Carte d'ensemble

<!-- Liste imbriquée Markdown. Paquetages en gras avec count d'UCs entre
     parenthèses ; UCs listés sous leur parent direct. -->

- **[Paquetage A]** ([N] UC)
  - **[Sous-paquetage A.1]** ([N] UC) — UC-[PFX]-XXX, UC-[PFX]-YYY
- **[Paquetage B]** ([N] UC) — UC-[PFX]-AAA, UC-[PFX]-BBB

### Fiches paquetage

<!-- Une fiche par paquetage non-feuille de l'extension. Format constant. -->

#### Paquetage : [Nom]

**Objectif** — [En une phrase, ce que regroupe le paquetage.]

**Contient :**

| Type | Élément |
|---|---|
| Paquetage | [Nom du sous-paquetage] ([N] UC) |
| UC | UC-[PFX]-XXX — [Intitulé du UC] |

## Diagramme des cas d'utilisation

<!-- Mermaid avec un subgraph par paquetage de l'extension. Les UCs de la
     spec racine référencés en dépendance apparaissent en pointillés pour
     montrer les liens. Si > 20 UC : un diagramme par paquetage racine + un
     diagramme « 30 000 pieds » des paquetages seuls (sans UCs). -->

```mermaid
graph TD
    Acteur1([Acteur 1])
    subgraph PA[Paquetage A — extension]
        UC_PFX_001[UC-PFX-001 : Intitulé]
    end
    UC_005[UC-005 : Intitulé racine]:::racine
    Acteur1 --> UC_PFX_001
    UC_PFX_001 -.->|include| UC_005
    classDef racine stroke-dasharray: 5 5;
```

## Cas d'utilisation détaillés

<!-- Regrouper par paquetage en suivant la profondeur de l'arborescence.
     Chaque UC suit le format exact défini dans references/UC-FORMAT.md.
     Les identifiants portent le préfixe de l'extension (ex : UC-ALR-001).
     Les références aux UC/RG de la racine utilisent les identifiants sans
     préfixe (ex : UC-005, RG-0012). -->

---

**📦 [Paquetage racine : Nom]**

<!-- Si le paquetage contient des sous-paquetages, ajouter un sous-titre
     pour chaque sous-paquetage avant ses UCs (récursivement selon la profondeur). -->

**[Sous-paquetage : Nom]**

<!-- Pour chaque UC, reproduire la structure exacte définie dans references/UC-FORMAT.md,
     en utilisant les identifiants préfixés. -->

## Objets participants

<!-- Supprimer cette section si aucun objet spécifique à cette fonction.
     Ne pas dupliquer les objets déjà définis dans la spec racine — les référencer. -->

| Objet | Description |
|---|---|
| [Nom] | [Description de l'entité métier.] |

## Exigences non fonctionnelles

<!-- Uniquement les ENF spécifiques à cette fonction. Les ENF globales sont
     dans la spec racine et n'ont pas besoin d'être répétées ici.
     Supprimer cette section si aucune ENF spécifique. -->

#### ENF-[PFX]-001 : [Titre court]

**Priorité :** [Critique | Important | Souhaité]

**Description :** [Comment le logiciel se comporte, avec des valeurs mesurables.]

**Critères d'acceptation :**

- **CA-ENF-[PFX]-001-01 :** Soit [contexte initial], Quand [action], Alors [résultat attendu avec valeur mesurable].

## Glossaire fonction

<!-- Termes spécifiques à cette fonction. Ne pas dupliquer le glossaire projet
     ni le glossaire SDD de la spec racine — seuls les termes nouveaux. -->

| Terme | Définition |
|---|---|
| [Terme] | [Définition.] |
````
