# Warp Prism Real-Host UI Exercise Harness — Architecture Decision

> **Date**: 2026-09-04
> **Author**: `gt-builders-expert-flutter` (builders lane)
> **Status**: Implemented v1 (core + 3 hosts), pending independent review
> **Non-goal**: This document does not promote the harness to a mandatory gate.
> Independent review must prove it deserves promotion.

## 1. Existing machinery (source reality)

| Surface | What exists | Reuse verdict |
|---|---|---|
| Monorepo topology | `pubspec.yaml` workspace `packages/**` + `apps/**`; melos scripts `analyze/format/test/test-ui/test-observatory/test-catalog/test-cybercore/test-boundaries` | New package auto-joins workspace — no root `pubspec.yaml` edit, no melos edit |
| `warp_prism_testkit` | Pure-Dart runtime fakes + contract suites (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`); deps `meta/test/runtime` only | **Do not extend** — adding `flutter_test` would pollute pure contracts and collide with the parallel Karax mission |
| Catalog host | `WarpPrismCatalogApp` (2 sections, `catalog-nav-<id>` keys, `catalogThemeVariant` + `PrismTokenRegistry` skin wiring) | Smoke targets `key:catalog-nav-gallery`, `key:catalog-nav-connected-lab`; reset = fresh pump + variant reset + registry reset |
| Observatory host | `WarpPrismApp` + `ProviderScope`, `GoRouter` singleton (`/overview /map /operate /history /governance`, `/assets/:id`, `/design-system`, `/workspace-snapshot*`) | Smoke = shell branch taps; reset = fresh pump + `go('/overview')`; singleton router noted as limitation |
| CyberCore host | `WarpPrismCyberCoreApp({router})` + `createAppRouter()` factory (test-safe), 4 pilot branches, teal skin opt-in, `Material` ancestor already present in shell | Smoke = 4 pilot tabs; reset = fresh `createAppRouter()` pump |
| `DSInteractiveSurface` | `Semantics(label, button, enabled, selected)` + Enter/Space + focus ring + 48dp (`ds_interactive_surface.dart`) | Discovery source #1: `Semantics(button:true)` scan — no new instrumentation needed |
| IDS kernel | Pure-Dart selection/inspection/query/state-machine/input-normalizer | Semantic vocabulary for future state markers; v1 uses only route + candidate-count markers |
| Theme recipes | `PrismTheme.dark/taldarimRed/talonPurple`, `PrismCyberCoreTealSkin`, `PrismTokenRegistry.applySkin`, `DSTheme.accentOf/focusRingOf` (Task 1833) | Harness treats recipes as opaque ids; adapters own skin application |
| Capture harness | Honest `_captureScreenshot` (local `RepaintBoundary.toImage` primary, `takeScreenshot` demoted, `BLOCKED` on no-bytes, sabotage test) per Task 1834 | Reuse `_verifyPngArtifact` pattern for optional failure screenshots; never swallow `MissingPluginException` into PASS |
| Error handling | `DSErrorBoundary` (global-stack honest contract), `FlutterError.onError` collector pattern in `widget_test.dart` files | Oracle = `FlutterError.onError` collector + `ErrorWidget` tree scan + `tester.takeException`; `ErrorWidget.builder` override deliberately avoided (`flutter_test` rejects it) |
| Oracle-gap proof | Tasks 1831 (No Material), 1832 (RenderFlex overflow), 1834 (false PASS) | Known-bad controls replicate all three classes |

## 2. Candidate reuse considered and rejected

- **Extend `warp_prism_testkit`**: rejected — Flutter dependency would break pure-Dart contract layering.
- **Put harness in `warp_prism_ui`**: rejected — `warp_prism_ui` is presentation-only and must not import apps (reverse dependency `ui → apps` violates the dependency direction law).
- **Duplicate crawler per app**: rejected — spec forbids it; one shared runner, three thin adapters.
- **Pixel-coordinate / CV exploration**: rejected for v1 — apps already expose stronger semantic information (semantics + keys + tappable types).

## 3. Minimal new mechanism

New package `packages/warp_prism_host_exercise/` (dependency-light: `flutter` + `flutter_test` + `meta` only; zero warp deps):

```text
lib/warp_prism_host_exercise.dart          barrel
lib/src/models/exercise_action.dart        ExerciseCandidate (stable id)
lib/src/models/exercise_trace.dart         ExerciseStep + ExerciseTrace (seed JSON)
lib/src/models/host_config.dart            HostExerciseConfig (host-only deltas)
lib/src/models/viewport_matrix.dart        4-desktop matrix + compact
lib/src/models/theme_matrix.dart           opaque recipe ids
lib/src/safety/action_policy.dart          SAFE/STATEFUL/DESTRUCTIVE classifier
lib/src/oracle/error_oracle.dart           FlutterError + ErrorWidget scan + takeException
lib/src/discovery/action_discovery.dart    semantics → keys → tappables (sorted, deterministic)
lib/src/runner/exercise_runner.dart        SMOKE/CRAWL/FUZZ/REPLAY + viewport + hang guard
lib/src/artifacts/trace_writer.dart        JSON traces + replay commands
test/host_exercise_test.dart               policy/trace/config/viewport units (5)
test/known_bad_control_test.dart           oracle calibration: no-material, overflow,
                                           build-throw, healthy silence + discovery determinism (5)
```

Host adapters (new files only, inside each app's `integration_test/host_exercise/` —
never in `lib/`, so production shipping is untouched):

```text
apps/catalog/integration_test/host_exercise/catalog_host.dart
apps/catalog/integration_test/host_exercise/catalog_exercise_test.dart
apps/observatory/integration_test/host_exercise/observatory_host.dart
apps/observatory/integration_test/host_exercise/observatory_exercise_test.dart
apps/cybercore/integration_test/host_exercise/cybercore_host.dart
apps/cybercore/integration_test/host_exercise/cybercore_exercise_test.dart
```

Repo-level replay CLI (fits `tool/` conventions):

```text
tool/warp_ui_exercise.dart   dart-run trace replay helper (no flutter import)
```

Failure artifacts (existing canonical location, no new ledger):

```text
docs/reports/host-exercise/traces/<host>_<mode>_s<seed>_<ts>.json
```

## 4. Collision surfaces (parallel Karax mission)

| Surface | Risk | Mitigation |
|---|---|---|
| `packages/warp_prism_ui/lib/**` | Karax likely mutating Tasks 1831–1833 fixes | **Zero edits** — harness reads UI only via generic Flutter types |
| `packages/warp_prism_testkit/**` | Contract churn | **Zero edits** — new package, no testkit dep |
| `apps/*/lib/**` | Host feature work | **Zero edits** — adapters live in `integration_test/`, use public app entrypoints |
| `pubspec.yaml` (root), melos scripts | Shared orchestration | **Zero edits** — workspace glob picks up new package automatically |
| `AGENTS.md`, `MISSION.md`, parent skills | Governance | **Zero edits** (explicit isolation requirement) |
| Task lanes (`docs/tasks/**`) | Lane authority | **Zero moves** — no task claimed, moved, or closed |
| `docs/reports/captures/` | Visual gate | New sibling dir `docs/reports/host-exercise/`; captures dir untouched |
| `tool/` | One additive file | `warp_ui_exercise.dart` is new; `validate_mock_workspace.py` untouched |

## 5. Execution cadence contract

```text
FAST affected-host smoke  → before shared UI/integration promotion to review
FULL deterministic crawl  → wave closeout / pre-checkpoint
SEEDED FUZZ (+ known-bad) → checkpoint / milestone boundary, and after
                            high-blast-radius shell/theme/navigation changes
```

Never run full/fuzz after every tiny agent edit. Exit status is
machine-readable: test failure (non-zero) on any oracle/material error or
unreachable smoke target; trace JSON carries `errors[]` for Karax/review
gating.

## 6. What v1 deliberately does not do

- Below-fold discovery (only `hitTestable` candidates; scrolled content is a
  documented blind spot, partially covered by explicit smoke targets).
- Text entry (taps only; text-field focus is SAFE, content mutation is out).
- Visual taste judgments (theme mode proves propagation/errors, not aesthetics).
- Pixel/CV exploration (later independent evidence layer, not the foundation).
