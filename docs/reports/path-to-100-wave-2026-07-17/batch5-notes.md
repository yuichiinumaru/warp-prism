# Path-to-100 Wave 2026-07-17 — Batch 5 Notes

> **Date**: 2026-07-18  
> **Executor**: builders (parent agentID=builders)  
> **Focus**: gallery, goldens, format dirt, a11y `hasFlag`, touch-target tests, organism polish  
> **Lane policy**: remain `docs/tasks/03-review/` — no git / no tasklist  
> **Tasks**: 1304, 1305, 1306, 1307, 1309, 1404, 1405, 1407, 1500, 1501, 1502, 1503, 1516, 1518, 1519, 1520

## Summary table

| Task | residual_fixed | exits | remaining |
| --- | --- | --- | --- |
| **1304** | Confirmed gallery gates still green; no code change required for task-scope residuals | gallery analyze 0; gallery suite green (host+registry) | package-wide INFO burn-down EXTERNAL |
| **1305** | Catalog host scroll smoke for late EPIC-15 ops/terminal + Prism labels | catalog `widget_test` **+10 PASS**; analyze clean | matrices representative≠exhaustive 1106 (accepted) |
| **1306** | Status-dot golden matrix enum-driven from `DSOperationalState.values` (named-ctor map, pixel-stable) | `ds_status_dot_golden_test` PASS (19 cases + grid) | none task-scope |
| **1307** | `hasFlag`→`flagsCollection`; AssetCard `isEnabled`; SemanticsHandle dispose | a11y suite **+20 PASS** | none task-scope |
| **1309** | Action-button ≥48×48 size assertion (`OutlinedButton`) | `state_surface_test` **+56 PASS** | none task-scope |
| **1404** | Confirmed redundant `governance_diagnostics` import already gone | `dart analyze lib/features/overview/` **No issues** | none task-scope |
| **1405** | Const-literal cleanups in `extended_detail_variants_test.dart` | analyze **No issues** (was 4 INFO) | none task-scope |
| **1407** | Audit §0 re-proof footnote (+778 live currency) | audit note updated; method/classifications intact | none |
| **1500** | Froze proposed O-28 name `PrismRiskAlertToastVariant` in brief master table | brief O-28 row updated | Wave I optional still deferred |
| **1501** | StatefulWidget stage-survival mount-count across hide/restore | map_hud tests PASS (incl. survival) | exclusive controller w/ 1502 deferred |
| **1502** | Format dirty closed; controlled `activeToolId→null` collapse test | tool_strip **11/11 PASS**; format clean | shared exclusive controller deferred |
| **1503** | Format dirty closed on organism+test | layer_control **12/12 PASS**; format clean | optional monolith split (info) |
| **1516** | Copy button `minimumSize(48,48)` + size test; format clean | share card tests PASS; format clean | none task-scope |
| **1518** | Format dirty closed on agent_shell_panel lib+test | agent_shell **8/8 PASS**; format clean | none task-scope |
| **1519** | Gallery + catalog host ListView scroll to ops/terminal + Prism labels | gallery PASS; catalog **+10 PASS** | container region semantics not exhaustive (info) |
| **1520** | Format three EPIC-15 golden test sources | 3/3 goldens PASS; format clean | none task-scope |

## Code / proof surfaces touched

### Format (1502/1503/1516/1518/1520)
- `packages/warp_prism_ui/lib/src/organisms/{tool_strip_slideout,layer_control_panel,view_presets,workspace_share_card,agent_shell_panel}/`
- Matching organism tests
- `test/goldens/prism_{map_hud_workspace,entity_intel_panel,osint_workbench}_golden_test.dart`
- Format probe: `dart format --output=none --set-exit-if-changed …` → **0 changed / EXIT 0**

### A11y / touch targets (1307/1309/1516)
- `test/accessibility/design_system_accessibility_test.dart` — `flagsCollection` migration
- `test/state_surface_test.dart` — action button size ≥48
- `lib/.../workspace_share_card/ds_workspace_share_card.dart` — `minimumSize: Size(48,48)`
- `test/organisms/workspace_share_card/workspace_share_card_test.dart` — size assert

### Organism polish (1501/1502)
- Map HUD stage survival StatefulWidget probe
- Tool strip controlled collapse via prop rebuild

### Gallery / goldens (1305/1306/1519/1520)
- Gallery host scroll + catalog host scroll for late EPIC-15 sections
- Status-dot matrix derived from enum
- EPIC-15 golden format closed

### Observatory (1404/1405/1407)
- Overview analyze clean (import residual already closed)
- Asset-detail test const INFO closed
- Retirement audit count-currency footnote

### Brief (1500)
- `docs/reports/epic-15-organism-contract-brief-2026-07-10.md` O-28 proposed name freeze

## Live verification (batch5)

| Suite | Result |
| --- | --- |
| a11y + gallery + status-dot + EPIC-15 goldens + tool_strip | **All tests passed** (`+77`) |
| catalog `test/widget_test.dart` | **+10 All tests passed** |
| state_surface / map_hud / share_card / layer / agent_shell / view_presets | **PASS** (prior batch run) |
| overview analyze + extended_detail analyze | **No issues found** |
| scoped format probe (organisms + EPIC-15 goldens) | **EXIT 0** |

## Lane action

**All 16 tasks remain in `docs/tasks/03-review/`.**  
No git operations. No tasklist mutations. Residual closure notes appended to each task file under `### 2026-07-18 — builders path-to-100 residual batch5`.
