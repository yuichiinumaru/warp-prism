---
type: decision
title: "useful-skills-and-agents-for-warp-prism-execution"
agent: builders
created: 2026-06-08T17:42:39
date: 2026-06-08
---

# useful-skills-and-agents-for-warp-prism-execution

## Skills to use during warp-prism execution

### flutter-harness (SKILL.md) — Primary Flutter/Dart governance
- 12 sub-skills: architecture, dart-language, state-management, testing, ui-ux, security, performance, navigation, data-layer, devops-release, tooling
- 2 workflows: flutter-development-preflight, flutter-review-wave
- 158 flutter-rules.md consolidated rules in code-quality-harness/references/
- Scripts: dart_gate.sh, check_drift.sh, 4 OWASP Python scanners (experimental)
- Reference Corpus Index: 30+ exact paths for Riverpod, Freezed, GoRouter, Hive, testing, OWASP, etc.
- KEY RULES: project stack first (read pubspec.yaml before suggesting patterns), no phantom Flutter validation (if SDK missing report blocker), codegen is part of contract, tests must prove behavior not presence

### design-system-harness (SKILL.md) — DS governance
- 6 sub-skills: classify-component, design-token, theme, storybook, accessibility, migrate
- Atomic Design is the accepted taxonomy
- Dark-first themes, semantic token aliases, component token contracts
- KEY RULE: no package update/lockfile mutation/rewrite without specific task

### Flutter Agents — Use these for subagent dispatch
- gt-flutter-engineer: Primary builder. Riverpod codegen, clean architecture, adaptive layouts, TDD. Use for all implementation tasks.
- gt-flutter-expert: Deep semantic correctness. Framework internals, render pipeline, platform channels. Use for complex lifecycle/performance issues.
- gt-flutter-code-reviewer: Implacable 6-axiom gate. Use for ALL reviews before task promotion to 03-review.
- gt-flutter-designer: Visual/UI/UX review via browser screenshots. Use for design token compliance, accessibility visual audit, responsive behavior.

### Other Useful Agents
- gt-evidence-clerk: Collects shallow evidence packets (file presence, counts, command output). Use after each task for pre-review evidence.
- gt-mechanical-investigator: Read-only codebase investigation. Use for path/line/inventory discovery during implementation.
- gt-architect: Use for any architecture decisions not already covered by tasks.
- gt-code-quality-reviewer: Cross-language consolidated reviewer. Use as fallback when flutter-specific review is not needed.
- gt-security-reviewer: Use for any security-sensitive code (auth, API keys, secrets).
- gt-draft-writer: Small bounded writer. Use for changelog/report drafts.

### Execution Priority for Builders
1. First validate Flutter SDK works: flutter doctor, flutter analyze, flutter test
2. Execute original 02-doing/ tasks that have real unchecked subtasks (re-validate [x] Done claims)
3. Tasks 0001-0006 (mock corpus) — deliverables exist, need verification
4. Tasks 0010-0013 (foundation) — code exists, need flutter analyze validation
5. Tasks 0014-0018 (design system) — code exists in lib/design_system/
6. NEW tasks 1101-1123 — execute in wave order per architect's plan
7. Gate: Task 1107 (Melos migration) is the structural pivot point
