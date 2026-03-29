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
| `tests/` | Tests de régression des skills (CDC de référence, prompts, sorties) | Interne |
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

## Tests

Le skill `sdd-uc-spec-write` est testé avec un cahier des charges fixe (CDC MaintiX — coordination d'interventions de maintenance industrielle) qui produit un SPEC.md quasi-déterministe. Cela permet de détecter les régressions lors des modifications du skill.

Le CDC MaintiX couvre largement les capacités du skill : machine à états, niveaux de support GMAO (système existant), mode offline, capteurs IoT, phases de livraison, permis de travail réglementaire, 5 acteurs dont 2 systèmes.

Les skills sans UC (`sdd-spec-write`, `sdd-system-design`) ne sont pas testés : ils sont destinés à être rendus obsolètes au profit des variantes UC.

Le flux de test simule un vrai projet SDD dans `tests/output/` :
1. `make test-setup` — prépare le projet simulé (copie skills/commands/rules dans `.claude/`, copie le CDC dans `docs/`)
2. `make test-init` — Claude analyse le projet et génère `CLAUDE.md` en fusionnant avec le template SDD
3. `make test-uc-spec` — Claude produit `docs/SPEC.md` à partir du CDC via le skill `sdd-uc-spec-write`
4. `make test-check` — compare les fichiers générés contre les références

Les tests appellent `claude -p --output-format stream-json` via le script `tests/run-tests.sh`. La sortie est affichée en temps réel par `tests/stream_filter.py` (filtre Python unbuffered) et sauvegardée dans `tests/log/`. Prérequis : `claude`, `python3`.

| Commande | Rôle |
|---|---|
| `make test` | Lance tous les tests dans l'ordre |
| `make test-check` | Vérifie les sorties contre les références |
| `make test-accept` | Accepte les sorties courantes comme nouvelles références |
| `make clean-test` | Supprime les sorties de test |

Première exécution : `make test` puis `make test-accept` pour établir les références. Exécutions suivantes : `make test` puis `make test-check` pour détecter les écarts.

## Améliorations planifiées

Les revues et améliorations sont documentées dans `to-do/` :

- **Skills** — Réduire la taille des SKILL.md (2-3x au-dessus de la limite agentskills.io), extraire les templates et glossaires dans des fichiers `references/`, harmoniser les frontmatter YAML entre les 4 skills.
- **Commandes** — Ajouter le frontmatter YAML (description, argument-hint, allowed-tools), aligner les identifiants AC/CA entre commandes et skills, ajouter des gardes sur les fichiers manquants.
- **Rules** — À supprimer ou repurposer : le contenu actuel est redondant avec les commandes et le CLAUDE.md.
- **Distribution** — Le Makefile de distribution (`make copy`, `make zip`) est opérationnel. Reste à valider le format de ZIP attendu par claude.ai enterprise.

## Fichiers CLAUDE.md

- **`CLAUDE.md` (racine)** — Guide Claude Code pour travailler sur ce dépôt.
- **`claude-file/CLAUDE.md`** — Template à copier dans les projets cibles. Décrit le processus SDD et les règles de collaboration avec Claude Code. **Attention :** ne jamais écraser un CLAUDE.md existant dans un projet en cours. Pour un nouveau projet, copier le template puis le compléter. Pour un projet existant, fusionner manuellement les sections du template avec le contenu déjà en place.
