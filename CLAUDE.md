# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **collection of Claude Code skills** implementing the Spec Driven Development (SDD) methodology. It is NOT a software project with build/test/deploy cycles. The deliverables are Markdown files (SKILL.md) that get installed into target projects' `.claude/` directories.

All content is written in French.

## Repository Structure

- `skills/` — Claude Code skills (conform to https://agentskills.io/home), each in its own directory with a `SKILL.md`
- `claude-file/CLAUDE.md` — **Template** CLAUDE.md for target SDD projects (not for this repo). Describes the SDD feedback loop and is meant to be copied into projects using the methodology.

## SDD Workflow Chain

The skills form a pipeline for target projects. All skills use the UC (Use Case) approach — structured around use cases (cas d'utilisation). Skills with `disable-model-invocation: true` are user-invocable only (slash commands).

1. **Spec writing** (`sdd-uc-spec-write`) — produces `docs/SPEC-racine-<NomProjet>.md` and `docs/SPEC-extension-<NomProjet>-<NomFonction>.md`
2. **System design** (`sdd-uc-system-design`) — produces `docs/ARCHITECTURE.md`, `DEPLOYMENT.md`, `SECURITY.md`, `COMPLIANCE_MATRIX.md`
3. **Planning** (`/sdd-plan`) — produces `plan/<lot>.md` files (user-invocable)
4. **Dev workflow** (`/sdd-dev-workflow <lot>`) — implementation loop with AC verification (user-invocable)
5. **QA workflow** (`/sdd-qa-workflow <lot>`) — test plans, execution, code review, reports (user-invocable)
6. **Brief** (`/sdd-brief`) — loads project context at session start (user-invocable)
7. **Tuto** (`/sdd-tuto`) — interactive SDD methodology tutorial (user-invocable; produces an HTML artifact on claude.ai)

## How to Work on This Repository

When editing skills:
- Skills must have YAML frontmatter (`name`, `description`) and follow the SKILL.md structure
- User-invocable skills use `disable-model-invocation: true` and receive `$ARGUMENTS`
- Keep the `claude-file/CLAUDE.md` template in sync with any workflow changes
