---
type: report
title: "Cross-Consumer Gap Matrix"
date: 2026-09-27
status: pending-independent-acceptance
scope: warp-prism epoch reset
---

# Cross-Consumer Gap Matrix

> **Evidence base**: 7 parallel read-only inventory passes over current source
> (Warp Prism ADS; Warp Prism IDS/runtime/bindings/FRB/Rust; Warpblade; Tempest;
> Sentry; Hyperion; historical/project-state reconciliation).
> **Status**: `accepted-with-amendments-applied-2026-09-27` — independent review
> returned AMEND (88/100); findings F1–F6/F8–F9 remediated in corpus (see reset
> report); F7 folded into Task 1841. Light verification pass pending.
> **Post-acceptance update 2026-10-11 (rem-0004)**: the 2026-09-27 `date:` above
> is preserved as the original evidence date — it is not altered by later
> verification. Two UNKNOWN rows carried since 2026-09-27 are now resolved
> (Tempest→Prism imports = zero; Sentry surface = none, Rust-only), each with
> method and date recorded in §2 and §6. The 2026-10-10 resolutions do not
> revoke the historical AMEND record or its acceptances.
> **Rule applied**: recurrence before crystallization. A component is not a
> candidate because it exists.

---

## 1. Warp Prism Current Capability Baseline

Source-verified, not planned:

| Area | Reality |
|---|---|
| ADS | `warp_prism_ui` — 296 `Prism*` barrel symbols, tokens + 3 opt-in skins, `PrismTokenRegistry`, M3 factory, 13 golden suites + atom goldens, in-package gallery (26 sections), `MasterDetailTemplate`. Flutter-only deps. |
| IDS | `warp_prism_interaction` — selection, query, inspection, input normalization, interaction state machine. Barrel-labeled `PROVEN`. Pure Dart. |
| Runtime | `warp_prism_runtime` — all 4 contracts exist as **CODE** (`AsyncCommand`, `EventStream`, `HealthSource`, `GraphSource`), all `EXPERIMENTAL`, presentation-purged. |
| Bindings | `warp_prism_bindings` — 4 thin projections; `Offset` owned at this edge. |
| Testkit | `warp_prism_testkit` — fake + conformance suite per contract. |
| FRB | `warp_prism_adapter_frb` — real FFI wiring, FRB 2.13.0, `.so`-gated. Only Dart package importing FRB. |
| Rust | `warp_bridge_core` (0 transport deps) vs `warp_bridge_frb` (FRB + tokio). Split proven by manifests + imports. |
| Proof labs | `apps/catalog` (gallery + connected bridge lab), `warp_prism_host_exercise` (smoke/crawl/fuzz). |
| Purity | ui / interaction / runtime free of FRB + runtime + bindings imports. Proven at grep time. |
| Consumers | **Zero.** No consumer depends on any `warp_prism_*` package. |

**The dominant fact**: Warp Prism has a complete, layered, purity-enforced
substrate and **no consumer adoption**. Every row below is therefore about
closing that distance, not about extending a substrate that is already thin.

---

## 2. Consumer Baseline

| Consumer | Reachable | UI | Rust/FRB | Warp Prism adoption | Bridge |
|---|---|---|---|---|---|
| **Warpblade** | yes | Flutter desktop, `setState` + `StreamSubscription` | active, 10 crates, facade-enforced | **none** (proven: no pubspec dep) | `ads-debt.md`, 35.6 KB |
| **Tempest** | yes (file content via harness deny) | Flutter desktop, Provider/ChangeNotifier | active, 5 crates + `tempest-bridge` | **none — UNKNOWN resolved 2026-10-10** *(prior value: "UNKNOWN (import scan denied)" — superseded, recorded in the note below)* | `ads-debt.md`, 37.8 KB |
| **Sentry** | top-level only | **none — Rust-only, no Flutter UI surface at all** *(prior value: "UNKNOWN" — superseded, recorded in the note below)* | Rust-workspace shaped (3 crates, no FRB) | none | **empty** (0 entries) |
| **Hyperion** | yes | none — no product code | none | none | **absent** (not fabricated) |

> **Resolved-UNKNOWN note (added 2026-10-11, rem-0004 — resolution evidence parent-verified 2026-10-10)**:
>
> - **Tempest row** — the "import scan denied" UNKNOWN is **CLOSED: Tempest declares zero Warp Prism adoption.** Verification method: parent-verified direct reads of `flutter/pubspec.yaml` and `flutter/pubspec.lock` plus a repo-wide `rg 'warp_prism'` sweep; matches appear only in the bridge doc itself (`docs/warp-prism/ads-debt.md`), never in a manifest or lockfile (`rg` exit = no match). Evidence carrier: `.project/reports/architects/future-capability-program-inventory-2026-10-10.md` §0.1.
> - **Sentry row** — the "UNKNOWN" UI surface is **CLOSED: Sentry has no Flutter UI or integration surface to audit.** Verification method: parent-verified structural read — no `pubspec.yaml` exists anywhere in the repo (Rust-only), 3 crates, no `flutter_rust_bridge` dependency, zero repo-wide `warp_prism` matches. Also note `docs/bridge/sentry/` is a symlink into `sentry/docs/warp-prism` and is confirmed empty (0 entries). Evidence carrier: same report §0.1/§2.
> - **Effect on this matrix**: no disposition changes. Both rows point the same way they did as UNKNOWNs (no adoption, nothing to harvest); §6's "Missing Proofs" rows are now answered rather than open. The per-capability `UNKNOWN` cells in §3's Sentry column are consistent with the resolved answer — they are UNKNOWN because no Sentry Flutter UI surface exists to inspect, not because an existing surface went unexamined. Historical rows are preserved in place, not deleted.

---

## 3. The Matrix

Legend — **M** exact match, **N** near match (extend), **D** duplicated locally,
**G** gap in Prism, **L** keep local.

| # | Capability | Prism today | Warpblade | Tempest | Sentry | Hyperion | Disp. | Rec. |
|---|---|---|---|---|---|---|---|---|
| 1 | Provider / service health display | `PrismProviderHealthMatrix`, `DSHealthCard` | `DiagnosticsPanel` (composes) | `ProviderConnectionCard` | UNKNOWN | needs-table | **N** (add keyring/quota/weight-asset) | 2 |
| 2 | Command-plan review before execution | `DSCommandPalette`, `DSToolCallCard`, `DSExecutionConsole` | `ProposalPanel` | `CommandBarDialog`, `ActionPlanReviewCard` | UNKNOWN | UNKNOWN | **N** → `CANDIDATE_UPSTREAM` | 2 |
| 3 | Prompt/response diff viewer | `DSExecutionConsole` (partial) | `ProposalDiffSummaryCard` | `PromptEnhancerDialog` diff viewer | UNKNOWN | UNKNOWN | **N** → `CANDIDATE_UPSTREAM` | 2 |
| 4 | Timecode / duration display | none | `TimecodeCounter` (mono `MM:SS.ss`) | `TimecodeCounter` (mono `MM:SS.cs`) | UNKNOWN | UNKNOWN | **G** → `CANDIDATE_UPSTREAM` | **2** |
| 5 | Hardware / GPU status badge | `DSHealthCard` (composable) | `DiagnosticsPanel` (partial) | `HardwareStatusIndicator` (GPU/PipeWire) | UNKNOWN | UNKNOWN | **N** → `CANDIDATE_UPSTREAM` | 2 |
| 6 | Persistent job / batch-progress banner | `DSToast`, `DSStateSurface` | `ExportProgressBanner`, `ExportReportBanner` (SHA-256 receipt) | `ProgressCard` (multi-stage + cancel) | UNKNOWN | UNKNOWN | **N** (toast ≠ persistent job) | **2** |
| 7 | App shell / sidebar / split pane | `DSShellResponsive`, `DSSplitPane`, `DSErrorBoundary` | `PrismEditorialWorkspace` (own layout) | `MainShellLayout` (NavigationRail, 7 areas) | UNKNOWN | needs-table | **D** risk — converge tokens, keep layout local | 2 |
| 8 | Native texture / media viewport host | **none** | `TexturedPreviewHost` (FFI `Texture`, aspect lock) | not applicable | UNKNOWN | UNKNOWN | **G** — data plane, needs transfer-semantics design | 1 |
| 9 | NLE timeline (ruler/lane/clip/playhead) | `DSTimeline` (log list), `DSTimeMachineScrubber` (histogram) | `TimelineStrip` family | `StudioTimelineLane`, `MusicalRuler` | UNKNOWN | UNKNOWN | **G** ×3 ontologies — do **not** unify; **L** | 1 per domain |
| 10 | Transport bar (play/step/scrub) | `DSSlider` composable | `TransportBar` | `StudioTransportBar` | UNKNOWN | UNKNOWN | **G** (shared shape) but time ontologies differ → **L** until proven | 2 shapes |
| 11 | Rational / exact time arithmetic | **none** | `rational_time.dart` (BigInt/GCD) | musical grid (bars/beats/ticks) | UNKNOWN | UNKNOWN | **G** — two incompatible models → **L** | 1 |
| 12 | Level / loudness metering (dB, LUFS, peak) | `DSMetricTile`, `DSSparkline` (linear) | not applicable | `AudioPeakMeterBar`, `LufsMeterBar` | UNKNOWN | UNKNOWN | **L** (broadcast-calibrated) | 1 |
| 13 | Faders / knobs / M-S-Arm controls | `DSSwitch`, `DSCheckbox` | not applicable | `DbFader`, `PanKnob`, `MuteSoloArm` | UNKNOWN | UNKNOWN | **L** (studio ergonomics) | 1 |
| 14 | Spectrogram / Lissajous painters | `DSGraphCanvas` (topology only) | not applicable | planned `AudioSpectrogramCanvas`, `StereoGoniometer` | UNKNOWN | UNKNOWN | **L** (data plane) | 1 |
| 15 | Track/channel strip composite | `DSAssetCard` | not applicable | `StudioTrackControls`, `StemMixerChannelStrip` | UNKNOWN | UNKNOWN | **L** | 1 |
| 16 | Master / FX chain rack | **none** | not applicable | `StudioFxRackDialog`, `MasteringFxPanel` | UNKNOWN | UNKNOWN | **L** | 1 |
| 17 | Model asset (VRAM/license/weight) card | **none** | not applicable | `ModelAssetCard` | UNKNOWN | UNKNOWN | **L** (domain) / **N** for a generic `ResourceAssetCard` | 1 |
| 18 | Version DAG / tree visualization | `DSGraphCanvas` + `GraphSource` | not applicable | `ProjectVersionDagTree` (planned) | UNKNOWN | UNKNOWN | **N** — real `GraphSource` consumer proof | 1 + 1 (docs) |
| 19 | Crash-recovery / fail-closed dialog | `DSErrorBoundary` | `WarpbladeStartupErrorPage` | not applicable | UNKNOWN | UNKNOWN | **N** → `CANDIDATE_UPSTREAM` (single-consumer: Warpblade only; stays local until a second consumer appears) | 1 |
| 20 | NLE interaction verbs (trim/slip/slide/split) | `PrismSelection` generic | `TimelineIntentResolver`, `EditorialCommandRegistry` (planned) | DAW tool modes, automation Touch/Latch/Write | UNKNOWN | UNKNOWN | **G** IDS — but semantics diverge per domain → document as gap, **L** by default | 1 |
| 21 | Anchored floating command bar | `DSToolStripSlideout` (composable) | not applicable | planned `FloatingContextCommandBar` | UNKNOWN | UNKNOWN | **N** (compose + one extension) | 1 |
| 22 | Generative-take audition/lineage grid | `DSVirtualGrid` (composable) | `TakeTilesPanel` | not applicable | UNKNOWN | UNKNOWN | **L** | 1 |
| 23 | Drag-drop with domain payload | `DSDraggableCard`, `DSDropTarget` | clip drag | `DropZoneCard` (metadata) | UNKNOWN | UNKNOWN | **M** — reuse | 2 |
| 24 | Progress + cancel over a long async job | `AsyncCommand` contract exists | `ExportProgressBanner` (stream) | `ProgressCard` (prepare→chunk→post) | UNKNOWN | UNKNOWN | **N** — consumer **proof** for the existing contract | 2 |
| 25 | Version DAG over a live journal | `GraphSource` + `EventStream` exist | not applicable | project journal (planned) | UNKNOWN | UNKNOWN | **N** — consumer **proof** | 1 |
| 26 | Quota / cost / token tracking | `HealthSource` (no cost axis) | not applicable | planned `ProviderQuotaUsageTracker` | UNKNOWN | UNKNOWN | **N** — extend `HealthSource` proposal | 1 |
| 27 | Bridge surface itself | `docs/bridge/{warpblade,tempest}/` | present | present | **absent (empty)** | **absent** | **G** — BRIDGE_CONTRACT_GAP | — |
| 28 | Consumer adoption of the substrate | 7 packages built, verified | 0 deps | 0 deps (~~UNKNOWN~~ **verified zero 2026-10-10**) | none | none | **G** — the real gap | 0 |

---

## 4. Strong Recurrence (≥2 consumers) — Harvest Now

Five candidates where **two independent consumers** want the same conceptual
capability (a sixth, fail-closed startup page, was demoted to single-consumer
watch on re-review — see its row). These are the only rows that satisfy the
promotion gate's recurrence clause today.

| Candidate | Consumers | What is actually shared | Stays local |
|---|---|---|---|
| **Timecode / duration display** | Warpblade + Tempest | Monospace tabular timecode, semantic formattable value, not a media pipeline | which time *ontology* (SMPTE vs musical) |
| **Persistent batch-job banner** | Warpblade + Tempest | long-running job, staged progress, cancel, deterministic terminal receipt, dismissible | what the job *is* |
| **Command-plan review card** | Warpblade + Tempest | propose → inspect → confirm/reject with provenance, before execution | the domain plan body |
| **Prompt/diff viewer** | Warpblade + Tempest | side-by-side before/after with per-hunk semantic annotation | the diff computation |
| **Hardware / capability badge** | Warpblade + Tempest | compact capability + health readout for a local machine | GPU vs PipeWire specifics |
| **Fail-closed startup page** | Warpblade only (single-consumer watch — Tempest N/A; stays local until a second consumer appears) | opaque fatal-startup surface, no stack-trace leak, actionable message | the product's own error codes |

**Honest note on row 4**: Warpblade and Tempest independently asked for a
"timecode counter". They are *not* the same component — one is AV timecode, the
other musical time. The shared thing is a *formattable semantic duration
value + monospace display primitive*, not a timecode widget. Extracting the
widget without the value would produce a component with two incompatible type
inputs. This is exactly the near-match/near-duplicate distinction the reset
mandate asks to be preserved.

---

## 5. Conflicting Semantics — Do Not Unify

Three mutually incompatible time ontologies are present:

1. **Wall-clock / log time** — `DSTimeline`, `DSTimeMachineScrubber`.
2. **Rational AV time** — Warpblade `rational_time.dart` (BigInt num/den, GCD).
3. **Musical grid** — Tempest (bars/beats/ticks, BPM fraction).

And three control/data-plane characters:

4. **Control plane** — health, commands, topology: model with runtime contracts.
5. **Streamed telemetry** — meters, progress: `EventStream`, declare rate.
6. **Data plane** — texture frames, peak pyramids, FFT: declare transfer +
   ownership semantics, or stay product-local.

Any candidate that silently merges these is a defect, not a compression win.

---

## 6. Missing Proofs (block promotion regardless of recurrence)

| Proof | Gap |
|---|---|
| Host-composition proof | No real consumer host exercises a Prism primitive today. Every row in §4 lacks it. |
| Flutter↔Rust lifecycle proof for the 6 §4 candidates | Cross-boundary candidates (#4, #6, #8) have no adapter-vs-fake parity evidence. |
| Data-plane transfer semantics | #8 (texture), #12/#14 (audio) have no declared transfer/ownership contract. |
| Consumer adoption | 0 of 4 consumers depend on the substrate. |
| Bridge content for Sentry | absent. |
| Sentry UI/integration surface | **RESOLVED 2026-10-10** — no Flutter UI surface exists: no `pubspec.yaml` anywhere, Rust-only, 3 crates, no FRB. *(original row: "unverified — external read denied.")* |
| Tempest → Warp Prism import check | **RESOLVED 2026-10-10** — definitively zero: `flutter/pubspec.yaml` + `pubspec.lock` + repo-wide `rg 'warp_prism'` return no manifest matches (`rg` exit 1). Method: parent-verified direct reads. *(original row: "UNKNOWN — external read denied.")* |

---

## 7. Acceptance Status

`pending-independent-acceptance`

An independent reviewer must adversarially test, per the reset mandate:

- current source was actually inspected (not inferred from bridge prose);
- symlink targets resolved correctly;
- completed work was not mistaken for future work;
- stale planning was not preserved as authority;
- product-local semantics were not falsely generalized (the Tempest audio and
  Warpblade NLE clusters must remain `KEEP_LOCAL`);
- all four intended consumers are represented honestly;
- UNKNOWNs are explicit;
- no "component exists therefore reusable" reasoning;
- Warp Prism is no longer modeled as owner of consumer frontends;
- ADS / IDS / Runtime / Bindings / FRB responsibilities remain distinct.

Verdict must be `PASS` before implementation planning proceeds.
