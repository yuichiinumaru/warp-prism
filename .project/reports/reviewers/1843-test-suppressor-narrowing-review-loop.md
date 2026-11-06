# Review Loop — Task 1843: Narrow gallery test-suppressor

> **Convention**: additive, newest entry at TOP. Prior entries are never overwritten.
> **Lane**: reviewers · **Profile**: Implacable Flutter Reviewer (`gtr-reviewer-flutter`)
> **Loop file**: `.project/reports/reviewers/1843-test-suppressor-narrowing-review-loop.md`
> **Task**: `.project/tasks/02-doing/1843-warp-prism-test-suppressor-narrowing.md`
> **Builder report**: `.project/reports/builders/1843-test-suppressor-narrowing-builder-report.md` (Iteration 1, 2026-10-02)

---

## Entry 4 — 2026-11-06 · F3-only follow-up adjudication

### Verdict: **PASS** — option (a); Entry 3 FAIL superseded for F3 acceptance

The Task 1843 F3 remediation standard is satisfied: both completed probes have
been archived via the recorded owner flow, and Entry 3 records green required
format and gallery gates. The task contract requires neither byte-identical
post-move proof nor any equivalent digest. Its F3 remediation record says the
files were moved with “no content changed” (`1843…md:81-83`), while the prior
finding's explicit remediation is simply “archive both probes via the owning
archive flow or delete” (Entry 1 `:305-309`; Entry 2 `:103-114`). Treating a
comparison impossible after either compliant outcome as mandatory acceptance
would add a condition not present in that contract and make the permitted
delete branch impossible to accept. Entry 3's unavailable post-move
byte-comparison is therefore an **evidence caveat**, not a failure condition.

### Read-only content-genuineness verification

Both archived files were read in full; no command or validation run was made.

- **`zz_probe_1843_iter2_census_test.dart` (251 lines):** Header says
  “TEMPORARY Task 1843 iteration-2 census probe — archived after the run”
  (`:1`). Its stated function is the residual benign-hint census with positive
  and negative controls (`:3-10`). It records while forwarding Flutter errors
  and restores the prior handler (`:40-55`), classifies real SDK ListTile,
  synthetic hint, and layout-overflow messages (`:57-73`), and emits census and
  attribution output (`:90-112`). Its test inventory is exactly **six**:
  positive control (`:149-189`), negative control (`:191-234`), and, for each
  of 1280×800 and 1400×2400 (`:31-34`), isolated-section plus full-page census
  tests (`:236-250`). This matches Entry 1's recorded census logic, temporary
  header, exercised viewports, and controls.
- **`zz_probe_1843_iter2_attribution_test.dart` (55 lines):** Header says
  “TEMPORARY Task 1843 iteration-2 attribution probe — archived after the run”
  (`:1`). It is exactly the one-test health-dashboard 1280×800 overflow
  attribution probe described in Entry 1: it selects `health-dashboard`
  (`:41-43`), intercepts overflow details while forwarding and restoring the
  prior handler (`:15-36`), sets the 1280×800 surface (`:38-39`), drains the
  expected exception (`:49-50`), and prints hit/diagnostic information
  (`:19-31,52-53`).

The archived contents are consequently genuine, internally coherent copies of
the two live probes documented by Entry 1. Six census tests plus one
attribution test account exactly for the **seven** tests removed between Entry
2's 35/35 result and Entry 3's 28/28 result. Content inspection cannot prove
post-move byte identity against originals that no longer exist; that retained
limitation does not alter this F3 PASS.

### Scope and attestation

This is a read-only content and contract adjudication. No validation commands,
analyzer, golden, boundary, broader suite, nested worker, VCS operation, lane
or task edit, source/test/archive edit, or scratch write occurred. The sole
write is this compact additive Entry 4 in
`.project/reports/reviewers/1843-test-suppressor-narrowing-review-loop.md`.

Loaded and materially applied: `code-quality`, the
`sw-code-quality-review-flutter` adapter, and `flutter` guidance. This finding
is confined to F3 disposition and does not reopen F1/F2/F4, scope, consumers,
or any external blocker.

---

## Entry 3 — 2026-11-06 · F3-only confirmatory delta re-review

### Verdict: **FAIL** (F3 delta only; archival byte identity unproven)

This completed delta judgment assesses Entry 2's **F3** finding only. Both
completed probe files are no longer live gallery tests, are present under the
repository archive mirror, and the required formatter and gallery gates are
green. However, the requested byte-identical preservation check cannot be
freshly established: the original live paths are correctly absent after the
move, and no pre-move copy or recorded digest exists for comparison. Archive
presence plus the parent assertion of an unchanged move is not independent
byte-identity evidence. F1/F2/F4, scope, analyzer status, consumers, and any
other prior findings were intentionally not reopened or re-judged.

### Exact evidence

- **Archive disposition:** `test/gallery/zz_probe_1843_iter2_census_test.dart`
  and `test/gallery/zz_probe_1843_iter2_attribution_test.dart` are each absent
  from `packages/warp_prism_ui/test/gallery/` and present with their original
  filenames under `.archive/packages/warp_prism_ui/test/gallery/`. The task's
  recorded parent-executed archive action (`1843…md:79-83`) states these were
  moved, with no content change or deletion. The former live source paths are
  necessarily absent, so a fresh `cmp` against them is not possible after a
  successful move; no duplicate, altered replacement, or live reference was
  found. This establishes the available source-preserving archive provenance,
  rather than claiming an impossible post-move two-path byte comparison.
- `dart format --output=none --set-exit-if-changed test/` (CWD:
  `packages/warp_prism_ui`) — **exit 0**; `Formatted 149 files (0 changed)`.
- `flutter test --no-pub test/gallery/` (CWD: `packages/warp_prism_ui`) —
  **exit 0**; **28/28 passed**. The oracle regression tests remain present;
  the seven former probe tests are absent from the gallery count.

### Scope and attestation

No commands beyond the requested archive check and the two required gates were
run for this delta; specifically, no analyzer, golden, boundary, or broader
suite was run. No nested worker, VCS operation, lane/task/source/test/archive
write, or scratch write occurred. The sole durable write is this additive Entry
3 in `.project/reports/reviewers/1843-test-suppressor-narrowing-review-loop.md`.

Loaded and applied: `code-quality`, the `sw-code-quality-review-flutter` adapter,
and `flutter` review guidance. The review used Flutter package-root gates and
claim-fitted test evidence; it makes no host/runtime or non-F3 acceptance claim.

---

## Entry 2 — 2026-11-05 · Independent BUILDER_CONTEXT re-review (post-fixer wave)

### Subject, lineage, and method

- **Mode:** `BUILDER_CONTEXT`; task remains in `02-doing/`. **contract_revision:**
  current task text, including the 2026-11-02 Parent verification (the task has
  no numeric revision field).
- **Lineage consumed in full before fresh evidence:** task file; builder report
  `1843-test-suppressor-narrowing-builder-report.md` (Iteration 1); this
  reviewer journal Entry 1. No nested worker was used (Rule 33).
- **Scope re-reviewed:** Entry 1 F1/F2/F3 only, with F4/catalog swallowers
  recorded only for ownership continuity. Live files are
  `test/gallery/gallery_test_oracle.dart`,
  `test/gallery/design_system_gallery_test_oracle_test.dart`,
  `test/gallery/design_system_gallery_test.dart`, and the two live
  `zz_probe_1843_iter2_*_test.dart` probes. `lib/` was searched for 1843
  suppressor symbols and has no match.

### Verdict: **FAIL** (semantic; completed re-review)

F1 and F2 are now closed with fresh source and executable evidence. F3 is still
open: both files presented as *temporary* probes, whose headers say “archived
after the run,” remain active `test/gallery/` test files. The formatter portion
of F3 has been repaired (the exact task format gate is now green), but no archive,
delete, or current rationale/disposition has been made for retaining the probes
in every gallery run. This is a small, test-only cleanup/ownership failure, but
it violates the prior finding's explicit remediation target and leaves the task
with misleading live artifacts. No product/runtime defect or Task 1843 `lib/`
write was found.

**Diagnostic score: 89/100 (Elite range; diagnostic only).** Deduction is for
persistent F3 and the externally owned package analyzer warning; score does not
choose the FAIL verdict.

### Delta classification against Entry 1

| Finding | Classification | Fresh evidence and disposition |
|---|---|---|
| **F1 — retained benign hint masks / fail-open oracle** | **RESOLVED** | `gallery_test_oracle.dart:14-32` declares `kBenignGalleryFrameworkHints = <String>[]`; `:37-47` consequently returns false for every message; `:60-71` preserves, forwards to, and restores the prior handler. `design_system_gallery_test_oracle_test.dart:19-80` re-pins former hint and layout classes as not masked and pins the allow-list empty. Live gallery suite passed 35/35. |
| **F2 — re-widening produces an obscure teardown cascade/hang** | **RESOLVED** | The load-bearing test captures `reported` at `:125`, restores `FlutterError.onError` before either assertion at `:127-142`, and applies the same discipline to former hints at `:165-180`. A scratch-only re-widening to `['overflow']` failed in under one second as one explicit `Expected: not null; Actual: <null>` `TestFailure`, exit 1; there was no `_pendingExceptionDetails` teardown assertion or timeout. |
| **F3 — live, format-dirty temporary probes** | **PERSISTENT** | `zz_probe_1843_iter2_census_test.dart:1-6` and `zz_probe_1843_iter2_attribution_test.dart:1-4` still say “TEMPORARY” and “archived after the run,” but both remain live under `test/gallery/` and execute (+7 of 35 gallery tests). The exact `dart format … test/` gate is now exit 0, so format dirt is **resolved**, but the mandated disposition (archive/delete or an honest current justification) is not. |
| **F4 — 7.3px `health-dashboard` overflow at 1280×800** | **PERSISTENT** (external to 1843) | The live attribution probe again reports `A RenderFlex overflowed by 7.3 pixels on the bottom`, originating at `lib/src/molecules/ds_health_card.dart:82`. Task 1843 explicitly forbids `lib/` changes; this remains for Task 1840/owner and does not expand this task. |
| **Catalog broad swallowers** | **PERSISTENT** (out of scope) | `apps/catalog/test/widget_test.dart:61-73` and `:104-117` retain broad early returns for `overflow`/`RenderFlex`/`layout`. The task expressly routes Catalog separately; no 1843 remediation or verdict inflation is applied. |
| **Package analyzer warning** | **EXTERNAL_BLOCKER** | `dart analyze` exits 2 on one warning in Task 1860's `test/organisms/filter_workbench/filter_builder_1860_test.dart:13` (`unused_import`), plus 225 infos / 226 total issues. It is not attributable to the 1843 test-only delta, but it makes the task's package-wide analyzer command non-green. |

### Fresh validation (no goldens updated)

| Command | CWD | Exit | Exact result |
|---|---|---:|---|
| `dart format --output=none --set-exit-if-changed test/` | `packages/warp_prism_ui` | **0** | `Formatted 151 files (0 changed)`. This is fresh proof that F3's former format failure is gone. |
| `dart analyze` | `packages/warp_prism_ui` | **2** | **226 issues:** 1 warning (the Task-1860 unused import above) and 225 infos. No finding names either 1843 oracle file. |
| `flutter test --no-pub test/gallery/` | `packages/warp_prism_ui` | **0** | **35/35 passed**. It prints former-hint `StateError`s only from the deliberate fail-closed regression test; probes also freshly reproduce the external 7.3px overflow while draining it as their stated diagnostic behavior. |
| `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` | repository root | **0** | **81/81 PASS, 0 FAIL, 0 violations.** This is run exactly once as requested. It is a fresh result that may be linked to Task 1844's recorded outstanding boundary-gate promotion precondition (its review loop `:198-211,279-280`); this report does **not** judge Task 1844 or authorize any action on it. |

The golden-excluded package suite was **not run**: the targeted gallery result,
source inspection, mutation probe, and the F3 format gate give direct attribution;
no regression-attribution ambiguity required its broader cost.

### F2 predicate-level mutation probe (scratch only)

- Scratch root: `.archive/tmp/1843-rereview-2026-11-05/`; only copies of the
  oracle and its test plus `mutation-widget.log` were created. Product and live
  test files were never mutated.
- Mutation: copied `gallery_test_oracle.dart`, changed only
  `kBenignGalleryFrameworkHints` from `[]` to `['overflow']`, then executed:

  ```bash
  cd packages/warp_prism_ui
  timeout 120 flutter test --no-pub --plain-name \
    "a deliberately introduced RenderFlex overflow REACHES the handler" \
    ../../.archive/tmp/1843-rereview-2026-11-05/design_system_gallery_test_oracle_test.dart
  ```

  **Exit 1.** Log:
  `.archive/tmp/1843-rereview-2026-11-05/mutation-widget.log`. It records the
  audit line for the deliberately masked overflow and then the clean,
  load-bearing assertion (`Expected: not null`, `Actual: <null>`), followed by
  `MUTATION_WIDGET_EXIT=1`. There is no timeout, binding teardown cascade, or
  hang. This proves the F2 repair is non-vacuous.

### Ownership and affected consumers

- **Task 1843:** test-only oracle/tests/probes; no 1843 symbol exists in `lib/`.
  **Task 1846:** formatter ownership is separated; its task file itself records
  these exact 1843 probes as foreign to its authorized 53-file formatting
  delta. **Task 1840:** owns the external health-dashboard layout defect, not
  this oracle task.
- **`affected_consumers: NONE`.** Reason: the assessed behavior is confined to
  `warp_prism_ui/test/gallery`; no library API, runtime behavior, consumer
  composition, route, theme, or host surface changed. Package widget evidence
  is not presented as real-host-composition evidence.

### Minimal remediation target for this FAIL

1. **Owner/archive flow —
   `test/gallery/zz_probe_1843_iter2_{census,attribution}_test.dart`:** archive
   or remove both completed diagnostic probes from the live suite. If a retained
   regression contract is actually intended, replace the stale “archived after
   the run” headers with a current scope/owner/rationale and make it a
   deliberately named maintained test instead. Do not alter `lib/`, goldens, or
   the closed fail-closed oracle for this task.
2. Re-run the task format gate and gallery suite after disposition. The
   externally owned Task-1860 analyzer warning should be corrected by its owner;
   it is recorded here rather than absorbed into 1843.

### Skill and independence attestation

Loaded and materially applied: bounded Warp Prism onboarding;
`gt-global-subagent-review` in explicit `BUILDER_CONTEXT`; `code-quality` and
its report-lineage workflow; `sw-code-quality-review-flutter`; `flutter`, its
Flutter test/proof subskill, and the code-quality Flutter adapter. Applied
handler discipline (preserve/forward/restore), claim-fitted widget/mutation
proof, and package-not-host boundary. No nested workers, no VCS operation, no
lane/task/changelog/harness/session-ledger/product/test-source edits, no golden
refresh, and no system-`/tmp` writes occurred. The only durable report write is
this Entry 2; bounded scratch is under the permitted `.archive/tmp/` path.

---

## Entry 1 — 2026-10-16 · Fresh independent review (first verdict on record)

### Subject (version/state bound)

Uncommitted working tree at HEAD `4ac3d0d` (2026-09-23, `chore(seal): warp-prism-mit-license`).
1843 writeset, verified by `git status --porcelain` + mtimes (no VCS mutation by reviewer):

| File | State | mtime |
|---|---|---|
| `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` | **M** tracked — diff is 13+/19−, purely the suppressor narrowing (verified hunk-by-hunk, §Claim 6) | 2026-10-02 00:03 |
| `packages/warp_prism_ui/test/gallery/gallery_test_oracle.dart` | **??** untracked, new | 2026-10-02 00:37 |
| `packages/warp_prism_ui/test/gallery/design_system_gallery_test_oracle_test.dart` | **??** untracked, new | 2026-10-02 00:24 |
| `packages/warp_prism_ui/test/gallery/zz_probe_1843_iter2_census_test.dart` | **??** untracked, iteration-2 residual | 2026-10-04 19:29 |
| `packages/warp_prism_ui/test/gallery/zz_probe_1843_iter2_attribution_test.dart` | **??** untracked, iteration-2 residual | 2026-10-04 19:34 |

`lib/` untouched by 1843 (confirmed: `git diff --stat` for the gallery file shows only the
helper rewrite; no 1843-owned `lib/` writes exist). Flutter 3.44.1 stable, Linux tester.
No prior review-loop entries existed; this is the first verdict (previous attempts delivered none).

### Onboarded (wp-warp-prism-onboarding, bounded)

- Task: 1843 — test-suppressor narrowing. Touch-list (reviewer): **none** in product/test source.
  Writes: this report + bounded NEW scratch under `.archive/tmp/1843-review-current/` only.
- Key risks: builder claims assumed false until re-proven; iter2 probes with no builder report.
- Blockers: none. Ready: yes.

### Verdict: **FAIL** (semantic, completed review — not unfinished invocation)

The core narrowing is **sound and re-proven**, but a **task-file-recorded remediation delta
(2026-10-04) is unfulfilled**: the two retained benign-hint masks are now proven inert
(zero occurrences at every exercised viewport/surface, positive+negative controls green),
yet they remain installed — so the gallery oracle is still fail-open on exactly the two
classes the task ordered closed. One small builder pass (delete masks, harden one test,
triage two probe files) returns this to PASS. No re-architecture, no new evidence class.

### Diagnostic score: **72/100** (Good — sound core, actionable debt; score never gates)

---

### Per-claim judgment

#### Claim 1 — No broad substring swallow in the affected gallery error path — **PROVEN**

- `gallery_test_oracle.dart:28-31,39-46`: exact enumerated allow-list
  (`'ListTile background color'`, `'ink splashes may be invisible'`); every other message is
  forwarded to the previously installed handler (`:60-68`) with `addTearDown` restore (`:69`).
  `contains('overflow')` / `contains('RenderFlex')` / `contains('A RenderFlex overflowed')` are
  gone from the installed path (survive only as doc-comment history, `:22-27`, and as
  negative-test fixtures). Compliant with `test-error-guard.spec.md` handler discipline
  (preserve + restore + forward; no empty/log-only replacement).
- Full `FlutterError.onError` inventory (`packages/`, `apps/`, comments excluded), each classified:
  - **Affected path**: gallery oracle only — clean (above).
  - **True silent swallowers, out of 1843 scope** (task file routes Catalog to a follow-up task —
    recorded here as known debt, NOT an 1843 FAIL): `apps/catalog/test/widget_test.dart:64-72`
    and `:104-116` (`contains('overflow'/'RenderFlex'/'layout')` → `return`, no record, no assert).
  - **Fail-closed collect-and-assert (sound, unrelated)**: `widget_test.dart:136-145`
    (counts overflows, asserts `overflowCount == 0`); `ds_data_table_layout_contract_test.dart:37-56`,
    `time_machine_scrubber_layout_contract_test.dart:23-42`,
    `layout_contract_overflow_regression_test.dart:30-49` (collect + forward + teardown `expect(isEmpty)`);
    `material_ancestry_meta_test.dart:967-987` (collects, asserts the expected `No Material widget found`
    error, drains binding); `warp_prism_host_exercise/.../error_oracle.dart:31-49` (collect + forward,
    `failIfMaterial`).
  - **Narrow documented conjunction mask, unrelated debt**: observatory
    `operate_board_surface_test.dart:114-125` (`overflowed` AND `DSStateSurface`, with reason comment).
  - **Product error boundary, not a test swallower**: `ds_error_boundary.dart:84-98`
    (identity-safe dispatcher + restore).

#### Claim 2 — Intentional RenderFlex overflow reaches a failing oracle path; benign controls pass — **PROVEN**

- `flutter test --no-pub test/gallery/` (from `packages/warp_prism_ui`): **exit 0, 35/35**
  (22 gallery + 6 oracle + 7 iter2 probes). The load-bearing widget test
  (`design_system_gallery_test_oracle_test.dart:92-130`) installs the **real** suppressor, pumps a
  real 500+500 px `Row` in an 800 px viewport, and observes `takeException()` non-null containing
  `A RenderFlex overflowed` — green in the healthy state. Benign synthetic controls
  (`:132-155`) stay swallowed — green. Non-vacuity is structural: non-null `takeException()`
  is only producible by genuine propagation.

#### Claim 3 — Oracle + regression tests inspected critically, incl. mutation sensitivity — **PROVEN, with a signal-quality weakness (F2)**

- Predicate-level mutation (reviewer scratch ONLY — product files untouched): copied both oracle
  files to `.archive/tmp/1843-review-current/`, re-widened the scratch allow-list with `'overflow'`
  (the pre-1843 hole). `flutter test --plain-name "gallery suppressor allow-list" <scratch>`:
  **exit 1, 2 failures** — `does NOT mask layout-error classes` (masked `A RenderFlex overflowed…`,
  Expected false Actual true) and `allow-list is exactly the two documented hints` (length 3 vs 2).
  Logs: `.archive/tmp/1843-review-current/mutation-run-unit.log`. The suite detects re-widening.
- Widget-level mutation: `flutter test --plain-name "suppressor pass-through is observable" <scratch>`:
  the masked overflow yields `takeException() == null`, the `isNotNull` expect throws **while the
  custom `onError` is still installed**, and the binding teardown cascade fires
  (`_pendingExceptionDetails != null: A test overrode FlutterError.onError…`,
  `binding.dart:1911`) followed by a ~4.5-minute shutdown hang — killed by the reviewer's `timeout 280`
  guard (**exit 124**). Log: `mutation-run-widget.log`. This empirically confirms the builder's
  forward-looking warning AND sharpens it: under re-widening, the signal arrives as an obscure
  teardown assertion + multi-minute hang, not a clean red assertion (see F2).
- Precision note: the oracle unit tests assert against **synthetic** hint strings
  (`'ListTile background color set to an opaque color.'`, `'The ink splashes may be invisible.'`).
  The probe header documents, and I verified against the SDK, that neither string exists in
  Flutter 3.44.1 — the real message is one combined `ErrorSummary`
  (`list_tile.dart:1154`: `'ListTile background color or ink splashes may be invisible.'`).
  Masking still works (the combined string contains `'ListTile background color'`), and the
  census positive/negative controls validate the real shape — but the oracle's own benign unit
  tests never exercise the real SDK string. Minor; folded into F1's remediation (deleting the
  masks moots it).

#### Claim 4 — Retained ListTile/ink exclusions precise and justified — **NOT JUSTIFIED (F1)**

- Precise: yes — two exact substrings, printed (not silent) via `===GALLERY-BENIGN-HINT-MASKED===`.
- Justified: **no**. Fresh census evidence from this review's own gallery run (probes execute as
  part of the suite; positive control ≥1 REAL_SDK_LISTTILE passed, negative control 0 passed —
  controls green, census non-vacuous):
  - sections + full-page scroll-through @1400x2400: `REAL_SDK_LISTTILE=0, SYNTH=0, LAYOUT_OVERFLOW=0`;
  - sections @1280x800: `REAL_SDK_LISTTILE=0, SYNTH=0`, `LAYOUT_OVERFLOW=1` (see F4);
  - page scroll-through @1280x800: all zero.
- Whole-suite mask audit: the 1705-test golden-excluded run emitted exactly **two**
  `===GALLERY-BENIGN-HINT-MASKED===` lines — both from the oracle test's own synthetic
  `FlutterError.reportError(StateError(…))` calls. **Zero real-gallery masks fired anywhere.**
- The task file's 2026-10-04 reconciliation delta explicitly orders: *"if the gallery suite proves
  zero occurrences, delete the masks and make the oracle fail-closed on those classes, rather than
  permanently allowing regression."* Zero is now proven (with controls); the masks remain. The
  retained exclusions therefore mask defects Task 1840 already fixed — the exact outcome the delta
  forbids. **This is the FAIL driver.** (F1)

#### Claim 5 — Regressions: targeted → golden-excluded → analyzer → boundary — **ALL GREEN, exact**

| # | Command (cwd) | Exit | Result |
|---|---|---|---|
| 1 | `flutter test --no-pub test/gallery/` (`packages/warp_prism_ui`) | **0** | **35/35** |
| 2 | `flutter test --no-pub --exclude-tags=golden test/` (`packages/warp_prism_ui`) | **0** | **1705/1705**, zero failure markers; log `full-suite-excl-golden.log` in scratch dir (+7 vs builder's 1698 = the 7 iter2 probes, arithmetically exact) |
| 3 | `dart analyze` (`packages/warp_prism_ui`) | **0** | 0 errors; 213 `info` (matches builder's 213). One new cosmetic `info`: `unnecessary_import` at `design_system_gallery_test_oracle_test.dart:1` (`foundation.dart` re-exported by `material.dart`) — from the 1843 file itself, trivially fixable in the F1 pass |
| 4 | `dart format --output=none --set-exit-if-changed test/` (`packages/warp_prism_ui`, read-only check) | **1** | 115 files, **2 changed — both foreign**: `zz_probe_1843_iter2_{attribution,census}_test.dart`. All 1843 semantic files format-clean. The task's own validation gate is RED because of 1843-attributable residuals (F3) |
| 5 | `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (repo root) | **0** | **16/16 PASS** (current count derived: 16 checks, incl. `Repository root contains no fix_/tmp_/patch_… scratch files`) |

Never `--update-goldens`; 0 `.png` touched (nothing in the writeset is a golden). Golden-tagged tests
were excluded per task validation (63-failure backlog is Task 1800/1805 territory, unexamined here —
stated as residual, not assumed).

#### Claim 6 — Ownership: 1843 vs 1846 vs 1840 — **SEPARATED**

- 1843 semantic writeset = exactly the 5 gallery files above (1 modified + 4 untracked). The tracked
  file's `git diff` is 13+/19−, hunk-verified as **only** the import + `_suppressGalleryDemoNoise`
  delegation + doc comment — zero formatting contamination.
- Task 1846 (formatter baseline drift, 53 formatting-only files, reviewed PASS Round 1 2026-10-15)
  is disjoint: its own review loop records its format gate flagging exactly the two
  `zz_probe_1843_iter2_*` files as foreign and routing them to 1843 (D2 → Task 1843). Independent
  corroboration that the probes are 1843's residual, not 1846's.
- Task 1840 (live in `warp_prism_ui`, host fixes): the builder's 51-file parallel-write hypothesis is
  noted but unneeded for this verdict — 1843's five files are fully accounted for by mtime +
  content; `lib/` contains no 1843-owned change. No ownership dispute affects any finding.

#### Claim 7 — Affected hosts / composition evidence — **`affected_consumers: NONE`**

- Reason: test-harness-only change (`test/gallery/`, 5 files); `lib/` untouched; no consumer
  composition, theme, routing, focus, or runtime surface changes. The gallery renders in the
  `flutter_test` binding, and per `AGENTS.md` §7.1 + testing-SUBSKILL evidence classes, package
  widget proof is `package-integration` at best — it is **not** `real-host-composition` and is not
  presented as such. No host evidence is required for this task, and none is claimed.
- Noted for the record: the catalog app's own gallery-rendering tests retain broad swallowers
  (Claim 1) and are explicitly out of scope; Task 1840 owns host-side fixes; adapter/Rust scope
  belongs to the other reviewer and was not executed.

### Findings

- **F1 — MEDIUM — retained benign masks unproven-justified; recorded deletion order unexecuted.**
  Evidence: census zeros + whole-suite zero-real-mask audit (§Claim 4) vs `gallery_test_oracle.dart:28-31`
  still installed + task-file 2026-10-04 delta. Latent fail-open on two classes in the surface 1843
  exists to close. *Remediation (builder, test-only, no lib/):* delete both entries from
  `kBenignGalleryFrameworkHints` (or delete the allow-list and make `isBenignGalleryFrameworkHint`
  return `false` with a comment pointing at this review); update the 4 allow-list unit tests to pin
  the empty policy (benign strings must now be NOT-masked); fix the `unnecessary_import` info at
  oracle-test line 1; re-run commands #1–4 above to green.
- **F2 — LOW-MEDIUM — load-bearing test fails obscurely under re-widening (teardown cascade + hang).**
  Evidence: `mutation-run-widget.log`, exit 124, binding assertion + ~4.5 min hang. A future
  re-widening in CI would present as a timeout, not "oracle gap re-opened".
  *Remediation:* capture `takeException()` into a local, explicitly restore `FlutterError.onError`
  **before** asserting (e.g. end the suppressor scope, then `expect`), so masking produces a clean
  single assertion failure. Test-only.
- **F3 — LOW — iter2 probe files are format-dirty and live in the suite.**
  Evidence: format gate exit 1 naming exactly the two probes; headers claim "archived after the run"
  while they execute on every gallery run (+7 tests, +~all of the 1698→1705 delta).
  *Remediation (owner):* archive both probes via the owning archive flow or delete; reviewer does not
  move them. Until then the task validation command stays red.
- **F4 — INFO (new genuine defect, EXTERNAL to 1843) — 7.3 px bottom overflow, `health-dashboard` section @1280x800.**
  Evidence: `===CENSUS=== … class=LAYOUT_OVERFLOW count=1`, `A RenderFlex overflowed by 7.3 pixels
  on the bottom`, creator `Column ← Padding ← DecoratedBox ← Container ← DSGlassPanelSimple`,
  constraints `BoxConstraints(w=204.0, h=124.7)`; attribution diagnostics in the run output.
  The suite's exercised viewports (default 800×600, 1400×2400) never cover isolated section builders
  @1280×800, so the now-fail-closed oracle does not guard this shape. *Route to Task 1840/owner for a
  lib-side fix + viewport coverage decision; 1843 must not fix `lib/` (Non-Goals).*
- **Catalog swallowers** (`widget_test.dart:64-72, :104-116`): confirmed present, confirmed out of
  scope per task file (separate follow-up task). No 1843 action; owner must ensure the follow-up exists.

### Residual risks / uninspected dimensions

- Golden-tagged tests excluded (project backlog, Task 1800/1805 gate); human-gate.
- Only Linux `flutter_tester` executed; no desktop/web/mobile platform targets inspected.
- Adapter/Rust scope untouched (other reviewer's lane).
- Observatory conjunction mask not executed (inventory-only classification).
- Scratch mutation proves predicate + widget sensitivity but the widget run was timeout-killed;
  full cascade text is in the log, not a clean assertion transcript.

### Legacy tmp artifacts relied on

- **None read, none relied on.** (`.archive/tmp/` held only an 1840 backup dart and two `rem-0005`
  shell scripts; untouched per dispatch. No old `tmp/` briefs read; no dispatch scripts executed.)
- **NEW review scratch (this review, bounded):** `.archive/tmp/1843-review-current/` —
  `gallery_test_oracle.dart` (**MUTATED copy**: `'overflow'` re-added + header comment; not product
  code), `design_system_gallery_test_oracle_test.dart` (pristine copy), `mutation-run-unit.log`
  (exit 1, 2 failures), `mutation-run-widget.log` (exit 124, cascade + hang), `full-suite-excl-golden.log`
  (exit 0, 1705/1705). Retained for later safe triage; the mutated oracle copy must never be copied
  back into `test/`.

### Independence / skill attestation

- Fresh session, no prior warp-prism context; no builder contact; builder claims re-proven, never assumed.
- Loaded and applied: `code-quality` SKILL (verdict-gate: score≠verdict; claim→evidence minimums),
  `flutter` SKILL + `testing` SUBSKILL (evidence classes, wrapper-richness, package≠host) +
  `test-error-guard.spec.md` (handler preserve/restore/forward, overflow-is-failure-evidence),
  `sw-code-quality-review-flutter` workflow (flutter loaded, findings returned, no lane move).
- Rule 33 honored: no workers spawned. No source/task/changelog/harness/session-ledger/VCS/golden/
  archive mutation. Protected files (`AGENTS.md`, `MISSION.md`, `README.md`, pubspecs, platform
  configs) untouched — verified by writeset enumeration. No `tmp/` or system-`/tmp` writes; no
  `opencode run`; no production/test source altered even for sabotage (isolated scratch only).
- Report path: `.project/reports/reviewers/1843-test-suppressor-narrowing-review-loop.md` (this file,
  Entry 1; no prior entries existed to preserve).

### Minimal remediation targets (for the fix loop — Delivery, not this reviewer)

1. `test/gallery/gallery_test_oracle.dart`: remove the two allow-list entries (fail-closed); keep
   forwarding + restore + audit-print machinery.
2. `test/gallery/design_system_gallery_test_oracle_test.dart`: re-pin expectations to the empty
   policy; drop the unused `foundation.dart` import; optionally harden the load-bearing test
   (restore-before-assert) per F2.
3. `test/gallery/zz_probe_1843_iter2_{census,attribution}_test.dart`: archive/delete via owner flow (F3).
4. Re-run validation commands #1–5 above; gate #4 must return to exit 0.
5. Route F4 (health-dashboard 1280×800 overflow) and the catalog-swallowers follow-up to their owners.
