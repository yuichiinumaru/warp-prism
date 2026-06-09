---
name: gt-code-review
description: Multi-tiered code review workflow with deterministic checks, adversarial review, scoring, and task routing.
uses_skills:
  - code-quality-harness
  - project-management
  - agent-wiki
kind: review
canonicality: parentCanonical
tags:
  - review
  - quality
  - scoring
---

# gt-code-review

Multi-tiered code review workflow.

## Stages

1. Static analysis pass
2. Adversarial review by gt-code-quality-reviewer
3. Scoring and evidence collection
4. Task routing based on score
