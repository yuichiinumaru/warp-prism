# Build-Gate Review: 1206 — Pre-existing Failure Classification Policy

**Date**: 2026-06-11
**Reviewer**: gt-build-review workflow
**Task file**: docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md

## Score: 78/100 — Good

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `cat .agents/rules/pre-existing-failure-policy.md` | FAIL | Required validation command fails because `.agents/rules/pre-existing-failure-policy.md` does not exist. |
| `grep "pre-existing" .agents/rules/promotion-state-model.md` | PASS | Source rule references the governance policy in Rule 2, the Failure Taxonomy row, and Reference section. |
| `test -f docs/governance/pre-existing-failure-policy.md` | PASS | Implemented policy document exists. |
| `test -f docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md` | PASS | Local changelog entry exists. |
| `test -f docs/reports/warp-prism-failure-baseline-inventory.md` | FAIL | Where table names this inventory file, but it does not exist. The implementation used `docs/reports/warp-prism-test-failure-baseline.md` instead. |
| Policy content check | PASS | Policy includes unrelated/related/caused classes, decision tree, promotion rules, evidence requirements, reviewer checklist, anti-gaming rules, and baseline reference. |
| `.agents/rules/promotion-state-model.md` policy-reference check | PASS | Contains 3 references to `docs/governance/pre-existing-failure-policy.md`. |
| `docs/governance/promotion-state-model.md` policy-reference check | FAIL | Canonical governance document does not reference `pre-existing-failure-policy.md`, leaving docs/rules governance surfaces inconsistent. |
| Flutter/Dart gates | N/A | Governance/docs task; no Dart/Flutter source was changed by Task 1206. |

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | N/A | Governance-only task; no widget/controller code changed. |
| 2 | Provider Scoping | N/A | Governance-only task; no Riverpod/provider code changed. |
| 3 | Const Constructors | N/A | Governance-only task; no widget constructors changed. |
| 4 | Semantic Labels | N/A | Governance-only task; no interactive UI changed. |
| 5 | Type Safety | N/A | Governance-only task; no Dart runtime code changed. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | ✅ | Policy/governance docs only; no backend writes, runtime mutation, or live service dependency introduced. |
| DS*/Prism* boundary | N/A | No design-system/API boundary code changed. |
| Mock workspace fixtures | N/A | No fixture/data-layer code changed. |
| Melos package boundary | N/A | No package imports changed. |
| Operational state vocabulary | N/A | No operational-state widgets changed. |
| Design token usage | N/A | No UI styling changed. |
| Gallery coverage | N/A | No DS component added. |
| Test coverage | N/A | Governance policy task; validation is document existence/content/reference checks. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | A policy document exists at `docs/governance/pre-existing-failure-policy.md`. | ✅ | File exists and was read. |
| 2 | The policy defines classification criteria, promotion rules, reviewer checklist. | ✅ | `docs/governance/pre-existing-failure-policy.md:17-52` defines classes and decision tree; `:55-87` defines promotion rules; `:134-156` defines reviewer checklist. |
| 3 | `.agents/rules/promotion-state-model.md` references the policy. | ✅ | `.agents/rules/promotion-state-model.md:33-37`, `:71`, `:78`. |
| 4 | Local changelog entry added under `docs/changelog/`. | ✅ | `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md` exists. |
| 5 | Completion Evidence is filled before review handoff. | ✅/⚠️ | Completion Evidence exists at `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:131-143`, but it omits the missing `.agents/rules/pre-existing-failure-policy.md` validation failure and claims only the implemented docs path. |

## Findings

### Critical

- None.

### High

- [HIGH] Required policy file from the task contract and validation commands is missing. The Where table requires creating `.agents/rules/pre-existing-failure-policy.md` (`docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:88-91`), and the Validation Commands require `cat .agents/rules/pre-existing-failure-policy.md` (`:122-127`). That command fails with `No such file or directory`. The implemented policy at `docs/governance/pre-existing-failure-policy.md` also claims a source rule mirror exists (`docs/governance/pre-existing-failure-policy.md:3-5`), but the mirror is absent.

### Medium

- [MEDIUM] Governance surfaces are inconsistent: `.agents/rules/promotion-state-model.md` references the policy, but the canonical governance document `docs/governance/promotion-state-model.md` still contains the older generic rule and no link to `pre-existing-failure-policy.md` (`docs/governance/promotion-state-model.md:251-282`). This weakens the policy's authority because `docs/governance/promotion-state-model.md:3-5` declares itself the canonical governance reference.
- [MEDIUM] The named baseline inventory in the Where table is missing. The task says to read `docs/reports/warp-prism-failure-baseline-inventory.md` (`docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:88-93`), but that file does not exist. The delivered policy correctly references the actual baseline file `docs/reports/warp-prism-test-failure-baseline.md`; the task contract and evidence were not reconciled.
- [MEDIUM] Completion evidence and changelog overstate validation completeness. The task evidence records only `test -f docs/governance/pre-existing-failure-policy.md` and `grep "pre-existing" .agents/rules/promotion-state-model.md` as passing (`docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:137-139`), while the task's own validation command `cat .agents/rules/pre-existing-failure-policy.md` fails. The changelog similarly records only the docs-path validation (`docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md:29-33`).

### Low

- [LOW] Task status metadata is stale/mismatched for review handoff: status remains `[ ] Open` while the file is in `02-doing/` and has builder completion evidence (`docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:3-4`, `:131-143`).
- [LOW] The policy is substantively useful but somewhat longer than the "2 minutes" guardrail (`docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md:116-118`): 202 lines. This is not a blocker because the decision matrix and checklist are actionable, but it should be tightened during correction if a mirror/source rule is created.

## Patches Applied

- None. Score is below 90, so gt-build-review rules prohibit reviewer patching.

## Verdict

REJECTED → stays in `docs/tasks/02-doing/`.

## Path to 100

1. Create or correctly relocate the required `.agents/rules/pre-existing-failure-policy.md` surface, or formally update the task contract through governance so the canonical location is only `docs/governance/pre-existing-failure-policy.md`. The policy's own source-rule claim must match repository reality.
2. Reconcile `docs/governance/promotion-state-model.md` with `.agents/rules/promotion-state-model.md` so both canonical/rule surfaces reference the pre-existing failure policy consistently.
3. Reconcile the missing inventory filename: either create/rename `docs/reports/warp-prism-failure-baseline-inventory.md` as the contract says, or update the task contract/evidence to use `docs/reports/warp-prism-test-failure-baseline.md` everywhere.
4. Re-run and record the exact validation commands from the task body, including `cat .agents/rules/pre-existing-failure-policy.md` and `grep "pre-existing" .agents/rules/promotion-state-model.md`.
5. Update task status/review-state metadata and completion evidence so lane state, validation commands, and delivered paths agree.
