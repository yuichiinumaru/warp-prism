# Task 1816: Post-1805 Visual/Baseline Freeze

> **Priority**: 🔴 P0 · **Type**: `governance`
> **Origin**: EPIC-19 (S19-06) · Source-Reality Review 2026-09-01
> **Blocks**: Post-v2 visual baseline updates, goldens regeneration v2
> **Depends on**: Task 1805 (Screenshot Visual Acceptance Gate — EXTERNAL HUMAN BLOCKER)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 19-E visual baseline freeze (canonical v2 visual reference for all later UI work)
- **Strategic why**: L1 UI work must be validated against a frozen, human-approved visual baseline; without it, goldens and visual acceptance remain on legacy pre-Obsidian baselines.
- **Consequence if absent**: golden suites stay frozen on stale baselines (59 failures expected); any v2 visual verification is unverifiable.

## Human-Blocker Protocol

Task 1805 requires **product-owner/user visual sign-off** — a reviewer cannot substitute it. The first subtask verifies recorded sign-off and STOPs if missing. This task is not executable until that sign-off exists; it stays in `00-planning/` as a materialized hold until then.

## Objective

Following the recorded user approval and sign-off on Task 1805 (Screenshot Visual Acceptance Gate), regenerate and freeze all golden test suites across packages and apps against the approved Black Obsidian visual contract, document the canonical visual baseline v2, and lift the interim golden freeze policy.

## Background Context

### What already exists

- `.project/reports/1805-visual-acceptance-gate-report.md` — visual acceptance gate report (marked PENDING-USER sign-off).
- `docs/design/black-obsidian-visual-contract.md` — live visual contract canon.
- 13 golden test suites in `packages/warp_prism_ui/test/goldens/` frozen under Task 1800/1805 interim golden freeze policy.
- Screenshot integration capture test suites in `apps/catalog`, `apps/observatory`, and `apps/cybercore`.

### What is missing or broken

- Golden files remain frozen against legacy pre-Obsidian baselines (59 golden failures expected during interim freeze).
- Canonical visual baseline v2 document not yet finalized.
- Interim golden freeze policy remains active until formal human sign-off on Task 1805.

## Subtasks

- [ ] **Read before modifying**: `.project/reports/1805-visual-acceptance-gate-report.md`, `docs/design/black-obsidian-visual-contract.md`, `packages/warp_prism_ui/test/goldens/`.
- [ ] **Verify human sign-off**: confirm explicit human/product-owner approval on Task 1805 is recorded before proceeding. If sign-off is missing, STOP (external human blocker).
- [ ] **Regenerate goldens**: run `flutter test test/goldens/ --update-goldens` in `packages/warp_prism_ui`.
- [ ] **Verify golden suite passes**: ensure all golden test suites pass cleanly with 0 failures against the updated baselines.
- [ ] **Document visual baseline v2**: create `docs/design/visual-baseline-v2.md` recording checksums, sample screenshots, and token mappings.
- [ ] **Update golden policy**: transition golden policy from `FREEZE` to `ACTIVE_CANONICAL`.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub
flutter analyze packages/warp_prism_ui
cd apps/catalog && flutter test --no-pub
```

## Where

| File | Purpose |
|---|---|
| `docs/design/visual-baseline-v2.md` | Create — canonical visual baseline v2 record |
| `packages/warp_prism_ui/test/goldens/` | Regenerate — updated golden files |
| `.project/reports/1805-visual-acceptance-gate-report.md` | Update — record final approved status |

## Exit Conditions

- [ ] Explicit user sign-off on Task 1805 verified in evidence.
- [ ] All golden test suites in `packages/warp_prism_ui/test/goldens/` regenerated and passing (0 failures).
- [ ] `docs/design/visual-baseline-v2.md` committed with baseline documentation.
- [ ] Golden policy updated to active canonical.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: [list]
- **Tests or validation commands**: [commands + PASS/FAIL]
- **Local changelog entry**: [path]
- **Executor**: [agent]
- **Completion date**: [YYYY-MM-DD]
