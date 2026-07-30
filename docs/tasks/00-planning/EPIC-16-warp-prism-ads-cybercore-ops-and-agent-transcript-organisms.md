# EPIC 16 — Warp Prism ADS: CyberCore Ops + Agent Transcript Organisms

> **Planning Status**: Active Epic  
> **Executable?**: No — planning only. Executable work: `Task 16NN` / related `15NN` extensions.  
> **Promotion Gate**: Prefer after EPIC-15 Waves A–F are in flight or stable enough that gallery capacity exists; may start inventory + PageShell/Tree in parallel with EPIC-15.  
> **Origin**: 2026-07-10 harvests — OmniRoute visual-reference, `warp-prism/references/` catalog triage, atomic DS hygiene (judatop/ahmedm).  
> **Depends on**: EPIC-01, EPIC-13 (Prism barrel), EPIC-11 (CyberCore pilot fixtures). Soft: EPIC-15 (shared gallery/catalog surface).  
> **Related harvest reports**:  
> - `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`  
> - `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`  
> - `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`  
> - `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`

---

## Goal

Grow the ADS with **net-new organisms** for:

1. **CyberCore ops consoles** (provider health, traffic, MCP inspect, timing) — fixture-first while Go backend lands.  
2. **Agent transcript / tool-call surfaces** (DeepChat / Open WebUI patterns).  
3. **Generic content chrome** missing from EPIC-15 Map HUD: page shell + hierarchical tree (OmniRoute visual-ref).  
4. **Package hygiene** patterns from external Flutter ADS kits (not widget ports).

**Do not**: rebrand Observatory to OmniRoute teal; port MapLibre/Recharts/Widgetbook; re-open EPIC-15 Map HUD scope.

---

## Visibility surface (catalog / “storybook”)

| Fact | Detail |
| --- | --- |
| **Not Widgetbook** | Deferred by policy (`docs/design/token-theme-catalog-policy.md`) — custom catalog MVP. |
| **Proof surface** | `DesignSystemGalleryPage` + registry/sections inside `packages/warp_prism_ui`. |
| **Host app** | `apps/catalog/` → thin shell: `MaterialApp` → gallery page. |
| **Also** | Observatory route `/design-system` (demo script). |
| **Show someone today** | `cd apps/catalog && flutter run` (desktop/web target as available). |
| **Gap** | README only documents Observatory `flutter run`; catalog run path under-documented; section discovery for many organisms is scroll-heavy. |

Epic includes **Task 1600/visibility** work so stakeholders can be shown ADS without guessing commands.

---

## Idea catalog (net-new; not EPIC-15 duplicates)

| ID | Proposed organism | Origin | Fit |
| --- | --- | --- | --- |
| C-01 | `PrismPageShell` | OmniRoute visual-ref page chrome | Content page header (≠ `DSShell`) |
| C-02 | `PrismTree` | OmniRoute tree | Hierarchy + status/meta/selection |
| C-03 | `PrismAgentTranscript` | DeepChat / Open WebUI | Scrollable agent conversation |
| C-04 | `PrismToolCallCard` | DeepChat tool blocks | Tool name/args/result card |
| C-05 | `PrismMessageStatusHistory` | Open WebUI status pipeline | Compact status step strip |
| C-06 | `PrismArtifactWorkbench` | DeepChat artifacts | Side panel for generated artifacts |
| C-07 | `PrismProviderHealthMatrix` | OmniRoute / CyberCore | Grid of provider health cells |
| C-08 | `PrismMcpCapabilityInspector` | CyberCore MCP inspect | Capability/tool list inspector |
| C-09 | `PrismTimingWaterfall` | OmniRoute timing views | Request timing bars (fixture data) |
| C-10 | `PrismTrafficInspector` | OmniRoute traffic | Request/response inspect MVP |
| C-11 | `PrismWorkflowCanvasStage` contract | Sim Studio | Workflow DAG stage **contract** (not map stage O-17) |
| C-12 | `PrismExecutionConsole` | Sim Studio terminal | Streamed execution log console (distinct from EPIC-15 terminal workspace) |
| C-13 | Interactive state matrix + package purity checklist | judatop / ahmedm | Governance / hygiene — not a widget port |

### Explicit skips

- OmniRoute teal rebrand; Orbitron/scanlines; Recharts ports.  
- Login/product pages from villa/judatop.  
- Mesh crypto, live keys, mutation ALLOW/BLOCK panels.  
- Duplicating EPIC-15 O-01–O-22 HUD/map/OSINT set.

---

## Waves

| Wave | Theme | IDs |
| --- | --- | --- |
| **V** | Visibility + inventory | Catalog showability, epic brief |
| **J** | Content chrome | C-01, C-02 |
| **K** | Agent transcript family | C-03–C-06 |
| **L** | CyberCore ops inspect | C-07–C-10 |
| **M** | Workflow/execution contracts | C-11, C-12 |
| **N** | Hygiene | C-13 |
| **X** | Gallery + goldens + acceptance | cross |

---

## Candidate tasks (IDs 1600–1616)

| Task | Name | Wave |
| --- | --- | --- |
| 1600 | EPIC-16 inventory + catalog showability brief | V |
| 1601 | Document + verify catalog/gallery demo path (README + smoke) | V |
| 1602 | `PrismPageShell` organism | J |
| 1603 | `PrismTree` organism | J |
| 1604 | `PrismAgentTranscript` organism | K |
| 1605 | `PrismToolCallCard` + status history strip | K |
| 1606 | `PrismArtifactWorkbench` organism | K |
| 1607 | `PrismProviderHealthMatrix` organism | L |
| 1608 | `PrismMcpCapabilityInspector` organism | L |
| 1609 | `PrismTimingWaterfall` + `PrismTrafficInspector` MVP pack | L |
| 1610 | `PrismWorkflowCanvasStage` contract | M |
| 1611 | `PrismExecutionConsole` organism | M |
| 1612 | ADS package purity + interactive state matrix hygiene | N |
| 1613 | EPIC-16 gallery/catalog registration | X |
| 1614 | EPIC-16 goldens + boundary audit | X |
| 1615 | EPIC-16 acceptance audit | X |
| 1616 | Optional: CyberCore teal ThemeExtension skin (not Observatory default) | optional |

---

## Acceptance (epic)

- [ ] Catalog/gallery can be demoed with documented command in README.  
- [ ] C-01–C-12 either delivered or explicitly deferred with reason.  
- [ ] No teal Observatory rebrand; no MapLibre/Recharts ports.  
- [ ] Public `Prism*` + boundaries 6/6.  
- [ ] Fixture-first for all CyberCore-facing organisms.

---

## Relationship to EPIC-15

| EPIC-15 | EPIC-16 |
| --- | --- |
| Map HUD, layers, intel, OSINT, stage chrome | Ops health, agent chat transcript, page shell, tree |
| Waves A–I | Waves V, J–N, X |
| Do not block 15 on 16 | Can start 1600–1603 in parallel with 15 Wave A |

---

*Created 2026-07-10. Planning only.*
