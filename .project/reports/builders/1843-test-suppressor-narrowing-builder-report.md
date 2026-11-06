# Builder Report — Task 1843: Narrow the gallery test-suppressor

> **Convention**: additive, newest entry at TOP. Prior entries are never overwritten.
> **Lane**: builders · **Role**: gt-builders-engineer-flutter (fleet B)
> **Date**: 2026-10-02 · **Task**: `.project/tasks/01-open/1843-warp-prism-test-suppressor-narrowing.md`
> **Status**: `completed` — suppressor narrowed, oracle gap closed, all
> validations green.
> **Not self-accepted. No lane move. No task-file edit. No golden refresh.**

---

## Iteration 1 — 2026-10-02 · suppressor narrowed + regression proof

### Headline finding: the old suppressor masked **nothing** — it was inert

The task's constraint was explicit: *do not simply delete the suppression if the
underlying noise is real — find out what it actually suppresses*. So I measured
instead of assumed.

I instrumented the **real** helper to **record** rather than swallow, and ran the
full gallery suite:

```text
flutter test test/gallery/design_system_gallery_test.dart
→ 01:19 +22: All tests passed!
→ ===SUPPRESSED=== lines: 0
```

**Zero messages were ever suppressed across all 22 gallery tests.**

The old filters were `contains('overflow')`, `contains('RenderFlex')`,
`contains('A RenderFlex overflowed')`, `contains('ListTile background color')`,
`contains('ink splashes may be invisible')`. Note that the first three are
mutually redundant — "A RenderFlex overflowed by N pixels" already contains both
`RenderFlex` and `overflow` — so the effective hole was a single broad
substring test over the entire layout-error class.

I also ran a **no-suppressor census probe** (temporary, since removed) that
pumped the gallery page and every registry section builder with no error handler
installed: `PAGE_ERRORS_COUNT=0`, `BUILDER_ERRORS_COUNT=0`.

**Conclusion: the suppressed messages were NOT genuine defects.** They were
nothing at all today. But the filter was **latent** — any future overflow, in
any of those 22 tests, would have been masked silently and the suite would have
stayed green. That is a real oracle gap even though it is currently unexercised,
so narrowing (not deletion) is the correct fix.

### The narrowing

**Removed** (the oracle gap):
- `contains('overflow')` — the widest hole; masked *every* overflow class
- `contains('RenderFlex')` and `contains('A RenderFlex overflowed')` — the
  layout-error class the gallery exists to prove absent

**Kept**, as an exact enumerated allow-list of the two benign Flutter/Material
*debug hints* the original doc comment named:
- `ListTile background color…` (Material ancestor/background debug warning)
- `ink splashes may be invisible` (Material ink-splash debug hint)

**Made auditable:** residual benign masks are now `print`ed as
`===GALLERY-BENIGN-HINT-MASKED===` instead of being silently dropped, so the
suppressor is no longer opaque in test output.

### Files

| File | Change |
| --- | --- |
| `test/gallery/gallery_test_oracle.dart` | **new** — single canonical owner: `kBenignGalleryFrameworkHints`, `isBenignGalleryFrameworkHint`, `installGalleryBenignHintSuppressor` |
| `test/gallery/design_system_gallery_test_oracle_test.dart` | **new** — 6 regression tests |
| `test/gallery/design_system_gallery_test.dart` | `_suppressGalleryDemoNoise` now delegates to the shared oracle; doc comment rewritten |

Extracting the oracle to its own file was required, not stylistic: a regression
test must be able to import the *exact* function the gallery suite installs.
Keeping it private to `design_system_gallery_test.dart` would have made an honest
non-vacuous test impossible to write.

### Regression proof — mutation-tested, not asserted

The task required proof that a deliberately introduced layout error *would* fail
a gallery test. I did not just assert it; I **mutation-tested** it by restoring
the old broad filter and confirming the tests catch it:

```text
MUTATION (old broad filter restored):
  ✗ gallery suppressor allow-list … does NOT mask layout-error classes
  ✗ … a deliberately introduced RenderFlex overflow REACHES the handler …
  → 2 failures, TEST_EXIT=1
MUTATION REVERTED:
  → 00:26 +28: All tests passed!  TEST_EXIT=0
```

**The regression tests are genuinely non-vacuous.** Under the old filter they
fail; under the narrowing they pass. `grep -c "TEMP MUTATION"` = 0 confirms the
mutation was fully reverted.

The load-bearing test installs the **real** suppressor, pumps a real
500+500 px `Row` in an 800 px viewport, and asserts `tester.takeException()`
is non-null and contains `A RenderFlex overflowed`. Non-null proves pass-through;
null (i.e. swallowed) is what the old filter produced and what would fail it.

### One implementation correction worth recording

My first version of the pass-through test installed its own
`FlutterError.onError` collector. It **failed** with:

```text
Failed assertion: '_pendingExceptionDetails != null': A test overrode
FlutterError.onError but either failed to return it to its original state …
+ TimeoutException after 0:10:00
```

Overriding `FlutterError.onError` bypasses the binding's pending-exception
bookkeeping, so `takeException()` returned null and teardown asserted — plus a
10-minute hang. Rewrote both tests to use `tester.takeException()`, flutter_test's
own mechanism, which is both correct and the only sound observable here.

**Forward-looking risk:** in the mutated state the suite took **10 minutes** to
fail rather than failing fast. If the filter is ever re-widened in CI, the signal
may arrive as a 10-minute timeout instead of a clean assertion failure. Worth
knowing when triaging.

### Validation — exact exits

| # | Command | Exit | Result |
| --- | --- | --- | --- |
| — | `dart format --output=none --set-exit-if-changed test/gallery/` | **0** | **PASS** (all 3 files clean) |
| 1a | `dart analyze` (warp_prism_ui) | **0** | **PASS — 0 errors** (213 pre-existing `info` lints) |
| 1b | `flutter test test/gallery/ --no-pub` | **0** | **PASS 28/28** (was 22; +6 new) |
| 2 | `flutter test test/ --no-pub --exclude-tags=golden` | **0** | **PASS 1698/1698** |
| 3 | `boundary_test.dart --repo-root .` | **0** | **PASS 15/15, 0 violations** |

Side finding: validation 2 shows the **63 golden failures** carried in the Task
1839 backlog are entirely golden-tagged — with `--exclude-tags=golden` the whole
suite is green. That backlog item is a pure Task 1800/1805 human gate with no
code defect behind it.

### Scope compliance

My writes, enumerated: **exactly 3 files**, all in `test/gallery/` — the 2 new
and the 1 modified. Both temporary probe files were archived to
`.archive/packages/warp_prism_ui/test/gallery/`, so no scratch remains in the
suite. `lib/` untouched by me · no other package touched · goldens untouched
(0 `.png` modified) · `AGENTS.md`/`MISSION.md`/`README.md` untouched · no
`.agents/` · no `.project/tasks/` edit · no `git`, no `jj`, no `rm`, no lane
move, no self-acceptance.

### ⚠ Write-collision finding — owner action required

Verifying scope with `find -newermt` surfaced **53 files written in the 00:02
minute**, including **27 files under `packages/warp_prism_ui/lib/`** and many
other test files.

**I did not write those.** My only writes this session were 3 gallery files
(mtimes 00:03, 00:24, 00:37) and 2 probe archives. Every `edit`/`write`/`archive`
call I issued targeted those 5 paths.

Evidence of a parallel agent in this exact directory:
`.archive/packages/warp_prism_ui/test/gallery/` contains
`zz_scratch_1840_repro_test.dart` and `zz_scratch_1840_sibling_test.dart`
(Sep 29) — **Task 1840's** scratch files. The 00:02 bulk write of 51 non-mine
files (27 in `lib/`) is consistent with a package-scoped `dart format`/`dart fix`
by that agent, and matches the 56–57 file pre-existing format drift already
observed in Tasks 1839/1842.

**Functional impact: none.** All validations above were executed *after* the
00:02 write and are green against the current tree, and my 3 files are
format-clean. But the Task 1843 dispatch asserted "disjoint fileset from
1842/1844" without accounting for **1840**, which was live in `warp_prism_ui`
and in this very directory. Recommend the owner treat the claimed disjointness as
unsafe while 1840 is active, and confirm the 51-file reformat was intended
rather than an accidental broad `dart format` / `dart fix --apply`.

### Residual risks

1. The 51-file `lib/` reformat by a parallel agent is unreviewed by me and
   outside my scope. If it was unintended it should be reverted or reviewed.
2. Benign-hint masking is still automatic. Mitigated by printing, but a reviewer
   must still read test output; it is not a hard oracle.
3. The allow-list is an enumerated judgment. If the gallery legitimately needs a
   third masked class, it must be added deliberately with a reason — never by
   widening a substring pattern, which is what created the original gap.
4. No `AGENTS.md` §7.1 host-composition evidence produced: this task changes test
   harness code only, and the gallery renders in a test binding, not a real host.

### Epistemic status

- Old suppressor masked nothing: **PROVEN** (instrumented run of the real suite,
  0 `===SUPPRESSED===` lines; independent no-suppressor census also 0).
- Suppressed messages were not genuine defects: **PROVEN** (zero messages emitted
  at all — nothing existed to be a defect).
- Narrowing closes the oracle gap: **PROVEN** (mutation test — 2 failures under
  the old filter, 0 under the new).
- Regression tests are non-vacuous: **PROVEN** by mutation, not by assertion.
- Layout errors now fail gallery tests: **PROVEN** (`takeException()` non-null
  with the real suppressor installed).
- The 00:02 `lib/` writes are not mine: **PROVEN** by enumeration of my 5 issued
  write calls and their mtimes; authorship of the other 51 is
  **STRONG_HYPOTHESIS** (Task 1840) — I can prove it was not me, but I cannot
  prove who did it from inside my tool visibility.
