# Review Report: Task 1833 — Theme-Role and Accent Propagation — 2026-09-04

## Review Lineage

- **Current task**: Task 1833 (`1833-warp-prism-theme-role-accent-propagation.md`); live path: `docs/tasks/01-open/1833-warp-prism-theme-role-accent-propagation.md`
- **Previous reports read**: none found for Task 1833.
- **Related reports considered**:
  - `docs/reports/review/1807-token-override-theme-editor-independent-review-2026-08-23.md` — establishes the production mutation boundary previously observed for the registry and the accepted analyzer policy context.
  - `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md` — establishes that the three-host capture harness can produce technical host evidence, but does not accept the visual criteria.
  - `docs/architecture/layer-contracts-v2.md` — defines registry mutator ownership and the current boundary-check contract.
  - `docs/reports/1825-integration-readiness-l1-exit-report.md` — records the boundary harness result and the registry-mutator ownership claim.
- **Review mode**: `initial` independent revalidation / score-only. No product code or task-lane mutation was performed.
- **Evidence partiality**: `partial` for the task's full runtime claim. Package and app command evidence was rerun; no independent real-host route exercise was available in this review, and the current source contains a direct production-path contradiction.

## Scope and Review Question

The review tests the Task 1833 claims that:

1. equivalent interactive chrome uses one recipe-driven accent role;
2. skin switches propagate to all shared interactive roles;
3. CyberCore teal remains opt-in and does not use production registry mutation or leak into structural/semantic/data roles;
4. criteria 3, 5, 9, and 11 of Task 1805 can be re-established from current source and evidence.

The named shared widgets inspected were `DSButton`, `DSSwitch`, `DSCheckbox`, `DSTextField`, `DSTabBar`, `DSSidebar`, and `DSInteractiveSurface`. The three affected consumers declared by the task are Catalog, CyberCore, and Observatory.

## Score and Verdict

- **Quality score**: **48/100 — Serious**
- **Verdict**: **FAIL**
- **Evidence confidence**: **high** for the two source contradictions; **medium** for the missing host-evidence conclusion.
- **Lane recommendation**: `no-move` from this score-only review. The task remains in its current lane; remediation belongs to the builder/owner under the task workflow.

The package regression tests are green, but they prove registry mutation plus a `ListenableBuilder`, not that the named widgets consume a red/purple `ThemeData` skin extension without registry mutation. The source also contains two CyberCore production registry mutations, contradicting the documented production boundary and the task's claimed scoped opt-in design.

## Axiom Compliance

| Axiom | Status | Evidence and limitation |
|---|---|---|
| 1. Analyzer Integrity | **PARTIAL** | Task-required `flutter analyze --no-fatal-infos --no-fatal-warnings` exited 0 for the package, Catalog, CyberCore, and Observatory. Literal default `flutter analyze` exited 1 for `warp_prism_ui` with exactly 212 issues and Observatory with exactly 124 issues; Catalog and CyberCore default analyze exited 0. The repository's accepted gate treats the package/Observatory info baseline as non-fatal, but strict zero-info integrity is not met. |
| 2. Lifecycle Safety | **PASS for reviewed surfaces** | The reviewed internal controller/focus/ticker resources have matching cleanup: `DSTextField` disposes internally-created `TextEditingController` and `FocusNode` and removes focus listeners; tab/sidebar `FocusNode`s are disposed; `DSGlowBorder` disposes its `AnimationController`. No lifecycle defect was found in the Task 1833 surfaces inspected. |
| 3. Dependency Direction | **PARTIAL** | The boundary harness exited 0 and the UI package does not import the consumer apps. However, the mutable token singleton is written from CyberCore production code at `apps/cybercore/lib/main.dart:7-9` and `:23-25`, despite the registry contract and architecture docs assigning mutation to tooling/theme-editor paths. |
| 4. UI Accessibility | **PARTIAL** | The shared interactive surface supplies a 48x48 minimum and semantic button state, and the targeted accessibility suite passed. Dynamic accent/focus role propagation is not consistent across the named widgets, so accessibility contrast/focus proof for alternate skins is incomplete even though the static criterion-9 calculations pass. |
| 5. Proof Reality | **FAIL** | The seven Task 1833 tests pass twice and the package token/theme/accessibility suite passes twice, but the widget regression uses `ListenableBuilder` plus registry mutation. It does not exercise `PrismTheme.taldarimRed()`/`talonPurple()` with the named widgets while leaving the registry untouched, and no independent real-host composition proof establishes the same contract across all three consumers. |
| 6. Release Security | **PARTIAL / not release-scoped** | No secret or debug-log defect was found in the reviewed files, but this task did not provide release-obfuscation or artifact-hardening evidence. The production singleton mutation is an integrity/architecture defect rather than a demonstrated secret exposure. |

## Findings

### F1 — Production CyberCore code mutates the global token registry — `NEW`, Serious, Open

**Evidence**:

- `apps/cybercore/lib/main.dart:7-9` calls `PrismTokenRegistry.instance.applySkin(...)` in `main()`.
- `apps/cybercore/lib/main.dart:23-25` calls the same mutator again from `WarpPrismCyberCoreApp.build()`.
- `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart:128-132` documents the registry as a tooling/Theme Editor override layer and states that production paths never mutate token state.
- `docs/architecture/layer-contracts-v2.md:109` names the enforced ownership as `prism_token_registry.dart` plus `theme_editor/`.
- `packages/warp_prism_ui/test/boundaries/boundary_test.dart:516-533` only scans the UI library for `setColor|resetRole`; it does not scan consumer apps and does not detect `applySkin`.

**Impact**: CyberCore production startup and every `build()` invocation mutate process-global token state. This makes the claimed theme-extension-only opt-in boundary unenforced and creates state coupling between any consumers/tests sharing the process. The build-time mutation is especially unsafe because it is not a one-time initialization boundary.

**Required change**: Remove both production `PrismTokenRegistry.instance.applySkin` calls. Install `DSCyberCoreTealSkin` on the CyberCore `ThemeData` only, then make dynamic widgets resolve their active accent/focus roles from the theme context. Extend the boundary check or a dedicated consumer check to forbid registry mutators in `apps/observatory/lib/**` and `apps/cybercore/lib/**`, with an explicit tooling-only allowlist for Catalog if that remains authorized.

### F2 — Named interactive widgets still bypass the theme recipe helpers — `NEW`, Serious, Open

The task added `DSTheme.accentOf`, `accentMutedOf`, `accentDimOf`, `focusRingOf`, and `borderGlowOf`, but none of the inspected named widgets call those helpers. The source contains exactly **20** direct dynamic-role references in the reviewed widget set:

- `DSButton`: one teal-extension/static fallback at `packages/warp_prism_ui/lib/src/atoms/button/ds_button.dart:121-122`.
- `DSSwitch`: one teal-extension/static fallback at `packages/warp_prism_ui/lib/src/atoms/switch/ds_switch.dart:31-32`.
- `DSCheckbox`: four `DSColors.accentBlue` references at `ds_checkbox.dart:88-89,97,112,119`.
- `DSTextField`: five accent/focus references at `ds_text_field.dart:141-142,152,161,179,238`.
- `DSTabBar`: six accent/focus references at `ds_tab_bar.dart:298,300,301,303,374,399`.
- `DSSidebar`: two accent/focus references at `ds_sidebar.dart:186,255`.
- `DSInteractiveSurface`: one focus reference at `ds_interactive_surface.dart:135`.

The `DSButton` and `DSSwitch` special-case only `DSCyberCoreTealSkin.maybeOf(context)`, so Taldarim Red and Talon Purple theme extensions fall back to the registry-backed Khalai Blue. The other five widget implementations read registry-backed `DSColors` directly and ignore a `PrismAccentSkin` installed on `ThemeData`.

**Impact**: `PrismTheme.taldarimRed()` and `PrismTheme.talonPurple()` can render a red/purple `ColorScheme`/extension while the shared interactive widgets remain blue unless another caller mutates the global registry. This directly defeats the task's alternate-skin propagation objective and leaves criteria 3 and 11 unproven.

**Required change**: Replace dynamic interactive/focus reads in the seven named widgets with a single canonical context resolver, using `DSTheme.accentOf(context)`, `DSTheme.accentMutedOf(context)`, `DSTheme.accentDimOf(context)`, `DSTheme.focusRingOf(context)`, or `DSTheme.borderGlowOf(context)` according to the role. Preserve `accentCyan`, `accentViolet`, `accentGold`, and status/data roles where they are intentionally semantic or categorical.

### F3 — The regression test does not test the failing theme-extension path or real hosts — `EVIDENCE_GAP`, Serious, Open

**Evidence**:

- `packages/warp_prism_ui/test/theme/theme_role_accent_propagation_test.dart:133-202` wraps widgets in `ListenableBuilder`, applies each skin through `PrismTokenRegistry.instance.applySkin`, and asserts registry-backed glow colors. This can pass even when widgets ignore `ThemeData.extensions`.
- `theme_role_accent_propagation_test.dart:204-262` tests the helper functions with four themes, but the probe only records helper return values; it does not pump the named widgets under the returned themes and inspect their visible roles.
- `apps/observatory/lib/app/app.dart:14-18` uses the default theme and contains no alternate-skin/registry wiring.
- `apps/catalog/lib/main.dart:229-247` is an authorized tooling switcher and does mutate the registry, but that path is not representative proof for production consumers.
- The Task 1833 completion evidence claims affected consumers but does not provide independent real-host route/viewport/framework-error evidence for all three hosts.

**Impact**: Seven passing tests and the 200-test scoped suite prove package-local behavior under a registry-driven wrapper, not the claimed shared contract across ThemeData skins and real consumer composition. The missing oracle allows F2 to survive.

**Required change**:

1. Add widget tests that pump each named interactive widget under `PrismTheme.taldarimRed()` and `PrismTheme.talonPurple()` without calling any registry mutator, then assert the visible red/purple role.
2. Add a theme-switch test that replaces `ThemeData`/`ThemeExtension` and verifies the same widget subtree changes without global registry state.
3. Add real-host composition evidence for Catalog, CyberCore, and Observatory: launch the actual host, enter an affected route, exercise one interaction, cover representative compact/expanded viewports, and fail on framework errors, `ErrorWidget`, or overflow.
4. Re-run criteria 3, 5, 9, and 11 after the source fix. Criterion 9's existing contrast suite is useful but cannot substitute for propagation proof.

### F4 — Strict default analyzer integrity is not green — `EVIDENCE_GAP`, Debt, Open

**Evidence**:

- `packages/warp_prism_ui`: default `flutter analyze` exit 1, exactly 212 reported issues; task-required non-fatal gate exit 0.
- `apps/observatory`: default `flutter analyze` exit 1, exactly 124 reported issues; task-required non-fatal gate exit 0.
- `apps/catalog`: default analyze exit 0.
- `apps/cybercore`: default analyze exit 0.

This appears to be an existing repository baseline reflected by prior accepted review policy, not a defect introduced by the Task 1833 patch. It nevertheless prevents a strict six-axiom Analyzer Integrity PASS and should not be described as literal analyzer cleanliness.

**Required change**: Either remove the 212/124 baseline diagnostics under the owning task, or explicitly maintain the project-level non-fatal-info analyzer policy and phrase completion evidence as “zero errors under the repository gate,” not “clean” under the default invocation.

## Validation Evidence

### Commands rerun in this review

| Command | Result |
|---|---|
| `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings` | **Exit 0**; output reports 212 issues under the accepted non-fatal-info policy |
| `cd packages/warp_prism_ui && flutter analyze` | **Exit 1**; exactly 212 issues |
| `cd packages/warp_prism_ui && flutter test test/theme/theme_role_accent_propagation_test.dart --no-pub` | **Exit 0**, 7 tests passed; run 1 |
| Same target test command | **Exit 0**, 7 tests passed; run 2 |
| `cd packages/warp_prism_ui && flutter test test/tokens/ test/theme/ test/accessibility/ --no-pub` | **Exit 0**, 200 tests passed; run 1 |
| Same package scoped-suite command | **Exit 0**, 200 tests passed; run 2 |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **Exit 0**; boundary harness passed |
| `cd apps/catalog && flutter analyze --no-fatal-infos --no-fatal-warnings` | **Exit 0** |
| `cd apps/catalog && flutter analyze` | **Exit 0** |
| `cd apps/catalog && flutter build linux --debug` | **Exit 0** |
| `cd apps/catalog && flutter test --no-pub` | **Exit 0** |
| `cd apps/cybercore && flutter analyze --no-fatal-infos --no-fatal-warnings` | **Exit 0** |
| `cd apps/cybercore && flutter analyze` | **Exit 0** |
| `cd apps/cybercore && flutter test --no-pub` | **Exit 0** |
| `cd apps/observatory && flutter analyze --no-fatal-infos --no-fatal-warnings` | **Exit 0**; output reports 124 issues under the accepted non-fatal-info policy |
| `cd apps/observatory && flutter analyze` | **Exit 1**; exactly 124 issues |
| `cd apps/observatory && flutter test --no-pub` | **Exit 0** |
| `dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart` | **Exit 0**; public barrel audit passed (recorded earlier in this review session) |

### Evidence not established

- No independent real-host composition run across all three affected consumers was completed in this review.
- No widget-level proof exists for red/purple `ThemeData` extensions with the registry untouched.
- No release obfuscation/split-debug-info validation was in scope for Task 1833.
- No golden baselines were refreshed, consistent with the task freeze.

## Criteria Revalidation

| Task 1805 criterion | Revalidation judgment | Reason |
|---|---|---|
| 3 — accent limited to interaction/focus | **FAIL remains** | The shared widgets do not consistently resolve the active theme recipe; direct static/registry-backed reads remain in 20 reviewed role references. |
| 5 — rainbow/decorative chrome | **PARTIAL / not re-established** | CyberCore route colors were narrowed, but the global registry mutation is still in production and `mcp_inspector_page.dart:95` retains `PrismColors.accentViolet` for a tool-count insight. That may be an intentional data role, but the current evidence does not prove the distinction across the live host. |
| 9 — contrast/focus | **PARTIAL** | The criterion-9 calculation and accessibility suite pass, and the reviewed lifecycle/focus code is sound. Alternate-skin widget propagation and real-host focus rendering remain unproven. |
| 11 — same contract across hosts | **FAIL remains** | Catalog uses tooling registry mutation, CyberCore uses production registry mutation, and Observatory uses the default theme; there is no proof that all three hosts use one equivalent theme-context contract. |

## Positive Evidence and Safe Findings

- The Task 1833 regression file contains exactly seven declared tests and all seven pass in two consecutive target runs.
- The combined package tokens/theme/accessibility suite passes exactly 200 tests in two consecutive runs.
- Registry setup/teardown is present at `theme_role_accent_propagation_test.dart:30-36`.
- Semantic/data freeze assertions cover status colors, categorical accents, and obsidian surfaces at `theme_role_accent_propagation_test.dart:91-131`.
- The relevant controller, focus-node, listener, and animation-controller cleanup inspected in the affected widgets is present.
- The public barrel audit and boundary harness both exit 0; their current scope does not detect the production `applySkin` calls described in F1.

## Path To 100

1. **Remove the two CyberCore production registry writes** at `apps/cybercore/lib/main.dart:7-9` and `:23-25`; keep CyberCore teal as a `ThemeData`/`ThemeExtension` opt-in only.
2. **Centralize dynamic role resolution** and migrate the exact 20 reviewed role references in `DSButton`, `DSSwitch`, `DSCheckbox`, `DSTextField`, `DSTabBar`, `DSSidebar`, and `DSInteractiveSurface` to the context-based recipe helpers. Do not change semantic/data/categorical tokens.
3. **Strengthen the regression oracle** with red and purple widget tests that do not mutate `PrismTokenRegistry`, plus a theme replacement test proving visible updates in the same subtree.
4. **Add host-composition proof** for Catalog, CyberCore, and Observatory, including affected routes, representative viewport conditions, one interaction, focus/theme propagation, and uncaught framework-error detection. Record `affected_consumers` and exact artifacts.
5. **Harden the mutation boundary check** so `applySkin`, `setAccentRecipe`, `setColor`, `resetRole`, and `reset` are scanned in consumer app libraries; allow only explicitly authorized Catalog tooling/test-host paths.
6. **Re-run the task gates** and revalidate criteria 3/5/9/11. Keep the existing semantic/data freeze and no-golden-refresh constraints.
7. **Correct the task ledger/completion wording** to distinguish package-local registry proof from real-host proof and to record the F1/F2 remediation evidence. Do not promote the task until an independent reviewer can mark all mandatory conditions PASS.
8. **For strict 100/100 analyzer compliance**, resolve the exact 212 package and 124 Observatory default diagnostics or document and govern a deliberate policy exception rather than calling default analysis clean.

## Task Ledger Patch Suggestion

The task's compact Review Ledger should record the following, without copying this full report:

```markdown
### Latest Review

- **Date**: 2026-09-04
- **Reviewer profile**: `reviewers`
- **Score**: `48/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review/1833-theme-role-accent-propagation-independent-review-2026-09-04.md`
- **Lane outcome**: no move by score-only reviewer

#### Current Open Blockers

- `NEW / Serious`: CyberCore mutates the global PrismTokenRegistry from `main()` and `build()`.
- `NEW / Serious`: named interactive widgets bypass the ThemeData recipe helpers; red/purple theme extensions are not propagated without registry mutation.
- `EVIDENCE_GAP`: package tests do not prove the ThemeData path or real-host behavior across Catalog, CyberCore, and Observatory.
- `EVIDENCE_GAP / Debt`: default analyzer exits 1 for the package (212 issues) and Observatory (124 issues); non-fatal-info task gate exits 0.

#### Path-to-100 Summary

- Remove CyberCore production registry mutation.
- Migrate the exact 20 dynamic-role references to context-based recipe helpers.
- Add red/purple no-registry widget tests and three real-host composition proofs.
- Extend registry mutation boundary enforcement and re-run criteria 3/5/9/11.
```

No task file, product implementation, golden, lane, or VCS surface was modified by this review.
