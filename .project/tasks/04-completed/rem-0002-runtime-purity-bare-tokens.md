# rem-0002: Runtime purity test — bare presentation-token scan

> **Remediation namespace**: `rem-NNNN` (overnight remediation wave 1; independent numbering). Source finding: Inv-1 (`ses_ed6d99da3ffeqPghq5y9Hovbpc`) Gap 3.
> **Review State**: `Review Approved`
> **Priority**: 🟢 P2 | **Type**: `remediation` | **Origin**: architect investigation
> **Blocks**: N/A | **Depends on**: N/A (different file from rem-0001; test-resource contention protocol shared — see note)
> **parallel-safe**: file writes — yes (disjoint file); test execution — serial vs concurrent runs (retry protocol)

---

## Review Trail

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_ed6b7af4bffeNeNMY2sRAiTKmk` (independent)
- **Verdict**: PASS (88/100 diagnostic) — 2026-10-11
- **Re-verified**: +70/−0 additive; suite 3/3 green exit 0 (reviewer re-run); doc-comment suppression mechanically sound at both live `Offset` prose sites; fixture relocated to `.archive/` outside scanned `lib/`; analyze clean.
- **Recorded caveats (accepted, non-blocking)**: (a) F13 — Phase-A detection artifact not preserved; detection direction rests on builder testimony + deterministic code reasoning (no-FP direction proven); (b) F14 — trailing-`//`-comment tokens would false-positive by design (conservative; no current source triggers it).
- **Promotion**: Review Approved → 04-completed by governance owner.

## Milestone Alignment

- **Target milestone**: N/A (remediation).
- **Capability / Gate advanced**: MUST-NOT 3 enforceability ("runtime contract MUST NOT contain Flutter layout/presentation concept unless marked").
- **Strategic why**: current purity test checks only `package:flutter`/`dart:ui` *imports*; bare `Offset`/`Widget`/`BuildContext`/`Color` tokens pass silently (one file checked for `Offset` only).
- **Consequence if absent**: presentation concepts leak into contracts undetected; model/presentation separation erodes by accident.

---

## Objective

Extend `packages/warp_prism_runtime/test/purity_test.dart` with a bare-token scan for `Offset|Widget|BuildContext|Color` over non-comment runtime source (comment-stripping precedent: `boundary_isolation_test.dart:33–40`), proved by a synthetic fixture, without breaking the currently-passing suite.

## Background Context

### What already exists

- `purity_test.dart:23` — import scan (currently PASS, zero matches).
- `purity_test.dart:66,76` — presentation/polling pattern list (extension point).
- `boundary_isolation_test.dart:33–40` — `_stripComments` precedent for comment-safe token scanning.

### What is missing or broken

- No bare-token scan: a `final Offset position;` field with no Flutter import passes today.

---

## Test Requirements

- Synthetic fixture with a bare `Offset` field is detected (then reverted).
- Existing suite still green (no false positives on current source, incl. doc-comment mentions).

## Exit Conditions

- [x] Forbidden-pattern list extended (bare tokens, comment-stripped).
- [x] Fixture-proof detection demonstrated then reverted.
- [x] `dart test packages/warp_prism_runtime/test/purity_test.dart` green (or contention protocol exhausted + recorded).
- [x] Local changelog entry added under `.project/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: `purity_test.dart` (full — short file; lines ~23, ~66, ~76), `boundary_isolation_test.dart:33–40` (strip precedent).
- [x] Extend pattern list with `\b(Offset|Widget|BuildContext|Color)\b` applied to comment-stripped source.
- [x] Fixture-proof detection; revert fixture.
- [x] **Simplicity pass**: no other test behavior changed.
- [x] **Regression verification**: run purity suite; confirm green + detection worked.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_runtime/test/purity_test.dart` | Modify — pattern extension (only file touched) |
| `packages/warp_prism_bindings/test/boundary_isolation_test.dart` | Read — strip precedent |
| `.project/changelog/` | Create — entry |

### How

1. Mirror the strip-comments approach; do not invent a new scanner.
2. Verify zero false positives against current `runtime/lib` (doc-comment `Offset` mentions must not trip).
3. Fixture-proof before claiming; revert in the same change.

### Why

Import-scans prove the absence of imports, not the absence of concepts. The law bans concepts; the test must scan concepts.

---

## Contention note (test-resource lock)

Same shared `.dart_tool/` lock domain as rem-0001's validation. Retry ≤3 × 60s on lock errors; then record `BLOCKED-on-resource` with evidence. Assertion failures = FAIL.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not flag doc-comment mentions (strip first). Do not leave the fixture. Do not weaken existing patterns.

---

## Validation Commands

```bash
dart test packages/warp_prism_runtime/test/purity_test.dart
```

Record tooling unavailability literally, never as PASS.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_runtime/test/purity_test.dart` — **modified**
    (`+70/−0`; 104 → 174 lines): added `_stripComments` helper (verbatim mirror
    of the `boundary_isolation_test.dart:33–40` precedent) and a third test
    `warp_prism_runtime lib/ contains zero bare presentation tokens` scanning
    `\b(Offset|Widget|BuildContext|Color)\b` over comment-stripped source.
    Both edits were purely additive — every pre-existing line is preserved
    byte-for-byte, so no existing behavior was modified or weakened.
    (`boundary_isolation_test.dart` was read only, never written.)
  - `.project/changelog/20261011-013333-rem-0002-runtime-purity-bare-token-scan-builder-engineer.md`
    — **created**.
- **Tests or validation commands**:

  | Command | Exit | Result |
  | --- | --- | --- |
  | `dart test packages/warp_prism_runtime/test/purity_test.dart` (baseline, pre-change) | 0 | **PASS 2/2** |
  | `dart test packages/warp_prism_runtime/test/purity_test.dart` (extended, current source) | 0 | **PASS 3/3** |
  | `dart test packages/warp_prism_runtime/test/purity_test.dart` (fixture-proof Phase A — bare `Offset`) | 1 | **PASS — detection proven** |
  | `dart test packages/warp_prism_runtime/test/purity_test.dart` (fixture-proof Phase B — doc-comment mentions only) | 0 | **PASS — no false positive** |
  | `dart analyze packages/warp_prism_runtime` | 0 | **PASS — "No issues found!"** |

  No tool-lock contention: the shared `.dart_tool/` lock was free on every
  run, no retry was needed, and no BLOCKED-on-resource state was reached.

- **Fixture-proof detail** (temporary probe
  `packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart`, then
  reverted):
  - Phase A — a `final Offset position;` field with no Flutter import. Test
    failed exactly as required with
    `.../rem_0002_fixture_proof.dart matched RegExp: pattern=\b(Offset|Widget|BuildContext|Color)\b flags= near "Offset"`.
    This is precisely the hole the task describes.
  - Phase B — the same file with the bare token replaced by a plain `double`
    field while keeping doc-comment mentions (`position: Offset`, `Widget
    identity`, `BuildContext access`, `Color palette`). Test stayed green,
    proving comment-stripping suppresses documented examples rather than
    scanning prose.
  - **Revert mechanism (disclosed)**: `rm` is denied by workspace policy, so
    the fixture was removed from the live scanned tree via the canonical
    `archive` mechanism (root `AGENTS.md` §6) rather than an alias:
    `packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart` →
    `.archive/packages/warp_prism_runtime/lib/src/rem_0002_fixture_proof.dart`.
    The archive destination is outside `lib/`, so the scan cannot see it, and
    the fixture remains inspectable as evidence. Verification that the live
    tree is clean: `grep -r "rem_0002|fixture_proof|FixtureProof"
    packages/warp_prism_runtime` → zero matches.

- **False-positive check on current source**: the only two live
  `Offset` occurrences in `warp_prism_runtime/lib` are doc-comment prose
  (`graph_source_contract.dart:11`, `graph_source_models.dart:26`, each
  `` (`position: Offset`) ``) and are **pre-existing** — this task did not
  create them. Both are suppressed by the strip step; the extended suite
  reports zero violations on unchanged source.

- **Local changelog entry**:
  `.project/changelog/20261011-013333-rem-0002-runtime-purity-bare-token-scan-builder-engineer.md`

- **Executor**: builder-engineer (Flutter/Dart builder)
- **Completion date**: 2026-10-11

