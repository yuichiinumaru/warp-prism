---
name: remediation-harness
description: Routes quality issues to appropriate fix workflows, manages fix prioritization, and tracks remediation progress.
triggers:
  - quality issue found
  - fix routing
  - remediation needed
  - issue triage
  - fix verification
sub_skills:
  - issue-routing
  - fix-prioritization
  - remediation-tracking
  - fix-verification
canonicality: parentCanonical
tags:
  - remediation
  - fixes
  - routing
  - triage
---

# remediation-harness

## Purpose

Manages the remediation lifecycle when quality issues are discovered during review. Routes issues to appropriate fix workflows, prioritizes fixes, tracks remediation progress, and verifies fixes are effective.

## When To Use

- Quality review finds issues requiring fixes
- Security audit identifies vulnerabilities
- Test failures need investigation and resolution
- Adversarial review discovers edge cases

## Routing Rules

1. **Critical**: Security vulnerabilities → immediate fix, block promotion
2. **Major**: Test failures, coverage gaps → return to doing lane
3. **Minor**: Lint warnings, style issues → fix in current cycle
4. **Info**: Suggestions, optimizations → backlog if time permits

## Sub-Skills

- `issue-routing`: Issue classification and routing logic
- `fix-prioritization`: Priority assignment based on severity
- `remediation-tracking`: Progress tracking across fix cycles
- `fix-verification`: Fix effectiveness validation
