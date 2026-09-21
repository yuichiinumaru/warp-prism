# Review Report: Task 1040 — Glass Performance Budget Pass — 2026-06-19

## Review Lineage

- **Current task**: Task 1040 (`1040-warp-prism-glass-performance-budget-pass`), reviewed from `docs/tasks/03-review/1040-warp-prism-glass-performance-budget-pass.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1040-review.md` — prior 100/100 PASS.
  - `docs/reports/review-wave-2026-06-17/task-1000-review.md` — rejected the Task 1000 EPIC 10 polish baseline as stale.
  - `docs/reports/build-gate-review/1060-review-2026-06-17-independent.md` — rejected downstream EPIC 10 acceptance and warned to re-audit Tasks 1040/1050 against live evidence.
- **Related documents read**: `docs/reports/epic-10-polish-baseline.md`, `docs/reports/epic-10-glass-performance-budget.md`, `docs/research.md`, Task 1010/1020/1030/1060 lane state, Task 1040 changelog entry.
- **Review mode**: independent re-review / documentation accuracy + Flutter design-system contract review.

## Score And Verdict

- **Score**: `62/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The focused package regression file exists at the live package path and runs successfully with the current Flutter toolchain.
- `RESOLVED`: The basic `DSGlassPanel` tier constants and high-frequency card/widget checks covered by `packages/warp_prism_ui/test/glass_budget_test.dart` pass.
- `RESOLVED`: Flutter SDK is available in the current environment; the historical “Flutter SDK not installed” blocker is obsolete.

### Persistent Findings

- `PERSISTENT`: The task, budget report, changelog, and prior build-gate report are written for the old root `lib/` / `test/design_system/` layout rather than the current Melos package layout.
- `PERSISTENT`: The task depends on Task 1000, but Task 1000 is live in `02-doing` with `Review State: Doing` after its baseline was rejected as stale.

### Regressions

- `REGRESSION`: The budget’s “only DSStoryPanel uses BackdropFilter” claim is false against the live design-system package.

### New Findings

- `NEW`: `DSToast` renders `DSGlassPanel(...)`, which uses `BackdropFilter` blur by default, but it is not inventoried or justified in the budget.
- `NEW`: `DSCommandPalette` manually renders a `BackdropFilter` with sigma 20, but it is not inventoried or covered by the regression.
- `NEW`: The “all 40 design system files” audit scope is stale; the live `packages/warp_prism_ui` package has a much larger ADS surface including gallery, command palette, toast, data table, virtual scroll, graph, log viewer, etc.
- `NEW`: Focused analyzer now runs and reports four info-level findings in `ds_story_panel.dart`, so the task’s validation evidence must be refreshed from stale SDK-blocked claims.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No regression currently proves “only documented blur hosts exist”; the final test in `glass_budget_test.dart` is a placeholder `expect(true, isTrue)`.
- `EXTERNAL_BLOCKER`: None for focused package proof. Flutter 3.44.1 / Dart 3.12.1 are installed.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | Critical | Open | The budget report’s core inventory is false: it claims only `DSStoryPanel` uses BackdropFilter, but live code has additional blur hosts. | `docs/reports/epic-10-glass-performance-budget.md:11`, `:40-57`; `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:59-65`; `packages/warp_prism_ui/lib/src/organisms/command_palette/ds_command_palette.dart:320-324`; grep output found those hosts. |
| F2 | EVIDENCE_GAP | High | Open | Regression coverage does not enforce the documented budget across live DS hosts. | `packages/warp_prism_ui/test/glass_budget_test.dart:170-186` is a placeholder; no tests mention `DSToast` or `DSCommandPalette`. |
| F3 | PERSISTENT | High | Open | Task/doc/changelog paths and audit scope target removed root layout and old 40-file DS inventory. | Task Where table `docs/tasks/03-review/1040-...md:70-84`; completion evidence `:110-118`; budget report `:3-6`, `:93-99`; changelog `docs/changelog/20260607-211903-1040-...md:16-20`; live files are under `packages/warp_prism_ui/`. |
| F4 | PERSISTENT | Medium | Open | Declared prerequisite Task 1000 is not approved and its baseline report was rejected as stale. | Task 1040 `Depends on: Task 1000`; `docs/tasks/02-doing/1000-warp-prism-polish-baseline-audit.md:3-4`; `docs/reports/review-wave-2026-06-17/task-1000-review.md:12-15`, `:70-76`. |
| F5 | NEW | Low | Open | Focused analyzer is executable now and reports task-owned info findings rather than an SDK blocker. | `flutter analyze --no-pub lib/src/atoms/ds_glass_panel.dart lib/src/organisms/ds_story_panel.dart test/glass_budget_test.dart test/story_panel_narrative_test.dart` — 4 info issues. |

## Evidence Reviewed

- Governance/onboard: `AGENTS.md`, `.agents/workflows/onboard.md`, `.agents/rules/project-boundaries.md`, `.agents/rules/task-governance.md`, `.agents/rules/task-reference-policy.md`.
- Task lineage: Task 1040, prior `1040-review.md`, Task 1000 live rejection, Task 1060 rejection, related EPIC 10 task lane states.
- Task-owned docs/tests/code: `docs/reports/epic-10-glass-performance-budget.md`, Task 1040 changelog, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_story_panel.dart`, `packages/warp_prism_ui/test/glass_budget_test.dart`.
- Live blur audit surfaces: package grep for `DSGlassPanel`, `BackdropFilter`, `ImageFilter.blur`, and `blur` under `packages/warp_prism_ui/lib` plus focused reads of `DSToast` and `DSCommandPalette`.
- Non-runtime rationale: Task 1040 is documentation/regression-heavy, so approval depends on a true live inventory and enforceable regression. The focused widget test passing is insufficient while the written budget omits current blur hosts.

## Commands And Results

- `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter --version && ... dart --version` — PASS; Flutter 3.44.1 / Dart 3.12.1.
- `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub test/glass_budget_test.dart` from `packages/warp_prism_ui` — PASS, `+13`.
- `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter analyze --no-pub lib/src/atoms/ds_glass_panel.dart lib/src/organisms/ds_story_panel.dart test/glass_budget_test.dart test/story_panel_narrative_test.dart` from `packages/warp_prism_ui` — completed with 4 info issues.
- Grep/read inspection of live package blur hosts — found `DSToast` and `DSCommandPalette` in addition to `DSStoryPanel`.

## Path To 100

1. Re-audit the current `packages/warp_prism_ui/` design-system package, not the obsolete root `lib/` snapshot.
2. Update `docs/reports/epic-10-glass-performance-budget.md` to inventory every live BackdropFilter/DSGlassPanel host, including `DSStoryPanel`, `DSToast`, and `DSCommandPalette`, and classify each as allowed/simple/forbidden-by-default.
3. Replace root-path task/changelog evidence with current package paths and remove stale “Flutter SDK not installed” language.
4. Replace the placeholder budget test with deterministic coverage that fails when undocumented blur hosts are added, or explicitly tests all allowed hosts.
5. Reconcile Task 1040’s dependency on Task 1000: either wait for Task 1000 re-approval or document a narrow waiver that this task’s live package audit supersedes the stale baseline.
6. Re-run focused package tests/analyze and record exact current output.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-19 with score `62/100`, verdict `REJECTED_TO_DOING`, report path `docs/reports/review-wave-2026-06-19/task-1040-epic-10-glass-budget-rereview.md`, lane outcome `returned to doing`, and open findings F1-F5 above.
