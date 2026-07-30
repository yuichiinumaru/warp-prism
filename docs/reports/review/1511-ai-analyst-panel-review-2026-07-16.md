# Task 1511 Independent Re-Review — PrismAiAnalystPanel

- **Date**: 2026-07-16
- **Reviewer profile**: reviewers
- **Scope**: `docs/tasks/03-review/1511-warp-prism-ai-analyst-panel-fixture-organism.md`, AI analyst panel source/tests, Prism aliases, gallery registration, boundary harness
- **Score**: 74/100
- **Verdict**: REJECT — route back to `docs/tasks/02-doing/`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Required `dart analyze lib test` returned **141 info-level issues**. Scoped reviewed surfaces were clean. |
| Lifecycle Safety | FAIL | Async `send()` can notify after controller/panel disposal; post-frame scroll callback lacks `mounted` guard. |
| Dependency Direction | PASS | No live network/model/API-key paths; boundary harness **7/7 PASS**. |
| UI Accessibility | PARTIAL | Composer/send controls have labels and 48dp target; streaming indicator ignores reduced motion. |
| Proof Reality | PARTIAL | Scoped tests pass live, but package analyzer and format gate are red; tests do not cover dispose-during-stream. |
| Release Security | PASS | Grep found no http/HttpClient/api_key/localStorage/sqlite/MapLibre/dio paths under `ai_analyst_panel`. |

## Live Commands

```text
cd packages/warp_prism_ui

dart analyze lib test
# FAIL: 141 info-level issues

flutter test test/organisms/status_ticker/ test/organisms/watchlist_dock/ test/organisms/coordinate_status_bar/ test/organisms/map_legend/ test/organisms/osint_workbench/ test/organisms/ai_analyst_panel/
# PASS: 61 tests

dart run test/boundaries/boundary_test.dart
# PASS: 7/7

dart analyze lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel ...
# PASS: No issues found

dart format --output=none --set-exit-if-changed [reviewed organism/test paths]
# FAIL: would change 12 files, including ai_analyst_panel source/test
```

## Findings

### CRITICAL — Async send can notify after controller disposal
- **Evidence**: `DSAiAnalystController.send()` awaits `Future.delayed(streamSimulationDelay)` at `ds_ai_analyst_panel.dart:394-396`, then later calls `notifyListeners()` in `finally` at `ds_ai_analyst_panel.dart:438-440`. `DSAiAnalystPanel.dispose()` disposes the owned controller at `ds_ai_analyst_panel.dart:640-645` via `_unbind()` at `ds_ai_analyst_panel.dart:619-623` without cancelling in-flight `send()`.
- **Impact**: If a user sends a message and the panel is removed before the simulated stream completes, the disposed `ChangeNotifier` can be used after disposal. This violates Lifecycle Safety.
- **Fix**: Add disposal/cancellation state in `DSAiAnalystController` (override `dispose()`, set `_disposed = true`, check after every await before mutating/notifying) or make `send()` cancellable. Add a widget/controller test that starts a delayed send, disposes the panel/controller, pumps past the delay, and expects no Flutter errors.

### MODERATE — Post-frame scroll callback can touch state after widget disposal
- **Evidence**: `_onControllerChanged()` schedules `WidgetsBinding.instance.addPostFrameCallback` at `ds_ai_analyst_panel.dart:629-636`; the callback checks `_scroll.hasClients` but does not check `mounted` before reading/animating the controller.
- **Impact**: Panel disposal between scheduling and callback execution risks use-after-dispose on `_scroll`.
- **Fix**: Add `if (!mounted || !_scroll.hasClients) return;` inside the callback before using `_scroll`.

### MODERATE — Package analyzer exit condition is red
- **Evidence**: `dart analyze lib test` returned **141** info-level issues.
- **Impact**: The task’s validation command is not satisfied.
- **Fix**: Clean/rebaseline package analyzer or document a governance-approved scoped gate.

### MODERATE — Format gate fails for this organism
- **Evidence**: non-mutating format reported `Changed lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart` and `Changed test/organisms/ai_analyst_panel/ai_analyst_panel_test.dart`.
- **Impact**: Unformatted source cannot pass.
- **Fix**: Run `dart format lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel` and re-run `--set-exit-if-changed`.

### LOW — Streaming progress indicator has no reduced-motion override
- **Evidence**: `CircularProgressIndicator` is always used for streaming at `ds_ai_analyst_panel.dart:999-1011` and send busy state at `ds_ai_analyst_panel.dart:1248-1256`.
- **Impact**: Accessibility is weaker for reduced-motion users.
- **Fix**: Respect `MediaQuery.disableAnimationsOf(context)` and render a static icon/text alternative when animations are disabled.

## Exact Counts

- Lifecycle-managed objects in panel state: **4** (`TextEditingController`, `ScrollController`, `FocusNode`, optional owned `DSAiAnalystController`).
- Matching disposals/removals: **4** direct disposals, but async cancellation is **0**, causing the critical lifecycle finding.
- Public Prism aliases verified for 1511: **5** (`PrismAiAnalystPanel`, turn, role, turn status, controller).
- Network/API-key/storage paths under `ai_analyst_panel`: **0** matches beyond policy text.

## Path to 100

1. Fix `DSAiAnalystController.send()` disposal/cancellation safety and add a dispose-during-stream regression test.
2. Add `mounted` guard inside the post-frame scroll callback.
3. Format AI analyst source/test and re-run non-mutating format check.
4. Resolve/rebaseline package analyzer so `dart analyze lib test` is clean.
5. Add reduced-motion handling for streaming/busy indicators and a widget test with `MediaQueryData(disableAnimations: true)`.
6. Re-run scoped tests, package analyzer, boundary harness, and format gate.
