# Task 1823: Minimal Rust Bridge Substrate (2 Crates)

> **Priority**: 🔴 P0 · **Type**: `feature`
> **Origin**: EPIC-22 (S22-01 + Topology) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1824
> **Depends on**: Task 1822 (FRB Spike PASS), Task 1819 (Experimental Runtime Contracts)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 22-B minimal Rust bridge substrate (2 crates + Dart adapter)
- **Strategic why**: the 2-crate substrate is the replaceable Rust half of the L1 golden path; everything 1824 tests exists because this task builds it.
- **Consequence if absent**: 1824 has no bridge to test; the golden path remains Dart-only fakes.

## Objective

Create the minimal 2-crate Rust substrate under `rust/`: `rust/warp_bridge_core/` (transport-agnostic Rust types and domain logic for command, events, health, graph modules) and `rust/warp_bridge_frb/` (FRB FFI bridge and codegen bindings). Create the Dart adapter package `packages/warp_prism_adapter_frb/`. Enforce the concept-existence ≠ crate-existence rule (no premature microcrates).

## Background Context

### What already exists

- `docs/reports/1822-frb-spike-kill-gate-report.md` confirming toolchain compatibility, pinned candidate quadruple, and Cargo workspace placement ADR.
- `packages/warp_prism_runtime/` (from Task 1819) with pure Dart runtime contracts.
- `docs/architecture/layer-contracts-v2.md` enforcing adapter isolation (adapter may import FRB; widgets MUST NOT import adapter or FRB directly).

### What is missing or broken

- No Rust crates exist in the repository (`rust/` directory is greenfield).
- No Dart FRB adapter package exists (`packages/warp_prism_adapter_frb/` is greenfield).

## Subtasks

- [ ] **Read before modifying**: `docs/reports/1822-frb-spike-kill-gate-report.md`, `docs/architecture/layer-contracts-v2.md`, `docs/architecture/package-topology.md`.
- [ ] **Initialize Rust workspace**: create Cargo workspace per ADR from Task 1822 with 2 crates only.
- [ ] **Create `rust/warp_bridge_core/`**: pure Rust, transport-agnostic library containing modules:
  - `command`: async command execution, results, cancellation token.
  - `events`: event stream producer, ordering, subscription channel.
  - `health`: snapshot state, watch channel.
  - `graph`: node/edge graph data structures.
- [ ] **Create `rust/warp_bridge_frb/`**: FRB boundary crate wrapping `warp_bridge_core` and exposing FRB-annotated API entrypoints.
- [ ] **Create `packages/warp_prism_adapter_frb/`**: Dart adapter package wrapping FRB-generated Dart glue and implementing `packages/warp_prism_runtime` interfaces.
- [ ] **Run codegen & compile**: execute FRB codegen and verify both Rust crates compile with 0 warnings (`cargo check`, `cargo test`).
- [ ] **Add boundary harness checks**: verify `warp_prism_ui` does not import FRB (check 11), `warp_prism_adapter_frb` is not imported by `warp_prism_ui` (check 15).
- [ ] **Simplify pass**: remove unnecessary complexity; reject any attempts to split modules into additional crates.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
cargo test --workspace --manifest-path rust/Cargo.toml  # or per-ADR manifest path
flutter analyze packages/warp_prism_adapter_frb
flutter test packages/warp_prism_adapter_frb
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `rust/Cargo.toml` | Rust workspace manifest |
| `rust/warp_bridge_core/` | Transport-agnostic Rust substrate (modules: command, events, health, graph) |
| `rust/warp_bridge_frb/` | FRB bridge FFI bindings and codegen entrypoints |
| `packages/warp_prism_adapter_frb/` | Dart adapter implementing runtime contracts via FRB |

## Exit Conditions

- [ ] Rust workspace initialized with exactly 2 crates (`warp_bridge_core` + `warp_bridge_frb`).
- [ ] Core modules (command, events, health, graph) implemented in pure Rust.
- [ ] Dart adapter package `warp_prism_adapter_frb` implements runtime contract interfaces.
- [ ] Rust and Dart test suites compile and pass.
- [ ] Boundary harness checks pass (no adapter leakage into UI widgets).
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created**: rust/Cargo.toml (2-member workspace), rust/warp_bridge_core/ (command.rs/events.rs/health.rs/graph.rs + unit tests, FRB-free), rust/warp_bridge_frb/ (api.rs, frb_generated.rs, tests.rs, FRB 2.13.0), packages/warp_prism_adapter_frb/ (barrel, adapter_init, FrbAsyncCommand/FrbEventStream/FrbHealthSource/FrbGraphSource implementing runtime contracts, generated bridge bindings). NOTE: `resolution: workspace` in adapter pubspec was added by 1820's builder but belongs to 1823 — the 1823 builder re-affirmed it during adapter package creation.
- **Tests or validation commands**:
  - `cargo build --manifest-path rust/Cargo.toml`: PASS, **0 warnings** (frb_expand cfg allowed)
  - `cargo test --manifest-path rust/Cargo.toml`: PASS (**16 tests**: 11 core + 5 FRB)
  - `cd packages/warp_prism_adapter_frb && flutter analyze .`: PASS (0 issues)
  - `cd packages/warp_prism_adapter_frb && flutter test .`: PASS (**10 tests**: 3 FFI smoke + 7 contract adapter tests including in-flight cancel, native health watch, native graph update)
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`: PASS (10/10)
  - `grep -rn "flutter_rust_bridge" rust/warp_bridge_core/`: 0
  - `ls rust/`: Cargo.toml Cargo.lock target warp_bridge_core warp_bridge_frb (exactly 2 crates, root clean)
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-rust (builder + remediation, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: independent review FAIL (cargo build warning; async cancel preflight-only; health watch Dart-local; graph updates adapter-generated) → remediated (frb_expand cfg allow; in-flight cancel via CommandRegistry+cancel_command; native health watch stream; native graph update notifications via shared state + broadcast; 16 Rust tests + 10 Dart tests) → focal re-review **PASS** (0 warnings, in-flight cancel across FFI, native health/graph watch tests pass).
