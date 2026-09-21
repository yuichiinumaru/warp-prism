---
date: 20260718-052900
timestamp: 20260718-052900
project: warp-prism
agent: gt-flutter-engineer
task: "1517"
description: "Terminal workspace pane controller lifecycle path-to-100 (drain S=86)"
is_rebuild_safe: true
---

# Task 1517: PrismTerminalWorkspace lifecycle remediation

## Summary

Path-to-100 after drain review S=86: dispose per-pane Scroll/Text/Focus controllers when panes leave the model; post-frame scroll uses `mounted` + map membership; clear/close chrome is 48×48; tests cover resource eviction and touch targets.

## Changes

- `ds_terminal_workspace.dart`: `_disposePaneResources` / `_reconcilePaneResources` on controller changes; `debugOwnedPaneResourceCount` for tests; post-frame auto-scroll guards; pane titlebar clear/close 48dp hosts.
- `ds_terminal_workspace_test.dart`: close-pane resource leak test; 48dp chrome target test; IconButton resolution via tooltip field (Flutter RawTooltip).

## Verification

- `dart analyze` (terminal_workspace lib+test): No issues found
- `flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub`: **10/10 PASS**
- Boundary harness: **7/7 PASS**
- No xterm/PTY deps
