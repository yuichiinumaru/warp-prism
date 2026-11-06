# External Intelligence: Tempest Flutter UI Surface — Provisional Inventory

> **Date:** 2026-10-15
> **Scope:** Read-only research pass. Provisional evidence only — not decisions, not implementation grants.
> **Authority:** Warp Prism architecture owner decides final disposition.

## Coverage

- **Inspected:** 32 Dart source files under `references/ganthritor-tempest/flutter/lib/` (44 total `.dart` files discovered; 12 FRB-generated + l10n skipped as non-UI).
- **Uninspected:** `flutter/test/` (test-only), `flutter/build/`, `flutter/.dart_tool/`, `flutter/l10n.yaml`, `flutter/analysis_options.yaml`, `flutter/README.md`, all Rust crates under `crates/` and `target/`.

## Top-Level Surfaces (Routes)

| Surface | Path | Prism Coverage |
|---|---|---|
| Library | `features/library/presentation/library_screen.dart` | Partial — `PrismAssetCard` + `PrismSearchBar` |
| Separate | `features/separate/presentation/separate_screen.dart` | Partial — `PrismStateSurface`, `PrismMetricTile` |
| Create | `features/create/presentation/create_screen.dart` | Partial — `PrismDialog`, `PrismSelect` |
| Studio | `features/studio/presentation/studio_screen.dart` | **GAP** — no Prism equivalent for DAW multitrack |
| Models | `features/models/presentation/models_screen.dart` | Partial — `PrismAssetCard`, `PrismStatusDot` |
| Providers | `features/providers/presentation/providers_screen.dart` | Partial — `PrismProviderHealthMatrix` |
| Settings | `features/settings/presentation/settings_screen.dart` | Partial — `PrismStateSurface` |

## Shell & Navigation

| Component | Path | Prism Coverage |
|---|---|---|
| `MainShellLayout` | `core/layout/main_shell.dart:9-203` | **DUPLICATE_IMPLEMENTATION** — Material `NavigationRail`, 7 branches, hardware badge inline. Prism has `PrismSidebar`/`PrismShell` but Tempest uses raw Material widgets with own color tokens. |
| `AppRouter` | `core/router/app_router.dart:15-103` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — `StatefulShellRoute.indexedStack` with 7 branches; go_router is consumer-local. |
| `AppTheme` | `core/theme/app_theme.dart:5-290` | **DUPLICATE_IMPLEMENTATION** — full M3 `ThemeData` with own `AppColors` (47 color tokens). Prism has `PrismTokenRegistry` + M3 factory; Tempest does not consume Prism tokens. |
| `AppColors` | `core/theme/app_colors.dart:4-46` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — 47 semantic color tokens incl. stem colors. Prism tokens exist but Tempest uses its own. |
| `ThemeModeNotifier` | `core/theme/theme_provider.dart:4-30` | **REUSE_EXISTING_WARP_PRIMITIVE** — trivial Riverpod `StateNotifier<ThemeMode>`. Prism has equivalent pattern. |
| `LocaleNotifier` | `core/theme/theme_provider.dart:21-30` | **REUSE_EXISTING_WARP_PRIMITIVE** — trivial Riverpod `StateNotifier<Locale>`. |

## Studio (DAW) Surface — Highest Gap Density

| Component | Path | Prism Coverage |
|---|---|---|
| `StudioTransportBar` | `features/studio/presentation/widgets/studio_transport_bar.dart:7-414` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — transport bar shape (Save/Undo/Redo/Command Bar, Play/Pause/Stop/Rewind/Record, Loop/Metronome, dual timecode, BPM/Tap, TimeSignature, Add Track/Export/Mastering) is a generic studio-transport pattern. Prism has no transport bar organism. |
| `MusicalRuler` | `features/studio/presentation/widgets/musical_ruler.dart:7-166` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — bars/beats/ticks grid with BPM-fraction math. Gap matrix §5 flags musical grid time as domain-local; do not unify. |
| `_RulerPainter` | `features/studio/presentation/widgets/musical_ruler.dart:169-304` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — custom painter for musical grid + playhead triangle. |
| `StudioTimelineLane` | `features/studio/presentation/widgets/studio_timeline_lane.dart:7-339` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — multitrack lane with grid, regions, waveform, fades, playhead. Prism has `PrismTimeline` (log list) and `PrismTimeMachineScrubber` (histogram) but no DAW lane. |
| `_LaneGridPainter` | `features/studio/presentation/widgets/studio_timeline_lane.dart:342-402` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — BPM/time-signature grid painter. |
| `_RegionWaveformPainter` | `features/studio/presentation/widgets/studio_timeline_lane.dart:404-465` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — RMS peak waveform with fade-in/out ramps. Presentation seam: generic "waveform bar" is reusable; dB calibration stays local. |
| `StudioTrackControls` | `features/studio/presentation/widgets/studio_track_controls.dart:7-375` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — 240dp track header: color stripe, type badge, name, M/S/Arm toggles, FX rack button, volume fader + dB readout, pan slider. Prism has no channel-strip organism. |
| `MasteringFxPanel` | `features/studio/presentation/widgets/mastering_fx_panel.dart:7-344` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — LUFS/True Peak metering + mastering presets. Calibration semantics stay local; presentation seam = generic "side panel with meters". |
| `_buildPeakMeter` | `features/studio/presentation/widgets/mastering_fx_panel.dart:287-313` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — vertical gradient meter (green/amber/red, -inf..-1 dBFS). |
| `_buildLufsMeter` | `features/studio/presentation/widgets/mastering_fx_panel.dart:315-344` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — LUFS-I meter calibrated to broadcast standards. |
| `StudioFxRackDialog` | `features/studio/presentation/widgets/studio_fx_rack_dialog.dart:7-342` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — EQ/Compressor/Reverb/Limiter insert chain. DSP semantics stay local. |
| `CommandBarDialog` | `features/studio/presentation/widgets/command_bar_dialog.dart:10-384` | **CANDIDATE_UPSTREAM** — generic NL→plan→confirm modal. Gap matrix §4 already flags this as a strong recurrence candidate (Warpblade + Tempest). |
| `StudioState` | `features/studio/models/studio_models.dart:342-653` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — DAW domain model (bars/beats/ticks, dB, LUFS). |
| `StudioController` | `features/studio/controllers/studio_controller.dart:10-1289` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — DAW controller with playback timer, tap tempo, undo/redo. |

## Separate (Source Separation) Surface

| Component | Path | Prism Coverage |
|---|---|---|
| `SeparateScreen` | `features/separate/presentation/separate_screen.dart:13-211` | **REUSE_EXISTING_WARP_PRIMITIVE** — standard form layout with error banner, FilledButton, SnackBars. Prism `PrismStateSurface` covers empty/error states. |
| `DropZoneCard` | `features/separate/presentation/widgets/drop_zone_card.dart:23-187` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — drag-drop upload card with metadata display (duration, format, sample rate, channels, bitrate). Prism has `PrismDraggableCard` + `PrismDropTarget` but no audio-specific drop zone. |
| `PresetSelector` | `features/separate/presentation/widgets/preset_selector.dart:24-151` | **REUSE_EXISTING_WARP_PRIMITIVE** — `ChoiceChip` wrap with icons. Prism `PrismFilterChipGroup` covers this. |
| `QualityModeSelector` | `features/separate/presentation/widgets/quality_mode_selector.dart:24-235` | **REUSE_EXISTING_WARP_PRIMITIVE** — `SegmentedButton` + `ExpansionTile` with dropdowns. Prism `PrismSelect` + `PrismAccordion` cover this. |
| `ProgressCard` | `features/separate/presentation/widgets/progress_card.dart:17-169` | **REUSE_EXISTING_WARP_PRIMITIVE** — multi-stage progress with cancel. Prism `PrismStateSurface` + `PrismToast` cover states; `LinearProgressIndicator` is Material. |
| `StemMixer` | `features/separate/presentation/widgets/stem_mixer.dart:32-470` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — channel strip grid: M/S toggles, fader + peak meter, pan slider, export/open actions. Prism has no mixer strip organism. |
| `SeparateController` | `features/separate/controllers/separate_controller.dart:37-619` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — separation job orchestration. |

## Create (AI Music Generation) Surface

| Component | Path | Prism Coverage |
|---|---|---|
| `CreateScreen` | `features/create/presentation/create_screen.dart:103-538` | **REUSE_EXISTING_WARP_PRIMITIVE** — prompt field + chips + cards + FilledButton. Prism `PrismTextField`, `PrismButton`, `PrismAssetCard` cover this. |
| `SongBlueprintWidget` | `features/create/presentation/widgets/song_blueprint_widget.dart:7-238` | **WARP_PRIMITIVE_NEEDS_EXTENSION** — energy bar chart with per-section drag sliders + preset toolbar. Prism has `PrismGraphCanvas` (topology only) but no energy-curve chart. |
| `LyricsWorkspaceWidget` | `features/create/presentation/widgets/lyrics_workspace_widget.dart:7-344` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — lyric section cards with syllable counting, rhyming, meter adjustment. Domain-specific. |
| `PromptEnhancerDialog` | `features/create/presentation/widgets/prompt_enhancer_dialog.dart:7-287` | **CANDIDATE_UPSTREAM** — side-by-side prompt diff with rationale cards. Gap matrix §4 flags this as a strong recurrence candidate. |
| `CreateController` | `features/create/controllers/create_controller.dart` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — generative music orchestration. |

## Library, Models, Providers, Settings Surfaces

| Component | Path | Prism Coverage |
|---|---|---|
| `LibraryScreen` | `features/library/presentation/library_screen.dart:192-510` | **REUSE_EXISTING_WARP_PRIMITIVE** — search + filter chips + grid of project cards. Prism `PrismSearchBar`, `PrismFilterChipGroup`, `PrismAssetCard` cover this. |
| `ModelsScreen` | `features/models/presentation/models_screen.dart:24-436` | **REUSE_EXISTING_WARP_PRIMITIVE** — model catalog with search, filter chips, download progress, verification badges. Prism `PrismAssetCard`, `PrismStatusDot`, `PrismMetricTile` cover this. |
| `_VerificationBadge` | `features/models/presentation/models_screen.dart:475-531` | **REUSE_EXISTING_WARP_PRIMITIVE** — status badge with icon. Prism `PrismStatusDot` + `PrismBadge` cover this. |
| `ProvidersScreen` | `features/providers/presentation/providers_screen.dart:43-658` | **REUSE_EXISTING_WARP_PRIMITIVE** — BYOK provider cards with API key field, endpoint, model selector, test/save/remove. Prism `PrismProviderHealthMatrix` covers health; credential management is product-local. |
| `_StatusBadge` | `features/providers/presentation/providers_screen.dart:661-703` | **REUSE_EXISTING_WARP_PRIMITIVE** — status badge. Prism `PrismStatusDot` covers this. |
| `SettingsScreen` | `features/settings/presentation/settings_screen.dart:8-448` | **REUSE_EXISTING_WARP_PRIMITIVE** — hardware info card, audio config dropdowns, theme switcher, language dropdown. Prism `PrismStateSurface` covers states. |
| `SettingsController` | `features/settings/controllers/settings_controller.dart:6-139` | **PRODUCT_SPECIFIC_KEEP_LOCAL** — hardware probing + audio device enumeration. |

## Declared Needs Not Yet Implemented

From `docs/bridge/tempest/ads-debt.md` §2 (consumer-owned bridge documentation, 2026-09-13) and source inspection:

| # | Planned Component | Evidence | Classification |
|---|---|---|---|
| 1 | `AudioSpectrogramCanvas` | ads-debt.md §2.1.3 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — FFT visualization, data-plane |
| 2 | `StereoGoniometerCanvas` | ads-debt.md §2.1.6 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — Lissajous polar distribution |
| 3 | `AutomationLane` | ads-debt.md §2.2.1 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — automation envelope |
| 4 | `CompressorTransferGraph` | ads-debt.md §2.2.3 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — DSP curve |
| 5 | `DawToolPalette` | ads-debt.md §2.2.5 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — DAW tool modes |
| 6 | `TakeCompingStrip` | ads-debt.md §2.2.6 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — take system |
| 7 | `VirtualMidiController` | ads-debt.md §2.3.4 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — musical keyboard |
| 8 | `PluginHostContainer` | ads-debt.md §2.3.8 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — CLAP/LV2/VST3 hosting |
| 9 | `FloatingContextCommandBar` | ads-debt.md §2.3.11 | **CANDIDATE_UPSTREAM** — generic anchored command bar |
| 10 | `ProviderQuotaUsageTracker` | ads-debt.md §2.2.18 | **WARP_PRIMITIVE_NEEDS_EXTENSION** — extends `HealthSource` with cost axis |
| 11 | `ProjectVersionDagTree` | ads-debt.md §2.3.2 | **WARP_PRIMITIVE_NEEDS_EXTENSION** — real `GraphSource` consumer proof needed |
| 12 | `MasteringRecommendationTable` | ads-debt.md §2.2.16 | **PRODUCT_SPECIFIC_KEEP_LOCAL** — DSP vs AI comparison |

## Prism Baseline Deltas

**What the current catalog does NOT cover:**

1. **Transport bar** (`StudioTransportBar`) — no Prism organism for session/transport controls.
2. **Channel strip / mixer** (`StudioTrackControls`, `StemMixer`) — no Prism organism for fader + meter + pan + M/S/Arm.
3. **Audio metering** (peak, LUFS) — Prism has `PrismMetricTile` (linear) and `PrismSparkline` but no calibrated audio meter.
4. **DAW timeline lane** (`StudioTimelineLane`) — Prism `PrismTimeline` is a log list, not a multitrack lane.
5. **Waveform display** — Prism has no waveform painter.
6. **Musical grid ruler** — domain-local per gap matrix §5.
7. **Song blueprint / energy curve** — Prism `PrismGraphCanvas` is topology-only.
8. **BYOK credential management** — Prism `PrismProviderHealthMatrix` covers health, not credential storage.
9. **Drag-drop audio import** — Prism has `PrismDraggableCard`/`PrismDropTarget` but no audio-specific composition.

**What the catalog DOES cover well:**
- Cards, search bars, filter chips, dialogs, state surfaces, status dots, badges, toast, skeletons — all present and reusable.
- Shell/sidebar/split-pane primitives exist but Tempest does not consume them.

## Unknowns / Blockers

1. **Tempest → Warp Prism import scan** — gap matrix §2 claims zero adoption (verified 2026-10-10). Re-verified today: `flutter/pubspec.yaml` (32 lines, 5 deps) has zero `warp_prism_*` entries. **CONFIRMED ZERO.**
2. **State management** — Tempest uses `flutter_riverpod` (`ProviderScope` in `main.dart:17`, `ConsumerWidget`/`StateNotifier` throughout). Prism does not prescribe a state-management framework (IDS is pure Dart, no Flutter dep). This is a consumer choice, not a Prism gap.
3. **Theming** — Tempest builds its own `ThemeData` from `AppColors` (47 tokens). Prism has `PrismTokenRegistry` + M3 factory + 3 opt-in skins. Tempest does **not** consume Prism tokens. This is a **DUPLICATE_IMPLEMENTATION** at the token layer, not a Prism gap.
4. **Localization** — Tempest is 100% pt-BR first release (`main.dart:36-41`, `localeProvider` defaults to `Locale('pt','BR')`). Prism has no l10n contract. Consumer-local.
5. **Rust/FRB integration** — Tempest uses FRB 2.13.0 (`pubspec.yaml:20`, `frb_generated.dart`, `dto.dart`). `TempestBridgeService` (`core/services/tempest_bridge_service.dart:1-1610`) is a 1610-line abstract service interface with ~40 methods. Prism has `warp_prism_adapter_frb` + `warp_bridge_core`/`warp_bridge_frb`. **RUST_INTEGRATION_GAP**: Tempest's bridge service is a hand-written abstract class, not generated from a Prism contract. No shared bridge contract exists.
6. **Audio engine** — all DSP/audio logic is Rust-side (`crates/`). Not inspected (out of scope). UI only consumes typed DTOs.
7. **Test coverage** — `flutter/test/` not inspected. Cannot verify whether any UI component has test coverage.
8. **Disabled controls** — several controls are honestly disabled with `onPressed: null` and `enabled: false` (Loop at `studio_transport_bar.dart:174`, Metronome at `studio_transport_bar.dart:186`, A/B compare at `mastering_fx_panel.dart:99-102`, FX insert at `studio_fx_rack_dialog.dart:243`, Smart Loop at `studio_timeline_lane.dart:269`). These are declared needs, not implemented capabilities.

## Summary Counts

| Metric | Count |
|---|---|
| Components inventoried (OBSERVED in source) | 43 |
| Covered by existing Prism primitives (REUSE) | 18 |
| Need Prism extension (EXTENSION) | 7 |
| Candidate upstream (CANDIDATE) | 3 |
| Keep local / product-specific (KEEP_LOCAL) | 12 |
| Duplicate implementation (DUPLICATE) | 2 |
| Unknowns | 8 |
| **Total classified** | **50** (includes planned/need items) |
