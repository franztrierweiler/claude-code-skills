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
# Flux de test complet :
#   1. test-setup       Copie skills/commands/rules dans tests/.claude/
#   2. test-init        Génère CLAUDE.md via /init + template SDD
#   3. test-uc-spec     Produit un SPEC.md (variante UC, MaintiX)
#   4. test-check       Compare toutes les sorties contre les références
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

# Prépare l'environnement de test : copie skills/commands/rules dans tests/.claude/
test-setup:
	@echo "Préparation de l'environnement de test..."
	@mkdir -p $(TEST_DIR)/.claude
	@for dir in $(DIRS); do \
		rsync -a --delete $$dir/ $(TEST_DIR)/.claude/$$dir/; \
	done
	@echo "  -> $(TEST_DIR)/.claude/ prêt"

# Lance tous les tests dans l'ordre
test: test-init test-uc-spec
	@echo ""
	@echo "Tous les tests ont été exécutés."
	@echo "Lancer 'make test-check' pour comparer avec les références."

# Génère le CLAUDE.md via claude /init puis complète avec le template SDD
test-init: test-setup
	@echo ""
	@echo "=== Test init ==="
	@mkdir -p $(TEST_OUT)/init
	@rm -f $(TEST_DIR)/CLAUDE.md
	@echo "  Génération du CLAUDE.md via /init..."
	cd $(TEST_DIR) && claude --print \
		"/init" \
		> $(abspath $(TEST_OUT))/init/init.log 2>&1
	@if [ ! -f $(TEST_DIR)/CLAUDE.md ]; then \
		echo "  ÉCHEC — CLAUDE.md non produit par /init"; \
		echo "  Consulter $(TEST_OUT)/init/init.log"; \
		exit 1; \
	fi
	@echo "  Complétion avec le template SDD (claude-file/CLAUDE.md)..."
	cd $(TEST_DIR) && claude --print \
		"Lis le fichier CLAUDE.md existant à la racine. Lis le template SDD dans ../claude-file/CLAUDE.md. Fusionne les deux : garde la structure et les sections du template SDD, complète-les avec les informations spécifiques au projet générées par /init. Le résultat doit être un CLAUDE.md complet qui suit la méthodologie SDD tout en décrivant ce projet. Écris le résultat dans CLAUDE.md." \
		> $(abspath $(TEST_OUT))/init/merge.log 2>&1
	@cp $(TEST_DIR)/CLAUDE.md $(TEST_OUT)/init/CLAUDE.md
	@echo "  -> $(TEST_OUT)/init/CLAUDE.md généré"

# Teste sdd-uc-spec-write sur MaintiX
test-uc-spec: test-init
	@echo ""
	@echo "=== Test sdd-uc-spec-write (MaintiX) ==="
	@mkdir -p $(TEST_OUT)/uc-spec
	@rm -f $(TEST_DIR)/docs/SPEC.md
	cd $(TEST_DIR) && claude --print \
		"$$(cat prompts/prompt-uc-spec-write.md)" \
		> $(abspath $(TEST_OUT))/uc-spec/session.log 2>&1
	@if [ -f $(TEST_DIR)/docs/SPEC.md ]; then \
		cp $(TEST_DIR)/docs/SPEC.md $(TEST_OUT)/uc-spec/SPEC.md; \
		echo "  -> $(TEST_OUT)/uc-spec/SPEC.md généré"; \
	else \
		echo "  ÉCHEC — docs/SPEC.md non produit"; \
		echo "  Consulter $(TEST_OUT)/uc-spec/session.log"; \
		exit 1; \
	fi

# Vérifie toutes les sorties contre les références
test-check:
	@echo "Vérification des sorties contre les références..."
	@fail=0; \
	echo ""; \
	echo "=== CLAUDE.md (init) ==="; \
	out="$(TEST_OUT)/init/CLAUDE.md"; \
	ref="$(TEST_DIR)/reference/init-CLAUDE.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — pas de sortie (lancer 'make test' d'abord)"; \
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
	echo "=== SPEC.md (uc-spec) ==="; \
	out="$(TEST_OUT)/uc-spec/SPEC.md"; \
	ref="$(TEST_DIR)/reference/uc-spec-SPEC.md"; \
	if [ ! -f "$$out" ]; then \
		echo "  SKIP — pas de sortie (lancer 'make test' d'abord)"; \
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
		echo "Des écarts ont été détectés. Vérifier les sorties dans $(TEST_OUT)/."; \
	fi

# Accepte les sorties courantes comme nouvelles références
test-accept:
	@if [ -f "$(TEST_OUT)/init/CLAUDE.md" ]; then \
		cp "$(TEST_OUT)/init/CLAUDE.md" "$(TEST_DIR)/reference/init-CLAUDE.md"; \
		echo "  -> $(TEST_DIR)/reference/init-CLAUDE.md mis à jour"; \
	else \
		echo "  SKIP init — pas de sortie"; \
	fi
	@if [ -f "$(TEST_OUT)/uc-spec/SPEC.md" ]; then \
		cp "$(TEST_OUT)/uc-spec/SPEC.md" "$(TEST_DIR)/reference/uc-spec-SPEC.md"; \
		echo "  -> $(TEST_DIR)/reference/uc-spec-SPEC.md mis à jour"; \
	else \
		echo "  SKIP uc-spec — pas de sortie"; \
	fi

# Supprime les sorties de test et les fichiers générés
clean-test:
	@rm -rf $(TEST_OUT)
	@rm -rf $(TEST_DIR)/.claude
	@rm -f $(TEST_DIR)/CLAUDE.md
	@rm -f $(TEST_DIR)/docs/SPEC.md
	@echo "Sorties de test supprimées."
