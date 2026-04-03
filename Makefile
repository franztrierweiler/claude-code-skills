# =============================================================================
# claude-code-skills — Makefile
# =============================================================================
#
# Installation globale :
#   make install    — Installe les skills dans ~/.claude/skills/
#
# Distribution locale :
#   make copy       — Copie skills/rules vers les projets cibles
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
#   make test                     — Lance tous les tests
#   make test-init                — Génère le CLAUDE.md via /init + template SDD
#   make test-uc-spec             — Teste sdd-uc-spec-write sur MaintiX
#   make test-review              — Claude évalue la complétude du SPEC.md
#   make test-check               — Contrôles déterministes (seuils, valeurs métier)
#   make test-uc-system-design    — Teste sdd-uc-system-design sur MaintiX
#   make test-system-design       — Contrôles structurels du skill sdd-uc-system-design
#   make test-system-design-check — Contrôles des documents produits
#   make test-plan                — Planifie le développement en lots
#   make test-plan-check          — Contrôles des fichiers de plan
#   make test-dev-workflow        — Développe le premier lot via sdd-dev-workflow
#   make test-dev-check           — Contrôles des sorties du développement
#   make test-qa-workflow         — Lance la QA sur le premier lot
#   make test-qa-check            — Contrôles des sorties QA
#   make test-brief               — Lance /sdd-brief sur le projet de test
#   make test-brief-check         — Contrôles de la sortie du brief
#   make test-tuto                — Affiche le tutoriel SDD (pas de contrôle)
#   make test-setup               — Prépare l'environnement de test
#   make clean-test               — Supprime les sorties de test
# =============================================================================

TARGETS_FILE := targets.txt
DIST_DIR     := dist
DIRS         := skills rules
SKILLS       := $(wildcard skills/*)

TEST_DIR     := tests
TEST_OUT     := $(TEST_DIR)/output
TEST_LOG     := $(TEST_DIR)/log

.PHONY: help install copy copy-dry diff status check-deps \
        zip zip-all zip-check clean-dist \
        test test-init test-uc-spec test-uc-system-design test-review \
        test-check test-system-design test-system-design-check \
        test-plan test-plan-check test-dev-workflow test-dev-check \
        test-qa-workflow test-qa-check \
        test-brief test-brief-check test-tuto \
        test-setup clean-test

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
	@echo "    make copy        Copie skills/rules vers les projets cibles"
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
	@echo "  Tests :"
	@echo "    make test                       Lance tous les tests"
	@echo "    make test-init                  Génère le CLAUDE.md"
	@echo "    make test-uc-spec               Produit le SPEC.md (sdd-uc-spec-write)"
	@echo "    make test-uc-system-design      Produit les docs de conception (sdd-uc-system-design)"
	@echo "    make test-review                Claude évalue la complétude du SPEC.md"
	@echo "    make test-check                 Contrôles déterministes (seuils, valeurs)"
	@echo "    make test-system-design         Contrôles structurels du skill"
	@echo "    make test-system-design-check   Contrôles des documents produits"
	@echo "    make test-plan                  Planifie le développement en lots"
	@echo "    make test-plan-check            Contrôles des fichiers de plan"
	@echo "    make test-dev-workflow          Développe le premier lot"
	@echo "    make test-dev-check             Contrôles des sorties du développement"
	@echo "    make test-qa-workflow           Lance la QA sur le premier lot"
	@echo "    make test-qa-check              Contrôles des sorties QA"
	@echo "    make test-brief                 Lance /sdd-brief sur le projet de test"
	@echo "    make test-brief-check           Contrôles de la sortie du brief"
	@echo "    make test-tuto                  Affiche le tutoriel SDD (pas de contrôle)"
	@echo "    make clean-test                 Supprime les sorties de test"
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

# -----------------------------------------------------------------------------
# Tests — validation du skill sdd-uc-spec-write avec un CDC de référence
# -----------------------------------------------------------------------------
#
# CDC de test : MaintiX (maintenance industrielle)
#
# Le répertoire tests/output/ est le projet simulé :
#   output/.claude/     skills/rules
#   output/CLAUDE.md    généré par test-init
#   output/docs/        CDC (copié) + SPEC.md (généré par test-uc-spec)
#
# Flux :
#   make test          Génère CLAUDE.md + SPEC.md
#   make test-check    Contrôles déterministes (seuils, valeurs métier)
#   make test-review   Claude évalue la complétude du SPEC.md vs le CDC
# -----------------------------------------------------------------------------

# Valeurs métier qui doivent apparaître dans le SPEC.md (séparées par |)
EXPECTED_VALUES := 15 min|4h|24h|10 ans|6 mois|2 ans|300ms|99,5%|200 techniciens|8 heures|30 secondes|10 secondes

# Seuils minimaux d'identifiants dans le SPEC.md
# Extraits du CDC MaintiX : ~15 UC, ~15 RG, ~15 CA, ~6 ENF
MIN_UC  := 10
MIN_RG  := 10
MIN_CA  := 10
MIN_ENF := 4

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

# Sauvegarde des skills globaux (~/.claude/skills/ est prioritaire sur
# les skills projet). On remplace temporairement par les skills UC du
# repo pour que les tests utilisent les bonnes versions.
GLOBAL_SKILLS     := $(HOME)/.claude/skills
GLOBAL_SKILLS_BAK := $(HOME)/.claude/skills.bak

# Prépare le projet simulé dans output/ : skills + rules + CDC
# Remplace aussi ~/.claude/skills/ pour éviter les conflits de priorité.
test-setup: check-deps
	@echo "Préparation du projet de test dans $(TEST_OUT)/..."
	@mkdir -p $(TEST_OUT)/.claude/skills $(TEST_OUT)/docs $(TEST_LOG)
	@rm -rf $(TEST_OUT)/.claude/skills/*
	@for skill in $(TEST_SKILLS); do \
		rsync -a $$skill/ $(TEST_OUT)/.claude/$$skill/; \
		echo "  ✓ $$skill (projet)"; \
	done
	@rsync -a --delete rules/ $(TEST_OUT)/.claude/rules/
	@echo "  ✓ rules/"
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

# Lance tous les tests
# Chaîne complète : structurel → génération (Claude) → contrôles déterministes
test: test-system-design test-setup
	@echo ""
	@echo "=== Répertoire cible des tests : $(TEST_OUT) ==="
	@echo ""
	$(TEST_DIR)/run-tests.sh all
	$(MAKE) test-check
	$(MAKE) test-system-design-check
	$(MAKE) test-plan-check
	$(MAKE) test-dev-check
	$(MAKE) test-qa-check
	$(MAKE) test-brief-check

# Génère le CLAUDE.md dans output/
test-init: test-setup
	$(TEST_DIR)/run-tests.sh init

# Produit le SPEC.md dans output/docs/
test-uc-spec: test-setup
	$(TEST_DIR)/run-tests.sh uc-spec

# Produit les documents de conception (ARCHITECTURE, DEPLOYMENT, SECURITY, COMPLIANCE)
test-uc-system-design: test-setup
	$(TEST_DIR)/run-tests.sh uc-system-design

# Évaluation du SPEC.md par Claude (complétude, cohérence vs CDC)
test-review: test-setup
	$(TEST_DIR)/run-tests.sh review

# Contrôles structurels du skill sdd-uc-system-design
test-system-design:
	@$(TEST_DIR)/check_system_design.sh

# Contrôles des documents produits par sdd-uc-system-design
test-system-design-check:
	@$(TEST_DIR)/check_system_design_output.sh $(TEST_OUT)

# Planifie le développement en lots
test-plan: test-setup
	$(TEST_DIR)/run-tests.sh plan

# Contrôles des fichiers de plan (format, traçabilité, couverture UC)
test-plan-check:
	@$(TEST_DIR)/check_plan_output.sh $(TEST_OUT)

# Développe le premier lot via sdd-dev-workflow
test-dev-workflow: test-setup
	$(TEST_DIR)/run-tests.sh dev-workflow

# Contrôles des sorties du développement (plan, code, tests, Makefile)
test-dev-check:
	@$(TEST_DIR)/check_dev_workflow_output.sh $(TEST_OUT)

# Lance /sdd-brief sur le projet de test (après tout le reste)
test-brief: test-setup
	$(TEST_DIR)/run-tests.sh brief

# Lance la QA sur le premier lot
test-qa-workflow: test-setup
	$(TEST_DIR)/run-tests.sh qa-workflow

# Contrôles des sorties QA (plan de test, revue, rapport)
test-qa-check:
	@$(TEST_DIR)/check_qa_workflow_output.sh $(TEST_OUT)

# Affiche le tutoriel SDD (exécution seule, pas de contrôle déterministe)
test-tuto: test-setup
	$(TEST_DIR)/run-tests.sh tuto

# Contrôles de la sortie du brief
test-brief-check:
	@$(TEST_DIR)/check_brief_output.sh $(TEST_LOG)/brief.log

# Contrôles déterministes : sections, seuils d'identifiants, valeurs métier
test-check:
	@echo ""
	@echo "=== Contrôles déterministes ==="
	@fail=0; \
	echo ""; \
	echo "--- CLAUDE.md ---"; \
	out="$(TEST_OUT)/CLAUDE.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — fichier absent (lancer 'make test' d'abord)"; \
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
	echo "--- docs/SPEC.md ---"; \
	out="$(TEST_OUT)/docs/SPEC.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — fichier absent (lancer 'make test' d'abord)"; \
	else \
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
					count=$$(grep -oE "CA-(UC|ENF)-[0-9]+-[0-9]+" "$$out" 2>/dev/null | sort -u | wc -l); \
				else \
					count=$$(grep -oP "(?<!CA-)$$prefix-[0-9]+" "$$out" 2>/dev/null | sort -u | wc -l); \
				fi; \
			if [ "$$count" -ge "$$min" ]; then \
				echo "    ✓ $$prefix : $$count (min $$min)"; \
			else \
				echo "    ✗ $$prefix : $$count < $$min"; \
				fail=1; \
			fi; \
		done; \
		echo "  Valeurs métier :"; \
		echo "$(EXPECTED_VALUES)" | tr '|' '\n' | while IFS= read -r val; do \
			if grep -q "$$val" "$$out"; then \
				echo "    ✓ \"$$val\""; \
			else \
				echo "    ✗ \"$$val\" ABSENT"; \
				fail=1; \
			fi; \
		done; \
	fi; \
	echo ""; \
	if [ "$$fail" -eq 0 ]; then \
		echo "Tous les contrôles passent."; \
	else \
		echo "Des écarts ont été détectés."; \
	fi

# Supprime le projet simulé et les logs (conserve le CDC, les prompts et les références)
# Supprime le projet simulé et restaure les skills globaux
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
