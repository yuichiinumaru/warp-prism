# Warp Prism v2 — Package Topology & Workspace Coordination

> **Status**: Active architecture specification & decision record
> **Author**: Task 1812 — Package Topology + Workspace Coordination
> **Date**: 2026-09-01
> **Milestone Alignment**: M01 — Warp Prism v2: L1 Integration-Capable
> **Depends on**: Task 1810 (Charter v2 ADR), Task 1811 (Layer Contracts v2)
> **Blocks**: Task 1818 (Runtime Consumer Audit), Task 1822 (FRB Spike)

---

## 1. Executive Summary & Objective

This document defines the canonical package and crate topology for **Warp Prism v2**, establishing the naming conventions, layer ownership boundaries, dependency direction laws, and workspace coordination model across Dart/Flutter packages and Rust crates.

---

## 2. Dart Package Registry (v2)

Warp Prism v2 organizes Dart and Flutter code into six modular packages, each with strict single-responsibility boundaries:

| Package | Target Directory | Tier / Technology | Ownership & Boundary Rules |
|---------|------------------|-------------------|-----------------------------|
| `warp_prism_ui` | `packages/warp_prism_ui` | Flutter ADS | **Presentation-only**: tokens, atoms, molecules, organisms, templates, gallery. **MUST NOT** import FRB, backend, domain, or persistence. |
| `warp_prism_interaction` | `packages/warp_prism_interaction` | Pure Dart + Flutter IDS | **Interaction semantics**: gesture models, focus traversal, selection state. Pure Dart core with optional Flutter gesture adapters. |
| `warp_prism_runtime` | `packages/warp_prism_runtime` | Pure Dart Contracts | **Backend-agnostic runtime contracts**: `EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`. **NO** Flutter imports, **NO** presentation policy. |
| `warp_prism_bindings` | `packages/warp_prism_bindings` | Flutter Projection | **Projection layer**: thin wiring between UI, interaction semantics, and runtime contracts for consumer application convenience. |
| `warp_prism_testkit` | `packages/warp_prism_testkit` | Dart Test Fakes | **Verification harnesses**: in-memory test doubles, contract compliance suites, and deterministic fixture drivers for runtime contracts. |
| `warp_prism_adapter_frb` | `packages/warp_prism_adapter_frb` | Dart + FRB Adapter | **Native adapter**: Flutter Rust Bridge projection implementing `warp_prism_runtime` contracts. The **ONLY** Dart package allowed to import FRB. |

---

## 3. Dependency Direction Law

Dependencies flow strictly inward toward pure contracts. No cyclic dependencies or layer bypasses are permitted.

### 3.1 Dependency Diagram

```
                 ┌────────────────────────┐
                 │  Consumer Applications │ (apps/observatory, apps/catalog, apps/cybercore)
                 └───────┬───────┬────┬───┘
                         │       │    │
            ┌────────────┘       │    └─────────────────┐ (optional native path)
            ▼                    ▼                      ▼
┌──────────────────┐   ┌───────────────────┐   ┌────────────────────────┐
│  warp_prism_ui   │   │warp_prism_bindings│   │ warp_prism_adapter_frb │
│(presentation-only│   │  (UI ↔ runtime)   │   │      (FRB adapter)     │
└──────────────────┘   └───┬─────────────┬─┘   └───────────┬────────────┘
                           │             │                 │
                           ▼             ▼                 │
              ┌─────────────────────┐  ┌───────────────────┴────┐
              │warp_prism_interact- │  │   warp_prism_runtime   │
              │        ion          │  │  (pure Dart contracts) │
              └─────────────────────┘  └───────────▲────────────┘
                                                   │
                                       ┌───────────┴────────────┐
                                       │   warp_prism_testkit   │
                                       │  (in-memory test fakes)│
                                       └────────────────────────┘
```

### 3.2 Invariant Rules

1. `ui` ← `apps`: Consumer applications import presentation components from `warp_prism_ui`.
2. `bindings` → {`ui`, `interaction`, `runtime`}: `warp_prism_bindings` coordinates visual components, interaction behaviors, and runtime contracts.
3. `adapter_frb` → {`runtime`}: `warp_prism_adapter_frb` implements interfaces from `warp_prism_runtime`.
4. `apps` → {`ui`, `bindings`, `adapter_frb` (optional)}: Applications compose UI, bindings, and native adapters.
5. `interaction` → ∅: Pure Dart interaction semantics have no internal Warp Prism dependencies.
6. `runtime` → ∅: Pure Dart runtime contracts have no internal Warp Prism dependencies.
7. `testkit` → {`runtime`, `interaction`}: Testkit verifies contract implementations.
8. **Isolation Invariant**: NOTHING may import `warp_prism_adapter_frb` except consumer applications.
9. **UI Purity Invariant**: `warp_prism_ui` **MUST NOT** import `interaction`, `runtime`, `bindings`, `adapter_frb`, or FRB.

---

## 4. Rust 2-Crate Topology & Concept ≠ Crate Law

The native substrate is consolidated into a minimal two-crate topology under `rust/`:

| Crate | Directory | Role & Boundary Rules |
|-------|-----------|-----------------------|
| `warp_bridge_core` | `rust/warp_bridge_core` | **Transport-agnostic native core**: houses core modules (`command`, `events`, `health`, `graph`). Independent of FRB and FFI. |
| `warp_bridge_frb` | `rust/warp_bridge_frb` | **FRB bridge projection**: maps native core types and streams to Dart via `flutter_rust_bridge`. The **ONLY** crate depending on FRB. |

### 4.1 The "Concept Existence ≠ Crate Existence" Law

Warp Prism enforces the architectural principle: **concept existence ≠ crate existence**. Domain concepts (`command`, `events`, `health`, `graph`) are Rust **modules** within `warp_bridge_core`, not independent crates.

A module is promoted to an independent crate **only** when at least one demonstrated motive is proven:
1. **Dependency isolation**: requiring heavy third-party dependencies not needed by the core.
2. **Independent lifecycle / versioning**: evolving on an asynchronous release cadence.
3. **Build isolation**: enabling discrete compilation caching to prevent monolithic rebuilds.
4. **Independent reuse**: consuming the capability from non-Warp-Prism binaries.
5. **Compilation boundary**: enforcing formal FFI / ABI stability boundaries.

Future capabilities (`jobs`, `media`, `telemetry`) remain module candidates within `warp_bridge_core` until crate promotion criteria are satisfied.

---

## 5. Model-Ownership Rule (Runtime ≠ Presentation)

To prevent domain leakage and preserve presentation purity, Warp Prism mandates strict model separation:

- **Runtime & Semantic Models** (in `warp_prism_runtime`, `warp_bridge_core`): Own semantic properties, IDs, status states, node relationships, metrics, and command payloads.
- **Presentation Models** (in `warp_prism_ui`, `warp_prism_bindings`): Own layout coordinates (`position: Offset`), viewport bounds, expanded states, render styles, and animation controllers.
- **Rule**: Semantic graph and runtime models own **NO** layout fields. Spatial and presentation attributes remain strictly within the UI and bindings layers.

---

## 6. Workspace Coordination & Open ADR

### 6.1 Toolchain Coordination

- **Dart / Flutter**: Managed via Melos workspace commands.
- **Rust**: Managed via Cargo workspace commands.
- **Root Orchestration**: Top-level scripts (`warp validate` / Melos scripts) coordinate cross-toolchain checks.

### 6.2 Melos Configuration Reality

Root `pubspec.yaml` configures the Dart workspace (`workspace: [packages/**, apps/**]`) and embeds Melos script definitions (`melos: ...`). Physical filesystem verification confirms that `melos.yaml` does not exist as an independent root file; workspace coordination relies on the embedded pubspec configuration.

### 6.3 RESOLVED ADR: Cargo Workspace Placement

- **Context**: The Rust workspace configuration can be placed at the repository root (`Cargo.toml`) or nested within the native directory (`rust/Cargo.toml`).
- **Status**: **RESOLVED** in **Task 1822** (see `docs/reports/1822-frb-spike-kill-gate-report.md` §6).
- **Decision**: Adopted nested `rust/Cargo.toml` based on empirical comparative build evidence (zero repo-root pollution, dedicated CI caching, and clean toolchain isolation from Melos/pubspec).

---

## 7. Source Evidence & References

| Source | Relevance |
|--------|-----------|
| `AGENTS.md` §1, §5, §7 | Warp Prism governance, scope, and product constraints |
| `pubspec.yaml` (root) | Root Dart workspace & Melos script configuration baseline |
| `packages/warp_prism_ui/pubspec.yaml` | Existing ADS package definition |
| `docs/tasks/00-planning/EPIC-19-warp-prism-v2-foundation.md` | S19-04 package topology charter |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Monorepo structure and boundary history |
| `docs/design/charter.md` | Tripartite mission (ADS + IDS + Runtime contracts) |
