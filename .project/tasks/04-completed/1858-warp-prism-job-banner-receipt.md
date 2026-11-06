# Task 1858: PrismJobBanner molecule with staged progress, cancel, and terminal receipt

Change only the job-presentation seam in `warp_prism_ui`: add an EXPERIMENTAL
molecule `PrismJobBanner` (staged progress + cancel + deterministic terminal
receipt slot) converged from Warpblade export banners, Tempest `ProgressCard`,
and the Command-center loading trio. Success is the stated observable behavior,
verified by the relevant checks below.

## Outcome and boundaries

- **Authorized outcome**: one reusable job-banner vocabulary exists as
  EXPERIMENTAL (spec + fake + conformance suite, no barrel export): staged
  progress, cancel affordance with semantics, deterministic terminal receipt
  slot. Receipt *content* (DEST/FRAMES/BYTES/SHA256 and equivalents) stays
  consumer-side — Prism owns the slot, never the bytes.
- **Subject**: `packages/warp_prism_ui` molecule layer only. Extends
  `DSStateSurface` modes; does not duplicate them. Toast is not a job: no
  toast-path changes in this task (toast policy is Task 1867).
- **Constraints**: `warp_prism_ui` MUST NOT import FRB, runtime, bindings, or
  any adapter (layer-contracts §1 row 1, §4). No consumer domain types in core
  (§4.5 leakage rule). Fail-closed states: unknown must never render as
  success/disabled styling (backlog F-10 gate). Determinism: indeterminate
  progress excluded from golden capture. a11y: progress semantics + cancel
  reason announced, not colour-only.
- **Non-goals**: no `AsyncJobExecutor` (Task 1859); no decision-review surface
  (P0 F-04); no loading-chrome consolidation beyond the banner's own modes;
  no STABLE/barrel promotion in this task.

## Context / reliance

- Inherits P0 F-02 honest-unknown vocabulary read-only; if F-02 `DSStateType`
  members are absent, fall back to local neutral styling and record the gap —
  do not relitigate F-02 here.
- Source evidence: backlog F-10 card (S5: WB-U4 banner half + TP-U07
  `ProgressCard` + CC W3-B companion + Macro P1-5/C6); macro-review C6
  (job-banner CANDIDATE + loading GOLD rationale `integration/loading.dart:3-11`
  non-animated determinism).
- MISSION §3.1 + §11.4: mandate-covered absorption; recurrence never gates.
  Layer law: `.project/architecture/layer-contracts.md` §§1, 4, 10.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Extend | Existing modes the banner composes; read before mutation |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` | Negative boundary | Read to prove toast/job separation; do not mutate |
| `packages/warp_prism_ui/lib/src/molecules/ds_provenance_pill.dart` | Reference | Receipt-slot adjacency pattern only |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read-only | Alias completeness guard; no export added (EXPERIMENTAL) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness, 16 checks |
| `packages/warp_prism_testkit/lib/src/` | Suite home | Fake + conformance suite for banner model |
| `apps/catalog/lib/` | Proof lab | Gallery/demo entry for the banner (EXPERIMENTAL section) |

## Work / responsibility

- [ ] Read `ds_state_surface.dart`, toast pair, and testkit fake/suite
  conventions before mutation.
- [ ] Specify the banner model (stages, cancel, terminal receipt slot,
  fail-closed unknown mapping) as pure presentation input; no backend logic.
- [ ] Implement `PrismJobBanner` molecule + fake model + conformance suite
  (staged progress, cancel semantics, receipt-slot determinism, fail-closed
  states, a11y announcements).
- [ ] Add deterministic golden at fixed stage values; prove indeterminate
  spinner is excluded from golden capture.
- [ ] Register gallery/demo entry under the EXPERIMENTAL section; no barrel
  export, no `DS*` leak.
- [ ] Run full validation below; record results and limits in the task.

## Success and verification

- Fake + conformance suite green; fail-closed test asserts unknown ≠ success
  ≠ disabled styling, in semantics label and styling.
- Cancel path tested (cancel offered only when cancellable; cancel reason
  propagated to semantics).
- Host proof: Tempest `ProgressCard` site + Command-center loading-trio site
  composed with the banner in host exercise — interact, no framework errors /
  `ErrorWidget` / `RenderFlex` overflow, theme/focus intact (AGENTS.md §7.1).
- MISSION §6 gates for this task: item 1 (mandate coverage + recorded
  macro-review C6 decision — cite this task), items 2–4 (fake + conformance +
  boundary clearance), item 5 (host proof), item 7 (independent review).
  Item 6 n/a (no FRB boundary crossed).
- `dart format`, analyze, boundary harness, barrel check all clean.

**Validation commands** (run from repo root unless noted):

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_testkit/lib
flutter analyze packages/warp_prism_ui packages/warp_prism_testkit
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_testkit
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here on completion: suite outputs, golden paths, host-exercise
  evidence (host, route, interaction, framework-error absence), review verdict.
- Partial results stay explicit; missing host proof blocks STABLE, never
  EXPERIMENTAL landing.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_1971f228e001IAHn0uJ3qGHnRT`, resumed same session `ses_e68e0dcc1ffewSk4tdV5Rr33hN` twice (`continue`, then text-only handoff extract). Handoff `status: complete` recovered from session transcript (978KB export path not re-pulled here; packet content verified against disk below).
- **Filesystem check**: new `ds_job_banner.dart` + 18-test suite + host-composition + golden tests + 5 PNGs + testkit fake/contract + suite consumer present; additive edits only (testkit barrels +2 export lines, gallery sections/registry +1 section/entry, gallery test count 24→25, boundary +4 `banner_1858_*`); 1860's filter/data-table/virtual-scroll/chip files untouched; `ds_state_surface.dart` unmutated (8-value enum preserved); no barrel/alias exports.
- **Parent re-run (fresh, after return, with 1860 still active in tree)**: `dart format` on 6 touched paths → 0 changed exit 0; banner suites (widget + host + golden) → **25/25 pass exit 0**; pure-dart boundary harness → **57/57 PASS exit 0** (4 banner checks green).
- **Not re-run by parent**: testkit 103/103 + gallery 22/22 + catalog widget 10/10 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: whitelist-format whitespace collateral in 5–7 pre-existing files (semantic no-op; reconcile with Task 1860 owner if needed); full-suite 64 reds attributed (62 environmental golden pixel-drifts + 2 in-flight 1860 host failures, zero in banner paths); donor re-verification INHERITED-REPORT + real-host substituted with headless sweep (exact limitations recorded by worker).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e5192d661ffemQV2UbY0p7uCQN` (independent — did not build). Report: `.project/reports/reviewers/1858-warp-prism-job-banner-receipt-review-loop.md` (new file).
- **Verdict**: PASS (90/100 diagnostic). No remediation.
- **Accepted evidence**: banner trio 25/25 + testkit fake 19/19; format 0-changed; analyze seam clean; boundary 81/81 (4/4 banner checks); gallery 22/22 (shared, attributed); EXPERIMENTAL containment; fail-closed unknown; cancel requires reason; no await/unmounted hazard.
- **Residual (non-blocking)**: real Tempest/CC host proof owed before STABLE; recorded, not a verdict blocker at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

**Parallelizable with**: Task 1860 (filter builder, disjoint owner), Task 1861
(meter/fader, disjoint owner). Shares no writeset with either.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 90/100; banner trio 25/25, fake 19/19, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1858-warp-prism-job-banner-receipt-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
