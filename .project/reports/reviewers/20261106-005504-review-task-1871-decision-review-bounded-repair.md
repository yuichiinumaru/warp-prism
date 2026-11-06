# Independent Review — Task 1871: Decision-review surface + bounded repair (F-04)

> **Lane**: reviewers · **Subject**: Task 1871 (`02-doing/1871-warp-prism-decision-review-bounded-repair.md`)
> **Verdict**: PASS · **Diagnostic score**: 87/100 (diagnostic only; does not gate acceptance)
> **Report path**: `.project/reports/reviewers/20261106-005504-review-task-1871-decision-review-bounded-repair.md`
> **Prior lineage**: no prior 1871/1874 reviewer reports (verified `ls … | grep -E "1871|1874"` → `NO-PRIOR-1871-1874-REPORTS`); parent builder verification in the task file §"Parent verification — 2026-11-01" treated as evidence input, not acceptance; all claims below re-proven live by this reviewer.

## 1. What was reviewed (stable view)

- Task contract: `packages/warp_prism_ui` organism `PrismDecisionReviewSurface` (inspector + evidence + caller-diff + caller-action-bar) + bounded-repair molecule (RepairDialog shape, approval-mode/undo-per-reply options); verdict pass-through invariant (unknown ⇒ unknown, never pass, consumes 1869); every gated action resolves through 1868 with tooltip reason per verdict; EXPERIMENTAL, no barrel export, no STABLE promotion.
- Implementation (read in full):
  - `packages/warp_prism_ui/lib/src/organisms/ds_review_verdict.dart` — resolver `resolveReviewVerdict` (`:123-:132`), reason `verdictReasonFor` (`:138-:176`), authority projection `authorityForVerdict` (`:210-:224`), fake `ReferenceReviewPolicy` (`:235-:254`).
  - `packages/warp_prism_ui/lib/src/organisms/ds_decision_review_surface.dart` — surface `DSDecisionReviewSurface.build` (`:90-:169`), action-bar rendering (`:139-:164`), caller-data `DSReviewAction` (`:176-:203`), fail-closed banner `_VerdictBanner` (`:212-:256`).
  - `packages/warp_prism_ui/lib/src/molecules/ds_bounded_repair.dart` — `DSBoundedRepair` (`:30-:170`), fail-closed default `approveAuthority = DSActionAuthority.deny` (`:80`), `effectiveApproveReason` fallback (`:89-:93`), per-reply undo gating (`canUndo`, `:249`).
- Tests (read): `test/organisms/review_verdict_passthrough_test.dart` (16), `test/organisms/decision_review_surface_test.dart` (5), `test/molecules/bounded_repair_dialog_test.dart` (6), `test/organisms/review_host_composition_test.dart` (4, headless host-shaped sweep with explicit limitation header `:15-:19`).
- Architecture law: `.project/architecture/layer-contracts.md` §§1/4/9 (ADS stays Flutter-only; EXPERIMENTAL = no barrel export; STABLE needs boundary + host proof + independent review + API freeze).

## 2. Lifecycle / layer audit (Flutter ΔR)

- **Controllers/subscriptions/timers**: none in the seam. Grep over `ds_review_verdict.dart`, `ds_decision_review_surface.dart`, `ds_bounded_repair.dart` for `TextEditingController|AnimationController|ScrollController|StreamSubscription|Timer(` → zero hits. `DSTimeRuler`-style state is not part of this seam. No `dispose()` obligation arises; stateless presentation + pure-Dart resolver is the correct shape.
- **Unmounted/async**: no `await` in the seam's lib code paths; widgets are synchronous renders of injected data. No `setState`-after-dispose or use-after-await surface exists.
- **Riverpod/state-management**: not used in this seam; state arrives as injected constructor data (`evidence`, `actions`, `replies`, authorities). No provider-lifecycle question arises.
- **Async tri-state**: N/A as async UI; the synchronous analogue (pass/fail/unknown) is exhaustively handled — banner switches all three verdicts (`_VerdictBanner.build`), evidence rows project indeterminate/error/determinate, every verdict carries a non-empty reason (suite-proven).
- **Layer direction**: UI consumes only its own tokens/theme/molecules plus the frozen 1868/1869 vocabulary (`DSActionAuthority`, `DSStateType`); no `flutter_rust_bridge`, runtime, bindings, adapter, persistence/IO, or consumer-src imports in the seam. UI never evaluates capability presence — authority arrives as data. Domain stays caller-local (`diff` opaque slot, `onPressed/onUndo/onApprove` caller callbacks). Correct direction.

## 3. Fresh validation (exact commands, live results)

- `dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/organisms packages/warp_prism_ui/lib/src/molecules` → `Formatted 180 files (0 changed)`, exit 0. (Task 1871 format gate: clean.)
- `flutter analyze packages/warp_prism_ui` → **zero errors**; only `info` lints plus one pre-existing `warning: unused_import` in the unrelated `test/organisms/filter_workbench/filter_builder_1860_test.dart:13:8`. No finding touches the 1871 seam. (Task 1871 analyze gate: pass with unrelated pre-existing warning noted.)
- Task-scope suites, run individually then jointly:
  - `decision_review_surface_test.dart` → 5/5 pass.
  - `bounded_repair_dialog_test.dart` → 6/6 pass.
  - `review_verdict_passthrough_test.dart` → 16/16 pass.
  - `review_host_composition_test.dart` → 4/4 pass (CC-like denied-abort refusal, WB-like unknown-blocks-approval, repair undo/cancel, 3-viewport sweep; zero `FlutterError` in each).
  - Joint 1871 four-file run → **31/31 pass** (`All tests passed!`), matching the parent's 31/31 claim with fresh evidence.
- Superset re-proof: `flutter test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/molecules` → **1381/1381 pass** (`All tests passed!`). No regressions in adjacent suites.
- `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` (repo root) → **81/81 PASS**, including the three `review_1871_*` checks; attributed to both tasks per dispatch.
- EXPERIMENTAL export check: grep for `ds_review_verdict|ds_decision_review|ds_bounded_repair` in `lib/warp_prism_ui.dart`, `src/organisms/organisms.dart`, `src/molecules/molecules.dart`, `src/prism_aliases.dart` → zero hits; grep for `PrismDecision|PrismBounded|PrismReview` in `lib/` → zero hits. No barrel/alias leak. STABLE gates remain deferred by contract.

## 4. Semantic findings

1. **Fail-closed resolver — sound.** Order of checks (empty/indeterminate → unknown; then error → fail; else pass) makes unknown-never-pass structural, not conventional. `authorityForVerdict` maps non-pass to deny with the verdict reason. Suite pins all edges including single-unknown-among-passing and determinism (repeated calls agree).
2. **Banner and repair defaults — sound.** Unknown renders `DSStateSurface.unknown` (never success); fail renders error with the blocking reason; `DSBoundedRepair` defaults to deny with a fail-closed reason fallback, so an unreasoned gate still withholds with explanation.
3. **Caller-authority coupling — recorded residual, not a contract breach (the one open concern from dispatch).** `DSDecisionReviewSurface` renders each `DSReviewAction.authority` exactly as supplied (`:147-:160`) and never derives it from `authorityForVerdict(evidence)`; the class doc states authority arrives "as data (never evaluated here)" (`:173-:174`). A caller that supplies `allow` under unknown evidence would get an enabled action under a "Verdict withheld" banner. The task text requires "every gated action resolves through Task 1868 with tooltip-reason per verdict" — satisfied as *type + reason* (gate renders through `DSActionGate`, tooltip falls back to the verdict reason), but the task does not state the surface auto-derives each action from the verdict, and the only unknown-evidence surface test supplies `deny` manually. The in-repo correct-composition pattern (proposal route derives `gate = authorityForVerdict(verdict, evidence)` and passes `gate.authority/gate.reason`) is proven in `review_host_composition_test.dart:83-:102`. **Disposition**: acceptable for EXPERIMENTAL with no barrel export (misuse requires explicit `src/` import and contradicts the documented composition pattern), but the promotion task should either (a) derive/consistency-assert action authorities from the verdict inside the surface, or (b) elevate the "derive via `authorityForVerdict`" rule from test/doc into a mechanical check. Left as a named residual for the promotion gate, not a FAIL, because the resolver, banner, gate rendering, and proven composition pattern are all fail-closed and the component is honest about its boundary.
4. **1868/1869 adjacency — clean.** Indeterminacy flows through 1869's `isIndeterminate` (never re-invented); gating flows through 1868's `DSActionAuthority` (never re-evaluated in UI). Test-only IDS→ADS mappers mirror the Task 1870 precedent and live in tests, not lib. No vocabulary fork.
5. **Real-host proof — explicit residual.** The host test header records that CC/WB/TP product hosts live outside the workspace and no display host was available, so the "≥2 hosts" evidence is a headless host-shaped sweep (named routes, two meaningful interactions, theme/focus propagation, viewport sweep), not real-host execution. Package proof only. Correctly recorded as a limitation, never claimed as host PASS; consistent with EXPERIMENTAL (real-host proof is a STABLE gate).

## 5. Verdict and next action

- **Verdict: PASS.** The 1871 contract holds on fresh evidence: review surface renders inspector+evidence+diff+action-bar, unknown≠pass is suite-proven, every verdict/gate carries its reason, fake/reference agree deterministically, format/analyze/suite/boundary gates are green, and EXPERIMENTAL constraints (no barrel/alias export, no STABLE claim) hold.
- **Score: 87/100** (diagnostic only).
- **Remediation**: none required by this reviewer (no FAIL finding; nothing was mutated — review session scored and reported only).
- **Named residuals for downstream gates** (not holds on this EXPERIMENTAL seam): (i) caller-authority coupling — promotion should enforce derivation/consistency of action authorities from the verdict; (ii) real CC/WB product-host exercise still owed before STABLE; (iii) one pre-existing unrelated analyze warning (`filter_builder_1860_test.dart` unused import) left untouched as out of scope.
