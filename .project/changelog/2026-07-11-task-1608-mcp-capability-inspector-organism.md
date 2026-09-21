---
date: 20260711-160000
timestamp: 20260711-160000
project: warp-prism
agent: gt-flutter-engineer
task: "1608"
description: "Add PrismMcpCapabilityInspector organism (C-08 CyberCore MCP inspect)"
is_rebuild_safe: true
---

# Task 1608: PrismMcpCapabilityInspector

## Summary

Implemented **PrismMcpCapabilityInspector** (`DSMcpCapabilityInspector`) —
capability-gated inspector for MCP tools / resources / prompts (plus optional
roots/ping stubs). Fixture-first CyberCore ops surface (EPIC-16 C-08 / Wave L).
No live MCP JSON-RPC client, no ALLOW/BLOCK mutation panels.

Public `Prism*` aliases; organisms barrel export; minimal gallery case;
widget + unit tests.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/mcp_capability_inspector/`
  - Models: `DSMcpCapabilities`, `DSMcpCapabilityKind`, tool/resource/prompt
    items, roots/ping stubs, selection payload
  - `DSMcpCapabilityInspector`: gated `DSTabBar` sections + list + detail
    (`DSSplitPane` / fixed list + `DSDetailInspector`)
  - Capability flags hide non-advertised sections
  - Selection (controlled / uncontrolled) with detail metadata
  - Disabled mock “Invoke” chrome on tools (no side effects)
  - Fixtures: standard tools/resources/prompts, tools+resources-only gating,
    empty capabilities, minimal pack
- Exported barrel from `organisms.dart` (append-only)
- Aliased in `prism_aliases.dart`:
  - `PrismMcpCapabilityInspector`, kinds/capabilities/items/selection
  - Fixture helpers (`prismMcpCapabilityInspector*`)
- Gallery (organisms section): fixture inspector demo
- Widget tests under `test/organisms/mcp_capability_inspector/`

## Non-goals honored

- No live MCP protocol / network client in ADS package
- No ALLOW/BLOCK mutation UIs
- No API keys / secrets
- No product route rewrite (ADS-first)
- No Observatory teal rebrand

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/mcp_capability_inspector \
  lib/src/prism_aliases.dart lib/src/organisms/organisms.dart \
  test/organisms/mcp_capability_inspector
# No issues found

flutter test test/organisms/mcp_capability_inspector/
# 11/11 PASS

cd ../..
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Boundary harness: 6/6 PASS
```
