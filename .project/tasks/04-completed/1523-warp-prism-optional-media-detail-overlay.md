# Task 1523: Optional Media Detail Overlay

> **Review State**: `ACCEPTED_100`
> **Priority**: 🟢 P2
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: N/A (optional Wave I; if completed, refresh Task 1519 matrix)
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1523` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Optional Wave I: implement `PrismMediaDetailOverlay` for media/stream detail lightbox-style overlay using **fixtures** (static images / placeholder frames). Do not implement live CCTV streaming stacks or hls.js ports.

### Source origin

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismMediaDetailOverlay` |
| **Harvest ID** | O-27 |
| **ShadowBroker** | CCTV / region imagery lightbox patterns |
| **Osiris** | `CameraViewer.tsx` (pattern only) |
| **Wave** | I (optional) |
| **Action type** | `NEW` |

## Background Context

### What already exists

- Glass modal/overlay patterns via panels and error boundaries.
- Markdown/code for non-media detail.
- Entity intel panel may host media later via composition.

### What is missing or broken

- No media detail overlay organism for imagery/stream placeholders.
- No gallery fixture for media lightbox chrome.

### False-gap / skips

- No hls.js / WebRTC / live CCTV backend.
- No auth-gated camera product.
- Prefer placeholder `Image.asset` / network fixture only if test-safe; otherwise color/box placeholder with caption.

### Composition notes (molecules may derive later)

- Media caption bar
- Overlay close control
- Optional next/prev media control

---

## Test Requirements

- MUST open/close overlay via API/callbacks.
- MUST show media title/caption and placeholder visual.
- MUST support multi-item next/prev if multi fixture provided (optional but tested if present).
- Widget tests: open, close, empty media, a11y labels on close/next/prev.
- Gallery fixture with mock media items.

---

## Exit Conditions

- [x] `PrismMediaDetailOverlay` exported via barrel + alias.
- [x] Widget tests for open/close (+ navigation if implemented) PASS.
- [x] Gallery case present or Task 1519 matrix updated.
- [x] No streaming engine dependencies added to pubspec.
- [x] `dart analyze` + scoped `flutter test` PASS.
- [x] Boundary harness 7/7 after aliases.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: harvest O-27, organisms barrel, prism_aliases, glass panel, pubspec, EPIC-15 Non-Goals.
- [x] Define media item model (id, title, caption, placeholder).
- [x] Implement overlay chrome open/close with a11y.
- [x] Fixture gallery + widget tests.
- [x] Export alias + barrel.
- [x] **Simplicity pass**: placeholder media only; no player controls beyond open/close/next.
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/media_detail_overlay/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/media_detail_overlay/ds_media_detail_overlay.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — `PrismMediaDetailOverlay` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/media_detail_overlay/` | Create — tests |
| `packages/warp_prism_ui/pubspec.yaml` | Read — no streaming deps |

### How

1. Build modal overlay with glass frame.
2. Placeholder media body.
3. Tests for open/close.
4. Export/gallery.

### Why

Media lightbox is P2 polish from both harvests; fixture overlay completes the investigation chrome set without live video risk.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Optional task — deferrable with written reason. No hls.js, no live CCTV, no MapLibre.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. ADS gallery sufficient
> for exit. No product route requirements.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/media_detail_overlay/
cd ../..
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/media_detail_overlay/ds_media_detail_overlay.dart`
  - `packages/warp_prism_ui/lib/src/organisms/media_detail_overlay/media_detail_overlay.dart`
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (`PrismMediaDetailOverlay`, `PrismMediaDetailItem`, `PrismMediaDetailFixtures`)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` + registry
  - `packages/warp_prism_ui/test/organisms/media_detail_overlay/media_detail_overlay_test.dart` (8)
  - `docs/changelog/20260718-052900-1523-media-detail-overlay-gt-flutter-engineer.md`
- **pubspec**: no video_player / chewie / hls / webrtc / xterm / pty deps (`rg` proof empty)
- **Tests or validation commands** (2026-07-18T05:28Z):
  - `dart analyze` owned surfaces → **No issues found**
  - `flutter test test/organisms/media_detail_overlay/ --concurrency=1 --no-pub` → **8/8 PASS**
  - Boundary harness → **7/7 PASS**
- **Boundary harness**: 7/7 PASS
- **Local changelog entry**: `docs/changelog/20260718-052900-1523-media-detail-overlay-gt-flutter-engineer.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under parent builder-orchestrator)
- **Completion date**: 2026-07-18
- **Lane**: left in `02-doing` per builder compact (no promote)

### Changelog Draft

```yaml
task: "1523"
agent: gt-flutter-engineer
project: warp-prism
title: "Optional PrismMediaDetailOverlay fixture lightbox"
description: "Placeholder media overlay with caption, close, next/prev; no streaming engines"
summary: >
  DSMediaDetailOverlay + fixtures + gallery + Prism aliases; 8 widget tests;
  boundaries 7/7; pubspec free of streaming deps.
verification: >
  dart analyze clean; flutter test media_detail_overlay 8/8; boundary 7/7
```

### Entrypoint Chain Proof

- **Claim**: helper/library-only ADS organism (fixture lightbox)
- **Classification**: `helper/library-only`
- **Helper**: `DSMediaDetailOverlay`
- **Regression test**: open/close, empty, next/prev, a11y labels

---

## Independent Live Review Ledger — Third Batch — 2026-08-23

- **Score:** 100/100
- **Verdict:** `ACCEPTED_100`
- **Full report:** `docs/reports/review/independent-2026-08-23-third-batch-task-1523.md`
- **Lane outcome:** remains `docs/tasks/03-review/`
- **Fresh proof:** overlay suite 10/10; scoped analyzer exit 0 with four info-level style findings; non-mutating format clean for owned overlay files; boundary 7/7; gallery 22/22.
- **Regression guards:** placeholder-only media, no streaming engines, append index preservation, route semantics, and finite-height frame remain verified.

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal parallel)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1523.md`
- **Lane outcome**: moved to `03-review`
- **Task reference**: Task 1523 (`1523-warp-prism-optional-media-detail-overlay`)

#### Current Open Blockers

- None.

#### Path-to-100 Summary

- Already at 100 (formal independent re-proof of expert path-to-100).
- Live: analyze clean; **10/10** media tests; boundary **7/7**; no streaming deps.

#### Regression Guards

- No video_player / chewie / hls / webrtc / xterm / pty deps.
- Placeholder media only — do not port live CCTV stacks.
- Do not snap index to initialIndex on item-list append.
- Keep modal AT scopesRoute + overflow-safe frame under finite maxHeight.

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1523.md` — expert path-to-100 100/100 (before 88)
