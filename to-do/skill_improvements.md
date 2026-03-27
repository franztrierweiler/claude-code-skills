# Skill Improvements — Review Results

## 1. Compliance with agentskills.io Standard

### Critical: SKILL.md size far exceeds recommendations

The standard recommends **< 500 lines** and **< 5000 tokens** per SKILL.md.

| Skill | Lines | Bytes | vs. 500-line limit |
|---|---|---|---|
| `sdd-spec-write` | 943 | 42 KB | **~2x over** |
| `sdd-uc-spec-write` | 1114 | 48 KB | **~2.2x over** |
| `sdd-system-design` | 1379 | 56 KB | **~2.8x over** |
| `sdd-uc-system-design` | 1498 | 63 KB | **~3x over** |

**Impact**: When a skill is activated, the entire SKILL.md body is loaded into the agent's context. These files consume 12K-20K+ tokens each, leaving significantly less room for the actual conversation and project files. This is the single biggest compliance issue.

**Recommendation**: Use the **progressive disclosure** pattern (3-tier loading):
- Keep the core instructions in SKILL.md (< 500 lines)
- Move templates, glossaries, detailed examples, and the SPEC.md template to a `references/` subdirectory
- Move detailed phase instructions (e.g., A.1-A.7 questions) to separate reference files

Example restructuring for `sdd-uc-spec-write`:
```
sdd-uc-spec-write/
├── SKILL.md                          # ~400 lines: triggers, philosophy, process overview, checklist
├── references/
│   ├── TEMPLATE-SPEC.md              # The full SPEC.md template (currently ~230 lines)
│   ├── GLOSSARY-SDD.md               # SDD glossary (duplicated across all skills)
│   ├── UC-FORMAT.md                  # Detailed UC structure and writing rules
│   └── UPDATE-WORKFLOW.md            # Spec update rules (identifiers, changelog, deprecation)
```

### Critical: `description` field exceeds 1024-char limit on 2 skills

| Skill | Description length | Limit |
|---|---|---|
| `sdd-spec-write` | ~603 chars | OK |
| `sdd-uc-spec-write` | ~220 chars | OK |
| `sdd-system-design` | **~1773 chars** | **Over by ~750** |
| `sdd-uc-system-design` | **~1831 chars** | **Over by ~800** |

The `description` field is the primary metadata used by agents for skill discovery. It's loaded at startup for **all** skills (~100 tokens budget). The two system-design skills embed trigger/anti-trigger logic in the YAML description that should be in the body instead.

**Recommendation**: Shorten the description to a concise summary of what + when. Move trigger details to the body (as `sdd-uc-spec-write` already does correctly).

### Missing: No `references/`, `scripts/`, or `assets/` subdirectories

All four skills are a single monolithic SKILL.md with no supporting files. The standard explicitly recommends splitting content into subdirectories for progressive loading.

### Missing: Optional frontmatter fields

None of the skills use `metadata` for version tracking. The version is currently embedded in the body text (`Version : 1.0.0`). Consider:

```yaml
metadata:
  version: "1.0.0"
  author: "franz"
```

---

## 2. Structural Inconsistencies Across Skills

### Inconsistent `description` style in YAML

- `sdd-spec-write`: Multi-line block scalar (no `>` indicator), includes trigger/anti-trigger logic in YAML
- `sdd-uc-spec-write`: Folded scalar with `>`, concise, trigger logic moved to body section
- `sdd-system-design`: Multi-line block scalar, includes trigger/anti-trigger logic in YAML
- `sdd-uc-system-design`: Multi-line block scalar, includes trigger/anti-trigger logic in YAML

**`sdd-uc-spec-write` is the model to follow** — concise YAML description, trigger details in the body.

### Inconsistent section naming for triggers

| Skill | Section name |
|---|---|
| `sdd-spec-write` | "Declenchement" with subsections "Declenchement primaire" / "Declenchement secondaire" / "Ne pas declencher" |
| `sdd-uc-spec-write` | "Criteres de declenchement" with subsections "Declenchement primaire (haute confiance)" / "Declenchement secondaire (confiance moyenne)" / "Anti-triggers" |
| `sdd-system-design` | "Declenchement" with "Ne pas declencher (anti-triggers)" |
| `sdd-uc-system-design` | "Declenchement" with "Ne pas declencher (anti-triggers)" + extra "Validation du format d'entree" |

**Recommendation**: Standardize on the `sdd-uc-spec-write` pattern (most explicit and consistent naming).

### Inconsistent CA identifier prefixes

| Skill/Context | Format |
|---|---|
| `sdd-spec-write` | `CA-001-01`, `CA-NF-001-01` |
| `sdd-uc-spec-write` | `CA-UC-001-01`, `CA-ENF-001-01` |

The UC variant uses scoped prefixes (`CA-UC-`, `CA-ENF-`) which is clearer. The standard variant uses bare `CA-` which is ambiguous when both functional and non-functional CAs exist in the same document. Consider aligning.

### Duplicated SDD Glossary

The SDD glossary is copy-pasted into every skill (and into every generated SPEC.md). This creates a maintenance burden — if you update a definition, you must update 4 files.

**Recommendation**: Extract to a shared `references/GLOSSARY-SDD.md` at the repo level and reference it from each skill. Each skill can say "Include the SDD glossary from `references/GLOSSARY-SDD.md`" rather than embedding the full table.

Note: the two glossaries are also **different** — the UC variant has UC-specific terms (Acteur, Cas nominal, Exception, RG, Package, Include, Extend, Generalisation) that the standard variant doesn't. This is correct, but the shared terms should come from one source.

---

## 3. Content Quality Issues

### `sdd-spec-write` (v1.0.0) — hasn't evolved since initial version

- No "Message d'accueil" section (unlike `sdd-uc-spec-write` which has one)
- No "Concepts cles" section explaining the domain model
- No guidance for updating an existing spec (the update workflow is present but less detailed than the UC variant)
- Missing "Changelog du skill" entries beyond v1.0.0 — yet the UC variant is at v1.2.0 with documented improvements

This skill appears to have been written first and then the UC variant was created with significant improvements that were never backported.

### `sdd-system-design` (v1.0.0) vs `sdd-uc-system-design` (v2.0.0)

Same pattern: the UC variant is significantly more mature. The UC variant adds:
- "Validation du format d'entree" — graceful degradation if wrong SPEC format
- Likely more detailed phase instructions (both are very long)

The non-UC variants feel like v1 drafts that need the improvements from their UC counterparts.

### No cross-skill navigation guidance

When a skill finishes, it should clearly tell the user which skill comes next in the SDD pipeline. The `sdd-spec-write` skills mention "passage de relais" but don't explicitly name the next skill (`sdd-system-design` or `sdd-uc-system-design`). The system-design skills should similarly point to planning/dev workflow.

---

## 4. Summary of Recommended Actions

| Priority | Issue | Action |
|---|---|---|
| **High** | Skills 2-3x over size limit | Split into SKILL.md + `references/` files |
| **High** | 2 descriptions over 1024 chars | Shorten YAML description, move triggers to body |
| **Medium** | Duplicated glossary in 4 files | Extract to shared reference file |
| **Medium** | Inconsistent YAML description style | Align all on `sdd-uc-spec-write` pattern (concise `>` scalar) |
| **Medium** | Inconsistent trigger section naming | Standardize naming across all 4 skills |
| **Medium** | Non-UC skills lagging behind UC variants | Backport improvements (welcome message, concepts, update workflow) |
| **Low** | No `metadata` frontmatter | Add version/author in YAML metadata |
| **Low** | No cross-skill navigation | Add explicit "next skill" guidance at skill completion |
