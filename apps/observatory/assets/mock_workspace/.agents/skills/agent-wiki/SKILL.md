---
name: agent-wiki
description: Stores continuity, learnings, decisions, errors, reviews, fixes, and audits. Knowledge persistence layer for the workspace.
triggers:
  - record decision
  - store learning
  - document error
  - knowledge capture
  - continuity note
sub_skills:
  - decision-log
  - error-patterns
  - learnings-capture
  - review-history
canonicality: parentCanonical
tags:
  - knowledge
  - continuity
  - wiki
  - memory
---

# agent-wiki

## Purpose

Acts as the knowledge persistence layer for the workspace. Records decisions, learnings, error patterns, review outcomes, and operational notes so that agents maintain continuity across sessions.

## When To Use

- Recording architectural or implementation decisions
- Capturing learnings from task execution
- Documenting error patterns and their fixes
- Storing review outcomes for pattern recognition
- Maintaining operational continuity notes

## Content Types

- **Decisions**: Why specific approaches were chosen
- **Learnings**: Non-obvious discoveries during implementation
- **Errors**: Error patterns and their resolution paths
- **Reviews**: Review patterns and recurring findings
- **Fixes**: Effective fix patterns for common issues

## Sub-Skills

- `decision-log`: Structured decision recording
- `error-patterns`: Error pattern cataloging
- `learnings-capture`: Learning extraction and storage
- `review-history`: Review outcome tracking
