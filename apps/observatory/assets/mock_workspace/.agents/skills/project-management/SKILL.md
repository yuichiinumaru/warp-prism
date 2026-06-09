---
name: project-management
description: Governs tasks, tasklist sync, changelog, handoff, and agent memory. Core skill for execution visibility.
triggers:
  - create task
  - tasklist sync
  - changelog entry
  - lane management
  - task handoff
sub_skills:
  - task-creation
  - tasklist-sync
  - changelog-management
  - lane-operations
canonicality: parentCanonical
tags:
  - tasks
  - project
  - governance
  - execution
---

# project-management

## Purpose

Manages the task lifecycle across all lanes (planning, open, doing, review, completed). Handles tasklist synchronization, changelog emission, and handoff coordination between agents.

## When To Use

- Creating or modifying task files
- Moving tasks between lanes
- Synchronizing tasklist with actual workspace state
- Emitting changelog entries for task lifecycle events
- Coordinating handoffs between orchestrator agents

## Core Rules

1. Tasks must have frontmatter: id, title, status, priority, owner, created, updated, skills, workflows, depends_on, proof_state, review_score
2. Lane directories: 00-planning, 01-open, 02-doing, 03-review, 04-completed
3. Every lane transition must be recorded in the changelog
4. Task IDs must be unique across the workspace

## Sub-Skills

- `task-creation`: Task file structure and frontmatter schema
- `tasklist-sync`: Synchronizing tasklist index with actual files
- `changelog-management`: Changelog entry format and emission
- `lane-operations`: Lane transition rules and validation
