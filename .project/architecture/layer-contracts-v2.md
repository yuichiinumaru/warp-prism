# Warp Prism v2 — Layer Contracts & Boundary Law

> ## ⚠️ SUPERSEDED (2026-09-28) — RETAINED AS HISTORICAL EVIDENCE ONLY
>
> **This is no longer a semantic owner of the layer-contract law.** The
> canonical matrix is **[`layer-contracts.md`](layer-contracts.md)** in this
> same directory. Where this document and `layer-contracts.md` disagree,
> `layer-contracts.md` governs.
>
> **Why it was orphaned**: the 2026-09-27 epoch reset authored a new
> `docs/architecture/layer-contracts.md` without diffing it against this
> document, leaving two live owners of the same normative law. The reset's
> path (`docs/architecture/`) was then closed by the operator decision of
> 2026-09-28, and both files now live side by side here. Only one may own the
> law; this one is retired.
>
> **Citations elsewhere in this directory that point at `layer-contracts-v2`
> are historical provenance, not current authority** — e.g.
> `runtime-consumer-audit.md` cites `layer-contracts-v2 §3.2`, `§2`, `§4.3`.
> Those citations are preserved verbatim and are not rewritten; they record
> what the law said when the audit was written.
>
> ### What this document uniquely held that `layer-contracts.md` dropped
>
> | Attribute | v2 (here) | v3 (`layer-contracts.md`) |
> |---|---|---|
> | Per-check **enforcement status** (`ENFORCED NOW` vs `PHASED`) | present, 17 rows | **dropped — flattened** |
> | Per-check **provenance** (which Task added each check) | present | dropped except one parenthetical |
> | Declared check count | 17 | 16 |
> | Actual checks in `boundary_test.dart` | — | **15** |
>
> The lost status column is a real semantic regression: it is what told a reader
> which law was an **active hard gate** versus merely **specified**. Recovering
> it is open work, not a claim this document makes.
>
> ### Known drift recorded here, not repaired here
>
> `layer-contracts.md` §10 item 16 ("`bindings` never imports FRB generated
> surfaces") is **not implemented** in `boundary_test.dart` — the harness
> registers 15 checks, not 16. The reset's own §10 preamble requires a row with
> no mechanical check to be marked as documentation-only; that marking was
> omitted. Corrected in `layer-contracts.md` on 2026-09-28.

> **Status**: SUPERSEDED — historical evidence only (was: Active architecture
> specification & boundary law)
> **Author**: Task 1811 — Layer Boundaries + Dependency Law + Boundary Harness v2
> **Date**: 2026-09-01
> **Superseded by**: `.project/architecture/layer-contracts.md` (2026-09-27,
> rehomed 2026-09-28)
> **Milestone Alignment**: M01 — Warp Prism v2: L1 Integration-Capable
> **Depends on**: Task 1810 (Charter v2 ADR), Task 1812 (Package Topology)
> **Blocks**: Task 1818 (Runtime Consumer Audit), Task 1822 (FRB Spike)

---

## 1. Executive Summary & Purpose

Warp Prism v2 is a compositional design and integration system for Flutter applications. It provides:
1. **Visual Design System (ADS)**: Presentation-only tokens, atoms, molecules, organisms, and templates.
2. **Interaction Design System (IDS)**: Reusable interaction semantics, gesture models, selection behaviors, and keyboard navigation.
3. **Runtime Contracts**: Backend-agnostic UI↔runtime interfaces (`EventStream`, `AsyncCommand`, `HealthSource`, `GraphSource`) with a high-performance, Rust-first integration golden path via `flutter_rust_bridge` (FRB).

This document establishes the **canonical layer contracts** and **MUST / MAY / MUST NOT boundary law** across all packages, crates, and consumer layers in the Warp Prism ecosystem. It serves as the authoritative specification against which automated boundary harnesses, static analyzers, and code reviews enforce layer integrity.

---

## 2. Canonical Layer Contract Matrix

The following matrix governs the responsibilities, permitted capabilities, and strict prohibitions for each layer:

| Layer | MUST | MAY | MUST NOT |
|---|---|---|---|
| `warp_prism_ui` | • Provide pure presentation components (tokens, atoms, molecules, organisms, templates, gallery)<br>• Maintain 100% fixture-backed standalone testability<br>• Enforce token-first theming and accessibility (WCAG AA) | • Depend on Flutter framework (`package:flutter`)<br>• Expose visual customization parameters via `PrismTheme` and widget props | • **MUST NOT** import `flutter_rust_bridge` (FRB) or native FFI<br>• **MUST NOT** import `warp_prism_interaction`, `warp_prism_runtime`, `warp_prism_bindings`, or `warp_prism_adapter_frb`<br>• **MUST NOT** perform networking, disk IO, or persistence<br>• **MUST NOT** import state management engines (Riverpod, GoRouter)<br>• **MUST NOT** contain domain types or business logic |
| `warp_prism_interaction` | • Define pure interaction semantics (gesture state machines, focus traversal, selection models)<br>• Expose framework-agnostic intent and event models | • Depend on pure Dart libraries<br>• Provide optional Flutter-specific gesture / keybinding adapters | • **MUST NOT** depend on `warp_prism_runtime`, `warp_prism_bindings`, or `warp_prism_adapter_frb`<br>• **MUST NOT** import FRB or Rust crates<br>• **MUST NOT** execute backend commands or hold runtime state<br>• **MUST NOT** embed concrete widget rendering styles |
| `warp_prism_runtime` | • Define backend-agnostic UI↔runtime contract interfaces (`EventStream`, `AsyncCommand`, `HealthSource`, `GraphSource`)<br>• House semantic DTOs, identifiers, and status enums<br>• Remain pure Dart without platform binding | • Depend on pure Dart foundational packages (async, meta)<br>• Expose reactive streams (`Stream<T>`) and future-based command handlers | • **MUST NOT** import `package:flutter` (`Widget`, `BuildContext`, `Color`, `Offset`)<br>• **MUST NOT** contain presentation policy (e.g. auto-scroll, follow-tail, retry timers)<br>• **MUST NOT** import `warp_prism_ui`, `warp_prism_interaction`, `warp_prism_bindings`, or `warp_prism_adapter_frb`<br>• **MUST NOT** import FRB or native bindings |
| `warp_prism_bindings` | • Project runtime contracts into UI and interaction layers for consumer application convenience<br>• Manage stream lifecycles, widget binding hooks, and view models | • Depend on `warp_prism_ui`, `warp_prism_interaction`, and `warp_prism_runtime`<br>• Depend on Flutter state wrappers | • **MUST NOT** be imported by `warp_prism_ui`, `warp_prism_interaction`, or `warp_prism_runtime`<br>• **MUST NOT** import `warp_prism_adapter_frb` or direct FRB bindings<br>• **MUST NOT** implement backend orchestration or persistent business logic |
| `warp_prism_testkit` | • Provide deterministic in-memory test doubles, fakes, and contract compliance test suites for runtime contracts<br>• Verify adapter implementations against standard contract suites | • Depend on `warp_prism_runtime`, `warp_prism_interaction`, and Dart test libraries<br>• Provide fixture generators and mock event emitters | • **MUST NOT** be imported in production application code or core libraries<br>• **MUST NOT** require live daemons, network sockets, or external binaries |
| `warp_prism_adapter_frb` | • Implement `warp_prism_runtime` contracts via `flutter_rust_bridge`<br>• Translate native Rust bridge types to Dart semantic contract models<br>• Encapsulate FFI / bridge initialization lifecycle | • Depend on `warp_prism_runtime` and `flutter_rust_bridge`<br>• Expose native connection configuration | • **MUST NOT** be imported by `warp_prism_ui`, `warp_prism_interaction`, or `warp_prism_runtime`<br>• **MUST NOT** be imported directly by UI widgets (consumption is via runtime contracts or bindings)<br>• **MUST NOT** leak raw FRB autogenerated structs across public contract boundaries |
| Rust Core (`warp_bridge_core`) | • Implement native transport-agnostic core logic (`command`, `events`, `health`, `graph` modules)<br>• House native state machines, high-throughput buffers, and system probes | • Depend on standard Rust crates and OS capabilities<br>• Expose asynchronous Tokio streams and channels | • **MUST NOT** depend on `flutter_rust_bridge` (FRB)<br>• **MUST NOT** depend on Flutter or Dart FFI semantics<br>• **MUST NOT** embed application-specific persistence engines (e.g. SQLite) without governance |
| Rust Bridge (`warp_bridge_frb`) | • Map `warp_bridge_core` modules and types to Dart via `flutter_rust_bridge`<br>• Handle bridge FFI thread safety, stream sinks, and error propagation | • Depend on `warp_bridge_core` and `flutter_rust_bridge` | • **MUST NOT** implement standalone business logic (acts solely as a projection bridge)<br>• **MUST NOT** expose unstable raw native pointers to Dart |
| Consumer Applications (`apps/`) | • Compose `warp_prism_ui`, `warp_prism_bindings`, and platform adapters (`warp_prism_adapter_frb`)<br>• Own application-specific routing, screens, and dependency injection | • Depend on app-specific state management (Riverpod, GoRouter)<br>• Implement product-local domain contracts and backends | • **MUST NOT** import `src/` internal paths from any Warp Prism package<br>• **MUST NOT** bypass public `Prism*` APIs with unaliased `DS*` internals |
| Scaffolding & Templates | • Provide minimal, canonical reference wiring for new applications and plugins<br>• Adhere strictly to the package topology and layer matrix | • Provide fixture-first mock bindings and optional FRB configuration | • **MUST NOT** create speculative abstraction layers or unverified package templates<br>• **MUST NOT** violate layer dependency directions |

---

## 3. Global Invariants

These rules apply universally across all packages and layers in Warp Prism:

### 3.1 No Domain Types in Core Packages
Core packages (`warp_prism_ui`, `warp_prism_interaction`, `warp_prism_runtime`, `warp_prism_bindings`, `warp_prism_testkit`, `warp_prism_adapter_frb`, `warp_bridge_core`, `warp_bridge_frb`) **MUST NOT** contain domain-specific identifiers or types from Ganthritor host systems or companion projects:
- No `Ganthritor` agent or task types
- No `OmniRoute` provider, combo, or routing types
- No `CyberCore` lease, token, or administrative models
- No `Cersei` tool execution types

Domain-specific types belong strictly within consumer applications (`apps/observatory`, `apps/cybercore`) or dedicated product adapters.

### 3.2 Explicit Lifecycle Tags
All public APIs and contract interfaces must carry an explicit lifecycle annotation:
- `PROPOSED`: Draft API under active design review; subject to change without deprecation.
- `EXPERIMENTAL`: Implementation available for testing in integration labs and pilots; not guaranteed stable.
- `PROVEN`: Validated by at least two distinct consumer applications or domains; stable semantics.
- `STABLE`: Production-grade API with strict backward-compatibility guarantees.

### 3.3 Stable Public Barrel Discipline
The top-level public package barrel (e.g., `package:warp_prism_ui/warp_prism_ui.dart`) **MUST** export only `PROVEN` or `STABLE` APIs. Internal implementation symbols (including all raw `DS*` declarations) must be hidden or aliased via unified `Prism*` exports.

---

## 4. Domain Leakage Rule & Bypass Policy

### 4.1 The Domain Leakage Rule
Warp Prism enforces a clear boundary between reusable integration contracts and product-local domain semantics:

1. **Reusable UI↔Runtime Semantics**: Interaction patterns that recur across multiple operational applications (e.g., streaming logs/events, monitoring daemon health, executing asynchronous commands, traversing entity graphs) are candidates for standardization in `warp_prism_runtime`.
2. **Domain-Specific Semantics**: Application business rules, proprietary data schemas, domain-specific persistence, and bespoke protocol drivers **MUST** remain product-local.

### 4.2 Bypass-is-a-Feature Clause
Warp Prism explicitly treats layer bypass as an **architectural feature**:

> **Bypass-is-a-Feature Clause**: Consumer applications (`apps/observatory`, `apps/cybercore`, future verticals) are **never required** to force domain-specific interactions through Warp Prism runtime contracts. Products **MAY** maintain direct, product-local adapters, proprietary state management, or custom backends alongside Warp Prism visual components.

Warp Prism standardizes the interfaces through which applications expose backend capabilities to UI; it does not dictate how applications construct their proprietary internal logic.

### 4.3 Model Ownership Rule (Runtime Semantic Models ≠ Presentation Models)
To prevent semantic degradation and preserve presentation purity:
- **Runtime Semantic Models** (in `warp_prism_runtime`, `warp_bridge_core`) own semantic properties: unique identifiers, lifecycle states, connection metrics, node relationships, and payload data. They own **NO** layout fields (`position`, `Offset`, pixel sizes, expanded flags).
- **Presentation Models** (in `warp_prism_ui`, `warp_prism_bindings`) own spatial and visual properties: coordinate offsets, render styles, animation controllers, viewport bounds, and widget keys.

---

## 5. Boundary Enforcement & Harness Evolution Matrix

Warp Prism employs an automated boundary test harness (`packages/warp_prism_ui/test/boundaries/boundary_test.dart`) to enforce layer isolation. 

Checks are categorized according to their enforcement status:
- **READY_TO_ENFORCE_NOW / ENFORCED NOW**: Deterministic check with zero false positives; active hard gate in CI.
- **MECHANIZABLE_NOW**: Technically mechanizable but operates as an advisory report until migrations/allowlists are finalized.
- **PHASED**: Formally specified; activated as soon as the target package or substrate lands in the repository.

### 5.1 Authoritative Numbered Check List (Checks 1–17)

| # | Check Name & Description | Classification | Enforcement Owner / Trigger |
|---|---|---|---|
| 1 | `CyberCore contains zero DS* references` | **ENFORCED NOW** | Existing Check 1 (`boundary_test.dart`) |
| 2 | `Consumer apps do not import warp_prism_ui src/ paths` | **ENFORCED NOW** | Existing Check 2 (`boundary_test.dart`) |
| 3 | `warp_prism_ui does not import Riverpod or GoRouter` | **ENFORCED NOW** | Existing Check 3 (`boundary_test.dart`) |
| 4 | `warp_prism_ui does not import app-specific packages` | **ENFORCED NOW** | Existing Check 4 (`boundary_test.dart`) |
| 5 | `warp_prism_ui does not import forbidden persistence or IO packages` | **ENFORCED NOW** | Existing Check 5 (`boundary_test.dart`) |
| 6 | `All public DS declarations have Prism aliases` | **ENFORCED NOW** | Existing Check 6 (`boundary_test.dart`) |
| 7 | `Public barrel hides DS* names from consumers` | **ENFORCED NOW** | Existing Check 7 (`boundary_test.dart`) |
| 8 | `PrismTokenRegistry mutators called only by theme_editor organism` | **ENFORCED NOW** | **Task 1811** (Check 8 added in this task; allowlist: `prism_token_registry.dart` + `theme_editor/`) |
| 9 | `Repository root contains no scratch files` (`fix_`, `tmp_`, `patch_`, `append_`, `snippet_`) | **READY_TO_ENFORCE_NOW** | **Task 1813** (ships atomically with the root sweep) |
| 10 | `No local structural re-hex: raw Color(0x outside tokens/` | **MECHANIZABLE_NOW** | Advisory report in M01; hard gate after token migration |
| 11 | `warp_prism_ui does not import flutter_rust_bridge` | **PHASED** | Activated when FRB enters repository (Task 1822) |
| 12 | `warp_prism_runtime contains no Flutter imports` (`package:flutter`, `Widget`, `BuildContext`, `Color`, `Offset`) | **PHASED** | Activated when `warp_prism_runtime` package is created |
| 13 | `warp_prism_interaction is pure Dart` | **PHASED** | Activated when `warp_prism_interaction` package is created |
| 14 | `warp_prism_bindings is not imported by warp_prism_ui` | **PHASED** | Activated when `warp_prism_bindings` package is created |
| 15 | `warp_prism_adapter_frb is not imported by ui/interaction/runtime` | **PHASED** | Activated when `warp_prism_adapter_frb` package is created |
| 16 | `Core packages contain no domain types` (Ganthritor, Cersei, OmniRoute, CyberCore) | **ENFORCED NOW** | **Task 1830** (scans v2 semantic packages `interaction`, `runtime`, `bindings`, `testkit`, `adapter_frb`; teal skin is ui-local sanctioned per Task 1825 Part 7) |
| 17 | `FRB generated files are not imported directly by widgets` | **ENFORCED NOW** | **Task 1830** (scans `apps/*/lib/` and `packages/*/lib/` excluding `adapter_frb` for direct generated-surface imports) |

---

## 6. Source Evidence & Architectural Lineage

| Artifact | Authority & Context |
|---|---|
| `docs/design/charter.md` | Warp Prism Child-Project Charter (v2) — Tripartite mission (ADS + IDS + Runtime contracts) and ADR-0001 |
| `docs/architecture/package-topology.md` | 6-package Dart topology, 2-crate Rust topology, and Concept ≠ Crate Law |
| `docs/reports/warp-prism-v2-source-reality-review-2026-08-31.md` | Source-Reality Review §F (Boundary enforcement classification) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Automated boundary test harness |
| `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` | Theme token registry mutation API baseline |
| `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` | Canonical sole caller of runtime token overrides |
