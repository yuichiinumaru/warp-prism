# Review Wave 2 — Fixture Contract Tasks 0001-0003

**Date**: 2026-06-14  
**Reviewer**: reviewers  
**Scope**: Task 0001, Task 0002, Task 0003 fixture contract review against live filesystem evidence.

## Summary

| Task | Score | Route | Decision |
|---|---:|---|---|
| 0001 — Mock Workspace Contract Baseline | 84/100 | `docs/tasks/02-doing/` | Rejected: contract/evidence path drift and archive destination inconsistency. |
| 0002 — Agent and Workflow Markdown Fixtures | 95/100 | Remains `docs/tasks/03-review/` | Pass with notes: live 9 agents + 11 workflows validate under app-local corpus. |
| 0003 — Skill Hierarchy Markdown Fixtures | 93/100 | Remains `docs/tasks/03-review/` | Pass with notes: live hierarchy validates after narrow YAML quoting patch. |

## Findings

- [MEDIUM] `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md:117` — Task 0001 evidence names a manifest path that does not exist.
  Evidence: live filesystem has `apps/observatory/assets/mock_workspace/manifest.yaml`, while `assets/mock_workspace/manifest.yaml` is absent; `python3 tool/validate_mock_workspace.py --project-root .` fails with `FATAL: manifest.yaml not found at assets/mock_workspace/manifest.yaml`.
  Impact: downstream tasks inherit a false corpus root and root-level validation evidence is non-reproducible.
  Path to 100: either intentionally restore a root `assets/mock_workspace/` corpus or update the contract/task evidence/validator invocation to the app-local corpus path, then rerun validation.

- [LOW] `docs/mock-workspace-corpus-contract.md:161` — Task 0001 archive destination wording is inconsistent with live state.
  Evidence: contract text mentions `archive/mock_workspace/` and `warp-prism/archive/mock_workspace/`, manifest says `.archive/`, and live archived files are under `.archive/mock_workspace/`.
  Impact: future archive/legacy validation can route to the wrong destination.
  Path to 100: normalize contract and manifest to one exact destination, preferably `.archive/mock_workspace/`, and update task evidence.

- [LOW] `apps/observatory/assets/mock_workspace/.agents/skills/development-methodologies/SKILL.md:3` — Task 0003 had invalid YAML frontmatter before reviewer patch.
  Evidence: PyYAML rejected the unquoted colon in `description: Contains RF8 methodology: ...`; reviewer-owned patch quoted the scalar and post-patch parse passed.
  Impact: strict YAML consumers would drop or fail this skill asset.
  Fix applied: quoted the description scalar. No further action required for Task 0003.

## Commands / Evidence

- `pwd && python3 - <<'PY' ...` — confirmed execution stayed in `/home/sephiroth/working/ganthritor/warp-prism`; root `assets/mock_workspace` absent; app-local corpus present.
- `python3 tool/validate_mock_workspace.py --project-root apps/observatory` — PASS.
- `python3 tool/validate_mock_workspace.py --project-root .` — FAIL, manifest missing at root path.
- `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml` — PASS, 5 expected manifest markers.
- `rg -n "Parser deltas|Legacy corpus mapping|Required counts" docs/mock-workspace-corpus-contract.md` — PASS, required sections present.
- `rg --files apps/observatory/assets/mock_workspace/.agents/agents apps/observatory/assets/mock_workspace/.agents/workflows` — PASS, 20 files (9 agents + 11 workflows).
- PyYAML required-key/body check for agents, workflows, and skills — PASS after Task 0003 patch.
- Python manifest-to-disk name comparison — PASS: 9 agents, 13 skills, 11 workflows match manifest.
- Python agent/workflow cross-reference check — PASS: referenced skills/workflows resolve.
- Python skill sub-surface population check — PASS: all 13 super-skills have non-empty `sub-skills/`, `workflows/`, `references/`, and `scripts/`.

## Patches / Routing

- Added Review Ledger entry to Task 0001 and moved it from `03-review` to `02-doing` because score is below 90.
- Added Review Ledger entries to Task 0002 and Task 0003; both remain in `03-review` for parent final verification.
- Narrow reviewer-owned patch: quoted `development-methodologies` skill description to make YAML frontmatter valid.

## Verdict

- Task 0001: NEEDS FIX.
- Task 0002: PASS WITH NOTES.
- Task 0003: PASS WITH NOTES.
