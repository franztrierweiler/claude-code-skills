# claude-code-skills

Skills, commandes et règles Claude Code pour implémenter la méthodologie **Spec Driven Development (SDD)** dans une organisation.

Les skills sont conformes au standard [agentskills.io](https://agentskills.io/home).

## Contenu

| Répertoire | Rôle | Cible |
|---|---|---|
| `skills/` | Skills SDD (SKILL.md) — spécification, conception technique | Claude Code + claude.ai enterprise |
| `commands/` | Commandes slash — workflows de développement et QA | Claude Code uniquement |
| `rules/` | Règles auto-déclenchées sur des chemins de fichiers | Claude Code uniquement |
| `claude-file/` | Template CLAUDE.md décrivant la boucle de rétroaction SDD | À copier dans les projets cibles |
| `to-do/` | Revues et améliorations planifiées | Interne |

## Deux variantes SDD

- **`sdd-uc-*`** — Structuration par cas d'utilisation (Use Case). Variante détaillée, adaptée aux projets avec interactions utilisateur complexes.
- **`sdd-*`** (sans `uc`) — Structuration par exigences fonctionnelles. Variante plus légère.

Les deux variantes suivent le même pipeline : Spécification → Conception → Planification → Développement → QA → Livraison.

## Distribution

Ce projet se clone à côté des projets de travail. Les fichiers sont distribués de deux façons :

- **`make copy`** — Copie `skills/`, `commands/`, `rules/` dans le `.claude/` des projets locaux listés dans `targets.txt`.
- **`make zip`** — Produit un ZIP par skill dans `dist/` pour upload dans claude.ai enterprise.

### Configuration de targets.txt

Le fichier `targets.txt` liste les projets cibles, un chemin absolu par ligne. Il est propre à chaque machine et ignoré par git.

```bash
# Créer le fichier avec les chemins de vos projets
cat > targets.txt <<EOF
/home/user/prog/project-a
/home/user/prog/project-b
EOF
```

Commandes disponibles :

| Commande | Rôle |
|---|---|
| `make copy` | Copie les fichiers vers les projets cibles |
| `make copy-dry` | Affiche ce qui serait copié sans rien modifier |
| `make diff` | Compare le repo source avec les copies installées |
| `make status` | Liste les projets cibles et leur état |
| `make zip` | Produit un ZIP par skill dans `dist/` |
| `make zip-all` | Ajoute un ZIP global contenant toutes les skills |

## Skills

Les skills sont activées automatiquement par Claude lorsque la demande de l'utilisateur correspond aux critères de déclenchement.

### sdd-spec-write

Rédige des spécifications SDD structurées par exigences fonctionnelles. Produit un `docs/SPEC.md` exploitable par un agent IA pour l'implémentation.

**Déclenchement :** demander une spec SDD, un SPEC.md, ou transformer des notes en spécification structurée.

**Processus :** dialogue en 3 étapes — Cadrage (questions contexte, contraintes) → Exigences (par domaine fonctionnel, avec critères d'acceptation Soit/Quand/Alors et cas limites) → Limites (niveaux de support, hors périmètre). Chaque étape demande validation avant de poursuivre.

**Produit :** `docs/SPEC.md`, et si applicable `GRAMMAR.md`, `DATA-MODEL.md`.

### sdd-uc-spec-write

Rédige des spécifications SDD structurées par cas d'utilisation (UC). Variante plus détaillée de `sdd-spec-write`, adaptée aux projets avec des interactions utilisateur complexes.

**Déclenchement :** demander une spec SDD par cas d'utilisation, ou fournir un SPEC.md existant à modifier.

**Processus :** dialogue en 3 étapes — Cadrage (questions contexte, acteurs, diagramme de contexte) → Cas d'utilisation (arborescence en packages niveau 2/niveau 1, puis rédaction UC par lot avec étapes, exceptions, règles de gestion, IHM) → Compléments (objets participants, exigences non fonctionnelles). Supporte aussi la mise à jour chirurgicale d'une spec existante.

**Produit :** `docs/SPEC.md` structuré par UC, avec diagrammes Mermaid des relations entre UC.

### sdd-system-design

Produit les documents de conception technique à partir d'un SPEC.md existant (variante exigences).

**Déclenchement :** demander l'architecture, le déploiement, la sécurité ou la conformité d'un projet SDD.

**Processus :** dialogue en 4 phases — Architecture (cadrage macro, analyse du SPEC.md, modèle de données, flux, choix technologiques, propriétés non fonctionnelles, synthèse et arbitrages) → Déploiement → Sécurité → Conformité (si cadre réglementaire).

**Produit :** `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md`, `docs/SECURITY.md`, `docs/COMPLIANCE_MATRIX.md` (si applicable).

### sdd-uc-system-design

Produit les documents de conception technique à partir d'un SPEC.md structuré par cas d'utilisation. Variante de `sdd-system-design` adaptée au format UC.

**Déclenchement :** identique à `sdd-system-design`. Détecte automatiquement le format UC du SPEC.md fourni (identifiants `UC-xxx`, packages, étapes Na/Nb).

**Processus :** identique à `sdd-system-design`, avec traçabilité vers les UC, RG et CA-UC du SPEC.md.

**Produit :** identique à `sdd-system-design`.

## Commandes

Les commandes sont invoquées manuellement par l'utilisateur via `/nom-commande`. Elles pilotent les phases opérationnelles du projet (développement, QA).

### /sdd-brief

Initialise le contexte d'une session de travail SDD.

**Usage :** `/sdd-brief` (sans argument)

**Actions :** lit la documentation du projet (`docs/`, `CLAUDE.md`), liste les commandes et skills SDD disponibles, affiche le statut du projet et la progression des EPICs.

### /sdd-dev-workflow

Pilote le développement d'un EPIC : implémentation itérative, vérification des critères d'acceptation, mise à jour du plan.

**Usage :** `/sdd-dev-workflow epic-01-lexer`

**Processus :** charge le plan de l'EPIC → implémente fonctionnalité par fonctionnalité → vérifie chaque AC → exécute les tests via Makefile → produit un rapport AC → met à jour `plan/<epic>.md`. En fin d'EPIC, propose de lancer la QA.

### /sdd-qa-workflow

Pilote la recette de test d'un EPIC : plan de test, exécution, revue de code, rapport QA.

**Usage :** `/sdd-qa-workflow epic-01-lexer`

**Prérequis :** l'EPIC doit être complet avec des AC à 100%. Sinon, redirige vers `/sdd-dev-workflow`.

**Processus :** charge le contexte → élabore le plan de test dans `qa/plan-test-<epic>.md` (soumis au pilote pour validation) → exécute les scénarios → effectue une revue de code dans `qa/code-review/<epic>-review.md` → produit le rapport final dans `qa/qa-results/rapport-<epic>.md`.

## Fichiers CLAUDE.md

- **`CLAUDE.md` (racine)** — Guide Claude Code pour travailler sur ce dépôt.
- **`claude-file/CLAUDE.md`** — Template à copier dans les projets cibles. Décrit le processus SDD et les règles de collaboration avec Claude Code.
