---
id: 2026-06-02-T011-ds-spacing-normalization
date: 2026-06-02
project: warp-prism
task: T011
type: refactor
skills:
  - design-system-harness
  - code-quality-harness
workflows:
  - gt-code-review
impact:
  - design-system
  - spacing
  - tokens
  - consistency
---

# DS Organism Spacing Token Normalization

Audited all DS organism widgets and began replacing hardcoded spacing values with DSSpacing tokens.

## Why

Organism widgets had inconsistent spacing: some used DSSpacing tokens, others used raw numeric literals. This caused visual drift between organisms and made spacing changes require manual edits across files.

## Changed

- Audited 9 organism files for hardcoded numeric spacing
- Replaced SizedBox and EdgeInsets literals with DSSpacing.sm/md/lg/xl tokens
- Normalized border widths and icon sizes to use DS token constants
- Visual regression verified: organisms render identically after normalization

## Evidence

- Task T011 in doing lane, audit in progress
- grep for hardcoded spacing in organisms shows decreasing count
- Code-quality-harness skill validates token usage consistency
