# rem-0001: Boundary harness row-16 enforcement + domain regex + §10 status column

> **Remediation namespace**: `rem-NNNN` (overnight remediation wave 1; independent numbering — never collides with canonical `NNNN`). Source finding: Inv-1 (`ses_ed6d99da3ffeqPghq5y9Hovbpc`) Gaps 1, 2, 5.
> **Review State**: `Review Approved`
> **Priority**: 🟡 P1 | **Type**: `remediation` | **Origin**: architect investigation (mechanical law-vs-harness gap)
> **Blocks**: N/A | **Depends on**: N/A (writeset disjoint from 02-doing 1840/1843/1846; validation may contend on test-resource lock — see contention note)
> **parallel-safe**: file writes (single file) — yes; test execution — serial vs concurrent flutter runs (retry protocol below)

---

## Review Trail

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_ed6b7af4bffeNeNMY2sRAiTKmk` (independent — did not build)
- **Verdict**: PASS (92/100 diagnostic) — 2026-10-11
- **Re-verified**: harness 16/16 PASS exit 0 (reviewer re-run); check #16 genuinely bindings-scoped (`:735–744`), distinct from #15; regex exactly `|Warpblade|Tempest` added with zero live hits; §10 16-row all-ENFORCED, row-16 marker gone; analyze + format clean; fixture zero residue; no pre-existing check weakened.
- **Recorded nuance F2 (accepted)**: #16 adds dedicated traceable enforcement, not new detection (#15 subsumes its violation set). Deliverable honest as specified.
- **Promotion**: Review Approved → 04-completed by governance owner (overnight operator).

## Milestone Alignment

- **Target milestone**: N/A (remediation, not milestone-driven — hardening the enforcement harness, not advancing a product gate).
- **Capability / Gate advanced**: layer-contracts §9–§10 enforceability (law with no check is documentation).
- **Strategic why**: row 16 is explicitly declared "open work" in canonical architecture; the domain regex omits two law-named consumers.
- **Consequence if absent**: `bindings`-FRB violations pass silently; `Warpblade`/`Tempest` domain leakage undetectable.

---

## Objective

Make layer-contracts §10 row 16 mechanically enforced (16/16 harness checks), extend the domain-type regex to the two law-named consumers it omits, and reconcile the §10 table with a per-row enforcement-status column — in one coherent unit touching one test file + one architecture doc section.

## Background Context

### What already exists

- `packages/warp_prism_ui/test/boundaries/boundary_test.dart`: exactly 15 `BoundaryCheck{name, run}` entries (`:95–159`); check #15 (`_checkNoDirectFrbGeneratedImports`, `:678–727`) scans `packages/*/lib` excl. adapter for `src/rust/|frb_generated`.
- Domain regex at `:671`: `\b(Ganthritor|Cersei|OmniRoute|CyberCore)\b` — law text (`layer-contracts.md:85–86`) also names `Warpblade`, `Tempest`. Zero current hits for either (latent gap, not active leak).
- `layer-contracts.md:202–207` marks row 16 DOCUMENTATION ONLY ("correcting that is open work"); `:25–34` drift note records the lost enforcement-status column as open work.

### What is missing or broken

- No `bindings`-scoped FRB-import check (row 16 unenforced except incidentally via check #15).
- Regex omits two named consumers.
- §10 table has no status column (cannot tell enforced law from prose law).

---

## Test Requirements

- Harness reports 16/16 PASS including the new `bindings`-scoped check.
- A synthetic `Warpblade` token in a test fixture is detected (then reverted).
- `layer-contracts.md` §10 carries a per-row status column; row 16 no longer marked documentation-only.

## Exit Conditions

- [ ] New `BoundaryCheck` added + implemented (bindings-scoped FRB scan).
- [ ] Regex extended at `:671`; fixture-proof detection demonstrated then reverted.
- [ ] §10 status column added (16 rows); row-16 marker removed.
- [ ] `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` → 16/16 PASS (or contention protocol exhausted + recorded — see below).
- [ ] No other check weakened (15 pre-existing still green).
- [ ] Local changelog entry added under `.project/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `boundary_test.dart:95–159` (registry), `:653–727` (checks #14/#15 + regex), `layer-contracts.md:182–207` (§10 table).
- [ ] Add `BoundaryCheck(name: 'warp_prism_bindings does not import FRB generated surfaces', run: _checkBindingsNoFrbGenerated)` mirroring `_checkNoDirectFrbGeneratedImports` scoped to `packages/warp_prism_bindings/lib`.
- [ ] Extend `:671` regex with `Warpblade|Tempest`; fixture-proof detection; revert fixture.
- [ ] Add ENFORCED/DOCUMENTATION-ONLY status column to all 16 §10 rows; remove row-16 marker.
- [ ] **Simplicity pass**: no other harness behavior changed.
- [ ] **Regression verification**: run harness; confirm 16/16 + 15 pre-existing green.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Modify — new check + regex (only file touched for code) |
| `.project/architecture/layer-contracts.md` (§10 only, ~:182–207) | Modify — status column + marker removal (verify no concurrent editor via `git status` first) |
| `.project/changelog/` | Create — entry per workflow §3.6 |

### How

1. Read check #15 fully; mirror its scan logic with the bindings scope (do not refactor #15).
2. Fixture-proof BEFORE claiming detection works; revert the fixture in the same change.
3. Doc edit confined to §10; verify `git status` shows no other editor on that file first.

### Why

An unenforced MUST-NOT is a suggestion. Row 16 guards the bindings seam — the exact layer where FRB leakage would silently recouple transport to presentation.

---

## Contention note (test-resource lock)

`02-doing` workers run `flutter test` in `packages/warp_prism_ui` (shared `.dart_tool/`+`build/`). If harness execution fails with a tool-lock/contention error (not an assertion failure): wait 60s, retry, max 3 attempts. If still locked, STOP, record `BLOCKED-on-resource` with the exact error + timestamps in Completion Evidence, and hand off — do not force, do not weaken the validation.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not weaken or skip any of the 15 pre-existing checks. Do not leave the synthetic fixture in place. Do not edit layer-contracts outside §10.

---

## Validation Commands

```bash
dart packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

If Dart/Flutter tooling is unavailable, record the exact failure and do not claim checks passed. Assertion failures = FAIL (fix, do not weaken). Lock errors = contention protocol above.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (modified) — check #16 registered + `_checkBindingsNoFrbGenerated()` implemented; domain regex extended with `Warpblade|Tempest`.
  - `.project/architecture/layer-contracts.md` (modified, §10 only) — 16-row status column; row-16 DOCUMENTATION-ONLY marker removed.
  - `.project/changelog/20261011-043721-rem-0001-boundary-harness-row16-regex-status-builder-engineer.md` (created).
  - Fixture `packages/warp_prism_bindings/lib/rem0001_fixture_probe.dart` was created for detection proof and deleted in the same change (not left in place).
- **Tests or validation commands** (no contention encountered; retry protocol not needed):
  - `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` — pre-edit baseline: exit 0, 15/15 PASS.
  - same command with fixture in place: exit 1, 13/16 PASS — checks #14 (`Warpblade` token), #15, and #16 (FRB generated import) all flagged the fixture → detection proven.
  - same command after fixture revert (final): exit 0, **16/16 PASS, 0 FAIL, 0 violation(s)**; 15 pre-existing checks still green.
  - `dart format --output=none --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` — exit 0, 0 changed.
  - `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` — exit 0, no issues.
- **Local changelog entry**: `.project/changelog/20261011-043721-rem-0001-boundary-harness-row16-regex-status-builder-engineer.md`
- **Executor**: builder-engineer (subagent; session ID recorded by dispatching parent, not self-recorded)
- **Completion date**: 2026-10-11
- **Independent acceptance**: pending — executor claims are evidence input, not PASS.
