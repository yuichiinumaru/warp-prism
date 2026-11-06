# Architect Upgrade Proposal — Tempest → Warp Prism Convergence

> **Artifact:** `.project/research/architect-upgrade-tempest-2026-11-01.md`
> **Date:** 2026-11-01
> **Lane:** Warp Prism architect — read-only synthesis, no implementation grant
> **Posture:** Ambitious, NOT conservative — per explicit request
> **Governing law:** `MISSION.md` §3.1 (full-coverage mandate: absorption is default,
> recurrence = priority not gate) + §11.4 (amendment supersedes recurrence gates,
> keep-local-default, blanket anti-design-system) + §§4–7 (layer contracts, purge law,
> domain leakage, data/control plane) + §6 (evidence gates stand unchanged)
> **Status:** Proposal only. No code, signature, or task is created here.

## 0. Sources read (evidence, not vibes)

| # | Source | Class | Date / state |
|---|---|---|---|
| 1 | `MISSION.md` §§3.1, 11.4, 4–7 | governing law | active canon |
| 2 | `docs/design/component-catalog.md` | canonical index | checked live 2026-10-15; spot re-verified 2026-11-01 (atoms/molecules/organisms dirs) |
| 3 | `.project/research/consumer-inventory-tempest-2026-10-15.md` | OBSERVED-REPORT (32 files) | 43 observed + 12 declared rows; arithmetic discrepancy recorded as UNKNOWN (39 enumerated + 12 declared) |
| 4 | `.project/research/macro-review-unification-map-2026-10-20.md` | synthesis map, live Prism leg | C1–C11 clusters + per-component dispositions §4.2/§4.3 |
| 5 | `docs/bridge/tempest/ads-debt.md` | consumer-owned bridge doc | 2026-09-13; 43 current + 45 planned = 88 uncovered |
| 6 | `.project/architecture/cross-consumer-gap-matrix.md` | accepted-with-amendments | 2026-09-27, rem-0004 2026-10-11; pre-amendment recurrence framing superseded on conflict |
| 7 | Live Prism workspace 2026-11-01 | OBSERVED-LIVE | `packages/warp_prism_{ui,interaction,runtime,bindings,testkit,adapter_frb,host_exercise}`, `apps/catalog` confirmed present |
| 8 | Live Tempest workspace 2026-11-01 | OBSERVED-LIVE (read-only, no mutation) | `flutter/lib/features/{studio,separate,create,library,models,providers,settings}`, 7-branch shell, FRB ^2.0.0, zero `warp_prism_*` deps in `pubspec.yaml` |

**Zero-adoption confirmed again today:** `../tempest/flutter/pubspec.yaml` (6 deps:
`flutter_riverpod`, `go_router`, `freezed_annotation`, `json_annotation`,
`flutter_rust_bridge`, intl) contains **zero** `warp_prism_*` entries. Every
Tempest UI component below is therefore a mandate-covered absorption target,
never a "wait for recurrence" case.

**What this proposal does NOT do:** no API signatures, no package scaffolding,
no task creation, no Tempest mutation, no FRB/Rust redesign. Dispositions follow
the macro-review vocabulary: **REUSE / EXTEND / CANDIDATE / KEEP_LOCAL-domain-only**.

---

## 1. Why ambitious is correct here

1. **The mandate orders it.** §3.1: Prism must eventually hold native equivalents
   of *all* Tempest UI components. Single-consumer is absorbed, not kept local.
   `KEEP_LOCAL` is valid only for domain engines/math/data planes — never as a
   terminal disposition for a UI component.
2. **The corpus already unified the seams.** Macro-review C1–C11 reduces 88
   ads-debt items + 51 inventory rows to **five shared seams + chrome primitives**:
   injected time model, injected capability/authority, injected formatter, honest
   unknown, provenance-as-evidence. Tempest's DAW surface is the richest single
   exercise of seams 1–3.
3. **Tempest's debt is concentrated, not scattered.** ~70% of the gap lives in
   three files/routes: `studio_transport_bar.dart` (414 lines),
   `studio_timeline_lane.dart` (+ painters, ~465 lines),
   `studio_track_controls.dart` (375 lines) + `stem_mixer.dart` (470 lines) +
   `mastering_fx_panel.dart` (344 lines). Five Prism seams absorb the majority.
4. **Convergence is directional, not a flag day** (bridge contract §4). Proposals
   below are ordered so Tempest can adopt incrementally without being blocked by
   a missing primitive — and Prism absorbs without waiting for Tempest to migrate.

**Deliberate non-goal:** no `warp_prism_audio` fork as an excuse to avoid core
evolution. Where geometry is generic (meter fill, fader drag, lane layout,
transport chrome, review framing, command registry), it belongs in Prism core
with **injected calibration/models**. Only data-plane painters (FFT/spectrogram,
goniometer, RMS pyramids at audio rate) stay product-local or in a future
satellite — see U-09.

---

## 2. Ranked upgrades (impact order)

> Impact = (user-visible Tempest value × Prism reuse leverage × unblock power) ÷ gate burden.
> P0–P2 change the trajectory; P3–P5 compound it; P6+ are cheap convergence or staged roadmap.

### U-01 [P0] Token + shell convergence — kill the duplicate design system

**Tempest today:** `AppTheme` (290 lines M3 `ThemeData`) + `AppColors` (47 tokens
incl. stem colors) + `MainShellLayout` (203 lines `NavigationRail`, 7 branches,
hardware badge inline). Prism has `PrismTokenRegistry` + M3 factory + 3 opt-in
skins + `PrismShell`/`PrismSidebar`/`PrismTopbar`/`PrismPageShell` — none consumed.
**Impact:** highest. Every later upgrade renders wrong until tokens converge;
duplicated color layer is the only DUPLICATE_IMPLEMENTATION at the foundation.
**Proposal (EXTEND→REUSE):**
- Map 47 Tempest tokens onto `PrismTokenRegistry`; stem colors stay Tempest-domain
  (injected swatch, not Prism vocabulary — domain leakage rule).
- Converge `MainShellLayout` onto `PrismShell`/`PrismSidebar` composition; shell
  slot state (rail/main/panel) follows macro-review C10 IDS slot-machine seam.
- Adopt `PrismTheme` + one skin; keep `go_router` + `AppRouter` product-local
  (routing is infrastructure, not a component — macro-review 4.2 #2 stands).
**Evidence gates:** host-composition proof in Tempest studio route (theme/focus/
navigation propagation per `AGENTS.md` §7.1); `dart format` + `flutter analyze`
clean; barrel check (`Prism*` only). **Risk:** low-medium (mechanical, wide touch).

### U-02 [P0] `PrismTransportBar` organism — absorb the 414-line studio bar

**Tempest today:** `StudioTransportBar` — session ops (Save/Undo/Redo/Command Bar),
transport (Play/Pause/Stop/Rewind/Record), Loop/Metronome, dual timecode
(`MM:SS.cs` + `Bar.Beat.Tick`), BPM/Tap, time-signature, Add-Track/Export/Mastering.
**Prism now:** no transport organism (only private `_TransportBar` inside
time-machine scrubber — verified live). Gap-matrix row 10 + macro C1.
**Proposal (CANDIDATE, organism):** chrome-only bar (play/pause/±step/scrub + mono
readout) with **injected time model + injected formatter** (Warpblade already made
this the right shape: `formatTime` as caller-supplied function) and caller-supplied
trailing slots for Tempest record/loop/metronome/BPM. No SMPTE/bars-beats ontology
enters Prism. Unify with Warpblade `TransportBar` (2 consumers, highest chrome reuse).
**Evidence gates:** fake transport model + conformance (step sizes, disabled semantics,
formatter injection, keyboard/a11y labels); host proof in **both** real hosts;
determinism (no animation-dependent capture). **Risk:** low. Unblocks U-05/U-06.

### U-03 [P0] Meter + fader family — `PrismMeter` atom + `PrismFaderStrip` molecule

**Tempest today:** `_buildPeakMeter` (green/amber/red, -inf…-1 dBFS), `_buildLufsMeter`
(-24…-6 LUFS), `DbFader` (log gain), `PanKnobSlider` (center-detent), `MuteSoloArmButton`,
`StudioTrackControls` (240dp header), `StemMixer` channel strips, `MasterBusStrip`.
**Prism now:** `PrismMetricTile`/`PrismSparkline` linear-only; negative sweep confirms
zero meter/fader/knob vocabulary. Macro C2.
**Proposal (CANDIDATE):** atom `PrismMeter` with injected scale descriptor + injected
zone thresholds (geometry generic, dBFS/LUFS/RMS calibration injected and local);
molecule `PrismFaderStrip` (meter + fader + label + dB readout + pan + M/S/Arm slots).
Unify `StudioTrackControls` × `StemMixer` into one seam (single-consumer today →
mandate absorption, not recurrence).
**Evidence gates:** golden at fixed viewport/value (meters are the classic
animation-capture trap); a11y (semantics role + numeric value, never colour-only);
host proof in Tempest studio + separate routes; boundary clearance (no audio types
in `warp_prism_ui`). **Risk:** medium (data-plane adjacency — declare rate semantics,
stay control-plane).

### U-04 [P1] Multitrack timeline — `PrismTrackLane` + `PrismTimeRuler` + IDS `TimelineIntent`

**Tempest today:** `StudioTimelineLane` (grid + regions + waveform + fades + playhead),
`MusicalRuler` + `_RulerPainter` + `_LaneGridPainter` + `_RegionWaveformPainter`,
`AudioRegionCard`, trim/crossfade/grid-snap handles (planned atoms).
**Prism now:** `PrismTimeline` is a log list, `PrismLaneBoard` is kanban — neither is
a lane (verified live). Macro C3, highest-coupling cluster.
**Proposal (CANDIDATE):** organism `PrismMultitrackTimeline` = molecule
`PrismTimeRuler` (tick/scale chrome, injected time model) + molecule `PrismTrackLane`
(header gutter + clip rects + min hit-targets + playhead needle) + IDS pure-Dart
`TimelineIntent` verbs (seek/split-at-playhead/ripple/nudge/quantize — Warpblade's
`timeline_intents.dart` is the consumer's own proof that semantics live outside the
widget). Domain painters (BPM grid math, musical math, waveform RMS) stay local;
chrome + verbs unify across Warpblade seconds-model and Tempest bars/beats-model.
**Evidence gates:** **two-ontology conformance** (fake suite passes with seconds AND
bars/beats models or the seam is proven wrong); pixel↔time determinism at fixed
`pixelsPerSecond`; IDS purity (no Flutter); host proof in both hosts; independent
review. **Risk:** high. **Blocking premise:** validate injected-model seam on the
Warpblade side first (weaker layout: single scrolling column, constructor-only zoom).

### U-05 [P1] `PrismDecisionReviewSurface` — one review-before-commit composition

**Tempest today:** `CommandBarDialog` (NL→plan→confirm, 384 lines),
`PromptEnhancerDialog` (side-by-side prompt diff + rationale, 287 lines),
`ActionPlanReviewCard`. Warpblade independently built `ProposalPanel` +
`AssurancePanel`; Command-center built gated `ControlPanel`. Macro C4.
**Prism now:** all parts exist (`PrismDetailInspector`, `PrismEvidenceRow`,
`PrismAssetCard`, templates) but the review framing is absent as a composition.
**Proposal (EXTEND `PrismDetailInspector`):** organism composing inspector sections +
evidence rows + caller-supplied diff region + caller-supplied action bar; verdicts pass
**verbatim** (unknown must fall through to neutral — Warpblade's own rule, Prism-worthy
invariant). Domain plan bodies stay local.
**Evidence gates:** pass-through conformance (unknown/absent verdict can never render
as accepted/pass); host proof in ≥2 hosts; tooltip-reason on every verdict. **Risk:**
medium. Compounds with U-06.

### U-06 [P1] IDS `CommandIntent` registry + palette extension

**Tempest today:** `CommandBarDialog` (Ctrl+K), declared `FloatingContextCommandBar`
(anchored) + `DawToolPalette` (tool modes). Warpblade `WarpbladeKeyboardRouter`
(guard-aware dispatch); Command-center `_GatedAction`. Macro C5 + C11-command-face.
**Prism now:** `PrismCommandPalette` has `id/label/shortcut` but **no registry, no
applicability/enabled-reason, no shortcut index** (verified live); IDS has
`input/inspection/query/selection/state_machine` — **no command-intent module** though
`MISSION.md:32` names it.
**Proposal (CANDIDATE IDS + EXTEND palette):** pure-Dart `CommandIntent` registry
(identity, label, chord, applicability, enabled/disabled reason, enumeration) +
router molecule with edit-focus guard (guard belongs to the widget, eligibility to IDS).
**Evidence gates:** IDS purity; chord-collision/precedence + disabled-reason propagation
conformance; keyboard-only a11y path; host proof in Warpblade + Command-center.
**Risk:** medium (new IDS surface; IDS is `PROVEN`-labelled → needs its own review).

### U-07 [P2] Job banner + honest-unknown state vocabulary

**Tempest today:** `ProgressCard` (multi-stage + cancel + timer), honestly-disabled
controls (`onPressed: null` ×5 sites — declared needs, not done). Warpblade banners
with SHA-256 terminal receipt; Sentry W6/W7 honest-unknown demand. Macro C6.
**Prism now:** `PrismStateSurface` enum lacks unknown/abstained (verified live:
`empty/loading/error/disabled/stale/degraded/excluded`); toast is not a job.
**Proposal (EXTEND):** (a) extend state vocabulary with honest-unknown + not-attempted,
with **fail-closed rendering rule** (unknown ≠ empty/success/disabled in styling and
semantics); (b) molecule `PrismJobBanner` (staged progress + cancel + deterministic
terminal receipt slot). Converge `ProgressCard` × Warpblade banners into it.
**Evidence gates:** fail-closed conformance (unknown-rendering test); determinism
(indeterminate progress excluded from goldens); host proof in Tempest + Command-center
(GOLD host). **Risk:** low-medium. High trust value, cheap build.

### U-08 [P2] Mixer/workspace compositions — no new primitives, converge now

**Tempest today:** `StemMixer` (full post-separation console), `LyricsWorkspaceWidget`
(domain), `SongBlueprintWidget` (energy bar + drag sliders + preset toolbar),
`DropZoneCard`, `PresetSelector`, `QualityModeSelector`, `MasterBusStrip`.
**Proposal (REUSE + EXTEND, zero-gate burden):**
- `LibraryScreen`/`ModelsScreen`/`ProvidersScreen`/`SettingsScreen`/`SeparateScreen`/
  `CreateScreen` → **REUSE** `PrismSearchBar`/`PrismFilterChipGroup`/`PrismAssetCard`/
  `PrismStatusDot`/`PrismMetricTile`/`PrismStateSurface`/`PrismSelect`/`PrismAccordion`
  (macro 4.2 #21–#38 stand; composition guidance only).
- `DropZoneCard` → EXTEND `PrismDropTarget` + `PrismAssetCard` (metadata display is the delta).
- `StemMixer` + `StudioTrackControls` → compose over U-03 `PrismFaderStrip` (no second strip).
- `SongBlueprintWidget` → CANDIDATE P2 energy-curve editor (topology-only `PrismGraphCanvas`
  is insufficient; single consumer → backlog P2, not P0).
- `LyricsWorkspaceWidget`, `StudioFxRackDialog` (EQ/Comp/Reverb chain), lyric syllable
  logic → KEEP_LOCAL-domain-only (DSP/domain, correctly local per §4.5).
**Risk:** low. Fastest adoption win; proves REUSE claims that today rest on catalog reads.

### U-09 [P2] Data-plane-adjacent painters — satellite, not core, and only the host seam

**Tempest today/declared:** `_RegionWaveformPainter` (RMS + fades), planned
`AudioSpectrogramCanvas` (FFT), `StereoGoniometerCanvas` (Lissajous),
`PhaseCorrelationMeter`, `DynamicRangeMeter`, `ParametricEqCurveEditor`,
`CompressorTransferGraph`, `AutomationLane` + node/tension handles.
**Law:** MISSION §7 — data plane must declare transfer/ownership; never model a
high-rate surface as a semantic event stream. Prism core must not import audio types.
**Proposal (KEEP_LOCAL-domain-only + narrow CANDIDATE):** wave/spectral/FFT/goniometer
painters, LUFS/RMS calibration, DSP curves, automation envelopes stay Tempest-local.
The only Prism seam is a **generic canvas-host contract** (fixed-viewport determinism,
downsampled/bounded data, a11y numeric fallback) — if a second media consumer ever
needs it, crystallize as `warp_prism_audio_ui` satellite, never in `warp_prism_ui`.
`AutomationLane` chrome may later ride U-04 lane geometry; the envelope math never does.
**Risk:** medium if over-unified; low if the seam above is respected.

### U-10 [P3] Runtime-proof upgrades — make Tempest the first real `GraphSource`/`HealthSource` host

**Tempest today:** `TempestBridgeService` (1610-line hand-written abstract class, ~40
methods) — no shared bridge contract; `ProviderQuotaUsageTracker` (declared, cost axis);
`ProjectVersionDagTree` (declared DAG); `HardwareStatusIndicator` (GPU/PipeWire badge).
Prism has `AsyncCommand`/`EventStream`/`HealthSource`/`GraphSource` + fakes + testkit,
all EXPERIMENTAL, zero consumer proofs (gap-matrix §1/§6).
**Proposal (runtime, not ADS):**
- `ProjectVersionDagTree` → first real `GraphSource` consumer proof (blocked until the
  DAG surface exists — record as dependency-gated HOLD, not ready work).
- `ProviderQuotaUsageTracker` → `HealthSource` cost-axis extension proposal.
- `HardwareStatusIndicator` → converge onto `PrismProviderHealthMatrix` + health card
  (BYOK credential storage stays product-local per secrets law).
- Long-tail: `ProgressCard` staged jobs → `AsyncCommand` parity suite (fake vs real adapter).
**Evidence gates:** same suite passes for fake and real adapter; transfer/ownership
declared for any high-rate payload; independent review. **Risk:** medium-high; payoff is
proving the runtime layer Tempest will eventually ride.

---

## 3. What stays Tempest-local (and why — domain law, not conservatism)

| Local | Law |
|---|---|
| Musical-grid math (`MusicalRuler` fractions, `_RulerPainter`, `_LaneGridPainter`, BPM/time-sig arithmetic), rational AV arithmetic (Warpblade side) | MISSION §4.5 + gap-matrix §5: incompatible time ontologies; chrome unifies, ontology never does |
| DSP/insert chains (`StudioFxRackDialog`, mastering calibration, LUFS broadcast targets, RMS windowing, EQ/comp/reverb internals) | domain engine; calibration injected, never owned |
| Waveform/spectral/goniometer painters, FFT pyramids, Lissajous distribution | data plane (§7); product-local until a declared transfer contract exists |
| DAW/generation orchestration (`StudioState`, `StudioController`, `SeparateController`, `CreateController`), take/comping systems, MIDI surfaces, plugin hosting (CLAP/LV2/VST3), lyric syllable/rhyme engine, credential storage, hardware probing | domain models/engines/persistence/workflows; explicit bypass is a feature |
| `go_router` routing, Riverpod holders, pt-BR l10n, crash-recovery dialog bodies | consumer infrastructure |

Nothing above is a terminal disposition for a *UI component* — each has its chrome
counterpart in §2 absorbed under mandate law.

---

## 4. Execution order (ambitious but collision-safe)

```text
Wave 1 (unblocks everything):  U-01 tokens+shell  →  U-07 job/state vocab
Wave 2 (DAW core):              U-02 transport  +  U-03 meter/fader  (parallel-safe: distinct seams)
Wave 3 (timeline + intent):     U-04 lane/ruler/verbs  (needs U-02 formatter discipline)
Wave 4 (decision + command):    U-05 review surface  +  U-06 command registry  (parallel-safe)
Wave 5 (convergence sweep):     U-08 REUSE sweep  (no new primitives; do early if a builder is free)
Wave 6 (proof + roadmap):      U-10 runtime proofs  +  U-09 satellite seam  (dependency-gated where declared)
```

Shared-write guards: `PrismTokenRegistry`/skins (U-01), `prism_aliases.dart`/barrels,
`boundary_test.dart`, gallery registry, `layer-contracts.md` — one owner per invariant;
parallelism elsewhere is safe. `AppRouter`, Tempest `crates/`, secrets/keyring paths are
never Prism touch-targets.

---

## 5. Per-artifact reconciliation notes (honest deltas)

- **ads-debt §4.2 (satellite-first) is superseded in emphasis, not deleted:** the doc's
  instinct (don't pollute core with dB math) is correct and preserved via injected
  calibration; its recommendation to keep 80+ components out of Prism core is superseded
  by §3.1 — generic chrome *does* enter core, only math/painters/engines stay out.
- **Gap-matrix §3 rows 9–16 (`L` dispositions) are partially superseded:** ontology-local
  stands; chrome/verb `L` is replaced by CANDIDATE/EXTEND per macro-review C1–C4 + mandate.
  Rows 4/6/19 already pointed at CANDIDATE and are confirmed, not changed.
- **Inventory UNKNOWN-1 (43 vs 39+12 arithmetic) is inherited, not resolved:** §2 counts
  use the enumerated 39 observed + 12 declared; a re-scan of Tempest at task-creation
  time must reconcile the 4-row gap before U-04/U-09 HOLDs promote.
- **Sentry/Command-center/Warpblade legs** are inherited-report, not re-read this session;
  every cross-consumer claim (C1/C4/C5/C6/C7/C11) carries that provenance and needs
  host-proof in ≥2 hosts before STABLE.

---

## 6. Definition of ready (for the future task wave, not this artifact)

No task from §2 promotes to `01-open` until: injected-model/formatter seams are
decided on evidence (U-02/U-04), calibration-injection boundary is explicit (U-03/U-09),
fake + conformance + boundary + host-proof + independent-review gates (§6 items 2–7)
are named in the task, and writesets/owners are collision-checked. Declared-only
surfaces (`ProjectVersionDagTree`, quota tracker, automation console) remain HOLD in
`00-planning` until Tempest builds the local counterpart.

---

## 7. Return-packet summary

Ambitious Tempest upgrade path = **converge the foundation (U-01), absorb the studio
chrome (U-02–U-04), unify decision/command (U-05–U-06), sweep the cheap reuse (U-07–U-08),
prove the runtime (U-10), satellite only the data plane (U-09)** — ranked by impact
above, each with its Prism owner, Tempest counterpart, disposition, evidence gate, and
risk. Highest recurrence cluster touched: capability-gated action (C11, four consumers)
via U-06/U-07; richest single-consumer cluster: DAW transport/meter/lane (C1–C3) via
U-02–U-04. No implementation, no Tempest writes, no authority changes proposed.
