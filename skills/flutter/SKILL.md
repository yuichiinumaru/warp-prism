---
name: flutter
description: |
  Flutter and Dart governance for Ganthritor-family projects. READ THIS FIRST before
  designing, implementing, reviewing, testing, debugging, or releasing Flutter/Dart
  code. Routes to narrow subskills and host-composition workflows without treating
  external reference repositories or experimental scripts as active doctrine.
sub-skills-index:
  - architecture: "Plan feature/layer boundaries, dependency direction, domain purity, DI, and scalable Flutter app structure."
  - dart-language: "Apply modern Dart, null-safety, analyzer, documentation, package, and code-generation discipline."
  - state-management: "Choose and audit Riverpod/BLoC/provider lifecycle, rebuild scope, async guards, and mutation flow."
  - testing: "Design unit/widget/golden/package-integration/real-host/e2e evidence and match proof strength to the claim."
  - ui-ux: "Build adaptive, accessible, localized, token-driven Flutter UI and design-system surfaces. Owns Flutter-side atomic design-system governance (classify, token domain×role, dark-first theme, DS a11y gates, harvest migration) merged from frontend-quality 2026-09-23."
  - security: "Audit source and APK/AAB security, permissions, secrets, WebView/deep-link risk, and release artifact evidence."
  - performance: "Diagnose widget rebuilds, frame budget, layout cost, async/runtime efficiency, isolates, and caching."
  - navigation: "Govern routing, deep links, modal boundaries, route guards, and state restoration according to the project stack."
  - data-layer: "Design repositories, datasources, API clients, persistence boundaries, migrations, DTO mapping, and offline/cache behavior."
  - devops-release: "Run Flutter/Dart verification, codegen, CI, toolchain triage, signing, stores, and release preflight."
workflows:
  - sk-flutter-flutter-development-preflight: "Before/after implementation verification for Flutter/Dart work."
  - sk-flutter-flutter-review-wave: "Flutter/Dart domain review workflow; independent acceptance remains with code-quality."
  - sk-flutter-host-composition: "Contract-minimal wrappers, consumer-shell proof, constraint/viewport probes, and real-host evidence for shared/reusable surfaces."
triggers:
  - flutter
  - dart
  - riverpod
  - bloc
  - gorouter
  - go_router
  - widget test
  - golden test
  - real host composition
  - apk security
  - aab security
  - flutter analyze
  - dart analyze
  - pubspec.yaml
  - flutter release
---

# Flutter Harness

This is the parent-canonical gateway for Flutter and Dart praxis.

**Load this root first, then load only the relevant subskill/workflow.**
External source repositories are provenance/corpus, not a second routing tree and
not active authority.

## Routing

```text
What are you doing?
├── Planning feature/layer structure?  → sub-skills/architecture/SUBSKILL.md
├── Dart correctness/language work?    → sub-skills/dart-language/SUBSKILL.md
├── Providers/state lifecycle?         → sub-skills/state-management/SUBSKILL.md
├── Creating tests or proof?           → sub-skills/testing/SUBSKILL.md
├── Shared/reusable host composition?  → workflows/sk-flutter-host-composition.md
├── UI/design-system/accessibility?    → sub-skills/ui-ux/SUBSKILL.md
├── Security/artifact risk?            → sub-skills/security/SUBSKILL.md
├── Jank/performance?                  → sub-skills/performance/SUBSKILL.md
├── Routing/deep links?                → sub-skills/navigation/SUBSKILL.md
├── APIs/persistence/data boundaries?  → sub-skills/data-layer/SUBSKILL.md
└── Tooling/CI/release?                → sub-skills/devops-release/SUBSKILL.md
```

For public Dart API-contract design, route additionally to
`api-design/sub-skills/design-dart-api`.

For dependency, lockfile, pub/Cargo, FRB-version, or codegen ownership policy,
route to `dependency`.

For an already-failing runtime surface, let `remediation` diagnose first and
route back to the relevant Flutter praxis.

## Non-Negotiable Operating Rules

1. **Source reality first.** Read the current project before selecting Riverpod,
   BLoC, Freezed, GoRouter, Drift, FVM, Firebase, Widgetbook, or any reference
   pattern. Existing project contracts outrank reference-corpus preferences.
2. **Project commands first.** Run analysis/tests from the correct package root
   and prefer project-defined commands over generic recipes.
3. **No phantom validation.** Missing SDK/device/native host means the affected
   evidence is unavailable or blocked, not PASS.
4. **Generated artifacts are reproducible outputs.** Record the generator and
   whether generated files changed; dependency/codegen ownership policy remains
   with `dependency`.
5. **Respect active project persistence policy.** Backend/storage choices are
   project/family policy, not universal Flutter doctrine. This skill governs the
   Flutter-side boundary, not which database a product must use.
6. **Security-sensitive edits require the authority required by the active
   project/harness.** Do not silently mutate signing, auth, permissions,
   payments, production endpoints, publishing, privacy, or dependency policy.
7. **UI claims include accessibility/adaptivity when applicable.** Desktop-first
   does not erase keyboard/focus/semantics/text-scaling concerns.
8. **Tests prove behavior, not presence.** Instantiating a widget or observing a
   mock call is insufficient when the claim concerns visible behavior, state
   transitions, error behavior, routing, or composition.
9. **Package PASS is not host PASS.** Package-local evidence never proves that a
   shared/reusable component composes correctly in a real consumer host.
   `real-host-composition` is a distinct evidence class for that claim. Never
   swallow framework errors merely to keep a test green.

See `sub-skills/testing/SUBSKILL.md` for evidence classes and
`workflows/sk-flutter-host-composition.md` for the host-composition procedure.

## Baseline Commands

Use project-specific commands when present. Otherwise, depending on the package:

```bash
dart analyze
dart test
flutter analyze
flutter test
```

Run dependency-mutating commands only under the active dependency policy.

Golden refreshes require explicit intent; do not update snapshots merely to make
a failing test pass.

## Reference Corpus and Experimental Tools

- `references/source-repos.md` is provenance/discovery material.
- `references/scripts-status.md` is the authority for the status of copied
  scripts/config candidates.
- Files marked `experimental` are **not Ganthritor enforcement** merely because
  they exist under `scripts/`. They require host adaptation, calibration,
  documented I/O/side effects, and review before canonization.

## Boundary: When Not To Use

Do not use this skill for non-Flutter UI stacks, native-only Swift/Kotlin work,
backend-only Dart with no Flutter concern, or generic review where no Flutter/Dart
surface is material.
