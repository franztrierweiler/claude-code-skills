# Command Improvements — Review Results

## 1. Compliance with Modern Claude Code Format

All three commands use the **legacy format** (`.claude/commands/<name>.md`) rather than the modern skill format (`.claude/skills/<name>/SKILL.md`). The legacy format still works but is being phased out. More importantly, the legacy format lacks access to powerful frontmatter fields.

### Missing frontmatter on all three commands

None of the commands have YAML frontmatter. Here's what they're missing:

| Field | `sdd-brief` | `sdd-dev-workflow` | `sdd-qa-workflow` |
|---|---|---|---|
| `description` | Missing | Missing | Missing |
| `argument-hint` | N/A | Missing | Missing |
| `disable-model-invocation` | Missing | Missing | Missing |
| `allowed-tools` | Missing | Missing | Missing |

**Impacts:**

- **No `description`**: Claude cannot auto-discover or auto-suggest these commands. The agent falls back to parsing the first paragraph of markdown, which is a title ("Initialisation du projet"), not a useful description.
- **No `argument-hint`**: When a user types `/sdd-dev-workflow`, they get no hint that an argument is expected. Should be `[epic-name]`.
- **No `disable-model-invocation`**: These are user-initiated workflows with significant side effects (writing files, running tests, updating plans). Claude could theoretically auto-invoke them, which is undesirable.
- **No `allowed-tools`**: Each command reads multiple files and runs Makefile commands. Pre-approving `Read, Glob, Grep, Bash(make *)` would reduce permission prompts during execution.

---

## 2. Per-Command Review

### `/sdd-brief` — Initialization command

**Strengths:**
- Clear, sequential instructions
- Good separation of concerns (docs, CLAUDE.md, commands, skills, plan)
- Graceful handling of Makefile (conditional display)

**Issues:**

1. **Step 1 is risky** — "Lire tous les fichiers markdown dans le repertoire `docs/`" with no guard. If `docs/` has 50 files or doesn't exist, behavior is undefined. Should add: "Si `docs/` n'existe pas ou est vide, indiquer que la documentation n'est pas encore en place."

2. **Step 4 scans the wrong location** — "fichiers `sdd-*` dans `.claude/commands/` du projet". This assumes the legacy path. If commands are migrated to `.claude/skills/`, this step breaks.

3. **Step 6 is vague** — "Afficher le statut actuel du projet (extrait de CLAUDE.md)". The CLAUDE.md template has `<REMPLIR_ICI>` as placeholder for project overview. If the project hasn't filled this in, Claude will display a placeholder. Should add: "Si la section est vide ou contient un placeholder, le signaler."

4. **No error recovery** — No instruction for what to do if critical files are missing (no CLAUDE.md, no `docs/SPEC.md`). This is the entry point for new sessions — it should be the most resilient command.

5. **Missing git context** — Doesn't show branch name or recent commits. For a session initialization command, knowing "you're on branch `feature/epic-03`" is valuable context.

### `/sdd-dev-workflow` — Development workflow

**Strengths:**
- Well-structured 6-step process with clear progression
- AC verification loop is explicit and actionable
- Cross-references to QA workflow at closure
- Report format is standardized

**Issues:**

1. **No guard on missing plan file** — Step 1.1 reads `plan/$ARGUMENTS.md`. If the file doesn't exist, there's no fallback instruction. Should say: "Si le fichier n'existe pas, indiquer les plans disponibles dans `plan/` et demander confirmation."

2. **Step 1.4 assumes SPEC.md location** — Hardcoded to `docs/SPEC.md`. The SPEC.md could be at the project root or in another location referenced by CLAUDE.md.

3. **No progress indicator** — Unlike the skills (which have a progress bar system), this command has no visual tracking mechanism across messages. The phrases "Fin d'iteration" and "Fin d'implementation significative" are good but informal. Consider a structured status line similar to the skills' progress bar.

4. **Report format uses checkboxes for completed items** — The template shows `- [ ] AC-XXX-XX: Description — Statut` with unchecked boxes. Completed ACs should use `- [x]`. The template should show both states.

5. **No rollback guidance** — If an implementation breaks previously passing ACs, there's no instruction to revert or flag regression. Should include: "Si un AC precedemment satisfait regresse, le signaler immediatement avant de continuer."

6. **Step 2 says "Pour chaque fonctionnalite"** — But doesn't define what a "fonctionnalite" is within an EPIC. Is it one AC? A group of ACs? A section of the plan? The mapping between plan structure and implementation units is implicit.

### `/sdd-qa-workflow` — QA workflow

**Strengths:**
- Prerequisites check before starting (best practice not present in dev-workflow)
- Strong traceability requirement (test function naming with scenario IDs)
- Clear deliverables with exact file paths
- Structured final report template
- Explicit pilot validation gate before test execution

**Issues:**

1. **Test naming convention mixes formats** — Step 2.4 says `test_tXX_YY_description` but references "CL-XXX-XX de la spec" in step 2.2. The link between CL identifiers (from spec) and T-XX scenario numbers (QA-local) is never defined. How does `CL-007-03` become `T09-01`?

2. **No SPEC.md reading in context loading** — Step 1 reads the plan, ACs, source code, and tests — but not the SPEC.md itself. Yet step 2.2 references "CL-XXX-XX de la spec". The SPEC.md should be loaded in step 1.

3. **Step 3.1 says "Executer les tests via Makefile"** — But doesn't specify which Makefile target. `make test`? `make qa`? `make test-epic`? The dev-workflow has the same vagueness.

4. **Code review criteria are generic** — Step 4.2 says "lisibilite, securite, performance, conformite aux conventions". These are standard but the review should also check against the specific SPEC.md exigences and architecture decisions from ARCHITECTURE.md.

5. **No handling of partial failure** — If 8 out of 10 scenarios pass, the verdict is "A CORRIGER" but there's no guidance on whether to fix and re-run only failures or re-run the entire suite. Also no guidance on blocking vs non-blocking failures.

6. **Report template has no timestamp for individual scenarios** — The final report table (`| # | Scenario | Resultat |`) doesn't track when each scenario was run. If QA spans multiple sessions, this matters.

---

## 3. Cross-Command Consistency Issues

### No shared conventions document

The three commands share implicit conventions (AC format, file paths, Makefile usage) but these aren't documented in one place. If a convention changes (e.g., `plan/` moves to `docs/plan/`), all three commands need updating.

### Inconsistent AC identifier format

- `sdd-dev-workflow` report template: `AC-XXX-XX`
- `sdd-qa-workflow` references: `CL-XXX-XX` (from spec)
- Rule `sdd-dev-workflow.md`: `AC-XXX-XX`
- Spec skills produce: `CA-001-01` or `CA-UC-001-01`

The commands use `AC-XXX-XX` but the skills that produce the spec use `CA-XXX-XX`. "AC" (Acceptance Criteria) and "CA" (Critere d'Acceptation) refer to the same thing but with different prefixes. This will confuse Claude when cross-referencing between spec and plan.

### No UC-variant awareness

The commands don't differentiate between UC-format specs and standard-format specs. `/sdd-dev-workflow` reads `docs/SPEC.md` but doesn't know whether to look for `EXG-xxx` or `UC-xxx` identifiers. The commands should either:
- Auto-detect the spec format, or
- Have UC variants (`sdd-uc-dev-workflow`, `sdd-uc-qa-workflow`)

---

## 4. Rules Review (Companion Files)

### `rules/sdd-dev-workflow.md`

- **Good**: Appropriate path triggers (`src/**`, `tests/**`)
- **Good**: Distinguishes structured work from punctual interventions
- **Issue**: Duplicates the report format from the command. If the format changes, both files need updating.
- **Issue**: Trailing line missing closing `` ``` `` for the code block.

### `rules/sdd-qa.md`

- **Good**: Appropriate path trigger (`qa/**`)
- **Good**: Lists all QA file conventions in one place
- **Issue**: Trailing empty bullet point on line 19 (`- `) — leftover artifact.
- **Issue**: Doesn't mention the test naming convention (`test_tXX_YY_description`) that the command requires. This is a key convention that should be in the rule too.

---

## 5. Summary of Recommended Actions

| Priority | Issue | Action |
|---|---|---|
| **High** | No YAML frontmatter on any command | Add `description`, `argument-hint`, `disable-model-invocation: true`, `allowed-tools` |
| **High** | AC/CA identifier mismatch between commands and skills | Align on one prefix across the entire SDD methodology |
| **High** | No guards for missing files (plan, SPEC, docs/) | Add fallback instructions in each command |
| **Medium** | Legacy `.claude/commands/` format | Migrate to `.claude/skills/<name>/SKILL.md` format |
| **Medium** | No UC-variant awareness in commands | Add spec format auto-detection or create UC variants |
| **Medium** | `sdd-qa-workflow` doesn't load SPEC.md in context | Add SPEC.md to step 1 context loading |
| **Medium** | Test naming convention (T-XX) not linked to spec identifiers (CL-XXX) | Define the mapping explicitly |
| **Low** | Rules have minor artifacts (empty bullet, unclosed code block) | Clean up |
| **Low** | No git context in `/sdd-brief` | Add branch name and recent commits to initialization |
| **Low** | No shared conventions file for commands | Extract shared paths/formats to a reference doc |
