# Independent Review Report: Task 1831 — Host Composition Material Ancestry Contract (DSSearchBar) — 2026-09-04

> **Task**: Task 1831 (`1831-warp-prism-host-composition-material-contract.md`, currently resolved at `docs/tasks/01-open/`)
> **Review type**: POST-ACCEPTANCE REVALIDATION (independent; reviewer did not author this work)
> **Reviewer profile**: `reviewers` (Flutter/Dart route)
> **Date**: 2026-09-04
> **Mode**: Score-only + revalidation verdict (no lane authority exercised; task lane moves are explicitly out of this reviewer's write scope)

## Verdict

- **PASS** — post-acceptance revalidation passes for the DSSearchBar/PrismSearchBar Material-ancestry surface.
- **Quality score**: `93/100` (Elite band, diagnostic)
- **Evidence confidence**: `high`
- **Lane routing advice (advice only — no lane move performed)**: task evidence is review-complete; the governance owner may route Task 1831 through its remaining Rule-42 promotion steps (`03-review` record-keeping → `04-completed` acceptance by the orchestrator-reviewers parent). Note: the task file currently sits in `01-open/` with filled Completion Evidence — that lane placement is a parent-owned reconciliation, not a defect of this fix.

## Review Lineage

- **Current task**: Task 1831 (`1831-warp-prism-host-composition-material-contract`); live path `docs/tasks/01-open/1831-warp-prism-host-composition-material-contract.md`
- **Previous reports read**: none found for Task 1831 under `docs/reports/` (verified by search; this is the first independent review of this task).
- **Related reports considered**:
  - `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md` — Task 1805 capture-determinism verdict (`PASS` technical / `BLOCKED` on user visual gate). Relevant because Task 1831's Origin invalidated the same "real-host correctness" premise the 1805 visual packet depends on; also confirms the Task 1800 golden freeze that 1831 must not violate.
  - `docs/reports/review/1805-catalog-local-capture-remediation-independent-review-2026-09-03.md` — same wave context.
- **Review mode**: `final-gate`-style independent review (first review of the task) + L1 revalidation mapping.

## Scope Verified

Files reviewed in full:

- `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` (196 lines, entire file)
- `packages/warp_prism_ui/test/molecules/ds_search_bar_material_contract_test.dart` (134 lines, entire file)
- `docs/tasks/01-open/1831-warp-prism-host-composition-material-contract.md` (entire, incl. Completion Evidence + Changelog Draft)
- `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` (both `DSShell` and `DSShellResponsive`, entire file — to prove the test host supplies no hidden `Material`)
- `packages/warp_prism_ui/lib/src/prism_aliases.dart` (PrismSearchBar alias)
- `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart`, `organisms/command_palette/ds_command_palette.dart`, `molecules/dialog/ds_dialog.dart`, `molecules/ds_toast_manager.dart`, `organisms/watchlist_dock/ds_watchlist_dock.dart` (ownership-canon evidence)
- Real host composition: `apps/observatory/lib/app/app_shell.dart`, `features/map/map_workspace_page.dart`, `features/map/widgets/map_catalog_panel.dart`, `features/workspace_snapshot/widgets/workspace_search_bar.dart`; `apps/catalog/lib/main.dart` (gallery ListTile host)
- Flutter SDK source: `text_field.dart` (`assert(debugCheckHasMaterial(context))` at SDK line 1531) and `material/debug.dart` (`debugCheckHasMaterial`, lines 34–46) — mechanism determinism proof
- Sibling-task attribution surfaces: Task 1832/1833/1834 files and Where tables

## Builder Claim Verification (falsification attempts and outcomes)

### Claim 1 — Ownership decision `component-self-sufficient` with source evidence — VERIFIED

All four cited precedents confirmed at their exact current lines (post-fix shift accounted):

| Claimed evidence | Verified at | Content |
|---|---|---|
| `_IconButton` local Material (claimed pre-fix `:180`) | `ds_search_bar.dart:183-184` | `child: Material(color: DSColors.transparent, child: InkWell(...))` — molecule already owned ink-splash Material locally; the missing ancestor above `TextField` was an internal inconsistency, proving the component already assumed self-sufficiency |
| Command-palette canon (claimed `:257-258`) | `ds_command_palette.dart:257-258` | `Material(type: MaterialType.transparency, ...)` with the exact doc comment "Material is required for TextField/InkWell even when shown via a raw PageRoute without a Scaffold" |
| `ds_dialog.dart:355` | `:355` | `child: Material(` |
| `ds_toast_manager.dart:339` | `:339` | `child: Material(` |
| `ds_watchlist_dock.dart:494` | `:494` | `return Material(` |

The ownership decision is source-backed, not asserted. Fix idiom matches the command-palette canon exactly (`MaterialType.transparency`).

### Claim 2 — Regression test fails pre-fix with exact stack at `:95`, passes 4/4 post-fix — VERIFIED (mechanism-proven; see caveat)

- **Post-fix execution (re-run by reviewer)**: `flutter test test/molecules/ds_search_bar_material_contract_test.dart --no-pub` → **4/4 passed, exit 0**.
- **Pre-fix failure mechanism proven deterministically**: Flutter SDK `TextField.build` asserts `debugCheckHasMaterial(context)` (SDK `text_field.dart:1531`), which throws `No Material widget found. TextField widgets require a Material widget ancestor within the closest LookupBoundary.` (SDK `material/debug.dart:34-46`). `MaterialApp` supplies Localizations/Directionality but **no `Material` widget**; only `Scaffold` (or an explicit `Material`) does. All 4 tests mount the component under `MaterialApp` with **no `Scaffold`** — verified by reading the full test file and the full `DSShellResponsive` source (contains `LayoutBuilder`/`Container`/`Row`/`Column`/`Stack`/`Expanded` only; zero `Material` widgets).
- **Line arithmetic cross-check**: the fix added exactly 2 lines above the `TextField` (`Material(` at :76, `type: MaterialType.transparency,` at :77) and 1 closing paren at the end (:160). Post-fix `TextField` sits at `:97`; pre-fix position `:95` matches the authoritative user runtime crash frame `ds_search_bar.dart:95:22` recorded in the task Origin (2026-09-03, pre-dating the fix). `_IconButton`'s Material shifted `:180 → :183` (+3), exactly consistent with the same insertion. The claimed pre-fix line references and the current file are arithmetically coherent with a fix that changed **only** the wrapper.
- **Real-route ancestry fidelity**: test 3 replicates the actual `/map` route chain `MaterialApp → PrismShellResponsive → Column → Expanded → IndexedStack → Column → Padding → PrismSearchBar`, verified against real host code (`app_shell.dart:115` uses `PrismShellResponsive`; `map_workspace_page.dart:234` uses `IndexedStack`; neither supplies `Material`). Test 2/4 use `DSShellResponsive` (identical class to `PrismShellResponsive`; alias at `prism_aliases.dart:308` also confirms `typedef PrismSearchBar = DSSearchBar`, so the tests exercise the same implementation class the host uses).
- **Caveat (does not reduce the verdict)**: the reviewer could not re-execute the literal pre-fix state (would require mutating repo implementation files or creating a scratch project — both outside this review's write scope; `git` access is permission-denied in this environment). The pre-fix-failure claim is therefore confirmed by (a) deterministic SDK mechanism, (b) authoritative pre-fix user runtime evidence recorded as task Origin, and (c) exact line-shift arithmetic — not by a live pre-fix replay. Confidence in this sub-claim: high, not absolute.

### Claim 3 — All gates exit 0 — VERIFIED (all re-run independently by reviewer)

| Command | Claimed | Reviewer re-run result | Exit |
|---|---|---|---|
| `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings` | exit 0 | 212 info-level lints, **all pre-existing** (gallery files, `graph_painter`, `media_detail_overlay`, `theme_editor`), **0 in touched files** | **0** |
| `cd packages/warp_prism_ui && flutter test test/molecules/ --no-pub` | 335 passed | **+335: All tests passed!** (exact count match) | **0** |
| `cd packages/warp_prism_ui && flutter test test/molecules/ds_search_bar_material_contract_test.dart --no-pub` | 4 passed | **+4: All tests passed!** | **0** |
| `cd apps/observatory && flutter analyze --no-fatal-infos --no-fatal-warnings` | exit 0 | 124 info-level lints, all pre-existing | **0** |
| `cd apps/observatory && flutter test` (811 claim) | 811 passed | **+811: All tests passed!** (exact count match) | **0** |
| `cd apps/observatory && flutter build linux --debug` | exit 0 | **✓ Built build/linux/x64/debug/bundle/warp_prism_observatory** (fresh reviewer-executed build; pre-existing build artifacts at 16:37 also postdate the fix) | **0** |

### Falsification sweep — no hidden traps found

- **No host-supplied Material in the tests** (would make them vacuous): `DSShellResponsive` full-read proves zero `Material` widgets; no test uses `Scaffold`. The regression genuinely exercises the ancestry the real route lacks.
- **No golden refresh**: baseline goldens under `test/goldens/goldens/` newest mtime 2026-07-25 (Task 1800 freeze intact). `test/goldens/failures/` artifacts are from 2026-09-01 (pre-date Task 1831; test-run failure outputs, not baselines). No search-bar goldens exist at all.
- **No protected-file edits**: `AGENTS.md` (2026-09-03 19:23), `MISSION.md` (2026-09-03 19:23), `README.md` (2026-08-23), root `pubspec.yaml` (2026-07-09) — all pre-date the 2026-09-04 work window.
- **No scope creep / exact writeset match**: Task 1831's window is `15:25:40` (`ds_search_bar.dart`), `15:29:36` (contract test), `15:32:17` (task file). Every other 2026-09-04 modification in the repo is attributed to sibling tasks by their own declared writesets: Task 1834 (capture harnesses, 15:24–15:31, self-review 15:31), Task 1832 (data_table/scrubber + layout tests, 15:34–15:48), Task 1833 (tokens/theme + `apps/catalog/lib/main.dart` 16:03, `apps/cybercore/lib/**` 16:06–16:09). **Zero** `apps/observatory/lib/**` files were modified today — host read-only contract respected (the ownership decision was component-side, so no host mutation was authorized or performed).
- **No assertion weakening**: pre-existing search-bar tests retain full assertions (`molecules_contract_test.dart` behavior assertions, `design_system_accessibility_test.dart` focus-registration + semantics-label assertions, `templates_contract_test.dart` presence assertions). The new contract test only adds assertions. `findsOneWidget`/`takeException`-null checks are non-vacuous: test 4 asserts observable state transitions (query callback value, filter-tap flag, clear-button appearance/disappearance).
- **Zero visual/API/behavioral change beyond ancestry**: the added `Material(type: MaterialType.transparency)` paints nothing (SDK canonical non-visual Material — the same idiom as the command palette at `:257-258`); the inner `Container` already paints its own background (`obsidianElevated`) and border. No constructor signature, public API, token, color, size, or semantics changed (verified by full file read; `Semantics` labels unchanged at `:94-96`, `:120`, `:139`; touch targets unchanged 48 dp at `:79`, `:181-182`). The 335 molecules suite (which includes the accessibility and template suites) plus 811 observatory tests passing empirically confirms no behavioral delta.

## Six-Axiom Compliance

| # | Axiom | Status | Evidence |
|---|---|---|---|
| 1 | Analyzer Integrity | **PASS** | Both analyzes exit 0 with project flags; 0 issues in touched files; 212+124 info lints all pre-existing |
| 2 | Lifecycle Safety | **PASS** | 2 controllers created (`_controller` :42, `_focusNode` :43), 2 disposed (`:65`, `:66`); both listeners attach to the disposed objects themselves; 2 `mounted` guards (:45, :49); 0 Timer / StreamSubscription / AnimationController in file; fix added no lifecycle code |
| 3 | Dependency Direction | **PASS** | Molecule imports only `tokens` + `atoms` (:2-3); fix added no imports |
| 4 | UI Accessibility | **PASS** | 3 interactive elements (TextField, clear, filter), all with `Semantics` labels (:94-96, :177-180); 48 dp touch targets (:79, :181-182); accessibility suite green within 335 |
| 5 | Proof Reality | **PASS** | 4 non-vacuous regression tests incl. interactive state-cycle assertions; exact counts match (4/335/811); all re-run by reviewer, exit 0 |
| 6 | Release Security | **PASS (N/A surface)** | No secrets, no `print`/`debugPrint` added, no release-artifact change; `Material` addition is not a security surface |

## Post-Acceptance Revalidation Mapping (per AGENTS.md §3.6)

**What the original crash contradicted (2026-09-03 user runtime evidence):**

- The L1 "real-host correctness" dimension — the claim that Prism interaction/presentation primitives survive contact with real consumers — for the search-bar surface specifically: `DSSearchBar`/`PrismSearchBar` crashed with `No Material widget found` on real Observatory routes (`/map`, `/workspace-snapshot`) because package-local tests supplied `MaterialApp`+`Scaffold` ancestry the real host (`PrismShellResponsive` routes, no `Scaffold`) does not (AGENTS.md §7.1: a widget-test wrapper may not be treated as composability proof). Any prior acceptance evidence resting on "Observatory primary routes render Prism components without framework errors" was invalidated for this surface.

**What this fix re-establishes (independently re-verified today):**

- Component self-sufficiency for Material ancestry on the affected surface, with the exact real-route ancestry (no `Scaffold`) now regression-tested — 4/4 contract tests, 335/335 molecules, 811/811 observatory, both analyzes, and a fresh `flutter build linux --debug` all exit 0, re-executed by this reviewer. The previously invalidated host-composition claim for `/map` and `/workspace-snapshot` search surfaces is re-established.

**What remains invalid / not yet re-established (outside this task's scope):**

1. The **class-wide** Material-ancestry contract is decided but only enforced for `DSSearchBar` plus already-canonical components (command palette, dialog, toast manager, watchlist dock, `DSTextField` atom). Three organisms with raw `TextField` still lack component-local `Material` (see F1) — latent, no current real-host consumer, but the package-wide "shared components are self-sufficient" invariant is not yet systematically enforced.
2. **Sibling invalidated dimensions from the same crash wave remain open**: layout-overflow (Task 1832) and theme-role/accent propagation (Task 1833) are materialized and in their own lanes awaiting their own review cycles; L1 gate state `REVALIDATION_REQUIRED` in `MISSION.md` is not closed by this task alone.
3. **Task 1805's visual gate** remains `BLOCKED — PENDING-USER` (human visual sign-off); its technical capture-determinism `PASS` is unaffected historical evidence.

**Unaffected historical evidence preserved (history not rewritten):**

- Task 1800 golden freeze: baselines untouched (newest 2026-07-25).
- Task 1805 capture-determinism acceptance (100/100, `BLOCKED` on user gate, 2026-09-03) remains historically valid for its evidence snapshot.
- Prior task verdicts and review reports were read, not altered.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
|---|---|---|---|---|---|
| F1 | EVIDENCE_GAP | Moderate (latent risk, no current consumer) | Open | Sibling blast-radius audit required by the task's first subtask and Where table ("grep for other raw TextField/ListTile/ink-dependent widgets… lacking component-local Material") was performed incompletely and **its result was not recorded** in Completion Evidence. Reviewer's independent audit found 3 organisms with raw `TextField` and **zero** component-local `Material`: `ds_filter_workbench.dart:868`, `ds_ai_analyst_panel.dart:1219`, `ds_terminal_workspace.dart:595`. Verified **no real-host consumer** exists for any of the three (zero hits in `apps/*/lib`), and gallery hosting is under `Scaffold` — so nothing "proven-same-mechanism" at runtime; latent contract violations only. (`prism_theme_editor.dart:499` is covered via the self-sufficient `DSTextField` atom — its `Material` at `ds_text_field.dart:341`.) | `ds_filter_workbench.dart:868`; `ds_ai_analyst_panel.dart:1219`; `ds_terminal_workspace.dart:595` |
| F2 | EVIDENCE_GAP | Low | Open | Task Background directed: "Related `ListTile background color or ink splashes may be invisible` warnings in Catalog runs… investigate, do not assume." No recorded investigation in Completion Evidence. Reviewer disposition: gallery `ListTile`s (`design_system_gallery_sections.dart:2543`, `:4555+`) are hosted under the Catalog app's `Scaffold` (`apps/catalog/lib/main.dart:104`), which supplies `Material` — this is the ink-visibility **warning** class (cosmetic), a different mechanism from the `No Material widget found` **crash** class, and out of 1831's crash scope. Should be recorded, then closed or routed separately. | `design_system_gallery_sections.dart:2543`; `apps/catalog/lib/main.dart:104` |
| F3 | ACCEPTABLE_DUPLICATION (informational) | Info | No action | Idiom inconsistency inside `ds_search_bar.dart`: `_IconButton` uses `Material(color: DSColors.transparent)` (:183-184) while the new wrapper uses `Material(type: MaterialType.transparency)` (:76-77). Both are non-visual and behaviorally equivalent for this use (ink features + ancestor resolution); `MaterialType.transparency` is the canonical form. Cosmetic only. | `ds_search_bar.dart:76-77` vs `:183-184` |
| F4 | Ledger hygiene | Low | Open | All task subtask checkboxes and exit-condition checkboxes are unchecked (`- [ ]`) while Completion Evidence is filled — checkbox state contradicts the recorded evidence (compare Task 1834, which checked its boxes). Lane-derived status governs, so this is cosmetic drift, not a status claim. | task file lines 59-66, 73-80 |
| F5 | RESOLVED (regression guard) | — | Closed | Original defect: `DSSearchBar` `TextField` without component-local `Material` ancestor crashed real host routes. Fixed by `Material(type: MaterialType.transparency)` wrapper; 4-test regression guard replicating real route ancestry is in place and green. | `ds_search_bar.dart:76-77`, `:97`; contract test 4/4 |

No Critical findings. No Serious findings. No REGRESSION findings. No NEW code defects (first review of this task; the delta-aware `NEW` restriction does not apply — all non-F5 findings are evidence-completeness items, not code defects).

## Evidence Reviewed

- **Task file**: Task 1831 in full, incl. Completion Evidence, Ownership decision, `affected_consumers` (recorded per AGENTS.md §7.2: Observatory `/map` via `MapPageShell → MapWorkspacePage → MapCatalogPanel → PrismSearchBar` and `/workspace-snapshot` via `WorkspaceSearchBar → PrismSearchBar` — both verified in host source), Changelog Draft.
- **Source/test files**: listed in Scope Verified.
- **Runtime wiring proof**: real-route ancestry chain verified in host source (`app_shell.dart:115`, `map_workspace_page.dart:234`, `map_catalog_panel.dart:84`, `workspace_search_bar.dart:27`); production composition compiles (fresh `flutter build linux --debug`, exit 0).
- **Commands run** (all by reviewer, this session): the 6 gates in the Claim-3 table, plus framework-source greps for mechanism determinism, blast-radius greps, mtime forensics, and golden-baseline freshness checks.
- **Commands not run and why**: literal pre-fix test replay (would require mutating implementation files or scratch-project creation outside this review's write scope; `git` permission-denied in this environment) — mitigated by SDK-source mechanism proof + authoritative pre-fix origin evidence + line-shift arithmetic.

## Path To 100

1. **Record the sibling blast-radius audit result** in the task's Completion Evidence: the 3 latent organisms (`ds_filter_workbench.dart:868`, `ds_ai_analyst_panel.dart:1219`, `ds_terminal_workspace.dart:595`), classified "latent — no current real-host consumer; fix when a consumer exists or in a package-wide ancestry sweep". (Closes F1.)
2. **Record the Catalog ListTile investigation disposition** (warning class ≠ crash class; hosted under `Scaffold`; route as separate cosmetic follow-up if desired). (Closes F2.)
3. **Check the task's subtask and exit-condition checkboxes** to match the already-filled evidence. (Closes F4.)
4. *(Optional polish, zero behavioral delta)*: normalize `_IconButton`'s `Material(color: DSColors.transparent)` (:183) to `MaterialType.transparency` for idiom consistency with the new wrapper and the command-palette canon. (Closes F3; no goldens cover this widget, so it is safe — but purely cosmetic and may be legitimately skipped.)
5. *(Recommended follow-up task, not blocking)*: package-wide Material-ancestry contract enforcement — a meta-test mounting every public `Prism*` widget under bare `MaterialApp` (no `Scaffold`) to make the component-self-sufficiency invariant systematic rather than per-component, plus the 3 latent organisms when they gain consumers.

## Task Ledger Patch Suggestion

*(Suggestion only — the reviewer's write scope is this report; the parent applies ledger updates at reconciliation.)*

```markdown
### Latest Review

- **Date**: 2026-09-04
- **Reviewer profile**: `reviewers`
- **Score**: `93/100` (diagnostic)
- **Verdict**: `PASS` (post-acceptance revalidation of the DSSearchBar Material-ancestry surface)
- **Full report**: `docs/reports/review/1831-host-composition-material-contract-independent-review-2026-09-04.md`
- **Lane outcome**: no move performed by reviewer; governance owner to route per Rule 42
- **Task reference**: Task 1831 (`1831-warp-prism-host-composition-material-contract`)

#### Current Open Blockers

- `EVIDENCE_GAP`: sibling blast-radius audit result not recorded (3 latent TextField organisms; no current host consumer)
- `EVIDENCE_GAP`: Catalog ListTile warning investigation not recorded (separate mechanism; out of crash scope)
- Ledger hygiene: subtask/exit checkboxes unchecked despite filled evidence

#### Path-to-100 Summary

- Record audit + investigation dispositions in Completion Evidence
- Check task checkboxes to match evidence
- Optional: `_IconButton` Material idiom normalization
- Follow-up task: package-wide ancestry meta-test
```

## Residual Risks

1. **Latent same-mechanism exposures** in 3 organisms with no current real-host consumer (F1) — they will crash the same way the moment a host mounts them without `Material` ancestry. Bounded risk until consumers exist.
2. **Pre-fix replay is evidence-reconstructed, not live-replayed** in this review (documented caveat) — the reconstruction is deterministic (SDK mechanism + authoritative origin + arithmetic), so this is an epistemic footnote, not a doubt about the fix.
3. **`MaterialType.transparency` footprint** is canonical and paints nothing, but the class-wide contract is now only as strong as its per-component tests; the meta-test in Path-to-100 item 5 is the systemic guard.
4. **L1 gate state** `REVALIDATION_REQUIRED` remains open pending sibling tasks 1832/1833 reviews and the 1805 user visual gate.

## Recommended Next Action

The technical work passes independent post-acceptance revalidation. Recommended routing (advice only; this reviewer moves nothing):

1. Parent orchestrator applies the Task Ledger Patch above and routes Task 1831 through its remaining Rule-42 promotion steps (`03-review` → `04-completed` acceptance by the orchestrator-reviewers parent). No remediation round is required — the open findings are evidence-recording completions (F1/F2/F4), not code defects, and can be closed by a task-file edit or folded into the promotion record.
2. Materialize the package-wide Material-ancestry meta-test as a small follow-up task (it directly protects the re-established L1 dimension from regressing on the next component).
3. Task 1805 remains blocked solely on the human visual gate — unaffected by this review.

---

*Reviewer: independent Flutter-route reviewer, `reviewers` lane. Read-only review; only this report was written.*
