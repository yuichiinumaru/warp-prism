# Task 1861: PrismMeter atom plus PrismFaderStrip molecule and canvas-host contract

Change only the meter/fader seam in `warp_prism_ui`: add EXPERIMENTAL atom
`PrismMeter` (injected scale + zone thresholds) + molecule `PrismFaderStrip`
(meter + fader + label + dB readout slot) + the narrow generic canvas-host
contract (fixed-viewport determinism, bounded data, a11y numeric fallback).
Success is the stated observable behavior, verified by the relevant checks.

## Outcome and boundaries

- **Authorized outcome**: reusable meter geometry exists (vertical fill,
  zone bands, peak-hold marker, fader track + handle + drag semantics) with
  calibration fully injected (dBFS floor, LUFS targets, RMS windowing stay
  caller-side). Narrow canvas-host contract defined for the one generic seam
  that may later crystallise a satellite — no satellite package in this wave.
- **Subject**: `warp_prism_ui` atom/molecule layer + contract doc/type for the
  host seam.
- **Constraints**: no audio types in `warp_prism_ui` (boundary B14: no
  consumer domain; B4: no persistence/IO; calibration types are domain —
  keep them out). Geometry generic, calibration injected. a11y numeric
  (semantics role + value), never colour-only. Fixed-value goldens only —
  meters are the classic animation-capture trap.
- **Non-goals**: no LUFS/RMS calibration, no FFT/spectral/goniometer
  painters, no DSP/insert chains, no `warp_prism_audio_ui` split, no DAW
  orchestration (all product-local per §4.5).

## Context / reliance

- Source evidence: backlog F-13 card (TP `_buildPeakMeter`/`_buildLufsMeter`/
  `DbFader`/`PanKnob`/`StudioTrackControls`/`StemMixer`/`MasterBusStrip`;
  Prism linear-only `PrismMetricTile`/`Sparkline`; Macro P1-6/C2).
- Negative evidence honoured: Warpblade metering not applicable.
- MISSION §§4.1/4.5/7 (ADS owns visual; domain + data-plane stay local);
  layer-contracts §§1, 4, 8.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart` | Reference | Linear/health conventions to compose, not fork |
| `packages/warp_prism_ui/lib/src/atoms/ds_sparkline.dart` | Reference | Sparkline pattern; read before geometry work |
| `packages/warp_prism_ui/lib/src/atoms/` | Extend | New `PrismMeter` atom home (new file, existing dir) |
| `packages/warp_prism_ui/lib/src/molecules/` | Extend | New `PrismFaderStrip` molecule home (new file) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read-only | No export added (EXPERIMENTAL) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Includes no-audio-types clearance posture |
| `apps/catalog/lib/` | Proof lab | Fixed-value gallery entries |

## Work / responsibility

- [ ] Read metric-tile/sparkline conventions + boundary harness audio/type
  posture before mutation.
- [ ] Specify injected scale descriptor + zone thresholds + a11y numeric
  contract + canvas-host contract (fixed viewport, bounded data, placeholder
  determinism).
- [ ] Implement atom + molecule + fake scale + conformance (zones, peak-hold,
  drag semantics, a11y value) + fixed-value goldens.
- [ ] Prove no audio/domain type enters `warp_prism_ui` (grep evidence).
- [ ] Gallery entries; run full validation below.

## Success and verification

- Fixed-value goldens green at documented viewport + value; no animation
  dependence; a11y semantics carry numeric value.
- Boundary clearance: no audio/domain imports in `warp_prism_ui`; grep
  evidence recorded.
- Host proof: Tempest studio route composes meter + fader — interact, no
  framework errors / overflow, theme/focus intact.
- MISSION §6: items 1 (mandate + Macro C2), 2–4 (fake + conformance +
  boundary), 5 (host proof), 7 (review). Item 6 n/a.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_ui
grep -rnE "dBFS|LUFS|FFTGoniometer|SpectralPainter|Tempest[A-Z]" packages/warp_prism_ui/lib/src/atoms packages/warp_prism_ui/lib/src/molecules || true
```

## Evidence / assessment

- Bind results here: golden paths, grep output, host-exercise evidence,
  review verdict.

**Parallelizable with**: Task 1858, Task 1860 — disjoint seams; shared
barrel/gallery guards read-only here.

## Parent verification — 2026-11-01 (builders lane; COMPLETE, post-fixer)

Supersedes the PARTIAL note above. The solo-fixer turn (`sh_1976c52e1001S147i9h9UeZJjn`) plus parent serial verification closed every remainder item.

- **Fixer outcome**: replaced fragile pointer drags with keyboard fader adjust (deterministic, a11y-first), restored `FlutterError.onError` in `finally` before asserts (fixes runner poisoning + shutdown hang), added `faderFocusNode` plumbing, converted footer `Row+Spacer` to `Wrap` (fixes 195px/2x overflow as product code, not test-only).
- **Parent re-run (fresh, after return, tree quiet, `--no-pub` — plain `flutter test` hangs on pub-network stall in this env; pubspecs untouched so `--no-pub` is proof-equivalent)**: conformance → **17/17 pass**; host file → **2/2 pass**; golden file as-is → **4/4 pass** (PNGs already on disk from fixer run, deterministic re-render confirmed); pure-dart boundary harness → **66/66 PASS** (3 `meter_1861_*` green); `dart format` on 7 touched paths → 0 changed; `flutter analyze` on 7 seam paths → **No issues found**; no barrel/alias exports.
- **Root causes established**: (1) host-test hangs were flutter-tool contention (orphan `flutter_tester` processes from killed runs — 7 reaped by parent) compounded by pub-network stalls (`flutter test` implicit `pub get` hangs with zero output; `--no-pub` runs instantly); (2) test-logic bugs (off-screen tap, onError-guard poisoning) fixed by the fixer, plus one genuine product overflow fixed in `ds_fader_strip.dart` footer.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e5189151effeLEom6J55hHEubr` (independent — did not build). Report: `.project/reports/reviewers/1861-warp-prism-meter-fader-canvas-host-review-loop.md` (created; no prior entries existed).
- **Verdict**: PASS (90/100 diagnostic). No remediation.
- **Accepted evidence**: 23/23 task tests (17 conformance + 4 golden + 2 host); format 0-changed; zero attributable analyzer findings; boundary 81/81 (3× `meter_1861_*`); task-exact no-audio grep zero matches; zero barrel/alias exports; no controllers/timers/async in seam; stateless deterministic; units opaque with caller formatters.
- **Residual (non-blocking)**: real Tempest studio/mixer host proof owed before STABLE; package proof suffices at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 90/100; 23/23, no-audio posture verified, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1861-warp-prism-meter-fader-canvas-host-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
