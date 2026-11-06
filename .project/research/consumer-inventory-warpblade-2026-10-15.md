# External Intelligence: Warpblade — Flutter UI Surface Inventory

> **Phase:** `wp-component-absorption` Phase 1 (Research — source analyst).
> **Evidence status:** every row and section below is derived from a live read of
> Warpblade source in this session. An earlier draft of this file contained
> unverified generic descriptions; those claims were removed, not softened.
> Nothing here is inherited from the draft.

## Header

- **Date:** 2026-10-15
- **Source:** `references/ganthritor-warpblade/apps/warpblade-app/`
- **Revision state:** **UNKNOWN.** `git log` / `git rev-parse` are denied in this
  workspace; no SHA, branch, or dirty-state claim is made. Best available markers
  are source mtimes (`main.dart` 2026-10-02, `timeline_strip.dart` 2026-09-07,
  `proposal_panel.dart` 2026-09-13, `take_tiles.dart`/`assurance_panel.dart`
  2026-09-30, `preview_host.dart`/`media_panel.dart`/`project_panel.dart`/
  `transport_bar.dart`/`banners.dart`/`diagnostics_panel.dart`/`startup_error_page.dart`
  2026-09-07, `keyboard_shortcuts.dart` 2026-09-21) and the
  `docs/bridge/warpblade/ads-debt.md` audit date 2026-09-13.
- **Coverage:** complete Flutter UI surface under `lib/` — `main.dart`,
  `timeline_strip.dart`, all 12 files in `lib/src/ui/`, the 4 files in
  `lib/src/bridge/`, and the FRB API directory listing. Plus the bridge-surface
  spike's app/controller/DTO structure.
- **Not inspected:** Rust crate internals (UI requirements only); FRB
  `*.freezed.dart` generated implementations and `frb_generated*.dart`
  (~380 KB) as generated artifacts, not design evidence; Warpblade `test/`,
  `integration_test/`; Linux desktop channel/platform code.

## Prism Baseline Reference

`pubspec.yaml:9-16` declares only `flutter`, `cupertino_icons`,
`flutter_rust_bridge 2.13.0`, `freezed_annotation`, and the local
`rust_lib_warpblade` path crate. **OBSERVED: zero Warp Prism adoption.**
Warpblade is therefore a clean inbound consumer rather than a partial adopter.

Warpblade also declares its own provisional-Prism intent in source comments,
which is stronger evidence than the marketing-style debt document: `preview_host.dart:3-9`
declares `WP-GAP-001`, `take_tiles.dart:68-71` and `:141-152` declare
`WP-GAP-ASSURANCE-01` plus a `TakeAuditionMatrix` family, and
`assurance_panel.dart:8-9` declares `WP-GAP-ASSURANCE-02` / `-03`.

## Inventory Table

| # | Actual symbol | Source | Observed role | Provisional classification |
|---|---|---|---|---|
| 1 | `WarpbladeApp` / `WarpbladeShellPage` | `lib/main.dart:23-48`, `:50-55` | Root app + single-page workspace shell | PRODUCT_SPECIFIC_KEEP_LOCAL |
| 2 | `TransportBar` | `lib/src/ui/transport_bar.dart:3-99` | Play/pause, ±0.25 s steps, scrub slider, time readout | CANDIDATE_UPSTREAM |
| 3 | `TexturedPreviewHost` | `lib/src/ui/preview_host.dart:3-178` | `WP-GAP-001` native-texture host + placeholder canvas | CANDIDATE_UPSTREAM |
| 4 | `ProposalPanel` | `lib/src/ui/proposal_panel.dart:4-466` | ADR-0005 proposal review, evidence, diff, accept/reject | CANDIDATE_UPSTREAM |
| 5 | `TimelineStrip` | `lib/timeline_strip.dart:4-541` | Read-only timeline projection: ruler, lanes, clips, playhead | CANDIDATE_UPSTREAM |
| 6 | `TakeTilesPanel` / `TakeTile` | `lib/src/ui/take_tiles.dart:139-591` | `TakeAuditionMatrix`: audition/compare/promote/regenerate | CANDIDATE_UPSTREAM |
| 7 | `MediaPanel` | `lib/src/ui/media_panel.dart:4-144` | Local-path open + probe metadata readout | PRODUCT_SPECIFIC_KEEP_LOCAL |
| 8 | `ProjectPanel` | `lib/src/ui/project_panel.dart:4-181` | Project lifecycle + asset import + export dispatch | CANDIDATE_UPSTREAM |
| 9 | `AssurancePanel` / `RepairDialog` | `lib/src/ui/assurance_panel.dart:5-778` | `WP-GAP-ASSURANCE-02/03` evidence + bounded repair | CANDIDATE_UPSTREAM |
| 10 | `DiagnosticsPanel` | `lib/src/ui/diagnostics_panel.dart:3-98` | Dev controls: ping, texture resize/dispose, error tests | PRODUCT_SPECIFIC_KEEP_LOCAL |
| 11 | `GenerationDrawer` | `lib/src/ui/generation_drawer.dart:5-552` | 3-level progressive generation disclosure | CANDIDATE_UPSTREAM |
| 12 | `ErrorBanner` / `ExportProgressBanner` / `ExportReportBanner` | `lib/src/ui/banners.dart:4-155` | Dismissible error, export progress, export report | CANDIDATE_UPSTREAM |
| 13 | `WarpbladeKeyboardRouter` | `lib/src/ui/keyboard_shortcuts.dart:4-85` | Shortcut router with text-edit guard | CANDIDATE_UPSTREAM |
| 14 | `WarpbladeStartupErrorPage` | `lib/src/ui/startup_error_page.dart:3-64` | Fail-closed native-bridge startup failure | CANDIDATE_UPSTREAM |
| 15 | `WarpbladeBridge` (facade barrel) | `lib/src/bridge/bridge_adapter.dart:1-33` | Sole legal FRB import surface + `init()` | RUNTIME_CONTRACT_GAP |
| 16 | `MediaTimeDtoUtils` / `TimeRangeDtoUtils` | `lib/src/bridge/rational_time.dart:3-79` | Exact rational math + timecode formatting | PRODUCT_SPECIFIC_KEEP_LOCAL |
| 17 | `TimelineIntentResolver` | `lib/src/bridge/timeline_intents.dart:5-161` | Pixel→rational seek, split, ripple-delete, nudge | CANDIDATE_UPSTREAM |
| 18 | `mapMediaError` / `isTerminalMediaError` | `lib/src/bridge/media_error_mapper.dart:3-65` | Typed error → user text; path-refusal disclosure | CANDIDATE_UPSTREAM |
| 19 | `WarpbladeSpikeApp` / `NativeSurfaceController` | `spikes/bridge-surface/spike_app/lib/main.dart:15`, `native_surface_controller.dart:26` | FRB v2 + FlTextureGL proof surface | PRODUCT_SPECIFIC_KEEP_LOCAL |

**Barrel note:** `lib/src/ui/ui.dart:1-11` exports 11 UI files. `timeline_strip.dart`
and `startup_error_page.dart`'s sibling `ui.dart` are re-exported through
`main.dart:5-8`, so the app has one import surface for UI.

## Per-Component Detail Sections

### 1. WarpbladeApp / WarpbladeShellPage

- **Source:** `lib/main.dart:10-20` (bootstrap), `:23-48` (`WarpbladeApp`), `:50-55` (`WarpbladeShellPage`), `:57-110` (state), `:1164-1449` (composition).
- **Bootstrap (OBSERVED):** `main()` awaits `WarpbladeBridge.init()` and captures failure into `initError` without `debugPrint`; `runApp(WarpbladeApp(startupError: ...))`. A comment at `:17` states the intent explicitly: "Release-safe fail-closed startup state: no debugPrint in release path."
- **App shell (OBSERVED):** `MaterialApp` with `title: 'Warpblade Shell'`, `ThemeData(brightness: dark, colorScheme: ColorScheme.dark(primary 0xFF3B82F6, secondary 0xFF10B981, surface 0xFF181B20, error 0xFFEF4444), useMaterial3: true)` (`:32-42`), and `home:` switching to `WarpbladeStartupErrorPage` when `startupError != null` (`:43-45`).
- **State (OBSERVED):** a single `_WarpbladeShellPageState` holds ~30 mutable fields and ~60 `setState` call sites; `initState` (`:106-110`) calls `_checkBridgeInfo()` and `_initProjectAndStreams()`. Two `StreamSubscription` fields exist for timeline and export streams (`:85-86`). No third-party state management is present.
- **Composition (OBSERVED):** `Scaffold` → `WarpbladeKeyboardRouter` wrapping `SingleChildScrollView` → one `Column` of children (`:1292-1305`, `:1308-1443`). **The workspace is a single vertically-scrolling stack, not a resizable multi-pane/zone layout.** `AppBar` (`:1166-1291`) carries a horizontally-scrolling title row with `SLICE 0..3` badges and `_sessionInfo`, plus proposal/generation toggles, a ping-latency readout, and an `FRB v2.13 ACTIVE` badge.
- **Provisional classification:** PRODUCT_SPECIFIC_KEEP_LOCAL as a composition. Note for Phase 2: the absence of any pane/zone layout means Warpblade currently exercises **no** multi-window layout primitive, so it cannot be counted as recurrence evidence for workbench layouts.

### 2. TransportBar

- **Source:** `lib/src/ui/transport_bar.dart:3-99`.
- **Shape (OBSERVED):** `StatelessWidget`, fully callback-driven: `isPlaying`, `positionSeconds`, `durationSeconds`, `isEnabled`, `onTogglePlayPause`, `onSeekBack`, `onSeekForward`, `onSliderChanged`, and a `String Function(double) formatTime` formatter injected by the caller (`:5-13`).
- **Rendering (OBSERVED):** a `Container` with hard-coded `0xFF181B20` fill / `0xFF262A35` border, containing a `Row` of: play/pause `IconButton` (`Icons.play_arrow`/`Icons.pause`), `fast_rewind` / `fast_forward` step buttons, an `Expanded` `Slider` with `semanticFormatterCallback: formatTime`, and a monospace `Container` showing `formatTime(position) / formatTime(duration)` (`:33-97`).
- **Corrected claim (OBSERVED):** there is **no stop button**; `durationSeconds` is only used to bound the slider (`:30-31`) and format the readout.
- **Reusable seam (INFERRED):** the bar is transport-domain-flavoured, but the underlying composition — icon-button group + slider + monospace time badge — is generic. `formatTime` is injected rather than owned, which is the reusable design decision.

### 3. TexturedPreviewHost

- **Source:** `lib/src/ui/preview_host.dart:3-178`.
- **Declared intent (OBSERVED, doc comment `:3-9`):** `WP-GAP-001: TexturedPreviewHost` — "Provisional local presentation component pending upstreaming to Warp Prism. Hosts native Linux presentation textures rendered via FlTextureGL / FlPixelBufferTexture."
- **Two-state design (OBSERVED):** `AspectRatio(aspectRatio)` → decorated `Container` → `Stack`. When `textureId != null`: `Texture(textureId: textureId!)` plus a HUD badge reading `FLTEXTURE_GL ID: $textureId • ${width}x$height • FRAME #$frameCount` (`:47-84`). When `textureId == null`: a `CustomPaint` grid painter, an icon, the literal label `'WP-GAP-001: TexturedPreviewHost (Provisional Primitive)'`, and a `statusMessage ?? 'Placeholder State  •  Target: …'` line (`:85-141`).
- **Corrected claim (OBSERVED):** the file's only import is `package:flutter/material.dart` (`:1`). **There is no dependency on any spike `NativeSurfaceController`.** Texture lifecycle is owned by `main.dart`; the widget is a pure presentation host.
- **Painter (OBSERVED):** `_PreviewPlaceholderGridPainter` draws a 40 px grid plus a centre crosshair, with `shouldRepaint` always `false` (`:150-178`).

### 4. ProposalPanel

- **Source:** `lib/src/ui/proposal_panel.dart:4-466`.
- **Declared intent (OBSERVED, doc comment `:4-10`):** "Review surface for AI-assisted editing proposals and analysis evidence. Implements ADR-0005 §2.5" — diff view is a Rust-computed projection, provenance is displayed passively, human override preserve-range actions invoke candidate transactions, and accept/reject invoke semantic commands through the bridge facade.
- **Trust boundary (OBSERVED):** the panel takes `ProposalDto`, `EvidenceSetDto`, and `ProposalDiffDto` and holds no proposal logic of its own; border colour is driven by `ProposalStatusDto` pending/expired (`:37-39`, `:48-55`).
- **States (OBSERVED):** status badge mapping pending→`PENDING REVIEW`, accepted→`ACCEPTED`, rejected→`REJECTED`, expired→`EXPIRED` (`:189-235`); a hard `banner_proposal_expired` warning explaining the timeline advanced past the baseline (`:94-117`); per-finding `Preserve Range` override (`:311-327`); a constraints list (`:338-377`); and a diff view showing `CLIPS: $beforeClips → $afterClips • DUR: $beforeDur → $afterDur` plus `opSummaries` (`:379-466`).

### 5. TimelineStrip

- **Source:** `lib/timeline_strip.dart:4-541`.
- **Declared intent (OBSERVED, doc comment `:4-8`):** "Pure read-only projection of `TimelineProjectionDto` received from the bridge. Displays tracks, clips, time ruler, and interactive scrub playhead."
- **Structure (OBSERVED):** header toolbar with timebase badge, `PLAYHEAD: … / …` readout, undo/redo, Split (`S`) and Ripple Delete (`Del`) (`:72-184`); explicit empty state when no active sequence (`:186-207`); horizontal `SingleChildScrollView` sized by `duration × pixelsPerSecond` with a 100 px track-header gutter (`:209-231`); ruler as `Semantics` + `GestureDetector` (tap and horizontal drag) + `CustomPaint` `_TimelineRulerPainter` with 1 s ticks (`:233-289`, `:481-541`); 52 px track lanes labelled `V{n}` / `A{n}` by `TrackKindDto` (`:291-367`); clips positioned by rational start with a 48 px minimum hit target and a `minWidth/minHeight` constrained box (`:369-450`); a 2 px playhead needle (`:452-468`).
- **Corrected claims (OBSERVED):** **no clip thumbnails**, **no drag-and-drop reorder**, and **no zoom controls** — `pixelsPerSecond` is a constructor property (`:30`) with no UI to change it. Selection toggles on tap (`:389-391`).
- **Seek correctness (OBSERVED):** `_handleRulerSeek` delegates to `TimelineIntentResolver.seekAtPixel` rather than doing arithmetic in the widget (`:470-478`).

### 6. TakeTilesPanel / TakeTile

- **Source:** `lib/src/ui/take_tiles.dart:12-741`.
- **Declared intent (OBSERVED, doc comments `:5-11`, `:139-152`):** `VerdictStyle` is "presentation only: Dart never decides or infers a verdict, it renders the exact `snake_case` wire name the core recorded", with unknown names falling through to neutral `UNASSESSED` styling so an unknown verdict "cannot be painted as a pass". The panel family is declared as provisional WP-GAPs: `TakeTilesPanel ~ TakeAuditionMatrix`, `VerdictBadge ~ AssuranceVerdictChip (WP-GAP-ASSURANCE-01)`, `_CompareStrip ~ ABComparisonSlider`, `_ProvenanceStrip ~ TakeMetadataStrip`, `TakePromotionActionBar`, `RepairActionBar (WP-GAP-ASSURANCE-03)`.
- **Verdict mapping (OBSERVED):** `accept`→green ACCEPT, `reject`→red REJECT, `repair`/`regenerate`/`human_review`→amber, `unresolved`/`unassessed`→blue-grey (`:29-63`), with matching icon switch (`:129-136`).
- **Corrected claim (OBSERVED):** it is **a vertical list, not a grid** — takes are `.map`ped into a `Column` (`:275-313`), and there are **no thumbnails**; a tile shows a movie icon, truncated id, an AUDITIONING badge, a `VerdictBadge`, and a text-only `_ProvenanceStrip`.
- **Actions (OBSERVED):** Audition, Compare, Promote, Regenerate, plus Assess/Assurance **rendered only when their callbacks are non-null** (`:568-584`). `Regenerate` opens a dialog minting a **child Take with lineage**, with seed and params-JSON overrides (`:324-332`, `:344-436`).
- **Compare (OBSERVED):** `_CompareStrip` compares DTO fields only and states "no pixel diff is invented", emitting `seed/fingerprint/params/lineage: SAME|DIFFER` (`:653-741`).

### 7. MediaPanel

- **Source:** `lib/src/ui/media_panel.dart:4-144`.
- **Corrected claim (OBSERVED):** this is **not a media bin**. There is no `ListView`, no thumbnail grid, no filter/sort, and no context menu. It is a single-path control: a monospace `TextField` (`input_media_path`) plus an `Open` button (`:69-102`), three hard-coded test `ActionChip`s (`Tiny Test (2s)`, `Corrupt File`, `Missing File`) that call `onOpenFile` with literal repo-relative paths (`:51-65`), and a probe-metadata block rendering resolution, duration (with exact `num/den`), codec + pixel format, fps, and timebase (`:103-140`).
- **Provisional classification:** PRODUCT_SPECIFIC_KEEP_LOCAL. The probe-metadata strip is AV-specific; only the monospace labelled-field pattern is generic.

### 8. ProjectPanel

- **Source:** `lib/src/ui/project_panel.dart:4-181`.
- **Corrected claim (OBSERVED):** this is **not a settings form**. There is no `Form`, no `TextFormField`, and no dropdowns. It is a **lifecycle/action panel**: a header row showing `PROJECT: <name or "NO PROJECT LOADED">`, an amber `*` dirty indicator driven by `projectState.isDirty`, and a truncated `DIGEST:` chip from `projectState.stateDigest` (`:47-95`).
- **Controls (OBSERVED):** one monospace `TextField` for a `.wbproj` path (`:100-120`), then a `Wrap` of six buttons — `New Project`, `Import Media`, `Place on Timeline`, `Save Project` (Outlined, disabled when `onSaveProject == null`), `Load Project`, `Export Sequence` (green, disabled unless a sequence exists and export is idle) — plus a `Quick Setup DoD` `ActionChip` (`:124-177`).
- **Notable pattern (OBSERVED):** capability is expressed by **nulling the callback**, so unavailable actions render disabled rather than disappearing (`main.dart:1328-1332`). The same idiom recurs in `TakeTile` (`take_tiles.dart:568-584`) and `AssurancePanel` (`assurance_panel.dart:292-297`, which even uses `Icon(Icons.build_outlined)` in both branches at `:287-290`).

### 9. AssurancePanel / RepairDialog

- **Source:** `lib/src/ui/assurance_panel.dart:5-778`.
- **Declared intent (OBSERVED, doc comment `:8-9`):** `WP-GAP-ASSURANCE-02 ObservationDetailPanel` and `WP-GAP-ASSURANCE-03 RepairActionBar`.
- **Trust boundary (OBSERVED, doc comment `:11-19`):** "This panel renders only what the core decided. It holds no verdict logic" — badge from `TakeDto.verdict`, styling from `FindingDto.outcome`, repair enabled-state from the core's verdict. "the panel re-reads the registry after each one rather than mutating a local copy into agreement."
- **Testability seam (OBSERVED):** data loads through an injected `AssuranceLoader` typedef defaulting to `loadAssuranceFromBridge`, and repair through `AssuranceRepairer` defaulting to `requestRepairFromBridge`, explicitly "so a widget test can drive every documented state — error, empty, populated — without a live native library" (`:21-23`, `:72-110`). This is the single most reusable runtime-contract shape found in the consumer.
- **States (OBSERVED):** loading (`:247-252`), error (`:228-246`), populated with `_StatusRow` (verdict/assessed/promotion/evidence counts/rationale, `:306-351`), `_GateRibbon` of `VerdictBadge` with rationale tooltips (`:377-409`), `_ObservationList` showing method, blind flag, exact `observedAtNum/observedAtDen`, fingerprint and input digest (`:411-506`), and `_FindingList` with three-valued pass/fail/neutral outcome and invariant-vs-expectation labelling (`:508-602`).
- **Bounded repair (OBSERVED):** `RepairDialog` collects a corrective instruction, optional params-JSON override, and `maxRetries` with validation, and states the fields "are the *authored correction*, never a claimed outcome" (`:617-778`). Repair is **disabled, not hidden**, when the core did not ask for it (`:292-297`).

### 10. DiagnosticsPanel

- **Source:** `lib/src/ui/diagnostics_panel.dart:3-98`.
- **Corrected claim (OBSERVED):** this is **not a health/telemetry display**. It exposes no metrics, health status, or log stream. It is a **developer control strip** with two rows: production bridge commands — `Ping`, `Toggle Res (1080p|720p)`, `Dispose` (resize/dispose disabled unless `hasTexture`, `:35-67`) — and a "Typed Error Validation" row with `Trigger Invalid Dimensions (0x0)` and `Trigger Texture Not Found (-999)` buttons (`:69-94`).
- **Provisional classification:** PRODUCT_SPECIFIC_KEEP_LOCAL. These are QA affordances, not a reusable runtime-contract surface. Treat any "diagnostics/health primitive" claim for Warpblade as **not yet evidenced**.

### 11. GenerationDrawer

- **Source:** `lib/src/ui/generation_drawer.dart:5-552`.
- **Declared intent (OBSERVED, doc comment `:5-16`):** progressive disclosure per ADR-0006 §2.5 — Level 1 capability-named intent actions "never model-catalog navigation"; Level 2 creative controls "generated from the descriptor — never hardcoded per-model widgets"; Level 3 provider mechanics behind explicit expansion with `Model: Auto` default and a **no-execution route preview**. "All generation/routing math lives Rust-side; this widget only formats display strings and invokes facade calls."
- **Descriptor-bound form (OBSERVED):** controls are generated by iterating `cap.declaredParams` and skipping `prompt`, whose hint text carries `decl.name (decl.kind) — decl.description` (`:408-432`). `_buildRequest` coerces `kind == 'uint'` params with non-negative-integer validation and throws `FormatException` on bad input (`:81-134`).
- **Route (OBSERVED):** empty explicit-provider field produces `RouteDto.auto()`, otherwise `RouteDto.explicit(providerId: ...)` (`:130-132`); the preview calls `previewRoute(req: ...)` and renders `preview.explanation` (`:149-175`, `:507-531`); capability descriptors expose `backend`, `locality`, `latencyTier`, `granularity` (`:475-482`).

### 12. ErrorBanner / ExportProgressBanner / ExportReportBanner

- **Source:** `lib/src/ui/banners.dart:4-155`.
- **Corrected claim (OBSERVED):** there is **no generic status/warning banner family** and no severity ladder. Exactly three widgets exist:
  - `ErrorBanner` — dismissible, `0xFF7F1D1D`/`0xFFEF4444`, monospace message (`:4-51`).
  - `ExportProgressBanner` — indeterminate `CircularProgressIndicator` plus `Exporting: Frame ${currentFrame} (${message})`, driven by `ExportProgressDto` (`:53-93`).
  - `ExportReportBanner` — success banner asserting `'EXPORT COMPLETE (DETERMINISTIC BIT-EXACT RENDER)'` and printing `DEST`, `FRAMES`, `BYTES`, and `SHA256` from `ExportReportDto` (`:95-155`).
- **Note (OBSERVED):** other error/progress surfaces are inline and duplicated across files rather than composed from this module — e.g. the generation error block (`generation_drawer.dart:356-372`), the take error block (`take_tiles.dart:250-268`), and the assurance error block (`assurance_panel.dart:228-246`). This is a real reuse seam for Phase 2, not a generic-banner gap.

### 13. WarpbladeKeyboardRouter

- **Source:** `lib/src/ui/keyboard_shortcuts.dart:4-85`.
- **Corrected claim (OBSERVED):** the class is `WarpbladeKeyboardRouter`, and it is a `StatelessWidget` wrapping a `KeyboardListener` with `autofocus: true` that dispatches to injected callbacks (`:9-35`, `:39-42`).
- **Bindings (OBSERVED):** `Ctrl/Cmd+Z` → undo, `Ctrl/Cmd+Shift+Z` and `Ctrl/Cmd+Y` → redo (`:49-60`); then `space` play/pause, `←`/`→` nudge, `S` split, `P` proposals, `G` generation, `Delete`/`Backspace` ripple delete (`:66-81`). `main.dart:1292-1302` binds these to `_undo`, `_redo`, `_toggleTimelinePlayPause`, `_seekNudgeTimeline(±0.25)`, `_splitClipAtPlayhead`, `_rippleDeleteSelectedClip`, and the two panel toggles.
- **Reusable detail (OBSERVED):** an edit-focus guard reads `FocusManager.instance.primaryFocus?.context?.widget is EditableText` and returns early, so typing in the path/params fields does not trigger shortcuts (`:62-64`). Modifier state comes from `HardwareKeyboard.instance` (`:45-47`).
- **Provisional classification:** CANDIDATE_UPSTREAM — a guard-aware shortcut router is reusable; the specific binding set is product-local.

### 14. WarpbladeStartupErrorPage

- **Source:** `lib/src/ui/startup_error_page.dart:3-64`.
- **Declared intent (OBSERVED, doc comment `:3-6`):** "Release-safe fail-closed startup error surface… Displayed when native bridge or platform library initialization fails… Ensures fail-closed security without leaking diagnostic strings via debugPrint."
- **Rendering (OBSERVED):** `Scaffold(backgroundColor: 0xFF0F1115)` → `Center` → `ConstrainedBox(maxWidth: 500)` → red-bordered `Container` with an `error_outline` icon, the title `Native Bridge Initialization Failed`, the error text in monospace, and the recovery guidance "verify that native libraries and platform dependencies are present" (`:13-63`).
- **Wiring (OBSERVED):** selected by `WarpbladeApp` only when `startupError != null` (`main.dart:43-45`), and populated from the caught exception in `main()` (`main.dart:12-19`). This is a genuine fail-closed boundary: the app never starts with a half-initialised bridge.
- **Provisional classification:** CANDIDATE_UPSTREAM — fail-closed bootstrap error is a reusable shell concern; the copy is product-local.

### 15. WarpbladeBridge (facade barrel)

- **Source:** `lib/src/bridge/bridge_adapter.dart:1-33`.
- **Declared intent (OBSERVED, doc comment `:1-6`):** "This facade is the single canonical boundary between Flutter UI and flutter_rust_bridge generated bindings. Widgets must only import this facade, never importing `src/rust/**` directly."
- **Actual content (OBSERVED):** the file is a `library;` that imports `../rust/frb_generated.dart` (`:8`), re-exports ten API modules — `editorial`, `assurance`, `export`, `generation`, `takes` (with `mediaSeek` hidden), `project`, `proposals`, `session`, `surface` (`:10-19`) — plus `media_error_mapper`, `rational_time`, `timeline_intents` (`:21-23`), and defines a single `WarpbladeBridge` class whose only member is `static Future<void> init() => RustLib.init()` (`:26-33`).
- **Corrected claim (OBSERVED):** this is **not** a command/event-stream multiplexer. There is no Dart-side `AsyncCommand`/`EventStream` abstraction here; commands are top-level FRB functions invoked directly from `_WarpbladeShellPageState` (~60 `setState` sites), and streams are consumed as raw `StreamSubscription` fields (`main.dart:85-86`). The reusable value is the **import-boundary discipline**, not a runtime contract.
- **Provisional classification:** RUNTIME_CONTRACT_GAP — the boundary exists, but the reusable command/event/health contracts are not yet expressed in Dart.

### 16. MediaTimeDtoUtils / TimeRangeDtoUtils

- **Source:** `lib/src/bridge/rational_time.dart:3-79`.
- **Corrected claim (OBSERVED):** these are **extension methods on FRB DTOs**, not a standalone rational-time value type. `MediaTimeDtoUtils` provides `toSeconds()` (explicitly "strictly for UI pixel layout and slider display", `:5-6`), `formatTime()` → `MM:SS.ss` (`:9-14`), exact `isBefore`/`isAfter`/`isBeforeOrEqual` via `BigInt` cross-multiplication (`:17-32`), `add`/`subtract` with GCD reduction (`:35-60`), and a `gcd` helper (`:63-70`). `TimeRangeDtoUtils.formatRange()` renders `MM:SS.ss – MM:SS.ss (dur: MM:SS.ss)` (`:73-79`).
- **Reusable seam (INFERRED):** the exact-rational arithmetic is AV-domain and stays local; the `formatTime`/`formatRange` presentation is a reusable timecode-formatting concern. Note the deliberate split already made in source: `toSeconds()` is documented as display-only, never authoritative.

### 17. TimelineIntentResolver

- **Source:** `lib/src/bridge/timeline_intents.dart:5-161`.
- **Declared intent (OBSERVED, doc comment `:5-8`):** "Semantic intent resolver for timeline and playback interactions. Encapsulates exact rational arithmetic, clip containment, target selection, and timebase quantization outside of presentation widgets."
- **API (OBSERVED):** all-static `TimelineIntentResolver` with `seekAtPixel` (pixel→rational, timebase-quantised, `:14-30`), `splitAtPlayhead` (returns `EditorialCommandDto.splitClip` or `null` when the playhead is not strictly inside a clip, `:35-69`), `rippleDeleteSelected` (`:74-90`), `mapPlayheadToSourceTime` (playhead→source media time within the active clip, `:95-109`), `nudgePlayhead` (`:113-127`), `nudgeMediaTime` (standalone media preview, `:131-145`), and `quantizeSliderValue` (`:148-160`).
- **Why it matters (OBSERVED):** this is the consumer's own demonstration of the "interaction semantics live outside the widget" pattern — `TimelineStrip._handleRulerSeek` and `TransportBar`'s slider both delegate here (`timeline_strip.dart:470-478`, `main.dart:1404-1419`). Strongest single candidate for an IDS/runtime-contract extraction.
- **Provisional classification:** CANDIDATE_UPSTREAM.

### 18. mapMediaError / isTerminalMediaError

- **Source:** `lib/src/bridge/media_error_mapper.dart:3-65`.
- **Cross-boundary contract (OBSERVED):** `pathRefusalPrefix = 'path refused ['` is pinned as a `const` "so there is exactly one reader of the cross-boundary contract, instead of a regex copy per presentation site", with the Rust side documented as building it via `format!("path refused [{}]: {error}", error.code())` (`:3-8`). `pathRefusalPattern` captures the refusal class and detail (`:10-17`).
- **Mapping (OBSERVED):** `mapMediaError` exhaustively maps `MediaError.when` to user text across `sessionClosed`, `unknownHandle`, `ioError`, `noVideoStream`, `unsupportedCodec`, `probeFailed`, `decodeFailed`, `seekFailed`, `surfaceError`, and `invalid` (`:31-49`). `describePathRefusal` is checked **before** the variant's own label so a policy refusal is never shown as a plain "Invalid" (`:43-47`).
- **Terminality (OBSERVED):** `isTerminalMediaError` returns `false` for `decodeFailed` ("Transient decode glitch may recover or pause") and `seekFailed` ("Bounded seek miss or range clamp"), `true` for the rest (`:51-65`). This is a real, non-obvious operational decision worth preserving.
- **Provisional classification:** CANDIDATE_UPSTREAM for the mapper shape; the refusal-prefix contract is a cross-boundary invariant that must be preserved verbatim.

### 19. WarpbladeSpikeApp / NativeSurfaceController

- **Source:** `spikes/bridge-surface/spike_app/lib/main.dart:15`, `:37`, `:278`, `:479`; `spikes/bridge-surface/spike_app/lib/native_surface_controller.dart:8`, `:26`, `:42`, `:115`, `:124`, `:159`; `spikes/bridge-surface/spike_app/lib/src/rust/api/simple.dart:41`, `:46`, `:81`, `:116`.
- **Role (OBSERVED):** a proof surface for FRB v2 + FlTextureGL / FlPixelBufferTexture, not product UI. `NativeSurfaceController` owns the texture lifecycle — `createTexture` (`:42`), `resizeTexture` (`:115`), `getTextureInfo` (`:124`), `destroyTexture` (`:159`) — and `SpikeHomeScreen` renders `Texture(textureId: _controller.textureId!)` (`main.dart:278`).
- **Typed errors (OBSERVED):** `BridgeError_TextureAllocationFailed` is caught and surfaced as `'Caught Typed BridgeError: TextureAllocationFailed(${w}x$h: $reason)'` (`main.dart:215`); the DTO set includes `PlaybackCommand`, `PlaybackResponse`, and `TimecodeTick` (`simple.dart:46`, `:81`, `:116`).
- **Zero-copy claim (OBSERVED, doc comment `main.dart:479`):** "Zero-Dart-Copy: Structural (native-side GL upload; no Dart frame buffers across bridge) + RSS sampled". This is a **spike assertion, not product evidence** — the production app's texture path is `main.dart:1386-1392` with no measured zero-copy claim.
- **Provisional classification:** PRODUCT_SPECIFIC_KEEP_LOCAL. Useful as the reference for how a texture host is driven; not a harvest source.

## Declared Needs Not Yet Implemented

> Status labels follow Warpblade's own convention: `OBSERVED` = read in source;
> `DECLARED` = asserted in `ads-debt.md` or a source comment, not independently
> confirmed here. Every phase-2 disposition must be checked against source again.

### A. Zero Prism adoption (OBSERVED)

`pubspec.yaml:9-16` declares no Warp Prism package. Every UI surface above is built
from raw Material 3 plus hand-rolled widgets. This is the baseline fact the whole
harvest must respect: Warpblade has never consumed a Prism primitive.

### B. Consumer-declared provisional primitives (OBSERVED, strongest evidence)

Warpblade names its own missing primitives in source, which outranks the debt doc:

| Declared gap | Source | What it names |
|---|---|---|
| `WP-GAP-001` | `preview_host.dart:3-9` | `TexturedPreviewHost` — pending upstreaming to Warp Prism |
| `WP-GAP-ASSURANCE-01` | `take_tiles.dart:68-71` | `VerdictBadge` / `AssuranceVerdictChip` |
| `WP-GAP-ASSURANCE-02` | `assurance_panel.dart:8-9` | `ObservationDetailPanel` |
| `WP-GAP-ASSURANCE-03` | `assurance_panel.dart:8-9`, `:619` | `RepairActionBar` / bounded-repair dialog |
| `TakeAuditionMatrix` family | `take_tiles.dart:141-152` | audition matrix, AB comparison, provenance strip, promotion action bar, compare controls |

### C. Keep-local by the consumer's own decision (DECLARED)

`docs/bridge/warpblade/ads-debt.md` P3 records `ProjectPanel` and
`DiagnosticsPanel` as "Manter local por ora". Source confirms both are
action/control surfaces rather than generic editors, consistent with that call.

### D. Negative evidence

- **OBSERVED:** no `TODO`/`FIXME`/`HACK`/`not implemented` markers in the Flutter UI
  sources read; declared need lives in `ads-debt.md` and in the WP-GAP comments
  above, not in inline markers.
- **OBSERVED:** no multi-pane/zone layout, no resize handles, no panel reorder
  (`main.dart:1303-1305`). Any claim that Warpblade needs a workbench/layout
  primitive is **unsupported by this consumer**.
- **OBSERVED:** no state-management library in `pubspec.yaml:9-16`; state lives in one
  large `StatefulWidget` (`main.dart:57-110`). Claims about provider/riverpod-style
  contracts are unsupported.
- **OBSERVED:** `AssurancePanel` is not composed in `main.dart`'s workspace at all —
  `TakeTilesPanel` embeds it (`take_tiles.dart:294-309`) but `main.dart:1363-1375`
  passes neither `onAssess` nor `onRepairRequest`, and `TakeTile` hides those buttons
  when the callbacks are null (`take_tiles.dart:568-584`). So in the real app the
  Assess/Assurance actions are currently unreachable. Treat this as a live finding,
  not a Phase-1 defect.

### E. Runtime-contract-shaped seams (INFERRED from OBSERVED structure)

1. **Injected loader/repairer** — `AssuranceLoader` / `AssuranceRepairer` typedefs with
   bridge defaults, explicitly so widget tests can drive every state without a live
   native library (`assurance_panel.dart:21-23`, `:72-110`).
2. **Callback-as-capability** — unavailable actions are signalled by a `null` callback
   and rendered disabled (`project_panel.dart:124-177`, `take_tiles.dart:568-584`,
   `assurance_panel.dart:292-297`). This is Warpblade's ad-hoc stand-in for a
   capability/health contract.
3. **Stream subscription ownership** — raw `StreamSubscription` fields for timeline and
   export (`main.dart:85-86`), with no lifecycle abstraction.
4. **Typed error disclosure** — refusal prefixes pinned across the boundary
   (`media_error_mapper.dart:3-8`) and terminality rules (`:51-65`).

### F. Domain semantics vs reusable seam

| Stays product-local | Possibly reusable |
|---|---|
| Rational time math, timebase quantisation, AV probe metadata | Timecode formatting (`MM:SS.ss`, range format) |
| NLE track/clip model, clip containment, source-time mapping | Timeline strip layout: ruler + lanes + playhead, with no thumbnails/reorder/zoom |
| Generation/routing math, capability descriptors | Descriptor-driven progressive-disclosure form |
| Provider selection, seed/params semantics | Capability-gated action buttons + bounded dialogs |
| Proposal lifecycle and diff computation | Proposal review surface: provenance + evidence + diff + override |
| Verdict decision and repair authoring | Verdict badge styling (core wire names must pass through unchanged) |
| GPU texture lifecycle and native surface | Texture-host container with placeholder/HUD (`WP-GAP-001`) |
| Project lifecycle, asset import, export | Project action panel |
| Assurance evidence content | Assurance evidence surface + bounded repair dialog |

## Prism Baseline Deltas

> **PROVISIONAL.** Each row must be line-checked against
> `docs/design/component-catalog.md` before Phase 2 treats it as a gap.

| Capability observed in Warpblade | Catalog gap (INFERRED) | Recurrence status |
|---|---|---|
| Timecode formatting (`MM:SS.ss`, range) | Formatting helpers are not presentation components | Needs a 2nd consumer |
| Timeline strip (ruler/lanes/playhead) | No timeline primitive | 1 consumer only; do not promote on this alone |
| Texture host with placeholder | `WP-GAP-001` self-declared | 1 consumer; spike only |
| Proposal review surface | No agent-proposal primitive | 1 consumer; AI-shaped — verify 2nd domain |
| Verdict badge / assurance surface | `WP-GAP-ASSURANCE-01/02/03` self-declared | 1 consumer |
| Descriptor-driven progressive disclosure | No dynamic-form primitive | 1 consumer |
| Bounded-retry dialog with validation | No bounded-action primitive | 1 consumer |
| Guard-aware keyboard router | No shortcut-router contract surfaced | Needs IDS catalog check |
| Fail-closed startup error page | Partial overlap with error-state handling | Verify against catalog |
| Capability-gated disabled actions | No capability/health contract in consumer | Verify against runtime-contract catalog |
| Import boundary over FRB (`bridge_adapter.dart:1-6`) | Not a component concern | Warpblade-local discipline |

**Non-deltas (explicit keep-local):** AV probe metadata, rational arithmetic,
timeline data model, generation/routing semantics, proposal computation, texture
lifecycle, project lifecycle.

## Unknowns and Blockers

- **Revision state UNKNOWN** — `git log` / `git rev-parse` denied; no SHA/branch/dirty
  claim. Report uses mtimes and the `ads-debt.md` audit date (2026-09-13).
- **Runtime behaviour UNKNOWN** — no consumer code was executed; all claims are static
  reads. The spike's "Zero-Dart-Copy" claim (`spike_app/lib/main.dart:479`) is an
  assertion, not measured evidence.
- **Uninspected scope (disclosed):** Rust crate internals; `*.freezed.dart` and
  `frb_generated*.dart` as generated artifacts; `test/` and `integration_test/`;
  Linux desktop channel/platform code; `spikes/bridge-surface/spike_app/src/rust/**`
  generated bindings.
- **Catalog diff not performed** — "Prism baseline deltas" is INFERRED and must be
  confirmed against `docs/design/component-catalog.md`.
- **Citation completeness** — detail sections now carry `path:line-range`; the
  inventory table's `Source` column uses file-level references and should be narrowed
  in a final pass if line-grade citation is required there too.
- **Accidental artifact** — `.project/research/test-write.md` (one line, `# test`) is a
  suspected scratch leftover from earlier write-protocol debugging. Ownership unverified;
  not deleted without mutation authority.

## Recommended Next Tasks

1. **Phase 1 close-out** — narrow the inventory table's `Source` column to
   `path:line-range`, then return the corrected counts/findings packet.
2. **Catalog diff** — confirm or refute every row of "Prism baseline deltas" against
   `docs/design/component-catalog.md`.
3. **Live finding** — raise the `AssurancePanel` unreachability
   (`main.dart:1363-1375` + `take_tiles.dart:568-584`) to the Warpblade owner for a
   product decision; it is outside Phase 1 scope.
4. **Second-consumer check** — before any promotion, test timeline-strip, timecode,
   texture-host, and proposal-surface recurrence against Tempest/Sentry/Hyperion.
5. **Conformance candidate** — scope `TimelineIntentResolver` + the injected
   loader/repairer seam as the first real-consumer conformance target
   (fake + suite + host-composition proof).
6. **Phase 2 handoff** — pass to the Warp Prism architecture owner; do not begin
   curation inside a research-only assignment.

**Phase boundary:** this is a Phase 1 (Research) deliverable. Source research,
fit curation, design, implementation and stable promotion remain separate phases.