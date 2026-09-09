# Task 1835: Package-Wide Material Ancestry Meta-Test

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status. Do not add a task-level `Status` field.
> **Review State**: `Promoted` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🟡 P1
> **Type**: `testing`
> **Origin**: Task 1831 independent review (2026-09-04) — reviewer F1/F2: 3 latent organisms with raw `TextField` lacking component-local `Material`; Catalog `ListTile` ink-visibility warning class
> **Blocks**: N/A
> **Depends on**: Task 1831 (completed)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug.

---

## Milestone Alignment

- **Target milestone**: M01 — L1 Integration-Capable
- **Capability / Gate advanced**: SYSTEMATIC_ORACLE_GAP closure — the Material-ancestry crash class was invisible to package tests until a real host exercised it
- **Strategic why**: One meta-test makes the entire class (not just `DSSearchBar`) regression-guarded, institutionalizing the 1831 reviewer's recommendation
- **Consequence if absent**: The next organism that mounts a raw `TextField`/ink primitive outside Material-providing ancestry ships green and crashes in a real host again

---

## Objective

Create a package-wide ancestry meta-test that mounts every public `Prism*` widget (or every widget exported from the public barrel) under a bare `MaterialApp` with NO `Scaffold`/`Material` supplied by the test harness, and fails on any `No Material widget found` / ink-visibility exception. Fix the 3 already-identified latent organisms (`ds_filter_workbench.dart:868`, `ds_ai_analyst_panel.dart:1219`, `ds_terminal_workspace.dart:595`) using the 1831 canon (`Material(type: MaterialType.transparency)`).

## Background Context

### What already exists
- 1831 canon: component-local `Material(type: MaterialType.transparency)` (see `ds_search_bar.dart`, `ds_command_palette.dart:257-258`).
- Task 1831 review F1: 3 latent organisms with raw `TextField`, no host consumer outside Material-providing ancestry today.
- Task 1831 review F2: Catalog `ListTile` background/ink warnings (cosmetic class, gallery under `Scaffold`).

### What is missing or broken
- No package-wide guard: nothing prevents a future component from reintroducing the crash class.
- The 3 latent organisms are unfixed (invisible today only because no host exercises them bare).

---

## Test Requirements
- Meta-test enumerates public barrel exports; each mounted under a **contract-minimal wrapper** (`Directionality`/`MediaQuery` only — NOT blanket bare-`MaterialApp`-and-fail) per `.agents/skills/flutter/workflows/sk-flutter-host-composition.md` §1–§2 (repaired Flutter harness, 2026-09-06 realignment).
- Per widget, classify outcome: `SELF_SUFFICIENT` | `DECLARED_PREREQUISITE` (documented/enforced) | `UNDOCUMENTED_PREREQUISITE` (fails contract-minimal mount without declaring it). Only `UNDOCUMENTED_PREREQUISITE` is a defect; a component may legitimately require an ancestor if the contract says so (flutter workflow §1 — do not assume a Material requirement is a component bug).
- The 3 latent organisms fixed per canon; meta-test proves them `SELF_SUFFICIENT`.
- `flutter analyze` + scoped tests green; no golden refresh.

## Exit Conditions
- [x] Meta-test exists and passes over the full public widget surface.
- [x] 3 latent organisms fixed per 1831 canon.
- [x] `flutter analyze` + scoped `flutter test` green.
- [x] `affected_consumers: NONE` justification recorded (test-only + latent-only fixes) or per AGENTS.md §7.2.
- [x] Completion Evidence filled; changelog draft in task.

## Validation Commands
```bash
cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings
cd packages/warp_prism_ui && flutter test test/ --no-pub --exclude-tags=golden
```

## Anti-Hallucination Guardrails
> [!CAUTION] Meta-test must mount real exported widgets with valid args — not stubs that skip build().

> [!IMPORTANT] No golden refresh. No public API changes. Do not refactor unrelated idiom variance (1831 F3 stays deferred). Harness realignment 2026-09-06: contract-minimal wrapper + `UNDOCUMENTED_PREREQUISITE` classification replaces blanket bare-mount-and-fail — a declared ancestor requirement is not automatically a component bug.

## Completion Evidence

### Files Modified & Created
- `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart`: wrapped `TextField` in `Material(type: MaterialType.transparency)` at line 868.
- `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart`: wrapped `TextField` in `Material(type: MaterialType.transparency)` at line 1219.
- `packages/warp_prism_ui/lib/src/organisms/terminal_workspace/ds_terminal_workspace.dart`: wrapped `TextField` in `Material(type: MaterialType.transparency)` at line 595.
- `packages/warp_prism_ui/test/meta/material_ancestry_meta_test.dart`: package-wide Material-ancestry meta-test suite enumerating and classifying all 118 public widgets (123 tests).
- `docs/reports/builders/1835-material-ancestry-meta-test-builder-report.md`: additive builder iteration report superseding the initial self-review.

### Validation Commands & Results
```bash
# 1. Package analysis
cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings
# Exit code: 0 (0 errors, 0 warnings, clean gate with 212 pre-existing info baseline)

# 2. Scoped tests (meta-test with all 118 specs + touched organisms + 1831 canon)
cd packages/warp_prism_ui && flutter test \
  test/meta/material_ancestry_meta_test.dart \
  test/organisms/filter_workbench/filter_workbench_test.dart \
  test/organisms/ai_analyst_panel/ai_analyst_panel_test.dart \
  test/organisms/terminal_workspace/ds_terminal_workspace_test.dart \
  test/molecules/ds_search_bar_material_contract_test.dart \
  --no-pub
# Exit code: 0 (171 / 171 passed)
```

### Affected Consumers Classification (AGENTS.md §7.2)
```yaml
affected_consumers: NONE
reason: Test-only meta-suite addition plus latent-only MaterialType.transparency fixes at raw TextField sites on 3 unexercised bare organisms (DSFilterWorkbench, DSAiAnalystPanel, DSTerminalWorkspace). No visual or behavioral changes to existing scaffolded hosts. Zero public API changes.
```

### Changelog Draft
- **task**: 1835
- **agent**: gt-builders-engineer-flutter
- **project**: warp-prism
- **title**: package-wide-material-ancestry-meta-test
- **description**: Implement package-wide Material-ancestry meta-test and fix 3 latent organisms per 1831 canon
- **summary**: Enumerated and classified all 118 public widgets exported by the warp_prism_ui barrel under contract-minimal wrappers (113 SELF_SUFFICIENT, 5 DECLARED_PREREQUISITE, 0 UNDOCUMENTED_PREREQUISITE). Wrapped raw TextField sites in DSFilterWorkbench, DSAiAnalystPanel, and DSTerminalWorkspace with Material(type: MaterialType.transparency) per the 1831 canon, proving all 3 organisms SELF_SUFFICIENT under bare host composition.
- **verification**: `cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub` (123/123 passed)

## Review Ledger

### Review 1 — 2026-09-06 (FAIL 82/100 -> Remediation, F1 blocker)

- **Reviewer profile**: `reviewers` (`gt-reviewers-reviewer-flutter`, session `ses_f8745bd18ffephR7OiLVh6S8xJ` + continuation; fleet reviewer — see `.projects/sessions/sessions.md`)
- **Score**: `82/100` (Good band; capped <90 by one Serious acceptance blocker per severity-coherence law)
- **Verdict**: **FAIL** — acceptance not established; small builder remediation required
- **Evidence confidence**: high
- **Full report**: `docs/reports/review/1835-material-ancestry-meta-test-independent-review-2026-09-06.md`
- **Open blockers**:
  - `NEW` **Serious (acceptance blocker)** — F1: enumeration incomplete; public widget surface = **118** names, meta-test has **117** specs; `PrismSelect` (`typedef … = DSSelect`, `prism_aliases.dart:356`; gallery consumption `design_system_gallery_sections.dart:449-510`) absent. Exit condition 1 ("full public widget surface") not satisfied; wrong denominator propagated to Completion Evidence, changelog draft, self-review.
  - `NEW` Debt — F2: bare-phase oracle accepts any exception as `declaredPrerequisite` (`meta_test.dart:818-823`); should assert the missing-`Material` `FlutterError` specifically.
  - `NEW` Debt — F3: 5 spec-built controllers never disposed (`meta_test.dart:425,431,594,679,684`) — add `addTearDown`.
  - `NEW` Improvement — F4: `PrismThemeEditor` height bound sits in builder (`:793`) instead of `prerequisiteWrapper`.
  - `NEW` Debt (follow-up, non-attributed) — F5: `--exclude-tags=golden` excludes nothing (zero `@Tags` in `test/`); full-suite red = 63 sibling golden mismatches (1833-wave atoms) + 1 DSButton focus-ring failure. Routed to wave owner, not 1835 scope.
- **Verified solid (no action)**: classification of the 117 enumerated (112 SELF_SUFFICIENT + 5 DECLARED_PREREQUISITE, both directions, source-honest); 3 latent organisms fixed per 1831 canon (F7 resolved); scoped suites 122/170 green; analyzer gate exit 0 with pre-existing info baseline only; `affected_consumers: NONE` defensible.
- **Required remediation (single pass)**: add `PrismSelect` spec (expected `selfSufficient` — verify by bare mount first), correct 117→118 counts in task Completion Evidence + changelog draft, tighten bare-phase oracle (F2), add `addTearDown`s (F3).
- **Path-to-100**: with F1 closed the task lands in the 90-99 APPROVED_PATH100 band pending verified `PrismSelect` classification.
- **Lane note**: moved `01-open/ -> 02-doing/` by parent (Karax) 2026-09-07 per claim law before remediation dispatch; lane anomaly (completed evidence in `01-open/`, falsified self-ACCEPT) flagged by reviewer — reconciled via this move.

### Review 2 — 2026-09-07 (APPROVED_PATH100 95/100 — Remediation Round 1 accepted; promoted)

- **Reviewer profile**: `reviewers` (dedicated fleet session `ses_f8745bd18ffephR7OiLVh6S8xJ`)
- **Score**: `95/100` (Elite band — APPROVED_PATH100; no open Serious/Critical finding in 1835 scope)
- **Verdict**: `APPROVED_PATH100_HELD_IN_REVIEW` at review time; parent final verify completed 2026-09-07 → **promoted**
- **Evidence confidence**: high (census independently recomputed; all gates re-run)
- **Full report**: `docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md` (Entry 2 + governance rider)
- **REGRESSION findings**: NONE
- **F1 RESOLVED** (honest, not greenwashed): census 118 specs = 118 public names (missing-set empty); `--plain-name PrismSelect` exit 0 `+1` (inverted from Review 1's exit 79); classification 113 SELF_SUFFICIENT + 5 DECLARED_PREREQUISITE + 0 UNDOCUMENTED (source-count arithmetic verified); bare mount of `PrismSelect` genuinely throws nothing (mechanism source-verified: GestureDetector-only trigger `:503/:552`, popup self-supplies `Material` `:293`); counts corrected across all claim surfaces (residual "117" strings confirmed as quoted history only).
- **F2 RESOLVED**: bare-phase oracle captures `FlutterErrorDetails`, asserts `'No Material widget found'` containment, handler restored before `takeException` (`:853-867`).
- **F3 RESOLVED**: `trackController` + `addTearDown` dispose loop covering all 5 controller sites (`:442, :448, :613, :699, :708`).
- **F4 RESOLVED**: `PrismThemeEditor` height bound moved into `prerequisiteWrapper` (`:818-826`); builder is `const PrismThemeEditor()`.
- **F6 RESOLVED**: task in `02-doing/` during remediation; 100/100 self-review honestly superseded; additive builder report is the live claim surface.
- **F7 re-confirmed**: latent organisms unchanged; scoped +171 green.
- **Gates re-run by reviewer**: analyze exit 0 (212 pre-existing info baseline, 0 in touched files) / meta `+123` / `--plain-name PrismSelect` `+1` / scoped 5-file `+171`.
- **Current Open Items (non-blocking, carried)**:
  - `PERSISTENT` F5 (harness follow-up, non-attributed): golden `@Tags` tagging / sibling golden reconciliation — owner: 1832/1833-wave parent.
  - `NEW`/Improvement N1: `PrismSelect` spec renders closed-state with no selection (mount-oracle adequate; interaction-level oracle is future work).
  - `NEW`/Improvement N2: bare-phase oracle asserts presence of the missing-Material error, not exclusivity (prerequisite-phase `takeException() isNull` is the stronger guard); optional `length == 1` tightening.
- **Governance rider (same session)**: Rule 70 behavioral-mutation review of the 2026-09-07 session-ledger convention → **PASS** (classification `behavioral` confirmed; no contradictions; `wp-` prefix-list improvement note routed to harness-architecture).
- **Lane outcome**: `02-doing → 03-review → 04-completed` (parent final verify; exit conditions 1–4 all verified green; F5/N1/N2 non-blocking and externally owned).

### Path-to-100 remediation queue

1. Add `PrismSelect` spec in molecules section; verify both directions.
2. Correct denominator 117→118 in task Completion Evidence, changelog draft (do not republish old one-shot self-review — supersede it in the additive builder report).
3. Tighten bare-phase oracle: bare-mount exception must be `FlutterError` containing `No Material widget found`.
4. `addTearDown` for spec-built controllers (`:425, :431, :594, :679, :684`).
5. *(Optional polish)* Move `PrismThemeEditor` height bound into `prerequisiteWrapper` (F4).

## Agent Session Ledger

- 2026-09-06: Task implementation and first self-review executed by builder-engineer. Implemented `material_ancestry_meta_test.dart` with 117 specs and wrapped 3 latent organisms in `MaterialType.transparency`. Scoped tests 170/170 passed. Task preserved in `01-open/` per Rule 42.
- 2026-09-07: Remediation Round 1 executed by persistent fleet engineer. Remediated Review 1 findings:
  1. F1: Added missing `PrismSelect` spec in molecules section; verified `selfSufficient` classification by bare mount. Full public widget surface is now completely enumerated at 118 specs / 123 tests.
  2. F2: Tightened declared-prerequisite bare-phase oracle to explicitly verify the exception contains `No Material widget found`.
  3. F3: Added controller tracking and teardown hook (`addTearDown`) for spec-built controllers in `PrismAiAnalystPanel`, `PrismTerminalWorkspace`, `PrismAgentShellPanel`, `PrismTabBar`, and `PrismTabView`.
  4. F4: Moved `PrismThemeEditor` height bound from builder into `prerequisiteWrapper` so the bare-mount probe tests the widget as mounted by a host.
  5. Corrected denominator 117 -> 118 in task Completion Evidence, changelog draft, and created additive builder report. Scoped 5-file suite 171/171 passed; analyzer gate exits 0 with 0 errors/0 warnings (212 pre-existing info baseline). Task preserved in `02-doing/` per Rule 42.
