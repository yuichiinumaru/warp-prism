# warp-prism — Milestone & Release Governance

> **Authority**: Canonical durable home for project milestone and release governance.
> **Scope**: warp-prism project lifecycle and release gates.
> **Purpose**: This document provides the single, living, versionable register answering: *"Can this release candidate be cut and activated?"*

---

## 1. Lifecycle & Governance Contract

Every release milestone transitions through a deterministic sequence of document states:

```text
PLANNED -> ACTIVE -> RC_READY -> RELEASED
   |          |          |
   +----------+----------+-----> BLOCKED
```

### State Definitions

| State | Meaning | Transition Invariants |
|---|---|---|
| `PLANNED` | Milestone defined in advance with explicit task spine, functional gates, candidate integrity criteria, non-goals, and evidence schema. | Implementation not yet complete. Milestone exists as strategic target. |
| `ACTIVE` | Work actively underway on the milestone's task spine and functional verification gates. | One active release milestone per project at any given time. |
| `RC_READY` | Implementation cutoff reached; candidate identity frozen; all mandatory functional gates demonstrably pass against the exact frozen candidate. | **RC_READY is NEVER release authorization by itself.** It is the prerequisite state for independent release-readiness review. |
| `BLOCKED` | A critical gate failure, security flaw, data-integrity issue, or unresolved dependency halts progress. | Requires classified remediation or explicit scope reconciliation by the architect and operator. |
| `RELEASED` | Milestone has achieved formal operator authorization and independent reviewer-owned publication/governance gates (`.opencode/rules/90-governance-activation-and-release.md`). | Immutable historical record; never amended except for explicitly labeled errata. |

### Hard Governance Boundaries

1. **Milestone states NEVER move task lanes**: Task lifecycle (`00-planning` through `04-completed`) is governed exclusively by the containing task directory (Rule 42). Milestone states belong solely to `docs/milestones.md`.
2. **No task receives a `Status` field**: The prohibition of `Status` fields in task ledgers is absolute.
3. **Milestone states NEVER authorize VCS or deployment by themselves**: A milestone reaching `RC_READY` or `RELEASED` in documentation does not authorize git commits, tags, pushes, or deployments. Release publication requires explicit operator authorization plus reviewer-owned publication workflows.
4. **Task Spine Anti-Expansion Rule**: The required task spine defines the necessary and sufficient task set for the milestone. A milestone does not expand its scope merely because unrelated open tasks remain in the backlog.
5. **Functional Gates Are Candidate-Bound**: Functional gates evaluate the actual candidate against its measurable exit criteria, independent of bookkeeping conveniences.

---

## 2. Implementation Cutoff & Candidate Integrity

1. **Implementation Cutoff**: Once a milestone enters release candidate preparation, feature mutations cease. Only classified, candidate-scoped remediation is permitted.
2. **Frozen Candidate Identity**: The candidate is identified by exact VCS revision/commit hash, artifact checksums, runtime configuration, and data schema hashes.
3. **Anti-Splicing (No Composed PASS)**: All functional gates and test batteries must execute against the **SAME** frozen candidate. Composing a PASS across distinct retries, runs, or candidates is prohibited.
4. **Live Evidence vs Local Mocks**: Mocks may prove local contract satisfaction, but cannot alone satisfy functional gates promising real integration or runtime readiness.

---

## 3. Immutable Checkpoint Semantics

- **"A checkpoint freezes the review subject, not project development."**
- **Continuous Development (`successor_work_may_continue = true`)**: While an immutable checkpoint is locked for review or release verification, development on successor tasks and future milestones may proceed in parallel.
- **Bound Checkpoint Record**: Each completed checkpoint immutably binds frozen VCS reference, integrity hashes, included task/evidence set, cutoff timestamp, independent review verdict, and operator authorization.
- **Preservation of Historical Truth**: Checkpoints record historical fact as it occurred; historical records are never retroactively edited.

---

## 4. Amendment Rules

1. **Newest-First Order**: New milestones are inserted above older milestones.
2. **Immutability of RELEASED**: Once marked `RELEASED`, a milestone record is permanently immutable.
3. **Authority Separation**: Builders attach evidence; Reviewers independently audit and issue verdicts; material scope/gate changes require architect reconciliation and operator approval.

---

## 5. Milestone Registry

### M01 — Warp Prism v2: L1 Integration-Capable (PLANNED)

> **State**: `PLANNED`  
> **L1 Integration Readiness Gate**: **PASSED** (Task 1825, 2026-09-02 — independent acceptance; evidence: `docs/reports/1825-integration-readiness-l1-exit-report.md`)  
> **Cutoff Ref**: TBD (VCS checkpoint operator-gated per Constitution §7)  
> **Successor Work Allowed**: `true`  
> **Target Date**: TBD  
> **Cutoff Ref**: TBD  
> **Successor Work Allowed**: `true`
> **Defined by**: architects lane, 2026-09-01, from the user-approved v2 portfolio (source-reality review 2026-08-31 + builder-handoff 2026-09-01). Activation to `ACTIVE` awaits operator action.

#### Objective

Take Warp Prism from L0 (ADS, complete) to **L1 Integration-Capable**: the compositional ADS + IDS + backend-agnostic runtime contracts with a Rust golden path via a replaceable FRB adapter, proven by a single-hypothesis integration lab. L2 (Rewrite-Capable) is explicitly NOT in this milestone — it requires the first real product pilot + harvest.

#### Required Task Spine

| Task | Unit |
|---|---|
| 1810 | 19-A Charter v2 + ADR + AGENTS alignment |
| 1811 | 19-B Layer boundaries + harness check 8 |
| 1812 | 19-C Package topology (2-crate Rust) |
| 1813 | 19-D State-based declutter + root hygiene + check 9 |
| 1814 | 20-A Interaction inventory |
| 1815 | 20-B IDS candidate kernel |
| 1816 | 19-E Post-1805 visual/baseline freeze (external human gate) |
| 1817 | 20-C IDS proof + promotion review |
| 1818 | 21-A Runtime consumer audit |
| 1819 | 21-B Experimental runtime contracts + testkit |
| 1820 | 21-C Bindings proof |
| 1821 | 21-D Runtime promotion-gate evidence |
| 1822 | 22-A FRB candidate spike (kill-gate) |
| 1823 | 22-B Minimal Rust bridge substrate |
| 1824 | 22-C Integration lab parity (FRB only) |
| 1825 | 22-D Integration Readiness / L1 exit gate + harvest checklist |

External dependency: Task 1805 (human visual sign-off) gates only 1816 and the visual branch — not the rest of the spine.

#### Mandatory Functional Gates

- Task 1825's 13-check Integration Readiness audit, all PASS (build-budget row recorded as baseline-of-record note; see report Part 4).
- Boundary harness (checks 1–15; 13 active in harness as of 2026-09-02 remediation — checks 16/17 remain PHASED) green.
- Contract compliance suites 100% on fakes; on the live FRB bridge, the same semantic contract suites **where applicable** (MISSION.md §45 standard): EventStream 19/19, HealthSource 7/7, GraphSource 6/6 fully symmetric; AsyncCommand via 6/6 modality matrix — closure-injection through FFI is architecturally inapplicable and is a documented exception (M01 gate amendment 2026-09-02).
- Human visual sign-off on Task 1805 before 1816 executes (operator action).

#### Non-Goals

- No RPC/daemon/hybrid transports (first lab is FRB-only, single hypothesis).
- No Rust microcrate proliferation (2 crates: warp_bridge_core + warp_bridge_frb).
- No product backend implementation in Warp Prism; no domain-type leakage into core packages.
- No scaffolder/template family/resolver machinery (EPIC-23B/24/25 remain post-pilot).
- No performance tuning beyond declared SLO baselines.

#### Candidate Integrity & Checkpoint Record

```yaml
# L1 Integration Readiness Gate PASSED 2026-09-02 (Task 1825 independent acceptance)
# candidate_ref / cutoff timestamp / integrity hashes: operator-authorized VCS checkpoint required (Constitution §7 — human gate; not in scope for builder/agent tasks)
candidate_ref: "TBD"
implementation_cutoff_timestamp: "TBD"
exact_included_tasks: []
exact_included_evidence: []
integrity_hashes:
  build_sha256: "TBD"
functional_gates_pass: false
independent_review_verdict: "PENDING"
reviewer_report: "TBD"
release_handoff_snapshot: "TBD"
operator_authorization: "NONE"
successor_work_may_continue: true
```

---

## 6. Amendment Log

- **2026-09-01**: Governed milestone skeleton established under Ganthritor Milestone Governance Contract (Task 4643).
- **2026-09-01**: M01 defined as "Warp Prism v2: L1 Integration-Capable" with the 1810–1825 task spine, from the approved v2 portfolio (recovery session, architects lane). State remains `PLANNED`; activation is an operator action.
- **2026-09-02**: **M01 gate amendment** (mission-control, disposition 2 of the 1825 independent review): the "100% on both fakes and live FRB bridge" gate wording was over-specified relative to MISSION.md §45 (higher authority: "the same semantic contract suite **where applicable**"). Gate aligned to the mission standard with the measured parity recorded per contract; AsyncCommand modality-matrix exception documented. Basis: 1825 review finding + 1824 §7 Gap Closure Amendment (Graph 6/6, Health 7/7 closed 2026-09-02).
