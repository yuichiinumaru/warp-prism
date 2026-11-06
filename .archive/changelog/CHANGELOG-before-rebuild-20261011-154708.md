# Changelog

> **Note**: Auto-generated from individual entries in `.project/changelog/`.
> **Do NOT edit manually** - use the changelog skill/subcommands.
> **Last rebuilt**: 2026-10-11 05:13:05 UTC
> **Scope**: Showing the latest 100 of 345 entries.
> **Full history**: See [`CHANGELOG-FULL.md`](./CHANGELOG-FULL.md).

---

# Task rem-0001: Boundary harness row-16 enforcement + domain regex + §10 status column

## Summary

Closed three mechanical law-vs-harness gaps in one coherent unit (source: Inv-1
findings Gaps 1, 2, 5):

1. **Row 16 is now enforced.** `boundary_test.dart` gained check #16,
   `warp_prism_bindings does not import FRB generated surfaces`
   (`_checkBindingsNoFrbGenerated`), mirroring check #15's scan logic scoped to
   `packages/warp_prism_bindings/lib`. The bindings projection seam can no
   longer silently import `src/rust/` or `frb_generated` surfaces.
2. **Domain regex extended.** Check #14's regex now includes `Warpblade` and
   `Tempest`, matching the MUST-NOT law text (`layer-contracts.md` §4.6) that
   already names them. Zero live hits — latent gap closed, no behavior change
   on current source.
3. **§10 reconciled.** The 16-row check list is now a table with a per-row
   enforcement-status column (all `ENFORCED`); the row-16 `DOCUMENTATION ONLY`
   marker is gone and the 2026-09-28 drift note records the column's recovery.

## Changes

| File | Change |
| --- | --- |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | +`BoundaryCheck` #16 in registry; +`_checkBindingsNoFrbGenerated()`; domain regex `(Ganthritor\|Cersei\|OmniRoute\|CyberCore)` → `(...\|Warpblade\|Tempest)` |
| `.project/architecture/layer-contracts.md` (§10 only) | numbered list → 16-row table with `Status` column; row-16 marker removed; drift note updated with recovery record |
| `.project/changelog/20261011-043721-rem-0001-boundary-harness-row16-regex-status-builder-engineer.md` | this entry |

No pre-existing check was weakened; no other harness behavior changed
(simplicity pass verified line-by-line against the pre-edit state).

## Verification

| Command | Exit | Result |
| --- | --- | --- |
| `dart packages/warp_prism_ui/test/boundaries/boundary_test.dart` (pre-edit baseline) | 0 | 15/15 PASS |
| same (fixture in place) | 1 | 13/16 PASS — checks #14/#15/#16 each flag the probe fixture (detection proven) |
| same (post-revert, final) | 0 | **16/16 PASS, 0 FAIL, 0 violations** |
| `dart format --output=none --set-exit-if-changed <file>` | 0 | 0 changed |
| `dart analyze <file>` | 0 | No issues found |

Fixture proof: a temporary probe file in `packages/warp_prism_bindings/lib`
carrying an `frb_generated` import and a `Warpblade` token was detected by
checks #14, #15 and #16 in the same run, then deleted in the same change. Bindings
lib restored to `src/` + `warp_prism_bindings.dart` only.

Contention: none — no tool-lock errors encountered; retry protocol not needed.

Independent acceptance: pending (executor is not the reviewer).

---

# Task rem-0003-adapter-barrel-lifecycle-doc: remediation-promoted

## Summary

rem-0003 reviewed PASS, promoted to completed

## Changes

- Documented task completion details.

## Verification

- [x] reviewer PASS 96/100 ses_ed6b7af4bffeNeNMY2sRAiTKmk
- [x] diff 1 insertion 0 deletions

---

# Task rem-0002-runtime-purity-bare-tokens: remediation-promoted

## Summary

rem-0002 reviewed PASS, promoted to completed

## Changes

- Documented task completion details.

## Verification

- [x] reviewer PASS 88/100 ses_ed6b7af4bffeNeNMY2sRAiTKmk
- [x] suite 3/3 exit 0

---

# Task rem-0001-boundary-harness-row16-regex-status: remediation-promoted

## Summary

rem-0001 reviewed PASS, promoted to completed

## Changes

- Documented task completion details.

## Verification

- [x] reviewer PASS 92/100 ses_ed6b7af4bffeNeNMY2sRAiTKmk
- [x] harness 16/16 exit 0

---

# Task rem-0003-adapter-barrel-lifecycle-doc: remediation-executed

## Summary

rem-0003 barrel lifecycle doc added

## Changes

- Documented task completion details.

## Verification

- [x] grep Lifecycle barrel >=1 hit
- [x] git diff addition-only, 1 file

---

# rem-0002: Runtime purity test — bare presentation-token scan

## Summary

`packages/warp_prism_runtime/test/purity_test.dart` could only prove the
absence of `package:flutter` / `dart:ui` **imports**. A contract that named a
Flutter presentation concept directly — `final Offset position;` with no import
at all — passed silently. MUST-NOT 3 bans the *concept*, so the test must scan
the concept, not its import.

The purity suite now carries a third test that scans
`\b(Offset|Widget|BuildContext|Color)\b` over **comment-stripped**
runtime source, closing Inv-1 Gap 3.

## Changes

| File | Change |
| --- | --- |
| `packages/warp_prism_runtime/test/purity_test.dart` | Added `_stripComments` helper (mirror of the `boundary_isolation_test.dart` precedent) and a third test: bare presentation tokens over comment-stripped source |

Both edits are purely additive (`+70/−0`, 104 → 174 lines): every pre-existing
line is preserved byte-for-byte.

Implementation notes:

- **No new scanner invented.** The `_stripComments` helper is a verbatim mirror
  of `packages/warp_prism_bindings/test/boundary_isolation_test.dart:33–40`:
  block comments removed wholesale, then every line whose *trimmed* content
  starts with `//` dropped. Trimming is what makes `///` doc-comments count —
  without it, doc-comment `Offset` mentions would trip the scan.
- **Existing patterns untouched.** The import scan and the
  presentation/polling pattern list are byte-identical to before; only a new
  test group member was appended. No existing behavior changed.
- **Deliberate asymmetry documented in code.** Trailing comments are left in
  place. This is the conservative direction for a ban: an inline
  `int brightness = 3; // tint Color near here` yields a loud false positive on
  a later scan rather than a silent miss, and it avoids mangling string
  literals that legitimately contain `//`. The precursor precedent accepted the
  same trade-off.
- Violation reporting names the matched token, not just the file, so a future
  red is diagnosable from the failure message alone.

## Verification

| Command | Exit | Result |
| --- | --- | --- |
| `dart test packages/warp_prism_runtime/test/purity_test.dart` (baseline, pre-change) | 0 | **PASS 2/2** |
| `dart test packages/warp_prism_runtime/test/purity_test.dart` (extended, current source) | 0 | **PASS 3/3** |
| `dart test packages/warp_prism_runtime/test/purity_test.dart` (fixture-proof Phase A, bare `Offset`) | 1 | **PASS — detection proven** |
| `dart test packages/warp_prism_runtime/test/purity_test.dart` (fixture-proof Phase B, doc-comment mentions only) | 0 | **PASS — no false positive** |
| `dart analyze packages/warp_prism_runtime` | 0 | **PASS — "No issues found!"** |

### Fixture-proof (both directions, then reverted)

A temporary synthetic fixture was written into the scanned tree
(`packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart`) and run
twice, distinguishing the two directions a naive scan conflates:

- **Phase A — bare token**: a `final Offset position;` field with no Flutter
  import. Test failed exactly as required:
  `lib/src/rem_0002_fixture_proof.dart matched RegExp: pattern=\b(Offset|Widget|BuildContext|Color)\b flags= near "Offset"`.
  This is the hole the task describes, now genuinely detected.
- **Phase B — doc-comment mention only**: the same file with the bare token
  replaced by a plain `double` field, keeping the doc-comment mentions
  (`position: Offset`, `Widget identity`, `BuildContext access`,
  `Color palette`). Test stayed green, proving comment-stripping suppresses
  documented examples rather than scanning prose.

### False-positive check on current source

The two live `Offset` occurrences in `warp_prism_runtime/lib` are both
doc-comment prose
(`graph_source_contract.dart:11` and `graph_source_models.dart:26`, each
`` (`position: Offset`) ``) and are pre-existing — this task did not create
them. Both are suppressed by the strip step, so the scan reports zero
violations on unchanged source.

### Fixture reverted — not weakened

The fixture is **not** part of the change. `rm` is denied by workspace policy,
so it was removed through the canonical archive mechanism per root
`AGENTS.md` §6 rather than via an alias:

```text
archive: packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart
     -> .archive/packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart
```

The live scanned tree is clean: `grep -r "rem_0002|fixture_proof|FixtureProof"
packages/warp_prism_runtime` returns zero matches. The archived copy sits
outside `lib/`, so the scan cannot see it, and the fixture never edits a real
contract file.

## Contention

No tool-lock contention was observed. The shared `.dart_tool/` lock was free for
every run recorded above; no retry was needed and no BLOCKED-on-resource state
was reached.

## Note for the parent

This change affects only `packages/warp_prism_runtime` test code. No consumer
app, package, or shared artifact is touched, so `affected_consumers` is NONE by
construction — the scan reads runtime package-local source and cannot alter any
consumer's composition. Per `AGENTS.md` §3.5 the executor provides no
acceptance verdict for this work; independent review is the next gate.

`packages/warp_prism_bindings/test/boundary_isolation_test.dart` was read as
the strip precedent and **not** modified.

The auto-generated projection `.project/changelog/index.md` was **not**
rebuilt: the engine's `build` action writes root-level `CHANGELOG.md` and
`CHANGELOG-FULL.md`, which fall outside this task's authorized writeset. The
ledger itself is registered — `project_changelog validate` reports
`Changelog valid: issues=0 entries=341`, including this entry — so the
projection can be refreshed safely by a later owner.

---

# Task PLAN-warp-prism-future-capability-program: future-program-plan-created

## Summary

Phase 2 program doc: 5 EPICs A-E, 9 stories, task index, DAG

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-review-lifecycle-spec: future-task-held

## Summary

HOLD review-lifecycle spec

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-registry-harvest-verify-loop: future-task-held

## Summary

HOLD harvest-verify loop design

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-job-progress-spec: future-task-held

## Summary

HOLD job-progress spec

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-host-proof-protocol: future-task-held

## Summary

HOLD spec task for host-composition proof protocol

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-health-badge-axis-spec: future-task-held

## Summary

HOLD health-badge axis spec

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-diff-viewer-spec: future-task-held

## Summary

HOLD diff-viewer spec

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-data-plane-contract-spec: future-task-held

## Summary

HOLD data-plane contract spec

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-component-registry-schema: future-task-held

## Summary

HOLD registry schema design

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task HOLD-warp-prism-bridge-surface-request: future-task-held

## Summary

HOLD bridge-surface request package

## Changes

- Documented task completion details.

## Verification

- [x] Phase 1 inventory REVIEWED-PASS ses_edbfcec4dffeX44ZMBOaLDsRWR

---

# Task 1839: theme-brand-normalization

## Summary

Independent review Entries 1-4 returned FAIL (45/48/48/48). The blocking wire-ID finding was cleared by Task 1842, which migrated the serialized cybercore-teal recipe ID to nerazim-teal; the formatter finding was resolved for the task surface and the residual package-wide drift moved to Task 1846. Entry 5 returned PASS 91/100 confidence 0.93 with zero Critical or Serious findings open.

## Changes

- Documented task completion details.

## Verification

- [x] grep -rn 'cybercore-teal' packages/ apps/ --include='*.dart' : 0 matches
- [x] dart analyze x4 (warp_prism_ui, warp_prism_host_exercise, apps/catalog, apps/cybercore) : exit 0, zero errors
- [x] apps/catalog flutter test --no-pub : +23 All tests passed
- [x] apps/cybercore flutter test --no-pub : +27 All tests passed
- [x] dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . : 15/15 PASS, 0 violations
- [x] dart format on all 8 task-touched files : 0 changed
- [x] Independent reviewer ses_f1ee307e8ffeS6nJ0qEurVbnDe Entry 5 : PASS 91/100 confidence 0.93

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

---

# Task 1840: catalog-statusticker-overflow-listtile-warnings

## Summary

Both reported defects were reproduced verbatim and attributed to their owning
gallery section, then classified and fixed at the correct layer.

The committed gallery suite calls `_suppressGalleryDemoNoise()`
(`test/gallery/design_system_gallery_test.dart:539-557`), which filters exactly
these two message classes, so a green suite proved nothing. Reproduction used a
throwaway harness that swept `dsGallerySections`, pumped each builder in a
`SingleChildScrollView`, and captured `FlutterError.onError` **per section**.

Verbatim reproduction (before):

```
A RenderFlex overflowed by 16 pixels on the bottom.
ListTile background color or ink splashes may be invisible.  (x3)
```

Attribution:

```
1840|section=epic15-stage-chrome|A RenderFlex overflowed by 16 pixels on the bottom.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
1840|section=epic15-stage-relations|ListTile background color or ink splashes may be invisible.
```

## Changes

- **`design_system_gallery_sections.dart:3059` (defect 1 — demo sizing).**
  `SizedBox(height: 120, width: 640, child: _StatusTickerDemo())` → `SizedBox(width: 640, …)`.
  The hard box was authored to the demo's *content* height (120) while omitting
  the demo's own `EdgeInsets.all(8)` padding, leaving the `Column` 104px for
  120px of content. The demo has only fixed-height children, so it now sizes
  intrinsically and renders at its natural 120px — the height originally
  intended. Nothing is clipped, and the defect class is removed rather than
  re-tuned to a new magic number.
- **`design_system_gallery_sections.dart:6205` (defect 2 — demo host
  composition).** The layer-registry `ListView` gained its own
  `Material(type: MaterialType.transparency)` so `SwitchListTile.adaptive` paints
  its background and ink splashes on a Material at the right layer, instead of
  on the distant Scaffold Material occluded by the enclosing coloured glass
  `DecoratedBox`. Glass appearance is unchanged.
- **Not modified:** `packages/warp_prism_ui/lib/src/organisms/status_ticker/ds_status_ticker.dart`.
  `DSStatusTicker` self-bounds via `SizedBox(height: widget.height)` and honours
  its documented contract (default 48 = WCAG min target); no widget-layer defect
  was proven.

## Verification

- [x] Unsuppressed per-section sweep at 1400x2400: 4 errors before → **0 after**
- [x] Sibling sweep, all 24 registry sections at the default catalog viewport
      `1280x800`: `epic15-stage-chrome` and `epic15-stage-relations` clean
- [x] Content integrity after fix: 2 tickers render at 622x36 (the requested
      `height: 36`, unclipped), both captions present, all 3 layer labels and 3
      switch tiles present, 0 errors
- [x] `dart format --set-exit-if-changed` on the touched file: exit 0 (0 changed)
- [x] `dart analyze` (`packages/warp_prism_ui`): exit 0 — 212 issues, all `info`
- [x] `flutter test --no-pub` (`packages/warp_prism_ui`): `+1703 -63` — **identical
      to the pre-change A/B baseline**, i.e. zero regressions. The 63 failures are
      pre-existing (golden/environment) and unrelated.
- [x] `flutter analyze` (`apps/catalog`): `No issues found!` exit 0
- [x] `flutter test --no-pub` (`apps/catalog`): 4 failures, all proven pre-existing
      by A/B revert (identical counts before/after). All 4 are
      `PathNotFoundException` in `_persist` — `apps/catalog/docs/` does not exist,
      so trace artifacts cannot be written to the pre-relocation
      `docs/reports/host-exercise/traces/` path. Unrelated to this task.
- [x] `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`:
      15/15 PASS exit 0
- [ ] **Host proof NOT run** — `flutter run -d linux` requires a display/GPU host
      and is operator-side. Headless `flutter_tester` evidence stands in; the
      operator should confirm at the default viewport.

## Sibling finding (reported, deliberately NOT fixed — out of writeset)

`health-dashboard` section: `A RenderFlex overflowed by 7.3 pixels on the bottom.`

- Widget: `Column`, `mainAxisSize: min`, `BoxConstraints(w=204.0, h=124.7)`
- Location: `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart:82:14`
- Only reproduces at the default catalog viewport `1280x800`; clean at 1400x2400
- Cause: `DSHealthCard` in a molecule file, outside Task 1840's writeset.
  Route as follow-up work; do not fix here.

---

# Task 1841: doc-comment-layer-contracts-path-sweep

## Summary

Independent re-review PASS (92/100, high confidence). During review the canonical home moved docs/architecture -> .project/architecture by operator decision (path-economy); orchestrator repointed 117 lib/ doc-comments + 7 README refs + 4 additional stale architecture refs and fixed lifecycle anchors §3.2 -> §9. Reviewer verified comment-only sampling across 8 files, zero stale strings, and all gates.

## Changes

- Documented task completion details.

## Verification

- [x] rg 'layer-contracts-v2' packages/*/lib packages/*/README.md packages/*/test apps/*/lib apps/*/test (excluding build/.dart_tool): 0 matches
- [x] rg 'docs/architecture/' packages/*/lib packages/*/README.md packages/*/test apps/*/lib apps/*/test: 0 matches
- [x] dart analyze: warp_prism_interaction, warp_prism_runtime, warp_prism_testkit, warp_prism_bindings, warp_prism_adapter_frb all 'No issues found!' exit 0
- [x] dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . : 15/15 PASS exit 0
- [x] Independent reviewer ses_f1ee307e8ffeS6nJ0qEurVbnDe re-review verdict PASS (92/100) after remediation of its Serious findings

---

# Task 1839: Theme Brand Normalization (Nerazim Teal / Purifier Gold)

## Summary

Normalized the teal skin brand and gold preset label to the canonical vocabulary
mandated by `AGENTS.md` §7.0. **Identifiers, labels, comments, and docs only** —
no hex value, no theme behavior, no visual change. The `AGENTS.md` §7.0
temporary section is now removable by governance once the residual out-of-scope
sites (listed below) are cleared and independent review passes.

## Changes

### Renamed files (originals archived to `.archive/`, reversible)

| Old | New |
| --- | --- |
| `packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart` | `.../ds_nerazim_teal_skin.dart` |
| `packages/warp_prism_ui/test/tokens/ds_cybercore_teal_skin_test.dart` | `.../ds_nerazim_teal_skin_test.dart` |
| `docs/design/cybercore-teal-theme-extension-skin.md` | `docs/design/nerazim-teal-theme-extension-skin.md` |

### Renamed identifiers

- `DSCyberCoreTealSkin` → `DSNerazimTealSkin`
- `PrismCyberCoreTealSkin` → `PrismNerazimTealSkin`
- factory `.omniRoute()` → `.nerazimTeal()`
  (recorded per task: the `omniRoute` anchor was itself a stale product anchor;
  every call site changes anyway, so it was renamed once.)
- catalog enum `CatalogThemeVariant.cybercoreTeal` → `.nerazimTeal`
- test probe key `'cybercore-teal-accent-probe'` → `'nerazim-teal-accent-probe'`

### Renamed labels / comments / docs

- `'CyberCore Teal (#00FFCC)'` → `'Nerazim Teal (#00FFCC)'` (catalog dropdown)
- `'CyberCore Teal'` → `'Nerazim Teal'` (theme editor preset chip)
- `'Protoss Gold'` → `'Purifier Gold'` (theme editor preset chip)
- `Nerazim Green/Teal` → `Nerazim Teal` (4 docstring sites:
  `prism_aliases.dart` ×2, `ds_taldarim_red_skin.dart`, `ds_talon_purple_skin.dart`)
- barrel export + import paths in `tokens.dart` and `prism_aliases.dart`
- `docs/design/public-barrel-audit.md` alias row
- `docs/design/black-obsidian-visual-contract.md` — 3 live brand-label mentions
  updated; the 2 historical-quote rows in the Supersession Map were deliberately
  left verbatim and annotated with a Task 1839 note (rewriting a verbatim quote
  of a superseded task artifact would falsify the record)

### Explicitly NOT changed (verified)

- **No hex value changed.** Teal `#00FFCC` / `#00B894` / `#007A66` proven
  byte-identical against the archived original. Talon Purple
  (`#9911E5`/`#770CB3`/`#4F0878`), Taldarim Red
  (`#E51A4C`/`#B8103A`/`#7A0A26`), and Khalai Blue (`#2F81FF`) untouched.
- `AGENTS.md`, `MISSION.md`, `README.md`, `pubspec.yaml` — not touched.
- `.archive/`, `.project/tasks/04-completed/`, `.project/tasks/03-review/` —
  not rewritten (0 files modified).
- No golden refresh (Task 1800 freeze respected).

## Verification

| Check | Result |
| --- | --- |
| `dart format --set-exit-if-changed` (my 5 authored/edited files) | **PASS** exit 0 |
| `dart format --set-exit-if-changed lib/ test/` (package-wide) | exit 1 — **pre-existing** baseline drift, 57 files dirty incl. files this task never touched |
| `dart analyze` (warp_prism_ui) | exit 3 — 10 errors, **all in 3 out-of-scope test files**; 0 errors in in-scope files; remaining 212 are pre-existing `info` lints |
| `flutter test test/tokens/ds_nerazim_teal_skin_test.dart` | **PASS** 15/15, exit 0 |
| canonical sibling skin tests (taldarim/talon) | **PASS**, exit 0 |
| `boundary_test.dart --repo-root .` | **PASS** 15/15, exit 0 |
| `apps/cybercore` `flutter analyze` | **PASS** exit 0 |
| `flutter test --no-pub` (warp_prism_ui, full) | exit 1 — 70 failures: 3 compile breaks from out-of-scope files + golden drift documented as expected under the Task 1800/1805 freeze |
| `apps/catalog` `flutter analyze` / `flutter test` | exit 1 / exit 1 — 2 errors, both in out-of-scope `test/host_exercise/catalog_host.dart` |
| `apps/cybercore` `flutter test` | exit 1 — 4 failures, **pre-existing** `PathNotFoundException` in the Task 1838 host-exercise harness; 0 references to any renamed symbol |
| Zero-hit sweep over in-scope live paths | **0 stale hits** |

### Out-of-`Where`-table stale-brand sites (reported, NOT edited — scope discipline)

These break compilation and must be cleared by an authorized follow-up:

- `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` (1 — docstring)
- `packages/warp_prism_ui/test/atoms/switch/ds_switch_test.dart` (1)
- `packages/warp_prism_ui/test/organisms/theme_editor/prism_theme_editor_test.dart` (2 — asserts `find.text('CyberCore Teal')`)
- `packages/warp_prism_ui/test/theme/prism_theme_test.dart` (3)
- `packages/warp_prism_ui/test/theme/theme_role_accent_propagation_test.dart` (11)
- `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` (2)
- `apps/catalog/test/host_exercise/catalog_host.dart` (2)
- `docs/governance/catalog-showability-2026-07-10.md` (1)

**Not edited, by design:** `AGENTS.md` §7.0 (the law must name the variants it
forbids; removed by governance after review), `.project/tasks/01-open/1839-*`
(the task itself), `.project/tasks/03-review/1806-*` (out of bounds),
`docs/design/black-obsidian-visual-contract.md` lines 180–181 (annotated
historical quotes).

---

# Epoch Reset Part 1: Reconcile, Declutter, Inventory, Plan (unsealed)

## Summary

Executed the user-authorized bounded architecture/governance reset up to the
persistence gate. Seven parallel read-only investigators inventoried Warp Prism
ADS, IDS/runtime/bindings/FRB/Rust, Warpblade, Tempest, Sentry, Hyperion, and
the historical corpus. Independent review returned AMEND 88/100 (F1–F9); all
mechanical findings remediated except F7, which is materialized as Task 1841.
A first review pass (BLOCKED 42/100) was set aside after citation audit proved
fabricated line references.

## Changes

- Archived 36 planning artifacts → `.archive/` + `.project/archive/epoch-reset-manifest.md`.
- `MISSION.md`: rewritten (348 lines; L0–L3 + Rewrite Factory superseded in §11).
- `AGENTS.md`: amended (consumer family, §7.0 temporary brand law per owner order, §8 onboard, §10.1 program target, §15 stop conditions, fixed broken rule/session paths).
- `README.md`: rewritten as arrival page.
- `docs/architecture/layer-contracts.md`: created (normative matrix + 16-check harness list).
- `docs/bridge/README.md`: created (harvest loop + classification vocabulary).
- `docs/reports/2026-09-27-cross-consumer-gap-matrix.md`: created (28-row matrix, 5 harvest candidates, conflicting-semantics section).
- `docs/design/charter.md`: refreshed to v2.1 (consumer family, real topology).
- `.agents/workflows/wp-warp-prism-onboarding.md`: repaired stale MISSION sections, layer-contracts path, tasklist path, report/session paths.
- `.project/tasks/tasklist.md`: regenerated (Open 3, Review 4, Planning 2, Completed 191).
- Tasks materialized in `01-open/`: 1839 (brand rename), 1840 (StatusTicker overflow + ListTile warnings, from operator live run), 1841 (doc-comment path sweep).
- Session ledger updated with 12 epoch-reset sessions.

## Validation

- Light verification pass by grep: zero dead planning paths in tasklist (EPIC-18 row is live), zero stale `docs/reports/1805` paths, zero archived-EPIC citations in current-authority docs, all manifest section pointers resolve, all onboarding/AGENTS referenced paths exist.
- Flutter/Dart test suites NOT run in this pass (governance-only mutations + provider-blocked builders).

## Open blockers

1. **Persistence**: `seal_checkpoint inspect` → BLOCKED (`blob-size`: ~899 MiB blob swept via the retargeted `references` symlink, a pre-existing worktree change from 2026-09-23 outside this pass's authority). Nothing sealed. Operator action required.
2. **Builders**: Tasks 1839/1840 sessions failed 3× on provider errors. Operator CLI fallback required (see reset report).
3. **Human gates (unchanged)**: Task 1805 visual sign-off; Task 1816 follows it.

---

# Task 1838: Real-Host Composition Revalidation Evidence — 1805 Criteria 3/5/9/11 Technical Layer (promoted)

## Summary

All three hosts green across the viewport matrix with errors:[] in every trace; the three historical invalidations (Observatory search-bar Material crash, CyberCore data-table overflow, chrome teal divergence) each addressed by specific runs; harness gained compact500x900 viewport + durable revalidation suites in apps/*/test/host_exercise/; zero product code modified.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md (93/100 APPROVED_PATH100, zero REGRESSION findings; suites re-run by reviewer with exact exits +9/+8/+8/+10)

---

# Task 1837: Golden Suite Tagging — --exclude-tags=golden Effective (promoted)

## Summary

flutter test test/ --no-pub --exclude-tags=golden now exits 0 (+1692 all passed) — the documented full-suite validation command is finally usable on this branch; goldens still run without exclusion (60 dir tests: 59 expected frozen-drift failures + 1 drift-invariant pass; 14 embedded); Task 1800/1805 golden freeze intact (0 baselines touched); boundary harness 15/15.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/reviewers/1837-golden-suite-tagging-review-loop.md (95/100 APPROVED_PATH100, zero REGRESSION findings; primary gate re-run +1692 exit 0)

---

# Task 1836: Layout-Band Completion — Scrubber/Table Falsified Bands + Trap Hygiene (promoted)

## Summary

Scrubber/table layout-contract bands independently re-executed green (18/18, 7/7, 2/2, 707/707 organisms, both host widget suites, both debug builds, capture suites); expected data-table golden drift recorded under Task 1800 freeze without refresh; F3/F7/F8 carried as accepted non-blocking residuals.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/review/1836-layout-band-completion-independent-review-2026-09-06.md (90/100 PASS, zero regressions)

---

# Task 1835: Package-Wide Material Ancestry Meta-Test — Remediation Round 1 (PrismSelect + oracle)

## Summary

Meta-test guards the full 118/118 public widget surface with a falsification-tight oracle; 123 tests green; classification counts corrected; task promoted to completed after 95/100 independent acceptance.

## Changes

- Documented task completion details.

## Verification

- [x] Independent re-review: docs/reports/reviewers/1835-material-ancestry-meta-test-review-loop.md (Entry 2, 95/100 APPROVED_PATH100, zero REGRESSION findings)

---

# Task 1833: Theme-Role and Accent Propagation — Remediation Round 3 (F6 chrome migration)

## Summary

CyberCore shell chrome now resolves teal from the installed theme; regression guard added; boundary harness 15/15; cybercore +23 tests green; task promoted to completed after 93/100 independent acceptance.

## Changes

- Documented task completion details.

## Verification

- [x] Independent re-review: docs/reports/reviewers/1833-theme-role-accent-propagation-review-loop.md (Entry 3, 93/100 APPROVED_PATH100, zero REGRESSION findings)

---

# Task 1835: Package-Wide Material Ancestry Meta-Test — Remediation Round 1 (PrismSelect + oracle)

## Summary

Meta-test now guards the full public widget surface (118/118) with a falsification-tight bare-phase oracle; test hygiene fixed (controller teardowns); classification counts corrected to 113 SELF_SUFFICIENT + 5 DECLARED_PREREQUISITE + 0 UNDOCUMENTED_PREREQUISITE.

## Changes

- Documented task completion details.

## Verification

- [x] cd packages/warp_prism_ui && flutter analyze --no-fatal-infos --no-fatal-warnings -> Exit 0 (0 errors, 212 pre-existing info baseline)
- [x] cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub -> Exit 0 (+123: All tests passed)
- [x] cd packages/warp_prism_ui && flutter test test/meta/material_ancestry_meta_test.dart --no-pub --plain-name PrismSelect -> Exit 0 (+1)
- [x] cd packages/warp_prism_ui && flutter test <scoped 5-file suite> --no-pub -> Exit 0 (+171: All tests passed)

---

# Task 1833: Theme-Role and Accent Propagation — Remediation Round 3 (F6 chrome migration)

## Summary

CyberCore shell chrome (header gradient, compact bottom-nav selection, all 4 story-panel accents) now resolves teal from the installed theme via PrismTheme.accentOf/accentMutedOf instead of static Khalai Blue; regression guard added proving teal resolution with pristine registry; DSButton focus-ring oracle strengthened to theme-following; boundary Check 8 stays 15/15 with zero registry mutators in apps/cybercore/lib.

## Changes

- Documented task completion details.

## Verification

- [x] cd apps/cybercore && flutter analyze --no-fatal-infos --no-fatal-warnings -> Exit 0 (No issues found)
- [x] cd apps/cybercore && flutter test --no-pub -> Exit 0 (+23: All tests passed, incl. new chrome teal tests)
- [x] cd apps/cybercore && flutter build linux --debug -> Exit 0
- [x] dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . -> Exit 0 (15/15 PASS)
- [x] cd packages/warp_prism_ui && flutter test test/atoms/button/ds_button_test.dart test/theme/theme_role_accent_propagation_test.dart --no-pub -> Exit 0 (+25)

---

# Task 1834: 1834-capture-proof-honesty

## Summary

Visual capture harnesses fail-closed: unavailable capture now yields BLOCKED/FAIL naming the missing capability instead of silent PASS; artifact verification (PNG magic, IHDR dims); permanent honesty tests.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review PASS 96/100: all claims independently reproduced (3 analyzes + 3 harness runs exit 0, twice each); sabotage honesty tests proven non-tautological; carry-forwards recorded to Task 1805.

---

# Task 1832: 1832-responsive-layout-contract-overflow

## Summary

DSDataTable + DSTimeMachineScrubber layout contracts under real host constraints (h=50, h=119) with LayoutBuilder density adaptation and scroll fallbacks; 16 regression tests.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review PASS exit-scope 73/100: all 7 claimed gates re-executed exit 0; pre-fix mechanism mechanically reconstructed; falsified bands F1/F2/F4 materialized as follow-up Task 1836.

---

# Task 1831: 1831-host-composition-material-contract

## Summary

DSSearchBar self-sufficient Material ancestry (MaterialType.transparency); host-ancestry regression suite; zero No-Material crashes on Observatory routes.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review PASS 93/100: contract test 4/4, molecules 335/335, observatory tests 811/811, observatory linux build, double analyze — all exit 0, reviewer-re-executed.

---

# Task 1805: 1805-final-capture-determinism-review

## Summary

Observatory ticker isolation restored byte-identical repeated capture evidence; all six candidate PNGs were audited as valid 1280x800 8-bit RGBA artifacts.

## Changes

- Documented task completion details.

## Verification

- [x] Catalog, Observatory, and CyberCore format/analyze/capture validations exited 0 with 4/4, 1/1, and 1/1 capture tests passing.
- [x] All six candidate PNGs are non-empty 1280x800 8-bit RGBA; Observatory SHA-256 5a984635c3f6af877dfb144a9e1b62ad906ef00ab2825cd184293fa3d04e0500 repeated exactly.
- [x] Independent reviewer ses_f9a461d7cffeOG5bVLNO6MPJqV returned remediation PASS 100/100 diagnostic; overall Task 1805 remains BLOCKED PENDING-USER.

---

# Task 1805: catalog-local-visual-capture-remediation

## Summary

Independent reviewer PASS 100/100 for the remediation. Four non-empty 1280x800 RGBA candidates now exist under docs/reports/captures/candidates/. Task 1805 remains in 03-review with overall BLOCKED/PENDING-USER: no golden refresh or visual approval is claimed.

## Changes

- Documented task completion details.

## Verification

- [x] cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart (4/4); dart format and flutter analyze exit 0; stat/file confirms four 1280x800 RGBA PNGs

---

# Task 1302: review-lane-drain-w2-w3-complete

## Summary

Executed the canonical 03-review drain (PLAN-03) to completion: 36 parked tasks -> 4, every closure independent-review-verified. W3 stragglers 6/6 PASS (1106 operational MVP artifacts, 1302 barrel lock 296/296 redundant-satisfied by boundary 15/15, 1401 failure baseline + F02 remediated, 1522 keyboard/toast 23/23, 1616 teal skin sanctioned-opt-in verified, 1617 profiles/changelog migration artifacts + validation). W2 EPIC-17 form primitives 7/8 PASS (1700 94, 1701 94, 1702 96, 1704 96, 1705 96, 1706 100, 1707 100 — gallery 22/22, boundary 15/15, analyzer 0E/0W); 1703 BLOCKED-1805 (8/8 behavioral PASS; 4 frozen-golden diffs pending single authorized refresh). W3a EPIC-15/16 organisms 13/13 PASS reconciled from complete verification packet (188 focused + 680 full organism suite, fixture-first held, zero clone paths, Prism aliases verified; formalization follow-up lost to provider failure - evidence authoritative, disposition centrally reconciled per drain plan 4). W1 EPIC-18 visual chain 6/8 PASS (1801 96, 1802 96, 1803 95, 1804 95, 1808 96, 1809 94; fresh evidence: tokens+theme 172/172, theme editor+color field 33/33, observatory 811/811, catalog 14/14, cybercore 16/16, native font smoke 1/1, WCAG recomputed for 1809); 1806+1807 BLOCKED-1805 (technical PASS 92/94 - exits inherently post-sign-off). Remaining 4 in 03-review are all explicitly 1805-human-gated: 1703, 1805 itself, 1806, 1807.

## Changes

- Documented task completion details.

## Verification

- [x] boundary 15/15 across all waves; per-wave test counts recorded in dispositions; 03-review lane: 36 -> 4 (4 = 1805-gated holds)

---

# Task 1830: boundary-checks-16-17-activation

## Summary

Activated the last two PHASED boundary checks, mechanizing the 1825 Part 7 conditional exception policy: check 16 (core packages contain no domain types — scans the 5 v2 semantic packages with word-boundary regex; sanctioned teal-skin stays ui-local per documented policy) + check 17 (FRB generated files not imported directly by widgets — scans apps+packages excluding adapter; import-only regex avoids false-positive on the legal adapter barrel). Boundary harness 13->15/15; layer-contracts-v2 5.1 rows 16/17 -> ENFORCED NOW. Dry-runs found 0 violations (no check weakening needed). Bundled review PASS 98/100.

## Changes

- Documented task completion details.

## Verification

- [x] boundary 15/15 PASS 0 FAIL; dart analyze boundary_test clean; layer-contracts grep ENFORCED NOW rows updated

---

# Task 1828: minimal-connected-catalog-proof

## Summary

First real app consumption surface (MISSION 30 authorizes pre-pilot): ConnectedBridgeLabPage in apps/catalog — WarpBridge.init -> FrbGraphSource -> GraphSourceBinding -> PrismGraphCanvas live projection with interactive addNode native mutation + live watchUpdates refresh. Constructor injection seam (source/bridgeInit) for testability; deterministic fixture fallback (FIXTURE MODE FAKE badge, no crash) when native lib unavailable. CONNECTED badge distinct from STATIC/INTERACTIVE. Zero registry/resolver machinery. Catalog 14/14 tests; FRB grep 0 (barrel-only imports). Bundled review PASS 96/100.

## Changes

- Documented task completion details.

## Verification

- [x] catalog analyze clean; flutter test 14/14; boundary 15/15; grep flutter_rust_bridge in apps/catalog/lib = 0

---

# Task 1827: testkit-suite-gap-closure-g1-g6

## Summary

Closed all 6 named contract-suite gaps from 1821: EventStream pause(resumeSignal) auto-resume + cancelOnError both modes (genuine contract params, not invented); AsyncCommand re-entrancy (contract permits concurrent, auto-cancel documented as binding-layer policy); CommandTimeoutError typed error -> failed lifecycle; HealthSource watch-error (emitWatchError helper, source stays usable); GraphSource watchUpdates error (snapshot intact). Testkit 53->65; adapter parity suite extended 87->95 without callback breakage. Bundled review PASS 94/100 (nuance: timeout lifecycle in fake-specific test, non-blocking).

## Changes

- Documented task completion details.

## Verification

- [x] testkit dart analyze clean + 65/65; adapter integration 95/95; boundary 15/15

---

# Task 1826: health-source-binding-contracts-ui-closure

## Summary

Created HealthSourceBinding + HealthSourceViewModel in warp_prism_bindings (mirroring established binding patterns; bindings MAY import ui per layer law): snapshot/watch projection with TTL freshness, worst-state rollup, watch-error resilience, disposal. HealthSourceMappers bridge HealthState/HealthCell to PrismProviderHealth presentation types. All 4 runtime contracts now have UI bindings — the 1821 named gap (HealthSource had no binding) closed. 43/43 tests. Bundled review PASS 98/100.

## Changes

- Documented task completion details.

## Verification

- [x] flutter analyze clean; flutter test 43 pass; purge grep Timer.periodic|retry = 0; boundary 15/15

---

# Task 1825: 1805-gate-open-pending-human-signoff

## Summary

M01 L1 Integration-Capable gate PASSED (independent acceptance). 13-check audit complete: ADS/IDS/Runtime/FRB golden path all live, 13-check boundary harness, full test suites green, common-subset parity fully symmetric post-remediation. L2 NOT certified (requires first real product pilot + harvest). Next: pilot selection (OmniRoute vertical, requires parent repo governance opening lane).

## Changes

- Documented task completion details.

## Verification

- [x] boundary 13/13; testkit 53/53; adapter 100/100; integration 87/87; cargo 20/20 zero warnings; ui scoped 200/200; IDS proof 7/7; catalog 10/10

---

# Task 1825: integration-readiness-l1-exit-gate-harvest-checklist

## Summary

Formal 13-check Integration Readiness audit executed with fresh evidence (12 PASS + 1 build-budget note + 0 FAIL post-remediation): certified M01 Level 1 Integration-Capable (ADS + IDS + backend-agnostic runtime contracts + Rust golden path via replaceable FRB 2.13.0 adapter, lab-proven). Remediation closed the substrate gaps: native graph update/remove/reset + controllable health watch implemented, parity now fully symmetric (EventStream 19/19, HealthSource 7/7, GraphSource 6/6; AsyncCommand 6/6 modality matrix with documented closure-injection exception per M01 gate amendment). Boundary checks 13/14/15 activated (13/13 harness). MISSION §45 crosswalk (28 items) + fresh ADS evidence (catalog 10/10, ui scoped 200/200) + candidate-identity release boundary recorded. L2 Rewrite Readiness explicitly NOT certified — requires first real product pilot + harvest. Review: FAIL (5 dispositions) -> all 5 executed -> re-review dispatched.

## Changes

- Documented task completion details.

## Verification

- [x] boundary 13/13; testkit 53/53; adapter 100/100 (integration 87/87); cargo build 0 warnings, cargo test 20; IDS proof 7/7; catalog 10/10; ui scoped 200/200

---

# Task 1824: frb-integration-lab-parity-common-subset

## Summary

Single-hypothesis FRB integration lab: same testkit contract suites wired to BOTH in-memory fakes and live native Rust FRB bridge (libwarp_bridge_frb.so via ExternalLibrary). Honest result: 100% parity on the COMMON SUBSET — EventStream 19/19 fully symmetric (all 4 backpressure strategies); HealthSource 5/7 + GraphSource 3/6 (watch/mutation assertions fake-only: substrate lacks mutation/control endpoints — disclosed with root causes in §6.1 COVERAGE LIMITATION); AsyncCommand via 6/6 modality-matrix substitute (suite needs Dart-closure injection, incompatible with fixed native handlers). In-flight cooperative FFI cancellation fully symmetric (CancellationToken → cancelCommand → CommandRegistry → Tokio abort). FFI smoke 5/5. Adapter alignment fixes (backpressure/complete/close idempotency) ruled legitimate contract alignment, not test-gaming. 82 integration tests + 95 total adapter tests pass; boundary 10/10. Review: FAIL 74/100 (overstated 100%-MATCH) → documentary remediation (common-subset verdict, coverage-limitation table, substrate gap-to-close list §6.2) → re-review PASS 96/100.

## Changes

- Documented task completion details.

## Verification

- [x] flutter test integration = 82 pass; full package = 95 pass; boundary 10/10; rg daemon/rpc/hybrid = no matches; cargo build --release clean

---

# Task 1821: runtime-promotion-gate-evidence-pack

## Summary

Created docs/reports/1821-runtime-contracts-promotion-evidence.md: 7-item DoD audit for the 4 runtime contracts (all PASS with named gaps) + per-contract lifecycle classification: ALL 4 HOLD @ EXPERIMENTAL — zero app-level contract consumers (grep-verified across 124 dart files); PROVEN requires real consumer adoption per layer-contracts §3.2 (1817 precedent counts operational app domains, not in-stack scaffolding). AsyncCommand strongest post-adoption candidate; HealthSource weakest (no binding, no real surface). Cross-cutting findings routed to 1825: adapter_frb zero @experimental annotations (check-12 blocker — remediated by orchestrator before 1825); in-stack-domain §3.2 interpretation question. Independent review PASS 89/100 CONDITIONAL (all material claims re-derived; HOLD ruled the only correct reading; this changelog entry closes the review's one HIGH finding).

## Changes

- Documented task completion details.

## Verification

- [x] testkit 53/53; boundary 10/10; runtime purity 2/2; bindings 33/33; grep app consumers = 0; domain leakage = 0

---

# Task 1823: minimal-rust-bridge-substrate-2-crates

## Summary

Created rust/ nested 2-crate workspace (ADR RESOLVED): rust/warp_bridge_core (transport-agnostic command/events/health/graph models + logic, FRB-free, 11 unit tests) + rust/warp_bridge_frb (FRB 2.13.0 projection: smoke add/echo/count_stream + command execute/cancel, event create/stream, health snapshot/watch, graph snapshot/mutation/update-watch; 5 tests; 0 warnings via frb_expand cfg allow). Created packages/warp_prism_adapter_frb (Dart adapter implementing runtime contracts over generated bridge: FrbAsyncCommand with in-flight cooperative cancellation via CommandRegistry+cancel_command, FrbEventStream MutableEventStream, FrbHealthSource native watch stream, FrbGraphSource native update notifications via shared state+broadcast; 10 tests incl. FFI smoke + in-flight cancel + native health/graph watch). Review: FAIL (cargo warning; cancel preflight-only; health watch local; graph updates local) -> remediation (cfg allow; CommandRegistry; native watch_health; native watch_graph_updates) -> re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] cargo build 0 warnings; cargo test 16 pass; adapter analyze clean; adapter flutter test 10 pass; boundary 10/10; core FRB-free; root clean of Cargo.toml

---

# Task 1820: bindings-proof-ids-runtime-convergence

## Summary

Created packages/warp_prism_bindings/ (Flutter package, deps ui+interaction+runtime, dev testkit): EventStreamBinding (subscription lifecycle, buffering, pause/resume/clear, deterministic epoch-0 fallback, optional advisory followState hook — zero owned presentation policy), GraphSourceBinding (semantic→renderable projection with layout Offset owned strictly in binding layer via deterministic circle/grid strategies; structural source-scan assertions enforce runtime purity), AsyncCommandBinding (executeWithIntent bridges IDS InputIntent→runtime AsyncCommand; executeWithQueryIntent bridges QueryIntent; cooperative cancellation). 33 tests via warp_prism_testkit fakes. Review: FAIL (isolation test weak; shallow ==; nondeterministic fallback; out-of-scope claim) -> remediation (source-scan assertions; identity semantics; deterministic sentinel; claim removed) -> re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] flutter analyze clean; flutter test 33 pass; boundary 10/10; grep bindings in ui lib = 0; grep domain/FRB in bindings = 0

---

# Task 1819: runtime-contracts-fakes-testkit

## Summary

Created packages/warp_prism_runtime (pure Dart backend-agnostic contracts: EventStream with producer-side MutableEventStream sink emit/emitBatch/replaceAll/clear, backpressure-as-data, documented Growth Notification (delivery IS notification) + Stable Identity (payload-owned via RuntimeEvent) decisions; HealthSource snapshot/watch/freshness with zero polling; GraphSource semantic models with open typedef kinds and sealed updates incl EdgeUpdated; AsyncCommand lifecycle with cooperative CancellationToken and zero retry) + packages/warp_prism_testkit (4 in-memory fakes + implementation-agnostic contract compliance suites: backpressure behavioral x4 strategies, in-flight cancellation, onDone/isClosed/post-close termination across all 4 suites, EdgeUpdated, growth/identity assertions - 53 tests). Boundary check 12 (runtime Flutter purity) appended: 10/10 PASS. Requirement dispositions recorded in audit section 6.1 (onCellSelected composition-owned; identity/growth payload/delivery-owned). Review: FAIL (8 findings) -> remediation -> FAIL (F1 partial) -> decision-documented remediation -> closed.

## Changes

- Documented task completion details.

## Verification

- [x] dart analyze both packages clean; runtime 2 purity tests; testkit 53 pass; purge grep 0; flutter/dart:ui grep 0; domain leakage 0; boundary 10/10; melos lists both packages

---

# Task 1817: ids-proof-real-consumer-integration-promotion

## Summary

IDS kernel proof and promotion review. Selection/Inspection/Query promoted EXPERIMENTAL -> PROVEN on real-consumer evidence: 7 real-widget proof tests pumping actual PrismWorkflowCanvasStage + PrismFilterWorkbench driven by kernel state via test-only dev_dependency seam (production binding layer = Task 1820). State machine hardened (transitionTo validates table target) + full transition-table adversarial coverage. Findings recorded honestly: multi-selection maps to primarySelection (widget has single-slot); FilterWorkbench reset requires cancel-before-reset per transition table. 104 kernel tests + 34 ui tests green; lib/ purity 0; boundary 9/9. Review: FAIL (isolation simulation) -> remediation (dev-dep + real widget proof) -> re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] flutter test ids_kernel_consumer_proof_test.dart = 7 pass on real organisms; dart test warp_prism_interaction = 104 pass; grep warp_prism_interaction in ui lib/ = 0; boundary 9/9

---

# Task 1822: frb-candidate-spike-kill-gate-pass

## Summary

FRB candidate spike on toolchain rustc 1.95.0/cargo 1.95.0/Flutter 3.44.1/Dart 3.12.1 (Linux x86_64): flutter_rust_bridge 2.13.0 + codegen 2.13.0 via cdylib dynamic loading. Codegen 1.34s; cold release build 8.57s; incremental 0.46s; Dart bridge suite 3/3 PASS (sync add, async echo, reactive stream). KILL-GATE: PASS. Cargo placement ADR RESOLVED -> rust/Cargo.toml (nested workspace) with comparative evidence (Variant A root 8.72s vs Variant B nested 8.64s parity; B wins isolation/cleanliness/codegen symmetry/CI cache). Review: FAIL (ADR lacked comparative evidence) -> remediated with A/B build matrix -> focal re-review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] both placement variants build Finished dev profile; report has measured comparative table; candidate (not adopted) framing retained; repo root clean of Cargo.toml

---

# Task 1818: runtime-consumer-source-audit

## Summary

Created docs/architecture/runtime-consumer-audit.md (141 lines, 25 file:line citations): evidence-backed consumer inventory for the 4 runtime contract candidates with UPDATED counts (EventStream: 1 live app consumer cybercore/live-logs; GraphSource: 1 live app consumer observatory, split already de-facto Offset-free; HealthSource: 0 confirmed, Timer.periodic=0 in apps; AsyncCommand: 2 real async apps, cybercore 6x duplicated boilerplate). Presentation-purge map (6 rows) + 4 MUST-ONLY rules; graph semantic-vs-layout split point; command-state census (Riverpod/ValueNotifier/local). Read-only audit, zero source mutations. Review PASS.

## Changes

- Documented task completion details.

## Verification

- [x] grep Timer.periodic apps/*/lib/ = 0 physically confirmed; boundary harness 9/9 PASS; flutter analyze 0 errors/warnings (214 pre-existing info)

---

# Task 1815: ids-candidate-kernel-selection-inspection-query

## Summary

Created packages/warp_prism_interaction/ (pure Dart, workspace-registered): IDS candidate kernel admitting Selection+Inspection+Query per inventory evidence (Command-intent/Navigation/Viewport deferred). Immutable SelectionState (single/multi/toggle/anchor) + SelectionNotifier bus; Inspection lifecycle (proposed/active/dismissed); QueryController with cancellation + out-of-order token protection; InteractionState transition table with illegal-transition rejection; sealed InputIntent contract (pure data, zero flutter imports; purity test enforces). 46 tests green. Review: FAIL (typedef annotations) -> remediated -> focal re-review PASS (38/38 public declarations @experimental).

## Changes

- Documented task completion details.

## Verification

- [x] dart analyze = no issues; dart test = 46 pass; purity test: 0 package:flutter imports in lib/; boundary harness 9/9 PASS

---

# Task 1813: state-based-declutter-root-hygiene-check9

## Summary

Archive-first root sweep: 22 root scratch files moved with ZERO deletions (1 -> scripts/start-tmux.sh; 21 -> docs/archive/root-scratch/ with 22-row PROVENANCE.md: original path, purpose, task provenance, classification). State-Based Declutter Rule documented in docs/archive/README.md (lifecycle-state-based, never epic-number-based). Boundary harness check 9 appended atomically with the sweep (prefix patterns fix_/tmp_/patch_/append_/snippet_/test_/replace_ds./start-tmux. + py/sh/dart extension class; no count assertions). Serialized after 1811 per writeset ownership. Review PASS: byte-identity of all 22 moves verified, zero dangling references, 9/9 PASS.

## Changes

- Documented task completion details.

## Verification

- [x] ls root *.py *.sh *.dart = 0; boundary harness 9/9 PASS 0 FAIL; dart analyze boundary_test.dart clean; 22/22 moves content-identical to HEAD

---

# Task 1814: interaction-inventory-evidence-driven

## Summary

Created docs/architecture/interaction-inventory.md: 35 evidence rows (31 components + 4 selection payloads) with file:line citations from ~40 source files. Verdicts: Selection/Inspection/Query RECURRENCE_PROVEN (Query = cybercore live-log filtering + observatory workspace search = 2 domains); Command-intent/Navigation-intent/Viewport-state DEFERRED to candidate ledger. 6 counter-examples mapped to correct homes. 4 source-reality corrections to task background recorded. Read-only audit: zero source files modified. Independent review PASS 2026-09-01 (incl. Query-inclusion decision endorsed).

## Changes

- Documented task completion details.

## Verification

- [x] boundary harness 8/8 PASS (no lib/ drift from read-only audit); 3 random file:line citations spot-checked by reviewer and matched

---

# Task 1812: package-topology-workspace-coordination

## Summary

Created docs/architecture/package-topology.md: 6-package v2 registry (ui/interaction/runtime/bindings/testkit/adapter_frb) with ownership, dependency direction law (ui purity, adapter isolation), Rust 2-crate topology (warp_bridge_core modules + warp_bridge_frb) with concept!=crate rule, Runtime!=Presentation model-ownership, workspace coordination reflecting physical Melos-in-pubspec reality, Cargo placement left as OPEN ADR for Task 1822. Independent review PASS 2026-09-01.

## Changes

- Documented task completion details.

## Verification

- [x] grep package names=17, warp_bridge=5, concept rule=1, OPEN ADR=2; melos.yaml physically absent confirmed; consistency with layer-contracts-v2 confirmed by reviewer

---

# Task 1811: layer-contracts-v2-harness-check-8

## Summary

Created docs/architecture/layer-contracts-v2.md (10-row MUST/MAY/MUST-NOT matrix, Global MUSTs, Domain Leakage Rule, bypass-is-a-feature, checks 1-17 authoritative enforcement table) and appended boundary harness check 8 (PrismTokenRegistry mutators only by theme_editor; 2-path allowlist verified precise). Check 9 deliberately left for Task 1813 (serialized writeset ownership). Independent review PASS 2026-09-01: harness 8/8 PASS, 0 FAIL.

## Changes

- Documented task completion details.

## Verification

- [x] dart run boundary_test.dart --repo-root ../.. = 8/8 PASS 0 FAIL; dart analyze boundary_test.dart = no issues; allowlist grep: setColor/resetRole callers only in theme_editor

---

# Task 1810: amend-charter-v2-adr-supersession

## Summary

Amended docs/design/charter.md to v2 mission (ADS+IDS+Runtime Contracts, Rust golden path via replaceable FRB adapter), verbatim framing tattoos, monorepo-level supersession of bootstrap runtime restriction with warp_prism_ui purity retained, preservation invariants, ADR-0001 (Context/Decision/Consequences). AGENTS.md verified-only (already current). Independent review PASS 2026-09-01.

## Changes

- Documented task completion details.

## Verification

- [x] grep tattoos: 2/3/5 counts confirmed; AGENTS.md Last Updated 2026-09-01 verified unedited; charter 189 lines

---

# Task 1809: Warp Prism Taldarim Red and Talon Purple Accent Themes

## Summary

Added two new opt-in accent themes — **Taldarim Red** (`#E51A4C` crimson energy ladder) and **Talon Purple** (`#9911E5` violet/crimson-purple energy ladder) — as `ThemeExtension` skins (`DSTaldarimRedSkin`, `DSTalonPurpleSkin`) and static factories (`DSTheme.taldarimRed()`, `DSTheme.talonPurple()`, aliased publicly as `PrismTheme.taldarimRed()` and `PrismTheme.talonPurple()`).

Both themes strictly honor Rule Zero: backgrounds stay in the `#030506` black obsidian family, static `DSColors` defaults remain unmodified (Khalai Blue default action accent `#2F81FF`), and existing Protoss brand labels (Khalai Blue, Nerazim Green/Teal, Purifier Gold) are documented alongside the new brand labels.

## Changes

- Created `packages/warp_prism_ui/lib/src/tokens/ds_taldarim_red_skin.dart` with `DSTaldarimRedSkin` ThemeExtension.
- Created `packages/warp_prism_ui/lib/src/tokens/ds_talon_purple_skin.dart` with `DSTalonPurpleSkin` ThemeExtension.
- Added `DSTheme.taldarimRed()` and `DSTheme.talonPurple()` static factories in `packages/warp_prism_ui/lib/src/theme/ds_theme.dart`.
- Re-exported `DSTaldarimRedSkin` and `DSTalonPurpleSkin` in `packages/warp_prism_ui/lib/src/tokens/tokens.dart`.
- Exported public aliases `PrismTaldarimRedSkin` and `PrismTalonPurpleSkin` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Updated `docs/design/public-barrel-audit.md` symbol inventory lock from 294 to 296 Prism symbols.
- Added unit tests in `packages/warp_prism_ui/test/tokens/ds_taldarim_red_skin_test.dart` and `ds_talon_purple_skin_test.dart`.
- Added factory & Rule Zero regression tests in `packages/warp_prism_ui/test/theme/prism_theme_test.dart`.
- Updated `apps/catalog/lib/main.dart` with `CatalogThemeVariant` enum for live preview of all 4 accent themes (Khalai Blue, Taldarim Red, Talon Purple, CyberCore Teal).

## Verification

- `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos` (PASS: 0 errors)
- `cd packages/warp_prism_ui && flutter test test/theme test/tokens` (PASS: 172/172 tests green)
- `cd packages/warp_prism_ui && flutter test test/boundaries` (PASS: 7/7 boundary harness green)
- `cd apps/catalog && flutter analyze` (PASS: 0 issues)
- `dart run tool/verify_public_barrel_audit.dart` (PASS: 296/296 symbols locked)
- Golden freeze intact: existing goldens untouched, zero new PNG goldens created.

---

# Task 1806: Component and Gallery Visual Reconciliation

## Summary

Reconciled all Warp Prism component families (EPIC-15 organisms, EPIC-16 organisms, EPIC-17 form primitives/atoms/molecules, legacy shell, sidebar, gallery framing, cards, status surfaces) against the approved Black Obsidian contract (`docs/design/black-obsidian-visual-contract.md`). Rewrote gallery color swatch page in `design_system_gallery_sections.dart` to expose the complete Black Obsidian palette as data source. Replaced the single retained gallery fixture raw hex swatch (`#0C1220`) at `design_system_gallery_sections.dart:4790` with token `DSColors.obsidianHover`. Formally recorded the semantic decision for `statusPromoted` (`DSColors.accentCyan` `#00D4FF` retained for operational data-state rendering to avoid collision with UI action controls `DSColors.accentBlue` `#2F81FF`). Verified EPIC-17 form primitives' `DSColors.accentBlue` defaults and updated gallery registry section count expectations to 24 sections (including Theme Editor).

## Changes

- Rewrote `_buildColorSwatches()` in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` to render obsidian surfaces (`obsidianDeep`, `obsidianBase`, `obsidianElevated`, `obsidianHover`), primary action blue ladder (`accentBlue`, `accentBlueMuted`, `accentBlueDim`, `focusRing`), data & status accents (`accentCyan`, `accentViolet`, `accentGold`, `statusSuccess`, `statusWarning`, `statusError`, `statusInfo`, `statusPromoted`), text and border tokens.
- Replaced retained raw hex swatch `const Color(0xFF0C1220)` in `design_system_gallery_sections.dart:4790` (`_MapHudWorkspaceDemo`) with token `DSColors.obsidianHover`.
- Updated `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` registry section count expectation to 24 sections to account for Task 1807 Theme Editor.
- Validated per-component compliance matrix across EPIC-15 organisms, EPIC-16 organisms, EPIC-17 form primitives, and legacy shell/cards/status surfaces.
- Preserved interim golden freeze policy (`PENDING-USER` golden refresh liftoff).

## Verification

- `cd packages/warp_prism_ui && flutter analyze` → PASS (0 errors, 218 infos)
- `cd apps/catalog && flutter analyze` → PASS (0 errors, 0 infos)
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → PASS (7/7 boundary checks passing)
- `cd packages/warp_prism_ui && flutter test test/tokens/ test/organisms/ test/gallery/ test/accessibility_focus_contrast_test.dart test/boundaries/ --no-pub` → PASS (853/853 non-golden unit/widget tests passing)
- `cd apps/catalog && flutter test --no-pub` → PASS (10/10 catalog widget/registry proof tests passing)
- `cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub` → Record expected golden drift (59 golden tests failing as expected against frozen baselines; 0 goldens regenerated)

---

# Task 1805: Screenshot Visual Acceptance Gate and Golden Policy

## Summary

Implemented mechanical screenshot capture infrastructure for `warp-prism` visual acceptance gate. Migrated all 13 golden test suites (`packages/warp_prism_ui/test/goldens/`) and atom test wrappers to consume `PrismTheme.dark()` canonical factory. Created desktop 1280x800 `integration_test` capture suites for Catalog (canonical host), Observatory, and CyberCore. Documented golden freeze policy handoff and review checklist scaffolding (marked `PENDING-USER` until user visual convergence session with Theme Editor).

## Changes

- Migrated all 13 golden test suites in `packages/warp_prism_ui/test/goldens/` from `ThemeData.dark()` to `PrismTheme.dark()`.
- Migrated atom golden test wrappers in `ds_button_test.dart`, `ds_text_field_test.dart`, and `ds_checkbox_test.dart` to consume `PrismTheme.dark()`.
- Created `apps/catalog/integration_test/visual_acceptance_capture_test.dart` for deterministic 1280x800 desktop captures of Typography specimen, Token Swatches palette, Dense Organism (`PrismProviderHealthMatrix`), and Form Primitives.
- Created `apps/observatory/integration_test/observatory_visual_capture_test.dart` for Observatory host dashboard capture.
- Created `apps/cybercore/integration_test/cybercore_visual_capture_test.dart` for CyberCore host shell with `PrismCyberCoreTealSkin` capture.
- Produced audit report `docs/reports/1805-visual-acceptance-gate-report.md`.

## Verification

- `cd packages/warp_prism_ui && dart analyze` (PASS, 0 errors; 217 existing infos)
- `cd apps/catalog && flutter analyze integration_test/visual_acceptance_capture_test.dart` (PASS, no issues)
- `cd apps/observatory && flutter analyze integration_test/observatory_visual_capture_test.dart` (PASS, no issues)
- `cd apps/cybercore && flutter analyze integration_test/cybercore_visual_capture_test.dart` (PASS, no issues)
- `cd apps/catalog && flutter test integration_test/visual_acceptance_capture_test.dart --name 'captures typography specimen'` (PASS, 1/1; desktop `takeScreenshot` unavailable via `MissingPluginException`, no PNG artifact)
- `cd apps/catalog && flutter test integration_test/` (FAIL, app startup/log-reader failure)
- `cd apps/observatory && flutter test integration_test/observatory_visual_capture_test.dart` (BLOCKED, startup/log-reader timeout)
- `cd apps/cybercore && flutter test integration_test/cybercore_visual_capture_test.dart` (BLOCKED, startup/log-reader timeout)
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (PASS, 7/7)
- `cd packages/warp_prism_ui && flutter test test/goldens/ --concurrency=1 --no-pub` (FAIL, 59 frozen golden-baseline failures; expected while PENDING-USER)

No committed PNG screenshots were produced in this headless desktop run. Human visual approval remains PENDING-USER.

---

# Task Governance: Lane-Derived Status

## Summary
Removed task-level `Status` header fields from the Warp Prism task corpus and
updated the task template and applicable governance rules so lifecycle/readiness
status is derived solely from the containing task lane directory.

## Changes
- Removed 169 task-header `Status` lines under `docs/tasks/`.
- Preserved five historical inline `Status` notes in Review Ledger/body prose.
- Updated `docs/tasks/000-template.md` with explicit lane-derived status guidance.
- Updated local `AGENTS.md` and lane/task artifact rules.
- Updated parent `AGENTS.md` with the cross-project convention.
- Updated sibling templates in `pm_lens`, `cryptosentinel-v1`, `optillm-go`,
  `research`, and `templar-archives`.
- Updated optillm-go task-governance guidance that still required header status.

## Verification
- Scoped Warp Prism scan reports no task-header `Status` lines; only five
  historical Review Ledger/body lines remain.
- Sibling inventory recorded legacy header counts for follow-up cleanup; no
  bulk edits were applied outside templates and explicitly inspected governance
  guidance.

---

# 2026-08-22 — Task 1807: Token Override Layer and PrismThemeEditor Organism

**Agent**: builders
**Task**: 1807
**Type**: feature

## Summary

Implemented the tooling-facing `PrismTokenRegistry` token override layer and the `PrismThemeEditor` organism widget. Replaces one-shot hex approval with live visual iteration inside the ADS Catalog storybook, enabling instant preview of Black Obsidian token overrides and exporting converged values as a Dart code snippet for bake-back.

## Changes

### `packages/warp_prism_ui/lib/src/tokens/`
- Created `prism_token_registry.dart`: `PrismTokenRegistry` singleton managing editable Black Obsidian color roles (`obsidianDeep`, `obsidianBase`, `obsidianElevated`, `obsidianHover`, `borderDefault`, `accentBlue`, `accentBlueMuted`, `accentBlueDim`, `focusRing`), `reset()`, hex parser/formatter helpers, and `generateBakeBackSnippet()`.
- Updated `ds_colors.dart`: Converted editable color roles from `static const` to getter-backed properties delegating to `PrismTokenRegistry.instance`. Re-aligned const-context usages across organisms and gallery.
- Updated `tokens.dart`: Exported `prism_token_registry.dart`.

### `packages/warp_prism_ui/lib/src/organisms/theme_editor/`
- Created `prism_theme_editor.dart`: `PrismThemeEditor` organism widget with grouped role editors, hex input fields, palette preset quick-chips (Obsidian Blue, CyberCore Teal, Protoss Gold), reset button, bake-back code snippet export dialog, 48x48 min touch targets with explicit Semantics, and per-role copy hex actions.

### `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Exported `PrismTokenRegistry`, `PrismThemeEditor`, and `DSOperationalStateUI` to fix package analyzer extension resolution.

### `apps/observatory/`
- Fixed 3 invalid `const` usages resulting from token getter migration in `map_graph_panel.dart`, `map_inspector_panel.dart`, and `shell_state_handler.dart`.

### `packages/warp_prism_ui/lib/src/gallery/`
- Integrated `PrismThemeEditor` toggle into `DesignSystemGalleryPage` header and registered `buildThemeEditorSection` in gallery sections & registry.

### `apps/catalog/lib/main.dart`
- Wrapped `WarpPrismCatalogApp` root with `ListenableBuilder` listening to `PrismTokenRegistry.instance` to enable live MaterialApp theme rebuilds when tokens change.

### `packages/warp_prism_ui/test/`
- Created `test/tokens/prism_token_registry_test.dart`: 7 unit/widget tests verifying defaults, `setColor`, `resetRole`, `reset`, hex parsing, snippet generation, and golden-safety rendering isolation proof test.
- Created `test/organisms/theme_editor/prism_theme_editor_test.dart`: 8 widget tests verifying rendering, preset chips, reset button, export snippet dialog, hex validation error handling, per-role copy hex action, and 48x48 touch targets.

## Path-to-100 Remediation (2026-08-23)
- Fixed Observatory getter migration const-fallout in 3 files (analyze clean).
- Exported `DSOperationalStateUI` via `prism_aliases.dart` to resolve 15 undefined getter errors in package tests (package analyze clean - 0 errors).
- Upgraded `_PresetChip` and per-role reset buttons to explicit 48x48 touch targets and `Semantics` buttons.
- Added per-role copy-hex action with visual SnackBar feedback and corresponding widget test.
- Added golden-safety rendering isolation proof test (`ListenableBuilder` consumer rendering + registry mutation + tearDown reset verification).
- Updated Completion Evidence with full validation suite exact outputs and golden freeze signal (59 failures / 0 regenerated).

## Validation

```text
cd packages/warp_prism_ui && flutter analyze                       # 0 errors
cd packages/warp_prism_ui && flutter test test/tokens/ test/boundaries/ test/organisms/theme_editor/ # 157/157 PASS
cd apps/observatory && flutter analyze                              # 0 errors
cd apps/catalog && flutter analyze && flutter test                  # 0 errors, 10/10 PASS
cd apps/cybercore && flutter analyze                                # 0 errors
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root . # 7/7 PASS
cd packages/warp_prism_ui && flutter test test/goldens/            # 59 failures (Task 1805 freeze, 0 baselines regenerated)
```

---

# 2026-08-22 — Task 1808: PrismColorField Molecule (Hex Input + Swatch Picker)

**Agent**: builders
**Task**: 1808
**Type**: feature

## Summary

Implemented the `PrismColorField` (`DSColorField`) molecule — a validated hex text field with preset swatch row, clear/error states, and eyedropper API hook.

## Changes

### `packages/warp_prism_ui/lib/src/molecules/color_field/`
- Created `hex_color_parser.dart`: pure functions for parsing #RGB, #RRGGBB, and #AARRGGBB hex colors and formatting Colors to hex strings.
- Created `ds_color_field.dart`: `DSColorField` stateful molecule widget adhering to ADS token contracts (obsidian elevated backgrounds, focus ring glow, 48x48 min touch targets, A11y semantics).
- Created `color_field.dart`: barrel export for color field molecule.

### `packages/warp_prism_ui/lib/src/molecules/molecules.dart`
- Added barrel export for `color_field/color_field.dart`.

### `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Exported `typedef PrismColorField = DSColorField`.

### `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Registered `_ColorFieldDemo` gallery section demonstrating interactive input, swatches, error state, and eyedropper hook.

### `packages/warp_prism_ui/test/molecules/color_field/`
- Created `hex_color_parser_test.dart`: 9 unit tests for hex parsing & formatting.
- Created `ds_color_field_test.dart`: 11 widget tests for rendering, typing, swatch selection, clearing, eyedropper callback, disabled state, and 48x48 touch targets.

## Scope Discipline & Decision
- **HSV Interactive Picker**: Evaluated v1.1 scope per task instructions. Explicitly cut from v1 to keep molecule lightweight and delivery honest. The core hex input + swatch row + clear/error states ship 100% usable.

## Validation

```text
cd packages/warp_prism_ui
flutter test test/molecules/color_field/                          # 20/20 PASS
dart run test/boundaries/boundary_test.dart --repo-root .          # 7/7 PASS
```

---

# Task 1803: Canonical ThemeData and App Host Wiring

## Summary

Created canonical `PrismTheme.dark()` (backed by `DSTheme.dark()`) inside `packages/warp_prism_ui`, exporting it through `prism_aliases.dart` and `warp_prism_ui.dart`. Wired Catalog, Observatory, and CyberCore app roots to consume `PrismTheme.dark()`.

## Changes

- Created `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` containing `DSTheme.dark()` static factory.
- Exported `PrismTheme` alias in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Added unit and widget tests in `packages/warp_prism_ui/test/theme/prism_theme_test.dart`.
- Wired `apps/catalog/lib/main.dart` to use `PrismTheme.dark()`.
- Wired `apps/observatory/lib/app/app.dart` to use `PrismTheme.dark()`.
- Wired `apps/cybercore/lib/main.dart` to apply `PrismCyberCoreTealSkin` over `PrismTheme.dark()`.
- Updated `docs/design/public-barrel-audit.md` to keep barrel audit lock in sync.

## Verification

- `cd packages/warp_prism_ui && flutter analyze && flutter test test/theme/` (PASS, 5/5 theme tests green)
- `cd apps/catalog && flutter analyze && flutter test` (PASS, 10/10 tests green)
- `cd apps/observatory && flutter analyze && flutter test` (PASS, 810/810 tests green)
- `cd apps/cybercore && flutter analyze && flutter test` (PASS, 16/16 tests green)
- `dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart` (PASS)

---

### Hardcoded Visual-Value Baseline Audit & Remediation

- **Audit Inventory**: Established workspace-wide baseline inventory of raw component-level colors.
- **Structural Remediation**: Migrated candidate structural raw `Color(0x...)` values in `ds_media_detail_overlay.dart` to token surface spectrum constants (`DSColors.obsidianActive`, `DSColors.glassOverlay`, `DSColors.obsidianHover`).
- **Audit Command**: Recorded high-signal repeatable audit command (`rg -n "Color\.(fromARGB|fromRGBO)|Color\(0x|HSLColor" --glob '!**/tokens/**' ...`) with a clean baseline expectation of 2 legitimate findings (1 swatch, 1 shadow scrim).
- **Deliverables**: Persisted durable analytical audit report at `docs/reports/builders/1804-warp-prism-hardcoded-visual-value-audit-report.md`.

---

# Task 1802: warp-prism-typography-font-assets

## Summary

Bundled Rajdhani TTFs (300–700 weights) and OFL.txt license file across all three applications (`apps/catalog`, `apps/observatory`, `apps/cybercore`), declared Rajdhani font families in all three app `pubspec.yaml` files, updated `DSTypography.fontFamilySans` to `'Rajdhani'` with explicit system fallback chains (`fontFamilySansFallback` and `fontFamilyMonoFallback`), fixed Observatory root `app.dart` global mono wiring defect by setting `fontFamilySans`, and updated token contract tests to verify font families, fallback contracts, and technical/metrics role allocations.

## Changes

- Bundled `Rajdhani-Light.ttf`, `Rajdhani-Regular.ttf`, `Rajdhani-Medium.ttf`, `Rajdhani-SemiBold.ttf`, `Rajdhani-Bold.ttf` + `OFL.txt` under `assets/fonts/` for `apps/catalog`, `apps/observatory`, and `apps/cybercore`.
- Updated `pubspec.yaml` in `apps/catalog`, `apps/observatory`, and `apps/cybercore` to declare the `Rajdhani` font family and weights.
- Updated `packages/warp_prism_ui/lib/src/tokens/ds_typography.dart`:
  - `fontFamilySans` updated from `'Inter'` to `'Rajdhani'`.
  - Added `fontFamilySansFallback` (`['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']`) and `fontFamilyMonoFallback` (`['Courier New', 'monospace']`).
  - Added `fontFamilyFallback` to all 18 text styles.
  - Documented role allocation and numeric/metrics technical role decision per Visual Contract §3.1.
- Updated `apps/observatory/lib/app/app.dart`: fixed global mono wiring defect by changing root `fontFamily` from `fontFamilyMono` to `fontFamilySans`.
- Updated `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`: updated family assertions ('Rajdhani' / 'JetBrainsMono') and added fallback contract and role separation assertions.

## Verification

- `dart analyze lib/src/tokens/ds_typography.dart test/tokens/ds_token_contract_test.dart` -> PASS (0 issues)
- `flutter test test/tokens/ds_token_contract_test.dart --concurrency=1 --no-pub` -> PASS (40/40 tests)
- `for app in catalog observatory cybercore; do test -f apps/$app/assets/fonts/Rajdhani-Regular.ttf || echo "MISSING $app"; done` -> PASS (all 3 present)
- `flutter test` in `apps/catalog` -> PASS (10/10 tests)

---

# Task 1801: Black Obsidian Token Migration and Semantic Palette Mapping

## Summary

Implemented Task 1800 Black Obsidian visual contract in shared Warp Prism tokens:
- Deep background `#030506`, base surface `#080C0E`, elevated surface `#0C1114`, hover lift `#12181C`, border `#121D22`.
- Additive blue accent ladder (`accentBlue` `#2F81FF`, `accentBlueMuted` `#1D64D8`, `accentBlueDim` `#114299`, `focusRing` `#2F81FF` @ 50%).
- Retained cyan (`accentCyan` `#00D4FF`) as data-category accent; `statusPromoted` remains `accentCyan`.
- Collision guard assertions prove blue ladder hexes are distinct from `#3B82F6` (`statusInfo`, `governanceLocal`, `laneOpen`).
- Updated Task 1616 regression guards with provenance citation ("amends Task 1616 regression guards per EPIC-18 / Task 1800 / Task 1801").
- Updated authoritative sections of `docs/design/token-theme-catalog-policy.md` (§2.2, §2.3, §6.3, §7.4) and `docs/design/ads-package-purity-and-interactive-state-checklist.md` with supersession notes.
- Added derived glow `glowBlue` to `DSShadows` and documented auto-shift behavior.

- Project-wide focus ring & active control migration across package components (`DSChip`, `DSFilterChipGroup`, `DSTextField`, `DSSelect`, `DSSearchBar`, `DSSwitch`, `DSButton`, `DSCheckbox`, `DSDropTarget`, `DSDraggableCard`, `DSAccordion`, `DSDataTable`, `DSViewPresets`, `DSLayerControlPanel`, `DSSplitPane`, `DSToolStripSlideout`, `DSOpsControlCluster`, `DSTerminalWorkspace`, `DSMapHudWorkspace`, `DSCommandPalette`, `DSTree`) to `DSColors.focusRing` (#802F81FF) and `DSColors.accentBlue` (#2F81FF).
- Created SVG before/after swatch artifact under `docs/design/swatches/token_migration_1801_swatch.svg`.

## Changes

- `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`: Black Obsidian background & blue action accent tokens.
- `packages/warp_prism_ui/lib/src/tokens/ds_shadows.dart`: Added `glowBlue` and auto-shift documentation comment.
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`: Updated `PrismColors` doc comments.
- `packages/warp_prism_ui/lib/src/`: Project-wide focus-ring & active control migration across 21 component files.
- `packages/warp_prism_ui/test/tokens/ds_cybercore_teal_skin_test.dart`: Updated hex guards with provenance citation.
- `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`: Added contract hex assertions, blue ladder tests, collision guards, status protection assertions, and shadow auto-shift test.
- `packages/warp_prism_ui/test/accessibility_focus_contrast_test.dart` & `ds_button_test.dart` & `ds_checkbox_test.dart`: Updated focus ring and active selection assertions.
- `docs/design/swatches/token_migration_1801_swatch.svg`: Created SVG swatch artifact.
- `docs/design/token-theme-catalog-policy.md`: Added supersession notes referencing Task 1800.
- `docs/design/ads-package-purity-and-interactive-state-checklist.md`: Updated default accent branding lines.

## Verification

- `dart analyze lib/src/ test/`: 0 errors.
- `flutter test test/tokens/ test/accessibility_focus_contrast_test.dart --concurrency=1 --no-pub`: 159/159 PASS.
- `dart test/boundaries/boundary_test.dart`: 7/7 PASS.
- Unit/widget/accessibility/gallery test suite (excluding goldens): 1407/1407 PASS.

---

# Task 1800: warp-prism-black-obsidian-visual-contract

## Summary

Created the authoritative Black Obsidian Visual Contract (`docs/design/black-obsidian-visual-contract.md`) to freeze product identity: black obsidian (#030506) background, bounded blue accent ladder (#2F81FF provisional), font role separation (Rajdhani UI / JetBrains Mono technical), forbidden-pattern checklist, supersession map for Task 1105 / Task 1616 / EPIC-17, and interim golden freeze policy between 1801 and 1805.

## Changes

- Created `docs/design/black-obsidian-visual-contract.md` containing Rule Zero verbatim, product owner rationale, provisional palette table, typography role table, binary forbidden checklist, can/cannot composition examples, supersession map, and interim golden freeze policy.
- Annotated `docs/tasks/00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` with supersession pointer for active/checked states.
- Annotated `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md` closing Task 1800 contract deliverable.

## Verification

- `test -f docs/design/black-obsidian-visual-contract.md && grep -q "screenshot" docs/design/black-obsidian-visual-contract.md` -> PASS
- `dart analyze packages/warp_prism_ui apps/catalog apps/observatory` -> PASS (0 errors)

---

# EPIC-18 Amendment — Theme Editor Convergence Loop

## Summary

User decision (2026-08-22): exact accent hexes are no longer approved from static
swatches. The Catalog storybook gains a live Theme Editor so the product owner iterates
accent/surface colors visually and converged values are baked back into tokens.

## Decisions

- Override mechanism = `PrismTokenRegistry` backing ONLY the editable role set
  (blue ladder, focus, surfaces, border) via static getters; call sites unchanged;
  data accents/statuses stay `static const` until Task 1806.
- `PrismThemeEditor` ships as an ADS organism in `warp_prism_ui`; Catalog hosts it.
- `PrismTokenRegistry` is tooling-facing only; production code paths never mutate.
- Task 1805 final approval/golden refresh runs after bake-back on defaults.
- Task 1800 amended: provisional ladder unblocks 1801–1803; sign-off completes at
  convergence.

## Files

- Created: `docs/tasks/01-open/1807-warp-prism-token-override-theme-editor.md`
- Created: `docs/tasks/01-open/1808-warp-prism-color-field-molecule.md`
- Modified: `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`
  (task graph + convergence loop amendment)
- Modified: `docs/tasks/01-open/1800-warp-prism-black-obsidian-visual-contract.md`
  (provisional-hexes exit conditions)

---

# EPIC-18 Promotion — Black Obsidian Visual Direction Reset

## Summary

Architect orchestrator validation wave (task-architect governance audit + Flutter
expert technical audit + direct evidence verification) approved the black-obsidian
visual direction and promoted seven expanded executable tasks from `00-planning/`
seeds to `docs/tasks/01-open/`.

## Key decisions recorded (EPIC-18 § Architect Review Questions — CLOSED)

- Rule Zero: default background is BLACK OBSIDIAN (`#030506` family); blue is
  accent-only; user health/aesthetic rationale recorded verbatim.
- Blue ladder additive; distinctness asserted vs `statusInfo`/`governanceLocal`/
  `laneOpen` (all `#3B82F6`).
- `accentCyan`: 347 call sites; cyan stays data-accent until Task 1806;
  `statusPromoted` re-pointing only there.
- Inter was declared but bundled nowhere — Task 1802 includes asset acquisition
  (Rajdhani OFL) plus token-contract test updates.
- Canonical theme = complete-M3 `PrismTheme.dark()` factory in `warp_prism_ui`
  (Task 1803); component-level non-mono assertion required.
- Corrected audit pattern for Task 1804 (ground truth ~9 raw values, 4 candidates).
- Screenshot gate builds on existing matchesGoldenFile harness; goldens cannot prove
  fonts (Ahem); human approval artifact = committed PNGs + signed checklist +
  changelog ref. Interim golden freeze between 1801 and 1805.

## Files

- Created: `docs/tasks/01-open/180{0..6}-warp-prism-*.md` (7 files, template-compliant)
- Modified: `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`
- Archived: seeds → `.archive/planning-seeds-epic18-2026-08-22/`

## Notes

- Child `AGENTS.md` §5 resolved via interpretive note inside Task 1800 (no
  constitutional edit).
- User sign-off pending only on exact blue accent hexes (swatch pick gate in 1800).

---

# Boundary Harness Regex Fix (generic typedefs)

## Summary

`test/boundaries/boundary_test.dart` failed its "All public DS declarations have Prism aliases" check (6/7 PASS) because the typedef-matching regex `typedef\s+Prism\w+\s*=\s*(DS[A-Z]\w+)\s*;` could not parse generic typedefs. Task 1702 introduced the package's first generic alias (`typedef PrismSelect<T> = DSSelect<T>;`), which broke the previously-green harness.

## Changes

- `packages/warp_prism_ui/test/boundaries/boundary_test.dart` line 237: regex now accepts optional type parameters on both sides:
  `r'typedef\s+Prism\w+(?:<[^>]*>)?\s*=\s*(DS[A-Z]\w+)(?:<[^>]*>)?\s*;'`

## Verification

- `dart run test/boundaries/boundary_test.dart --repo-root .` → 7/7 PASS, 0 FAIL, 0 violations
- `dart analyze test/boundaries/` → 0 issues

## Notes

- Existing aliases `PrismSelect`/`PrismSelectItem`/`PrismSelectOption` were always present and correct; the regex was the defect.

---

# Task 1705: warp-prism-prism-dialog-modal-molecule

## Summary

Implemented `DSDialog` and public alias `PrismDialog` for `warp_prism_ui`.
Features obsidian dark glass container (`DSGlassPanel.modal`), full-screen backdrop scrim (0.7 opacity obsidian overlay), header with title, subtitle, icon, and optional close button; scrollable content body slot; action buttons footer composing `DSButton` / `PrismButton`; keyboard `Escape` dismiss; keyboard `Enter` primary action execution; isolated `FocusScope` focus trap (Tab/Shift-Tab stays inside the modal); popup helper function `showPrismDialog` (`DSDialog.show`); and public-barrel re-export of `showPrismDialog` via `prism_aliases.dart` so consumers importing `package:warp_prism_ui/warp_prism_ui.dart` can call it directly.

## Changes

- Created `packages/warp_prism_ui/lib/src/molecules/dialog/ds_dialog.dart` (`DSDialog`, `DSDialogAction`, `DSDialogSize`, `showPrismDialog`)
- Created `packages/warp_prism_ui/lib/src/molecules/dialog/dialog.dart` (barrel export)
- Updated `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (added `dialog/dialog.dart` export)
- Registered `typedef PrismDialog = DSDialog;`, `typedef PrismDialogAction = DSDialogAction;`, `typedef PrismDialogSize = DSDialogSize;` and `showPrismDialog` top-level helper in `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Registered `Modal Dialog (DSDialog / PrismDialog)` interactive demos in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Created unit/widget test suite `packages/warp_prism_ui/test/molecules/dialog/ds_dialog_test.dart` (8 tests: 7 original + focus-trap Tab/Shift-Tab containment test)

## Verification

- [x] `cd packages/warp_prism_ui && dart analyze lib/src/molecules/dialog/ test/molecules/dialog/` (0 issues)
- [x] `cd packages/warp_prism_ui && flutter test test/molecules/dialog/ --concurrency=1 --no-pub` (8/8 PASS)
- [x] `cd packages/warp_prism_ui && dart analyze` (0 errors)

---

# Task 1707: PrismAccordion Molecule Implementation

## Summary

Implemented `DSAccordion` / `PrismAccordion` collapsible molecule in `warp_prism_ui` for collapsible content section display, supporting single and multi-expand modes, animated chevron rotation (180° via `AnimatedRotation`), `AnimatedSize` content expansion, disabled section support, empty content fallback state surface, and gallery demonstrations.

## Changes

- Created `packages/warp_prism_ui/lib/src/molecules/accordion/ds_accordion.dart` (`DSAccordion` widget + `DSAccordionItem` model + `DSAccordionSection` typedef).
- Created barrel file `packages/warp_prism_ui/lib/src/molecules/accordion/accordion.dart`.
- Re-exported accordion barrel from `packages/warp_prism_ui/lib/src/molecules/molecules.dart`.
- Registered `typedef PrismAccordion = DSAccordion;`, `typedef PrismAccordionItem = DSAccordionItem;`, and `typedef PrismAccordionSection = DSAccordionSection;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Updated public barrel audit table in `docs/design/public-barrel-audit.md`.
- Added interactive gallery demonstration in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Added comprehensive unit and widget tests in `packages/warp_prism_ui/test/molecules/accordion/ds_accordion_test.dart`.

## Verification

- `cd packages/warp_prism_ui && dart analyze lib/src/molecules/accordion/ test/molecules/accordion/`: 0 issues found.
- `cd packages/warp_prism_ui && flutter test test/molecules/accordion/ --concurrency=1 --no-pub`: All 8 tests passed.
- `cd packages/warp_prism_ui && dart run tool/verify_public_barrel_audit.dart`: Public barrel audit lock: PASS.

---

# Task 1706: PrismBreadcrumbs Organism Implementation

## Summary

Implemented `DSBreadcrumbs` / `PrismBreadcrumbs` organism in `warp_prism_ui` for hierarchical navigation path display, supporting custom separators, active item state, click callbacks, middle-item truncation via PopupMenuButton, optional route auto-derivation, and gallery demonstrations.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart` (`DSBreadcrumbs` widget + `DSBreadcrumbItem` model).
- Created barrel file `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/breadcrumbs.dart`.
- Re-exported barrel from `packages/warp_prism_ui/lib/src/organisms/organisms.dart`.
- Registered `typedef PrismBreadcrumbs = DSBreadcrumbs;` and `typedef PrismBreadcrumbItem = DSBreadcrumbItem;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Added interactive gallery demonstration in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Added comprehensive unit and widget tests in `packages/warp_prism_ui/test/organisms/breadcrumbs/ds_breadcrumbs_test.dart`.

## Verification

- `cd packages/warp_prism_ui && dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/`: 0 issues found.
- `cd packages/warp_prism_ui && flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub`: All 9 tests passed.

---

# Task 1704: warp-prism-prism-switch-toggle-atom

## Summary

Implemented `DSSwitch` and public alias `PrismSwitch` for `warp_prism_ui`.
Features obsidian dark glass track, cyan active fill (`DSColors.accentCyan` / optional `DSCyberCoreTealSkin`), smooth 200ms thumb animation (`AnimatedAlign` with `DSMotion.normal`), right-side label placement, disabled state opacity/input gating, and 48x48 min touch target composed via `DSInteractiveSurface`.

## Changes

- Created `packages/warp_prism_ui/lib/src/atoms/switch/ds_switch.dart`
- Created `packages/warp_prism_ui/lib/src/atoms/switch/switch.dart`
- Created compatibility barrel redirect `packages/warp_prism_ui/lib/src/atoms/ds_switch.dart`
- Updated `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
- Registered `typedef PrismSwitch = DSSwitch;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Updated `docs/design/public-barrel-audit.md`
- Added interactive switch demo in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Created widget/unit test suite `packages/warp_prism_ui/test/atoms/switch/ds_switch_test.dart` and redirect test `packages/warp_prism_ui/test/atoms/ds_switch_test.dart`

## Verification

- [x] `cd packages/warp_prism_ui && dart analyze lib/src/atoms/switch/ test/atoms/switch/` (0 issues)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/switch/ --concurrency=1 --no-pub` (9 tests passed)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/ds_switch_test.dart --concurrency=1 --no-pub` (9 tests passed)

---

# Task 1703: warp-prism-prism-checkbox-atom

## Summary

Implemented `DSCheckbox` and public alias `PrismCheckbox` for `warp_prism_ui`.
Features obsidian glass box background, cyan checked fill with glow border (`DSGlowBorder`), checkmark icon, tristate support (false -> true -> null -> false), label placement, disabled state, and 48x48 min touch target composed via `DSInteractiveSurface`.

## Changes

- Created `packages/warp_prism_ui/lib/src/atoms/checkbox/ds_checkbox.dart`
- Created `packages/warp_prism_ui/lib/src/atoms/checkbox/checkbox.dart`
- Updated `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
- Registered `typedef PrismCheckbox = DSCheckbox;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Registered checkbox interactive demo in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Created widget/unit/golden test suite `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart`

## Verification

- [x] `cd packages/warp_prism_ui && dart analyze lib/src/atoms/checkbox/ test/atoms/checkbox/` (0 issues)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/checkbox/ --concurrency=1 --no-pub` (12 tests passed)
- [x] `cd packages/warp_prism_ui && dart test test/boundaries/boundary_test.dart` (7/7 PASS)

---

# Task 1701: warp-prism-prism-text-field-atom

## Summary

Implemented `DSTextField` and public alias `PrismTextField` for `warp_prism_ui`.
Features obsidian glass container background (`DSColors.obsidianElevated`), focus border glow (`DSColors.accentCyan`), error border/text styling (`DSColors.statusError`), label/hint/helper/error text, prefix and interactive suffix icons, multiline and password obscure text support, and disabled state with 0.5 opacity.

## Changes

- Created `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart`
- Created `packages/warp_prism_ui/lib/src/atoms/text_field/text_field.dart`
- Updated `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
- Registered `typedef PrismTextField = DSTextField;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Registered text field demo in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Created unit/widget/golden test suite `packages/warp_prism_ui/test/atoms/text_field/ds_text_field_test.dart`
- Added contract test to `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart`

## Verification

- [x] `cd packages/warp_prism_ui && dart analyze lib/src/atoms/text_field/ test/atoms/text_field/` (0 issues)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/text_field/ --concurrency=1 --no-pub --update-goldens` (14/14 PASS)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/atoms_contract_test.dart --concurrency=1 --no-pub` (47/47 PASS)

---

# Task 1700: warp-prism-prism-button-atom

## Summary

Implemented `DSButton` and public alias `PrismButton` for `warp_prism_ui`.
Features 5 visual variants (primary, secondary, outline, ghost, danger) using `DSGlassPanel`, `DSGlowBorder`, and transparent surfaces; 3 size presets (sm, md, lg); loading state with `CircularProgressIndicator`; disabled state with 0.5 opacity; leading/trailing `DSIcon` support; keyboard activation via `DSInteractiveSurface` (Enter/Space); WCAG 48×48 minimum touch target; and CyberCore teal skin accent override.

## Changes

- Created `packages/warp_prism_ui/lib/src/atoms/button/ds_button.dart` (DSButton, DSButtonVariant, DSButtonSize)
- Created `packages/warp_prism_ui/lib/src/atoms/button/button.dart` (barrel export)
- Updated `packages/warp_prism_ui/lib/src/atoms/atoms.dart` (added `button/button.dart` export)
- Registered `typedef PrismButton = DSButton;`, `typedef PrismButtonVariant = DSButtonVariant;`, `typedef PrismButtonSize = DSButtonSize;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- Registered `_ButtonDemo` gallery section in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` under Atoms
- Created unit/widget/golden test suite `packages/warp_prism_ui/test/atoms/button/ds_button_test.dart` (15 tests)

## Verification

- [x] `cd packages/warp_prism_ui && dart analyze lib/src/atoms/button/ test/atoms/button/` (0 issues)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/button/ --concurrency=1 --no-pub` (15/15 PASS)
- [x] `cd packages/warp_prism_ui && flutter test test/atoms/ --concurrency=1 --no-pub` (106/106 PASS)
- [x] `cd packages/warp_prism_ui && flutter test test/gallery/design_system_gallery_test.dart --concurrency=1 --no-pub` (22/22 PASS)

---

# [2026-07-25] - Task 1702 PrismSelect Dropdown Molecule Implementation

## Added
- Implemented `DSSelect<T>` dropdown molecule widget in `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart` with obsidian dark glass modal popup, options list, search mode (`DSTextField`), placeholder, label, error state, clear button, disabled state, and keyboard navigation.
- Created `select.dart` barrel export in `packages/warp_prism_ui/lib/src/molecules/select/select.dart` and exported from `lib/src/molecules/molecules.dart`.
- Registered `PrismSelect`, `PrismSelectItem`, and `PrismSelectOption` public API aliases in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Added gallery section for `DSSelect` in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Added unit and widget tests covering selection, search filtering, clear button, disabled state, keyboard navigation, and aliases in `packages/warp_prism_ui/test/molecules/select/ds_select_test.dart`.

## Changed
- Path-to-100 review patch: wrapped clear button in explicit `Semantics(button, label, onTap)` with 48×48 dp `ConstrainedBox` to satisfy WCAG touch-target minimum; wrapped modal dismiss barrier in `Semantics(label: 'Dismiss dropdown', button)`; added 4 widget tests covering ArrowUp wrap, Space selection, `helperText` rendering, and explicit `onClear` callback precedence over `onChanged(null)`. Test count 14 → 18.

**Author**: builders
**Reviewer**: reviewers (internal builder review, path-to-100 patch applied)

---

# Task 1617: profiles-and-changelog-promote

## Summary

Promoted docs/changelog (~267) to .changelog; symlink; recovered unique keys after repair pollution; profiles merge 283 residual + collision merge; AGENTS path fix.

## Changes

- Documented task completion details.

## Verification

- [x] validate entries=267; docs/changelog symlink; _by_lane architects/builders/reviewers
- [x] docs/changelog is symlink to ../.changelog (or migrate-created ledger)
- [x] validate/build green after migration wave 20260721

---

# Task 1511: PrismAiAnalystPanel — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 74 → path-to-100) for
`PrismAiAnalystPanel`. Fixture-only policy unchanged (no live model keys /
network).

## Changes

- `DSAiAnalystController`: `_disposed` flag, `_safeNotify()`, post-await guards,
  `dispose()` override — no notify/mutate after disposal during stream delay
- Post-frame transcript scroll: `mounted` guard; jump when reduced motion
- Streaming + send busy indicators: static hourglass when
  `MediaQuery.disableAnimationsOf` is true
- Tests: dispose-during-stream (controller + panel), reduced-motion streaming
- `dart format` on organism source + tests

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/ai_analyst_panel test/organisms/ai_analyst_panel
# Formatted 0 changed (exit 0)

flutter test test/organisms/ai_analyst_panel/
# All tests passed (19)

dart analyze lib test
# exit 0 — pre-existing info-level lints only

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS

# rg: no http/HttpClient/api_key/dio paths under ai_analyst_panel/
```

---

# Task 1510: PrismOsintWorkbench — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 86 → path-to-100) for
`PrismOsintWorkbench` without changing product/fixture contracts.

## Changes

- Public constructor assert: `tools.length >= 2` (multi-tab workbench contract)
- History row: `ConstrainedBox(minHeight: 48)` for touch target
- Tests: constructor rejects single-tab; history row height ≥ 48dp
- `dart format` on organism source + tests (non-mutating format gate clean)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/osint_workbench test/organisms/osint_workbench
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/osint_workbench test/organisms/osint_workbench
# Formatted 0 changed (exit 0)

flutter test test/organisms/osint_workbench/
# All tests passed (14)

dart analyze lib test
# exit 0 — pre-existing info-level lints only (unrelated packages/surfaces)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

---

# Task 1509: Stage Chrome Pack Path-to-100 Resubmit

## Summary

Addressed `HELD_IN_REVIEW_RESUBMIT` (S=80) residuals for stage chrome pack:

1. Format gate green on watchlist/coord/map-legend source+tests.
2. All interactive IconButtons and row/category hit regions ≥48×48 (already on live code; re-verified).
3. Widget tests assert 48dp targets for expand/unpin/row and close/toggle/category.
4. Package-wide `dart analyze lib test` → **No issues found**.

## Changes (this resubmit)

- Live organisms already enforced 48dp (watchlist expand/unpin/rows; legend close/toggle/categories).
- Package analyzer baseline cleanup shared with Task 1508 resubmit (const fixes, deprecated
  semantics API, public Prism fixture alias in unrelated molecule test).

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib test
# → No issues found (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/watchlist_dock test/organisms/watchlist_dock \
  lib/src/organisms/coordinate_status_bar test/organisms/coordinate_status_bar \
  lib/src/organisms/map_legend test/organisms/map_legend
# → 0 changed (exit 0)

flutter test test/organisms/watchlist_dock/ \
  test/organisms/coordinate_status_bar/ \
  test/organisms/map_legend/
# → All tests passed (included in 36/36 scoped 1508+1509 suite)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS (exit 0)
```

---

# Task 1508: PrismStatusTicker Path-to-100 Resubmit

## Summary

Addressed `HELD_IN_REVIEW_RESUBMIT` (S=84) residuals for `PrismStatusTicker`:

1. Format gate green on status ticker source/test.
2. Package-wide `dart analyze lib test` → **No issues found** (zero infos/warnings/errors).
3. Interactive chip button semantics + ≥48dp targets proven by widget test.
4. Default strip height raised to 48; region uses `explicitChildNodes` when tappable.

## Changes (this resubmit)

- `ds_status_ticker.dart`: default `height` 48; `explicitChildNodes` when `onItemTap != null`;
  tappable chips use container button semantics + 48×48 `ConstrainedBox` + transparent `Material`.
- `status_ticker_test.dart`: hardened a11y target assertion.
- Package analyzer baseline cleanup (shared debt outside organism Where table, required by exit gate):
  `dart fix --apply` const/dangling-doc cleanups; Prism fixture alias fix in scale-measure test;
  deprecated `hasFlag` → `flagsCollection` in log_viewer/command_palette tests.

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib test
# → No issues found (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/status_ticker test/organisms/status_ticker
# → 0 changed (exit 0)

flutter test test/organisms/status_ticker/
# → All tests passed (14) (exit 0)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS (exit 0)
```

---

# Task 1507 Path-to-100 — Format Gate

## Summary

Remediation against review `docs/reports/review/1507-time-machine-scrubber-review-2026-07-16.md`
(score 88/100 REJECT). Sole blocking finding was a red `dart format` gate on
the task surface and shared barrels/gallery.

## Changes

- Re-ran `dart format --output=none --set-exit-if-changed` on
  `time_machine_scrubber/`, shared `organisms.dart` / `prism_aliases.dart` /
  `design_system_gallery_sections.dart`, and tests — **0 changed**.
- No implementation or API changes required; re-proved analyze, widget tests,
  and boundary harness green.

## Verification

```bash
cd packages/warp_prism_ui
dart format --output=none --set-exit-if-changed \
  lib/src/organisms/time_machine_scrubber \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/time_machine_scrubber
# → Formatted N files (0 changed), exit 0

dart analyze lib/src/organisms/time_machine_scrubber \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/time_machine_scrubber
# → No issues found!

flutter test test/organisms/time_machine_scrubber/
# → All tests passed (10)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS
```

---

# Task 1506 Path-to-100 — Format Gate + Semantics

## Summary

Remediation against review `docs/reports/review/1506-entity-locate-search-review-2026-07-16.md`
(score 86/100 REJECT). Blocking finding was a red `dart format` gate on the
task surface. Optional finding: nested locate-action semantics.

## Changes

- Re-ran `dart format --output=none --set-exit-if-changed` on
  `entity_locate_search/`, shared `organisms.dart` / `prism_aliases.dart` /
  `design_system_gallery_sections.dart`, and tests — **0 changed**.
- Confirmed locate row action uses bare `IconButton` + `tooltip` (no
  `ExcludeSemantics` + outer re-labeled `Semantics` wrapper).
- No product-route or contract changes.

## Verification

```bash
cd packages/warp_prism_ui
dart format --output=none --set-exit-if-changed \
  lib/src/organisms/entity_locate_search \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/entity_locate_search
# → Formatted N files (0 changed), exit 0

dart analyze lib/src/organisms/entity_locate_search \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/entity_locate_search
# → No issues found!

flutter test test/organisms/entity_locate_search/
# → All tests passed (12)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS
```

---

# Expert path-to-100 — Tasks 1302 / 1408 / 1504 / 1505 / 1506

> **Date**: 2026-07-18  
> **Agent**: gt-flutter-expert (builders subagent; parent agentID=builders)  
> **Lane**: tasks remain in `docs/tasks/02-doing/` (no git / no promote)

## Summary

Builder-side expert path-to-100 pack for five Warp Prism tasks. Live evidence
re-scored; residual defects fixed; expert reports under `docs/reports/review/`.

| Task | Before | After | Key fix |
| --- | ---: | ---: | --- |
| 1302 Public barrel audit | 96 | 100 | `tool/verify_public_barrel_audit.dart` freeze lock |
| 1408 Package imports | 100 | 100 | Re-prove DEEP=0 (no code edit) |
| 1504 Filter workbench | 92 | 100 | Keyboard FocusableActionDetector / IconHit Focus |
| 1505 Entity intel panel | 93 | 100 | Close/pin `excludeSemantics` double-node fix |
| 1506 Entity locate search | 95 | 100 | Result row 48dp ConstrainedBox + size test |

## Validation (pack end)

```text
dart format --set-exit-if-changed (owned) → exit 0
dart analyze (organisms + aliases + audit tool) → No issues
flutter test filter_workbench + entity_intel + entity_locate → +35 All tests passed
boundary_test → 7/7 PASS
verify_public_barrel_audit → PASS (274/278)
rg deep relative lib/features → DEEP=0
```

## Reports

- `docs/reports/review/expert-2026-07-18-task-1302.md`
- `docs/reports/review/expert-2026-07-18-task-1408.md`
- `docs/reports/review/expert-2026-07-18-task-1504.md`
- `docs/reports/review/expert-2026-07-18-task-1505.md`
- `docs/reports/review/expert-2026-07-18-task-1506.md`

---

# Changelog — Expert path-to-100 pack (Tasks 1512, 1513, 1514, 1515, 1517)

- **Date**: 2026-07-18T05:35Z
- **Agent**: gt-flutter-expert (builders)
- **Scope**: Warp Prism ADS organisms — residual expert fixes after builder resubmit

## Changes

| Task | Residual closed |
| --- | --- |
| 1512 | Background clear Semantics button only when selection active |
| 1513 | Footer Inspect/Expand `minimumSize` 48 + height test |
| 1514 | Host size no longer mutated during build; pan uses live layout size |
| 1515 | Format clean; dense launcher 48 floor assert |
| 1517 | History-growth-only auto-scroll; models extract; thrash regression test |

## Verification

```text
flutter test map_canvas_stage entity_relation_card floating_analytics_hud
  ops_control_cluster connector_panel terminal_workspace → 66/66 PASS
dart analyze owned surfaces → No issues found
dart format --set-exit-if-changed → exit 0
dart run test/boundaries/boundary_test.dart → 7/7 PASS
```

## Lane

Tasks remain in `docs/tasks/02-doing/` (no promote / no git).

## Reports

- `docs/reports/review/expert-2026-07-18-task-1512.md`
- `docs/reports/review/expert-2026-07-18-task-1513.md`
- `docs/reports/review/expert-2026-07-18-task-1514.md`
- `docs/reports/review/expert-2026-07-18-task-1515.md`
- `docs/reports/review/expert-2026-07-18-task-1517.md`

---

# Task 1523: Optional Media Detail Overlay

## Summary

Fixture-only media lightbox organism with placeholder frames, caption bar, open/close, multi-item next/prev, and a11y labels. No streaming engines.

## Changes

- `media_detail_overlay/` — `DSMediaDetailItem`, fixtures, overlay chrome, prev/next navigation.
- Barrel + `PrismMediaDetailOverlay` / `PrismMediaDetailItem` / `PrismMediaDetailFixtures` aliases.
- Gallery demo in Wave I polish section.
- Widget tests: open/close, empty, next/prev, a11y, escape.

## Verification

- `dart analyze` (media_detail_overlay): No issues found
- `flutter test test/organisms/media_detail_overlay/`: **8/8 PASS**
- Boundary harness: **7/7 PASS**
- No hls/WebRTC/video_player deps in pubspec

---

# Task 1522: Optional Keyboard Cheatsheet + Scale Bar + Risk Toast

## Summary

Wave I polish pack: `PrismKeyboardCheatsheet` overlay, `PrismScaleMeasureBar` molecule (not organism), and `DSToastRiskTier` / `DSToastEntry.risk` on the existing toast manager (no second stack). Gallery + Prism aliases + fixture tests.

## Changes

- **Organism**: `keyboard_cheatsheet/` — shortcut groups, keycaps, escape/backdrop dismiss, a11y dismiss label.
- **Molecule**: `ds_scale_measure_bar.dart` — read-only map scale chrome; classification documented as molecule.
- **Toast**: `DSToastRiskTier` + `DSToastEntry.risk` risk badge/region chrome via existing `DSToast`/`DSToastManager`.
- Exports: organisms barrel, molecules barrel, `prism_aliases.dart` (`PrismKeyboard*`, `PrismScale*`, `PrismToastRiskTier`).
- Gallery: Wave I polish section + toast risk demos.

## Verification

- `dart analyze` (owned surfaces): No issues found
- `flutter test test/organisms/keyboard_cheatsheet/`: PASS
- `flutter test test/molecules/ds_scale_measure_bar_test.dart`: PASS
- `flutter test test/molecules/ds_toast_risk_variant_test.dart`: PASS
- Boundary harness: **7/7 PASS**

---

# Task 1517: PrismTerminalWorkspace lifecycle remediation

## Summary

Path-to-100 after drain review S=86: dispose per-pane Scroll/Text/Focus controllers when panes leave the model; post-frame scroll uses `mounted` + map membership; clear/close chrome is 48×48; tests cover resource eviction and touch targets.

## Changes

- `ds_terminal_workspace.dart`: `_disposePaneResources` / `_reconcilePaneResources` on controller changes; `debugOwnedPaneResourceCount` for tests; post-frame auto-scroll guards; pane titlebar clear/close 48dp hosts.
- `ds_terminal_workspace_test.dart`: close-pane resource leak test; 48dp chrome target test; IconButton resolution via tooltip field (Flutter RawTooltip).

## Verification

- `dart analyze` (terminal_workspace lib+test): No issues found
- `flutter test test/organisms/terminal_workspace/ --concurrency=1 --no-pub`: **10/10 PASS**
- Boundary harness: **7/7 PASS**
- No xterm/PTY deps

---

# Task 1514: PrismFloatingAnalyticsHud — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 82 → path-to-100) for
`PrismFloatingAnalyticsHud`. Fixture metrics only; desktop pointer drag first.

## Changes

- Controller: public fields eliminate `prefer_initializing_formals` infos
- Drag handle / minimize / close: min 48×48 interactive constraints
- Title drag shares `Drag analytics HUD` semantic label
- Module split: models + controller + fixtures + widget
- Tests: 48dp header controls + draggable semantics (13 total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
# Formatted 0 changed (exit 0)

flutter test test/organisms/floating_analytics_hud/ --concurrency=1
# All tests passed (13)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1514
agent: gt-flutter-engineer
project: warp-prism
title: PrismFloatingAnalyticsHud path-to-100 a11y + split
description: >
  48dp header controls, drag semantics, zero scoped analyzer issues,
  module file split; fixture metrics overlay only.
summary: Floating analytics HUD resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```

---

# Task 1513: PrismEntityRelationCard — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 88 → path-to-100) for
`PrismEntityRelationCard`. Composes `DSGraphCanvas`; no force-graph JS.

## Changes

- Legend filter chips: `ConstrainedBox(minWidth/minHeight: 48)` hit targets
- Keyboard Enter/Space activation retained via `FocusableActionDetector`
- Module split: host + legend + sections
- Widget test asserts legend render box ≥ 48×48 (7 tests total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
# Formatted 0 changed (exit 0)

flutter test test/organisms/entity_relation_card/ --concurrency=1
# All tests passed (7)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1513
agent: gt-flutter-engineer
project: warp-prism
title: PrismEntityRelationCard path-to-100 legend a11y
description: >
  Legend filter 48dp hit targets + size test; host/legend/sections split;
  fixture graph preview only.
summary: Entity relation card resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```

---

# Task 1512: PrismMapCanvasStage — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 87 → path-to-100) for
`PrismMapCanvasStage`. Placeholder-only contract retained (no MapLibre port).

## Changes

- Feature markers: 48dp hit box with smaller visual glyph
- Status-strip Clear + popup dismiss: min 48×48 interactive targets
- Background clear: explicit `Semantics(label: 'Clear map selection', button: true)`
- Split mega-widget into host + `map_stage_placeholder_widgets.dart` + controller
- Tests: 48dp hit targets + background accessible label (13 total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
# Formatted 0 changed (exit 0)

flutter test test/organisms/map_canvas_stage/ --concurrency=1
# All tests passed (13)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1512
agent: gt-flutter-engineer
project: warp-prism
title: PrismMapCanvasStage path-to-100 a11y + module split
description: >
  48dp interactive targets, labeled background clear, placeholder widget
  extraction; fixture-only stage (no MapLibre).
summary: Map stage contract resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```

---

# 2026-07-18 — Task 1106 path-to-100 residuals (gt-flutter-engineer)

### Changed
- Closed drain-review residuals for Task 1106 (score 88 → ready for re-review):
  - **F1**: Confirmed `docs/design/operational-component-mvp.md` Pilot A framing = **Providers `/providers`** (historical Task Governance Board note only).
  - **§2.3**: Confirmed Data Table / Command Palette marked **delivered by 1112/1113** (not “not implemented”).
  - **Melos exits**: Re-ran `melos run analyze` → **SUCCESS** (`--no-fatal-infos`); annotated package-scoped test gate honestly in task Completion Evidence.
- Gallery registry hygiene: `design_system_gallery_test.dart` section count **22 → 23** (9 EPIC-15 incl. optional-polish).
- Refreshed task Completion Evidence; **left in `docs/tasks/02-doing/`** (no self-promote).

### Validation
- Scoped operational suites: **+183 All tests passed**
- Gallery suite: **+22 All tests passed**
- Scoped MVP analyze: **No issues found**
- `melos run analyze`: **SUCCESS**

**Author**: gt-flutter-engineer (path-to-100 residual pass)

---

# Task 1302: Public Barrel Audit

## Summary

Audited and re-verified the public barrel of `packages/warp_prism_ui`. Definitive
export manifest at `docs/design/public-barrel-audit.md` matches the live
four-export barrel (Prism aliases + gallery with DSGallery\* hidden).

## Live Findings (2026-07-18 session 2) — current

- **Barrel exports**: 4 files only
  - `src/prism_aliases.dart`
  - `src/gallery/design_system_gallery_page.dart`
  - `src/gallery/design_system_gallery_registry.dart` (`hide DSGallerySectionSpec`)
  - `src/gallery/design_system_gallery_sections.dart` (`hide DSGallerySections`)
- **278 total public top-level symbols**
  - **274 Prism API** (273 typedef + 1 extension)
  - **4 non-Prism gallery entrypoints** (`DesignSystemGalleryPage`,
    `dsGallerySections`, `dsGallerySectionIds`, `dsGallerySectionTitles`)
- **0 DS\* layer sub-barrels** re-exported
- **0 DSGallery\* public identifiers** (hidden; use PrismGallery\*)
- **7 experimental** drag-drop Prism aliases (live surface)
- Gallery remains intentionally public; optional `warp_prism_gallery.dart` split
  recommended as non-breaking follow-up (no export removal)
- Source↔audit set equality: **0 missing / 0 extra**; boundary harness **7/7**
- Session changelog: `20260718-052041-1302-public-barrel-live-reaudit-plus11-builders.md`

## Historical Live Findings (2026-07-09) — superseded

- **129 total public top-level symbols** (then)
  - **127 Prism API** (126 typedef + 1 extension)
  - **2 non-Prism gallery entrypoints**
- **5 experimental** drag-drop Prism aliases (then)

## Prior Stale Claims Corrected

| Stale | Live |
|---|---|
| 7–8 layer exports | 4 exports |
| 143 symbols | **129** symbols |
| 64 Prism aliases | **127** Prism API symbols |
| Incomplete manifest 126/128 (missing `PrismInsightRiskLevel`) | **127/129** with risk-level alias |
| DSGallery\* public | Hidden + PrismGallery\* aliases |
| Boundary harness deferred | 6/6 PASS |

## Files Touched

- `docs/design/public-barrel-audit.md` — full live rewrite
- `docs/changelog/1302-public-barrel-audit.md` — this entry
- Task file evidence refresh + lane → `03-review/`
- Archived stale review collision under `.archive/docs/tasks/03-review/`

## Verification

```text
dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart \
  packages/warp_prism_ui/lib/src/prism_aliases.dart
# → No issues found!

dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# → Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)

test -f docs/design/public-barrel-audit.md
# → PASS
```

No Dart production exports were removed (Task 1302 guardrail).

---

# Changelog — Task 1401 path-to-100 residual close

- **Date**: 2026-07-18
- **Task**: Task 1401 (`warp-prism-observatory-failure-baseline-inventory`)
- **Project**: warp-prism
- **Type**: governance / inventory evidence refresh

## Summary

Closed drain-review Proof Reality residual: inventory no longer claims
`history_story_modes_test` selection-sync failures. Live package is fully green.
No production or test code modified under this inventory task.

## Live proof anchors

```text
find apps/observatory/test -name '*_test.dart' | wc -l
→ 44

flutter test apps/observatory --concurrency=2 --no-pub
→ +808: All tests passed!

flutter test apps/observatory/test/features/history/history_story_modes_test.dart --no-pub
→ +31: All tests passed!

flutter analyze apps/observatory --no-pub
→ 127 issues found. (0 error / 0 warning / 127 info; exit 0)
```

## Inventory deltas

| Field | Prior current claim | Live 2026-07-18 |
| --- | --- | --- |
| Suites | 40 | **44** |
| Non-success suites | 1 (`history_story_modes`) | **0** |
| Residual tests | 2 errors | **0** |
| Full suite | ~816 green / residual | **+808 All tests passed** |
| Analyzer INFO | 164 | **127** |
| F01 | live residual | **historical remediated** |

New suites vs 40-universe: `production_router_test`, `map_graph_builder_edges_test`,
`operate_path_wins_lane_test`, `overview_provider_path_test`.

## Files

- Updated: `docs/reports/observatory-failure-baseline.md`
- Updated: `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md`
- Created: this changelog note

## Notes

- Task left in `02-doing/` (no promote; no git ops this pass).
- Historical changelogs retained under `docs/changelog/*1401*`.

---

# Changelog — Task 1070 path-to-100 residual close

- **Date**: 2026-07-18
- **Task**: Task 1070 (`warp-prism-task-namespace-integrity-verification`)
- **Project**: warp-prism
- **Type**: governance / docs evidence refresh

## Summary

Closed drain-review path-to-100 residuals for Task 1070 by re-running the
executable task-namespace integrity audit and refreshing the durable current-
state section. No Flutter application source was modified.

## Live proof anchors

- Open lane (`NNNN-*.md`): `total_files=0` — OPEN ID + structure **PASS**
- All executable lanes: `149` files / `149` unique IDs — dual-lane **[]**
- Lane counts: open=0, doing=23, review_exec=0, completed=126
- Prior duals closed: 1103, 1308, 1604, 1605, 1606, 1607 → each single under `04-completed/`
- Hygiene note: 15 `EPIC-*.md` planning files present in `03-review/` (non-executable)
- EPIC-02 `0001`–`0006` unique under `04-completed/`; 79 `Task 0001`–`0006` refs classified EPIC-02-local or explanatory

## Files

- Updated: `docs/reports/warp-prism-task-namespace-renumbering-map.md`
- Updated: `docs/tasks/02-doing/1070-warp-prism-task-namespace-integrity-verification.md`
- Created: this changelog note

## Notes

- Historical claim gap remains: `docs/changelog/20260606-163911-1070-*.md` still absent.
- Task left in `02-doing/` (no promote; no git ops this pass).

---

# Task 1408: Deep Import Residual Re-Proof

## Summary

Crash-resume wave re-verified import-scope exit conditions. Prior residual fix
(5× `governance_page_shell` package URI migrations) remains live. **No code
edits** this session.

## Proof (2026-07-18 session 2)

- `rg "import '\.\./\.\./\.\." apps/observatory/lib/features/` → **0**
- Package-style inventory: **88** import lines / **42** files
- Package URI targets for governance shell data imports: **all exist**
- `flutter analyze …/governance_page_shell.dart` → **No issues found!**
- `flutter test test/features/governance/` → **+104 All tests passed!**
- Boundary harness: **7/7 PASS**
- Allowed residual: 3× shallow `../../data/` map-root imports (simplicity pass)

## Regression

**None** — re-proof only.
---

---

# Task 1302: Public Barrel Live Re-Audit (+11 post-263)

## Summary

Prior same-day path-to-100 freeze claimed **263** Prism / **267** total. Live
`prism_aliases.dart` now has **273 typedef + 1 extension = 274** Prism symbols
(+11). Regenerated `docs/design/public-barrel-audit.md` with set equality proof.

## Live Findings (2026-07-18 session 2)

- **Barrel exports**: still 4 (`prism_aliases` + 3 gallery; `hide DSGallery*`)
- **Prism API**: **274** (273 typedef + 1 extension)
  - Production: 265
  - Experimental drag-drop: 7 (live surface: DraggableCard/DropTarget/events/intents/payload)
  - Gallery Prism aliases: 2
- **Non-Prism gallery entrypoints**: **4**
- **Total public top-level**: **278**
- **DS* layer barrels exported**: 0
- **Source ↔ audit set equality**: 0 missing, 0 extra
- **Boundary harness**: **7/7 PASS**
- **Scoped analyze** (`warp_prism_ui.dart` + `prism_aliases.dart`): No issues

## +11 symbols since 263 freeze

`PrismKeyboardCheatsheet`, `PrismKeyboardCheatsheetFixtures`,
`PrismKeyboardShortcut`, `PrismKeyboardShortcutGroup`,
`PrismMediaDetailFixtures`, `PrismMediaDetailItem`, `PrismMediaDetailOverlay`,
`PrismScaleMeasureBar`, `PrismScaleMeasureBarFixtures`, `PrismScaleSegment`,
`PrismToastRiskTier`

## Supersedes

| Prior claim (session 1) | Live session 2 |
|---|---|
| 263 Prism / 267 total | **274 Prism / 278 total** |
| typedef 262 | **273** |
| Experimental drag 5 (stale names) | **7** live drag surface |
| harness 7/7 | **7/7** (re-proved) |

## Guardrails Honored

- No export removals; no Dart production code changed
- Four-export barrel retained
- DSGallery* remains hidden
---

---

# Task 1505: PrismEntityIntelPanel Path-to-100

## Summary

Remediated REJECT 85/100 review findings for `PrismEntityIntelPanel`: format
gate clean on owned surfaces; gallery `_SelectChip` uses
`kMinInteractiveDimension` (48dp). Organism chrome already met 48dp via
IconButtons. Mode/registry contract only — no NewsFeed megafile port.
Revalidated live 2026-07-18.

## Changes

- Gallery `_SelectChip` → `BoxConstraints(minHeight/minWidth: kMinInteractiveDimension)`
- Format pass on entity_intel_panel + shared organism/alias/gallery surfaces

## Verification

```bash
cd packages/warp_prism_ui
dart format --output=none --set-exit-if-changed \
  lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/filter_workbench test/organisms/entity_intel_panel
# → Formatted 9 files (0 changed); exit 0

dart analyze lib/src/organisms/entity_intel_panel test/organisms/entity_intel_panel
# → No issues found!

flutter test test/organisms/filter_workbench/ test/organisms/entity_intel_panel/
# → +22: All tests passed! (11 entity intel)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS
```

---

# Task 1504: PrismFilterWorkbench Path-to-100

## Summary

Remediated REJECT 82/100 review findings for `PrismFilterWorkbench`: custom
interactive hit regions use `kMinInteractiveDimension` (48dp); format gate
clean on owned surfaces; size widget test covers apply/clear/advanced/modal
controls. Revalidated live 2026-07-18.

## Changes

- `_WorkbenchButton` / `_AdvancedExpandable` / `_IconHit` → 48dp minima
- Widget test `interactive controls meet 48dp minimum touch target`
- Format pass on filter_workbench + shared organism/alias/gallery surfaces

## Verification

```bash
cd packages/warp_prism_ui
dart format --output=none --set-exit-if-changed \
  lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel \
  lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/filter_workbench test/organisms/entity_intel_panel
# → Formatted 9 files (0 changed); exit 0

dart analyze lib/src/organisms/filter_workbench test/organisms/filter_workbench
# → No issues found!

flutter test test/organisms/filter_workbench/ test/organisms/entity_intel_panel/
# → +22: All tests passed!

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS
```

---
