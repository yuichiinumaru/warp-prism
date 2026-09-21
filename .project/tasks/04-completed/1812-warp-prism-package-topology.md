# Task 1812: Package Topology + Workspace Coordination

> **Priority**: 🔴 P0 · **Type**: `governance`
> **Origin**: EPIC-19 (S19-04) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1818 (consumer audit resolves package ownership from the topology doc), Task 1822 (FRB spike reads the 2-crate topology and Cargo-placement ADR)
> **Depends on**: None (root task)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 19-C package/crate topology law (naming, dependency direction, 2-crate Rust)
- **Strategic why**: every later task creates or validates packages against this topology; without a canonical doc each task would re-derive its own layout.
- **Consequence if absent**: package sprawl and ad-hoc crate decisions; the "concept ≠ crate" rule has no enforcement text.

## Objective

Decide and document the v2 package topology (naming, ownership, workspace coordination) with the reduced 2-crate Rust substrate, leaving the Cargo workspace placement as an open ADR to be decided at 1822 with build evidence.

## Background Context

### What already exists

- `packages/warp_prism_ui` — the only package that exists.
- `melos.yaml` referenced in `pubspec.yaml` but no `melos.yaml` at root (verify).
- `apps/catalog`, `apps/observatory`, `apps/cybercore` — existing Flutter apps.

### What is missing or broken

- No `warp_prism_interaction`, `warp_prism_runtime`, `warp_prism_bindings`, `warp_prism_testkit` packages.
- No Rust workspace (`rust/` or `Cargo.toml`).
- No canonical topology doc.
- Rust topology was reduced from 5+ crates to 2 (`rust/warp_bridge_core/` + `rust/warp_bridge_frb/`) per source-reality review — rule: concept existence ≠ crate existence.

## Subtasks

- [ ] **Read before modifying**: `pubspec.yaml` (root), `packages/warp_prism_ui/pubspec.yaml`, any existing `melos.yaml`.
- [ ] **Create `docs/architecture/package-topology.md`**: package naming (warp_prism_ui/interaction/runtime/bindings/testkit), dependency direction (ui/interaction ← bindings ← runtime ← FRB adapter ← Rust), Rust 2-crate topology.
- [ ] **Document workspace coordination**: Melos = Dart/Flutter packages, Cargo = Rust, root scripts coordinate (`warp validate`).
- [ ] **Leave open ADR**: Cargo workspace placement (root `Cargo.toml` vs `rust/Cargo.toml`) — to be decided at 1822 with build evidence.
- [ ] **Do not**: create directories or packages — this task is planning/docs only.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands.

## Validation Commands

```bash
grep -E "warp_prism_(ui|interaction|runtime|bindings|testkit)" docs/architecture/package-topology.md
grep -E "warp_bridge_core|warp_bridge_frb" docs/architecture/package-topology.md
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `docs/architecture/package-topology.md` | Create — topology + dependency direction + workspace coordination |

## Exit Conditions

- [ ] Topology doc committed with all v2 packages named + dependency direction.
- [ ] Rust topology = 2 crates (warp_bridge_core + warp_bridge_frb) with rule stated.
- [ ] Cargo placement left as OPEN ADR (decided at 1822).
- [ ] No packages or directories created.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: `docs/architecture/package-topology.md` (created: 6-package registry + dependency direction law (9 invariants + diagram) + Rust 2-crate topology + concept≠crate law + Runtime≠Presentation model-ownership rule + workspace coordination + OPEN ADR Cargo placement; 140 lines)
- **Tests or validation commands**:
  - `grep -cE "warp_prism_(ui|interaction|runtime|bindings|testkit|adapter_frb)"` → 17
  - `grep -cE "warp_bridge_core|warp_bridge_frb"` → 5
  - `grep -c "concept existence ≠ crate existence"` → 1
  - `grep -c "OPEN ADR"` → 2
  - `ls melos.yaml` → not found (physical reality recorded: workspace config lives in root `pubspec.yaml` `workspace:`/`melos:` sections — Melos v7 format; doc describes this)
  - boundary harness → 7/7 PASS at build time
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
