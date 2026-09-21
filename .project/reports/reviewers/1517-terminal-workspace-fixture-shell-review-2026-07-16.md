# Task 1517 Review — PrismTerminalWorkspace Fixture Shell

> **Reviewer**: reviewers  
> **Date**: 2026-07-16  
> **Verdict**: PASS  
> **Score**: 97/100  
> **Lane routing**: stays in `docs/tasks/03-review/` because score is 90–99.

## Scope reviewed

- Task: `docs/tasks/03-review/1517-warp-prism-terminal-workspace-fixture-shell.md`
- Implementation:
  - `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Tests:
  - `packages/warp_prism_ui/test/organisms/terminal_workspace/ds_terminal_workspace_test.dart`

## Live evidence

```text
cd packages/warp_prism_ui
pwd && dart analyze lib/src/organisms/terminal_workspace/ test/organisms/terminal_workspace/ && flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub
/home/sephiroth/working/ganthritor/warp-prism/packages/warp_prism_ui
Analyzing terminal_workspace, terminal_workspace...
No issues found!
...
00:03 +7: All tests passed!
```

Boundary proof (wave run):

```text
cd /home/sephiroth/working/ganthritor/warp-prism
dart run melos run test-boundaries
Checks: 7/7 PASS
```

## Axiom compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PASS | Scoped `dart analyze` returned `No issues found!`. No suppressions needed. |
| Lifecycle Safety | PASS | The state owns dynamic Maps of `ScrollController`, `TextEditingController`, and `FocusNode`. `dispose()` at `ds_terminal_workspace.dart:232-246` removes the controller listener, disposes `_tabController` (after removing its listener), then disposes every cached scroll controller, text controller, and focus node. `didUpdateWidget` also detaches and reattaches the controller listener on controller swap. |
| Dependency Direction | PASS | Organisms import atoms/molecules/tokens and split-pane/tab-bar organisms. All 12 Prism aliases exist (`prism_aliases.dart:1068-1092`). Boundary harness 7/7 PASS. |
| UI Accessibility | PARTIAL | `DSTerminalWorkspace` counts 9 `Semantics(` and 6 `IconButton(` call sites. All 6 icon buttons have explicit `constraints: const BoxConstraints(minWidth: 48, minHeight: 48)`. Header buttons pass. Pane title bar `clearHistory` + close buttons at `ds_terminal_workspace.dart:529-554` have `minWidth: 24, minHeight: 24` constraints — too small for the 48x48 minimum touch target. |
| Proof Reality | PASS | 7 scoped widget tests passed live; coverage includes split layout, focus switch, empty state, tab layout, command submit, clear+close, and public alias. Tests use public barrel only (except one `src/` import for internal controller; not a consumer boundary concern). |
| Release Security | PASS | No xterm/PTY, no `dart:io`, no `print()`/`debugPrint()`. `widget.onCommandSubmitted?.call` is a fixture-only hook that never reaches a real process. |

## Exact counts

| Surface | Count | Disposition |
| --- | ---: | --- |
| `TextEditingController` map key allocation | 1 per pane (dynamic) | Each entry disposed in `dispose()`. SAFE. |
| `ScrollController` map key allocation | 1 per pane | Each entry disposed in `dispose()`. SAFE. |
| `FocusNode` map key allocation | 1 per pane | Each entry disposed in `dispose()`. SAFE. |
| `DSTabController` owned | At most 1 | Disposed in `dispose()` + listener removed before dispose. SAFE. |
| `addListener` / `removeListener` balances | 4 adds, 5 removes | Balanced; extra remove at `_syncTabController` is intentional pre-mutation guard. SAFE. |
| `addPostFrameCallback` unbounded | 1 per layout build | No `mounted` guard before the post-frame callback at `ds_terminal_workspace.dart:567-575`. DRIFT. |
| `IconButton` touch-target pass | 6 total, 4 rem 48x48 | 2 pane buttons (clear + close) are 24x24. SAFE for the 4 header/action buttons; LOW for the 2 pane chrome buttons. |

## Findings

### MODERATE — Missing `mounted` guard on post-frame scroll in `_buildTerminalPaneBody`

- **Evidence**: `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart:567-575`
- **Why it matters**: `WidgetsBinding.instance.addPostFrameCallback` fires after the next frame. If the widget is disposed before that frame, `scrollController.animateTo` or even `scrollController.hasClients` may throw on a disposed `ScrollController`. The pattern is already correct in `ds_agent_shell_panel.dart:219-227`. Terminal workspace should match.
- **Blast radius**: Low. Widget disposal racing a scheduled frame callback is unlikely in test fixtures but is a lifecycle correctness gap.
- **Required patch**:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!_scrollControllers.containsKey(pane.id)) return;
  final sc = _scrollControllers[pane.id]!;
  if (sc.hasClients) { ... }
});
```

Equivalent: guard with a `mounted`-safety check or validate the controller map key before use.

### LOW — Pane chrome `clearHistory` and close buttons do not meet 48x48 minimum

- **Evidence**: `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart:529-554`
- **Why it matters**: The task requires a11y labels on pane tabs/controls. Both have semantic labels. But `const BoxConstraints(minWidth: 24, minHeight: 24)` is below the required minimum touch target of 48x48.
- **Blast radius**: Low. In a dense console UI these mini buttons are acceptable desktop affordance patterns, but WCAG 2.1 Success Criterion 2.5.8 (minimum target size) recommends spacing of 24px with no larger penalty only when an equivalent control exists elsewhere. Here the header toolbar already provides larger equivalents. Still a compliance gap per the axiom.
- **Required patch**: set `minWidth: 48, minHeight: 48` on the two IconButton constraints in `_buildPaneTitleBar`.

## Path to 100

1. Add `mounted` guard or controller-map validation before `addPostFrameCallback` in `_buildTerminalPaneBody`.
2. Set `minimumSize: Size(48, 48)` in the `Tooltip`-decorated pane IconButton calls at `ds_terminal_workspace.dart:529` and `ds_terminal_workspace.dart:544`.
3. Re-run:
   - `dart analyze lib/src/organisms/terminal_workspace/ test/organisms/terminal_workspace/`
   - `flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub`
   - `dart run melos run test-boundaries`

## Score rationale

97/100. Analyzer, lifecycle disposal, boundary proof, and no-PTY contract are green. 1 point docked for missing post-frame guard in the pane body scroll handler, 1 point docked for 24x24 pane chrome buttons, 1 point docked for not enforcing minimum touch target in tests.

## Previous Reports

None; first review.