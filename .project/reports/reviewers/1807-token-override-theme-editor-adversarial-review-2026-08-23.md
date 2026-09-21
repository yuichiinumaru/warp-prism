# Task 1807 Adversarial Review — Token Override Layer and PrismThemeEditor

- **Review date:** 2026-08-23
- **Reviewer profile:** `reviewers`
- **Review mode:** independent adversarial visual QA/editor review; builder-context `100/100` claim treated as untrusted
- **Score:** **88/100**
- **Verdict:** **REJECT**
- **Lane action:** move from `docs/tasks/03-review/` to `docs/tasks/02-doing/` (collision-safe; no existing 1807 file found)

## Lineage and claim reconciliation

Previous report: `docs/reports/review/1807-token-override-theme-editor-independent-review-2026-08-23.md` (builder-context final `100/100`). The current review independently confirms registry/editor behavior and scoped tests, but finds a concrete contract violation in the live editor implementation: the preset controls hardcode 15 color literals inside `prism_theme_editor.dart`, while Task 1807's contract says the editor targets the canonical editable roles and Task 1804's audit policy forbids raw component literals outside approved token/data lanes. The editor also has a deterministic-state safety gap: it subscribes to the singleton and resets only in tests; its public widget has no owned-scope/reset-on-dispose option, so an editor mutation can leak to a subsequent tooling/gallery consumer unless the host explicitly resets.

## Contract / editor safety audit

### Registry scope

`PrismTokenRegistry` contains exactly nine editable roles: surfaces, border, blue ladder, and focus ring. Defaults match the provisional Task 1800 contract. `DSColors` delegates the nine roles through getters; data/status colors remain const. This portion is sound.

### Editor preset literals

`prism_theme_editor.dart:309-373` contains 15 raw literals for Obsidian Blue, CyberCore Teal, and Protoss Gold presets. These are not merely display swatches: tapping each preset passes the raw values into `PrismTokenRegistry.setColor`, changing canonical editable blue/focus roles. This is a live visual override path and should consume a documented preset model/token source or an explicit editor preset data lane. Current Task 1804 and Task 1806 reports claim a 2-finding raw-color baseline and omit these values.

### Determinism / safety

- Registry tests reset in `setUp`/`tearDown`, and the golden-safety widget proves mutate → render → reset → defaults.
- `apps/catalog/lib/main.dart` listens to the singleton, and grep found no registry mutation in Observatory or CyberCore app code.
- However, `PrismThemeEditor.dispose()` removes its listener and disposes controllers but does **not** reset or scope registry state. The API is a global singleton and `setColor` is public. This preserves test determinism only through test discipline, not a fail-closed editor lifecycle contract.
- This is acceptable for the current Catalog-only tooling convention only if explicitly documented as host-owned global session state and the host resets on session end. No such host disposal/reset proof is present in the reviewed evidence.

## Axiom matrix

| Axiom | Status | Evidence |
|---|---|---|
| Registry correctness | ✅ | Nine-role enum, default values, override/reset/notification tests pass. |
| Public API integrity | ✅ | Prism aliases exported; boundary harness 7/7. |
| Editor behavior | ✅ | Hex parse/error/live update/copy/presets/reset tests pass; 48dp target tests pass. |
| Raw visual-value contract | ❌ | 15 live preset literals in the organism implementation; audit reports omit them. |
| Determinism/isolation | ⚠️ | Tests reset singleton, but runtime editor lifecycle has no owned scope or host teardown reset proof. |
| Human visual approval | ❌ | No approved screenshot/hex convergence or bake-back; explicitly PENDING-USER. |
| Analyzer/tests | ✅ | Package non-fatal analyzer 0 errors; scoped 189/189; Catalog clean; CyberCore clean; boundary 7/7. |
| Golden safety | ⚠️ | 59 frozen golden failures remain as expected interim drift; no baseline refresh. |

## Findings

### F1 — Preset raw literals violate live audit baseline (MODERATE; blocking)

The editor's 15 literals are in an organism implementation and are directly used for registry mutation. They are not token definitions and not passive gallery swatches. This contradicts the published Task 1804 exact-baseline statement and makes the audit command's current result 18 rather than 2.

**Path to 100:** define typed preset data in an explicitly documented fixture/editor-data file, or derive the Obsidian preset from `PrismColorRole.defaultColor` and route opt-in skins through a documented token/theme extension. Update Task 1804/1806 inventories and add a regression test proving editor preset sources are classified/allowed.

### F2 — Global singleton mutation is not lifecycle-scoped (MODERATE; safety evidence gap)

`PrismTokenRegistry` is a global mutable singleton. `_PrismThemeEditorState.dispose()` removes listeners but leaves overrides active. Tests reset manually, but a Catalog editor session can leave mutations visible to later gallery/test consumers unless the host resets. The task guardrail says production app paths must not mutate registry; Catalog is tooling, but the implementation does not encode a reset boundary.

**Path to 100:** document Catalog-owned session scope and prove a host teardown/reset path, or expose a scoped registry/session object to the editor while preserving singleton defaults. Add a widget/integration test that mounts editor, mutates, unmounts, remounts a consumer, and asserts the declared isolation behavior.

### F3 — Human convergence and bake-back remain pending (EVIDENCE_GAP / EXTERNAL_BLOCKER)

Task 1807 explicitly leaves bake-back, user-approved hexes, and post-bake golden pass incomplete. No screenshot artifact exists and Observatory capture is blocked by the stream-channel runtime failure. This is not a builder defect when correctly labeled, but it prevents visual acceptance.

**Path to 100:** user convergence with artifact hash/sign-off, bake back approved values into registry defaults and contract, then pass Task 1805's one-time golden refresh gate.

## Validation evidence

- Package analyzer `flutter analyze --no-fatal-infos --no-fatal-warnings`: PASS, 218 infos/0 errors.
- Scoped tests `test/tokens/ test/organisms/theme_editor/ test/organisms/media_detail_overlay/ test/gallery/ test/boundaries/`: PASS, 189/189.
- Boundary harness: PASS, 7/7.
- Catalog analyzer: PASS; CyberCore analyzer: PASS; Observatory no errors under non-fatal gate.
- Frozen golden suite: FAIL, 59 expected interim drift; no refresh.
- Catalog typography capture: harness pass, `MissingPluginException`, no PNG.
- Observatory capture: EXTERNAL_BLOCKER — stream-channel `Bad state: Cannot close sink while adding stream` / timeout.
- Non-mutating format check: red; 9 reviewed files reported as changed. No formatting mutation performed.

## Score rationale

88/100. Registry/editor behavior is well tested, but the live editor introduces raw preset literals that invalidate the claimed audit baseline, and global override lifecycle isolation is convention-only. Human visual approval is also absent. Score <90 requires rejection and lane return.

## Path to 100

1. Remove or formally isolate the 15 preset literals from the organism implementation; update audit inventories.
2. Encode/document registry session reset ownership and test editor unmount/remount isolation.
3. Resolve supported visual capture or record the external blocker with an approved device path.
4. Obtain user-approved hex convergence and screenshot artifact; bake back only after sign-off.
5. Perform one approved golden refresh; rerun analyzer, tests, boundaries, and non-mutating format gate.