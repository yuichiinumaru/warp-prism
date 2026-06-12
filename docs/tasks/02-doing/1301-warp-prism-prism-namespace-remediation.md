# Task 1301: Prism Namespace Remediation

> **Status**: `[x]` Builder Done
> **Review State**: Builder Done — completion evidence filled; gate verification pending
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, `DS*` vs `Prism*` namespace split.
> **Blocks**: 1303, 1304, 1305, 1205 (boundary tests validate this)
> **Depends on**: 1202 (promotion state model)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1301` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Establish `Prism*` as the sole public API namespace for `warp_prism_ui` and
migrate `apps/cybercore/` away from direct `DS*` usage. The `DS*` prefix
remains as internal implementation but must not be used by consumer apps.

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/src/prism_aliases.dart` provides `Prism*` aliases
  for some tokens and components.
- The public barrel `warp_prism_ui.dart` exports both `DS*` (via sub-barrels)
  and `Prism*` (via aliases).
- `apps/cybercore/` uses `DSColors`, `DSSpacing`, `DSBreakpoints`, `DSTypography`,
  `DSMetricTile`, `DSStoryPanel`, `DSDataTable`, `DSLaneBoard`, `DSTimeline`,
  etc. directly.
- EPIC-11 expansion decision identified this as a boundary violation.

### What is missing or broken

- `Prism*` aliases do not cover all public DS components, tokens, and types.
- The public barrel exports `DS*` names directly, allowing consumers to bypass
  the `Prism*` API.
- CyberCore has not been migrated to `Prism*` names.
- No automated check prevents `DS*` usage in consumer apps.

---

## Test Requirements

- All `Prism*` aliases exist for every public token, component, and type.
- `apps/cybercore/` uses only `Prism*` names (zero `DS[A-Z]` matches).
- Public barrel exports only `Prism*` names for consumer use.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/prism_aliases.dart` provides aliases for all
  public tokens, atoms, molecules, organisms, and templates.
- [x] `apps/cybercore/lib/` contains zero instances of `DS[A-Z]` (verified by
  `rg "DS[A-Z]" apps/cybercore/lib` returning empty).
- [x] Public barrel `warp_prism_ui.dart` exports `Prism*` as the primary API.
- [ ] Boundary test harness (Task 1205) passes the CyberCore DS* check.
  (1205 not yet executed — blocked on harness creation)
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/lib/src/prism_aliases.dart`,
  `packages/warp_prism_ui/lib/warp_prism_ui.dart`,
  `packages/warp_prism_ui/lib/src/tokens/tokens.dart`,
  `packages/warp_prism_ui/lib/src/atoms/atoms.dart`,
  `packages/warp_prism_ui/lib/src/molecules/molecules.dart`,
  `packages/warp_prism_ui/lib/src/organisms/organisms.dart`,
  `packages/warp_prism_ui/lib/src/templates/templates.dart`.
  Scan `apps/cybercore/lib/` for all `DS[A-Z]` occurrences.
- [x] Audit `prism_aliases.dart` and identify missing aliases.
- [x] Add missing `Prism*` aliases for all public types.
- [x] Migrate `apps/cybercore/lib/` to use `Prism*` names.
- [x] Verify public barrel exports `Prism*` as primary API.
- [x] Run `rg "DS[A-Z]" apps/cybercore/lib` and verify zero matches.
- [x] **Simplicity pass**: `DS*` stays as internal implementation. Do not rename
  internal files or classes.
- [ ] **Regression verification**: run boundary test harness. (1205 not yet available)

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — add missing aliases |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read / possibly modify — barrel exports |
| `apps/cybercore/lib/**/*.dart` | Modify — replace DS* with Prism* |

### How

1. Scan CyberCore for all `DS*` usages.
2. Audit `prism_aliases.dart` and identify which DS* names lack Prism* aliases.
3. Add missing aliases.
4. Migrate CyberCore imports and usages to Prism* names.
5. Verify with grep.

### Why

The `DS*` vs `Prism*` split is the #1 architectural blocker. Until consumer apps
use only the public `Prism*` API, the boundary between ADS internals and
consumer surface is not enforced. This blocks all downstream promotion.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not rename `DS*` internal classes. Only add aliases and migrate consumers.
> Internal implementation keeps `DS*` for now.

> [!IMPORTANT]
> The decision on whether `apps/observatory/` also migrates to `Prism*` is
> deferred. For now, only CyberCore must migrate. Observatory can remain on
> `DS*` as legacy until a separate task addresses it.

---

## Validation Commands

```bash
rg "DS[A-Z]" apps/cybercore/lib
# Expected: 0 matches after migration
dart tool/test_boundaries.dart
# Expected: CyberCore DS* check now passes
```

---

## Completion Evidence

- **Files created/modified**:
  - Modified: `packages/warp_prism_ui/lib/src/prism_aliases.dart` (added 8 token aliases + imports)
  - Modified: `apps/cybercore/lib/main.dart` (DSColors → PrismColors)
  - Modified: `apps/cybercore/lib/app/cybercore_shell.dart` (DSColors, DSSpacing, DSRadii, DSBreakpoints, DSTypography → Prism*)
  - Modified: `apps/cybercore/lib/features/dashboard/dashboard_page.dart` (DSColors, DSSpacing → Prism*)
  - Modified: `apps/cybercore/lib/features/governance/governance_page.dart` (DSColors, DSSpacing → Prism*)
  - Modified: `apps/cybercore/lib/features/audit/audit_page.dart` (DSColors, DSSpacing → Prism*)
  - Modified: `apps/cybercore/lib/features/tasks/tasks_page.dart` (DSColors, DSSpacing → Prism*)
  - Modified: `apps/cybercore/lib/features/registry/registry_page.dart` (DSColors → Prism*)
  - Created: `docs/design/prism-namespace-remediation-report.md`
  - Created: `docs/changelog/20260609-210000-1301-2026-06-09-task-1301-prism-namespace-remediation-builders.md`
- **Tests or validation commands**:
  - `rg "DS[A-Z]" apps/cybercore/lib/` → 0 matches ✅ PASS
  - `flutter analyze lib/src/prism_aliases.dart` → No issues found ✅ PASS
  - `flutter analyze apps/cybercore/lib/` → No issues found ✅ PASS
  - `flutter analyze packages/warp_prism_ui/lib/` → 460 pre-existing info lints, 0 errors ✅ PASS
  - Observatory DS* count: 78 (deferred per task spec)
- **Local changelog entry**: `docs/changelog/20260609-210000-1301-2026-06-09-task-1301-prism-namespace-remediation-builders.md`
- **Agent-wiki / docs institutionalization**: `docs/design/prism-namespace-remediation-report.md`
- **Executor**: builders
- **Completion date**: 2026-06-09
