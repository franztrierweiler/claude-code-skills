# Rule Improvements — Review Results

## Honest Assessment: These Rules Add Very Little Value

### What rules are for

Rules auto-inject context into the conversation when Claude touches files matching the `paths` patterns. They're meant to provide **knowledge Claude doesn't have** at the moment it needs it — project-specific conventions, gotchas, non-obvious constraints.

### What the current rules actually do

**`rules/sdd-dev-workflow.md`** (triggered on `src/**`, `tests/**`):
1. Suggests running `/sdd-dev-workflow` if working on a full EPIC
2. Repeats the AC report format from the command

**`rules/sdd-qa.md`** (triggered on `qa/**`):
1. Suggests running `/sdd-qa-workflow` if working on a full QA
2. Lists the QA file path conventions

### Why they're mostly redundant

**The suggestion to run a slash command is the wrong job for a rule:**

- If the user launched `/sdd-dev-workflow`, the command is already loaded — the rule adds noise by suggesting what's already running.
- If the user is doing a quick bug fix in `src/`, the rule fires anyway, then says "don't suggest the command for punctual interventions". So it loads into context just to say "ignore me". That's wasted context budget.
- The CLAUDE.md template already states that the workflow is piloted by `/sdd-dev-workflow` and `/sdd-qa-workflow`. A Claude instance that read CLAUDE.md already knows this.

**The AC report format is duplicated** from the command itself. If the command is active, Claude already has the format. If the command isn't active, Claude probably doesn't need the format (punctual work).

**The QA file path conventions** are the only genuinely useful content — but they're 4 lines. And they'll be obvious to Claude from the existing `qa/` directory structure the moment it lists the files.

### When rules ARE useful

Rules shine when they carry **non-obvious, context-specific knowledge** that Claude can't derive from reading the code. Examples:

- "Files in `src/auth/` must never import from `src/billing/` — these modules communicate only through events" (architectural constraint)
- "All SQL migrations must be backward-compatible — the old code runs alongside the new for 24h during rolling deploys" (deployment constraint)
- "Test files in `tests/integration/` require a running PostgreSQL. Run `make db-up` first" (environment gotcha)
- "Never modify `src/generated/` files directly — they're produced by `make codegen` from `schemas/`" (workflow trap)

These are things Claude would get wrong without the rule. The current rules don't meet this bar.

### Verdict

| Rule | Useful content | Redundant content | Recommendation |
|---|---|---|---|
| `sdd-dev-workflow.md` | None | Suggestion to run command + report format (both in command already) | **Remove** or repurpose |
| `sdd-qa.md` | QA path conventions (4 lines) | Suggestion to run command (in CLAUDE.md already) | **Remove** or repurpose |

### Minor defects in current rules

- `rules/sdd-dev-workflow.md`: Code block for report format is never closed (missing closing `` ``` ``).
- `rules/sdd-qa.md`: Trailing empty bullet point on line 19 (`- `) — leftover artifact.

---

## Recommended Actions

### Option A — Remove both rules

The CLAUDE.md template already describes the workflow. The commands carry their own instructions. The rules are overhead with no unique information.

### Option B — Repurpose with real value

If kept, replace the current content with things Claude actually needs to know when touching those paths. Example for a target project:

```yaml
---
description: Conventions de code pour le projet
paths:
  - "src/**"
---

- Tout module expose son API publique via `__init__.py`. Ne pas importer depuis les fichiers internes.
- Les exceptions metier heritent de `src/exceptions.py:AppError`. Ne pas lever de `ValueError` ou `RuntimeError` bruts.
- Les logs utilisent `structlog`. Ne pas utiliser `print()` ou `logging` standard.
```

This is knowledge Claude can't guess. The current rules are knowledge Claude either already has or doesn't need.

### If rules are kept as templates for target projects

Since this repo is a collection of SDD methodology files meant to be installed into target projects, the rules could be kept as **templates** — but they should be clearly marked as such and include placeholder sections for project-specific conventions. The current content (command suggestions) should still be removed, as it will be redundant in any project that has CLAUDE.md and the commands installed.
