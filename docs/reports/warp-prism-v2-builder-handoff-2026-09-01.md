# Builder Handoff — Warp Prism v2 First Execution Wave

> **Date**: 2026-09-01 · **From**: architects lane · **To**: builders lane
> **Authority**: Source-Reality Review 2026-09-01 + independent task-readiness review (2 passes, AMENDs remediated)
> **Scope**: Full v2 execution portfolio (Tasks 1810–1825; EPIC-19 foundation + EPIC-20 IDS + EPIC-21 Runtime + EPIC-22 FRB golden path)
> **Milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)

---

## 1. Mission

Execute the foundation work for Warp Prism v2: a compositional Flutter design + integration system (ADS + IDS + Runtime contracts + Rust golden path). This wave covers the charter, layer boundaries, package topology, root hygiene, and the start of the Interaction Design System kernel — all the work that is architecturally independent of the still-pending visual gate (Task 1805).

## 2. Initial executable wave (all in `01-open/`)

| ID | Name | Depends on | Scope |
|---|---|---|---|
| **1810** | Charter v2 + ADR + AGENTS Alignment | none | Amend `docs/design/charter.md` in place; record ADR; **verify-only** AGENTS.md §1 metadata (already current — do not re-edit). No governance/lane/promo edits. |
| **1811** | Layer Boundaries + Harness v2 | none | Create `docs/architecture/layer-contracts-v2.md` (MUST/MAY/MUST-NOT matrix + Domain Leakage Rule); add harness **check 8 only** (registry mutation scope). Check 9 belongs to 1813. |
| **1812** | Package Topology + Workspace | none | Create `docs/architecture/package-topology.md` (v2 packages + dependency direction + 2-crate Rust). Cargo placement = OPEN ADR resolved at 1822 by spike evidence. |
| **1813** | State-Based Declutter + Root Hygiene | none | Classify/move ~22 root scratch files into `tool/`/`scripts/`/archive; install + activate **check 9 atomically** (sweep + gate + PASS together). Does NOT depend on Task 1805. |
| **1814** | Interaction Inventory | none | Evidence-driven inventory of selection/inspection patterns → `docs/architecture/interaction-inventory.md`. Read-only; blocks 1815. |

**Parallelism**: 1810, 1812, 1814 are fully parallel. **OPERATIONAL SERIALIZATION (operator directive 2026-09-01): Tasks 1811 → 1813 MUST run serialized in a shared workspace** — both append to `boundary_test.dart` (writeset dependency, not architectural). Run 1810/1812/1814 in parallel with 1811; dispatch 1813 only after 1811 is PASS. Only truly isolated worktrees with governed integration may lift this. **Shared-write note**: 1811 adds check 8, 1813 adds check 9 (each an independent append; the file merges cleanly), but each task validates only its own check and neither asserts a total check count. **Archive-first law (1813)**: zero file deletions — every root scratch file moves to `tool/`, `scripts/`, or `docs/archive/` with provenance.

## 2.1 Full materialized portfolio (dependency-gated holds in `00-planning/`)

| ID | Name | Depends on | Gate |
|---|---|---|---|
| **1815** | IDS Candidate Kernel | 1814 | evidence floor for kernel scope |
| **1816** | Post-1805 Visual/Baseline Freeze | **Task 1805 (HUMAN)** | external human blocker |
| **1817** | IDS Proof + Promotion Review | 1815 | |
| **1818** | Runtime Consumer Audit | 1811 + 1812 | layer matrix + topology docs must exist |
| **1819** | Experimental Runtime Contracts + Testkit | 1818 | |
| **1820** | Bindings Proof (IDS ∥ Runtime) | 1815 + 1819 | convergence point |
| **1821** | Runtime Promotion-Gate Evidence | 1820 | |
| **1822** | FRB Candidate Spike (Kill-Gate) | 1812 | spike may run in parallel with 21-B once topology exists |
| **1823** | Minimal Rust Bridge Substrate | 1822 PASS + 1819 | kill-gate must PASS first |
| **1824** | Integration Lab Parity (FRB only) | 1823 + 1820 | |
| **1825** | Integration Readiness / L1 Exit Gate | 1824 + 1817 + 1821 | closes M01 |

## 3. Dependency / progression rules

```
1810 ┐
1811 ├─ parallel ─► all complete ─► architect promotes next wave
1812 ┤
1813 ┘
1814 ──────────────► 1815 (IDS kernel)

AFTER 1810–1815:
  ┌─ 20-C (IDS proof/promotion) ─ parallel ─┐
  │                                           │
  ├─ 21-A (runtime-consumer audit)           │
  │                                           │
  ├─ 21-B (experimental contracts + fakes)   │
  │                                           │
  └─ 21-C (bindings proof) ◄── convergence ◄──┘
                   │
                   ▼
              22-A (FRB candidate spike) — KILL-GATE
                   │
                   ▼
              22-B (minimal bridge substrate, 2 crates)
                   │
                   ▼
              22-C (integration lab parity, FRB only)
                   │
                   ▼
              22-D (Integration Readiness / L1 exit gate)
                   │
                   ▼
         FIRST REAL PRODUCT PILOT (OmniRoute vertical, parent-gated)
                   │
                   ▼
         PILOT HARVEST / RETROSPECTIVE (mandatory)
                   │
                   ▼
         REWRITE READINESS / L2 gate ─► 23B/24/25 crystallization
```

**Maturity ladder (corrected A1)**: L0 ADS (done) → L1 Integration-Capable (EPIC-19..22; exit = 22-D) → L2 Rewrite-Capable (one REAL product pilot + harvest) → L3 Rewrite Factory (post-L2 only). 22-D is **NOT** "Rewrite Readiness".

## 4. Review protocol

- Every task goes to **independent review** after builder done (no self-acceptance).
- Reviewer produces a real verdict: PASS / FAIL / BLOCKED (no rubber-stamp).
- On PASS: use proper architect/task-governance owner to promote newly unblocked downstream work.
- On FAIL/BLOCKED: remediate; do not promote.
- Golden freeze discipline (from Task 1800): no golden regeneration between 1801 merge and 1805 approval. Tasks 1810–1815 do not touch goldens, but the freeze remains in force for any future visual work.

## 5. Which tasks are held and why

| Task | Lane | Reason |
|---|---|---|
| 1805 (Screenshot Visual Acceptance) | `03-review` | EXTERNAL HUMAN BLOCKER — requires product-owner sign-off; no delegated reviewer satisfies the contract. Technical review already done (100/100, 2026-08-23); only the visual approval is pending. |
| 1816 (19-E Post-1805 Visual Freeze) | `00-planning` (hold) | Depends on Task 1805 human visual gate (EXTERNAL HUMAN BLOCKER) |
| 1815, 1817–1825 | `00-planning` (not-ready) | Dependency-gated materialized tasks — see §2.1; each becomes `01-open` when its deps complete and PASS |
| 1801–1804, 1806–1809 | `03-review` | EPIC-18 execution complete; awaiting review drain (W1) |
| EPIC-23B / 24 / 25, scaffolder/templates/resolver | `00-planning` (research hold) | Require L2 evidence (first real pilot + harvest) |

## 6. How downstream promotion is requested

When a task passes review:
1. Builder populates Completion Evidence + requests promotion to `04-completed`.
2. Architect (or governance owner) verifies exits + evidence.
3. On PASS: promote; then **re-evaluate the DAG** for newly unblocked work.
4. Dispatch next wave only when its dependencies are met (no speculative queue-loading).

## 7. Stop conditions

Stop the wave and return to architects when:
- A task is BLOCKED by a genuine architectural contradiction (not a fixable bug).
- A boundary harness check fails in a way that reveals a design flaw.
- The 1805 human gate cannot be satisfied and blocks 19-E.
- All executable work in the current wave is exhausted.

Do NOT stop for: routine test failures (remediate), scope clarification within the task's stated non-goals (defer to a follow-up task), or discovery of better abstractions (record in deferred ledger, do not expand scope).

## 8. Exact human-only blockers

| Blocker | Contract basis | Delegable? |
|---|---|---|
| **Task 1805 visual acceptance** | `1805-warp-prism-screenshot-visual-acceptance-gate.md` exit conditions: "Human-approved target artifact committed and linked (user sign-off recorded)", "Do not claim visual approval without a recorded user statement"; `PENDING-USER` on every exit; report checklist is human-gated | **NO** — product-owner/human approval explicitly required; no independent reviewer satisfies the contract. Gates ONLY Task 1816 + visual-baseline work; it does NOT block 1810–1815, 1817–1825. |

The AGENTS.md §1 edit (1810) is **already applied and verified** — builders do not touch AGENTS.md at all in this wave.

## 9. Independent readiness review (2026-09-01)

Two independent readiness-review passes ran after materialization (delegated, not self-review):

- **Pass A (Tasks 1810–1817)**: 8/8 AMEND → all remediated (stale 1810 bullet, 1811↔1813 boundary_test ownership split + count-agnostic exits, 1813 non-goals/Where gaps/pattern coverage, 1814 non-goals, 1817 named consumers + binary exits + Where gaps, 1816 verified correctly human-gated).
- **Pass B (Tasks 1818–1825)**: 7/8 READY, 1 AMEND (1818 non-goals) → remediated. Verified: no FRB pre-pin, Cargo placement = open ADR resolved at 1822, 1825 = L1-only.

Post-remediation verification (architect, mechanical): 16/16 tasks carry `## Milestone Alignment`, shared-write ownership notes present in 1811+1813, no `Status:` fields anywhere, DAG headers match §2.1 exactly, projections rebuilt via canonical `tasklist-sync` (218 tasks indexed, 0 missing refs).

**Residual known gaps (recorded, non-blocking):**
1. `Milestone Alignment` sections reference M01 in `docs/milestones.md`; M01 is defined (task spine = 1810–1825) but its state is `PLANNED` — activation to `ACTIVE` is an operator action, not a builder action.
2. Local `000-template.md` predates the shared-baseline `Milestone Alignment` requirement; template↔baseline reconciliation is a governance follow-up, not part of this wave.
3. Boundary-check numbers 10–17 in task bodies follow the §F numbering plan of the source-reality review; `layer-contracts-v2.md` (1811 output) is the authoritative list once it lands.

## 10. Canonical architecture / report references

The builder must consume **these**, NOT the transcript:

- `docs/milestones.md` — M01 task spine and functional gates (the milestone this wave closes)
- `docs/reports/warp-prism-v2-source-reality-review-2026-08-31.md` — canonical verdicts A–G
- `docs/tasks/00-planning/EPIC-19-warp-prism-v2-foundation.md` (amended 2026-09-01)
- `docs/tasks/00-planning/EPIC-20-warp-prism-ids-kernel.md`
- `docs/tasks/00-planning/EPIC-21-warp-prism-runtime-contracts-mvp.md`
- `docs/tasks/00-planning/EPIC-22-warp-prism-frb-golden-path-integration-lab.md` (amended 2026-09-01: 22-D = Integration Readiness / L1)
- `docs/tasks/00-planning/EPIC-OR-warp-prism-omniroute-cross-lane-anchors.md` (amended 2026-09-01: pilot precedes L2)
- `docs/design/black-obsidian-visual-contract.md` (live visual canon)
- `docs/tasks/00-planning/STORIES-ads-to-ids-epics-19-25.md` (coverage genome — informational, NOT a queue)

Do NOT consume as authority: `docs/ads-to-ids.md` (untrusted brainstorm transcript), story-level speculation, or any concept in the deferred ledger (§G of the report) unless explicitly promoted.

## 11. Builder autonomy contract

```
while executable work exists:
    claim a READY task (dependencies met, no blocker)
    implement ONLY the authorized scope in the task file
    run the validation commands listed in the task
    populate fresh evidence (what changed, commands run, results)
    send to INDEPENDENT review (not self)
    remediate failures
    after PASS:
        request promotion via architect/governance owner
        re-evaluate DAG for newly unblocked work
    continue

never:
    self-accept builder work
    bypass task dependencies
    broaden architecture ad hoc
    promote HOLD/RESEARCH concepts (EPIC-23B/24/25)
    implement speculative framework features
    regenerate goldens outside the 1805-approved path
    edit AGENTS.md beyond the pre-authorized 1810 text
    delete root files without provenance record (1813)
```

Use maximum safe parallelism only when writesets/dependencies permit. When in doubt, serialize.

---

**End of handoff. The next useful evidence must come from implementation.**
