# Drain Analysis 2026-06-20 — Batch 4 Governance / ADS

> Source: `gt-mechanical-investigator` task `ses_11caac625ffe7vav9EPEG769P9`.
> Scope: `02-doing/1202-1208`, `1301-1307`, `1309`.
> Status: COMPLETE packet returned in subagent output; persisted by parent due subagent write ambiguity.

## Per-Task Summary

| Task | Status / Review State | Latest Known Score | Quickwin | Recommended Action | Key Path To 100 |
| --- | --- | ---: | --- | --- | --- |
| `1202` | Doing | 82/88/84 rejected | High | `fixer_then_review` | Refresh promotion examples against live lanes; unblock dependents. |
| `1203` | Builder Done | 88 rejected after prior 100 | High | `fixer_then_review` / header-lane repair after `1202` | Fix lane/header mismatch and rejected dependency evidence. |
| `1204` | Doing | 68/80 rejected | Medium | `fixer_then_review` | Resolve Melos workspace contamination and prove scripts. |
| `1205` | Doing | 72 rejected after prior 100 | Medium | `fixer_then_review` after `1204/1301` | Boundary harness 6/6; public barrel DS leak. |
| `1206` | Doing | 88 rejected | High after `1202` | `fixer_then_review` | Revalidate after `1202` path-to-100. |
| `1207` | Doing | rejected | Medium | `fixer_then_review` after `1203/1204` | Fix lane/header/exit-condition mismatch and generator path drift. |
| `1208` | Doing | rejected | High after `1202` | `fixer_then_review` | Refresh live 02-doing count/snapshot and dependency evidence. |
| `1301` | Doing | 72 rejected after prior 100 | High | `fixer_then_review` after `1202` | Boundary 6/6; remove public-barrel DS leak. |
| `1302` | Doing | 58 rejected | Medium | `fixer_then_review` after `1301` | Manifest/barrel drift, boundary proof. |
| `1303` | Builder Done | 62 rejected | High impact | `fixer_then_review` after workspace cleanup | Fix scoped analyzer issues and contamination-blocked tests. |
| `1304` | Package Gate Failed | 62 rejected | High impact | `fixer_then_review` after `1303` | Gallery analyzer infos, deprecated APIs, mounted guards, secret-shaped demo value. |
| `1305` | Ready For Review | 82/42/66 rejected | Medium | `fixer_then_review` after `1303/1304` | Duplicate-ID proof, non-vacuous tests, contract proof. |
| `1306` | Package Gate Failed | 54 rejected | Medium | `fixer_then_review` after `1303/1304` | 11 golden failures, dependency unblock. |
| `1307` | Package Gate Failed | 68/84/82/85/78 rejected | Medium | `fixer_then_review` after `1303/1309` | Focus traversal, scoped analyzer, touch targets. |
| `1309` | Doing | 78 rejected after scoped 100 | High after `1303` | `fixer_then_review` | Workspace contamination, boundary 6/6, dependency revalidation. |

## Dependency Ordering

```text
1202 -> 1203 -> 1207
1202 -> 1206
1202 -> 1208
1204 -> 1205
1301 -> 1302
1301 -> 1205 boundary proof
1303 -> 1304 -> 1305/1306
1303 -> 1309 -> 1307
```

## Hard Blockers

1. **Workspace contamination**: nested `apps/observatory/tmp/pub-cache` breaks Melos/Dart workspace commands; affects `1204`, `1205`, `1303`, `1306`, `1309`.
2. **Task 1202 drift**: stale promotion model examples block multiple governance and ADS tasks.
3. **Task 1303 rejection**: component contract tests/analyzer not reproducibly clean, blocks multiple ADS tasks.
4. **Task 1304 rejection**: gallery analyzer and lifecycle/security-shaped demo issues block `1305`, `1306`.
5. **Public barrel DS leak**: `DSOperationalStateUI` exported through public barrel; boundary harness 5/6 blocks `1301`, `1302`, `1205`.

## Collision Risks

| Surface | Tasks | Decision |
| --- | --- | --- |
| Public barrel `warp_prism_ui.dart` | `1301`, `1302`, `1305`, `1205` | Serialize. |
| Melos scripts / boundary harness | `1204`, `1205` | Serialize. |
| `ds_state_surface.dart` / operational state semantics | `1303`, `1307`, `1309` | Serialize or same Flutter builder bundle. |
| Gallery/goldens | `1304`, `1305`, `1306` | Serialize after `1303`. |

## Recommended First Waves

1. **Governance docs wave**: `1202`, then `1203`, `1206`, `1208` via `gt-evidence-refresher` / `gt-archivist`.
2. **Workspace contamination audit/fix**: assign `gt-gitops-engineer` to classify and safely remediate repo-local nested tmp/pub-cache contamination without deleting non-task artifacts blindly.
3. **ADS serialized wave**: `1301 -> 1302 -> 1303 -> 1304 -> 1309 -> 1307`, then `1305/1306`.
