# Independent Review Report: Task 1835 — Package-Wide Material Ancestry Meta-Test — 2026-09-06

> **Task**: Task 1835 (`1835-warp-prism-material-ancestry-meta-test`, live path `docs/tasks/01-open/1835-warp-prism-material-ancestry-meta-test.md`)
> **Review type**: First independent review of this task (reviewer did not author this work)
> **Reviewer profile**: `reviewers` (Flutter/Dart route via `sk-code-quality-review-flutter.md` → `flutter`)
> **Date**: 2026-09-06 (review completed; sessions `ses_f8745bd18ffephR7OiLVh6S8xJ` + continuation)
> **Mode**: Score-only (no lane authority exercised — the task sits in `01-open/`, where the reviewer subagent's Rule-42 matrix grants no moves; the dispatch explicitly forbids lane/implementation/golden mutation)

## Score And Verdict

- **Score**: `82/100` (Good band; capped below 90 by one Serious acceptance blocker per the severity-coherence law)
- **Verdict**: `FAIL` for acceptance as-is (Task 1835 exit condition 1 — "passes over the full public widget surface" — is contradicted by accepted evidence: 117 of 118 public widget names are enumerated; `PrismSelect` is absent)
- **Evidence confidence**: `high`
- **Lane recommendation**: return to builder for a small remediation (add 1 spec + correct count claims); parent must also reconcile the task's lane placement (see F6). **No lane move performed by this reviewer.**

## Review Lineage

- **Current task**: Task 1835; live path `docs/tasks/01-open/1835-warp-prism-material-ancestry-meta-test.md` (lane placement itself is a finding — F6).
- **Previous reports read**:
  - `docs/reports/review/1831-host-composition-material-contract-independent-review-2026-09-04.md` — 93/100 PASS (post-acceptance revalidation). Task 1835 originates from its F1 (3 latent organisms) and its Path-to-100 item 5 (package-wide meta-test).
  - `docs/reports/review/1832-responsive-layout-contract-independent-review-2026-09-04.md` — sibling-wave context (layout overflow oracles; constrains how overflow diagnostics must be treated).
- **Related reports considered**:
  - `docs/reports/builders/20260906-task-1835-self-review.md` — builder self-review claiming `100/100 ACCEPT`, `Actionable Findings: 0` (contradicted by F1).
- **Review mode**: `initial` independent review (delta classes below use first-review semantics; `NEW` restriction for n>1 iterations does not apply).

## Scope Verified

Files reviewed in full or targeted depth:

- `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart` (838 lines — both wrappers, all 117 specs, the classification loop, and Section-1 tests)
- `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart` (fix site + lifecycle)
- `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart` (fix site + controller binding/lifecycle)
- `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart` (fix site + per-pane resource lifecycle)
- `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart` (raw `TextField` at :230; suffix-icon local Material at :345 — prerequisite-honesty evidence for `PrismTextField` classification)
- `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart` (closed-state GestureDeters :503/:552; popup self-supplies `Material(type: MaterialType.transparency)` :293-294; searchable `DSTextField` :308 — blast-radius analysis for F1)
- `packages/warp_prism_ui/lib/src/molecules/color_field/ds_color_field.dart` (:266 Column), `organisms/code_block/ds_code_block.dart` (:50 Column, :92 Row, `_CopyButton` InkWell :183), `organisms/data_table/ds_data_table.dart` (:354 Row, :417 DropdownButton), `organisms/theme_editor/prism_theme_editor.dart` (:182 Column, :538) — declared-prerequisite classification evidence
- `packages/warp_prism_ui/lib/src/prism_aliases.dart` (`typedef PrismSelect<T> = DSSelect<T>` :356), `lib/warp_prism_ui.dart` (barrel: 4 exports), `lib/src/gallery/design_system_gallery_sections.dart` (DSSelect gallery consumption :449-:510)
- Task file, builder self-review, Flutter SDK `flutter_test` binding source (`takeException` semantics, binding.dart:1620-1637 + 1720-1734)
- `apps/` usage sweep for the three latent organisms (zero hits in `apps/*/lib`; only package-internal gallery demos consume them, hosted under Catalog `Scaffold`)

## Builder Claim Verification (falsification attempts and outcomes)

### Claim 1 — "Enumerated and classified all 117 public widgets" — CONTRADICTED (F1)

The public widget surface is **118** names, not 117. Generic-aware extraction over `lib/src` (widget classes + barrel-exported aliases + gallery widget) yields:

| Quantity | Value | Verified by |
|---|---|---|
| Widget implementation classes | 115 | regex over all `lib/src/**/*.dart` (Stateless/Stateful/RenderObject widget bases) |
| Public widget names (classes + `Prism*` typedef aliases + `DesignSystemGalleryPage`) | **118** | barrel exports `prism_aliases.dart` + 3 gallery files; every widget class resolves to an exported public name |
| Meta-test specs (`WidgetAncestrySpec`) | **117** | `grep -c "WidgetAncestrySpec("` = 118 → minus 1 constructor declaration = 117 specs; unique spec names = 117 |
| Missing spec | **`PrismSelect`** | zero occurrences of the substring `Select` anywhere in the meta-test file; `--plain-name PrismSelect` → exit 79, "No tests ran" |

`PrismSelect` is publicly exported (`prism_aliases.dart:356`, `typedef PrismSelect<T> = DSSelect<T>`) and consumed by a real surface (`design_system_gallery_sections.dart:459, :488, :501, :510`). The same wrong denominator (117) is propagated to the task's Completion Evidence, the changelog draft, and the builder self-review.

**Blast radius of the omission (bounded, but real)**: source inspection of `DSSelect` shows the closed-state trigger is `GestureDetector`-only (:503, :552) and the popup self-supplies `Material(type: MaterialType.transparency)` (:293-294) around its searchable `DSTextField` (:308) — so `DSSelect` would very likely classify `SELF_SUFFICIENT` and mount cleanly bare today. The omission therefore hides **no live defect**; it is an enumeration-completeness failure of the guard itself. That matters because the meta-test's entire purpose (per the task Objective: "mounts every public `Prism*` widget") is to make the enumeration systematic rather than per-component — a guard that silently doesn't cover 1 of 118 public names reproduces, at suite scale, exactly the per-component blind spot the task was created to close.

### Claim 2 — Classification 112 SELF_SUFFICIENT / 5 DECLARED_PREREQUISITE / 0 UNDOCUMENTED_PREREQUISITE — VERIFIED (for the 117 enumerated)

- Spec census: 117 specs = 112 `selfSufficient` + 5 `declaredPrerequisite`; 0 specs expect `undocumentedPrerequisite` (correct: that class is the defect signal, detected at runtime as a test failure when a bare mount throws).
- The 5 declared prerequisites are **source-honest** (each verified against implementation, not just test-green):

| Widget | Rationale in spec | Source evidence |
|---|---|---|
| `PrismTextField` | requires Material ancestor | raw `TextField` at `ds_text_field.dart:230` with no component-local `Material` (only the suffix icon has one, :345) |
| `PrismColorField` | composes PrismTextField | `DSTextField` composition; error Column at `ds_color_field.dart:266` |
| `PrismCodeBlock` | copy button InkWell | `_CopyButton` InkWell at `ds_code_block.dart:183`; header Row :92; body Column :50 |
| `PrismTablePagination` | IconButton/InkResponse | `ds_data_table.dart:417` DropdownButton; ink controls; Row :354 |
| `PrismThemeEditor` | multiple DSTextFields + InkWell chips + bounded height | editor Column :182; InkWell :538; spec documents the height prerequisite |

- The tri-classification mechanism itself is sound per the repaired host-composition workflow: the contract-minimal wrapper supplies exactly `Directionality`/`MediaQuery`/`Localizations`/`Overlay` and no `Material`/`Scaffold`; the prerequisite wrapper adds only `Material(type: MaterialType.transparency)`; every declared-prerequisite spec is validated **both directions** (bare mount must throw, prerequisite mount must be exception-free).

### Claim 3 — "122/122 meta-tests, 170/170 scoped, analyze clean" — VERIFIED (exact-count matches on reviewer re-runs)

| Command (re-run by reviewer, `packages/warp_prism_ui`) | Claimed | Reviewer result | Exit |
|---|---|---|---|
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | exit 0 | 212 info-level lints, all pre-existing (identical count to the Task 1831 baseline; **0 in touched files**) | **0** |
| `flutter test test/meta/material_ancestry_meta_test.dart --no-pub` | 122/122 | `+122: All tests passed!` | **0** |
| scoped 5-file suite (meta + 3 organisms + search-bar contract) | 170/170 | `+170: All tests passed!` | **0** |
| `flutter test test/ --no-pub --exclude-tags=golden` (task Validation Commands) | not recorded by builder | **exit 1 — 1701 success / 64 error** | **1** |

### Claim 4 — 3 latent organisms fixed per 1831 canon, lifecycle-clean, zero visual delta — VERIFIED (F7)

- `Material(type: MaterialType.transparency)` wraps confirmed at `ds_filter_workbench.dart:868-869`, `ds_ai_analyst_panel.dart:1219-1220`, `ds_terminal_workspace.dart:595-596` — exact idiom of the 1831 canon (`ds_command_palette.dart:257-258`); `transparency` paints nothing, so no visual delta; no public API change.
- Lifecycle audit (exact counts): filter workbench — `TextEditingController` created :828, `FocusNode` :829 (+ :1220, :1327), all disposed (:846-847, :1225, :1332); AI analyst panel — `_composer`/`_scroll`/`_composerFocus` created :614-616, disposed :677-679, external-controller listener bound/removed :646/:650 with `_owned` disposed in `_unbind` :651; terminal workspace — per-pane maps disposed in `dispose()` :89-91 with `_reconcilePaneResources` :104-117 on controller swap, `_tabController` listener removed + disposed :82-83. **0 leaks in production code.**
- Section-1 tests prove the three organisms `SELF_SUFFICIENT` with non-vacuous assertions (`takeException()` null **and** `findsOneWidget` **and** `find.byType(TextField)` present).
- `affected_consumers: NONE` is defensible: zero usages of the three organisms under `apps/*/lib` (only package-internal gallery demos, hosted under Catalog `Scaffold`), and the wraps are pure ancestors.

### Full-suite red state — attributed, NOT to Task 1835 (F5)

The reviewer decomposed all 64 full-suite errors from the JSON reporter output:

- **63 golden pixel mismatches** (badge, checkbox, glass panels, metric tiles, status dots, text, shell/page-shell, transcript/map/osint/entity-intel/health-matrix fixtures) at ~99.5% pixel diff — a systemic token/render change, consistent with the sibling Task 1833 theme-role/accent wave (shared-atom files `ds_button.dart`, `ds_checkbox.dart`, `ds_switch.dart`, `ds_text_field.dart`, `ds_interactive_surface.dart`, `ds_sidebar.dart` all modified 2026-09-06 outside 1835's declared writeset), not with 1835's three `transparency` wraps (which paint nothing).
- **1 `TestFailure`** — `DSButton … Tab-focus renders visible focus ring BoxDecoration` (`ds_button_test.dart:239`, Expected true / Actual false) — same sibling atoms wave.
- **0 of the 64 failures touch any file in Task 1835's writeset** (meta-test + 3 organisms all green in scoped re-runs).

Secondary harness gap surfaced by this: `--exclude-tags=golden` excludes **nothing** — zero files under `test/` use `@Tags` (verified by grep), so the task's documented full-suite Validation Command cannot pass on this branch regardless of 1835. Routed as follow-up (F5), not a 1835 defect.

### Meta-test oracle semantics — `takeException` mechanics verified against SDK source

Per `flutter_test` `binding.dart` (takeException :1632-1637; two-exception rule :1720-1734): the bare-mount phase of each declared-prerequisite test throws the Material assertion first (pending), and the subsequent ~99k-pixel `RenderFlex` overflows observed in console output (6 total: `ds_text_field.dart:295`, `ds_color_field.dart:266`, `ds_code_block.dart:50`/`:92`, `ds_data_table.dart:354`, `prism_theme_editor.dart:182`) are **second exceptions dumped to console, not pending**. Mechanism: missing `Material` → `TextField` build throws → `ErrorWidget` substitution renders the giant assertion text → flex overflow. They are artifacts of the deliberate negative probe, not independent component layout defects. Critically, the prerequisite-mount phase's `expect(tester.takeException(), isNull)` **is a real clean-mount guard**: any new exception during that pump becomes pending and fails the test (verified: all 5 pass with zero diagnostics in that phase). The task's green result is therefore not a swallow-and-pass — with one oracle caveat recorded as F2.

## Six-Axiom Compliance

| # | Axiom | Status | Evidence |
|---|---|---|---|
| 1 | Analyzer Integrity | **PASS** | Project gate exit 0 on reviewer re-run; 212 infos all pre-existing (count identical to 1831 baseline), 0 in touched files; no suppressions added |
| 2 | Lifecycle Safety | **PASS (production)** | Exact audit above: every controller/focusNode/listener in the 3 touched organisms has a matching dispose/unbind; wraps add no lifecycle code. Test-side teardown gaps recorded as F3 (test-only) |
| 3 | Dependency Direction | **PASS** | Meta-test imports only `flutter/material`, `flutter_test`, and the package barrel; no layering change |
| 4 | UI Accessibility | **PASS (N/A-surface)** | Wraps add no interactive elements; accessibility suites green (none of the 64 failures are accessibility tests); meta-test is not a semantics oracle and does not claim to be |
| 5 | Proof Reality | **FAIL (partial)** | Core "full public widget surface" claim contradicted: 117/118 enumerated, `PrismSelect` absent (exit-79 falsification); count 117 propagated to task evidence, changelog draft, self-review; builder self-review "0 findings / 100-100 ACCEPT" falsified by F1 |
| 6 | Release Security | **PASS (N/A surface)** | No secrets, no `print`/`debugPrint` in the new test (grep-verified); no release surface touched |

## Delta Summary

### Resolved Since Previous Review (1831 lineage)

- `RESOLVED` (1831 F1, regression guard): the 3 latent organisms now carry component-local `Material(type: MaterialType.transparency)` per canon and are proven `SELF_SUFFICIENT` by dedicated Section-1 tests.
- `RESOLVED` (1831 Path-to-100 item 5): the package-wide Material-ancestry meta-test now exists — realized by this task, minus the enumeration hole (F1).
- `SUPERSEDED` (1831 F2 context): Catalog `ListTile` ink-visibility warning class remains out of 1835's scope (correctly not scope-crept); still routed separately per 1831 recommendation.

### New Findings

- `NEW` F1/F2/F3/F4/F5/F6 below (first review; all classes are first-observation, not regressions of a prior fix).

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
|---|---|---|---|---|---|---|
| F1 | NEW | **Serious** (acceptance blocker) | Open | Enumeration incomplete: 118 public widget names, 117 specs; `PrismSelect` (`typedef … = DSSelect` at `prism_aliases.dart:356`) absent — zero `Select` substring occurrences in the meta-test; `--plain-name PrismSelect` exits 79 "No tests ran". Task exit condition 1 ("passes over the **full** public widget surface") is not satisfied; wrong denominator (117) propagated to Completion Evidence, changelog draft, and self-review. No live defect hidden (DSSelect trigger is GestureDetector-only :503/:552; popup self-supplies Material :293) — the blast radius is guard integrity, which is the deliverable's purpose. | this report | `prism_aliases.dart:356`; `material_ancestry_meta_test.dart` (0 hits for `Select`); gallery consumption `design_system_gallery_sections.dart:449-510` |
| F2 | NEW | Debt | Open | Bare-phase oracle accepts **any** exception as `declaredPrerequisite` (`meta_test.dart:818-823` asserts only `isNotNull`). An unrelated bare-mount crash (null assertion, missing inherited widget other than Material) would be silently classified as a legitimate declared prerequisite instead of surfacing as a defect. Fix: assert the exception is a `FlutterError` whose message contains `No Material widget found` (workflow §2: the negative probe should fail loudly **for the declared reason**). | this report | `meta_test.dart:815-823` |
| F3 | NEW | Debt | Open | Test-hygiene: controllers created inside spec builders are never disposed — `PrismAiAnalystController` (:425), `PrismTerminalWorkspaceController` (:431), `PrismAgentShellPanelController` (:594), `PrismTabController` (:679, :684). Section-1 tests do this correctly via `addTearDown` (:145, :166). No production impact; ChangeNotifier leak per test run. | this report | `meta_test.dart:425, :431, :594, :679, :684` vs `:145, :166` |
| F4 | NEW | Improvement | Open | `PrismThemeEditor` spec embeds `SizedBox(height: 600)` inside the **builder** (:793), so the bare-mount probe also receives the height constraint. The constraint is part of the declared prerequisite (documented in the rationale); placing it in `prerequisiteWrapper` would keep the bare probe honest to "the widget as the host would mount it". Minor oracle clarity. | this report | `meta_test.dart:791-797` |
| F5 | NEW | Debt (harness, non-attributed) | Open (follow-up) | `--exclude-tags=golden` excludes nothing (0 `@Tags` in `test/`), so the task's documented full-suite Validation Command cannot pass on this branch: 64 errors = 63 sibling golden pixel mismatches (~99.5% diff — systemic token/render change from the 1833-wave atoms) + 1 DSButton focus-ring TestFailure (`ds_button_test.dart:239`). **None attributable to 1835's writeset.** Route: golden tagging or sibling-wave golden reconciliation. | this report | full-suite JSON run (1701/64); grep `@Tags` = 0; sibling atom files modified 2026-09-06 |
| F6 | NEW | Info (governance) | Open (parent-owned) | (a) Builder self-review claims `100/100 ACCEPT, 0 findings` — falsified by F1; self-review is not independent acceptance (Rule 42). (b) Task sits in `01-open/` with filled Completion Evidence — the claim-law `01-open → 02-doing → 03-review` progression never happened; same lane-anomaly pattern as 1831 F4; parent must reconcile lane placement. | this report | task file path; `docs/reports/builders/20260906-task-1835-self-review.md` |
| F7 | RESOLVED (regression guard) | — | Closed | 1831 F1's three latent organisms fixed per canon (evidence in Claim 4); lifecycle-clean; no visual delta; scoped suites + meta Section-1 green. | 1831 report | `ds_filter_workbench.dart:868-869`; `ds_ai_analyst_panel.dart:1219-1220`; `ds_terminal_workspace.dart:595-596` |

No Critical findings. One Serious finding (F1). No REGRESSION findings.

## Evidence Reviewed

- **Task file**: Task 1835 in full (Objective, Test Requirements, Exit Conditions, Completion Evidence, changelog draft).
- **Source/test files**: listed in Scope Verified.
- **Runtime wiring proof / non-runtime rationale**: this is a test-infrastructure + latent-fix task; the "runtime" surface is host composition, proven via the contract-minimal/prerequisite wrapper mechanics (Claim 2/4) — real-host composition for the 3 organisms is correctly `NONE` (no host consumer exists; gallery consumption is under `Scaffold`).
- **Commands run (reviewer, this review)**:
  1. `flutter analyze --no-fatal-infos --no-fatal-warnings` → **exit 0** (212 pre-existing infos)
  2. `flutter test test/meta/material_ancestry_meta_test.dart --no-pub` → **exit 0**, `+122: All tests passed!`
  3. `flutter test` scoped 5-file suite `--no-pub` → **exit 0**, `+170: All tests passed!`
  4. `flutter test test/ --no-pub --exclude-tags=golden` (JSON reporter) → **exit 1**, 1701 success / 64 error (63 golden + 1 focus-ring; 0 in 1835 writeset)
  5. `flutter test test/meta/material_ancestry_meta_test.dart --no-pub --plain-name PrismSelect` → **exit 79**, "No tests ran"
  6. Enumeration greps (118 specs check, `Select` substring = 0, `MaterialType.transparency` sites ×3, `PrismSelect` typedef, `print`/`debugPrint` = 0, `@Tags` = 0), SDK `takeException` source inspection, gallery/`apps` usage sweeps.
- **Commands not run and why**: full `flutter build` of consumer apps — no consumer is affected (`affected_consumers: NONE` verified by source sweep); golden baselines deliberately not touched (Task 1800 freeze).

## Path To 100

1. **Add the `PrismSelect` spec** (`material_ancestry_meta_test.dart`, molecules section). Expected classification: `selfSufficient` (verify by bare-mount first: trigger is GestureDetector-only at `ds_select.dart:503/:552`; popup self-supplies `Material` at :293). If the bare mount throws for a reason the contract doesn't declare, that is a real finding — otherwise `selfSufficient` + `findsOneWidget` assertion. Correct the denominator **118** (not 117) in: task Completion Evidence, changelog draft summary, and self-review counts. *(Closes F1 — the acceptance blocker; estimated +8-10 points.)*
2. **Tighten the bare-phase oracle** at `meta_test.dart:818-823`: assert `bareException` is a `FlutterError` whose `message` contains `No Material widget found`, so unrelated crashes cannot masquerade as declared prerequisites. *(Closes F2.)*
3. **Dispose spec-created controllers**: restructure the classification loop to create controllers in the test body with `addTearDown(controller.dispose)` (or add a `disposeHook` to `WidgetAncestrySpec`), covering :425, :431, :594, :679, :684. *(Closes F3.)*
4. *(Optional)* Move the `PrismThemeEditor` height bound from the builder (:793) into its `prerequisiteWrapper`. *(Closes F4.)*
5. **Route F5** to the 1832/1833 wave owner: add `@Tags("golden")` to golden suites (making `--exclude-tags=golden` effective) or reconcile the sibling golden baselines; record full-suite attribution. Not 1835 scope.
6. **Parent actions**: apply the Task Ledger Patch below; reconcile the task's lane placement per the claim law (the completed-evidence-in-`01-open` anomaly, F6).

## Task Ledger Patch Suggestion

*(Suggestion only — this reviewer's write scope is this report; the parent applies ledger updates at reconciliation.)*

```markdown
### Latest Review

- **Date**: 2026-09-06
- **Reviewer profile**: `reviewers`
- **Score**: `82/100` (diagnostic)
- **Verdict**: `FAIL` (acceptance not established — exit condition 1 contradicted; remediation required)
- **Full report**: `docs/reports/review/1835-material-ancestry-meta-test-independent-review-2026-09-06.md`
- **Lane outcome**: no move performed by reviewer (task in `01-open/`); parent to reconcile lane placement and route remediation
- **Task reference**: Task 1835 (`1835-warp-prism-material-ancestry-meta-test`)

#### Current Open Blockers

- `NEW` Serious: `PrismSelect` missing from the 117-spec enumeration (public surface = 118 names; `--plain-name` exit 79); "full public widget surface" exit condition not satisfied
- `NEW` Debt: bare-phase oracle accepts any exception as declaredPrerequisite
- `NEW` Debt: 5 spec-built controllers never disposed (test-only)
- `NEW` Debt (follow-up, non-attributed): golden exclusion ineffective (`@Tags` absent); full-suite red = 63 sibling goldens + 1 focus-ring failure
- Governance: self-review 100/100 ACCEPT falsified by F1; lane placement anomaly (completed evidence in `01-open/`)

#### Resolved (regression guards)

- 1831 F1 latent organisms: fixed per canon at `ds_filter_workbench.dart:868`, `ds_ai_analyst_panel.dart:1219`, `ds_terminal_workspace.dart:595` — lifecycle-clean, no visual delta, proven SELF_SUFFICIENT

#### Path-to-100 Summary

- Add `PrismSelect` spec; correct counts to 118 across task/changelog/self-review
- Assert the bare-mount exception is the missing-Material FlutterError
- addTearDown for spec-built controllers
- Route golden-tagging / sibling-wave reconciliation to the 1832/1833 owner
```

### Previous Reports

- `2026-09-04` — `93/100` — `docs/reports/review/1831-host-composition-material-contract-independent-review-2026-09-04.md`
  - **Carried forward**: F1 (3 latent organisms → resolved here as F7); F2 (Catalog ListTile warning → still routed separately); Path-to-100 item 5 (this task).
  - **Regression guard**: none of 1831's accepted repairs were undone by 1835's writeset.

## Residual Risks

1. **`PrismSelect`/`DSSelect` guard hole until F1 closes**: today likely `SELF_SUFFICIENT` (popup self-supplies `Material`; trigger has no ink primitives), but a future evolution of the trigger toward ink/`TextField` primitives would be invisible to the meta-test — precisely the regression class the suite exists to catch.
2. **Oracle looseness (F2)**: a non-Material bare-mount crash in any future widget would be silently classified `DECLARED_PREREQUISITE` rather than flagged, weakening the `UNDOCUMENTED_PREREQUISITE` defect signal.
3. **Full-suite red on this branch (F5)**: until golden tagging or sibling-wave reconciliation, any consumer of the documented full-suite command sees 64 errors; none are 1835's, but the signal-to-noise failure makes real regressions harder to spot.
4. **Negative-probe overflow diagnostics** (~99k px, 6 occurrences) will print on every meta-test run; they are `ErrorWidget` artifacts of the intentional bare mount (mechanism verified), but reviewers re-running the suite should know they are expected in the bare phase and must remain absent in the prerequisite phase (where the `isNull` guard is real).
5. **Lane governance (F6)**: completed evidence in `01-open/` leaves the task outside the review-lane flow the Rule-42 matrix assumes; parent reconciliation needed before any promotion step.

## Recommended Next Action

1. **Parent routes a small builder remediation** (single apply-path100 pass): add the `PrismSelect` spec, correct the 117→118 counts in the three claim surfaces, tighten the bare-phase oracle, add the missing `addTearDown`s. All four items are contained in `material_ancestry_meta_test.dart` plus documentation lines — no implementation, no goldens, no public API.
2. **Re-review** after remediation (delta-aware): F1 is the only acceptance blocker; with it closed the remaining items are Debt/Improvement and the task would score in the 90-99 `APPROVED_PATH100` band, subject to verified both-direction classification of `PrismSelect`.
3. **Parent reconciles lane placement** (F6) and applies the ledger patch.
4. **Route F5** (golden tagging / sibling golden reconciliation) to the 1832/1833 wave owner as harness follow-up.

---

*Reviewer: independent Flutter-route reviewer, `reviewers` lane. Read-only review; only this report was written. No implementation, task-lane, protected-file, or golden mutations were performed.*
