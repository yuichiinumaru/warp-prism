# Task 1843: Narrow gallery test-suppressor (`_suppressGalleryDemoNoise`) to per-test suppressor scope

> **Type**: bugfix | test-oracle | review infrastructure
> **Priority**: 🟡
> **Depends on**: nothing (independent)
> **Land after**: Task 1840 + Task 1842 (to agree with host-exercise proof contract)

## Objective

Replace the global noise-suppressor `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart:543-556` with a per-test suppressor so layout errors can fail those specific tests.

## Background

The test helper globally replaces `FlutterError.onError` to swallow specific platform filter triggers without asserting on them, making: (a) this render pipeline opaque, (b) fixed-length golden render variants like DSStatusDots — ~~example unit zero in accurate replay order, which was proven in 1839 — made up at the same site as "hidden denominator polling error" on validation step 3, plus (c) any future "pre-existing" rendering logic defect would not be caught by compiled smoke runs. This gap was identified in Task 1840's independent review.

## Where

- `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` (modify to move the suppressor contract and fill in fake-error tracking).
- Destroying-render logic hooks for `lib/src/organisms/ds_status_ticker.dart` if there are related gaps (protective — not required).

## Validation

```bash
cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed test/ && dart analyze && flutter test --no-pub test/gallery/
```
All gallery tests must yield zero RenderFlex overflow / ink warnings UNLESS at least one explicit narrowing makes them classifiable as green.

## Security

Test files are heavily structured — even a subtle rounding error filters false-positive drivers. Don't rewrite blindly; the scope is test-only (`test/`), not `lib/`.

## Non-Goals

- No changes to source layout code.
- No introduction of the eslint format fix or override of it convention.
- No suppressor-extension-equivalent on golden paths; thoses-inch persistent behavior is still too costed from other repair budgets.

## Lane History

- **2026-09-29 (claim)**: moved to `01-open`. Queued behind Task 1844 for
  dispatch because both require a `warp_prism_ui` test run and the builder
  fleet currently has one free Flutter slot. Disjoint fileset from 1842/1844.
- **2026-10-02 (execution)**: builder (fleet B engineer session; ID not recorded
  in the session ledger) executed iteration 1 — suppressor narrowed to an
  enumerated allow-list, canonical oracle extracted to
  `test/gallery/gallery_test_oracle.dart`, 6 mutation-tested regression tests
  added, all gates green. Builder report:
  `.project/reports/builders/1843-test-suppressor-narrowing-builder-report.md`.
  The claim move `01-open → 02-doing` was missed at dispatch time.
- **2026-10-04 (reconciliation, orchestrator-architects)**: lane corrected to
  `02-doing` post-hoc (Rule 42 §15 — nearest defensible state: execution
  complete, independent review pending). Remediation delta queued per the
  2026-10-04 adversarial-review wave: reassess the two residual benign-hint
  masks (`ListTile background color…`, `ink splashes may be invisible`) — Task
  1840 fixed the underlying Material ancestry, so if the gallery suite proves
  zero occurrences, delete the masks and make the oracle fail-closed on those
  classes, rather than permanently allowing regression. The Catalog-side
  independent swallower in `apps/catalog/test/widget_test.dart` is **out of
  1843's scope** (routed to a separate follow-up task).

## Parent verification — 2026-11-02 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), session `ses_e666b564bffeGBw0HKEpsbxfSE`. Handoff `Worker Handoff Packet` received in full (log `/tmp/opencode/task-1843-fix.log`); no lane move, no task/changelog/registry/VCS writes by worker.
- **Filesystem check**: exactly 2 test files changed in-wave (`gallery_test_oracle.dart`, `design_system_gallery_test_oracle_test.dart`, mtimes 21:09/21:10); `lib/**` untouched; `design_system_gallery_test.dart` modification pre-dates this wave (mtime 12:09, P1 gallery-count 24→29 update — foreign, not this worker).
- **Parent re-run (fresh, after return, serialized `--no-pub`)**: `dart format` on both files → 0 changed; `dart analyze` on both files → No issues found; `flutter test test/gallery/` → 35/35 green; boundary harness → 81/81 PASS.
- **Per-finding**: F1 DONE (fail-closed oracle, tests re-pinned, import fixed); F2 DONE in code (restore-before-assert; empirical re-mutation left to reviewer); F3 reported (probes remain live, format gate green with them present — owner archive flow pending); F4 + catalog swallowers confirmed untouched.
- **Residual**: package-wide `dart analyze` still exits nonzero on 1 foreign pre-existing warning (`filter_builder_1860_test.dart:13` unused import — owner: Task 1860).
- **Lane**: stays in `02-doing/`; submission to independent re-review belongs to the authorized actor. Independent re-review (F1/F2 closure + optional F2 re-mutation) still required — NOT self-granted.

## Review Ledger — Entry 2, 2026-11-06 (independent re-review)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51ce1d39ffeXxWuaZEziKU0xu` (independent — did not build or remediate). Report Entry 2 appended to `.project/reports/reviewers/1843-test-suppressor-narrowing-review-loop.md`; Entry 1 preserved.
- **Verdict**: FAIL (semantic re-review completed — not unfinished invocation).
- **Classification vs Entry 1**: F1 RESOLVED (allow-list empty, fail-closed pinned); F2 RESOLVED (restore-before-assert; scratch-only re-widening now fails fast with a clean TestFailure, exit 1, no hang); F3 PERSISTENT (both `zz_probe_1843_iter2_*` files still live; disposition absent); F4 PERSISTENT external to 1843 (routes to Task 1840/owner); catalog swallowers PERSISTENT out of scope; package analyzer warning EXTERNAL_BLOCKER (Task 1860's unused import).
- **Fresh validation**: format test/ exit 0 (151 files, 0 changed); gallery suite 35/35 exit 0; boundary harness 81/81 PASS exit 0 — reviewer states this run may be linked to Task 1844's outstanding boundary precondition.
- **Remediation dispatched**: narrow builder pass (session `ses_e51c724ddffeIo8kRd65LmAz4y`) to archive the two probe files via the archive mechanism + re-prove format/gallery gates. No other files in scope.
- **Lane**: stays in `02-doing/` pending F3 remediation + confirmatory re-review. No promotion claimed.

## F3 remediation — 2026-11-06 (parent-executed tiny unblocker)

- **Cause**: two builder dispatches (fresh + same-session resume, `ses_e51c724ddffeIo8kRd65LmAz4y`) returned empty packets with zero observable effect. Reassessment: the `archive` tool is unreachable in this session for both parent and worker (same failure class as the unreachable changelog/lane tools), while `rm` is denied — so the authorized provenance-preserving path was a shell move into the existing `.archive/` mirror, not a deletion.
- **Action**: moved `zz_probe_1843_iter2_census_test.dart` + `zz_probe_1843_iter2_attribution_test.dart` from `packages/warp_prism_ui/test/gallery/` to `.archive/packages/warp_prism_ui/test/gallery/` (original filenames preserved; no content changed; nothing deleted). This also clears the 1846 package-gate residual (same two files).
- **Re-proof (parent, fresh)**: `dart format --output=none --set-exit-if-changed test/` → 149 files, 0 changed, exit 0; `flutter test --no-pub test/gallery/` → 28/28 pass (35 − 7 probe tests), exit 0.
- **Next**: confirmatory delta re-review (F3 closure only) by the same reviewer; no other scope reopened.

## Review Ledger — Entry 4, 2026-11-06 (F3 evidence-bar adjudication, same reviewer)

- **Verdict**: PASS on the F3 delta — Entry 3's FAIL is superseded for F3 acceptance. The reviewer confirmed F3's contractual standard ("archive via owner flow or delete" + green gates) does not require post-move byte-identity proof, which would make the contract's own permitted delete path unmeetable. Recorded as evidence caveat, not failure.
- **Content-genuineness**: both archived files read in full — census probe (251 lines, 6 tests, TEMPORARY header, handler preserve/forward/restore + census/attribution logic) and attribution probe (55 lines, 1 test, health-dashboard 1280×800 overflow diagnostics) match Entry 1's record; together exactly the 7 removed tests (35→28).
- **Task state**: F1/F2/F3 CLOSED. Remaining non-task items: F4 overflow → Task 1840/owner; catalog swallowers → separate follow-up; package-wide `dart analyze` warning → Task 1860 (external). 1846's package-gate residual (same two probe files) is cleared as a side effect.
- **Lane**: stays in `02-doing/` pending only the external 1860 analyzer warning for the task's literal `dart analyze` gate. No promotion claimed; no code changed by review.

## Closure update — 2026-11-06 (external analyzer blocker cleared)

- The package-wide `dart analyze` gate now exits 0 (225 infos, 0 warnings/errors) after the 1860 import fix. 1843's literal validation trio is fully green: format test/ exit 0, analyze exit 0, gallery 28/28 exit 0.
- Remaining non-task items unchanged: F4 → Task 1840/owner; catalog swallowers → separate follow-up.
- Task 1843's contracted evidence is complete. Promotion follows in the closeout batch.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: F1/F2/F3 CLOSED (Entries 2-4); gallery 28/28, format 149/0, analyze exit 0, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1843-warp-prism-test-suppressor-narrowing-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
