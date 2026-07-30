# Task 1301: Prism Namespace Remediation

> **Status**: `[x]` Builder Done
> **Review State**: Held in Review — independent re-review 97/100 (2026-07-09); namespace gates green; not auto-completed
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
  for tokens and components.
- The public barrel `warp_prism_ui.dart` exports `Prism*` via aliases and
  gallery documentation surfaces with `DSGallery*` names hidden.
- `apps/cybercore/` uses only `Prism*` names (zero `DS[A-Z]` matches).
- Boundary harness enforces six package-namespace rules including alias
  completeness and public-barrel DS* leakage.

### What is missing or broken

- (Closed 2026-07-09) Prior rejection: harness was 4/4 without alias/barrel
  checks; gallery exported public `DSGallery*` types. Both remediated.

---

## Test Requirements

- All `Prism*` aliases exist for every public token, component, and type.
- `apps/cybercore/` uses only `Prism*` names (zero `DS[A-Z]` matches).
- Public barrel exports only `Prism*` names for consumer use (gallery
  documentation types exposed as `PrismGallery*`).

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/prism_aliases.dart` provides aliases for all
  public tokens, atoms, molecules, organisms, templates, and gallery types.
- [x] `apps/cybercore/lib/` contains zero instances of `DS[A-Z]` (verified by
  `rg "DS[A-Z]" apps/cybercore/lib` returning empty).
- [x] Public barrel `warp_prism_ui.dart` exports `Prism*` as the primary API and
  hides public `DSGallery*` declarations.
- [x] Boundary test harness passes all seven checks including CyberCore DS*,
  alias completeness, and public barrel DS leakage.
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
- [x] **Regression verification**: run boundary test harness (7/7 PASS).
- [x] **Path-to-100 (2026-07-09)**: hide `DSGallery*` from public barrel, add
  `PrismGallery*` aliases, add `PrismInteractiveSurface`, restore alias
  completeness + public-barrel DS-leak boundary checks.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — add missing aliases |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify — hide DSGallery* from barrel |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Modify — restore 6-check harness |
| `apps/cybercore/lib/**/*.dart` | Modify — replace DS* with Prism* |

### How

1. Scan CyberCore for all `DS*` usages.
2. Audit `prism_aliases.dart` and identify which DS* names lack Prism* aliases.
3. Add missing aliases.
4. Migrate CyberCore imports and usages to Prism* names.
5. Hide gallery DS* declarations from the public barrel; export Prism aliases.
6. Enforce with boundary harness (alias completeness + barrel DS hide).
7. Verify with grep + scoped analyze.

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
dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Expected: 7/7 PASS including CyberCore DS*, alias completeness, public barrel hide
dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart
# Expected: No issues found
```

---

## Completion Evidence

- **Files created/modified**:
  - Modified: `packages/warp_prism_ui/lib/src/prism_aliases.dart`
    - token/component aliases (prior)
    - `PrismInteractiveSurface` (2026-07-09)
    - `PrismGallerySectionSpec`, `PrismGallerySections` (2026-07-09)
  - Modified: `packages/warp_prism_ui/lib/warp_prism_ui.dart`
    - gallery exports hide `DSGallerySectionSpec` / `DSGallerySections`
  - Modified: `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
    - restored checks 5–6: Prism alias completeness + public barrel DS hide
  - Modified (prior): CyberCore app files migrated DS* → Prism*
  - Created (prior): `docs/design/prism-namespace-remediation-report.md`
  - Created (prior): `docs/changelog/20260609-210000-1301-2026-06-09-task-1301-prism-namespace-remediation-builders.md`
  - Created (2026-07-09): `docs/changelog/2026-07-09-task-1301-prism-namespace-path-to-100.md`
- **Tests or validation commands** (2026-07-09 live re-run):
  - `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **7/7 PASS**
    - CyberCore contains zero DS* references
    - Consumer apps do not import warp_prism_ui src/ paths
    - warp_prism_ui does not import Riverpod or GoRouter
    - warp_prism_ui does not import app-specific packages
    - All public DS declarations have Prism aliases
    - Public barrel hides DS* names from consumers
  - `rg "DS[A-Z]" apps/cybercore/lib` → 0 matches ✅
  - `dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart` → No issues found ✅
  - `dart format --output=none --set-exit-if-changed` on barrel/aliases/boundary_test → 0 changed ✅
  - Observatory DS* migration deferred per task spec
- **Local changelog entry**: `docs/changelog/2026-07-09-task-1301-prism-namespace-path-to-100.md`
- **Agent-wiki / docs institutionalization**: `docs/design/prism-namespace-remediation-report.md`
- **Executor**: builders
- **Completion date**: 2026-06-09
- **Path-to-100 completion date**: 2026-07-09

---

## Review Ledger

### 2026-06-30 — reviewers independent review
**Score**: 64/100 — REJECTED
**Path to 100** (closed 2026-07-09):
1. Restore alias completeness + public-barrel DS-leak boundary checks → **done (7/7)**
2. Hide/Prism-wrap `DSGallery*` from top-level barrel → **done**
3. Reconcile duplicate lane artifacts → **only `02-doing` copy active; promoting to `03-review`**

### 2026-07-09 — builders path-to-100
**Score (self)**: 100/100
**Verdict**: Ready For Review — all exit conditions green on live gates.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `97/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1301-prism-namespace-independent-rereview.md`
- **Lane outcome**: remains in `docs/tasks/03-review/` (S ≥ 90; never auto-moved to `04-completed`)
- **Task reference**: Task 1301 (`warp-prism-prism-namespace-remediation`)

#### Current Open Blockers

- None against Task 1301 exit conditions.
- `NEW` Low (note): intentional non-Prism gallery entrypoints `DesignSystemGalleryPage` / `dsGallerySections` remain.
- `NEW` Low (cross-task): Task 1302 audit under-counts symbols / omits `PrismInsightRiskLevel` — track under 1302, not a 1301 gate failure (alias exists live).

#### Path-to-100 Summary

1. Optional: sync design report wording with full alias list including `PrismInsightRiskLevel`.
2. Optional follow-up: separate gallery entrypoint (non-blocking).
3. No functional code change required for namespace exit conditions.

#### Regression Guards

- Public barrel must not re-export DS layer barrels or un-hide `DSGallery*`.
- Boundary harness checks 5–6 (alias completeness + barrel hide) must stay enabled and green.
- CyberCore must remain zero `DS[A-Z]`.
- Observatory DS* migration remains deferred unless a new task says otherwise.

### Previous Reports

- `2026-07-09` — builder self 100/100 — path-to-100 entry above
  - **Resolved since independent rejects**: 7/7 harness, DSGallery hide, 1202 dep completed
- `2026-06-30` — 64/100 — task ledger (alias/barrel checks + gallery)
- `2026-06-17` — 72/100 — `docs/reports/build-gate-review/1301-review-2026-06-17-independent.md`
  - **Resolved**: DSOperationalStateUI-style leak / barrel DS hide; 1202 now `04-completed`
- `2026-06-13` — 100/100 — `docs/reports/build-gate-review/1301-review.md` (historical)


---

### 2026-07-17 — drain independent re-review (reviewers)
- **Score**: `96/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1301-drain-review.md`
- **Prior**: 97/100 (draft; revalidated live)
- **Top residual / path-to-100**: Exit text synced to seven checks (live 7/7); non-Prism gallery entrypoints intentional residual
- **Lane outcome**: `04-completed/`


### 2026-07-18 path-to-100 batch4 (builders)
- Exit/evidence wording **six → seven** boundary checks to match live harness.
- Live re-proof: **7/7 PASS** (incl. persistence/IO + alias completeness).
- Report notes: `docs/reports/path-to-100-wave-2026-07-17/batch4-notes.md`
- Lane: left in `03-review/` (no self-promote)

---

### 2026-07-18 — independent path-to-100 re-review (reviewers, batch R4)
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1301-path100-rereview.md`
- **path100_applied**: yes — exit wording six→seven; live 7/7 alias+barrel hide
- **Live exits**: 7/7 harness; barrel hides DSGallery*; Prism aliases; CyberCore DS* 0
- **Top residual**: Intentional non-Prism gallery entrypoints (DesignSystemGalleryPage)
- **Lane outcome**: `03-review/` → `04-completed/`
- **No git / no tasklist**
