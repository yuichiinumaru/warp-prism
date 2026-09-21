# Task 1811: Layer Boundaries + Dependency Law + Boundary Harness v2

> **Priority**: 🔴 P0 · **Type**: `governance`
> **Origin**: EPIC-19 (S19-02) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1818 (runtime consumer audit reads the layer matrix), Task 1822 (FRB spike reads the layer matrix)
> **Depends on**: None (root task)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 19-B layer-contract law + boundary harness check 8 (the first structural gate of the v2 spine)
- **Strategic why**: the MUST/MAY/MUST-NOT matrix is the law every later package (interaction/runtime/bindings/adapter) is validated against; without it, layer drift is undetectable until code exists.
- **Consequence if absent**: v2 packages land with no enforceable boundary; Domain Leakage and presentation-purge invariants stay aspirational.

## Shared-Write Ownership (boundary_test.dart)

`packages/warp_prism_ui/test/boundaries/boundary_test.dart` is a shared file with TWO sequential owners:

- **Task 1811** (this task): appends **check 8 only** (registry mutation scope). Does NOT touch check 9 and does NOT assert a total check count that would go stale when 1813 lands check 9.
- **Task 1813**: appends **check 9 + performs the root sweep atomically** (sweep + gate + PASS together).

Builders must not run both edits in one lane pass; if both tasks are in flight, 1811's edit is check 8 append-only and 1813's is check 9 append-only, so the file merges cleanly — but each task validates only its own check.

## Objective

Publish the canonical MUST/MAY/MUST-NOT layer matrix for Warp Prism v2 packages (ADS, IDS, Runtime, Bindings, Adapter FRB, Rust core) and extend the boundary harness with the now-enforceable Check 8 (PrismTokenRegistry mutation scope). Note: Check 9 (root scratch-file hygiene) is owned atomically by Task 1813 alongside the root sweep.

## Background Context

### What already exists

- `packages/warp_prism_ui/test/boundaries/boundary_test.dart` — 7 existing checks (CyberCore zero DS*, consumer apps no src/ imports, ui no Riverpod/GoRouter, ui no app packages, ui no forbidden persistence/IO, all DS have Prism aliases, barrel hides DS*). Flat `List<BoundaryCheck>` pattern at `:95-125`.
- `PrismTokenRegistry` mutation API verified exact: `setColor/resetRole/reset` (`prism_token_registry.dart:113-147`); sole caller = `prism_theme_editor.dart`.
- Root scratch files exist but are swept and guarded atomically by Task 1813.

### What is missing or broken

- No canonical layer matrix doc exists yet (`docs/architecture/layer-contracts-v2.md` is referenced but not created).
- Harness has no check for registry mutation scope.
- Domain Leakage Rule not yet documented.

## Subtasks

- [ ] **Read before modifying**: `packages/warp_prism_ui/test/boundaries/boundary_test.dart`, `prism_token_registry.dart`, `prism_theme_editor.dart`, `prism_aliases.dart`.
- [ ] **Create `docs/architecture/layer-contracts-v2.md`**: full MUST/MAY/MUST-NOT matrix (ui, interaction, runtime, bindings, adapter_frb, rust core, apps, templates) + Global MUSTs + Domain Leakage Rule + bypass-is-a-feature clause.
- [ ] **Add harness check 8**: `PrismTokenRegistry mutators called only by theme_editor organism` — grep `setColor|resetRole` outside `prism_token_registry.dart` + `theme_editor/`. READY_TO_ENFORCE_NOW (allowlist = 2 paths).
- [ ] **Check 9 coordination**: Check 9 (root scratch hygiene) is owned atomically by Task 1813 together with the sweep; do not install check 9 here to avoid CI race conditions.
- [ ] **Do not**: promote check 10 (no-local-rehex) as hard gate yet — it needs semantic allowlist first (MECHANIZABLE_NOW, NOT_READY_TO_ENFORCE).
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands.

## Validation Commands

```bash
# Check 8 passes and no prior check regressed (count-agnostic: 1813's check 9 is NOT yet expected)
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . | grep -c "PASS"   # ≥8 PASS, 0 FAIL
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `docs/architecture/layer-contracts-v2.md` | Create — canonical matrix + Domain Leakage Rule |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Modify — add check 8 |

## Exit Conditions

- [ ] Layer matrix committed with all rows (ui/interaction/runtime/bindings/adapter_frb/rust core/apps/templates) + Global MUSTs + Domain Leakage Rule + bypass clause.
- [ ] Harness check 8 added + deterministic (allowlist precise).
- [ ] Check 10 NOT promoted to hard gate (advisory only).
- [ ] Boundary harness: check 8 passes, zero failures overall (no total-count assertion).
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**:
  - `docs/architecture/layer-contracts-v2.md` (created: 10-row MUST/MAY/MUST-NOT matrix + Global MUSTs + Domain Leakage Rule + bypass-is-a-feature + Model-Ownership Rule + authoritative checks 1–17 enforcement table; 131 lines)
  - `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (check 8 appended: `_checkRegistryMutatorScope` scanning `setColor|resetRole` outside 2-path allowlist)
- **Mutation-API verification** (builder, from source): mutators at `prism_token_registry.dart:132-153` (`setColor(PrismColorRole, Color)`, `resetRole(PrismColorRole)`, `reset({bool silent})`); all setColor/resetRole callers confined to `theme_editor/prism_theme_editor.dart:79,308-364,485`; zero callers outside allowlist — allowlist precise, no widening needed
- **Tests or validation commands**:
  - `dart run test/boundaries/boundary_test.dart --repo-root ../..` → **8/8 PASS, 0 FAIL** (7 prior + check 8)
  - `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` → No issues found
  - `grep -c "MUST NOT" layer-contracts-v2.md` → 13; `grep -c "Domain Leakage"` → 2; `grep -c "READY_TO_ENFORCE_NOW\|ENFORCED NOW"` → 10; `wc -l` → 131
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
