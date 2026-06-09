---
name: code-quality-harness
description: Handles review, audit, proof, verification, security, and scoring. Core skill for quality gates and review cycles.
triggers:
  - code review
  - quality check
  - security audit
  - task scoring
  - verification
sub_skills:
  - deterministic-checks
  - adversarial-review
  - security-scan
  - quality-scoring
canonicality: parentCanonical
tags:
  - quality
  - review
  - security
  - scoring
---

# code-quality-harness

## Purpose

Provides the rules, checks, and scoring criteria for code quality review. Combines deterministic automated checks with adversarial manual review to produce quality scores and routing decisions.

## Quality Tiers

1. **Deterministic**: Lint, test pass, coverage threshold, complexity limits
2. **Adversarial**: Edge cases, error handling, performance, security patterns
3. **Scoring**: Composite 0-100 score from weighted tier results
4. **Routing**: Promote if score >= 70, return if below

## When To Use

- Running code reviews in the review workflow
- Scoring task completion evidence
- Security auditing code changes
- Validating quality gates during implementation

## Sub-Skills

- `deterministic-checks`: Lint, test, coverage, complexity analysis
- `adversarial-review`: Edge case and security pattern analysis
- `security-scan`: Vulnerability and dependency scanning
- `quality-scoring`: Composite scoring and threshold routing
