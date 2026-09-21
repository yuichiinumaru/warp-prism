# Review Report: Task 0310 — Backbone Model Contract Audit — 2026-06-17

## Review Lineage

- **Current task**: Task 0310 (`warp-prism-backbone-model-contract-audit`), reviewed at `docs/tasks/03-review/0310-warp-prism-backbone-model-contract-audit.md`.
- **Previous reports read**:
  - `docs/reports/0310-backbone-model-contract-audit.md` — builder audit; validation blocked.
  - `docs/reports/build-gate-review/0310-review.md` — claimed 100/100 despite three blocked exit conditions.
- **Related reports considered**: `docs/reports/warp-prism-task-gap-overlap-audit.md` — establishes the strict 0310 → 0311 → 0312 → 0313 chain.
- **Review mode**: re-review / fresh verification gate.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The Flutter SDK is now installed (`Flutter 3.44.1`, Dart `3.12.1`), so the historical “SDK not installed” explanation is stale.

### Persistent Findings

- `PERSISTENT`: The required analyzer and focused-test gates remain unproven. Both fresh commands exit before analysis/testing because package resolution includes `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0` as a workspace member without `resolution: workspace`.
- `PERSISTENT`: No Task 0310 changelog entry exists under `docs/changelog/`.

### Regressions

- None established; the required tests did not execute.

### New Findings

- `NEW`: Task state and the previous 100/100 report contradict current evidence. The task is marked Ready For Review while three binary exits remain unchecked, and the previous report labels blocked analyzer/test/changelog exits as “task complete.”

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No fresh analyzer or focused-test result exists. This is a repository-local package-resolution/caching defect, not evidence that the model contract passes.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Mandatory package proof does not execute | 2026-06-07 builder report | `docs/tasks/03-review/0310-warp-prism-backbone-model-contract-audit.md:49-50`; fresh commands fail during package resolution |
| F2 | PERSISTENT | Medium | Open | Required changelog evidence is absent | 2026-06-07 builder report | `docs/tasks/03-review/0310-warp-prism-backbone-model-contract-audit.md:51`; no `docs/changelog/*0310*` or content match |
| F3 | NEW | High | Open | Ready/100 claims are phantom completion evidence | 2026-06-17 | `docs/tasks/03-review/0310-warp-prism-backbone-model-contract-audit.md:3-4,49-51,127-133`; `docs/reports/build-gate-review/0310-review.md:7-9,62-64,91-95` |
| F4 | NEW | Low | Open | Unused private helper adds analyzer debt | 2026-06-17 | `apps/observatory/lib/data/models/workspace_graph.dart:216-223` (`_listEquals` has no caller) |

## Evidence Reviewed

- Task and reports listed above.
- Product/planning evidence: `docs/prompt.txt`, `docs/research.md`, `docs/draft.md`, `docs/reports/warp-prism-task-gap-overlap-audit.md`.
- Source/test files: `apps/observatory/lib/data/models/models.dart`, `workspace_graph.dart`, `task_contracts.dart`, `changelog_contracts.dart`, `governance_diagnostics.dart`, `data_models.dart`, and `apps/observatory/test/data/models/workspace_graph_models_test.dart`.
- Runtime wiring proof: this is a data-contract task. Production consumers import `WorkspaceAsset`/`TaskMetadata` throughout Observatory; `rg`/content search found 220 references, including `lib/data/parsers/workspace_markdown_parser.dart`, map, overview, snapshot, and asset-detail surfaces. Runtime wiring is therefore present, but it does not replace package proof.
- Commands run from `apps/observatory`:
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" flutter analyze lib/data/models test/data/models` — exit 1, package resolution failed.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" flutter test test/data/models/workspace_graph_models_test.dart` — exit 1, package resolution failed.
  - Repeated with repository-root `HOME`/`PUB_CACHE` paths — same failure.
  - `command -v flutter && flutter --version` — Flutter 3.44.1 / Dart 3.12.1 available.
  - Changelog filename/content searches for `0310` — no result.
- Commands not run: broad Observatory suite, because the task’s focused package commands fail before test execution and broad proof cannot repair that gap.

## Stale-Evidence Notes

The 2026-06-13 report’s SDK-unavailable statement is stale. Its unrelated package/app counts do not prove this task’s focused model tests, and blocked binary exits cannot support a 100/100 completion verdict under the promotion-state model.

## Path To 100

1. Remove or relocate the nested `apps/observatory/tmp/pub-cache` from workspace glob discovery (without using external directories), or otherwise configure the repository-local cache so Pub does not treat cached packages as workspace members.
2. Run `flutter analyze lib/data/models test/data/models` from `apps/observatory` and record a zero-error result.
3. Run `flutter test test/data/models/workspace_graph_models_test.dart` and record zero failures.
4. Remove the unused `_listEquals` helper or use it meaningfully, then rerun analyzer/test proof.
5. Add the required Warp Prism changelog entry through the repository’s current governed mechanism and record it.
6. Update task completion evidence and state only after all binary exits pass.

## Dependency Effect

Tasks 0311, 0312, and 0313 depend on Task 0310’s stable typed contract. They must not be approved while Task 0310 is returned to doing; each must be triaged against this live upstream blocker.

## Task Ledger Patch Suggestion

Record score 72/100, `REJECTED_TO_DOING`, this report path, F1–F4, and the package-resolution/analyzer/test/changelog path to 100. Set Review State to `Package Gate Failed` and route the task to `02-doing/`.
