# Macro-Review Unification Map — Cross-Consumer Component Clusters

- **Artifact:** `.project/research/macro-review-unification-map-2026-10-20.md`
- **Date:** 2026-10-20 (report epoch; synthesis session ran 2026-11-01)
- **Lane:** Warp Prism macro-review synthesizer — **read-only synthesis, no implementation**
- **Governing law:** `MISSION.md` §3.1 (full-coverage central ADS+IDS, absorption default,
  recurrence = priority not gate, evidence gates §6.2–§6.7 stand, domain engines stay local
  per §4.5) + §11.4 (amendment). **MISSION WINS** over consumer-local dispositions, stale
  bridge prose, and pre-amendment recurrence framing.
- **Phase posture:** this is a macro-review *decision map*, not a task plan, not an API design,
  not an implementation grant. No code, signature, or task is created here.
- **Scope:** every UI component inventoried in the six input artifacts, plus the donor
  mechanisms already harvested, clustered by similar purpose and given a disposition.

---

## 1. Header — evidence provenance and method

### 1.1 Inputs read (all workspace-local)

| # | Artifact | Evidence class | Consumer-side currency |
|---|---|---|---|
| 1 | `.project/research/consumer-inventory-warpblade-2026-10-15.md` | OBSERVED-REPORT (live source read 2026-10-15) | mtimes 2026-09-07…2026-10-02; **revision state UNKNOWN** (VCS denied) |
| 2 | `.project/research/consumer-inventory-tempest-2026-10-15.md` | OBSERVED-REPORT (32 files read 2026-10-15) | revision state UNKNOWN |
| 3 | `.project/research/sentry-requests-prism-verification-2026-10-20.md` | OBSERVED-REPORT (Prism-side live re-verify) + **DECLARED consumer requests** | Sentry has **no Flutter UI surface** (§6 of that report) |
| 4 | `.project/research/command-center-inventory-verification-2026-10-20.md` | OBSERVED-REPORT (both legs read 2026-10-20) | live clone read; revision state UNKNOWN |
| 5 | `.project/research/donor-harvest-figcraft-2026-10-15.md` | `IMPL`/`TEST-DEF`/`DOC` mix, partial; **inspiration only** | donor, not a consumer |
| 6 | `.project/research/donor-harvest-everything-2026-10-15.md` | OBSERVED source reads; **inspiration only** | donor, not a consumer |
| 7 | `docs/design/component-catalog.md` | canonical index, checked 2026-10-15 | — |
| 8 | `MISSION.md` §§3–6, §11.4 | governing law | — |
| 9 | `.project/architecture/cross-consumer-gap-matrix.md` | accepted-with-amendments 2026-09-27; **pre-amendment recurrence framing** | superseded on conflict by §3.1/§11.4 |

### 1.2 Method, and what this pass did *not* do

- **Prism side is OBSERVED-LIVE this session.** Directory listings and class/enum declaration
  lines under `packages/warp_prism_ui/lib/src/{atoms,molecules,organisms}/`,
  `packages/warp_prism_ui/lib/src/prism_aliases.dart`, and
  `packages/warp_prism_interaction/lib/src/` were read directly. Negative sweeps
  (`waveform|transport|lufs|peak meter|goniometer|spectrogram|fader|knob`) were run over
  `packages/warp_prism_ui/lib/src/`.
- **Consumer side is INHERITED-REPORT, not re-read this session.** Every consumer `path:line`
  below comes from inputs 1–4. Those reports were live reads at their dates; this pass did not
  re-open consumer sources. Treat consumer citations as *report-grade*, Prism citations as
  *live-grade*.
- **No execution.** No build, test, golden, analyze, or runtime observation was performed on any
  side. No host-composition evidence exists for any cluster. No VCS operation.
- **No catalog line-diff was re-run.** `docs/design/component-catalog.md` was compared against
  live source only where a disposition depends on it (see §2.2).
- **Disclosed input inconsistency.** Input 2's own summary claims "43 components inventoried /
  50 total classified", while its tables enumerate **39 observed rows** and **12 declared rows**
  (51). This map accounts all 39 + 12 and records the discrepancy as UNKNOWN-1 rather than
  silently reconciling the arithmetic.

### 1.3 Disposition vocabulary (as mandated)

| Disposition | Meaning under §3.1 |
|---|---|
| **REUSE** | Existing Prism surface already covers it; consumer should converge; **no new Prism primitive**. |
| **EXTEND** | Prism has the right owner but the wrong/insufficient vocabulary; extend that owner. |
| **CANDIDATE** | No adequate Prism surface; mandate-covered UI → candidate primitive with evidence gates. |
| **KEEP_LOCAL-domain-only** | Genuinely non-UI domain logic, or a domain ontology/engine/data plane that §4.5 and §7 keep product-local. **Never** a terminal disposition for a generic UI component. |

Cluster decisions use **UNIFY** (one shared primitive absorbs several consumers' variants),
**KEEP-DISTINCT** (shared seam, incompatible ontology — merge chrome only), and
**KEEP-LOCAL** (domain-only).

---

## 2. Executive synthesis

### 2.1 The macro finding

The nine consumer clusters do **not** decompose into nine widgets. They decompose into
**five shared seams plus a small number of chrome primitives**. The recurring structure across
Warpblade, Tempest, Command-center and Sentry is:

1. **Injected time model** — Warpblade rational AV time, Tempest musical grid, Sentry five-clock
   family, Prism wall-clock scrubber. Four ontologies, one chrome.
2. **Injected capability / authority** — Warpblade null-callback-as-capability, Command-center
   `_GatedAction`/`PermissionSection`, Tempest `onPressed: null`, Sentry Allow/Constrain/Deny.
   Four independent re-inventions of "this action is not available, and here is why".
3. **Injected formatter** — Warpblade injects `formatTime` rather than owning timecode
   (`transport_bar.dart:5-13`); Tempest owns its own; Prism owns none.
4. **Honest unknown** — Sentry W6/W7 is the sharpest expression, but Command-center's
   `StateRegion`, Warpblade's duplicated inline error blocks, and Prism's `DSStateType` all lack
   a vocabulary for "we do not know" as distinct from "empty", "error", or "disabled".
5. **Provenance as evidence, not decoration** — Warpblade carries digest/fingerprint/SHA-256,
   Command-center groups by causation, Sentry wants hash witnesses; Prism's
   `PrismProvenancePill` is **canonicity only** (`ds_provenance_pill.dart:8`, `:9-41`, `:110-127`).

### 2.2 Live Prism baseline corrections that matter to this map

- **No transport organism exists.** The only transport chrome in the package is the *private*
  `_TransportButton` (`organisms/time_machine_scrubber/ds_time_machine_scrubber.dart:797`) and
  `_buildTransportRow` (`:687`) inside the time-machine scrubber. `showTransport` is a flag on
  that organism (`:181`, `:214`), not an exported primitive. The negative sweep found **zero**
  hits for waveform / LUFS / peak meter / goniometer / spectrogram / fader / knob anywhere in
  `packages/warp_prism_ui/lib/src/`.
- **`DSStateType` has no honest-unknown member.** Live enum
  (`molecules/ds_state_surface.dart:294-315`) = `empty, loading, error, disabled, stale,
  degraded, excluded`. Sentry W6/W7's central complaint is therefore confirmed against live
  source, not just against a stale catalog.
- **`DSCommand` has no registry.** `organisms/command_palette/ds_command_palette.dart:28`
  carries `id/label/description/icon/category/onExecute/route/shortcut`, but there is no
  enumeration surface, no applicability/enabled-reason, and no shortcut index. `packages/
  warp_prism_interaction/lib/src/` contains `input, inspection, query, selection, state_machine`
  — **no command-intent module**. Command *intent* is the IDS responsibility named in
  `MISSION.md:32` and it is currently unowned.
- **`DSOperationalState` is binary on authority** — `approved`/`rejected` (`tokens/
  ds_operational_state.dart:30-34`) with no Allow/Constrain/Deny and no reasoned-disabled.
- **`PrismTimeline` is a log list, not a lane** (`organisms/ds_timeline.dart:9`, entry model
  `:69`); `PrismLaneBoard` is a kanban-style column board (`organisms/ds_lane_board.dart:16`,
  `DSLane` `:262`, `DSLaneTask` `:270`) — it is **not** a multitrack lane and must not be
  conflated with one.
- **Table/list coverage is genuinely strong** — `DSDataTable` with sort state, column/row models
  and specialized cells (`organisms/data_table/ds_data_table.dart:12,45,94,124,146,163,179`),
  `DSVirtualList`/`DSVirtualGrid` (`organisms/virtual_scroll/ds_virtual_scroll.dart:134,390`),
  `DSStatusGrid` (`organisms/ds_status_grid.dart:48`). The tables/boards cluster is mostly
  convergence work, not construction work.

### 2.3 Law checks applied

- Recurrence was used **only as priority**, never as a gate (§3.1). Single-consumer UI is
  absorbed as CANDIDATE where it is a real product component.
- `KEEP_LOCAL` was assigned **only** to domain engines/ontologies/data planes: musical-grid math,
  rational AV arithmetic, DSP/plug-in hosting, LUFS/broadcast calibration, audio/spectral
  painters, credential storage, lyric/syllable domain, DAW/generation orchestration.
- Domain leakage rule honored bidirectionally: no `Warpblade*`/`Tempest*`/`Sentry*`/
  `CyberCore*` vocabulary is proposed for Prism core; Sentry's decision-reconstruction
  *models* stay in Sentry, only its *interaction semantics* are candidates.
- **Donor material is not demand.** FigCraft and Everything mechanisms appear in §8 as
  inspiration leads only. Under §3.1/§10 coverage is bounded by real Ganthritor product
  components, so a donor-only idea is **not** a candidate and is **not** in the backlog.

---

## 3. Cluster map

Eleven clusters. The nine requested purposes are C1–C9; two additional clusters emerged from
the evidence and cannot be honestly omitted (C10 shells, C11 capability-gated action — the
latter being the highest-recurrence cluster in the entire corpus).

Legend for the `Prism now` column: **[L]** = verified live this session, **[C]** = catalog-only
claim, **[R]** = inherited from an input report.

---

### C1 — Transport / time control & timecode

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `TransportBar` | `lib/src/ui/transport_bar.dart:3-99` | Warpblade | [R] |
| `StudioTransportBar` | `features/studio/presentation/widgets/studio_transport_bar.dart:7-414` | Tempest | [R] |
| `formatTime` / `formatRange` | `lib/src/bridge/rational_time.dart:9-14`, `:73-79` | Warpblade | [R] |
| `TimecodeCounter` (mono readout) | gap-matrix row 4 (Warpblade + Tempest) | both | [C] |

**Prism now [L]:** no transport organism. Private `_TransportButton`
(`ds_time_machine_scrubber.dart:797`), `_buildTransportRow` (`:687`), `showTransport` flag
(`:181`, `:214`); `DSMetricTile` (`molecules/ds_metric_tile.dart:20`), `DSMetricTileCompact`
(`:172`), `DSTrend` (`:147`); `DSTimelineMarker`; `PrismKeyboardCheatsheet`.

**Delta:** (a) transport chrome as a reusable cluster — play/pause, ±step, scrub, mono readout,
with a *slot* for record/loop/metronome/BPM that Tempest needs and Warpblade does not;
(b) an injected timecode formatter (Warpblade already made this the right decision:
`formatTime` is a caller-supplied `String Function(double)`, `transport_bar.dart:5-13`);
(c) no time ontology in Prism at all.

**Decision: UNIFY chrome, KEEP-DISTINCT ontology.** Both consumers want the same visual and
interaction cluster; neither may impose SMPTE or bars/beats on the other. Gap-matrix §5 (three
incompatible time ontologies) remains correct and is *satisfied*, not violated, by chrome-only
unification.

**Proposed Prism-native seam:** organism `PrismTransportBar` (layer: **organism**), composed
from existing atoms (`PrismButton`/`PrismIcon`) + a mono readout molecule; time enters as an
opaque injected model plus an injected formatter, and optional trailing slots are caller-supplied
so Tempest's record/loop/metronome do not enter Prism vocabulary. No signature proposed.

**Evidence gates needed (§6):** fake transport model + conformance suite covering step sizes,
disabled semantics, formatter injection, and keyboard/a11y labels; host-composition proof in
**both** real hosts; determinism (no animation-dependent capture); independent review.
**Risk:** low. **Blocking premise:** none.

---

### C2 — Meters / levels / faders

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `_buildPeakMeter` | `mastering_fx_panel.dart:287-313` | Tempest | [R] |
| `_buildLufsMeter` | `mastering_fx_panel.dart:315-344` | Tempest | [R] |
| `MasteringFxPanel` | `mastering_fx_panel.dart:7-344` | Tempest | [R] |
| `StemMixer` (fader + peak) | `stem_mixer.dart:32-470` | Tempest | [R] |
| `StudioTrackControls` (fader + dB) | `studio_track_controls.dart:7-375` | Tempest | [R] |
| Warpblade metering | — | Warpblade | **negative: not applicable** |

**Prism now [L]:** `DSMetricTile` (`ds_metric_tile.dart:20`, `DSMetricTileHealth` `:152`),
`DSMetricTileCompact` (`:172`), `DSSparkline`, `DSUptimeBar`, `DSStatusGrid`
(`ds_status_grid.dart:48`). All **linear and uncalibrated**. No vertical meter, no threshold
zones, no peak-hold, no fader control (negative sweep confirmed).

**Delta:** meter *geometry* (vertical fill, green/amber/red zones, peak-hold marker, fader track
+ handle + drag semantics) versus *calibration* (dBFS floor, LUFS-I broadcast targets, RMS
windowing). Only the geometry is generic.

**Decision: UNIFY geometry, KEEP-DISTINCT calibration.** Single consumer (Tempest) today, so
this is mandate-covered absorption rather than recurrence-driven — but it is also the cluster
where over-unification is most tempting and most wrong: LUFS is a standard, dBFS is a scale, and
neither belongs in a design system.

**Proposed Prism-native seam:** atom `PrismMeter` (layer: **atom**) with an injected scale
descriptor and injected zone thresholds; molecule `PrismFaderStrip` (**molecule**) composing
meter + fader + label + dB readout slot. Calibration constants, LUFS targets, and RMS windowing
stay in Tempest. No API proposed.

**Evidence gates:** fake scale + golden capture at fixed viewport and fixed value (determinism is
critical — meters are the classic animation-dependent-capture trap); a11y (semantics role +
numeric value, not colour-only); host proof in Tempest studio route; boundary clearance (no audio
types in `warp_prism_ui`). **Risk:** medium (data-plane adjacency).

---

### C3 — Timelines / scrubbers / lanes

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `TimelineStrip` (ruler + lanes + clips + playhead) | `lib/timeline_strip.dart:4-541` | Warpblade | [R] |
| `TimelineIntentResolver` (seek/split/ripple/nudge) | `lib/src/bridge/timeline_intents.dart:5-161` | Warpblade | [R] |
| `StudioTimelineLane` | `studio_timeline_lane.dart:7-339` | Tempest | [R] |
| `MusicalRuler` + `_RulerPainter` | `musical_ruler.dart:7-166`, `:169-304` | Tempest | [R] |
| `_LaneGridPainter` | `studio_timeline_lane.dart:342-402` | Tempest | [R] |
| `_RegionWaveformPainter` | `studio_timeline_lane.dart:404-465` | Tempest | [R] |
| Five-clock family (W4, PARTIAL) | Sentry request | Sentry | [R] |
| `DSTimeMachineScrubber` (existing) | `ds_time_machine_scrubber.dart:146` | Prism | [L] |

**Prism now [L]:** `DSTimeMachineScrubber` (`:146`, domain/playhead/range API per sentry report
`:242-277`, `:341-351`), `DSTimeline` **log list** (`ds_timeline.dart:9`), `DSTimelineMarker`,
`DSLaneBoard` **kanban board** (`ds_lane_board.dart:16`) — explicitly *not* a multitrack lane.
No ruler, no clip geometry, no playhead needle, no zoom.

**Delta:** three separable concerns. (i) **Ruler chrome** — tick/grid/scale painting with an
injected time model (Warpblade seconds, Tempest bars/beats/ticks, Sentry artifact clocks).
(ii) **Lane geometry** — track header gutter + horizontal scroll + clip rectangles + minimum hit
targets + playhead needle. (iii) **Interaction verbs** — pixel→time seek, split at playhead,
ripple delete, nudge, quantize: Warpblade already extracted these out of the widget
(`timeline_intents.dart:5-8` is the consumer's own statement of the "semantics live outside the
widget" pattern), which is exactly the IDS shape Prism is missing.

**Decision: UNIFY chrome + verbs, KEEP-DISTINCT ontology.** Gap-matrix §3 row 9's "G ×3
ontologies — do not unify; **L**" is now *partially superseded* by §3.1: the ontology stays local
(`MusicalRuler` math, rational AV arithmetic), but the chrome and verbs are mandate-covered UI/IDS
and absorption is the default. What must **not** happen is a single widget with two incompatible
type inputs (gap-matrix §4's honest warning) — hence chrome-with-injected-model, not merged model.

**Proposed Prism-native seam:** (a) organism `PrismMultitrackTimeline` (**organism**) composed of
molecule `PrismTimeRuler`, molecule `PrismTrackLane`, atom-level playhead; (b) IDS
`TimelineIntent` verbs (**IDS, pure Dart**) as generic seek/split/nudge/quantize over an injected
time model. Domain painters (`_LaneGridPainter`, `_RegionWaveformPainter`, musical math) stay in
Tempest; rational arithmetic stays in Warpblade. No API proposed.

**Evidence gates:** a **two-ontology conformance requirement** — the fake time model suite must
pass with both a seconds-based and a bars/beats-based model, or the seam is proven wrong; exact
pixel↔time determinism (golden at fixed `pixelsPerSecond`); IDS purity test (pure Dart, no
Flutter); host proof in Warpblade and Tempest; independent review. **Risk:** high (highest
coupling in the corpus). **Blocking premise:** the injected-model seam must be validated on the
Warpblade side first — Warpblade has the weaker layout (single scrolling column, no zoom UI,
`pixelsPerSecond` is constructor-only, `timeline_strip.dart:30`).

---

### C4 — Inspectors / cards / review surfaces

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `ProposalPanel` (evidence + diff + override + accept/reject) | `proposal_panel.dart:4-466` | Warpblade | [R] |
| `AssurancePanel` + `RepairDialog` (bounded repair) | `assurance_panel.dart:5-778` | Warpblade | [R] |
| `TakeTilesPanel` / `TakeTile` (audition/compare/promote) | `take_tiles.dart:139-591` | Warpblade | [R] |
| `ProjectPanel` (lifecycle actions + dirty + digest) | `project_panel.dart:4-181` | Warpblade | [R] |
| `MediaPanel` probe strip | `media_panel.dart:103-140` | Warpblade | [R] |
| `CommandBarDialog` (NL→plan→confirm) | `command_bar_dialog.dart:10-384` | Tempest | [R] |
| `PromptEnhancerDialog` (side-by-side diff) | `prompt_enhancer_dialog.dart:7-287` | Tempest | [R] |
| `SessionDetail` | `sessions.dart:240` | Command-center | [R] |
| `ProvenanceView` | `provenance_view.dart:55` | Command-center | [R] |
| `ControlPanel` | `control_panel.dart:25` | Command-center | [R] |
| W1 dual-authority panes, W3 advisory, W10 episode, W11 hypothesis | Sentry requests | Sentry | [R] |

**Prism now [L]:** `DSDetailInspector` (`ds_detail_inspector.dart:10`, `DSDetailSection` `:194`,
`DSPropertyRow` `:210`, `DSLinkRow` `:252`), `DSStoryPanel` (`organisms/ds_story_panel.dart:9`),
`DSEvidenceRow`, `DSAssetCard`, `DSTaskCard`, `DSMediaDetailOverlay`, `DSArtifactWorkbench`,
`MasterDetailTemplate` (`templates/master_detail_template.dart:27-266`).

**Delta:** the *review-before-commit* surface — status header + evidence list + computed diff +
constraint list + bounded-override actions + accept/reject — is absent as a composition even
though every part exists. Three consumers independently built it (Warpblade proposal review,
Tempest command-plan review, Command-center control panel with gated actions).

**Decision: EXTEND + UNIFY.** `DSDetailInspector` is the right owner; the missing vocabulary is
the review/decision framing, not a new inspector.

**Proposed Prism-native seam:** organism `PrismDecisionReviewSurface` (**organism**) composing
inspector sections + evidence rows + a caller-supplied diff region + a caller-supplied action
bar; verdict/status values pass through **verbatim from the data** (Warpblade's own rule:
unknown verdicts must fall through to neutral, `take_tiles.dart:5-11`, `:29-63` — this is a
Prism-worthy invariant, not a Warpblade detail). Domain content (proposal diff computation,
assurance registry, session grouping) stays in the consumer.

**Evidence gates:** fake review model + conformance asserting **pass-through integrity** (an
unknown/absent verdict can never render as accepted/pass); host proof in ≥2 hosts; a11y
(tooltip-reason on every verdict); independent review. **Risk:** medium.

---

### C5 — Palettes / commands / keyboard

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `WarpbladeKeyboardRouter` (guard-aware dispatch) | `keyboard_shortcuts.dart:4-85` | Warpblade | [R] |
| `CommandBarDialog` | `command_bar_dialog.dart:10-384` | Tempest | [R] |
| `FloatingContextCommandBar` (declared) | `ads-debt.md` §2.3.11 | Tempest | DECLARED |
| `DawToolPalette` (declared) | `ads-debt.md` §2.2.5 | Tempest | DECLARED |
| `_GatedAction` command invocation | `control_panel.dart:49-138` | Command-center | [R] |
| W8 authority dispositions, W9 partial fill | Sentry requests | Sentry | [R] |

**Prism now [L]:** `DSCommandPalette` (`ds_command_palette.dart:82`) with `DSCommand` (`:28`,
includes a `shortcut` hint), `DSCommandCategory` (`:12`), `showDSCommandPalette`; `DSToolStripSlideout`,
`DSKeyboardCheatsheet`, `DSExecutionConsole`, `DSToolCallCard`.
**IDS now [L]:** `input, inspection, query, selection, state_machine` — **no command module**
(directory listing). Command *intent* is named as an IDS responsibility in `MISSION.md:32` and is
currently unowned.

**Delta:** (a) a **command registry** — one enumeration with id/label/shortcut/applicability/
enabled-reason, so palette, menubar, toolstrip and keyboard bindings cannot drift;
(b) a **shortcut index** with collision/precedence resolution and an edit-focus guard;
(c) **dispatch eligibility** — "may this run now, and if not, why" (the C11 cluster's command
face). Warpblade's router already implements the guard correctly
(`FocusManager.instance.primaryFocus?.context?.widget is EditableText`, `:62-64`) and Tempest's
declared `FloatingContextCommandBar` wants the anchored variant.

**Decision: UNIFY the registry (IDS), EXTEND the palette.** The palette is already the right
surface; it lacks a registry to draw from and the IDS lacks the intent model.

**Proposed Prism-native seam:** IDS `CommandIntent` registry (**IDS, pure Dart**): command
identity, label, shortcut chord, applicability predicate, enabled/disabled reason, and an
enumeration surface. Presentation stays `DSCommandPalette` + `DSToolStripSlideout`. Dispatch
router as a molecule with the edit-focus guard. No API proposed.

**Evidence gates:** IDS purity (pure Dart, no Flutter — the guard is a *presentation* concern and
must not enter IDS; the guard belongs to the router widget, the eligibility predicate to IDS);
conformance for chord collision/precedence, disabled-reason propagation, and enumeration
stability; keyboard-only a11y path; host proof in Warpblade and Command-center. **Risk:** medium
(the registry is a new IDS surface and IDS is `PROVEN`-labelled today — extending it needs its own
review).

---

### C6 — State surfaces / loading / progress / jobs

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `LoadingPane` / `LoadingRow` / `StateRegion` | `integration/loading.dart:17,42,69` | Command-center | [R] — **GOLD** candidate in input 4 |
| `ProgressCard` (multi-stage + cancel) | `progress_card.dart:17-169` | Tempest | [R] |
| `ErrorBanner` / `ExportProgressBanner` / `ExportReportBanner` | `banners.dart:4-155` | Warpblade | [R] |
| Duplicated inline error blocks | `generation_drawer.dart:356-372`; `take_tiles.dart:250-268`; `assurance_panel.dart:228-246` | Warpblade | [R] |
| `DaemonNotConnected`, `DaemonBootstrap` | `main.dart:81`, `:123` | Command-center | [R] |
| W6 unknown/dispatch fold (**highest priority**), W7 reasoned abstention | Sentry requests | Sentry | [R] |

**Prism now [L]:** `DSStateSurface` (`ds_state_surface.dart:31`) with `DSStateType` (`:294-315`)
= `empty, loading, error, disabled, stale, degraded, excluded`; `DSShimmer`, `DSSkeletonTextLine`,
`DSSkeletonCard`, `DSSkeletonTableRows`, `DSToast`/`DSToastManager`, `DSFallbackView`,
`DSErrorBoundary`, `DSMessageStatusHistory` (`DSMessageStatusStepState` per sentry report `:10-22`
lacks `unknown`).

**Delta:** (a) **honest-unknown** and **reasoned abstention** are not in the vocabulary — the
enum has no member for "the system does not know, and that is a distinct fact from empty/error/
disabled". This is Sentry's #1 finding and it is confirmed live. (b) **Persistent job banner**
with staged progress, cancel, and a deterministic terminal receipt (Warpblade prints
`DEST/FRAMES/BYTES/SHA256`, `banners.dart:95-155`) — toast is not a job. (c) **Loading chrome
consolidation** — Command-center's non-animated loading trio is explicitly justified in source
(`loading.dart:3-11`) and duplicates `DSStateSurface`'s loading/empty/error modes.

**Decision: EXTEND `DSStateSurface` + UNIFY loading chrome + CANDIDATE job banner.**

**Proposed Prism-native seam:** (a) extend the state vocabulary (`DSStateType` + IDS
inspection/query states) with honest-unknown and abstained/not-attempted, with a **fail-closed
rendering rule**: unknown must never degrade to empty, success, or disabled styling;
(b) molecule `PrismJobBanner` (**molecule**) for staged long-running work with cancel + terminal
receipt slot; (c) converge loading chrome into `DSStateSurface` modes rather than a new molecule.

**Evidence gates:** conformance suite that **fails closed** — a dedicated test asserting
unknown ≠ empty ≠ success ≠ disabled in both semantics label and styling; determinism (indeterminate
progress must be excluded from golden capture, per the purge law on animation-dependent
observation); host proof in Command-center (the GOLD candidate's own host) and Warpblade; a11y
state announcements. **Risk:** low-medium. **Blocking premise:** none.

---

### C7 — Provenance / seal / tamper evidence

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| Observation list: fingerprint, input digest, exact `observedAtNum/Den` | `assurance_panel.dart:411-506` | Warpblade | [R] |
| `_ProvenanceStrip` (seed/fingerprint/params/lineage SAME\|DIFFER) | `take_tiles.dart:141-152`, `:653-741` | Warpblade | [R] |
| `ExportReportBanner` SHA-256 receipt | `banners.dart:95-155` | Warpblade | [R] |
| `ProvenanceView` (causation grouping) | `provenance_view.dart:55` | Command-center | [R] |
| W2 sealed, W13 hash/tamper, W14 phase rail | Sentry requests | Sentry | [R] |
| `_ProvenanceStrip` in take tiles | `take_tiles.dart:116` | Warpblade | [R] |

**Prism now [L]:** `DSProvenancePill` (`ds_provenance_pill.dart:8`, size enum `:130`) —
**canonicity only** (`:9-41`, `:110-127`); `DSEvidenceRow`; `DSMessageStatusHistory`. No hash, no
verification state, no sealed mode, no tamper evidence (confirmed by input 3's grep and by this
pass's reading of the pill).

**Delta:** three distinct provenance facts that Prism currently collapses into one badge:
canonicity (what Prism has), **witness** (a hash + verification state: verified/unverified/
mismatched/unknown), and **immutability** (sealed: no affordance may be rendered on a sealed
artifact). Three consumers carry at least one of these, independently.

**Decision: UNIFY into a provenance family.** Highest recurrence in this cluster (Warpblade digest
+ fingerprint + SHA-256, Command-center causation view, Sentry hash witness) and the highest
correctness stakes: a badge that renders "verified" when verification is unknown is a trust defect.

**Proposed Prism-native seam:** atom `PrismProvenanceBadge` (canonicity, existing pill renamed/
extended) + atom `PrismWitnessBadge` (**atom**: hash token + verification state, opaque hash
string, no hashing logic in Prism) + a **sealed rendering-mode contract** (presentation-level
rule: when an artifact is sealed, interactive affordances are absent, not disabled). Hashing,
verification, and sealing *logic* stay in the consumer/backend.

**Evidence gates:** conformance that unverified/unknown/mismatched never render as verified
(fail-closed, same discipline as C6); sealed-mode test asserting **absence** of interactive
affordances (not merely disabled); host proof in Command-center + Warpblade; independent review.
**Risk:** low (presentation), with high semantic consequence.

---

### C8 — Graphs / lineage / relations

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `_CompareStrip` lineage SAME\|DIFFER | `take_tiles.dart:653-741` | Warpblade | [R] |
| Take regenerate → child take with lineage | `take_tiles.dart:324-436` | Warpblade | [R] |
| `ProjectVersionDagTree` (declared) | `ads-debt.md` §2.3.2 | Tempest | DECLARED |
| `ProviderQuotaUsageTracker` (declared) | `ads-debt.md` §2.2.18 | Tempest | DECLARED |
| W12 lineage verbs (PARTIAL) | Sentry request | Sentry | [R] |
| W1 then/now dual authority | Sentry request | Sentry | [R] |

**Prism now [L]:** `DSGraphCanvas` (`ds_graph_canvas.dart:29` node, `:82` edge, `:108` widget),
`GraphEdge.edgeType{uses,triggers,references}` (`organisms/graph/graph_model.dart:130-146`),
`DSWorkflowCanvasStage` (`DSWorkflowEdgeKind` `:53`), `DSEntityRelationCard`, `DSTrafficInspector`,
`DSTimingWaterfall`, `DSWorkflowCanvasStage`; runtime `GraphSource<N,E>` contract exists
(`MISSION.md:146`).

**Delta:** the *rendering* substrate is present and adequate; the missing thing is a **real
`GraphSource` consumer** (gap-matrix rows 18/25, both flagged "consumer proof") plus domain lineage
verbs (derived-from, supersedes, generated-by) and DAG layout for version trees. Warpblade's
lineage is a *textual* SAME|DIFFER strip, not a graph — do not over-read it as graph demand.

**Decision: EXTEND, KEEP-DISTINCT edge ontology per domain.** Edge vocabulary is domain; the
projection contract is generic. This is the cleanest place to prove `GraphSource` in a real host.

**Proposed Prism-native seam:** extend `DSGraphCanvas` input to accept a projected node/edge model
whose kind is caller-supplied (no fixed verb set in Prism core); lineage strip as a molecule
(`PrismLineageStrip`) for the SAME|DIFFER / derived-from case; `GraphSource` conformance proof via
a real consumer rather than a new contract.

**Evidence gates:** fake `GraphSource` + conformance (already exists per gap-matrix §1 testkit);
**host-composition proof with a real DAG** (Tempest's declared `ProjectVersionDagTree` is the
natural first host, but it is DECLARED — not built — so this is blocked until it exists or another
host supplies a DAG); boundary clearance (no domain verbs in core). **Risk:** medium.
**Blocking premise:** no observed consumer DAG surface today.

---

### C9 — Tables / boards / lists

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `SessionList` | `sessions.dart:15` | Command-center | [R] — SILVER in input 4 |
| `LibraryScreen` grid | `library_screen.dart:192-510` | Tempest | [R] — REUSE |
| `ModelsScreen` catalog | `models_screen.dart:24-436` | Tempest | [R] — REUSE |
| `TakeTilesPanel` (vertical list, **not** a grid) | `take_tiles.dart:275-313` | Warpblade | [R] |
| `EventStreamView` | `event_stream.dart:16` | Command-center | [R] — BRONZE in input 4 |

**Prism now [L]:** `DSDataTable` (`ds_data_table.dart:12` sort direction, `:45` sort state, `:94`
column, `:124` status cell, `:146` badge cell, `:163` timestamp cell, `:179` secret cell),
`DSVirtualList` (`:134`) / `DSVirtualGrid` (`:390`), `DSLaneBoard` (`:16`), `DSStatusGrid`
(`:48`), `DSLogViewer` (`ds_log_viewer.dart:29` + filter bar `:12` + severity `:11`), `DSTree`,
`DSBreadcrumbs`, `DSViewPresets`.

**Delta:** essentially none for tables/lists/boards. The genuine deltas are compositions:
grouped/sectioned list with per-row gated actions (Command-center sessions), and the
audition/compare matrix (Warpblade takes) which is a *matrix of cells with verdicts and actions*,
not a data table.

**Decision: REUSE (primary).** No new table, list, grid, or board primitive is justified. The
matrix case is a CANDIDATE composition over existing `DSVirtualGrid` + `DSLaneBoard`, and the
event-stream case is REUSE of `DSLogViewer`/`DSTimeline`/`DSExecutionConsole` (input 4's BRONZE
already says this).

**Proposed Prism-native seam:** none new for the table family. Composition guidance + barrel-level
REUSE convergence. Matrix composition deferred to backlog P2.

**Evidence gates (for the REUSE claims):** host-composition proof that the *existing* organisms
actually compose in Command-center and Tempest without wrapper-supplied ancestors — this is the
weakest-evidence area of the corpus, because every REUSE claim rests on a catalog read rather than
a host run. **Risk:** low (but evidence-poor).

---

### C10 — Shells / navigation / layout

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| `MainShellLayout` (NavigationRail, 7 branches) | `core/layout/main_shell.dart:9-203` | Tempest | [R] — DUPLICATE |
| `AppRouter` (go_router, 7 branches) | `core/router/app_router.dart:15-103` | Tempest | [R] |
| `CommandCenterShell` | `integration/shell.dart:22` | Command-center | [R] |
| `CommandCenterApp` | `main.dart:35` | Command-center | [R] |
| `WarpbladeApp`/`WarpbladeShellPage` | `main.dart:23-48`, `:50-55`, `:1164-1449` | Warpblade | [R] — **single scrolling column** |
| `AppTheme` / `AppColors` (47 tokens) | `app_theme.dart:5-290`, `app_colors.dart:4-46` | Tempest | [R] — DUPLICATE |

**Prism now [L]:** `DSShell` (`organisms/ds_shell.dart`), `DSSidebar`, `DSTopbar`,
`DSPageShell`, `DSSplitPane` (`organisms/split_pane/ds_split_pane.dart:31-92`), `DSTabBar`,
`DSBreadcrumbs`, `DSTree`, `MasterDetailTemplate` (`:27-266`), `TimelineTemplate` (`:397-542`),
`PrismTokenRegistry` + M3 factory + 3 opt-in skins.

**Delta:** (a) the shell **slot state machine** — which slot (rail/sidebar/main/panel) shows what,
and where focus returns after a layout change; (b) **fail-closed bootstrap** as a shell state
(Command-center `DaemonBootstrap`/`DaemonNotConnected`, Warpblade `WarpbladeStartupErrorPage`);
(c) Tempest's duplicated token layer is a *convergence* problem, not a Prism gap.

**Decision: REUSE primitives, EXTEND with the slot/router contract, UNIFY fail-closed bootstrap.**
Warpblade is **negative evidence** for a workbench layout (no panes, no resize, no reorder —
`main.dart:1303-1305`) and must not be counted as recurrence for layout; Command-center and
Tempest are the layout hosts.

**Proposed Prism-native seam:** IDS shell-slot state machine (**IDS**: slot identity, active
pane, focus-return token) + organism `PrismShellRouter` composition over existing `DSShell`/
`DSSplitPane`; molecule `PrismStartupFailureView` (**molecule**) for fail-closed bootstrap,
extending `DSFallbackView`/`DSErrorBoundary` rather than duplicating them.

**Evidence gates:** a11y focus-restoration conformance (the genuinely hard part; donor H1's
focus-tracking is the reference *idea*, not code); host proof in Command-center (real multi-pane
host) — Warpblade cannot supply it; determinism across layout transitions. **Risk:** medium-high.
**Blocking premise:** none, but the IDS extension needs its own review given IDS is
`PROVEN`-labelled.

---

### C11 — Capability-gated action / authority

**The highest-recurrence cluster in the corpus — four independent re-inventions.**

| Member | Source ref | Consumer | Evidence |
|---|---|---|---|
| Null-callback-as-capability (disabled, never hidden) | `project_panel.dart:124-177`; `take_tiles.dart:568-584`; `assurance_panel.dart:292-297` | Warpblade | [R] |
| `_GatedAction` / `_DisabledButton` / `AbortSection` | `control_panel.dart:49-138`, `:172` | Command-center | [R] |
| `PermissionSection` (capability-gated permissions) | `control_panel.dart:252` | Command-center | [R] |
| Honestly-disabled controls (`onPressed: null`) | `studio_transport_bar.dart:174`, `:186`; `mastering_fx_panel.dart:99-102`; `studio_fx_rack_dialog.dart:243`; `studio_timeline_lane.dart:269` | Tempest | [R] |
| W8 Allow/Constrain/Deny + `subject_hash`; W9 partial-fill remainder; W6 terminal-for-dispatch | Sentry requests | Sentry | [R] |

**Prism now [L]:** `DSOperationalState` (`tokens/ds_operational_state.dart:18`) with
`approved`/`rejected` binary gate outcomes (`:30-34`), `archived` terminal (`:41`);
`AsyncCommandStatus{idle,running,succeeded,failed,cancelled}` (per sentry report
`async_command_models.dart:7-22`) — no unknown, no attempt fold, no remainder. No
enabled-with-reason vocabulary anywhere.

**Delta:** every consumer needs three things Prism lacks: (i) an **availability** state distinct
from a boolean (available / unavailable-with-reason / terminal-for-dispatch / unknown);
(ii) a **rendering rule** (unavailable renders disabled *with its reason*, never silently hidden —
all three consumers independently converged on this); (iii) an **authority disposition** vocabulary
(allow / constrain / deny) that is *semantics*, not presentation.

**Decision: UNIFY.** This is the single highest-value seam in the corpus: four consumers, no data
plane, pure semantics, and the failure mode it prevents (a hidden action masquerading as "not
applicable", or a disabled action with no reason) is exactly the kind of trust defect
`AGENTS.md` §12/§4 exists to prevent.

**Proposed Prism-native seam:** IDS `ActionAvailability` / `CapabilityState` semantics (**IDS,
pure Dart**: available | unavailable(reason) | terminal-for-dispatch | unknown) + molecule
`PrismActionGate` (**molecule**) that renders the disabled-with-reason rule and the
terminal-for-dispatch rule; `DSOperationalState` extended only where the authority vocabulary
genuinely generalizes (allow/constrain/deny as an *authority outcome*, not as Sentry's decision
model).

**Evidence gates:** conformance for the three-way distinction (denied ≠ hidden ≠ enabled) and for
reason propagation; IDS purity; host proof in Command-center (`_GatedAction` is the richest real
implementation) and Warpblade; a11y (disabled semantics must carry the reason, not just the state).
**Risk:** medium (IDS extension + semantic breadth). **Blocking premise:** none.

---

## 4. Per-component disposition tables

Every inventoried UI unit is accounted. `Prism now` cites live-verified Prism surfaces where the
disposition depends on them.

### 4.1 Warpblade — 19 inventory rows (18 accounted UI/helper units + 1 non-UI bridge row)

| # | Component | Disposition | Prism owner / seam | Rationale |
|---|---|---|---|---|
| 1 | `WarpbladeApp`/`WarpbladeShellPage` | **REUSE** (composition) | `DSShell`, `DSPageShell`, `DSSidebar` | Composition root is product; the shell primitives it hand-rolled exist. Not a new primitive. |
| 2 | `TransportBar` | **CANDIDATE** → C1 | new `PrismTransportBar` organism | 2 consumers; injected formatter already the right shape. |
| 3 | `TexturedPreviewHost` | **CANDIDATE** → C2/C3 boundary | new `PrismSurfaceHost` (data-plane host) | `WP-GAP-001` self-declared. Data plane: must declare transfer/ownership (MISSION §7) — highest gate burden. |
| 4 | `ProposalPanel` | **EXTEND** → C4 | `DSDetailInspector` + decision-review surface | Parts exist; review framing missing. |
| 5 | `TimelineStrip` | **CANDIDATE** → C3 | `PrismMultitrackTimeline` | 2 consumers; chrome only, ontology local. |
| 6 | `TakeTilesPanel`/`TakeTile` | **CANDIDATE (P2)** → C9 | `DSVirtualGrid` + `DSLaneBoard` composition | Audition matrix; single consumer. |
| 7 | `MediaPanel` | **KEEP_LOCAL-domain-only** (probe metadata) + **REUSE** (labelled-field chrome) | `DSPropertyRow`, `DSTextField` | AV probe metadata is domain; the monospace labelled-field pattern is already Prism. |
| 8 | `ProjectPanel` | **CANDIDATE** → C11 (+C4) | `PrismActionGate` + `DSDetailInspector` | Action panel with dirty/digest state and capability-nulled actions. |
| 9 | `AssurancePanel`/`RepairDialog` | **EXTEND** → C4 + C7 | `DSDetailInspector` + `DSEvidenceRow` + witness badge | Trust-boundary panel; bounded repair is a decision-review surface. |
| 10 | `DiagnosticsPanel` | **REUSE** | `DSButton`, `DSStatusDot`, `DSGlassPanel` | QA control strip; a composition of atoms, not a design-system component. |
| 11 | `GenerationDrawer` | **CANDIDATE (P2)** → C12-form | descriptor-driven disclosure (extend `DSAccordion`+`DSSelect`) | Single consumer; descriptor-driven form is real but thin evidence. |
| 12 | `ErrorBanner`/`ExportProgressBanner`/`ExportReportBanner` | **EXTEND** → C6 | `DSStateSurface` + new job banner | Duplicated inline error blocks are a real reuse seam (source-observed). |
| 13 | `WarpbladeKeyboardRouter` | **CANDIDATE** → C5 | IDS command registry + dispatch router | Guard-aware dispatch is generic; binding set is local. |
| 14 | `WarpbladeStartupErrorPage` | **EXTEND** → C6/C10 | `DSFallbackView`/`DSErrorBoundary` + startup-failure view | Fail-closed bootstrap; now 2 consumers (with CC `DaemonNotConnected`). |
| 15 | `WarpbladeBridge` facade | **non-UI** — runtime/bridge discipline | `warp_prism_bindings` / adapter | Not a component. Import-boundary discipline is already Prism law. |
| 16 | `MediaTimeDtoUtils`/`TimeRangeDtoUtils` | **KEEP_LOCAL-domain-only** (rational math) + **CANDIDATE** (formatting) → C1 | timecode formatter seam | Exact BigInt/GCD arithmetic is AV domain; `formatTime`/`formatRange` is generic. |
| 17 | `TimelineIntentResolver` | **CANDIDATE** → C3/C5 | IDS `TimelineIntent` verbs | Consumer's own proof of "semantics outside the widget". |
| 18 | `mapMediaError`/`isTerminalMediaError` | **CANDIDATE** → C6/C11 | terminality + disclosure semantics | `isTerminalMediaError`'s non-obvious transient rules are a real operational invariant; refusal-prefix contract must be preserved verbatim if absorbed. |
| 19 | `WarpbladeSpikeApp`/`NativeSurfaceController` | **KEEP_LOCAL-domain-only** | — | Spike proof surface; explicitly not a harvest source. |

### 4.2 Tempest — 39 observed rows

| # | Component | Disposition | Prism owner / seam | Rationale |
|---|---|---|---|---|
| 1 | `MainShellLayout` | **REUSE** | `DSShell`/`DSSidebar` | DUPLICATE_IMPLEMENTATION; converge, don't extend. |
| 2 | `AppRouter` | **KEEP_LOCAL-domain-only** | — | go_router routing is consumer infrastructure, not a UI component. |
| 3 | `AppTheme` | **REUSE** | `PrismTokenRegistry` + `PrismTheme` | Duplicate token layer; convergence target. |
| 4 | `AppColors` (47 tokens) | **REUSE** | `PrismColors` | Duplicate; stem colours stay domain (see #14). |
| 5 | `ThemeModeNotifier` | **REUSE** | pattern already Prism-equivalent | Trivial state holder. |
| 6 | `LocaleNotifier` | **REUSE** | — | Consumer-local; Prism has no l10n contract (fine). |
| 7 | `StudioTransportBar` | **CANDIDATE** → C1 | `PrismTransportBar` | 2 consumers. |
| 8 | `MusicalRuler` | **KEEP_LOCAL-domain-only** (bars/beats math) + chrome → C3 | `PrismTimeRuler` | Ontology local, chrome generic. |
| 9 | `_RulerPainter` | **KEEP_LOCAL-domain-only** | — | Musical grid painting. |
| 10 | `StudioTimelineLane` | **CANDIDATE** → C3 | `PrismTrackLane` | Lane geometry generic; grid/waveform painters local. |
| 11 | `_LaneGridPainter` | **KEEP_LOCAL-domain-only** | — | BPM/time-signature grid. |
| 12 | `_RegionWaveformPainter` | **CANDIDATE (P2)** → C3 | waveform bar seam | Generic bar geometry; dB calibration local. |
| 13 | `StudioTrackControls` | **CANDIDATE** → C2 | `PrismFaderStrip` | Channel strip; unify with `StemMixer`. |
| 14 | `MasteringFxPanel` | **CANDIDATE** (panel seam) → C2 | side-panel-with-meters | Panel chrome generic; LUFS/True-Peak calibration local. |
| 15 | `_buildPeakMeter` | **CANDIDATE** → C2 | `PrismMeter` | Geometry generic, dBFS scale injected. |
| 16 | `_buildLufsMeter` | **CANDIDATE** (geometry only) → C2 | `PrismMeter` | Broadcast calibration stays local. |
| 17 | `StudioFxRackDialog` | **KEEP_LOCAL-domain-only** | — | DSP insert chain. |
| 18 | `CommandBarDialog` | **CANDIDATE** → C4/C5 | decision-review surface + command registry | NL→plan→confirm is the review cluster. |
| 19 | `StudioState` | **KEEP_LOCAL-domain-only** | — | DAW domain model. |
| 20 | `StudioController` | **KEEP_LOCAL-domain-only** | — | DAW orchestration. |
| 21 | `SeparateScreen` | **REUSE** | `DSStateSurface`, `DSButton` | Standard form layout. |
| 22 | `DropZoneCard` | **EXTEND** → C4 | `DSDropTarget` + `DSAssetCard` | Metadata display on existing drop target. |
| 23 | `PresetSelector` | **REUSE** | `DSFilterChipGroup` | Direct match. |
| 24 | `QualityModeSelector` | **REUSE** | `DSSelect` + `DSAccordion` | Direct match. |
| 25 | `ProgressCard` | **EXTEND** → C6 | `DSStateSurface` + job banner | Multi-stage + cancel; unify with Warpblade banners. |
| 26 | `StemMixer` | **CANDIDATE** → C2 | `PrismFaderStrip` | Unify with `StudioTrackControls`. |
| 27 | `SeparateController` | **KEEP_LOCAL-domain-only** | — | Job orchestration. |
| 28 | `CreateScreen` | **REUSE** | `DSTextField`, `DSButton`, `DSAssetCard` | Direct match. |
| 29 | `SongBlueprintWidget` | **CANDIDATE (P2)** → C8-adjacent | energy-curve editor | `DSGraphCanvas` is topology-only; single consumer. |
| 30 | `LyricsWorkspaceWidget` | **KEEP_LOCAL-domain-only** | — | Syllable/rhyme/meter domain. |
| 31 | `PromptEnhancerDialog` | **CANDIDATE** → C4 | diff region in decision-review surface | Side-by-side diff; unify with proposal diff. |
| 32 | `CreateController` | **KEEP_LOCAL-domain-only** | — | Generation orchestration. |
| 33 | `LibraryScreen` | **REUSE** | `DSSearchBar`, `DSFilterChipGroup`, `DSAssetCard` | Direct match. |
| 34 | `ModelsScreen` | **REUSE** | `DSAssetCard`, `DSStatusDot`, `DSMetricTile` | Direct match. |
| 35 | `_VerificationBadge` | **REUSE** | `DSStatusDot`/`DSBadge` | Direct match. |
| 36 | `ProvidersScreen` | **REUSE** (health) + **KEEP_LOCAL-domain-only** (credentials) | `DSProviderHealthMatrix` | Credential storage is product-local by law. |
| 37 | `_StatusBadge` | **REUSE** | `DSStatusDot` | Direct match. |
| 38 | `SettingsScreen` | **REUSE** | `DSStateSurface`, `DSSelect` | Direct match. |
| 39 | `SettingsController` | **KEEP_LOCAL-domain-only** | — | Hardware/device enumeration. |

### 4.3 Tempest — 12 DECLARED (not implemented) rows

| # | Planned component | Disposition | Seam / note |
|---|---|---|---|
| 1 | `AudioSpectrogramCanvas` | **KEEP_LOCAL-domain-only** | Data plane (FFT). Presentation seam only: generic canvas host. |
| 2 | `StereoGoniometerCanvas` | **KEEP_LOCAL-domain-only** | Lissajous domain painter. |
| 3 | `AutomationLane` | **KEEP_LOCAL-domain-only** | Automation envelope is DAW domain. |
| 4 | `CompressorTransferGraph` | **KEEP_LOCAL-domain-only** | DSP curve. |
| 5 | `DawToolPalette` | **CANDIDATE (P2)** → C5 | Tool-mode palette over command registry; single consumer. |
| 6 | `TakeCompingStrip` | **KEEP_LOCAL-domain-only** | Take system domain. |
| 7 | `VirtualMidiController` | **KEEP_LOCAL-domain-only** | Musical keyboard domain. |
| 8 | `PluginHostContainer` | **KEEP_LOCAL-domain-only** | CLAP/LV2/VST3 hosting. |
| 9 | `FloatingContextCommandBar` | **EXTEND** → C5 | `DSToolStripSlideout` + command registry. |
| 10 | `ProviderQuotaUsageTracker` | **EXTEND** (runtime) | `HealthSource` cost axis; runtime contract, not ADS. |
| 11 | `ProjectVersionDagTree` | **EXTEND** → C8 | `DSGraphCanvas` + `GraphSource` proof — **blocked**: declared, not built. |
| 12 | `MasteringRecommendationTable` | **KEEP_LOCAL-domain-only** | DSP-vs-AI comparison is domain. |

### 4.4 Command-center — 15 app widgets

| # | Widget | Disposition | Prism owner / seam | Rationale |
|---|---|---|---|---|
| 1 | `AbortSection` | **CANDIDATE** → C11 | `PrismActionGate` | Capability-gated abort; richest real gated-action implementation. |
| 2 | `CommandCenterApp` | **REUSE** (composition) | `PrismTheme` + `PrismNerazimTealSkin` | App root; already consumes Prism. |
| 3 | `CommandCenterShell` | **REUSE** + **EXTEND** → C10 | `DSShell`/`DSSplitPane` + slot router | Multi-pane host; composition product-specific. |
| 4 | `ConnectionPanel` | **REUSE** (health) + **EXTEND** → C11 | `DSStateSurface`, `DSStatusDot` | Health/attach surface with gated actions. |
| 5 | `ControlPanel` | **EXTEND** → C4/C11 | decision-review + `PrismActionGate` | Control surface; gated invocation. |
| 6 | `DaemonBootstrap` | **EXTEND** → C6/C10 | startup-failure view | Bootstrap state. |
| 7 | `DaemonNotConnected` | **EXTEND** → C6/C10 | `DSFallbackView` + startup-failure view | Fail state; second consumer of Warpblade #14. |
| 8 | `EventStreamView` | **REUSE** | `DSLogViewer`/`DSTimeline`/`DSExecutionConsole` | Input 4's BRONZE; bespoke stream view is convergent duplication. |
| 9 | `LoadingPane` | **EXTEND** → C6 | `DSStateSurface` loading mode | GOLD candidate; non-animated rationale is reusable. |
| 10 | `LoadingRow` | **EXTEND** → C6 | `DSSkeletonTextLine`/`DSStateSurface` | Same. |
| 11 | `PermissionSection` | **CANDIDATE** → C11 | `PrismActionGate` + authority disposition | Capability-gated permissions; the authority face of C11. |
| 12 | `ProvenanceView` | **CANDIDATE** → C7 | provenance family | Causation grouping; third provenance consumer. |
| 13 | `SessionDetail` | **REUSE** (composition) | `DSDetailInspector` | Detail surface; composition only. |
| 14 | `SessionList` | **REUSE** (composition) | `DSDataTable`/`DSVirtualList` | SILVER; grouped list w/ gated rows is C11-dependent. |
| 15 | `StateRegion` | **EXTEND** → C6 | `DSStateSurface` | Generic state chrome (GOLD). |

**Command-center consumed identifiers (10):** all **REUSE / RESOLVES** — verified live in input 4
(`PrismButton`, `PrismChip`, `PrismColors`, `PrismTheme`, `PrismNerazimTealSkin`, `PrismRadii`,
`PrismSpacing`, `PrismStateSurface`+`PrismStateType`, `PrismStatusDot`, `PrismOperationalState`).
No new primitive is required by any consumed identifier.

### 4.5 Sentry — 14 W-items (DECLARED requests; Sentry has no Flutter UI surface)

| W | Request | Disposition | Prism owner / seam |
|---|---|---|---|
| W1 | Dual-authority then/now panes, sealed-vs-now | **EXTEND** → C4/C10 | `MasterDetailTemplate` + `DSSplitPane` + sealed mode (C7) |
| W2 | Sealed artifact state (`OPEN→SEALED`) | **CANDIDATE (P1)** → C7 | sealed rendering-mode contract |
| W3 | Advisory/confidence/view-cutoff framing | **CANDIDATE (P2)** → C4 | advisory section in review surface |
| W4 | Five-clock family + per-artifact clock | **EXTEND** → C3 | `DSTimeMachineScrubber` + injected clock model |
| W5 | Epistemic lens/badge vocabulary | **CANDIDATE (P2)** | lens badge — needs evidence: no 2nd consumer, domain-heavy |
| W6 | Unknown/not-knowable + dispatch terminality (**highest priority**) | **EXTEND** → C6/C11 | `DSStateType` + `ActionAvailability` |
| W7 | Reasoned abstention (zero attempts) | **EXTEND** → C6 | state vocabulary |
| W8 | Allow/Constrain/Deny + `subject_hash` | **CANDIDATE** → C11 | authority disposition vocabulary |
| W9 | Partial-fill remainder / terminal-for-dispatch | **CANDIDATE** → C11 | availability vocabulary |
| W10 | Episode closure + outcome refs | **KEEP_LOCAL-domain-only** (model) + **CANDIDATE (P2)** (view) | Sentry core owns the model |
| W11 | `Hypothesis`/`PROPOSED` artifact | **KEEP_LOCAL-domain-only** (model) + **CANDIDATE (P2)** (card) | Sentry core owns the model |
| W12 | Lineage verbs | **EXTEND** → C8 | graph projection |
| W13 | Hash/tamper-evidence witness | **CANDIDATE** → C7 | `PrismWitnessBadge` |
| W14 | Phase rail / SEAL legal-act marker | **CANDIDATE (P2)** → C7 | phase rail molecule |

**Sentry law note:** W10/W11 are *decision-reconstruction domain models*. `MISSION.md` §4.5 and
the domain-leakage rule keep them in Sentry's Rust core. Prism may render them; Prism must not own
them. Only the generic interaction semantics (unknown, abstention, sealed, availability) are
absorbed.

---

## 5. Disposition totals

Counting rule: **one row = one primary disposition.** Where a component has both a domain-local
part and a generic part (e.g. `MusicalRuler` = musical math + ruler chrome), the primary
disposition is the one governing the *absorbable UI part*, and the domain part is named in the
rationale column. Domain parts are not double-counted as separate units.

| Disposition | Warpblade | Tempest (obs.) | Tempest (decl.) | Command-center | Sentry | **Total** |
|---|---|---|---|---|---|---|
| **REUSE** | 3 | 15 | 0 | 6 | 0 | **24** |
| **EXTEND** | 4 | 2 | 3 | 6 | 5 | **20** |
| **CANDIDATE** | 10 | 12 | 1 | 3 | 9 | **35** |
| **KEEP_LOCAL-domain-only** | 1 | 10 | 8 | 0 | 0 | **19** |
| **Row total** | **18** | **39** | **12** | **15** | **14** | **98** |
| Non-UI row (not a UI unit) | 1 (`WarpbladeBridge` facade) | — | — | — | — | **1** |
| Consumption rows (not units) | — | — | — | 10 consumed `Prism*` identifiers, all REUSE | — | **10** |

Inventory rows read: 19 + 51 + 15 + 14 = **99**; minus 1 non-UI bridge row = **98 UI units
accounted**, plus 10 consumption rows verified as REUSE.

**Observation, not a finding:** CANDIDATE (35) is the largest bucket. That is the expected shape
under §3.1's absorption default — the corpus was collected *because* Prism lacks these surfaces —
but it also means the backlog in §6, not this table, is the actionable artifact. Nothing here is
authorized by being counted.

---

## 6. Prioritized candidate backlog

Priority basis, in order: **consumer count** (§3.1: recurrence = priority), **evidence
readiness** (is the consumer source actually observed?), **correctness stakes** (what trust defect
does the absence cause?), **risk** (data plane / ontology coupling), **blocking premises**.
A single-consumer candidate is still listed if mandate-covered and unblocked.

### P0 — unblocked, multi-consumer, low-to-medium risk

| ID | Candidate | Consumers | Layer | Why P0 | Gates |
|---|---|---|---|---|---|
| **P0-1** | `ActionAvailability` / `CapabilityState` semantics + `PrismActionGate` (C11) | Warpblade, Command-center, Tempest (+Sentry W8/W9 partial) | IDS + molecule | 4 independent re-inventions; pure semantics; no data plane; prevents "hidden as not-applicable" | IDS purity; denied≠hidden≠enabled conformance; reason propagation; a11y disabled-with-reason; host proof CC + Warpblade |
| **P0-2** | Honest-unknown + reasoned-abstention in `DSStateType` + `DSStateSurface` (C6) | Command-center, Warpblade, Sentry (their #1) | molecule + token enum | Confirmed live gap; highest epistemic risk (unknown rendering as empty/success) | fail-closed conformance (unknown ≠ empty ≠ success ≠ disabled); a11y state; host proof CC + Warpblade |
| **P0-3** | `PrismTransportBar` + injected timecode formatter (C1) | Warpblade, Tempest | organism | 2 consumers, same chrome, injected formatter already proven in consumer source; gap-matrix rows 4/10 | fake transport model conformance; determinism; host proof both |
| **P0-4** | Provenance family: `PrismProvenanceBadge` + `PrismWitnessBadge` + sealed rendering mode (C7) | Warpblade, Command-center, Sentry W13 | atoms + presentation rule | 3 consumers; trust-critical; Prism today is canonicity-only | unverified-never-renders-verified conformance; sealed = absent-affordance test; host proof CC + Warpblade |

### P1 — unblocked but heavier (ontology coupling, IDS extension, or host-proof dependency)

| ID | Candidate | Consumers | Layer | Why P1 not P0 | Gates |
|---|---|---|---|---|---|
| **P1-1** | Command registry + shortcut index (C5) | Warpblade, Command-center, Tempest | IDS + `DSCommandPalette` extension | IDS is `PROVEN`-labelled; extending it needs its own review | IDS purity; chord collision/precedence; enumeration stability; keyboard-only a11y |
| **P1-2** | Multitrack timeline chrome: `PrismTimeRuler` + `PrismTrackLane` + playhead (C3) | Warpblade, Tempest | organism | Highest coupling in corpus; injected-model seam must be validated first | two-ontology conformance (seconds **and** bars/beats must pass); exact pixel↔time determinism; host proof both |
| **P1-3** | Decision-review surface: `PrismDecisionReviewSurface` (C4) | Warpblade, Tempest, Command-center | organism | Composition breadth; depends on verdict pass-through discipline | pass-through integrity conformance (unknown verdict ≠ pass); host proof ≥2 |
| **P1-4** | Loading-chrome consolidation into `DSStateSurface` (C6) | Command-center (GOLD), Warpblade | molecule | Convergence, not construction — lower novelty, high value | host proof in the GOLD candidate's own host; determinism (exclude indeterminate animation) |
| **P1-5** | Job banner with staged progress + terminal receipt (C6) | Warpblade, Tempest | molecule | Needs receipt semantics declared (what a receipt *is* stays consumer) | receipt determinism; cancel semantics; host proof both |
| **P1-6** | Meter geometry + fader strip: `PrismMeter` + `PrismFaderStrip` (C2) | Tempest (mandate-covered) | atom + molecule | Data-plane adjacency; calibration must be provably injected | fake scale + fixed-value goldens; a11y numeric semantics; no audio types in ADS |
| **P1-7** | Shell slot state machine + `PrismStartupFailureView` (C10) | Command-center, Tempest, Warpblade | IDS + organism/molecule | Focus-restoration correctness is the hard part; IDS extension | focus-restoration conformance; multi-pane host proof (CC only); determinism across transitions |
| **P1-8** | Timeline interaction verbs (IDS `TimelineIntent`) (C3/C5) | Warpblade (+Tempest) | IDS | Depends on P1-2's injected time model | pure-Dart purity; quantize/seek edge conformance; fake time model |

### P2 — single-consumer, evidence-thin, or blocked

| ID | Candidate | Consumers | Blocker / reason |
|---|---|---|---|
| **P2-1** | Audition/compare matrix (Warpblade takes) | Warpblade only | Single consumer; compose over `DSVirtualGrid`+`DSLaneBoard`; needs verdict pass-through (P1-3) |
| **P2-2** | Graph/lineage extension + real `GraphSource` proof (C8) | Tempest (declared), Sentry W12 | **Blocked**: no observed consumer DAG surface; Tempest's DAG is declared, not built |
| **P2-3** | Sealed decision case + dual-authority panes (Sentry W1/W2/CAND-2/CAND-4) | Sentry (request only) | Single consumer with **no UI source**; highest semantic risk; depends on P0-4 |
| **P2-4** | Authority disposition explainer (Sentry W8/CAND-5) | Sentry | Depends on P0-1 vocabulary landing first |
| **P2-5** | Partial-fill remainder / terminal-for-dispatch (Sentry W9/CAND-6) | Sentry | Runtime contract implication (`AsyncCommand`) — needs runtime review, not just ADS |
| **P2-6** | Descriptor-driven disclosure form (Warpblade `GenerationDrawer`) | Warpblade only | Single consumer; extend `DSAccordion`+`DSSelect` when a 2nd descriptor host appears |
| **P2-7** | Energy-curve editor (Tempest `SongBlueprintWidget`) | Tempest only | Single consumer; `DSGraphCanvas` is topology-only |
| **P2-8** | Waveform bar geometry (Tempest `_RegionWaveformPainter`) | Tempest only | Data plane; needs transfer/ownership declaration (MISSION §7) |
| **P2-9** | Episode closure view (W10) / hypothesis card (W11) | Sentry | Model stays in Sentry; view waits for a real host |
| **P2-10** | Phase rail / SEAL legal-act marker (W14) | Sentry | Depends on sealed mode (P0-4) |
| **P2-11** | Epistemic lens badge (W5) | Sentry | Domain-heavy vocabulary; no 2nd consumer; risk of leaking decision-reconstruction ontology into ADS |
| **P2-12** | Textured surface host (`WP-GAP-001`) | Warpblade only | Data plane; must declare transfer + ownership before any ADS work |

### Held — **not** candidates (donor-only, no consumer demand)

Recorded so they are not silently lost, and explicitly **excluded** from the backlog because
`MISSION.md` §3.1/§10 bounds coverage by real Ganthritor product components:

| Donor mechanism | Source | Status |
|---|---|---|
| Unified command catalog (palette/menubar/ribbon from one source) | Everything H4 `spreadsheet/src/ui/command-catalog.js:1-97` | **Inspiration for P1-1 only.** FigCraft A2 (`control.rs:221-226`) is the same idea. No consumer demand observed. |
| Rich filter builder (nested AND/OR, debounce-commit, flush-on-close) | Everything H5 `records/src/ui/toolbar.js:181-363` | Held. Prism already has `DSFilterWorkbench`; no consumer asked. |
| Toolbar panel framework (button→popover→flush→reanchor) | Everything H7 `toolbar.js:1-549` | Held. |
| Sidebar section model (custom sections, drag-reorder, unread pills) | Everything H2 `teamchat/src/ui/sidebar.js:1-928` | Held. |
| Presence overlay (cursor glide, idle fold, per-user colour) | Everything H6 `presence.js:1-229` | Held. No consumer demand; collaboration is not in any consumer inventory. |
| Composer organism (mentions, attachments, drafts) | Everything H8 `composer.js:1-1108` | Held. |
| Toast policy layer (cap, sticky, opener hand-back) | Everything M2 `toast.js:1-170` | Held. `DSToastManager` exists; policy extension unproven. |
| Number field as a primitive (typed/relative edits, scrub, commit boundary) | FigCraft B3 `field_math.rs`, `widgets.rs:20-133` | Held. No consumer inventory contains a numeric field. |
| Reorder with insertion affordance | FigCraft B6 `list_drag.rs:1-7` | Held. |
| Region-based keyboard model / draw-derived focus | FigCraft A7/A8 `a11y.rs:29-58`, `:86-99` | Held — relevant *idea* for P1-7 focus restoration; no consumer demand. |

---

## 7. Cross-cluster invariants (the reusable findings)

These are the properties that recur across clusters and should be treated as **design constraints**
for any candidate that proceeds:

1. **Inject the model, own the chrome.** Time, scale, verdict, capability, and hash all enter
   Prism as caller-supplied models. Prism never owns the ontology. (C1, C2, C3, C7, C11)
2. **Fail closed on absence.** Unknown never renders as empty, success, verified, or enabled.
   Warpblade states the rule for verdicts (`take_tiles.dart:5-11`: unknown falls to neutral,
   "cannot be painted as a pass"); Sentry states it for knowledge; the same rule applies to
   provenance and availability.
3. **Disabled with a reason, never silently hidden.** Three consumers converged on this
   independently (`project_panel.dart:124-177`, `take_tiles.dart:568-584`,
   `assurance_panel.dart:292-297`, `control_panel.dart:49-138`). A hidden action that is
   indistinguishable from "not applicable" is the defect this rule prevents.
4. **Semantics outside the widget.** Warpblade proved it (`timeline_intents.dart:5-8`); Tempest
   proves the cost of not doing it (`StudioController` at 1289 lines); Prism's own purge law
   already requires it for runtime contracts (`MISSION.md:148-151`).
5. **Determinism before goldens.** Meters, progress, and timelines are the animation-dependent
   capture traps. Every cluster above carries a determinism gate for that reason.
6. **Data plane is a separate decision.** Texture, waveform, spectral, and peak-pyramid payloads
   require declared transfer + ownership (`MISSION.md:245-250`) and are not event streams.

---

## 8. Unknowns and blockers

| ID | Unknown / blocker | Effect on this map |
|---|---|---|
| **UNKNOWN-1** | Input 2's summary counts (43/50) disagree with its own tables (39 observed + 12 declared). | This map accounts the tables, not the summary. If the true observed count is 43, four components are unaccounted and must be recovered from Tempest source. |
| **UNKNOWN-2** | Consumer revision states are all UNKNOWN (VCS denied in every input pass). | Consumer citations are report-grade and may be stale relative to live consumer source. |
| **UNKNOWN-3** | **Sentry has no Flutter UI surface at all** (input 3 §6: no `pubspec.yaml`, Rust-only, 3 crates). Its 14 W-items are *requests*, not observed components. | Every Sentry row is DECLARED evidence. Sentry-derived candidates carry weaker evidence than Warpblade/Tempest/CC candidates. |
| **UNKNOWN-4** | No host-composition proof exists anywhere in the corpus. No consumer host has ever run a Prism primitive as a *proof* (Command-center consumes Prism but its composition has never been exercised as evidence). | Every REUSE disposition in §4 is catalog-grade, not host-grade. §6 gate 5 remains the largest single blocker for the whole program. |
| **UNKNOWN-5** | No execution of any kind: no build, test, golden, analyze, or runtime observation on either side. | Nothing here is a PASS. Every "covers" claim is a static-read claim. |
| **UNKNOWN-6** | Tempest's 12 planned components are DECLARED in `ads-debt.md`, not built. | P2-2 (graph/DAG) is blocked on a surface that does not exist yet. |
| **UNKNOWN-7** | Warpblade's `AssurancePanel` is unreachable in the real app (`main.dart:1363-1375` passes neither `onAssess` nor `onRepairRequest`; buttons hide on null callbacks, `take_tiles.dart:568-584`). | The assurance surface is a *declared* capability that the product does not currently exercise — its host proof will be impossible until the product owner fixes it. |
| **UNKNOWN-8** | Command-center bridge symlink target is unreadable from this workspace (`external_directory` denial); verification used the workspace-local clone instead. | Spot-check resolved EXISTS, not blocked, but bridge-doc provenance is clone-grade. |
| **UNKNOWN-9** | `docs/bridge/README.md:32` still lists `sentry/` as empty while `docs/bridge/sentry/` is populated — a stale projection. Also `layer-contracts.md` §9, `docs/bridge/README.md` harvest loop, and `docs/design/token-theme-catalog-policy.md` still state recurrence as a gate (`MISSION.md:369-373` names this reconciliation debt). | Any downstream task citing those documents as current law may re-introduce the superseded recurrence gate. **Reconciliation is owed by task governance, not by this map.** |
| **UNKNOWN-10** | Donor harvests are partial (`FigCraft` B5/B7–B10 `UNVERIFIED` and excluded; Everything 41 apps uninspected). | Donor-derived inspiration is a sample. Irrelevant to the backlog, which is consumer-bounded. |
| **UNKNOWN-11** | No consumer has requested any of the held donor mechanisms. | Held items cannot become candidates without consumer evidence under §3.1/§10. |
| **UNKNOWN-12** | Whether IDS can absorb `ActionAvailability`, `TimelineIntent`, and the command registry without ceasing to be "not a state-management framework" (`MISSION.md:140`) is unresolved. | P0-1, P1-1, P1-8, P1-7 all depend on this architectural question being answered by the architecture owner before implementation. |

---

## 9. What this map explicitly does not do

- It does **not** create tasks, authorize implementation, or promote anything. Every candidate is
  pre-implementation per `MISSION.md` §6.
- It does **not** design APIs. Seams name purpose, layer, and injection points only.
- It does **not** re-litigate closed architecture. Gap-matrix §5's "do not unify time ontologies"
  is honored — this map unifies chrome, not ontology.
- It does **not** treat donors as consumers, and does **not** treat a donor idea as demand.
- It does **not** claim any consumer adoption, host run, or test result.

---

## 10. Compact packet

- **Scope:** 6 input research artifacts + live Prism spot-check → 11 purpose clusters over
  **98 inventoried UI units + 10 consumption rows** (Warpblade 19 rows/18 units, Tempest 39+12,
  Command-center 15, Sentry 14).
- **Governing law:** `MISSION.md` §3.1 + §11.4. Absorption default, recurrence = priority,
  evidence gates stand, domain engines local. MISSION wins over the pre-amendment gap matrix and
  over stale bridge prose.
- **Core synthesis:** the clusters reduce to **five shared seams** (injected time model, injected
  capability/authority, injected formatter, honest-unknown, provenance-as-evidence) plus a small
  number of chrome primitives — not nine widgets.
- **Highest-recurrence cluster:** **C11 capability-gated action** (Warpblade + Command-center +
  Tempest + Sentry W8/W9) — four independent re-inventions, pure semantics, no data plane.
- **Largest confirmed live gap:** **honest-unknown** — `DSStateType`
  (`molecules/ds_state_surface.dart:294-315`) has `empty/loading/error/disabled/stale/degraded/
  excluded` and no unknown; Sentry's #1 priority and a latent trust defect for every consumer.
- **Largest confirmed live absence:** no transport organism (only private `_TransportButton`,
  `ds_time_machine_scrubber.dart:797`); no meter/fader/waveform anywhere (negative sweep clean);
  no command-intent module in `warp_prism_interaction` (dirs: `input, inspection, query,
  selection, state_machine`).
- **Dispositions:** REUSE 24 · EXTEND 20 · CANDIDATE 35 · KEEP_LOCAL-domain-only 19
  (98 UI units; CANDIDATE is the largest bucket, which is the expected shape under the
  absorption default).
- **Backlog:** P0 = capability/authority gate, honest-unknown state, transport bar + formatter,
  provenance/witness family. P1 = command registry, timeline chrome, decision-review surface,
  loading consolidation, job banner, meter/fader, shell slot router, timeline verbs. P2 = matrix,
  graph/lineage (blocked), sealed decision case, authority explainer, partial-fill, descriptor
  form, energy curve, waveform, episode/hypothesis views, phase rail, epistemic lens, texture host.
  Held (not candidates): 10 donor-only mechanisms, including the Everything command catalog and
  filter builder and the FigCraft number field.
- **Top blockers:** no host-composition proof anywhere (UNKNOWN-4); Sentry has no UI source
  (UNKNOWN-3); Tempest's DAG is declared-not-built (UNKNOWN-6); IDS scope question unresolved
  (UNKNOWN-12); recurrence still stated as law in three unreconciled documents (UNKNOWN-9).
- **Evidence honesty:** Prism side OBSERVED-LIVE this session; consumer side INHERITED-REPORT, not
  re-read; zero execution on either side; nothing here is a PASS.
