# Warp Prism Upgrade Plan for Warpblade — Architect Proposal

- **Artifact:** `.project/research/architect-upgrade-warpblade-2026-11-01.md`
- **Date:** 2026-11-01
- **Lane:** Architect (read-only synthesis + upgrade proposal, no implementation)
- **Governing law:** `MISSION.md` §3.1 + §11.4 (full-coverage central ADS/IDS, absorption default, recurrence = priority not gate, evidence gates §6.2–§6.7 stand, domain engines stay local per §4.5) wins over pre-amendment recurrence framing, stale bridge prose, and any keep-local-by-default habit.
- **Posture:** deep-dive, ambitious, NOT conservative. No invented blockers. Every proposal below is mandate-covered Warpblade UI that Prism must eventually absorb natively.
- **Scope:** Warpblade only. Tempest / Command-center / Sentry appear only as recurrence-priority signals, never as scope expansion.

## 1. Sources read (all workspace-local)

| # | Source | Evidence class | What was taken from it |
|---|---|---|---|
| 1 | `MISSION.md` §§3–6, §11.4 | governing law | absorption default, KEEP_LOCAL only for non-UI domain logic, evidence gates, purge/data-plane/bypass/leakage rules |
| 2 | `docs/design/component-catalog.md` (checked 2026-10-15) | canonical index | live Prism baseline: atoms/molecules/organisms actually owned |
| 3 | `.project/research/consumer-inventory-warpblade-2026-10-15.md` | OBSERVED-REPORT (live source read 2026-10-15, 19 rows) | all Warpblade seams, WP-GAP declarations, negative evidence |
| 4 | `.project/research/macro-review-unification-map-2026-10-20.md` | decision map (Prism side OBSERVED-LIVE, consumer side INHERITED-REPORT) | C1–C11 clusters, P0/P1/P2 backlog, five shared seams, UNKNOWN-1…12 |
| 5 | `docs/bridge/warpblade/ads-debt.md` (audit 2026-09-13) | consumer-declared debt + roadmap | `warp_prism_av` target names, Slice 3–7 future demand, P0/P1/P2 intent |
| 6 | `references/ganthritor-warpblade/apps/warpblade-app/` live source (this session) | OBSERVED-LIVE re-verify | `transport_bar.dart:3-99`, `timeline_strip.dart:4-541`, `preview_host.dart:3-178`, `take_tiles.dart:12-741`, `proposal_panel.dart:4-466`, `assurance_panel.dart:5-778`, `generation_drawer.dart:5-552`, `banners.dart:4-155`, `keyboard_shortcuts.dart:4-85`, `startup_error_page.dart:3-64`, `project_panel.dart:4-181`, `media_panel.dart:4-144`, `bridge_adapter.dart:1-33`, `rational_time.dart:3-79`, `timeline_intents.dart:5-161`, `media_error_mapper.dart:3-65`, `main.dart:23-1449`, `pubspec.yaml:9-16` |
| 7 | Live Prism source (this session) | OBSERVED-LIVE | `ds_state_surface.dart:31,294-315`, `ds_provenance_pill.dart:8,130`, `ds_command_palette.dart:12,28,82,918`, `time_machine_scrubber/ds_time_machine_scrubber.dart:146,181,214,687,797`, `ds_timeline.dart:9,69`, `ds_lane_board.dart:16,262,270`, `warp_prism_interaction/lib/src/{input,inspection,query,selection,state_machine}`, `warp_prism_runtime/lib/src/{async_command,event_stream,graph_source,health_source}`, `warp_prism_bindings/lib/src/{async_command_binding,event_stream_binding,graph_source_binding,health_source_binding}` |
| 8 | `.project/architecture/layer-contracts.md` §§1–10 | enforcement reference | dependency direction, Global MUSTs/MUST-NOTs, leakage/bypass/model-separation, lifecycle, 16 harness checks |

**Revision honesty:** Warpblade clone revision state UNKNOWN (no VCS operation per workspace law); citations use `path:line` from live reads above. File sizes re-verified this session (`main.dart` 1449 lines, `timeline_strip.dart` 541, `take_tiles.dart` 741, `assurance_panel.dart` 778, `generation_drawer.dart` 553). Prism negative sweeps from macro-review §2.2 (no transport organism, no meter/fader/waveform, no command-intent module) re-confirmed by directory listing this session. Nothing here is a PASS — no build/test/host run was performed in this pass.

## 2. Warpblade reality in one paragraph

Warpblade (`pubspec.yaml:9-16`: Flutter + `flutter_rust_bridge 2.13.0` + local `rust_lib_warpblade`, **zero Prism adoption**) is a clean inbound consumer with 18 UI/helper units + 1 non-UI bridge row. Its workspace is a **single vertically-scrolling column** (`main.dart:1292-1305`, `:1308-1443`) with ~30 mutable fields and ~60 `setState` sites — no multi-pane shell, no zone layout, no state-management library. It already made three architecturally correct decisions Prism should absorb rather than re-litigate: (a) `formatTime` injected as `String Function(double)` (`transport_bar.dart:5-13`), (b) timeline arithmetic extracted out of the widget (`timeline_intents.dart:5-8`, consumed at `timeline_strip.dart:470-478`), (c) verdict pass-through with fail-closed unknown (`take_tiles.dart:5-11`, `:29-63`). It declares its own gaps in source (`WP-GAP-001` at `preview_host.dart:3-9`; `WP-GAP-ASSURANCE-01/02/03` at `take_tiles.dart:68-71,141-152` and `assurance_panel.dart:8-9`). Its strongest runtime-contract shape is the injected `AssuranceLoader`/`AssuranceRepairer` typedef pair (`assurance_panel.dart:21-23,72-110`) — explicitly "so a widget test can drive every documented state without a live native library". Its characteristic defect is duplicated inline error blocks (`generation_drawer.dart:356-372`, `take_tiles.dart:250-268`, `assurance_panel.dart:228-246`) plus a null-callback-as-capability idiom in three places (`project_panel.dart:124-177`, `take_tiles.dart:568-584`, `assurance_panel.dart:292-297`).

## 3. Upgrade ordering principle

Ordered by **Warpblade impact first** (what unlocks Warpblade convergence fastest), with recurrence as priority signal, correctness stakes as tiebreaker, and risk last. This deliberately re-orders macro-review P0/P1 into a Warpblade-first wave: anything Warpblade exercises **today in production source** outranks anything Warpblade only needs on its roadmap. No proposal is gated on recurrence. No proposal invents a blocker. Domain math/engines stay local in every item — Prism absorbs chrome + verbs + semantics, never rational arithmetic, NLE models, GPU lifecycle, or generation routing.

---

## 4. Proposed Prism upgrades, ordered by impact

### U1 — Capability-gated action semantics + `PrismActionGate` (IDS + molecule) — HIGHEST IMPACT

**Warpblade pain today:** unavailable actions are signalled by nulling callbacks and rendered disabled in three independent sites (`project_panel.dart:124-177` six-button Wrap with `onSaveProject == null` disable; `take_tiles.dart:568-584` Audition/Compare/Promote/Regenerate/Assess gated; `assurance_panel.dart:292-297` repair disabled-not-hidden). There is no vocabulary for *why* — no reason string, no terminal-vs-transient distinction, no unknown. The `AssurancePanel` unreachability finding (inventory §D: `main.dart:1363-1375` passes neither `onAssess` nor `onRepairRequest`, so Assess buttons are currently dead in the real app) is a direct consequence: without a first-class availability model, dead gating is invisible.

**Prism gap (live):** `DSOperationalState` (`tokens/ds_operational_state.dart:18,30-34`) is binary `approved/rejected` + `archived`; `AsyncCommandStatus` (`async_command_models.dart:7-22` per sentry report) is `idle/running/succeeded/failed/cancelled` with no unknown, no attempt fold, no remainder. No enabled-with-reason vocabulary anywhere. Confirmed live this session by macro-review §2.2 + §C11.

**Proposal (ambitious):**
- IDS (pure Dart, no Flutter): `ActionAvailability` / `CapabilityState` semantics — `available | unavailable(reason) | terminalForDispatch(reason) | unknown`. Reason is a first-class opaque string, never an enum Prism owns. Terminality reuses Warpblade's own `isTerminalMediaError` invariant (`media_error_mapper.dart:51-65`: decode/seek = transient, everything else terminal) as the reference shape, not copied logic.
- Molecule `PrismActionGate`: renders the **disabled-with-reason, never silently hidden** rule (all three Warpblade sites independently converged on this) + the terminal-for-dispatch rule. Takes `availability + reason + child action`. Accessibility: disabled semantics carry the reason, not just the state.
- Extend `DSOperationalState` only where authority vocabulary genuinely generalizes (allow/constrain/deny as outcome, not as Sentry's decision model).

**Why first:** four independent re-inventions (Warpblade + Command-center `_GatedAction` + Tempest `onPressed: null` + Sentry W8/W9); pure semantics; zero data plane; prevents the trust defect of a hidden action masquerading as not-applicable. Unblocks U5 (decision-review action bar), U8 (job cancel), U10 (project panel convergence).

**Evidence gates:** IDS purity (pure Dart); conformance denied≠hidden≠enabled + reason propagation; a11y disabled-with-reason; host proof in Warpblade `ProjectPanel` + `TakeTile` action rows. **Risk:** medium (IDS extension needs its own review — macro-review UNKNOWN-12 applies but is not a blocker).

### U2 — `PrismTransportBar` organism + injected timecode formatter (organism + AV value contract) — HIGHEST VISIBLE WIN

**Warpblade pain today:** `TransportBar` (`transport_bar.dart:3-99`) is 100 lines of hand-rolled container: hard-coded `0xFF181B20`/`0xFF262A35` chrome, play/pause + ±0.25s step + `Slider` + monospace readout. Correct decision trapped inside local chrome: `formatTime` injected (`:5-13`), `semanticFormatterCallback: formatTime`. `TimelineStrip` header duplicates timebase badge + `PLAYHEAD: … / …` readout + undo/redo + Split/RippleDelete (`timeline_strip.dart:72-184`).

**Prism gap (live):** no transport organism. Only private `_TransportButton` (`ds_time_machine_scrubber.dart:797`) + `_buildTransportRow` (`:687`) + `showTransport` flag (`:181,214`) inside the time-machine scrubber. No mono readout, no step cluster, no formatter contract anywhere (`formatTime`/`formatRange` have no Prism home).

**Proposal (ambitious):**
- Organism `PrismTransportBar`: icon-button group + scrub slider + mono time badge. Time enters as opaque `double seconds` + injected `String Function(double) formatTime` + injected `String Function(double,double)` range formatter (Warpblade's `rational_time.dart:9-14,73-79` shape, not its BigInt math — exact arithmetic stays in Warpblade per §4.5). Step sizes, labels, and trailing slots caller-supplied so Tempest's record/loop/metronome never enters Prism vocabulary.
- Atom/molecule `PrismTimecodeBadge` (mono readout) + `PrismTimebaseBadge` (fractional `30000/1001` display, from `timeline_strip.dart:89-103` `FPSBadge`) as shared chrome for transport + ruler + take tiles.
- Do NOT build stop-button, BPM, or metronome into the organism — slots only.

**Why second:** Warpblade exercises it on every frame of every session; Tempest `StudioTransportBar` (`7-414`) is the second consumer so host proof is available in both; the injected-formatter seam is already proven in consumer source. Smallest code, largest convergence surface.

**Evidence gates:** fake transport model + conformance (step sizes, disabled semantics, formatter injection, keyboard/a11y labels); determinism (no animation-dependent capture); host proof Warpblade + Tempest studio route. **Risk:** low.

### U3 — Multitrack timeline chrome + IDS `TimelineIntent` verbs (organism + IDS) — LARGEST ARCHITECTURAL PRIZE

**Warpblade pain today:** `TimelineStrip` (`timeline_strip.dart:4-541`) is a 541-line read-only projection: ruler (tap+drag seek, 1s ticks, `_TimelineRulerPainter` `:481-541`), 100px track-header gutter, 52px `V{n}`/`A{n}` lanes (`:291-367`), clips by rational start with 48px minimum hit target (`:369-450`), 2px playhead needle (`:452-468`). `pixelsPerSecond` is constructor-only (`:30`) — **no zoom UI**. Explicit empty state (`:186-207`). Seek correctness already delegated (`_handleRulerSeek` → `TimelineIntentResolver.seekAtPixel`, `:470-478`).

**Prism gap (live):** `DSTimeline` is a log list (`ds_timeline.dart:9,69`), `DSLaneBoard` is a kanban board (`ds_lane_board.dart:16,262,270`) — neither is a multitrack lane and neither may be conflated with one. No ruler, no clip geometry, no playhead needle, no zoom. IDS has **no timeline module** (`input, inspection, query, selection, state_machine` only).

**Proposal (ambitious — chrome + verbs, never ontology):**
- Organism `PrismMultitrackTimeline` composed of molecule `PrismTimeRuler` + molecule `PrismTrackLane` + atom playhead needle + `TimelineClipWidget` geometry (position/width from caller-supplied seconds, 48px minimum hit target preserved as invariant). All time enters as opaque caller-supplied `double` + injected timebase descriptor; **no `MediaTimeDto`, no bars/beats, no SMPTE in Prism core** (domain leakage rule).
- IDS `TimelineIntent` verbs (pure Dart): `seekAtPixel / splitAtPlayhead / rippleDeleteSelected / nudgePlayhead / quantizeSliderValue` over the injected time model — Warpblade's `timeline_intents.dart:5-161` is the reference shape (static, testable, widget-free). Rational BigInt/GCD math (`rational_time.dart:35-70`) stays in Warpblade; Prism owns the verb signatures + edge semantics (strictly-inside for split, null-when-no-target).
- Private painters (`_TimelineRulerPainter`, `_LaneGridPainter`, `_RegionWaveformPainter`) are NOT absorbed — lane geometry is, grid/waveform painting is not.

**Why third:** this is the highest-coupling cluster in the corpus and the one Warpblade proves is separable (semantics already live outside the widget — the exact IDS shape Prism is missing). Two-ontology conformance (seconds AND bars/beats fake models must both pass) makes the seam honest.

**Evidence gates:** two-ontology conformance requirement; exact pixel↔time determinism (golden at fixed `pixelsPerSecond`); IDS purity; host proof Warpblade first (weaker layout = harder test: single scrolling column, no zoom), Tempest second. **Risk:** high — sequence U1 (availability for Split/Delete enablement) and U2 (formatter) before this.

### U4 — Honest-unknown + reasoned abstention in state vocabulary (molecule + token + IDS) — HIGHEST CORRECTNESS STAKES

**Warpblade pain today:** three duplicated inline error blocks with no shared vocabulary (`generation_drawer.dart:356-372`, `take_tiles.dart:250-268`, `assurance_panel.dart:228-246`); `ExportProgressBanner` indeterminate spinner (`banners.dart:53-93`) vs `ExportReportBanner` terminal receipt (`:95-155`) with no lifecycle linking them; `WarpbladeStartupErrorPage` (`startup_error_page.dart:3-64`) as a one-off fail-closed surface.

**Prism gap (live):** `DSStateType` (`ds_state_surface.dart:294-315`) = `empty/loading/error/disabled/stale/degraded/excluded` — **no honest-unknown member**. `DSMessageStatusHistory` step state likewise lacks `unknown` (sentry report `:10-22`). Re-verified live this session. Sentry W6/W7 call this their #1 finding; Warpblade's `VerdictStyle.of` default-fallthrough (`take_tiles.dart:29-63`: unknown → neutral `UNASSESSED`, "cannot be painted as a pass") is the same invariant in miniature.

**Proposal (ambitious):**
- Extend `DSStateType` + IDS inspection/query states with `unknown` (system does not know — distinct from empty/error/disabled) and `abstained/notAttempted` (system declined to attempt — distinct from failure). **Fail-closed rendering rule:** unknown never degrades to empty, success, verified, or enabled styling — in semantics label AND visual tone.
- Consolidate Warpblade's three inline error blocks into `DSStateSurface` modes (convergence, not construction); add molecule `PrismJobBanner` for staged long-running work with cancel + deterministic terminal receipt slot (Warpblade prints `DEST/FRAMES/BYTES/SHA256` — receipt *shape* is caller's, banner chrome is Prism's).
- `PrismStartupFailureView` molecule extending `DSFallbackView`/`DSErrorBoundary` for fail-closed bootstrap (Warpblade `startup_error_page.dart` + Command-center `DaemonNotConnected` = second consumer).

**Why fourth:** latent trust defect in every consumer (unknown rendered as success/disabled is worse than a missing widget). Low-medium risk, unblocked, and prerequisite to U5/U6 pass-through discipline.

**Evidence gates:** fail-closed conformance (unknown ≠ empty ≠ success ≠ disabled in label + style); determinism (indeterminate progress excluded from goldens); a11y state announcements; host proof Warpblade banners + startup page. **Risk:** low-medium.

### U5 — `PrismDecisionReviewSurface` organism (review-before-commit) — WARPBLADE'S SIGNATURE SURFACE

**Warpblade pain today:** `ProposalPanel` (`proposal_panel.dart:4-466`: status badge pending→`PENDING REVIEW`, expired banner `:94-117`, preserve-range override `:311-327`, constraints list `:338-377`, diff `CLIPS/DUR + opSummaries` `:379-466`) + `AssurancePanel` (`assurance_panel.dart:5-778`: `_StatusRow`, `_GateRibbon` of `VerdictBadge` with rationale tooltips, `_ObservationList` with method/blind flag/exact `observedAtNum/Den`/fingerprint/digest, `_FindingList` three-valued pass/fail/neutral) + `RepairDialog` (`:617-778`: corrective instruction + params-JSON override + `maxRetries` validation, "authored correction, never claimed outcome") are three hand-built instances of one missing composition: **status header + evidence list + computed diff + constraint list + bounded-override actions + accept/reject**.

**Prism gap (live):** every part exists (`DSDetailInspector` `:10` + `DSDetailSection` `:194` + `DSPropertyRow` `:210`, `DSEvidenceRow`, `DSAssetCard`, `MasterDetailTemplate` `:27-266`) but the review/decision framing does not. No accept/reject-with-override composition.

**Proposal (ambitious):**
- Organism `PrismDecisionReviewSurface` composing inspector sections + evidence rows + **caller-supplied diff region** + **caller-supplied action bar** (gated by U1). Verdict/status values pass through **verbatim from data** — Warpblade's own rule (`take_tiles.dart:5-11`: unknown verdicts fall through to neutral) becomes a Prism-worthy invariant: an unknown/absent verdict can never render as accepted/pass.
- Absorb `RepairDialog` as bounded-repair molecule (instruction + params-override + bounded retries + validation); domain content (proposal diff computation, assurance registry, session grouping) stays in consumer.

**Why fifth:** Warpblade built it twice independently (proposal + assurance); Tempest `CommandBarDialog` (NL→plan→confirm) and `PromptEnhancerDialog` (side-by-side diff) plus Command-center `ControlPanel` with `_GatedAction` are the recurrence signal. Depends on U1 (gating) + U4 (unknown handling) — sequence accordingly.

**Evidence gates:** pass-through integrity conformance (unknown verdict ≠ pass); tooltip-reason on every verdict; host proof ≥2 hosts (Warpblade proposal + assurance counts as two surfaces in one host, plus one external host). **Risk:** medium (composition breadth).

### U6 — Provenance family: `PrismProvenanceBadge` + `PrismWitnessBadge` + sealed rendering mode (atoms + presentation rule)

**Warpblade pain today:** observation list carries fingerprint + input digest + exact `observedAtNum/Den` (`assurance_panel.dart:411-506`); `_ProvenanceStrip` shows seed/fingerprint/params/lineage `SAME|DIFFER` (`take_tiles.dart:141-152,653-741`); `ExportReportBanner` prints SHA-256 receipt (`banners.dart:95-155`). Three distinct facts with one rendering path.

**Prism gap (live):** `DSProvenancePill` (`ds_provenance_pill.dart:8`, `:9-41`, `:110-127`) is **canonicity only**; no hash, no verification state, no sealed mode, no tamper evidence. Confirmed by reading the pill + macro-review §2.2.

**Proposal (ambitious):**
- Atom `PrismProvenanceBadge` (canonicity — existing pill renamed/extended) + atom `PrismWitnessBadge` (hash token + verification state `verified/unverified/mismatched/unknown`; hash string opaque, **no hashing logic in Prism**) + **sealed rendering-mode contract** (presentation-level rule: sealed artifact renders zero interactive affordances — absent, not disabled).
- Fail-closed twin of U4: unverified/unknown/mismatched never renders as verified.

**Why sixth:** three consumers carry at least one of these (Warpblade digest/fingerprint/SHA-256, Command-center causation view, Sentry hash witness); highest correctness stakes per line of code; presentation-only risk. Unblocks sealed decision surfaces (Sentry W2, Tempest version DAG later).

**Evidence gates:** unverified-never-verified conformance; sealed = absence-of-affordance test; host proof Warpblade `_ProvenanceStrip` + `ExportReportBanner`. **Risk:** low.

### U7 — Command registry + shortcut index + dispatch router (IDS + palette extension + molecule)

**Warpblade pain today:** `WarpbladeKeyboardRouter` (`keyboard_shortcuts.dart:4-85`) is a correct guard-aware dispatcher (Ctrl/Cmd+Z, Shift+Z/Ctrl+Y redo, Space/←/→/S/P/G/Delete) with the edit-focus guard done right (`FocusManager.instance.primaryFocus?.context?.widget is EditableText`, `:62-64`; modifier via `HardwareKeyboard.instance`, `:45-47`) — but the binding set is product-local and there is no registry, no collision/precedence record, no enumeration surface.

**Prism gap (live):** `DSCommand` (`ds_command_palette.dart:28`: `id/label/description/icon/category/onExecute/route/shortcut`) has a shortcut *hint* but no registry, no applicability/enabled-reason, no shortcut index. `warp_prism_interaction/lib/src/` has **no command-intent module** — command intent is the IDS responsibility named in `MISSION.md:32` and it is currently unowned.

**Proposal (ambitious):**
- IDS `CommandIntent` registry (pure Dart): command identity, label, shortcut chord, applicability predicate, enabled/disabled reason, enumeration surface. Chord collision/precedence + enumeration stability as conformance.
- Presentation stays `DSCommandPalette` + `DSToolStripSlideout`; dispatch router as molecule with the edit-focus guard (guard is presentation — belongs to the router widget, NOT to IDS; eligibility predicate belongs to IDS).
- Tempest's declared `FloatingContextCommandBar` becomes the anchored variant once the registry lands.

**Why seventh:** Warpblade + Command-center (`_GatedAction` invocation) + Tempest (`CommandBarDialog`, declared `FloatingContextCommandBar`/`DawToolPalette`) + Sentry W8/W9 authority dispositions all need it; but IDS is `PROVEN`-labelled so the extension needs its own review — sequence after U1 proves the IDS-extension path.

**Evidence gates:** IDS purity; chord collision/precedence + disabled-reason propagation + enumeration stability; keyboard-only a11y path; host proof Warpblade router + one palette host. **Risk:** medium.

### U8 — Runtime contract wave: `AsyncCommand` executor + terminality + stream ownership (runtime + bindings + testkit)

**Warpblade pain today (the deepest runtime finding):** `WarpbladeBridge` (`bridge_adapter.dart:1-33`) is import-boundary discipline only — ten FRB module re-exports + `init()`. There is **no Dart-side `AsyncCommand`/`EventStream` abstraction**: commands are top-level FRB functions invoked from ~60 `setState` sites, streams consumed as raw `StreamSubscription` fields (`main.dart:85-86`). Generation (`GenerationDrawer`: `onGenerate`, `isGenerating`, `generationError`) and export (`ExportProgressBanner`/`ExportReportBanner`) are concurrent-job workloads forced through single-flight UI state.

**Prism gap (live):** `AsyncCommand` contract is single-flight cancel-and-replace (contract doc, this session) with only two implementations (testkit fake + FRB adapter) and **no production construction site for `AsyncCommandBinding`**; `EventStream`/`HealthSource`/`GraphSource` exist with fakes + suites but no Warpblade consumer proof.

**Proposal (ambitious — the one runtime bet in this plan):**
- (a) New runtime abstraction `AsyncJobExecutor` (or equivalent per-execution-handle concept — name owned by runtime architect): per-execution identity + state for genuine concurrent-job workloads (generation + export), leaving single-flight `AsyncCommand` untouched. Warpblade is the motivating consumer: generation queue + export render are concurrent, cancellable, receipt-bearing jobs, not one logical command.
- (b) Standardize terminality + refusal disclosure as runtime-adjacent semantics: `isTerminalMediaError` (`media_error_mapper.dart:51-65`) + `pathRefusalPrefix` const contract (`:3-8`, Rust builds via `format!("path refused [{}]: {error}")`) preserved **verbatim** as the cross-boundary invariant if absorbed — refusal checked before variant label (`:43-47`) so policy refusal never renders as plain "Invalid".
- (c) Bind Warpblade's raw subscriptions to `EventStream` (timeline + export streams) and bridge readiness to `HealthSource` (replacing the `FRB v2.13 ACTIVE` badge + `Ping`/`Toggle Res`/`Dispose` QA strip in `diagnostics_panel.dart:35-67` with a real health projection); prove `GraphSource` later via take-lineage (U9), not here.
- (d) Absorb the injected `AssuranceLoader`/`AssuranceRepairer` typedef shape (`assurance_panel.dart:21-23`) as the testkit pattern for every Warpblade-backed contract: bridge default + injectable fake so widget tests drive error/empty/populated without a live native library.

**Why eighth:** unblocks Warpblade's two heaviest async surfaces (generation + export) and converts its best-tested seam into Prism law. Sequenced after U1/U4 because availability + terminality + unknown are inputs to executor semantics.

**Evidence gates:** same-suite-for-fake-and-adapter (Global MUST 2–3); per-execution identity conformance; refusal-prefix verbatim test; `HealthSource` snapshot test driving the readiness badge. **Risk:** medium-high (new runtime surface — needs runtime-architect review, not just ADS review).

### U9 — Take audition matrix + generation drawer disclosure (compositions over existing primitives)

**Warpblade pain today:** `TakeTilesPanel` (`take_tiles.dart:139-591`) is a vertical list (NOT a grid — `.map` into `Column`, `:275-313`), no thumbnails, movie icon + truncated id + `AUDITIONING` badge + `VerdictBadge` + text `_ProvenanceStrip`; actions null-gated (`:568-584`); `Regenerate` mints child Take with lineage (`:324-436`); `_CompareStrip` is DTO-field `SAME|DIFFER`, "no pixel diff invented" (`:653-741`). `GenerationDrawer` (`generation_drawer.dart:5-552`) is 3-level progressive disclosure (intent rows → descriptor-generated controls iterating `cap.declaredParams` skipping `prompt`, `:408-432` → provider mechanics behind expansion with `Model: Auto` + no-execution route preview `:130-132,507-531`) with `uint` coercion + `FormatException` (`:81-134`).

**Prism gap:** `DSVirtualGrid` + `DSLaneBoard` + `DSAccordion` + `DSSelect` all exist — no new table/grid/board/form primitive is justified (macro-review C9 REUSE-primary).

**Proposal (ambitious composition, not construction):**
- Audition/compare matrix as documented composition over `DSVirtualGrid` + `DSLaneBoard` + U1 gate + U5 verdict discipline + U6 lineage strip (`PrismLineageStrip` molecule for `SAME|DIFFER`/derived-from — textual, NOT a graph).
- Descriptor-driven disclosure as `DSAccordion` + `DSSelect` extension pattern (caller-supplied descriptor → generated controls), with route-preview slot. Single-consumer today — ship as EXPERIMENTAL composition guidance + one conformance suite, promote when a second descriptor host appears.
- Do NOT build thumbnails, drag-reorder, or zoom — Warpblade explicitly lacks all three (inventory §§5,10 corrected claims).

**Why ninth:** real Warpblade surfaces, but single-consumer and correctly served by composition + prior upgrades. Depends on U1/U4/U5/U6.

**Evidence gates:** verdict pass-through (U5) + availability (U1) + witness (U6) conformance inherited; matrix keyboard/a11y order; host proof Warpblade takes route. **Risk:** low (composition).

### U10 — Project/media panel convergence + loading-chrome consolidation (REUSE + EXTEND)

**Warpblade pain today:** `ProjectPanel` (`project_panel.dart:4-181`) is a lifecycle/action panel (header `PROJECT: <name>` + amber dirty `*` + truncated `DIGEST:` chip; monospace `.wbproj` path field; six-button Wrap: New/Import/Place/Save/Load/Export + `Quick Setup DoD` chip) — explicitly "not a settings form". `MediaPanel` (`media_panel.dart:4-144`) is a single-path control (monospace path field + `Open` + three hard-coded test chips + probe-metadata block with exact `num/den`). Both built from raw Material 3 with zero Prism tokens.

**Prism gap:** none structural — `DSButton`, `DSTextField`, `DSPropertyRow`, `DSMetricTile`, `DSStateSurface` cover the chrome. Command-center `LoadingPane`/`LoadingRow`/`StateRegion` (GOLD) + Warpblade's three inline error blocks are the consolidation target.

**Proposal:**
- Converge both panels onto Prism atoms/molecules + U1 gates + U4 states (no new primitive). Probe-metadata strip → `DSPropertyRow` + mono labelled-field pattern (generic); AV probe semantics stay local.
- Consolidate loading chrome into `DSStateSurface` modes (Command-center GOLD rationale: non-animated, `loading.dart:3-11`) — Warpblade's duplicated blocks are the second converging host.

**Why tenth:** convergence, not construction — lowest novelty, but retires the most duplicated code and proves REUSE claims with host evidence (macro-review UNKNOWN-4: every REUSE claim is catalog-grade until a host run proves it).

**Evidence gates:** host-composition proof that existing organisms compose in Warpblade without wrapper-supplied ancestors (the weakest-evidence area of the corpus); no new-primitive test. **Risk:** low.

### U11 — `PrismSurfaceHost` data-plane host + preview HUD/placeholder (data-plane decision done right)

**Warpblade pain today:** `TexturedPreviewHost` (`preview_host.dart:3-178`): `WP-GAP-001` self-declared upstream intent; pure presentation host (only import is `material.dart`, `:1`); `AspectRatio` → decorated `Container` → `Stack`; live branch (`Texture(textureId) + HUD `FLTEXTURE_GL ID • WxH • FRAME #`` `:47-84`) vs placeholder branch (`CustomPaint` 40px grid + crosshair, `shouldRepaint false`, `:150-178` + `WP-GAP-001` label + `statusMessage`). Texture lifecycle owned by `main.dart`, spike path (`NativeSurfaceController` create/resize/getInfo/destroy) explicitly not a harvest source. Warpblade's "Zero-Dart-Copy" is a spike assertion (`spike_app/main.dart:479`), NOT product evidence (inventory §19).

**Prism gap:** zero — and that is correct under MISSION §7. No texture/GPU/native-surface primitive may enter ADS without declared transfer + ownership semantics, and a data plane MUST NOT be modeled as an event stream.

**Proposal (ambitious but gated — the only item with a hard precondition, and the precondition is stated in governing law, not invented):**
- Atom/organism-edge `PrismSurfaceHost`: aspect-ratio-locked native-texture host + placeholder canvas + HUD badge slot. Ships **only with** a written transfer/ownership declaration (who allocates/destroys the texture, which thread pushes frames, what `frameCount>0` means, resize/dispose lifecycle) satisfying Global MUST 5 + §8. Until that declaration exists, Warpblade keeps its provisional host (consumer-never-blocked rule, MISSION §3).
- HUD badge composes `DSStatusDot` + `DSBadge`; placeholder branch extends `DSStateSurface` empty mode specialized to 16:9/9:16 monitor (the `ViewportPlaceholder` from ads-debt §3.3).
- No zero-copy claim enters Prism without measured product evidence.

**Why eleventh:** highest gate burden by law (data plane), single consumer, spike-adjacent. Ranked last not because it is unimportant (it is Warpblade's most visible viewport) but because U1–U10 all ship without answering the ownership question, and the law — not this plan — sets that gate.

**Evidence gates:** transfer/ownership declaration reviewed by runtime architect; `Texture` host proof on real Linux host (Broadway headless per Warpblade AGENTS.md §14.4 is genuine host evidence for frame assertions; on-screen presentation scope stated separately if demanded); placeholder determinism (fixed grid golden — `shouldRepaint false` makes this cheap). **Risk:** medium (data-plane adjacency) with the highest blast radius if done wrong.

---

## 5. What is deliberately NOT proposed

- **No `warp_prism_av` package in this wave.** The ads-debt matrix targets `warp_prism_av` for ~20 Warpblade surfaces. That boundary needs a crate-boundary justification (independent reuse, dependency/feature isolation, independent lifecycle — `AGENTS.md` §5) that single-consumer Warpblade evidence does not yet supply. Build U1–U11 inside existing owners (`warp_prism_ui` / `warp_prism_interaction` / `warp_prism_runtime` / `warp_prism_bindings` / `warp_prism_testkit`); split the package when the second AV consumer's import graph forces it, not before.
- **No transport ontology, no rational-time type, no NLE model in Prism.** `MediaTimeDto` BigInt/GCD arithmetic, timebase quantization, clip containment, source-time mapping, generation routing math, proposal diff computation, GPU lifecycle, project lifecycle — all stay product-local per §4.5 and the bidirectional leakage rule. Prism owns chrome + verbs + semantics with injected models.
- **No meter/fader/waveform/spectrogram/goniometer work in this wave.** Negative sweep confirmed zero Warpblade metering demand (macro-review C2: "not applicable"); Tempest owns that cluster. Warpblade must not be counted as recurrence for audio calibration.
- **No workbench/shell-router work for Warpblade.** Warpblade is negative evidence for multi-pane layout (single scrolling column, no resize/reorder — `main.dart:1303-1305`). Shell slot state machine + `PrismStartupFailureView` multi-pane proof belong to Command-center/Tempest hosts, not this wave (U4 takes only the startup-failure molecule).
- **No donor-driven primitives.** FigCraft/Everything mechanisms remain Held (macro-review §8) — no consumer demand, no candidacy under §3.1/§10.
- **No `AssurancePanel` reachability fix in Prism.** The dead-Assess finding (`main.dart:1363-1375` + `take_tiles.dart:568-584`) is Warpblade-owner product scope, raised in inventory §C — Prism's U1/U5 make the dead gate visible, they do not fix Warpblade wiring.

## 6. Dependency order (the wave)

```text
U1 (availability gate) + U4 (unknown/abstention) + U2 (transport + formatter)
  → U6 (provenance/witness/sealed) + U7 (command registry)
    → U5 (decision-review) + U3 (timeline chrome + verbs)
      → U8 (executor + terminality + streams/health)
        → U9 (matrix + drawer compositions) + U10 (panel convergence)
          → U11 (surface host, after ownership declaration)
```

Sibling-safe parallelism (no shared writesets): U1 ∥ U2 ∥ U4 can start together (IDS molecule, ADS organism, ADS molecule/token — distinct owners); U6 ∥ U7 next (atoms vs IDS+palette); U5 and U3 compose on U1/U4 outputs, not on each other. U8 needs runtime-architect review independent of ADS lanes.

## 7. Per-upgrade barrel/lifecycle note

Per `layer-contracts.md` §9 (as reconciled 2026-10-19): mandate coverage + recorded macro-review decision admits PROVEN (fake + suite PASS required); STABLE additionally requires boundary clearance + host proof + independent review + API freeze. Every U-item above enters EXPERIMENTAL (spec + fake + suite, no barrel export) and advances only through those gates. No "must be core to be tested" circularity. Boundary harness (`boundary_test.dart` 16 checks + per-package purity tests) gains a check per new contract in the same task that adds it.

## 8. Unknowns carried (not resolved, not blocking)

- Consumer revision states UNKNOWN (no VCS operation in this workspace) — citations are `path:line` live reads, not SHAs.
- No execution in this pass — every "covers"/"gap" claim is a static-read claim; host-composition proof (macro-review UNKNOWN-4) remains the program's largest single evidence debt and is gated into every U-item above rather than assumed.
- Warpblade `AssurancePanel` unreachable in the real app (inventory §D) — product-owner decision, surfaced, not owned here.
- IDS scope question (macro-review UNKNOWN-12: can IDS absorb availability + timeline verbs + command registry and remain "not a state-management framework") — owned by the architecture owner at U1/U3/U7 review time, recorded here as review input, not as a blocker.
- Three documents still state recurrence as law (`layer-contracts.md` §9 PROVEN row already reconciled 2026-10-19; `docs/bridge/README.md` harvest loop + `docs/design/token-theme-catalog-policy.md` promotion gates per `MISSION.md:369-373`) — reconciliation owed through task governance; until then MISSION wins on conflict.

## 9. Handoff

Next owner: Warp Prism architecture/task-governance lane. Recommended materialization: one Task per U-item (U3 split into chrome + verbs; U8 split into executor vs stream/health binding), each ≥50 lines per `000-template.md`, with `Where` tables citing the `path:line` evidence above, explicit validation commands, and the evidence gates in §4 as exit conditions. Nothing here authorizes implementation — promotion readiness (`AGENTS.md` §3.1) is judged per Task at `00-planning → 01-open`.
