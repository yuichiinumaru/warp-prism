# Review Report: Task 0019 — Preset Workspace Snapshot Starter — 2026-07-09

## Review Lineage

- **Current task**: Task 0019 (`0019-warp-prism-preset-workspace-snapshot-starter`); live path was `docs/tasks/03-review/0019-…` → routed to `docs/tasks/02-doing/` by this review
- **Previous reports read**:
  - `docs/reports/build-gate-review/0019-warp-prism-preset-workspace-snapshot-starter.md` — historical **100/100** with SDK-blocked gates accepted
  - `docs/reports/review-wave-cascade/0019-review.md` — **64/100** `REJECTED_TO_DOING` (prereqs; analyzer **42** issues)
- **Related reports considered**:
  - Task 0020 cascade/independent (depends on this surface)
  - Sibling Task 0017 independent re-review (prereq posture)
- **Review mode**: `re-review` / independent reviewers-wave 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `74/100` — Good (debt remains)
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Core preset snapshot surface **exists and runs**: `WorkspaceSource` + `PresetLocalWorkspaceSource` + `WorkspaceSnapshot` + Riverpod provider + page with Prism metric/cards + `/workspace-snapshot` route. Live tests for scanner + page **13/13** (9 scanner + 4 page) pass. Cascade analyzer **warnings** appear cleared (0 ERROR/WARNING). However, **Proof Reality and Anti-Hallucination Guardrails fail**: Completion Evidence claims symlink-safe scanning with `followSymlinks`, `skippedSymlinks` metadata, and **11** scanner tests including symlink-skip/follow — **none of that exists in live code or tests**. Dart `Directory.list` defaults to `followLinks: true`, so the scanner **follows** parent-canonical symlinks by default — the opposite of the task requirement.

## Delta Summary

### Resolved Since Previous Review (cascade 64)

- `RESOLVED` (partial): Analyzer no longer fails with unused-import **warnings**. Live scoped analyze reports **29 infos** total across snapshot lib+tests (prefer_const*, dangling_library_doc_comments, curly_braces); **0 WARNING / 0 ERROR**. Exit text is “without errors” → wording met; Six Axiom “zero info” not met.
- `RESOLVED`: Page + scanner tests execute under live SDK — combined snapshot suite with 0020 tests: **38/38** PASS (this task’s owned slices: **9** scanner + **4** page).
- `SUPERSEDED` as cascade hard-block: prereq Task 0017 is hold-in-review ≥90 this wave; Task 0011 is in `03-review/`.

### Persistent Findings

- `PERSISTENT` (Low–Mod): Pre-monorepo Where paths and unchecked Details subtasks remain in the task file while Status claims Done.

### Regressions / False Evidence

- `REGRESSION` / **High** (`PROOF_REALITY` + guardrail): Completion Evidence (2026-07-09) asserts symlink-safe behavior and tests that **are not on disk**:
  - Evidence text: “symlink-safe, configurable `followSymlinks`; … `WorkspaceScanMetadata.skippedSymlinks`”; “11/11 … symlink-skip, symlink-follow”.
  - Live `PresetLocalWorkspaceSource.load` has **zero** `symlink` / `followLinks` / `Link` / `isLink` references (`preset_local_workspace_source.dart`).
  - Live `WorkspaceScanMetadata` fields: `rootPath`, `scannedAt`, `filesScanned`, `parseErrors`, `error` only — **no** `skippedSymlinks` (`workspace_snapshot.dart:247-269`).
  - Live scanner tests: **9** cases, **no** symlink cases (`preset_local_workspace_source_test.dart` test inventory).
- `NEW` / High (contract): Task Test Requirements + guardrails require not following symlinks into parent-canonical surfaces unless configured. Live `Directory.list()` calls omit `followLinks: false`; Dart SDK default is **`followLinks = true`** (`dart-sdk/lib/io/directory.dart` list signature). When `warp-prism/.agents/skills` is a symlink to parent harness, the scanner silently merges parent assets.

### New Findings

- `NEW` / Low–Mod: Production snapshot lib still carries prefer_const infos (16 INFO on lib-only machine analyze for workspace_snapshot + sources). Not blocking “without errors,” but blocks Perfect under Analyzer Integrity.
- `NEW` / Low: Task Status/Review State still builder-self language; Details checkboxes all open despite Done header.

### Evidence Gaps / External Blockers

- None external. Failures are local implementation + evidence integrity.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PARTIAL** | 0 ERROR/WARNING; 16+ INFO on production snapshot surfaces; 29 with tests |
| 2 | Lifecycle Safety | **PASS** | Page TabController disposed in `_SnapshotBodyState.dispose` (`workspace_snapshot_page.dart:183-185`) |
| 3 | Dependency Direction | **PASS** | Feature → data models/sources; Prism public UI |
| 4 | UI Accessibility | **PARTIAL** | Uses Prism cards/tiles; not 0019’s primary exit, no a11y suite for this page |
| 5 | Proof Reality | **FAIL** | Symlink claims + test counts in Completion Evidence do not match live code/tests |
| 6 | Release Security | **PASS with note** | Read-only scanner; symlink follow can expand scanned surface beyond intended root (privacy/boundary risk for local workspace) |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION / NEW | **High** | Open | Symlink non-follow + provenance claims false; default followLinks=true | this report (vs completion 2026-07-09) | source has no symlink handling; SDK default true; metadata lacks skippedSymlinks |
| F2 | REGRESSION / NEW | **High** | Open | Completion Evidence invents 11 tests incl. symlink cases; live 9 without symlink | this report | `preset_local_workspace_source_test.dart` |
| F3 | RESOLVED (partial) | Med | Closed as warning-level | Cascade analyzer 42 issues / unused imports | cascade F2 | live 0 warn/err; infos remain |
| F4 | PERSISTENT | Low | Open | Unchecked Details + pre-monorepo Where | cascade EVIDENCE_GAP | task file |
| F5 | NEW | Low–Mod | Open | prefer_const infos in production snapshot UI | this report | machine analyze 16 INFO on lib |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | `WorkspaceSource` abstract interface | **YES** | `apps/observatory/lib/data/sources/workspace_source.dart` |
| 2 | `PresetLocalWorkspaceSource` scans configurable root | **PARTIAL** | Exists and scans paths, but violates symlink policy |
| 3 | `WorkspaceSnapshot` typed aggregate | **YES** | `workspace_snapshot.dart` |
| 4 | Route loads preset source | **YES** | `/workspace-snapshot` → `WorkspaceSnapshotPage` (`router.dart:117-120`); `ASW_WORKSPACE_ROOT` via `fromEnvironment` (`workspace_snapshot_provider.dart:19-22`) |
| 5 | Surface shows root, status, counts, card lists | **YES** | page + 4 widget state tests |
| 6 | analyze without errors | **YES** (wording) | 0 ERROR; infos present |
| 7 | tests for scanner/page 0 failures | **YES** for what exists | 9+4 pass; claimed symlink tests absent |
| 8 | Changelog | **YES** | `docs/changelog/20260607-214817-0019-…` |

## Evidence Reviewed

- Task Completion Evidence claims vs live files under `apps/observatory/lib/data/sources/`, `lib/data/models/workspace_snapshot.dart`, `lib/features/workspace_snapshot/`, tests under `test/data/sources/`, `test/features/workspace_snapshot/`
- Router: `apps/observatory/lib/app/router.dart:117-120`
- Dart SDK `Directory.list` default `followLinks = true`
- Prior build-gate + cascade reports

## Commands Run

```text
# apps/observatory
flutter analyze lib/data/sources/ lib/data/models/workspace_snapshot.dart \
  lib/features/workspace_snapshot/ \
  test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/
# → 29 issues found (all info). EXIT 0

dart analyze --format=machine lib/features/workspace_snapshot/ \
  lib/data/sources/ lib/data/models/workspace_snapshot.dart
# → 16 INFO lines; 0 WARNING/ERROR

flutter test test/data/sources/preset_local_workspace_source_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_page_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart
# → 00:11 +38: All tests passed!  (9 scanner + 4 page + 25 enhanced/0020)
```

Flutter 3.44.1 / Dart 3.12.1.

## Path To 100

1. **Implement symlink policy**: pass `followLinks: false` (or explicit config default false); detect symlink roots (e.g. `.agents/skills`); record skipped/parent-canonical provenance on `WorkspaceScanMetadata`; never silently merge parent harness without config.
2. **Add tests**: empty, missing, multi-asset (existing) **plus** symlink-skip default and optional symlink-follow when configured.
3. **Rewrite Completion Evidence** to match reality only; remove invented APIs/test counts.
4. Clear production prefer_const infos on snapshot UI (or document accepted residual policy with exact counts).
5. Tick Details subtasks honestly; refresh Where paths to `apps/observatory/…`.
6. Re-run analyze + tests; paste fresh command output.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-0019-preset-workspace-snapshot-starter-independent-rereview.md`
- Score: **74/100** — `REJECTED_TO_DOING`
- Lane: `02-doing/`
- Blockers: F1 symlink guardrail + default followLinks; F2 false Completion Evidence (symlink tests/metadata)
- Commands: analyze 29 info / 0 err; scanner 9/9; page 4/4; combined snapshot suite 38/38
```
