# Review Report: Task 1201 — Test Failure Baseline Inventory — 2026-06-19

## Review Lineage

- **Current task**: Task 1201 (`1201-warp-prism-test-failure-baseline-inventory`); live path resolved by filesystem search as `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1201-review.md` — 20/100 rejection; primary deliverable, changelog, and completion evidence were absent at that time.
  - `docs/reports/build-gate-review/1201-review-round2.md` — 100/100 after reviewer patch; confirmed the 2026-06-11 captured baseline and taxonomy-column split.
  - `docs/reports/build-gate-review/1201-review-2026-06-17.md` — 92/100 pass with notes; fresh reruns were blocked by nested pub-cache workspace contamination under `apps/observatory/tmp/pub-cache`.
- **Related reports considered**:
  - `docs/reports/warp-prism-failure-baseline-inventory.md` — primary Task 1201 inventory deliverable.
  - `docs/reports/observatory-failure-baseline.md` — older Task 1401/EPIC-14 Observatory-specific historical baseline; confirms why successor/current baselines must be dated.
  - `docs/reports/warp-prism-test-failure-baseline.md` — older 2026-06-09 monorepo baseline superseded by the dated Task 1201 inventory.
- **Review mode**: re-review / evidence-gap verification / documentation-evidence audit.

## Score And Verdict

- **Score**: `100/100` after the narrow stale-wording and ledger patches listed below.
- **Verdict**: `ACCEPTED_100`
- **Lane recommendation**: `hold-in-review`; leave Task 1201 in `03-review` for parent final routing. Do not return to `02-doing`.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The 2026-06-17 nested pub-cache workspace contamination blocker is no longer present in the live filesystem. `apps/observatory/tmp/` exists but is empty, and a repository-local glob found `0` matching `apps/observatory/tmp/pub-cache/**/pubspec.yaml` files.
- `RESOLVED`: The four package/app test commands now start and run with repository-local `HOME`, `PUB_CACHE`, and `TMPDIR` plus `--no-pub`; they no longer fail before execution with Dart workspace-resolution errors.
- `RESOLVED`: The primary Task 1201 report still exists and remains internally consistent with its own captured 2026-06-11 raw logs: UI `+854`, Observatory `+641 -12`, catalog `+10`, cybercore `+12`; the Observatory table still has exactly 12 rows.
- `RESOLVED`: The Task 1201 changelog evidence exists at `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md` and matches the dated inventory counts.

### Persistent Findings

- None blocking. The live repository has many unrelated dirty files and current test failures, but Task 1201 is an inventory-only governance deliverable and is judged against its dated captured evidence, not against later unrelated implementation churn.

### Regressions

- None attributable to Task 1201. Fresh test counts have drifted from the 2026-06-11 inventory, but the drift is current-workspace state outside this Markdown/report-only task.

### New Findings

- `NEW/LOW` before reviewer patch: Task/report prose used “current” wording for the 2026-06-11 baseline, while 2026-06-19 live reruns now differ. This was patched narrowly so the Task 1201 inventory is explicitly historical/dated and cannot be mistaken for today’s live baseline.

### Evidence Gaps / External Blockers

- None open for Task 1201. The previous `EVIDENCE_GAP` about nested pub-cache contamination is resolved. A successor live baseline may be useful for current stabilization, but that is not a blocker for accepting the dated Task 1201 inventory.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Low | Closed | Nested pub-cache workspace contamination from the 2026-06-17 review no longer exists and no longer prevents test execution. | `docs/reports/build-gate-review/1201-review-2026-06-17.md` | `apps/observatory/tmp/` is empty; repo-local glob `apps/observatory/tmp/pub-cache/**/pubspec.yaml` returned `0`; fresh `flutter test --no-pub ...` commands executed tests instead of failing on workspace resolution. |
| F2 | RESOLVED | Low | Closed after patch | The Task 1201 evidence is a valid dated 2026-06-11 baseline, but “current” wording could mislead readers after live counts drifted. | 2026-06-19 re-review | Patched `docs/reports/warp-prism-failure-baseline-inventory.md` and `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md` to mark the captured counts as historical/dated and record the 2026-06-19 rerun drift. |
| F3 | RESOLVED | Informational | Closed | Primary report count integrity remains reproducible from repo-local captured logs. | 2026-06-11 round 2 | `tmp/1201-test-output/ui-test.log:875`, `tmp/1201-test-output/observatory-test.log:1042-1049`, `tmp/1201-test-output/catalog-test.log:31`, `tmp/1201-test-output/cybercore-test.log:33`, and `docs/reports/warp-prism-failure-baseline-inventory.md:13-21`, `:91-106`, `:185-200`. |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md:1-64`, `:85-92`, `:133-149`, `:152-208`.
- **Primary inventory report**: `docs/reports/warp-prism-failure-baseline-inventory.md:1-208`.
- **Raw dated logs captured by Task 1201**:
  - `tmp/1201-test-output/ui-test.log:875` — `00:46 +854: All tests passed!`
  - `tmp/1201-test-output/observatory-test.log:1042-1049` — `00:40 +641 -12: Some tests failed.` plus 12 `[E]` lines in the log.
  - `tmp/1201-test-output/catalog-test.log:31` — `00:48 +10: All tests passed!`
  - `tmp/1201-test-output/cybercore-test.log:33` — `00:03 +12: All tests passed!`
- **Changelog evidence**: `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md:15-35`.
- **Taxonomy/governance**: `.agents/rules/promotion-state-model.md:65-76`; `.agents/rules/task-reference-policy.md:7-16`, `:72-89`.
- **Previous reports**: `docs/reports/build-gate-review/1201-review.md`, `docs/reports/build-gate-review/1201-review-round2.md`, `docs/reports/build-gate-review/1201-review-2026-06-17.md`.
- **Runtime wiring proof or non-runtime rationale**: no runtime wiring applies. Task 1201 creates and maintains Markdown governance/evidence only (`docs/reports/...`, `docs/changelog/...`, task ledger text). It does not add Dart code, routes, widgets, services, persistence, backend writes, or live orchestration; product runtime reachability is therefore irrelevant. The correct proof is report existence, dated raw-log/count consistency, taxonomy consistency, and changelog/task ledger evidence.

## Commands Run

```bash
git status --short && git diff --stat && git log --oneline -10
env HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub packages/warp_prism_ui/
env HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/catalog/
env HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/cybercore/
env HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/observatory/
python3 - <<'PY'
from pathlib import Path
root = Path.cwd()
paths = list(root.glob('apps/observatory/tmp/pub-cache/**/pubspec.yaml'))
print('nested_pub_cache_pubspecs=', len(paths))
logs = {
  'ui': root/'tmp/1201-test-output/ui-test.log',
  'observatory': root/'tmp/1201-test-output/observatory-test.log',
  'catalog': root/'tmp/1201-test-output/catalog-test.log',
  'cybercore': root/'tmp/1201-test-output/cybercore-test.log',
}
for name, path in logs.items():
    lines = path.read_text(errors='replace').splitlines()
    final = next((line for line in reversed(lines) if line.strip()), '')
    e_count = sum(1 for line in lines if line.rstrip().endswith('[E]'))
    print(name, 'lines=', len(lines), 'final=', final, 'E_lines=', e_count)
report = root/'docs/reports/warp-prism-failure-baseline-inventory.md'
rows = [line for line in report.read_text().splitlines() if line.startswith('| ') and '`apps/observatory/test/' in line]
print('inventory_observatory_rows=', len(rows))
PY
```

### Fresh 2026-06-19 Test Results

- `packages/warp_prism_ui/` ran and failed with `+862 -11`; output showed DSBadge golden mismatches and boundary-harness violation text. This is current workspace drift, not the old workspace-resolution blocker and not a Task 1201 regression.
- `apps/observatory/` ran and failed with `+646 -7`; this differs from Task 1201’s dated `+641 -12` capture.
- `apps/catalog/` ran and passed with `+14`; this differs from Task 1201’s dated `+10` capture.
- `apps/cybercore/` ran and passed with `+12`; unchanged by count.

## Commands Not Run And Why

- `flutter test` without `--no-pub`: intentionally not run to avoid network/package-resolution side effects. The safe rerun used the existing repository-local cache and `--no-pub`.
- `flutter analyze`, `dart format`, coverage, and Melos-wide scripts: not required for this inventory-only re-review and not safe/value-adding in the current dirty workspace.
- Shared index/tasklist rebuilds: explicitly not run per review instructions.

## Stale-Evidence Notes

- Task 1201’s 2026-06-11 inventory remains valid as a dated historical baseline because its report, raw logs, count reconciliation, taxonomy mapping, changelog, and task completion evidence agree internally.
- The 2026-06-17 blocker was not a Task 1201 content defect; it was a live workspace contamination problem. That blocker is now resolved.
- The live 2026-06-19 test counts differ from the Task 1201 baseline. This does not invalidate Task 1201, but current stabilization work must not cite the 2026-06-11 counts as today’s live baseline. If current counts matter, create a successor baseline rather than rewriting Task 1201’s dated evidence.

## Path To 100

Task 1201 is at 100 after this re-review’s narrow documentation/ledger patch. No return-to-doing remediation is required.

For future current-baseline work outside Task 1201:

1. Create a successor dated baseline report if the project needs a current monorepo failure inventory.
2. Keep generated caches outside workspace glob paths such as `apps/**` and `packages/**`.
3. Run the four package/app test commands with repository-local cache settings and persist raw logs under a task-specific repo-local `tmp/<task>/` directory.

## Task Ledger Patch Suggestion

Applied as a compact ledger entry in `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md`:

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 100/100 — ACCEPTED_100
**Verdict**: leave in `03-review`; no return to doing.
**Report**: `docs/reports/build-gate-review/1201-review-2026-06-19-rereview.md`
**Diagnostics**: previous nested pub-cache workspace blocker is resolved; fresh `flutter test --no-pub` reruns execute and show current baseline drift (UI `+862 -11`, Observatory `+646 -7`, catalog `+14`, cybercore `+12`) rather than workspace-resolution failure.
**Findings**:
- `RESOLVED`: 2026-06-17 external/evidence blocker under `apps/observatory/tmp/pub-cache` no longer exists.
- `RESOLVED`: Task 1201 report remains internally consistent as a dated 2026-06-11 historical baseline with 12 Observatory failures and zero UI/catalog/cybercore failures at capture time.
**Path to 100**: N/A for Task 1201; create a successor current baseline if live 2026-06-19 counts need governance tracking.
```
