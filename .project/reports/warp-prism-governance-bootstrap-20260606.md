# Warp Prism Governance Bootstrap — 2026-06-06

## Classification

Case: `nursery-no-governance` with existing product docs, task lanes, reports,
and 55 executable open task specs, but no local `.agents/` harness and no local
task template or changelog folder.

## Created Child-Local Surfaces

| Surface | Purpose |
| --- | --- |
| `AGENTS.md` | Local child constitution for Warp Prism agents. |
| `.agents/rules/project-boundaries.md` | Product and workspace boundaries. |
| `.agents/rules/task-governance.md` | Local task namespace and lane rules. |
| `.agents/workflows/onboard.md` | Local onboarding ritual. |
| `.agents/profiles/` | Local role continuity namespace for child-root sessions. |
| `docs/tasks/000-template.md` | Local executable task template. |
| `docs/changelog/` | Simple child-local changelog ledger. |

## Parent-Canonical Inheritance

| Child path | Target |
| --- | --- |
| `.agents/skills` | `../../.agents/skills` |
| `.agents/agents` | `../../.agents/agents` |
| `.codex/agents` | `../../.codex/agents` |

Reusable skills and agent definitions remain parent-canonical. Child divergence
belongs in rules, workflows, tasks, reports, changelog, and profiles.

## Immediate Risks

- Local `docs/changelog/` is a simple ledger, not yet a generated changelog
  engine.
- Existing 55 task specs predate `docs/tasks/000-template.md`; they should be
  audited against the new local template during execution/review, not bulk
  rewritten blindly.
- Warp Prism `README.md` is a known product alignment gap already covered by
  baseline tasks.

## Suggested First Wave

Follow `docs/reports/warp-prism-task-gap-overlap-audit.md`:

1. Task 1070 if adding or renumbering task waves.
2. Task 0010–0013 foundation/compile/alignment.
3. Task 0014–0018 design-system baseline.
4. Task 0001–0006 mock corpus.
5. Task 0310–0315 data/graph backbone.

## Verification Notes

- Target `.agents/` path was absent before bootstrap.
- Parent-canonical symlink targets existed in the Ganthritor root.
- Child-local task lanes already existed.
