---
epic_id: EPIC-P1
story_id: P1-S03
title: "Convergence sweeps + graph/health proofs + composer + harness"
status: active
task_ids: [1882, 1883, 1884, 1866, 1867]
---

# Story P1-S03: Convergence Sweeps + Graph/Health Proofs + Composer + Harness

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P1](../epics/EPIC-P1-compound.md)
> **Home**: `.project/tasks/stories/P1-S03-convergence-proofs-harness.md` (non-lane)
> **Template**: `.project/tasks/templates/story.md`

---

## Objective

Prove the mandate by convergence, not construction: token+shell sweep (F-15),
session/panel/screen sweep (F-16), DAG-gated Graph/Health first-host proofs
(F-17), EXPERIMENTAL composer (F-18), and the harness upgrades that de-risk
the whole wave (F-19: layer-table compaction, two-tier capture, drain/cancel,
junk sweeps, toast policy).

## Scope

### In scope

- F-15: map 47 Tempest tokens onto `PrismTokenRegistry`; converge
  `MainShellLayout` onto `DSShell`/`DDSidebar`; verify (don't reinvent)
  Command-center theme baseline.
- F-16: compose SessionList/Detail, EventStreamView, Project/Media panels,
  Tempest Library/Models/Providers/Settings/Separate/Create screens,
  DropZoneCard onto existing atoms/molecules/organisms. Host-proof is the work.
- F-17: fake + conformance for `GraphSource` real-consumer proof and
  `HealthSource` cost/quota + provider-matrix axis; `DSGraphCanvas` input
  extension with caller-supplied kinds; `PrismLineageStrip` for SAME|DIFFER.
  DAG-gated: HOLD until a real DAG host exists.
- F-18: organism `PrismComposer` EXPERIMENTAL (autogrow/@mentions/emoji/
  format/attachment lifecycle/parked drafts); promotes on second-host adoption.
- F-19: (a) layer-table compaction to generated table + generic upward rule;
  (b) two-tier capture + frame-boundary drain + cooperative-cancel placement;
  (c) standing junk/adversarial sweep on every IDS/runtime suite +
  mechanism-mirrored filenames + stable test-id convention; (d) toast policy
  (cap/sticky/action/hand-back/onDismiss-only-on-close) in `PrismToastManager`.

### Out of scope

- Presence overlay (P2 F-24, gated HOLD); surface host + data-plane satellite
  (P2 F-25); Sentry views (P2 F-26/F-27); ribbon/matrix/form/energy P2 items.
- Credentials, persistence, daemon orchestration, DAW state/controllers.
- Donor-only STABLE widgets; flag-day migration (convergence is directional
  per bridge contract §4).

## Tasks (canonical)

**IDs only.** Never write mutable lane paths here.

- Task 1882
- Task 1883
- Task 1884
- Task 1866
- Task 1867

Frontmatter `task_ids` should match this list when both are used.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1882 | Token and shell convergence sweep onto Prism primitives | [1882](../01-open/1882-warp-prism-token-shell-convergence.md) |
| 1883 | Session/panel/screen convergence onto existing Prism compositions | [1883](../01-open/1883-warp-prism-session-panel-convergence.md) |
| 1884 | Graph/Health first-host proofs, DAG-gated (no host means HOLD with evidence) | [1884](../01-open/1884-warp-prism-graph-health-first-host-proofs.md) |
| 1866 | PrismComposer organism EXPERIMENTAL (autogrow, mentions, attachments, drafts) | [1866](../01-open/1866-warp-prism-composer-experimental.md) |
| 1867 | Harness upgrades — layer-table compaction, two-tier capture, drain/cancel, junk sweeps, toast policy | [1867](../01-open/1867-warp-prism-harness-upgrades-capture-nets-toast.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] All listed tasks through review/completed as required by the program
- [ ] Scope frozen or explicit successor story linked
- [ ] Real-host exercise evidence per AGENTS.md §7.1 for every affected host
  (interact, no framework errors / ErrorWidget / RenderFlex overflow,
  theme/focus intact)
- [ ] F-17 either host-proven against a real DAG or recorded HOLD with the
  blocking premise intact; F-19 lands with all existing suites still green
