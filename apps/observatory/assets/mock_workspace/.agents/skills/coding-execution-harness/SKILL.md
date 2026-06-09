---
name: coding-execution-harness
description: Manages code generation, iteration, testing, and implementation workflows. Core skill for the builder agent.
triggers:
  - implement feature
  - write code
  - run tests
  - fix bug
  - refactor code
sub_skills:
  - code-generation
  - test-execution
  - iteration-loop
  - build-verification
canonicality: parentCanonical
tags:
  - coding
  - implementation
  - testing
  - execution
---

# coding-execution-harness

## Purpose

Drives the implementation lifecycle: generate code, run tests, iterate on failures, and verify builds. This skill is the core engine behind the builder-orchestrator agent.

## Execution Loop

1. Read task scope and exit conditions
2. Generate or modify code
3. Run test suite
4. Check build status
5. Iterate on failures
6. Produce completion evidence

## When To Use

- Implementing features from task specifications
- Writing and running tests
- Fixing bugs identified during review
- Refactoring code for quality improvement

## Sub-Skills

- `code-generation`: Code scaffolding and generation patterns
- `test-execution`: Test running and result analysis
- `iteration-loop`: Failure analysis and retry logic
- `build-verification`: Build status and artifact validation
