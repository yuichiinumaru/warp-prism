# Warp Prism — Child-Project Charter (v2.1)

> **Status**: Active charter
> **Version**: 2.1.0
> **Authors**: Task 1101 (v1 baseline), Task 1810 / EPIC-19 (v2 mission & architecture),
> epoch reset 2026-09-27 (consumer family + topology actualization)
> **Date**: 2026-09-27 (v2.1 amendment)
> **Parent**: Ganthritor monorepo

---

## 1. Purpose and Mission

Warp Prism is a **Ganthritor child project** providing a unified, compositional Flutter design and runtime integration system for production-grade operational applications.

### 1.1 Core Mission Framing

> "Warp Prism is a compositional design and integration system for Flutter applications: a visual vocabulary, an interaction vocabulary, and a small set of runtime contracts with a Rust-first integration golden path."

> "It does not implement application backends. It standardizes the interfaces through which applications expose backend capabilities to UI."

Warp Prism standardizes the tripartite architectural foundation for Flutter frontends across the Ganthritor ecosystem:

1. **Visual Design System (ADS)**: Atomic design tokens, atoms, molecules, organisms, templates, and theme engine implemented in `packages/warp_prism_ui`.
2. **Interaction Design System (IDS)**: Reusable interaction semantics, gesture models, selection behaviors, and navigation flow primitives.
3. **Runtime Integration Contracts**: Backend-agnostic UI↔runtime contract interfaces (such as `EventStream`, `AsyncCommand`, `HealthSource`, and `GraphSource`) with a high-performance, Rust-first integration golden path via a replaceable `flutter_rust_bridge` (FRB) adapter.

Warp Prism lives under `warp-prism/` in the Ganthritor repository. It inherits reusable skills and agent definitions from the parent through symlinks (see `AGENTS.md` §2) while maintaining its local task namespace, design documents, changelog, reports, and profiles.

---

## 2. Product Identity

| Attribute | Value |
|-----------|-------|
| **Project name** | Warp Prism |
| **System role** | Compositional Flutter design + integration system (ADS + IDS + Runtime Contracts) |
| **Technology** | Flutter (desktop-first & cross-platform) + Rust golden path |
| **First consumers** | Intended consumer family: Warpblade, Tempest, Hyperion, Sentry (see `MISSION.md` §3). Catalog (`apps/catalog`) + host-exercise harness are owned proof laboratories. Observatory / CyberCore are not product destinations — classified on evidence, never by assumption. |
| **Integration model** | Backend-agnostic runtime contracts; Rust integration via replaceable FRB adapter |
| **Backend policy** | Application backends remain product-local; Warp Prism defines standardized UI↔backend interfaces |
| **Write policy** | Fixture-backed and contract-gated; live mutations only through explicit runtime contracts |
| **Visual direction** | Ultradark obsidian glass, 5% hacker, 5% protoss — restrained, serious, command-center aesthetic |
| **Proof target** | ADS Gallery / Catalog proves design system fitness; contract test suites prove runtime adapter compliance |

---

## 3. Scope and Boundaries

### 3.1 In Scope

- **Reusable Flutter ADS package (`warp_prism_ui`)**: Presentation-pure tokens, atoms, molecules, organisms, templates, and theme management — app-agnostic, testable, and governed by catalog + widget test + semantics coverage gates.
- **Interaction Design System (IDS)**: Reusable interaction semantics, focus/keyboard traversal patterns, multi-select, and viewport interaction models.
- **Backend-Agnostic Runtime Contracts**: Core contract abstractions (`EventStream`, `AsyncCommand`, `HealthSource`, `GraphSource`) defining how Flutter UI communicates with backends without coupling to specific implementations.
- **Rust Integration Golden Path**: Replaceable `flutter_rust_bridge` (FRB) adapter bridging Dart runtime contracts to high-performance native Rust services.
- **Consumer Applications**: Warp Prism does not host product frontends. The
  intended consumer family is Warpblade, Tempest, Hyperion, and Sentry
  (see `MISSION.md` §3 and `docs/bridge/README.md`). A missing Warp Prism
  primitive never blocks a consumer — consumers implement locally, Warp Prism
  harvests what recurs.
  - **Design System Catalog (`apps/catalog`)**: Owned proof laboratory —
    interactive component gallery proving ADS/IDS fitness, plus the connected
    bridge lab proving the runtime/FRB path.
  - **Historical in-tree apps (`apps/observatory`, `apps/cybercore`)**: Not
    product destinations. Classified by current function (proof surface,
    fixture/demo, legacy compatibility surface, still-valid consumer, or
    retirement candidate) on evidence.
- **Design, Architecture, and Governance Documentation**: Charters, layer matrices, topology definitions, and ADRs under `docs/design/`, `.project/architecture/`, and `docs/governance/`.

### 3.2 Out of Scope (Non-Goals)

| Non-Goal | Rationale |
|----------|-----------|
| **Application backend implementation** | Warp Prism does not build application backends. Domain business logic, persistence services, and service orchestrations remain product-local. |
| **Ontological Rust coupling in UI/Core** | FRB and Rust are replaceable adapters. Generic Warp Prism contracts and `warp_prism_ui` must never depend directly on Rust or FFI. |
| **SQLite or client-side durable state** | Warp Prism core does not embed local SQLite databases. Durable state architecture belongs in product-specific backends per Ganthritor policy. |
| **Tamagui / Ivisa code porting** | Historical Ivisa/Tamagui archaeology (Task 8240) is reference-only. Component state matrices are harvested; TSX code is not ported. |
| **Building consumer frontends inside Warp Prism** | Warp Prism is a library + proof-laboratory project. Product frontends live in product repositories; Warp Prism harvests what recurs. |
| **Full product frontend migration into this repo** | No product frontend is migrated into Warp Prism. Historical in-tree apps are classified on evidence (proof / fixture / legacy / consumer / retirement candidate). |
| **Generic SaaS pastel styling** | Visual identity remains ultradark obsidian glass with restrained hacker/protoss accents. |

### 3.3 Supersession and Preservation Invariants

#### Supersession of Bootstrap Runtime Restriction
In the bootstrap epoch (v1), Warp Prism was constrained by a strict "MUST NOT do runtime integration" rule to focus exclusively on initial ADS widget prototyping. Under Warp Prism v2 (EPIC-19), this restriction is **superseded at the monorepo level**: Warp Prism now explicitly charters runtime contract interfaces and native bridge adapters.

However, the restriction remains **strictly invariant for `warp_prism_ui`**:
- `warp_prism_ui` must remain 100% presentation-pure.
- `warp_prism_ui` MUST NOT depend on FRB, Rust crates, networking, disk persistence, or live backend orchestration.
- Runtime contracts and interaction behaviors live in dedicated, decoupled packages/modules.

#### Architectural Preservation Invariants
1. **`Prism*` Public API**: Unified public export prefix (`PrismButton`, `PrismCard`, `PrismTheme`, etc.) remains the standard public surface.
2. **`DS` Internal Namespace**: Internal implementation classes and legacy foundations remain cleanly encapsulated under `DS*`.
3. **ADS Gallery / Catalog**: The design system catalog must always build and showcase components independently of live backend services.
4. **Package Purity**: Strict layer boundaries between presentation (`warp_prism_ui`), interaction semantics, runtime contracts, and platform adapters.
5. **Golden, Semantics, and Boundary Gates**: Automated widget regression tests, accessibility semantics checks, and import boundary enforcement remain mandatory.
6. **Fixture-First Mode**: All UI surfaces and runtime contract consumers must support standalone execution via deterministic fixtures/mocks.

---

## 4. Architecture Decision Record (ADR)

### ADR-0001: Evolution to Warp Prism v2 (ADS + IDS + Runtime Integration System)

#### Context
In v1 (June 2026), Warp Prism was chartered primarily as a read-only Flutter ADS component library and ASW Observatory prototype, with an explicit prohibition against runtime integration. As the design system matured through EPIC-18 (Black Obsidian visual contract, token registry, typography, and test harnesses), two key requirements emerged:
1. Real operational Flutter applications require standardized interaction semantics (keyboard shortcuts, selection models, flow coordination) that belong above pure visual widgets.
2. Applications require a clean, high-performance way to connect Flutter UI with native domain engines (especially Rust-based daemons and services) without leaking domain code into the design system.

Without an architectural evolution, either each application would reinvent bespoke backend bridges and interaction models, or runtime integration work would contradict the v1 charter.

#### Decision
We evolve Warp Prism into a **compositional design and integration system** comprising three distinct layers:
1. **Visual Design System (ADS)**: Pure presentation components and tokens (`warp_prism_ui`).
2. **Interaction Design System (IDS)**: Reusable interaction semantics and gesture/flow behaviors.
3. **Runtime Contracts**: Standardized, backend-agnostic UI↔runtime interfaces (`EventStream`, `AsyncCommand`, `HealthSource`, `GraphSource`), accompanied by a Rust-first integration golden path using `flutter_rust_bridge` (FRB) as a replaceable adapter.

We supersede the bootstrap-era "MUST NOT do runtime integration" restriction at the monorepo level, while enforcing that `warp_prism_ui` retains presentation purity. Warp Prism standardizes interfaces, leaving application backend implementations product-local.

#### Consequences
- **Positive**:
  - Establishes a cohesive architectural standard for Flutter frontends across Ganthritor.
  - Enables high-performance native integration (Rust via FRB) through clean, replaceable contract boundaries.
  - Preserves `warp_prism_ui` purity, ensuring the widget catalog remains lightweight, fast, and fully testable without native dependencies.
  - Guarantees fixture-first testability across all visual and interactive components.
- **Negative / Trade-offs**:
  - Expands monorepo scope, requiring rigorous package boundary enforcement to prevent layer leaks.
  - Requires maintaining contract compatibility between Dart interfaces and native Rust bridge implementations.

---

## 5. Historical Context and Provenance

### 5.1 Voidframe (Superseded)

The project was originally conceived under the codename **Voidframe**. Key historical artifacts:
- **Task 8210**: Control-surface inventory that remains useful as historical evidence.
- **Task 8220**: Defined a prior `Voidframe` Flutter ADS kernel concept (superseded by Warp Prism).
- **Task 8230**: Defined a CyberCore pilot concept under Voidframe (superseded by EPIC-11).

`Voidframe` is **historical naming only**. No new packages, apps, or public components shall use the `voidframe_*` prefix. See `docs/design/naming.md` for the full supersession policy.

### 5.2 Cybernetics Core Design-System Evidence

- **Task 0583**: Documented Cybernetics Core admin design-system baseline.
- **Task 0590**: Implemented Cybernetics Core admin design-system baseline.

Both provide baseline evidence that Warp Prism's CyberCore pilot mirrors and validates against.

### 5.3 Evolution from v0/v1 to v2

- **v0 Baseline**: Initial prototype Flutter code under `lib/` with basic screens, parsers, and tokens (`docs/draft.md`).
- **v1 Epoch (EPIC-00 to EPIC-18)**: Melos monorepo structuring, `warp_prism_ui` maturation, Black Obsidian visual contract (`docs/design/black-obsidian-visual-contract.md`), `PrismTokenRegistry`, `DSTheme.dark()`, Rajdhani font bundling, and boundary gate test harness.
- **v2 Epoch (EPIC-19+)**: Compositional ADS + IDS + Runtime Integration System with Rust golden path, formalized layer contracts, and multi-consumer integration.

---

## 6. Governance and Monorepo Architecture

### 6.1 Parent/Child Boundary

Parent-canonical reusable surfaces (skills, agents, agent definitions) are symlinked from the Ganthritor root. Child-local surfaces (`AGENTS.md`, tasks, changelog, reports, design docs, profiles) are owned by Warp Prism.

### 6.2 Task Namespace

Warp Prism owns `.project/tasks/` across five canonical kanban lanes (`00-planning/`, `01-open/`, `02-doing/`, `03-review/`, `04-completed/`). Lifecycle is determined strictly by lane directory.

### 6.3 Monorepo Package Topology

| Member Path | Role | Layer / Constraint |
|-------------|------|-------------------|
| `packages/warp_prism_ui` | Reusable Flutter ADS | Presentation-only. Zero FRB/runtime/backend dependencies. |
| `packages/warp_prism_interaction` | Interaction Design System | Reusable user-intent semantics. Pure Dart. |
| `packages/warp_prism_runtime` | Runtime Contracts | Backend-agnostic UI↔runtime interfaces. Pure Dart. |
| `packages/warp_prism_bindings` | Thin projections | Contracts → Prism presentation. No backend logic. |
| `packages/warp_prism_testkit` | Fakes + conformance suites | One fake + one suite per contract. |
| `packages/warp_prism_adapter_frb` | FRB adapter | The ONLY Dart package importing `flutter_rust_bridge`. |
| `packages/warp_prism_host_exercise` | Host-exercise harness | Smoke/crawl/fuzz proof runner. |
| `rust/warp_bridge_core` | Rust domain core | Transport-independent. Zero transport deps. |
| `rust/warp_bridge_frb` | Rust FRB projection | Transport layer (FRB + tokio). |
| `apps/catalog` | Owned proof laboratory | Gallery + connected bridge lab. |
| `apps/observatory`, `apps/cybercore` | Historical in-tree apps | Pending evidence-gated classification — not product destinations. |

---

## 7. Source Evidence

| Source | Relevance |
|--------|-----------|
| `AGENTS.md` §1 | Scoped constitution defining v2 scope, contracts, and boundaries |
| `.project/archive/epoch-reset-manifest.md` | Per-artifact disposition of the pre-reset planning corpus (EPIC-00..26, roadmaps, story packets) + harvested invariants |
| `Task 1810` (task ledger, lane-neutral reference — see `.project/tasks/tasklist.md` for current location) | Task 1810 specification and exit conditions |
| `docs/design/black-obsidian-visual-contract.md` | Live visual contract specification |
| `docs/governance/promotion-state-model.md` | Task promotion and gate lifecycle model |
| `docs/prompt.txt` | Original product contract for the ASW Observatory |
| `docs/research.md` | Research synthesis: unified harness map + execution ledger |
| `docs/mock-workspace-corpus-contract.md` | Mock data naming and schema contract |
| Task 1101 (completed) | v1 Charter and naming convergence baseline |
| Task 1805 / EPIC-18 | Black Obsidian visual contract & token foundation |
| Task 8210 / 8220 / 8230 / 8240 | Historical Voidframe & Ivisa/Tamagui evidence |
| Task 0583 / 0590 | CyberCore design system evidence |
