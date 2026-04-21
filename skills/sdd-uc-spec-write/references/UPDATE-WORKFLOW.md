# Mise à jour d'une spec existante

Quand l'utilisateur fournit un SPEC.md existant et demande une modification, Claude
ne repart pas de zéro. Il opère en mode chirurgical : modifier ce qui doit l'être,
préserver tout le reste.

## Déclenchement de la mise à jour

Quand l'utilisateur fournit un SPEC.md et demande une modification, Claude :
1. Affiche le message d'accueil en mode modification (voir section Message d'accueil du SKILL.md).
2. Demande quelle(s) section(s) modifier : UC, glossaire, ENF, niveaux de support,
   hors périmètre, arborescence, objets participants, etc.
3. Procède à la modification ciblée.

## Identifier le type de modification

Avant toute modification, identifie et confirme avec l'utilisateur le type d'opération :

| Type | Exemples | Impact |
|---|---|---|
| **Ajout** | Nouveau UC, nouveau package, nouvelle ENF | Insertion sans modifier l'existant |
| **Modification** | Reformulation d'une étape, ajout d'une exception, changement de règle de gestion | Mise à jour ciblée d'éléments existants |
| **Dépréciation** | Un UC n'est plus pertinent mais doit rester traçable | Marquage, pas suppression |
| **Restructuration** | Découpage d'un UC en deux, fusion de packages, réorganisation de l'arborescence | Modification structurelle avec renumérotation potentielle |

## Règles de gestion des identifiants

Les identifiants sont le squelette de la traçabilité. Les corrompre, c'est casser
le lien entre spec et code.

**Ajout de UC :**
- Numérote à la suite du dernier identifiant existant, jamais dans les trous.
- Si le dernier UC est UC-047, le suivant est UC-048, même si UC-012 a été déprécié.

**Dépréciation de UC :**
- Ne supprime jamais un UC du document. Marque-le comme déprécié :
```
### ~~**UC-012** : Validation synchrone des entrées~~ [DÉPRÉCIÉ v2.1]

**Remplacé par :** UC-048, UC-049
**Raison :** Découpage en validation syntaxique (UC-048) et validation sémantique
(UC-049) suite à [justification métier].
```

- Les étapes, exceptions, règles de gestion et critères d'acceptation associés
  sont conservés barrés, pour historique.
- Le code qui référençait UC-012 doit être mis à jour vers les nouveaux
  identifiants — mentionne-le à l'utilisateur.

**Modification de critères d'acceptation :**
- Si un CA est reformulé sans changer le comportement testé : modifie en place,
  note le changement dans le changelog.
- Si un CA change le comportement attendu : déprécie l'ancien, crée un nouveau CA
  avec le numéro suivant disponible.

**Ajout d'exceptions ou règles de gestion a posteriori :**
- Signale à l'utilisateur que l'implémentation existante du UC concerné doit être
  revue pour couvrir ce nouvel élément.

## Changelog

Toute mise à jour de la spec incrémente la version et ajoute une entrée au changelog,
inséré entre l'en-tête (section 1) et le contexte (section 2) :
```markdown
## Changelog

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 2.1 | 2025-07-15 | [Auteur] | Ajout UC-048, UC-049. Dépréciation UC-012. Ajout RG-0025. |
| 2.0 | 2025-06-01 | [Auteur] | Restructuration package "Export". Ajout ENF-003. |
| 1.0 | 2025-04-10 | [Auteur] | Version initiale. |
```

**Convention de versioning :**
- **Majeure (X.0)** : restructuration significative du périmètre, ajout ou retrait
  de packages de niveau 2.
- **Mineure (X.Y)** : ajout, modification ou dépréciation de UC ou ENF à l'intérieur
  du périmètre existant.

L'objectif n'est pas de reproduire git — c'est de donner à un agent IA qui reçoit
la spec v2.1 une vision claire de ce qui a changé depuis la version qu'il a peut-être
déjà implémentée.

## Workflow de mise à jour

Quand l'utilisateur demande de modifier une spec existante, suis ce processus :

1. **Lis la spec entière** avant de toucher quoi que ce soit. Identifie la version
   actuelle, le dernier identifiant utilisé, et la structure existante.
2. **Confirme le périmètre** : "Tu veux [résumé de la modification]. Ça impacte
   [UC/sections concernés]. Je confirme avant de modifier."
3. **Applique les modifications** en respectant les règles d'identifiants ci-dessus.
4. **Régénère les diagrammes Mermaid** des relations entre UC.
5. **Mets à jour le changelog** et incrémente la version.
6. **Signale les impacts** : tout UC modifié ou déprécié implique une revue
   de l'implémentation correspondante. Liste-les explicitement :
   "UC impactés côté code : UC-012 (déprécié → retirer), UC-048/049
   (nouveaux → implémenter), RG-0025 (nouvelle règle → implémenter)."
   Si des fichiers `docs/SPEC-extension-*.md` référencent des identifiants
   modifiés ou dépréciés, signaler les impacts sur ces extensions.
