# Task 1608: PrismMcpCapabilityInspector Organism

> **Review State**: `HELD_IN_REVIEW_PATH_TO_100`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft)
> **Depends on**: Task 1600
>
> **Soft**: Task 1602 (PageShell) / Task 1603 (Tree) for richer gallery demos; not hard.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1608` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement **`PrismMcpCapabilityInspector`** — capability-gated inspector for MCP tools/resources/prompts (and optional ping/roots stubs) with tab or section strip and detail list. Fixture-first; read-only (no live MCP protocol client in ADS package). Public `Prism*` + `DS*` + alias; minimal gallery case.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismMcpCapabilityInspector` |
| **Internal** | `DSMcpCapabilityInspector` + typedef |
| **Harvest ID** | **C-08** |
| **Origin** | CyberCore MCP inspector; capability-gated tabs |
| **Wave** | **L** |
| **Action type** | `NEW` |

### What already exists

- Tab bar, split pane, detail inspector, data table, search bar.
- No MCP-specific capability inspector organism.

### What is missing or broken

- No capability-gated multi-pane MCP inspector contract in ADS.

### False-gap notes

- Do **not** implement real MCP JSON-RPC client inside `warp_prism_ui`.
- Do **not** add network permissions or live server discovery.
- Do **not** mutate remote tools (ALLOW/BLOCK mutation UIs are epic skips).

### Composition notes

- Compose `DSTabBar` / `DSTabView` for capability sections.
- Compose list + detail (table or simple list + inspector).
- Optional tree for tool hierarchy if 1603 present (not required).

---

## Test Requirements

- MUST render fixture capabilities with at least `tools` and `resources` sections (prompts recommended).
- MUST hide or disable sections not present in fixture capability set (capability-gating).
- MUST support selection of a tool/resource row showing detail metadata.
- Widget tests: gated tabs, selection, empty capability set.
- A11y: tabs and lists labeled.
- Gallery fixtures only — no live MCP.

---

## Exit Conditions

- [x] `PrismMcpCapabilityInspector` exported.
- [x] Tests + minimal gallery PASS.
- [x] No MCP network client in package; fixtures only.
- [x] Analyze + scoped tests PASS; boundaries **6/6** after barrel/alias.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session synthesis + references triage (CyberCore MCP inspector), Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_bar.dart`, `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_view.dart`, `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart`, `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart`, `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define fixture models for tools/resources/prompts + capability flags.
- [x] Implement inspector with gated sections and detail pane.
- [x] Export alias; tests; gallery.
- [x] **Simplicity pass**: read-only inspect; no invoke/mutate buttons that imply live side effects (disabled “invoke” chrome with fixture result OK if clearly mock).
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/mcp_capability_inspector/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/mcp_capability_inspector/ds_mcp_capability_inspector.dart` | Create |
| `packages/warp_prism_ui/lib/src/organisms/tab_bar/` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/mcp_capability_inspector/` | Create — tests |
| `docs/changelog/` | Create — changelog |

### How

1. Capability flags drive visible tabs.
2. List + detail for selected item from fixtures.
3. Export/test/gallery/boundaries.

### Why

MCP inspect is first-class CyberCore admin surface and GOLD in harvest; fixture-first ADS component unblocks pilot UI without backend coupling.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> No live MCP protocol. No mutation ALLOW/BLOCK panels. Fixtures only.

> [!IMPORTANT]
> Package purity: no riverpod/go_router in UI package. No API keys.

> [!WARNING]
> ADS-first. Do not rewrite CyberCore app routes for task exit (optional later).

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/mcp_capability_inspector/

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/mcp_capability_inspector/ds_mcp_capability_inspector.dart` (create)
  - `packages/warp_prism_ui/lib/src/organisms/mcp_capability_inspector/mcp_capability_inspector.dart` (create)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export append)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (aliases + fixture helpers)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (gallery case)
  - `packages/warp_prism_ui/test/organisms/mcp_capability_inspector/ds_mcp_capability_inspector_test.dart` (create)
  - `docs/changelog/2026-07-11-task-1608-mcp-capability-inspector-organism.md` (create)
- **Public API name verified**: `PrismMcpCapabilityInspector` via `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart` typedef → `DSMcpCapabilityInspector`
- **Tests or validation commands**:
  - `dart analyze lib/src/organisms/mcp_capability_inspector lib/src/prism_aliases.dart lib/src/organisms/organisms.dart test/organisms/mcp_capability_inspector` → **No issues found** (exit 0)
  - `flutter test test/organisms/mcp_capability_inspector/` → **11/11 PASS** (exit 0)
- **Boundary harness**: `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **6/6 PASS** (exit 0)
- **Local changelog entry**: `docs/changelog/2026-07-11-task-1608-mcp-capability-inspector-organism.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer
- **Completion date**: 2026-07-11
- **Lane note**: Remains in `02-doing/` per SHARED append-only instruction; Review State = Ready For Review

---

## Review Ledger

### Latest Review — drain 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Score**: `93/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1608-drain-review.md`
- **Lane outcome**: moved `03-review/` → `04-completed/`
- **Task reference**: Task 1608
- **Top residual**: format debt; MCP TabController lifecycle OK

#### Path-to-100 residuals (non-blocking for S≥90 closeout)

- See full report Path To 100. Shared: `dart format` on EPIC-16 organism/test/golden surfaces.
- Package-wide analyzer infos (141) are residual package hygiene, not scoped-task exit failures.

### Previous Latest Review
- **Date**: 2026-07-11
- **Reviewer profile**: `reviewers` (`gt-flutter-code-reviewer` + `code-quality-harness` + `flutter-harness`)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-11/task-1608-independent-review.md`
- **Live prove**: analyze clean; scoped organism tests PASS; boundary harness **6/6 PASS**
- **Lane outcome**: moved `02-doing/` → `03-review/` (never `04-completed/`)
- **Policy**: independent initial review; no git / no tasklist


---

## Review Ledger — 2026-07-18 Path-to-100 Re-review (Batch R6)

| Field | Value |
| --- | --- |
| **Date** | 2026-07-18 |
| **Reviewer** | independent `reviewers` (parent agentID=reviewers) |
| **Harnesses** | code-quality-harness + flutter-harness |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_100 |
| **Path-to-100 applied** | YES |
| **Lane** | → `04-completed/` |
| **Full report** | `docs/reports/review-wave-2026-07-18/task-1608-path100-rereview.md` |
| **Top finding** | none — format residual closed |
| **Exits** | PASS |
| **Live gates** | format 0; analyze 0; organism/gallery/goldens PASS; boundaries 7/7 |

