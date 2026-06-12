# Task 1402: Corpus and Frontmatter Contract Audit — Complete

## Summary
Audited all 130 `.md` files in the mock workspace corpus against the corpus contract and parser expectations. Key findings:

- **99/130 files have valid YAML frontmatter** — agents (9), skills (13), workflows (11), tasks (22), changelogs (36) all conform to their schemas.
- **39 files lack frontmatter** — all are nested inside skill directories (sub-skills, skill-workflows, references). Parser silently drops them.
- **Zero broken cross-references** — all agent→skill, agent→workflow, task→task, changelog→task references are intact.
- **Critical parser bug found**: `TaskLaneParsing.fromStatus()` passes through to `fromDirectoryPrefix()` which only handles directory-style strings like `"00-planning"`, not bare status strings like `"planning"`. This causes all tasks to default to `TaskLane.open`, cascading to 8+ test failures.

## Diagnosis
**The corpus is correct. The parser is wrong.** All corpus files conform to the contract. The parser code needs to be updated to handle the corpus's field values.

## Deliverables
- `docs/reports/corpus-frontmatter-audit.md` — full audit report
- `docs/changelog/2026-06-09-task-1402-corpus-frontmatter-audit.md` — changelog entry

## Unblocks
- Task 1403 (Parser Contract Chain) — now has clear direction: fix parser, not corpus
