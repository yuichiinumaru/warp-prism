# rem-0005: host_exercise dead exports cleanup

> **Remediation namespace**: `rem-NNNN` (overnight remediation wave 2). Source finding: Inv-7a (`ses_ed3e645e9ffeWgkpYJaWxGRyvf`) §5 — three zero-reference exports.
> **Review State**: `Review Approved`
> **Review Trail**: independent `gtr-reviewer-flutter` PASS 97/100 on 2026-10-16; report `.project/reports/reviewers/rem-0005-host-exercise-dead-exports-review-loop.md`; no mandatory remediation; M1/M2/M3 + host_config doc nit are parent-owned follow-ups.
> **Promotion**: `01-open` → `04-completed` by parent after independent PASS; no product files changed in promotion.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 97/100; three dead symbols removed, 25/25 host adapters green (see Review Trail above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-rem-0005-host-exercise-dead-exports-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
- Recovery note: a same-day append typo created a fragment file with a `-cleanup` suffixed name carrying only this Promotion block; that fragment was relocated to `.archive/temporary/` as SUPERSEDED and is not a task record.
> **Priority**: 🟢 P2 | **Type**: `remediation` | **Origin**: architect investigation
> **Blocks**: N/A | **Depends on**: N/A — but re-check the three symbols at execution time (a worker may have wired them between investigation and execution; that flips the disposition to LIVE, and the task becomes a no-op with evidence).
> **parallel-safe**: file writes yes (package-local); test execution serial if the tool lock contends.

---

## Finding (evidence)

Three exported symbols in `packages/warp_prism_host_exercise/lib` have **zero references outside their defining file** (grep-verified):

| Symbol | Defining site | Evidence |
|---|---|---|
| `ExerciseMode` | `models/exercise_trace.dart:4` | only a doc mention in `host_config.dart:21`; never instantiated; `.smoke/.crawl/.fuzz` selection uses raw strings |
| `kExerciseThemeRecipes` | `models/theme_matrix.dart:53` | defined, never read outside its own file |
| `kExerciseSmokeViewport` | `models/viewport_matrix.dart:93` | defined, never read outside its own file |

Full sampled list of the package's other 13 exports (`ExerciseTrace`, `ExerciseStep`, `ExerciseCandidate`, `ExerciseViewport`, `HostExerciseConfig`, `ExerciseActionDiscovery`, `ExerciseErrorCollector`, `ExerciseRunner`, `ExerciseRunCallbacks`, `ExerciseActionPolicy`, `ActionSafety`, `ExerciseActionKind`, `ExerciseTraceWriter`) all carry external references in `apps/{catalog,observatory,cybercore}/test/host_exercise/` — so the package is otherwise live.

## Objective

Decide-and-execute per symbol, by evidence not by taste:

- If a symbol is genuinely dead (re-verify at execution time): remove it, or (for the two `k*` constants) wire it if the corresponding configuration path manifestly should consume it. Prefer removal — an unused exported constant in a dependency-light harness is rot surface.
- If a symbol is actually live (re-verification finds a reference): record LIVE-AT-EXECUTION and close as no-op with evidence. **A no-op-with-evidence is a valid completion, not a failure.**
- `ExerciseMode` decision must additionally record whether the string-literal mode selection in `ExerciseRunner` (`runSmoke`/`runCrawl`/`runFuzz`) should consume it — answer from code reading, and if the answer is "yes", that is a second sub-unit within this task (small, bounded, in the same package).

## Background Context

- `warp_prism_host_exercise` is intentionally dependency-light (zero Warp Prism deps); its host adapters live in `apps/*/test/host_exercise/`.
- Astro-root rule `AGENTS.md` §6: obsolescence alone does not authorize deletion — here obsolescence is *proven by zero references*, and the removal target is a newly-written constant, not historical content. Removal is the default; `archive` if any doubt about intent.

## Test Requirements

- Re-verification at execution time (`rg` for each symbol across `packages/`, `apps/`, `rust/`, `.project/`) recorded verbatim in evidence.
- After removal: `dart analyze packages/warp_prism_host_exercise` clean (exit 0), package suite still green (`dart test packages/warp_prism_host_exercise`).
- If any host adapter in `apps/*/test/host_exercise/` breaks: STOP — that symbol was live; that is a FAIL of the finding, and the task closes as LIVE-AT-EXECUTION.

## Exit Conditions

- [x] Re-verification recorded (exact rg commands + outputs).
- [x] Per-symbol disposition executed (removed / wired) or LIVE-AT-EXECUTION closed with evidence.
- [x] `dart analyze` exit 0 on the package; suite green or contention protocol recorded.
- [x] No host-adapter regression (verify all three apps' host-exercise tests at least compile-check via analyze).
- [x] Local changelog entry added under `.project/changelog/`.
- [x] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: the three defining files + `host_config.dart:21` + `exercise_runner.dart` mode selection.
- [ ] Re-verify zero references (record commands).
- [ ] Execute per-symbol disposition.
- [ ] **Simplicity pass**: no API churn beyond the finding; barrel unchanged unless a removal forces it (record if so).
- [ ] **Regression verification**: analyze + suite + host-adapters analyze.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_host_exercise/lib/src/models/exercise_trace.dart` | Modify/Read — `ExerciseMode` |
| `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` | Modify/Read — `kExerciseThemeRecipes` |
| `packages/warp_prism_host_exercise/lib/src/models/viewport_matrix.dart` | Modify/Read — `kExerciseSmokeViewport` |
| `packages/warp_prism_host_exercise/test/` | Run — suite regression |
| `apps/{catalog,observatory,cybercore}/test/host_exercise/` | Analyze — regression boundary |
| `.project/changelog/` | Create — entry |

### How

1. Re-verify first; the finding is 1 day old and the tree is moving.
2. Removal via `archive` mechanism if deletion is authorized in your tool scope; otherwise leave in place and record.
3. Do not redesign the mode enum as part of this task (that is a separate design question — record it, don't solve it).

### Why

Dependency-light harnesses rot fastest: unused exports silently accumulate and mislead the next host adapter into thinking a capability exists.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Re-verify before removing — a live reference flips the finding to no-op. Do not break the three host adapters. Do not redesign mode selection beyond the finding's scope.

---

## Validation Commands

```bash
dart analyze packages/warp_prism_host_exercise
dart test packages/warp_prism_host_exercise
```

Contentions with a live session's test runs: retry ≤3 × 60s, then record BLOCKED-on-resource with evidence; never force, never weaken.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_host_exercise/lib/src/models/exercise_trace.dart` — REMOVED `enum ExerciseMode` (3 values, 11 lines incl. docs).
  - `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` — REMOVED `const kExerciseThemeRecipes` (6 lines incl. docs). Class `ExerciseThemeRecipe` and its four named constants (`khalaiBlue`, `taldarimRed`, `talonPurple`, `nerazimTeal`) + `toJson`/`fromJson` are untouched and remain exported.
  - `packages/warp_prism_host_exercise/lib/src/models/viewport_matrix.dart` — REMOVED `const kExerciseSmokeViewport` (3 lines incl. docs). Class `ExerciseViewport` and `kExerciseDesktopMatrix` untouched.
  - No file outside the Where table was modified. The barrel
    `lib/warp_prism_host_exercise.dart` is unchanged — the three removed
    symbols lived in files the barrel already exports; no export line
    needed editing (source files were kept, not deleted).
- **Tests or validation commands**:
  - `dart analyze packages/warp_prism_host_exercise` → **exit 0, "No issues found!"**
  - `flutter test packages/warp_prism_host_exercise` → **exit 0, 10/10 pass** (see Contention note for `dart test`)
  - `dart analyze apps/catalog apps/observatory apps/cybercore` → **exit 0, 124 issues found — byte-identical to the pre-change baseline**; `grep '/host_exercise/'` on both runs returns **zero lines**.
  - `flutter test apps/*/test/host_exercise/` → **catalog 9/9, observatory 8/8, cybercore 8/8, all exit 0**.
- **Local changelog entry**: `.project/changelog/20261011-155639-rem-0005-host-exercise-dead-exports-cleanup-builder-engineer.md` (registered via `project_changelog action=closeout`, exit 0, `Changelog valid: issues=0 entries=348`). A hand-written duplicate draft was archived to `.archive/.project/changelog/20261011-185438-rem-0005-…` after the canonical engine entry was confirmed, so the ledger carries exactly one rem-0005 entry.
- **Executor**: builder-engineer (`rem-0005`, single-subagent execution, no delegation)
- **Completion date**: 2026-10-11

### Re-verification (execution time, verbatim)

Four `rg` runs were executed from the repo root **before** any mutation, and
again after mutation. Representative verbatim output:

```
$ rg -n --no-heading 'ExerciseMode' .
./packages/warp_prism_host_exercise/lib/src/models/host_config.dart:21:  /// Canonical smoke paths for [ExerciseMode.smoke]: ordered stable
./packages/warp_prism_host_exercise/lib/src/models/exercise_trace.dart:4:enum ExerciseMode {
EXIT=0

$ rg -n --no-heading 'kExerciseThemeRecipes' .
./packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:53:const kExerciseThemeRecipes = <ExerciseThemeRecipe>[
EXIT=0

$ rg -n --no-heading 'kExerciseSmokeViewport' .
./packages/warp_prism_host_exercise/lib/src/models/viewport_matrix.dart:93:const kExerciseSmokeViewport = ExerciseViewport.desktop1280x800;
EXIT=0
```

Corroborating sweep over the first-party source surface
(`packages/ apps/ rust/ docs/`) for `ExerciseThemeRecipe` returned only
defining-file hits inside `theme_matrix.dart`; no `apps/` host adapter
references any of the three symbols. Post-mutation, the same three patterns
return **only** the one doc-comment mention in `host_config.dart:21` (see
Note A). **All three symbols were dead at execution time — no LIVE flip.**

### Per-symbol disposition

| Symbol | Disposition | Evidence |
|---|---|---|
| `ExerciseMode` | **REMOVED** | Zero instantiation / zero reference. `ExerciseRunner` selects behaviour by separate methods (`runSmoke` / `runCrawl` / `runFuzz`), and `ExerciseTrace.mode` is a `String` on purpose (it is a serialized wire field: `'fuzz'`, `'crawl'`, `'fuzz-replay'` — the `-replay` suffix is synthesised by string interpolation in `replayTrace`, so it is *not* an enum value). |
| `kExerciseThemeRecipes` | **REMOVED** | Zero reference. Each host adapter hardcodes its own ladder: `catalog_theme_matrix_test.dart:28–34` declares a local `recipeLadder` `List<String>`; the catalog/observatory/cybercore adapters map recipe ids through `applyCatalogThemeRecipe` / their own equivalents. No host iterates a package-provided recipe set. |
| `kExerciseSmokeViewport` | **REMOVED** | Zero reference. `HostExerciseConfig.viewport` already defaults to `ExerciseViewport.desktop1280x800` (`host_config.dart:51`), which is the exact value this constant aliased — it was a redundant alias, not a distinct default. |

### ExerciseRunner mode-wiring question (required answer)

**No — `runSmoke`/`runCrawl`/`runFuzz` should NOT consume `ExerciseMode`.**

Reasoning from code reading (not preference):

1. Mode is already enforced by *arity of the API surface*, not by a value:
   three distinct static methods. A `run(mode)` dispatcher would be one
   call site with a `switch` — strictly more indirection, zero new safety,
   and it would make the caller's mode selection a runtime string match
   instead of a compile-time-selected method.
2. `ExerciseTrace.mode` is a `String` wire field, and `replayTrace`
   synthesises `'${trace.mode}-replay'`. A closed 3-value enum cannot
   represent that 4th observable value, so making the enum the source of
   truth would create a type that lies about the serialized domain.
   `ExerciseTraceWriter.replayCommand(host:, mode:, seed:)` also passes
   `mode` straight into a CLI flag: `--mode $mode`.
3. Host adapters select mode by string today
   (`catalogExerciseConfig(mode: 'crawl', ...)`), and those calls live
   outside this package's writeset. Wiring an enum in would either change
   the adapter signature (out of scope, and a break of the harness
   contract) or require an adapter-side enum→String shim that adds no value.

Conclusion: the string-literal mode selection is the *correct* shape for
this harness; only the dead enum needed to go. Per the task's own
instruction, the enum-redesign question is recorded here and deliberately
**not solved** — see Note B.

### Contention (recorded per task instruction)

`dart test packages/warp_prism_host_exercise` fails during **loading**
with a VM-internal compiler crash, before any test body compiles:

```
Unhandled exception:
Crash when compiling:
type 'InvalidType' is not a subtype of type 'FunctionType' in type cast
  #0  _FfiUseSiteTransformer._verifyAndReplaceNativeCallable
      (package:vm/modular/transformations/ffi/use_sites.dart:1317)
```

This was **proven pre-existing and unrelated** to this task by three
independent controls:

1. The identical crash reproduces in `packages/warp_prism_bindings`
   (`dart test packages/warp_prism_bindings`, exit 1, same stack) — a
   package this task never touched.
2. The removed symbols were temporarily re-added (full pristine restore,
   verified by `dart analyze` exit 0), and `dart test` crashed
   **identically** on the pristine tree. They were then removed again and
   the final state was re-verified.
3. `packages/warp_prism_runtime` (a pure-Dart package with no FFI
   dependency) passes `dart test` with exit 0, isolating the crash to a
   workspace-wide FFI/toolchain condition — consistent with
   `packages/warp_prism_adapter_frb/lib/src/rust/frb_generated.io.dart`
   being the only `dart:ffi` source in the tree.

Retry protocol performed as instructed (3 × 60 s backoff, scripted):
retries 1/2/3 all returned exit 1 with the identical stack — **deterministic,
not contention**. No BLOCKED-on-resource state was reached because the
failure is a deterministic toolchain fault, not lock contention.

Per "never weaken a check to pass", the check was **not** replaced or
loosened: the equivalent, un-weakened suite was executed through the
canonical Flutter runner — `flutter test
packages/warp_prism_host_exercise` → **exit 0, 10/10 pass** — which runs
the same two test files with no assertion modified. `dart test` remains
broken environment-wide and is reported to the parent as a separate
pre-existing defect.

### Note A — out-of-writeset residue (recorded, NOT modified)

`host_config.dart:21` still contains the doc-comment reference
`/// Canonical smoke paths for [ExerciseMode.smoke]: ordered stable`.
`host_config.dart` is not in this task's Where table, so it was left
byte-untouched. This now-dangling doc-reference is recorded here for the
parent's next owner; it is doc-comment-only and does not affect `dart
analyze` (exit 0 confirms).

### Note B — out-of-scope design question (recorded, NOT solved)

Whether the harness should eventually unify its mode representation (raw
strings + separate methods vs. a typed enum + a dispatcher) is a design
question beyond this task's finding. It is recorded, not solved, exactly
as the task instructs. Per the reasoning above, removal of the dead enum
does not create urgency for that redesign.

- **affected_consumers**: NONE
  reason: the change deletes three zero-reference exports from a
  dependency-light harness package. `kExerciseDesktopMatrix`,
  `ExerciseViewport`, `ExerciseThemeRecipe`, `ExerciseStep`,
  `ExerciseTrace`, `HostExerciseConfig`, `ExerciseRunner` and every other
  export are unchanged; all three host adapters' suites and all three
  apps' analyzes are byte-identical to baseline. A consumer cannot observe
  the removal of a symbol it never referenced.

