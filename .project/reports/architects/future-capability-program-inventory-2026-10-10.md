# Warp Prism — Future Capability Program: Phase 1 Inventory

> **Status**: REVIEWED — PASS (independent architecture review `ses_edbfcec4dffeX44ZMBOaLDsRWR`, 2026-10-10; 18 falsification checks, §10 amendments applied). Phase 2 authorized in bounded form only.
> **Authority**: planning/research mission of 2026-10-10. Current `MISSION.md`, `AGENTS.md`, `.project/architecture/layer-contracts.md`, `docs/bridge/README.md` are authoritative. Historical GT conversations/plans are idea corpus only; the Rewrite Factory teleology, context/transport mission, product-feature ownership, and frontend-hosting mission are rejected as obsolete authority.
> **Method**: three parallel read-only investigations (Source Sets A/B/C) + parent verification of decision-moving claims + repaired `references` symlink + permission probe. No product functionality implemented; no consumer repository mutated; no bridge content copied.
> **Owner**: architects lane orchestration. Return packets are evidence input, not truth; every decision-moving claim below is either parent-verified or marked with its verification state.

---

## 0. Evidence provenance & verification states

| Source | Worker session | State |
|---|---|---|
| A — Warp Prism current capability inventory | `ses_edc5fcc1dffeLUU6S8smnkuglo` (`gts-investigator-codebase`) | delivered, complete; in-repo reads need no external grant |
| B — consumer reality + cross-consumer matrix | `ses_edc5f4489ffeHAKMZwTqcc6INY` (`gts-investigator-codebase`) | delivered, complete; **partially obtained via `gortex_*` after an `external_directory` filesystem deny — a Rule-33-§5 / Boot-Law route violation; decision-moving claims (zero adoption, repo structure, bridge state) re-verified by the parent via direct `rg`/manifest reads (see §0.1)** |
| C — reference harvest, attempt 1 | `ses_edc5f42eeffe21XkKnurvQ3gbN` (`gts-investigator-codebase`) | 1 empty return, then delivered declaring the corpus unreadable (honest partiality) |
| C — attempt 2 | `ses_edc486602ffevzvmvedU2iTmUe` (`gts-analyst-externalrepo`) | empty return (1 consecutive) |
| C — attempt 3 (aborted) | fresh `gts-investigator-codebase` via bash route | `Tool execution aborted` — cause undetermined, not diagnosed per Rule 33 §4 |
| C — permission probe | `ses_edc2657d1ffeijDIEhJd4Vpb3k` (`gts-investigator-codebase`) | 3/3 reads via `references/...` passed, no denials |
| C — fresh harvest (attempt 4, corrected route) | `ses_edc24a21fffeeVXQaK0J0CdR7o` (`gts-investigator-codebase`) | delivered, complete, source-cited |

### 0.1 Parent-verified facts (direct reads, no delegation)

- **Zero external consumer adoption** — verified by whole-repo `rg 'warp_prism'` sweeps:
  - Warpblade: matches only in `docs/warp-prism/ads-debt.md` (the bridge doc itself). `apps/warpblade-app/pubspec.yaml` + `pubspec.lock`: zero matches.
  - Tempest: matches only in `docs/warp-prism/ads-debt.md`. `flutter/pubspec.yaml` + `flutter/pubspec.lock`: zero matches (`rg` exit 1).
  - Sentry: no `pubspec.yaml` exists anywhere (Rust-only, 3 crates, no FRB); zero `warp_prism` matches repo-wide.
  - Hyperion: no `pubspec.yaml`, no `Cargo.toml`; one `warp_prism` match in `docs/warp-prism-conditions.md` (conditions prose, not code).
- **`references` symlink repaired** (user-authorized): was → `/home/sephiroth/working/ganthritor/research/github-repos/006-warp-prism` (nonexistent since the 2026-09-23 retarget); now → `../../research/github-repos/006-warp-prism` (relative, per root `AGENTS.md` §7 "relative paths, not machine-specific destinations"; reversible in one line; **not committed** — working tree is dirty with the active hardening session's changes, and VCS needs its own grant per §8.3).
- **Harness surface finding**: the `external_directory` deny applied to the *absolute* corpus path but not to the repo-relative `references/...` route — a symlink inside the repo mitigates the workspace-boundary permission. The real protection is legal (Boot Law, `AGENTS.md` §7), not mechanical; Rule 33 §3 already warns "prompt-only prohibition is not enforcement."

### 0.2 Prior-order falsification worth recording

The in-workspace harvest report of 2026-07-10 described `crux` as a "Rust-native cross-platform UI toolkit" with a `crux_core`/`crux_app` split. Fresh inspection proves it is a generic `create-turbo` starter template (Next.js + React + Jest, zero Rust). **Second-order evidence was wrong; fresh inspection falsified it.** All C claims below rest on fresh reads, not on the 2026-07-10 reports.

---

## 1. Current Warp Prism capability inventory (Source Set A, source-verified)

### 1.1 Package reality

| Package | Deps (pubspec-verified) | Public surface (source-read) | Stage |
|---|---|---|---|
| `warp_prism_ui` (ADS) | `flutter` SDK; dev-only `warp_prism_interaction` | tokens → atoms → molecules → organisms → **templates** → gallery; ~200+ `Prism*` typedefs in `prism_aliases.dart`; `DS*` internal | docstring: "Atomic Design System" |
| `warp_prism_interaction` (IDS) | `meta` only | 5 sub-libraries: selection (`SelectionNotifier`/`SelectionState`), inspection (`InspectionNotifier`), query (`QueryController`/`QueryExecution`), input intents (`InputIntent`/`PointerIntent`/`KeyboardIntent`/`A11yIntent`), state machine (`InteractionStateMachine`/`InteractionTransitionTable`) | barrel declares **PROVEN** |
| `warp_prism_runtime` (contracts) | `meta` only | 4 contracts: `EventStream<T>` (+`EventStreamSink`, `MutableEventStream`, backpressure), `HealthSource`, `GraphSource<TNode, TEdge>` (zero-`Offset` PURGE LAW), `AsyncCommand<TParam, TResult>` (single-flight cancel-and-replace, sealed `CommandError` ×6 / `CommandResult` ×3, `CancellationToken`) | **EXPERIMENTAL** (barrel + `@experimental`) |
| `warp_prism_bindings` (projections) | `ui` + `interaction` + `runtime`; dev `testkit` | 4 `ChangeNotifier` bindings + 4 view models + layout strategy; **owns `Offset`** (`graph_source_binding.dart:32`, `graph_view_model.dart:26`); `runtime` contains zero `Offset` (grep-verified) | **EXPERIMENTAL** |
| `warp_prism_testkit` | `runtime` | 4 fakes (`FakeEventStream`, `FakeHealthSource`, `FakeGraphSource`, `FakeAsyncCommand`) + 4 `verify*Contract` suites (20+/9/8/14 tests incl. adversarial) | **EXPERIMENTAL** |
| `warp_prism_adapter_frb` | `flutter_rust_bridge: 2.13.0` + `runtime`; dev `testkit` | 4 adapters (`FrbEventStream`/`FrbLocalEventStream`/`FrbNativeEventStream`, `FrbHealthSource`, `FrbGraphSource`, `FrbAsyncCommand`) + `WarpBridge` init + `CommandIdGenerator` | **EXPERIMENTAL by per-file evidence; the barrel itself carries no lifecycle declaration (discrepancy D2)** |
| `warp_prism_host_exercise` | zero Warp Prism deps | `ExerciseRunner` (SMOKE/CRAWL/FUZZ/REPLAY), `ExerciseTrace` JSON w/ deterministic replay command, strict `FlutterError`-throwing oracle, 15-pattern destructive-action safety policy | no lifecycle claim |
| `apps/catalog` | `ui` + `runtime` + `bindings` + `adapter_frb`; dev `host_exercise` + `testkit` | 22-section gallery (Dart const registry) + `ConnectedBridgeLabPage` (LIVE FRB vs FIXTURE fallback badges) + capture-gated visual acceptance tests | proof lab |
| `rust/warp_bridge_core` | **zero deps** (`[dependencies]` empty) | `CommandRegistry`, `CancellationToken` (`Arc<AtomicBool>`), `execute_command_pure` (sync, no async runtime), events/graph/health modules; zero `#[frb]`, zero tokio | transport-independent (structural, not nominal) |
| `rust/warp_bridge_frb` | `warp_bridge_core` + `flutter_rust_bridge = "=2.13.0"` + `tokio` (rt/sync/time) | `Frb*` DTO wrappers with `From`/`Into` core conversions; all `#[frb]` + `StreamSink` confined here; **exact FRB pin match with the Dart side** | transport owner |

FRB isolation mechanically confirmed: `flutter_rust_bridge` appears in exactly one Dart pubspec (`adapter_frb`) and all 10 Dart `flutter_rust_bridge` imports live inside `adapter_frb/`.

### 1.2 Historical-app classification (evidence-gated, per `MISSION.md` §2)

- **`apps/observatory` → STILL-VALID CONSUMER.** Full product routing (12+ routes), real state (`flutter_riverpod`), real charting/graph libs (`fl_chart`, `graphview`), version `1.0.0+1` (only non-`0.1.0` in tree), 60+ files. It is the one in-tree app functioning as a genuine product frontend on `warp_prism_ui`. (It is not one of the four intended external consumers; it does not change the zero-external-adoption fact.)
- **`apps/cybercore` → FIXTURE/DEMO.** Pubspec self-describes as "fixture-backed read-only observatory"; 4 pilot routes; hardcoded JSON fixtures (incl. redacted tokens); read-only.

### 1.3 Discrepancies (source vs source)

- **D2** (real): `warp_prism_adapter_frb` barrel omits the lifecycle declaration every sibling barrel carries. Per-file intent is EXPERIMENTAL; the barrel is silent.
- **D7** (minor): `warp_prism_ui` barrel `hide`s `DSGallerySectionSpec`/`DSGallerySections` while `prism_aliases.dart` re-exports the `Prism*` equivalents — the `hide` clauses are redundant, not contradictory.
- **D9** (resolved in-code): a prior false "FRB native-backed" docstring on `FrbEventStream` is self-recorded as corrected (WP-003).
- **No machine-readable registry exists.** Closest is the Dart const `dsGallerySections` (programmatically consumable inside Dart only) and four CyberCore/Observatory fixture/manifest JSON/YAML files that are consumer-local, not Prism registries.

---

## 2. Four-consumer delta matrix (Source Set B; critical claims parent-verified)

Bridge state: Warpblade present (`ads-debt.md`, in-doc 2026-09-13); Tempest present (`ads-debt.md`, 2026-09-13); **Sentry empty** (0 entries); **Hyperion absent** (deliberately not fabricated). Both present surfaces predate the 2026-09-27 gap matrix and were its inputs — no post-matrix drift. Two gap-matrix UNKNOWNs are now CLOSED: Tempest→Prism imports = definitively ZERO; Sentry surface = Rust-only, no Flutter UI at all (guard rail in `sentry/AGENTS.md` §3).

### 2.1 Capabilities satisfying the ≥2-consumer recurrence gate (9)

| # | Capability | Consumers | Current Prism equivalent | Disposition |
|---|---|---|---|---|
| 1 | App shell / workspace slot template | Warpblade + Tempest | `DSShellResponsive`, `DSSplitPane`, `DSSidebar`, `DSTopbar`, `MasterDetailTemplate` | `DUPLICATE_IMPLEMENTATION` (shape exists; no shared slot contract) |
| 2 | Transport bar shape (play/step/scrub + time readout) | Warpblade + Tempest | `DSSlider` only | `PRODUCT_SPECIFIC_KEEP_LOCAL` (time ontologies diverge — see §2.3) |
| 3 | Formattable duration value + monospace display primitive (NOT a timecode widget) | Warpblade + Tempest | `DSBadge` (no semantic timecode) | `CANDIDATE_UPSTREAM` (**the value**, not the widget) |
| 4 | Command-plan review before execution (propose → inspect → confirm/reject) | Warpblade (`ProposalPanel`, 467 lines, Rust-computed diff) + Tempest (`CommandBarDialog`, 385 lines) | `DSCommandPalette`, `DSToolCallCard` (no proposal lifecycle) | `CANDIDATE_UPSTREAM` (strongest; IDS-adjacent) |
| 5 | Prompt/response diff viewer | Warpblade + Tempest | partial (`DSExecutionConsole`) | `CANDIDATE_UPSTREAM` |
| 6 | Hardware/capability/health badge | Warpblade (bridge-QA) + Tempest (GPU/VRAM/probe) | `DSHealthCard`, `PrismProviderHealthMatrix` (partial) | `CANDIDATE_UPSTREAM` / `WARP_PRIMITIVE_NEEDS_EXTENSION` |
| 7 | Persistent batch-job progress (staged + cancel + receipt) | Warpblade (`ExportProgressBanner` + SHA-256 receipt) + Tempest (`ProgressCard`: prepare→chunk→post + stopwatch + cancel) | `DSToast`, `DSStateSurface` (toast ≠ persistent job) | `WARP_PRIMITIVE_NEEDS_EXTENSION` |
| 8 | Drag-drop with domain payload | Warpblade + Tempest | `DSDraggableCard`, `DSDropTarget` (**exact match**) | `REUSE_EXISTING_WARP_PRIMITIVE` |
| 9 | Provider/service health display (incl. keyring/quota axis) | Warpblade (`DiagnosticsPanel`) + Tempest (`ProviderConnectionCard`) | `PrismProviderHealthMatrix` (missing keyring/quota axis) | `WARP_PRIMITIVE_NEEDS_EXTENSION` |

**Promotion blocker (all 9): recurrence is necessary but not sufficient.** Per `AGENTS.md` §10.1, STABLE needs fake + conformance + boundary + **host-composition proof** + independent review. Host-composition proof is absent for every candidate: no real consumer host exercises a Prism primitive, and Tempest does not even consume Prism tokens (owns `AppColors` — recorded as `DUPLICATE_IMPLEMENTATION`, reason left to consumer governance).

### 2.2 Single-consumer only (17, condensed)

Warpblade-only: fail-closed startup error page (Tempest's equivalent is planned-only → watch-list); NLE timeline; rational AV time arithmetic; take-audition grid; native texture viewport host. Tempest-only: DAW timeline; musical-grid arithmetic; LUFS metering; faders/knobs/M-S-Arm; channel strip; FX rack; model-asset card; version-DAG (docs-only); quota tracking (docs-only); spectrogram (docs-only). **Default disposition: `PRODUCT_SPECIFIC_KEEP_LOCAL`.** Tempest `AppColors` self-owned token system is a failure-to-adopt, not a domain necessity.

### 2.3 Conflicting-semantics register (must NOT be unified)

Rational AV time (BigInt num/den) × musical grid (bars/beats/ticks) × wall-clock log time; LUFS broadcast calibration; studio dB fader mapping; NLE edit verbs × DAW automation verbs; data-plane transfer semantics × control-plane contract semantics. *"Any candidate that silently merges these is a defect, not a compression win."*

---

## 3. Reference-derived candidate ledger (Source Set C, fresh reads)

### 3.1 Verified HIGH donors

| Donor | Verified reusable semantic | Warp layer | Status vs existing Prism |
|---|---|---|---|
| `ag-ui` (`sdks/typescript/packages/core/src/events.ts`, `types.ts`, `proto/events.proto`) | 26-member discriminated event union (`BaseEvent` + `type` + ts + passthrough); 4-phase tool-call envelope (`Start`→`Args`→`End`→`Result`, `toolCallId`-owned); `STATE_SNAPSHOT` + RFC-6902 `STATE_DELTA`; `RunStarted/Finished/Error` with `parentRunId` | runtime / IDS / bindings | Net-new contract vocabulary; strongest protocol prior art. Falsifier: no two of the four consumers would consume the same union |
| `secondary-yuichiinumaru-ivisa-tamagui` (`packages/ui/component-registry.json` 6018 lines; `scripts/harvest.ts` ts-morph AST; `scripts/verify_components.py` Storybook+Playwright oracle; `scripts/mcp-server.py`) | Machine-readable registry shape `{version, lastUpdated, components[{id,name,type,description,filePath,importPath,props[{name,type,required,description,defaultValue}],dependencies,usageExamples}]}` + deterministic harvest→validate→write pattern | catalog / taxonomy | **Only machine-readable registry in corpus.** Not a gap in *concept* (Dart const registry exists) but in *representation* (not consumable outside Dart, no verification loop) |
| `secondary-simstudioai-sim` (`apps/sim/blocks/registry.ts` 1035 lines; `executor/dag/builder.ts`; `executor/types.ts` 579 lines) | Dual registry (`BLOCK_REGISTRY` execution truth + `BLOCK_META_REGISTRY` presentation metadata, never read by executor); DAG builder with loop/parallel sentinels; `ExecutionContext` pause/snapshot/resume (`pauseKind: human\|time`); handler registry with `canHandle` negotiation; "components OWN their chrome" (props, never class overrides) | catalog / runtime / ADS | Execution/presentation split mirrors Prism's model/presentation split — corroboration, plus pause/snapshot vocabulary Prism lacks |
| `secondary-thinkinaixyz-deepchat` (`src/shared/types/core/chat.ts`; `contracts/common.ts`; `messageBlocks.ts`) | `AssistantMessageBlock` discriminated union + typed `artifact` envelope (code/md/html/svg/mermaid/react) + `finalizeAssistantMessageBlocks` terminal-state transition with pending-interaction guards | IDS / runtime | Union members are chat-domain taxonomy (product-specific); the **envelope + terminal-state-guard pattern** is the reusable half |
| `secondary-open-webui-open-webui` (`StatusHistory.svelte`; `Artifacts.svelte`) | Reactive status trail (latest-at-top, collapsible, per-item `hidden`/`done` + shimmer); store-driven artifact panel (auto-open/close) | ADS / IDS | Duplicates existing Prism organisms (`DSTimeline`, `DSStatusGrid`, `PrismArtifactWorkbench`) at higher abstraction — corroboration, not gap |
| `flutter_rust_bridge` (`frb_dart/lib/src/stream/stream_sink.dart`) | `RustStreamSink<T>` (pass-sink-before-access pattern); explicit bridge-stream cancellation; zero-copy big arrays + multiple codecs | bindings / FRB | Confirmation of existing FRB surface; data-plane vocabulary lives here, not in a Prism contract |

### 3.2 Rejected by inspection (material entries)

- **`crux` — falsified**: generic Turborepo starter, zero Rust. Prior internal description was wrong.
- **`supabase-data-viewer` — product-specific**: 9128-line inline vanilla-JS single-vendor dashboard, no componentization.
- **`getwidget` — anti-pattern**: monolithic styling, no tokens, no atomic structure.
- Judatop/Villa/ahmedm: taxonomy confirmation only; hardcoded colors, platform IO in UI package, README-only, or license-`TODO`.
- Open-webui StatusHistory / deepchat union-as-contract / sim block-registry-as-replacement / ivisa registry-as-gap: **DUPLICATE** of existing Prism capability (higher-abstraction organisms, PROVEN IDS, Dart const registry already exist).

---

## 4. Historical-idea reconciliation

| Hypothesis | Verdict | Grounds |
|---|---|---|
| Component Contract Registry / machine-readable Catalog | **KEEP AS CANDIDATE** | Nothing equivalent exists (§1.3); strongest corpus prior art (§3.1 ivisa); falsifier: Dart const proves sufficient outside Dart (unlikely) |
| Recipe / Workbench taxonomy above organisms | **SPLIT: templates SUPERSEDED (already built); recipe/workbench above templates → RESEARCH ONLY** | `MasterDetailTemplate`/`CanvasTemplate`/`TimelineTemplate` exist; ivisa (richest donor) stops at organisms with no template layer; zero consumer demand for anything above templates |
| Deterministic fixture/scenario/capture model | **SUPERSEDED (mostly)** | host-exercise smoke/crawl/fuzz + trace replay + strict oracle + catalog capture-gated goldens already implement it; residual (scenario-as-versioned-artifact) is a weak candidate pending demand |
| Action/Intent → semantic-owner | **SUPERSEDED** | IDS PROVEN implements it; ag-ui/deepchat corroborate |
| Optimistic projection + reconciliation | **RESEARCH ONLY** | Weak prior art only (open-webui deep-equal, sim edge-restore); zero consumer demand |
| Typed agent transcript / tool-call / artifact surfaces | **KEEP AS CANDIDATE (weak)** | Partially exists (`DSToolCallCard`, `PrismArtifactWorkbench`); natural consumer (Hyperion) has no code; ag-ui/deepchat prove the shape |
| Operational table/filter/timeline/diff primitives | **SUPERSEDED** | `DSDataTable`, `DSFilterWorkbench`, `DSTimeline`, `DSLogViewer` exist |
| Graph/map/inspector primitives | **SUPERSEDED** | `DSGraphCanvas`+`GraphSource`, `PrismMapCanvasStage`, `DSDetailInspector` exist |
| Workflow/execution workbench primitives | **RESEARCH ONLY** | Best donor (sim) is workflow-product-specific; `PrismExecutionConsole` covers the console half; zero consumer demand for DAG canvas |
| Media-oriented reusable primitives | **PRODUCT-LOCAL (default)** | Data-plane rule (§8 layer-contracts); Warpblade texture + Tempest meters stay local; recurrence exists only at contract level (see G7) |
| Native heavy-data-plane patterns | **KEEP AS CANDIDATE** | Rule declared (layer-contracts §8), contract type missing; both AV and DAW domains hit it; FRB zero-copy vocabulary is transport-side only |
| Desktop capability contracts | **REJECT** | Zero consumer demand + zero useful prior art (deepchat presenters are product implementations, not contracts) |

---

## 5. Taxonomy findings

The ADS taxonomy is **tokens → atoms → molecules → organisms → templates → gallery**, all real on disk (`packages/warp_prism_ui/lib/src/`). The above-organism layer is `templates/` (1 file, 3 classes — correctly not yet a subdirectory per path economy). No `workbench/`, `recipes/`, `composites/`, or `primitives/` layer exists anywhere. Notably, ivisa-tamagui — the richest donor — has **no template layer at all**; Warp Prism is ahead of its best donor on this axis. **Do NOT mass-rename code in any follow-up pass**; taxonomy work, if any, is additive (registry describing the existing taxonomy, not renaming it).

---

## 6. Ranked future gap list

> Ordering key: evidence strength × recurrence × promotion-law readiness. A missing primitive NEVER blocks a consumer; reference-only inspiration with zero demand stays RESEARCH.

- **G0 (program-level, meta): zero external adoption + zero host-composition proof.** Not a primitive — the condition on which every promotion depends. Any EPIC set that adds primitives without addressing G0 builds on an unexercised foundation.
- **G1: host-composition proof for the 9 recurrent candidates.** Evidence machinery, not components: affected-host exercise (per `AGENTS.md` §7.1) for command-plan review, batch-job banner, capability badge, diff viewer, duration primitive. Blocked until a consumer cooperates — this is the genuine external gate.
- **G2: bridge-surface completion.** Sentry bridge empty, Hyperion absent. Without surfaces, recurrence detection is blind on half the consumer family. (Consumer-owned work; Prism side can only request/specify.)
- **G3: machine-readable component/contract registry.** Unlocks deterministic discovery, verification loops, and agent consumption; ivisa proves the shape; harvest pattern (AST→validate→write) is the reusable half.
- **G4: command-plan review lifecycle (propose → inspect → confirm/reject).** Strongest upstream candidate: two substantial local implementations, Rust-computed diffs on one side, no shared lifecycle in Prism.
- **G5: staged batch-job progress (staged + cancel + receipt).** Toast ≠ persistent job; both consumers prove the shape including determinism receipts.
- **G6: capability/health badge with keyring/quota axis.** Partially exists; the extension axis is precisely named.
- **G7: data-plane transfer + ownership contract.** Declared as rule, missing as type; recurrence at contract level across AV/DAW; transport vocabulary exists only FRB-side.
- **G8 (watch-list): fail-closed startup error surface.** 1 implemented + 1 planned; single-consumer → stays watch-list until the second lands.
- **G9: operational diff viewer.** 2 consumers, both local; weaker than G4 (subset of the review lifecycle).

Out of scope for any future EPIC by default: time-ontology unification (defect, not compression), LUFS/studio-ergonomics extraction, NLE/DAW timeline unification, desktop contracts, workflow DAG canvas without consumer demand.

---

## 7. Dependency / recurrence map

```text
G0 (adoption/proof condition)
 └─ gates ALL promotion to STABLE (contract lifecycle, layer-contracts §9)
G2 (bridge completion) ── feeds ──► recurrence detection (new G4..G9 candidates)
G3 (registry) ── enables ──► deterministic verification of G4..G7 + agent consumption
G4 (review lifecycle) ── uses ──► existing IDS intents + AsyncCommand + DSToolCallCard
G5 (job progress) ── uses ──► existing EventStream + DSToast vocabulary (extension, not new layer)
G6 (capability badge) ── extends ──► existing HealthSource + PrismProviderHealthMatrix
G7 (data-plane contract) ── needs ──► FRB-side design + runtime contract (new type, EXPERIMENTAL entry)
G8/G9 ── leaves, no dependents
Conflicts (§2.3) ── constrain ──► G4/G5/G7 (shared shape, never shared ontology)
Active hardening (tasks 1840/1843/1846, Karax session) ── must not be duplicated ──► G3..G7 start at 00-planning/HOLD
```

Recurrence summary: 9 capabilities ≥2 consumers; 17 single-consumer (product-local by default); entire substrate zero-demand in adoption terms; reference-only ideas without consumer demand stay RESEARCH.

---

## 8. UNKNOWNs (preserved, not inferred)

- A8/A9 (Source Set A): `adapter_frb` package-level stage (barrel silent); exact `Prism*` symbol count (file capped at 50 KB read); possible `DS*` leak via `prism_theme_editor.dart`; host-exercise traces ever produced; cybercore/observatory CI coverage; observatory `manifest.yaml` test consumption.
- B8 (Source Set B): Hyperion `tmp/` contents (unenumerable); Warpblade `StreamSubscription` (claimed by gap matrix, not re-observed); Tempest musical-grid type location (display verified, type not located); all runtime-semantics columns are source-inferred, never execution-verified.
- R6 (Source Set C): `secondary-nexu-io-nexu/` uninspected beyond listing; FRB codegen internals unread; sim `subBlocks` uninspected per-block; deepchat ACP contract unread; open-webui backend unread; root gitingest digests never opened (by design).
- Program-level: whether Sentry/Hyperion will ever produce bridge surfaces; whether any consumer will cooperate on host-composition proof (the G1 external gate).

---

## 9. Review gate

This inventory is submitted for **independent architecture review**. Required verdict form: `PASS | FAIL | BLOCKED` + falsification-first findings with source-cited evidence. Acceptance of this inventory authorizes Phase 2 (smallest coherent future EPIC set → Stories → Tasks in `00-planning/` HOLD/CANDIDATE only). It does not authorize implementation, does not move anything to `01-open/`, and does not duplicate tasks 1840/1843/1846.

---

## 10. Independent review amendments (2026-10-10, reviewer `ses_edbfcec4dffeX44ZMBOaLDsRWR` — verdict PASS)

Original §§0–9 preserved verbatim above; the PASS applies to the factual layer as amended here. None of these changes any disposition, gap rank, or the Phase 2 authorization.

- **F7 donor-path precision**: corpus paths omit one nesting level. Correct: `secondary-simstudioai-sim/apps/sim/blocks/registry.ts` (1035 lines ✓), `.../apps/sim/executor/types.ts` (579 ✓), `.../apps/sim/executor/dag/builder.ts` (172); `harvest.ts` lives at `secondary-yuichiinumaru-ivisa-tamagui/ivisa-tamagui/packages/ui/scripts/harvest.ts`; `component-registry.json` is **6017 lines** (not 6018). No fabricated donors or scripts.
- **F14 bridge-drift evidence**: "no post-matrix drift" (§0.1/§2) is amended — in-doc audit dates (both 2026-09-13) predate the 2026-09-27 gap matrix (confirmed), but the Warpblade bridge file mtime is 2026-10-07, so **byte-level drift since 2026-09-27 is UNVERIFIED** (sibling-repo git access denied). Recorded as explicit UNKNOWN; recurrence rows do not depend on bridge docs alone.
- **F15 observatory phrasing**: "genuine product frontend on `warp_prism_ui`" is true only as *visual composition of Prism widgets*; the *dependency* reading is false (`apps/observatory/pubspec.yaml` declares no `warp_prism_*` dep — consistent with §0.1 zero-adoption). Zero-adoption fact unaffected.
- **F16 gallery count**: `design_system_gallery_registry.dart` contains **25** `DSGallerySectionSpec` entries (not 22). Cosmetic; not decision-moving.
- **V3-2 prior-report characterization**: the §0.2 claim that the 2026-07-10 report text described crux as "Rust-native cross-platform UI toolkit with a `crux_core`/`crux_app` split" is UNVERIFIED (prior report not re-read); the falsification of the *referent* (crux = Turborepo boilerplate, zero `.rs` files) is independently confirmed.
- **V3-3 "sentinel" wording**: the "loop/parallel sentinels" paraphrase for the sim DAG builder is UNCONFIRMED as a referent (`LoopConstructor`/`ParallelConstructor` + loop/parallel config maps verified; the specific mechanism wording not verified).
- **V3-4 brand-law retirement**: consciously recorded — `AGENTS.md` §7.0 retired by Task 1839 acceptance; no action.
- **V3-5 Task 1841 — RETRACTED 2026-10-10 (overnight Inv-3 `ses_ed6d99d12ffe6FqxhURko1u75N`)**: 1841 is NOT dangling. It exists at `.project/tasks/04-completed/1841-warp-prism-doc-comment-layer-contracts-sweep.md` (57-file writeset, independent review FAIL 50/100 → re-review PASS 92/100). The "dangling" flag above was an enumeration error (lanes searched without the 04-completed hit). Gap-matrix "F7 folded into Task 1841" stands as accurate. Associated finding: `tasklist.md` still lists 1841 under `01-open` (STALE projection; rebuild requires explicit user request per workflow §3.7 — recorded, not executed).
