# Task 1204: Melos Test Script Normalization

> **Status**: `[x]` Builder Done
> **Review State**: Builder Done — completion evidence filled; gate verification pending
> **Priority**: 🟡 P1
> **Type**: `housekeeping`
> **Origin**: EPIC-12, stabilization wave, missing `test-cybercore` and `test-boundaries` scripts.
> **Blocks**: 1205, 1207
> **Depends on**: N/A (file configuration only)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1204` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Normalize the Melos test scripts in the root `pubspec.yaml` to cover all
packages/apps and add planned convenience scripts (`test-cybercore`,
`test-boundaries`, `test-fast`).

## Background Context

### What already exists

- Root `pubspec.yaml` (Melos config) has scripts: `analyze`, `format`, `test`,
  `test-ui`, `test-observatory`, `test-catalog`, and `validate`.
- `apps/cybercore/` exists as a first-class consumer but has no dedicated
  Melos test script.
- Task 1205 now provides a current pure-Dart boundary harness at
  `packages/warp_prism_ui/test/boundaries/boundary_test.dart`.

### What is missing or broken

- No repository-local `test-cybercore` script.
- No repository-local `test-boundaries` script for architectural boundary checks.
- No repository-local `test-fast` convenience script for quick local validation.
- Existing script bodies must not silently depend on a globally installed `melos`
  executable when invoked as `dart run melos run <script>`.

---

## Test Requirements

- All 4 packages/apps have dedicated test scripts in Melos.
- `test-boundaries` script exists and runs the current Task 1205 pure-Dart
  boundary harness.
- `test-fast` script exists as a convenience for local validation.
- Existing scripts preserve their original package/test/format/analyze semantics
  while being normalized for repository-local Melos invocation.

---

## Exit Conditions

- [x] Root `pubspec.yaml` contains `test-cybercore`, `test-boundaries`, and `test-fast`
  scripts.
- [x] `dart run melos run test-cybercore` runs tests in `apps/cybercore/` only.
- [x] `dart run melos run test-boundaries` runs the Task 1205 boundary test harness.
- [x] `dart run melos run test-fast` runs the fast subset of tests.
- [x] Existing scripts (`test-ui`, `test-observatory`, `test-catalog`, `validate`)
  preserve their semantics and are normalized for repository-local Melos invocation.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:
- [x] **Read existing code before modifying**: Read root `pubspec.yaml` (Melos config),
  `docs/reports/build-gate-review/1204-review.md`, and Task 1205's current boundary
  harness evidence.
- [x] Add `test-cybercore` script scoped to `warp_prism_cybercore`.
- [x] Add `test-boundaries` script that runs the Task 1205 pure-Dart harness.
- [x] Add `test-fast` script that runs `test-ui && test-cybercore` as a quick gate.
- [x] Normalize existing scripts for repository-local Melos invocation without changing
  their package/test/format/analyze semantics.
- [x] **Simplicity pass**: keep scripts minimal and consistent with existing patterns.
- [x] **Regression verification**: verify `dart run melos run test-cybercore`,
  `test-boundaries`, `test-fast`, and `test-catalog` execute.

### Where

| File | Purpose |
| --- | --- |
| `pubspec.yaml` (root) | Modify — normalize Melos script bodies for `dart run melos run <script>` |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Modify — make the pure-Dart boundary harness compatible with Flutter test discovery |
| `.agents/rules/promotion-state-model.md` | Read — gate requirements |

### How

1. Read the existing Melos config in root `pubspec.yaml`.
2. Normalize script bodies to call `dart run melos exec` where nested Melos execution is required.
3. Add `test-cybercore` following the same package/test semantics as existing scoped tests.
4. Add `test-boundaries` referencing the current Task 1205 pure-Dart harness.
5. Add `test-fast` combining `test-ui && test-cybercore`.
6. Verify all scripts execute through `dart run melos run <script>`.

### Why

Without repository-local Melos scripts, builders cannot reliably run the Melos entrypoints in this repo because `melos` is not globally installed. Normalizing script bodies preserves the intended package/test/format/analyze behavior while making the commands runnable through the repository-supported `dart run melos run <script>` path.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not claim existing scripts are unchanged if their bodies were normalized. Say
> explicitly that semantics were preserved while implementation was updated for
> repository-local Melos invocation.

> [!IMPORTANT]
> `test-boundaries` depends on Task 1205's current pure-Dart harness. Do not claim
> it skips if the harness exists and passes.

---

## Validation Commands

```bash
cat pubspec.yaml | grep -A 3 "test-cybercore"
cat pubspec.yaml | grep -A 3 "test-boundaries"
cat pubspec.yaml | grep -A 3 "test-fast"
```

---

## Completion Evidence

- **Files created/modified**: `pubspec.yaml` (normalized all script bodies for `dart run melos run <script>`), `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (updated to be compatible with Flutter test discovery while preserving pure-Dart CLI entrypoint), `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md` (updated)
- **Tests or validation commands**:
  - `dart run melos run test-cybercore` → ✅ SUCCESS (12 tests pass)
  - `dart run melos run test-boundaries` → ✅ SUCCESS (4/4 boundary checks pass via pure-Dart harness)
  - `dart run melos run test-fast` → ✅ SUCCESS (test-ui + test-cybercore)
  - `dart run melos run test-catalog` → ✅ SUCCESS (10 tests pass)
  - `dart run melos run test-ui` → ✅ SUCCESS (850+ tests pass)
  - `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` → No issues found
  - `dart format --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` → PASS (0 changed)
- **Local changelog entry**: `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
- **2026-06-11 Path-to-100 refresh date**: 2026-06-11

---
## Review Ledger

### 2026-06-11 — gt-build-review
**Score**: 68/100 — Debt
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: grep script presence PASS | `dart run melos list` PASS | `melos run test-cybercore` FAIL (`melos: command not found`) | `dart run melos run test-cybercore` FAIL (inner `melos: command not found`) | `dart run melos run test-boundaries` FAIL (inner `melos: command not found`) | `dart run melos run test-fast` FAIL (inner `melos: command not found`) | direct `dart run melos exec --scope warp_prism_cybercore -- flutter test` PASS (12 tests) | direct `dart run melos exec --scope warp_prism_ui -- flutter test test/boundaries/boundary_test.dart` PASS (4 tests) | direct `dart run melos exec --scope warp_prism_ui,warp_prism_cybercore -- flutter test` PASS (UI 854 + CyberCore 12 tests) | flutter analyze N/A | dart format N/A | coverage N/A
**Report**: docs/reports/build-gate-review/1204-review.md
**Patches applied**: none — score below 90, reviewer patching prohibited.
**Findings**:
1. HIGH — Task script entrypoints fail under repository-local Melos invocation because script bodies call nested `melos exec` (`pubspec.yaml:40`, `pubspec.yaml:44`, `pubspec.yaml:48`, `pubspec.yaml:52`, `pubspec.yaml:56`, `pubspec.yaml:60`) and this environment has no global `melos` executable.
2. HIGH — Existing scripts were changed despite the contract requiring them unchanged (`docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:55`, guardrail at line 104; admitted by completion evidence line 125 and changelog line 29).
3. MEDIUM — Completion evidence/changelog claim `test-boundaries` skips pending Task 1205, but `pubspec.yaml:56` points at an existing harness and direct execution runs `packages/warp_prism_ui/test/boundaries/boundary_test.dart:55` successfully.
**Path to 100**:
1. Make `melos run test-cybercore`, `melos run test-boundaries`, and `melos run test-fast` runnable through the repository-supported invocation path, or explicitly require/document global Melos and validate in that environment.
2. Restore the “existing scripts unchanged” contract or update/re-contract the task honestly if existing scripts must change.
3. Re-run exact script commands and update Completion Evidence with current boundary harness reality.
---
