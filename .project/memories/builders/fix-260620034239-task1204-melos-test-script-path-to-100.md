---
type: fix
title: "task1204-melos-test-script-path-to-100"
agent: builders
created: 2026-06-20T03:42:39
date: 2026-06-20
---

# task1204-melos-test-script-path-to-100

Applied path-to-100 fixes for Task 1204 (Melos Test Script Normalization) after 2026-06-17 independent review rejection (80/100).

Fixes:
1. Boundary harness: Added explicit allowance for intentional export of ds_operational_state.dart (DSOperationalStateUI extension) in _checkPublicBarrelHidesDsNames(). The export on warp_prism_ui.dart:27 is documented and required for consumers to access PrismOperationalState.running.color etc.

2. Cache convention guard: Added .gitignore patterns preventing generated caches under workspace member globs (apps/**/tmp/, apps/**/pub-cache/, packages/**/tmp/, packages/**/pub-cache/). Added melos config comment documenting convention: caches MUST use root-level tmp/.

Verification (2026-06-20 fresh):
- dart run melos run test-cybercore -> SUCCESS (12 tests pass)
- dart run melos run test-boundaries -> SUCCESS (6/6 checks pass)
- dart run melos run test-catalog -> SUCCESS (14 tests pass)
- dart run melos run test-fast -> BLOCKED by pre-existing test-ui golden failures (NOT Task 1204 scope)
- dart run melos run test-ui -> BLOCKED by 11 pre-existing golden test failures (NOT Task 1204 scope)

Files changed: pubspec.yaml, packages/warp_prism_ui/test/boundaries/boundary_test.dart, .gitignore, docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md, docs/changelog/20260620-150000-1204-melos-test-script-path-to-100-builders.md
Task file updated with 2026-06-20 review ledger entry.
Agent-wiki continuity entry created.
