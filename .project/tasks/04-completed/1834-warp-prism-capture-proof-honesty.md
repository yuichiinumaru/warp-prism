# Task 1834: Visual Capture Proof Honesty — MissingPluginException Must Not Be PASS

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status (`00-planning/`, `01-open/`, `02-doing/`, `03-review/`, or `04-completed/`). Do not add a task-level `Status` field; record richer state in the body or Review Trail.
> **Review State**: `Open` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: Controlled realignment 2026-09-03 — capture harness reports test PASS while the screenshot operation emits `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)`; current PASS therefore does not prove screenshot capture capability
> **Blocks**: Task 1805 (visual packet must rest on honest capture proof)
> **Depends on**: N/A (secondary to Tasks 1831–1833 real-host correctness; may run in parallel — different writeset)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable
- **Capability / Gate advanced**: Honest proof machinery — the capture oracle must be able to fail
- **Strategic why**: A test that cannot fail is not evidence. The capture suite is the foundation of the Task 1805 visual gate; false-confidence PASS undermines every downstream acceptance claim.
- **Consequence if absent**: Task 1805 keeps accumulating green checks that prove nothing about screenshot capability; a future real capture failure would be invisible until a human looks.

---

## Objective

Diagnose the supported capture path on this Linux/desktop environment and make the capture-test semantics honest: if `captureScreenshot` is unavailable and no real screenshot bytes are produced and verified, the test must report BLOCKED or FAIL — never PASS. If a supported local-render path (e.g. `RenderRepaintBoundary.toImage`) genuinely produces verified PNG bytes, keep it as the primary proof and demote the driver call to documented best-effort fallback with explicit assertions on the primary artifact.

## Background Context

### What already exists

- Capture harnesses: `apps/catalog/integration_test/visual_acceptance_capture_test.dart`, `apps/observatory/integration_test/observatory_visual_capture_test.dart`, `apps/cybercore/integration_test/cybercore_visual_capture_test.dart`.
- Prior remediation history (Task 1805 trail): local `RepaintBoundary` rasterization was added as the primary path with non-empty-file assertions; driver `takeScreenshot` kept as fallback. Prior reviews treated the `MissingPluginException` as non-blocking.
- The controlled-realignment finding asserts the current semantics still over-claim: test PASS does not establish screenshot capture capability on this runner.

### What is missing or broken

- It is UNKNOWN from the task author's seat whether the local-render path actually yields verified bytes on this runner in all three harnesses, or whether some harness still passes on fallback-swallowed exceptions. The builder must establish this from source + execution reality.
- The honest-semantics rule is unenforced: unavailable-capture → BLOCKED/FAIL is not encoded in the harness.

---

## Test Requirements

- Execute each of the three capture harnesses and record, per harness: does a verified non-empty PNG reach disk via a real raster path, or does execution pass through the `MissingPluginException` path?
- After the fix: sabotage check — with the raster path deliberately disabled (or on a runner without capture support), the test must BLOCKED/FAIL, proving the oracle can now fail.
- `flutter analyze` clean for touched files.
- No committed golden baselines refreshed. Candidate-output paths only (`docs/reports/captures/candidates/`); never write to golden directories from these tests.

---

## Exit Conditions

- [x] Per-harness diagnosis recorded (real-bytes path vs exception path, with evidence).
- [x] Harness semantics honest: unavailable capture → BLOCKED/FAIL, verified bytes → PASS, with assertions on artifact existence + non-emptiness (+ dimensions where cheap).
- [x] Sabotage check proves the oracle can fail.
- [x] `flutter analyze` + capture-harness runs green under the new semantics (or honestly BLOCKED with the exact missing capability named, if the runner truly cannot capture).
- [x] Local changelog draft added to task evidence (parent publishes via engine).
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read all three capture-test files fully; trace the exact exception-handling path around `takeScreenshot` and around the local raster path; check what each test asserts vs what it assumes.
- [x] Run each harness; record per-harness capture reality (bytes on disk + sizes + `file` metadata vs exception path taken).
- [x] Implement honest semantics at the owning layer (shared helper if the three harnesses share one; per-harness otherwise — check for duplication first).
- [x] Sabotage check: prove BLOCKED/FAIL when capture is unavailable.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [x] **Regression verification**: run the validation commands listed below.

### Where

| File | Purpose |
| --- | --- |
| `apps/catalog/integration_test/visual_acceptance_capture_test.dart` | Read / Modify — honest capture semantics |
| `apps/observatory/integration_test/observatory_visual_capture_test.dart` | Read / Modify — honest capture semantics |
| `apps/cybercore/integration_test/cybercore_visual_capture_test.dart` | Read / Modify — honest capture semantics |
| `docs/reports/captures/candidates/` | Write (test output only) — candidate PNGs |

### How

1. Reads + per-harness execution reality first; record the diagnosis table.
2. Minimal semantics fix (assert primary artifact; honest BLOCKED/FAIL; no swallowed exceptions).
3. Sabotage check proving the oracle can fail.
4. Gates: analyze + harness runs. Hand off with evidence packet. Do NOT invent a new screenshot framework.

### Why

This task repairs the oracle, not the product. It is deliberately secondary to Tasks 1831–1833 (real-host correctness first), but it must land before any fresh Task 1805 visual packet is assembled — otherwise the packet's foundation is unverifiable.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without the sabotage check. A capture test that still cannot fail is not fixed.

> [!IMPORTANT]
> Do NOT build a second UI crawler/screenshot framework in this worktree — a parallel effort is preparing the stronger host-composition harness; this task only makes the existing harness honest. No golden refresh. No VCS operations.

---

## Validation Commands

```bash
cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart --no-fatal-infos --no-fatal-warnings
cd apps/observatory && flutter analyze integration_test/observatory_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings
cd apps/cybercore && flutter analyze integration_test/cybercore_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings
cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --no-pub
cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart --no-pub
cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart --no-pub
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `apps/catalog/integration_test/visual_acceptance_capture_test.dart` (modified — honest capture semantics, `VisualCaptureArtifact`, `_verifyPngArtifact`, artifact assertions, and automated honesty sabotage test)
  - `apps/observatory/integration_test/observatory_visual_capture_test.dart` (modified — honest capture semantics, `VisualCaptureArtifact`, `_verifyPngArtifact`, artifact assertions, and automated honesty sabotage test)
  - `apps/cybercore/integration_test/cybercore_visual_capture_test.dart` (modified — honest capture semantics, `VisualCaptureArtifact`, `_verifyPngArtifact`, artifact assertions, and automated honesty sabotage test)
  - `docs/reports/builders/20260904-task-1834-capture-proof-honesty-self-review.md` (created — self-close report)
  - `docs/reports/captures/candidates/` (output PNG artifacts verified: 4 catalog, 1 observatory, 1 cybercore)
- **Per-harness diagnosis**:
  | Host / Harness | Local Render Raster Path (`toImage` -> PNG) | Integration Driver Path (`takeScreenshot`) | Reality & Diagnostic Finding |
  |---|---|---|---|
  | `apps/catalog` (`visual_acceptance_capture_test.dart`) | Produces verified non-empty PNGs (4 files: `catalog_typography_specimen.png` [32KB], `catalog_token_swatches.png` [32KB], `catalog_dense_organism.png` [16KB], `catalog_form_primitive.png` [27KB]). All 1280x800 RGBA. | Throws `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)` | Driver screenshot is unimplemented on Linux desktop platform channel. Local `RenderRepaintBoundary.toImage` genuinely produces real pixel bytes. |
  | `apps/observatory` (`observatory_visual_capture_test.dart`) | Produces verified non-empty PNG (`observatory_overview_dashboard.png` [26KB], 1280x800 RGBA). | Throws `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)` | Driver screenshot unimplemented. Local render path produces valid PNG bytes. |
  | `apps/cybercore` (`cybercore_visual_capture_test.dart`) | Produces verified non-empty PNG (`cybercore_shell_teal_skin.png` [57KB], 1280x800 RGBA). | Throws `MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)` | Driver screenshot unimplemented. Local render path produces valid PNG bytes. |
- **Sabotage proof**:
  | # | Path Sabotaged | Breakage Applied | Test Affected | Result Observed | Reverted |
  |---|----------------|------------------|---------------|-----------------|----------|
  | 1 | Visual capture availability | Set `disableRasterForTesting: true` on typography specimen | `visual_acceptance_capture_test.dart` | ✅ FAILED as expected: `BLOCKED: Visual capture unavailable for "catalog_typography_specimen". Missing capability: local RepaintBoundary rasterization failed ... and integration driver takeScreenshot unavailable (MissingPluginException...).` | ✅ Yes |
  | 2 | Artifact dimension verification | Set `expectedWidth: 1920` on token swatches | `visual_acceptance_capture_test.dart` | ✅ FAILED as expected: `Visual capture artifact width mismatch for catalog_token_swatches: expected 1920 but got 1280` | ✅ Yes |
  | 3 | Automated honesty test in suite | Call `_captureScreenshot(..., disableRasterForTesting: true)` | All three harnesses (`catalog`, `observatory`, `cybercore`) | ✅ PASSED: `throwsA(isA<TestFailure>())` verified that unavailable capture throws `TestFailure` with BLOCKED and names missing capability | ✅ Permanent test in each suite |
- **Tests or validation commands**:
  - `flutter analyze integration_test/visual_acceptance_capture_test.dart --no-fatal-infos --no-fatal-warnings` (workdir `apps/catalog`): exit code 0 (No issues found)
  - `flutter analyze integration_test/observatory_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings` (workdir `apps/observatory`): exit code 0 (No issues found)
  - `flutter analyze integration_test/cybercore_visual_capture_test.dart --no-fatal-infos --no-fatal-warnings` (workdir `apps/cybercore`): exit code 0 (No issues found)
  - `flutter test integration_test/visual_acceptance_capture_test.dart --no-pub` (workdir `apps/catalog`): exit code 0 (5/5 tests passed)
  - `flutter test integration_test/observatory_visual_capture_test.dart --no-pub` (workdir `apps/observatory`): exit code 0 (2/2 tests passed)
  - `flutter test integration_test/cybercore_visual_capture_test.dart --no-pub` (workdir `apps/cybercore`): exit code 0 (2/2 tests passed)
- **Local changelog draft**:
  ```markdown
  ### Changelog Draft

  - **task**: 1834
  - **agent**: gt-builders-engineer-flutter
  - **project**: warp-prism
  - **title**: honest-capture-proof-semantics
  - **description**: Make visual-capture harness semantics honest with fail-closed checks on missing capture capabilities, direct PNG artifact verification, and automated sabotage tests.
  - **summary**: Diagnosed Linux desktop capture reality across Catalog, Observatory, and CyberCore test harnesses. Local `RenderRepaintBoundary.toImage` confirmed as primary working raster path producing verified 1280x800 PNG bytes, while unimplemented driver `takeScreenshot` is demoted to documented fallback. Added `VisualCaptureArtifact` validation checking file existence, non-emptiness, PNG magic signature, and IHDR dimensions. Unavailable capture now fails closed with honest BLOCKED/FAIL naming `plugins.flutter.io/integration_test`. Sabotage checks confirmed oracle failure on disabled capture and dimension mismatch.
  - **verification**: `flutter analyze` clean in all 3 apps; all 3 capture test suites pass (5/5 catalog, 2/2 observatory, 2/2 cybercore); sabotage checks verified.
  ```
- **Executor**: gt-builders-engineer-flutter
- **Completion date**: 2026-09-04

---

## Review Ledger

### Independent Review — 2026-09-04 (PASS)

- **Reviewer**: `gt-reviewers-reviewer-flutter`, session `ses_f923db084ffeGnwneMKIpClg5O`
- **Verdict**: `PASS`; **score** `96/100`; **confidence** `high`
- **Full report**: `docs/reports/review/1834-capture-proof-honesty-independent-review-2026-09-04.md`
- **Every builder claim independently reproduced from live filesystem + fresh execution**: driver `MissingPluginException` on all 3 harnesses (live); local `toImage` path yields verified 1280×800 RGBA bytes (file metadata + SHA-256 on all 6 artifacts); both-paths-failed ⇒ `TestFailure` BLOCKED naming the capability, with the honesty test proven **non-tautological**; artifact verification (existence/non-empty/PNG magic/IHDR dims, offsets 16/20 BE) confirmed; 0/0/0 analyzes and 5/5, 2/2, 2/2 test runs exit 0, twice each.
- **Revalidation mapping**: contradicted (green-suite ⇒ capture-capability proof) re-established as fail-closed; Task 1805 packet remains `REVALIDATION_REQUIRED` (human gate open + moving-target candidates); history preserved.
- **Carry-forward findings to Task 1805**:
  - **F1 (Moderate)**: the oracle is content-blind by design — during the review, `cybercore_shell_teal_skin.png` shifted 57,854→57,520 bytes (different SHA-256) because the parallel 1833 session edited `warp_prism_ui` tokens/theme while captures ran, and all suites stayed green. **1805 must re-baseline candidates from a quiesced tree, or stamp source-state beside captures.**
  - **F4 (Moderate, operational)**: shared-bundle-path collision — one catalog run executed 1 unrelated test from the parallel session's `host_exercise` suite while it built the same binary. **Serialize catalog validation waves or isolate build dirs.**
  - Bit-reproducibility reconfirmed: five of six artifacts byte-identical across 3 sessions/2 days; cybercore byte-stable within a fixed source tree.
- **Lane action**: none performed by reviewer; parent owns promotion.

## Agent Session Ledger

(to be appended per session)

- `2026-09-04 (parent — promotion)`: independent review PASS 96/100 with two material carry-forwards to Task 1805 recorded above (quiesced-tree re-baseline; serialized/isolated catalog validation). Lane move `01-open/ → 04-completed/` authorized by task-governance owner. Changelog entry published via manage-changelog engine.
