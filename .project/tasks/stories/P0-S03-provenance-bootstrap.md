---
epic_id: EPIC-P0-trust-core
story_id: P0-S03
title: "Provenance family + bootstrap landings"
status: active
task_ids: [1872, 1876]
---

# Story P0-S03: Provenance Family + Bootstrap Landings

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md)
> **Home**: `.project/tasks/stories/P0-S03-provenance-bootstrap.md` (non-lane)
> **Source**: backlog seams S8 (provenance+lineage) + S4-landings (startup/loading); F-05 (I=80) + F-09 (I=48).

## Objective

Provenance becomes a witnessed, sealed-honest presentation family (canonicity + opaque-hash witness + lineage strip), and bootstrap/loading becomes a converged fail-closed landing (startup-failure view + `DSStateSurface` modes). Both are the cheapest trust-critical presentation work in P0: small surfaces, high deception risk if wrong.

## Scope

### In scope

- `PrismProvenanceBadge` + `PrismWitnessBadge` atoms + sealed-rendering-mode contract + `PrismLineageStrip` molecule; no hashing in Prism (Task 1872).
- `PrismStartupFailureView` + loading-chrome convergence onto `DSStateSurface`; leak-negative (no stack-trace render) coverage (Task 1876).
- Determinism: indeterminate/progress states excluded from goldens; GOLD non-animated rationale preserved.

### Out of scope

- Fingerprint/hash computation, receipt signing, causation grouping — consumer-side, opaque to Prism.
- Daemon bootstrap/orchestration fixes — product-local (WB `AssurancePanel` reachability is a product-owner fix, surfaced not owned).

## Tasks (canonical)

- Task 1872
- Task 1876

Frontmatter `task_ids` matches this list.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1872 | Provenance family + sealed mode + lineage strip (F-05) | [1872](../01-open/1872-warp-prism-provenance-witness-lineage.md) |
| 1876 | Startup-failure view + loading-chrome convergence (F-09) | [1876](../01-open/1876-warp-prism-startup-failure-loading-convergence.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] Both tasks closed with independent review; unverified-never-verified and sealed-absence-of-affordance proven by suite.
- [ ] Host proof CC + WB for both (backlog gates).
- [ ] No STABLE/barrel promotion — both land EXPERIMENTAL.
