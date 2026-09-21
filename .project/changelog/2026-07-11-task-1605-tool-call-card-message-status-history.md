---
date: 20260711-133638
timestamp: 20260711-133638
project: warp-prism
agent: gt-flutter-engineer
task: "1605"
description: "Add PrismToolCallCard + PrismMessageStatusHistory organisms (C-04/C-05 pack)"
is_rebuild_safe: true
---

# Task 1605: PrismToolCallCard + PrismMessageStatusHistory

## Summary

Implemented companion agent-transcript family organisms for EPIC-16 Wave K:

1. **PrismToolCallCard** (`DSToolCallCard`) — expandable glass tool-invocation
   card (name, args summary, args/result/error body, status badge).
2. **PrismMessageStatusHistory** (`DSMessageStatusHistory`) — compact pipeline
   status step strip (pending / running / success / error).

Fixture-first; public `Prism*` aliases; organisms barrel export; standalone
gallery cases plus optional composition inside `PrismAgentTranscript` custom
blocks (soft dep Task 1604 landed).

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/tool_call_card/`
  - `DSToolCallStatus`, `DSToolCallData`, `DSToolCallCard`
  - Fixtures: success / error / running / catalog
- Created `packages/warp_prism_ui/lib/src/organisms/message_status_history/`
  - `DSMessageStatusStepState`, `DSMessageStatusStep`, `DSMessageStatusHistory`
  - Horizontal + vertical layouts; empty steps safe
  - Fixtures: success / running / error trails
- Exported both barrels from `organisms.dart` (append-only)
- Aliased in `prism_aliases.dart`:
  - `PrismToolCallCard`, `PrismToolCallData`, `PrismToolCallStatus`
  - `PrismMessageStatusHistory`, `PrismMessageStatusStep`,
    `PrismMessageStatusStepState`
- Gallery (organisms section): standalone tool cards, status trails, and
  composed transcript demo embedding both via `DSAgentMessageBlock.custom`
- Widget tests for both organisms (happy / empty / error / a11y / composition)

## Non-goals honored

- No live tool execution / MCP / network
- No TraceDialog / subagent task trees
- No `DSLogViewer` duplication as tool card
- No teal Observatory rebrand
- No product route rewrite (ADS-first)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/tool_call_card \
  lib/src/organisms/message_status_history \
  lib/src/prism_aliases.dart lib/src/organisms/organisms.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/tool_call_card test/organisms/message_status_history
# No issues found (prefer_const infos fixed)

flutter test test/organisms/tool_call_card/ \
  test/organisms/message_status_history/
# 22/22 PASS

cd ../..
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Boundary harness: 6/6 PASS
```
