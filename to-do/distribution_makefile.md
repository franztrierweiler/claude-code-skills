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
