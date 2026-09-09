# EPIC-OR-00 / OR-01 / OR-02 — OmniRoute Cross-Lane Planning Anchors (Parent-Repo Scope)

> **Planning Status**: RESEARCH INTENT (refined 2026-08-31). OmniRoute enters as **consumer/validator, never as source of domain types** in Warp Prism core. Read-only archaeology (Behavioral Freeze, Capability Census, State/Effect Census, Oracle Capture) may run in PARALLEL with EPIC-19..22 under parent authorization. First implementation pilot candidate = Provider Management (list/inspect/configure/test-connection/observe-health) — **a target to validate during OmniRoute planning, not an axiom**. Domain Leakage Rule applies bidirectionally.

---

## Scope

| Anchor | Content |
|---|---|
| OR-00 — Behavioral Freeze | criteria for freezing an OmniRoute revision suitable for capability census (freeze revision, census hooks, oracle corpus) |
| OR-01 — Capability Census | read-only inventory of OmniRoute behaviors producing a capability manifest aligned to Warp Prism contracts |
| OR-02 — Provider Vertical Pilot | ONE vertical slice (list providers → inspect → configure → test-connection → observe health) crossing ADS+IDS+runtime+Rust+FRB+state+network+errors+live-updates — the graduation test |

## Non-Promise Clauses (mandatory)

- No epics, tasks, directories, or code in the OmniRoute/cybernetics-core tree may be created from this planning packet.
- These anchors name future corridors only, not current rights.
- Any real work requires: (1) parent repo governance opening the lane, (2) Warp Prism Integration Readiness / L1 PASS (from EPIC-22 exit), (3) explicit user authorization. The Provider Pilot (OR-02) is the first REAL product pilot: it runs BEFORE the L2 Rewrite Readiness gate and its harvest IS the L2 evidence — it must not be blocked on L2.
- DSH/Cordis/Cersei adoption experiments belong to their own repos' governance, not Warp Prism.

## Sequencing (from transcript)

```
EPIC-19..22 (Warp Prism v2)      EPIC-OR-00/01 (read-only, parallel)
        │                               │
        └───────────┬───────────────────┘
                    ▼
      INTEGRATION READINESS / L1 EXIT GATE (22-D)
                    ▼
           EPIC-OR-02 Provider Pilot  ← first REAL product pilot
                    ▼
           Retrospective / Harvest (mandatory — this harvest IS the L2 evidence)
                    ▼
          REWRITE READINESS / L2 GATE
        ┌───────────┴───────────┐
        ▼                       ▼
  improve Warp Prism      continue OmniRoute
        └───────────┬───────────┘
                    ▼
         Streaming Pilot → Graph/Workflow Pilot
                    ▼
         Migration DAG (providers → ... → management)
                    ▼
              REWRITE FACTORY (Level 3)
```
