---
name: agent-cli-delegation
description: Delegates tasks to CLI tools, manages tool execution, handles tool output parsing, and coordinates multi-tool workflows.
triggers:
  - cli tool execution
  - tool delegation
  - multi-tool workflow
  - tool output parsing
  - command execution
sub_skills:
  - tool-execution
  - output-parsing
  - multi-tool-coordination
  - error-recovery
canonicality: parentCanonical
tags:
  - cli
  - tools
  - delegation
  - execution
---

# agent-cli-delegation

## Purpose

Manages delegation of tasks to CLI tools and external commands. Handles tool selection, execution, output parsing, error recovery, and multi-tool workflow coordination.

## When To Use

- Running CLI commands for research or validation
- Coordinating multiple tools in sequence
- Parsing structured output from tool execution
- Handling tool errors and retries

## Tool Categories

- **Search**: ripgrep, find, grep for codebase exploration
- **Build**: flutter, dart, npm for build operations
- **Test**: flutter test, dart test for verification
- **Git**: git commands for version control operations
- **Network**: curl, wget for external resource access

## Sub-Skills

- `tool-execution`: Command construction and execution
- `output-parsing`: Structured output extraction
- `multi-tool-coordination`: Sequential and parallel tool chains
- `error-recovery`: Tool failure analysis and retry logic
