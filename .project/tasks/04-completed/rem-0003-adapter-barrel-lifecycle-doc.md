# rem-0003: adapter_frb barrel lifecycle declaration (D2)

> **Remediation namespace**: `rem-NNNN` (overnight remediation wave 1; independent numbering). Source finding: Inv-1 (`ses_ed6d99da3ffeqPghq5y9Hovbpc`) Gap 4 (discrepancy D2, confirmed unchanged).
> **Review State**: `Review Approved`
> **Priority**: ⚪ P3 | **Type**: `remediation` | **Origin**: architect investigation
> **Blocks**: N/A | **Depends on**: N/A (doc-comment only; zero test contention — grep validation)
> **parallel-safe**: yes — single 7-line barrel file, no test execution required

---

## Review Trail

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_ed6b7af4bffeNeNMY2sRAiTKmk` (independent)
- **Verdict**: PASS (96/100 diagnostic) — 2026-10-11
- **Re-verified**: line-1 grep hit byte-identical to three sibling barrels; diff 1 insertion, 0 deletions, single file; no annotation/export change.
- **Promotion**: Review Approved → 04-completed by governance owner.

## Milestone Alignment

- **Target milestone**: N/A (remediation).
- **Capability / Gate advanced**: barrel-level lifecycle uniformity (every sibling barrel declares stage; adapter barrel is silent).
- **Strategic why**: per-symbol EXPERIMENTAL is satisfied; the barrel — the first file any consumer/reader opens — states nothing.
- **Consequence if absent**: trivial individually; collectively barrel silence erodes the lifecycle-declaration discipline.

---

## Objective

Add the `Lifecycle: EXPERIMENTAL` declaration to `packages/warp_prism_adapter_frb/lib/warp_prism_adapter_frb.dart` barrel, conservative option: doc-comment block only (no annotation-semantics risk at barrel scope), matching the wording convention of the sibling barrels (`warp_prism_runtime.dart:10`, `warp_prism_bindings.dart:15`, `warp_prism_testkit.dart:9`).

## Background Context

### What already exists

- Barrel: 7 lines (`library` + 5 plain exports), no lifecycle text (Inv-1 G4 verified).
- Per-file EXPERIMENTAL: `adapter_init.dart:7–8`, `frb_event_stream.dart`, `frb_graph_source.dart:7–8`, `frb_health_source.dart:7–8`, `frb_async_command.dart:88–98`.
- Sibling barrel convention: `/// Lifecycle: EXPERIMENTAL` doc-comment line.

### What is missing or broken

- One doc-comment block on the barrel. Nothing else.

---

## Test Requirements

- `grep -n "Lifecycle:"` on the barrel returns ≥1 hit.
- Wording matches sibling convention (no invented stage vocabulary).
- No other line of the barrel changed (diff shows comment-block addition only).

## Exit Conditions

- [ ] Doc-comment lifecycle block added; diff confined to the addition.
- [ ] Grep validation passes.
- [ ] Local changelog entry added under `.project/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: the 7-line barrel + one sibling barrel (wording convention).
- [ ] Add the doc-comment block (comment only — no annotation, no export changes).
- [ ] **Simplicity pass**: nothing else touched.
- [ ] **Regression verification**: grep validation + `git diff --stat` shows 1 file, addition-only.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_adapter_frb/lib/warp_prism_adapter_frb.dart` | Modify — doc-comment addition (only file) |
| `packages/warp_prism_runtime/lib/warp_prism_runtime.dart` | Read — wording convention |
| `.project/changelog/` | Create — entry |

### How

1. Copy the sibling wording exactly (stage + one-line meaning); do not paraphrase the lifecycle vocabulary.
2. Verify the diff is addition-only before claiming done.

### Why

Smallest uniformity fix in the inventory; keeps the barrel-declaration discipline total across all seven packages.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Comment only. No annotation, no export, no rewording of the lifecycle vocabulary. One file.

---

## Validation Commands

```bash
grep -n "Lifecycle:" packages/warp_prism_adapter_frb/lib/warp_prism_adapter_frb.dart
git diff --stat -- packages/warp_prism_adapter_frb/lib/warp_prism_adapter_frb.dart
```

No test execution required; no contention possible. Record tooling issues literally.

---

## Completion Evidence

- **Files created/modified**: `packages/warp_prism_adapter_frb/lib/warp_prism_adapter_frb.dart` (+1 line, doc-comment only)
- **Tests or validation commands**: `grep -n "Lifecycle:"` → 1 hit (line 1); `git diff --stat` → 1 file, 1 insertion(+), 0 deletions — PASS
- **Local changelog entry**: `.project/changelog/20261011-014551-rem-0003-adapter-barrel-lifecycle-doc-remediation-executed-architects-lane.md` (342 entries valid)
- **Executor**: architects-lane root (tiny-unblocker: 1-line doc comment, delegation overhead exceeded work)
- **Completion date**: 2026-10-11
