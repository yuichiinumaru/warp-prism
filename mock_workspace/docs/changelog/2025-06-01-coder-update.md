# Changelog Entry: 2025-06-01

## Summary
Major update to the Coder Agent with improved code generation capabilities and new refactoring tools.

## Changes

### Added
- New `smart-refactor` skill for intelligent code refactoring
- Support for TypeScript 5.5 features in code generation
- Automatic import organization and optimization
- Integration with ESLint flat config

### Changed
- Upgraded model from claude-sonnet-3.5 to claude-sonnet-4
- Improved error handling with more descriptive messages
- Optimized token usage by 23% through better context management
- Updated test generation to use Vitest by default

### Fixed
- Fixed issue where generated code had inconsistent formatting
- Resolved memory leak in long-running code analysis sessions
- Fixed incorrect type inference for generic functions

### Deprecated
- Legacy `format_code` tool - use `lint_code` with `fix: true` instead

## Affected Assets
- Agent: coder (v1.8.2 -> v1.8.3)
- Skill: code-review (v2.0.0 -> v2.0.1)
- Workflow: code-implementation (v1.1.0 -> v1.2.0)

## Evidence
- PR #234: Model upgrade and optimization
- Issue #189: TypeScript 5.5 support request
- Benchmark results: 23% token reduction confirmed

## Author
@asw-team

## Tags
- enhancement
- performance
- coder
