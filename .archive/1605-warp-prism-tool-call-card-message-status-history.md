# Task 1605: PrismToolCallCard + PrismMessageStatusHistory

> **Status**: `[x]` Completed (independent drain 2026-07-17)
> **Review State**: `Ready For Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft)
> **Depends on**: Task 1600
>
> **Soft depends**: Task 1604 (`PrismAgentTranscript`) — preferred so tool cards and status
> strips can be shown inside a transcript gallery case; if 1604 is not ready, ship
> standalone gallery cases for both widgets and note composition deferred.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1605` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement two companion organisms for the agent transcript family:

1. **`PrismToolCallCard`** — tool name, args summary, result/error body, expand/collapse.
2. **`PrismMessageStatusHistory`** — compact status step strip (pipeline stages).

Fixture-first; public `Prism*` + internal `DS*` + aliases; minimal gallery cases.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Public names** | `PrismToolCallCard`, `PrismMessageStatusHistory` |
| **Internal** | `DSToolCallCard`, `DSMessageStatusHistory` + typedefs |
| **Harvest IDs** | **C-04**, **C-05** |
| **Origin** | DeepChat tool blocks; Open WebUI status pipeline |
| **Wave** | **K** |
| **Action type** | `NEW` (pack of two) |

### What already exists

- Code block, markdown renderer, badges, status dots, operational state tokens.
- Task 1604 transcript (soft host).

### What is missing or broken

- No tool-call card organism for agent tool invocations.
- No compact multi-step message status history strip.

### False-gap notes

- Do **not** execute tools or call MCP from the UI package.
- Do **not** build full TraceDialog / subagent task tree product.
- Do **not** duplicate `DSLogViewer` as a tool card.

---

## Test Requirements

- **ToolCallCard**: render name + args + result; collapsed vs expanded; error state fixture.
- **MessageStatusHistory**: render ordered steps with state (pending/running/success/error); empty steps safe.
- Widget tests for both components (happy + empty + error).
- A11y: expandable tool card control labeled; status steps list semantics.
- Gallery: standalone cases; optional embedded in transcript if 1604 delivered.
- Boundaries 6/6 after aliases.

---

## Exit Conditions

- [x] Both public names exported via aliases + organisms barrel.
- [x] Widget tests + minimal gallery for both PASS.
- [x] No live tool execution; fixtures only.
- [x] Analyze + scoped tests PASS; boundaries **6/6**.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session synthesis + references triage (DeepChat tool blocks / Open WebUI StatusHistory), Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_badge.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_status_dot.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, and `packages/warp_prism_ui/lib/src/organisms/agent_transcript/` if Task 1604 landed.
- [x] Implement `DSToolCallCard` model + widget.
- [x] Implement `DSMessageStatusHistory` step model + strip widget.
- [x] Export both aliases; tests; gallery cases.
- [x] Optionally compose into transcript gallery if 1604 available.
- [x] **Simplicity pass**: no subagent trees; no network.
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/tool_call_card/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/tool_call_card/ds_tool_call_card.dart` | Create |
| `packages/warp_prism_ui/lib/src/organisms/message_status_history/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/message_status_history/ds_message_status_history.dart` | Create |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/tool_call_card/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/message_status_history/` | Create — tests |
| `docs/changelog/` | Create — changelog |

### How

1. Tool card: glass panel + header chip + expandable body (args/result as monospace or code block).
2. Status history: horizontal or vertical compact steps with status dots.
3. Export/test/gallery; optional transcript embedding.

### Why

Typed tool-call and status pipeline chrome are the highest-signal DeepChat/Open WebUI harvests for agent UX after the base transcript.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> No tool execution. No live MCP. Fixtures only.

> [!IMPORTANT]
> Soft dependency on 1604 only — do not hard-block if transcript not ready.

> [!WARNING]
> ADS-first. Do not rebrand teal. Do not recreate EPIC-15 HUD set.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/tool_call_card/
flutter test test/organisms/message_status_history/

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/tool_call_card/ds_tool_call_card.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/tool_call_card/tool_call_card.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/message_status_history/ds_message_status_history.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/message_status_history/message_status_history.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (exports)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (aliases)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (standalone + composed demos)
  - Created `packages/warp_prism_ui/test/organisms/tool_call_card/ds_tool_call_card_test.dart`
  - Created `packages/warp_prism_ui/test/organisms/message_status_history/ds_message_status_history_test.dart`
  - Created `docs/changelog/2026-07-11-task-1605-tool-call-card-message-status-history.md`
- **Public API names verified**: `PrismToolCallCard`, `PrismToolCallData`, `PrismToolCallStatus`, `PrismMessageStatusHistory`, `PrismMessageStatusStep`, `PrismMessageStatusStepState`
- **Tests or validation commands**:
  - `dart analyze` (scoped tool_call_card / message_status_history / aliases / gallery / tests) → **PASS** (no errors/warnings)
  - `flutter test test/organisms/tool_call_card/` + `test/organisms/message_status_history/` → **22/22 PASS**
- **Boundary harness**: **6/6 PASS** (`dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`)
- **Local changelog entry**: `docs/changelog/2026-07-11-task-1605-tool-call-card-message-status-history.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (builders)
- **Completion date**: 2026-07-11
- **Lane**: stays `02-doing/` (Ready For Review; no git; no auto-promote to `03-review/`)

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review — drain 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Score**: `93/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1605-drain-review.md`
- **Lane outcome**: moved `03-review/` → `04-completed/`
- **Task reference**: Task 1605
- **Top residual**: format debt on tool_call + status history; composition gallery verified

#### Path-to-100 residuals (non-blocking for S≥90 closeout)

- See full report Path To 100. Shared: `dart format` on EPIC-16 organism/test/golden surfaces.
- Package-wide analyzer infos (141) are residual package hygiene, not scoped-task exit failures.

### Previous Latest Review

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness)
- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review/1605-tool-call-status-history-quality-gate-2026-07-16.md`
- **Lane outcome**: `returned to doing` (move `docs/tasks/03-review/` → `docs/tasks/02-doing/`)
- **Task reference**: Task 1605 (`1605-warp-prism-tool-call-card-message-status-history`)

#### Current Open Blockers

- `PERSISTENT` — **`AI-141`**: `dart analyze lib test` reports 141 info-level issues in `warp_prism_ui`. Scope surfaces clean; full-package analyzer violates Axiom 1. Shared blocker across Tasks 1604–1607.
- `PERSISTENT` — **`I1`**: expand a11y body discovery polish (optional).

#### Path-to-100 Summary

- Clear full-package analyzer (141 → 0).
- Optional: extend expand announcement with body visibility hint; shared fixture catalog file.

### Previous Reports

- `2026-07-11` — `96/100` — `docs/reports/review-wave-2026-07-11/task-1605-independent-review.md`
  - **Carried forward**: `I1` (expand-semantics body discovery optional)
  - **Resolved since**: none
  - **Regression guard**: AI-141 was accepted at 96 in prior review; now flagged as persistent blocker
