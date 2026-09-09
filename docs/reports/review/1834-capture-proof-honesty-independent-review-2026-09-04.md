# Independent Post-Acceptance Revalidation Review — Task 1834 — Capture Proof Honesty — 2026-09-04

## Review Lineage

- **Current task**: Task 1834 (`warp-prism-capture-proof-honesty`); live path `docs/tasks/01-open/1834-warp-prism-capture-proof-honesty.md`
- **Reviewer**: `gt-reviewers-reviewer-flutter` (REVIEW-1834 dispatch, reviewer-lane context; Score-only lane authority — **no lane move performed or implied**)
- **Previous reports read**:
  - `docs/reports/builders/20260904-task-1834-capture-proof-honesty-self-review.md` — builder self-close, self-reported 100/100 (Score-only, zero lane authority claimed — verified compliant)
  - `docs/reports/review/1805-final-capture-determinism-independent-rereview-2026-09-03.md` — prior 1805 re-review whose "PASS + `MissingPluginException` non-blocking" stance is the historical evidence snapshot this task's Origin finding contradicted
- **Related reports considered**:
  - `docs/reports/review/1805-catalog-local-capture-remediation-independent-review-2026-09-03.md` (referenced via 1805 trail; not re-opened)
- **No prior independent review of Task 1834 exists** — this is the first. The builder did not self-accept (task remains in `01-open`; Review Ledger was empty before this review).
- **Review mode**: `re-review-equivalent` post-acceptance revalidation (falsification objective; AGENTS.md §3.6 mapping required by dispatch)

## Score And Verdict

- **Score**: `96/100` — Elite (minor improvements; no acceptance blockers within Task 1834's declared scope)
- **Verdict**: **PASS**
- **Evidence confidence**: **high** — every builder claim independently reproduced from live filesystem + fresh execution; two claims (transient sabotages #1/#2) verified by exact source-site message tracing + the permanent automated honesty tests executing live in all three suites
- **Lane recommendation**: parent routes per governance; **no lane move performed by this reviewer** (dispatch: "you do not move lanes")

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Analyzer Integrity | PASS (task-scoped) | 3× `flutter analyze <capture file> --no-fatal-infos --no-fatal-warnings` → `No issues found!`, exit 0 each. Task defines these exact commands; analyzer detected zero issues of any severity. Path-scoped (not full-package) per task contract — noted as LOW observation, not a violation. |
| 2 | Lifecycle Safety | PASS | 6 `ui.Image` created / 6 disposed in `finally` (catalog:133-135 and identical sites); viewport `addTearDown` resets (catalog:183-184, observatory:190-191, cybercore:189-190); 0 controllers/timers/subscriptions across all 3 files (exact count via read). |
| 3 | Dependency Direction | PASS | Test-only code; imports are app + `warp_prism_ui` + SDK — no layer violations; no production file touched. |
| 4 | UI Accessibility | N/A | Test harness code, not production UI surface. |
| 5 | Proof Reality | PASS | Oracle proven able to fail: permanent honesty tests executed live in all three suites (5/5, 2/2, 2/2); artifact verification independently confirmed via `file` + SHA-256; falsification reproduced. Residual: content-stability not asserted (outside 1834 scope — see F1). |
| 6 | Release Security | PASS/N/A | Test-only; no secrets; `debugPrint` usage is test-path only (9 call sites, all in test files). No release surface touched. |

## Verification Of Builder Claims (falsification results)

| Claim | Independent result | Verdict |
|---|---|---|
| Driver `takeScreenshot` always `MissingPluginException` on all 3 harnesses | Observed live in **every** test of **every** re-run: `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)` — catalog 5×, observatory 2×, cybercore 2× per run, across 2 clean runs each | **CONFIRMED** |
| Local `toImage` path yields verified 1280×800 RGBA bytes on all 3 harnesses | All 6 artifacts on disk: `file` → `PNG image data, 1280 x 800, 8-bit/color RGBA, non-interlaced`; byte sizes match builder's table exactly (32,724 / 32,642 / 16,239 / 26,658 / 26,358 / 57,854-at-builder-time) | **CONFIRMED** (one drift — see F1) |
| Both-paths-failed ⇒ `TestFailure` BLOCKED naming missing capability | Traced: `catalog:156-163` — `writtenFile == null` → `fail('BLOCKED: Visual capture unavailable for "$name". Missing capability: local RepaintBoundary rasterization failed ($rasterError) and integration driver takeScreenshot unavailable ($driverError)...')`. Honesty tests assert `isA<TestFailure>()` + `contains('BLOCKED: Visual capture unavailable')` + `contains('Missing capability')` + `contains('plugins.flutter.io/integration_test')` — all present | **CONFIRMED, non-tautological** (see analysis below) |
| Artifact verification checks existence/non-emptiness/PNG magic/IHDR dims | `catalog:44-96` — existence (:50-52), non-empty (:54-56), ≥24 bytes (:57-62), PNG magic `89 50 4E 47 0D 0A 1A 0A` (:63-71), IHDR width/height at big-endian offsets 16/20 (:73-74), both correct per PNG spec, guarded by the ≥24 check | **CONFIRMED** |
| Sabotage #1 (disableRaster) breaks suite | Permanent honesty test is the automated form; executed and passed in all 3 clean runs. `disableRasterForTesting: true` (catalog:110-112) converges on the identical `fail()` site any real raster exception reaches via the catch at :136-139 — not a mock-only path | **CONFIRMED** |
| Sabotage #2 (wrong width) breaks suite | Source site `catalog:76-81` produces exactly the claimed message `Visual capture artifact width mismatch for catalog_token_swatches: expected 1920 but got 1280` (assertions and interpolation verified verbatim) | **CONFIRMED** (by exact source tracing; live re-execution not performed — not authorized to mutate implementation files) |
| 3 analyzes + 3 harness runs (5/5, 2/2, 2/2) exit 0 | Reproduced with clean exit capture: catalog 0/5-passed, observatory 0/2-passed, cybercore 0/2-passed, analyzes 0/0/0 | **CONFIRMED** (exact counts match) |

### Honesty-test tautology analysis (dispatch falsification task 2)

The permanent test is **not tautological**:

1. `throwsA(...)` fails if the closure does not throw — the test genuinely requires the fail-closed branch to execute.
2. The `disableRasterForTesting` flag simulates raster failure, but the convergence point is code-identical to real raster exceptions: any `toImage`/`toByteData`/write failure lands in the same catch (`catalog:136-139`) → `rasterError` set → `writtenFile == null` → the same `fail()` at :156-163. The flag is a controlled input to a real convergence site, not a mocked oracle.
3. On this runner the driver path genuinely throws `MissingPluginException` (observed live in every run) — so the both-paths-failed state is **real, not simulated**, for the driver half.
4. Cross-runner soundness: on a future driver-capable runner the honesty test still passes (`writtenFile` still null → `fail()` still called), though the message would read `unavailable (null)` (LOW, see F5).

### Driver-call semantics (dispatch falsification task 3)

`binding.takeScreenshot` is **documented best-effort fallback, neither silently required nor silently swallowed**:

- Documented: comment `// 2. Best-effort fallback / driver hook: binding.takeScreenshot.` (catalog:142, observatory:143, cybercore:142) + failure `debugPrint` naming the channel (`plugins.flutter.io/integration_test`) at catalog:148-152.
- Not silently swallowed: `driverError` is captured and **named inside the BLOCKED message** when the gate trips.
- Not silently required: its standalone failure does not fail the suite; only both-paths-failure does — conservative-fail design (a real driver success with raster failure still BLOCKs, which can only over-block, never false-PASS).

### Scope / guardrail verification (dispatch falsification task 4)

- **Candidate-only output**: all writes go to `docs/reports/captures/candidates/` (`catalog:127-131` etc.); grep for `golden|Golden` across all 3 harness files → **0 matches**; golden directories (`packages/warp_prism_ui/test/goldens/`) **not modified today**; no `matchesGoldenFile`/`--update-goldens` anywhere.
- **Protected files untouched**: `AGENTS.md`/`MISSION.md` (Sep 3 19:23), root `pubspec.yaml` (Jul 9), `README.md` (Aug 23) — all predate the task window.
- **Builder writeset = Where table exactly**: 15:00–16:00 window shows the 3 capture files (15:28), task file, self-review report, and the 6 candidate PNGs. All `warp_prism_ui` file changes today (15:25–15:55) + `apps/catalog/pubspec.yaml` (16:41) + `integration_test/host_exercise/` (16:41–16:55) belong to the **parallel Tasks 1831/1832 session**, not Task 1834.
- **No new framework invented**: no new packages, directories, or abstraction layers created by the builder.
- **No VCS operations**: `.git` untouched today (only `.git/opencode` tooling metadata).
- **Changelog**: draft only in task evidence; `.changelog/` ledger untouched today (parent publishes via engine — correct).

## Exact Re-Run Evidence (commands + exits)

All commands run 2026-09-04 16:2x–17:0x local, Flutter 3.44.1 / Dart 3.12.1, same machine as builder.

| Command (workdir) | Exit | Result |
|---|---:|---|
| `flutter analyze integration_test/visual_acceptance_capture_test.dart --no-fatal-infos --no-fatal-warnings` (`apps/catalog`) | 0 | No issues found |
| `flutter analyze integration_test/observatory_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings` (`apps/observatory`) | 0 | No issues found |
| `flutter analyze integration_test/cybercore_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings` (`apps/cybercore`) | 0 | No issues found |
| `flutter test integration_test/visual_acceptance_capture_test.dart --no-pub` (`apps/catalog`) | 0 | 5/5 passed (run A ~16:36 and clean re-run C ~17:05; 4 artifacts verified 32724/32642/16239/26658 bytes, 1280×800) |
| `flutter test integration_test/observatory_visual_capture_test.dart --no-pub` (`apps/observatory`) | 0 | 2/2 passed (×2 runs; 26358 bytes, 1280×800, SHA-256 identical to 1805 record) |
| `flutter test integration_test/cybercore_visual_capture_test.dart --no-pub` (`apps/cybercore`) | 0 | 2/2 passed (×2 runs; 57520 bytes, 1280×800 — see F1) |

Disk-artifact independence: `file` confirms all 6 PNGs `1280 x 800, 8-bit/color RGBA, non-interlaced`; SHA-256 of 5/6 artifacts **byte-identical** to the 2026-09-03 1805 re-review record across three separate sessions spanning two days — the catalog typewriter/token/dense/form and observatory artifacts are bit-reproducible. Cybercore is byte-stable within a fixed source tree (my two runs identical: `64f9f775…`) but shifted from the builder/1805 value (`b18d46c2…`) — root-caused in F1.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | `EVIDENCE_GAP` (residual risk carried to Task 1805) | Moderate | Open | Harness proves **structural** honesty (existence/non-empty/magic/dims) but has **no content-stability assertion**; live falsification: `cybercore_shell_teal_skin.png` changed 57,854→57,520 bytes (different SHA-256) between builder's 15:46 run and my 16:39/17:08 runs while **all three suites stayed green** — a real visual change in the parallel session's `warp_prism_ui` token/theme edits (15:41–15:55: `prism_token_registry.dart`, `ds_theme.dart`, `ds_cybercore_teal_skin.dart`) passes this oracle undetected. Not a violation of 1834's declared exits (which promise structure-only verification); it **is** a live demonstration that the oracle is intentionally content-blind, which Task 1805's golden/human layer must cover. | this review | `docs/reports/captures/candidates/cybercore_shell_teal_skin.png` mtime 15:46 (57,854 per 1805 record + builder table) vs 16:39 (57,520); `packages/warp_prism_ui/lib/src/tokens/*` mtimes 15:41–15:55 |
| F2 | `NEW` (candidate, not required) | Low | Open | 163-line helper block (`VisualCaptureArtifact`, `_repositoryRoot`, `_verifyPngArtifact`, `_captureScreenshot`, `_setDesktopViewport`) duplicated across the 3 harness files (catalog↔cybercore byte-identical; catalog↔observatory differs by 1 blank line). Classification: **CANDIDATE**, not REQUIRED_CONSOLIDATION — consolidation requires either a new shared home or protected `pubspec.yaml` edits in 2 more apps (out of scope; explicitly warned against by the task's anti-guardrail and the parallel host-composition effort). | this review | `apps/*/integration_test/*_capture_test.dart` lines 15–178 |
| F3 | `NEW` (informational) | Low | Open | Honesty sabotage exercises raster failure via the test-only flag rather than breaking the real raster path; the boundary-not-found `StateError` route (catalog:114-119) has no dedicated sabotage case. Acceptable: same `fail()` convergence site; the permanent test + live driver exception make the oracle real. | this review | `catalog:110-112`, `catalog:114-119` |
| F4 | `NEW` (environmental, not builder-attributable) | Moderate (operational) | Open | **Shared-worktree validation collision**: a parallel session is concurrently building `warp_prism_catalog` and mutating `warp_prism_ui`. One of my catalog runs (~16:57, during the parallel 16:56 `flutter build linux --debug`) executed **1 unrelated test** from the parallel session's `host_exercise` suite (output named `catalog-nav-gallery`/fuzz-trace debug lines absent from the capture file) instead of the 5 capture tests — the shared `build/linux/x64/debug/bundle/warp_prism_catalog` path served the wrong binary. Builder's evidence was **not** contaminated (counts/sizes match my clean runs exactly), but any future validation in this worktree can be silently corrupted the same way. | this review | `ps aux` 16:56 build PID; run-B transcript `tmp/review1834-catalog-run2.txt`; `host_exercise/` mtimes 16:41–16:55 |
| F5 | `NEW` (cosmetic) | Low | Open | BLOCKED message composes `driverError` unguarded — on a future driver-capable runner it would read `integration driver takeScreenshot unavailable (null)`. Assertions still hold (BLOCKED/Missing-capability strings present), so the honesty test remains valid cross-runner; message accuracy degrades. | this review | `catalog:158-162` |
| F6 | `NEW` (informational) | Low | Open | `_repositoryRoot()` silently falls back to `Directory.current` if no ancestor has `docs/reports/` — could create `candidates/` under an unexpected cwd and still pass verification. Benign on this repo layout (both builder and reviewer runs resolved the true root; live output shows absolute repo-root paths). | this review | `catalog:33-42` |

**No Critical or Serious findings.** All builder claims verified; no fabrication: self-reported test counts (5/5, 2/2, 2/2) match actual output exactly; the self-close 100/100 was properly labeled Score-only self-check with zero lane authority claimed (protocol-compliant), and the task correctly remained un-promoted awaiting this independent review.

## Post-Acceptance Revalidation Mapping (AGENTS.md §3.6)

### Which evidence claims were contradicted by the false-PASS finding

The controlled-realignment finding (task Origin, 2026-09-03) contradicted the **1805-era claim that a green capture suite PASS proved screenshot capture capability** — pre-1834 semantics could yield PASS while `takeScreenshot` emitted `MissingPluginException` and (in the both-paths-failed world) without any verified screenshot bytes. Invalidated dimension: **capability-proof semantics of a green suite** (the oracle could not fail).

### What this fix re-establishes

1. **Fail-closed BLOCKED semantics**: both-paths-failed ⇒ `TestFailure` naming the exact missing capability — verified live in all three suites via the permanent honesty tests (5/5, 2/2, 2/2 green runs each include the honesty test passing for the right reason).
2. **Capability proof via artifact assertions**: existence, non-emptiness, ≥24 bytes, PNG magic, IHDR 1280×800 dims — independently confirmed on disk for all 6 artifacts.
3. **Driver call as documented best-effort fallback** — not silently required (standalone driver failure doesn't fail), not silently swallowed (error captured, logged with channel name, and embedded in the BLOCKED message when the gate trips).
4. **Oracle-can-fail proof** — permanent automated honesty test per harness + builder's transient sabotages #1/#2 (message sites verified verbatim in source).
5. **All six validation gates green** — reproduced with clean exit capture.

### What remains invalid / revalidation still required

- **Task 1805 packet assembly remains `REVALIDATION_REQUIRED`**: not because 1834's repair failed, but because (a) the human PENDING-USER eleven-criteria gate is untouched and still open, and (b) **the candidate bytes are a moving target while parallel waves mutate `warp_prism_ui`** — the 1805 artifact table's cybercore hash is no longer current-source truth (F1). Task 1805 must re-baseline candidates from a quiesced tree (or record source-state alongside captures) before assembling its packet. Any 1805 packet built from pre-15:55 bytes would carry stale cybercore visuals.
- **Content-stability is not guarded by 1834's semantics** (by design — structure-only). Detecting visual drift remains the golden-comparison/human layer of Task 1805; today's live 57,854→57,520 drift with all-green suites is the concrete proof that the layer boundary is real.

### Unaffected history preserved

- The 2026-09-03 1805 re-review's `PASS` remains historically valid for its evidence snapshot: its six artifacts were real, verified bytes (five of six still bit-reproducible today). 1834 does not retroactively invalidate it; it repairs the semantics going forward. No history rewritten.

## Evidence Reviewed

- **Task file**: `docs/tasks/01-open/1834-warp-prism-capture-proof-honesty.md` (full: diagnosis table, sabotage proof, Changelog Draft, Completion Evidence)
- **Source/test files**: the three capture harnesses (full read); `apps/cybercore/lib/main.dart`, `app/router.dart`, `app/cybercore_shell.dart`, `features/providers/providers_page.dart`, `data/fixtures/fixture_loader.dart` (root-cause analysis for F1/F3-adjacent race); `apps/catalog/pubspec.yaml` (parallel-session attribution)
- **Governance**: `AGENTS.md` §7.1–7.2, §3.6; task AGENTS contract; `gt-global-subagent-review.md`; flutter + code-quality harnesses
- **Commands run**: 6 analyze/test commands listed above (exact exits recorded); `file` metadata; `sha256sum` (pre/post-run, twice); `ps aux` (parallel-session attribution); mtime-window sweeps (15:00–16:00 builder writeset verification); grep for golden references (0 hits)
- **Commands not run and why**: `git status`/`git log` — denied by environment permission policy (noted; filesystem mtime evidence used instead). No implementation-file sabotage re-executed — write-scope forbids mutating implementation files; substituted with source-site verification + live permanent-honesty-test execution.
- **Runtime wiring proof**: not applicable — task is a test-harness honesty repair; the harnesses themselves are the runtime surface and were executed on the real Linux host runner.

## Path To 100 (96 → 100)

1. **F1 (−2)** — Carry forward to Task 1805 (not 1834): require packet assembly from a quiesced source tree, or record a source-state stamp (e.g., hash of `warp_prism_ui` token/theme files) beside each candidate, or add an opt-in byte-stability assertion (two consecutive captures must match) in the 1805 layer where goldens are authorized.
2. **F2 (−1)** — When the parallel host-composition harness lands, consolidate the 3×163-line helper block into the shared testkit under that effort's scope (it owns the new surface + pubspec edits); until then this duplication is the cheaper, safer choice.
3. **F3 (−1)** — Add one permanent honesty variant that breaks the real raster path (e.g., pump without the capture-root `RepaintBoundary`) so the boundary-not-found `StateError` route has its own oracle.
4. **F5 (cosmetic)** — Guard the `driverError` interpolation ("unavailable (null)" → "returned no artifact") for future driver-capable runners.
5. **F6 (cosmetic)** — Make `_repositoryRoot()` fail loudly when no repo root is found instead of silently writing candidates into cwd.

## Residual Risks

1. **Moving-target worktree (F4)**: parallel Tasks 1831/1832 actively build catalog and mutate `warp_prism_ui` in this worktree; any validation run can be bundle-collision-corrupted (demonstrated live) and artifacts can shift bytes (demonstrated live). Mitigation: serialize catalog validation waves, or use isolated build directories/worktrees when the toolchain supports them.
2. **Content-blind oracle (F1)**: a visual regression preserving 1280×800 structure stays green — by design until Task 1805's golden layer.
3. **CyberCore async fixture race (out of scope)**: `ProvidersPage.initState` fires a real `rootBundle` fixture load racing the fixed 500 ms pump; under heavy machine load the raster can catch a different render state. My two runs were byte-identical, but the race window exists in app source (not the harness) — belongs to the host-composition effort, not 1834.
4. **Path-scoped analyze only** — per task contract; full-package analysis was not demanded and not run.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- **Date**: 2026-09-04
- **Reviewer profile**: `reviewers` (gt-reviewers-reviewer-flutter, REVIEW-1834)
- **Score**: 96/100
- **Verdict**: PASS (post-acceptance revalidation of the false-PASS repair — all 1834 claims reproduced; no Critical/Serious findings)
- **Full report**: `docs/reports/review/1834-capture-proof-honesty-independent-review-2026-09-04.md`
- **Lane outcome**: no move performed (reviewer holds no lane authority in this dispatch)
- **Task reference**: Task 1834 (`warp-prism-capture-proof-honesty`)

#### Current Open Blockers
- `EVIDENCE_GAP` (F1, Moderate, carried to Task 1805): candidate bytes are a moving target under parallel `warp_prism_ui` edits; 1805 must re-baseline from a quiesced tree before packet assembly.
- `NEW` (F2, Low): 163-line helper duplication ×3 — consolidate via host-composition effort, not 1834.
- `NEW` (F4, Moderate operational): shared-worktree bundle collisions can corrupt catalog validation runs; serialize waves.

#### Path-to-100 Summary
- Source-state stamping or byte-stability assertion in the 1805 layer (F1).
- Testkit consolidation when the parallel harness lands (F2).
- Real-raster-path honesty variant (F3); driverError message guard (F5); loud repo-root fallback (F6).
```

---

*Review closed read-only. No product code, task files, protected files, or lanes were modified. Evidence transcripts preserved at `tmp/review1834-catalog-run2.txt` (contaminated run), `tmp/review1834-catalog-run3.txt`, `tmp/review1834-obs-run2.txt`, `tmp/review1834-cc-run2.txt`.*
