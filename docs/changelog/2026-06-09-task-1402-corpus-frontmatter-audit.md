# Task 1402: Corpus and Frontmatter Contract Audit

## Why
The stabilization wave (EPIC-14) identified 64 test failures. Before fixing parsers (Task 1403), we needed to determine whether failures stem from corpus drift or parser drift.

## Changed
- Audited all 130 `.md` files in `assets/mock_workspace/` against the corpus contract
- Verified frontmatter schemas for agents (9), skills (13), workflows (11), tasks (22), changelogs (36)
- Identified 39 nested skill files (sub-skills, skill-workflows, references) missing frontmatter entirely
- Identified critical `TaskLaneParsing.fromStatus()` pass-through bug as root cause of 8+ parser test failures
- Verified all cross-references (agent→skill, agent→workflow, task→task, changelog→task) are intact

## Evidence
- `docs/reports/corpus-frontmatter-audit.md` — full audit report with per-type schema analysis
- All 130 files scanned; 99 have frontmatter, 39 do not
- Zero broken cross-references found
- Zero duplicate YAML keys found
- Conclusion: corpus is conformant; parser code needs fixes
