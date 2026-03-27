# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **collection of Claude Code skills, commands, and rules** implementing the Spec Driven Development (SDD) methodology. It is NOT a software project with build/test/deploy cycles. The deliverables are Markdown files (SKILL.md, command files, rule files) that get installed into target projects' `.claude/` directories.

All content is written in French.

## Repository Structure

- `skills/` — Claude Code skills (conform to https://agentskills.io/home), each in its own directory with a `SKILL.md`
- `commands/` — Claude Code slash commands (`.md` files)
- `rules/` — Claude Code rules that auto-trigger on file path patterns
- `claude-file/CLAUDE.md` — **Template** CLAUDE.md for target SDD projects (not for this repo). Describes the SDD feedback loop and is meant to be copied into projects using the methodology.

## Two SDD Variants

- **UC (Use Case) variant** — `sdd-uc-*` files: structured around use cases (cas d'utilisation). This is the more detailed approach.
- **Standard variant** — `sdd-*` files (without `uc`): simpler, not structured by use cases.

Both variants share the same workflow phases: Spec -> System Design -> Planning -> Dev -> QA -> Delivery.

## SDD Workflow Chain

The skills and commands form a pipeline for target projects:

1. **Spec writing** (`sdd-spec-write` / `sdd-uc-spec-write` skill) — produces `docs/SPEC.md`
2. **System design** (`sdd-system-design` / `sdd-uc-system-design` skill) — produces `docs/ARCHITECTURE.md`, `DEPLOYMENT.md`, `SECURITY.md`, `COMPLIANCE_MATRIX.md`
3. **Planning** — manual, produces `plan/<epic>.md` files
4. **Dev workflow** (`/sdd-dev-workflow <epic>` command) — implementation loop with AC verification
5. **QA workflow** (`/sdd-qa-workflow <epic>` command) — test plans, execution, code review, reports
6. **Brief** (`/sdd-brief` command) — loads project context at session start

## Rules Auto-Triggering

- `rules/sdd-dev-workflow.md` — triggers on `src/**` and `tests/**`, reminds about the dev workflow
- `rules/sdd-qa.md` — triggers on `qa/**`, reminds about QA conventions

## How to Work on This Repository

When editing skills or commands:
- Skills must have YAML frontmatter (`name`, `description`) and follow the SKILL.md structure (trigger conditions, welcome message, instructions)
- Commands receive `$ARGUMENTS` from the user's slash command invocation
- Rules need `description` and `paths` in their YAML frontmatter
- Keep the `claude-file/CLAUDE.md` template in sync with any workflow changes made to skills/commands
