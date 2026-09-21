# Report 1805: Visual Acceptance Gate Infrastructure & Golden Policy Audit

> **Task**: Task 1805 (`1805-warp-prism-screenshot-visual-acceptance-gate.md`)
> **Date**: 2026-08-23
> **Status**: `INFRASTRUCTURE_READY_PENDING_USER_VISUAL_SIGN_OFF`
> **Golden Freeze Policy**: `FROZEN_PENDING_USER_CONVERGENCE`
> **Evidence correction**: The initial headless run produced no candidate PNGs because `takeScreenshot` is unavailable on the Linux desktop plugin channel (`MissingPluginException`). The 2026-09-03 remediation now produces six local rendered candidate PNGs across all three hosts; human visual approval and golden refresh remain pending.

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
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Typography Specimen (Rajdhani UI / JetBrainsMono Tech & Numeric) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` | `PASS` local candidate PNG; driver fallback unavailable; `PENDING-USER` visual approval |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Token Swatches Palette (Obsidian Deep/Base/Elevated + Accents) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `PASS` local candidate PNG; `PENDING-USER` visual approval |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Dense Organism (`PrismProviderHealthMatrix`) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `PASS` local candidate PNG; `PENDING-USER` visual approval |
| `apps/catalog` (Canonical) | 1280x800 @ 1.0 DPR | Form Primitive (`PrismTextField` + `PrismButton` + `PrismCheckbox`) | `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart` | `PASS` local candidate PNG; `PENDING-USER` visual approval |
| `apps/observatory` | 1280x800 @ 1.0 DPR | Observatory Overview Dashboard & Shell | `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` | `PASS` local candidate PNG; deterministic repeated hash; `PENDING-USER` visual approval |
| `apps/cybercore` | 1280x800 @ 1.0 DPR | CyberCore Shell with `PrismCyberCoreTealSkin` | `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` | `PASS` local candidate PNG; deterministic repeated hash; `PENDING-USER` visual approval |

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
- `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` (historical PASS, 1/1; `takeScreenshot` logged `MissingPluginException`; local PNG remediation now produces all four candidates)
- `cd apps/catalog && flutter test integration_test/` (FAIL, full suite app startup: `Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.`)
- `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` (PASS, 1/1; bounded pumps; local candidate rendered; repeated hash identical after test-only ticker isolation)
- `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` (PASS, 1/1; bounded pumps; local candidate rendered; repeated hash identical)
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (PASS, 7/7)
- `cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub` (FAIL, 59 golden failures against frozen legacy baselines; expected while `PENDING-USER`)

---

## 5. Current Capture Remediation — 2026-09-03

The Catalog harness was remediated after the initial `MissingPluginException`
evidence gap. Each specimen is now rendered inside a bounded
`RepaintBoundary`; `RenderRepaintBoundary.toImage(pixelRatio: 1.0)` writes a
non-empty candidate PNG before the best-effort driver screenshot call. The
driver-channel exception remains observable but cannot mask a missing local
artifact.

| Artifact | Size | Format |
|---|---:|---|
| `docs/reports/captures/candidates/catalog_typography_specimen.png` | 32,724 bytes | 1280×800, 8-bit RGBA PNG |
| `docs/reports/captures/candidates/catalog_token_swatches.png` | 32,642 bytes | 1280×800, 8-bit RGBA PNG |
| `docs/reports/captures/candidates/catalog_dense_organism.png` | 16,239 bytes | 1280×800, 8-bit RGBA PNG |
| `docs/reports/captures/candidates/catalog_form_primitive.png` | 26,658 bytes | 1280×800, 8-bit RGBA PNG |

The two secondary hosts were then remediated to use bounded frame pumps instead
of waiting for an indeterminate loading animation to settle. Their current
candidate artifacts are:

| Artifact | Size | Format |
|---|---:|---|
| `docs/reports/captures/candidates/observatory_overview_dashboard.png` | 26,358 bytes | 1280×800, 8-bit RGBA PNG; SHA-256 `5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500` |
| `docs/reports/captures/candidates/cybercore_shell_teal_skin.png` | 57,854 bytes | 1280×800, 8-bit RGBA PNG |

Current validation:

- `dart format --output=none --set-exit-if-changed integration_test/visual_acceptance_capture_test.dart` — exit 0.
- `flutter analyze integration_test/visual_acceptance_capture_test.dart` — exit 0, no issues.
- `flutter test integration_test/visual_acceptance_capture_test.dart` — exit 0, 4/4 passed.
- `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` — exit 0, 1/1 passed; local candidate rendered.
- `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` — exit 0, 1/1 passed; local candidate rendered.
- Independent remediation review: `docs/reports/review/1805-catalog-local-capture-remediation-independent-review-2026-09-03.md` — `PASS`, 100/100 diagnostic.
- Observatory determinism review: two consecutive capture runs produced the same 26,358-byte artifact with SHA-256 `5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500`.
- CyberCore determinism review: two consecutive capture runs produced the same 57,854-byte artifact with SHA-256 `b18d46c2229bb6078e5a330868a435517e5158a480dab37666a6fe836eb7481b`.

This evidence establishes capture-path correctness and artifact existence. It
does not establish the eleven human visual criteria, authorize golden refresh,
or complete Task 1805.

## 6. Determinism Remediation — 2026-09-03

The Observatory candidate previously varied between successful runs because its
loading shell contained an indeterminate progress animation. The capture test
now disables tickers only inside the test capture subtree with
`TickerMode(enabled: false)`. This preserves the production app and loading
semantics while pinning the captured frame. The bounded pump and local PNG
assertions remain in place.

The complete three-host remediation received independent technical re-review
(`PASS`, 100/100 diagnostic) on 2026-09-03. Human visual approval and the one
authorized golden refresh remain pending.

## 7. Final Independent Technical Re-review — 2026-09-03

- **Reviewer**: `gt-reviewers-reviewer-flutter`; session
  `ses_f9a461d7cffeOG5bVLNO6MPJqV`.
- **Remediation verdict**: `PASS`; diagnostic quality score `100/100`; high
  evidence confidence.
- **Overall Task 1805 verdict**: `BLOCKED` — explicit user sign-off for all
  eleven visual criteria remains absent.
- **Validation**: Catalog, Observatory, and CyberCore format/analyze/test
  commands all exited 0. Capture tests passed `4/4`, `1/1`, and `1/1`.
- **Artifacts**: all six candidates are current, non-empty, non-interlaced
  `1280×800`, 8-bit RGBA PNGs. Observatory repeated hash is
  `5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500`; CyberCore
  repeated hash is
  `b18d46c2229bb6078e5a330868a435517e5158a480dab37666a6fe836eb7481b`.
- **Findings**: no Critical, Serious, Debt, or required Improvement findings.
  The bounded pumps intentionally prove deterministic initial-state capture, not
  async data readiness; the Linux driver `MissingPluginException` remains a
  documented non-blocking fallback.
- **Report**:
  `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md`.
