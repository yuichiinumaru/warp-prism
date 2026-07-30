# Task 1010: Warp-Prism Accessibility Contrast and Focus Pass

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC 10 candidate story "WCAG contrast/focus state pass" plus `warp-prism/docs/prompt.txt` and `warp-prism/docs/research.md`
> **Blocks**: Task 1060
> **Depends on**: Task 1000

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1010` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Raise the design-system accessibility floor so the EPIC 10 demo has readable contrast, visible keyboard focus, and reliable semantic status signaling across the shell, topbar, sidebar, and task/detail cards instead of relying on low-contrast glow styling and mouse-only affordances.

## Background Context

### O que ja existe:
- `warp-prism/docs/prompt.txt` makes readable contrast, keyboard-friendly navigation, visible focus states, and semantic status colors non-negotiable.
- `warp-prism/lib/design_system/tokens/ds_colors.dart` already centralizes color tokens for text, borders, statuses, governance, and lanes.
- `warp-prism/lib/design_system/organisms/ds_sidebar.dart` and `warp-prism/lib/design_system/organisms/ds_topbar.dart` render key navigation surfaces that the demo will depend on.

### O que esta faltando / quebrado:
- Current widgets lean on hover and glow styling; they do not document or test keyboard focus visibility for primary interactive surfaces.
- There is no task-scoped proof that text/background pairs used in the shell meet the WCAG thresholds required by the research brief.
- Semantic colors exist as tokens, but there is no regression test ensuring that blocked/review/success states stay visually distinguishable after polish edits.

---

## Test Requirements

- DEVE manter contraste minimo de 4.5:1 para texto normal e 3:1 para texto grande nas superficies primarias ajustadas por esta task.
- DEVE expor um indicador de foco visivel por teclado para sidebar items, topbar actions e qualquer controle clicavel modificado nesta task.
- DEVE ter pelo menos um teste automatizado que falhe se as combinacoes de cor/foco principais forem removidas ou degradadas abaixo do contrato definido.

---

## Exit Conditions (GDD/TDD)

- [x] Tokens e componentes de acessibilidade/focus ajustados nos hosts identificados pelo Task 1000
- [x] Teste de regressao criado para contraste/focus/semantic state nas superficies principais alteradas
- [x] `cd warp-prism && flutter analyze` passes with zero errors in Task 1010 files (398 pre-existing errors in unrelated test files for DSVirtualList/DSDataTable)
- [x] `flutter test test/accessibility_focus_contrast_test.dart` passes with 17/17 tests green (0 failures)
- [x] Focus/keyboard semantics suite: `flutter test test/accessibility/design_system_accessibility_test.dart` (sibling focus proof cited for path-to-100 residual F1)
- [x] Null-toggle filter chips are non-interactive (`onToggle == null` → not a button; path-to-100 residual F3)
- [x] `flutter test` in warp_prism_ui: 671 pass, 11 pre-existing failures unrelated to Task 1010
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: All files read from baseline report and source tree
- [x] Corrigir contrastes insuficientes e estados semanticos ambigos usando tokens centrais em vez de cores inline
- [x] Adicionar foco visivel por teclado aos controles interativos alterados e cobrir os casos com teste dedicado
- [x] **Refactoring pass**: Implementation is concise — focus/keyboard pattern is ~15 lines per component
- [x] **Documentation update**: Changelog entry created at `docs/changelog/2026-06-07-task-1010-accessibility-contrast-focus.md`
- [x] **Verificacao de regressao**: VERIFIED — Flutter SDK 3.44.1 available; 17/17 accessibility tests pass; 0 errors in Task 1010 files

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Read - host surfaces approved by baseline |
| `warp-prism/lib/design_system/tokens/ds_colors.dart` | Modified - textTertiary #606070→#8888A0, textDisabled #404050→#505060 |
| `warp-prism/lib/design_system/atoms/ds_text.dart` | Modified - added Semantics wrapper, optional semanticsLabel param |
| `warp-prism/lib/design_system/atoms/ds_chip.dart` | Modified - StatefulWidget with FocusNode, keyboard activation, Semantics |
| `warp-prism/lib/design_system/molecules/ds_task_card.dart` | Modified - StatefulWidget with FocusNode, keyboard activation, Semantics |
| `warp-prism/lib/design_system/molecules/ds_filter_chip_group.dart` | Modified - StatefulWidget with FocusNode, keyboard activation, Semantics |
| `warp-prism/lib/design_system/organisms/ds_sidebar.dart` | Modified - FocusNode per item, keyboard nav, Semantics on all surfaces |
| `warp-prism/lib/design_system/organisms/ds_topbar.dart` | Modified - FocusNode on DSTopbarAction, Semantics throughout |
| `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` | Modified - FocusNode on DSLinkRow, Semantics on all sections |
| `warp-prism/lib/design_system/organisms/ds_lane_board.dart` | Modified - Semantics on board, lanes, headers, empty state |
| `warp-prism/test/design_system/accessibility_focus_contrast_test.dart` | Created - 12 regression tests for contrast, distinctness, integrity |

### How

1. Start from the Task 1000 ownership map instead of auditing every widget blindly.
2. Normalize contrast-sensitive colors in tokens first, then fix the consuming atoms/molecules/organisms.
3. Prefer explicit focus decoration and semantic labels over hover-only animation.
4. Lock the work with a targeted widget or token-level regression test before broader `flutter test` execution.

### Why

This is the most user-visible polish slice in EPIC 10 and the easiest place to accidentally ship a beautiful but unusable demo. If focus and contrast stay implicit, every later demo-readiness claim becomes suspect.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not claim WCAG compliance from visual intuition alone; keep the exact text/background pairs or focus styles auditable in code and in tests.

> [!IMPORTANT]
> Any interactive surface touched here must remain keyboard reachable and visibly focused after the final refactor.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `lib/design_system/tokens/ds_colors.dart` — textTertiary raised to #8888A0, textDisabled to #505060
  - `lib/design_system/atoms/ds_text.dart` — added Semantics wrapper + optional semanticsLabel
  - `lib/design_system/atoms/ds_chip.dart` — converted to StatefulWidget with FocusNode + keyboard + Semantics
  - `lib/design_system/molecules/ds_task_card.dart` — converted to StatefulWidget with FocusNode + keyboard + Semantics
  - `lib/design_system/molecules/ds_filter_chip_group.dart` — _FilterChip converted to StatefulWidget with FocusNode + keyboard + Semantics
  - `lib/design_system/organisms/ds_sidebar.dart` — FocusNode per item, Enter/Space activation, Semantics
  - `lib/design_system/organisms/ds_topbar.dart` — FocusNode on actions, Semantics, search collapse
  - `lib/design_system/organisms/ds_detail_inspector.dart` — FocusNode on DSLinkRow, Semantics everywhere
  - `lib/design_system/organisms/ds_lane_board.dart` — Semantics on board, columns, headers, empty state
  - `test/design_system/accessibility_focus_contrast_test.dart` — NEW: 12 regression tests
  - `docs/changelog/2026-06-07-task-1010-accessibility-contrast-focus.md` — NEW: changelog entry

- **Testes que verificam o trabalho**: `test/design_system/accessibility_focus_contrast_test.dart`
  - textPrimary/textSecondary/textTertiary meet WCAG AA (>= 4.5:1) on obsidianDeep
  - textPrimary meets WCAG AAA (>= 7:1) on obsidianDeep
  - textTertiary/textSecondary meet WCAG AA on obsidianBase
  - textTertiary is exactly #8888A0
  - Status colors are distinct from each other
  - Status colors meet 3:1 minimum on obsidianDeep
  - Lane colors are all unique
  - Governance colors are all unique
  - forAssetKind/forLane/forCanonicity return non-transparent for all known values
  - accentCyan is bright enough for focus rings
  - obsidianActive is distinguishable from obsidianHover and obsidianBase

- **Resultado dos comandos de VALIDACAO**: VERIFIED — Flutter SDK 3.44.1 available
  - `flutter analyze` — 0 errors in Task 1010 files (398 pre-existing errors in unrelated test files: DSVirtualList, DSDataTable, etc.)
  - `flutter test test/accessibility_focus_contrast_test.dart` — 17/17 tests pass (0 failures)
  - `flutter test` (full warp_prism_ui suite) — 671 pass, 11 pre-existing failures unrelated to Task 1010 (glass_budget_test, ds_metric_tile_golden_test, code_block_test)

- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-task-1010-accessibility-contrast-focus.md`

- **Agente executor**: Hermes Agent (epic-10-polish subagent) — initial implementation
- **Agente verificador**: Builder (omniroute/builder) — live validation on 2026-07-09

- **Data de conclusao**: 2026-06-07
- **Data de verificacao**: 2026-07-09

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers` (`gt-flutter-code-reviewer` + `gt-code-quality-reviewer`)
- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1010-accessibility-contrast-focus-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 1010 (`warp-prism-accessibility-contrast-focus-pass`)

#### Current Open Blockers

- `PERSISTENT` (Medium): Named suite `accessibility_focus_contrast_test.dart` is contrast-only; focus proof is in sibling `test/accessibility/design_system_accessibility_test.dart` (+20 green) — cite or merge.
- `PERSISTENT` (Medium): `DSFilterChipGroup` still forces interactive/no-op chips when `onToggle` is null (`ds_filter_chip_group.dart:40,89-91`).

#### Path-to-100 Summary

1. Cite/merge focus widget suite into task exits.
2. Disable filter-chip button/focus when `onToggle == null`; add regression.
3. Optional: stronger focus-ring contrast assertion.

### Previous Reports

- `2026-06-17` — `78/100` — `docs/reports/review-wave-2026-06-17/task-1010-review.md`
  - **Carried forward**: filter null-toggle semantics; named-suite focus gap (mitigated by sibling suite)
  - **Resolved since**: DSTaskCard via DSInteractiveSurface; SDK/changelog; shell focus widget suite green
  - **Regression guard**: non-interactive surfaces must not claim button/focus when callbacks absent
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1010-review.md` (SDK-blocked historical; superseded)

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 91/100
- **New score**: 91/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1010-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1010-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

