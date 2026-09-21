# Task 1813: State-Based Declutter + Root Hygiene

> **Priority**: 🔴 P0 · **Type**: `housekeeping`
> **Origin**: EPIC-19 (S19-05) · Source-Reality Review 2026-09-01
> **Blocks**: Boundary harness full-green state (check 9 ships here); Task 1825 check-9 audit row
> **Depends on**: None (root task — does NOT depend on Task 1805 per A2 split)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 19-D root hygiene + boundary check 9 (one of the L1 exit-gate audit rows in 1825)
- **Strategic why**: the ~22 root scratch files are deterministic debt that check 9 must police forever; sweep + gate + PASS must land as one atomic unit so CI is never red on pre-existing debt.
- **Consequence if absent**: root clutter persists; check 9 either never lands or lands red (CI-race design flaw).

## Shared-Write Ownership (boundary_test.dart)

`packages/warp_prism_ui/test/boundaries/boundary_test.dart` is shared with Task 1811 (see its ownership note). **Operational rule (operator directive, 2026-09-01): in a shared workspace, Tasks 1811 and 1813 must NOT run simultaneously — serialize 1811 → 1813.** This is a writeset dependency, not an architectural one: both append to `boundary_test.dart`, and concurrent edits on the same working tree are forbidden. Only truly isolated worktrees with governed integration may lift this serialization. This task appends **check 9 only** and performs the root sweep atomically in the same pass — sweep + gate + PASS together. Task 1811's check 8 is an independent append; neither task asserts a total check count.

## Archive-First Law (operator directive, 2026-09-01)

**No file may be deleted by the agent in this task.** The `delete (no value)` classification option is REMOVED. Every root scratch file is classified to exactly one of:

- `tool/` — legitimate reusable tooling;
- `scripts/` — legitimate build/utility scripts;
- `docs/archive/` — historical value (with a provenance record in the classification table: original path, date, purpose, task provenance).

Files with zero apparent value still go to `docs/archive/` (e.g. a `docs/archive/root-scratch/` subfolder) — the operator may prune archives later; the agent never deletes.

## Non-Goals

- **Do not**: move or delete any task lane file (`docs/tasks/**`) — the declutter rule is documented here, its application to lanes is out of scope.
- **Do not**: touch `docs/tasks/00-planning/PLAN-03-review-drain.md` unless a classification directly affects the drain plan (conditional write, listed below).
- **Do not**: DELETE any file — archive-first is law (see above); every file moves to `tool/`, `scripts/`, or `docs/archive/` with a provenance record.
- **Do not**: edit code under `packages/` or `apps/` — scratch-file classification touches root-level files only.

## Objective

Establish state-based declutter rules (CURRENT OPERATING SET vs HISTORICAL CORPUS by lifecycle state, not epic number), sweep the ~22 root scratch files into `tool/`, `scripts/`, or archive, and install + enable boundary harness check 9 atomically — verifying 0 scratch files remain at root.

## Background Context

### What already exists

- ~22 root scratch files: `fix_0001.py`, `fix_0010.py`, `fix_0011.py`, `fix_0610.sh`, `fix_0611.sh`, `fix_evidence.py`, `fix_imports.py`, `fix_test.py`, `fix2.py`, `patch_ds_chip.py`, `patch2_ds_chip.py`, `replace_ds.sh`, `start-tmux.sh`, `append_to_atoms.dart`, `append_to_molecules.dart`, `snippet_molecules_tests.dart`, `test_molecules_append.dart`, `test_public_api.dart`, `test_shell.dart`, `tmp_fix_heights.py`, `tmp_fix_sizedboxes.py`, `tmp_height_patch.py`.
- `tool/validate_mock_workspace.py` — only current tooling.
- `packages/warp_prism_ui/test/boundaries/boundary_test.dart` — boundary harness.

### What is missing or broken

- No state-based declutter rule exists.
- Root scratch files pollute the workspace root.
- Boundary harness check 9 needs atomic installation alongside file sweep to prevent CI race conditions.
- No `scripts/` directory for legitimate build/tooling scripts.

## Subtasks

- [x] **Read before modifying**: each root scratch file (first 5 lines for purpose), `docs/tasks/04-completed/` (to understand provenance of completed tasks), `packages/warp_prism_ui/test/boundaries/boundary_test.dart`.
- [x] **Classify each root file**: `tool/` (legitimate reusable tooling), `scripts/` (legitimate build/utility scripts), or `docs/archive/` (historical value; zero-value files included — **no delete option exists**).
- [x] **Create `scripts/` directory** for legitimate build/tooling scripts.
- [x] **Move files** to proper homes per classification.
- [x] **Create `docs/archive/`** for historical files if needed.
- [x] **Add harness check 9 to `boundary_test.dart`**: `Repository root contains no fix_/tmp_/patch_/append_/snippet_/test_ scratch files` — glob root for the full enumerated list below (not just the 5 prefixes; covers `replace_ds.sh` and `start-tmux.sh` via the `ls`-based pattern class).
- [x] **Update `docs/tasks/00-planning/PLAN-03-review-drain.md`** if classification affects drain plan (conditional write - checked, unaffected).
- [x] **Simplify pass**: remove unnecessary complexity.
- [x] **Regression verification**: run validation commands.

## Validation Commands

```bash
# Check 9: root scratch files gone
ls *.py *.sh *.dart 2>/dev/null | grep -vE "^(pubspec|melos)" | wc -l   # expect 0
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .   # boundary harness passes with check 9
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `tool/` | Move legitimate tooling scripts here |
| `scripts/` | Create — move legitimate build scripts here |
| `docs/archive/` | Create — historical files with provenance (archive-first law: this or tool//scripts/ are the ONLY destinations; never delete) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Modify — add check 9 (atomic with sweep) |
| `docs/tasks/00-planning/PLAN-03-review-drain.md` | Conditional modify — only if classification affects drain plan |

## Exit Conditions

- [x] State-based declutter rule documented: CURRENT = non-terminal tasks + active planning + canon + active evidence; HISTORICAL = terminal + superseded + old waves.
- [x] All root scratch files classified and MOVED (tool/, scripts/, or docs/archive/ — **zero deletions**, provenance record for every file).
- [x] Boundary harness check 9 installed and active in `boundary_test.dart`.
- [x] Boundary harness passes with 0 root scratch files.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**:
  - `scripts/` (new directory)
  - `scripts/README.md` (new file)
  - `scripts/start-tmux.sh` (moved from root)
  - `docs/archive/` (new directory)
  - `docs/archive/README.md` (new file - state-based declutter rule)
  - `docs/archive/root-scratch/` (new directory)
  - `docs/archive/root-scratch/PROVENANCE.md` (new file - full inventory + provenance table)
  - 21 files moved from root to `docs/archive/root-scratch/`
  - `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (appended check 9)
  - `docs/tasks/01-open/1813-warp-prism-state-based-declutter.md` (subtasks + evidence updated)
- **Tests or validation commands**:
  - `ls *.py *.sh *.dart 2>/dev/null | wc -l`: 0 (PASS)
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`: 9/9 PASS (PASS)
  - `flutter analyze packages/warp_prism_ui`: no new issues (PASS)
  - `ls docs/archive/root-scratch/ | wc -l`: 22 (21 moved scripts + PROVENANCE.md) (PASS)
- **Local changelog entry**: [Reported in builder return packet]
- **Executor**: builder-engineer (Task 1813)
- **Completion date**: 2026-09-01
