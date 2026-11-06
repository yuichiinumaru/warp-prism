# Review loop — Task 1867: Harness upgrades (layer-table compaction, two-tier capture, junk sweeps, toast policy)

## Entry 1 — 2026-11-06 independent bundled review (BUILDER_CONTEXT, reviewer: Implacable Flutter Reviewer)

- **Subject**: Task `1867-warp-prism-harness-upgrades-capture-nets-toast.md` in `02-doing/` + live files in its Where table (boundary harness, §10 owner doc, testkit junk conventions, IDS/runtime sweep targets, host-exercise capture entrypoints, toast manager + chrome).
- **Mode**: BUILDER_CONTEXT (task in `02-doing/`; verdict gates `02-doing → 03-review` only via authorized actor; this reviewer performs no lane move, no product edit, no git write).
- **Verdict**: **PASS** (all mandatory acceptance conditions satisfied on fresh evidence).
- **Diagnostic score**: **86 / 100 — Elite** (diagnostic only; does not choose the verdict).
- **Skills/methods actually used**: `code-quality` (bundled-review per-task verdicts, diff ownership, cross-task blast radius), `flutter` (widget lifecycle: toast-manager Timer/Overlay/mounted-guard audit; capture-tier bounded-pump audit), `.opencode/workflows/gt-global-subagent-review.md` (claim-first verdict protocol), `sw-code-quality-bundled-review.md` (one-by-one order after 1859, evidence isolation), `sw-code-quality-review-flutter.md` (Dart evidence adapter). Cross-cutting `security`/`sast` not separately loaded — no secret/auth/network surface in scope; verification evidence collected directly via the task-exact suites below.
- **Prior reports**: none under `.project/reports/reviewers/` for 1867 (glob `*1867*` → no files). Builder journal counterpart: N/A for this initial review turn (same P2 basis as 1859). The task file's Parent verification section (2026-11-01, partial + full-UI residuals) was treated as evidence input, not proof.

### Diff ownership (1867 owns; neighbors do not)

- Owns: boundary-harness compaction (generated layer table + generic upward rule; 5 new `*_1867_*` checks green, 76 legacy held), `layer-contracts.md` §10 tranche rows 17–20 (task-authorized self-update law), `junk_sweep.dart` conventions (stable ids, hostile corpus + `assertCorpusHostile` guard, `JunkSweep` facade), mechanism-mirrored `*_junk_test.dart` suites across IDS + runtime, `capture_tiers.dart` two-tier reference + drain/cancel placement, `ds_toast_manager.dart` policy (cap/sticky/action/hand-back/onDismiss-only-on-close; `PrismToastRemovalReason`, `PrismToastHandBack`). Proof lab `apps/catalog` capture-tier determinism is referenced, not mutated as product work.
- Does not own: executor/terminality vocabulary, binding projections, contract suites (1859's); job-banner vocabulary (1858's, explicitly untouched — toast changes verified not to alter banner semantics); golden-baseline freeze dispute (1816's, not litigated here). Product-widget edits: none found (Parent scope-discipline check stands; remaining tree M's are whitespace/other-wave artifacts, not this review's subject).

### Mandatory acceptance conditions vs fresh evidence

| # | Task condition | Evidence (fresh, this review) | State |
|---|---|---|---|
| a | Layer-table compaction: generated table single source, generic upward rule, every green held | Boundary harness → **81/81 PASS** incl. `layer_table_1867_upward_rule`, `layer_table_1867_single_source`, `toast_1867_policy_symbols`, `capture_1867_tiers_present`, `junk_1867_conventions_present`; §10 rows 17–20 present and ENFORCED | SATISFIED |
| b | Two-tier capture reference + drain/cancel placement proven for FRB path | `capture_tiers.dart` read: Tier-1 chrome-free bounded pumps only (`pumpBounded`, `pumpAndSettle` forbidden by doc contract), Tier-2 `runWindowedCapture` returns structured `WindowedCaptureInspect` (never bare screenshot) with errors visible + oracle-enforced (`failIfMaterial`, never log-and-pass); `FrameBoundaryDrain` bounded (`maxBoundaries`, BLOCKED on non-settle, no infinite loop); `CooperativeCancelScope` request→observe→terminate shape matching the FRB cancel-and-replace token. `flutter test packages/warp_prism_host_exercise` → **17/17 pass, exit 0** | SATISFIED |
| c | Junk/adversarial sweep green on every IDS + runtime suite, mirrored filenames, stable test-ids | `flutter test packages/warp_prism_testkit packages/warp_prism_interaction packages/warp_prism_runtime` → **All tests passed (445 tests), exit 0**; stable-id format `[<mechanism>_junk_<case>]` verified in runtime junk suites; corpus-hostility assert present; filenames mirror mechanisms (`command_junk_test`, `async_command_junk_test`, `describe_junk_test`, etc.) | SATISFIED |
| d | Toast policy + conformance green (cap, sticky, action, hand-back, onDismiss-only-on-close) | `ds_toast_manager.dart` read end-to-end (520 lines): cap eviction hands back `evicted` outside setState; sticky (`Duration.zero`) never starts a timer; action tap hands back `actioned` without firing close callback; `dismiss(id)` is the ONLY `onCloseDismissed` path; `clear()` hands back `cleared` per entry; every `Future.delayed` continuation guards `!mounted`; `dispose()` removes overlay + cancels all timers. Toast conformance → **8/8 pass, exit 0**; `--plain-name toast` UI sweep → all pass | SATISFIED |
| e | All pre-existing suites green through migration; format/analyze/boundary/barrel clean | `dart format` on 5 touched paths → **0 changed, exit 0**; `dart analyze interaction+runtime` → **No issues found**; `flutter analyze` on seam files → 0 errors/warnings (infos only) + 1 known `unused_import` warning in 1860-owned `filter_builder_1860_test.dart:13` (noted by owner, not expanded); boundary 81/81 (above); no new barrel/alias exports (boundary `Public barrel hides DS*` + `experimental_no_barrel_export` family all PASS) | SATISFIED |

### Task-specific findings (none blocking)

- No FAIL/BLOCKED findings. Lifecycle audit notes (all clear):
  1. Toast timers: every `Timer` is cancelled on replace/evict/hover-pause/dismiss/clear/dispose; id-captured (never index-captured) across async gaps — the exact use-after-mutation class this reviewer hunts for is absent.
  2. Toast `setState` after async gaps (`Future.delayed(DSMotion.slow, …)`) is `mounted`-guarded in all three paths (dismiss/expiry/action) — no unmounted-`setState` leak.
  3. Capture tiers use bounded pumps only; `FrameBoundaryDrain` terminates on first quiet boundary or `maxBoundaries` — no unbounded `pumpAndSettle` anywhere in the new surface.
  4. Junk suites assert fail-closed (StateError/no-op/sanitized round-trip) with no bare `sleep`-based flakiness observed in the green runs.
- Non-blocking suggestions (optional, never mandatory):
  1. `CooperativeCancelScope` is synchronous-only; if a future FRB placement needs cross-isolate cancellation, that task should revisit — not this one.
  2. The 227 `flutter analyze` infos (mostly `prefer_const_constructors`) are pre-existing style debt across UI tests; touching them here would violate smallest-sufficient-intervention.

### Cross-cutting findings (shared surfaces, no leakage)

- Shared `boundary_test.dart` + §10 table co-touched with 1859: 1867 owns the compaction (16→table+rule) and rows 17–20; 1859 owns only its additive `executor_1859_*` checks. Both green in the same 81/81 run; neither task's evidence promoted the other — each verdict above rests on its own task-exact suites.
- The 1860 `unused_import` analyzer warning is classified by owner (1860), surfaced here only because the dispatch demands it — no scope expansion, no remediation claimed.

### Commands run (1867 scope + shared gate, exact)

- `dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_testkit/lib packages/warp_prism_host_exercise/lib packages/warp_prism_interaction/lib packages/warp_prism_runtime/lib` → 312 files, 0 changed, exit 0.
- `dart analyze packages/warp_prism_interaction packages/warp_prism_runtime` → No issues found, exit 0.
- `flutter analyze packages/warp_prism_ui packages/warp_prism_testkit packages/warp_prism_host_exercise` → 0 errors/warnings in seam files (infos only; 1 known 1860-owned warning), exit 0.
- `flutter test packages/warp_prism_testkit packages/warp_prism_interaction packages/warp_prism_runtime` → All tests passed (445 tests), exit 0.
- `flutter test packages/warp_prism_host_exercise` → All tests passed (17 tests), exit 0.
- `flutter test packages/warp_prism_ui/test/molecules/ds_toast_policy_conformance_test.dart` → 8/8 pass, exit 0.
- Shared: `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` → **81/81 PASS**, run once from repo root, attributed here for the five `*_1867_*` checks + held greens.

### Residual risks / uninspected targets

- Full-UI sweep (+2207 with 63 pre-existing environmental golden pixel diffs per Parent) not re-run per dispatch (out-of-scope: unrelated full suites, goldens, catalog/observatory/cybercore hosts, sibling repos). None touch the 1867 surfaces; golden-freeze dispute belongs to 1816. Real-host proof substituted with headless sweeps per dispatch: for EXPERIMENTAL harness/toast/capture work, package + boundary + headless-windowed-capture proof suffices; affected-consumer classification: **NONE requiring real-host proof at EXPERIMENTAL** — no product-widget consumer of the changed seams exists yet, and STABLE/host-composition gates stand deferred. This is stated, not treated as PASS-by-absence: the PASS above covers the task's stated observable behavior (mechanical migration green + reference tiers proven on own suites), with STABLE gates explicitly deferred per EXPERIMENTAL holds.
- `harness_catalog` rebuild/validate numbers stand from prior waves (tool absent in runtimes) — accepted as stated residual, not re-proven.

### Remediation targets

- None — PASS carries no mandatory remediation.

### Compact ledger suggestion

```markdown
- 2026-11-06 independent bundled review (BUILDER_CONTEXT) — **PASS**, score 86/100 (diagnostic). Fresh: format 0-changed (312 files); analyze clean (1 known 1860-owned warning noted); IDS+runtime+testkit 445 pass; host_exercise 17 pass; toast conformance 8/8; boundary 81/81. Toast lifecycle clean (mounted-guarded, id-captured timers); capture bounded; junk nets green with stable ids. Report: `.project/reports/reviewers/1867-warp-prism-harness-upgrades-capture-nets-toast-review-loop.md` Entry 1.
```
