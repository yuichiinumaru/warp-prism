# Warp Prism v2 — Source-Reality Review (Pre-Promotion Adversarial Pass)

> **Date**: 2026-08-31 · **Pass type**: falsification against repo state, NOT transcript coverage
> **Inputs**: direct orchestrator ground-truth (2026-08-31) + investigator packet `ses_fa64e1616ffeQwSADlZpuNmAkB` (file:line evidence) + user directive (24 points, 2026-08-31)
> **Principle applied**: *precision of description is not evidence of correctness; an abstraction becomes architecture only after surviving contact with real consumers.*
> **Effect**: This report AMENDS the EPICs 19–25 planning artifacts in place. No parallel versions created. No v9 stories. No new stories.

---

## 0. Ground truth established (what the repo actually is, 2026-08-31)

**ALREADY LANDED (by EPIC-18 builder sessions, in `03-review` awaiting drain):**
- `prism_token_registry.dart` — enum `PrismColorRole` with contract defaults (`#030506/#080C0E/#0C1114/#12181C`, blue ladder `#2F81FF/#1D64D8/…`); **`DSColors` migrated to registry-backed getters** (const→getter blast radius already absorbed by builders).
- `DSTheme.dark()` full M3 ColorScheme factory (`lib/src/theme/ds_theme.dart`) + `PrismTheme` alias + Taldarim/Talon variant skins; **catalog consumes `PrismTheme.dark()`** (no more bare `ThemeData.dark()`).
- `PrismThemeEditor` organism + tests (`organisms/theme_editor/`, incl. registry tests); `PrismColorField` (1808).
- Rajdhani (300–700) + JetBrainsMono + `OFL.txt` bundled in catalog & observatory; `apps/*/integration_test/` exists (typography smoke + visual capture).
- `docs/design/black-obsidian-visual-contract.md` is live canon. **`docs/design/charter.md` already exists.**

**DOES NOT EXIST (verified):**
- No `rust/`, no `Cargo.toml`, no FRB anywhere (greenfield — EPIC-22 entirely unvalidated).
- No `warp_prism_interaction` / `warp_prism_runtime` / bindings / testkit packages. Only `warp_prism_ui` (+ 3 apps).
- No stream/subscribe API on ANY organism. ExecutionConsole controller = append-only buffer + presentation auto-scroll (`ds_execution_console.dart:285-406, :538-665`). LogViewer = presentation filter/scroll, takes full list. GraphCanvas = pan/zoom/physics presentation. ProviderHealthMatrix = stateless.
- No shared selection model: **>100 ad-hoc `selected` usages, 10+ bespoke callback patterns**; only `DSWorkflowSelection` is a dedicated payload (`ds_workflow_canvas_stage.dart:370-402`). `DSInteractiveSurface` = mechanics only, no semantic state.
- No shared command-state in apps (observatory uses Riverpod `AsyncValue`; catalog `ValueNotifier`; cybercore local state).
- No health polling anywhere in `apps/*/lib` (zero `Timer.periodic`) → **HealthSource has zero current consumers**.
- `GraphNode`/`DSWorkflowNode` **mix layout `position: Offset` with semantic identity** in one class.
- Boundary harness = flat `List<BoundaryCheck>` (7 checks) — trivially extensible.
- Root hygiene debt CONFIRMED: ~22 `fix_*/tmp_*/patch_*/append_*/test_*/snippet_*` files at root; `tool/` has only `validate_mock_workspace.py`.

---

## A. Source-Reality Review — verdicts per EPIC/story

Format: verdict · conversation basis → source reality · required change.

### EPIC-19 — Warp Prism v2 Foundation → **EXECUTION CANDIDATE**

| Story | Verdict | Basis → Reality | Required change |
|---|---|---|---|
| S19-01 Charter v2 + ADR | **AMEND** | Charter text desired → `docs/design/charter.md` ALREADY EXISTS; visual contract canon already live | Amend existing charter in place; no parallel doc. AGENTS.md identity edits = protected file, require explicit user authorization. Tattoos + preservation invariant stay. |
| S19-02 Layer-Contracts Matrix | **ACCEPT** (with phasing) | Matrix desired → only 1 package exists; 6 of 10 rows describe packages that don't exist yet | Keep matrix as LAW for future packages; phase harness enforcement (see F). Domain Leakage Rule ACCEPTED. |
| S19-03 Section-Gateway Policy | **REJECT (as scoped) / REWRITE** | Transcript carried Ganthritor harness concepts (Skill Sections, lobe promotion, bounded hopping) → **warp-prism has zero skills of its own (parent symlinked)**; concept has NO substrate here | Rewrite S19-03 as Warp Prism **integration-gateway policy**: `reusable UI↔runtime semantic → candidate Warp Runtime Contract; domain-specific semantic → MAY remain product-local`. Harness-lobe/skill-routing → parent Ganthritor handoff (ledger §G). |
| S19-04 Package Topology | **AMEND** | Transcript enumerated 6–7 Rust crates + 4 parent skills + tool/ names → nothing exists; crates premature; skills are parent-canonical territory | Rust topology reduced to **2 crates**: `rust/warp_bridge_core/` (modules: command/events/health/graph) + `rust/warp_bridge_frb/`. Rule: *concept existence ≠ crate existence*. Skill topology → parent handoff (ledger). Tool names stay intent-only. Cargo root-vs-`rust/` remains an OPEN ADR at 22-B. |
| S19-05 Historical Declutter + Root Hygiene | **AMEND** | "EPIC-00..18 = historical" is wrong → 36 tasks under EPIC-18 are ACTIVE non-terminal review work; ~22 root files confirmed | State-based sets: CURRENT = all non-terminal executable tasks + active planning + current canonical decisions + evidence needed by active work; HISTORICAL = terminal tasks + superseded planning + old waves. Root-hygiene sweep stays; mechanizable check now (see F). |
| S19-06 V2 Baseline Snapshot | **AMEND** | Snapshot assumed pre-implementation → baseline artifacts (contract, registry, theme factory) already exist in 1801–1808 work | Baseline = **post-1805-approval** freeze; merges with the 1805 human gate, not a separate parallel snapshot. |

**Sequencing fix (user pt 2):** EPIC-18 closure gates ONLY visual-baseline-dependent work (goldens v2, screenshot acceptance, UI-visible acceptance, 19-D visual baseline). It does NOT gate 19-A/B/C, IDS/runtime planning, or experimental contract work. Kill-condition rewritten accordingly.

### EPIC-20 — IDS Kernel → **EXECUTION CANDIDATE** (parallel to EPIC-21)

| Story | Verdict | Basis → Reality | Required change |
|---|---|---|---|
| S20-01 Primitive Set | **AMEND** | Transcript listed 8 primitives → recurrence evidence exists ONLY for **Selection + Inspection** (>10 ad-hoc implementations, >100 `selected` usages, `DSWorkflowSelection`); no evidence for Query/NavigationIntent/ViewportState as package primitives (viewport lives inside GraphCanvas mechanics; navigation is app GoRouter) | Inventory-driven kernel: 20-A inventory classifies; kernel admits only recurrence-backed primitives (Selection/Inspection/Command-intent first). Query/Navigation/Viewport → candidate ledger. Non-framework guard + DSInteractiveSurface reuse note stay. |
| S20-02 State Machine Vocabulary | **ACCEPT** | Cheap, useful, no controversy | — |
| S20-03 Input Contract | **ACCEPT** | a11y first-class matches DSInteractiveSurface semantics | — |
| S20-04 Counter-Example Matrix | **ACCEPT** | Maps to real near-misses (health polling→Runtime, layout→presentation) | — |
| S20-05 Promotion Gate | **AMEND** | Formula correct; lifecycle missing | Fold PROPOSED→EXPERIMENTAL→PROVEN→STABLE (see pt 5). |

**Dependency fix (user pt 3):** remove EPIC-20 → EPIC-21 edge. Both depend only on the 19 foundation gate (A+B+C); they converge at bindings (21-C).

### EPIC-21 — Runtime Contracts MVP → **EXECUTION CANDIDATE** (parallel to EPIC-20)

| Story | Verdict | Basis → Reality | Required change |
|---|---|---|---|
| S21-01 Contract Definitions | **AMEND (presentation purge)** | Transcript leaked presentation policy into contracts: EventStream described with "start/stop/**auto-scroll**/backpressure" → investigator proves auto-scroll/follow-tail are INTERNAL presentation state in ExecutionConsole (`:538-665`) and LogViewer (`:122-157`); they belong to widget/IDS | EventStream = subscribe/unsubscribe, ordering, delivery, completion/error, backpressure, (cursor/resume only if needed). **Auto-scroll/follow-tail/viewport/pause-presentation → IDS/binding/UI.** HealthSource = snapshot + optional watch + freshness/source-state — **NO polling/retry policy** (poll-every-X, refresh-on-focus, exponential retry → composition layer). AsyncCommand = execution/result/error/cancellation — **retry is another layer** unless strong proof. Runtime≠Presentation model separation CONFIRMED needed (GraphNode/DSWorkflowNode currently mix). Sequencing constraint relaxed (all 4 experimental; lab needs all 4 anyway). |
| S21-02 Testkit | **ACCEPT + AMEND** | Suites sound; Performance pipeline verbatim ok | SLO fields = declarations, not optimizations. Add: **no zero-copy/manual-buffering/lock-free/SIMD/affinity work without profiler evidence** (user pt 23). |
| S21-03 Bindings | **ACCEPT** | thin projection, MAY depend ui+interaction+runtime | — |
| S21-04 DoD / Quality Gates | **AMEND** | 7-item DoD + promotion-by-recurrence → circularity risk ("must be core to be tested / must be tested to be core") | Add lifecycle: contracts enter runtime package as **EXPERIMENTAL without joining the stable public barrel**; PROVEN after ≥2 distinct consumers OR 2 distinct domains; STABLE = barrel + API freeze. (User pt 5.) |
| S21-05 Fixture-First | **ACCEPT** | matches existing fixture-first culture | — |

**Consumer reality check:** EventStream ≈ 2 candidate consumers (LogViewer, ExecutionConsole — same domain); GraphSource ≈ 2 (GraphCanvas, WorkflowCanvasStage — same domain); HealthSource = **0 today**; AsyncCommand = ad-hoc in 3 apps. All four legitimately start EXPERIMENTAL.

### EPIC-22 — FRB Golden Path → **EXECUTION CANDIDATE** (single-hypothesis lab)

| Story | Verdict | Basis → Reality | Required change |
|---|---|---|---|
| S22-01 Version Pinning | **AMEND** | "Pin FRB 2.13.0" froze a version current-at-conversation-time → nothing spiked; version was never a decision | Wording → **candidate spike version**: at spike time verify latest stable + Dart/Flutter/toolchain compatibility → build/integration matrix → only then ADOPT + pin exact FRB/codegen/Native-Assets-integration/Rust-toolchain quadruple. Before spike: "candidate", never "adopted architectural dependency". (User pt 9.) |
| S22-02 Native Assets Spike | **ACCEPT** | kill-gate framing already correct; epistemic warning already recorded | Spike measures: cold build, incremental build, CI integration, packaging — Linux first, Android second. |
| S22-03 Integration Lab | **AMEND** | Lab scoped "both FRB embedded AND RPC/daemon paths" → mixing transports makes results epistemically worthless (can't attribute success/failure) | First lab validates **ONE hypothesis: Flutter↔Rust via FRB**. Remove resident daemon / RPC / remote worker / hybrid / Cersei / Ganthritor / OmniRoute from the lab. Those → ledger §G. BackgroundJob exclusion stays. |
| S22-04 Parity | **ACCEPT** | same-suite-as-fake + error/cancel/bidirectional + Bridge pipeline | — |
| S22-05 Exit Gates | **ACCEPT + AMEND** | 13-check Rewrite Readiness + 3 No's correct | Add: exit gate **attaches the harvest/retrospective checklist** (user pt 22) as the mandatory next step, and gates only Level-2 readiness — never Level-3 factory work. |

**Rust topology (user pt 6):** 5+ crates planned → **2**: `warp_bridge_core` (modules command/events/health/graph) + `warp_bridge_frb`. `jobs`/`media`/`telemetry` crates = future capability candidates until a concrete crate-boundary motive exists (dependency isolation / independent lifecycle / build isolation / independent reuse / compile boundary).

### EPIC-23 — Connected Catalog → **CONDITIONAL / PARTIALLY PROVABLE**
- **23A — Minimal Connected Catalog Proof** (post-22): component + interaction declaration + runtime requirement + fake adapter + live FRB adapter for **one or few cases**. Promotable after 22-D.
- **23B — Generalization** (full registry, manifest exporter, generalized resolver metadata, tri-state-everything) → **DEFERRED post-pilot** (ledger). Source reality: catalog today is a theme-switching showcase; the generalization has zero consumers.

### EPIC-24 — Scaffolding & Extensibility → **HOLD / POLICY INTENT**
- Policy text stays as law-in-waiting (iron policies, promotion formula, crystallization rule: first occurrence → local; second recurrence → candidate abstraction; multiple stable recurrences → primitive/template). **No executable tasks.** Nothing to scaffold — zero recurrences exist.

### EPIC-25 — Rewrite Resolver → **RESEARCH INTENT** (unchanged)
- Specs/outlines only. Levels restated: L0 ADS (done) → L1 Integration-Capable (EPIC-19..22) → L2 Rewrite-Capable (one successful vertical pilot + harvest) → L3 Rewrite Factory (only AFTER L2, extracted from it).

### EPIC-OR — OmniRoute anchors → **RESEARCH INTENT** (refined)
- Read-only parallel archaeology (Behavioral Freeze, Capability Census, State/Effect Census, Oracle Capture) may run alongside 19–22 under parent authorization. First implementation pilot candidate = Provider Management (list/inspect/configure/test/observe-health) — **target to validate during OmniRoute planning, not an axiom**. OmniRoute enters as consumer/validator, never as source of domain types in Warp Prism core.

---

## B. Epic amendments — applied in place

Files amended (same paths, no parallel versions): `EPIC-19…25`, `EPIC-OR`, plus annotations on `PLAN-task1807-const-migration-containment.md` (superseded-by-reality), `PLAN-03-review-drain.md` (W1 evidence note), and a verdict banner on `STORIES-ads-to-ids-epics-19-25.md` (stories remain the coverage genome, NOT a queue).

---

## C. Revised dependency DAG

```
EPIC-18 (visual reset) ── gates ONLY ──► visual baseline v2, goldens, UI-visible acceptance, 19-E baseline freeze
                                              │
                    ┌─── 19 gate (A charter + B boundaries + C topology) ───┐
                    │                                                        │
              20-A interaction inventory                          21-A runtime-consumer audit
                    │                                                        │
              20-B IDS candidate kernel  ──parallel──►         21-B experimental contracts + fakes/testkit
                    │                                                        │
              20-C IDS proof/promotion                            21-C bindings proof (IDS ∥ Runtime CONVERGE)
                                                                             │
      22-A FRB candidate spike (build-matrix part may parallel 21-B)
                                                                             │
      22-B minimal bridge substrate (rust/warp_bridge_core + warp_bridge_frb)
                                                                             │
      22-C integration lab parity (FRB ONLY — single hypothesis)
                                                                             │
      22-D INTEGRATION READINESS / L1 EXIT GATE  ──► Integration-Lab retrospective (optional, distinct from pilot harvest)
                                                                             │
      FIRST REAL PRODUCT PILOT (OmniRoute vertical slice, parent-gated)
                                                                             │
      PILOT HARVEST / RETROSPECTIVE (mandatory)
                                                                             │
      REWRITE READINESS / L2 GATE ──► 23A/23B, 24, 25 crystallization eligibility
```

**Maturity ladder (corrected A1, 2026-08-31):** L0 ADS (done) → **L1 Integration-Capable** (EPIC-19..22; exit = 22-D Integration Readiness gate) → **L2 Rewrite-Capable** (one successful REAL product pilot + post-pilot harvest; exit = Rewrite Readiness gate) → L3 Rewrite Factory (post-L2 only). 22-D is NOT "Rewrite Readiness". An Integration-Lab retrospective may follow 22-D but is a distinct event from the post-product-pilot harvest; the first real pilot precedes the L2 gate.

Key properties: no artificial 18→19 serialization; IDS and Runtime independent until bindings; FRB below a replaceable adapter boundary; everything post-pilot is conditional.

---

## D. Authority classification

| Artifact | Classification |
|---|---|
| S19-01/02 (charter amend, layer law), S19-05 hygiene rules, boundary matrix | **canonical decision** (upon 19-gate sign-off) |
| EPIC-19 A–D, EPIC-20 A–C, EPIC-21 A–D, EPIC-22 A–D | **execution candidate** (task compression §E) |
| 4 runtime contracts, IDS kernel primitives | **experimental hypothesis** (lifecycle-gated; none STABLE today) |
| 23A | **conditional future work** (post-22-D) |
| 23B, EPIC-24, templates/scaffolder, EPIC-25, EPIC-OR | **hold / policy intent / research intent** |
| Skill-lobe/section-gateway, parent skill topology, RPC/daemon lab mixing, 5→2 crate remainder, FRB 2.13 pre-pin, auto-scroll-in-EventStream, polling/retry-in-contracts, BackgroundJob/media/jobs crates | **rejected from current scope** (ledger §G with reactivation evidence) |

---

## E. Candidate task compression (33 stories → 16 executable tasks, split 19-D/E per user A2)

> Planning genome stays as stories; execution queue is compressed. Not promoted yet — 19-gate sign-off required; plus W1 drain (1805 human gate) before 19-E.

| Task | Content (stories folded in) |
|---|---|
| **19-A** Charter v2 + ADR + scoped AGENTS.md alignment | S19-01 (amend `docs/design/charter.md`; tattoos; supersession; preservation) — AGENTS.md edit authorized in minimal scope (2026-09-01 sign-off) |
| **19-B** Boundaries + dependency law + harness v2 (now-enforceable subset) | S19-02 + checks 8–9 (registry scope, root hygiene) |
| **19-C** Topology + workspace + model-ownership rules | S19-04 (2-crate Rust, packages naming, Cargo-placement open ADR at 22-B, Runtime≠Presentation field discipline) |
| **19-D** State-based declutter + root sweep | S19-05 — does NOT depend on Task 1805 (A2 split) |
| **19-E** Post-1805 visual/baseline freeze | S19-06 — depends on Task 1805 human visual gate (EXTERNAL HUMAN BLOCKER) |
| **20-A** Interaction inventory (evidence-driven) | S20-01 inventory half + S20-04 counter-examples |
| **20-B** IDS candidate kernel (Selection/Inspection/Command-intent; experimental) | S20-01 kernel half + S20-02 + S20-03 |
| **20-C** IDS proof + promotion review | S20-05 + lifecycle |
| **21-A** Runtime-consumer/source audit | maps real consumers (EventStream≈2, Graph≈2 same-domain, Health=0, Command=ad-hoc×3 apps) |
| **21-B** Experimental contracts + fakes + testkit | S21-01 (presentation-purged) + S21-02 + S21-05 |
| **21-C** Bindings proof (convergence point) | S21-03 + S21-04 DoD (6/7, Rust deferred to 22) |
| **21-D** Promotion-gate evidence pack | lifecycle PROPOSED→EXPERIMENTAL→PROVEN→STABLE rules + S24-02 formula folded where executable |
| **22-A** FRB candidate compatibility/build spike | S22-01(candidate-version process) + S22-02 — kill-gate |
| **22-B** Minimal bridge substrate | S22 topology (2 crates) |
| **22-C** Integration lab parity (FRB only) | S22-03(amended) + S22-04 |
| **22-D** Integration Readiness / L1 exit gate + harvest checklist | S22-05 + pt-22 questions pre-attached |

---

## F. Boundary enforcement matrix (doc + readiness-classified checks)

Existing 7 checks (all keep). Classification per user directive B (2026-09-01): `MECHANIZABLE_NOW` (possible) vs `READY_TO_ENFORCE_NOW` (deterministically correct as hard gate today) vs `PHASED` (later, when substrate exists). A grep that is merely implementable is NOT automatically a hard gate — hard gates must be deterministic, not just easy.

| # | Proposed check | Classification (2026-09-01) | Rationale |
|---|---|---|---|
| 8 | `PrismTokenRegistry mutators called only by theme_editor organism` — grep `setColor\|resetRole` outside `prism_token_registry.dart` + `theme_editor/` | **READY_TO_ENFORCE_NOW** | Mutation API verified exact (`setColor/resetRole/reset`, registry file:113-147); sole current caller verified `prism_theme_editor.dart`; allowlist is precise (2 paths) — deterministic |
| 9 | `Repository root contains no fix_/tmp_/patch_/append_/snippet_ scratch files` — glob root for ~22 known patterns | **READY_TO_ENFORCE_NOW** (in 19-D after sweep — gate and sweep ship together; harness check lands with the cleanup so CI never red-lights on pre-existing debt) | Pattern list is exact and closed; no semantic judgment needed |
| 10 | `No local structural re-hex: raw Color(0x outside tokens/` | **MECHANIZABLE_NOW — NOT a hard gate yet** | 9 raw occurrences today incl. 4 media-overlay placeholders that need migration first; without a semantic allowlist (fixtures/gallery-swatch exemptions) it produces false positives → soften to report-lint in 19-B, promote to hard gate in 19-D post-migration |
| 11 | `warp_prism_ui does not import flutter_rust_bridge` | PHASED (trivially greppable once FRB enters repo) | substrate absent |
| 12 | `warp_prism_runtime contains no Flutter imports (package:flutter, Widget, BuildContext, Color, Offset)` | PHASED | package absent |
| 13 | `warp_prism_interaction is pure Dart` | PHASED | package absent |
| 14 | `warp_prism_bindings is not imported by warp_prism_ui` | PHASED | package absent |
| 15 | `warp_prism_adapter_frb is not imported by ui/interaction/runtime` | PHASED | adapter absent |
| 16 | `Core packages contain no domain types` (Ganthritor/Cersei/OmniRoute/CyberCore identifiers in runtime/interaction/bindings/testkit) | PHASED | packages absent |
| 17 | `FRB generated files are not imported directly by widgets` | PHASED | codegen absent |

Law (doc, `docs/architecture/layer-contracts-v2.md` when 19-B lands): ui = presentation/tokens/a11y/mechanics ONLY; interaction = reusable semantics, pure Dart; runtime = backend-agnostic contracts, semantic DTOs, NO presentation; bindings = thin projection, MAY depend ui+interaction+runtime, MUST NOT own backend logic; adapter_frb = MAY depend FRB, MUST NOT be imported by widgets; rust core = transport-independent, no Flutter assumptions. Bypass is an architectural FEATURE: products MAY keep domain-specific contracts local.

---

## G. Deferred / rejected idea ledger (nothing forgotten)

| Idea | Disposition | Why | Reactivation evidence |
|---|---|---|---|
| Skill Section/lobe promotion policy, bounded hopping | REJECTED from WP → **parent Ganthritor handoff** | harness concept; WP has zero own skills (parent symlink) | parent opens a harness-governance task citing `ads-to-ids.md` Sec 29-30 |
| 4 parent-canonical skills (warp-prism-development, flutter-rust-integration, performance-engineering, rewrite-with-warp-prism) | DEFER → parent handoff | `.agents/skills/` is parent-canonical; WP cannot create unilaterally | parent harness governance; flutter-rust-integration becomes real during 22-C |
| Rust crates events/jobs/graph/media/telemetry as separate crates | REJECTED now | concept ≠ crate; no isolation motive yet | dependency isolation / independent lifecycle / build isolation need demonstrated |
| Lab with RPC/daemon/remote-worker/hybrid/Cersei/Ganthritor/OmniRoute | REJECTED from first lab | single-hypothesis falsifiability | after 22-D pass, a second lab for daemon/RPC if embedded-mode shows limits |
| FRB pinned at 2.13.0 | REJECTED pre-spike | version was conversation-time current, never tested | 22-A spike outcome (ADOPT + exact quadruple pin) |
| auto-scroll/follow-tail/viewport in EventStream | REJECTED | presentation policy; lives in widgets today (file:line evidence) | never — wrong layer by definition |
| poll-every-X / refresh-on-focus / exponential retry inside HealthSource/AsyncCommand | REJECTED | composition/policy layer | strong proof of need in ≥2 real consumers after pilots |
| PrismQuery/PrismNavigationIntent/PrismViewportState as kernel primitives | DEFER | no recurrence evidence (viewport = GraphCanvas mechanics; navigation = app GoRouter) | 20-A inventory finds ≥2 distinct consumers/domains |
| BackgroundJob contract + media/data-plane crates | DEFER | zero consumers; data-plane heavy | Warpblade/media pilot need (post-L2) |
| 4 templates (flutter-rust-app/daemon/hybrid/plugin) + `prism add` scaffolder + resolver machinery + 23B full registry/manifest | HOLD (intent) | crystallize AFTER recurrences, not before | harvest/retrospective of first real pilots (pt 22) |
| prism_aliases.dart split into per-family barrels | HOLD (healthy today: 1417 lines, 100+ aliases, works) | no empirical pain | alias churn friction measured during v2 work |
| PLAN-task1807 const-migration containment | SUPERSEDED-BY-REALITY (annotated in place) | builders already absorbed the const→getter migration; registry live | n/a — historical value only |
| EPIC-00..18 = "historical corpus" numbering rule | REJECTED | 36 active non-terminal tasks live under EPIC-18 | never — replaced by state-based sets |

---

## Success-criteria self-check (user's 14)

1. Harness concepts removed from WP (S19-03 rewritten; parent handoff) ✅
2. EPIC-19–22 reflect repo reality (registry/theme/fonts landed; rust/IDS/runtime greenfield; consumer counts recorded) ✅
3. IDS ∥ Runtime independent, converge at bindings ✅
4. Runtime contracts presentation-purged (auto-scroll/polling/retry out) ✅
5. FRB below replaceable adapter boundary (MUST-NOTs + deferred checks 11/15/17) ✅
6. Rust topology 2 crates (concept ≠ crate rule) ✅
7. Lab = single FRB hypothesis ✅
8. EPIC-23–25 classified CONDITIONAL/HOLD/RESEARCH without losing intent (ledger) ✅
9. Declutter state-based ✅
10. Experimental→stable lifecycle explicit ✅
11. Task set compressed 33 → 15 ✅
12. Mechanizable checks identified (3 now, 7 phased) ✅
13. Every removal has provenance/rationale/reactivation (ledger §G) ✅
14. Next step = implementation evidence (19-gate sign-off + W1 drain, then 19-A..D) ✅

**Open items for the user (decide before 19-gate):**
1. AGENTS.md identity/scope edit (protected file) — required by 19-A; needs explicit authorization.
2. Cargo placement (root vs `rust/`) — stays an OPEN ADR decided in 22-B with build evidence.
3. W1 drain: 1805 human screenshot sign-off is the single blocking act for EPIC-18 closure.
