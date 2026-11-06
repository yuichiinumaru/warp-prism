# Task 1846: Clear the warp_prism_ui package-wide formatter baseline drift

> **Priority**: 🟡 Medium (hygiene; blocks a deterministic package gate)
> **Type**: `chore` | `hygiene` | `flutter`
> **Origin**: Task 1839 review Entry 4, finding F5 (2026-09-30)

## Problem

`cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed lib/ test/`
exits nonzero: **53 of 312 files** would be reformatted. This predates Task 1839
(it reported 57 before that task and 56 after), so it is pre-existing aggregate
drift, not a regression.

It nonetheless blocks a clean package gate and caused a repeated Serious finding
on Task 1839, because a reviewer cannot distinguish task-introduced drift from
baseline drift without a per-file preimage.

## Objective

Reformat the 53 files, or land a documented baseline file that pins the current
drift so the gate is deterministic and future tasks can attribute drift
mechanically.

## Where

- `packages/warp_prism_ui/lib/**` and `packages/warp_prism_ui/test/**` — the 53 flagged files
- optionally `packages/warp_prism_ui/.formatted-baseline.json` — machine-readable baseline

## Validation

```bash
cd packages/warp_prism_ui && dart format lib/ test/ \
  && dart format --output=none --set-exit-if-changed lib/ test/   # must exit 0
cd packages/warp_prism_ui && dart analyze && flutter test --no-pub
```

Note: the 63 golden mismatches in the full suite are a separate pre-existing
condition frozen under Task 1805. Do NOT run `--update-goldens`. Use
`flutter test test/ --no-pub --exclude-tags=golden` as the meaningful gate.

## Non-Goals

- No behaviour change. Formatting is whitespace-only; if a reformat causes a
  test to fail, stop and report rather than adjusting the test.
- No golden refresh.
- No touch to other packages.

## Lane History

- **2026-10-02 (execution)**: builder (fleet B engineer session; ID not recorded
  in the session ledger) executed approach (a) reformat: 53/53 authorized files
  reformatted, token-identity proof per file, gates green. Foreign mid-task
  files (Task 1843's new gallery tests) were the only residual format red at
  that time. Builder report:
  `.project/reports/builders/1846-formatter-baseline-drift-builder-report.md`.
  The claim move `01-open → 02-doing` was missed at dispatch time.
- **2026-10-04 (reconciliation, orchestrator-architects)**: lane corrected to
  `02-doing` post-hoc (Rule 42 §15). Awaiting independent review; reviewer must
  verify the current tree is fully format-clean (1843's files are now formatted
  per its own report).

## Completion Evidence

- Independent review: `.project/reports/reviewers/1846-formatter-baseline-drift-review-loop.md`, Round 1 (2026-10-15), PASS, diagnostic 96/100. Review subject is the 53 authorized formatting-only files, not a repository-wide format-clean claim.
- Per-file formatter check: 53/53 clean; reviewer reports no token changes attributable to Task 1846 and no golden baseline changes.
- Reviewed validation: `dart analyze` exit 0 (213 info, no errors/warnings); `flutter test test/ --no-pub --exclude-tags=golden` exit 0 (+1705); boundary harness from repository root exit 0 (16/16).
- Whole-package formatter check at review: exit 1 due to two foreign Task-1843 probes, `zz_probe_1843_iter2_attribution_test.dart` and `zz_probe_1843_iter2_census_test.dart`. The original package-clean exit remains open until their disposition; this does not invalidate the historical PASS on the authorized 53-file delta.
- Repository-wide format drift is separately reported in review D1 and is outside this task's writeset. Do not infer a green root gate from this review.
- Local changelog closeout: pending parent reconciliation after the active gallery review; no lifecycle promotion or persistence claimed here.

## Gate update — 2026-11-06

- Task-1843 probe files archived (see Task 1843 F3 remediation): `dart format --output=none --set-exit-if-changed lib/ test/` from `packages/warp_prism_ui` now exits 0 over 379 files — the whole-package gate the task required is green. The authorized 53-file delta remains token-identical per the Round 1 review.
- Local changelog closeout: still pending the canonical changelog mechanics (tool unreachable this session); recorded as the sole open item. Promotion follows in the closeout batch.

## Review Ledger

- Independent reviewer session: `ses_ebdd62ec4ffeRBNK41JPf7TzxK`; Round 1 carrier linked above. Semantic review PASS for the 53-file delta is preserved. Administrative closeout remains pending the package-gate residual and changelog evidence; no product files changed during this reconciliation.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 96/100 Round 1 on 53-file delta; whole-package format now 379/0 after probe archival (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1846-warp-prism-formatter-baseline-drift-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
