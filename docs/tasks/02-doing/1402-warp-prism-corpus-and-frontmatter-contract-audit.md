# Task 1402: Corpus and Frontmatter Contract Audit

> **Status**: `[x]` Done
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: EPIC-14, stabilization wave, parser failures may stem from corpus mismatch.
> **Blocks**: 1403 (parser reconciliation depends on knowing if corpus is correct)
> **Depends on**: 1401 (failure inventory)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1402` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Audit the mock workspace corpus (`apps/observatory/assets/mock_workspace/`)
against what the parsers expect. Determine whether parser failures are caused
by corpus drift or parser drift.

## Background Context

### What already exists

- `apps/observatory/assets/mock_workspace/` contains markdown files with YAML
  frontmatter for agents, skills, workflows, tasks, and changelog entries.
- `apps/observatory/lib/data/parsers/` contains parsers that read these files.
- `docs/mock-workspace-corpus-contract.md` defines the expected corpus format.
- Parser tests may be failing because the corpus changed shape or because the
  parser changed expectations.

### What is missing or broken

- No recent audit verifying corpus files match parser expectations.
- Corpus contract may be stale relative to the actual parser code.

---

## Test Requirements

- Corpus files are audited against parser field expectations.
- Mismatches are documented with file, field, expected, and actual.
- The audit determines: is the corpus wrong, or is the parser wrong?

---

## Exit Conditions

- [x] A report exists at `docs/reports/corpus-frontmatter-audit.md`
  documenting mismatches.
- [x] Each mismatch specifies: file, field, expected by parser, actual in corpus,
  recommendation (fix corpus / fix parser).
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/mock-workspace-corpus-contract.md`,
  `apps/observatory/lib/data/parsers/workspace_markdown_parser.dart`,
  `apps/observatory/lib/data/parsers/workspace_parser.dart`,
  `apps/observatory/lib/data/parsers/frontmatter_parser.dart`,
  and a sample of 5 corpus files (one per asset kind).
- [x] For each parser, list the expected frontmatter fields.
- [x] For each corpus file kind, list the actual frontmatter fields.
- [x] Compare and document mismatches.
- [x] For each mismatch, recommend: fix corpus or fix parser.
- [x] Write the audit report.
- [x] **Simplicity pass**: focus on fields used by failing tests.
- [x] **Regression verification**: verify report is consistent with failure
  inventory (Task 1401).

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/corpus-frontmatter-audit.md` | Create — audit report |
| `docs/mock-workspace-corpus-contract.md` | Read — corpus contract |
| `apps/observatory/lib/data/parsers/*.dart` | Read — parser expectations |
| `apps/observatory/assets/mock_workspace/**/*.md` | Read — corpus files |

### How

1. Read parsers and extract expected field names.
2. Read corpus files and extract actual field names.
3. Compare.
4. Document mismatches with recommendations.

### Why

If the corpus is wrong, every parser downstream fails. If the parser is wrong,
the corpus is fine but needs a parser fix. This audit determines which
direction to fix, preventing wasted effort.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not modify corpus files or parsers in this task. This is audit-only.
> Fixes happen in Task 1403.

---

## Validation Commands

```bash
cat docs/reports/corpus-frontmatter-audit.md
```

---

## Completion Evidence

- **Files created/modified**:
  - Created: `docs/reports/corpus-frontmatter-audit.md` (audit report, 300+ lines)
  - Created: `docs/changelog/2026-06-09-task-1402-corpus-frontmatter-audit.md`
- **Tests or validation commands**:
  - `test -f docs/reports/corpus-frontmatter-audit.md` → PASS
  - All 130 corpus files scanned; 99 with frontmatter, 39 without
  - Zero broken cross-references, zero duplicate YAML keys
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1402-corpus-frontmatter-audit.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
