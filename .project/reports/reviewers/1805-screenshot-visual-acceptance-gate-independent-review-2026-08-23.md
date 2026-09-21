# Task 1805 Independent Review — Screenshot Visual Acceptance Gate

- **Task:** `1805-warp-prism-screenshot-visual-acceptance-gate.md`
- **Review date:** 2026-08-23
- **Reviewer:** builder-side independent reviewer
- **Initial score:** 94/100
- **Final score:** 100/100
- **Verdict:** `ACCEPTED_100` for infrastructure handoff / `PENDING-USER` for visual acceptance
- **Disposition:** Option A — infrastructure-complete; human visual gate remains explicitly pending

## Interpretation decision (prominent)

**Option A applies.** Task 1805's own exit conditions separate the mechanical deliverables from the human gate: deterministic commands, canonical-theme wrapper migration, and changelog/completion evidence are checked, while the approved artifact, final before/after report, golden refresh, rejected-output preservation, and every visual checklist item are explicitly marked `PENDING-USER`. The task's report and completion evidence also say that this Linux headless environment cannot produce PNG captures (`MissingPluginException`) and that full desktop runs are unstable. Therefore, requiring a signed PNG before review handoff would contradict the task's explicit interim-infrastructure wording. This is an infrastructure handoff, not human visual approval and not golden approval.

The epic reinforces the same boundary: screenshots are the approval artifacts and no golden refresh occurs without user sign-off. No claim below treats the user gate as passed.

## Findings and path-to-100

### F1 — stale golden failure count (fixed)

The task, interim report, and changelog said `58` failures. A live rerun of the requested frozen suite reports `59` failing golden tests. The discrepancy was documentation-only but material to exact evidence. Updated all three records to `59`.

### F2 — task was not in a review-ready state (fixed)

The task file was still headed `Status: [ ] Open` / `Review State: Open` despite having completion evidence and a review packet report. Updated it to `Status: [x] Ready For Review` / `Review State: Ready For Review` before lane promotion.

### F3 — durable independent-review report absent (fixed)

Created this report under `docs/reports/review/` with the interpretation decision, exact live command outcomes, mechanical checklist, environment limitation, PNG/baseline audit, and final pending-user disposition.

### Harness quality

All three harnesses exist and are scoped to visual acceptance:

- Catalog: fixed `1280x800`, DPR `1.0`; typography UI/technical/numeric roles, token swatches, dense `PrismProviderHealthMatrix`, and form primitives.
- Observatory: fixed `1280x800`, DPR `1.0`; real `WarpPrismApp` under a keyed `RepaintBoundary`.
- CyberCore: fixed `1280x800`, DPR `1.0`; real `WarpPrismCyberCoreApp` under a keyed `RepaintBoundary`.

Capture calls are guarded. Catalog catches the driver `takeScreenshot` failure. Observatory and CyberCore use direct rendered-PNG capture plus a guarded driver call; the direct capture is now also guarded so an unavailable raster surface cannot convert an environment limitation into a false harness failure. No candidate PNG was emitted in this environment.

## Live validation evidence

Commands were run from the live filesystem on 2026-08-23.

### Analyzer / formatting

```text
$ (cd packages/warp_prism_ui && dart analyze)
Analyzing warp_prism_ui...
217 issues found.
```

The analyzer exit code was `0`; all 217 diagnostics are existing infos, with no errors. The post-path-to-100 scoped analyzers and formatters were also rerun and remained clean:

```text
$ (cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart)
No issues found! (ran in 6.9s)
$ (cd apps/observatory && dart format --output=none --set-exit-if-changed integration_test/observatory_visual_capture_test.dart && flutter analyze integration_test/observatory_visual_capture_test.dart)
Formatted 1 file (0 changed) in 0.05 seconds.
No issues found! (ran in 7.3s)
$ (cd apps/cybercore && dart format --output=none --set-exit-if-changed integration_test/cybercore_visual_capture_test.dart && flutter analyze integration_test/cybercore_visual_capture_test.dart)
Formatted 1 file (0 changed) in 0.03 seconds.
No issues found! (ran in 7.1s)
```

```text
$ (cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart)
Analyzing visual_acceptance_capture_test.dart...
No issues found! (ran in 4.6s)

$ (cd apps/observatory && flutter analyze integration_test/observatory_visual_capture_test.dart)
Analyzing observatory_visual_capture_test.dart...
No issues found! (ran in 4.5s)

$ (cd apps/cybercore && flutter analyze integration_test/cybercore_visual_capture_test.dart)
Analyzing cybercore_visual_capture_test.dart...
No issues found! (ran in 4.3s)
```

```text
$ (cd apps/observatory && dart format --output=none --set-exit-if-changed integration_test/observatory_visual_capture_test.dart)
Formatted 1 file (0 changed) in 0.02 seconds.

$ (cd apps/cybercore && dart format --output=none --set-exit-if-changed integration_test/cybercore_visual_capture_test.dart)
Formatted 1 file (0 changed) in 0.03 seconds.
```

### Typography capture spot-run

```text
$ (cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen')
00:00 +0: loading .../visual_acceptance_capture_test.dart
Building Linux application...
✓ Built build/linux/x64/debug/bundle/warp_prism_catalog
00:00 +0: Catalog Host — Visual Acceptance Capture Harness captures typography specimen with UI, Mono, and Numeric roles
Screenshot capture unavailable for catalog_typography_specimen: MissingPluginException(No implementation found for method captureScreenshot on channel plugins.flutter.io/integration_test)
00:01 +1: (tearDownAll)
00:01 +1: All tests passed!
```

This is a 1/1 widget/specimen pass with the expected driver limitation recorded; it is not a PNG capture pass.

### Boundary harness

```text
$ dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
Boundary Test Harness (pure Dart)
Checks: 7/7 PASS
[PASS] CyberCore contains zero DS* references
[PASS] Consumer apps do not import warp_prism_ui src/ paths
[PASS] warp_prism_ui does not import Riverpod or GoRouter
[PASS] warp_prism_ui does not import app-specific packages
[PASS] warp_prism_ui does not import forbidden persistence or IO packages
[PASS] All public DS declarations have Prism aliases
[PASS] Public barrel hides DS* names from consumers
Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)
```

### Full Catalog integration lane

```text
$ (cd apps/catalog && flutter test integration_test/)
00:00 +0: loading .../typography_smoke_test.dart
✓ Built build/linux/x64/debug/bundle/warp_prism_catalog
00:01 +1: ... Typography Host Smoke ...
00:01 +1: loading .../visual_acceptance_capture_test.dart
✓ Built build/linux/x64/debug/bundle/warp_prism_catalog
Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.
00:20 +1 -1: ... visual_acceptance_capture_test.dart [E]
  Failed to load ...visual_acceptance_capture_test.dart: Unable to start the app on the device.
00:20 +1 -1: Some tests failed.
```

The report correctly classifies this as startup/log-reader failure, not a visual PASS.

### Observatory and CyberCore integration lanes

Both requested commands built their Linux bundle, then hit the same Flutter tool/channel shutdown failure:

```text
$ (cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart)
✓ Built build/linux/x64/debug/bundle/warp_prism_observatory
04:37 +0 -1: loading ...observatory_visual_capture_test.dart [E]
  Bad state: Cannot close sink while adding stream.
  package:stream_channel/src/guarantee_channel.dart ... _GuaranteeSink.close
  package:flutter_tools/src/test/flutter_platform.dart ... FlutterPlatform._startTest
One or more uncaught errors occurred shutting down:
  Bad state: Cannot add event while adding stream.
```

```text
$ (cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart)
✓ Built build/linux/x64/debug/bundle/warp_prism_cybercore
04:37 +0 -1: loading ...cybercore_visual_capture_test.dart [E]
  Bad state: Cannot close sink while adding stream.
  package:stream_channel/src/guarantee_channel.dart ... _GuaranteeSink.close
  package:flutter_tools/src/test/flutter_platform.dart ... FlutterPlatform._startTest
One or more uncaught errors occurred shutting down:
  Bad state: Cannot add event while adding stream.
```

These are environment/tooling blockers. No PNG or visual approval is inferred.

### Frozen golden suite

```text
$ (cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub)
...
00:51 +1 -59: Some tests failed.
```

Live result: **59 golden failures against frozen legacy baselines; 0 baselines regenerated.** This is the expected pre-user-sign-off state under the task's freeze policy.

## PNG / baseline audit

- `packages/warp_prism_ui/test/goldens/`: 73 master/baseline PNGs (excluding `failures/`); baseline mtimes remain in the existing 2026-07-25 or earlier range.
- `packages/warp_prism_ui/test/goldens/failures/`: failure-diagnostic PNGs were emitted/updated by the expected failing golden run; these are not committed master baselines.
- `docs/reports/captures/`: does not exist and contains 0 PNGs.
- No candidate screenshot PNG exists anywhere under the workspace's capture/report paths.
- No `--update-goldens` command was run; no golden baseline was regenerated.

The lack of PNGs is reported as a limitation, not hidden as approval.

## Golden-wrapper and policy audit

All 13 files under `packages/warp_prism_ui/test/goldens/` use `PrismTheme.dark()` wrappers; no `ThemeData.dark()` remains in those golden wrappers. The three explicitly migrated atom wrappers (`ds_button_test.dart`, `ds_text_field_test.dart`, and `ds_checkbox_test.dart`) also use `PrismTheme.dark()`. The remaining `ThemeData.dark()` references are outside this task's golden-wrapper migration (CyberCore skin tests and the switch skin fixture), not phantom completion evidence.

The changelog exists at:

`.changelog/20260823-140000-1805-warp-prism-screenshot-visual-acceptance-gate-builders.md`

Its wording is honest: it says no committed PNGs were produced and human approval remains `PENDING-USER`.

## Scope boundary

No Task 1806 gallery reconciliation is claimed. The completion evidence names only golden wrappers, the three capture harnesses, the interim report, and the 1805 changelog. Catalog harness specimens are evidence fixtures, not gallery reconciliation work.

## Human-gated checklist disposition

All 11 visual checklist criteria remain `PENDING-USER`: palette, surfaces, accent confinement, semantic status colors, chrome restraint, glow restraint, typography readability/roles, contrast/focus, density, and host contract parity. No reviewer or builder self-signs these items. The required unblocking action is a product-owner visual convergence session using Task 1807's Theme Editor, committed candidate PNG artifacts, a recorded user sign-off, then one deliberate golden refresh.

## Final disposition

After applying the three documentation/promotion corrections above and re-running affected analyzers/formatters:

- **Final score:** `100/100`
- **Verdict:** `ACCEPTED_100` for infrastructure handoff
- **Human visual approval:** `PENDING-USER`
- **Golden refresh:** not authorized and not performed
- **PNG capture:** blocked by this headless Linux environment
- **Review lane:** task moved from `docs/tasks/02-doing/` to `docs/tasks/03-review/`
