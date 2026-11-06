---
date: 20261011-154708
timestamp: 20261011-154708
project: "warp-prism"
agent: "flutter-dart-builder"
task: "rem-0004-architecture-doc-drift-corrections"
description: "Docs-only remediation of four architecture-doc drift sites so readers deciding from these files decide correctly. (1) layer-contracts.md §2 dependency-direction diagram drew a downward arrow from the ui/interaction bracket into warp_prism_bindings, inverting the law; corrected to bindings→ui with a §1 cross-reference note that preserves the superseded wording. (2) package-topology.md §3.2 rule 9 asserted a blanket ui-MUST-NOT-import-interaction ban, contradicting the dev-only carve-out in layer-contracts.md §1 row 1 / §2 and the actual dev_dependencies in warp_prism_ui/pubspec.yaml; original rule text preserved verbatim alongside the carve-out. (3) runtime-consumer-audit.md cited layer-contracts-v2.md as governing in nine places; each citation annotated with its current owner (v2 §2 -> §1 matrix, §3.2 -> §9 lifecycle, §4.3 -> §7 model separation, §5 -> §10 checks) plus a 'law baseline updated 2026-10-11' note; v2 citations retained as historical provenance. (4) cross-consumer-gap-matrix.md: the Tempest 'UNKNOWN (import scan denied)' and Sentry 'UNKNOWN' rows in §2, the two matching rows in §6 Missing Proofs, and the stale '0 deps (UNKNOWN)' cell in §3 row 28 are all updated to the verified answers, each naming its verification method and date (parent-verified 2026-10-10); the 2026-09-27 date and AMEND acceptance history are preserved, with resolution notes appended rather than deleting rows."
is_rebuild_safe: true
---

# Task rem-0004-architecture-doc-drift-corrections: remediation-executed

## Summary

Four architecture docs corrected for drift: inverted ui<->bindings dependency arrow (layer-contracts.md §2), over-strict interaction ban (package-topology.md:93), nine superseded layer-contracts-v2 citations (runtime-consumer-audit.md), and two resolved UNKNOWN rows plus stale adoption row (cross-consumer-gap-matrix.md). MISSION.md protected: read-only, evidence recorded in task file. All corrections annotate history rather than deleting it.

## Changes

- Documented task completion details.

## Verification

- [x] Re-read layer-contracts.md §2 immediately before editing (rem-0001 drift guard; §10 16-row table intact)
- [x] Finding 1 verified against six pubspecs: ui declares no bindings dep; bindings deps on ui+interaction+runtime
- [x] Finding 2 verified: warp_prism_ui/pubspec.yaml lists warp_prism_interaction under dev_dependencies only (lines 14-19)
- [x] Finding 3 verified: 9 of 9 layer-contracts-v2 citation sites in runtime-consumer-audit.md repointed or annotated (rg)
- [x] Finding 4 evidence: parent-verified 2026-10-10 resolutions carried by .project/reports/architects/future-capability-program-inventory-2026-10-10.md §0.1/§2
- [x] No source/test/config touched; no lane moves; MISSION.md unmodified
- [x] OUT-OF-WRITESET SIDE EFFECT (disclosed): the changelog engine's `closeout` action internally rebuilt root CHANGELOG.md + CHANGELOG-FULL.md + .project/changelog/index.md + .project/changelog/views/*.md. `action=build` was NOT invoked. The engine archived the prior root CHANGELOG.md to .archive/changelog/CHANGELOG-before-rebuild-20261011-154708.md, so the change is recoverable; root-file review is recommended.
