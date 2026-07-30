# Review Report: Task 1040 — Glass Performance Budget Pass — 2026-07-09

## Review Lineage

- **Current task**: Task 1040 (`1040-warp-prism-glass-performance-budget-pass`), reviewed from `docs/tasks/02-doing/1040-warp-prism-glass-performance-budget-pass.md`.
- **Role**: `gt-code-quality-reviewer`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1040-review.md` — historical 100/100 (stale vs live package).
  - `docs/reports/review-wave-2026-06-19/task-1040-epic-10-glass-budget-rereview.md` — 62/100 `REJECTED_TO_DOING` (F1–F5).
- **Related documents**: `docs/reports/epic-10-glass-performance-budget.md`, Task 1000 lane (`03-review`), completion evidence in Task 1040.
- **Review mode**: independent re-review after 2026-07-09 Prism* API unblock pass.

## Score And Verdict

- **Score**: `66/100` — Debt
- **Verdict**: `NEEDS FIX` / `REJECTED_TO_DOING`
- **Lane**: `02-doing` (do **not** promote to `03-review`; S≠100)

## Delta Summary

### Resolved Since 2026-06-19

- `RESOLVED`: `packages/warp_prism_ui/test/glass_budget_test.dart` consumes public `Prism*` names via `package:warp_prism_ui/warp_prism_ui.dart` (no hidden `DS*` consumer import). Fresh run: **+13 All tests passed**.
- `RESOLVED` (partial): Task `Where` table points at live Melos package paths under `packages/warp_prism_ui/`.
- `SUPERSEDED` (partial F4): Declared prerequisite Task 1000 is no longer stuck in `02-doing`; it is in `03-review` with refreshed evidence. Dependency is still not formally approved/completed.

### Persistent Findings

- `PERSISTENT` **F1**: Budget report core inventory remains false — claims only `DSStoryPanel` uses BackdropFilter while live package has additional blur hosts.
- `PERSISTENT` **F2**: Regression still ends in a placeholder `expect(true, isTrue)` and does not cover `DSToast` / `DSCommandPalette`.
- `PERSISTENT` **F3**: Budget report + completion evidence still assert “40 design-system files” / “Total BackdropFilter instances in hosts: 1” and still reference obsolete `test/design_system/glass_budget_test.dart` / root-`lib/` method language.

### New / Confirmed Performance Note

- `NEW` (quality): `DSToast` uses full `DSGlassPanel` (elevated blur) while toast stacks allow multiple simultaneous instances (`DSToastManager.maxVisible` default 5). That is a multi-instance blur host class the budget never classifies — worse than a single-instance modal omission.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Exit checkboxes for package/root `flutter analyze` and full `flutter test` remain unchecked; focused analyze on glass-related files reports info-level issues only (not used as a hard fail for this score).
- `EXTERNAL_BLOCKER`: None for focused package proof. Flutter toolchain available.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Critical | Open | Budget inventory claim “only DSStoryPanel uses BackdropFilter / Total hosts: 1” is false. | `docs/reports/epic-10-glass-performance-budget.md:11`, `:40-56`; live: `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:65-66` (`DSGlassPanel` elevated); `.../command_palette/ds_command_palette.dart:322-323` (`BackdropFilter` sigma 20). Package grep under `lib/` shows those hosts plus the atom implementation. |
| F2 | PERSISTENT | High | Open | Regression does not enforce the documented allowed-host set. | `packages/warp_prism_ui/test/glass_budget_test.dart:169-185` placeholder; no toast/palette coverage; comment still claims “blur is only used on narrative surfaces (PrismStoryPanel)”. |
| F3 | PERSISTENT | High | Open | Task completion evidence and budget enforcement section still over-claim and use stale paths/scope. | Task Completion Evidence “AUDITED: All 40 design system files… only DSStoryPanel”; budget §4 path `test/design_system/glass_budget_test.dart`; method line says search in `lib/`. |
| F4 | PERSISTENT | Medium | Open (softened) | Depends on Task 1000 which is not completed/approved. | Task header `Depends on: Task 1000`; Task 1000 live in `docs/tasks/03-review/1000-...md`. |
| F5 | RESOLVED / LOW residual | Low | Softened | Focused analyzer is executable; residual infos are mostly prefer_const / deprecated `withOpacity` outside the Prism* test change. | Focused analyze on glass panel, story panel, toast, command palette, glass_budget_test → 21 info issues; zero errors. |

## Evidence Reviewed

- Task contract, exit conditions, completion evidence, anti-hallucination guardrails.
- Budget policy doc end-to-end.
- Live blur/glass host audit: `BackdropFilter`, `ImageFilter.blur`, `DSGlassPanel(` under `packages/warp_prism_ui/lib`.
- Public API aliases: `PrismGlassPanel` / `PrismGlassPanelSimple` in `prism_aliases.dart`.
- Regression file full read + fresh `flutter test`.
- High-frequency simple path hosts covered by tests still correct (`PrismStoryCardQuick`, `PrismMetricTile`, `PrismAssetCard`, `PrismTaskCard`).

## Commands And Results

```text
# from packages/warp_prism_ui
HOME=... PUB_CACHE=... TMPDIR=... flutter test --no-pub test/glass_budget_test.dart
→ All tests passed! (+13)

HOME=... PUB_CACHE=... TMPDIR=... flutter analyze --no-pub \
  lib/src/atoms/ds_glass_panel.dart \
  lib/src/organisms/ds_story_panel.dart \
  lib/src/molecules/ds_toast.dart \
  lib/src/organisms/command_palette/ds_command_palette.dart \
  test/glass_budget_test.dart
→ 21 info issues, 0 errors
```

## Path To 100

1. **Re-audit live package** `packages/warp_prism_ui/lib` for every `BackdropFilter` / `DSGlassPanel` host (not “40 root files”).
2. **Rewrite** `docs/reports/epic-10-glass-performance-budget.md` inventory:
   - Keep/justify `DSStoryPanel` / `PrismStoryPanel` elevated (sigma 15).
   - Classify `DSCommandPalette` as allowed single-instance modal blur (sigma 20) **or** route it through `DSGlassPanel.modal` and document.
   - Classify `DSToast`: either **justify** capped multi-toast elevated blur, **or** swap to `DSGlassPanelSimple` (preferred for multi-instance) and retest.
3. **Replace** placeholder test with deterministic enforcement:
   - Widget tests that allowed blur hosts render expected BackdropFilter counts.
   - High-frequency / multi-instance surfaces (toast if kept simple; cards already covered) assert `findsNothing` for `BackdropFilter`.
   - Prefer failing when a new host is added without inventory update (static allow-list test or package grep assertion is acceptable).
4. **Refresh** task completion evidence: remove false “only one host / 40 files” claims; record exact package paths and fresh command output.
5. **Dependency**: note Task 1000 waiver (this task’s package audit supersedes stale baseline) **or** wait for 1000 approval before final closeout.
6. Re-run focused `flutter test test/glass_budget_test.dart` (expect ≥ current +13, expand count as coverage grows) and focused analyze; leave residual infos only if out of scope or fixed cheaply.

## Lane Recommendation

Keep Task 1040 in **`docs/tasks/02-doing/`**. Do not move to `03-review` until path-to-100 items 1–3 are closed and score reaches 100 under independent re-review.
