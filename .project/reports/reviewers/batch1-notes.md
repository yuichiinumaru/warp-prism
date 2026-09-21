# Path-to-100 Wave — Batch 1 Notes (2026-07-18)

**Builder**: path-to-100 / builders  
**Scope**: 0002, 0003, 0004, 0005, 0006, 0011–0018, 0310, 0314, 0315  
**Lane rule**: leave tasks in `docs/tasks/03-review/` (no move to `04-completed`)

## Summary

| Task | Prior hold | Residual fixed | Exit proof |
| --- | --- | --- | --- |
| 0002 | 95 notes (path drift) | Monorepo evidence + live validator | validator EXIT 0; 9 agents / 11 workflows |
| 0003 | 93 notes (path drift) | Monorepo evidence + live validator | validator EXIT 0; 13 skills |
| 0004 | drain 100 | Re-prove | validator EXIT 0; 22 tasks |
| 0005 | 94 notes + open checkbox | Paths + checkbox N/A closed | validator EXIT 0; 36 changelogs |
| 0006 | drain 100 | Re-prove archive + no residual root | validator EXIT 0; `mock_workspace/` absent |
| 0011 | format residual history | Fixed trailing braces on `history_page.dart` | analyze clean; format EXIT 0 |
| 0012 | drain 100 | Re-prove templates clean | templates analyze No issues |
| 0013 | drain 100 | INFO severity re-check | 0 ERROR; INFO-only residual class |
| 0014 | drain 100 | Inventory 156/109 re-check | find counts match inventory §0 |
| 0015 | drain 100 | Re-check | held |
| 0016 | drain 100 | templates clean | held |
| 0017 | Details hygiene | Re-check all Details `[x]` | held |
| 0018 | a11y guide drift | Guide already live API; re-confirm | no withOpacity in guide |
| 0310 | dual-surface 95 | **Archived** legacy models + YAML parser | models tests PASS; live dual surface gone |
| 0314 | fan-in/category 91 | **highFanIn** + **reviewPressure** + deferred docs | diagnostics tests PASS |
| 0315 | VM providers 92 | **VM FutureProviders** + **AsyncLoading** test | providers tests PASS |

## Code changes (non-doc)

- `.archive/legacy-yaml-parser-20260718/` — retired dual surface
- `governance_diagnostics.dart` — `highFanIn`, implemented/deferred sets
- `workspace_diagnostics_service.dart` — highFanIn emit + reviewPressure detector
- `workspace_providers.dart` — shell VM providers
- Governance panels/tests updated for highFanIn
- `history_page.dart` — parse repair

## Changelog

- `docs/changelog/2026-07-18-path-to-100-batch1-0310-0314-0315.md`

## Not done (by design)

- No git commit
- No tasklist rebuild
- No lane moves to `04-completed`
- Pre-existing GoRouter percent-encoding assertion in `governance_page_shell_test` (`skill:local` vs `skill%3Alocal`) is out of this batch’s path-to-100 residual list (not introduced by highFanIn)
