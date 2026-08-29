# Independent Adversarial Re-Review: Task 1511 — PrismAiAnalystPanel

> **Date**: 2026-08-23
> **Reviewer**: `reviewers` (independent adversarial gatekeeper)
> **Task**: `docs/tasks/03-review/1511-warp-prism-ai-analyst-panel-fixture-organism.md`
> **Score**: **94/100** — Elite
> **Verdict**: **HELD_IN_REVIEW_PATH_TO_100**
> **Lane routing**: stays in `docs/tasks/03-review/` (>=90; no lane move)

## Review Lineage

Previous reports read:

- `docs/reports/review-wave-2026-07-11/task-1511-independent-review.md` — 92/100.
- `docs/reports/review/1511-ai-analyst-panel-review-2026-07-16.md` — 74/100, rejected for async disposal safety, missing mounted guard, format/analyzer evidence, and reduced-motion handling.
- `docs/reports/review/expert-2026-07-18-task-1511.md` — claimed 100/100 after path-to-100.
- `docs/reports/review/formal-2026-07-18-task-1511.md` — claimed 100/100 final gate.

This is an independent re-review; prior formal claims are treated as stale until reproduced.

## Delta Summary

### RESOLVED

- `DSAiAnalystController` tracks `_disposed`, uses `_safeNotify()`, checks `_disposed` after the stream delay and reply await, and avoids final notification after disposal (`ds_ai_analyst_panel.dart:378-471`).
- Panel-owned composer, scroll controller, focus node, and optional owned controller are disposed/removed in `ds_ai_analyst_panel.dart:649-680`.
- Post-frame scroll callback now checks `!mounted || !_scroll.hasClients` at `ds_ai_analyst_panel.dart:659-671`.
- Reduced motion uses a static hourglass indicator instead of a progress animation (`1017-1049`, `1262-1281`).
- Dispose-during-stream, panel-unmount, reduced-motion, and send/a11y tests all pass.

### NEW / PERSISTENT

- **F1 — AI source is not format-clean (−2)**: non-mutating format reports `Changed lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart`. Completion Evidence claims zero changed; this is stale.
- **F2 — Package analyzer claim stale (−4)**: current `dart analyze lib test` reports **218 info-level issues**, not zero. The task claims `No issues found!`; current live proof contradicts it.

No new lifecycle, cancellation, mounted, reduced-motion, API, or security defect was found.

## Live Verification

| Gate | Result |
| --- | --- |
| Scoped analyzer: AI source/tests | **PASS** — `No issues found!` |
| Non-mutating format: AI source/tests | **FAIL** — source would change |
| AI panel widget/controller tests | **PASS** — 19 tests in combined 70-test organism run |
| Combined EPIC-15 organism tests | **PASS** — 70/70 |
| Gallery suite | **PASS** — 23/23 |
| Direct boundary harness | **PASS** — 7/7 |
| `melos run test-boundaries` | **PASS** — 7/7 |
| Full package analyzer | **FAIL/EVIDENCE GAP** — 218 infos |
| Aliases | **PASS** — `PrismAiAnalystPanel`, Turn, Role, TurnStatus, Controller at `prism_aliases.dart:851+` |
| Gallery registration | **PASS** — `epic15-osint` section and AI analyst fixture demo |

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | **PARTIAL** | Scoped clean; task source format red; package analyzer 218 infos |
| Lifecycle Safety | **PASS** | Controller disposal state and post-await guards; panel resource disposal and listener unbinding; post-frame mounted guard |
| Dependency Direction | **PASS** | Fixture reply adapter only; boundary 7/7; no network/model/storage imports |
| UI Accessibility | **PASS** | Panel/header/turn/composer/text-field semantics; send and close 48dp; reduced-motion static indicator |
| Proof Reality | **PARTIAL** | Functional 70/70 + gallery/boundaries green, but format/package analyzer claims stale |
| Release Security | **PASS** | Fixture policy banner; no http/HttpClient/dio/api keys/local storage/sqlite paths |

## Async Cancellation / Mounted Audit

- `send()` has two await boundaries: delayed stream simulation and `Future.sync(replyAdapter(...))`.
- `_disposed` is checked after the delay and after the reply await, plus before mutation and inside catch/finally.
- `dispose()` sets `_disposed = true`, clears busy, then calls `super.dispose()`.
- `_safeNotify()` no-ops after disposal.
- Panel `_onControllerChanged()` guards `mounted` before mutation and again in the post-frame callback before reading/animating `_scroll`.
- Tests cover controller disposal during stream and panel unmount during stream; both pass in the live 19-test subset.

No phantom `onSend` contract documentation remains; dartdoc uses `onTurnsChanged`.

## Accessibility Audit

- Panel semantic region and header labels present.
- Composer is labeled as a message composer; text field has `textField: true` and label.
- Send `IconButton` has tooltip and 48×48 constraints.
- Close `IconButton` has button semantics and 48×48 constraints.
- Streaming state has semantic label and reduced-motion static fallback.

## Path To 100

1. Format `ds_ai_analyst_panel.dart` (and any associated changed test if format probe reports it) and re-run non-mutating format.
2. Correct Completion Evidence so it does not state package analyzer clean while current full-package analyzer reports 218 infos.
3. Close/rebaseline the package analyzer info baseline or obtain a governance-approved scoped-gate exception.
4. Re-run all exact evidence commands and update the ledger.

## Lane Action

Score **94** is in the 90–99 band. Keep Task 1511 in `docs/tasks/03-review/`; do not route to `02-doing/` or `04-completed/`.

## Evidence Reviewed

- `packages/warp_prism_ui/lib/src/organisms/ai_analyst_panel/ds_ai_analyst_panel.dart` and tests.
- Public aliases, gallery registry/sections, task Completion Evidence.
- Prior independent, expert, and formal reports listed in Review Lineage.
- Current package/scoped analyzer, non-mutating format, 70 organism tests, 23 gallery tests, and direct/Melos boundary commands.