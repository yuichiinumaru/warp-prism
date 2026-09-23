---
name: dart-language
parent: flutter
description: Apply modern Dart, null-safety, type modeling, analyzer, documentation, package, and code-generation correctness without owning public API architecture.
---

# Dart Language Discipline

Use this route for `.dart` correctness, analyzer/lint failures, language
semantics, documentation correctness, package mechanics, and code generation.

> **Scope boundary:** this route owns Dart *correctness*. Public-contract
> architecture — exported surfaces, stability/experimental boundaries, failure
> protocol, compatibility evolution, stream/cancellation contract design, and
> the choice of class modifiers for a public boundary — belongs to
> `api-design/sub-skills/design-dart-api`.

## Core Axioms

- **Null safety is explicit.** Prefer total constructors, guards, pattern
  matching, and typed fallbacks over avoidable `!`.
- **Unknown data is contained.** Prefer a specific type or `Object?`; keep
  transport/JSON shapes at the boundary and map them promptly.
- **Finite states deserve explicit modeling** when that improves exhaustiveness
  and clarity.
- **Modern Dart features are tools, not mandates.** Records, patterns, switch
  expressions, class modifiers, extension types, and null-aware elements are
  adopted when they improve the active codebase.
- **Generated code must be reproducible.** The generator command and generated
  artifact policy must be known when generated surfaces change.
- **Documentation is part of public correctness** when callers depend on it.

## Public-API Routing

Language correctness can tell whether a modifier is legal and what it means.
It does not decide universally that every repository must be an
`abstract interface class`, every hierarchy must be sealed, or every error must
use one result type.

When the question is "which public contract should we expose?", load
`api-design/sub-skills/design-dart-api`.

## Review Checklist

- [ ] Types/nullability reflect actual semantics.
- [ ] No avoidable `dynamic`, unchecked `!`, or untyped collection leakage.
- [ ] Async APIs expose meaningful `Future<T>` / `Stream<T>` semantics and do
      not silently swallow failures.
- [ ] Equality, immutability, and copy behavior match project conventions.
- [ ] Generated outputs are in the state required by repository policy.
- [ ] Public docs/links are current where they are part of the contract.
- [ ] Analyzer findings are resolved or explicitly scoped by the task/project.

## Default Commands

Prefer project-defined commands. Otherwise, from the correct Dart package root:

```bash
dart format --set-exit-if-changed .
dart analyze
dart test
```

Do not claim Flutter-specific proof from Dart-only commands.

## Common Smells

- Long nullable chains ending in `!`.
- `dynamic`/JSON shapes spreading into domain/UI state.
- Public APIs exposing persistence/transport implementation records by accident.
- Hand-edited generated code.
- Stale public-doc references.
- Applying a reference-repo style rule globally without checking current project
  conventions.

## Code Generation

When the project uses `build_runner`, use the project-declared invocation.
A common fallback is:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not run destructive clean/regeneration merely because a reference recipe says
so; read repository and dependency/codegen policy first.

## Analysis Configuration

`../../scripts/analysis_options.reference.yaml` is an **experimental reference
configuration**, not a universal lint policy. Compare it with the project’s
current analyzer/lint setup before adopting any rule or plugin.
