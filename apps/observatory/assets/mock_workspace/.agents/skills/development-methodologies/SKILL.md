---
name: development-methodologies
description: "Contains RF8 methodology: Goal → Domain → Feature → Representation → Specs → Behaviour → Test → Eval. Used for structured decomposition."
triggers:
  - rf8 decomposition
  - goal analysis
  - feature planning
  - requirements breakdown
  - spec generation
sub_skills:
  - rf8-decomposition
  - goal-domain-analysis
  - spec-generation
  - behaviour-specification
canonicality: parentCanonical
tags:
  - methodology
  - rf8
  - planning
  - decomposition
---

# development-methodologies

## Purpose

Provides structured methodologies for decomposing goals into implementation-ready artifacts. The primary methodology is RF8: a sequential decomposition framework that ensures completeness from high-level goals down to testable behaviors.

## RF8 Stages

1. **Goal**: What are we trying to achieve?
2. **Domain**: What problem domain does this belong to?
3. **Feature**: What specific features address this goal?
4. **Representation**: How will the feature be represented in the system?
5. **Specs**: What are the detailed specifications?
6. **Behaviour**: What observable behaviors must the system exhibit?
7. **Test**: How will we verify the behaviors?
8. **Eval**: Did we achieve the goal?

## When To Use

- Breaking down PRDs into tasks
- Analyzing goals for completeness
- Generating specifications from features
- Creating test strategies from behaviors

## Sub-Skills

- `rf8-decomposition`: Full RF8 pipeline execution
- `goal-domain-analysis`: Goal and domain stage analysis
- `spec-generation`: Specification generation from features
- `behaviour-specification`: Behaviour and test stage definition
