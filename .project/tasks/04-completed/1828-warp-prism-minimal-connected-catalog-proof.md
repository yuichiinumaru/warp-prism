# Task 1828: Minimal Connected Catalog Proof (CONNECTED Mode)

> **Priority**: 🟡 P1 · **Type**: `feature`
> **Origin**: MISSION.md §30 (a minimal connected Catalog proof may occur before the first real product pilot) + Task 1825 open items
> **Blocks**: Pilot feasibility evidence (first real adapter consumption surface)
> **Depends on**: Task 1820 + Task 1823 (bindings + live FRB adapter PASS)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: Catalog CONNECTED mode — proves the full stack (Prism widget ← binding ← runtime contract ← FRB adapter ← Rust) is consumable by an app, not just by tests.
- **Strategic why**: every L1 claim so far is lab-grade (tests + integration suite); a minimal connected app surface converts lab proof into consumption proof without waiting for the pilot.
- **Consequence if absent**: "integration-capable" rests only on test harnesses; the pilot becomes the first-ever real consumer with no smaller step in between.

## Objective

Add a minimal CONNECTED section to `apps/catalog`: one bounded page that renders live FRB-backed data through the full v2 stack (GraphSource or HealthSource via binding + adapter), clearly labeled CONNECTED vs the existing STATIC/INTERACTIVE sections. NOT a registry/resolver — MISSION.md §30 forbids generalized machinery before recurrence.

## Scope

- Read `apps/catalog/lib/main.dart` (routing/sections pattern) + `packages/warp_prism_bindings/` + `packages/warp_prism_adapter_frb/` (WarpBridge.init loading).
- Add ONE page (e.g. "Connected Bridge Lab"): loads the native lib via `WarpBridge.init()`, instantiates FrbGraphSource (or FrbHealthSource), projects through GraphSourceBinding into a PrismGraphCanvas (or health matrix organism), and lets the user trigger a native mutation (addNode button) seeing the update stream flow live.
- Catalog labeling: CONNECTED badge on the section (STATIC/INTERACTIVE/CONNECTED modes per MISSION.md §30).
- Apps MAY import bindings + adapter (layer law allows apps → {ui, bindings, adapter}); ui package stays pure.
- Fallback handling: if the native lib fails to load, the page shows a deterministic "bridge unavailable" state (fixture mode), not a crash — this also documents the offline story.
- Tests: widget test with the fake adapter (fake-mode path) + a smoke test that the page builds; the CONNECTED live path is exercised by the existing adapter integration suite (87 tests) — do not duplicate FFI tests here.

## Validation Commands

```bash
cd apps/catalog && flutter analyze . && flutter test test/widget_test.dart   # >10 pass incl. new page
cd ../.. && dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .   # 13/13 (check 2: no src/ imports; apps may import packages)
```

## Where

| File | Purpose |
|---|---|
| `apps/catalog/lib/` | Extend — one connected page + section registration |
| `apps/catalog/test/` | Extend — page widget test |

## Exit Conditions

- [x] One CONNECTED page live-projects FRB-backed data through binding→widget.
- [x] CONNECTED mode labeled distinctly from STATIC/INTERACTIVE.
- [x] Deterministic bridge-unavailable fallback (no crash).
- [x] Catalog analyze clean + tests pass; boundary harness 13/13.
- [x] No registry/resolver/generalized machinery added.
- [x] Local changelog entry proposed in packet.

## Completion Evidence

- **Files created**: apps/catalog/lib/connected/connected_bridge_lab_page.dart + test/connected_bridge_lab_page_test.dart; main.dart (section nav + CONNECTED badge); pubspec (+runtime/bindings/adapter deps, dev testkit); analysis_options (experimental_member_use ignore).
- **Architecture**: constructor injection seam (source + bridgeInit) — live path WarpBridge.init→FrbGraphSource→GraphSourceBinding→PrismGraphCanvas; deterministic fallback (in-memory fixture, FIXTURE MODE (FAKE) badge, no crash); interactive addNode→native mutation→watchUpdates→live refresh; bridge-alive echo indicator.
- **Boundary law**: apps may import barrels (layer law); grep flutter_rust_bridge in apps/catalog/lib = 0; no src/ imports (check 2); no registry/resolver (MISSION §30).
- **Tests**: catalog analyze clean; flutter test = **14/14** (fallback mode, injected testkit fakes, stream updates, section switching); boundary 15/15.
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (2026-09-02)
- **Completion date**: 2026-09-02
- **Review trail**: bundled independent review **PASS 96/100** — injection seams real, fallback deterministic + honestly labeled FAKE vs CONNECTED, no machinery added, barrel-only imports confirmed.
