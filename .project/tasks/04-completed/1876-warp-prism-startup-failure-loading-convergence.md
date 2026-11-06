# Task 1876: Startup-failure view + loading-chrome convergence (F-09)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S03](../stories/P0-S03-provenance-bootstrap.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-09 (I=48, seam S4-landings) — WB-U4/U10, CC W2-B/I-2, TP U-07 part, Macro P1-4.
> **Priority**: P0 · **Depends on**: Task 1869 vocabulary (construction on the frozen interface may start; integration waits). **Parallelizable with**: Task 1872, Task 1870.

Fail-closed bootstrap: WB `startup_error_page.dart` + CC `DaemonNotConnected`/`DaemonBootstrap` (2 consumers) plus the GOLD loading rationale (non-animated determinism). This task converges them onto one landing vocabulary — a bootstrap failure must inform without leaking internals.

## Outcome and boundaries

Land molecule `PrismStartupFailureView` extending `DSFallbackView`/`DSErrorBoundary`, and converge `LoadingPane`/`Row`/`StateRegion` + Warpblade inline errors into `DSStateSurface` modes built on Task 1869's vocabulary. Leak-negative coverage: no stack trace / exception string / daemon internals ever render. Determinism preserved (GOLD non-animated rationale). EXPERIMENTAL, no barrel export.

Non-goals: daemon bootstrap/orchestration fixes, retry *policy* (presentation-free law — policy lives product-side), job banners (P1 F-10); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/organisms/ds_fallback_view.dart` | Extension base for the startup view |
| `packages/warp_prism_ui/lib/src/organisms/ds_error_boundary.dart` | Boundary behavior — startup view composes with it |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Loading-mode convergence site (consumes 1869's extended `DSStateType`) |
| `packages/warp_prism_ui/lib/src/molecules/` | New `PrismStartupFailureView` home |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task |
| `docs/bridge/command-center/prism-gap-components.md` | CC bootstrap donor citations — re-verify live |

## Work

- [ ] Re-verify WB `startup_error_page.dart` + CC bootstrap citations live (record provenance; INHERITED-REPORT where unreadable).
- [ ] Implement startup-failure molecule + state-surface mode convergence on 1869's vocabulary; leak-negative suite (adversarial exception/daemon payloads ⇒ sanitized render, failing-first); determinism (loading states excluded from goldens, non-animated).
- [ ] Fake/reference green; a11y announcements for failure/loading transitions.
- [ ] Format/analyze clean; boundary green; host proof CC (backlog gate — bootstrap route exercised with a simulated daemon failure, no leak, theme/focus intact).

## Success and verification

Success = startup failures render helpfully with zero internal leakage (suite-proven), loading chrome converged onto state-surface modes, MISSION §6 gates (2)(3)(4)(5 CC)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/molecules packages/warp_prism_ui/lib/src/organisms
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/molecules packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with leak-negative tests, CC host-exercise log with simulated failure, reviewer verdict.

## Context / reliance

Blocked on 1869's vocabulary for integration (interface suffices for construction). Parallelizable with 1872/1870. No feed-out inside P0 beyond completing the S4 seam.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_1970e42ca001oNwYx4AOcXHuRS`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: new `ds_startup_failure_view.dart` + 5 convergence constructors in `ds_state_surface.dart` (grep-confirmed) + new 27-test suite present; `boundary_test.dart` additive-only (5 `startup_1876_*`); 1859's runtime/bindings/testkit/adapter files untouched; no barrel/alias exports.
- **Parent re-run (fresh, after return, with 1859 still active in tree)**: `dart format` on 3 touched paths → 0 changed exit 0; new suite → **27/27 pass exit 0**; pure-dart boundary harness → **52/52 PASS exit 0** (all 5 new checks green; the 1859-owned `media_terminality.dart` leak flagged mid-wave is fixed in-tree).
- **Not re-run by parent**: full molecules+organisms 1219 + state-surface 134 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: donor re-verification INHERITED-REPORT (sibling reads denied by workspace boundary); real-display host proof substituted with headless sweep (exact limitation recorded).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51a3ee20ffeYG7d29XMBfAPf0` (independent — did not build). Report: `.project/reports/reviewers/1876-warp-prism-startup-failure-loading-convergence-review-loop.md`.
- **Verdict**: PASS (89/100 diagnostic). No remediation; only optional STABLE-stage suggestions. Leak-negative proven incl. the kDebugMode trap (unreachable path, adversarial-payload group green).
- **Accepted evidence**: startup suite 27/27; format sweep 0-changed; analyzer 0 errors (1 pre-existing unrelated 1860 warning); boundary 81/81 incl. 5× `startup_1876_*`; EXPERIMENTAL containment; 1869 vocabulary consumed interface-only.
- **Residual (non-blocking)**: real CC bootstrap host proof owed before STABLE; recorded, not a verdict blocker at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 89/100; startup 27/27, leak-negative proven, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1876-warp-prism-startup-failure-loading-convergence-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
