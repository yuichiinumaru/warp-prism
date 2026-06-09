---
name: harness-architecture
description: Meta-cognition for Agent System Workspace asset creation. READ THIS FIRST when creating agents, skills, workflows, or tools.
triggers:
  - create agent
  - create skill
  - create workflow
  - harness governance
  - asset modification
  - workspace structure change
sub_skills:
  - create-agent
  - create-skill
  - create-workflow
  - harness-management
canonicality: parentCanonical
tags:
  - harness
  - governance
  - meta-harness
---

# harness-architecture

## Purpose

This is the meta-governance skill for the Agent System Workspace. It defines the rules, patterns, and validation criteria for creating and modifying all harness assets: agents, skills, workflows, and tools.

## When To Use

- **ALWAYS** before creating any new agent, skill, or workflow
- When modifying existing harness assets
- When validating workspace structure compliance
- When regenerating indexes after asset changes

## Core Rules

1. Every agent must have YAML frontmatter with: name, model, mode, description, skills, workflows
2. Every skill must have YAML frontmatter with: name, description, triggers, sub_skills, canonicality, tags
3. Every workflow must have YAML frontmatter with: name, description, uses_skills, kind
4. Asset names must be kebab-case and match their filename
5. Cross-references must use exact asset names from the manifest

## Sub-Skills

- `create-agent`: Agent creation rules and templates
- `create-skill`: Skill creation rules and directory structure
- `create-workflow`: Workflow creation rules and frontmatter schema
- `harness-management`: Manifest updates, index regeneration, governance audits
