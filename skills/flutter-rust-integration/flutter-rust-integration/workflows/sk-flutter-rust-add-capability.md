---
name: sk-flutter-rust-add-capability
owner: flutter-rust-integration
kind: sequential
maturity: candidate
---

# Add a Flutter↔Rust Capability

## Entry condition

A product/domain capability is authorized and needs to cross an existing Flutter↔Rust boundary.

## Invariants

- Semantic ownership is decided before transport projection.
- Generated bindings do not become the semantic owner.
- Builders produce evidence; this workflow does not grant independent acceptance.
- Existing valid work is preserved through failures/retries.

## Transition 1 — Characterize

**Precondition:** requirement known.  
**Actor:** builder/architect as authorized.  
**Action:** load `design-boundary`; produce/update the boundary census for the capability.  
**Postcondition:** owner, contract, projection, payload class, lifecycle needs, and evidence needs are known.  
**Failure route:** unresolved ownership → architecture decision, not codegen experimentation.

## Transition 2 — Implement semantic owner

**Precondition:** contract defined.  
**Action:** implement/test the semantic behavior on the owning side (commonly Rust).  
**Evidence:** domain/unit/contract tests appropriate to that claim.  
**Failure route:** semantic design failure → return to Transition 1.

## Transition 3 — Project through transport

**Precondition:** semantic behavior exists.  
**Action:** load `implement-frb`; add the bounded bridge projection. If dependency/toolchain/codegen mutation is required, route to `dependency`.  
**Evidence:** codegen/build evidence and static boundary containment.

## Transition 4 — Implement consumer adapter

**Precondition:** generated projection exists.  
**Action:** map generated transport into the Dart semantic adapter; keep UI/domain-facing vocabulary transport-independent.  
**Evidence:** adapter tests.

## Transition 5 — Prove native crossing

**Precondition:** both adapters build.  
**Action:** load `verify-boundary`; run the minimum native oracle required by the claim.  
**Evidence:** actual native call/async/stream/error/cancel evidence as applicable.  
**Failure route:** classify via `remediation`; do not replace native failure with fake success.

## Transition 6 — Prove host when required

**Precondition:** native integration proven.  
**Action:** if the claim includes application composition, run affected real-host evidence under Flutter testing/coding-execution policy.  
**Postcondition:** capability exists through the real stack.

## Output

Return an evidence packet:

```yaml
capability:
semantic_owner:
contract:
transport_projection:
changed_surfaces:
claims_proven:
claims_not_proven:
commands:
runtime_evidence:
risks:
```

Independent acceptance remains with review/code-quality governance.
