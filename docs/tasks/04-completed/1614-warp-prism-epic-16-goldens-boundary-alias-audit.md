# Task 1614: EPIC-16 Goldens + Boundary Alias Audit

> **Review State**: `PASS — independent builder review 100/100 (2026-07-16)`
> **Priority**: 🟡 P1
> **Type**: `testing`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1615
> **Depends on**: Task 1613
>
> **Scope note**: Goldens cover **delivered** EPIC-16 organisms at execution time
> (minimum: content chrome + agent transcript + CyberCore ops families from 1602–1609).
> Wave M (1610–1611) goldens optional same-pass if landed; else follow-up.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1614` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Add **default-state golden baselines** for key EPIC-16 organism families and run a **boundary + Prism alias audit** so public contract remains clean (no DS* leakage to consumers; boundaries 6/6).

### Golden families (minimum)

1. Content chrome — `PrismPageShell` **or** `PrismTree` default state
2. Agent transcript family — `PrismAgentTranscript` **or** `PrismToolCallCard` default
3. CyberCore ops — `PrismProviderHealthMatrix` **or** `PrismMcpCapabilityInspector` / traffic pack member

Plus alias audit for all new EPIC-16 `Prism*` exports.

## Background Context

### What already exists

- Golden MVP under `packages/warp_prism_ui/test/goldens/` (Task 1306 pattern).
- Boundary harness + `melos run test-boundaries`.
- Gallery registration from Task 1613.

### What is missing or broken

- No goldens for EPIC-16 organism families.
- Alias/barrel may drift after parallel organism landings.

---

## Test Requirements

- At least **3** new golden tests for EPIC-16 default states (chrome + transcript + ops).
- Goldens MUST use fixed surface sizes and deterministic fixtures (careful `pumpAndSettle`).
- Alias audit MUST list every new public `Prism*` for EPIC-16 and confirm barrel import path.
- Boundary tests MUST remain **6/6 PASS**.
- No MapLibre/Recharts/network in golden pumps.
- No Observatory teal hardcode requirement (goldens use default WP theme).

---

## Exit Conditions

- [x] ≥3 EPIC-16 golden tests + committed PNG baselines under `packages/warp_prism_ui/test/goldens/`.
- [x] `flutter test` on new golden files PASS (or documented environment skip — prefer pass).
- [x] Alias/barrel audit note in Completion Evidence (table Prism → implementation).
- [x] `melos run test-boundaries` → **6/6 PASS** (live harness **7/7 PASS**).
- [x] `dart analyze` clean of errors on touched paths.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui/test/goldens/` (existing golden tests for patterns), `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/test/boundaries/`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, EPIC-16 acceptance criteria, Task 1613 matrix if present, and the three target organism implementations.
- [x] Add golden tests for chrome + transcript + ops default states.
- [x] Generate and commit golden PNGs.
- [x] Run boundary harness; fix alias/barrel regressions only as needed.
- [x] Produce alias audit table in Completion Evidence.
- [x] **Simplicity pass**: default state only; no full state-matrix goldens.
- [x] **Regression verification**: goldens + boundaries + analyze.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/goldens/` | Create — new golden tests + PNGs |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read/Modify — alias fixes if gaps |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — public surface |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Read — exports |
| `packages/warp_prism_ui/test/boundaries/` | Read — harness |
| `docs/changelog/` | Create — changelog |

### How

1. Copy pattern from existing golden tests (fixed size, theme wrap).
2. Pump default fixtures for three families.
3. Audit aliases for all EPIC-16 public names present.
4. Boundaries 6/6.

### Why

Without goldens and alias audit, parallel EPIC-16 landings risk silent visual drift and DS* leakage.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete without golden files + boundary evidence.

> [!IMPORTANT]
> No MapLibre/Recharts. No teal rebrand goldens as Observatory default.

> [!WARNING]
> Prefer default-state only. Do not block on optional 1616 skin goldens.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/goldens/
# Prefer scoped new files if naming is clear, e.g.:
# flutter test test/goldens/prism_page_shell_golden_test.dart

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created: `packages/warp_prism_ui/test/goldens/prism_page_shell_golden_test.dart`
  - Created: `packages/warp_prism_ui/test/goldens/prism_agent_transcript_golden_test.dart`
  - Created: `packages/warp_prism_ui/test/goldens/prism_provider_health_matrix_golden_test.dart`
  - Created: `packages/warp_prism_ui/test/goldens/goldens/prism_page_shell_default.png`
  - Created: `packages/warp_prism_ui/test/goldens/goldens/prism_agent_transcript_default.png`
  - Created: `packages/warp_prism_ui/test/goldens/goldens/prism_provider_health_matrix_default.png`
  - Created: `docs/changelog/2026-07-16-task-1614-epic-16-goldens-boundary-alias-audit.md`
  - Read-only (no alias/barrel edits needed): `prism_aliases.dart`, `warp_prism_ui.dart`, `organisms.dart`, boundary harness

- **Golden families**:
  1. Content chrome — `PrismPageShell` default (800×480, Providers fixture)
  2. Agent transcript — `PrismAgentTranscript` multi-role default (720×520, fixed UTC timestamps, `renderMarkdown: false`)
  3. CyberCore ops — `PrismProviderHealthMatrix` default (800×420, `prismProviderHealthMatrixMinimalFixture()`)

- **Alias audit table** (EPIC-16 C-01–C-12 + supporting public types):

  | C-ID | Public Prism* | Implementation | Barrel path |
  | --- | --- | --- | --- |
  | C-01 | `PrismPageShell` | `DSPageShell` | `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart` |
  | C-02 | `PrismTree` / `PrismTreeNode` | `DSTree` / `DSTreeNode` | same |
  | C-03 | `PrismAgentTranscript` | `DSAgentTranscript` | same |
  | — | `PrismAgentMessage` / `PrismAgentMessageBlock` / `PrismAgentRole` / `PrismAgentMessageBlockType` | DS* equivalents | same |
  | C-04 | `PrismToolCallCard` / `PrismToolCallData` / `PrismToolCallStatus` | DS* | same |
  | C-05 | `PrismMessageStatusHistory` / `PrismMessageStatusStep` / `PrismMessageStatusStepState` | DS* | same |
  | C-06 | `PrismArtifactWorkbench` | `DSArtifactWorkbench` | same |
  | C-07 | `PrismProviderHealthMatrix` / `PrismProviderHealthCell` / `PrismProviderHealthProvider` | DS* | same |
  | C-08 | `PrismMcpCapabilityInspector` + capability kinds/items/selection + fixture helpers | DS* | same |
  | C-09 | `PrismTimingWaterfall` / `PrismTimingSpan` / `PrismTimingWaterfallLayout` | DS* | same |
  | C-10 | `PrismTrafficInspector` / `PrismTrafficRequest` / `PrismTrafficDetailTab` | DS* | same |
  | C-11 | `PrismWorkflowCanvasStage` + node/edge/layout/selection + fixtures | DS* | same (Wave M landed) |
  | C-12 | `PrismExecutionConsole` + lines/groups/controller + fixtures | DS* | same (Wave M landed) |

  **Audit result**: No alias gaps. Boundary check “All public DS declarations have Prism aliases” **PASS**. No `prism_aliases.dart` / barrel edits required this pass.

- **Tests or validation commands**:
  - `flutter test --update-goldens test/goldens/prism_page_shell_golden_test.dart test/goldens/prism_agent_transcript_golden_test.dart test/goldens/prism_provider_health_matrix_golden_test.dart --concurrency=1 --no-pub` → **3/3 PASS** (baselines written)
  - `flutter test test/goldens/prism_page_shell_golden_test.dart test/goldens/prism_agent_transcript_golden_test.dart test/goldens/prism_provider_health_matrix_golden_test.dart --concurrency=1 --no-pub` → **3/3 PASS**
  - `dart analyze test/goldens/prism_page_shell_golden_test.dart test/goldens/prism_agent_transcript_golden_test.dart test/goldens/prism_provider_health_matrix_golden_test.dart lib/src/prism_aliases.dart` → **No issues found**
  - `dart run test/boundaries/boundary_test.dart --repo-root ../..` (from `packages/warp_prism_ui`) → **7/7 PASS**

- **Boundary harness**: **7/7 PASS** (task wording 6/6; harness expanded in Task 1612 — document vs task wording per wave note)

- **Local changelog entry**: `docs/changelog/2026-07-16-task-1614-epic-16-goldens-boundary-alias-audit.md`

- **Agent-wiki / docs institutionalization**: N/A (role continuity only at session end if parent requests)

- **Executor**: builders (Wave C / omniroute-builder)

- **Completion date**: 2026-07-16

### Residual risks

- Goldens may be platform/font-sensitive across CI hosts (same class as existing atom goldens).
- Wave M organism goldens (`PrismWorkflowCanvasStage`, `PrismExecutionConsole`) not added this pass (optional).
- Full `test/goldens/` suite not re-run; only the three new EPIC-16 files validated.

(End of file)

---

## Review Ledger

| Field | Value |
| --- | --- |
| Reviewer | reviewers (internal builder review / omniroute-reviewer) |
| Date | 2026-07-16 |
| Score | **100/100** — Perfect |
| Verdict | **PASS** |
| Lane | `02-doing` → `03-review` |

### Live verification (this review)

| Gate | Result |
| --- | --- |
| ≥3 EPIC-16 family goldens | **PASS** — chrome `PrismPageShell`, transcript `PrismAgentTranscript`, ops `PrismProviderHealthMatrix` |
| PNG baselines committed | **PASS** — 800×480, 720×520, 800×420 RGBA PNGs present |
| Public Prism* only in goldens | **PASS** — no `DS*` / `src/` imports in new golden tests |
| No network/MapLibre/Recharts | **PASS** — no forbidden imports in golden sources |
| `dart analyze` (scoped) | **PASS** — No issues found |
| `flutter test` (3 goldens) | **PASS** — 3/3 All tests passed |
| Boundary harness | **PASS** — 7/7 |

### Axiom compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | Scoped analyze clean |
| Lifecycle Safety | PASS | Surface size tearDown; single `pump()`; no controllers/subs |
| Dependency Direction | PASS | Public barrel only; boundary 7/7 |
| UI Accessibility | PARTIAL→SAFE for scope | Transcript sets `semanticLabel`; default-state goldens not a11y matrix |
| Proof Reality | PASS | Live re-run matched claims; PNGs match claimed sizes |
| Release Security | PASS | No secrets; fixture-only pumps |

### Residual risks (accepted, non-blocking)

- Platform/font golden sensitivity across CI hosts (same class as existing atom goldens).
- Optional Wave M goldens (`PrismWorkflowCanvasStage`, `PrismExecutionConsole`) deferred by task scope.
- Full `test/goldens/` suite not re-run this pass (scoped three new files only).

### Path to 100

None — score 100. Optional follow-ups only if product wants Wave M organism goldens (out of Task 1614 minimum).

### Independent review (gatekeeper, 2026-07-16)

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-07-16 | reviewers (independent adversarial gatekeeper) | **96** | **PASS WITH NOTES** | `docs/reports/review/1614-epic-16-goldens-boundary-alias-audit-independent-review-2026-07-16.md` |

**Finding**: EPIC-16 golden tests pass all functional gates (goldens, boundaries, analyzer, deps, alias audit, full golden suite 60/60, teal skip confirmed) but `dart format` reports the three new EPIC-16 golden files would be changed. Path to 100: `dart format` the three files and re-run the scoped format probe.


### Latest Review — drain 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Score**: `94/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1614-drain-review.md`
- **Lane outcome**: moved `03-review/` → `04-completed/`
- **Task reference**: Task 1614
- **Top residual**: golden format residual persists; goldens 60/60

#### Path-to-100 residuals (non-blocking for S≥90 closeout)

- See full report Path To 100. Shared: `dart format` on EPIC-16 organism/test/golden surfaces.
- Package-wide analyzer infos (141) are residual package hygiene, not scoped-task exit failures.


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
| **Full report** | `docs/reports/review-wave-2026-07-18/task-1614-path100-rereview.md` |
| **Top finding** | none — ≥3 goldens + format clean + 7/7 boundaries |
| **Exits** | PASS |
| **Live gates** | format 0; analyze 0; organism/gallery/goldens PASS; boundaries 7/7 |

