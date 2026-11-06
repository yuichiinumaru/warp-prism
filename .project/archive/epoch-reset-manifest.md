---
type: manifest
title: "Warp Prism Epoch Reset — Archive Manifest"
date: 2026-09-27
authority: epoch-reset (user-authorized bounded architecture/governance reset)
archive_root: .archive/
---

# Epoch Reset — Archive Manifest

> **Non-authoritative by default.** Archived artifacts are historical evidence.
> Nothing in `.archive/` is current authority. If an archived artifact is cited
> as current truth, that citation is a defect.
>
> **Reversibility:** every entry below still exists verbatim at
> `.archive/<original project-relative path>`. Archiving moved nothing out of
> git history and destroyed no evidence.

## Invariants Harvested Before Archiving

These were extracted from the archived corpus and are now owned by the current
canonical corpus. They are recorded here so no invariant is silently lost.

| Invariant | Harvested into |
|---|---|
| `warp_prism_ui` MUST NOT import FRB / runtime / bindings | `MISSION.md` §4; `AGENTS.md` §7; `docs/architecture/layer-contracts.md` |
| Runtime contracts carry semantics, not presentation policy (purge law) | `MISSION.md` §4; enforced by `runtime/test/purity_test.dart` |
| FRB is transport, not ontology; Rust domain core stays transport-independent | `MISSION.md` §4, §6 |
| Domain Leakage Rule (bidirectional; consumer never sources domain types) | `MISSION.md` §4.5 |
| Explicit bypass: products MAY bypass contracts when genuinely domain-specific | `MISSION.md` §4.5 |
| Runtime model ≠ presentation model (Offset owned by binding, never by contract/Rust) | `MISSION.md` §4, §6; `graph_layout_strategy.dart` |
| Promotion gate: ≥2 distinct consumers OR ≥2 distinct domains + fake + suite PASS | `MISSION.md` §6 |
| Crystallization rule: no template until ≥2 real validated integrations | `MISSION.md` §6 |
| L3 / Rewrite-Factory prohibition | `MISSION.md` §11.1 (superseded), `AGENTS.md` §10.1 |
| Golden interim freeze: single governed refresh only after recorded human sign-off | `docs/design/black-obsidian-visual-contract.md` §7 |
| Boundary harness is the mechanical enforcer of layer purity | `packages/warp_prism_ui/test/boundaries/boundary_test.dart` |
| Consumer harvest loop: local impl → bridge evidence → classification → recurrence → extraction → adoption → promotion | `docs/bridge/README.md` |
| FRB version pinning is a candidate, never a canon | `MISSION.md` §4.4 |

## Entries

| Old path | Artifact identity | Epoch | Reason archived | Current replacement / canonical owner |
|---|---|---|---|---|
| `00-planning/EPIC-00-warp-prism-foundation-compile-gate.md` | EPIC-00 Foundation Compile Gate | v1 bootstrap | Executed; wording stale | `04-completed/` task corpus |
| `00-planning/EPIC-01-warp-prism-atomic-design-system.md` | EPIC-01 ADS | v1 | Executed; wording stale | `docs/design/charter.md`, `token-theme-catalog-policy.md` |
| `00-planning/EPIC-02-warp-prism-mock-workspace-corpus.md` | EPIC-02 Mock Workspace Corpus | v1 | Executed | `04-completed/` task corpus |
| `00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md` | EPIC-03 Data Layer | v1 | Executed | `04-completed/` task corpus |
| `00-planning/EPIC-04-warp-prism-product-shell-overview.md` | EPIC-04 Product Shell | v1 | Executed; product-shell framing superseded (Warp Prism no longer owns product frontends) | `MISSION.md` §3 |
| `00-planning/EPIC-05-warp-prism-map-surface.md` | EPIC-05 Map Surface | v1 | Executed; map-as-product-surface superseded | `MISSION.md` §3 |
| `00-planning/EPIC-06-warp-prism-operate-surface.md` | EPIC-06 Operate Surface | v1 | Executed; product-surface framing superseded | `MISSION.md` §3 |
| `00-planning/EPIC-07-warp-prism-history-surface.md` | EPIC-07 History Surface | v1 | Executed; product-surface framing superseded | `MISSION.md` §3 |
| `00-planning/EPIC-08-warp-prism-governance-surface.md` | EPIC-08 Governance Surface | v1 | Executed; product-surface framing superseded | `MISSION.md` §3 |
| `00-planning/EPIC-09-warp-prism-universal-asset-detail.md` | EPIC-09 Universal Asset Detail | v1 | Executed | `04-completed/` task corpus |
| `00-planning/EPIC-10-warp-prism-polish-accessibility-demo-coherence.md` | EPIC-10 Polish/A11y/Demo | v1 | Executed | `04-completed/` task corpus |
| `00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | EPIC-11 CyberCore Frontend | v1 | Executed; CyberCore-as-consumer framing superseded | `docs/bridge/README.md` |
| `00-planning/EPIC-12-warp-prism-test-suite-stabilization-and-promotion-gates.md` | EPIC-12 Test Stabilization | v1 | Executed; promotion machinery now canonical | `docs/governance/promotion-state-model.md` |
| `00-planning/EPIC-13-warp-prism-ads-public-contract-and-catalog-hardening.md` | EPIC-13 ADS Public Contract | v1 | Executed; barrel lock now canonical | `docs/design/public-barrel-audit.md` |
| `00-planning/EPIC-14-warp-prism-observatory-legacy-contract-reconciliation.md` | EPIC-14 Observatory Legacy | v1 | Executed; Observatory-as-legacy-consumer now a classification question | `MISSION.md` §2 |
| `00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` | EPIC-15 Organism Expansion | v1 | Executed (1500–1616 completed); harvest method absorbed | `MISSION.md` §5; `docs/bridge/README.md` |
| `00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md` | EPIC-16 Ops/Transcript Organisms | v1 | Executed; harvest method absorbed | `MISSION.md` §5; `docs/bridge/README.md` |
| `00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` | EPIC-17 Form Primitives Gap | v1 | Executed except 1703, which remains live in `03-review/` | `03-review/1703-…` (active) |
| `00-planning/EPIC-19-warp-prism-v2-foundation.md` | EPIC-19 v2 Foundation | v2 planning | Stale executability wording (spine 1810–1817 executed); substance harvested | `MISSION.md`, `docs/architecture/layer-contracts.md` |
| `00-planning/EPIC-20-warp-prism-ids-kernel.md` | EPIC-20 IDS Kernel | v2 planning | Built, not planned (IDs package exists, PROVEN); wording stale | `packages/warp_prism_interaction/` (source reality) |
| `00-planning/EPIC-21-warp-prism-runtime-contracts-mvp.md` | EPIC-21 Runtime Contracts | v2 planning | Built, not planned (4 contracts exist as CODE); wording stale | `packages/warp_prism_runtime/` (source reality) |
| `00-planning/EPIC-22-warp-prism-frb-golden-path-integration-lab.md` | EPIC-22 FRB Golden Path | v2 planning | Built, not planned (2 crates exist); FRB-candidate caution harvested | `rust/`, `packages/warp_prism_adapter_frb/`, `MISSION.md` §4.4 |
| `00-planning/EPIC-23-warp-prism-connected-catalog-component-contract-registry.md` | EPIC-23 Connected Catalog | v2 planning | 23A executed (1826–1830); 23B absorbed into new program | `apps/catalog/`, new EPIC set |
| `00-planning/EPIC-24-warp-prism-scaffolding-extensibility-policy.md` | EPIC-24 Scaffolding Policy | v2 planning | Policy absorbed into mission; zero executable work existed | `MISSION.md` §6 |
| `00-planning/EPIC-25-warp-prism-rewrite-resolver-strategy.md` | EPIC-25 Rewrite Resolver | v2 planning | Rewrite-Factory framing superseded; L3 prohibition retained | `MISSION.md` §11.1 |
| `00-planning/EPIC-26-warp-prism-ads-ivisa-foundry-future-capability-catalog.md` | EPIC-26 Ivisa Foundry Catalog | v2 planning | Remains **CANDIDATE/reference only** per reset mandate; not promoted, not ported | Deferred candidate; no successor task |
| `00-planning/EPIC-OR-warp-prism-omniroute-cross-lane-anchors.md` | EPIC-OR OmniRoute Anchors | v2 planning | OmniRoute-centric anchoring superseded by Warpblade/Tempest/Hyperion/Sentry family; invariants harvested | `MISSION.md` §3, §5; `docs/bridge/README.md` |
| `00-planning/1829-warp-prism-first-real-product-pilot-hold.md` | Task 1829 First Real Product Pilot | post-L1 | OmniRoute-anchored; consumer family superseded. Record of a real operator gate | New program pilot story (consumer-family scoped) |
| `00-planning/1100-warp-prism-operational-atomic-design-system-epic.md` | Task 1100 Origin Epic | genesis | Genesis record; Voidframe→Warp Prism rename provenance | Historical provenance only |
| `00-planning/PLAN-03-review-drain.md` | PLAN-03 Review Drain | 2026-08-29 audit | Executed (lane 36→4, completed 132→191) | `04-completed/`; `03-review/` current state |
| `00-planning/PLAN-task1807-const-migration-containment.md` | PLAN Task 1807 Const Containment | 2026-08-31 | Self-declared SUPERSEDED-BY-REALITY | `boundary_test.dart` check #8 |
| `00-planning/ROADMAP-warp-prism-asw-observatory.md` | ROADMAP ASW Observatory | bootstrap | Goal ("read-only observability console") and namespace path both superseded | `MISSION.md` §3 |
| `00-planning/STORIES-ads-to-ids-epics-19-25.md` | STORIES Ads→Ids Packet v8 | 2026-08-29 synthesis | Coverage genome over an untrusted brainstorm transcript; self-declared NOT a task queue | Historical planning map only |
| `00-planning/CANDIDATE-2026-07-18-builder-wave-retrospect-and-skill-upgrades.md` | CANDIDATE Builder Retrospect | 2026-07-18 | Historical failure-pattern lesson; not current work | Historical lesson only |
| `00-planning/parent-tasks.md` | Parent Task Index | 2026-07-20 | Self-declared non-authoritative index; parent paths may have moved | Re-search parent repo on demand |
| `docs/ads-to-ids.md` | Ads→Ids brainstorm transcript (14,970 lines) | 2026-08-29 synthesis source | Raw untrusted brainstorm; derived corpus (STORIES packet, EPIC-19..25) already archived; zero live citations | Historical planning map only |
| `00-planning/epics/` | (empty directory) | — | Empty; no content | — |

## Retained in Active Planning

| Path | Why retained | Disposition |
|---|---|---|
| `00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md` | Still governs the open human visual gate (1805/1806/1807/1703 unblock chain) | CANONICAL_CURRENT (gate remnant) |
| `00-planning/1816-warp-prism-post-1805-visual-baseline-freeze.md` | Live P0 hold, gated on recorded Task 1805 human sign-off | CANONICAL_CURRENT (hold) |

## Stale References Corrected by This Reset

- `AGENTS.md` §3.3 / §5 no longer instruct builders to treat EPIC numbers as scheduling authority.
- `MISSION.md` no longer anchors consumers to Catalog / Observatory / CyberCore / OmniRoute.
- No active canonical document cites an archived artifact as current authority.
  Verified by grep sweep recorded in the reset report.
