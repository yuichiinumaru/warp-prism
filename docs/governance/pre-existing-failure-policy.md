# Pre-existing Failure Classification Policy

> **Authority**: Canonical governance reference for pre-existing failure handling.
> **Source rule**: `.agents/rules/pre-existing-failure-policy.md` (builder source rule)
> **Scope**: All executable tasks under `.project/tasks/`.
> **Created**: 2026-06-09
> **Task origin**: Task 1206
> **Supersedes**: All prior uses of "pre-existing" as unclassified promotion bypass.

This policy defines when a test failure is pre-existing, how to classify it,
and what that classification means for task promotion. It exists because
"pre-existing failure" was the most dangerous phrase in the project: it allowed
tasks to be marked complete while the test gate was red.

---

## 1. Failure Classes

Every test failure encountered during task execution must be classified into
one of three classes. No failure may remain unclassified.

| Class | Definition | Example |
|-------|-----------|---------|
| **Pre-existing (unrelated)** | The failure existed before the task's changes. The task did not touch the failing file, module, or contract. | Task 1116 (toast) encounters gallery compile errors from Tasks 1112/1114 that predate it. |
| **Pre-existing (related)** | The failure existed before the task, but the task modified code in the same file, module, or contract boundary as the failure. | Task 1118 (state vocabulary) changes `DSStateSurface` while `state_surface_test.dart` already had a stale state-count assertion. |
| **Regression (caused)** | The failure did not exist before the task. The task introduced it. | Task 1106 (operational component MVP) changed `DSStatusDot` constructors, breaking 8 molecules contract tests that previously passed. |

---

## 2. Classification Decision Tree

Use this checklist to classify a failure. Stop at the first match.

1. **Did the failure exist before the task's changes?**
   - Run the test suite **before** modifying any code. Record results as the baseline.
   - If the failure was already present: go to step 2.
   - If the failure was NOT present: **Regression (caused)**. Stop.

2. **Did the task modify any file in the failing test's dependency chain?**
   - Check the failing test file, the source file(s) it tests, and any barrel
     exports between them.
   - If the task touched any file in that chain: **Pre-existing (related)**. Stop.
   - If the task touched nothing in that chain: **Pre-existing (unrelated)**. Stop.

### Quick-Reference Matrix

| Failure in baseline? | Task touched failing area? | Classification | Blocks promotion? |
|:--------------------:|:--------------------------:|----------------|:-----------------:|
| No | *(any)* | Regression (caused) | **Yes, always** |
| Yes | Yes | Pre-existing (related) | **Yes, until resolved or justified** |
| Yes | No | Pre-existing (unrelated) | **No** |

---

## 3. Promotion Rules

### 3.1 Regression (caused)

**Always blocks promotion.** The task must fix the regression before declaring
Builder Done. No exceptions. No reviewer override. The gate must be green.

**If the builder cannot fix it**: the task must move to Blocked with a
documented explanation of what external dependency prevents the fix.

### 3.2 Pre-existing (related)

**Blocks promotion until one of these conditions is met:**

1. The failure is fixed as part of the task.
2. A follow-up task exists in `01-open/` that explicitly owns the failure, and
   the reviewer approves the deferral with written justification in the task's
   completion evidence.

**Reviewer sign-off is mandatory.** The reviewer must confirm:
- The classification is correct (the failure is truly pre-existing, not caused).
- The follow-up task is concrete and tracked.
- The deferral does not leave an interactive or accessibility component broken.

### 3.3 Pre-existing (unrelated)

**Does not block promotion of THIS task**, subject to two obligations:

1. The failure must be classified in the baseline inventory
   (`docs/reports/warp-prism-test-failure-baseline.md`) or its successor.
2. The task's completion evidence must cite the failure count and confirm zero
   regressions introduced by the task.

---

## 4. Evidence Requirements

### 4.1 How to prove a failure is pre-existing

| Evidence type | How to obtain | When required |
|---------------|--------------|---------------|
| **Baseline comparison** | Run `flutter test` before and after task changes. Compare failure lists. Failures present in both runs are pre-existing. | Always (this is the primary evidence). |
| **Git blame / git log** | `git log --oneline <failing-file>` to confirm the failure predates the task's commits. | When baseline comparison is ambiguous (e.g., flaky tests, intermittent failures). |
| **Baseline inventory** | Cross-reference with `docs/reports/warp-prism-test-failure-baseline.md`. If the failure is listed there, it is pre-existing. | Always (secondary confirmation). |
| **File scope audit** | List all files modified by the task. Compare against the failing test's import chain. No overlap = unrelated. | When classifying as unrelated vs related. |

### 4.2 Completion evidence template for pre-existing claims

Every task that encounters pre-existing failures must include this in its
Completion Evidence section:

```
- **Pre-existing failures**: <count> failures present before and after changes.
  - Classification: [unrelated/related]
  - Affected areas: [list test files or feature areas]
  - Baseline evidence: [flutter test before/after diff, or inventory reference]
  - Regression introduced: NONE
```

---

## 5. Current Baseline Reference

As of 2026-06-09, the test failure baseline (`docs/reports/warp-prism-test-failure-baseline.md`)
records:

| Classification | Count | Package | Origin |
|----------------|-------|---------|--------|
| Pre-existing (unrelated to stabilization wave) | **64** | `warp_prism_observatory` | Phantom completions from original 57-task wave. Parser contract drift, view-model mismatch, missing fixtures, history narrative contract, map state/selection, shell/router, operate inspector. Owned by EPIC-14 tasks (1401-1408). |
| Regression (caused by Wave 4) | **24** | `warp_prism_ui` | Component contract drift (8), gallery compile errors (7), template contract drift (3), accessibility/semantics drift (3), state vocabulary (1), operational components (1), atoms contract (1). Owned by Tasks 1303, 1304, 1307, 1309. |

**Policy implication**: A task working on Observatory code that encounters one
of the 64 known failures can classify it as pre-existing (unrelated) if the
task did not touch the failing file. A task working on UI code that encounters
one of the 24 Wave 4 regressions must treat it as pre-existing (related) or
regression depending on whether the task introduced or touched the failing area.

---

## 6. Reviewer Checklist

When reviewing a task that claims pre-existing failures, the reviewer must
verify:

- [ ] **Baseline exists**: The task's completion evidence includes before/after
      test results or a reference to the baseline inventory.
- [ ] **Classification is correct**: The decision tree was followed. The failure
      is not actually a regression the builder missed.
- [ ] **File scope is accurate**: `git diff --name-only` for the task's commits
      confirms no overlap with the failing area (for unrelated claims).
- [ ] **Count is honest**: The claimed pre-existing count matches the baseline
      inventory or before/after diff.
- [ ] **No hidden regressions**: New failures are not masked by counting them
      as pre-existing. Every new failure is either fixed or classified as
      regression.
- [ ] **Related failures are tracked**: If any failures are classified as
      pre-existing (related), a follow-up task exists and the deferral is
      justified.
- [ ] **Interactive/accessible components**: If the failing area involves
      user-facing interactive or accessibility semantics, the failure is not
      deferred without explicit reviewer approval.

---

## 7. Anti-Gaming Rules

1. **"Pre-existing" is not a magic word.** Saying "pre-existing" without
   evidence is a governance violation. The reviewer must reject the claim.
2. **Baseline must be captured before changes.** A builder who runs tests only
   after making changes cannot claim failures are pre-existing.
3. **Scope creep into failing areas is not free.** If a task voluntarily
   modifies a file that has pre-existing failures, those failures become
   related and must be addressed.
4. **Flaky tests are not pre-existing.** A test that passes sometimes and
   fails sometimes is flaky, not pre-existing. It must be classified as
   async/flaky per the promotion state model failure taxonomy and fixed to
   be deterministic before promotion.

---

## 8. Relationship to Promotion State Model

This policy operationalizes the `Pre-existing (unrelated)` row in the
[Promotion State Model](promotion-state-model.md) failure taxonomy. That model
states: *"Pre-existing (unrelated): Failure existed before, task did not touch
the area. Does not block promotion, but must be classified."*

This policy adds:
- The classification decision tree (how to determine related vs unrelated).
- The evidence requirements (what "classified" means in practice).
- The reviewer checklist (how to verify claims).
- The anti-gaming rules (what "must be classified" prevents).

The promotion state model references this policy for pre-existing failure
handling in both `.agents/rules/promotion-state-model.md` and
`docs/governance/promotion-state-model.md`.

---

## 9. References

- **Failure baseline**: `docs/reports/warp-prism-test-failure-baseline.md`
  (Task 1201)
- **Promotion state model**: `docs/governance/promotion-state-model.md`
  (Task 1202)
- **Source rule**: `.agents/rules/pre-existing-failure-policy.md`
- **Builder promotion state model**: `.agents/rules/promotion-state-model.md`
- **Failure taxonomy**: Promotion state model §3 (Failure Taxonomy table)
- **EPIC-14 tasks**: 1401-1408 (Observatory pre-existing failure remediation)
- **Wave 4 regression owners**: Tasks 1303, 1304, 1307, 1309
