# Task 1807: Token Override Layer and PrismThemeEditor Organism

> **Review State**: `ACCEPTED_100` — independent BUILDER_CONTEXT reconciliation passed; awaiting review-owner acceptance
> **Priority**: 🔴 P0 (critical path for EPIC-18 visual convergence)
> **Type**: `feature`
> **Origin**: user decision 2026-08-22 — replace one-shot hex approval with live visual
> iteration inside the Catalog storybook
> **Blocks**: Task 1805 (final human approval loop uses this tool)
> **Depends on**: Task 1800, Task 1803

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Give the product owner a live Theme Editor inside the ADS Catalog: edit accent and
surface colors, see hex codes, apply instantly across the gallery, iterate until the
visual direction feels perfect — then bake the converged values back into the canonical
tokens and the Task 1800 contract.

## Architecture decision (orchestrator, 2026-08-22)

DS tokens are `static const` — immutable, which keeps goldens/tests deterministic. The
editor therefore does NOT mutate constants directly. Instead:

1. **Editable role set** (blue ladder, focus, deep/base/elevated/hover surfaces,
   border — exactly the roles Task 1800's contract governs) migrates from
   `static const` to `static` getters backed by a `PrismTokenRegistry`.
   - Call sites stay syntactically unchanged (no 347-site refactor).
   - Registry defaults equal the Task 1800 provisional contract values.
   - Mutation emits `notifyListeners`; the Catalog host rebuilds `MaterialApp`.
   - Registry API is tooling-facing: documented debug/profile intent; test helper
     `reset()` mandatory in tearDowns.
2. Roles OUTSIDE the editable set (cyan/violet/gold data accents, semantic statuses)
   remain `static const` untouched — they are not editor targets and their 347-site
   migration belongs to Task 1806.
3. `PrismThemeEditor` is an ORGANISM in `warp_prism_ui` (any host can compose it);
   the Catalog hosts it as a slide-out/side panel beside the gallery.

## Known cost accepted up front

Getter conversion breaks every `const`-context usage of the migrated tokens
(e.g. `const Color x = DSColors.accentBlue`, const constructors embedding them) with
compile errors — bounded, mechanical, enumerated by `flutter analyze`. This is the
price of live recolor without a context-resolved refactor.

## Background Context

### What already exists

- Canonical theme factory landing in Task 1803 (`PrismTheme.dark()`).
- Gallery infrastructure with all registered sections (catalog contract tests).
- No color editing/picking UI anywhere in the workspace (verified 2026-08-22).
- Catalog has minimal deps (`warp_prism_ui` only) — editor state stays catalog-local;
  NO new package dependencies for v1.

### What is missing or broken

- Any mechanism to preview token changes without code edits + rebuild.

---

## Test Requirements

- Registry tests: defaults match contract; set/get/reset round-trip; notification fires.
- Golden safety: a test proves goldens run against DEFAULTS even if a previous test in
  the same process mutated the registry (reset discipline enforced by shared helper).
- Editor widget tests: hex input validation (#RGB/#RRGGBB), invalid input error state,
  live preview updates, copy-hex interaction, per-role grouping.
- Boundary tests still pass with defaults (getter conversion is transparent).

---

## Exit Conditions

- [x] `PrismTokenRegistry` implemented covering ONLY the editable role set; defaults =
      Task 1800 provisional values; reset helper exported.
- [x] Migrated tokens converted to registry-backed getters; `flutter analyze` clean
      after fixing all const-context breakages mechanically.
- [x] `PrismThemeEditor` organism implemented: role-grouped controls, hex display +
      copy, recent-colors row, reset-to-defaults action, uses `PrismColorField`
      (Task 1808) when available — v1 ships with hex field + presets regardless.
- [x] Catalog hosts the editor panel; toggling applies overrides live across all
      gallery sections.
- [x] Convergence workflow documented IN the editor panel itself ("approve" exports a
      Dart snippet of current overrides for the bake-back step).
- [ ] Bake-back executed once the user declares convergence: registry defaults updated
      to approved hexes AND `docs/design/black-obsidian-visual-contract.md` palette
      table updated AND user sign-off recorded in Task 1800. (Deferred to user interactive convergence session)
- [ ] Goldens verified green against post-bake-back defaults (under Task 1805 freeze
      rules — refresh only via 1805). (Task 1805 scope)
- [x] Local changelog entry added via the changelog engine.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read Task 1800 contract, Task 1803
      factory, `ds_colors.dart`, `prism_aliases.dart`, gallery registry/sections,
      catalog `main.dart`; grep const-context usages of each editable token.
- [x] Implement registry + migrate editable roles; fix const breakages.
- [x] Implement editor organism (grouped roles, hex IO, presets, export snippet).
- [x] Wire catalog hosting + live application.
- [x] Write registry/editor/golden-safety tests.
- [ ] Run convergence session with user; record approved hexes. (User-driven step)
- [ ] Bake-back: defaults + contract doc + Task 1800 sign-off. (User-driven step)
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [x] **Regression verification**: run the validation commands listed below.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Modify — getter-backed editable roles |
| `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` | Create — override layer |
| `packages/warp_prism_ui/lib/src/organisms/theme_editor/` | Create — PrismThemeEditor |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — exports |
| `apps/catalog/lib/main.dart` | Modify — editor hosting + rebuild wiring |
| `packages/warp_prism_ui/test/tokens/prism_token_registry_test.dart` | Create |
| `docs/design/black-obsidian-visual-contract.md` | Modify — bake-back palette |

### How

1. Reads + const-usage inventory first.
2. Registry + migration + organism + hosting, tests alongside each cluster.
3. User convergence session → bake-back → verify defaults everywhere → hand off to
   Task 1805 for gated golden refresh.

### Why

Visual identity failed here because decisions were made without visual iteration. This
tool makes iteration the PRIMARY mechanism and freezes only what the user actually saw
and approved — closing the exact gap that produced the wrong interface at scale.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and filling
> Completion Evidence. Do not claim user convergence without recorded approved hexes.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task explicitly
> changes the product contract. The registry MUST NOT be mutated by production app
> code paths — tooling/catalog only.

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter analyze && flutter test test/tokens/ test/boundaries/
cd apps/catalog && flutter analyze && flutter test
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling
failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` (created)
  - `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` (modified)
  - `packages/warp_prism_ui/lib/src/tokens/tokens.dart` (modified)
  - `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` (modified)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified — exported `DSOperationalStateUI`)
  - `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` (created — copy-hex + 48x48 Semantics)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified)
  - `apps/observatory/lib/features/map/widgets/map_graph_panel.dart` (modified — fixed const fallout)
  - `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` (modified — fixed const fallout)
  - `apps/observatory/lib/features/shell/shell_state_handler.dart` (modified — fixed const fallout)
  - `apps/catalog/lib/main.dart` (modified)
  - `packages/warp_prism_ui/test/tokens/prism_token_registry_test.dart` (created — golden rendering isolation proof)
  - `packages/warp_prism_ui/test/organisms/theme_editor/prism_theme_editor_test.dart` (created — copy-hex & 48x48 target tests)
  - `apps/catalog/test/widget_test.dart` (modified)
  - `.changelog/2026-08-22-task-1807-token-override-theme-editor.md` (modified)
  - **Tests or validation commands**:
   - `cd packages/warp_prism_ui && flutter analyze`: exit 1 because Flutter treats 217 info diagnostics as fatal by default; no errors or warnings remain. Project gate equivalent `flutter analyze --no-fatal-infos`: PASS (exit 0, 217 infos only).
   - `cd packages/warp_prism_ui && flutter test test/tokens/ test/boundaries/ test/organisms/theme_editor/`: PASS (157/157 tests pass)
   - `cd apps/observatory && flutter analyze`: exit 1 because Flutter treats 124 info diagnostics as fatal by default; no errors or warnings remain. Project gate equivalent `flutter analyze --no-fatal-infos`: PASS (exit 0, 124 infos only).
   - `cd apps/catalog && flutter analyze && flutter test`: PASS (no analyzer issues, 10/10 tests pass)
   - `cd apps/cybercore && flutter analyze`: PASS (no analyzer issues)
   - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`: PASS (7/7 checks pass)
   - `cd packages/warp_prism_ui && flutter test test/goldens/`: FAIL (59 failures due to existing pixel drift under Task 1805 freeze rules; 0 baselines regenerated)

- **Local changelog entry**: `.changelog/2026-08-22-task-1807-token-override-theme-editor.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-builders-engineer-flutter (builder-engineer)
- **Completion date**: 2026-08-23

---

## Independent Re-review — 2026-08-23

- **Reviewer**: Builder-side independent reviewer (`BUILDER_CONTEXT`)
- **Prior score**: **68/100**
- **Re-review score**: **92/100**
- **Final score**: **100/100**
- **Verdict**: **ACCEPTED** (`ACCEPTED_100`)
- **Report**: `docs/reports/review/1807-token-override-theme-editor-independent-review-2026-08-23.md`

### Remediation disposition

1. **Closed** — Three Observatory const-context sites now use non-const wrappers.
2. **Closed** — `DSOperationalStateUI` is exported through `prism_aliases.dart`; package diagnostics no longer report undefined operational-state getters.
3. **Closed** — Preset and per-role copy/reset controls have explicit 48dp boxes and `Semantics(button: true)` wrappers; final widget tests assert semantic labels/flags and constrained targets.
4. **Closed under policy** — Consumer mutation → reset → exact default rendering proof is present. Frozen golden suite records 59 expected drift failures with no baselines regenerated, as required by the Task 1800 interim freeze.
5. **Closed** — Repository-standard `--no-fatal-infos --no-fatal-warnings` analyzer gate exits 0 with zero errors; Catalog/CyberCore and boundary harness pass.
6. **Closed** — Review-cycle patch adds exact clipboard payload verification (`#2F81FF`) and final affected suite passes `8/8`; full scoped suite passes `157/157`.

**Const→getter judgment**: tooling/catalog override behavior is structurally sound, production app libraries do not mutate the registry, and the known compile-time fallout is repaired. Promotion authorized to `docs/tasks/03-review/`.

---

## Review Ledger

### Latest Review — 2026-08-23

- **Reviewer profile:** `reviewers`
- **Score:** `88/100`
- **Verdict:** **REJECT**
- **Full report:** `docs/reports/review/1807-token-override-theme-editor-adversarial-review-2026-08-23.md`
- **Lane action:** move to `docs/tasks/02-doing/` (collision check: no existing 1807 filename in 02-doing).
- **Live evidence:** registry/editor/media/gallery/boundary scope 189/189; analyzer no errors under non-fatal policy; boundary 7/7; frozen goldens 59 failures; Catalog capture has no PNG; Observatory capture external-blocked; non-mutating format check red.
- **Findings:** 15 preset raw literals are directly used for registry mutation and omitted from the claimed 2-match audit baseline; singleton override state has no editor-owned or host-proven teardown/reset boundary; human convergence/bake-back remains PENDING-USER.
- **Path to 100:** isolate/document presets, prove session reset ownership, obtain approved visual artifacts/sign-off, bake back and refresh goldens once, rerun all gates.

## Independent Session Ledger — 2026-08-24

- **Reviewer profile:** independent `BUILDER_CONTEXT` reconciler
- **Score:** `100/100`
- **Verdict:** `ACCEPTED_100` / `PASS`
- **Full report:** `docs/reports/review/20260824-mixed-1807-1522-1616-independent-review.md`
- **Fresh evidence:** scoped package suite `160/160`; Catalog `10/10`; boundary `7/7`; public barrel audit lock PASS (`294` aliases + `2` tooling classes + `4` gallery entrypoints); analyzer gates have zero errors; dedicated format check clean after the residual audit/doc synchronization.
- **Residual classification:** user convergence/bake-back and golden refresh remain intentionally deferred to Task 1805; no golden baseline was regenerated.
- **Lane outcome:** parent-authorized move from `02-doing` to `03-review` completed; current path is `docs/tasks/03-review/1807-warp-prism-token-override-theme-editor.md`.

## 🔍 Review Trail

### Independent final re-review — 2026-08-23 (Builder-side independent reviewer)

- **Score**: `100/100`
- **Verdict**: `ACCEPTED` (`ACCEPTED_100`)
- **Evidence**: Package canonical analyzer gate `217 infos / 0 errors`, Observatory `124 infos / 0 errors`, scoped suite `157/157`, final Theme Editor suite `8/8`, Catalog `10/10`, CyberCore analyzer clean, boundary harness `7/7`, and consumer mutation/reset default-color proof all pass. The three Observatory const contexts and public operational-state extension export are repaired. Per-role copy-hex and explicit 48dp semantic targets are present and directly asserted.
- **Golden policy**: 59 golden failures are expected interim drift under Task 1800 §7; zero baselines regenerated, matching accepted Task 1801 evidence. Golden refresh belongs to Task 1805 after human approval.
- **Lane outcome**: Promoted to `docs/tasks/03-review/`.


## Review/Fix Ledger — 2026-08-24 Wave 4 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fcde09181ffeGKqYbxb1MEOLp4`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent


## Final Review Disposition

- **Verdict**: **BLOCKED-1805 (technical PASS 94/100)** — implementation affirmed fresh; bake-back exit requires user convergence declaration; post-bake golden verification under 1805 freeze. Unblocks on: 1805 human visual sign-off.
- **Reviewer**: W1 wave 2026-09-02 (read-only).
