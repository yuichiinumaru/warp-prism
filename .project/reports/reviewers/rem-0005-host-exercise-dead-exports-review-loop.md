# Review loop — rem-0005: host_exercise dead exports cleanup

- **Task**: rem-0005 (`01-open/rem-0005-host-exercise-dead-exports.md`)
- **Mode**: independent review on explicit user dispatch (fresh session; no lane authority exercised; no lane move performed)
- **contract_revision**: task file as executed 2026-10-11 (Exit Conditions checked; Completion Evidence + Contention + Notes A/B filled) + live tree 2026-10-16
- **Reviewer**: Implacable Flutter Reviewer (fresh session; not the executor; zero product mutations — read-only reads plus analyzer/test runs only)
- **Counterpart journals**: builder journal N/A (none exists under `.project/reports/builders/` for rem-0005); prior reviewer report: none (this is Round 1)

## Current State

- **verdict**: PASS
- **score**: 97/100 (diagnostic only; does not gate acceptance)

## Open Items (all non-blocking; routed to parent, none requires rem-0005 remediation)

- O1 — `dart test` unusable workspace-wide for this transitive closure (VM/FFI toolchain crash; pre-existing environment defect).
- O2 — `host_config.dart:21` dangling `[ExerciseMode.smoke]` doc ref (one-line follow-up; NOT material).
- O3 — Changelog-engine closeout rebuild (shared with rem-0004; see cross-task section).

## Round 1 — initial independent review (2026-10-16)

### Verdict: PASS

All three symbols were dead at execution time and remain dead today; the removals are exactly as described; the barrel is correctly untouched; the package analyzes clean and its suite is green through the canonical Flutter runner (10/10); all three real host adapters are green (9/9, 8/8, 8/8) with full-app analyzes clean (exit 0, 124 info-only issues, zero host_exercise/removed-symbol hits); the mode-wiring answer is sound and correctly scoped (recorded, not solved). The `dart test` crash was independently reproduced — deterministic pre-existing toolchain fault, not a task regression.

### Diagnostic score: 97/100

| Deduction | Points | Basis |
|---|---|---|
| Retry-protocol raw logs not preserved (scripts survive; outputs gone) + unchecked What-subtasks | −1 | Method scripts at `.archive/tmp/` corroborate procedure; fresh repro compensates |
| Closeout generator rebuild undisclosed in rem-0005's own evidence (same engine path rem-0004 disclosed) | −1 | Low materiality (archived, superseded); routes to parent/engine |
| `dart test` runner substitution | −0 | `flutter test` is the canonical runner for `flutter_test`-based suites; same files, same assertions, unweakened |

### Diff ownership (this task vs neighbors)

| File / surface | Owner | Evidence |
|---|---|---|
| `packages/warp_prism_host_exercise/lib/src/models/exercise_trace.dart` (remove `ExerciseMode`) | rem-0005 | mtime Oct 11 15:50; enum gone, `ExerciseStep`/`ExerciseTrace` (String `mode`) intact |
| `.../models/theme_matrix.dart` (remove `kExerciseThemeRecipes`) | rem-0005 | mtime Oct 11 15:50; `ExerciseThemeRecipe` + 4 consts + toJson/fromJson intact |
| `.../models/viewport_matrix.dart` (remove `kExerciseSmokeViewport`) | rem-0005 | mtime Oct 11 15:50; `ExerciseViewport` + `kExerciseDesktopMatrix` intact |
| `lib/warp_prism_host_exercise.dart` (barrel) | correctly UNTOUCHED | file-level exports; no line referenced a removed symbol |
| `host_config.dart:21` doc ref | untouched by design (outside Where table) | residue recorded, not material (see V6) |
| `layer-contracts.md` §2 label indent ~15:54 | attributed to rem-0005's session window (unrecorded in rem-0005 evidence) | cosmetic; diagram verified intact (see rem-0004 report V1) |

### Per-symbol verification (fresh evidence, current session)

Independent repo-wide sweeps (`packages/ apps/ rust/ docs/ .project/`) reproduce the dead finding five days post-execution — no LIVE flip:

| Symbol | Remaining hits | Assessment |
|---|---|---|
| `ExerciseMode` | `host_config.dart:21` doc comment only (+ changelog/task/report record-mentions, all historical) | dead; sole residue is a doc comment (V6) |
| `kExerciseThemeRecipes` | record-mentions only (changelog, task file, one historical review-loop note describing pre-removal state) | dead; zero code references |
| `kExerciseSmokeViewport` | record-mentions only | dead; zero code references |

**Disposition accuracy (verified from code, not preference):**
- `ExerciseMode` removal correct: `ExerciseRunner` selects behavior by method arity (`runSmoke`/`runCrawl`/`runFuzz`, string literals `'smoke'`/`'crawl'`/`'fuzz'` at exercise_runner.dart L144/L233/L304); `replayTrace` synthesizes `'${trace.mode}-replay'` (L378) — a 4th value a closed 3-value enum cannot represent; `ExerciseTraceWriter.replayCommand` passes `mode` straight into `--mode $mode` (trace_writer.dart L23); adapters call with raw strings (e.g. `observatoryExerciseConfig(mode: 'smoke'/'crawl'/'fuzz')`). Wiring the enum would add indirection with zero new safety — the recorded "No" is sound.
- `kExerciseThemeRecipes` removal correct: each adapter owns a local ladder (verified `catalog_theme_matrix_test.dart` L28–34: local `const recipeLadder = <String>[...]`); no host iterates a package-provided set.
- `kExerciseSmokeViewport` removal correct: pure redundant alias of `ExerciseViewport.desktop1280x800`, which remains the `HostExerciseConfig.viewport` default (host_config.dart L51, read in full).
- "Package otherwise live" corroborated: all 10 adapter files across the three hosts reference retained exports (4–11 hits/file: `ExerciseRunner`, `HostExerciseConfig`, `ExerciseTrace`, `ExerciseViewport`, `ExerciseThemeRecipe`, `ExerciseActionKind`, `ExerciseTraceWriter`).

### Validation (reviewer ran everything fresh 2026-10-16)

| Command | Result |
|---|---|
| `dart analyze packages/warp_prism_host_exercise` | **exit 0, "No issues found!"** ✓ |
| `flutter test packages/warp_prism_host_exercise` | **exit 0, +10 All tests passed** ✓ |
| `dart test packages/warp_prism_host_exercise` | **exit 255, VM FFI crash at load** (`_FfiUseSiteTransformer._verifyAndReplaceNativeCallable`, `InvalidType`/`FunctionType` cast; zero user-code frames; `+0: loading` phase) — independently reproduced, deterministic, pre-existing toolchain fault. Removed symbols are pure-Dart model constants with zero FFI surface; cannot cause a VM transformer crash. Builder's pristine-restore control accepted as reported (re-running it would require mutation, forbidden to this reviewer). |
| `dart analyze apps/catalog apps/observatory apps/cybercore` | **exit 0, "124 issues found"** — exact-count match with the builder's baseline number; all visible issues are info-level style lints (`prefer_const_*`, `unnecessary_import`, `dangling_library_doc_comments`) in app test files; zero errors/warnings |
| same analyze output piped to `rg "host_exercise\|ExerciseMode\|kExerciseThemeRecipes\|kExerciseSmokeViewport"` | **zero hits** (grep exit 1) ✓ |
| `flutter test apps/catalog/test/host_exercise/` | **exit 0, +9 All tests passed** ✓ |
| `flutter test apps/observatory/test/host_exercise/` | **exit 0, +8 All tests passed** ✓ |
| `flutter test apps/cybercore/test/host_exercise/` | **exit 0, +8 All tests passed** ✓ |
| Changelog/ledger check | exactly **1** rem-0005 ledger entry, indexed (index.md:9); duplicate draft archived (`.archive/.project/changelog/20261011-185438-…`) ✓ |

Suites not run per dispatch boundary: `warp_prism_ui` gallery suites and adapter/Rust (`cargo`) tests — owned by other reviewers; untouched by this task's writeset (verified: zero references, barrel unchanged, analyzes clean).

### Affected consumers — classification (not "zero adoption from zero refs")

| Consumer class | Members | Impact | Proof |
|---|---|---|---|
| In-repo host adapters | `apps/{catalog,observatory,cybercore}/test/host_exercise/` (10 files) | NONE — no file referenced any removed symbol | suites 9/9+8/8+8/8 green; full-app analyzes exit 0 with zero removed-symbol hits |
| In-repo package dependents | all three apps dev-depend on `warp_prism_host_exercise` (path) | NONE — barrel file-set unchanged; retained API surface byte-identical | barrel read; analyzer clean on all three apps |
| External consumers | none possible | NONE — package is `publish_to: 'none'`, v0.1.0, path/dev-only; external zero-adoption stands on the reviewed carrier | pubspec read; carrier §0.1 |
| Host-proof sufficiency | the host_exercise suites ARE real-host composition tests (they pump the real catalog/observatory/cybercore widgets with the strict error oracle) | SUFFICIENT — 25/25 across the three real hosts, plus clean analyzes | per AGENTS.md §7.1 affected-host evidence |

A consumer cannot observe the removal of a symbol it never referenced, through a barrel whose exported file-set is unchanged, in an unpublished package. The task's `affected_consumers: NONE` is correct and properly evidenced.

### Findings

**Task-specific: none blocking.** Every Test Requirement and Exit Condition is satisfied with fresh evidence.

**Cross-cutting / NEW (for parent triage, not rem-0005 remediation):**

- **M1 — `dart test` environment defect (parent triage).** The task's letter-of-the-law runner (`dart test`) is deterministically broken workspace-wide for this transitive closure (VM-internal FFI transformer crash at compile/load, exit 255, reproduced today). The builder's substitution (`flutter test`, same files/assertions) is the *canonical* runner for `flutter_test`-based suites — an upgrade in correctness, not a weakening — and all mandatory proof is satisfied through it. No BLOCKED attaches to this task (proof exists via an equivalent-or-better runner). Route the toolchain fault itself to whoever owns the Dart/Flutter environment.
- **M2 — Retry raw logs not preserved.** `.archive/tmp/rem-0005-retry.sh` and `rem-0005-app-tests.sh` survive (method evidence: 3 × retry with 60 s sleeps; per-app `flutter test` loops), but the scripts' `tmp/rem-0005-*.txt` outputs are absent from repo-root `tmp/`. The "deterministic, not contention" claim therefore rests on method + my fresh repro rather than preserved artifacts. Triage: keep the two scripts (already archived); no recovery possible for the outputs.
- **M3 — Closeout generator rebuild (shared with rem-0004).** rem-0005's 15:56:39 closeout rebuilt the same parent-owned generated surfaces (archive `CHANGELOG-before-rebuild-20261011-155639.md` proves it); rem-0005's entry does not restate the effect rem-0004 disclosed. Same low materiality, same parent/engine ownership question. See cross-task section.
- **M4 (minor)** — What-subtasks unchecked while Exit Conditions are checked (mirror image of rem-0004's pattern). Cosmetic.

### Remediation targets

None mandatory — verdict is PASS. Non-blocking follow-ups (parent-owned, any future owner): one-line reword of the `host_config.dart:21` doc comment to drop the dangling `[ExerciseMode.smoke]` link (bundle with the next authorized `host_exercise` touch; file is outside rem-0005's closed scope); triage M1/M2/M3 as above.

### On V6 / O2 — is the `host_config.dart:21` residue material?

No. It is a `///` doc comment; `dart analyze` exits 0 (the `comment_references` lint evidently does not fire fatally here); no test, export, barrel, or runtime behavior references it; dartdoc renders an unlinked code span at worst. Severity: trivial doc nit. Remediation: reword to plain prose (e.g. "Canonical smoke paths: ordered stable candidate ids…"). Explicitly NOT performed here (outside writeset; reviewer is non-mutating by default).

### Commands run — full list

All in the Validation table above, plus: full reads of the three model files, `host_config.dart`, barrel, `exercise_runner.dart` (L1–393), `trace_writer.dart` replay-command lines, `catalog_theme_matrix_test.dart` ladder lines, all three app pubspecs, repo-wide `rg` for all three symbols, retained-export liveness `rg`, `.archive/tmp` + repo `tmp/` + `.opencode/tmp/` sweeps, both task files, both changelog entries, changelog index rows. No `tmp/` or system-`/tmp` artifacts created by this review. No gallery/cargo suites run. No nested delegation (Rule 33 — no child launched).

### Old-tmp triage (parent use)

Evidence-relevant and keep-worthy: `.archive/tmp/rem-0005-retry.sh` (327 B), `.archive/tmp/rem-0005-app-tests.sh` (309 B) — method evidence for the contention protocol and per-app test loops. Safe to retain indefinitely (already under `.archive/`; tiny). NOT evidence and not mine to triage: `1840_fixed_backup.dart`, `1843-review-current/`, `1844-review-current/`, reviewer-1843/1844 logs (other tasks/reviewers). Repo-root `tmp/` holds no rem-0005 outputs. This review created no scratch (`.archive/tmp/rem-0004-0005-review-current/` not needed, not created).

### Skill attestation (truthful)

Loaded and applied: `code-quality` (bundled-review per-task verdicts + evidence isolation; contract blast-radius for the export removal; changelog-gate observation; verdict-gate), `flutter` (source-reality-first, project commands, no phantom validation — the `dart test` crash is recorded as unavailable-infra proof with a canonical-runner equivalent, never as PASS-by-absence), `code-quality/workflows/sw-code-quality-review-flutter` + `gt-global-subagent-review` (claim-first verdict), report-lineage (additive per-task loop files). Rules: 30 (claim-scoped evidence; delegated pristine-restore control weighted as medium-confidence reported evidence, compensated by fresh repro), 33 (no nested delegation), 40/41/42 succession (lane neutrality; no lane move). Widget-lifecycle/state subskills deliberately not loaded — pure-Dart model-constant removal with no widget, controller, subscription, or async-state surface. No scoring-route, no remediation, no VCS/lane/changelog/harness edits.

### Cross-Task Blast Radius (shared rem-0004/rem-0005 section; duplicated verbatim in both loop files)

- **Shared files**: `layer-contracts.md` (rem-0004 owns the §2/diagram+note edit; rem-0005's session made a cosmetic label-indent pass at 15:54 — verified zero content effect); root `CHANGELOG.md` / `CHANGELOG-FULL.md` / `.project/changelog/index.md` / `views/*` (BOTH closeouts rebuilt them; parent-owned generated surface; archived at both timestamps; centrally rebuilt Oct 15 — no residual conflict); `.project/changelog/index.md` rows for both tasks coexist additively (lines 9–10).
- **Shared interfaces/types/constructors**: NONE. rem-0004 is docs-only; rem-0005 removed three zero-referrer exports (barrel file-set unchanged). No coupling.
- **Generated surfaces**: changelog views/index as above; no tasklist/index edits by either task.
- **Regression risk if only one task is accepted**: NONE either way — the tasks are content-independent (doc corrections vs dead-export removal); neither depends on the other's output. The only shared exposure is the changelog-engine rebuild behavior (process, already superseded).
- **Serial vs parallel residual**: no remaining serial work between these two tasks. Open follow-ups (engine ownership, §1-row scope, host_config:21 doc nit, `dart test` env defect) are independent micro-items for parent triage.
- **Diff ownership map**: 4 architecture docs → rem-0004; 3 host_exercise model files → rem-0005; `host_config.dart` → untouched by both (residue recorded); generated changelog surfaces → engine/parent shared effect.
