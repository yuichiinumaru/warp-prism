---
date: 20261011-013333
timestamp: 20261011-013333
project: warp-prism
agent: builder-engineer
task: "rem-0002"
description: "Runtime purity test extended with a comment-stripped bare-token scan (Offset/Widget/BuildContext/Color), closing the Inv-1 Gap 3 hole where presentation concepts passed without any Flutter import"
is_rebuild_safe: true
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
