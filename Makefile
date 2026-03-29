# =============================================================================
# claude-code-skills — Makefile
# =============================================================================
#
# Distribution locale :
#   make copy       — Copie skills/commands/rules vers les projets cibles
#   make copy-dry   — Simule la copie sans rien modifier
#   make diff       — Compare le repo avec les copies installées
#   make status     — Liste les projets cibles et leur état
#
# Distribution enterprise :
#   make zip        — Produit un ZIP par skill dans dist/
#   make zip-all    — Ajoute un ZIP global contenant toutes les skills
#   make zip-check  — Affiche le contenu des ZIPs pour vérification
#   make clean-dist — Supprime le répertoire dist/
#
# Tests :
#   make test              — Lance tous les tests
#   make test-init         — Génère le CLAUDE.md via /init + template SDD
#   make test-uc-spec      — Teste sdd-uc-spec-write sur MaintiX
#   make test-setup        — Prépare l'environnement de test
#   make test-check        — Vérifie les sorties contre les références
#   make test-accept       — Accepte les sorties courantes comme références
#   make clean-test        — Supprime les sorties de test
# =============================================================================

TARGETS_FILE := targets.txt
DIST_DIR     := dist
DIRS         := skills commands rules
SKILLS       := $(wildcard skills/*)

TEST_DIR     := tests
TEST_OUT     := $(TEST_DIR)/output
TEST_LOG     := $(TEST_DIR)/log

.PHONY: help copy copy-dry diff status zip zip-all zip-check clean-dist \
        test test-init test-uc-spec test-setup test-check test-accept \
        clean-test

.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Aide
# -----------------------------------------------------------------------------

help:
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  Distribution locale (Claude Code) :"
	@echo "    make copy       Copie skills/commands/rules vers les projets cibles"
	@echo "    make copy-dry   Simule la copie sans rien modifier"
	@echo "    make diff       Compare le repo avec les copies installées"
	@echo "    make status     Liste les projets cibles et leur état"
	@echo ""
	@echo "  Distribution enterprise (claude.ai) :"
	@echo "    make zip        Produit un ZIP par skill dans dist/"
	@echo "    make zip-all    Ajoute un ZIP global avec toutes les skills"
	@echo "    make zip-check  Affiche le contenu des ZIPs"
	@echo "    make clean-dist Supprime le répertoire dist/"
	@echo ""
	@echo "  Tests :"
	@echo "    make test            Lance tous les tests"
	@echo "    make test-init       Génère le CLAUDE.md via /init + template SDD"
	@echo "    make test-uc-spec    Teste sdd-uc-spec-write sur MaintiX"
	@echo "    make test-check      Vérifie les sorties contre les références"
	@echo "    make test-accept     Accepte les sorties comme références"
	@echo "    make clean-test      Supprime les sorties de test"
	@echo ""
	@echo "  Configuration :"
	@echo "    Créer un fichier targets.txt avec un chemin absolu par ligne."
	@echo "    Les lignes vides et les commentaires (#) sont ignorés."

# -----------------------------------------------------------------------------
# Vérification du fichier targets.txt
# -----------------------------------------------------------------------------

define check_targets
	@if [ ! -f $(TARGETS_FILE) ]; then \
		echo "Erreur : $(TARGETS_FILE) introuvable."; \
		echo "Créer le fichier avec un chemin de projet par ligne :"; \
		echo ""; \
		echo "  echo '/home/user/prog/mon-projet' > $(TARGETS_FILE)"; \
		echo ""; \
		exit 1; \
	fi
endef

# Lecture de targets.txt en ignorant les commentaires et lignes vides
READ_TARGETS = grep -v '^\s*\#' $(TARGETS_FILE) | grep -v '^\s*$$'

# -----------------------------------------------------------------------------
# Distribution locale — copie vers les projets cibles
# -----------------------------------------------------------------------------

copy:
	$(check_targets)
	@$(READ_TARGETS) | while IFS= read -r target; do \
		echo "=== $$target ==="; \
		if [ ! -d "$$target" ]; then \
			echo "  SKIP — répertoire inexistant"; \
			continue; \
		fi; \
		mkdir -p "$$target/.claude"; \
		for dir in $(DIRS); do \
			rsync -av --delete $$dir/ "$$target/.claude/$$dir/"; \
		done; \
		echo "  -> $$target/.claude/ mis à jour"; \
		echo ""; \
	done

copy-dry:
	$(check_targets)
	@$(READ_TARGETS) | while IFS= read -r target; do \
		echo "=== $$target ==="; \
		if [ ! -d "$$target" ]; then \
			echo "  SKIP — répertoire inexistant"; \
			continue; \
		fi; \
		for dir in $(DIRS); do \
			rsync -avn --delete $$dir/ "$$target/.claude/$$dir/"; \
		done; \
		echo ""; \
	done

diff:
	$(check_targets)
	@$(READ_TARGETS) | while IFS= read -r target; do \
		echo "=== $$target ==="; \
		if [ ! -d "$$target/.claude" ]; then \
			echo "  Pas de .claude/ dans ce projet"; \
			continue; \
		fi; \
		for dir in $(DIRS); do \
			if [ -d "$$target/.claude/$$dir" ]; then \
				diff -rq $$dir/ "$$target/.claude/$$dir/" 2>/dev/null || true; \
			else \
				echo "  $$dir/ absent dans la cible"; \
			fi; \
		done; \
		echo ""; \
	done

status:
	$(check_targets)
	@$(READ_TARGETS) | while IFS= read -r target; do \
		if [ ! -d "$$target" ]; then \
			echo "MISS  $$target (répertoire inexistant)"; \
		elif [ ! -d "$$target/.claude" ]; then \
			echo "NEW   $$target (pas de .claude/)"; \
		else \
			echo "OK    $$target"; \
		fi; \
	done

# -----------------------------------------------------------------------------
# Distribution enterprise — packaging ZIP pour claude.ai
# -----------------------------------------------------------------------------

zip: clean-dist
	@mkdir -p $(DIST_DIR)
	@for skill in $(SKILLS); do \
		name=$$(basename $$skill); \
		(cd skills && zip -rq ../$(DIST_DIR)/$$name.zip $$name/); \
		echo "  -> $(DIST_DIR)/$$name.zip"; \
	done
	@echo ""
	@echo "$$(ls $(DIST_DIR)/*.zip 2>/dev/null | wc -l) archive(s) créée(s) dans $(DIST_DIR)/"

zip-all: zip
	@(cd skills && zip -rq ../$(DIST_DIR)/sdd-all-skills.zip ./)
	@echo "  -> $(DIST_DIR)/sdd-all-skills.zip"

zip-check:
	@if [ ! -d $(DIST_DIR) ] || [ -z "$$(ls $(DIST_DIR)/*.zip 2>/dev/null)" ]; then \
		echo "Aucun ZIP trouvé dans $(DIST_DIR)/. Lancer 'make zip' d'abord."; \
		exit 1; \
	fi
	@for z in $(DIST_DIR)/*.zip; do \
		echo "=== $$z ==="; \
		unzip -l "$$z"; \
		echo ""; \
	done

clean-dist:
	@rm -rf $(DIST_DIR)

# -----------------------------------------------------------------------------
# Tests — validation du skill sdd-uc-spec-write avec un CDC de référence
# -----------------------------------------------------------------------------
#
# CDC de test : MaintiX (maintenance industrielle)
# Couvre : machine à états, niveaux de support GMAO, mode offline,
#          capteurs IoT, phases de livraison, permis de travail (ICPE)
#
# Seul le skill sdd-uc-spec-write est testé. Les skills sans UC
# (sdd-spec-write, sdd-system-design) ne sont pas testés.
#
# Le répertoire tests/output/ est le projet simulé (répertoire de travail
# de Claude). Il contient la même structure qu'un vrai projet SDD :
#   output/.claude/     skills/commands/rules
#   output/CLAUDE.md    généré par test-init
#   output/docs/        CDC (copié) + SPEC.md (généré par test-uc-spec)
#
# Flux de test complet :
#   1. test-setup       Prépare output/ (skills + CDC)
#   2. test-init        Génère output/CLAUDE.md
#   3. test-uc-spec     Génère output/docs/SPEC.md
#   4. test-check       Compare output/ contre reference/
#
# Première exécution :
#   make test               Génère toutes les sorties
#   make test-check         Vérifie (échoue car pas de références)
#   make test-accept        Accepte les sorties comme références
#
# Exécutions suivantes (après modification d'un skill) :
#   make test               Régénère toutes les sorties
#   make test-check         Compare avec les références
# -----------------------------------------------------------------------------

# Valeurs métier attendues dans le SPEC.md (séparées par |)
EXPECTED_VALUES := 15 min|4h|24h|10 ans|6 mois|2 ans|300ms|99,5%|200 techniciens|8 heures|30 secondes|10 secondes

# Vérifie les dépendances
check-deps:
	@command -v python3 >/dev/null 2>&1 || { echo "Erreur : python3 est requis."; exit 1; }
	@command -v claude >/dev/null 2>&1 || { echo "Erreur : claude est requis."; exit 1; }

# Prépare le projet simulé dans output/ : skills + CDC
test-setup: check-deps
	@echo "Préparation du projet de test dans $(TEST_OUT)/..."
	@mkdir -p $(TEST_OUT)/.claude $(TEST_OUT)/docs $(TEST_LOG)
	@for dir in $(DIRS); do \
		rsync -a --delete $$dir/ $(TEST_OUT)/.claude/$$dir/; \
	done
	@cp $(TEST_DIR)/docs/CDC-maintenance.md $(TEST_OUT)/docs/CDC-maintenance.md
	@echo "  ✓ $(TEST_OUT)/.claude/ prêt (skills, commands, rules)"
	@echo "  ✓ $(TEST_OUT)/docs/CDC-maintenance.md copié"

# Lance tous les tests dans l'ordre
test: test-setup
	$(TEST_DIR)/run-tests.sh all

# Génère le CLAUDE.md dans output/
test-init: test-setup
	$(TEST_DIR)/run-tests.sh init

# Produit le SPEC.md dans output/docs/
test-uc-spec: test-setup
	$(TEST_DIR)/run-tests.sh uc-spec

# Vérifie les fichiers générés contre les références
test-check:
	@echo ""
	@echo "Vérification contre les références..."
	@fail=0; \
	echo ""; \
	echo "=== CLAUDE.md ==="; \
	out="$(TEST_OUT)/CLAUDE.md"; \
	ref="$(TEST_DIR)/reference/CLAUDE.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — pas de fichier (lancer 'make test' d'abord)"; \
	elif [ ! -f "$$ref" ]; then \
		echo "  SKIP — pas de référence (lancer 'make test-accept' pour créer)"; \
	else \
		echo "  Sections attendues du template SDD :"; \
		for section in "Processus global" "Vue d'ensemble" "Méthode de travail" "Règles pour Claude Code" "Workflow de développement" "Commits"; do \
			if grep -qi "$$section" "$$out"; then \
				echo "    \"$$section\" : OK"; \
			else \
				echo "    \"$$section\" : ABSENT"; \
				fail=1; \
			fi; \
		done; \
	fi; \
	echo ""; \
	echo "=== docs/SPEC.md ==="; \
	out="$(TEST_OUT)/docs/SPEC.md"; \
	ref="$(TEST_DIR)/reference/SPEC.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — pas de fichier (lancer 'make test' d'abord)"; \
	elif [ ! -f "$$ref" ]; then \
		echo "  SKIP — pas de référence (lancer 'make test-accept' pour créer)"; \
	else \
		echo "  Structure :"; \
		out_sections=$$(grep -c '^#' "$$out" || true); \
		ref_sections=$$(grep -c '^#' "$$ref" || true); \
		echo "    Sections : sortie=$$out_sections référence=$$ref_sections"; \
		echo "  Identifiants :"; \
		for prefix in ENF CA UC RG IHM; do \
			out_count=$$(grep -oE "$$prefix-[0-9]+" "$$out" 2>/dev/null | sort -u | wc -l); \
			ref_count=$$(grep -oE "$$prefix-[0-9]+" "$$ref" 2>/dev/null | sort -u | wc -l); \
			if [ "$$ref_count" -gt 0 ] || [ "$$out_count" -gt 0 ]; then \
				status="OK"; \
				if [ "$$out_count" -ne "$$ref_count" ]; then status="DIFF"; fail=1; fi; \
				echo "    $$prefix : sortie=$$out_count référence=$$ref_count [$$status]"; \
			fi; \
		done; \
		echo "  Valeurs métier :"; \
		echo "$(EXPECTED_VALUES)" | tr '|' '\n' | while IFS= read -r val; do \
			if grep -q "$$val" "$$ref"; then \
				if grep -q "$$val" "$$out"; then \
					echo "    \"$$val\" : OK"; \
				else \
					echo "    \"$$val\" : ABSENT dans la sortie"; \
					fail=1; \
				fi; \
			fi; \
		done; \
	fi; \
	echo ""; \
	if [ "$$fail" -eq 0 ]; then \
		echo "Tous les contrôles passent."; \
	else \
		echo "Des écarts ont été détectés."; \
	fi

# Accepte les fichiers générés comme nouvelles références
test-accept:
	@if [ -f "$(TEST_OUT)/CLAUDE.md" ]; then \
		cp "$(TEST_OUT)/CLAUDE.md" "$(TEST_DIR)/reference/CLAUDE.md"; \
		echo "  ✓ tests/reference/CLAUDE.md mis à jour"; \
	else \
		echo "  SKIP — $(TEST_OUT)/CLAUDE.md absent"; \
	fi
	@if [ -f "$(TEST_OUT)/docs/SPEC.md" ]; then \
		cp "$(TEST_OUT)/docs/SPEC.md" "$(TEST_DIR)/reference/SPEC.md"; \
		echo "  ✓ tests/reference/SPEC.md mis à jour"; \
	else \
		echo "  SKIP — $(TEST_OUT)/docs/SPEC.md absent"; \
	fi

# Supprime le projet simulé et les logs (conserve le CDC, les prompts et les références)
clean-test:
	@rm -rf $(TEST_OUT)
	@rm -rf $(TEST_LOG)
	@echo "Projet de test et logs supprimés."
