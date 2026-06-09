# Warp Prism — RF8 Plan

> **Status**: Active planning artifact
> **Author**: Task 1101 — Warp Prism Charter And Naming Convergence
> **Date**: 2026-06-08

---

## 1. Overview

This document applies the RF8 framework (Goal → Domain → Feature →
Representation → Specs → Behaviour → Test → Eval) to the Warp Prism child
project. It separates the reusable ADS and observatory prototype work from
the Cybernetics Core migration/pilot work and maps each RF8 stage to the
local EPIC planning artifacts.

---

## 2. RF8 Stages

### 2.1 Goal

**Make governed agentic workspace structure understandable at a glance.**

Warp Prism produces two outputs:

1. A **reusable Flutter operational Atomic Design System** (`warp_prism_ui`)
   that any Ganthritor-family frontend can consume.
2. A **read-only ASW Observatory** (`warp_prism_observatory`) that visualizes
   mock workspace data as a graph-backed, storytelling, governance-aware
   console.

The first proof is the Design System Gallery — the ADS must exist and be
demonstrable before any product screen is built.

**Source evidence**: `docs/prompt.txt` (product contract), `docs/research.md`
(research synthesis), `docs/tasks/00-planning/ROADMAP-...md` (local roadmap).

---

### 2.2 Domain

The domain is **read-only Agent System Workspace observability** over mock
`.agents/` and `docs/` assets normalized into a graph model.

| Domain Concept | Description | EPIC |
|----------------|-------------|------|
| **Assets** | Agents, skills, sub-skills, workflows, tasks, changelog entries, scripts, references, rules | EPIC-02, EPIC-03 |
| **Edges** | contains, routesTo, dependsOn, references, changedBy, proves, uses | EPIC-03 |
| **Canonicality** | parentCanonical, childLocal, generated, appendOnly, archive, mock | EPIC-03, EPIC-08 |
| **Surfaces** | Map, Operate, History, Governance, Asset Detail, Overview | EPIC-04 through EPIC-09 |
| **Design System** | Tokens, atoms, molecules, organisms, templates, gallery | EPIC-01 |
| **Governance** | Drift, orphaning, proof gaps, fan-in, review pressure | EPIC-08 |

**Source evidence**: `docs/prompt.txt` (domain model section),
`docs/research.md` (relational model section),
`docs/mock-workspace-corpus-contract.md` (asset/edge enums).

---

### 2.3 Feature

The feature roadmap is decomposed into **ADS work** (inventory, scaffold,
tokens, components, catalog) and **product surface work** (mock corpus, data
layer, shell, screens, polish). CyberCore pilot work is **separate** and
gated behind the monorepo scaffold.

#### 2.3.1 ADS Track

| Story | Core Gate | EPIC / Task |
|-------|-----------|-------------|
| Naming and charter convergence | This document set exists | **Task 1101** (this task) |
| CyberCore control-surface inventory | Surface inventory and pilot matrix documented | Task 1102, EPIC-11 |
| Melos monorepo architecture plan | Package topology and CI gates defined | Task 1104 |
| Token / ThemeExtension / catalog policy | Token specs, golden policy, and accessibility baseline defined | Task 1105, EPIC-01 |
| Atomic and operational component MVP | Tokens through organisms pass catalog + widget test | Task 1106, EPIC-01 |
| Design System Gallery | Gallery route demonstrates all required tokens/components/states | EPIC-01 |

#### 2.3.2 Product Surface Track

| Story | Core Gate | EPIC / Task |
|-------|-----------|-------------|
| Foundation compile gate | `flutter analyze` passes or residual is documented | EPIC-00 |
| Mock workspace corpus | Required markdown/frontmatter files exist at correct counts | EPIC-02 |
| Data layer and graph backbone | Normalized graph model, parsers, and repositories exist | EPIC-03 |
| Product shell and overview | App launches, navigation works, overview dashboard shows derived metrics | EPIC-04 |
| Map surface | Catalog/graph/inspector views work over repositories | EPIC-05 |
| Operate surface | Task lanes, cards, detail, and filters work | EPIC-06 |
| History surface | Changelog timeline/story/impact views work | EPIC-07 |
| Governance surface | Drift, canonicality, orphan, proof diagnostics work | EPIC-08 |
| Universal asset detail | Detail page works for all asset kinds | EPIC-09 |
| Polish, accessibility, demo coherence | WCAG, responsive, storytelling, performance pass | EPIC-10 |

#### 2.3.3 CyberCore Pilot Track (Separate from ADS/Surface work)

| Story | Core Gate | EPIC / Task |
|-------|-----------|-------------|
| CyberCore frontend scope and route parity matrix | Scope decision and route inventory exist | Task 1108, EPIC-11 |
| CyberCore API/data contract inventory | Read-only API surface documented | Task 1109, EPIC-11 |
| CyberCore fixture-backed app shell MVP | Pilot app compiles in monorepo, consumes `warp_prism_ui` | Task 1110, EPIC-11 |
| CyberCore pilot mirror and expansion gate | Two pilot surfaces pass catalog + widget test + ADS compatibility | Task 1111, EPIC-11 |
| Critical ADS gap resolution | Data table, command palette, log viewer resolved or deferred | Tasks 1112–1118, EPIC-11 |

**Source evidence**: `docs/tasks/00-planning/1100-...epic.md` (story breakdown,
candidate tasks), `docs/tasks/00-planning/EPIC-00` through `EPIC-11`.

---

### 2.4 Representation

| Artifact | Location | Purpose |
|----------|----------|---------|
| **Design docs** | `docs/design/` | Charter, naming policy, this RF8 plan, future specs |
| **Task ledger** | `docs/tasks/` | Five-lane governed work execution |
| **Changelog** | `docs/changelog/` | Append-only change ledger |
| **Reports** | `docs/reports/` | Audits, gap analyses, sweeps |
| **Mock corpus** | `assets/mock_workspace/` | Markdown/frontmatter ASW data |
| **ADS package** | `packages/warp_prism_ui/` (planned) | Reusable Flutter components |
| **Catalog app** | `packages/warp_prism_catalog/` (planned) | ADS validation gallery |
| **Observatory app** | `apps/observatory/` (planned) | ASW Observatory prototype |
| **CyberCore pilot** | `apps/cybercore/` (planned) | Fixture-backed CyberCore mirror |
| **State matrices** | Component-level docs (planned) | Behaviour state vocabulary per component |

**Source evidence**: `AGENTS.md` §2 (parent/child boundary),
`docs/tasks/00-planning/ROADMAP-...md` (governance decisions).

---

### 2.5 Specs

| Spec Domain | Key Contracts | Source |
|-------------|---------------|--------|
| **Asset model** | `WorkspaceAsset { id, kind, name, path, description, canonicality, frontmatter, tags, triggers, edges }` | EPIC-03, `prompt.txt` |
| **Edge model** | `WorkspaceEdge` with typed `EdgeKind { contains, routesTo, dependsOn, references, changedBy, proves, uses }` | EPIC-03, `prompt.txt` |
| **Canonicality** | `Canonicality { parentCanonical, childLocal, generated, appendOnly, archive, mock }` | EPIC-03, `prompt.txt` |
| **Token specs** | Color, typography, spacing, radii, shadows, motion, semantics | EPIC-01, Task 1105 |
| **Component API specs** | Props, variants, and slot contracts per atom/molecule/organism | EPIC-01, Task 1106 |
| **Operational state vocabulary** | Default, disabled, loading, error, degraded, redacted, exposed, narrow, long text, high text scale, reduced motion + CyberCore expansions (14+ states) | EPIC-01, EPIC-11 |
| **Catalog / golden policy** | Every promoted component must have a catalog case, widget test, and semantics check | EPIC-01, Task 1105 |
| **Mock data contract** | File counts, frontmatter schemas, directory structure | EPIC-02, `docs/mock-workspace-corpus-contract.md` |

---

### 2.6 Behaviour

The ASW Observatory and ADS must support the following behavioural states:

#### 2.6.1 Component-Level States (ADS)

| State | Description |
|-------|-------------|
| **Default** | Normal resting state |
| **Disabled** | Non-interactive, visually dimmed |
| **Loading** | Skeleton or progress indicator |
| **Error** | Failure state with message |
| **Degraded** | Partial data, missing edges, incomplete graph |
| **Redacted** | Content hidden but structure visible |
| **Exposed** | Selected, focused, or inspected |
| **Narrow** | Responsive compressed layout |
| **Long text** | Overflow handling |
| **High text scale** | Accessibility text scaling |
| **Reduced motion** | Motion-sensitive users |

#### 2.6.2 Surface-Level Interactions (Observatory)

| Surface | Key Interactions |
|---------|-----------------|
| **Map** | Browse agents/skills/workflows, search/filter, select node to inspect, switch graph modes (containment, operational, evidence) |
| **Operate** | View task lanes, filter by lane/owner/proof state, inspect task detail, navigate to related skills/workflows/changelog |
| **History** | Browse changelog timeline, filter by project/type/skill/task, switch to story mode, follow impact paths |
| **Governance** | View diagnostic panels (orphans, stale refs, proof gaps, fan-in), drill down to affected assets |
| **Asset Detail** | View any asset's metadata, body, incoming/outgoing links, related tasks/changelog |
| **Overview** | View derived metrics, current story, blockers, review queue, governance warnings |

**Source evidence**: `docs/prompt.txt` (UX requirements, interaction
requirements), `docs/research.md` (visibility frontend sections).

---

### 2.7 Test

| Test Category | Command / Method | Scope |
|---------------|------------------|-------|
| **Format** | `dart format --set-exit-if-changed .` | All Dart files |
| **Analyze** | `flutter analyze` | All Dart files — zero errors |
| **Unit tests** | `flutter test` | Model, parser, repository, service, provider tests |
| **Widget tests** | `flutter test test/widgets/` | Core component tests for atoms/molecules/organisms |
| **Golden tests** | `flutter test --update-goldens test/goldens/` | Visual regression for design system components |
| **Semantics tests** | `flutter test test/semantics/` | Accessibility label and traversal tests |
| **Catalog smoke** | Manual or automated: launch gallery, navigate all sections | ADS Gallery completeness |
| **Parser fixtures** | `flutter test test/parsers/` | Frontmatter extraction, graph normalization |
| **Melos gate (future)** | `melos run analyze && melos run test` | Monorepo-wide validation |

**Validation baseline**: Until EPIC-00 is complete, `flutter analyze` may
have documented residual failures. After EPIC-00, zero-error is the gate.

**Source evidence**: `docs/prompt.txt` (acceptance criteria, delivery order),
`docs/tasks/00-planning/EPIC-00-...foundation-compile-gate.md`.

---

### 2.8 Eval

Evaluation criteria determine when the project is ready to advance past its
current phase.

#### 2.8.1 ADS Readiness Gate (Phase 1 → Phase 2+)

The ADS is ready when:

- [ ] Gallery demonstrates all required tokens, atoms, molecules, organisms, templates, and behavioural states.
- [ ] Feature screens can compose DS primitives without local hardcoded styling.
- [ ] Component names/APIs are consistent enough for analyzer and widget tests.
- [ ] Accessibility and readability constraints are explicit in promoted tasks.
- [ ] Every promoted component has a catalog case, widget test, and semantics check.

#### 2.8.2 Observatory Readiness Gate (Phase 2+ → Polish)

The Observatory is ready when:

- [ ] App launches into a coherent shell with navigation to all required surfaces.
- [ ] Map, Operate, History, Governance, and Asset Detail surfaces function over mock data.
- [ ] The graph backbone powers all surfaces from one normalized model.
- [ ] Tasks, changelog, and assets show correct relationships and can be navigated.
- [ ] Loading, empty, error, and degraded states are handled consistently.

#### 2.8.3 CyberCore Pilot Gate (ADS → CyberCore)

The CyberCore pilot is ready when:

- [ ] Scope decision and route parity matrix exist (Task 1108).
- [ ] Pilot app compiles and tests inside the Warp Prism monorepo (Task 1110).
- [ ] At least two pilot surfaces have fixtures, catalog cases, widget tests, and semantics checks (Task 1111).
- [ ] ADS changes are validated against the catalog, Observatory, and CyberCore pilot in one monorepo gate.
- [ ] Critical ADS gaps (data table, command palette, log viewer) are resolved or explicitly deferred.

#### 2.8.4 Demo Readiness Gate (Polish → Present)

The prototype is demo-ready when all 13 acceptance criteria from `prompt.txt`
are met, with particular emphasis on:

- The first implemented milestone was the design system, not product screens.
- The app visually matches ultradark obsidian glass with restrained accents.
- The app remains readable and accessible.
- The demo clearly answers: what exists, what matters now, why it changed,
  what is risky, and how assets connect.

**Source evidence**: `docs/prompt.txt` (acceptance criteria),
`docs/tasks/00-planning/1100-...epic.md` (validation/promotion criteria),
`docs/tasks/00-planning/EPIC-11-...cybercore-frontend.md` (completion criteria).

---

## 3. Dependency Graph

```
EPIC-00 (Compile Gate)
  └─→ EPIC-01 (ADS)
       └─→ EPIC-04 (Shell) ──→ EPIC-05 (Map)
                            ──→ EPIC-06 (Operate)
                            ──→ EPIC-07 (History)
                            ──→ EPIC-08 (Governance)
                            ──→ EPIC-09 (Universal Detail)
       └─→ Task 1106 (Component MVP)
            └─→ EPIC-11 (CyberCore Pilot) — gated on Task 1107 (Melos)

EPIC-00 ──→ EPIC-02 (Mock Corpus)
              └─→ EPIC-03 (Data Layer)
                   └─→ EPIC-04 through EPIC-09

EPIC-05 through EPIC-09 ──→ EPIC-10 (Polish)
```

Task 1101 (this task) has **no technical dependencies** — it is a governance
prerequisite that produces the docs other tasks cite.

---

## 4. Key Decisions and Rationale

| Decision | Rationale |
|----------|-----------|
| ADS before screens | `prompt.txt` makes this a non-negotiable execution rule. |
| Read-only until explicitly authorized | `AGENTS.md` §5 constraint; prevents governance bypass. |
| Mock data over live infrastructure | Safer, testable, no auth/infra dependency. |
| One normalized graph | `research.md` conclusion: harness map + execution ledger share one backbone. |
| Separated CyberCore pilot | Avoids premature migration risk; validates ADS against a real domain. |
| `Prism*` component prefix | Distinguishes public API from internal `DS`/`Ds` classes; prevents namespace collision. |
| `Voidframe` superseded | Historical codename; preventing accidental resurrection of stale naming. |
| Melos monorepo (planned) | Task 1104 will formalize; keeps ADS package app-agnostic. |
| No SQLite | `AGENTS.md` §5 constraint; PostgreSQL/Redis if ever needed. |

---

## 5. Source Evidence

| Source | Relevance |
|--------|-----------|
| `docs/prompt.txt` | Product contract, domain model, visual direction, acceptance criteria |
| `docs/research.md` | Architecture decisions, Flutter stack, UX recommendations |
| `docs/draft.md` | V0 codebase diagnostic, gap report, recovery order |
| `docs/mock-workspace-corpus-contract.md` | Mock data schema and migration contract |
| `AGENTS.md` | Product constraints, governance, protected files |
| `docs/tasks/00-planning/1100-...epic.md` | Epic breakdown, candidate tasks, guardrails |
| `docs/tasks/00-planning/EPIC-00` through `EPIC-11` | Local epic planning — source of truth for scope |
| `docs/tasks/00-planning/ROADMAP-...md` | Active roadmap, RF8 framing, epic ordering |
| Task 8210, 8220, 8230, 8240 (historical) | Provenance evidence for Voidframe-era planning |
| Task 0583, 0590 (completed) | CyberCore admin design-system baseline |
