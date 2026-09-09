# Warp Prism Real-Host UI Exercise Harness — Builder Closeout Report

> **Date**: 2026-09-04
> **Executor**: `gt-builders-expert-flutter` (builders lane)
> **Status**: v1 complete, headless, 24/24 green; awaiting independent review
> **Companion docs**: [architecture-decision.md](architecture-decision.md) ·
> [finding-catalog-compact-overflow.md](finding-catalog-compact-overflow.md)
> **Rule 42**: no task lane moves were performed; no task claimed.

---

## 1. What was built

A bounded **real-host UI exercise harness** detecting UI/integration defect
classes that package/widget tests miss, via reproducible interaction
exploration of the three real proof hosts (Catalog, Observatory, CyberCore).

**Not** a redesign of Warp Prism. **Not** a replacement for
unit/widget/golden/integration tests. A new evidence mechanism for
HOST COMPOSITION CORRECTNESS.

## 2. Architecture (summary — full ADR in architecture-decision.md)

```text
packages/warp_prism_host_exercise/   # shared engine, zero warp deps
  models/     ExerciseCandidate · ExerciseTrace(seed JSON) · HostExerciseConfig
              ExerciseViewport (matrix) · ExerciseThemeRecipe
  safety/     ExerciseActionPolicy — SAFE / STATEFUL_LOCAL / EXTERNAL_DESTRUCTIVE
  oracle/     ExerciseErrorCollector — FlutterError + ErrorWidget scan +
              takeException + overflow/ancestor/route classifiers
  discovery/ ExerciseActionDiscovery — semantics → keys → tappables
              (deterministic sorted order; hit-testable only)
  runner/     ExerciseRunner — SMOKE / CRAWL / FUZZ / REPLAY + viewport
              + bounded-frame pumps (no pumpAndSettle: real hosts own
              perpetual animations by design)
  artifacts/  ExerciseTraceWriter — JSON traces + replay commands +
              fake-async-safe encode/decode

apps/<host>/test/host_exercise/       # per-host adapters (thin, no duplication)
  <host>_host.dart                     # bootstrap / routes / policy / reset
  <host>_exercise_test.dart            # SMOKE + CRAWL + FUZZ/REPLAY
  catalog_theme_matrix_test.dart       # theme ladder + viewport×recipe spot

tool/warp_ui_exercise.dart             # replay CLI (dart run, pure Dart)
docs/reports/host-exercise/traces/     # failure/proof artifacts (canonical)
```

**Headless by design**: suites live under `test/` (flutter_tester,
offscreen — no GPU window pops on the operator's desktop). An
`integration_test`/real-device runner variant can layer later without
changing suite semantics.

## 3. Files changed (exact)

Created (26):
- `packages/warp_prism_host_exercise/` — pubspec.yaml,
  analysis_options.yaml, lib barrel + 9 source files, 2 test suites
  (10 tests).
- `apps/catalog/test/host_exercise/` — catalog_host.dart,
  catalog_exercise_test.dart, catalog_theme_matrix_test.dart.
- `apps/observatory/test/host_exercise/` — observatory_host.dart,
  observatory_exercise_test.dart.
- `apps/cybercore/test/host_exercise/` — cybercore_host.dart,
  cybercore_exercise_test.dart.
- `tool/warp_ui_exercise.dart`.
- `docs/reports/host-exercise/` — architecture-decision.md,
  finding-catalog-compact-overflow.md, this report,
  traces/catalog_fuzz_s18473_vertical.json (seeded proof artifact).

Modified (3, minimal):
- `apps/catalog/pubspec.yaml` — +dev-dep warp_prism_host_exercise.
- `apps/observatory/pubspec.yaml` — +dev-dep warp_prism_host_exercise.
- `apps/cybercore/pubspec.yaml` — +dev-dep warp_prism_host_exercise.

Zero edits: warp_prism_ui/testkit/interaction/runtime sources,
apps/*/lib/**, AGENTS.md, MISSION.md, parent skills, task lanes, goldens,
CHANGELOG (parent-owned), tasklist (parent-owned).

Debug probes (5 files) archived under `tmp/host-exercise-debug-probes/`
(reversible scratch, not durable artifacts).

## 4. Commands (all exit 0 unless noted)

```bash
# Harness package
cd packages/warp_prism_host_exercise && flutter analyze --no-fatal-infos --no-fatal-warnings   # No issues
cd packages/warp_prism_host_exercise && flutter test --no-pub                                    # 10/10

# Hosts (per-host exercise suites)
cd apps/catalog     && flutter test test/host_exercise/ --no-pub                                # 5/5
cd apps/observatory && flutter test test/host_exercise/ --no-pub                                # 5/5
cd apps/cybercore   && flutter test test/host_exercise/ --no-pub                                # 4/4

# Host regression (existing suites still green)
cd apps/catalog     && flutter test test/ --no-pub                                              # 19/19
cd apps/cybercore   && flutter test test/ --no-pub                                              # 20/20
cd apps/observatory && flutter test test/ --no-pub                                              # 816/816

# Format gate (melos-compatible)
cd packages/warp_prism_host_exercise && dart format --set-exit-if-changed lib test              # 0 changed
(cd apps/*/test/host_exercise/ dirs) dart format --set-exit-if-changed                          # 0 changed

# Replay CLI
dart run tool/warp_ui_exercise.dart --host catalog --seed 18473 \
  --replay docs/reports/host-exercise/traces/catalog_fuzz_s18473_vertical.json                  # validates + prints replay cmd
```

## 5. Host support matrix

| Host | SMOKE | CRAWL | FUZZ | REPLAY | Viewports | Theme recipes | Reset mechanism |
|---|---|---|---|---|---|---|---|
| Catalog | ✅ gallery⇄connected-lab | ✅ | ✅ seed 18473 | ✅ exact sequence + **disk artifact via env-var** | 1280×800, 1920×1080, 390×844 | ✅ A→B→C→D→A live switch | fresh pump + registry reset + UniqueKey |
| Observatory | ✅ 5 shell branches | ✅ | ✅ seed 90210 | ✅ | +800×600, 390×844 | n/a (Khalai-only by product contract, Task 1833) | fresh pump + go('/overview') + UniqueKey |
| CyberCore | ✅ 4 pilot branches | ✅ | ✅ seed 71717 | ✅ | +390×844 | n/a (teal scoped opt-in at construction) | fresh createAppRouter() + UniqueKey |

Host adapters supply only host-specific deltas (~100 lines each); the
crawler is implemented once.

## 6. Deterministic crawl evidence

`catalog_fuzz_s18473_vertical.json` (durable artifact, canonical traces
dir): 8 recorded steps with per-step `route_before/route_after/state_marker`,
including a theme-editor open → preset apply → hex-copy interaction chain.
Second-run crawl reproduces identical target ordering (asserted in suite).

## 7. Seeded fuzz evidence + replay

FUZZ seed 18473 (Catalog), 90210 (Observatory), 71717 (CyberCore): each
run records seed + ordered actions; suite replays the exact recorded
sequence from a fresh reset and asserts identical target lists.

**Artifact replay from disk (executed, not decorative)**: the CLI emits

```text
WARP_UI_EXERCISE_TRACE=docs/reports/host-exercise/traces/catalog_fuzz_s18473_vertical.json \
  cd apps/catalog && flutter test test/host_exercise/catalog_exercise_test.dart \
  --plain-name "replay: recorded trace artifact replays from disk"
```

and that exact command was executed and PASSED (loads the JSON artifact,
replays all 8 recorded steps error-free, asserts identical target list).
Without the env var the replay test is a silent shell (skippable), so the
suite stays green in default runs.

`tool/warp_ui_exercise.dart --replay <trace>` also emits a seeded
regeneration command (`--plain-name "FUZZ seed=<n>"`) for
reproducing the walk from the seed alone.

## 8. Known-bad calibration (oracle must fail)

Five calibration controls in `test/known_bad_control_test.dart`:

| Control | Defect class | Oracle result |
|---|---|---|
| Raw `TextField` without Material | Task 1831 | ❌ FAILS (missing-ancestor classifier hit) |
| Fixed-height Column overflow | Task 1832 | ❌ FAILS (overflow classifier hit) |
| `build()` throw | interaction throw | ❌ FAILS (async error captured) |
| Healthy control | — | ✅ stays silent |
| Discovery determinism | — | ✅ identical ordering across calls |

Plus one **live defect caught in the product** (not synthetic):
`compact390x844` Catalog smoke detects the gallery-header horizontal
overflow (`RenderFlex overflowed by 90/285px`) — pinned to
`design_system_gallery_page.dart:136` via render-tree dump, documented in
finding-catalog-compact-overflow.md, left as a red calibration control
(flips when the product fix lands). A crawler that cannot fail on a
known-bad control is not an evidence gate — this one fails on four
synthetic classes and one live defect.

**Anti-pattern closed**: capture-unavailable → BLOCKED/FAIL semantics are
inherited from the Task 1834 pattern (oracle never converts a missing
capability into PASS; `MissingPluginException`-style swallowing is
structurally impossible in the oracle — every collected error routes to
`failIfMaterial` or `trace.errors`).

## 9. Failure artifact example

`docs/reports/host-exercise/traces/catalog_fuzz_s18473_vertical.json` —
seed, host, mode, initial_route, viewport (name+size+DPR), theme_recipe,
action_budget, ordered actions with per-step route transitions and state
markers, errors array, replay command.

## 10. Measured runtime cost

| Suite | Wall time | Tests |
|---|---|---|
| Harness package (core + calibration) | 12.7s | 10 |
| Catalog exercise (smoke+crawl+fuzz/replay+theme) | 18.5s | 5 |
| Observatory exercise (+viewport matrix) | 19.0s | 5 |
| CyberCore exercise (+viewport) | 10.1s | 4 |
| **FAST gate (host smoke only)** | **~4-6s per host** | 1-2 |

## 11. Proposed gate cadence (for Karax / code-quality — NOT self-promoted)

```text
FAST affected-host smoke  → before shared UI/integration promotion to review
                            (~5s per affected host; oracle is strict)
FULL deterministic crawl  → wave closeout / pre-checkpoint (~20s per host)
SEEDED FUZZ (+ calibration) → checkpoint / milestone boundary; after
                              high-blast-radius shell/theme/nav changes
                              (~20s per host)
```

Machine-readable exit: non-zero test exit on any material error; trace
JSON `errors[]` for post-processing. The harness does NOT make itself
mandatory — independent review must prove it deserves promotion (§13).

## 12. Integration proposal (returned, not applied)

1. **Karax remediation gate**: add `flutter test test/host_exercise/` of
   each affected host to the affected-host FAST checks for Tasks 1831-1834
   family (adds ~5s, catches the exact oracle-gap class that hid 1831/1832).
2. **code-quality reviewer workflow**: reviewer lane may invoke the suites
   plus `tool/warp_ui_exercise.dart --replay` to verify reproducibility of
   any filed defect trace.
3. **Melos** (optional, parent-owned): a `test-host-exercise` script entry
   would mirror existing per-host scripts; deliberately not self-added
   (root pubspec is a collision surface — §4 ADR).

## 13. Limitations / blind spots (honest)

1. **Below-fold discovery**: only hit-testable candidates; scrolled content
   reachable only via explicit smoke targets. Scrolling exploration is a
   v2 candidate.
2. **Taps only**: no text entry, drag, hover, or keyboard focus traversal
   (focus-activate kind recorded but tap-executed in v1).
3. **Headless flutter_tester**: no real platform channels, fonts-as-bundled,
   no real compositor — golden-grade pixel fidelity is NOT the claim;
   composition-protocol errors are. Consequently **no screenshot-on-failure
   in v1**: the harness records structured error/stack/trace artifacts;
   screenshot capture would require the `integration_test` runner variant
   (deferred — the Task 1834-honest RepaintBoundary path exists to reuse
   when that variant lands).
4. **Observatory router singleton**: adapter resets to `/overview` instead
   of a fresh router (app owns a global `appRouter`); cross-run navigation
   state is reset but the router object persists — acceptable for v1.
5. **Theme matrix limited to Catalog** (only host with runtime recipe
   switching; Observatory/CyberCore are recipe-fixed by product contract).
6. **Known-defect calibration stays red** until the product fix lands; it
   must be removed/flip at that point (documented in-test).
7. **No melos script / CI wiring yet** — deliberate: parent-owned surfaces.
8. **Replay shell-test skips silently** without `WARP_UI_EXERCISE_TRACE`
   (visible only via env-var invocation) — acceptable trade vs. a
   hard-fail on a missing optional artifact.

## 14. Review request

Independent review should test especially:
- Does it detect known-bad controls? (§8 — four synthetic + one live)
- Can failures replay? (§7 — seed + ordered trace + CLI)
- Can it false-PASS? (oracle collects FlutterError + ErrorWidget scan +
  takeException; no swallow path)
- Can it cause destructive side effects? (§5 policy: destructive patterns
  blocklisted; Observatory scanner excluded; taps only)
- Does it materially add evidence beyond package tests? (live compact-width
  overflow that 156 package files + 811 Observatory tests all missed)
- Is runtime cost appropriate? (§10 — 5s FAST / 20s FULL per host)
