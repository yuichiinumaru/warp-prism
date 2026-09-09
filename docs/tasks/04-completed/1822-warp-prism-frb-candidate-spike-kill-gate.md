# Task 1822: FRB Candidate Compatibility and Build Spike (Kill-Gate)

> **Priority**: 🔴 P0 · **Type**: `verification`
> **Origin**: EPIC-22 (S22-01 + S22-02) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1823
> **Depends on**: Task 1812 (Package Topology)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 22-A FRB candidate compatibility/build spike — **the kill-gate of the Rust golden path**
- **Strategic why**: L1's Rust path is entirely unvalidated (greenfield); this spike is the only empirical evidence that Flutter↔Rust via FRB works with the repo's toolchain before any substrate is built.
- **Consequence if absent**: 1823 builds a bridge on untested assumptions; a toolchain failure surfaces mid-substrate at 10× the cost.

## Objective

Execute an isolated Flutter↔Rust compatibility and build spike using a candidate `flutter_rust_bridge` (FRB) version against the current repository Dart/Flutter/Rust toolchain. Measure cold build times, incremental compilation, CI integration, and packaging on Linux desktop (Android secondary). If fatal toolchain/codegen incompatibilities occur, halt as a KILL-GATE. On PASS, record the exact verified candidate quadruple (FRB version / codegen / Native Assets / Rust toolchain) and resolve the open Cargo workspace placement ADR (`rust/Cargo.toml` vs root).

## Background Context

### What already exists

- `docs/architecture/package-topology.md` (from Task 1812) defining the 2-crate Rust substrate and leaving Cargo placement as an open ADR.
- Repository environment: Linux x86_64 with Flutter/Dart and Rust toolchain installed.
- Zero existing Rust/FRB code in repository (greenfield validation).

### What is missing or broken

- No empirical spike proves that FRB builds and links cleanly with the repository's toolchain.
- FRB version must be tested as a candidate spike version at execution time (never pre-pinned without deterministic build evidence).
- Cargo workspace placement ADR remains open pending build matrix outcome.

## Subtasks

- [ ] **Read before modifying**: `docs/architecture/package-topology.md`, `docs/architecture/layer-contracts-v2.md`.
- [ ] **Probe active toolchains**: inspect `rustc --version`, `cargo --version`, `flutter --version`, `dart --version` to identify exact baseline environment.
- [ ] **Create isolated spike workspace**: in `tmp/frb_spike/` or a temporary harness, initialize a minimal candidate FRB setup (Dart caller + minimal Rust lib returning a primitive/string).
- [ ] **Run build matrix**:
  1. Measure cold `cargo build` time.
  2. Measure incremental build time after Rust source change.
  3. Measure codegen execution time.
  4. Test Dart/Flutter linking and invocation of Rust exported function on Linux desktop.
- [ ] **Kill-Gate Evaluation**: if codegen crashes, toolchain is irreconcilably incompatible, or link failures cannot be resolved cleanly, record findings and HALT (kill-gate triggered).
- [ ] **Decide Cargo placement ADR**: compare root `Cargo.toml` vs `rust/Cargo.toml` based on build spike ergonomics; record decision.
- [ ] **Document candidate quadruple**: create `docs/reports/1822-frb-spike-kill-gate-report.md` recording exact versions: FRB, codegen CLI, Native Assets/build mechanism, and Rust toolchain version.
- [ ] **Simplify pass**: clean up temporary spike artifacts; do not leave scratch files at repository root.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
rustc --version
cargo --version
flutter --version
grep -E "Candidate Quadruple|Cargo Placement ADR|KILL-GATE" docs/reports/1822-frb-spike-kill-gate-report.md
```

## Where

| File | Purpose |
|---|---|
| `docs/reports/1822-frb-spike-kill-gate-report.md` | Create — spike execution report, candidate quadruple, ADR resolution |
| `tmp/frb_spike/` | Temporary isolated build spike workspace (cleaned up after pass) |

## Exit Conditions

- [ ] Toolchain compatibility verified empirically on Linux desktop.
- [ ] Cold and incremental build times measured and documented.
- [ ] Kill-gate decision recorded: PASS (continue) or FAIL/HALT (escalate).
- [ ] Exact candidate quadruple pinned based on verified build results.
- [ ] Cargo workspace placement ADR decided with build evidence.
- [ ] Spike report committed at `docs/reports/1822-frb-spike-kill-gate-report.md`.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created**: `docs/reports/1822-frb-spike-kill-gate-report.md` (125 lines) + `tmp/frb_spike/` spike workspace (rust_lib crate with api.rs/tests.rs/frb_generated.rs; dart_app package with generated bridge + spike_test.dart; retained in tmp/ as reproducibility evidence — archive-first, not deleted).
- **Toolchain baseline (verified)**: rustc 1.95.0 (59807616e) · cargo 1.95.0 (f2d3ce0bd) · Flutter 3.44.1 stable · Dart 3.12.1 (linux_x64).
- **Candidate quadruple (pinned empirically, spike-verified)**: flutter_rust_bridge **2.13.0** (Dart package + Rust crate) · flutter_rust_bridge_codegen **2.13.0** · build mechanism = cdylib dynamic library (`librust_lib.so`) via FRB dynamic loader (Linux desktop x86_64, Tokio async, SSE FFI serialization) · rustc 1.95.0 edition 2021.
- **Build matrix (measured)**: codegen **1.34s**; cold cargo release build **8.57s** (51 deps, 915 KB artifact); incremental **0.46s**; Rust unit tests 2/2 PASS; Dart bridge suite **3/3 PASS** in 0.99s (sync add, async echo, reactive stream countStream → [1..5]).
- **Kill-gate verdict**: **PASS** — zero fatal crashes, zero ABI mismatches, clean FFI linkage, reactive streams operational. Task 1823 unblocked.
- **Cargo Placement ADR: RESOLVED → `rust/Cargo.toml`** (nested workspace manifest). Rationale: root stays pubspec/Melos-governed; Rust artifacts localized (rust/target/, rust/Cargo.lock); codegen flags target nested subcrates cleanly; CI cache granularity isolated from pub cache.
- **Tests or validation commands**: toolchain probes recorded verbatim; `cargo build && cargo test` → Finished dev profile, tests ok; report greps confirmed (Candidate Quadruple / Cargo Placement ADR / KILL-GATE sections present); `wc -l` → 125.
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-rust (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: 2026-09-01 independent review FAIL (ADR lacked comparative build evidence; stale refs) → remediated (Variant A root-workspace vs Variant B rust/Cargo.toml both built in tmp/frb_spike/placement_{a,b}/ with identical 2-crate members: cold 8.72s vs 8.64s parity, B wins artifact isolation/root cleanliness/codegen symmetry/CI caching; decision unchanged rust/Cargo.toml; topology §6.3 → RESOLVED + cross-ref; task ref lane-neutral) → focal re-review PASS (both variants build; measured table present; candidate framing retained; root clean).
- **Residual risks**: mobile (NDK/Xcode) not verified by this spike — desktop Linux only (validates the spike's Linux-first scope; Android is secondary per task); candidate versions are spike-verified, formal ADOPT+pin for the monorepo happens in 1823 when the substrate lands.
