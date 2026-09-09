# EPIC 22 — Warp Prism Rust Golden Path (flutter_rust_bridge) + Integration Lab

> **Planning Status**: Draft — source-reality reviewed 2026-08-31. Verdict: **EXECUTION CANDIDATE** with single-hypothesis lab. NOT executable yet.
> **Priority**: 🟡 P1
> **Origin**: `docs/ads-to-ids.md` hypothesis corpus, falsified 2026-08-31. Repo has ZERO Rust/FRB — this epic is entirely greenfield and its central hypothesis is UNVALIDATED.
> **Depends on**: EPIC-21 experimental contracts (21-B) for parity targets; 22-A build-matrix portion may run in parallel with 21-B.

## 0. SINGLE-HYPOTHESIS RULE (2026-08-31)

The first Integration Lab answers ONE question: **does our golden path Flutter↔Rust via FRB work correctly inside the defined boundaries?**

```
Flutter Integration Lab → FRB → Rust fake/test runtime
   (AsyncCommand · EventStream · HealthSource · GraphSource)
```

**EXCLUDED from this lab** (mixing transports makes results epistemically worthless — you can't attribute success/failure): resident daemon, RPC, remote workers, hybrid topology, Cersei, Ganthritor, OmniRoute runtime. → deferred ledger; a second lab may validate daemon/RPC AFTER 22-D if embedded mode shows limits.

## 0b. FRB VERSION = CANDIDATE, NOT CANON (2026-08-31)

"2.13.0" was conversation-time current — never tested. At spike time: (1) verify latest stable appropriate then; (2) verify Dart/Flutter/toolchain compatibility; (3) select **candidate spike version**; (4) run build/integration matrix; (5) only then ADOPT + pin the quadruple: FRB package + matching codegen + Native Assets/build integration + Rust toolchain. Before adoption the wording everywhere is `candidate`, never `adopted architectural dependency`.

## 0c. RUST TOPOLOGY = 2 CRATES (reduced 2026-08-31)

```
rust/
├── warp_bridge_core/     # modules: command/ events/ health/ graph/
└── warp_bridge_frb/      # the FRB projection
```
Rule: **concept existence ≠ crate existence.** `jobs`/`media`/`telemetry` remain future capability candidates until a concrete crate motive exists (dependency isolation / independent lifecycle / build isolation / independent reuse / compile boundary). Cargo workspace placement (root vs `rust/`) = OPEN ADR decided at 22-B with build evidence.

---

## 1. Objective

Adopt `flutter_rust_bridge` as the Dart↔Rust golden path — **as a pinned dependency, never absorbed/forked** — and validate the four runtime contracts across the language boundary with a fake Rust runtime in an isolated Integration Lab.

## 2. Non-Negotiable Guards

- `warp_prism_ui` MUST NOT contain or depend on FRB.
- FRB code lives only in `warp_prism_adapter_frb` (Dart) + `warp_bridge_frb` (Rust projection).
- Rust crates: `warp_bridge_core/events/jobs/graph` = ZERO FRB; only `warp_bridge_frb` knows FRB.
- Rust crates MUST NOT own application domain/business logic.

## 3. ⚠️ Epistemic status — UNVALIDATED (audit 2026-08-29)

The "golden path" framing is a **hypothesis from the transcript**, not a proven fact:
- FRB 2.13.0 + Native Assets on Linux has **never been spiked in this repo**.
- No benchmark, no cold/incremental build measurement, no CI integration evidence exists.
- The transcript's own history includes a production post-mortem caused by an untested migration — treat this epic accordingly: **the spike (S22-02) is a kill-gate, not a formality**.

## 4. Stories (v8)

| Story | Title | Key deliverable | 2026-08-31 verdict |
|---|---|---|---|
| S22-01 | Version Selection (candidate → adopt) | candidate-version process §0b; pin only post-spike (quadruple) | AMEND (never pre-pin) |
| S22-02 | Native Assets Spike | cold/incremental/CI/packaging, Linux first then Android; async Rust/callbacks/traits; **KILL-GATE** | ACCEPT |
| S22-03 | Integration Lab (apps/integration_lab) | FRB-ONLY lab per §0; fixture/fake-first; no auth/DB/product; BackgroundJob excluded | AMEND (single transport) |
| S22-04 | Contract Suite Parity | same suite as fakes; error/cancel/bidirectional; Bridge pipeline | ACCEPT |
| S22-05 | Exit Gates + Harvest Checklist | 13-check gate + 3 No's; **22-D = Integration Readiness / L1 EXIT GATE** (NOT "Rewrite Readiness" — L2 requires first real product pilot + harvest BEFORE the Rewrite Readiness gate); mandatory harvest-checklist questions pre-attached for the post-PILOT harvest (distinct from any Integration-Lab retrospective); gates Level-1 exit only | AMEND (A1 terminology, 2026-09-01) |

## 5. Exit Conditions

- [ ] FRB tools version-pinned; upgrade path recorded.
- [ ] Native Assets spike report committed (Linux first) — decision: adopt vs classic plumbing.
- [ ] Integration Lab proves 4 contracts across Dart↔Rust boundary.
- [ ] Parity suite executed with matching pass/fail vs Dart fakes.
- [ ] Integration Readiness / L1 Exit Gate (13 checks + 3 No's) all PASS. (L1 = Integration-Capable; L2 Rewrite Readiness requires the first real product pilot + harvest, which happens AFTER this epic.)
- [ ] **Before promotion of any story: verify integration_test harness infrastructure exists (audit finding — current tasks 1802/1805 assumed it without checking).**

## 6. Dependencies / Kill Conditions

- EPIC-21 must pass its quality gates first.
- S22-02 spike failure ⇒ fall back to classic plumbing path or halt; do NOT proceed with Native Assets assumption.
