---
name: architecture
parent: flutter
description: Plan and audit Flutter feature architecture, layer boundaries, dependency direction, modularity, DI, and scalable app structure.
---

# Flutter Architecture

Use this route when planning or reviewing feature structure, app scaffolds, dependency direction, modularization, repository boundaries, or long-term maintainability.

## Architecture Axioms

- **Project stack first**: inspect `pubspec.yaml`, `analysis_options.yaml`, `lib/`, package structure, and current tasks before recommending patterns.
- **Dependency direction stays inward**: UI/presentation can depend on application/repositories; domain must not depend on Flutter widgets, UI packages, routing, or persistence implementation.
- **Feature boundaries beat type buckets** when product areas are independent; shared design-system/core utilities belong in explicit shared packages or `core/` with strict import direction.
- **Repositories return domain concepts**, not transport DTOs or storage models.
- **Dependency injection is explicit**: constructors, providers, or generated DI are acceptable when consistent; hidden singletons are review debt unless the project intentionally owns them.
- **No speculative framework swaps**: never replace an established Riverpod/BLoC/Provider architecture only because a reference repo prefers another.

## Review Checklist

- [ ] `lib/` structure maps to product features and shared core/design-system surfaces.
- [ ] Domain entities/value objects are pure Dart and do not import Flutter, UI widgets, storage SDKs, or generated data models.
- [ ] Data models and DTOs are mapped at repository/datasource boundaries.
- [ ] Business rules are outside widgets.
- [ ] Navigation, persistence, and network clients do not leak into domain objects.
- [ ] Shared widgets are promoted intentionally; no duplicate UI primitives across features.
- [ ] Architecture tests or import-boundary checks exist for high-risk packages.

## Common Anti-Patterns

- `lib/widgets/` or `lib/utils/` becoming a dumping ground.
- Screens directly opening storage boxes, files, sockets, SDK clients, or HTTP clients.
- Domain classes with `BuildContext`, `Widget`, `Color`, `Theme`, or route imports.
- State objects that mix DTO, entity, and view-model responsibilities.
- Feature code depending on sibling feature internals instead of public contracts.

## Evidence To Capture

- Package root and relevant manifests.
- Existing folder map and import examples.
- Any project rule or task that mandates Riverpod/BLoC/Freezed/GoRouter/design-system conventions.
- Analyzer/test commands used to prove the structure still compiles.

## Production Architecture Patterns (from reference corpus)

### Caching Mixin Strategy (achieve-flutter-architecture)
Production-proven 3-tier caching: Persistent (Hive/local DB), Secure (FlutterSecureStorage), Ephemeral (in-memory). Repositories inherit caching behavior via mixins rather than duplicating cache logic.

### DataPage Lifecycle (achieve-flutter-architecture)
Base screen pattern with automatic loading/error/refresh state management, OperationRunnerState for async operations, and PageReloaded event bus for cross-feature side effects.

### Freezed Sealed Classes (building-flutter-apps)
- Use `sealed class` for Freezed unions, never `abstract class`.
- Match with Dart native `switch`, never Freezed `.when()` / `.map()`.
- Value Objects: `@Freezed(map: FreezedMapOptions.none, when: FreezedWhenOptions.none)` for domain VOs.
- Domain entities get private `const` constructor for Rich Model methods.

### Reference corpus paths

- `references/achieve-flutter-architecture-skills/achieve-flutter-architecture/SKILL.md` — full production architecture with caching mixin.
- `references/building-flutter-apps/references/architecture.md` — 4-layer feature architecture.
- `references/building-flutter-apps/references/freezed-sealed.md` — Freezed/sealed union patterns.
- `references/building-flutter-apps/references/value-objects.md` — domain Value Object discipline.
- `references/RobertAlvv-flutter-skills/architecture-auditor/` — architecture audit methodology.
- `references/claude-code-dart-flutter/.claude/templates/feature.dart.template` — feature module scaffold template.
