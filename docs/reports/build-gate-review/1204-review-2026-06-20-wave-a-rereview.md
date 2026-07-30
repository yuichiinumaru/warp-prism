# Build-Gate Re-Review: Task 1204 — Melos Test Script Normalization — Wave A

**Date**: 2026-06-20
**Reviewer**: gt-devops-runtime-reviewer via `gt-build-review`
**Task file**: `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md`
**Previous report**: `docs/reports/build-gate-review/1204-review-2026-06-20-wave-a.md`
**Skills loaded**: `code-quality-harness`, `flutter-harness`

## Score: 84/100 — Good, rejected

The prior high findings are only partially resolved. The public `DSOperationalStateUI` export is gone and `test-fast` now exits 0, but the public Prism API no longer exposes the operational-state UI getters the builder claims consumers can use (`PrismOperationalState.running.color`, `.label`, `.icon`). Golden tests were annotated with `@Tags(['golden'])`, but the annotations are ineffective because `flutter test --exclude-tags golden` still runs the golden tests and fails. A newly added contamination probe exists and passes, but it is not `dart format --set-exit-if-changed` clean.

## Diagnostics

| Command | Result | Evidence |
| --- | --- | --- |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run test-boundaries` | PASS | Boundary harness reports `Checks: 6/6 PASS` and `0 FAIL, 0 violation(s)`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run test-contamination` | PASS | `Contamination probe: PASS (no nested workspace pubspecs in cache dirs)`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run test-cybercore` | PASS | CyberCore scoped tests pass: `00:00 +12: All tests passed!`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run test-catalog` | PASS | Catalog scoped tests pass: `00:15 +14: All tests passed!`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run test-fast` | PASS | UI fast subset passes `+802`; CyberCore then passes `+12`. This script avoids `test/goldens/` by explicit path selection. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart packages/warp_prism_ui/test/boundaries/contamination_probe.dart packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | PASS | `No issues found!`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart format --output=none --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart packages/warp_prism_ui/test/boundaries/contamination_probe.dart packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | FAIL | Reports `Changed packages/warp_prism_ui/test/boundaries/contamination_probe.dart`; the new probe is not format-clean. |
| Public API probe importing only `package:warp_prism_ui/warp_prism_ui.dart` and using `PrismOperationalState.running.color`, `.label`, `.icon` | FAIL | `dart analyze tmp/review_1204_public_api_probe.dart` reports undefined getters `color`, `label`, and `icon` on `DSOperationalState`. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos exec --scope warp_prism_ui -- flutter test --exclude-tags golden` | FAIL | Golden tests still run despite tags; failures begin in `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` with 11 golden mismatches. |
| `env PUB_CACHE="$PWD/tmp/pub-cache" HOME="$PWD/tmp/home" XDG_CACHE_HOME="$PWD/tmp/cache" TMPDIR="$PWD/tmp" dart run melos run analyze` | FAIL | Repository analyzer remains red with pre-existing debt; output includes `warp_prism_ui` and `warp_prism_observatory` failures. Not scored as a Task 1204 blocker beyond task-touched file format/analyze evidence. |
| Coverage | NOT RUN | Not useful while task-touched formatting and public API contract are red. |

## Prior Finding Classification

| Prior finding | Classification | Current evidence |
| --- | --- | --- |
| Public DS leak through public barrel | PARTIALLY RESOLVED / REGRESSION | `packages/warp_prism_ui/lib/warp_prism_ui.dart:21` now exports only `src/prism_aliases.dart`, and no DS sub-barrel export exists. However, removing the extension export broke the claimed public API getters on `PrismOperationalState`, so the functional requirement remains unmet. |
| Boundary harness whitelist for `ds_operational_state.dart` | RESOLVED | `_checkPublicBarrelHidesDsNames()` now forbids DS sub-barrel exports without the earlier whitelist: `packages/warp_prism_ui/test/boundaries/boundary_test.dart:274-315`. |
| `test-fast` exits non-zero due golden tests | RESOLVED | `pubspec.yaml:60-62` now runs an explicit non-golden UI path subset plus `test-cybercore`, and the script exits 0. |
| Cache guard was documentation-only | RESOLVED | `packages/warp_prism_ui/test/boundaries/contamination_probe.dart:11-40` exists and `pubspec.yaml:56-58` wires `test-contamination`; the script passes. |
| Evidence staleness | PERSISTENT | Task completion evidence still says boundary harness allowed the intentional `ds_operational_state.dart` export and `test-fast` is blocked (`docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:134-140`), contradicting current code and verification. |

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Widget Lifecycle | N/A | Task-touched files are Melos config and pure-Dart boundary/probe scripts. No controllers, subscriptions, or widget lifecycle objects were introduced in `packages/warp_prism_ui/test/boundaries/boundary_test.dart:1-422` or `contamination_probe.dart:1-168`. |
| 2 | Provider Scoping | N/A | No Riverpod provider code changed in the task-touched files. |
| 3 | Const Constructors | N/A | No new Flutter widgets introduced by the task-touched code. |
| 4 | Semantic Labels | N/A | No new interactive UI widgets introduced by the task-touched code. |
| 5 | Type Safety | PASS | Targeted analyzer passes for `boundary_test.dart`, `contamination_probe.dart`, public barrel, alias file, and operational-state token file. |

## Warp Prism Checks

| Check | Status | Evidence |
| --- | --- | --- |
| Read-only contract | PASS | Changes are scripts, boundary inspection, and docs/task evidence; no live mutation endpoint or API dependency added. |
| DS*/Prism* boundary | FAIL | Public DS sub-barrel export is removed, but public Prism functionality regressed. `packages/warp_prism_ui/lib/warp_prism_ui.dart:23-26` claims the `DSOperationalStateUI` extension is accessible via `PrismOperationalState`, yet a consumer importing only `warp_prism_ui.dart` cannot access `.color`, `.label`, or `.icon`. |
| Mock workspace fixtures | N/A | No fixture data path changed. |
| Melos package boundary | PASS | Required scripts are in root `pubspec.yaml:48-66`; `test-boundaries`, `test-contamination`, `test-cybercore`, `test-catalog`, and `test-fast` run through repository-local `dart run melos ...` entrypoints. |
| Operational state vocabulary | FAIL | The canonical 15-state enum remains present at `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart:18-78`, but the public Prism API no longer exposes UI metadata getters to consumers through the public barrel. |
| Design token usage | N/A | No token values or component rendering code changed for this task. |
| Gallery coverage | N/A | No new DS component added. |
| Test coverage | PARTIAL | `test-fast` is green and includes boundary/tokens/atoms/molecules/organisms/accessibility/templates/gallery selected roots plus CyberCore. It does not rely on the ineffective golden tags. There is no public API regression test for `PrismOperationalState.running.color` through the public barrel. |

## Exit Conditions

| # | Condition | Met? | Evidence |
| --- | --- | --- | --- |
| 1 | Root `pubspec.yaml` contains `test-cybercore`, `test-boundaries`, and `test-fast` scripts. | YES | `pubspec.yaml:48-62`. |
| 2 | `dart run melos run test-cybercore` runs tests in `apps/cybercore/` only. | YES | Script scope is `warp_prism_cybercore` at `pubspec.yaml:48-50`; command passes 12 tests. |
| 3 | `dart run melos run test-boundaries` runs Task 1205 boundary test harness. | YES | `pubspec.yaml:52-54` runs `packages/warp_prism_ui/test/boundaries/boundary_test.dart`; command passes 6/6. |
| 4 | `dart run melos run test-fast` runs the fast subset of tests. | YES WITH CAUTION | Command exits 0 and runs UI non-golden subset plus CyberCore. This is acceptable as a fast subset, not as full UI coverage. |
| 5 | Existing scripts preserve semantics and are normalized for repository-local Melos invocation. | YES | `analyze`, `format`, `test`, scoped package tests, and `validate` use `dart run melos ...` at `pubspec.yaml:24-66`. |
| 6 | Local changelog entry added under `docs/changelog/`. | YES | Existing entries include `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md` and `docs/changelog/20260620-150000-1204-melos-test-script-path-to-100-builders.md`. |
| 7 | Completion Evidence is filled before review handoff. | NO | Completion evidence is stale and contradictory: it still says boundary harness allowed an intentional DS export and says `test-fast` is blocked at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:134-140`. |

## Findings

### Critical

None.

### High

- [HIGH] Public Prism API operational-state UI functionality is broken after removing the `DSOperationalStateUI` public export. `packages/warp_prism_ui/lib/warp_prism_ui.dart:23-26` claims the extension remains accessible via `PrismOperationalState`, and `packages/warp_prism_ui/lib/src/prism_aliases.dart:96-97` repeats that claim, but a consumer importing only `package:warp_prism_ui/warp_prism_ui.dart` cannot access `PrismOperationalState.running.color`, `.label`, or `.icon` (`dart analyze tmp/review_1204_public_api_probe.dart` reports undefined getters). This fails the Wave A path-to-100 requirement to preserve operational-state UI functionality through a policy-backed Prism public API.

### Medium

- [MEDIUM] Golden tests are not actually excluded by the new `@Tags(['golden'])` annotations. The annotations are placed before helper declarations such as `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart:13-15`, and `flutter test --exclude-tags golden` still runs the golden tests and fails. `test-fast` is green only because it explicitly enumerates non-golden paths; the tag-based claim is unproven/false.
- [MEDIUM] Task-touched format gate is red for the new contamination probe. `dart format --output=none --set-exit-if-changed ... contamination_probe.dart` reports that `packages/warp_prism_ui/test/boundaries/contamination_probe.dart` would change.
- [MEDIUM] Completion evidence and changelog are stale after the latest builder fix. The task still records `test-fast` as blocked and describes a now-removed DS export allowance at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:134-140` and `:184-200`, while current `pubspec.yaml:60-62` and `warp_prism_ui.dart:21-31` say otherwise.

### Low

- [LOW] `test-fast` is acceptable as a fast subset, but it is not a general “all non-golden tests” command: it excludes at least root `packages/warp_prism_ui/test/accessibility_focus_contrast_test.dart` and `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart`. Do not present it as full non-golden UI coverage.

## Patches Applied

None. Score is below 90; reviewer patching is prohibited by `.agents/workflows/gt-build-review.md:91-100` and RFLoop score routing.

## Verdict

REJECTED -> stays in `docs/tasks/02-doing/`.

## Path to 100

1. Restore public operational-state UI functionality without leaking a DS-named public symbol. Add/export a Prism-named public extension or equivalent Prism API so a consumer importing only `package:warp_prism_ui/warp_prism_ui.dart` can compile `PrismOperationalState.running.color`, `.label`, `.icon`, and related operational metadata, then add a regression test/probe for that public import path.
2. Make the golden tag annotations effective or remove the claim. If retaining tags, prove `flutter test --exclude-tags golden` does not execute `test/goldens/**`; otherwise document that `test-fast` is path-based and does not depend on tags.
3. Run `dart format --set-exit-if-changed` on all task-touched Dart files, including `packages/warp_prism_ui/test/boundaries/contamination_probe.dart`, and keep the checked-in file format-clean.
4. Refresh task Completion Evidence and changelog so they match the current implementation: `test-fast` now passes; the DS export whitelist is gone; `test-contamination` exists and passes.
5. Rerun and record: `test-boundaries`, `test-contamination`, `test-cybercore`, `test-catalog`, `test-fast`, public API probe/analyzer, and targeted format/analyzer.
