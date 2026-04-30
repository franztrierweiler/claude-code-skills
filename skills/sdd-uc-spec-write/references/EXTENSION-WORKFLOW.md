# Création d'une extension fonctionnelle

Une extension documente une nouvelle fonction rattachée à une spec racine existante.
Elle produit un document autonome (`SPEC-extension-<NomProjet>-<NomFonction>.md`)
traitable indépendamment par l'équipe de développement, sans modifier la spec racine.

## Choix du préfixe

Chaque extension possède un **préfixe de 3 à 4 lettres majuscules** dérivé du nom
de la fonction. Ce préfixe est utilisé dans tous les identifiants de l'extension.

**Dérivation :**
- « Alertes » → ALR
- « Export PDF » → EXP
- « Gestion Stock » → GST
- « Tableau de bord » → TDB

**Validation :**
1. Scanne tous les fichiers `docs/SPEC-extension-*.md` existants pour extraire
   les préfixes déjà utilisés (champ `Préfixe` du cartouche).
2. Propose un préfixe au format `[A-Z]{3,4}` et vérifie qu'il n'entre pas en
   collision avec un préfixe existant.
3. Valide le préfixe avec l'utilisateur avant de poursuivre.

## Lecture de la spec racine

Avant de commencer la rédaction, lis la spec racine pour extraire :

| Information | Usage |
|---|---|
| UUID (champ `UUID` du cartouche) | Renseigner le champ `UUID racine` du cartouche de l'extension |
| Nom du fichier (champ `Document` du cartouche) | Renseigner le champ `Spec racine` du cartouche |
| Liste des acteurs | Proposer les acteurs concernés par la fonction |
| Liste des UC et leurs intitulés | Permettre les références croisées dans la table des dépendances |
| Liste des RG | Permettre les références croisées |
| Dernier identifiant utilisé | Information (non nécessaire car l'extension a sa propre numérotation) |

## Identifiants préfixés

Tous les identifiants créés dans une extension portent le préfixe de l'extension.
Les identifiants de la spec racine restent sans préfixe.

```
Extension « Alertes » (préfixe ALR) :

UC-ALR-001        Cas d'utilisation n°1 de l'extension
CA-UC-ALR-001-01  Premier critère d'acceptation du UC-ALR-001
RG-ALR-0001       Règle de gestion n°1 de l'extension
IHM-ALR-001       Écran n°1 de l'extension
ENF-ALR-001       Exigence non-fonctionnelle n°1 de l'extension
CA-ENF-ALR-001-01 Premier CA de ENF-ALR-001
```

**Références à la spec racine :**
```
UC-005            → UC de la spec racine (pas de préfixe)
RG-0012           → RG de la spec racine (pas de préfixe)
```

**Références croisées entre extensions (cas avancé) :**
```
UC-EXP-003 (voir SPEC-extension-MaintiX-Export.md)
```
Les références entre extensions sont possibles mais rares. Toujours indiquer
le nom du fichier source pour lever toute ambiguïté.

## Convention de référence

La règle est simple :
- **Identifiant sans préfixe** (UC-005, RG-0012) → toujours la spec racine
- **Identifiant avec préfixe** (UC-ALR-001, RG-ALR-0001) → l'extension qui porte ce préfixe

Cette convention rend les références non ambiguës dans tout le projet.

## Table des dépendances

La section « Dépendances vers la spec racine » est un tableau maintenu au fil
de la rédaction. Elle couvre **tous les types d'identifiants** de la racine
référencés par l'extension : UC, RG, ENF, IHM ou CA. Chaque fois qu'un élément
de l'extension cite un identifiant racine — que ce soit dans une relation
`include` / `extend`, dans une étape, une exception, une RG, une IHM, une
contrainte non fonctionnelle ou un critère d'acceptation — ajouter une ligne
à la table.

| Colonne | Contenu |
|---|---|
| **Identifiant racine** | L'identifiant cité (ex : UC-005, RG-0341, ENF-002) |
| **Intitulé** | Le titre ou l'énoncé court, pour lisibilité |
| **Nature de la dépendance** | Include / Extend / Donnée en entrée / Prérequis / Réutilisée / Étendue |

**Passe de consolidation finale (obligatoire avant livraison) :** scanner le
document final pour chaque identifiant racine cité (sans préfixe d'extension)
et vérifier qu'il figure dans la table avec sa nature de dépendance. Une
référence orpheline (citée dans le corps mais absente de la table) est un bug
de traçabilité — corriger en ajoutant la ligne manquante. Patrons à scanner :

- `UC-\d+` (UC racine)
- `RG-\d+` (RG racine)
- `ENF-\d+` (ENF racine)
- `IHM-\d+` (IHM racine)
- `CA-(UC|ENF)-\d+-\d+` (CA racine)

Sans préfixe d'extension dans aucun de ces patrons.

Si aucune dépendance n'est identifiée, écrire « Aucune dépendance identifiée. »

## Relation extension / racine

Principes fondamentaux :

1. **L'extension ne modifie jamais la spec racine.** Si la spec racine doit
   évoluer pour supporter la nouvelle fonction, l'utilisateur doit utiliser le
   mode modification (mode 3) sur la spec racine séparément.

2. **L'extension est autonome.** Un agent IA qui reçoit la spec racine + une
   extension peut implémenter la fonction sans information supplémentaire.

3. **Les acteurs de l'extension sont ceux de la racine** (sauf si la fonction
   introduit un nouvel acteur, qui est alors défini dans l'extension).

## Mise à jour d'une extension existante

La mise à jour d'une extension suit les mêmes règles que la mise à jour d'une
spec racine — consulte `references/UPDATE-WORKFLOW.md` pour le workflow détaillé.

Les identifiants dépréciés ou ajoutés dans une extension utilisent le préfixe :
- Dépréciation : `~~**UC-ALR-003** : [Titre]~~ [DÉPRÉCIÉ v1.1]`
- Ajout : numérotation séquentielle après le dernier identifiant préfixé existant

## Checklist extension

Avant de livrer une extension, vérifier :

- [ ] Le cartouche contient les 11 champs requis (dont Spec racine, UUID racine, Préfixe).
- [ ] Le préfixe est unique (pas de collision avec une autre extension du projet).
- [ ] Tous les identifiants de l'extension portent le préfixe.
- [ ] La table « Dépendances vers la spec racine » est complète et à jour : couvre UC, RG, ENF, IHM et CA. Aucune référence racine orpheline (citée dans le corps mais absente de la table).
- [ ] Les références aux UC/RG/ENF/IHM/CA de la racine utilisent les identifiants sans préfixe.
- [ ] Le glossaire fonction ne duplique pas les termes du glossaire racine.
- [ ] Les diagrammes Mermaid sont à jour et incluent les UC racine référencés.
- [ ] Chaque UC a au moins un critère d'acceptation au format Soit/Quand/Alors.
- [ ] Un agent IA pourrait implémenter chaque UC sans poser de question.
