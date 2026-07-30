# Task 1511: PrismAiAnalystPanel Fixture-First Organism

> **Status**: `[x]` Ready For Review — Resubmit path-to-100
> **Review State**: `Ready For Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1511` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismAiAnalystPanel` as fixture-first chat/intel turns panel (scripted responses). No live model keys; optional streaming simulation with fixtures.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismAiAnalystPanel` |
| **Internal implementation (preferred)** | `DSAiAnalystPanel` + `typedef PrismAiAnalystPanel = DSAiAnalystPanel` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-15` |
| **ShadowBroker origin** | AI intel panels (SB) — conversation/intel surfaces |
| **Osiris origin** | `AiAnalyst.tsx` / `AiOverview.tsx` (fixture-first reimplementation) |
| **Wave** | **E** |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore AI analyst; no live Gemini/keys |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- Markdown renderer, code block, toast system.
- Detail inspector chrome patterns.

### What is missing or broken

- No fixture-driven AI analyst conversation organism.
- No gallery demo of intel turns without backend.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Chat turn bubble
- Composer bar
- Streaming placeholder line

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST render multi-turn conversation from fixtures.
- MUST accept user message append via callback/controller with scripted reply.
- MUST show empty and loading/streaming placeholder states.
- Widget tests: initial turns, send message, empty, error fixture.
- A11y labels on composer send control.
- Gallery documents fixture-only policy.

---

## Exit Conditions

- [x] `PrismAiAnalystPanel` exported.
- [x] Tests + gallery PASS.
- [x] No network client or API key code paths.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define turn model (role, content, timestamp, status).
- [x] Implement transcript + composer.
- [x] Fixture reply adapter (deterministic).
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart` | Read — compose for assistant content |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/ai_analyst_panel/` | Create — tests |

### How

1. Build chat transcript UI with glass chrome.
2. Script fixture replies; no HTTP.
3. Export/test/gallery.

### Why

AI analyst UI is expected in CyberCore pilots; fixture-first keeps ADS unblocked while backends evolve.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.

> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.


---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/ai_analyst_panel/
# flutter test test/organisms/*ai_analyst_panel*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified** (resubmit 2026-07-18):
  - `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart` — dispose-safe `send()`, mounted scroll, reduced-motion indicators; format
  - `packages/warp_prism_ui/test/organisms/ai_analyst_panel/ai_analyst_panel_test.dart` — dispose-during-stream + reduced-motion tests; format
  - `docs/changelog/2026-07-18-task-1511-ai-analyst-panel-resubmit.md` (create)
  - Prior land: module, barrel, aliases, gallery, original changelog
- **Public API name verified**: `PrismAiAnalystPanel` via `typedef PrismAiAnalystPanel = DSAiAnalystPanel` in `prism_aliases.dart`, re-exported by `package:warp_prism_ui/warp_prism_ui.dart`
- **No network / no API keys**: rg under `ai_analyst_panel/` — no http/HttpClient/api_key/dio paths
- **Resubmit blockers closed**:
  1. Lifecycle: `_disposed` + `_safeNotify()` + post-await guards; dispose-during-stream tests (controller + panel unmount)
  2. Scroll post-frame: `if (!mounted || !_scroll.hasClients) return;`
  3. Format gate: PASS
  4. Package analyzer: exit 0 (pre-existing infos only; scoped clean)
  5. Reduced motion: static `Icons.hourglass_top_rounded` when `disableAnimations`; widget test
- **Tests or validation commands** (pack gate re-verify 2026-07-18T05:25Z):
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel
  # exit 0 — No issues found!

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel
  # exit 0 — 0 changed

  flutter test test/organisms/ai_analyst_panel/ --concurrency=1
  # 19/19 PASS

  dart analyze lib test
  # exit 0 — No issues found!

  dart run test/boundaries/boundary_test.dart
  # Boundary harness: 7/7 PASS
  ```
- **Boundary harness**: 7/7 PASS (`dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui`)
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1511-ai-analyst-panel-resubmit.md` (+ prior `2026-07-11-task-1511-ai-analyst-panel-fixture-organism.md`)
- **Agent-wiki / docs institutionalization**: N/A (ADS organism land; no new durable role SOP)
- **Executor**: gt-flutter-engineer (+ flutter-harness + verification-gate) under builders
- **Completion date**: 2026-07-18
- **Lane note**: Remains in `02-doing/` per builder instruction (Ready For Review; no promote / no move to `03-review/`)
- **Changelog Draft**:
  ```yaml
  task: 1511
  agent: gt-flutter-engineer
  project: warp-prism
  title: PrismAiAnalystPanel path-to-100 resubmit
  description: Dispose-safe stream, mounted scroll, reduced-motion indicators; fixture-only.
  summary: AI analyst panel resubmit ready for re-review.
  verification: 19 tests + package analyze clean + 7/7 boundaries
  ```

---

## Review Ledger

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `gt-flutter-code-reviewer` (builders; flutter-harness + code-quality-harness + design-system-harness)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1511.md`
- **Lane outcome**: **moved to `03-review/`** (formal gate; S=100; no git)
- **Prior expert fix verified**: dartdoc contract — `onTurnsChanged` (no phantom `onSend`)

#### Current Open Blockers

- None

#### Path-to-100 Summary (completed)

1. ~~Dispose-safe stream + mounted scroll + reduced motion + format/analyzer~~ DONE (builder)
2. ~~Contract dartdoc accuracy~~ DONE (expert)
3. ~~Formal final gate~~ DONE — score 100 (**19** tests)

### Previous Reports

| Date | Score | Verdict | Report |
| --- | --- | --- | --- |
| 2026-07-11 | 92 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-11/task-1511-independent-review.md` |
| 2026-07-16 | 74 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1511-ai-analyst-panel-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/expert-2026-07-18-task-1511.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/formal-2026-07-18-task-1511.md` |
