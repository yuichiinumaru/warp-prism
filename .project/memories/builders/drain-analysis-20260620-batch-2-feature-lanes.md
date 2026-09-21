# Drain Analysis 2026-06-20 — Batch 2 Feature Lanes

> Source: `gt-mechanical-investigator` task `ses_11caac692ffe2gPdSwnLYwQ7ju`.
> Scope: `02-doing/0610-0613`, `0710-0713`, `0810-0813`.
> Status: COMPLETE packet returned in subagent output; persisted by parent due subagent report write ambiguity.

## Findings Summary

| Claim | Confidence | Notes |
| --- | --- | --- |
| All 12 tasks are in `02-doing/` after re-reviews | High | Review Ledgers indicate June 17-19 returns. |
| Operate chain is serial: `0610 -> 0611 -> 0612 -> 0613` | High | `0610` root blocker. |
| History chain is serial: `0710 -> 0711 -> 0712 -> 0713` | High | `0710` root blocker. |
| Governance chain converges: `0810`,`0811`,`0812 -> 0813` | High | `0813` blocked on all three. |
| `0314` blocks much of this batch | High | Blocks `0610`, `0711`, `0810`, `0811`, `0812`. |
| Old Flutter SDK blocker claims are stale | High | Current environment has Flutter available per project context. |

## Per-Task Triage Matrix

| Task | Predicted Score | Quickwin | Recommended Action | Key Path To 100 |
| --- | ---: | --- | --- | --- |
| `0610` | 62 | Medium | `fixer_then_review` after `0314` | Fix `0314`, load real lane fixtures, canonical lane inference, fresh analyze/test. |
| `0611` | 55 | Low | `builder_wave` after `0610` | Wire `/operate`, real view tests, resolve `0610`. |
| `0612` | 58 | Low | `fixer_then_review` after `0610/0611` | Wire detail panel, fix 2 failing widget tests, route proof. |
| `0613` | 76 | Medium | `builder_wave` after `0612` | Widget proof for story panel, route wire, refresh evidence. |
| `0710` | 82 | High | `reviewer_only` / evidence refresh | Update paths, reconcile `impact` vs `impact_tags`, fresh 21-test/analyzer evidence. |
| `0711` | 74 | Medium | `fixer_then_review` after `0710` | Workflow facets, repository corpus load, evidence refresh. |
| `0712` | 64 | Low | `fixer_then_review` after `0711` | Wire `/history`, consume `HistoryTimeline`, integration proof. |
| `0713` | 78 | Medium | `builder_wave` after `0712` | Live route/read model, missed-tap warning, analyzer cleanup, changelog. |
| `0810` | 55 | Low | `fixer_then_review` after `0314` | Governance route diagnostics, analyzer/test evidence, count correction. |
| `0811` | 45 | Medium | `fixer_then_review` after `0314` | Add changelog-link-gap group, route wire, a11y 48x48/Semantics, changelog. |
| `0812` | 42 | Low | `fixer_then_review` after `0314` | Correct hotspot category, fix test, route wire, derive review pressure service-side. |
| `0813` | 48 | Low | `architecture_needed` / after dependencies | Fix `0810-0812`, real GoRouter/inspector drilldown, URL encoding, a11y. |

## Collision Matrix

| File/Domain | Tasks | Risk | Serialization Decision |
| --- | --- | --- | --- |
| `workspace_parser.dart` | `0610`, `0711` | High | Serialize; `0610` first if operating on task lane inference, `0711` after corpus model. |
| `lib/features/operate/` | `0610`-`0613` | High | Bundle under one Flutter builder, sequential inside bundle. |
| `lib/features/history/` | `0710`-`0713` | High | Bundle under one Flutter builder, sequential inside bundle. |
| `lib/features/governance/` | `0810`-`0813` | High | Bundle after `0314`; `0810-0812` may be coordinated, `0813` last. |
| `assets/mock_workspace` | `0610`, `0710` | Medium | `0710` owns corpus before downstream consumers. |

## Suggested Parent Routing

1. Address `0314` before feature-lane bundles.
2. Candidate low-risk quickwin: `0710` evidence/corpus reconciliation.
3. Do not start `0611-0613`, `0711-0713`, or `0813` until roots resolve.
