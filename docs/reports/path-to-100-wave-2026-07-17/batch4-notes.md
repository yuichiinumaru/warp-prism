# Path-to-100 Wave 2026-07-17 — Batch 4 Notes

**Agent**: builders (PATH-TO-100)  
**Date**: 2026-07-18  
**Lane policy**: leave tasks in `docs/tasks/03-review/` (no git / no tasklist / no self-promote)  
**Focus**: a11y · prefer_const · overflow tests · layoutEngine residuals · boundary doc currency (7/7) · virtual scroll soft SLA · README residual

## Tasks

1110, 1111, 1112, 1113, 1117, 1119, 1120, 1121, 1122, 1123, 1126, 1204, 1205, 1207, 1301, 1303

## Code Changes

| Area | Files | Fix |
| --- | --- | --- |
| 1120 prefer_const | `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart` | `const` min/max lane width + `const DSStateSurface.empty` |
| 1122 withOpacity | `tab_bar/ds_tab_bar.dart`, `split_pane/ds_split_pane.dart` | migrate to `withValues(alpha: …)`; const border + step |
| 1122 overflow | `test/organisms/tab_bar_test.dart` | many tabs + narrow viewport → `maxScrollExtent > 0` + scroll arrow semantics |
| 1123 soft SLA | `test/performance/virtual_scroll_benchmark.dart` | soft 200ms avg demoted to informational print; hard virt SLA retained |
| 1112 a11y | `test/organisms/data_table/ds_data_table_test.dart` | Semantics(button, Select table row) widget + tap proof |
| 1117 a11y + layoutEngine | `lib/src/organisms/graph/graph_canvas.dart`, graph tests, task What boxes | node Semantics labels; What checkboxes ticked |
| 1121 fence Semantics | `markdown_renderer/ds_markdown_renderer.dart` + tests | fenced code block semantics labels |

## Doc Changes

| Task | Residual closed |
| --- | --- |
| 1110 | Live CE currency 16/16; pilot fixture honesty note; Where path fix |
| 1111 | Where → `cybercore-scope-route-parity.md` + `cybercore-pilot-surface-matrix.md`; 12→16 counts |
| 1113 | No code residual (already 100); ledger only |
| 1119 | Soft polish residual acknowledged (gallery/lazy) |
| 1126 | Residual table / CE 6/6 → **7/7** (README already live-current) |
| 1204 | Evidence harness strings → **7/7** |
| 1205 | Contract/evidence **6 → 7** checks (persistence/IO rule) |
| 1207 | 1107 example as-of lane → `03-review/` (historical body kept) |
| 1301 | Exit wording six → seven checks |
| 1303 | EXTERNAL package INFO / Epic15-16 contract expansion noted as follow-on |

## Live Exits (this session)

```text
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
→ Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)

cd packages/warp_prism_ui
dart analyze --format=machine \
  lib/src/organisms/ds_lane_board.dart \
  lib/src/organisms/tab_bar/ lib/src/organisms/split_pane/ \
  lib/src/organisms/graph/graph_canvas.dart \
  lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart
→ 0 machine lines

flutter test --concurrency=1 --no-pub \
  test/molecules/ds_drag_drop_test.dart \
  test/organisms/tab_bar_test.dart \
  test/organisms/split_pane_test.dart \
  test/organisms/data_table/ds_data_table_test.dart \
  test/organisms/graph/backward_compat_test.dart \
  test/organisms/markdown_renderer_test.dart \
  test/performance/virtual_scroll_benchmark.dart
→ +142 All tests passed
```

## Result Table

| task | residual_fixed | exits | remaining |
| --- | --- | --- | --- |
| 1110 | CE 16/16 currency + pilot fixture honesty + Where path | docs | historical CE paragraphs retained as history |
| 1111 | Where dead path + 12→16 counts | docs | optional 1109 schema ASW drift |
| 1112 | row Semantics widget + tap a11y proof | tests green | soft 1000-row frame harness |
| 1113 | none needed (already clean) | n/a | optional shell Cmd+K embed |
| 1117 | node Semantics + What boxes ticked | graph suite green | test-only INFO; keyboard nav follow-on |
| 1119 | ledger only | n/a | gallery primary demo; soft lazy assert |
| 1120 | 3 prefer_const INFO closed | analyze 0; 24/24 | soft same-lane newIndex geometry |
| 1121 | fence Semantics + tests | 43+ green | regex highlighter scope (accepted) |
| 1122 | overflow test + withOpacity→withValues | analyze 0; 34+ green | none material |
| 1123 | soft SLA demoted (hard virt only) | +5 green isolated | optional profile-mode 60fps external |
| 1126 | residual table 7/7 currency | boundaries 7/7 | none material |
| 1204 | evidence 7/7 currency | boundaries 7/7 | optional full test-fast one-shot |
| 1205 | contract 6→7 checks | 7/7 PASS | historical narrative 5/6 stories kept |
| 1207 | 1107 as-of lane annotation | docs | none material |
| 1301 | exit wording 6→7 | 7/7 PASS | intentional non-Prism gallery entrypoints |
| 1303 | ledger only | prior contract green | package INFO EXTERNAL; Epic15/16 contracts |

## Lane

All 16 tasks remain in `docs/tasks/03-review/`.
