# Review Report: Task 1123 — Virtual Scroll Optimization — 2026-06-13

## Review Lineage

- **Current task**: Task 1123 (`warp-prism-virtual-scroll-optimization`); live path `docs/tasks/03-review/1123-warp-prism-virtual-scroll-optimization.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1123-review.md` — previous score `100/100`, verdict `APPROVED`.
- **Related reports / context considered**:
  - `docs/reports/ads-gap-analysis-20260608.md` — defines GAP-N4 virtual scroll context.
  - `docs/tasks/03-review/1105-warp-prism-token-theme-catalog-policy.md` — lane-resolved replacement for the task's stale `01-open` pointer.
  - `docs/tasks/03-review/1112-warp-prism-data-table-component.md` — lane-resolved replacement for the task's stale `01-open` pointer.
- **Review mode**: re-review / independent wave-1 verification.
- **Reviewer profile**: `reviewers`.

## Score And Verdict

- **Score**: `49/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

The implementation has a good core widget shape, and the task-specific analyzer, format check, and virtual list/grid widget tests pass. However, the required performance benchmark currently does not compile from the package root, and the benchmark source does not prove the task's stated 60fps / 16ms / p99 / memory-delta contract even after the import failure is fixed. There is also a lifecycle bug around `ScrollController` replacement in `DSVirtualList`.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | PASS, scoped | `flutter analyze lib/src/organisms/virtual_scroll/` passed with `No issues found`. Package-wide analyzer was not requested in this review wave. `packages/warp_prism_ui/pubspec.yaml` uses constrained versions; no `any` dependency was found in that package. |
| 2. Lifecycle Safety | FAIL | `DSVirtualList` creates 1 internal `ScrollController`, 1 `FocusNode`, and 1 listener. Initial create/dispose counts match, but controller identity changes are not handled in `didUpdateWidget`, leaving listener ownership unsafe and allowing an external-controller-to-null rebuild to read an uninitialized `late final` controller. Evidence: `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/ds_virtual_scroll.dart:177-200`. |
| 3. Dependency Direction | PASS | Virtual scroll imports Flutter/tokens only. Data table imports sibling virtual scroll through organism boundary: `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart:5`. No domain/data/presentation layer violation in the reviewed package surface. |
| 4. UI Accessibility | PARTIAL | `DSVirtualList`/`DSVirtualGrid` expose optional semantic labels and default `addSemanticIndexes=true` (`ds_virtual_scroll.dart:153-154`, `348-353`, `412-413`, `508-513`). Data table interactive code sites remain partially unlabeled/undersized: 7 interactive code sites were identified in `ds_data_table.dart` (`GestureDetector` x3, `InkWell` x2, `Checkbox` x2, plus `PopupMenuButton` x1 from grep evidence); not all have explicit semantics or 48x48 targets. |
| 5. Proof Reality | FAIL | Required benchmark command fails to compile. The benchmark also asserts average frame time `<50ms`, not 60fps `<16.67ms`, does not assert p99 under budget, does not assert all frames under budget, and records no peak memory delta. Evidence: `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart:1-8`, `144-160`; command output below. |
| 6. Release Security | PASS | No secrets/endpoints/signing changes found in reviewed implementation. `print()` / `debugPrint()` count in `lib/src/organisms/virtual_scroll/`: 0. Benchmark `debugPrint()` calls are test-only, not release paths. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: None identified. The previous report had no open findings.

### Persistent Findings

- `PERSISTENT`: None from the previous report, because it reported 100/100.

### Regressions

- `REGRESSION`: The previous report claimed `flutter test test/performance/virtual_scroll_benchmark.dart` passed 4/4. Current verification from `packages/warp_prism_ui/` fails during compilation because the benchmark imports the public package barrel but references non-exported `DS*` names.

### New Findings

- `NEW`: `DSVirtualList` listener/controller lifecycle does not handle `scrollController` changes across rebuilds.
- `NEW`: Benchmark source does not encode the task's 60fps contract even if compilation is repaired.
- `NEW`: Data-table interactive code sites still need an accessibility/touch-target pass before claiming full Axiom 4 compliance.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing benchmark proof exists for 10K+ items at p99/all-frames <=16.67ms and no peak memory delta is measured.
- `EXTERNAL_BLOCKER`: None. Flutter tooling is available in this environment.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Required performance benchmark does not compile from package root. | This review | `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart:15`, command output: undefined `DSVirtualScrollConfig`, `DSVirtualList`, `DSVirtualGrid` |
| F2 | EVIDENCE_GAP | CRITICAL | Open | Benchmark does not prove the 60fps contract: it asserts average `<50ms`, not p99/all frames `<16.67ms`, and does not measure peak memory delta. | This review | `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart:144-160`; task requirements `docs/tasks/03-review/1123-warp-prism-virtual-scroll-optimization.md:51-52`, anti-hallucination gate `:123-125` |
| F3 | NEW | MODERATE | Open | `DSVirtualList` listener/controller lifecycle is unsafe when `scrollController` is added, removed, or replaced after the state is created. | This review | `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/ds_virtual_scroll.dart:177-200` |
| F4 | NEW | MODERATE | Open | Accessibility proof is incomplete for data-table interactive surfaces touched by integration: exact grep count found 7 interactive code sites plus the popup menu; multiple sites lack explicit `Semantics(button: true, label: ...)` and/or guaranteed 48x48 dp hit targets. | This review | `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart:206`, `:237`, `:423`, `:483`, `:554`, `:642`, `:669`; popup menu `:594-601` |
| F5 | NEW | LOW | Open | The task's first subtask remains unchecked despite completion evidence claiming review-ready status. This is a task-governance evidence mismatch, not a runtime defect. | This review | `docs/tasks/03-review/1123-warp-prism-virtual-scroll-optimization.md:78` |

### Finding Details And Required Changes

#### F1 — CRITICAL — Benchmark compile failure

Current benchmark import:

- `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart:15` imports `package:warp_prism_ui/warp_prism_ui.dart`.
- Public barrel `packages/warp_prism_ui/lib/warp_prism_ui.dart:19-21` exports `src/prism_aliases.dart`, not raw `DS*` names.
- `packages/warp_prism_ui/lib/src/prism_aliases.dart:315-319` exports `PrismVirtualList` and `PrismVirtualGrid`; `:468-469` exports `PrismVirtualScrollConfig`.

**Specific change recommendation**: either use public aliases in the benchmark:

```dart
PrismVirtualList(
  config: PrismVirtualScrollConfig.highCache,
  ...
)

PrismVirtualGrid(...)
```

or, if this is intentionally an internal DS implementation benchmark, change the import to:

```dart
import 'package:warp_prism_ui/src/organisms/virtual_scroll/ds_virtual_scroll.dart';
```

Given Task 1105's DS*/Prism* public boundary, the public-alias fix is preferable.

#### F2 — CRITICAL — Benchmark does not prove 60fps or memory delta

The task explicitly requires 10,000+ items without exceeding a 16ms frame budget and requires total build time, average frame time, 99th percentile frame time, and peak memory delta. The current benchmark comments mention those metrics, but the assertions do not enforce them:

- Average frame time assertion is `<50.0`: `virtual_scroll_benchmark.dart:156-160`.
- p99 is printed but not asserted: `:144-149`.
- max/all-frame budget is printed but not asserted: `:149-150`.
- peak memory delta is not measured anywhere in the file despite the header metric list omitting it and task requiring it.

**Specific change recommendation**:

1. Add a deterministic memory metric, for example using `ProcessInfo.currentRss` in the VM test environment, and report/assert a bounded delta or document why the environment cannot support stable memory assertions.
2. Replace the `<50ms` average-only assertion with the task contract:

```dart
expect(avgFrameTime, lessThanOrEqualTo(16.67));
expect(p99FrameTime, lessThanOrEqualTo(16.67));
expect(maxFrameTime, lessThanOrEqualTo(16.67));
```

If widget-test harness overhead makes all-frame 16.67ms nondeterministic, then do not claim the task proves 60fps. Split the proof into a repeatable benchmark script/profile-mode measurement and keep the widget test as a virtualization smoke test.

#### F3 — MODERATE — Controller lifecycle unsafe across rebuilds

Exact lifecycle count in `DSVirtualList`:

| Resource/listener | Created/attached | Removed/disposed | Initial lifecycle classification |
| --- | --- | --- | --- |
| Internal `ScrollController` | 1 conditional create at `ds_virtual_scroll.dart:187-189` | 1 conditional dispose at `:197-199` | SAFE for initial null-controller lifecycle |
| `FocusNode` | 1 field create at `:182` | 1 dispose at `:196` | SAFE |
| Scroll listener `_onScroll` | 1 `addListener` at `:190` | 1 `removeListener` at `:195` | UNSAFE on controller replacement; no `didUpdateWidget` |

Risk scenarios:

1. Initial `scrollController != null`, later rebuild with `scrollController == null`: `_defaultController` was never initialized, so `_controller` can evaluate an uninitialized `late final`.
2. Initial external controller A, later external controller B: listener remains attached to A and is not attached to B.
3. Initial internal controller, later external controller: internal controller listener is not detached before `_controller` points at the external controller.

**Specific change recommendation**: replace the `late final _defaultController` + getter-only ownership model with explicit active-controller tracking:

```dart
ScrollController? _ownedController;
ScrollController? _attachedController;

ScrollController get _controller => widget.scrollController ?? _ownedController!;

@override
void initState() {
  super.initState();
  _ownedController = widget.scrollController == null ? ScrollController() : null;
  _attachController(_controller);
}

@override
void didUpdateWidget(covariant DSVirtualList oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.scrollController != widget.scrollController) {
    _detachController();
    if (widget.scrollController == null && _ownedController == null) {
      _ownedController = ScrollController();
    }
    _attachController(_controller);
  }
}

void _attachController(ScrollController controller) {
  _attachedController = controller;
  controller.addListener(_onScroll);
}

void _detachController() {
  _attachedController?.removeListener(_onScroll);
  _attachedController = null;
}

@override
void dispose() {
  _detachController();
  _focusNode.dispose();
  _ownedController?.dispose();
  super.dispose();
}
```

Add widget tests covering external→external, external→null, null→external controller transitions.

#### F4 — MODERATE — Accessibility/touch-target gaps in touched data-table integration surface

Exact grep count in `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` found these interactive code sites:

1. `GestureDetector` at `:206` — secret reveal toggle, lacks explicit `Semantics(button: true, label: ...)`; hit target is icon-sized.
2. `InkWell` at `:237` — action item, tooltip exists but `DSIcon.small` has no semantic label; padding appears below 48x48.
3. `InkWell` at `:423` — page button has `Semantics` at `:419-422`, but icon+padding target appears below 48x48.
4. `Checkbox` at `:483` — select-all checkbox has built-in semantics but no explicit contextual label and is constrained to width 40.
5. `GestureDetector` at `:554` — sortable column header lacks explicit button semantics/state label.
6. `GestureDetector` at `:642` — clickable row lacks explicit button semantics when `row.onTap != null`.
7. `Checkbox` at `:669` — row checkbox has built-in semantics but no row-specific label and is constrained to width 40.
8. `PopupMenuButton` at `:594-601` — has tooltip and icon label; lower risk than the seven sites above.

**Specific change recommendation**: wrap custom tap regions in `Semantics(button: true, label: ..., enabled: ...)`, use `InkWell`/`Material` where possible, and enforce `ConstrainedBox(minWidth: 48, minHeight: 48)` for icon-only actions and pagination buttons. Add semantics tests for reveal, action, sort header, row tap, select-all, and row checkbox labels.

## Evidence Reviewed

- Governance:
  - `AGENTS.md`
  - `.agents/rules/definition-of-done.md`
  - `.agents/rules/project-boundaries.md`
  - `.agents/rules/task-governance.md`
  - `.agents/workflows/onboard.md`
  - `.agents/skills/code-quality-harness/SKILL.md`
  - `.agents/skills/flutter-harness/SKILL.md`
  - Flutter subskills: performance, UI/UX, testing
- Task and lineage:
  - `docs/tasks/03-review/1123-warp-prism-virtual-scroll-optimization.md`
  - `docs/reports/build-gate-review/1123-review.md`
- Where-table files and lane-resolved context:
  - `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/ds_virtual_scroll.dart`
  - `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/virtual_scroll.dart`
  - `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart`
  - `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart`
  - `packages/warp_prism_ui/test/organisms/virtual_list_test.dart`
  - `packages/warp_prism_ui/test/organisms/virtual_grid_test.dart`
  - `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart`
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart`
  - `packages/warp_prism_ui/lib/warp_prism_ui.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`
  - `apps/catalog/lib/main.dart`
  - `apps/catalog/pubspec.yaml`
  - `apps/catalog/test/widget_test.dart`
  - `docs/reports/ads-gap-analysis-20260608.md`
  - `docs/tasks/03-review/1105-warp-prism-token-theme-catalog-policy.md`
  - `docs/tasks/03-review/1112-warp-prism-data-table-component.md`
  - `docs/changelog/20260608-223000-1123-2026-06-08-task-1123-virtual-scroll-optimization-builders.md`
- Runtime wiring proof:
  - `DSGallerySections.buildVirtualScrollSection` exists at `design_system_gallery_sections.dart:1793` and is registered in `design_system_gallery_registry.dart:85-90`.
  - Public package barrel exports Prism aliases, not raw `DS*` symbols: `warp_prism_ui.dart:19-21`; `prism_aliases.dart:315-319`, `:468-469`.

## Commands Run

All commands were run from `packages/warp_prism_ui/` unless stated otherwise.

| Command | Result | Evidence |
| --- | --- | --- |
| `flutter analyze lib/src/organisms/virtual_scroll/` | PASS | `No issues found!` |
| `flutter test test/organisms/virtual_list_test.dart test/organisms/virtual_grid_test.dart` | PASS | `00:02 +30: All tests passed!` |
| `flutter test test/performance/virtual_scroll_benchmark.dart` | FAIL | Compilation failed: undefined `DSVirtualScrollConfig`, `DSVirtualList`, `DSVirtualGrid` because benchmark imports public package barrel. |
| `dart format --set-exit-if-changed lib/src/organisms/virtual_scroll/` | PASS | `Formatted 2 files (0 changed) in 0.01 seconds.` |
| `git status --short` from repo root | INFO | Working tree already contained many unrelated modified/untracked files before this report write; reviewer did not move the task file. |

### Command Output Excerpt For Failed Gate

```text
test/performance/virtual_scroll_benchmark.dart:37:25: Error: Undefined name 'DSVirtualScrollConfig'.
                config: DSVirtualScrollConfig.highCache,
                        ^^^^^^^^^^^^^^^^^^^^^
test/performance/virtual_scroll_benchmark.dart:35:22: Error: Method not found: 'DSVirtualList'.
              child: DSVirtualList(
                     ^^^^^^^^^^^^^
...
test/performance/virtual_scroll_benchmark.dart:243:22: Error: Method not found: 'DSVirtualGrid'.
              child: DSVirtualGrid(
                     ^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

## Exit-Condition Verification

| Task condition | Verdict | Evidence |
| --- | --- | --- |
| `virtual_scroll/` exists with config/list/grid | PASS | `ds_virtual_scroll.dart`, `virtual_scroll.dart` exist. |
| `DSVirtualList` supports `itemExtent` and `cacheExtent` | PASS | `DSVirtualScrollConfig.itemExtent/cacheExtent` at `ds_virtual_scroll.dart:23-30`; forwarded at `:315-316`, `:330`. |
| `DSVirtualGrid` supports `crossAxisCount` and `cacheExtent` | PASS | `crossAxisCount` at `ds_virtual_scroll.dart:390-391`; `cacheExtent` at `:402-404`; builder at `:495-505`. |
| `DSDataTable` integrates `DSVirtualList` via `virtualScrollConfig` | PASS | Parameter at `ds_data_table.dart:914-921`; use at `:1083-1099`. |
| Performance benchmark proves 10K+ items at 60fps | FAIL | Benchmark command does not compile; source does not assert 16.67ms p99/all-frame budget or memory delta. |
| Catalog cases for list/grid | PASS, source-level | `buildVirtualScrollSection()` includes 1K, 5K, 10K list demos and 1K/5K grid demos at `design_system_gallery_sections.dart:1793-2077`; registry entry at `design_system_gallery_registry.dart:85-90`. |
| Analyzer/test claims in Completion Evidence | FAIL, partial | Analyzer and widget tests pass; benchmark pass claim is false in current verification. |
| Changelog entry | PASS | `docs/changelog/20260608-223000-1123-2026-06-08-task-1123-virtual-scroll-optimization-builders.md`. |
| Completion Evidence filled | PARTIAL | Filled, but contains false/currently stale benchmark PASS claim and 60fps claim mismatch. |

## Path To 100

1. **Repair the benchmark compile failure**: update `test/performance/virtual_scroll_benchmark.dart` to use `PrismVirtualList`, `PrismVirtualGrid`, and `PrismVirtualScrollConfig`, or import the internal virtual-scroll file intentionally. Re-run `flutter test test/performance/virtual_scroll_benchmark.dart` and capture the exact passing output.
2. **Make the benchmark prove the actual contract**: assert average, p99, and max/all frame times against `16.67ms`; add peak memory delta measurement/reporting; remove the current `<50ms` substitute or explicitly downgrade the claim if only a smoke test is feasible.
3. **Fix `DSVirtualList` controller lifecycle**: add `didUpdateWidget` controller detach/attach logic and replace the uninitialized `late final` failure mode with nullable owned-controller tracking. Add regression tests for external→external, external→null, and null→external controller transitions.
4. **Add accessibility regression tests for data-table integration surfaces**: explicit semantics labels and 48x48 targets for secret reveal, row actions, page buttons, sortable headers, row tap, select-all checkbox, and row checkbox. Keep the exact interactive code-site count from this review as the baseline.
5. **Refresh task evidence after fixes**: update the task's unchecked first subtask and Completion Evidence only after the gates pass. Do not preserve the current 100/100 previous score claim without the new benchmark evidence.

## Task Ledger Patch Suggestion

Do not paste this full report into the task. Suggested compact ledger update:

```markdown
---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed under Previous Reports. Persistent findings and regression guards are part of the acceptance contract.

### Latest Review

- **Date**: 2026-06-13
- **Reviewer profile**: `reviewers`
- **Score**: `49/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-1/1123-review.md`
- **Lane outcome**: `return to doing`
- **Task reference**: Task 1123 (`warp-prism-virtual-scroll-optimization`)

#### Current Open Blockers

- `REGRESSION`: `flutter test test/performance/virtual_scroll_benchmark.dart` fails to compile from `packages/warp_prism_ui/` because the benchmark imports the public barrel but references non-exported `DS*` symbols.
- `EVIDENCE_GAP`: Benchmark asserts average `<50ms`, not 60fps `<16.67ms`, does not assert p99/all-frame budget, and does not measure peak memory delta.
- `NEW`: `DSVirtualList` lacks controller replacement lifecycle handling.
- `NEW`: Data-table interactive surfaces need explicit semantics/touch-target proof before Axiom 4 can pass fully.

#### Path-to-100 Summary

- Fix benchmark imports or use Prism aliases, then rerun the benchmark.
- Enforce 16.67ms average/p99/max and memory-delta metrics, or stop claiming 60fps proof.
- Add `didUpdateWidget` controller attach/detach logic and lifecycle regression tests.
- Add semantics and 48x48 target tests for data-table interactive surfaces.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1123-review.md`
  - **Carried forward**: Core implementation shape accepted, but current review invalidates benchmark proof.
  - **Regression guard**: Benchmark command must pass from `packages/warp_prism_ui/` with the same command listed in the task.
```
