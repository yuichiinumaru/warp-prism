# Ads-to-Ids Story Packet v8 — Validated Decomposition (33 Stories)

> **⚠️ STATUS 2026-08-31 (source-reality review)**: this packet remains the **coverage genome / planning map** — it is **NOT a task queue**. Execution was compressed to ~15 tasks (see `docs/reports/warp-prism-v2-source-reality-review-2026-08-31.md` §E). Individual story verdicts (ACCEPT/AMEND/DEFER/REJECT) live in that report §A and are amended into the EPIC files in place. Do not re-derive tasks 1:1 from stories.

> **Source**: `docs/ads-to-ids.md` (14,970 lines) — 9 corrected EPICs ACCEPTED.
> **Provenance**: Synthesis by subagent `ses_fb0237ca8ffeEU75shi0yRgCcn` (Steps 1); orchestrator full-read (Step 3); corrections (Steps 4); EPIC review (Step 5); story decomposition + 6 adversarial fix rounds via subagent `ses_faf79f1e5ffeVDULRPLVp9eWdi` (Steps 6-9, 2026-08-29).
> **Epistemic status**: Fidelity-of-coverage to the transcript is validated. The transcript itself is **untrusted brainstorm evidence** — stories inherit that status. Coverage ≠ truth. "100% closed" below means "no known uncovered transcript section", NOT "all claims are facts".
> **Invariants**: `warp_prism_ui` pure (MUST NOT import FRB/runtime), runtime contracts backend-agnostic pure Dart, no Rust/FRB before EPIC-22, declutter without bulk moves, `≥2 distinct consumers OR 2 distinct domains` before core.
> Planning-only — no Where tables, no validation commands, no lanes. IDs stable S19-01..S25-04.

---

## EPIC-19 — Warp Prism v2 Foundation

### S19-01 — Charter v2 + ADR
**Objective:** Redefine Warp Prism as ADS + IDS + Runtime Integration System; ADR-record that runtime integration is in-scope at monorepo level but forbidden inside `warp_prism_ui`.
**Scope — In:** Charter v2 text, ADR, supersession note, preservation invariant, verbatim tattoos. **Out:** package scaffolding, code, FRB/Cargo, catalog work.
**Acceptance Criteria:**
- [ ] Charter states: visual vocabulary + interaction vocabulary + backend-agnostic runtime contracts with Rust as first-class replaceable adapter
- [ ] Second sentence verbatim: `It does not implement application backends. It standardizes the interfaces through which applications expose backend capabilities to UI.`
- [ ] ADR: previous `MUST NOT do runtime integration` invariant *only* for `warp_prism_ui`; superseded at monorepo level; consequences for Melos/harness/promotion
- [ ] Preservation invariant: `Prism* public API, DS internal namespace, ADS gallery, Melos monorepo, package purity, golden/semantics/boundary gates, fixture-first mode are PRESERVED — not refactored for aesthetics`
- [ ] Charter/ADR approvable without package directories existing
**Dependencies:** None (root). Blocks S19-02..06, EPIC-20/21.
**Evidence:** L13648-L13653 + L13771 + L13245-L13259 + L13442-L13478 + L14333

### S19-02 — Layer-Contracts Matrix
**Objective:** Publish canonical MUST/MAY/MUST-NOT matrix + Global MUSTs/MUST-NOTs + Domain Leakage Rule.
**Scope — In:** full matrix + global invariants + dependency graph. **Out:** harness implementation, package creation, contract authoring.
**Acceptance Criteria:**
- [ ] All rows: `warp_prism_ui` / `warp_prism_interaction` / `warp_prism_runtime` / `warp_prism_bindings` (MAY depend ui+interaction+runtime; MUST NOT own backend logic) / `warp_prism_testkit` / `warp_prism_adapter_frb` (MUST NOT be imported by UI) / `warp_bridge_core` (std crates only) / `warp_bridge_frb` (no app business logic) / `apps/*` (MAY compose everything) / `templates/` (MUST NOT introduce silent arch)
- [ ] Global MUSTs verbatim (L14187-L14197): every connected UI capability crosses a declared runtime contract; every contract has fake/reference; every FRB adapter passes same suite as its fake; generated bindings reproducible; large/data-plane payloads declare transfer/ownership semantics
- [ ] Domain Leakage Rule with wrong-vs-correct example: no `GanthritorAgentRuntime`/`CyberCore*` in core; core exposes `BackgroundJobRuntime`/`EventSource`/`GraphSource`; product adapters project domain onto generic contracts
- [ ] Global MUST-NOTs verbatim: Widget → generated FRB call directly; Prism component → Cersei/Ganthritor/CyberCore type directly; runtime contract → Flutter layout concept (Offset/Widget/BuildContext/Color) unless explicitly presentation-layer; `warp_prism_ui → flutter_rust_bridge` never
- [ ] Dependency graph direction (ui/interaction ← bindings ← runtime ← FRB/RPC adapter ← Rust) with note ui need not depend on interaction initially
**Dependencies:** S19-01. Blocks S19-03/04, EPIC-21/22.
**Evidence:** L13273-L13314 + L14174-L14261 + L14187-L14197

### S19-03 — Section-Gateway Policy
**Objective:** Define (a) harness section-gateway/lobe policy, (b) cross-ref to Global MUSTs, (c) Global MAYs.
**Scope — In:** lobe policy + MAYs. **Out:** contract definitions, lobe implementation, catalog wiring.
**Acceptance Criteria:**
- [ ] (a) Lobe policy: when a Skill's Sections evolve into independent lobe (route) vs remain in hub; bounded hopping; decision criteria for lobe promotion
- [ ] (b) Cross-reference Global MUSTs to S19-02 (no duplication)
- [ ] (c) Global MAYs (L14199-L14207): products MAY bypass runtime contracts when genuinely domain-specific; MAY have custom Rust crates; adapters MAY optimize transport independently of presentation; a component MAY be purely visual forever
- [ ] IDS and Runtime declared as distinct gateways from ADS
**Dependencies:** S19-02.
**Evidence:** Sec 29-30 (round-2) + L13273-L13349 + L14187-L14207

### S19-04 — Package Topology Acceptance
**Objective:** Decide and document-accept v2 package/template/tooling/workspace/skill topology before directory creation.
**Acceptance Criteria:**
- [ ] Packages: `warp_prism_ui` ≠ `warp_prism_runtime` ≠ `warp_prism_interaction`; bindings separate; `warp_bridge_core = ZERO FRB` vs `warp_bridge_frb = FRB projection`; adapters replaceable transports
- [ ] Templates: 4 (`flutter-rust-app`, `flutter-rust-daemon`, `flutter-rust-hybrid`, `flutter-rust-plugin`) — only after ≥2 real validated integrations
- [ ] Tooling: `prism_scaffold`/`bridge_doctor`/`contract_check`/`rewrite_manifest` under `tool/`
- [ ] Workspace: BOTH root-vs-`rust/` Cargo.toml options evaluated + ADR-recorded; Melos=Dart, Cargo=Rust; root scripts coordinate (`warp validate`)
- [ ] Skill topology parent-canonical: 4 skills (`warp-prism-development`, `flutter-rust-integration`, `performance-engineering`, `rewrite-with-warp-prism`) under `.agents/skills/`; NO `warp-prism/skills/` second system
- [ ] No scaffolding in this story
**Dependencies:** S19-01, S19-02.
**Evidence:** L12252-L12276 + L12848-L12892 + L13773 + L13561-L13614

### S19-05 — Historical Declutter + Root Hygiene
**Objective:** Establish declutter rules without bulk moves; enforce generator hygiene.
**Acceptance Criteria:**
- [ ] CURRENT OPERATING SET = EPIC-19+ active/review/new work; HISTORICAL CORPUS = EPIC-00..18 completed + old waves/reports; corpus ignored by default; bulk `git mv` forbidden
- [ ] Root hygiene: `tool/`/`scripts/`/`templates/` ONLY allowed locations for `fix_*`/`patch_*`/`tmp_*`/`append_*` generators
- [ ] No new root-level generator files; existing classified
- [ ] If migrated later: `docs/archive/v1/` + manifest (task, canonical_id, historical_path, archive_path); corpus recoverable only on explicit reference/provenance
**Dependencies:** S19-01. Independent of S19-02..04.
**Evidence:** L13777-L13785 + L13504-L13528 + L13796-L13827

### S19-06 — V2 Baseline Snapshot
**Objective:** Capture frozen baseline as single reference for IDS/Runtime/FRB.
**Acceptance Criteria:**
- [ ] Snapshot declares EPIC-19 closed; EPIC-20/21 eligible; EPIC-22..25 stubs deferred
- [ ] References accepted versions of Charter/matrix/gateways/topology
- [ ] Preservation invariant re-affirmed
- [ ] `prism_aliases.dart` (296 Prism*) observed HEALTHY — no split in v2 baseline; future split only if empirically justified
**Dependencies:** S19-01..05.
**Evidence:** L14267-L14271 + L13442-L13502

---

## EPIC-20 — IDS Kernel

### S20-01 — Interaction Primitive Set
**Objective:** Closed initial set of interaction primitives with non-framework guard.
**Acceptance Criteria:**
- [ ] Primitives: `PrismIntent`, `PrismSelection<T>`, `PrismCommand<I>`, `PrismQuery<Q,R>`, `PrismNavigationIntent`, `PrismDragSession<T>`, `PrismInspection<T>`, `PrismViewportState` + lifecycle idle/active/busy/disabled/failed/completed
- [ ] Guard: NOT a state-management framework (no Redux/Riverpod)
- [ ] Reuse note: DSInteractiveSurface mechanics stay in `warp_prism_ui`; IDS standardizes semantics above it
- [ ] Kernel small; extension requires ≥2 distinct consumers OR 2 distinct domains
**Dependencies:** S19-06.
**Evidence:** L12157-L12212 + L12628-L12632

### S20-02 — Interaction State Machine Vocabulary
**Acceptance Criteria:**
- [ ] Template: states/events/transitions/guards/pure effects
- [ ] Separates interaction state (pressed/selected/disabled) from ADS visual tokens
- [ ] Example machine (toggle or drag) validates template
**Dependencies:** S20-01.

### S20-03 — Input Contract
**Acceptance Criteria:**
- [ ] Pointer/keyboard/a11y modalities with normalized fields
- [ ] Pure Dart, no Flutter widget dependency
- [ ] A11y first-class
**Dependencies:** S20-01, S20-02.

### S20-04 — Counter-Example Matrix
**Acceptance Criteria:**
- [ ] ≥4 counter-examples (health polling, graph layout, execution streaming → Runtime not IDS) with rationale
- [ ] Each maps to correct home: ADS / Runtime / App domain
- [ ] Used as promotion gate
**Dependencies:** S20-01..03.

### S20-05 — Promotion Gate
**Acceptance Criteria:**
- [ ] ≥2 distinct consumers OR 2 distinct domains before core (not duplicate fixtures)
- [ ] Candidate/local stage allowed before proof
- [ ] State machine + input contract + counter-example clearance before merge
- [ ] Interaction pipeline verbatim (7 steps): observed pattern → distinguish mechanics vs semantics → prove recurrence → define state/intent contract → keyboard/pointer/a11y → component integrations → promote
**Dependencies:** S20-01..04. Feeds S24-02.
**Evidence:** L14048-L14092

---

## EPIC-21 — Runtime Contracts (MVP)

### S21-01 — Contract Definitions
**Acceptance Criteria:**
- [ ] 4 contracts pure Dart (no Flutter/FRB/app domain)
- [ ] AsyncCommand async/cancel/error; EventStream streaming; HealthSource polling/subscription; GraphSource N/E generics
- [ ] Runtime vs Presentation model separation (`RuntimeGraphNode` vs `PrismGraphNodeViewModel` via `GraphViewMapper`; Rust MUST NOT return Offset as domain)
- [ ] State vocabulary discipline: runtime lifecycle ≠ UI operational semantics
- [ ] 4-axis classification per contract: ownership / control-vs-data-plane / pure-vs-stateful / sync-vs-long-running
- [ ] Sequence: EventStream/HealthSource/GraphSource first, then AsyncCommand; BackgroundJob deferred
**Dependencies:** S19-06.
**Evidence:** L12355-L12696 + L12079-L12092

### S21-02 — Testkit
**Acceptance Criteria:**
- [ ] Dart-only conformance suite per contract; fake/reference MUST PASS; no promotion without suite PASS
- [ ] Performance SLO fields optional (`delivery.mode: stream`, `expected_rate.typical_hz`, `backpressure.strategy: latest`, `payload.expected_max_bytes`, `data_plane.crossing: handle_only`)
- [ ] Performance pipeline verbatim (4 steps): benchmark → baseline → receipt → regression proof
**Dependencies:** S21-01.
**Evidence:** L13409-L13440 + L14048-L14092

### S21-03 — Bindings
**Acceptance Criteria:**
- [ ] Thin projection `runtime/interaction → Prism presentation`; MAY depend ui+interaction+runtime; MUST NOT own backend logic/storage
- [ ] MUST NOT be imported directly by UI components
- [ ] Backend-agnostic: depend on contracts, not FRB
**Dependencies:** S21-01, S21-02.
**Evidence:** L14178-L14180

### S21-04 — Definition-of-Done / Quality Gates
**Acceptance Criteria:**
- [ ] DoD 7 items (L12969-L13020): contract spec + testkit suite + fake/reference + binding to ≥1 Prism organism + catalog demo + boundary clearance (+ Rust FRB adapter — added in EPIC-22; S21 requires 6/7)
- [ ] Runtime pipeline verbatim (7 steps): observed pattern → prove cross-domain reuse → contract first → Fake → contract suite → FRB → live integration → promote
- [ ] No domain leakage; no Flutter/FRB imports in runtime package
**Dependencies:** S21-01..03.
**Evidence:** L12969-L13020 + L14048-L14092

### S21-05 — Fixture-First Fallback Policy
**Acceptance Criteria:**
- [ ] Every contract declares fixture/fake dataset
- [ ] FRB/RPC adapters are replaceable transports, not ontology
- [ ] No promotion without fixture-first demo in catalog or lab
**Dependencies:** S21-01, S21-04.

---

## EPIC-22 — Rust Golden Path + Integration Lab

### S22-01 — Version Pinning Policy
**Acceptance Criteria:**
- [ ] FRB pinned 2.13.0 (or ADR successor); `rust-toolchain.toml` concrete toolchain
- [ ] Native Assets documented as recommended (reduces plumbing, doesn't eliminate codegen)
- [ ] Triple upgraded atomically with integration_lab verification
**Dependencies:** S19-06.
**Evidence:** L13829-L13935

### S22-02 — Native Assets Spike (KILL-GATE)
**Acceptance Criteria:**
- [ ] Spike evaluates cold build, incremental build, CI integration, packaging — Linux first, then Android
- [ ] Validates async Rust, complex types, traits/trait objects, Rust→Dart callbacks
- [ ] Outcome: adopt-vs-classic decision WITH rationale — failure ⇒ fallback/halt, NOT forced adoption
**Dependencies:** S22-01.
**Evidence:** L13834-L13900 + L11572
**⚠️ Epistemic note (audit 2026-08-29):** FRB 2.13 + Native Assets on Linux is UNVALIDATED. No spike has been run. The spike is a kill-gate, not a formality.

### S22-03 — Integration Lab (apps/integration_lab)
**Acceptance Criteria:**
- [ ] Dedicated app; both FRB embedded and RPC/daemon paths
- [ ] Fixture/fake-first; no auth, no DB, no production infos — architecture validation, not product
- [ ] BackgroundJob explicitly EXCLUDED (4 contracts only; deferred per S21-01 sequencing — resolves L13341 vs L13731)
**Dependencies:** S22-01, S22-02.
**Evidence:** L13339-L13355 + L12698-L12708

### S22-04 — Contract Suite Parity
**Acceptance Criteria:**
- [ ] Every FRB adapter passes same behavioral suite as its fake
- [ ] Coverage: AsyncCommand, EventStream, HealthSource minimum (GraphSource desirable)
- [ ] Explicit: error propagation, cancellation, bidirectional round-trip (Rust→Dart stream + Dart→Rust async command)
- [ ] Bridge pipeline verbatim (4 steps): Rust tests → Dart tests → FRB smoke → same contract suite
- [ ] Failure blocks promotion
**Dependencies:** S21-02, S22-03.
**Evidence:** L14191-L14193 + L14840-L14863

### S22-05 — Exit Gates
**Acceptance Criteria:**
- [ ] Full Rewrite Readiness gate (L14840-L14863) all PASS: ADS regression / architecture boundaries / IDS primitive set / runtime contract set / fake adapters / FRB integration / Rust contract impl / error propagation / cancellation / Rust→Dart stream / Dart→Rust async command / catalog connected examples / Linux production build
- [ ] 3 inviolable No's: No UI imports FRB; No runtime knows domain; No bridge owns business logic
- [ ] Integration Lab = architecture ONLY; product labs (CyberCore Phase 6, Cersei Phase 7, media Phase 8) are follow-on gated by this exit
- [ ] Incomplete if any check fails — no partial promotion
**Dependencies:** S22-01..04.
**Evidence:** L14840-L14863

---

## EPIC-23 — Connected Catalog

### S23-01 — Component Contract Schema
**Acceptance Criteria:**
- [ ] Links component → IDS primitive → runtime contract (if connected) → fixture/adapter refs
- [ ] Tri-state tag: Static / Interactive / Connected
- [ ] Schema declaration-only; states (empty/loading/running/failed etc.) + adapters + fixture refs
**Dependencies:** EPIC-20/21.

### S23-02 — Catalog Upgrade Reuse-First
**Acceptance Criteria:**
- [ ] Same component renders in 3 modes (static fixture / interactive state machine / connected fake-or-live)
- [ ] Reuse-first: search ADS/IDS → runtime contract → only then new primitive if recurrent
- [ ] Recurrence evidence ≥2 distinct consumers OR 2 distinct domains
**Dependencies:** S23-01.

### S23-03 — Manifest Export
**Acceptance Criteria:**
- [ ] Manifest lists components with tri-state tag + contract refs
- [ ] Version pins for FRB/Dart/Rust triple
- [ ] Declared input to EPIC-25 resolver (deferred)
**Dependencies:** S23-01, S23-02.

### S23-04 — Fake-Engine Integration
**Acceptance Criteria:**
- [ ] Every Connected entry has fake/reference engine passing its suite
- [ ] Catalog toggles fake vs live without component rewrites
- [ ] Catalog runs fully on fakes in CI without Rust toolchain
**Dependencies:** S21-02/05, S23-01..03, S22-04.

---

## EPIC-24 — Scaffolding & Extensibility Policy

### S24-01 — Iron Policies
**Acceptance Criteria:**
- [ ] L14174-L14181 MUST-NOTs as iron (no exceptions without ADR)
- [ ] `FRB is transport, not ontology`
- [ ] CI-enforceable via harness (not docs-only)
- [ ] Root-hygiene iron (tool/scripts/templates only)
- [ ] Preservation iron (Prism* API)
- [ ] Skill governance: parent-canonical; no divergent tree
- [ ] Template crystallization: ≥2 real validated integrations before any template exists
**Dependencies:** S19-06.
**Evidence:** L14174-L14193 + L13599-L13602

### S24-02 — Promotion Formula & Pipelines
**Acceptance Criteria:**
- [ ] ≥2 distinct consumers OR 2 distinct domains; candidate stage allowed
- [ ] All 5 pipelines verbatim with step arrows: Visual (8 steps) / Interaction (7) / Runtime (7) / Bridge (4) / Performance (4)
- [ ] Governance: proposal references consumers/domains + suite PASS + boundary + pipeline-specific PASS
**Dependencies:** S24-01, S20-05, S21-04.
**Evidence:** L14048-L14092

### S24-03 — Anti-Fragile Guardrails
**Acceptance Criteria:**
- [ ] Generators scaffold contract + fake + suite before adapter
- [ ] Generated `warp_prism_ui` fails CI on dart:io/Riverpod/GoRouter/FRB imports
- [ ] Templates include tri-state awareness
**Dependencies:** S24-01, S24-02, S23-01.

### S24-04 — Narrow Scoping
**Acceptance Criteria:**
- [ ] Single capability per proposal
- [ ] Backend-agnostic proof (fake + ≥1 transport)
- [ ] Domain overflow rejected via bypass clause + Domain Leakage Rule
**Dependencies:** S24-01..03.

---

## EPIC-25 — Rewrite Resolver (Research-Only / Deferred)

### S25-01 — Freeze Criteria
**Acceptance Criteria:**
- [ ] Prerequisites: EPIC-19 + IDS kernel + runtime kernel DONE; FRB spike decided; contract set frozen
- [ ] Forbids implementation before EPIC-22 parity gates
- [ ] Output is criteria doc, not code
**Dependencies:** S19-06.

### S25-02 — Capability Manifest Spec
**Acceptance Criteria:**
- [ ] Capability fields to match ADS/IDS/Runtime vs external service vs drop
- [ ] Census-scoped; reuses EPIC-23 manifest concepts
- [ ] Research-only with open questions logged
**Dependencies:** S25-01.

### S25-03 — Resolver Outline
**Acceptance Criteria:**
- [ ] Mirrors loop: failure → candidate → isolated trial → independent verify → governed promotion
- [ ] Distinguishes institutional vs constitutional promotion
- [ ] Output is outline doc, not code
**Dependencies:** S25-02.

### S25-04 — Escape Hatch
**Acceptance Criteria:**
- [ ] Conditions for external service / legacy-only / drop recommendations
- [ ] Cross-refs bypass clause (S19-03) + Domain Leakage Rule (S19-02)
- [ ] All EPIC-25 stories research-only, no code deliverables
**Dependencies:** S25-01..03.

---

## Open Owner Decisions (not fidelity gaps)

1. **S19-04 crate granularity**: single `warp_bridge_*` workspace crate vs multiple thin crates — owner call.
2. **S22-02/S22-05 mobile coverage**: exit gates currently Linux-first; Android/iOS scope needs explicit decision.
3. **S24-02 consumer definition strictness**: does catalog+lab count as 2 distinct consumers, or must both be product surfaces?

## Provenance & Review Trail

| Step | Actor | Result |
|---|---|---|
| 1 | subagent ses_fb0237ca8ffeEU75shi0yRgCcn | synthesis + task-creation order |
| 2 | orchestrator | session IDs noted in lane memory |
| 3 | orchestrator | full 14,970-line read |
| 4 | orchestrator → subagent | 6 corrections (timeline, Nomos mapping, 4-contracts, EPIC-20 breakdown, FRB-4th reasoning, OR-lane) |
| 5 | orchestrator | EPIC review: 7 gaps found |
| 6 | subagent ses_faf79f1e5ffeVDULRPLVp9eWdi | 33 stories v3 (after provider crash of first channel; recreated) |
| 7-9 | orchestrator ↔ subagent (5 adversarial rounds) | v4 (4 fixes) → v5 (4) → v6 (4) → v7 (4) → v8 (3 micro) |
| 10 | USER | **pending — paused for review** |
