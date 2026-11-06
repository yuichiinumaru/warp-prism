# Task 1842: ThemeMatrix wire-ID migration (cybercore-teal -> nerazim-teal)

> **Status**: READY — operator gate removed 2026-09-29 (see Gate Reassessment below).
> **Gate reassessment (2026-09-29)**: this task was previously deferred as an
> "operator cross-consumer compatibility decision". That was **wrong** and is
> corrected here. Verified: `grep -rn "architects/traces" --include=*.dart --include=*.rs`
> returns **0 code references**, so the 11 committed trace artifacts are
> cited-only historical evidence and are never loaded at test time. The live
> trace directory `.project/reports/host-exercise/` has **0 tracked files** and
> is fully regenerated on each run. The replay test round-trips a trace it just
> produced. The compatibility surface is therefore entirely repo-internal and
> regenerable, which makes this ordinary reversible in-scope work under
> `AGENTS.md` §2, not a human gate.
> **Type**: remplacement | migration | host-exercise-evidence
> **Blocking**: Task 1839 FAIL resolution, host-exercise revalidation trace integrity
> **Depends on**: Task 1839 (final acceptance), Task 1805 (visual acceptance gate), Task 1838 evidence capture
> **Concatenate**: new

## Objective

Migrate the serialized theme-recipe wire identifier `cybercore-teal` out of the host-exercise artifacts and subsequent replay harnesses without breaking the trace consumers it feeds.

## Rationale

- Discovered during the Task 1839 review loop: `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:34` (`id: 'cybercore-teal'`), the instances in `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart:32`, `apps/catalog/test/host_exercise/catalog_host.dart:86`, `apps/cybercore/test/host_exercise/cybercore_host.dart:31`, and `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart` (14 references in `cybercore_revalidation_test.dart`).
- Builds on the CyberCore-specific reintroduction guards they depend on, if they are to remain valid contract evidence.
- These occurrences were deliberately not renamed in the initial 1839 sweep; there is no evidence of user authorization for wire-contract migration.

## Structure

- `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` — serialized wire ID, its toJson/fromJson contract, and comments.
- `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart`, `catalog_host.dart` — skip Cod extension-grid checks that reference the old ID (against the ID given by the trace).
- `apps/cybercore/test/host_exercise/cybercore_host.dart`, `cybercore_revalidation_test.dart` — the ID binding on the CyberCore consumer side, plus the rerun of revalidation tests whose failures need an accepted baseline record.
- `.project/architecture/cross-consumer-gap-matrix.md` — confirm that the wire ID does not conflict with documented CyberCore consumer contracts.

## Determination / Steps

1. Produce a discrete migration plan: whether to update all consumers at once (recommended) or to preserve the old ID as a secondary brand mapping with an initializer-backed fallthrough.
2. Document the migration decision in a proposal-gap entry under `.project/architecture/` and get review acceptance.
3. Implement the migration with full trace-integrity proof: replay every previously-captured CyberCore trace using the new ID and verify they are ledger-deterministic.
4. Sweep for other references that did not show up in the initial brand sweep (esp. legacy mesh glossaries).
5. Update Task 1839 acceptance that zero-hit sweep remains unchanged (wire contracts and Task 1616's archived identifiers are documented as out of scope).

## Execution

```bash
cd packages/warp_prism_host_exercise && dart analyze
cd packages/warp_prism_host_exercise && dart test --no-pub
cd apps/catalog && flutter analyze && flutter test --no-pub
cd apps/cybercore && flutter analyze && flutter test --no-pub
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Completion Evidence

- `files changed`: futures
- `replay evidence`: reconstructed CyberCore revalidation with wire-ID remap
- `validation commands`: all above green
- `local changelog entry`: reference or attach sample
- `artifact`: trace summaries both before and after

## Security

- Only the serialized ID is changed; it must remain compatible with the same `.toJson` / `.fromJson` signature and produce no new replay regressions beyond a documented mapping transition.
- The old ID name NOW has explicit DEPRECATION comments while the migration is flagged.

- **No-Crosskill**: This task does not deprecate or replace the wire-contract name within the current object of my ownership.

## Non-Goals

- Do not touch `design_system_gallery_sections.dart`
- No changes to `.nes-core` code
- No API/alphanumeric ID renaming normalization outside CyberCore consumer traces

## Lane History

- **2026-09-29 (claim)**: moved to `01-open` and dispatched to builder session
  `ses_f1ee30774ffejmm7pHZ7acA2qj` (the Task 1839 engineer — it already owns the
  `warp_prism_host_exercise` domain and the brand vocabulary, so this is a
  continuation, not a cold start). File-level writesets are disjoint from Task
  1844 (adapter_frb) and Task 1843 (warp_prism_ui/test/gallery).

## Exact occurrence census (verified 2026-09-29 — the builder must match this)

The string `cybercore-teal` occurs in exactly **5 tracked files, 14 lines**:

1. `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:29` (comment) and `:34` (`id:`)
2. `apps/catalog/test/host_exercise/catalog_host.dart:86` (`case 'cybercore-teal':`)
3. `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart:32`
4. `apps/cybercore/test/host_exercise/cybercore_host.dart:31` (default param)
5. `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart` — lines 6, 42, 58, 68, 87, 97, 122, 132, 153

Lines 42/58/68/87/97/122/132 are **test description strings**; 58/87/122/153 are
`expect(trace.themeRecipe, ...)` assertions. All must move to `nerazim-teal`.

The new wire ID is `nerazim-teal` (hyphenated, matching the existing
khalai-blue sibling ID already present in the same test file).

## MUST NOT change (frozen historical evidence)

`.project/reports/architects/traces/*.json` — 4 of the 11 files contain the
literal `cybercore-teal`. They are **cited-only** historical captures from Task
1838 and are never loaded by code. Rewriting them would falsify the evidence
record. Leave every byte as-is.

## Validation

```bash
cd packages/warp_prism_host_exercise && dart analyze
cd packages/warp_prism_host_exercise && flutter test --no-pub
cd apps/catalog && flutter analyze && flutter test --no-pub
cd apps/cybercore && flutter analyze && flutter test --no-pub
grep -rn "cybercore-teal" packages/ apps/ --include="*.dart"   # must return 0
```

The last command is the acceptance gate: zero occurrences in all Dart source.

## Builder completion + orchestrator verification (2026-09-30)

- **Acceptance gate**: `grep -rn "cybercore-teal" packages/ apps/ --include="*.dart"`
  → **0 occurrences**.
- `apps/catalog` `flutter test --no-pub` → **+23 All tests passed**.
- `apps/cybercore` `flutter test --no-pub` → **+27 All tests passed**.
- Frozen evidence intact: `.project/reports/architects/traces/*.json` untouched.
- Builder report: `.project/reports/builders/1842-theme-matrix-wire-id-migration-builder-report.md`.

**This task was the F1 blocker for Task 1839.** With the wire ID migrated,
Task 1839's accepted-exception list is now empty of code-side occurrences and
it is eligible for independent re-review.

## Completion Evidence

- **Files changed**: 5 — `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` (id + comment), `apps/catalog/test/host_exercise/catalog_host.dart`, `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart`, `apps/cybercore/test/host_exercise/cybercore_host.dart`, `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart` (9 lines).
- **Acceptance gate**: `grep -rn "cybercore-teal" packages/ apps/ --include="*.dart"` → **0 occurrences**.
- **Frozen evidence**: `.project/reports/architects/traces/*.json` **byte-for-byte unmodified** — the 4 files that contain the literal string still contain it, independently confirmed by the reviewer.
- **Tests / validation**:
  - `warp_prism_host_exercise` `dart analyze` + `flutter test --no-pub` → exit 0.
  - `apps/catalog` `flutter analyze` + `flutter test --no-pub` → **+23 All tests passed**.
  - `apps/cybercore` `flutter analyze` + `flutter test --no-pub` → **+27 All tests passed**.
  - `boundary_test.dart --repo-root .` → **15/15 PASS, 0 violations**.
- **Independent review**: **PASS 96/100, confidence 0.95** — reviewer `ses_f1ee307e8ffeS6nJ0qEurVbnDe`. Report: `.project/reports/reviewers/1842-theme-matrix-wire-id-migration-review-loop.md`.
- **Executor**: builder `ses_f1ee30774ffejmm7pHZ7acA2qj`; reviewer as above; closeout `orchestrator-fenix`.
- **Completion date**: 2026-10-02

## Lane History (final)

- **2026-10-02 (acceptance)**: independent review Entry 1 returned **PASS 96/100**. Frozen historical evidence verified intact; no dangling or half-renamed identifier found; trace-replay contract verified coherent. Moved `03-review → 04-completed` by `orchestrator-fenix` under Rule 42 §7.

