# Task 1201: Test Failure Baseline Inventory

> **Review State**: `Promoted` — inventory-only governance deliverable accepted and promoted as a dated 2026-06-11 baseline; consumer/app gate remained red at capture time because `apps/observatory/` had 12 classified pre-existing/unrelated failures that this task inventories rather than fixes.
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-12, stabilization wave, analysis of 95 monorepo test failures.
> **Blocks**: 1203, 1206, EPIC-13 tasks, EPIC-14 tasks
> **Depends on**: EPIC-00 (compile baseline awareness)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1201` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create a complete inventory of all test failures in the Warp Prism monorepo,
classified by failure taxonomy. This task does NOT fix any failure. It produces
the map that all subsequent stabilization tasks use.

## Background Context

### What already exists

- Melos migration (Task 1107) registered: `warp_prism_ui` 757 pass / 31 fail;
  `warp_prism_observatory` 589 pass / 64 fail; `apps/catalog` 1/0; `apps/cybercore` 12/0.
- Task completion evidence from Wave 4 mentions failures in:
  `molecules_contract_test`, `templates_contract_test`, `design_system_gallery_test`,
  `design_system_accessibility_test`, `state_surface_test`, `operational_components_test`,
  `atoms_contract_test`, `ds_toast_test`, `command_palette_test`.
- Observatory failures mentioned in:
  `workspace_task_projection_parser_test`, `extended_detail_variants_test`,
  `skill_task_detail_widgets_test`, `history_story_modes_test`,
  `responsive_detail_integration_test`, `operate_task_detail_inspector_test`.

### What is missing or broken

- No unified failure inventory document exists.
- No failure taxonomy is applied consistently.
- "Pre-existing failure" is used as an unclassified catch-all.
- No distinction between failures that block promotion and failures that are informational.

---

## Test Requirements

- Inventory covers every failing test file across all 4 packages/apps.
- Each failure is classified by taxonomy class (broken compile, contract drift, stale test,
  real regression, async/flaky, semantics drift, missing fixture, pre-existing unrelated).
- Each failure is classified by chain position (corpus, parser, projection, mapper, view,
  test stale, compile).

---

## Exit Conditions

- [x] A report exists at `docs/reports/warp-prism-failure-baseline-inventory.md` listing
  every failure with file, test name, taxonomy class, chain position, and affected area.
- [x] Failure counts match the captured package/app test output at time of inventory.
- [x] Classification is consistent with `.agents/rules/promotion-state-model.md` taxonomy.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read `.agents/rules/promotion-state-model.md`,
  `docs/tasks/00-planning/EPIC-12-warp-prism-test-suite-stabilization-and-promotion-gates.md`,
  and existing task completion evidence referencing failures.
- [x] Run `flutter test` in `packages/warp_prism_ui/` and capture all failures.
- [x] Run `flutter test` in `apps/observatory/` and capture all failures.
- [x] Run `flutter test` in `apps/catalog/` and `apps/cybercore/` and capture results.
- [x] Classify each failure by taxonomy class and chain position.
- [x] Produce `docs/reports/warp-prism-failure-baseline-inventory.md` with tables per package.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [x] **Regression verification**: verify the inventory matches the actual test output.

### Where

| File | Purpose |
| --- | --- |
| `docs/reports/warp-prism-failure-baseline-inventory.md` | Create — failure inventory report |
| `.agents/rules/promotion-state-model.md` | Read — failure taxonomy definitions |
| `docs/tasks/00-planning/EPIC-12-warp-prism-test-suite-stabilization-and-promotion-gates.md` | Read — source evidence |

### How

1. Read the promotion state model rule and the EPIC-12 source evidence.
2. Run `flutter test` in each package/app directory, capturing stdout/stderr.
3. Parse output to extract failing test names and error messages.
4. Classify each failure using the taxonomy from the promotion state model.
5. Write the inventory report with per-package tables.
6. Verify counts match the captured output.

### Why

Without a complete failure inventory, every subsequent stabilization task is
guessing. The inventory is the map that tells builders and reviewers which
failures are urgent, which are stale, and which block promotion.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the test commands and filling
> Completion Evidence with actual output.

> [!IMPORTANT]
> If Flutter SDK is not available, record the exact tooling failure and do not
> claim tests were run. Document the SDK gap as a blocker.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/
flutter test apps/observatory/
flutter test apps/catalog/
flutter test apps/cybercore/
```

---

## Completion Evidence

- **Files created/modified**:
  - Created `docs/reports/warp-prism-failure-baseline-inventory.md`.
  - Created `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md`.
  - Modified `docs/tasks/02-doing/1201-warp-prism-test-failure-baseline-inventory.md` header, exit conditions, subtasks, and completion evidence.
- **Tests or validation commands**:
  - `flutter test packages/warp_prism_ui/` → `EXIT:0` → `00:46 +854: All tests passed!`
  - `flutter test apps/observatory/` → `EXIT:1` → `00:40 +641 -12: Some tests failed.`
  - `flutter test apps/catalog/` → `EXIT:0` → `00:48 +10: All tests passed!`
  - `flutter test apps/cybercore/` → `EXIT:0` → `00:03 +12: All tests passed!`
  - Regression verification parsed unique Observatory `[E]` failures → `12`, matching the report table and the `+641 -12` final line.
- **Local changelog entry**: `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md`
- **Agent-wiki / docs institutionalization**: N/A; report and changelog are the institutionalized deliverable.
- **Executor**: builders
- **Completion date**: 2026-06-11
- **Review State note**: `Ready For Review`; the reviewer accepts the inventory-only governance scope because the dated 2026-06-11 app/consumer gate remained red in `apps/observatory/` with 12 classified pre-existing/unrelated failures that Task 1201 documents for follow-up stabilization rather than fixes.

---
## Review Ledger

### 2026-06-11 — gt-build-review
**Score**: 20/100 — Critical
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: flutter analyze N/A | dart format N/A | flutter test packages/warp_prism_ui PASS (`+854`) | flutter test apps/observatory FAIL (`+641 -12`) | flutter test apps/catalog PASS (`+10`) | flutter test apps/cybercore PASS (`+12`) | coverage N/A
**Report**: docs/reports/build-gate-review/1201-review.md
**Patches applied**: none — score below 90
**Findings**:
- `docs/reports/warp-prism-failure-baseline-inventory.md` is missing, violating the primary exit condition at this task's lines 57-64.
- Completion Evidence remains placeholder text at this task's lines 133-140.
- No `docs/changelog/*1201*` changelog entry exists.
- Task header remains `Status: [ ] Open` / `Review State: Open` while sitting in `02-doing/`, so it is not a completed review candidate.
**Path to 100**:
1. Rerun the required test commands and capture complete package/app output.
2. Create `docs/reports/warp-prism-failure-baseline-inventory.md` with every current failure classified by taxonomy and chain position.
3. Reconcile failure counts against captured output and explicitly record zero-failure packages.
4. Add a Task 1201 changelog note under `docs/changelog/`.
5. Fill Completion Evidence with changed files, commands/results, changelog path, executor, and date.
6. Set task status/review state consistently before review handoff.

### 2026-06-11 — gt-build-review round 2
**Score**: 100/100 — Perfect
**Verdict**: APPROVED → moved to 03-review
**Diagnostics**: dart format PASS (`284 files`, `0 changed`) | flutter analyze baseline INFO/WARN in `packages/warp_prism_ui/` and `apps/observatory/`, PASS in `apps/catalog/` and `apps/cybercore/` | flutter test packages/warp_prism_ui PASS (`+854`) | flutter test apps/observatory EXPECTED BASELINE FAIL (`+641 -12`) | flutter test apps/catalog PASS (`+10`) | flutter test apps/cybercore PASS (`+12`) | coverage N/A
**Report**: docs/reports/build-gate-review/1201-review-round2.md
**Patches applied**:
- Split the inventory's Observatory failure table into `Task relationship` and `Primary taxonomy class` columns so `pre-existing (unrelated)` is no longer used as a replacement for a concrete taxonomy class.
- Added reviewer round-2 confirmation that the rerun baseline still contains the same 12 Observatory failures and zero failures in UI/catalog/cybercore.
**Findings**:
- No remaining blockers. The inventory-only governance scope is accepted; the app/consumer gate remains red only because the 12 classified Observatory failures are intentionally documented for follow-up tasks rather than fixed by Task 1201.
**Path to 100**: N/A — already 100 after reviewer patch and re-validation.
---

### 2026-06-17 — reviewers independent review
**Score**: 92/100 — PASS WITH NOTES
**Verdict**: remains in 03-review for parent final verification; no completed-lane move.
**Report**: `docs/reports/build-gate-review/1201-review-2026-06-17.md`
**Diagnostics**: inventory report/read-only governance evidence PASS; fresh package/app test reruns BLOCKED by current nested pub-cache workspace contamination under `apps/observatory/tmp/pub-cache`, not by Task 1201 content.
**Findings**:
- `EVIDENCE_GAP/LOW`: current workspace cache artifacts prevent reproducing the four package/app `flutter test` commands. The Task 1201 report remains present and internally consistent with its captured 2026-06-11 output.
**Path to 100**:
1. Clean or relocate generated pub/cache artifacts out of `apps/**` so root workspace globbing no longer includes dependency package pubspecs.
2. Rerun the four package/app test commands and either confirm Task 1201 remains a historical baseline or create a successor current baseline.
3. Keep Task 1201 in `03-review` pending parent final verification.
---

### 2026-06-19 — reviewers independent re-review
**Score**: 100/100 — ACCEPTED_100
**Verdict**: leave in `03-review`; no return to doing.
**Report**: `docs/reports/build-gate-review/1201-review-2026-06-19-rereview.md`
**Diagnostics**: previous nested pub-cache workspace blocker is resolved; fresh `flutter test --no-pub` reruns execute and show current baseline drift (UI `+862 -11`, Observatory `+646 -7`, catalog `+14`, cybercore `+12`) rather than workspace-resolution failure.
**Findings**:
- `RESOLVED`: 2026-06-17 external/evidence blocker under `apps/observatory/tmp/pub-cache` no longer exists.
- `RESOLVED`: Task 1201 report remains internally consistent as a dated 2026-06-11 historical baseline with 12 Observatory failures and zero UI/catalog/cybercore failures at capture time.
**Path to 100**: N/A for Task 1201; create a successor current baseline if live 2026-06-19 counts need governance tracking.
---
