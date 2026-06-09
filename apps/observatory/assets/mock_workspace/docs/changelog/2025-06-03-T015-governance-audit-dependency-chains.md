---
id: 2025-06-03-T015-governance-audit-dependency-chains
date: 2025-06-03
project: asw-observatory
task: T015
type: audit
impact:
  - governance
  - provenance
  - canonicality
skills:
  - code-quality-harness
  - harness-architecture
---

# Governance audit of task dependency chains

## Why

The Governance workspace needs to surface canonicality and provenance risks. Without auditing the dependency chains in the task corpus, the observatory cannot flag stale tasks, broken `depends_on` references, or orphaned assets.

## Changed

- Audited all 20 mock tasks for `depends_on` validity: every referenced task ID must exist in the corpus.
- Found 3 broken references where `depends_on` pointed to non-existent task IDs. Fixed by correcting the IDs.
- Verified `proof_state` values are consistent with task lane: completed tasks must have `proof_state: verified`.
- Added canonicality classification: `parentCanonical` for planning tasks, `childLocal` for open/doing, `generated` for changelog entries.

## Evidence

- `assets/mock_workspace/docs/tasks/03-review/T015-governance-audit-task-dependency-chains.md` documents the audit findings.
- All 20 task files verified against the dependency graph.
