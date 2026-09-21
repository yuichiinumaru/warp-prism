# Task 1830: Boundary Checks 16 + 17 Activation

> **Priority**: 🟡 P1 · **Type**: `governance`
> **Origin**: Task 1825 Part 7 exception policy (activation triggers now satisfied) + layer-contracts-v2 §5.1 (checks 16/17 PHASED → triggers present)
> **Blocks**: none (closes the boundary enforcement surface)
> **Depends on**: Task 1825 (L1 gate PASS) + Part 7 exception policy

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: full boundary enforcement — checks 16/17 are the last PHASED rows; their triggers (v2 packages exist, FRB codegen pipeline established) are satisfied since 1823/1825.
- **Strategic why**: the 1825 exception policy (Part 7) is conditional — the honest close is activating the checks with the documented allowlist, not leaving them as advisory forever.
- **Consequence if absent**: boundary enforcement stays at 13 checks with a documented-but-inactive exception; reviewers must keep hand-verifying domain leakage and generated-surface import discipline.

## Objective

Activate boundary checks 16 (core packages contain no domain types, with the documented teal-skin allowlist per 1825 Part 7) and 17 (FRB generated files not imported directly by widgets) in `boundary_test.dart` → harness 15/15.

## Scope

- Read 1825 report Part 7 (the exception policy to mechanize) + layer-contracts-v2 §5.1 rows 16/17 + the existing check pattern.
- Check 16: scan `{interaction,runtime,bindings,testkit,adapter_frb}/lib/` (NOT warp_prism_ui — the teal skin is a sanctioned ui-local L0 visual extension; the v2 semantic packages are the protected surface) for domain tokens (Ganthritor|Cersei|OmniRoute|CyberCore, word-boundary matched to avoid the teal-skin class-name false positive — the classes live in ui, out of scan scope).
- Check 17: scan `apps/*/lib/` + `packages/*/lib/` (excluding the adapter itself) for direct imports of the FRB generated surface (`lib/src/rust/` paths or `frb_generated`) — widgets/apps must consume the adapter barrel, never generated internals.
- Append-only to boundary_test.dart, no count assertions.
- Update layer-contracts-v2 §5.1: rows 16/17 PHASED → ENFORCED NOW (with the check-16 scope note).
- Run everything: 15/15.

## Validation Commands

```bash
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .   # 15/15 PASS
grep -c "ENFORCED NOW" docs/architecture/layer-contracts-v2.md   # rows 16/17 updated
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Extend — checks 16 + 17 |
| `docs/architecture/layer-contracts-v2.md` | Update — §5.1 rows 16/17 status |

## Exit Conditions

- [x] Check 16 active with the documented v2-packages scope (teal skin out of scan surface, word-boundary matching).
- [x] Check 17 active (no direct generated-surface imports outside the adapter).
- [x] Boundary harness 15/15 PASS.
- [x] layer-contracts-v2 §5.1 updated to ENFORCED NOW for 16/17.
- [x] Local changelog entry proposed in packet.

## Completion Evidence

- **Files modified**: packages/warp_prism_ui/test/boundaries/boundary_test.dart (checks 16+17 appended) + docs/architecture/layer-contracts-v2.md (§5.1 rows 16/17 → ENFORCED NOW with scope notes).
- **Check 16**: scans 5 v2 semantic packages (interaction/runtime/bindings/testkit/adapter_frb — NOT ui; teal-skin sanctioned per 1825 Part 7); word-boundary regex (Ganthritor|Cersei|OmniRoute|CyberCore); dry-run 0 hits.
- **Check 17**: scans apps/*/lib + packages/*/lib excluding adapter_frb for direct generated imports (src/rust/|frb_generated); import-only regex does NOT false-positive on the legal adapter barrel; dry-run 0 hits across 8 dirs.
- **Harness**: **15/15 PASS** (13→15); dart analyze boundary_test clean.
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (2026-09-02)
- **Completion date**: 2026-09-02
- **Review trail**: bundled independent review **PASS 98/100** — scopes/regexes verified precise, no total-count assertions, append-only, barrel-import nuance confirmed, §5.1 updated. The 1825 Part 7 conditional exception policy is now mechanized — checks active, no violation found.
