# Warp Prism — ADS Package Purity and Interactive State Matrix Hygiene Guidelines

## 1. Purpose

This document establishes the official design system quality standards for packages/warp_prism_ui. It defines the constraints, naming structures, user interaction states, and testing requirements to prevent structural drift, duplicate ports of external components, and architectural boundary leaks.

These rules govern all developers working on EPIC-15, EPIC-16, and ongoing Atomic Design System (ADS) features.

---

## 2. Package Purity Constraints

To ensure warp_prism_ui remains a lightweight, portable, and pure presentation layer, the following constraints must be strictly observed:

### 2.1 Dependency Isolation
* The UI package must depend only on the Flutter SDK (as specified in packages/warp_prism_ui/pubspec.yaml).
* No external packages for state management, routing, or database/caching should be declared in dependencies.

### 2.2 Forbidden Imports and APIs
* No Riverpod: Imports of package:flutter_riverpod or package:riverpod are prohibited. All dependency injection and state providers must reside in the consumer application layer.
* No GoRouter: Imports of package:go_router are prohibited.
* No Navigator or Local Routing: The package must not push, pop, or manage routes. Navigation is requested via callbacks (e.g., VoidCallback, ValueChanged) or consumer controllers, allowing the host application to determine the routing outcome.
* No Platform IO: Banned imports like dart:io or checks like Platform.isAndroid that bind the package to native host environments. Use responsive breakpoints via LayoutBuilder or design parameters.
* No Local Persistence: Databases (SQLite, Hive, Isar) or key-value stores (SharedPreferences) must not be configured inside the UI package. Theme persistence must reside at the application level.

---

## 3. Naming Conventions and Alias Taxonomy

Warp Prism uses a dual-layer naming model to isolate internal implementation modules from the public API contract:

### 3.1 Internal Implementation (DS* Prefix)
* Component implementations under packages/warp_prism_ui/lib/src/ are named with the DS prefix (e.g., DSGlassPanel, DSInteractiveSurface, DSTaskCard).
* File names reflect their internal structure (e.g., ds_interactive_surface.dart).

### 3.2 Public API Layer (Prism* Prefix)
* The public barrel file (packages/warp_prism_ui/lib/warp_prism_ui.dart) exports only the aliases defined in packages/warp_prism_ui/lib/src/prism_aliases.dart.
* All public widgets, tokens, and data models must be exposed using a `Prism*` prefix (e.g., PrismGlassPanel, PrismInteractiveSurface, PrismColors).
* If a new DS* component is promoted to the public layer, a matching typedef alias must be added to packages/warp_prism_ui/lib/src/prism_aliases.dart:
  ```dart
  typedef PrismNewWidget = DSNewWidget;
  ```
* Direct import of packages/warp_prism_ui/src/ files by consumer applications is prohibited.

---

## 4. Interactive State Matrix Expectations

Every interactive component (atoms, molecules, and organisms) must support and visually distinguish the following semantic user state variations:

### 4.1 State Matrix

| State Name | Visual Treatment (Obsidian Glass Theme) | Pointer / Cursor | Behavior |
|------------|------------------------------------------|------------------|----------|
| Enabled | Obsidian background base + accented border colors | Click (SystemMouseCursors.click) | Interactive. Ready for click or touch input. |
| Focus | Focus ring (2px accentCyan at 50% opacity) | Click (SystemMouseCursors.click) | Receives tab/keyboard focus. Enter/Space calls primary callback. |
| Hover | Glow accent activation (cyan, violet, gold) | Click (SystemMouseCursors.click) | Ambient highlight. |
| Pressed | Slight opacity scaling or dark overlays | Click (SystemMouseCursors.click) | Temporary interaction feedback. |
| Disabled | Decayed opacity (0.5), gray borders, muted text | Basic (SystemMouseCursors.basic) | Non-interactive. Ignores focus and hit-tests. |
| Loading / Busy | Replaces action indicators with progress spinners | Basic (SystemMouseCursors.basic) | temporarily disables input, ignores pointer hit-tests. |

### 4.2 Callback Contract Rules
* Widgets must keep controllers and callbacks external.
* Action callback parameters should be nullable and defaulted to null (which naturally indicates the disabled state).
* Interactive widgets must wrap their core structure inside DSInteractiveSurface to ensure keyboard accessibility, SystemMouseCursors pointer switching, and minimum 48x48 dp touch targets.

---

## 5. Testing & Gallery Standards

No task implementing or modifying a UI component should be marked complete without providing catalog presence and passing the validation checks:

### 5.1 Gallery Integration
1. The component must be integrated into packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart.
2. It must demonstrate all major visual variants (e.g., success, warning, error, default) and interaction states (e.g., enabled, disabled, loading).
3. The catalog gallery can be rendered inside the custom catalog shell (apps/catalog/).

### 5.2 Test Specifications
* Widget tests must cover the default render path and each custom variant or constructor parameter.
* Semantics tests must verify that interactive surfaces announce themselves correctly to screen readers, follow keyboard focus order, and respond to input shortcuts (tab, space, enter).
* Boundary verification: The boundary checks in boundary_test.dart must continue to pass (currently 7/7 checks passing).

---

## 6. Forbidden Implementations (Anti-patterns)

To protect the integrity of the design system:
* Do NOT port external widgets: Do not import or copy external components like login forms, e-commerce templates, bottom sheets, or navigation scaffolds from references like judatop, ahmedm, or villa.
* Do NOT implement theme persistence within the package.
* Do NOT use Widgetbook or similar external dependencies in warp_prism_ui.
* Do NOT change the visual brand to green/teal: Keep the default Obsidian-glass branding (accents: cyan, violet, gold) as defined in DSColors.

---

## 7. Cross-References

* Boundary test: `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
* Contamination probe: `packages/warp_prism_ui/test/boundaries/contamination_probe.dart`
* Harvest report: `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
* Theme / catalog policy: `docs/design/token-theme-catalog-policy.md`
