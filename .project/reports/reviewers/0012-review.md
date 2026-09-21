# Review Report: Task 0012 — Design System API Normalization — 2026-06-17

## Review Lineage

- **Current task**: Task 0012 (`0012-warp-prism-design-system-api-normalization`); reviewed at `docs/tasks/03-review/0012-warp-prism-design-system-api-normalization.md` before routing.
- **Previous reports read**: `docs/reports/build-gate-review/0012-review.md` — prior 100/100 approval.
- **Related reports considered**: Task 0010 executor report, prior review, and `docs/reports/review-wave-3/0010-review.md`.
- **Review mode**: dependency triage and re-review.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Fresh source inspection and a regex sweep find no stale `Ds*` casing references in current `packages/warp_prism_ui/lib` or tests.
- `RESOLVED`: Current template composition uses the real `DSShell`, `DSSidebar`, and `DSTopbar` contracts, and the focused template/token tests pass.

### Persistent Findings

- `PERSISTENT`: The prior review converted blocked analyzer/test commands and a nonexistent changelog exception into passing exit conditions.
- `PERSISTENT`: No Task 0012 changelog artifact exists despite the task checking that exit condition.

### Regressions

- `REGRESSION`: The current public-barrel boundary test reports that `warp_prism_ui.dart` exposes a DS implementation file, violating the now-declared Prism-only public namespace. This later public-API policy did not exist in the original Task 0012 framing, but it is now part of the live API-normalization surface.

### New Findings

- `NEW`: Task 0010, the declared prerequisite, is rejected at 58/100, so Task 0012 cannot be finalized against its claimed trustworthy baseline.
- `NEW`: The task's old root `lib/design_system` paths are stale after migration; current ownership is `packages/warp_prism_ui/lib/src`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Package analysis exits nonzero with 590 diagnostics. Most are later lint/deprecation debt, but the task has not provided a narrowed analyzer proof that isolates the naming/API drift contract.
- No SDK blocker remains; Flutter 3.44.1 is installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Failed prerequisite Task 0010 prevents finalization against the claimed baseline. | 2026-06-17 | `docs/tasks/03-review/0012-warp-prism-design-system-api-normalization.md:9`, `docs/reports/review-wave-3/0010-review.md` |
| F2 | REGRESSION | Medium | Open | The live public barrel directly exports a DS implementation file, and the boundary harness reports this violates the Prism-only public API. | 2026-06-17 | `packages/warp_prism_ui/lib/warp_prism_ui.dart:15-27`, focused boundary output |
| F3 | PERSISTENT | Medium | Open | Blocked validation and absent changelog work were marked as passing by the previous review. | prior review | `docs/tasks/03-review/0012-warp-prism-design-system-api-normalization.md:44-51`, `docs/reports/build-gate-review/0012-review.md:50-96` |
| F4 | EVIDENCE_GAP | Medium | Open | Current package analyzer exits nonzero with 590 diagnostics; there is no scoped analyzer artifact proving the task-owned normalization surface is clean independently of broader debt. | 2026-06-17 | fresh analyzer output; `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart`, `packages/warp_prism_ui/lib/src/organisms/` |
| F5 | NEW | Low | Open | Task paths and evidence counts describe a removed root design-system tree rather than the current package. | 2026-06-17 | `README.md:12-43`, `packages/warp_prism_ui/lib/src/` |

## Evidence Reviewed

- Full Task 0012 and every `Where` file, resolving migrated counterparts under `packages/warp_prism_ui/lib/src/`.
- Current public barrel, Prism alias policy, and Observatory compatibility layer.
- Runtime wiring rationale: this is a reusable UI package contract task; consumer wiring was confirmed through Observatory's `ds_compat.dart` and app imports, while package tests exercise template composition.
- Commands:
  - `rg -n "\\bDs[A-Z]" lib test` — no matches.
  - focused stale-symbol/token scan — no stale `DsColors`, `DsShell`, `DsSidebar`, or `DsTopbar`; only a legitimate Scaffold `body:` appeared.
  - `flutter analyze --no-pub` in `packages/warp_prism_ui` — exit 1, 590 diagnostics; includes package/test lint debt.
  - `flutter test --no-pub test/templates/templates_contract_test.dart test/tokens/ds_token_contract_test.dart test/boundaries/boundary_test.dart` — Flutter runner exits 0 with 44 tests passed, but the boundary script's own output says 5/6 checks passed and flags `warp_prism_ui.dart:27`; therefore the aggregate is a fake-pass risk and cannot prove barrel coherence.
- Commands not run: network/package retrieval was prohibited.

## Stale-Evidence Notes

The root design-system tree was migrated into `packages/warp_prism_ui`. That path drift is not itself a functional regression. The current public API policy also evolved from DS-prefixed classes toward Prism-prefixed exports; Task 0012 must reconcile that live contract rather than relying only on its historical casing sweep.

## Dependency Effect

Task 0012 is not finalizable while Task 0010 is rejected. Its original DS casing/parameter objective appears technically satisfied, but current barrel normalization, clean analyzer proof, changelog evidence, and migration-aware task evidence remain unresolved.

## Path To 100

1. Resolve Task 0010 and update Task 0012's baseline reference.
2. Update all `Where` and evidence paths to `packages/warp_prism_ui/`, preserving historical migration lineage.
3. Fix the public-barrel DS export violation or adjust the boundary contract through the owning task, then make the boundary harness fail the test process when any check fails.
4. Run a clean analyzer command for the package or a documented task-owned narrowed analyzer gate; classify unrelated diagnostics instead of claiming a pass.
5. Add or link a real Task 0012 changelog entry and rerun focused template/token/boundary proof.

## Task Ledger Patch Suggestion

- Date: 2026-06-17
- Reviewer profile: `reviewers`
- Score: `72/100`
- Verdict: `REJECTED_TO_DOING`
- Full report: `docs/reports/review-wave-3/0012-review.md`
- Lane outcome: returned to doing
- Open blockers: failed prerequisite, public-barrel boundary violation/fake-pass, missing changelog, stale paths, and analyzer evidence gap.
