# HOLD-warp-prism-health-badge-axis-spec (EPIC-D S2)

> **Planning Status**: Strategically Deferred
> **Promotion Gate**: program acceptance (PLAN doc) + runtime owner review slot (`HealthSource` axis extension touches a live EXPERIMENTAL contract; owner review required before spec finalizes field shape).
> **Reason held**: contract-surface protection — extending `HealthSource`'s vocabulary (keyring/quota axis) without owner review risks a still-EXPERIMENTAL contract's evolution path.
> **Promotion target**: `01-open` when gate met AND §3.1 readiness holds.
> **Type**: `feature` (spec) | **Origin**: Phase 1 inventory G6 + review PASS `ses_edbfcec4dffeX44ZMBOaLDsRWR`
> **Depends on**: Phase 1 PASS (met) | **Blocks**: none (leaf)

---

## Objective

Specify the capability/health badge extension axis: keyring-aware credential state (present/absent/invalid without ever carrying secret values), quota/cost/latency dimensions, and weight-asset (VRAM/model) readiness — generalizing Warpblade's `DiagnosticsPanel` (bridge ping, texture lifecycle, typed errors) and Tempest's `HardwareStatusIndicator` + `ProviderConnectionCard` (GPU/CPU, VRAM, keyring-obfuscated key field, connectivity test, latency badge) onto the existing `HealthSource` + `PrismProviderHealthMatrix`, with secret-hygiene as a load-bearing (not decorative) requirement.

## Background Context

### What already exists

- `HealthSource` contract (snapshot + watch + freshness TTL + aggregate-state fold) + `FakeHealthSource` + conformance suite.
- `PrismProviderHealthMatrix`, `DSHealthCard` — partial badge vocabulary (missing keyring/quota axis).
- Consumer proof: keyring obfuscation pattern, connectivity-test interaction, latency badge, hardware probe readout.

### What is missing

- The axis: credential-state dimension (no secret values cross the contract — opaque presence only), quota/cost dimension, weight-asset dimension.
- Secret-hygiene rule: what the contract may carry (presence/validity/expiry-class) vs never (values, tokens, keys) — mechanical, not advisory.
- Mapping of both consumers' badge content onto the extended axis (residue → product-local).

## Test Requirements

- A secret value cannot be expressed in the extended vocabulary (prove by construction: no field accepts one).
- Both consumer badges map onto the axis without residue, or residue is named product-local.
- The extension preserves `HealthSource`'s existing conformance suite (additive fields, no breaking change to snapshot/watch semantics).

## Exit Conditions

- [ ] Axis fields + secret-hygiene rule + both-consumer mapping completed (`## Specification`).
- [ ] Additive-only proof sketch (existing suite unaffected).
- [ ] Cited-path sweep passes.
- [ ] No secret-shaped example values in the spec (use `***REDACTED***`-class placeholders only).
- [ ] No `HealthSource` source modified (spec only).
- [ ] Completion Evidence filled.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `HealthSource` contract + models + testkit fake/suite, `PrismProviderHealthMatrix` + `DSHealthCard`, both consumer badge surfaces (authorized routes, record route), Phase 1 inventory §2.1 rows 6/9.
- [ ] Draft the axis (credential-state, quota/cost, weight-asset) with field shapes.
- [ ] Draft the secret-hygiene rule (carry/never-carry lists, mechanical).
- [ ] Build the both-consumer mapping; name residue product-local.
- [ ] Sketch additive-only conformance impact (new suite cases, zero changes to existing).
- [ ] **Simplicity pass**: cut dimensions no mapping needs.
- [ ] **Regression verification**: cited-path sweep; contract untouched.

### Where

| File | Purpose |
|---|---|
| `packages/warp_prism_runtime/lib/src/health_source/` | Read — contract to extend (do not modify) |
| `packages/warp_prism_testkit/lib/src/` (health fake + suite) | Read — additive-impact surface |
| Prism health-matrix/card sources | Read — existing badge vocabulary |
| Consumer `diagnostics_panel.dart` / providers + shell badge code | Read — authorized routes only; record route |
| This file (`## Specification`) | Create — axis spec lives here |

### How

1. Secret-hygiene first: the never-carry list is normative and precedes field design.
2. Additive-only: any field breaking existing snapshot/watch semantics is rejected, not versioned around.
3. Residue named per consumer (diagnostics-QA depth? hardware-probe specifics?).

### Why

Capability badges are the surface where secret values most want to leak (key fields, tokens in diagnostics) and where quota/cost blindness ships as "healthy." The axis makes keyring/quota first-class without ever carrying a secret — the property that justifies a shared contract over two local badges.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not carry, invent, or example any real secret value (placeholders only). Do not modify `HealthSource`. Do not break existing conformance semantics — additive only.

---

## Validation Commands

```bash
ls packages/warp_prism_runtime/lib packages/warp_prism_testkit/lib .project/tasks/00-planning/PLAN-warp-prism-future-capability-program.md .project/reports/architects/future-capability-program-inventory-2026-10-10.md
```

Code gates do not apply to this prose spec; on promotion the executor adds package-appropriate exits (including the additive conformance cases).

---

## Specification

*(To be written on promotion-approach: axis fields, secret-hygiene rule, both-consumer mapping, additive-impact sketch.)*

---

## Completion Evidence

- **Files created/modified**: (executor fills)
- **Tests or validation commands**: (commands + PASS/FAIL)
- **Local changelog entry**: (path)
- **Executor**: —
- **Completion date**: —
