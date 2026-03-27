# Distribution Makefile — Ideas

## Concept

Git clone ce projet a cote des autres projets. Un `make copy` permet de selectionner dans quels projets on veut distribuer les fichiers de `.claude/`.

Pas de submodule, pas de sparse checkout — juste une copie controlable.

## Fichiers distribues

Seuls les repertoires utiles a `.claude/` sont copies :
- `skills/`
- `commands/`
- `rules/`

## Questions ouvertes

### 1. Ou stocker la liste des projets cibles ?

Options :
- **Fichier `targets.txt`** avec un chemin par ligne (simple, versionnable ou `.gitignore`-able)
- **Argument au Makefile** : `make copy TARGETS="~/proj-a ~/proj-b"` (flexible, rien a persister)
- **Scan automatique** d'un dossier parent : tous les voisins qui ont un `.claude/` (magique mais risque)

### 2. Comportement si le projet cible a deja des fichiers dans `.claude/` ?

- Ecrasement silencieux (rsync --delete) ?
- Confirmation interactive ?
- Mode dry-run par defaut (`make copy-dry`) + mode effectif (`make copy`) ?

### 3. Faut-il un `make diff` ?

Pour voir ce qui a change entre le repo source et les copies installees avant de copier. Permet de verifier avant d'ecraser.

## Esquisse du Makefile

```makefile
TARGETS_FILE := targets.txt
DIRS := skills commands rules

# Copie skills/, commands/, rules/ vers les .claude/ des projets cibles
copy:
	@if [ ! -f $(TARGETS_FILE) ]; then echo "Error: $(TARGETS_FILE) not found"; exit 1; fi
	@for target in $$(cat $(TARGETS_FILE)); do \
	    mkdir -p "$$target/.claude"; \
	    for dir in $(DIRS); do \
	        rsync -av --delete $$dir/ "$$target/.claude/$$dir/"; \
	    done; \
	    echo "-> $$target/.claude/ updated"; \
	done

# Dry-run: affiche ce qui serait copie sans rien modifier
copy-dry:
	@if [ ! -f $(TARGETS_FILE) ]; then echo "Error: $(TARGETS_FILE) not found"; exit 1; fi
	@for target in $$(cat $(TARGETS_FILE)); do \
	    echo "=== $$target ==="; \
	    for dir in $(DIRS); do \
	        rsync -avn --delete $$dir/ "$$target/.claude/$$dir/"; \
	    done; \
	done

# Diff entre le repo source et les copies installees
diff:
	@if [ ! -f $(TARGETS_FILE) ]; then echo "Error: $(TARGETS_FILE) not found"; exit 1; fi
	@for target in $$(cat $(TARGETS_FILE)); do \
	    echo "=== $$target ==="; \
	    for dir in $(DIRS); do \
	        diff -rq $$dir/ "$$target/.claude/$$dir/" 2>/dev/null || true; \
	    done; \
	done

# Liste les projets cibles et leur statut
status:
	@if [ ! -f $(TARGETS_FILE) ]; then echo "Error: $(TARGETS_FILE) not found"; exit 1; fi
	@for target in $$(cat $(TARGETS_FILE)); do \
	    if [ -d "$$target/.claude" ]; then \
	        echo "OK  $$target"; \
	    else \
	        echo "NEW $$target (no .claude/ yet)"; \
	    fi; \
	done
```

## Format de targets.txt

```
# Un chemin par ligne, commentaires avec #
/home/franz/prog/project-a
/home/franz/prog/project-b
```

Ajouter `targets.txt` au `.gitignore` car les chemins sont specifiques a chaque machine.

## Distribution enterprise — make zip

### Contexte

Claude.ai en version entreprise permet d'installer des skills a disposition de tous les utilisateurs de l'organisation. Les skills doivent etre uploadees sous forme de fichier ZIP.

### Cibles de packaging

Chaque skill doit etre zippee individuellement (un ZIP par skill) pour pouvoir etre installee separement dans claude.ai :

```
dist/
├── sdd-spec-write.zip
├── sdd-uc-spec-write.zip
├── sdd-system-design.zip
└── sdd-uc-system-design.zip
```

On peut aussi produire un ZIP global contenant toutes les skills pour un import en lot :

```
dist/
├── sdd-spec-write.zip
├── sdd-uc-spec-write.zip
├── sdd-system-design.zip
├── sdd-uc-system-design.zip
└── sdd-all-skills.zip          # toutes les skills dans un seul ZIP
```

### Decisions

1. **Commands et rules : non inclus.** Claude.ai web (enterprise) fonctionne avec des projets et du "project knowledge". Il n'a pas d'equivalent aux `.claude/commands/` ni aux `.claude/rules/` qui sont specifiques a Claude Code (CLI/IDE). Seules les skills (SKILL.md) sont portables entre Claude Code et claude.ai. Les commands et rules restent distribues uniquement via `make copy` pour les projets Claude Code locaux.

2. **Pas de version dans le nom du ZIP.** La version est deja dans le SKILL.md (frontmatter ou corps). Versionner le nom du fichier (`sdd-spec-write-v1.0.0.zip`) cree une charge de maintenance (renommer a chaque release, supprimer l'ancien upload, gerer les anciens noms). Garder des noms stables (`sdd-spec-write.zip`) et laisser la version interne faire foi.

3. **ZIP avec dossier racine.** Le standard agentskills.io definit une skill comme un dossier contenant un `SKILL.md`. Le ZIP doit contenir `sdd-spec-write/SKILL.md` (et `sdd-spec-write/references/` si present), pas un `SKILL.md` nu. C'est ce que le `(cd skills && zip -r ...)` produit deja.

### Esquisse Makefile

```makefile
DIST_DIR := dist
SKILLS := $(wildcard skills/*)

# Zip chaque skill individuellement
zip: clean-dist
	@mkdir -p $(DIST_DIR)
	@for skill in $(SKILLS); do \
	    name=$$(basename $$skill); \
	    (cd skills && zip -r ../$(DIST_DIR)/$$name.zip $$name/); \
	    echo "-> $(DIST_DIR)/$$name.zip"; \
	done
	@echo "Done. $$(ls $(DIST_DIR)/*.zip | wc -l) archives created in $(DIST_DIR)/"

# Zip toutes les skills dans un seul fichier
zip-all: zip
	@(cd skills && zip -r ../$(DIST_DIR)/sdd-all-skills.zip ./)
	@echo "-> $(DIST_DIR)/sdd-all-skills.zip"

# Lister le contenu des ZIPs pour verification
zip-check:
	@for z in $(DIST_DIR)/*.zip; do \
	    echo "=== $$z ==="; \
	    unzip -l "$$z"; \
	done

# Nettoyer le repertoire de distribution
clean-dist:
	@rm -rf $(DIST_DIR)
```

### Workflow prevu

```bash
# Generer les ZIPs
make zip

# Verifier le contenu
make zip-check

# Uploader dans claude.ai enterprise
# (manuel — via l'interface admin claude.ai)
```
