# Final Upgrade Backlog — Warp Prism (2026-11-01)

- **Artifact:** `.project/research/final-upgrade-backlog-2026-11-01.md`
- **Date:** 2026-11-01
- **Lane:** Root final synthesizer — read-only, no implementation, no tasks created here
- **Governing law:** `MISSION.md` §3.1 (full-coverage central ADS/IDS, absorption default, recurrence = priority not gate) + §11.4 (amendment supersedes recurrence gates, keep-local default, blanket anti-design-system) + §§4–7 (layer contracts, purge law, domain leakage, data/control plane) + §6 items 2–7 (evidence gates stand). **MISSION WINS** over all pre-amendment prose.
- **Posture:** Ambitious, NOT conservative. Every mandate-covered UI component is absorbed or unified. Single-consumer is absorbed, never rejected. Domain engines/math/painters stay local per §4.5.
- **Inputs deduped (all workspace-local):**
  1. `architect-upgrade-warpblade-2026-11-01.md` (WB U1–U11)
  2. `architect-upgrade-tempest-2026-11-01.md` (TP U-01–U-10)
  3. `architect-upgrade-commandcenter-2026-11-01.md` (CC I-1–I-7 / W1-A–W5)
  4. `architect-upgrade-everything-2026-11-01.md` (EV P0/P1/P2 waves, H1–H8/M1–M8/L1–L4)
  5. `architect-upgrade-figcraft-2026-11-01.md` (FG U1–U8, rev4 A1–A9/B1–B6)
  6. `macro-review-unification-map-2026-10-20.md` (C1–C11, P0/P1/P2, Held table — Prism side OBSERVED-LIVE, consumer side INHERITED-REPORT)
  7. `MISSION.md` §§3.1, 11.4 + `docs/design/component-catalog.md` (checked 2026-10-15)

**No execution in this pass.** No build/test/golden/host run. Nothing here is a PASS. Prism citations are live-grade (re-verified in inputs); consumer citations are report-grade (INHERITED-REPORT, revision UNKNOWN).

---

## 1. Merged seams (dedupe record)

Every idea below appears **once**. The table records what was merged and what won.

| Seam | Merged inputs | Unified verdict |
|---|---|---|
| **S1 capability gate + authority** | WB-U1 + TP U-06/U-07 part (`onPressed:null`) + CC W1-A/I-1 (`_GatedAction`, `PermissionSection`, `AbortSection`) + EV trust-core item 6 + Macro P0-1/C11 + Sentry W8/W9 | IDS `ActionAvailability`/`CapabilityState` (pure Dart) + molecule `PrismActionGate` + authority outcome `allow/constrain/deny`. Disabled-with-reason-never-hidden + terminal-for-dispatch. Figcraft adds nothing here; Everything M8 folds here. |
| **S2 command registry + self-doc catalog + dispatch** | WB-U7 + TP U-06 + CC W4 + EV H4 + FG-U1 (A2 self-doc `describe()`) + Macro P1-1/C5 | IDS `CommandIntent` registry (identity/label/chord/applicability/enabled-reason/enumeration) **with** Figcraft self-doc seam (`describe()` non-drift) + router molecule with edit-focus guard + palette stays presentation. One seam, not two. |
| **S3 transport + injected formatter** | WB-U2 + TP U-02 + EV item 10 (transport half) + Macro P0-3/C1 | Organism `PrismTransportBar` (chrome only, slots for record/loop/metronome/BPM) + `PrismTimecodeBadge`/`PrismTimebaseBadge` + injected `formatTime`/`formatRange`. No time ontology. |
| **S4 honest-unknown + loading convergence + startup-failure** | WB-U4 (state half) + WB-U10 (loading half) + TP U-07 (state half) + CC W1-B/I-2 + CC W2-B (`PrismStartupFailureView`) + EV item 6 (state half) + Macro P0-2/P1-4/C6 + Sentry W6/W7 | Extend `DSStateType` + IDS inspection/query with `unknown` + `abstained/notAttempted`, fail-closed rule; converge `LoadingPane/Row/StateRegion` + Warpblade inline errors into `DSStateSurface`; `PrismStartupFailureView` extends `DSFallbackView`/`DSErrorBoundary`. One vocabulary, three landings. |
| **S5 job banner + terminal receipt** | WB-U4 (banner half) + TP U-07 (`ProgressCard`) + CC W3-B companion + EV (job half) + Macro P1-5/C6 | Molecule `PrismJobBanner` (staged + cancel + deterministic receipt slot; receipt *content* stays consumer). Toast is not a job. |
| **S6 decision-review surface + bounded repair** | WB-U5 + TP U-05 + CC W3-C/I-7 + EV item 7 (H3+M6) + FG-U4 (commit invariant feeds it) + Macro P1-3/C4 | Organism `PrismDecisionReviewSurface` (inspector + evidence + caller-diff + caller-action-bar) + bounded-repair molecule (RepairDialog shape) + approval-mode/undo-per-reply as options. Verdict pass-through invariant shared. |
| **S7 timeline chrome + IDS verbs + commit boundary** | WB-U3 + TP U-04 + EV item 11 + FG-U4 (B1 one-gesture-one-undo + `Set|Scrub` typing) + Macro P1-2/P1-8/C3 + gap-matrix §3 | Organism `PrismMultitrackTimeline` (`PrismTimeRuler` + `PrismTrackLane` + playhead) + IDS `TimelineIntent` verbs over injected model + cross-cluster commit invariant (one-gesture-one-history-step, live-vs-committed typed). |
| **S8 provenance family + lineage strip** | WB-U6 + CC W1-C/I-3 (`ProvenanceView`) + EV item 12 + Macro P0-4/C7 + Sentry W2/W13 (+W1/W14 views wait on it) | Atom `PrismProvenanceBadge` (canonicity) + atom `PrismWitnessBadge` (opaque hash + verified/unverified/mismatched/unknown) + sealed-rendering-mode contract (sealed = absent affordances) + molecule `PrismLineageStrip` (SAME\|DIFFER/derived-from). No hashing in Prism. |
| **S9 shell router + Draw-derived focus + sidebar + startup** | TP U-01 (tokens+shell) + CC W2-A/I-4 (`CommandCenterShell`) + EV H1/H2 (shell + sidebar) + FG-U2 (A7/A8 Draw-derived focus + Region model) + Macro P1-7/C10 | IDS shell-slot machine (slot/active-pane/focus-return token **derived from last committed layout**, `refocus`+`scroll_to` edge cases) + organism `PrismShellRouter` over `DSShell/SplitPane` + `PrismSidebar` section-model extension (kept-row fold, insertion line, Starred, unread pills) + S4 startup view. WB is negative evidence for layout (not counted). |
| **S10 meter/fader + generic canvas-host** | TP U-03 + TP U-09 (canvas-host half) + EV transport/meter half + WB negative (not counted) + Macro P1-6/C2 | Atom `PrismMeter` (injected scale + zone thresholds) + molecule `PrismFaderStrip` + narrow generic canvas-host contract (fixed-viewport determinism, bounded data, a11y numeric fallback). Calibration/FFT/goniometer/RMS stay local. |
| **S11 filter/table compositions + insertion + descriptor form** | EV H5/H7 (FilterBuilder + ToolbarPanel) + FG-U5 (B6 insertion line + test seams) + FG-U3-consumes (descriptor half) + WB-U9 (matrix + GenerationDrawer) + TP U-08 (REUSE sweep, DropZone, SongBlueprint) + CC W3-A/W3-B (sessions/event-stream) + Macro C9/P2-1 | Organism `PrismFilterBuilder` (nested AND/OR, per-type editors, debounce-commit+flush) + `PrismToolbarPanel` framework (button→popover→typed-panel→reanchor) + insertion-line behaviour for LaneBoard/VirtualGrid + descriptor-driven form as `DSAccordion`+`DSSelect` extension + audition/compare matrix as composition guidance. No new table/grid/board primitive. |
| **S12 composer + presence (multi-user-gated)** | EV H8 (composer) + EV H6 (presence) + TP annotations/WB comments/CC notes anchors | Organism `PrismComposer` (autogrow/@mentions/emoji/format/attachment lifecycle/parked drafts) + `PrismPresenceOverlay` (glide scaling, idle fold, stable-hash colour, culling). Presence ships **gated** on first multi-user host; composer ships EXPERIMENTAL until second host adopts. |
| **S13 numeric field + commit typing + quality nets** | FG-U3 (B3 numeric EXPERIMENTAL) + FG-U4 (commit) + FG-U8 (junk sweep + mirrored names) + FG-U5 (test-seam half) + WB `formatTime` params + TP studio/mastering params anchors | Atom `PrismNumericField` EXPERIMENTAL (`Set|Scrub` in type, quantum, modifier rates, release-frame no-op, Lead-as-name) + standing junk/adversarial sweep on every IDS/runtime suite + mechanism-mirrored test filenames + stable test-id convention. |
| **S14 runtime + harness proof upgrades** | WB-U8 (executor + terminality + streams/health) + TP U-10 (Graph/Health proofs) + CC event-stream REUSE + EV runtime needs + FG-U6 (A1 layer-table economics) + FG-U7 (A4/A5/A6 two-tier capture + frame-drain + cooperative cancel) + toast policy EV-M2 | (a) `AsyncJobExecutor` concept (per-execution identity for concurrent jobs, single-flight `AsyncCommand` untouched) + terminality/refusal-disclosure standardisation; (b) first-real-host proofs: `GraphSource` (DAG-gated), `HealthSource` (quota/hardware), `EventStream` bindings; (c) testkit/host-exercise: two-tier capture (chrome-free golden + windowed chrome + structured inspect), frame-boundary drain + cancel placement, toast policy (cap/sticky/hand-back), layer-table compaction. No contract change except (a). |
| **S15 convergence sweeps (REUSE — no new primitives)** | WB-U9/U10 + TP U-01 (token map) + TP U-08 + CC W3-A/W3-B/W5 + Macro REUSE-24 | Map 47 Tempest tokens onto `PrismTokenRegistry` (stem colours injected, not owned); converge Project/Media panels, Library/Models/Providers/Settings/Separate/Create screens, SessionList/Detail, EventStreamView, DropZoneCard, verification badges onto existing atoms/molecules/organisms. Host-proof is the work. |
| **S16 data-plane hosts (satellite-or-local, highest gate)** | WB-U11 (`PrismSurfaceHost`) + TP U-09 (spectrogram/goniometer/phase/DSP curves/automation) + WB spike (`NativeSurfaceController` excluded) + Macro P2-8/P2-12 | `PrismSurfaceHost` (aspect-locked texture host + placeholder canvas + HUD badge) ships **only with** written transfer/ownership declaration; FFT/spectral/goniometer/RMS/DSP/automation painters stay product-local; only the generic canvas-host seam may later crystallise as `warp_prism_audio_ui` satellite. Zero-copy claims require measured product evidence. |

Dedupe notes (what was NOT double-counted):

- Warpblade U1 = Command-center W1-A = Tempest `onPressed:null` = Sentry W8/W9 = one seam (S1). The "richest implementation" (CC `_GatedAction`) does not create a second item.
- Warpblade U7 = Tempest U-06 = CC W4 = Everything H4 = Figcraft U1 = one registry (S2); Figcraft's self-doc is an enrichment, not a rival.
- Warpblade U3 verbs = Tempest lane verbs = Figcraft B1 commit = one invariant inside S7.
- Warpblade banners = Tempest `ProgressCard` = CC loading trio = Sentry W6/W7 = S4 vocabulary + S5 widget (split by kind, not by consumer).
- Warpblade Proposal/Assurance = Tempest CommandBar/PromptEnhancer = CC Control/Connection = Everything H3/M6 = one surface (S6).
- Tempest shell = CC shell = Everything H1 = Figcraft A7/A8 = one router (S9); Warpblade shell explicitly excluded as recurrence.
- Meter geometry (S10) is Tempest-led; Warpblade is recorded as negative evidence, not a second consumer.
- Numeric field (S13) has zero current consumers — ranked as EXPERIMENTAL preempt, not STABLE; its promotion is gated on Warpblade/Tempest param adoption.
- Toast policy, layer-table compaction, two-tier capture, junk sweeps (S14/S13) are harness upgrades, not widgets — ranked for leverage, not visibility.

---

## 2. Final ranked list (ALL interesting ideas, ordered by impact)

**Impact = Consumer-coverage × Trust-risk × Reuse-leverage**, each 1–5. `I = C·T·L` (max 125). Ties broken by unblock power, then gate burden (lower burden first).

| Rank | ID | Idea (unified) | C | T | L | I= | Pri | Owner / layer |
|---|---|---|---|---|---|---|---|---|
| 1 | F-01 | Capability-gated action + authority (S1) | 5 | 5 | 5 | **125** | P0 | IDS (`warp_prism_interaction`) + ADS molecule |
| 2 | F-02 | Honest-unknown + abstention vocabulary + fail-closed rendering (S4-core) | 5 | 5 | 5 | **125** | P0 | ADS molecule+token + IDS inspection/query |
| 3 | F-03 | Command registry + self-doc catalog + dispatch router (S2) | 5 | 4 | 5 | **100** | P0 | IDS + ADS organism ext (`DSCommandPalette`) + runtime `describe()` |
| 4 | F-04 | Decision-review surface + bounded repair (S6) | 4 | 5 | 5 | **100** | P0 | ADS organism (extends `DSDetailInspector`) |
| 5 | F-05 | Provenance family + sealed mode + lineage strip (S8) | 4 | 5 | 4 | **80** | P0 | ADS atoms + presentation rule + molecule |
| 6 | F-06 | Shell-slot router + Draw-derived focus + sidebar section model (S9-core) | 3 | 4 | 5 | **60** | P0 | IDS + ADS organism + `PrismSidebar` ext |
| 7 | F-07 | Timeline chrome + IDS verbs + commit invariant (S7) | 3 | 4 | 5 | **60** | P0 | ADS organism + IDS verbs |
| 8 | F-08 | Transport bar + injected formatter + timecode badges (S3) | 3 | 3 | 5 | **45** | P0 | ADS organism + atom/molecule |
| 9 | F-09 | Startup-failure view + loading-chrome convergence (S4-landings) | 3 | 4 | 4 | **48** | P0 | ADS molecule (extends `DSFallbackView`/`DSErrorBoundary`) + `DSStateSurface` modes |
| 10 | F-10 | Job banner + terminal receipt (S5) | 3 | 3 | 4 | **36** | P1 | ADS molecule |
| 11 | F-11 | AsyncJobExecutor + terminality/refusal standard + stream/health binding (S14-runtime) | 3 | 4 | 4 | **48** | P1 | Runtime (`warp_prism_runtime`) + bindings + testkit |
| 12 | F-12 | Filter builder + toolbar-panel framework (S11-core) | 3 | 3 | 5 | **45** | P1 | ADS organism + framework |
| 13 | F-13 | Meter + fader strip + canvas-host contract (S10) | 2 | 3 | 4 | **24** | P1 | ADS atom + molecule; satellite later |
| 14 | F-14 | Numeric field EXPERIMENTAL + `Set\|Scrub` typing (S13-widget) | 2 | 3 | 5 | **30** | P1 | ADS atom (EXPERIMENTAL, proof-lab only) |
| 15 | F-15 | Token + shell convergence sweep (S15-foundation) | 3 | 2 | 5 | **30** | P1 | Tokens + ADS compositions (REUSE) |
| 16 | F-16 | Session/list/detail + event-stream + panel convergence sweep (S15-compositions) | 3 | 3 | 4 | **36** | P1 | ADS compositions (REUSE, host-proof work) |
| 17 | F-17 | Graph/Health first-host proofs — DAG-gated (S14-proofs) | 2 | 3 | 4 | **24** | P1 | Runtime contracts + `DSGraphCanvas` ext + `PrismLineageStrip` |
| 18 | F-18 | Composer organism EXPERIMENTAL (S12-composer) | 3 | 2 | 4 | **24** | P1 | ADS organism (EXPERIMENTAL) |
| 19 | F-19 | Harness upgrades: layer-table compaction + two-tier capture + drain/cancel + junk sweeps + toast policy (S14-harness + S13-nets) | 5 | 3 | 4 | **60** | P1 | Boundary harness + testkit + host-exercise + `PrismToastManager` |
| 20 | F-20 | Audition/compare matrix composition (S11-matrix) | 1 | 3 | 3 | **9** | P2 | Composition guidance over `DSVirtualGrid`+`DSLaneBoard` + S1/S4/S8 |
| 21 | F-21 | Descriptor-driven disclosure form (S11-form) | 1 | 2 | 4 | **8** | P2 | `DSAccordion`+`DSSelect` extension pattern |
| 22 | F-22 | Ribbon collapse-priority + tool-mode palette (S11-ribbon) | 1 | 2 | 3 | **6** | P2 | ADS pattern (single-consumer) |
| 23 | F-23 | Energy-curve editor (SongBlueprint) | 1 | 2 | 2 | **4** | P2 | CANDIDATE P2 (topology-only `DSGraphCanvas` insufficient) |
| 24 | F-24 | Presence overlay — gated on first multi-user host (S12-presence) | 1 | 2 | 3 | **6** | P2 | ADS overlay (gated HOLD) |
| 25 | F-25 | Surface host + waveform/spectral/goniometer satellite seam (S16) | 1 | 4 | 2 | **8** | P2 | Adapter boundary / future `warp_prism_audio_ui`; painters local |
| 26 | F-26 | Sealed decision case + dual-authority panes + phase rail + epistemic lens (Sentry W1/W3/W5/W10/W11/W14 views) | 1 | 4 | 2 | **8** | P2 | ADS views over S5/S8/S6; models stay in Sentry |
| 27 | F-27 | Authority explainer + partial-fill remainder views (Sentry W8/W9 views, depend on S1) | 1 | 3 | 3 | **9** | P2 | ADS views; runtime implication for remainder |

> Read the rank as priority, not sequence. F-07 depends on F-08's formatter discipline + F-01 gating; F-04 depends on F-01 + F-02; F-19's harness items land first where independent (layer-table + junk nets are 1-session wins); F-17's DAG proof and F-24 stay HOLD until their hosts exist.

### Detail cards (score rationale + source refs + owner/layer)

**F-01 — Capability-gated action + authority [P0, 125].** Four independent re-inventions (WB null-callback ×3 sites `project_panel.dart:124-177`, `take_tiles.dart:568-584`, `assurance_panel.dart:292-297`; CC `_GatedAction`/`_DisabledButton` `control_panel.dart:49-138` + `PermissionSection` `:252-430` + `AbortSection`; TP `onPressed:null` ×5 sites; Sentry W8/W9). Prevents hidden-as-not-applicable trust defect. *Sources:* WB-U1; TP U-06/U-07; CC W1-A/I-1; EV-§5 item 6; Macro P0-1/C11. *Owner:* IDS pure-Dart semantics + ADS molecule `PrismActionGate`; extends `DSOperationalState` only for generic allow/constrain/deny. *Gates:* IDS purity; denied≠hidden≠enabled + reason propagation; a11y disabled-with-reason; host proof CC + WB.

**F-02 — Honest-unknown + abstention [P0, 125].** Live gap confirmed: `DSStateType` (`ds_state_surface.dart:294-315`) has no unknown; `DSMessageStatusHistory` step state likewise. Sentry #1; WB three duplicated inline error blocks (`generation_drawer.dart:356-372`, `take_tiles.dart:250-268`, `assurance_panel.dart:228-246`); CC GOLD loading trio. Unknown rendering as success/disabled is worse than a missing widget. *Sources:* WB-U4; TP U-07; CC W1-B/I-2; Macro P0-2/C6. *Owner:* ADS token+molecule + IDS inspection/query states. *Gates:* fail-closed conformance; determinism (indeterminate excluded from goldens); a11y announcements; host proof CC + WB.

**F-03 — Command registry + self-doc + dispatch [P0, 100].** IDS has no command module (`input/inspection/query/selection/state_machine` only — live). `DSCommand` has shortcut hint but no registry/applicability/index. Donor A2 (`control.rs:221-226` `engine.commands` returns `{id,label,params,menu,shortcut,undoable}`) proves drift-proof shape; Figcraft B6/`x_tests` naming + Warpblade `keyboard_shortcuts.dart:62-64` guard prove the split (guard = presentation, eligibility = IDS). *Sources:* WB-U7; TP U-06; CC W4; EV-H4; FG-U1; Macro P1-1/C5. *Owner:* IDS registry + `DSCommandPalette`/`DSToolStripSlideout` ext + runtime `describe()` seam + router molecule. *Gates:* IDS purity; chord collision/precedence + enumeration stability + disabled-reason propagation; keyboard-only path; host proof WB + CC.

**F-04 — Decision-review surface [P0, 100].** Built independently 3× (WB `ProposalPanel` `:4-466` + `AssurancePanel` `:5-778` + `RepairDialog` `:617-778`; TP `CommandBarDialog` + `PromptEnhancerDialog`; CC `ControlPanel` + `_GatedAction`). All parts exist (`DSDetailInspector` `:10` + `:194` + `:210`, `DSEvidenceRow`, `DSAssetCard`, `MasterDetailTemplate`); the review framing does not. *Sources:* WB-U5; TP U-05; CC W3-C/I-7; EV-H3/M6; Macro P1-3/C4. *Owner:* ADS organism + bounded-repair molecule. Depends on F-01 + F-02. *Gates:* pass-through integrity (unknown≠pass); tooltip-reason per verdict; host proof ≥2 hosts.

**F-05 — Provenance family + sealed + lineage [P0, 80].** `DSProvenancePill` (`:8`,`:9-41`,`:110-127`) is canonicity-only. WB carries fingerprint+digest+`observedAtNum/Den` (`assurance_panel.dart:411-506`), `_ProvenanceStrip` SAME|DIFFER (`take_tiles.dart:141-152,653-741`), SHA-256 receipt (`banners.dart:95-155`); CC causation grouping; Sentry hash witness. Cheapest trust-critical presentation work. *Sources:* WB-U6; CC W1-C/I-3; EV-12; Macro P0-4/C7. *Owner:* ADS atoms + presentation rule + `PrismLineageStrip` molecule. *Gates:* unverified-never-verified; sealed = absence-of-affordance; host proof CC + WB.

**F-06 — Shell router + Draw-derived focus + sidebar [P0, 60].** Only real multi-pane hosts: CC + Tempest `MainShellLayout` (203 lines, 7 branches); WB is negative evidence (single column). Donor H1 focus-tracking is idea-only; Figcraft A7/A8 (`a11y.rs:29-58,86-99` `Region` + `Drawn` + `refocus` + `scroll_to`) is the only proven focus shape. Sidebar H2 (collapsible/kept-row/Starred/unread/drag-insertion) folds here. *Sources:* TP U-01; CC W2-A/I-4; EV-H1/H2; FG-U2; Macro P1-7/C10. *Owner:* IDS slot machine + ADS `PrismShellRouter` over `DSShell/SplitPane` + `PrismSidebar` ext. *Gates:* focus-restoration conformance; multi-pane host proof (CC); determinism across transitions.

**F-07 — Timeline chrome + verbs + commit [P0, 60].** Highest-coupling cluster. WB `TimelineStrip` (`:4-541`, 1s ticks, 52px lanes, 48px min-target, `pixelsPerSecond` ctor-only, seek delegated to `timeline_intents.dart:5-161`) proves semantics-outside-widget; TP `StudioTimelineLane` + `MusicalRuler` + painters prove the second ontology. Donor B1 (`right.rs:26-57` one-undo-step + `FieldEdit Set|Scrub`) supplies the shared commit invariant. *Sources:* WB-U3; TP U-04; EV-11; FG-U4; Macro P1-2/P1-8/C3. *Owner:* ADS organism (`PrismTimeRuler` + `PrismTrackLane` + playhead) + IDS verbs (pure Dart). Domain painters/math stay local. *Gates:* **two-ontology conformance** (seconds AND bars/beats); pixel↔time determinism; IDS purity; host proof WB + TP. Validate on WB side first (weaker layout).

**F-08 — Transport bar + formatter [P0, 45].** Highest visible win per line of code. WB `TransportBar` (`:3-99`, `formatTime` injected `:5-13` — correct decision trapped in local chrome); TP `StudioTransportBar` (`:7-414`); Prism has only private `_TransportButton` (`:797`) + `_buildTransportRow` (`:687`) + `showTransport` flag. *Sources:* WB-U2; TP U-02; EV-10; Macro P0-3/C1. *Owner:* ADS organism + `PrismTimecodeBadge`/`PrismTimebaseBadge`. Step sizes/labels/slots caller-supplied; no SMPTE/BPM ontology. *Gates:* fake + conformance (steps/disabled/formatter/a11y); determinism; host proof both hosts.

**F-09 — Startup-failure + loading convergence [P0, 48].** Fail-closed bootstrap (WB `startup_error_page.dart:3-64` + CC `DaemonNotConnected`/`DaemonBootstrap` = 2 consumers) + GOLD loading rationale (`loading.dart:3-11` non-animated determinism). *Sources:* WB-U4/U10; CC W2-B/I-2; TP U-07 part; Macro P1-4. *Owner:* ADS molecule + `DSStateSurface` modes. Depends on F-02. *Gates:* leak-negative test (no stack-trace render); host proof CC; determinism.

**F-10 — Job banner + receipt [P1, 36].** WB export banners (indeterminate spinner vs terminal receipt, no lifecycle link) + TP `ProgressCard` (multi-stage + cancel + timer) + CC loading trio. Toast is not a job. *Sources:* WB-U4; TP U-07; CC W3-B; Macro P1-5. *Owner:* ADS molecule `PrismJobBanner`. *Gates:* fail-closed states; determinism; cancel semantics; host proof TP + CC.

**F-11 — Runtime executor + terminality + bindings [P1, 48].** Deepest runtime finding: WB `bridge_adapter.dart:1-33` is import-boundary only; ~60 `setState` sites, raw `StreamSubscription`s, single-flight generation/export forced through one-flight UI. Proposes `AsyncJobExecutor` (per-execution identity; `AsyncCommand` untouched) + `isTerminalMediaError` (`media_error_mapper.dart:51-65`) + `pathRefusedPrefix` verbatim invariant + `AssuranceLoader/Repairer` typedef shape (`assurance_panel.dart:21-23`) as testkit pattern + `EventStream`/`HealthSource` bindings (bridge badge → real health projection). *Sources:* WB-U8; TP U-10 (parity suite); Macro runtime rows. *Owner:* `warp_prism_runtime` + `warp_prism_bindings` + testkit. Needs runtime-architect review. *Gates:* same-suite-for-fake-and-adapter; per-execution identity; refusal-prefix verbatim; health snapshot test.

**F-12 — Filter builder + toolbar-panel [P1, 45].** Donor HIGH H5 (nested AND/OR, per-type editors, debounce-commit+flush) + H7 (button→popover→typed-panel→reanchor) land on real anchors: `PrismFilterWorkbench` partial, logs/timelines/status grids everywhere, TP library/models screens, CC session list, WB takes. *Sources:* EV-H5/H7; Macro C9; FG corroboration. *Owner:* ADS organism + framework. *Gates:* fake model + per-type editor suite; determinism; host proof TP + CC.

**F-13 — Meter + fader + canvas host [P1, 24].** TP `_buildPeakMeter`/`_buildLufsMeter`/`DbFader`/`PanKnob`/`StudioTrackControls`/`StemMixer`/`MasterBusStrip`; Prism linear-only (`PrismMetricTile`/`Sparkline`). Geometry generic, calibration injected (dBFS/LUFS/RMS local). *Sources:* TP U-03/U-09; EV-10; Macro P1-6/C2. *Owner:* ADS atom + molecule. *Gates:* fixed-value goldens; a11y numeric (never colour-only); boundary clearance (no audio types in `warp_prism_ui`).

**F-14 — Numeric field EXPERIMENTAL [P1, 30].** Donor B3 (`field_math.rs:8-43` Typed/relative/div-zero/.Format bounds + `widgets.rs:20-133` Lead/Set-vs-Scrub/commit/quantum/modifier rates/release-frame + `field_tests.rs:18-52` parse table). Zero current consumers; near-certain future demand (WB transport params, TP studio/mastering). Ships EXPERIMENTAL proof-lab + ported table suite; STABLE only on adoption. *Sources:* FG-U3; WB rational/format anchors; TP params anchors. *Owner:* ADS atom. Consumes F-07 commit invariant + F-19 nets. *Gates:* parse/scrub/keep-after-release/sibling-untouched suites; no STABLE/barrel until host adoption.

**F-15 — Token + shell convergence [P1, 30].** TP `AppTheme` (290 lines) + `AppColors` (47 tokens) duplicate `PrismTokenRegistry` + M3 factory + 3 skins; `MainShellLayout` duplicates `PrismShell/Sidebar`. Mechanical, widest touch, unblocks every later visual. *Sources:* TP U-01; CC theme baseline (already consumes — verify, don't invent); Macro C10. *Owner:* tokens + ADS compositions. *Gates:* host proof TP studio route (theme/focus/navigation per AGENTS §7.1); format+analyze clean; barrel check.

**F-16 — Session/panel/screen convergence [P1, 36].** No new primitives: `SessionList/Detail` → `DSDataTable/VirtualList/StatusGrid` + F-01 rows + S8 badges; `EventStreamView` → `DSLogViewer/Timeline/ExecutionConsole`; `ProjectPanel/MediaPanel` (lifecycle/action + probe strip → `DSPropertyRow`/mono pattern); TP Library/Models/Providers/Settings/Separate/Create → `DSSearchBar/FilterChipGroup/AssetCard/StatusDot/MetricTile/StateSurface/Select/Accordion`; `DropZoneCard` → `DSDropTarget`+`AssetCard` ext. The work is host-proof (weakest-evidence area), not construction. *Sources:* WB-U9/U10; TP U-08; CC W3-A/W3-B; Macro C9 REUSE-24. *Owner:* composition guidance. *Gates:* real-host exercise (interact, no framework errors/`ErrorWidget`/`RenderFlex` overflow, theme/focus intact).

**F-17 — Graph/Health first-host proofs [P1, 24].** Rendering substrate present (`DSGraphCanvas`, `GraphEdge`, `WorkflowCanvasStage`); missing: a real `GraphSource` consumer. `ProjectVersionDagTree` is DECLARED-not-built → HOLD; `ProviderQuotaUsageTracker` → `HealthSource` cost-axis proposal; `HardwareStatusIndicator` → `PrismProviderHealthMatrix` (credentials stay product-local). *Sources:* TP U-10; WB take-lineage (textual SAME|DIFFER — not graph demand); Macro C8/P2-2. *Owner:* runtime + `DSGraphCanvas` input ext (caller-supplied kinds) + `PrismLineageStrip`. *Gates:* fake + conformance; real-DAG host proof when host exists; boundary clearance.

**F-18 — Composer EXPERIMENTAL [P1, 24].** Donor H8 (autogrow/@mentions/emoji/format/attachment lifecycle/parked drafts, 1108 lines). Anchors: WB comments, TP annotations, CC operator notes (all forthcoming local surfaces, not yet inventoried — ships EXPERIMENTAL, promotes on second-host adoption). *Sources:* EV-H8; Macro Held→CANDIDATE upgrade. *Owner:* ADS organism. *Gates:* draft/caret conformance; host proof when anchors land.

**F-19 — Harness upgrades (do first where independent) [P1, 60].** (a) Layer-table compaction (donor A1 `layers.rs:8-75` TABLE+direct-deps+fail-closed → collapse 16 hand-written assertions toward generated table + generic upward rule, all greens held); (b) two-tier capture (chrome-free deterministic render for goldens + windowed screenshot for chrome + structured inspect; bounded waits, visible-window errors); frame-boundary drain + cooperative-cancel placement for FRB adapter work; (c) junk/adversarial sweep on every IDS/runtime suite (fail-closed, not crash-free); mechanism-mirrored filenames + stable test-ids + `tab_to`-by-name; (d) toast policy (cap/sticky/action/hand-back/onDismiss-only-on-close). *Sources:* FG-U6/U7/U8; EV-M2; Macro §6 gates + UNKNOWN-4. *Owner:* boundary harness + testkit + host-exercise + `PrismToastManager`. *Gates:* existing suites stay green through migration; determinism; hand-back/cap conformance.

**F-20 — Audition/compare matrix [P2, 9].** WB `TakeTilesPanel` (`:139-591`, vertical list NOT grid, no thumbs/drag/zoom — corrected claims honoured) + `_CompareStrip` SAME|DIFFER `:653-741` + Regenerate-lineage `:324-436` as composition over `DSVirtualGrid`+`DSLaneBoard` + F-01 + F-04 + F-05. Single-consumer → EXPERIMENTAL guidance + one suite; promote on second descriptor host. *Sources:* WB-U9; Macro P2-1/C9. *Owner:* composition guidance. Depends on F-01/F-04/F-05.

**F-21 — Descriptor-driven disclosure form [P2, 8].** WB `GenerationDrawer` (`:5-552`, 3-level disclosure, descriptor-iterated controls skipping `prompt`, uint+`FormatException` `:81-134`, route-preview slot) as `DSAccordion`+`DSSelect` extension pattern. Single-consumer. *Sources:* WB-U9; EV-M3; FG descriptor half. *Owner:* ADS extension pattern.

**F-22 — Ribbon + tool-mode palette [P2, 6].** Donor M7 (contextual tabs, priority collapse) + TP declared `DawToolPalette`/`FloatingContextCommandBar`. Single-consumer until second. *Sources:* EV-M7; TP declared rows; FG-A2 corroboration. *Owner:* ADS pattern over S2 registry.

**F-23 — Energy-curve editor [P2, 4].** TP `SongBlueprintWidget` (energy bar + drag sliders + preset toolbar). `DSGraphCanvas` topology-only → insufficient; single consumer → backlog P2. *Sources:* TP U-08; Macro P2-7. *Owner:* CANDIDATE P2.

**F-24 — Presence overlay, gated HOLD [P2, 6].** Donor H6 (glide scaling, idle-name fold, per-user colour, culling). No current multi-user host — build behind fake-room-model gate, prove glide/culling determinism, HOLD STABLE until first multi-user host. *Sources:* EV-H6. *Owner:* ADS overlay.

**F-25 — Surface host + data-plane satellite seam [P2, 8].** WB `TexturedPreviewHost` (`:3-178`, `WP-GAP-001`, presentation-only, `Texture(textureId)` + HUD vs `CustomPaint` grid + `shouldRepaint false`; spike `NativeSurfaceController` explicitly NOT harvest) + TP FFT/spectral/goniometer/phase/DSP/automation. Highest gate burden by law (transfer/ownership per MISSION §7; data plane ≠ event stream). Ranked last by build order, not by visibility. *Sources:* WB-U11; TP U-09; Macro P2-8/P2-12. *Owner:* adapter boundary / future satellite. *Gates:* written transfer/ownership declaration + runtime-architect review; Linux host proof; placeholder determinism.

**F-26 — Sealed decision views + phase rail + epistemic lens [P2, 8].** Sentry W1/W3/W5/W10/W11/W14 (dual-authority panes, advisory framing, lens badge, episode closure, hypothesis card, SEAL legal-act marker). Models stay in Sentry; Prism renders views over F-04/F-05. Single request-only consumer with no Flutter source → views wait for a real host; lens badge is domain-heavy → needs second-consumer evidence. *Sources:* Macro §4.5 W-rows; CC/TP review hosts as second proof where applicable. *Owner:* ADS views. Depends on F-04/F-05.

**F-27 — Authority explainer + partial-fill remainder views [P2, 9].** Sentry W8 (explainer over F-01) + W9 (remainder/terminal-for-dispatch; runtime-contract implication for `AsyncCommand` — needs runtime review, not just ADS). Depends on F-01 landing. *Sources:* Macro W8/W9; CC/WB gated-action hosts. *Owner:* ADS views + runtime review for remainder.

---

## 3. Coverage map (who proves what)

| Consumer | Primary proof load | Negative / local-only (honoured) |
|---|---|---|
| Warpblade (clean inbound, zero Prism deps, single scrolling column) | F-01 gates, F-03 router, F-08 transport+formatter, F-07 verbs (weaker-layout validation first), F-02 banners, F-04 proposal+assurance (two surfaces), F-05 strips+receipt, F-11 executor/streams, F-20/F-21 compositions, F-25 placeholder | Rational BigInt/GCD, timebase quantisation, NLE models, GPU lifecycle, generation routing, proposal computation, spike controller, AssurancePanel reachability fix (product-owner) |
| Tempest (DAW, 7-branch shell, FRB ^2.0.0, zero Prism deps) | F-15 tokens+shell, F-08 + F-13 + F-07 (studio route), F-04/F-03 (CommandBar/enhancer), F-10 `ProgressCard`, F-12/F-16 REUSE sweep, F-17 DAG/quota/hardware (when built), F-09/F-25 data-plane seam | Musical-grid math, DSP/insert chains, LUFS/RMS calibration, FFT/spectral/goniometer painters, DAW orchestration/state/controllers, take/comping, MIDI, plugin hosting, lyric engine, credentials, routing/l10n |
| Command-center (only real multi-pane host, 10/10 Prism ids RESOLVE, 15/15 absent) | **Designated proof host:** F-01 (`_GatedAction` richest impl), F-02 GOLD loading trio, F-05 causation, F-06 shell router + focus, F-09 bootstrap, F-16 sessions/stream/panels, F-04 review | App root/router, daemon wiring/persistence/credentials/orchestration, causation computation, capability evaluation, transport/meter/timeline construction (other tracks) |
| Sentry (Rust-only, no Flutter surface, 14 DECLARED requests) | Priority signal only: F-02 (W6/W7 #1), F-05 (W2/W13), F-01 (W8/W9), F-07 clocks (W4), F-17 lineage (W12) | Decision-reconstruction models, episode/hypothesis models, five-clock family ownership, lens ontology — all stay in Sentry core |
| Donors (Figcraft/Everything — inspiration only, never demand) | Harness + mechanism detail: self-doc (A2→F-03), focus (A7/A8→F-06), numeric (B3→F-14), commit (B1→F-07), insertion/test-seams (B6→F-11/F-16), layer-table (A1→F-19), capture/drain/cancel (A4/A5/A6→F-19), junk sweeps (→F-19); H5/H7→F-12, H2→F-06, H8/H6→F-18/F-24 | Donor accidents never port: `el()/h()` helpers, store emitter, hash router, localStorage, account dep, glyph sets, WebRTC, canvas painters, `structuredClone/debounce/keepFocus`, vite setup, domain coupling, egui/wgpu/Figma coupling, brand/glyphs |

---

## 4. Owner / layer index

| New surface | Layer | Why this layer |
|---|---|---|
| `ActionAvailability`/`CapabilityState`, `CommandIntent` registry, shell-slot machine + focus-return token, `TimelineIntent` verbs, commit invariant, unknown/abstention query states | **IDS** (`warp_prism_interaction`, pure Dart, no Flutter) | User-intent semantics; IDS is the named owner (MISSION §4.2). Eligibility/focus-tokens/commit are semantics; widgets own mechanics. |
| `PrismTransportBar`, `PrismTimecodeBadge`, `PrismTimeRuler/TrackLane`, `PrismDecisionReviewSurface`, `PrismFilterBuilder`, `PrismToolbarPanel`, `PrismComposer`, `PrismPresenceOverlay`, audition/matrix compositions | **ADS organisms/molecules** (`warp_prism_ui` only, no FRB/runtime imports) | Reusable visual + interaction chrome. |
| `PrismActionGate`, `PrismMeter`, `PrismFaderStrip`, `PrismJobBanner`, `PrismWitnessBadge`, `PrismProvenanceBadge`, `PrismStartupFailureView`, `PrismNumericField`, `PrismLineageStrip`, loading convergence | **ADS atoms/molecules** | Presentation of injected models; calibration/verification/hashing logic stays consumer-side. |
| Edit-focus guard, focus wiring, dispatch router widget, canvas-host widget | **ADS presentation** | Focus/DOM-equivalent mechanics must not enter IDS. |
| `AsyncJobExecutor`, terminality/refusal standard, `describe()` seam | **Runtime** (`warp_prism_runtime`, presentation-free) | Semantics + lifecycle; purge law holds (no presentation policy). Dialog/request-boundary concepts stay out (A3 excluded by layer law). |
| Stream/health/graph binding, `Offset` ownership | **Bindings** (thin projections) | No backend logic/storage; widgets never call generated FRB directly. |
| Fake/reference + conformance per contract, junk sweeps, two-tier capture, drain/cancel reference, test-id conventions | **Testkit + host-exercise harness** | Proof before promotion (§6 gates 2/5/6). |
| Layer-table compaction, barrel/alias checks | **Boundary harness** | Same-task check per new contract (layer-contracts §10). |
| Texture/media viewport hosts | **Adapter boundary, not ADS core** | Must declare transfer/ownership (MISSION §7); highest gate burden. |

---

## 5. Unknowns carried (not resolved, not blocking unless noted)

- **U-REV:** all consumer revision states UNKNOWN (no VCS operation per workspace law). Citations are `path:line` live reads / report-grade inherits, not SHAs. Re-verify at task-creation time.
- **U-EXEC:** zero execution in every input pass (no build/test/golden/analyze/host run). Every "covers/gap" claim is a static-read claim. Host-composition proof (Macro UNKNOWN-4) remains the program's largest single evidence debt and is gated into every F-item above.
- **U-SENTRY:** Sentry has no Flutter UI surface — all W-items are DECLARED requests. Sentry strengthens priority, never substitutes for WB/TP/CC host proof.
- **U-DAG:** Tempest `ProjectVersionDagTree` (F-17) and presence multi-user host (F-24) are DECLARED/forthcoming — both stay HOLD in `00-planning` until the host exists.
- **U-ASSURANCE:** Warpblade `AssurancePanel` unreachable in real app (`main.dart:1363-1375` passes neither `onAssess` nor `onRepair`) — product-owner fix, surfaced not owned; F-01/F-04 make the dead gate visible.
- **U-IDS (Macro UNKNOWN-12, narrowed):** whether IDS absorbs availability/command-eligibility/slot/focus/commit and stays "not a state-management framework". F-01/F-03/F-06/F-07 give the architecture owner four bounded proposals to accept/reject — record as review input, batch into one IDS review.
- **U-ARITH (Macro UNKNOWN-1):** Tempest inventory 43/50 summary vs 39+12 enumerated — re-scan Tempest at task-creation time; 4-row gap must be reconciled before F-07/F-17/F-25 promote.
- **U-RECON (Macro UNKNOWN-9):** `layer-contracts.md` §9 PROVEN row already reconciled (Task 1847); `docs/bridge/README.md` harvest loop + classification vocabulary and `docs/design/token-theme-catalog-policy.md` promotion gates still state recurrence. Downstream tasks cite MISSION §3.1/§6-item-1 on conflict until reconciled through task governance.
- **U-COUNT:** 295 vs 296 alias declarations — immaterial; barrel is authority. Re-run exhaustive counts at kickoff.
- **U-DONOR:** Figcraft B5/B7–B10 remain `UNVERIFIED`/excluded; Everything 41 apps (incl. `audio-studio`, `video-studio`, `cad`, `calendar`) uninspected — future harvest frontier, not a blocker. Donor snapshot identity UNKNOWN; bodies beyond cited ranges unread (5 exact follow-up reads in FG §7); donor test *presence* ≠ quality.
- **U-SYMLINK:** CC bridge symlink unreadable from workspace (`external_directory` denial) — CC citations are clone-grade (`references/ganthritor-command-center/`); note provenance on downstream tasks.
- **U-DRIFT:** CC `integration/theme.dart:5-12` vs direct `warp_prism_ui` imports in `features/` — fix in convergence wave (F-15/F-16), not as drive-by in F-01–F-03.

---

## 6. Non-goals (ambitious does not mean unbounded)

- No `warp_prism_av` / `warp_prism_audio_ui` package split in this wave — build inside existing owners; split when an import graph forces it (crate-boundary justification required).
- No time-ontology unification (SMPTE vs bars/beats vs wall-clock vs rational vs five-clock stay distinct); no rational-time type, NLE model, musical math, LUFS/RMS calibration, DSP chains, FFT/goniometer painters, credentials, DAW/generation orchestration, lyric/syllable engine, plugin hosting in Prism.
- No app-root/router absorption, no persistence, no daemon wiring, no product orchestration.
- No donor-only STABLE widgets (M5/L1/L3 parked as inspiration; F-14/F-18 EXPERIMENTAL with adoption gates).
- No flag-day migration — convergence is directional (bridge contract §4); local deletions wait for STABLE + host proof per surface.
- No speculative templates/scaffolds — crystallisation rule stands; absorbing product-proven components is not speculation.
- No transitive-coverage claims for either layer checker (direct-dep class only).
- No zero-copy claims without measured product evidence.
- No `warp_prism_av` transport ontology, no Figma-shaped ontology, no egui/wgpu coupling, no brand/glyph porting.

---

## 7. Suggested build order (for the future task wave, not this artifact)

```text
F-19a (layer-table + junk nets — independent, 1-session wins)
  → F-01 (gate) ∥ F-02 (unknown) ∥ F-08 (transport+formatter) — disjoint writesets
    → F-03 (registry+self-doc) + F-06 (shell+focus, batched IDS review with F-01/F-03)
      → F-05 (witness/sealed) + F-09 (startup/loading) + F-10 (job banner)
        → F-04 (review surface) + F-07 (timeline chrome+verbs; validate on WB first)
          → F-11 (executor+terminality+binding) + F-12 (filter+toolbar) + F-13 (meter/fader)
            → F-14 (numeric EXPERIMENTAL) + F-15/F-16 (convergence sweeps, anytime a builder is free)
              → F-17 (DAG proof, HOLD until host) + F-18 (composer) + F-20/F-21/F-22/F-23 (P2 compositions)
                → F-24 (presence, gated HOLD) + F-25 (surface host, after ownership declaration)
                  + F-26/F-27 (Sentry views over landed F-01/F-04/F-05)
```

Sibling-safe parallelism: F-01 ∥ F-02 ∥ F-08 (IDS vs token/molecule vs organism — distinct owners); F-05 ∥ F-09 ∥ F-10 next (atoms/molecules distinct); F-04 and F-07 compose on F-01/F-02 outputs, not on each other. Shared-write guards (`PrismTokenRegistry`/skins, `prism_aliases.dart`/barrels, `boundary_test.dart`, gallery registry, `layer-contracts.md`, `component-catalog.md`) — one owner per invariant. F-11 needs runtime-architect review independent of ADS lanes.

Per-upgrade lifecycle: every F-item enters EXPERIMENTAL (spec + fake + suite, no barrel export) and advances only via MISSION §6 gates 2–7 (fake + conformance + boundary + host proof + FRB lifecycle where applicable + independent review + barrel export + API freeze). No task promotes `00-planning → 01-open` until injected-model/formatter/calibration seams, writesets/owners, validation commands, and host-proof exit criteria are explicit.

---

## 8. Return packet

- **Scope:** 5 architect-upgrade inputs + macro-review (98 UI units + 10 consumption rows, C1–C11) + MISSION §3.1/§11.4 + component-catalog → 16 unified seams (S1–S16) → **27 ranked ideas (F-01–F-27)**: P0 = F-01–F-09 (trust core + shell/focus + timeline + transport + startup), P1 = F-10–F-19 (job/meter/numeric/filter/convergence/runtime-proofs/composer/harness), P2 = F-20–F-27 (single-consumer compositions, gated presence/DAG/surface-host, Sentry views).
- **Merge record:** §1 table — every duplication across the 5 inputs collapsed once (gate ×4, registry ×5, transport ×4, unknown ×5, review ×5, timeline ×5, provenance ×4, shell ×5, meter ×3, filter/matrix ×5, composer/presence ×2, numeric/commit/nets ×3, runtime/harness ×4, convergence ×4, data-plane ×3).
- **Highest impact:** F-01/F-02 (125 — 4–5 consumers, fail-closed trust defects, pure-semantics leverage) > F-03/F-04 (100 — command/review spines) > F-05 (80 — witness/sealed) > F-06/F-07 (60 — shell/timeline, hardest correctness) > F-08/F-09 (transport/startup, visibility + fail-closed landings). Harness F-19 scores 60 on leverage — scheduled first where independent despite P1 label.
- **Proof host:** command-center is the designated real-host proof surface (multi-pane, consuming, richest gated-action + GOLD loading); Warpblade validates weaker-layout seams first (formatter, verbs); Tempest proves studio/meter/lane; Sentry never substitutes for host proof.
- **Laws enforced:** layer purity (16 checks), IDS pure-Dart, purge law, bidirectional domain-leakage, data-plane separation, MISSION §6 evidence gates, no flag day, no self-acceptance.
- **Blockers named:** IDS scope review (batched F-01/F-03/F-06/F-07); zero host proof corpus-wide; DAG + presence hosts HOLD; Tempest 4-row arithmetic; 3 stale-recurrence docs; revision UNKNOWN; donor partiality; symlink provenance; CC coupling drift.
- **Next owner:** Warp Prism architecture/task-governance lane. Materialize one task per F-item (split F-07 chrome vs verbs, F-11 executor vs stream/health binding, F-19 harness pieces), each ≥50 lines per `000-template.md`, with `Where` tables citing the `path:line` evidence above and the §2 gates as exit conditions. Nothing here authorizes implementation.
