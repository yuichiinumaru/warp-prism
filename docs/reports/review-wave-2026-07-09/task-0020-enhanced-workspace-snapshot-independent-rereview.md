# Review Report: Task 0020 — Enhanced Workspace Snapshot Search/Detail/Graph — 2026-07-09

## Review Lineage

- **Current task**: Task 0020 (`0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph`); live path was `docs/tasks/03-review/0020-…` → routed to `docs/tasks/02-doing/` by this review
- **Previous reports read**:
  - `docs/reports/build-gate-review/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md` — historical **100/100** with SDK-blocked gates + “debounced filtering” claim
  - `docs/reports/review-wave-cascade/0020-review.md` — **52/100** `REJECTED_TO_DOING` (prereq 0019; **fake debounce**; analyzer 42 issues; thin UI/deep-link proof)
- **Related reports considered**:
  - Task 0019 independent re-review this wave (**74/100** rejected — prereq)
- **Review mode**: `re-review` / independent reviewers-wave 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `76/100` — Good (debt remains)
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Enhancement surface is substantially present: search/filter providers, two graph modes (`containment` / `operational`), Prism graph canvas + detail inspector, deep-link routes for agent/skill/workflow/task/changelog, derived metrics on the model, and **25** model-level enhanced tests green. Cascade analyzer warning-level debt is reduced to infos. **Persistent contract falsehood remains**: exit condition and page docs claim **debounced** search; live `debouncedSearchQueryProvider` is an immediate passthrough with an explicit comment that debounce is “optional” (`workspace_snapshot_provider.dart:59-65`). Completion Evidence further claims **29** tests with **4 new provider-level** scenarios (graph projection modes, selection open/close, search+filter combo) — live `workspace_snapshot_enhanced_test.dart` has **25** pure model/builder tests and **zero** `ProviderContainer` / selection / debounce tests. Prerequisite Task 0019 is rejected this wave (symlink/evidence).

## Delta Summary

### Resolved Since Previous Review (cascade 52)

- `RESOLVED` (partial): Analyzer no longer fails on unused-import warnings; scoped snapshot analyze is **0 ERROR/WARNING**, **29 INFO**.
- `RESOLVED`: Enhanced + page + scanner tests run live — **38/38** PASS overall; enhanced file **25/25**.
- `RESOLVED`: Graph modes + UI wiring exist — `GraphMode.containment|operational`, `_projectGraph`, `WorkspaceGraphPanel` + `PrismGraphCanvas`, mode toggle (`workspace_graph_panel.dart`).
- `RESOLVED`: Detail inspector uses `PrismDetailInspector` (`workspace_detail_inspector.dart`); cards/graph call `selectAsset`.
- `RESOLVED`: Deep-link routes registered (`router.dart:122-156`) and page accepts `assetId` (`workspace_snapshot_page.dart:43-55`).

### Persistent Findings

- `PERSISTENT` / **High**: Debounced search exit condition still false — passthrough provider with comment admitting no timer (`workspace_snapshot_provider.dart:59-65`). First seen cascade F2; still open.
- `PERSISTENT` / Medium: UI-level proof for card click, graph node click, and deep-link inspector remains thin — enhanced suite is model-only; page tests cover loading/loaded/error/empty only (no selection assertions).

### Regressions / False Evidence

- `NEW` / **High** (Proof Reality): Completion Evidence (2026-07-09) claims:
  - `flutter test …workspace_snapshot_enhanced_test.dart` → `+29` with “4 new provider-level scenarios”
  - Live inventory: **25** `test(` entries, all model/graph-builder groups; **no** provider selection/graph-mode/search+filter provider tests; live run total with page+scanner is 38, not 29 enhanced alone.
- `PERSISTENT` via prereq: Task 0019 symlink/guardrail rejection blocks clean dependency posture (this wave 0019 = **74**).

### New Findings

- `NEW` / Medium (Lifecycle): Deep-link handling schedules `addPostFrameCallback` to `selectAsset` on **every** rebuild while `assetId != null` (`workspace_snapshot_page.dart:53-56`). Can re-open selection after user closes inspector and thrash selection state under rebuilds. Prefer `initState`/route-aware one-shot or listen to GoRouter state once.
- `NEW` / Low: Page header comment still claims “debounced filtering” (`workspace_snapshot_page.dart:5`) while provider does not debounce.
- `NEW` / Low: Details subtasks all unchecked; Where paths pre-monorepo.

### Evidence Gaps / External Blockers

- No external SDK blocker. Missing: real debounce + test; widget tests for selection/deep-link; honest evidence rewrite; prereq 0019 symlink fix.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PARTIAL** | 0 ERROR/WARNING; 29 INFO scoped (prefer_const*, curly_braces, dangling doc) |
| 2 | Lifecycle Safety | **PARTIAL** | TabController disposed; deep-link post-frame every rebuild is unsafe pattern |
| 3 | Dependency Direction | **PASS** | Feature providers use data models/services; Prism UI |
| 4 | UI Accessibility | **PARTIAL** | Inherits Prism controls; no dedicated a11y suite for enhanced surface |
| 5 | Proof Reality | **FAIL** | Debounce claim false; provider-test claim false; UI selection poorly proven |
| 6 | Release Security | **PASS** | Read-only; no secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | **High** | Open | Debounced search not implemented | cascade 2026-06-17 F2 | `workspace_snapshot_provider.dart:59-65` |
| F2 | PERSISTENT | Medium | Open | Weak UI/deep-link selection proof | cascade F3/gap | page tests 4 states only; enhanced model-only |
| F3 | NEW | **High** | Open | Completion Evidence invents +29 / 4 provider tests | this report | enhanced file 25 model tests; no ProviderContainer |
| F4 | NEW | Medium | Open | Deep-link `addPostFrameCallback` every rebuild | this report | `workspace_snapshot_page.dart:53-56` |
| F5 | REGRESSION | High | Open via dep | Prereq Task 0019 rejected (symlink/evidence) | this wave 0019 | sibling report 74/100 |
| F6 | RESOLVED (partial) | Med | Closed as warn | Analyzer 42 with warnings | cascade | live infos only |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Global search with **debounced** filtering | **NO** | passthrough provider |
| 2 | Filter chips kind/lane/provenance | **YES** (impl) | `workspace_filter_chips.dart` + providers; model filter tests |
| 3 | ≥2 graph modes from snapshot relationships | **YES** | containment/operational projection + tests via graph builder |
| 4 | Detail inspector on card/graph/deep-link | **PARTIAL** | wiring present; deep-link rebuild smell; weak widget proof |
| 5 | Deep-link routes agent/skill/workflow/task (+ changelog) | **YES** | `router.dart:122-156` |
| 6 | Derived metrics beyond raw counts | **YES** | model getters + UI `workspace_derived_metrics.dart` + unit tests |
| 7 | analyze without errors | **YES** (wording) | 0 ERROR |
| 8 | tests 0 failures for search/filter/graph/detail/deep-link | **PARTIAL** | search/filter/metrics/graph unit green; detail/deep-link widget proof weak; no debounce test |
| 9 | Changelog | **YES** | `docs/changelog/20260607-215829-0020-…` |

## Evidence Reviewed

- Provider/page/widgets under `apps/observatory/lib/features/workspace_snapshot/`
- Model metrics/search: `apps/observatory/lib/data/models/workspace_snapshot.dart`
- Tests: `workspace_snapshot_enhanced_test.dart` (25), `workspace_snapshot_page_test.dart` (4)
- Router deep-links: `apps/observatory/lib/app/router.dart`
- Prior build-gate + cascade 0020; sibling 0019 report

## Commands Run

```text
# apps/observatory
flutter analyze lib/data/sources/ lib/data/models/workspace_snapshot.dart \
  lib/features/workspace_snapshot/ \
  test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/
# → 29 issues found (all info). EXIT 0

flutter test test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_page_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart
# → 00:11 +38: All tests passed!
# Inventory: enhanced = 25 model tests (not 29 provider suite)
```

Flutter 3.44.1 / Dart 3.12.1.

## Path To 100

1. Implement real debounce (Timer/`Ref.listen`/async notifier) for search; assert rapid updates coalesce in a provider or widget test.
2. Add widget/provider tests: card `onTap` opens inspector; graph node select; deep-link `assetId` selects once; clear closes.
3. Fix deep-link selection to one-shot (no per-rebuild post-frame).
4. Align Completion Evidence with actual test counts and behaviors.
5. Clear prefer_const / curly_braces infos on touched production files.
6. Unblock after Task 0019 symlink/evidence remediation (or document accepted residual with explicit product sign-off — not reviewer auto-complete).
7. Tick Details checkboxes only when true; refresh monorepo Where paths.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-0020-enhanced-workspace-snapshot-independent-rereview.md`
- Score: **76/100** — `REJECTED_TO_DOING`
- Lane: `02-doing/`
- Blockers: F1 fake debounce; F3 false provider-test evidence; F4 deep-link rebuild selection; F5 prereq 0019
- Commands: analyze 29 info / 0 err; combined snapshot tests 38/38 (enhanced 25 model-only)
```
