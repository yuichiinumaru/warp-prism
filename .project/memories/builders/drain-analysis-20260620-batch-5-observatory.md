# Drain Analysis 2026-06-20 — Batch 5 Observatory

> Source: `gt-mechanical-investigator` task `ses_11caac5f2ffeUoOe6hyVPq3mUS`.
> Scope: `02-doing/1401-1408` plus review-lane anomaly probes for `0410`, `0510-0514`.
> Status: PARTIAL-COMPLETE — subagent read all 8 EPIC-14 task files and governance files, but did not persist full schema before step limit. It reported that the scoped `03-review/` anomaly paths did not exist in its filesystem view; parent preflight observed current `03-review` files for those IDs, so treat that discrepancy as stale/tool-context inconsistency requiring parent verification before action.

## EPIC-14 Tasks Read

- `1401` — Observatory Failure Baseline Inventory
- `1402` — Corpus and Frontmatter Contract Audit
- `1403` — Parser and Task Projection Reconciliation
- `1404` — View-model and Mapper Contract Reconciliation
- `1405` — Detail Variant and Responsive Shell Reconciliation
- `1406` — History and Operate Feature Flow Reconciliation
- `1407` — Legacy Test Retirement or Rewrite Audit
- `1408` — Observatory Package Imports Cleanup

## Confirmed Dependency Chain

```text
1401 -> 1402 -> 1403 -> 1404 -> 1405 -> 1406 -> 1407
                         └-> 1408 (parallel after 1403)
```

## Critical Blockers

| Blocker | Affected Tasks | Notes |
| --- | --- | --- |
| Nested `apps/observatory/tmp/pub-cache` workspace contamination | `1401`, `1408`, likely all EPIC-14 validation | Breaks clean `flutter test` / `flutter analyze` runs. |
| `1202` dependency rejected | `1401` and downstream proof chain | Must fix promotion model truth first. |
| `1402` / `1403` contradiction | `1402`, `1403`, downstream | Audit says corpus conformant while documenting 39 missing-frontmatter files; `1403` then says no corpus fixes needed. |
| Synthetic evidence | `1404`, `1405`, `1406` | Downstream tests/evidence do not prove live corpus after rejected `1403`. |
| `1406` failing tests/evidence gaps | `1406` | Operate inspector tests still failing; completion evidence placeholder-only. |
| `1407` zero-progress audit gap | `1407` | Required retirement audit report, classification, changelog missing. |
| Remaining deep import | `1408` | One deep feature import remains; analyzer blocked by contamination. |

## Per-Task Routing Summary

| Task | Predicted Routing | Path To 100 Summary |
| --- | --- | --- |
| `1401` | `fixer_then_review` after `1202` + contamination fix | Reproduce current Observatory baseline with clean workspace, update evidence. |
| `1402` | `fixer_then_review` | Reconcile audit contradiction; classify/fix 39 frontmatter defects. |
| `1403` | `fixer_then_review` after `1402` | Apply parser/projection reconciliation against corrected corpus truth. |
| `1404` | `fixer_then_review` after `1403` | Replace synthetic proof with live corpus/view-model evidence. |
| `1405` | `fixer_then_review` after `1404` | Revalidate detail/responsive shell against corrected mapper. |
| `1406` | `fixer_then_review` after `1404/1405` | Fix Operate inspector tests and fill completion/changelog evidence. |
| `1407` | `builder_wave` after previous tasks | Produce required legacy test audit/report/classification/changelog. |
| `1408` | `fixer_then_review` after contamination + `1403` | Remove remaining deep import and prove analyzer with clean workspace. |

## Suggested Wave Order

1. Resolve shared governance/workspace blockers (`1202`, workspace contamination).
2. `1402` audit correction.
3. `1403` parser/projection correction.
4. `1408` import cleanup can run after `1403` if file conflicts are low.
5. `1404 -> 1405 -> 1406 -> 1407` serialized.

## Caveat

The subagent's statement that scoped `03-review/0410,0510-0514` did not exist conflicts with parent live glob output. Parent must verify those lane anomalies separately; do not use this batch report to move review-lane files.
