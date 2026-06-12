# EPIC 12 — Warp-Prism Test Suite Stabilization and Promotion Gates

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after baseline failure inventory and promotion state model exist.
> **Origin**: Stabilization wave — analysis of 95 test failures, absence of promotion semantics,
>   and gap between "builder done" and "promotion proof" across the monorepo.
> **Depends on**: EPIC 00, EPIC 01, EPIC 03 (existing baseline).

## Goal

Transform the Warp Prism test suite from a collection of tests into a **governance system**
that deterministically distinguishes local proof, package proof, consumer proof, and promotion
proof. Eliminate the false binary where `[x] Done` means "builder ran a local test" and the
global gate remains red.

## Source Evidence

- Melos migration (Task 1107) registered `warp_prism_ui: 757 pass / 31 fail` and
  `warp_prism_observatory: 589 pass / 64 fail` as pre-existing.
- `apps/catalog`: 1 pass / 0 fail — smoke-only, near-irrelevant as gate.
- `apps/cybercore`: 12 pass / 0 fail — 10 model tests + 2 widget smoke tests.
- Task completion evidence across Wave 4 repeatedly shows: "local pass, package/global fail,
  still marked done."
- No `test-cybercore` Melos script exists despite `apps/cybercore/` being a first-class
  consumer pilot.
- No boundary tests exist for `DS*` vs `Prism*`, `src/` imports, or ADS dependency purity.
- `pre-existing failure` is used as an unclassified catch-all that blocks promotion analysis.

## Scope

- Failure baseline inventory with taxonomy (regression, stale, broken compile, contract drift,
  async/flaky, semantics drift, missing fixture).
- Formal promotion state model replacing the current ambiguous `[x] Done` in tasks.
- Gate matrix defining which gates each task type must pass.
- Melos script normalization (`test-cybercore`, `test-boundaries`, `test-fast`).
- Boundary test harness enforcing package purity and namespace rules.
- Pre-existing failure policy distinguishing "legitimate pre-existing" from "related pre-existing
  that blocks promotion."
- Review packet generator to economize reviewer quota.

## Out of Scope

- Fixing the actual test failures (that is EPIC-13 and EPIC-14).
- New product features, new ADS components, CyberCore expansion.
- Golden test creation (that is EPIC-13 task 1305).
- Live API or runtime mutation.

## Candidate Tasks

| Task | Name | Type |
|------|------|------|
| 1201 | Test Failure Baseline Inventory | governance |
| 1202 | Promotion State Model Definition | governance |
| 1203 | Test Gate Matrix per Task Type | governance |
| 1204 | Melos Test Script Normalization | housekeeping |
| 1205 | Boundary Test Harness | testing |
| 1206 | Pre-existing Failure Classification Policy | governance |
| 1207 | Review Packet Generator | governance |
| 1208 | Existing Task Lane Reconciliation and Review Backlog Snapshot | governance |

## Dependencies

- Depends on EPIC 00 for compile baseline awareness.
- EPIC-13 and EPIC-14 consume the gate model defined here.
- 1201 (inventory) should complete before 1203 (gate matrix) and before EPIC-13/14 tasks
  that fix specific failure classes.
- 1208 (lane reconciliation) depends on 1202 (promotion state model) and 1201 (failure
  inventory). It should complete early so existing tasks are classified before review waves.

## Acceptance Criteria for Epic Completion

- Every task failure in the monorepo is classified in a taxonomy document.
- The promotion state model is defined as a governance rule and referenced by task templates.
- The gate matrix specifies required gates for each task type (docs-only, ADS component, app
  route, parser/data layer, monorepo migration, CyberCore fixture, performance-sensitive).
- `melos run test-boundaries` exists and passes (enforcing package purity).
- The pre-existing failure policy is documented and prevents unclassified "pre-existing" from
  blocking promotion analysis.
- Review packets are a defined format that a reviewer (human or automated) can consume without
  re-running all commands.

## Why This Epic Is Mandatory Now

The project has 95 test failures accepted as "pre-existing" and 79 tasks stuck in `02-doing/`
with no clear distinction between builder-done and promotion-ready. Without this epic, every
subsequent task risks the same pattern: local pass, global fail, status ambiguous. This epic
does not fix code; it fixes the **governance layer** that determines when code is trustworthy.
