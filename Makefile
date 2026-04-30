# =============================================================================
# claude-code-skills — Makefile
# =============================================================================
#
# Installation globale :
#   make install    — Installe les skills dans ~/.claude/skills/
#
# Distribution locale :
#   make copy       — Copie skills vers les projets cibles
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
# Tests — Génération (Claude) :
#   make test-init                              Génère le CLAUDE.md
#   make test-uc-spec-racine                    Produit le SPEC racine
#   make test-uc-spec-extension                 Produit un SPEC extension
#   make test-uc-system-design                  Produit les docs de conception
#   make test-plan                              Planifie le développement en lots
#   make test-dev-workflow                      Développe le premier lot
#   make test-qa-workflow                       Lance la QA sur le premier lot
#   make test-brief                             Lance /sdd-brief
#   make test-tuto                              Affiche le tutoriel SDD
#
# Tests — Revue qualité (Claude) :
#   make test-uc-spec-racine-review-content     Claude évalue le SPEC racine vs CDC
#   make test-uc-spec-extension-review-content  Claude évalue le SPEC extension
#
# Tests — Contrôles déterministes :
#   make test-skills-check-structure            Contrôles structurels de tous les skills
#   make test-uc-spec-racine-check-structure    Contrôles du SPEC racine
#   make test-uc-spec-extension-check-structure Contrôles du SPEC extension
#   make test-uc-system-design-check-structure  Contrôles des documents de conception
#   make test-plan-check-structure              Contrôles des fichiers de plan
#   make test-dev-workflow-check-structure       Contrôles des sorties du développement
#   make test-qa-workflow-check-structure        Contrôles des sorties QA
#   make test-brief-check-structure             Contrôles de la sortie du brief
#
# Utilitaires :
#   make test-setup               — Prépare l'environnement de test
#   make clean-test               — Supprime les sorties de test
# =============================================================================

TARGETS_FILE := targets.txt
DIST_DIR     := dist
DIRS         := skills
SKILLS       := $(wildcard skills/*)

TEST_DIR     := tests
TEST_OUT     := $(TEST_DIR)/output
TEST_LOG     := $(TEST_DIR)/log

.PHONY: help install copy copy-dry diff status check-deps \
        zip zip-all zip-check clean-dist \
        test test-init test-uc-spec-racine test-uc-spec-extension \
        test-uc-system-design test-plan test-dev-workflow test-qa-workflow \
        test-brief test-tuto \
        test-uc-spec-racine-review-content test-uc-spec-extension-review-content \
        test-skills-check-structure \
        test-uc-spec-racine-check-structure test-uc-spec-extension-check-structure \
        test-uc-system-design-check-structure \
        test-plan-check-structure test-dev-workflow-check-structure \
        test-qa-workflow-check-structure test-brief-check-structure \
        test-setup clean-test \
        clean-dist

.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Aide
# -----------------------------------------------------------------------------

help:
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  Installation globale (~/.claude/) :"
	@echo "    make install      Installe les skills dans ~/.claude/skills/"
	@echo ""
	@echo "  Distribution locale (projets cibles) :"
	@echo "    make copy        Copie skills vers les projets cibles"
	@echo "    make copy-dry    Simule la copie sans rien modifier"
	@echo "    make diff        Compare le repo avec les copies installées"
	@echo "    make status      Liste les projets cibles et leur état"
	@echo ""
	@echo "  Distribution enterprise (claude.ai) :"
	@echo "    make zip        Produit un ZIP par skill dans dist/"
	@echo "    make zip-all    Ajoute un ZIP global avec toutes les skills"
	@echo "    make zip-check  Affiche le contenu des ZIPs"
	@echo "    make clean-dist Supprime le répertoire dist/"
	@echo ""
	@echo "  Tests — Génération (Claude) :"
	@echo "    make test-init                              Génère le CLAUDE.md"
	@echo "    make test-uc-spec-racine                    Produit le SPEC racine"
	@echo "    make test-uc-spec-extension                 Produit un SPEC extension"
	@echo "    make test-uc-system-design                  Produit les docs de conception"
	@echo "    make test-plan                              Planifie le développement en lots"
	@echo "    make test-dev-workflow                      Développe le premier lot"
	@echo "    make test-qa-workflow                       Lance la QA sur le premier lot"
	@echo "    make test-brief                             Lance /sdd-brief"
	@echo "    make test-tuto                              Affiche le tutoriel SDD"
	@echo ""
	@echo "  Tests — Revue qualité (Claude) :"
	@echo "    make test-uc-spec-racine-review-content     Claude évalue le SPEC racine vs CDC"
	@echo "    make test-uc-spec-extension-review-content  Claude évalue le SPEC extension"
	@echo ""
	@echo "  Tests — Contrôles déterministes :"
	@echo "    make test-skills-check-structure             Contrôles structurels de tous les skills"
	@echo "    make test-uc-spec-racine-check-structure     Contrôles du SPEC racine"
	@echo "    make test-uc-spec-extension-check-structure  Contrôles du SPEC extension"
	@echo "    make test-uc-system-design-check-structure   Contrôles des documents de conception"
	@echo "    make test-plan-check-structure               Contrôles des fichiers de plan"
	@echo "    make test-dev-workflow-check-structure        Contrôles des sorties du développement"
	@echo "    make test-qa-workflow-check-structure         Contrôles des sorties QA"
	@echo "    make test-brief-check-structure              Contrôles de la sortie du brief"
	@echo ""
	@echo "  Utilitaires :"
	@echo "    make test-setup    Prépare l'environnement de test"
	@echo "    make clean-test    Supprime les sorties de test"
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
# Installation globale — copie vers ~/.claude/
# -----------------------------------------------------------------------------

install:
	@if [ -d "$(HOME)/.claude/skills" ] && [ "$$(ls -A $(HOME)/.claude/skills 2>/dev/null)" ]; then \
		backup="$(HOME)/.claude/skills-backup-$$(date +%Y%m%d-%H%M%S).tar.gz"; \
		echo "Sauvegarde des skills existants..."; \
		tar -czf "$$backup" -C "$(HOME)/.claude" skills/; \
		echo "  ✓ $$backup"; \
		echo ""; \
	fi
	@echo "Installation des skills dans ~/.claude/skills/..."
	@mkdir -p $(HOME)/.claude/skills
	@for skill in $(SKILLS); do \
		name=$$(basename $$skill); \
		rsync -a --delete $$skill/ $(HOME)/.claude/skills/$$name/; \
		echo "  ✓ $$name"; \
	done
	@echo ""
	@echo "Skills installés globalement dans ~/.claude/skills/"
	@echo "Ces skills seront disponibles dans tous les projets."
	@echo "Pour restaurer : tar -xzf ~/.claude/skills-backup-XXXXXXXX-XXXXXX.tar.gz -C ~/.claude/"

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

# =============================================================================
# Tests
# =============================================================================
#
# CDC de test : MaintiX (maintenance industrielle)
#
# Le répertoire tests/output/ est le projet simulé :
#   output/.claude/     skills
#   output/CLAUDE.md    généré par test-init
#   output/docs/        CDC (copié) + SPEC (généré par test-uc-spec-racine)
# =============================================================================

# Valeurs métier qui doivent apparaître dans le SPEC racine (séparées par |)
EXPECTED_VALUES := 15 min|4 h|24 h|10 ans|6 mois|2 ans|300 ms|99,5 %|200 techniciens|8 heures|30 secondes|10 secondes

# Seuils minimaux d'identifiants dans le SPEC racine
MIN_UC  := 10
MIN_RG  := 10
MIN_CA  := 10
MIN_ENF := 4

# Seuils minimaux pour une extension Alertes capteurs
MIN_UC_EXT  := 3
MIN_RG_EXT  := 2
MIN_CA_EXT  := 3
MIN_ENF_EXT := 1

# Vérifie les dépendances requises
check-deps:
	@echo "Vérification des dépendances..."
	@fail=0; \
	for cmd in python3 claude rsync grep sed zip unzip tar; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  ✓ $$cmd"; \
		else \
			echo "  ✗ $$cmd MANQUANT"; \
			fail=1; \
		fi; \
	done; \
	if [ "$$fail" -eq 1 ]; then \
		echo ""; \
		echo "Installer les dépendances manquantes avant de continuer."; \
		exit 1; \
	fi; \
	echo ""

# Skills à installer dans l'environnement de test
TEST_SKILLS := $(SKILLS)

# Sauvegarde des skills globaux
GLOBAL_SKILLS     := $(HOME)/.claude/skills
GLOBAL_SKILLS_BAK := $(HOME)/.claude/skills.bak

# Prépare le projet simulé dans output/ : skills + CDC
test-setup: check-deps
	@echo "Préparation du projet de test dans $(TEST_OUT)/..."
	@mkdir -p $(TEST_OUT)/.claude/skills $(TEST_OUT)/docs $(TEST_LOG)
	@rm -rf $(TEST_OUT)/.claude/skills/*
	@for skill in $(TEST_SKILLS); do \
		rsync -a $$skill/ $(TEST_OUT)/.claude/$$skill/; \
		echo "  ✓ $$skill (projet)"; \
	done
	@cp $(TEST_DIR)/docs/CDC-maintenance.md $(TEST_OUT)/docs/CDC-maintenance.md
	@echo "  ✓ $(TEST_OUT)/docs/CDC-maintenance.md copié"
	@echo ""
	@echo "⚠️  Isolation des skills globaux pour les tests"
	@echo "    Claude Code charge les skills de ~/.claude/skills/ en priorité"
	@echo "    sur ceux du projet. Pour garantir que les tests utilisent les"
	@echo "    bonnes versions, les skills globaux sont temporairement remplacés."
	@echo ""
	@if [ -d "$(GLOBAL_SKILLS)" ]; then \
		if [ ! -d "$(GLOBAL_SKILLS_BAK)" ]; then \
			echo "    1. Sauvegarde : ~/.claude/skills/ → ~/.claude/skills.bak/"; \
			mv "$(GLOBAL_SKILLS)" "$(GLOBAL_SKILLS_BAK)"; \
		else \
			echo "    1. Sauvegarde : déjà présente (skills.bak/)"; \
		fi; \
		echo "    2. Remplacement : ~/.claude/skills/ ← skills UC du repo"; \
		mkdir -p "$(GLOBAL_SKILLS)"; \
		for skill in $(TEST_SKILLS); do \
			rsync -a $$skill/ $(GLOBAL_SKILLS)/$$(basename $$skill)/; \
			echo "       ✓ $$(basename $$skill)"; \
		done; \
		echo ""; \
		echo "    → Lancer 'make clean-test' pour restaurer les skills originaux."; \
	else \
		echo "    ~/.claude/skills/ absent — rien à sauvegarder."; \
	fi
	@echo ""

# Lance tous les tests (chaîne complète)
test: test-skills-check-structure test-setup
	@echo ""
	@echo "=== Répertoire cible des tests : $(TEST_OUT) ==="
	@echo ""
	$(TEST_DIR)/run-tests.sh all
	$(MAKE) test-uc-spec-racine-check-structure
	$(MAKE) test-uc-spec-extension-check-structure
	$(MAKE) test-uc-system-design-check-structure
	$(MAKE) test-plan-check-structure
	$(MAKE) test-dev-workflow-check-structure
	$(MAKE) test-qa-workflow-check-structure
	$(MAKE) test-brief-check-structure

# -----------------------------------------------------------------------------
# Tests — Génération (Claude)
# -----------------------------------------------------------------------------

test-init: test-setup
	$(TEST_DIR)/run-tests.sh init

test-uc-spec-racine: test-setup
	@rm -f $(TEST_OUT)/docs/SPEC.md $(TEST_OUT)/docs/SPEC-*.md
	$(TEST_DIR)/run-tests.sh uc-spec

test-uc-spec-extension: test-setup
	$(TEST_DIR)/run-tests.sh uc-spec-extension

test-uc-system-design: test-setup
	$(TEST_DIR)/run-tests.sh uc-system-design

test-plan: test-setup
	$(TEST_DIR)/run-tests.sh plan

test-dev-workflow: test-setup
	$(TEST_DIR)/run-tests.sh dev-workflow

test-qa-workflow: test-setup
	$(TEST_DIR)/run-tests.sh qa-workflow

test-brief: test-setup
	$(TEST_DIR)/run-tests.sh brief

test-tuto: test-setup
	$(TEST_DIR)/run-tests.sh tuto

# -----------------------------------------------------------------------------
# Tests — Revue qualité (Claude)
# -----------------------------------------------------------------------------

test-uc-spec-racine-review-content: test-setup
	$(TEST_DIR)/run-tests.sh review

test-uc-spec-extension-review-content: test-setup
	$(TEST_DIR)/run-tests.sh review-extension

# -----------------------------------------------------------------------------
# Tests — Contrôles déterministes
# -----------------------------------------------------------------------------

# Contrôles structurels de tous les skills (fichiers, versions, références)
test-skills-check-structure:
	@$(TEST_DIR)/check_skills_structure.sh

# Contrôles du SPEC racine (cartouche, sections, UC, identifiants, valeurs métier)
test-uc-spec-racine-check-structure:
	@echo ""
	@echo "=== Contrôles du SPEC racine ==="
	@fail=0; \
	echo ""; \
	echo "--- CLAUDE.md ---"; \
	out="$(TEST_OUT)/CLAUDE.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — fichier absent (lancer 'make test-init' d'abord)"; \
	else \
		for section in "Processus global" "Vue d'ensemble" "Méthode de travail" "Règles pour Claude Code" "Workflow de développement" "Commits"; do \
			if grep -qi "$$section" "$$out"; then \
				echo "  ✓ \"$$section\""; \
			else \
				echo "  ✗ \"$$section\" ABSENT"; \
				fail=1; \
			fi; \
		done; \
	fi; \
	echo ""; \
	echo "--- docs/SPEC-racine-*.md ---"; \
	out=$$(find "$(TEST_OUT)/docs" -maxdepth 1 -name 'SPEC-racine-*.md' -type f 2>/dev/null | head -1); \
	if [ -z "$$out" ]; then \
		echo "  SKIP — aucun SPEC-racine-*.md trouvé (lancer 'make test-uc-spec-racine' d'abord)"; \
	else \
		echo "  Fichier détecté : $$out"; \
		echo "  Cartouche :"; \
		if ! python3 $(TEST_DIR)/check_cartouche.py "$$out"; then \
			fail=1; \
		fi; \
		echo "  Sections obligatoires du template :"; \
		for section in "Contexte et objectifs" "Hors périmètre" "Arborescence des cas d'utilisation" "Cas d'utilisation détaillés" "Exigences non fonctionnelles" "Glossaire projet" "Glossaire SDD"; do \
			if grep -qi "$$section" "$$out"; then \
				echo "    ✓ \"$$section\""; \
			else \
				echo "    ✗ \"$$section\" ABSENT"; \
				fail=1; \
			fi; \
		done; \
		echo "  Champs structurels par UC :"; \
		if ! python3 $(TEST_DIR)/check_uc_fields.py "$$out"; then \
			fail=1; \
		fi; \
		echo "  Identifiants (seuils minimaux) :"; \
		for pair in "UC:$(MIN_UC)" "RG:$(MIN_RG)" "CA:$(MIN_CA)" "ENF:$(MIN_ENF)"; do \
			prefix=$${pair%%:*}; \
			min=$${pair##*:}; \
			if [ "$$prefix" = "CA" ]; then \
					count=$$(grep -oE "CA-(UC|ENF)-([A-Z]{3,4}-)?[0-9]+-[0-9]+" "$$out" 2>/dev/null | sort -u | wc -l); \
				else \
					count=$$(grep -oP "(?<!CA-)$$prefix-([A-Z]{3,4}-)?[0-9]+" "$$out" 2>/dev/null | sort -u | wc -l); \
				fi; \
			if [ "$$count" -ge "$$min" ]; then \
				echo "    ✓ $$prefix : $$count (min $$min)"; \
			else \
				echo "    ✗ $$prefix : $$count < $$min"; \
				fail=1; \
			fi; \
		done; \
		echo "  Valeurs métier :"; \
		echo "$(EXPECTED_VALUES)" | tr '|' '\n' | { \
			inner_fail=0; \
			while IFS= read -r val; do \
				val_compact=$$(printf '%s' "$$val" | tr -d ' '); \
				if grep -qF "$$val" "$$out" || grep -qF "$$val_compact" "$$out"; then \
					echo "    ✓ \"$$val\""; \
				else \
					echo "    ✗ \"$$val\" ABSENT"; \
					inner_fail=1; \
				fi; \
			done; \
			exit $$inner_fail; \
		}; \
		if [ $$? -ne 0 ]; then fail=1; fi; \
	fi; \
	echo ""; \
	if [ "$$fail" -eq 0 ]; then \
		echo "Tous les contrôles passent."; \
	else \
		echo "Des écarts ont été détectés."; \
	fi

# Contrôles du SPEC extension (cartouche 11 champs, sections, UC préfixés, dépendances)
test-uc-spec-extension-check-structure:
	@echo ""
	@echo "=== Contrôles du SPEC extension ==="
	@fail=0; \
	ext=$$(find "$(TEST_OUT)/docs" -maxdepth 1 -name 'SPEC-extension-*.md' -type f 2>/dev/null | head -1); \
	if [ -z "$$ext" ]; then \
		echo "  SKIP — aucun SPEC-extension-*.md trouvé (lancer 'make test-uc-spec-extension' d'abord)"; \
	else \
		echo "  Fichier détecté : $$ext"; \
		echo "  Cartouche (extension) :"; \
		if ! python3 $(TEST_DIR)/check_cartouche.py "$$ext"; then \
			fail=1; \
		fi; \
		echo "  Sections obligatoires du template extension :"; \
		for section in "Contexte de la fonction" "Dépendances vers la spec racine" "Hors périmètre" "Arborescence des cas d'utilisation" "Cas d'utilisation détaillés" "Glossaire fonction"; do \
			if grep -qi "$$section" "$$ext"; then \
				echo "    ✓ \"$$section\""; \
			else \
				echo "    ✗ \"$$section\" ABSENT"; \
				fail=1; \
			fi; \
		done; \
		echo "  Champs structurels par UC :"; \
		if ! python3 $(TEST_DIR)/check_uc_fields.py "$$ext"; then \
			fail=1; \
		fi; \
		echo "  Identifiants préfixés (seuils minimaux) :"; \
		for pair in "UC:$(MIN_UC_EXT)" "RG:$(MIN_RG_EXT)" "CA:$(MIN_CA_EXT)" "ENF:$(MIN_ENF_EXT)"; do \
			prefix=$${pair%%:*}; \
			min=$${pair##*:}; \
			if [ "$$prefix" = "CA" ]; then \
				count=$$(grep -oE "CA-(UC|ENF)-[A-Z]{3,4}-[0-9]+-[0-9]+" "$$ext" 2>/dev/null | sort -u | wc -l); \
			else \
				count=$$(grep -oP "(?<!CA-)$$prefix-[A-Z]{3,4}-[0-9]+" "$$ext" 2>/dev/null | sort -u | wc -l); \
			fi; \
			if [ "$$count" -ge "$$min" ]; then \
				echo "    ✓ $$prefix : $$count (min $$min)"; \
			else \
				echo "    ✗ $$prefix : $$count < $$min"; \
				fail=1; \
			fi; \
		done; \
		echo "  Références à la spec racine :"; \
		if grep -q "Dépendances vers la spec racine" "$$ext" && grep -qE "UC-[0-9]+" "$$ext"; then \
			echo "    ✓ Table des dépendances avec références racine"; \
		else \
			echo "    ✗ Table des dépendances vide ou absente"; \
			fail=1; \
		fi; \
	fi; \
	echo ""; \
	if [ "$$fail" -eq 0 ]; then \
		echo "Tous les contrôles extension passent."; \
	else \
		echo "Des écarts ont été détectés."; \
	fi

# Contrôles des documents produits par sdd-uc-system-design
test-uc-system-design-check-structure:
	@$(TEST_DIR)/check_system_design_output.sh $(TEST_OUT)

# Contrôles des fichiers de plan
test-plan-check-structure:
	@$(TEST_DIR)/check_plan_output.sh $(TEST_OUT)

# Contrôles des sorties du développement
test-dev-workflow-check-structure:
	@$(TEST_DIR)/check_dev_workflow_output.sh $(TEST_OUT)

# Contrôles des sorties QA
test-qa-workflow-check-structure:
	@$(TEST_DIR)/check_qa_workflow_output.sh $(TEST_OUT)

# Contrôles de la sortie du brief
test-brief-check-structure:
	@$(TEST_DIR)/check_brief_output.sh $(TEST_LOG)/brief.log

# -----------------------------------------------------------------------------
# Nettoyage
# -----------------------------------------------------------------------------

clean-test:
	@rm -rf $(TEST_OUT)
	@rm -rf $(TEST_LOG)
	@echo "Projet de test et logs supprimés."
	@if [ -d "$(GLOBAL_SKILLS_BAK)" ]; then \
		rm -rf "$(GLOBAL_SKILLS)"; \
		mv "$(GLOBAL_SKILLS_BAK)" "$(GLOBAL_SKILLS)"; \
		echo ""; \
		echo "✓ ~/.claude/skills/ restauré depuis skills.bak :"; \
		ls "$(GLOBAL_SKILLS)" | sed 's/^/    /'; \
	else \
		echo ""; \
		echo "Pas de sauvegarde skills.bak à restaurer."; \
	fi
