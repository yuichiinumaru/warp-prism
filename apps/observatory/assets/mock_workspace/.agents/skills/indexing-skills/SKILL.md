---
name: indexing-skills
description: Regenerates indexes for agents, skills, and workflows. Maintains manifest accuracy and asset discoverability.
triggers:
  - regenerate index
  - update manifest
  - asset added
  - asset removed
  - index rebuild
sub_skills:
  - agent-index
  - skill-index
  - workflow-index
  - manifest-sync
canonicality: parentCanonical
tags:
  - indexing
  - manifest
  - discovery
  - synchronization
---

# indexing-skills

## Purpose

Maintains accurate indexes and manifests for all workspace assets. Ensures that agents, skills, and workflows are discoverable and that the manifest.yaml reflects the true state of the workspace.

## When To Use

- After creating or removing any asset
- When the manifest count doesn't match actual files
- During harness governance audits
- When rebuilding the asset graph

## Index Types

- **Agent index**: List of all agents with their skill and workflow references
- **Skill index**: Hierarchical skill tree with triggers and sub-skills
- **Workflow index**: All workflows with their skill dependencies
- **Manifest sync**: Validate manifest.yaml against actual file counts

## Sub-Skills

- `agent-index`: Agent directory scanning and indexing
- `skill-index`: Skill hierarchy tree construction
- `workflow-index`: Workflow dependency mapping
- `manifest-sync`: Manifest validation and update
