# Review Report: Task 1840 — Catalog StatusTicker Overflow + ListTile Ink Warnings — 2026-09-29

## Review Entry 1 — Initial Independent Review

### Review Lineage

- **Current task**: Task 1840, live path `.project/tasks/02-doing/1840-warp-prism-catalog-statusticker-overflow-listtile-warnings.md`.
- **Previous Task 1840 reviewer reports**: none found.
- **Builder evidence**: the specified `.project/reports/builders/1840-catalog-statusticker-overflow-listtile-warnings-builder-report.md` could not be read and no matching Task 1840 builder report was found under `.project/reports/builders/`. The task's Completion Evidence and the requested changelog were available; builder-only A/B assertions below remain unverified.
- **Review mode**: initial independent review. No prior Task 1840 review was used.
- **Lane context**: the task file is physically in `02-doing/`. The generated `.project/tasks/tasklist.md` currently lists it as `01-open`; the filesystem lane is canonical. No lane move or task-file edit was made.

### Score And Verdict

- **Verdict**: **BLOCKED** — not PASS, because the required real Catalog host proof is unavailable; not FAIL, because the source diff itself does not demonstrate that either fix is defective.
- **Diagnostic score**: **45/100** (Serious band). Deductions: F1 −23, F2 −20, F3 −5, F4 −5, F5 −2. Score is diagnostic; the missing host evidence governs the verdict.
- **Confidence**: high in the two current source edits, current command outcomes, and the test-helper suppression behavior; medium overall because the designated builder report is missing, the A/B claims were not independently reproduced, and no display/GPU host was available.
- **Lane recommendation**: no move. This remains a `02-doing` task; as a builder-context review, it cannot be promoted by this reviewer below 100.

### Delta Summary

- **Resolved / persistent / regression**: not applicable; no earlier independent Task 1840 review report was found.
- **New findings**: F1–F5 below. The out-of-writeset `DSHealthCard` sibling is recorded separately as a follow-up signal, not as a Task 1840 implementation defect.

## Scope And Attribution

- The live diff for `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` contains exactly two Task-1840-shaped hunks: the `_StatusTickerDemo` height removal and the local transparent `Material` wrapper around the layer-registry `ListView`. The old executable `SizedBox(height: 120, width: 640, child: _StatusTickerDemo())` is absent; the replacement is at line 3064 and the Material is at lines 6212–6214.
- The current worktree is broadly dirty from other work. Two other visible modified Catalog files contain theme/recipe-name changes unrelated to this Task's stated gallery writeset; they are not attributed to Task 1840. Within the inspected Task 1840 paths, the only product-source diff is the gallery file. The expected task and changelog files are present as untracked artifacts; the expected builder report is absent.
- No product source, task, changelog, AGENTS, or golden baseline was edited by this reviewer. Read-only `git diff`/`git status` checks were used only to inspect state.
- **Affected consumer**: Catalog gallery (`apps/catalog`, affected gallery sections). `flutter run -d linux` was not run: this environment has no display/GPU host. Per the current instruction this is an unresolved **AMBIGUITY**, not a FAIL, and it is not accepted as host proof.
- **Gortex**: configured/tracked child scope was `warp-prism`; smart-context and symbol lookup succeeded, but three literal-search requests timed out. Gortex was stopped after those timeouts; native file reads and grep were used thereafter.
- **Onboarding path caveat**: local `AGENTS.md` references `.agents/workflows/onboard.md`, which is absent from the workflow index; the active Warp Prism onboarding and global onboarding workflows were used. `.project/tasks/AGENTS.md` appeared in the directory listing but direct read failed, so its contents remain unavailable.

## Per-Claim Epistemic Status

| Claim | Status | Evidence and limit |
|---|---|---|
| 1. The two intended source edits exist and the old fixed-height expression is gone | **PASS** | The current gallery source and read-only diff show only the height-free 640px-width call at `design_system_gallery_sections.dart:3064` and the transparent `Material` around the ListView at `:6212–6214`. The removed old expression appears as a deletion in the diff and has no live source match. No other text region in that file is changed beyond the two explanatory comments adjacent to these edits. |
| 2. The Task 1840 writeset is limited to its intended surfaces | **PARTIAL** | The Task-specific gallery source diff is exactly the two requested hunks; there is no diff for `ds_status_ticker.dart`, `ds_health_card.dart`, gallery test code, or baseline goldens. The Task file and changelog exist. Because the repository is broadly dirty and the designated builder report is missing, I cannot independently attribute every unrelated dirty path in the whole worktree to its originating task. |
| 3. Validation commands | **MIXED** | `dart analyze`, `flutter analyze`, and the boundary harness pass. The package-wide format check and both full test suites exit nonzero; details and exact strings are below. No A/B revert was performed and the builder's A/B-identical provenance is not accepted as independently verified. |
| 4. Original 16px overflow arithmetic and layer ownership | **PARTIAL** | The deleted source line proves the former outer hard height was 120px. Current tokens are `DSSpacing.xs=4`, `sm=8`, and `DSTypography.labelSmall` uses 10px × 1.4 = 14px. Two labels (28) + gaps (4+8+4=16) + two 36px tickers with 1px top/bottom glass-border inset each (2×38=76) gives **120px inner Column content**. The former 120px outer box left 104px after its 8px top/bottom padding: 120−16=104; 120−104=16px. The fix removes that cap. The whole padded widget's natural height is 136px, so references to a “120px natural demo height” should be read as the inner content height, not the outer widget height. Static evidence supports demo-sizing ownership; `DSStatusTicker` source was not modified and remains self-bounded by its `height` contract. No fresh pre-fix runtime reproduction was attempted. |
| 5. Other gallery sections and the reported sibling | **PASS for the static pattern check; separate sibling follow-up confirmed** | In `design_system_gallery_sections.dart`, the other direct `ColoredBox → Padding → Column` demos at lines 5208, 5320, 5378, 5584, 5791, 5850, 5988, and 6314 use `Expanded` for their main content. Other ColoredBox sections at 5051, 5910, 6084, 6105, and 6182 use different bounded/composite structures. The only direct fixed-child no-Expanded/no-scroll pattern found is `_StatusTickerDemo`. The separate `ds_health_card.dart:82` overflow is outside the Task's writeset and was not edited. |
| 6. Golden freeze | **PASS for no baseline refresh** | The scoped Git diff/status contains no baseline golden files, and no `--update-goldens` command was run. Note: current `AGENTS.md` §7.0 is the canonical theme-brand-name rule, not the golden-freeze rule. The active interim golden-freeze policy is `docs/design/black-obsidian-visual-contract.md` §7; Task 1805 records human approval as `PENDING-USER`. |
| 7. Changelog | **PARTIAL** | `.project/changelog/20260929-153400-1840-catalog-statusticker-overflow-listtile-warnings-gt-builders-engineer-flutter.md` exists. Its descriptions of the two source edits and unchanged `DSStatusTicker` match the live diff. Its historical reproduction/A/B claims cannot be fully independently authenticated because the builder report is missing and the archived harness does not prove the StatusTicker error count. |

## Findings

| ID | Class | Severity | Status | Finding | Minimal path to 100 |
|---|---|---|---|---|---|
| F1 | `NEW` | **Serious** | Open / `BLOCKED` | Required Catalog host proof (`flutter run -d linux` at the default viewport with a clean console) was not run. The environment is headless; this is unavailable evidence, not a demonstrated implementation failure. The archived widget harness is not real-host proof. | Operator runs the real Catalog host on a display/GPU host at the default viewport and records viewport plus console result. Do not claim acceptance before this evidence exists. |
| F2 | `NEW` | **Serious** | Open | `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart:543–556` replaces `FlutterError.onError` and returns without forwarding any message containing `overflow`, `RenderFlex`, `ListTile background color`, or `ink splashes may be invisible`. It is called from multiple gallery tests (`:31,69,102,155,192,305,410,435,450,508`), so those tests can pass while these exact failures occur. The archived StatusTicker diagnostic also fails to print/assert the captured `chrome` error count. This is a pre-existing test-oracle gap, not a code edit for Task 1840. | Route a separate authorized task to narrow/remove the global suppression and add a regression-sensitive unsuppressed assertion. Keep it out of the Task 1840 diff. |
| F3 | `NEW` | **Debt** | Open | The user-designated builder report does not exist at the requested path and no alternate Task 1840 builder report was found. Therefore the reported A/B-identical assertions are not independently reviewable; this review did not accept them. | Restore/provide the additive builder report or otherwise preserve the exact before/after command evidence. Do not claim historical “pre-existing” status from the missing packet. |
| F4 | `NEW` | **Debt** | Open | `flutter test --no-pub` in Catalog currently exits 1 on four trace-write `PathNotFoundException`s under `apps/catalog/docs/reports/host-exercise/traces/`. The Task diff does not change those test/persistence paths, but the claimed A/B pre-existence is not independently established, so classify causality as `UNKNOWN`, not “proven pre-existing.” | Record/fix the trace destination in a separate authorized task or provide independently captured before/after evidence. This is not attributed to the gallery edits. |
| F5 | `NEW` | **Debt** | Open | The package-wide formatter check exits 1 because 56 of 312 files are reported as needing formatting; the Task's edited `design_system_gallery_sections.dart` is not among them and its targeted format check exits 0. | Keep package-wide formatting debt separate; do not broaden Task 1840's source writeset. |
| F6 | `NEW` | **Improvement** | Open | The Task/changelog's “natural 120px” phrasing is ambiguous for the whole widget: 120px is the inner Column content; the surrounding 8px top/bottom Padding makes the self-sized outer widget 136px. The 16px overflow arithmetic itself (120−104) is sound. | Clarify future evidence/comments to distinguish inner content height from the outer padded demo height. |

### Out-of-writeset sibling signal (not scored as a Task 1840 defect)

The archived diagnostic `zz_scratch_1840_sibling_test.dart`, run independently at 1280×800, printed `A RenderFlex overflowed by 7.3 pixels on the bottom` at `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart:82:14`, with `BoxConstraints(w=204.0, h=124.7)`. Its process exits 0 because it only captures/prints and makes no failing assertion; the captured error is real evidence, not a passing test. The file is outside Task 1840's writeset, was not edited, and should be routed separately.

## Evidence And Exact Commands

| Command (working directory) | Exit | Observed result |
|---|---:|---|
| `git diff -- packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (repo root) | 0 | Exactly two Task-shaped hunks: old hard box removed; width-only StatusTicker box and transparent Material wrapper added. |
| `dart format --output=none --set-exit-if-changed lib/ test/` (`packages/warp_prism_ui`) | 1 | 312 files checked; 56 reported as needing formatting. The edited gallery file is not on the list. `--output=none` wrote nothing. |
| `dart format --output=none --set-exit-if-changed lib/src/gallery/design_system_gallery_sections.dart` (`packages/warp_prism_ui`) | 0 | One file, zero changes. |
| `dart analyze` (`packages/warp_prism_ui`) | 0 | 212 issues, all `info`; no warnings/errors. |
| `flutter test --no-pub` (`packages/warp_prism_ui`) | 1 | `+1703 -63`; observed failure output includes frozen golden pixel mismatches (e.g. `status_dot_stale.png`: 99.99%, 479956px; `status_dot_excluded.png`: 99.99%, 479960px; all-states grid: 97.33%, 467164px). I do **not** accept the builder's A/B-provenance assertion; no A/B revert was performed. |
| `flutter analyze` (`apps/catalog`) | 0 | `No issues found!`; Flutter resolved/downloaded dependency packages during this requested validation. No tracked manifest/lockfile changes were observed afterward. |
| `flutter test --no-pub` (`apps/catalog`) | 1 | `+19 -4`. Exact failures: `1838: catalog SMOKE @ desktop-1280x800`, `1838: catalog CRAWL @ desktop-1280x800`, `1838: catalog SMOKE @ laptop-1366x768`, and `Catalog Host Exercise — FUZZ fuzz: seeded walk is reproducible via replay`; each fails writing a JSON trace under `apps/catalog/docs/reports/host-exercise/traces/` (`PathNotFoundException`, `apps/catalog/docs/` does not exist). A/B provenance is `UNKNOWN`. |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (repo root) | 0 | 15/15 PASS, 0 violations. |
| `flutter test --no-pub ../../.archive/packages/warp_prism_ui/test/gallery/zz_scratch_1840_repro_test.dart` (`packages/warp_prism_ui`) | 0 | Captions=1 each, tickers=2, ticker size=622×36; relation labels=1 each and 3 switch tiles. It prints `TOTAL_ERRORS=0` only **after** clearing the captured list for the relations section; it does not report/assert the StatusTicker section's captured errors, so it does not prove zero overflow. |
| `flutter test --no-pub ../../.archive/packages/warp_prism_ui/test/gallery/zz_scratch_1840_sibling_test.dart` (`packages/warp_prism_ui`) | 0 | Prints the 7.3px `DSHealthCard` overflow above and `errors=1`; exit 0 is not a pass because the harness has no assertion. |
| `flutter run -d linux` (`apps/catalog`) | **NOT RUN** | Headless environment has no display/GPU host. Per the current operator direction this remains `AMBIGUITY`, not FAIL and not accepted as PASS. |

Additional read-only checks: the exact old `SizedBox(height: 120, width: 640, child: _StatusTickerDemo())` has no live match; `git diff --name-only -- packages/warp_prism_ui/test/goldens` and scoped golden `git status` output were empty. No `--update-goldens` was run. The dirty worktree also contains unrelated Catalog theme-name edits and other workspace changes; those were not attributed to Task 1840. The supplied builder report was absent.

## Path To 100

1. Obtain the operator-side Catalog host run at the default viewport; retain the no-`RenderFlex` / no-ListTile-warning console evidence.
2. Route a separate test-oracle task for `_suppressGalleryDemoNoise()` and a durable unsuppressed regression test; do not expand Task 1840's writeset.
3. Resolve or separately evidence the Catalog trace-path failures and the exact before/after claims; do not call them pre-existing without proof.
4. Keep the 7.3px `DSHealthCard` sibling as separate out-of-scope work; do not edit it here.
5. Correct the “120px natural demo” wording if it means the full padded widget; the actual full height is 136px while the inner content is 120px.

## Task Ledger Patch Suggestion (not applied)

```markdown
### Latest Review — 2026-09-29

- **Reviewer profile**: `reviewers`
- **Score**: `45/100`
- **Verdict**: `BLOCKED`
- **Full report**: `.project/reports/reviewers/1840-catalog-statusticker-overflow-listtile-warnings-review-loop.md`
- **Lane outcome**: no move; task remains in `02-doing`
- **Open blockers**: `NEW`/Serious F1 real Catalog host proof unavailable; `NEW`/Serious F2 test helper suppresses the targeted errors.
- **Evidence gaps/debt**: `NEW`/Debt F3 builder report/A-B provenance missing; `NEW`/Debt F4 Catalog trace-write failures have unknown pre-task causality; `NEW`/Debt F5 package-wide formatter check reports 56 out-of-scope files.
- **Previous reports**: none found for Task 1840.
```
