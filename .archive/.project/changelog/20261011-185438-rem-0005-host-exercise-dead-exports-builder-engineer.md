---
date: 20261011-185438
timestamp: 20261011-185438
project: warp-prism
agent: builder-engineer
task: "rem-0005"
description: "Removed three zero-reference exports from warp_prism_host_exercise (ExerciseMode enum, kExerciseThemeRecipes, kExerciseSmokeViewport) after execution-time re-verification; all three host adapters verified byte-identical to baseline"
is_rebuild_safe: true
---

# rem-0005: host_exercise dead exports cleanup

## Summary

Inv-7a §5 reported three exported symbols in
`packages/warp_prism_host_exercise/lib` with zero references outside their
defining file. The finding was ~1 day old at execution time and the tree
was live, so the first action was a fresh `rg` sweep (see Re-verification
below). **All three were still dead — no LIVE flip.** The finding held and
the cleanup proceeded as a pure removal.

`rem-0005` removes the three symbols. Nothing else in the package changed:
the barrel, `ExerciseViewport`, `ExerciseThemeRecipe`,
`kExerciseDesktopMatrix`, `ExerciseStep`, `ExerciseTrace`,
`HostExerciseConfig`, `ExerciseRunner` and every other export are
byte-identical.

## Changes

| File | Change |
| --- | --- |
| `packages/warp_prism_host_exercise/lib/src/models/exercise_trace.dart` | Removed `enum ExerciseMode` (3 values + doc comments, −11 lines) |
| `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` | Removed `const kExerciseThemeRecipes` (+ its doc comment, −6 lines) |
| `packages/warp_prism_host_exercise/lib/src/models/viewport_matrix.dart` | Removed `const kExerciseSmokeViewport` (+ its doc comment, −3 lines) |

Additive/subtractive shape: **-20 lines, +0 lines** across three files.
Every surviving line is preserved byte-for-byte.

## Per-symbol disposition

| Symbol | Disposition | Why removal is correct |
| --- | --- | --- |
| `ExerciseMode` | REMOVED | Never instantiated, zero references. Mode is already selected by method arity (`runSmoke`/`runCrawl`/`runFuzz`), and `ExerciseTrace.mode` is a `String` **wire** field that `replayTrace` extends to `'${mode}-replay'` — a value no 3-case enum can represent, so an enum would be a type that lies about its own serialized domain. |
| `kExerciseThemeRecipes` | REMOVED | Never read. Each host adapter owns its own ladder — `catalog_theme_matrix_test.dart:28–34` declares a local `recipeLadder` `List<String>`; the other adapters do the equivalent. No host iterates a package-provided recipe set. |
| `kExerciseSmokeViewport` | REMOVED | Never read. `HostExerciseConfig.viewport` already defaults to `ExerciseViewport.desktop1280x800` (`host_config.dart:51`) — the exact value this constant aliased. It was a redundant alias, not a distinct default. |

## ExerciseRunner mode-wiring question (required answer)

**No — `runSmoke`/`runCrawl`/`runFuzz` should NOT consume `ExerciseMode`.**

1. Mode is already enforced by the API surface (three distinct methods). A
   `run(mode)` dispatcher adds a `switch` and makes mode selection a
   runtime string match instead of a compile-time method selection.
2. `ExerciseTrace.mode` is a serialized `String` that `replayTrace`
   extends with a `-replay` suffix; a closed enum cannot represent that
   fourth observable value, and `ExerciseTraceWriter.replayCommand`
   passes it straight into a `--mode $mode` CLI flag.
3. Host adapters pass mode as a string today
   (`catalogExerciseConfig(mode: 'crawl', …)`). Wiring an enum in would
   either break the adapter signature (outside writeset) or add a
   pointless enum→String shim.

The string-literal mode selection is the correct shape for this harness.
The enum-redesign question was recorded, not solved, per the task's own
instruction — removal of the dead enum does not create urgency for a
redesign.

## Verification

| Command | Exit | Result |
| --- | --- | --- |
| `dart analyze packages/warp_prism_host_exercise` | 0 | **PASS** — "No issues found!" |
| `flutter test packages/warp_prism_host_exercise` | 0 | **PASS 10/10** |
| `dart analyze apps/catalog apps/observatory apps/cybercore` | 0 | **PASS** — 124 issues, byte-identical to pre-change baseline |
| `grep '/host_exercise/'` on that analyze output (before and after) | 0 | **PASS** — zero hits, both runs |
| `flutter test apps/catalog/test/host_exercise/` | 0 | **PASS 9/9** |
| `flutter test apps/observatory/test/host_exercise/` | 0 | **PASS 8/8** |
| `flutter test apps/cybercore/test/host_exercise/` | 0 | **PASS 8/8** |

Pre/post baseline for the apps analyze was snapshotted before any mutation
and diffed afterwards: `diff` reports the two files **identical**. That is
the strongest available statement that no host adapter regressed — the
apps' analyze output did not move by a single line.

## Contention

`dart test packages/warp_prism_host_exercise` fails during *loading* with a
VM-internal compiler crash (`InvalidType is not a subtype of FunctionType`
inside `_FfiUseSiteTransformer._verifyAndReplaceNativeCallable`), before
any test body compiles.

Proven pre-existing and unrelated to this task by three controls:

1. The identical crash reproduces in `packages/warp_prism_bindings` —
   a package this task never touched.
2. The removed symbols were temporarily re-added (full pristine restore,
   `dart analyze` exit 0) and `dart test` crashed **identically** on the
   pristine tree; they were then removed again and the final state
   re-verified.
3. `packages/warp_prism_runtime` (no FFI dep) passes `dart test` with
   exit 0, isolating the fault to a workspace-wide FFI/toolchain condition
   — consistent with `warp_prism_adapter_frb`'s `frb_generated.io.dart`
   being the only `dart:ffi` source in the tree.

Retry protocol performed as instructed (3 × 60 s): retries 1/2/3 returned
exit 1 with the identical stack — deterministic, not contention. No
BLOCKED-on-resource state was reached.

Per "never weaken a check to pass", no check was weakened or replaced. The
same unmodified suite was executed through the canonical Flutter runner
(`flutter test`, 10/10). `dart test` remains broken environment-wide and
is reported to the parent as a **separate pre-existing defect**, not a
rem-0005 blocker.

## Note for the parent

- `host_config.dart:21` still carries the now-dangling doc-comment
  reference `/// Canonical smoke paths for [ExerciseMode.smoke]: …`. That
  file is **not** in this task's Where table, so it was left byte-untouched.
  Doc-comment only; `dart analyze` exit 0 confirms it has no analyzer
  effect. Recorded for the next owner.
- **affected_consumers: NONE.** All three host adapters' suites and all
  three apps' analyzes are byte-identical to baseline, and the removed
  symbols had zero references. A consumer cannot observe the removal of a
  symbol it never referenced.
- Per root `AGENTS.md` §3.5 the executor provides **no acceptance verdict**
  for this work; independent review is the next gate.
- `project_changelog action=build` was **not** run: it writes root-level
  `CHANGELOG.md` / `CHANGELOG-FULL.md`, which fall outside this task's
  authorized writeset. The ledger entry itself is registered so a later
  owner can refresh the projection safely.
