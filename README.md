# claude-code-skills

Skills et règles Claude Code pour implémenter la méthodologie **Spec Driven Development (SDD)** dans une organisation.

Les skills sont conformes au standard [agentskills.io](https://agentskills.io/home).

## Pipeline SDD

| # | Icône | Skill | Version | Invocation | Phase |
|---|-------|-------|---------|-----------|-------|
| 1 | 🖊️ | sdd-uc-spec-write | v2.1.0 | Automatique | Spécification |
| 2 | 📐 | sdd-uc-system-design | v3.1.0 | Automatique | Conception technique |
| 3 | 🗺️ | sdd-plan | v1.0.0 | `/sdd-plan` | Planification |
| 4 | 🏗️ | sdd-dev-workflow | v2.1.0 | `/sdd-dev-workflow <lot>` | Développement |
| 5 | 🧪 | sdd-qa-workflow | v1.0.0 | `/sdd-qa-workflow <lot>` | QA |
| 6 | 💡 | sdd-brief | v1.1.0 | `/sdd-brief` | Tableau de bord |

Les skills auto-déclenchés (1-2) sont activés par Claude quand la demande correspond. Les skills invocables (3-6) ne se lancent que via `/nom-skill`.

## Contenu

| Répertoire | Rôle | Cible |
|---|---|---|
| `skills/` | Skills SDD (SKILL.md) — pipeline complet de la spec à la QA | Claude Code + claude.ai enterprise |
| `rules/` | Règles auto-déclenchées sur des chemins de fichiers | Claude Code uniquement |
| `claude-file/` | Template CLAUDE.md décrivant le processus SDD | À copier dans les projets cibles |
| `tests/` | Tests de régression (CDC de référence, prompts, contrôles) | Interne |
| `to-do/` | Revues et améliorations planifiées | Interne |

## Skills

### 🖊️ sdd-uc-spec-write

Rédige des spécifications SDD structurées par cas d'utilisation (UC).

**Déclenchement :** demander une spec SDD par cas d'utilisation, ou fournir un SPEC.md existant à modifier.

**Processus :** dialogue en 3 étapes — Cadrage → Cas d'utilisation → Compléments.

**Produit :** `docs/SPEC.md` structuré par UC, avec diagrammes Mermaid.

### 📐 sdd-uc-system-design

Produit les documents de conception technique. Gère les architectures SaaS, client lourd, driver et logiciel embarqué (mobile, TPE, terminal pro, dev board).

**Déclenchement :** demander l'architecture, le déploiement, la sécurité ou la conformité d'un projet SDD.

**Processus :** dialogue en 4 phases — Architecture → Déploiement → Sécurité → Conformité.

**Produit :** `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md`, `docs/SECURITY.md`, `docs/COMPLIANCE_MATRIX.md`.

### 🗺️ /sdd-plan

Planifie le développement en lots à partir du SPEC.md et de l'ARCHITECTURE.md. Propose un découpage, le soumet au pilote pour validation, puis produit les fichiers `plan/<lot>.md`.

**Usage :** `/sdd-plan`

### 🏗️ /sdd-dev-workflow

Pilote le développement d'un lot : implémentation itérative, écriture des tests, vérification des AC. Supporte la reprise après échec QA (🔧).

**Usage :** `/sdd-dev-workflow <nom-lot>`

### 🧪 /sdd-qa-workflow

Pilote la recette de test d'un lot : plan de test, exécution, revue de code, rapport QA.

**Usage :** `/sdd-qa-workflow <nom-lot>`

**Prérequis :** le lot doit être complet avec des AC à 100%.

### 💡 /sdd-brief

Charge le contexte complet d'un projet SDD en début de session : état des livrables, phase courante, progression des lots, outils disponibles.

**Usage :** `/sdd-brief`

## Distribution

Ce projet se clone à côté des projets de travail. Les fichiers sont distribués de trois façons :

- **`make install`** — Installe les skills dans `~/.claude/skills/` (disponibles dans tous les projets). Sauvegarde automatique avant installation.
- **`make copy`** — Copie `skills/`, `rules/` dans le `.claude/` des projets locaux listés dans `targets.txt`.
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

| Commande | Rôle |
|---|---|
| `make install` | Installe les skills dans `~/.claude/skills/` (avec backup) |
| `make copy` | Copie les fichiers vers les projets cibles |
| `make copy-dry` | Affiche ce qui serait copié sans rien modifier |
| `make diff` | Compare le repo source avec les copies installées |
| `make status` | Liste les projets cibles et leur état |
| `make zip` | Produit un ZIP par skill dans `dist/` |
| `make zip-all` | Ajoute un ZIP global contenant toutes les skills |

## Tests

Les skills sont testés avec un cahier des charges fixe (CDC MaintiX — coordination d'interventions de maintenance industrielle). Le CDC couvre : machine à états, niveaux de support GMAO, mode offline, capteurs IoT, phases de livraison, permis de travail réglementaire, 5 acteurs dont 2 systèmes.

Le flux de test simule un vrai projet SDD dans `tests/output/` :

| # | Étape | Cible make | Type |
|---|-------|-----------|------|
| 1 | Contrôles structurels du skill | `test-system-design` | Déterministe |
| 2 | Génération CLAUDE.md | `test-init` | Claude |
| 3 | Production SPEC.md | `test-uc-spec` | Claude |
| 4 | Évaluation SPEC.md | `test-review` | Claude |
| 5 | Production docs de conception | `test-uc-system-design` | Claude |
| 6 | Planification en lots | `test-plan` | Claude |
| 7 | Développement premier lot | `test-dev-workflow` | Claude |
| 8 | Brief projet | `test-brief` | Claude |
| 9 | Contrôles SPEC.md | `test-check` | Déterministe |
| 10 | Contrôles docs de conception | `test-system-design-check` | Déterministe |
| 11 | Contrôles fichiers de plan | `test-plan-check` | Déterministe |
| 12 | Contrôles code + tests | `test-dev-check` | Déterministe |
| 13 | Contrôles brief | `test-brief-check` | Déterministe |

`make test` lance la chaîne complète. Prérequis : `python3`, `claude`, `rsync`, `tar` (vérifiés par `make check-deps`).

**Note :** `test-setup` sauvegarde `~/.claude/skills/` et le remplace temporairement par les skills du repo. `make clean-test` restaure les skills originaux.

## Améliorations planifiées

Les revues et améliorations sont documentées dans `to-do/` :

- **Rules** — À supprimer ou repurposer : le contenu actuel est redondant avec les skills et le CLAUDE.md.
- **Distribution** — Valider le format de ZIP attendu par claude.ai enterprise.

## Fichiers CLAUDE.md

- **`CLAUDE.md` (racine)** — Guide Claude Code pour travailler sur ce dépôt.
- **`claude-file/CLAUDE.md`** — Template à copier dans les projets cibles. Décrit le processus SDD et les règles de collaboration avec Claude Code. **Attention :** ne jamais écraser un CLAUDE.md existant dans un projet en cours. Pour un nouveau projet, copier le template puis le compléter. Pour un projet existant, fusionner manuellement les sections du template avec le contenu déjà en place.
