---
epic_id: EPIC-P1
story_id: P1-S01
title: "Jobs + runtime executor and stream/health bindings"
status: active
task_ids: [1858, 1859]
---

# Story P1-S01: Jobs + Runtime Executor and Stream/Health Bindings

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [EPIC-P1](../epics/EPIC-P1-compound.md)
> **Home**: `.project/tasks/stories/P1-S01-jobs-runtime.md` (non-lane)
> **Template**: `.project/tasks/templates/story.md`

---

## Objective

Deliver the P1 job-presentation primitive (`PrismJobBanner`, F-10) and the P1
runtime spine (`AsyncJobExecutor` + terminality/refusal standard + EventStream /
HealthSource bindings, F-11) so long-running work has one honest banner
vocabulary and one per-execution runtime identity, each proven by fake +
conformance + host/binding evidence.

## Scope

### In scope

- F-10: ADS molecule `PrismJobBanner` (staged + cancel + deterministic
  terminal receipt slot; receipt content stays consumer-side).
- F-11: runtime `AsyncJobExecutor` concept (per-execution identity;
  single-flight `AsyncCommand` untouched), terminality/refusal-disclosure
  standardisation, `EventStream`/`HealthSource` bridge-badge → real-projection
  bindings.
- Shared evidence: fail-closed states, determinism (no animation-dependent
  capture), cancel semantics, per-execution identity, refusal-prefix verbatim
  invariant, health snapshot test.

### Out of scope

- Toast policy mechanics (owned by Task 1867 / F-19).
- Decision-review surface (P0 F-04); shell router (P0 F-06); new runtime
  contracts (none — F-11 adds no contract except the executor concept).
- Product orchestration, generation routing, daemon wiring.

## Tasks (canonical)

**IDs only.** Never write mutable lane paths here.

- Task 1858
- Task 1859

Frontmatter `task_ids` should match this list when both are used.

## Path projection (generated)

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| 1858 | PrismJobBanner molecule with staged progress, cancel, and terminal receipt | [1858](../01-open/1858-warp-prism-job-banner-receipt.md) |
| 1859 | AsyncJobExecutor identity plus terminality standard and EventStream/HealthSource bindings | [1859](../01-open/1859-warp-prism-async-job-executor-bindings.md) |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] All listed tasks through review/completed as required by the program
- [ ] Scope frozen or explicit successor story linked
- [ ] `PrismJobBanner` host-proven in Tempest (`ProgressCard` site) +
  Command-center (loading trio site) without framework/runtime errors
- [ ] Executor + bindings pass the same suite for fake and adapter; health
  snapshot test green; `AsyncCommand` single-flight semantics unchanged
