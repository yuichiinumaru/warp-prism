# Review Report: Task 1115 — Loading Skeleton And Error Boundary — 2026-07-09

## Review Lineage

- **Current task**: Task 1115 (`1115-warp-prism-loading-skeleton-error-boundary`); live path at review start `docs/tasks/03-review/1115-warp-prism-loading-skeleton-error-boundary.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1115-review.md` — historical **100**
  - `docs/reports/build-gate-review/1115-review-2026-06-17.md` — independent **42** (workspace FAIL + **error-handler restore bug** + hard gate)
  - Wave promote 2026-07-09 — **100** on shimmer+error **+33**
- **Related reports considered**: CyberCore uses `PrismErrorBoundary` wrappers; skeleton tokens policy
- **Review mode**: `re-review` (independent; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Shimmer/skeleton stack is solid (AnimationController disposed; tokens; gallery; **19/19** tests). **DSErrorBoundary remains structurally defective**: restore guard compares against a **never-installed** method, so dispose **never** restores `FlutterError.onError`; nested boundaries leak global handlers. Tests claiming catch/retry **do not exercise the boundary** — they pump `DSFallbackView` directly (vacuous Proof Reality). Wave-100 is **not earned**.

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 42)

- `RESOLVED`: Live tests **19 + 14 = 33/33 PASS** (workspace no longer blocks).
- `RESOLVED`: Scoped analyze on shimmer/skeleton/error/fallback → **No issues found**.
- `RESOLVED` / SUPERSEDED: 1102 hard-gate Critical (upstream 100 in review).
- `RESOLVED`: `DSShimmer` AnimationController dispose path correct.

### Persistent Findings

- `PERSISTENT` / **High**: `DSErrorBoundary._restoreErrorHandler` only restores when `FlutterError.onError == _handleFlutterError`, but install assigns an **anonymous** closure — restore is a no-op. Global handler remains after dispose (2026-06-17 Lifecycle FAIL still live).
- `PERSISTENT` / High: `_handleFlutterError` is dead code relative to install path (same root cause).
- `PERSISTENT` / Medium: Mechanism uses global `FlutterError.onError`, which does **not** isolate subtree build errors the way a true boundary (`ErrorWidget.builder` / zone) would; contract overclaims “catches widget build errors”.

### Regressions

- None vs June source; prior 100 promote ignored known restore bug.

### New Findings

- `NEW` / **High**: Error-boundary tests titled as catch/retry only render `DSFallbackView` with comments admitting pipeline is “hard to test” — **does not prove** boundary catches exceptions or retry rebuilds child (task Test Requirements + Proof Reality).
- `NEW` / Low: Shimmer/skeleton lack `ExcludeSemantics` / reduced-motion note (decorative animation may be noisy for AT).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No test that forces a child build error under `DSErrorBoundary` and expects fallback + retry rebuild.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (scoped) | No issues found on 6 deliverable files |
| 2 | Lifecycle Safety | **FAIL** | Error handler not restored on dispose; global leak / nested stack corruption risk |
| 3 | Dependency Direction | **PASS** | molecules/organisms → tokens/atoms |
| 4 | UI Accessibility | **PARTIAL** | Fallback uses OutlinedButton; skeletons no exclude-semantics |
| 5 | Proof Reality | **FAIL** | Catch/retry tests vacuous; 33/33 pass does not prove boundary |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | **High** | Open | Dispose restore never runs (identity mismatch) | 2026-06-17 | `ds_error_boundary.dart` install vs `_restoreErrorHandler` |
| F2 | PERSISTENT | High | Open | Global onError not a real widget isolation boundary | 2026-06-17 / this | framework behavior + code |
| F3 | NEW | **High** | Open | Vacuous boundary tests (FallbackView only) | this report | `ds_error_boundary_test.dart` groups |
| F4 | RESOLVED | Critical | Closed | Workspace blocked tests | 2026-06-17 | live 33/33 |
| F5 | NEW | Low | Open | Shimmer no ExcludeSemantics / reduced motion | this report | `ds_shimmer.dart` |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1–4 | Shimmer + skeleton variants exist | **YES** | molecules present |
| 5–6 | ErrorBoundary + FallbackView | **PARTIAL** | files exist; behavior defective |
| 7–8 | Exports molecules/organisms | **YES** | barrels + Prism aliases |
| 9 | Gallery entries | **YES** | gallery sections |
| 10–11 | Tests 19+14 | **YES** count / **NO** quality for catch |
| 12–13 | Analyze + tests green | **YES** commands / **NO** for boundary proof |
| 14–15 | Changelog + evidence | **YES** | present |

## Evidence Reviewed

- `ds_shimmer.dart`, skeleton variants, `ds_error_boundary.dart`, `ds_fallback_view.dart`
- `test/molecules/ds_shimmer_test.dart`, `ds_error_boundary_test.dart` (full)
- Prior independent 42/100 findings

## Commands Run

```text
cd packages/warp_prism_ui
flutter test --concurrency=1 --no-pub \
  test/molecules/ds_shimmer_test.dart \
  test/molecules/ds_error_boundary_test.dart
# → +33: All tests passed!

dart analyze \
  lib/src/molecules/ds_shimmer.dart \
  lib/src/molecules/ds_skeleton_card.dart \
  lib/src/molecules/ds_skeleton_table_rows.dart \
  lib/src/molecules/ds_skeleton_text_line.dart \
  lib/src/organisms/ds_error_boundary.dart \
  lib/src/organisms/ds_fallback_view.dart
# → No issues found!
```

## Path To 100

1. **Fix restore**: install named/tear-off handler; restore only if current handler is this instance’s handler; support nested boundaries (stack).
2. Prefer **subtree isolation** pattern documented honestly (e.g. custom `ErrorWidget.builder` scoped carefully, or builder-based try pattern) — do not claim React-like catch if not delivered.
3. **Tests that must fail if broken**:
   - child that throws in build → fallback UI shown
   - retry clears error and rebuilds healthy child
   - dispose restores previous `FlutterError.onError`
   - nested boundary dispose order
4. Mark shimmer decorative with `ExcludeSemantics` (or document reduced-motion policy).
5. Keep skeleton suite as-is once boundary is fixed.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1115-loading-skeleton-error-boundary-independent-rereview.md`
- Score: **72/100** — `REJECTED_TO_DOING`
- Lane: `03-review/` → `02-doing/`
- Blockers: F1 handler restore; F3 vacuous catch tests; F2 isolation mechanism
- Commands: 33/33 PASS but proof quality FAIL for boundary; analyze clean
```
