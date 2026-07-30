# Review Report: Task 0315 — Provider Load State View Model Contracts — 2026-07-09

## Review Lineage

- **Current task**: Task 0315 (`warp-prism-provider-load-state-view-model-contracts`); live path at review start: `docs/tasks/03-review/0315-warp-prism-provider-load-state-view-model-contracts.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0315-review.md` — 100/100 (SDK-blocked; stale)
- **Related reports considered**:
  - Task 0312 wave-3 dual-repository finding (provider-local MockWorkspaceRepository) — claimed fixed by this task’s Completion Evidence
  - Tasks 0310/0313/0314 this wave for composed data chain health
- **Review mode**: `re-review` / first rigorous independent verification with live Flutter gates

## Score And Verdict

- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; never auto-complete to `04-completed`)

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Live gates green. `dart analyze lib/data/providers/ test/data/providers/` → **No issues found**. `flutter test test/data/providers/workspace_providers_test.dart` → **+17 All tests passed** (builder claimed 15; live is 17).
- `RESOLVED` / Critical for chain: Providers use canonical `MockWorkspaceRepository` from the repository layer (no local source-bridge class). Test asserts `runtimeType` contains `MockWorkspaceRepository`.
- `RESOLVED`: Typed VMs for Overview / Map / Operate / History / Governance with empty factories and service-backed constructors.
- `RESOLVED`: Snapshot success / empty / error transitions tested; graph and history fail closed on repository error (`StateError`).

### Persistent Findings

- None from prior independent code review (only stale build-gate 100).

### Regressions

- None.

### New Findings

- `NEW` / Low: No dedicated Riverpod providers that emit `WorkspaceOverviewViewModel` / etc. Contracts are pure classes; screens must compose `metrics + diagnostics` factories. Acceptable for “contracts” wording, slightly short of “providers expose … for shell” if interpreted as ready-made VM providers.
- `NEW` / Low: No explicit `AsyncLoading` assertion (loading exists on `WorkspaceLoadState` and AsyncNotifier reload path but is not exercised as a UI-visible transition test).
- `NEW` / Low: Downstream graph quality depends on 0312 partial-parse semantics and 0313 ID normalization residual — not defects **in** provider orchestration.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Provider suite does not load the real mock corpus (uses `_FakeWorkspaceRepository`). Integration proof deferred to feature epics; acceptable for scoped unit contract tests.
- Cross-task corpus 91/130 FM is **not** claimed fixed by 0315 — good honesty vs Task 1403 phantom claims.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed | Dual MockWorkspaceRepository in providers | wave-3 on 0312 | `workspace_providers.dart:47-50` uses repository-layer class |
| F2 | RESOLVED | High | Closed | Package/SDK gates blocked | build-gate 2026-06-13 | analyze clean; 17/17 PASS |
| F3 | NEW | Low | Open | No VM-level Riverpod providers | this review | only data async providers + pure VM classes |
| F4 | NEW | Low | Open | AsyncLoading transition untested | this review | suite jumps to future values |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Provider/VM contracts under lib; compose repo/services | PASS | `workspace_providers.dart`, `workspace_view_models.dart`, `providers.dart` |
| Load/error/empty/success typed reusable | PASS | `AsyncValue` + `WorkspaceLoadState` + empty VMs |
| `dart analyze lib/data/providers/ test/data/providers/` | PASS | No issues found |
| Provider tests 0 failures | PASS | 17/17 |
| Changelog | PASS | `docs/changelog/2026-07-09-task-0315-provider-load-state-view-model-contracts.md` |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | Provider surface clean |
| Lifecycle Safety | PASS | Riverpod AsyncNotifier; reload uses `AsyncValue.guard` |
| Dependency Direction | PASS | Providers orchestrate; no domain reimplementation |
| UI Accessibility | N/A | No widgets in scope |
| Proof Reality | PASS | Fresh commands match exits; count under-claim only |
| Release Security | PASS | |

## Evidence Reviewed

- `workspace_providers.dart`, `workspace_view_models.dart`, `providers.dart`
- Full `workspace_providers_test.dart`
- Cross-check repository class identity

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `dart analyze lib/data/providers/ test/data/providers/` | `apps/observatory` | No issues found |
| `flutter test --concurrency=1 --no-pub test/data/providers/workspace_providers_test.dart` | `apps/observatory` | +17 All tests passed |

## Path To 100

1. Optional: thin `overviewViewModelProvider` (and peers) composing metrics+diagnostics for shell, with one widget/provider test.
2. Add a loading-transition test (override repo with delayed future; observe `AsyncLoading` then data).
3. Align Completion Evidence test count to 17.
4. Keep regression guard: provider repository type must remain the canonical repository-layer class (wave-3 F1).

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0315-provider-load-state-vm-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Low: optional VM providers + AsyncLoading test.

#### Path-to-100 Summary
- Optional VM providers + loading transition test; evidence count fix.

### Previous Reports
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0315-review.md` (superseded; SDK blocked)
```
