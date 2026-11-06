# Task 1871: Decision-review surface + bounded repair (F-04)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S02](../stories/P0-S02-command-review-spine.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-04 (I=100, seam S6) — WB-U5, TP U-05, CC W3-C/I-7, EV-H3/M6, Macro P1-3/C4.
> **Priority**: P0 · **Depends on**: Task 1868 (authority outcome) + Task 1869 (unknown vocabulary) — construction may start on their frozen interfaces; integration waits for functioning implementations.

Built independently 3× (WB `ProposalPanel`+`AssurancePanel`+`RepairDialog`; TP `CommandBarDialog`+`PromptEnhancerDialog`; CC `ControlPanel`+`_GatedAction`). All parts exist (`DSDetailInspector`, `DSEvidenceRow`, `DSAssetCard`, `MasterDetailTemplate`); the review framing does not. This task supplies the framing, not the parts.

## Outcome and boundaries

Land organism `PrismDecisionReviewSurface` (inspector + evidence + caller-diff + caller-action-bar) plus bounded-repair molecule (RepairDialog shape) with approval-mode/undo-per-reply as options. Verdict pass-through invariant shared: unknown evidence ⇒ unknown verdict, never pass (consumes Task 1869); every gated action resolves through Task 1868 with tooltip-reason per verdict. EXPERIMENTAL, no barrel export.

Non-goals: proposal computation, prompt-enhancement models, approval policy, repair *execution* backends (product-local); decision-reconstruction models (Sentry-local); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart` | Extension base (`:10`,`:194`,`:210`) — review surface builds on it |
| `packages/warp_prism_ui/lib/src/molecules/ds_evidence_row.dart` | Evidence row part — reuse, do not fork |
| `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart` | Asset part — reuse |
| `packages/warp_prism_ui/lib/src/organisms/` | New `PrismDecisionReviewSurface` organism home |
| `packages/warp_prism_ui/lib/src/molecules/` | Bounded-repair molecule home |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task |
| `docs/bridge/command-center/prism-gap-components.md` | CC `ControlPanel` donor — re-verify live |

## Work

- [ ] Macro-review the three donor surfaces together (unify/improve, never copy blindly); record the unification decision (what was kept from each, what was rejected and why).
- [ ] Implement review organism + repair molecule; verdict pass-through suite: unknown/abstained evidence ⇒ non-pass verdict (failing-first); tooltip-reason per verdict.
- [ ] Wire eligibility through 1868's outcome type and indeterminacy through 1869's vocabulary — no local re-invention of either.
- [ ] Fake/reference + conformance green; determinism (no animation-dependent capture in verdict rendering).
- [ ] Format/analyze clean; boundary green; host proof on ≥2 hosts (backlog gate — CC + WB or TP, real routes, AGENTS §7.1 evidence).

## Success and verification

Success = review surface renders inspector+evidence+diff+action-bar, unknown≠pass suite-proven, every verdict carries its reason, MISSION §6 gates (2)(3)(4)(5 ≥2 hosts)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/organisms packages/warp_prism_ui/lib/src/molecules
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/molecules packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with pass-through tests, two host-exercise logs, unification decision record, reviewer verdict.

## Context / reliance

Blocked on 1868 + 1869 contracts for integration (interface-stability suffices for construction). Parallelizable with Task 1874 (different writesets; both compose on 1868/1869 outputs, not on each other). Feeds P2 Sentry views (F-26/F-27) — out of scope here.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197020f410018CWnyxbZrBFKQ8`, resumed same opencode session `ses_e68fdf023ffex3YUSmtKZYvlPg` with exactly `continue` (`sh_1970c960f001KGUUowiiF8tUpL`) after the launcher returned with no packet (worker had parked the full suite in an inner background shell that died with it). Full handoff `status: complete` recovered from the session transcript via `opencode session export` (978KB JSON, 4 packet copies; final used).
- **Filesystem check**: 3 new lib files (verdict contract + review organism + repair molecule) + 4 new test files present; `boundary_test.dart` additive-only (3 `review_1871_*`); 1874's timeline files untouched; no barrel/alias exports.
- **Parent re-run (fresh, after return)**: `dart format` on 7 touched paths normalized 4 test files (whitespace-only; worker's last format predated final test edits), re-run → 0 changed exit 0; new suites → **31/31 pass exit 0** (16+5+6+4); pure-dart boundary harness → **47/47 PASS exit 0**.
- **Not re-run by parent**: full organisms+molecules+boundary 1192 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residual**: real-host CC/WB exercise substituted with headless sweep on named routes (exact limitation recorded in host test header).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51b2a451ffeb2Z8G8XtGq5Ev3` (independent — did not build). Report: `.project/reports/reviewers/20261106-005504-review-task-1871-decision-review-bounded-repair.md`.
- **Verdict**: PASS (87/100 diagnostic). No remediation requested.
- **Accepted evidence**: format 180 files 0-changed; 4-file scope 31/31; organisms+molecules superset 1381/1381; boundary 81/81 (3× `review_1871_*`); analyzer zero errors (1 pre-existing unrelated warning in `filter_builder_1860_test.dart`, Task 1860's); EXPERIMENTAL containment (no barrel/alias exports); resolver fail-closed; 1868/1869 consumed, not re-invented.
- **Residuals (non-blocking)**: caller-supplied `DSReviewAction.authority` rendered as data (promotion-time derivation enforcement noted); real CC/WB host proof owed before STABLE only.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 87/100; 31/31 + superset 1381/1381, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1871-warp-prism-decision-review-bounded-repair-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
