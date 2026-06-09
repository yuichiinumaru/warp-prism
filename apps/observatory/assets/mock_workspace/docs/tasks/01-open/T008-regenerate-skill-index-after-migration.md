---
id: T008
title: "Regenerate skill index after migration"
status: open
priority: medium
owner: gt-wave-orchestrator
created: "2026-05-28"
updated: "2026-06-01"
skills:
  - indexing-skills
  - agent-wiki
workflows:
  - gt-research-orchestration
depends_on:
  - T003
  - T006
proof_state: none
review_score: n/a
---

# Regenerate Skill Index After Migration

## Goal
Rebuild the skill index from the frontmatter-based SKILL.md files after the parser migration, ensuring all 13 skills are discoverable and their sub-skills, workflows, and references are linked.

## Scope
- Scan all assets/mock_workspace/.agents/skills/*/SKILL.md
- Extract frontmatter and build a lookup index
- Validate that every skill referenced by agents and workflows resolves

## Exit Conditions
- [ ] Index contains all 13 required skills
- [ ] Every skill referenced in agent frontmatter resolves to a SKILL.md
- [ ] Index regeneration is idempotent (re-running produces identical output)

## Verification Commands
```bash
grep -c "name:" assets/mock_workspace/.agents/skills/*/SKILL.md | wc -l
```

## Completion Evidence
*Not yet completed — task is in open lane.*
