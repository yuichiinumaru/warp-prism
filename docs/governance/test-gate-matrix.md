# Test Gate Matrix — Warp Prism Governance

> **Authority**: Canonical reference for which validation gates each task type
> must pass before promotion.
> **Scope**: All executable tasks under `.project/tasks/`.
> **Created**: 2026-06-09
> **Task origin**: Task 1203
> **Depends on**: Task 1201 (failure baseline), Task 1202 (promotion state model)

This document defines the concrete, auditable test gates that every task type
must satisfy before advancing from **Builder Done** to **Ready For Review**.
It replaces the implicit assumption that "local test pass = done" with an
explicit checklist per task category.

---

## 1. Gate Definitions

### 1.1 Package Gate

The **Package Gate** verifies that the owning package compiles, analyzes, and
tests cleanly after the task's changes.

**Commands**:

```bash
# Static analysis (zero errors required)
cd packages/<package> && flutter analyze
# or via Melos for the specific package:
melos exec --scope <package_name> -- flutter analyze

# Unit/widget tests (no regressions vs. baseline)
cd packages/<package> && flutter test
# or via Melos:
melos run test-ui          # warp_prism_ui
melos run test-observatory # observatory
melos run test-cybercore   # cybercore
melos run test-catalog     # catalog
```

**Pass criteria**: `flutter analyze` returns zero errors. `flutter test` exits
with code 0 and introduces no new failures beyond the
[known baseline](#6-pre-existing-failure-policy).

### 1.2 Consumer Gate

The **Consumer Gate** verifies that downstream consumer applications still
compile and test after the task's changes propagate through package imports.

**Consumer apps**:

| App | Package Scope | Melos Script |
|-----|---------------|--------------|
| Observatory | `warp_prism_observatory` | `melos run test-observatory` |
| Catalog | `warp_prism_catalog` | `melos run test-catalog` |
| CyberCore | `warp_prism_cybercore` | `melos run test-cybercore` |

**Pass criteria**: Each required consumer (per task type) compiles and tests
without new failures.

### 1.3 Boundary Test

The **Boundary Test** verifies that import boundaries, namespace rules, and
API surface contracts are not violated. This prevents cross-package leaks,
ADS namespace violations, and unauthorized internal imports.

**Commands**:

```bash
# Full monorepo boundary check
melos run test-boundaries

# Manual namespace checks (fallback when the Melos script is unavailable):
# ADS namespace compliance
rg "DS[A-Z]" apps/cybercore/lib   # should be empty — no raw ADS in consumer apps
rg "DS[A-Z]" apps/observatory/lib # should be empty — use via catalog or ui package

# Import boundary enforcement
rg "import.*package:warp_prism_ui/src/" apps/ # should be empty — no internal imports
```

**Pass criteria**: No boundary violations. Manual `rg` checks are fallback
probes if `melos run test-boundaries` is unavailable in a local environment.

### 1.4 Golden Test

The **Golden Test** verifies that visual output of ADS components matches
approved golden files.

**Command**:

```bash
cd packages/warp_prism_ui && flutter test --tags=golden
# or filter for specific golden tests:
flutter test test/golden/
```

**Pass criteria**: All golden files match. If golden infrastructure is not yet
set up, this gate is noted as "planned" and does not block promotion.

### 1.5 Semantics Test

The **Semantics Test** verifies that accessibility labels, roles, and
interactions are correct and complete.

**Command**:

```bash
cd packages/warp_prism_ui && flutter test test/accessibility/
```

**Pass criteria**: All semantics tests pass. No new missing or incorrect labels.

### 1.6 Benchmark

The **Benchmark** verifies that performance-sensitive changes do not regress
below defined thresholds.

**Command**:

```bash
# Planned: Flutter benchmark runner
flutter test --benchmark
# or specific benchmark tests:
cd packages/warp_prism_ui && flutter test test/benchmarks/
```

**Pass criteria**: Benchmark results are within tolerance of the baseline. If
benchmark infrastructure is not yet available, this gate is "planned."

---

## 2. Gate Matrix by Task Type

Legend:

| Symbol | Meaning |
|--------|---------|
| ✅ | **Required** — must pass before promotion |
| ⚙️ | **Required if applicable** — only needed when the task touches that area |
| 📋 | **Recommended** — should run but does not block promotion |
| ➖ | **Not applicable** — gate does not apply to this task type |
| 🔜 | **Planned** — infrastructure not yet available; note as "planned in Task NNNN" |

### Full Matrix

| Task Type | Package Gate | Consumer Gate | Boundary Test | Golden Test | Semantics Test | Benchmark |
|-----------|:------------:|:-------------:|:-------------:|:-----------:|:--------------:|:---------:|
| **Docs-only** | ➖ | ➖ | ➖ | ➖ | ➖ | ➖ |
| **ADS component** | ✅ | ✅ | ✅ | ⚙️ | ⚙️ | ➖ |
| **ADS token/theme** | ✅ | ✅ | ✅ | ⚙️ | ➖ | ➖ |
| **App route** | ✅ | ⚙️ | ✅ | ➖ | ⚙️ | ➖ |
| **Parser/data layer** | ✅ | ⚙️ | ➖ | ➖ | ➖ | ➖ |
| **Monorepo migration** | ✅ | ✅ (all) | ✅ | ➖ | ➖ | ➖ |
| **CyberCore fixture** | ✅ | ⚙️ | ✅ | ➖ | ➖ | ➖ |
| **Performance-sensitive** | ✅ | ✅ | ✅ | ➖ | ➖ | ✅ |
| **Governance/housekeeping** | ➖ | ➖ | ➖ | ➖ | ➖ | ➖ |

### Column Details

**Package Gate** (all except docs-only and governance):
- `flutter analyze` — zero errors in owning package(s)
- `flutter test` — no new failures in owning package(s)
- If multiple packages are modified, all must pass

**Consumer Gate**:
- ✅ = all consumers must pass (`melos run test-observatory && melos run test-catalog && melos run test-cybercore`)
- ⚙️ = only consumers that import the modified package. See the consumer
  mapping below.
- For **ADS component** and **ADS token/theme**: all three consumers must pass
  (they all import `warp_prism_ui`).
- For **app route**: only the app where the route lives.
- For **parser/data layer**: only apps that consume the parser output.
- For **monorepo migration**: all consumers — migration changes break imports.
- For **CyberCore fixture**: `melos run test-cybercore` only.
- For **performance-sensitive**: all consumers that use the optimized surface.

**Boundary Test**:
- Required when the task modifies public API surfaces, ADS components,
  tokens/themes, routes, fixtures, or migration boundaries.
- Uses `melos run test-boundaries` or manual `rg` fallback checks.

**Golden Test**:
- ⚙️ = required when the task modifies visual appearance of a component that
  has approved golden files.
- If no golden files exist for the modified component, this gate is skipped.

**Semantics Test**:
- ⚙️ = required when the task modifies interactive components, focus behavior,
  or accessibility labels.
- Uses `flutter test test/accessibility/` in `warp_prism_ui`.

**Benchmark**:
- Required only for **performance-sensitive** tasks (e.g., virtual scroll,
  large list rendering, animation optimization).
- Uses benchmark test runner when available.

---

## 3. Exact Commands Per Gate

### 3.1 Package Gate Commands

```bash
# UI package
melos exec --scope warp_prism_ui -- flutter analyze
melos run test-ui

# Observatory package
melos exec --scope warp_prism_observatory -- flutter analyze
melos run test-observatory

# CyberCore package
melos exec --scope warp_prism_cybercore -- flutter analyze
melos run test-cybercore

# Catalog package
melos exec --scope warp_prism_catalog -- flutter analyze
melos run test-catalog
```

### 3.2 Consumer Gate Commands

```bash
# All consumers (required for ADS component, ADS token/theme, monorepo migration)
melos run test-observatory
melos run test-catalog
melos run test-cybercore

# Fast gate (UI + CyberCore only, for local iteration)
melos run test-fast

# Full CI gate (format + analyze + test all)
melos run validate
```

### 3.3 Boundary Test Commands

```bash
# Full boundary harness
melos run test-boundaries

# Manual namespace fallback checks:
rg "DS[A-Z]" apps/cybercore/lib
rg "DS[A-Z]" apps/observatory/lib
rg "DS[A-Z]" apps/catalog/lib
rg "import.*package:warp_prism_ui/src/" apps/
rg "import.*package:warp_prism_ui/src/" packages/ --ignore-package warp_prism_ui
```

### 3.4 Golden / Semantics / Benchmark Commands

```bash
# Golden tests (when golden infrastructure exists)
cd packages/warp_prism_ui && flutter test --tags=golden

# Semantics tests
cd packages/warp_prism_ui && flutter test test/accessibility/

# Benchmark (when benchmark infrastructure exists)
cd packages/warp_prism_ui && flutter test test/benchmarks/
```

---

## 4. Gate Execution Order

Tasks must execute gates in this order. A later gate is only run if the
earlier gate passes.

```
1. Package Gate (owning package)
   ├── PASS → proceed to step 2
   └── FAIL → task enters "Package Gate Failed" state
              classify failure per failure taxonomy
              fix and re-gate

2. Consumer Gate (required consumers per task type)
   ├── PASS → proceed to step 3
   └── FAIL → task enters "Consumer Gate Failed" state
              classify failure per failure taxonomy
              fix and re-gate

3. Boundary Test (if required per matrix)
   ├── PASS → proceed to step 4
   └── FAIL → classify violation, fix boundary breach, re-gate

4. Golden Test (if required per matrix)
   ├── PASS → proceed to step 5
   └── FAIL → update golden file or fix visual regression

5. Semantics Test (if required per matrix)
   ├── PASS → proceed to step 6
   └── FAIL → fix accessibility label or role, re-gate

6. Benchmark (if required per matrix)
   ├── PASS → task enters "Ready For Review" state
   └── FAIL → optimize or document regression with justification
```

If any gate fails, the task stays in the corresponding failure state (per
the [promotion state model](promotion-state-model.md)) and the builder must
fix the issue before re-gating.

---

## 5. Task Type Identification Guide

Use this table to classify a task. When a task touches multiple areas, apply
the most restrictive gate set (union of all applicable rows).

| Task Type | Indicators | Example Tasks |
|-----------|-----------|---------------|
| **Docs-only** | Only `.md` files, no `.dart` changes | Task 1201, Task 1202 |
| **ADS component** | Changes in `packages/warp_prism_ui/lib/atoms/`, `molecules/`, `organisms/`, `templates/` | Task 1106 (operational component MVP) |
| **ADS token/theme** | Changes to theme data, color tokens, typography tokens, spacing tokens | Task 1040 (glass budget) |
| **App route** | Changes to router, page scaffolds, navigation | Task 0011 (router shell), Task 0510 (map scaffold) |
| **Parser/data layer** | Changes to parsers, repositories, graph builders, projection logic | Task 0312 (mock workspace repo), Task 0313 (graph normalization) |
| **Monorepo migration** | Moves files between packages, changes import paths, restructures workspace | Task 1107 (melos migration) |
| **CyberCore fixture** | Changes to `apps/cybercore/`, fixture data, or CyberCore-specific tests | Task 1108 (scope route parity) |
| **Performance-sensitive** | Virtual scroll, lazy loading, animation optimization, render optimization | Task 1123 (virtual scroll) |
| **Governance/housekeeping** | Task governance, docs, reports, changelog, rules, templates | Task 1201, Task 1202, Task 1203 |

---

## 6. Pre-Existing Failure Policy

### Source

The failure baseline is documented in
`docs/reports/warp-prism-test-failure-baseline.md` (Task 1201).

### Current Baseline Snapshot (2026-06-09)

| Package | Pass | Fail | Pass Rate |
|---------|------|------|-----------|
| warp_prism_ui | 764 | 24 | 97.0% |
| observatory | 589 | 64 | 90.2% |
| cybercore | 12 | 0 | 100% |
| catalog | 1 | 0 | 100% |
| **Total** | **1366** | **88** | **94.0%** |

### Failure Classification

| Classification | Count | Packages Affected | Root Cause |
|----------------|-------|-------------------|------------|
| `wave4-regression` | 24 | UI | Wave 4 component changes (Tasks 1106-1122) broke contract tests |
| `pre-existing` | 64 | Observatory | Phantom completions from original 57-task wave |

### Policy Rules

1. **Pre-existing failures do not block promotion of unrelated tasks.** A task
   that does not touch the failing area is not responsible for fixing those
   failures. However, the builder must document the pre-existing failure count
   in the task's Completion Evidence.

2. **Tasks that touch an area with related pre-existing failures cannot be
   promoted until those failures are resolved or explicitly justified.** If a
   task modifies files in an area that has pre-existing failures, the builder
   must either:
   - Fix the pre-existing failures as part of the task, OR
   - Document that the pre-existing failures are unrelated to the task's
     changes (classify per the failure taxonomy), OR
   - Create a follow-up task to address the pre-existing failures.

3. **The failure baseline is the ground truth.** New failures introduced by a
   task must be caught by the package gate. The baseline is updated when
   remediation tasks (EPIC-14) reduce the failure count.

4. **Wave4-regression failures (24 in UI) are known and assigned.** These are
   expected to be fixed by Tasks 1303, 1304, 1307, 1309. Until those tasks
   complete, UI package gate results must be compared against the current
   baseline (764 pass / 24 fail), not a zero-failure expectation.

5. **Observatory pre-existing failures (64) are tracked in EPIC-14.** Tasks
   1401-1408 are expected to resolve them. Until then, the observatory package
   gate must be compared against the current baseline (589 pass / 64 fail).

### How to Document Pre-Existing Failures in Completion Evidence

```markdown
## Completion Evidence

- **Package gate result**: `melos run test-ui` — 764 pass, 24 fail (matches baseline)
- **New failures introduced**: 0
- **Pre-existing failures touched**: [list any failures the task modified files for]
- **Pre-existing failures unrelated**: [list failures in areas the task did not touch]
- **Follow-up tasks**: [if pre-existing failures need separate remediation]
```

---

## 7. Multi-Package Tasks

Some tasks modify files in multiple packages. For these:

1. **Package Gate**: Run `flutter analyze` and `flutter test` in **every**
   modified package. All must pass.
2. **Consumer Gate**: Run the consumer gate for **every** consumer that imports
   any of the modified packages. The union of consumer requirements applies.
3. **Boundary Test**: Check boundaries for all modified packages.

Example: A task that changes both `warp_prism_ui` (ADS component) and
`apps/observatory` (route) must pass:
- Package gate: `melos run test-ui` AND `melos run test-observatory`
- Consumer gate: `melos run test-catalog` AND `melos run test-cybercore`
  (because they import `warp_prism_ui`)
- Boundary test: full boundary check

---

## 8. Quick Reference Card

### "I just finished coding. What gates do I run?"

```
Is this a docs-only or governance task?
├── YES → No gates required. Add changelog, fill completion evidence.
└── NO ↓

Which package did I modify?
├── warp_prism_ui → melos run test-ui && melos exec --scope warp_prism_ui -- flutter analyze
├── observatory   → melos run test-observatory && melos exec --scope warp_prism_observatory -- flutter analyze
├── cybercore     → melos run test-cybercore && melos exec --scope warp_prism_cybercore -- flutter analyze
└── catalog       → melos run test-catalog && melos exec --scope warp_prism_catalog -- flutter analyze

Did the package gate pass?
├── NO → Fix failures. Classify per failure taxonomy. Re-gate.
└── YES ↓

Does my task type require a consumer gate?
├── ADS component / ADS token/theme → melos run test-observatory && melos run test-catalog && melos run test-cybercore
├── Monorepo migration              → same as above (all consumers)
├── Performance-sensitive           → same as above (all consumers)
├── App route / Parser / Fixture    → only the affected consumer(s)
└── No consumer gate needed         → skip

Did the consumer gate pass?
├── NO → Fix failures. Re-gate.
└── YES ↓

Does my task type require a boundary test?
├── YES → melos run test-boundaries (or manual rg checks)
└── NO → skip

Does my task touch golden / semantics / performance?
├── Golden files   → flutter test --tags=golden
├── Semantics      → flutter test test/accessibility/
├── Performance    → flutter test test/benchmarks/
└── None of above  → skip

All required gates passed → task is Ready For Review.
```

---

## 9. References

- **Failure baseline**: `docs/reports/warp-prism-test-failure-baseline.md`
  (Task 1201)
- **Promotion state model**: `docs/governance/promotion-state-model.md`
  (Task 1202)
- **Task template**: `.project/tasks/000-template.md` (includes `Review State` field)
- **Task governance**: `.agents/rules/task-governance.md`
- **Melos scripts**: `pubspec.yaml` (root, `melos.scripts` section)
- **Boundary test harness**: `melos run test-boundaries` (root `pubspec.yaml`)
- **Review packets**: planned in Task 1207
- **Failure classification**: Task 1206
