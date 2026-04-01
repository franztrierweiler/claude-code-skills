# Format et règles de rédaction des cas d'utilisation

## Structure d'un cas d'utilisation

Chaque cas d'utilisation suit ce format exact :

```markdown
### **UC-XXX** : [Intitulé]

**Résumé :** [Description en une à trois phrases de ce que fait ce cas d'utilisation.]

**Acteurs :** [Liste des acteurs impliqués.]

**Fréquence d'utilisation :** [Estimation : ex. "3 fois par jour", "mensuel", "à la demande".]

**Priorité :** [Critique | Important | Souhaité]

**État initial :** [Condition de départ obligatoire. Ex : "Session utilisateur ouverte",
"UC-003 déjà exécuté", "Mode nominal".]

**État final :** [Condition atteinte en fin d'exécution. Ex : "La commande est enregistrée,
elle peut être traitée par le service logistique."]

**Relations :**
- Include : [UC-XXX — raison] (ou "Aucune")
- Extend : [UC-XXX — condition] (ou "Aucune")
- Généralisation : [UC-XXX — spécialisation] (ou "Aucune")

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | [L'acteur fait quelque chose.] |
| 1b | ← Système | [Le système réagit. (IHM-XXX si applicable)] |
| 2a | → Acteur | [L'acteur fait quelque chose.] |
| 2b | ← Système | [Le système réagit.] |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si [condition] | [Réaction. Suite à l'étape X / Dérouler UC-XXX] |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-XXXX | [Nb] | [Énoncé de la règle de gestion.] |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-XXX | [Description de l'écran ou copie d'écran fournie par l'utilisateur.] |

**Objets participants :** [Liste des entités métier impliquées dans ce UC.]

**Contraintes non fonctionnelles :** [Contraintes spécifiques à ce UC, ou "Voir ENF-XXX".]

**Critères d'acceptation / Cas de tests :**

- **CA-UC-XXX-01 :** Soit [contexte initial], Quand [action], Alors [résultat attendu].
- **CA-UC-XXX-02 :** Soit [contexte initial], Quand [action], Alors [résultat attendu].
```

## Règles de rédaction des UC

- **Cas nominal uniquement dans les étapes.** Les étapes décrivent le scénario où
  tout se passe bien. Les problèmes et variations vont dans les exceptions.

- **Convention de numérotation des étapes.** Chaque étape porte un numéro suivi
  d'un suffixe :
  - `a` = action de l'acteur (→ vers le système)
  - `b` = réaction du système (← vers l'acteur)

- **Exceptions : un seul "Si...Alors" par ligne.** Chaque exception est rattachée
  à un id d'étape précis. Une exception mène soit à un traitement local (affichage
  d'un message d'erreur, popup), soit à un renvoi vers une autre étape, soit à un
  renvoi vers un autre UC.

- **Règles de gestion : rattachées à une étape.** Chaque RG est identifiée par un
  numéro unique (RG-XXXX) et rattachée à l'étape où elle s'applique.

- **Références IHM.** Quand une étape système affiche un écran, référence l'IHM
  entre parenthèses dans la description de l'étape : `(IHM-XXX)`.

- **Atomicité.** Un UC = un objectif utilisateur. Si un UC poursuit deux objectifs
  distincts, sépare-le en deux UC.

- **Vérifiabilité.** Chaque UC doit avoir au moins un critère d'acceptation.
  Si tu ne peux pas écrire le critère, le UC est trop vague — reformule-le.

- **Identifiants uniques.** Chaque UC, RG, IHM, CA a un identifiant unique. Ces
  identifiants sont référencés dans le code pour assurer la traçabilité.

- **Visibilité de la référence UC.** L'identifiant UC dans le titre du cas
  d'utilisation est toujours en gras : `### **UC-XXX** : [Intitulé]`.
  Cela garantit un repérage visuel immédiat lors de la lecture du document.

## Critères d'acceptation — format Soit/Quand/Alors

Chaque critère d'acceptation utilise strictement le format Soit/Quand/Alors :

- **Soit** décrit l'état initial du système (contexte, données en place).
- **Quand** décrit l'action unique déclenchée.
- **Alors** décrit le résultat observable et vérifiable.

Chaque clause doit être suffisamment précise pour être vérifiable
sans interprétation. Si le "Alors" contient "devrait fonctionner correctement", le critère
est inutile — reformule avec une valeur observable.

## Questions à poser pour renseigner un UC

Pour chaque UC, pose les questions suivantes à l'utilisateur pour l'aider à fournir
les données requises. Ne laisse pas de champ vide par défaut — force la réponse :

1. **Qui déclenche ce cas d'utilisation ?** → Acteurs
2. **Quelle est la condition de départ ?** → État initial
3. **Qu'est-ce qui est vrai à la fin de l'exécution ?** → État final
4. **Décris-moi les étapes quand tout se passe bien.** → Étapes (cas nominal)
5. **À quelle fréquence ce cas se produit-il ?** → Fréquence
6. **Que se passe-t-il si [situation anormale] ?** → Exceptions
7. **Y a-t-il des règles métier qui s'appliquent à certaines étapes ?** → Règles de gestion
8. **Y a-t-il des écrans ou des maquettes associés ?** → IHM
9. **Quels objets métier sont impliqués ?** → Objets participants
10. **Ce UC dépend-il d'un autre UC ou en inclut-il un ?** → Relations

L'utilisateur peut fournir un **schéma** (diagramme, maquette, capture d'écran) que
Claude interprète pour alimenter les champs du UC.
