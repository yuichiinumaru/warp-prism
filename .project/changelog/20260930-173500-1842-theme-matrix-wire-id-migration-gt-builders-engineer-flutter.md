---
date: 20260930-173500
timestamp: 20260930-173500
project: warp-prism
agent: gt-builders-engineer-flutter
task: "1842"
description: "ThemeMatrix wire-ID migration: cybercore-teal -> nerazim-teal across 5 Dart files / 14 sites, with frozen Task 1838 trace evidence preserved"
is_rebuild_safe: true
---

# Task 1842: ThemeMatrix wire-ID migration (cybercore-teal -> nerazim-teal)

## Summary

Completed the serialized theme-recipe wire-ID migration that Task 1839
deliberately deferred. The Dart const had already been renamed to `nerazimTeal`
in Task 1839; this task moves the **serialized `id` string** and all of its
consumers in one atomic change. String-only change: **no behavior, no visual,
and no contract-signature change.** `ExerciseThemeRecipe.toJson` / `fromJson`
are untouched and keep the same `{id, label}` shape.

Full census match: the task's binding census (**5 tracked files, 14 lines**) was
verified against disk before editing and matched exactly.

## Changes

| File | Lines | Change |
| --- | --- | --- |
| `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` | 28–37 | `id:` → `'nerazim-teal'`; obsolete Task 1839 "id preserved" note replaced with a migration record |
| `apps/catalog/test/host_exercise/catalog_host.dart` | 86 | `case 'nerazim-teal':` |
| `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart` | 32 | recipe ladder entry |
| `apps/cybercore/test/host_exercise/cybercore_host.dart` | 31 | `themeRecipeId` default param |
| `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart` | 6, 42, 58, 68, 87, 97, 122, 132, 153 | 1 comment + 4 test descriptions + 4 `expect(trace.themeRecipe, …)` assertions |

Used the hyphenated `nerazim-teal`, matching the `khalai-blue` sibling ID in the
same files.

### Deprecated-alias decision

The task's Security section suggested leaving DEPRECATION comments on the old ID.
Not applicable to this execution: step 1 chose the **update-all-consumers-at-once**
option, so no old-ID consumer survives to deprecate. A deprecated alias would have
been a second canonical home for the wire ID. An accurate migration record (old
value's origin, deferral in 1839, completion in 1842, frozen-evidence carve-out)
was written instead.

## Verification

| Command | Exit | Result |
| --- | --- | --- |
| `grep -rn "cybercore-teal" packages/ apps/ --include=*.dart` | 1 (no output) | **PASS — 0 occurrences** |
| `packages/warp_prism_host_exercise` `dart analyze` | **0** | **PASS — "No issues found!"** |
| `packages/warp_prism_host_exercise` `flutter test --no-pub` | **0** | **PASS 10/10** |
| `apps/catalog` `flutter analyze` | **0** | **PASS — "No issues found!"** |
| `apps/catalog` `flutter test --no-pub` | **0** | **PASS 23/23** |
| `apps/cybercore` `flutter analyze` | **0** | **PASS — "No issues found!"** |
| `apps/cybercore` `flutter test --no-pub` | **0** | **PASS 27/27** |

### Trace-integrity proof

The live regenerated traces now record the new ID, proving the rename propagates
end-to-end through config → runner → trace → assertion (not just a string edit):

```text
live .project/reports/host-exercise/traces/   →  4 × "nerazim-teal", 4 × "khalai-blue"
frozen .project/reports/architects/traces/    →  4 × "cybercore-teal", 7 × "khalai-blue"  (untouched)
```

`expect(trace.themeRecipe, 'nerazim-teal')` passes in all four revalidation
tests, so the runner genuinely recorded the new value.

### Frozen evidence preserved

The 4 `.project/reports/architects/traces/*.json` captures still embed the old
literal and were **not** touched (mtimes remain `2026-09-08`). Independently
re-verified the task's premise: `grep -rn "architects/traces" --include=*.dart
--include=*.rs` returns **0 code references**, so they are cited-only and never
loaded. The live trace writer targets
`.project/reports/host-exercise/traces/`, a different directory.

## Note for the parent

The 4 CyberCore + 4 Catalog `PathNotFoundException` host-harness failures
reported as pre-existing in the Task 1839 backlog had **self-resolved** by the
time this task started — they were environment-state failures (missing trace
artifacts), not code defects. All three targets now have a fully green baseline
and pass with the migration applied. That backlog item can be closed.

Separately, `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart`
lines 5–8 still carry the stale prose "CyberCore / Teal" **split across two
lines**, which evades the literal grep. It is outside the binding 14-line census
and was left untouched; it is reported for a scoping decision.
