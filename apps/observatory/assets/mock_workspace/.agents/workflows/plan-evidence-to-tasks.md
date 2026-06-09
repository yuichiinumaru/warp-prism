---
name: plan-evidence-to-tasks
description: Converts planning evidence and PRD artifacts into a batch of properly structured tasks with dependency ordering.
uses_skills:
  - project-management
  - development-methodologies
  - agent-wiki
kind: conversion
---

# plan-evidence-to-tasks

## Purpose

Take accumulated planning evidence from the planning lane and convert it into a batch of implementation-ready tasks. Ensures dependency ordering is correct and no gaps exist between evidence and task scope.

## Steps

1. Collect planning evidence from `docs/tasks/00-planning/`
2. Validate evidence completeness against RF8 stages
3. Identify gaps and missing evidence
4. Generate task batch with dependency graph
5. Place tasks in `docs/tasks/01-open/`
6. Record conversion decisions in agent-wiki

## Skills Used

- `project-management`: Task batch creation and dependency management
- `development-methodologies`: RF8 evidence validation
- `agent-wiki`: Recording conversion rationale

## Artifacts Produced

- Task batch in open lane
- Dependency graph document
- Evidence-to-task mapping record
