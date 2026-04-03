# claude-code-skills

Skills et règles Claude Code pour implémenter la méthodologie **Spec Driven Development (SDD)** dans une organisation.

Les skills sont conformes au standard [agentskills.io](https://agentskills.io/home).

## Contenu

| Répertoire | Rôle | Cible |
|---|---|---|
| `skills/` | Skills SDD (SKILL.md) — spécification, conception, dev, QA, brief | Claude Code + claude.ai enterprise |
| `rules/` | Règles auto-déclenchées sur des chemins de fichiers | Claude Code uniquement |
| `claude-file/` | Template CLAUDE.md décrivant la boucle de rétroaction SDD | À copier dans les projets cibles |
| `tests/` | Tests de régression des skills (CDC de référence, prompts, sorties) | Interne |
| `to-do/` | Revues et améliorations planifiées | Interne |

## Distribution

Ce projet se clone à côté des projets de travail. Les fichiers sont distribués de deux façons :

- **`make install`** — Installe les skills dans `~/.claude/skills/` (disponibles dans tous les projets).
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
| `make install` | Installe les skills dans `~/.claude/skills/` |
| `make copy` | Copie les fichiers vers les projets cibles |
| `make copy-dry` | Affiche ce qui serait copié sans rien modifier |
| `make diff` | Compare le repo source avec les copies installées |
| `make status` | Liste les projets cibles et leur état |
| `make zip` | Produit un ZIP par skill dans `dist/` |
| `make zip-all` | Ajoute un ZIP global contenant toutes les skills |

## Skills

Les skills auto-déclenchés sont activés automatiquement par Claude. Les skills avec `disable-model-invocation: true` ne sont invocables que par l'utilisateur via `/nom-skill`.

### Skills auto-déclenchés

#### sdd-uc-spec-write

Rédige des spécifications SDD structurées par cas d'utilisation (UC).

**Déclenchement :** demander une spec SDD par cas d'utilisation, ou fournir un SPEC.md existant à modifier.

**Processus :** dialogue en 3 étapes — Cadrage → Cas d'utilisation → Compléments.

**Produit :** `docs/SPEC.md` structuré par UC, avec diagrammes Mermaid.

#### sdd-uc-system-design

Produit les documents de conception technique. Gère les architectures SaaS, client lourd, driver et logiciel embarqué (mobile, TPE, terminal pro, dev board).

**Déclenchement :** demander l'architecture, le déploiement, la sécurité ou la conformité d'un projet SDD.

**Processus :** dialogue en 4 phases — Architecture → Déploiement → Sécurité → Conformité.

**Produit :** `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md`, `docs/SECURITY.md`, `docs/COMPLIANCE_MATRIX.md`.

### Skills invocables par l'utilisateur uniquement

#### /sdd-brief

Charge le contexte complet d'un projet SDD en début de session : état des livrables, phase courante, progression des EPICs, outils disponibles.

**Usage :** `/sdd-brief`

#### /sdd-dev-workflow

Pilote le développement d'un EPIC : implémentation itérative, vérification des AC, mise à jour du plan.

**Usage :** `/sdd-dev-workflow <nom-epic>`

#### /sdd-qa-workflow

Pilote la recette de test d'un EPIC : plan de test, exécution, revue de code, rapport QA.

**Usage :** `/sdd-qa-workflow <nom-epic>`

**Prérequis :** l'EPIC doit être complet avec des AC à 100%.

## Tests

Les deux skills sont testés avec un cahier des charges fixe (CDC MaintiX — coordination d'interventions de maintenance industrielle). Le CDC couvre largement les capacités des skills : machine à états, niveaux de support GMAO, mode offline, capteurs IoT, phases de livraison, permis de travail réglementaire, 5 acteurs dont 2 systèmes.

Le flux de test simule un vrai projet SDD dans `tests/output/` :
1. `make test-system-design` — contrôles structurels du skill (fichiers, numérotation, cohérence)
2. `make test-init` — Claude génère `CLAUDE.md`
3. `make test-uc-spec` — Claude produit `docs/SPEC.md` via `sdd-uc-spec-write`
4. `make test-review` — Claude évalue la complétude du SPEC.md
5. `make test-uc-system-design` — Claude produit les documents de conception via `sdd-uc-system-design`
6. `make test-check` — contrôles déterministes sur le SPEC.md (seuils UC/RG/CA/ENF, valeurs métier)
7. `make test-system-design-check` — contrôles déterministes sur les documents de conception

Les tests appellent `claude -p --output-format stream-json` via le script `tests/run-tests.sh`. La sortie est affichée en temps réel par `tests/stream_filter.py` et sauvegardée dans `tests/log/`. Prérequis : `python3`, `claude`, `rsync` (vérifiés par `make check-deps`).

**Note :** `test-setup` sauvegarde `~/.claude/skills/` et le remplace temporairement par les skills UC du repo. `make clean-test` restaure les skills originaux.

| Commande | Rôle |
|---|---|
| `make test` | Lance tous les tests dans l'ordre |
| `make test-system-design` | Contrôles structurels du skill system-design |
| `make test-check` | Contrôles déterministes sur le SPEC.md |
| `make test-system-design-check` | Contrôles déterministes sur les docs de conception |
| `make test-review` | Évaluation de complétude par Claude |
| `make clean-test` | Supprime les sorties de test et restaure `~/.claude/skills/` |

## Améliorations planifiées

Les revues et améliorations sont documentées dans `to-do/` :

- **Rules** — À supprimer ou repurposer : le contenu actuel est redondant avec les skills et le CLAUDE.md.
- **Distribution** — Valider le format de ZIP attendu par claude.ai enterprise.

## Fichiers CLAUDE.md

- **`CLAUDE.md` (racine)** — Guide Claude Code pour travailler sur ce dépôt.
- **`claude-file/CLAUDE.md`** — Template à copier dans les projets cibles. Décrit le processus SDD et les règles de collaboration avec Claude Code. **Attention :** ne jamais écraser un CLAUDE.md existant dans un projet en cours. Pour un nouveau projet, copier le template puis le compléter. Pour un projet existant, fusionner manuellement les sections du template avec le contenu déjà en place.
