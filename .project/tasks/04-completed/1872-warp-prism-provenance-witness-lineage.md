# Task 1872: Provenance family + sealed mode + lineage strip (F-05)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S03](../stories/P0-S03-provenance-bootstrap.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-05 (I=80, seam S8) — WB-U6, CC W1-C/I-3, EV-12, Macro P0-4/C7.
> **Priority**: P0 · **Parallelizable with**: Task 1876, Task 1870 (distinct atoms/molecules; no shared writesets).

`DSProvenancePill` (`:8`,`:9-41`,`:110-127`) is canonicity-only. WB carries fingerprint+digest+`observedAtNum/Den`, `_ProvenanceStrip` SAME|DIFFER, and a SHA-256 receipt; CC carries causation grouping; Sentry carries the hash-witness request. Cheapest trust-critical presentation work in P0: small surfaces, high deception risk if unverified renders as verified.

## Outcome and boundaries

Land atom `PrismProvenanceBadge` (canonicity) + atom `PrismWitnessBadge` (opaque hash + verified/unverified/mismatched/unknown) + sealed-rendering-mode contract (sealed = absent affordances — no copy/re-verify/re-resolve actions render) + molecule `PrismLineageStrip` (SAME|DIFFER/derived-from). No hashing, fingerprinting, or verification logic in Prism — hashes arrive opaque from the consumer. EXPERIMENTAL, no barrel export.

Non-goals: hash computation/receipt signing (consumer-side); causation computation (product-local); witness-badge promotion to STABLE (waits on host proof); no STABLE promotion here.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/molecules/ds_provenance_pill.dart` | Extension base (`:8`,`:9-41`,`:110-127`) — canonicity part lives here |
| `packages/warp_prism_ui/lib/src/atoms/` | New `PrismProvenanceBadge` + `PrismWitnessBadge` homes |
| `packages/warp_prism_ui/lib/src/molecules/` | New `PrismLineageStrip` home |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task (opaque-hash rule is mechanically worth guarding) |
| `docs/bridge/command-center/prism-gap-components.md` | Causation-grouping donor — re-verify live |

## Work

- [ ] Re-verify `DSProvenancePill` gap + WB strip/receipt citations live (record INHERITED-REPORT provenance where consumer source is unreadable from this workspace).
- [ ] Implement the two atoms + lineage molecule + sealed-mode contract; conformance suite with the two trust invariants failing-first: unverified-never-verified (every non-verified witness state is visually distinct from verified), sealed-absence-of-affordance (no interactive affordance renders in sealed mode).
- [ ] Fake/reference green; determinism (hash display truncation rules fixed, no layout-dependent rendering).
- [ ] Format/analyze clean; boundary green; host proof CC + WB (backlog gate — real routes showing witnessed + sealed + lineage states).

## Success and verification

Success = both atoms + strip render all states, the two invariants are suite-proven, no verification logic leaked into Prism, MISSION §6 gates (2)(3)(4)(5 CC+WB)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/atoms packages/warp_prism_ui/lib/src/molecules
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/atoms packages/warp_prism_ui/test/molecules packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with invariant tests, two host-exercise logs, reviewer verdict.

## Context / reliance

Depends on nothing structurally (consumes 1869's unknown vocabulary for the `unknown` witness state where frozen — interface reliance only). Parallelizable with 1876 and 1870. Feeds P2 Sentry views (F-26) — out of scope.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196f67667001btHO7W0pOhUVrB`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: 3 new lib files (provenance/witness atoms + lineage molecule) + 2 new 53-test suites present; `boundary_test.dart` additive-only (3 `lineage_1872_*`); 1873's files untouched (no M on its paths); no barrel/alias exports (grep over 4 barrels empty).
- **Parent re-run (fresh, after return)**: `dart format` on 5 touched paths → 0 changed exit 0; new suites → **53/53 pass exit 0**; pure-dart boundary harness → **40/40 PASS exit 0** (all 1873 checks intact alongside).
- **Not re-run by parent**: broader atoms+molecules sweep (worker reports 537 pass + 4 pre-existing environmental checkbox-golden diffs; re-proof belongs to independent review).
- **Known residuals**: real-host CC/WB exercise substituted with headless sweep (exact limitation recorded; `affected_consumers: NONE` — no shared surface mutated); donor SHA-256-receipt claim recorded as INHERITED-REPORT without live UI counterpart; donor-name tokens scrubbed from comments per domain-leakage law.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51a3ee20ffeYG7d29XMBfAPf0` (independent — did not build). Report: `.project/reports/reviewers/1872-warp-prism-provenance-witness-lineage-review-loop.md`.
- **Verdict**: PASS (90/100 diagnostic). No remediation; only optional STABLE-stage suggestions.
- **Accepted evidence**: provenance/witness conformance 44/44 + lineage 9/9; format sweep 0-changed; analyzer 0 errors (1 pre-existing unrelated 1860 warning); boundary 81/81 incl. 3× `lineage_1872_*`; EXPERIMENTAL containment; stateless-only; `affected_consumers: NONE` accepted.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 90/100; conformance 44/44 + lineage 9/9, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1872-warp-prism-provenance-witness-lineage-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
