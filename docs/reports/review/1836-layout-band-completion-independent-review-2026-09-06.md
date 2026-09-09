# Review Report: Task 1836 — Layout-Band Completion — 2026-09-06

## Review Lineage

- **Current task**: Task 1836 (`1836-warp-prism-layout-band-completion`); live path `docs/tasks/01-open/1836-warp-prism-layout-band-completion.md`
- **Review mode**: `initial independent review` of Task 1836 completion claims; score-only, no lane move
- **Previous reports read**:
  - `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md` — `73/100`, `PASS` for the original exit-condition scope, with follow-up findings F1–F8
  - `docs/reports/builders/20260906-task-1836-self-review.md` — builder self-review, `100/100 ACCEPT`; not independent acceptance evidence
- **Related reports considered**:
  - `docs/tasks/04-completed/1832-warp-prism-responsive-layout-contract-overflow.md` — prior task Review Ledger and follow-up ownership
  - `docs/tasks/03-review/1805-warp-prism-screenshot-visual-acceptance-gate.md` — golden-freeze ledger and real-host revalidation context
  - `docs/reports/review/1831-host-composition-material-contract-independent-review-2026-09-04.md` — affected-host composition context
  - `docs/reports/review/1834-capture-proof-honesty-independent-review-2026-09-04.md` — capture proof and shared-bundle caveats
- **Independence**: The reviewer did not author the Task 1836 implementation or its self-review. The current task remains in `01-open/`; no lifecycle transition was performed.

## Score And Verdict

- **Score**: `90/100` — Elite
- **Verdict**: `PASS`
- **Evidence confidence**: `high` for the implemented F1/F2/F4/F6 claims and required gates; `medium-high` for the accepted latent F3/F7/F8 dispositions
- **Lane recommendation**: `no-move`

The mandatory Task 1836 outcome is established: F1, F2, and F4 are remediated; F6 uses a non-re-entrant collection pattern in all three regression suites; F3, F7, and F8 have explicit residual dispositions; the required package/host validations passed; and no golden baseline was refreshed. The remaining deductions are non-blocking quality debt and evidence-quality limitations, not unrecorded acceptance blockers.

The builder's `100/100` self-score is not accepted as independent proof. The score above is the independent diagnostic score for the live tree.

## Delta Summary

### Resolved Since Task 1832 Lineage

- `RESOLVED`: F1 titled scrubber overflow band. Current regression coverage at exact heights `70`, `80`, `90`, `95`, and `100` passed; the component now computes `minRequiredHeight` and enters the scroll fallback below that requirement (`ds_time_machine_scrubber.dart:447-480`).
- `RESOLVED`: F2 empty-state-with-title overflow band and thin h=119 margin. Current tests at `110`, `118`, and `119` passed; h=119 includes an explicit `slack >= 4.0` assertion (`time_machine_scrubber_layout_contract_test.dart:312-328`).
- `RESOLVED`: F4 textScale 2.0 overflow at the h=119 Catalog constraint. Current regressions at text scales `1.3`, `1.6`, and `2.0` passed; threshold and chrome calculations use `MediaQuery.textScalerOf(context)` (`ds_time_machine_scrubber.dart:433-470`).
- `RESOLVED`: F6 re-entrant overflow trap. All three regression files now collect matching Flutter errors and assert in `addTearDown` after restoring the original handler (`time_machine_scrubber_layout_contract_test.dart:23-41`, `layout_contract_overflow_regression_test.dart:30-49`, `ds_data_table_layout_contract_test.dart:32-51`).
- `RESOLVED`: F5 expected golden drift is recorded in the Task 1836 Completion Evidence and is also present in the Task 1805 freeze ledger. The frozen baseline was not refreshed.

### Persistent Findings / Residual Debt

- `PERSISTENT`: F3 remains an accepted latent public-API risk. A table with a toolbar still overflows at h=`40`, `50`, and `80` in the reviewer danger-zone probe. The builder's claim of “0 usages” is true only for `apps/`; the package gallery itself passes `DSDataTable.toolbar` at `design_system_gallery_sections.dart:2377-2433`, and the integration test passes a toolbar at `ds_data_table_test.dart:759-793`. Those callers use roomy constraints, so no current extreme-height host caller was found, but the public component still has no bounded-height toolbar fallback.
- `PERSISTENT`: F7 remains an accepted extreme-constraint behavior. At h<34, the table deliberately omits `_buildBody` (`ds_data_table.dart:1237-1239`) and wraps the remaining header/content in a `SingleChildScrollView` (`:1260-1265`). The body is therefore not reachable through the rendered tree at that height. This is documented as a density trade-off, not incorrectly reported as fixed.
- `PERSISTENT`: F8 remains an accepted accessibility trade-off. Select-all checkbox target dimensions are `32px` in compact mode and `28px` in ultra-compact mode, with `shrinkWrap` tap-target sizing (`ds_data_table.dart:508-546`). The table's public `selectable` default is false (`:1008-1066`), and no application caller enables it in the compact host paths inspected, but the public selectable compact path remains below the 48dp target requirement.
- `EVIDENCE_GAP`: The accepted F3/F7/F8 dispositions are source-backed and explicit, but the new regression suites do not directly assert all of the stated rationale. In particular, the h=25 F7 regression asserts no overflow and no crash (`ds_data_table_layout_contract_test.dart:220-243`) rather than asserting header visibility and intentional body omission. This does not invalidate the disposition because the current source makes the behavior explicit, but it prevents a 100 score.
- `PERSISTENT`: The package analyzer command succeeds under the repository's non-fatal-info gate, but a package-wide run reports exactly `212` info-level diagnostics, primarily pre-existing `prefer_const_*` findings. The strict Analyzer Integrity axiom therefore remains `PARTIAL`, even though the five touched source/test files analyzed with `No issues found!` under the same non-fatal flags.

### Regressions

- `REGRESSION`: None found in the reviewed F1/F2/F4/F6 scope. The current danger-zone probe reports no scrubber failures across titled h=`70`, `80`, `90`, `100`, `105`, `109`, `110`, `115`, `118`, or empty titled h=`100`, `110`, `115`, `118`, `119`, `121`.

### New Findings

- `NEW`: None. The residual F3/F7/F8 items are carried forward from the Task 1832 review rather than introduced by the Task 1836 fix.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Improvement | Closed | Dynamic chrome-aware thresholding sends titled scrubbers below the computed minimum into a scroll fallback; exact required heights pass. | Task 1832 review; resolved 2026-09-06 | `ds_time_machine_scrubber.dart:447-509`; `time_machine_scrubber_layout_contract_test.dart:254-280` |
| F2 | RESOLVED | Improvement | Closed | Empty titled scrubber passes h=`110`, `118`, and `119`; h=`119` asserts at least 4px rendered slack. | Task 1832 review; resolved 2026-09-06 | `ds_time_machine_scrubber.dart:456-475`, `:528-575`; `time_machine_scrubber_layout_contract_test.dart:286-328` |
| F3 | PERSISTENT | Debt | Accepted latent | Toolbar remains a non-flexible child and overflows at h=`40/50/80`; no current application caller uses an extreme constraint, but package gallery/test callers prove the API is active. | Task 1832 review | `ds_data_table.dart:1162-1171`, `:1254-1267`; reviewer probe output: `41px`, `31px`, `9px`; package caller `design_system_gallery_sections.dart:2377-2433` |
| F4 | RESOLVED | Improvement | Closed | TextScaler-aware threshold and chrome arithmetic eliminate the prior 33px h=119 overflow at textScale 2.0. | Task 1832 review; resolved 2026-09-06 | `ds_time_machine_scrubber.dart:433-470`; `time_machine_scrubber_layout_contract_test.dart:334-368` |
| F5 | RESOLVED | Improvement | Recorded | `data_table_default` still fails with the expected frozen-baseline drift (`99.62%`, `478180px`), and the drift is recorded without refreshing the baseline. | Task 1832 review; resolved/recorded 2026-09-06 | `docs/tasks/01-open/1836-warp-prism-layout-band-completion.md:116-118`; `docs/tasks/03-review/1805-warp-prism-screenshot-visual-acceptance-gate.md:442-453` |
| F6 | RESOLVED | Improvement | Closed | All three overflow traps use collect-then-expect and restore the original handler before asserting, avoiding `fail()` recursion. | Task 1832 review; resolved 2026-09-06 | `time_machine_scrubber_layout_contract_test.dart:23-41`; `layout_contract_overflow_regression_test.dart:30-49`; `ds_data_table_layout_contract_test.dart:32-51` |
| F7 | PERSISTENT | Debt | Accepted extreme constraint | h<34 renders the header-only fallback and omits the body; the behavior is explicit and documented but silently hides data in an extreme public constraint. | Task 1832 review | `ds_data_table.dart:1224-1265`; `ds_data_table_layout_contract_test.dart:220-243`; reviewer behavior probe: `ListView present=false`, `row visible=false`, `ScrollView count=1` |
| F8 | PERSISTENT | Debt | Accepted latent | Compact selectable table header uses 32px/28px checkbox dimensions and `shrinkWrap`, below 48dp. No compact selectable application consumer was found. | Task 1832 review | `ds_data_table.dart:508-546`; table selectable default `:1008-1066`; package selectable gallery caller `design_system_gallery_sections.dart:2340-2361` is not compact |
| F9 | EVIDENCE_GAP | Improvement | Open | Package-wide analyzer has exactly 212 info-level diagnostics under the non-fatal gate; strict zero-info Analyzer Integrity is not established. | Current review | `packages/warp_prism_ui/analysis_options.yaml:1-7`; current `flutter analyze lib test/organisms --no-fatal-infos --no-fatal-warnings` output |

## Axiom Compliance

| Axiom | Status | Evidence and exact accounting |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | Scoped touched-file analyzer: `No issues found!`; package `lib test/organisms` analyzer exits 0 with exactly `212` info-level diagnostics. The repository intentionally uses `--no-fatal-infos --no-fatal-warnings`, so zero-info compliance is not proven. No suppression was added in `packages/warp_prism_ui/analysis_options.yaml:1-7`. |
| Lifecycle Safety | PASS | In the changed organism source, exactly one timer field is declared (`_playbackTimer`, `ds_time_machine_scrubber.dart:286`), exactly one periodic timer creation site exists (`:367`), and exactly one `dispose()` cancellation exists (`:336-338`), with additional cancellation paths at `:360`, `:366`, and `:384-386`. `DSDataTable` has no `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, `Timer`, or explicit listener creation. Gesture callbacks and the post-frame callback are guarded by the widget lifecycle where needed (`:314-316`, `:367-370`). |
| Dependency Direction | PASS | `DSTimeMachineScrubber` imports Flutter plus local atoms/tokens; `DSDataTable` imports local tokens/atoms/molecules/virtual-scroll. Neither imports data, application, presentation-host, FRB, networking, or persistence layers. |
| UI Accessibility | PARTIAL | Scrubber transport has explicit semantic labels and default buttons retain 48px targets (`ds_time_machine_scrubber.dart:825-853`). Table sort, pagination, row actions, secret reveal, and table region carry semantic labels. F8 remains a public compact selectable path with 32px/28px checkbox targets, below 48dp. |
| Proof Reality | PARTIAL | Exact current evidence: scrubber regression `18/18`, table regression `7/7`, combined regression `2/2`, full organisms `707/707`, Catalog widgets `10/10`, CyberCore widgets `9/9`, Catalog capture `5/5`, CyberCore capture `2/2`, and both Linux debug builds exit 0. The data-table golden intentionally fails (`99.62%`, `478180px`) under the active freeze and is recorded rather than refreshed. The F3/F7/F8 rationale has no complete direct behavioral oracle for every stated disposition. |
| Release Security | PASS (not release-scoped) | No secret, credential, endpoint, release-signing, or platform hardening change is in the Task 1836 writeset. No `print`/`debugPrint` exists in either changed organism source. Release obfuscation and split-debug-info were not claimed by this layout task and were not assessed as a release gate. |

## Runtime / Consumer Wiring

`affected_consumers` is explicitly recorded in the task:

- `apps/catalog`: the Catalog host renders the package gallery, including the scrubber gallery section; Catalog widget tests cover all gallery sections and high text scale without overflow.
- `apps/cybercore`: Providers, MCP Servers, and MCP Inspector compose `PrismDataTable` inside bounded `Expanded → LayoutBuilder → SizedBox` host chains (`providers_page.dart:124-135`, `mcp_servers_page.dart:105-116`, and the corresponding inspector page). Their table callers do not pass `toolbar` or `selectable` in the compact paths inspected.

Fresh consumer evidence:

- Catalog widget suite: `10/10`, exit 0.
- CyberCore widget suite: `9/9`, exit 0.
- Catalog Linux debug build: exit 0, bundle created.
- CyberCore Linux debug build: exit 0, bundle created.
- Catalog visual capture suite: `5/5`, exit 0; local RepaintBoundary PNG artifacts verified at `1280x800`. The runner also emits the expected `MissingPluginException` for the best-effort driver hook, while local raster artifacts are independently checked.
- CyberCore visual capture suite: `2/2`, exit 0; same expected driver-hook exception and verified local artifact path.

These host results establish composition/build compatibility for the affected consumers. They do not turn the latent extreme toolbar/checkbox paths into tested host behavior.

## Evidence Reviewed

### Source and task files

- `AGENTS.md`, `MISSION.md`, `docs/tasks/AGENTS.md`
- `.agents/workflows/gt-global-subagent-review.md`
- `.agents/rules/30-evidence-and-partiality.md`
- `.agents/rules/40-lane-authority-and-lifecycle.md`
- `.agents/rules/41-task-artifact-contract.md`
- `.agents/rules/42-task-completion-and-promotion.md`
- `docs/tasks/01-open/1836-warp-prism-layout-band-completion.md`
- `docs/reports/builders/20260906-task-1836-self-review.md`
- `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md`
- `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart`
- `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart`
- all three Task 1836/1832 layout regression suites
- Catalog and CyberCore widget/capture test files and affected host source files
- Task 1805 golden-freeze ledger

### Deterministic commands run during this independent review

| Command | Result |
| --- | --- |
| `flutter test test/organisms/time_machine_scrubber/time_machine_scrubber_layout_contract_test.dart --no-pub` | `18/18 passed`, exit 0 |
| `flutter test test/organisms/data_table/ds_data_table_layout_contract_test.dart --no-pub` | `7/7 passed`, exit 0 |
| `flutter test test/organisms/layout_contract_overflow_regression_test.dart --no-pub` | `2/2 passed`, exit 0 |
| `flutter test test/organisms/ --no-pub` | `707/707 passed`, exit 0 |
| `flutter analyze lib/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart lib/src/organisms/data_table/ds_data_table.dart test/organisms/time_machine_scrubber/time_machine_scrubber_layout_contract_test.dart test/organisms/layout_contract_overflow_regression_test.dart test/organisms/data_table/ds_data_table_layout_contract_test.dart --no-fatal-infos --no-fatal-warnings` | `No issues found!`, exit 0 |
| `flutter analyze lib test/organisms --no-fatal-infos --no-fatal-warnings` | exit 0; exactly `212` info-level diagnostics |
| `flutter pub outdated --no-transitive` | completed; no dependency mutation; 7 direct dependencies constrained below latest resolvable versions, 2 locked below current upgradable versions |
| `flutter test test/widget_test.dart --no-pub` in `apps/catalog` | `10/10 passed`, exit 0 |
| `flutter test test/widget_test.dart --no-pub` in `apps/cybercore` | `9/9 passed`, exit 0 |
| `flutter build linux --debug` in `apps/catalog` | bundle built, exit 0 |
| `flutter build linux --debug` in `apps/cybercore` | bundle built, exit 0 |
| `flutter test integration_test/visual_acceptance_capture_test.dart --no-pub` in `apps/catalog` | `5/5 passed`, exit 0; local PNG artifacts verified |
| `flutter test integration_test/cybercore_visual_capture_test.dart --no-pub` in `apps/cybercore` | `2/2 passed`, exit 0; local PNG artifact verified |
| `flutter test ../../tmp/review-1832-dangerzone-probe_test.dart --no-pub` | scrubber probes all passed; toolbar probe reproduced exactly `41px` @40, `31px` @50, `9px` @80; no-toolbar table probes passed |
| `flutter test ../../tmp/review-1832-behavior-probe_test.dart --no-pub` | scrubber content h=119 measured `101px`; h=33 table reported no ListView and no visible row, one ScrollView |
| `flutter test ../../tmp/review-1832-textscale-probe_test.dart --no-pub` | scrubber scales `1.0, 1.15, 1.3, 1.6, 2.0` and table scales `1.0, 1.15, 1.3` passed |
| `flutter test ../../tmp/review-1832-extreme-state-probe_test.dart --no-pub` | `18/18` loading/empty/error extreme-state probes passed |
| `flutter test test/goldens/ds_data_table_golden_test.dart --no-pub` | expected frozen drift failure: `99.62%`, `478180px diff detected`; no baseline refresh performed |

### Commands not run / limitations

- A strict zero-info `dart analyze` acceptance was not available as a green claim because the live package analyzer reports exactly 212 existing info diagnostics under the project command. The scoped touched-file `flutter analyze` was run and passed.
- No `git`/VCS command was used because repository governance and the active review environment prohibit reviewer VCS inspection. Host source/consumer claims were therefore checked from live files and deterministic execution, not diff attribution.
- No golden refresh was attempted; the active Task 1805 freeze explicitly forbids it.
- No production release build was required by Task 1836; debug Linux builds were the declared host build gates.

## Path To 100

1. **Close F3 at the owning table boundary**: make `DSDataTable.toolbar` constraint-safe under bounded heights. For h below the toolbar's intrinsic minimum, place toolbar and table content in a scrollable fallback or provide an explicit compact/collapsible toolbar contract. Add a regression matrix for toolbar callers at h=`40`, `50`, `80`, `100`, and `119`, asserting zero overflow and toolbar reachability.
2. **Make F7 intentional and test-proven**: either keep the header-only h<34 policy but expose the omission in the API/semantics and add a test asserting header visibility plus intentional body omission, or retain rows inside a scrollable fallback so data remains reachable. Do not rely on a no-crash assertion alone for a data-loss-shaped behavior.
3. **Resolve F8 against the accessibility contract**: preserve a genuine 48x48 semantic hit target for selectable compact headers, or make compact mode explicitly non-selectable and expose that state through semantics/API validation. Add tests for compact and ultra-compact selectable tables that inspect the semantic target size and enabled state.
4. **Reduce Analyzer Integrity debt**: eliminate the exact `212` package-wide info diagnostics or document narrowly justified, rule-scoped exceptions. Re-run `dart analyze`/`flutter analyze` without non-fatal suppression and record zero errors, warnings, and infos.
5. **Add direct disposition tests**: include explicit tests for F3's toolbar fallback, F7's h<34 body policy, and F8's compact target semantics so the accepted residual rationale cannot drift silently.
6. **After the above, re-run the complete matrix**: `test/organisms/` exact count, all focused regressions, both host widget suites, both debug builds, capture suites, and the Task 1805 frozen golden audit without refreshing baselines.

## Task Ledger Patch Suggestion

The parent/task owner should add or refresh the compact ledger; this reviewer did not mutate the task file:

```markdown
---

## Review Ledger

### Latest Review

- **Date**: 2026-09-06
- **Reviewer profile**: `reviewers` — independent Task 1836 review
- **Score**: `90/100`
- **Verdict**: `PASS`
- **Full report**: `docs/reports/review/1836-layout-band-completion-independent-review-2026-09-06.md`
- **Lane outcome**: `no move` — task remains in `01-open/`; lane routing is parent/governance-owner authority
- **Task reference**: Task 1836 (`1836-warp-prism-layout-band-completion`)

#### Current Open Residuals

- `PERSISTENT / Debt`: F3 toolbar path still overflows at h=`40/50/80`; accepted latent because no extreme-height application caller was found, but package gallery/test callers exist at roomy heights.
- `PERSISTENT / Debt`: F7 h<34 body omission remains an intentional accepted extreme-constraint policy; direct header/omission oracle is still desirable.
- `PERSISTENT / Debt`: F8 compact/ultra-compact selectable checkbox target remains `32px`/`28px`, below 48dp; no compact selectable host caller found.
- `EVIDENCE_GAP / Improvement`: package-wide analyzer has exactly `212` info diagnostics under the non-fatal gate.

#### Resolved Since Task 1832 Lineage

- F1/F2/F4 scrubber bands independently re-executed and green.
- F6 trap hygiene independently inspected in all three suites.
- F5 expected `data_table_default` drift explicitly recorded; no baseline refreshed.

### Previous Reports

- `2026-09-04` — `73/100` — `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md`
  - **Carried forward**: F3/F7/F8 are explicit accepted residuals with the limitations described above.
  - **Resolved since**: F1/F2/F4/F6 and the expected-drift recording obligation.
  - **Regression guard**: preserve exact height/text-scale matrices, collect-then-expect traps, h=119 slack assertion, and the no-golden-refresh freeze.
```
