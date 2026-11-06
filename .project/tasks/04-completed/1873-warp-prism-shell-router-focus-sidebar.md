# Task 1873: Shell-slot router + Draw-derived focus + sidebar section model (F-06)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S04](../stories/P0-S04-shell-timeline-transport.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-06 (I=60, seam S9) — TP U-01, CC W2-A/I-4, EV-H1/H2, FG-U2 (A7/A8 Draw-derived focus + Region model), Macro P1-7/C10.
> **Priority**: P0 · **Parallelizable with**: Task 1870, Task 1872 (distinct writesets; shared batched IDS review).

Only real multi-pane hosts: CC + Tempest `MainShellLayout` (203 lines, 7 branches); WB single-column is recorded negative evidence, not proof. Donor H1 focus-tracking is idea-only; Figcraft A7/A8 (`a11y.rs:29-58,86-99` Region + Drawn + `refocus` + `scroll_to`) is the only proven focus shape. Sidebar H2 (collapsible/kept-row/Starred/unread/drag-insertion) folds here — one router, not two items.

## Outcome and boundaries

Land IDS shell-slot machine (slot/active-pane/focus-return token **derived from last committed layout**, `refocus`+`scroll_to` edge cases) + organism `PrismShellRouter` over `DSShell`/`SplitPane` + `PrismSidebar` section-model extension (kept-row fold, insertion line, Starred, unread pills). Focus wiring mechanics stay ADS (focus/DOM-equivalent mechanics must not enter IDS). Determinism across transitions. EXPERIMENTAL, no barrel export.

Non-goals: app roots/routers, daemon wiring, sidebar drag backends (product-local); token/shell convergence sweep (P1 F-15); WB shell (negative evidence); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_interaction/lib/src/state_machine/` | Slot-machine semantics home (pure-Dart neighbor) |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | `DSShell`/`SplitPane` base — router builds over it |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | `PrismSidebar` extension site |
| `packages/warp_prism_ui/lib/src/organisms/` | New `PrismShellRouter` home |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task |
| `docs/bridge/command-center/prism-gap-components.md` | `CommandCenterShell` donor — re-verify live |

## Work

- [ ] Re-verify CC shell + Tempest `MainShellLayout` shape live where readable (INHERITED-REPORT otherwise); confirm WB exclusion as negative evidence.
- [ ] Implement IDS slot machine + focus-return token with Draw-derived semantics; focus-restoration conformance suite (layout transition ⇒ focus returns to committed token; `refocus`/`scroll_to` edge cases covered).
- [ ] Implement `PrismShellRouter` + sidebar section-model extension; multi-pane host proof on CC (only real multi-pane host — AGENTS §7.1 evidence: enter primary routes, interact, viewport conditions, theme/focus/navigation propagation).
- [ ] Determinism across transitions (no transition-animation-dependent state); format/analyze clean; boundary green.

## Success and verification

Success = slot machine + token semantics in IDS, router + sidebar in ADS, focus-restoration suite green, CC host proof complete, MISSION §6 gates (2)(3)(4)(5 CC)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_interaction/lib/src/state_machine packages/warp_prism_ui/lib/src/organisms
flutter analyze packages/warp_prism_interaction packages/warp_prism_ui
flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with focus-restoration tests, CC host-exercise log, reviewer verdict.

## Context / reliance

Consumes 1868's eligibility shape for gated sidebar rows (interface reliance). U-IDS review input (slot/focus tokens in IDS — batch with 1868/1870/1874 proposals into one IDS review). Parallelizable with 1870/1872; independent of 1874/1875 except shared guards.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196f67655001boWVBPAIw75gk8`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: IDS `state_machine/shell_slot_machine.dart` + 12-test suite, `ds_sidebar_sections.dart`, `shell_router/ds_shell_router.dart`, 3 UI test files present; `boundary_test.dart` additive-only (4 `shell_1873_*`); 1872's in-progress files untouched; no barrel/alias exports (grep over 4 barrels empty).
- **Parent re-run (fresh, after return, with 1872 still active in tree)**: `dart format` on 9 touched paths → 0 changed exit 0; slot-machine suite → **12/12 pass exit 0**; shell_router UI suites → **15/15 pass exit 0**; pure-dart boundary harness → **40/40 PASS exit 0** (33 prior + 4 shell + 1872's 3 landed checks, no interference).
- **Not re-run by parent**: full interaction 233 + organisms 762 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: direct CC/Tempest donor reads were performed by the worker (stronger than INHERITED-REPORT); real-display host proof substituted with headless sweep (exact limitation recorded); WB single-column negative evidence accepted as stated per task.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51a3ee20ffeYG7d29XMBfAPf0` (independent — did not build). Report: `.project/reports/reviewers/1873-warp-prism-shell-router-focus-sidebar-review-loop.md`.
- **Verdict**: PASS (88/100 diagnostic). No remediation; only optional STABLE-stage suggestions. Highest-risk surface verified line-by-line (FocusNode/ScrollController disposal, mounted-guarded post-frame restore, slot-machine snapshot/throw discipline).
- **Accepted evidence**: slot-machine 12/12 + shell_router suites 12/12 + CC multipane 3/3 (headless); format sweep 0-changed; analyzer 0 errors (1 pre-existing unrelated 1860 warning); boundary 81/81 incl. 4× `shell_1873_*`; EXPERIMENTAL containment.
- **Residual (non-blocking)**: real CC multi-pane host proof owed before STABLE; recorded, not a verdict blocker at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 88/100; slot 12/12 + router 15/15 + multipane 3/3, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1873-warp-prism-shell-router-focus-sidebar-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
