---
name: sk-flutter-flutter-review-wave
description: "Flutter Review Wave"
---

# Flutter Review Wave

Use this workflow for reviewer or architect-led Flutter/Dart audits.

## 1. Route the Review

Load `code-quality` first for review scoring and report lineage. Then load `flutter` and the relevant sub-skills:

- Architecture/layers → `architecture`
- Providers/state → `state-management`
- Tests/proof → `testing`
- UI/design/accessibility → `ui-ux`
- Artifact or source risk → `security`
- Jank/perf → `performance`
- Routing/deep links → `navigation`
- Data/persistence → `data-layer`
- CI/release/toolchain → `devops-release`

## 2. Evidence Preflight

- Resolve the actual package root and current lane/task state without assuming old paths.
- Read relevant code before scoring.
- Prefer project commands and current task exit conditions over generic commands.
- Treat missing Flutter SDK as an environmental blocker, not a passed gate.

## 3. Review Dimensions

Score with the code-quality harness 0-100 rubric, using Flutter dimensions as evidence:

- Dart/analyzer/type-safety/language correctness.
- Architecture and dependency direction.
- State lifecycle and async safety.
- UI, accessibility, responsive behavior, and design-system consistency.
- Test adequacy and non-vacuous proof.
- Security/privacy/release artifact risk when relevant.
- Performance evidence and regression risk.
- CI/toolchain/release reproducibility.

## 4. Report

Use `code-quality/workflows/sk-code-quality-review-report-lineage.md` for task reviews. Include:

- Score and lane routing recommendation.
- Findings with file/line evidence where possible.
- Missing command evidence and environmental blockers.
- Path to 100 with minimal, ordered repairs.
- Whether Flutter/Dart SDK gates were run, skipped, or blocked.

## 5. Closeout

- Record review verdict with `agent-wiki --profile reviewers --type review` for review-lane work, or `architects` for architecture-only audits.
- If a recurring Flutter failure pattern appears, propose a harness update or task rather than burying it in a single review report.
