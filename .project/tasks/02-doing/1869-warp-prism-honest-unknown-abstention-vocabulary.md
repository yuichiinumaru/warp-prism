# Task 1869: Honest-unknown + abstention vocabulary, fail-closed rendering (F-02)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S01](../stories/P0-S01-authority-vocabulary.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-02 (I=125, seam S4-core) — WB-U4, TP U-07, CC W1-B/I-2, Macro P0-2/C6.
> **Priority**: P0 · **Parallelizable with**: Task 1868, Task 1875 (disjoint writesets: state vocabulary vs gate vs transport).

Live gap, statically confirmed: `DSStateType` has no unknown; `DSMessageStatusHistory` step state likewise. WB carries three duplicated inline error blocks; CC carries the GOLD loading trio. Rendering unknown as success/disabled is worse than a missing widget — this task makes indeterminacy a first-class, fail-closed vocabulary.

## Outcome and boundaries

Extend `DSStateType` (`ds_state_surface.dart:294-315`) with `unknown`, extend IDS inspection/query with `unknown` + `abstained/notAttempted`, and establish the fail-closed rule (unknown ⇒ never renders as success/enabled/verified; indeterminate states excluded from goldens). Converge the duplicated inline error blocks onto the converged vocabulary. Lands EXPERIMENTAL — no barrel export.

Non-goals: startup-failure view and loading-chrome convergence landings (Task 1876, consumes this vocabulary); job banners (P1 F-10); no STABLE promotion here.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | `DSStateType` enum (`:294`) + surface rendering — extension site |
| `packages/warp_prism_interaction/lib/src/inspection/inspection_state.dart` | Inspection `unknown` state home |
| `packages/warp_prism_interaction/lib/src/query/query_state.dart` | Query `unknown`/`abstained` state home |
| `packages/warp_prism_ui/lib/src/tokens/` | Token support for unknown rendering (non-animated determinism per GOLD rationale) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check for any new contract surface, same task |
| `docs/bridge/command-center/prism-gap-components.md` | GOLD loading trio donor — re-verify live, INHERITED-REPORT until read |

## Work

- [ ] Re-verify the `DSStateType` gap live (read `:294-315` plus `DSMessageStatusHistory` step state) and record the exact pre-change enumeration.
- [ ] Extend `DSStateType` + IDS inspection/query states; fail-closed conformance suite: every unknown input ⇒ unknown/abstained render, and a failing-first test proving unknown≠success, unknown≠verified, unknown≠enabled.
- [ ] Converge WB's three duplicated inline error blocks onto the vocabulary (mechanical, weakest-evidence area — host proof is the work).
- [ ] Determinism: indeterminate states excluded from golden capture; a11y announcements for unknown/abstained.
- [ ] `dart format` + `flutter analyze` clean; boundary harness green.
- [ ] Host proof: CC (GOLD trio route) + WB banner sites, real-host exercise per AGENTS §7.1.

## Success and verification

Success = unknown/abstained vocabulary exists in ADS+IDS, fail-closed rule is suite-proven (unknown can never render as success), determinism exclusions hold, MISSION §6 gates (2) fake/reference, (3) conformance green, (4) boundary clearance, (5) host proof CC+WB, (7) independent review. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/molecules packages/warp_prism_interaction/lib/src/inspection packages/warp_prism_interaction/lib/src/query
flutter analyze packages/warp_prism_ui packages/warp_prism_interaction
flutter test packages/warp_prism_interaction/test packages/warp_prism_ui/test/molecules packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites including the failing-first unknown≠success tests, boundary green, host logs for both hosts, reviewer verdict.

## Context / reliance

Depends on nothing (foundation task). Feed-out: Task 1876 (startup/loading landings) waits on this vocabulary; Task 1871's pass-through invariant (unknown≠pass) consumes it. Construction on downstream tasks may proceed on this task's frozen interface; integration waits for functioning implementation.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196c9bcc1001txpOoB9QpALRG1`, resumed same opencode session `ses_e69364281ffenYtKo01t2tRqPq` with exactly `continue` (`sh_196e12b7c0015PUemL675JPvqm`) after launcher timeout 124 cut the first run mid golden-triage with no handoff. Final handoff `status: complete` received on resume; full packet in shell outputs (not copied here).
- **Filesystem check**: implementation present (query/inspection vocab, `DSStateType.unknown` wired, 2 new test files, 5 `honest_unknown_*` boundary checks appended after 1868's entry, 1868's files untouched). `packages/warp_prism_interaction/lib/src/input/` never touched (collision guard honored).
- **Parent re-run (fresh, after return)**: `dart format --set-exit-if-changed` on touched dirs → 0 changed exit 0; task-exact `flutter test interaction/test + ui/test/molecules + boundary_test.dart` → **561 pass exit 0** (matches worker claim); pure-dart boundary harness → **22/22 PASS exit 0**.
- **Not re-run by parent**: golden pixel suite (environmental 99%+ diffs on untouched widgets, pre-existing per Tasks 1805/1846; worker-guarded by new golden-exclusion tests, also green here via boundary + conformance).
- **Known residuals**: real-host WB/CC proof substituted with catalog + cybercore in-tree hosts (sibling repos outside workspace boundary; exact limitation recorded by worker); golden-run `failures/` artifact dirs left in place (`rm` permission-denied for worker and parent alike; regenerable test output, boundary scratch check green).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51da4820ffebdCKhZVV4JlJNR` (independent — did not build). Report: `.project/reports/reviewers/20261106-000803-review-task-1869-honest-unknown-abstention-vocabulary.md`.
- **Verdict**: AMEND (84/100 diagnostic). No code defect assigned; no implementation amendment requested.
- **Accepted package evidence**: format 48 files 0-changed; task-exact suites 729 pass; focused analyzer on touched paths clean; golden-exclusion holds; EXPERIMENTAL containment (no new barrel/alias exports); shared boundary run 81/81 PASS (reviewer-executed, current tree).
- **Blockers (no builder remediation requested)**:
  - B1 (external): task-required real CC GOLD-trio route + WB banner-site host proof unavailable — named hosts outside the workspace boundary; in-tree/headless evidence explicitly not treated as named-host proof.
  - B2 (baseline owner): literal full-package `flutter analyze` exits non-zero on the pre-existing 226-issue baseline; focused touched-path analysis is clean and no diagnostic is assigned to this task. Disposition belongs to the analyzer-baseline owner.
- **Lane**: stays in `02-doing/` pending B1/B2 disposition or an authorized acceptance decision. No promotion claimed.

## Gate update — 2026-11-06

- B2's literal gate is now green: package-wide `dart analyze` exits 0 (225 infos, 0 warnings/errors) after the 1860 import fix. B2 collapses to a non-blocking baseline-hygiene note for the baseline owner. B1 (external CC/WB host proof) is the sole remaining acceptance item.
