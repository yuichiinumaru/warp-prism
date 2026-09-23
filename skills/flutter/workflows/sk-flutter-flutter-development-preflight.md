---
name: sk-flutter-flutter-development-preflight
description: "Flutter Development Preflight"
---

# Flutter Development Preflight

Use this workflow before and after Flutter/Dart implementation sessions.

## 1. Scope and Evidence

- Read the task or user request completely.
- Identify package root(s), current stack, and relevant manifests: `pubspec.yaml`, `analysis_options.yaml`, generated-code config, and project instructions.
- Load the relevant `flutter` sub-skill route(s).
- State assumptions and blockers before editing.

## 2. Pre-Change Gate

- Read existing code and neighboring patterns before modifying.
- If tests are required, identify or create the failing proof first.
- If Flutter/Dart SDK is unavailable, record the blocker and avoid implementation claims that require SDK proof.

## 3. Implementation Guardrails

- Touch the smallest relevant files.
- Preserve current state-management, routing, design-system, and persistence conventions.
- Do not silently change security-sensitive release/auth/payment/permission/publishing behavior.
- Keep generated-code commands explicit.

## 4. Post-Change Verification

Run project-specific commands. If absent, prefer this order when available:

```bash
dart analyze
dart test
flutter test
```

Add `dart run build_runner build --delete-conflicting-outputs`, `flutter build`, golden tests, or integration tests only when the touched surface requires them.

## 5. Evidence and Handoff

- Record files changed, commands, exit status, SDK/tool blockers, generated files, and remaining risks.
- If reusable knowledge was created, update the appropriate skill/workflow/report and then add an `agent-wiki` continuity or learning entry.
