---
id: T011
title: "Normalize DS organism spacing tokens"
status: doing
priority: medium
owner: gt-code-quality-reviewer
created: "2026-06-02"
updated: "2026-06-06"
skills:
  - design-system-harness
  - code-quality-harness
workflows:
  - gt-code-review
depends_on:
  - T005
proof_state: none
review_score: 5.0
---

# Normalize DS Organism Spacing Tokens

## Goal
Audit all DS organism widgets (DSShell, DSSidebar, DSTopbar, DSLaneBoard, DSTimeline, DSDetailInspector, DSStoryPanel, DSGraphCanvas) and replace hardcoded spacing values with DSSpacing tokens.

## Scope
- Replace all SizedBox(height: 8.0) etc. with DSSpacing.xs/sm/md/lg/xl
- Replace all EdgeInsets.all(16.0) etc. with DSSpacing-based insets
- Ensure consistency across all 9 organism files

## Exit Conditions
- [ ] Zero hardcoded numeric spacing values in organism widgets
- [ ] All organisms use DSSpacing tokens exclusively
- [ ] Visual regression: organisms render identically before and after

## Verification Commands
```bash
grep -rn '[0-9]\+\.[0-9]' lib/design_system/organisms/ | grep -v '//' | grep -v 'DSSpacing'
```

## Completion Evidence
*Not yet completed — task is in doing lane, audit in progress.*
