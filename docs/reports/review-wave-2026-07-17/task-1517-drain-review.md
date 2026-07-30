# Drain Review: Task 1517 — Terminal Workspace Fixture Shell

> **Date**: 2026-07-17  
> **Reviewer**: independent (adversarial lifecycle deep-dive)  
> **Parent agentID**: reviewers  
> **Task**: `docs/tasks/03-review/1517-warp-prism-terminal-workspace-fixture-shell.md`  
> **Prior score**: 97 (2026-07-16)  
> **New score**: **86 / 100**  
> **Verdict**: **REJECT — return to doing**  
> **Lane**: `03-review` → **`02-doing`** (S<90)

## Review lineage

- `docs/reports/review/1517-terminal-workspace-fixture-shell-review-2026-07-16.md` (97) treated map dispose-on-widget-only as SAFE. This drain **rejects that leniency**.

## Live gates

| Gate | Result |
| --- | --- |
| Analyze | **No issues found** |
| Widget tests | **7/7 PASS** |
| Gallery | Terminal section demos present |
| Boundaries | **7/7** |
| No xterm/PTY | **PASS** |
| Format | **FAIL** implementation + test |

## Critical new finding (lifecycle)

### B1 — Pane close does not dispose per-pane controllers (MODERATE→Serious in long sessions)

**Evidence**:
- Allocation: `ds_terminal_workspace.dart:562-564` — `putIfAbsent` for `ScrollController`, `TextEditingController`, `FocusNode` keyed by `pane.id`.
- Close path: `closePane` at L142–150 only mutates `_panes` model; `_buildPaneTitleBar` L550 and tab `onClose` L432 call `controller.closePane` with **no** map eviction.
- Dispose path: L232–245 disposes all map values only when the **host State** dies.

**Impact**: Opening and closing N unique pane ids leaks 3N controllers until workspace unmount. Fixture demos that create/close panes accumulate native resources. Lifecycle Safety axiom fails for exclusive long-lived hosts.

**Required fix**:
```dart
void _disposePaneResources(String paneId) {
  _scrollControllers.remove(paneId)?.dispose();
  _textControllers.remove(paneId)?.dispose();
  _inputFocusNodes.remove(paneId)?.dispose();
}
// Call when controller panes lose an id (listener / didUpdate / close hooks).
```
Add widget test: open pane A, close A, assert no exception and (via diagnostic) maps empty or re-open reuses cleanly.

### B2 — Post-frame scroll lacks `mounted` / map-key guard (prior MODERATE, still open)

**Evidence**: L567–575 `addPostFrameCallback` calls `scrollController.animateTo` without `mounted` or map membership check. Race if State disposed mid-frame.

### B3 — Pane chrome touch targets 24×24 (prior LOW, still open)

**Evidence**: L529–554 `BoxConstraints(minWidth: 24, minHeight: 24)` on clear/close IconButtons.

### B4 — Format dirty

Owned `.dart` files fail `dart format --set-exit-if-changed`.

## Score math (start 100)

| Item | Δ |
| --- | ---: |
| B1 pane controller orphan on close | −8 |
| B2 post-frame dispose race | −3 |
| B3 24×24 chrome targets | −2 |
| B4 format | −1 |
| **Total** | **86** |

## Path to 100

1. Evict+dispose per-pane controllers when pane leaves `controller.panes` (listener reconcile).  
2. Guard post-frame scroll (`if (!mounted) return;` + map containsKey).  
3. Raise clear/close min constraints to 48×48 (or provide equivalent larger controls only + document WCAG exception with spacing).  
4. Format + re-run organism suite + boundaries.

## Lane action

**Move to `docs/tasks/02-doing/`**. Builder-scale lifecycle patch required; reviewer does not auto-patch S<90.
