# Task 1203: Test Gate Matrix per Task Type

> **Review State**: Promoted — independent reviewer scored 95/100; parent routed to completed after preserving rejected-collision duplicates outside review lane.
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, absence of gate requirements per task type.
> **Blocks**: 1206, 1207, all future task promotion decisions
> **Depends on**: 1201 (failure baseline), 1202 (promotion state model)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1203` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Define which validation gates are required for each task type before promotion.
The gate matrix replaces the implicit assumption that "local test pass = done"
with an explicit, auditable checklist per task category.

## Background Context

### What already exists

- `.agents/rules/promotion-state-model.md` defines promotion states and a
  summary gate matrix.
- Task 1105 defines per-component promotion requirements (catalog case, widget
  test, semantics test, golden test, alias compliance).
- The Melos workspace has scripts: `analyze`, `format`, `test`, `test-ui`,
  `test-observatory`, `test-catalog`, `validate`.
- No `test-cybercore` or `test-boundaries` scripts exist yet.

### What is missing or broken

- No formal gate matrix document exists that builders can reference.
- Tasks do not declare which gates they must pass.
- The summary in the promotion state model needs to be expanded into a
  full, standalone matrix with rationale.

---

## Test Requirements

- Gate matrix covers all task types used in the project.
- Each gate specifies the exact Melos/local command required.
- The matrix distinguishes mandatory gates from recommended gates.

---

## Exit Conditions

- [x] A document exists at `docs/governance/test-gate-matrix.md` defining
  required gates per task type.
- [x] The matrix references Melos scripts (existing and planned from Task 1204).
- [x] The matrix is consistent with `docs/governance/promotion-state-model.md`.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `docs/governance/promotion-state-model.md`, Task 1105 (catalog policy), and
  `pubspec.yaml` root (Melos scripts).
- [x] Define task type categories: docs-only, ADS component, ADS token/theme,
  app route, parser/data layer, monorepo migration, CyberCore fixture,
  performance-sensitive, governance/housekeeping.
- [x] For each category, define mandatory gates: local proof, package proof,
  consumer proof, boundary test, golden test, semantics test, benchmark.
- [x] For each gate, specify the exact command (e.g., `flutter test`,
  `melos run test-ui`, `rg "DS[A-Z]" apps/cybercore/lib`).
- [x] Write the matrix to `docs/governance/test-gate-matrix.md`.
- [x] **Simplicity pass**: ensure the matrix is practical, not aspirational.
  If a command does not exist yet, note it as "planned in Task 1204."
- [x] **Regression verification**: verify the matrix is consistent with the
  promotion state model.

### Where

| File | Purpose |
| --- | --- |
| `docs/governance/promotion-state-model.md` | Read — state definitions and summary matrix |
| `docs/governance/test-gate-matrix.md` | Create — full gate matrix |
| `pubspec.yaml` (root) | Read — existing Melos scripts |

### How

1. Read the promotion state model and existing Melos scripts.
2. Define task type categories based on historical task patterns.
3. For each category, specify mandatory and recommended gates with exact commands.
4. Write the matrix document.
5. Cross-check against the promotion state model for consistency.

### Why

Without a gate matrix, every task is judged ad-hoc. Builders do not know which
commands to run. Reviewers do not know what to check. The matrix makes promotion
deterministic.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not invent commands that do not exist yet. If a Melos script is missing,
> note it as "planned in Task 1204" with the expected command.

> [!IMPORTANT]
> The matrix must be practical. Do not require gates that cannot be run in the
> current environment (e.g., golden tests if Flutter SDK is unavailable).

---

## Validation Commands

```bash
test -f docs/governance/test-gate-matrix.md
grep "melos run" docs/governance/test-gate-matrix.md
```

---

## Completion Evidence

- **Files created/modified**: `docs/governance/test-gate-matrix.md` (created, 468 lines)
- **Tests or validation commands**:
  - `test -f docs/governance/test-gate-matrix.md` — PASS
  - `grep "melos run" docs/governance/test-gate-matrix.md` — PASS (29 references found)
  - Consistency check against `docs/governance/promotion-state-model.md` section 3 — PASS
  - Pre-existing failure counts match `docs/reports/warp-prism-test-failure-baseline.md` — PASS
- **Local changelog entry**: `docs/changelog/20260609-213000-1203-2026-06-09-task-1203-test-gate-matrix-builders.md`
- **Agent-wiki / docs institutionalization**: N/A (governance doc, no agent-wiki entry needed)
- **Executor**: builders
- **Completion date**: 2026-06-09

---
## Review Ledger

### 2026-06-30 — independent reviewer
**Score**: 95/100 — Elite
**Verdict**: PASS WITH NOTES — remains in `03-review/`
**Diagnostics**: Mandatory governance reads complete; `test -f docs/governance/test-gate-matrix.md` PASS; script consistency probe PASS (`test-boundaries`, `test-catalog`, `test-cybercore`, `test-fast`, `test-observatory`, `test-ui`, `validate` all present in root `pubspec.yaml`); no Flutter/Dart gates run because Task 1203 is governance/docs-only.
**Patches applied**: Header changed from stale `Builder Done` to `Ready For Review` to satisfy lane move rules for a task already in `03-review/`.
**Path to 100**: Refresh stale historical text in task background/changelog that says `test-cybercore`/`test-boundaries` were missing or `test-boundaries` was planned, if the owner wants current-state docs with no historical drift.

### 2026-06-11 — gt-build-review
**Score**: 100/100 — Perfect
**Verdict**: APPROVED → 03-review
**Diagnostics**: `test -f docs/governance/test-gate-matrix.md && grep "melos run" docs/governance/test-gate-matrix.md` PASS | script consistency probe PASS | flutter analyze N/A | dart format N/A | flutter test N/A | coverage N/A
**Report**: docs/reports/build-gate-review/1203-review.md
**Patches applied**: `docs/governance/test-gate-matrix.md` boundary-harness wording updated to reflect the existing root `test-boundaries` Melos script instead of stale planned-Task-1205 language.
**Path to 100**: n/a — score is 100 after reviewer patch.
---
