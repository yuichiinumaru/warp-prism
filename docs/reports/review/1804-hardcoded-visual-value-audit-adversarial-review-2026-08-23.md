# Task 1804 Adversarial Review — Hardcoded Visual-Value and Structural-Color Audit

- **Review date:** 2026-08-23
- **Reviewer profile:** `reviewers`
- **Review mode:** independent adversarial visual QA/editor review; builder-side `ACCEPTED_100` claim treated as untrusted
- **Score:** **92/100**
- **Verdict:** **PASS FOR INFRASTRUCTURE BASELINE; HELD FOR EVIDENCE/EDITOR DRIFT**
- **Lane:** remains `docs/tasks/03-review/`

## Lineage and claim reconciliation

Previous report: `docs/reports/review/1804-hardcoded-visual-value-audit-independent-review-2026-08-23.md` (builder-context `100/100`). Current review found material evidence drift since that report: the documented expected audit baseline of 2 is no longer live after Task 1807 introduced 15 raw preset literals in the Theme Editor and the color parser has 2 parsing literals. These are classified, not silently counted as structural violations, but the durable Task 1804 baseline is stale and must not claim exactly 2 findings.

## Contract / visual audit

The approved command was re-run exactly:

```text
rg -n "Color\.(fromARGB|fromRGBO)|Color\(0x|HSLColor" --glob '!**/tokens/**' packages/warp_prism_ui/lib apps/catalog/lib apps/observatory/lib apps/cybercore/lib
```

Live result: **18 matches** outside token files:

- `hex_color_parser.dart`: 2 parser implementation literals — **exempt parser/data behavior**.
- `prism_theme_editor.dart`: 15 preset literals — **fixture/editor preset data**, but the Task 1804 report's expected baseline is stale and Task 1806's raw-color report also predates these additions.
- `ds_keyboard_cheatsheet.dart`: 1 alpha scrim — **legitimate elevation/scrim**.
- Media overlay: 0 raw matches — migration remains live.
- App `lib` surfaces: 0 raw matches.

Token files were checked separately and remain the source-of-truth lane. No new structural raw colors were found in media overlay or app implementations. The provisional visual contract remains explicit that raw component implementation colors are forbidden; editor preset data is a narrow exception only if documented.

## Axiom matrix

| Axiom | Status | Evidence |
|---|---|---|
| Ground-truth audit | ⚠️ | Correct command was re-run; live count is 18, not documented 2. All 18 are classifiable, but the baseline document is stale. |
| Structural remediation | ✅ | Media overlay has no raw matches; app `lib` directories have zero matches. |
| Contract compliance | ⚠️ | Theme Editor's 15 literals are data presets but are not recorded in Task 1804's durable baseline or Task 1806's raw-color inventory. |
| Analyzer/tests | ✅ | Package analyzer `--no-fatal-infos --no-fatal-warnings` exit 0, 218 infos/0 errors; scoped suite 189/189 passed; boundary 7/7. |
| Visual evidence | ⚠️ | No candidate screenshots or target reference PNG are present. This task is an audit baseline, so screenshots are not a hard requirement, but visual proof remains infrastructure-only. |

## Findings

### F1 — Persistent stale audit baseline (EVIDENCE_GAP; moderate)

`docs/reports/builders/1804-warp-prism-hardcoded-visual-value-audit-report.md:67-74` claims the exact live non-token baseline is 2. Current live filesystem returns 18 matches. The 15 Theme Editor preset literals and 2 parser literals are legitimate categories, but the report does not enumerate them. A future reviewer cannot distinguish intentional editor preset data from an accidental new structural literal using the published baseline.

**Path to 100:** update Task 1804 report with all 18 live findings, explicit parser/editor categories, and a revised expected baseline or a command that excludes documented editor/parser paths by role.

### F2 — Cross-task audit report drift (EVIDENCE_GAP; low)

Task 1806 independent report lines 53-79 records a raw-color inventory that omits the live Theme Editor preset and parser findings. This does not prove a structural violation, but it is stale visual audit ground truth and should be reconciled before EPIC-18 visual closeout.

**Path to 100:** update the cross-task inventory and link the revised 1804 baseline.

## Validation evidence

- `flutter analyze --no-fatal-infos --no-fatal-warnings` — PASS, 218 infos, 0 errors.
- `flutter test test/tokens/ test/organisms/theme_editor/ test/organisms/media_detail_overlay/ test/gallery/ test/boundaries/ --concurrency=1 --no-pub` — PASS, 189/189.
- Boundary harness — PASS, 7/7.
- Frozen golden suite — FAIL, 59 expected failures; no baseline refresh run.
- Non-mutating format check — red: formatter reports 9 changed files in the reviewed token/editor/parser/test surfaces. No files were modified by this review.

## Score rationale

92/100: structural remediation and tests are strong, but the primary audit deliverable's exact-baseline claim is false on the current filesystem. The finding is an evidence/lineage defect rather than an unapproved structural color. No lane move because score is >=90.

## Human/infrastructure distinction

This score accepts the **mechanical audit infrastructure only**. It does not approve the visual contract, screenshots, or goldens. Human visual approval remains owned by Task 1805 and is not present.

## Path to 100

1. Reconcile Task 1804's report with the live 18-match classified inventory.
2. Reconcile Task 1806's raw-color appendix with the same inventory.
3. Re-run the non-mutating format gate after builder formatting; no golden regeneration.
4. Re-run audit, analyzer, scoped tests, and boundary harness.