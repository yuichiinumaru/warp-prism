# Report 1805: Visual Acceptance Gate Infrastructure & Golden Policy Audit

> **Task**: Task 1805 (`1805-warp-prism-screenshot-visual-acceptance-gate.md`)
> **Date**: 2026-08-23
> **Status**: `INFRASTRUCTURE_READY_PENDING_USER_VISUAL_SIGN_OFF`
> **Golden Freeze Policy**: `FROZEN_PENDING_USER_CONVERGENCE`
> **Evidence correction**: Candidate PNG artifacts were not produced in this headless run. Integration tests verify widget/specimen wiring; `takeScreenshot` is unavailable on the Linux desktop plugin channel (`MissingPluginException`).

---

## Executive Summary

Task 1805 establishes visual correctness as a mandatory release gate for `warp-prism`. Analyzer clean and unit/widget test success are necessary but insufficient for visual promotion. This report documents:

1. **Golden Suite Theme Migration**: All 13 golden test suites in `packages/warp_prism_ui/test/goldens/` plus atom test suites with ad-hoc theme wrappers have been migrated from `ThemeData.dark()` to the canonical `PrismTheme.dark()` factory (Task 1803).
2. **Deterministic Capture Infrastructure**: Desktop `integration_test` capture suites have been created across all 3 app hosts (`apps/catalog` as canonical host, plus `apps/observatory` and `apps/cybercore` as secondary hosts) running at desktop 1280x800 resolution (DPR 1.0).
3. **Golden Freeze & User Gate Enforcement**: Per EPIC-18 convergence policy, goldens remain frozen (`[ ]` un-regenerated) until the human product owner iterates with the Task 1807 Theme Editor in Catalog, converges visual hexes, and explicitly approves committed screenshot artifacts.

---

## 1. Deterministic Capture Suite Specifications

| Host App | Viewport | Target Specimen / Organism | Test Command | Capture Status |
| --- | --- | --- | --- | --- |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Typography Specimen (Rajdhani UI / JetBrainsMono Tech & Numeric) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` | `PASS` widget wiring; `PENDING-USER` PNG (driver unavailable) |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Token Swatches Palette (Obsidian Deep/Base/Elevated + Accents) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `BLOCKED` full suite app startup/log-reader failure; PNG unavailable |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Dense Organism (`PrismProviderHealthMatrix`) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `BLOCKED` full suite app startup/log-reader failure; PNG unavailable |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Form Primitive (`PrismTextField` + `PrismButton` + `PrismCheckbox`) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `BLOCKED` full suite app startup/log-reader failure; PNG unavailable |
| `apps/observatory` | 1280x800 @ 1.0 DPR | Observatory Overview Dashboard & Shell | `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` | `BLOCKED` 180s startup/log-reader timeout; PNG unavailable |
| `apps/cybercore` | 1280x800 @ 1.0 DPR | CyberCore Shell with `PrismCyberCoreTealSkin` | `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` | `BLOCKED` 180s startup/log-reader timeout; PNG unavailable |

---

## 2. Review Checklist Scaffolding (Binary Gate)

The binary checklist for final human visual sign-off:

| Criteria Item | Interim Status | User Convergence Target |
| --- | --- | --- |
| background is black obsidian, not blue | `PENDING-USER` | #080C0E / #030506 black obsidian base |
| surfaces neutral near-black with restrained elevation | `PENDING-USER` | #0C1114 / #12181C elevation |
| blue confined to action/focus/highlight roles | `PENDING-USER` | #2F81FF action primary |
| semantic green/amber/red remain meaningful | `PENDING-USER` | Status colors intact |
| no excessive teal/green/rainbow chrome | `PENDING-USER` | Restrained accents |
| no persistent high-intensity blue ambient glow | `PENDING-USER` | Glow budget clean |
| UI typography readable and non-mono in interface roles | `PENDING-USER` | Rajdhani UI font family |
| JetBrains Mono only in technical roles | `PENDING-USER` | JetBrainsMono code/numeric |
| contrast/focus states accessible | `PENDING-USER` | WCAG AA compliance |
| density matches approved reference intent | `PENDING-USER` | Desktop density |
| Catalog and app hosts render the same theme contract | `PENDING-USER` | Canonical `PrismTheme.dark()` wiring |

---

## 3. Golden Policy Handoff & Freeze Statement

1. **Task 1800 Freeze Liftoff Condition**:
   Golden regeneration (`flutter test --update-goldens`) is **prohibited** until the human product owner completes the interactive visual convergence session using the Task 1807 Theme Editor in Catalog (`apps/catalog`), confirms converged hex tokens, and signs off on captured screenshot artifacts.

2. **Single Deliberate Refresh Execution**:
   Once user sign-off statement is recorded and linked, golden files across `packages/warp_prism_ui/test/goldens/` will be refreshed exactly once (`flutter test --update-goldens test/goldens/`), committing new PNG baselines aligned with the user-approved contract.

3. **Rejection Artifact Preservation**:
   Any visually rejected output must be saved under `docs/reports/captures/rejected/` with timestamp and rejection notes. It must never be silently overwritten or discarded.

---

## 4. Verification Evidence

- `cd packages/warp_prism_ui && dart analyze` (PASS, 0 errors; 217 existing infos)
- `cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart` (PASS, no issues)
- `cd apps/observatory && flutter analyze integration_test/observatory_visual_capture_test.dart` (PASS, no issues)
- `cd apps/cybercore && flutter analyze integration_test/cybercore_visual_capture_test.dart` (PASS, no issues)
- `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` (PASS, 1/1; `takeScreenshot` logged `MissingPluginException`, no PNG produced)
- `cd apps/catalog && flutter test integration_test/` (FAIL, full suite app startup: `Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.`)
- `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` (BLOCKED, 180s startup/log-reader timeout: `Bad state: Cannot close sink while adding stream.`)
- `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` (BLOCKED, 180s startup/log-reader timeout: `Bad state: Cannot close sink while adding stream.`)
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (PASS, 7/7)
- `cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub` (FAIL, 59 golden failures against frozen legacy baselines; expected while `PENDING-USER`)
