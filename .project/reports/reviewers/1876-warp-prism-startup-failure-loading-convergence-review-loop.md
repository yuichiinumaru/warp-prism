# Review loop — Task 1876: Startup-failure view + loading-chrome convergence (F-09)

> **Task**: `02-doing/1876-warp-prism-startup-failure-view-loading-convergence.md` · **Mode**: BUILDER_CONTEXT (independent bundled review; review-only, no lane move)
> **Reviewer**: Implacable Flutter Reviewer · **Date (UTC)**: 2026-11-06
> **Skills/methods**: `code-quality`, `flutter`, `gt-global-subagent-review.md`, `sw-code-quality-bundled-review.md`, `sw-code-quality-review-flutter.md`
> **Prior entries**: none (initial review in this file).

## Verdict: PASS · Diagnostic score: 89/100 (Elite-band; diagnostic only, does not gate)

## 1. Scope and diff ownership (Task 1876 owns)

| File | Ownership |
|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_startup_failure_view.dart` | NEW, 1876-owned |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | ADDITIVE-ONLY: 5 convergence constructors (`loadingPane`, `loadingRow`, `inlineError`, `startupFailure`, `bootstrapLoading`) on the pre-existing surface; 1876 owns exactly these constructors |
| `packages/warp_prism_ui/test/molecules/startup_failure_view_test.dart` | NEW, 1876-owned (27/27) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ADDITIVE-ONLY: 5 `startup_1876_*` checks; shared cross-task |
| `packages/warp_prism_ui/lib/src/organisms/{ds_fallback_view.dart,ds_error_boundary.dart}` | NOT touched (composition bases, read-only) |

No other bundle task writes these paths (parent confirms 1859's runtime/bindings/testkit/adapter files untouched).

## 2. Lifecycle audit (Flutter ΔR)

- **Controllers/subscriptions/timers**: none in scope. `DSStartupFailureView` is `StatelessWidget` with an optional caller-owned `FocusNode` (never created, never disposed here — correct: creator disposes). `DSStateSurface` additions are `const` constructors only. Determinism claim verified: no `CircularProgressIndicator` animation was ADDED by this task (the pre-existing loading-mode indicator is untouched base behavior); no timers/wall-clock; boundary check `startup_1876_deterministic_no_animation` PASS and `startup_1876_goldens_exclude_startup` PASS. **Clean.**
- **Unmounted `setState`/post-`await`**: no `async`/`await`/`setState` in scope. `guard()` forwards the caught failure synchronously into `DSErrorBoundary`'s `fallbackBuilder`. **Clean.**
- **Riverpod/`AsyncValue`**: N/A — no providers; indeterminate state is plain data (`_indeterminate` flag + frozen `DSStateType.unknown`).
- **Leak-negative (the trust-critical invariant)**: `cause` is accepted as opaque `Object?` (7 grep hits, all plumbing/doc — zero render sites). `build()` renders only `title`/`guidance` fixed copy through `DSStateSurface.error`/`.unknown`. `DSFallbackView`'s `kDebugMode ? error.toString()` path (lines 68–72) is **not** in this task's render path — `guard()` routes failures to `DSStartupFailureView`, never to the raw `DSFallbackView`. Suite group `leak-negative: internals never render` (line 85) feeds adversarial exception/daemon payloads and asserts sanitized render — green. Boundary check `startup_1876_no_leak_rendering` PASS. **Fail-closed proven, including the debug-mode trap.**
- **1869 vocabulary consumption**: interface-only (`DSStateType.unknown`, `isIndeterminate` assert at lines 129–132 that fails loudly if the frozen contract is ever violated, `.unknown` surface for indeterminate). No re-invention. Boundary check `startup_1876_unknown_consumes_1869_vocabulary` PASS. 1869 itself is consumed, not re-reviewed, per dispatch.
- **Layer direction**: molecule imports organisms' boundary + state surface + tokens; no domain/backend/daemon imports. Causation/bootstrap orchestration stays product-side; `onRetry` is a pure affordance (no backoff/budgets). **Clean.**

## 3. Findings

### Task-specific
- None blocking. One non-blocking note: `cause` is retained as an opaque field for the widget's lifetime (docstring says "not retained in memory beyond the opaque [cause]" — it IS retained as the field, just never rendered). The wording slightly overclaims; retention of an opaque reference the consumer already holds is harmless, but the comment could say "never rendered or inspected" instead. Cosmetic.

### Cross-cutting
- `boundary_test.dart` additive-only; 5 `startup_1876_*` checks PASS within 81/81. The mid-wave `media_terminality.dart` leak flagged during this task's window is confirmed fixed in-tree (81/81, 0 violations). See return-packet blast radius.

## 4. Commands run (exact, with exits/counts)

- `dart format` on touched paths (covered in 209-file sweep) → 0 changed, exit 0.
- `flutter analyze packages/warp_prism_ui packages/warp_prism_interaction` → **0 errors**, exit 0.
- `flutter test packages/warp_prism_ui/test/molecules/startup_failure_view_test.dart` → **27/27 pass** (incl. leak-negative, convergence-mapping, golden-exclusion, a11y-announcement, simulated-daemon-failure host-proof groups).
- `dart …/boundaries/boundary_test.dart` → **81/81 PASS** incl. all 5 `startup_1876_*`; exit 0.
- Barrel/alias grep for `ds_startup_failure_view` → zero barrel matches, zero `PrismStartupFailureView` alias. **EXPERIMENTAL hold verified.**

## 5. Affected consumers / host proof

- Claimed consumer: CC bootstrap route with simulated daemon failure. Donor re-verification INHERITED-REPORT (sibling reads denied by workspace boundary — recorded, not disguised). Real-display proof **substituted with headless sweep** (suite group line 324, green). Classification: `affected_consumers: [CC bootstrap route — headless sweep with simulated failure only; real-display exercise deferred]`. Per dispatch, package proof suffices for EXPERIMENTAL. Not a blocker; STABLE must carry the CC real-host gate with a genuine simulated-daemon failure.

## 6. Remediation targets

None — no FAIL/BLOCKED findings.

## 7. Compact ledger suggestion

```markdown
- 2026-11-06 independent bundled review (reviewer, BUILDER_CONTEXT): PASS, diag 89. Evidence: startup suite 27/27 (leak-negative green incl. debug-mode path analysis), boundary 81/81 (5 startup_1876_* PASS), analyze 0 errors, no barrel/alias exports. Residual: real-display CC bootstrap proof + donor direct re-verify deferred to STABLE. Report: `.project/reports/reviewers/1876-warp-prism-startup-failure-loading-convergence-review-loop.md`.
```
