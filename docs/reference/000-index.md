# Cybernetics Core — Feature Catalog Index

> **Generated**: 2026-06-08
> **Total Cataloged Features**: ~1,336 (936 planned + 400 gap)
> **Sources**: EPIC-000→014, Tasks 0001→0078, diegosouza-omniroute, OmniRoute, cybernetics-core

## Catalog Structure

### Planning Catalog (Planned Features)
These files contain features already planned via EPICs and tasks.

| File | Category | Features | EPICs |
|------|----------|----------|-------|
| 001 | Foundation & Infrastructure | ~145 | 000, 001 |
| 002 | Identity & Authentication | ~81 | 002 |
| 003 | Capability Registry & Exposures | ~55 | 003 |
| 004 | Credential Broker & Secrets | ~57 | 004 |
| 005 | Policy Engine | ~46 | 005 |
| 006 | Routing & Route Graphs | ~76 | 005 |
| 007 | Execution & Providers | ~92 | 006 |
| 008 | Limits, Observability & Cache | ~96 | 007 |
| 009 | MCP & Sandbox | ~65 | 008 |
| 010 | Search & External | ~34 | 009 |
| 011 | Operational (CLI, Deploy) | ~84 | 012, 013 |
| 012 | Plugin System | ~75 | 014 |
| 013 | Frontend (Flutter) — BLOCKED | ~30 | 011 |

### Gap Catalog (Features from Reference Repos Not Yet Planned)

| File | Category | Features | CORE | EXTENDED |
|------|----------|----------|------|----------|
| 014 | Multimodal Endpoints | ~50 | 30 | 16 |
| 015 | Advanced Routing | ~40 | 22 | 16 |
| 016 | Compression & Context | ~35 | 21 | 12 |
| 017 | Guardrails & Safety | ~35 | 29 | 6 |
| 018 | Memory & Knowledge | ~30 | 0 | 20 |
| 019 | Webhooks & Events | ~25 | 16 | 6 |
| 020 | Provider Ecosystem | ~40 | 12 | 24 |
| 021 | Advanced Cache | ~25 | 14 | 9 |
| 022 | A2A Agent Protocol | ~30 | 20 | 7 |
| 023 | Workflow Orchestration | ~30 | 18 | 8 |
| 024 | MCP Governance | ~25 | 18 | 6 |
| 025 | Import/Export & Bootstrap | ~35 | 24 | 8 |

### Sidebar Taxonomy (diegosouza-omniroute UI Structure)

| File | Category | Features | Notes |
|------|----------|----------|-------|
| 101 | Backend API Endpoints | ~35 | All HTTP endpoints |
| 102 | Combos & Providers | ~25 | Routing engine, quotas |
| 103 | Agent Management | ~21 | CLI, ACP, Cloud agents |
| 104 | Analytics & Monitoring | ~27 | Usage, costs, evals |
| 105 | Logs & Audit | ~14 | Logging, audit, compliance |
| 106 | System & Dev Tools | ~15 | Health, translator, playground |
| 107 | Agentic Features | ~33 | Memory, skills, MCP, A2A |
| 108 | Other Features | ~16 | Media, batch, files, plugins |
| 109 | Configuration & Settings | ~47 | All config options |

## Cross-Reference Guide

### By Provider Type
- **LLM Chat**: 007-710→007-754, 020-001→020-015
- **Embedding**: 007-712, 020-020→020-025
- **Search**: 010-1010→010-1026
- **Image Gen**: 014-001→014-009
- **Audio/Video**: 014-010→014-029
- **Rerank**: 014-035→014-039

### By Security Feature
- **Auth**: 002-200→002-285
- **SSRF**: 001-1C0→001-1C8
- **Credential Broker**: 004-400→004-456
- **Policy**: 005-500→005-545
- **Guardrails**: 017-1700→017-1740, 024-2400→024-2420

### By Routing Feature
- **Route Graph**: 006-600→006-605
- **Load Balancing**: 006-630→006-635
- **Circuit Breaker**: 006-640→006-642
- **Advanced Strategies**: 015-1500→015-1539
- **Fallback/Hedging**: 006-650→006-653

### By Operational Feature
- **CLI**: 011-1130→011-11A1
- **Deployment**: 011-11B0→011-11E2
- **Monitoring**: 008-840→008-84B
- **Audit**: 008-820→008-82A
