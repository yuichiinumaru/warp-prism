# Warp Prism — Child-Project Charter

> **Status**: Active charter
> **Author**: Task 1101 — Warp Prism Charter And Naming Convergence
> **Date**: 2026-06-08
> **Parent**: Ganthritor monorepo

---

## 1. Purpose

Warp Prism is a **Ganthritor child project** that owns a reusable Flutter
operational Atomic Design System (ADS) and a read-only Agent System Workspace
Observatory prototype. Its first job is to turn mock ASW data into a
high-polish, desktop-first, graph-backed observability console that makes
governed agentic workspace structure understandable at a glance.

The project lives under `warp-prism/` in the Ganthritor repository. It
inherits reusable skills and agent definitions from the parent through
symlinks (see `AGENTS.md` §2) but owns its local task namespace, design
documents, changelog, reports, and profiles.

---

## 2. Product Identity

| Attribute | Value |
|-----------|-------|
| **Project name** | Warp Prism |
| **Product name** | ASW Observatory |
| **Technology** | Flutter (desktop-first) |
| **Data source** | Mock `.agents/` and `docs/` markdown corpus with YAML frontmatter |
| **Write policy** | Read-only until a future task explicitly authorizes mutation |
| **Visual direction** | Ultradark obsidian glass, 5% hacker, 5% protoss — restrained, serious, command-center aesthetic |
| **First proof target** | Design System Gallery route proves the ADS exists before any product screen is built |

---

## 3. Scope

### 3.1 In Scope

- **Reusable Flutter ADS package** (`warp_prism_ui`): tokens, atoms, molecules,
  organisms, templates, and a gallery/catalog — app-agnostic, testable, and
  governed by catalog + widget test + semantics coverage gates.

- **ASW Observatory app** (`warp_prism_observatory`): a desktop-first Flutter
  application that visualizes mock workspace data across four surfaces:
  Map, Operate, History, and Governance — plus a universal Asset Detail view.

- **Mock workspace corpus**: realistic `.md` files with YAML frontmatter under
  `assets/mock_workspace/`, covering agents, skills, workflows, tasks, and
  changelog entries per `docs/mock-workspace-corpus-contract.md`.

- **Data layer and graph backbone**: normalized `WorkspaceAsset`,
  `WorkspaceEdge`, `AssetKind`, `EdgeKind`, and `Canonicality` models powering
  all screens from one read-only repository (EPIC-03).

- **Design documentation** under `docs/design/`: charter, naming policy, and
  planning artifacts that anchor future implementer decisions.

- **Cybernetics Core pilot**: a fixture-backed Flutter app (`warp_prism_cybercore`)
  that consumes `warp_prism_ui`, mirrors selected CyberCore admin surfaces with
  fixed fixtures, and validates ADS fitness-for-purpose against a real domain
  (EPIC-11). This is a pilot, not a migration.

### 3.2 Out of Scope (Non-Goals)

| Non-Goal | Rationale |
|----------|-----------|
| **Tamagui / Ivisa code porting** | Ivisa/Tamagui archaeology (Task 8240) is reference-only. Component stories, variants, and state matrices are harvested; TSX is not ported. |
| **Hyperion-first work** | Hyperion is a future consumer. Warp Prism's first proof is the ADS catalog and CyberCore pilot, not Hyperion integration. |
| **Full Cybernetics Core Flutter migration** | The first CyberCore target is a fixture-backed pilot mirror (EPIC-11), not a destructive replacement of the existing Next.js frontend under `cyberneticscore/apps/frontend/`. |
| **Backend writes / live API mutation** | The observatory and ADS are read-only. No backend mutation, runtime orchestration, or hidden service dependencies. |
| **SQLite or client-side durable state** | Per AGENTS.md §5, route durable-state design through PostgreSQL/Redis governance if ever needed. |
| **Generic SaaS pastel dashboard** | The visual direction is ultradark obsidian glass with restrained hacker/protoss accents, not Material default or generic SaaS. |

---

## 4. Historical Context and Provenance

### 4.1 Voidframe (Superseded)

The project was originally conceived under the codename **Voidframe**. Key
historical artifacts:

- **Task 8210**: Control-surface inventory that remains useful as historical
  evidence but uses `Voidframe` naming. Not deleted; treated as provenance.
- **Task 8220**: Defined a prior `Voidframe` Flutter ADS kernel concept.
  Superseded by Warp Prism planning.
- **Task 8230**: Defined a Cybernetics Core pilot concept under Voidframe.
  Superseded by EPIC-11.

`Voidframe` is **historical naming only**. No new packages, apps, or public
components shall use the `voidframe_*` prefix. See `docs/design/naming.md`
for the full supersession policy.

### 4.2 Cybernetics Core Design-System Evidence

- **Task 0583**: Documented the current Cybernetics Core admin design-system
  baseline.
- **Task 0590**: Implemented Cybernetics Core's admin design-system baseline.

Both tasks provide baseline evidence that Warp Prism's CyberCore pilot must
match or exceed. They are cited as source evidence in EPIC-11.

### 4.3 Existing Flutter App

Warp Prism is **not empty**. A prior generation (v0) created a partial Flutter
application under `lib/` including:

- Design system tokens, atoms, molecules, organisms, templates, and gallery.
- Data models, parsers, repositories, providers, and services.
- Feature pages for Map, Operate, History, Governance, and Asset Detail.
- An app shell with routing and responsive layout scaffolding.

The `docs/draft.md` diagnostic identified compile-breaking naming/API
inconsistencies (e.g., `DSColors` vs `DsColors`, `DSShell` vs `DsShell`,
mismatched template parameters) and incomplete mock data. EPIC-00 addresses
the compile gate. Future tasks must read existing code before modifying.

---

## 5. Governance

### 5.1 Parent/Child Boundary

Parent-canonical reusable surfaces (skills, agents, agent definitions) are
symlinked from the Ganthritor root. Child-local surfaces (AGENTS.md, tasks,
changelog, reports, design docs, profiles) are owned by Warp Prism. Do not
copy parent skills into the child project.

### 5.2 Task Namespace

Warp Prism owns `docs/tasks/` with five lanes:

| Lane | Purpose |
|------|---------|
| `00-planning/` | Roadmaps, epics, stories, plans — not executable |
| `01-open/` | Template-complete tasks ready for builders |
| `02-doing/` | Active execution |
| `03-review/` | Completed work awaiting review |
| `04-completed/` | Reviewer-approved work |

Executable tasks follow `docs/tasks/000-template.md`, must be ≥50 lines, and
must require reading existing code/docs as the first subtask.

### 5.3 Monorepo Architecture (Planned)

Task 1104 will formalize the Melos monorepo architecture. The planned package
topology is:

| Package | Role |
|---------|------|
| `packages/warp_prism_ui` | Reusable Flutter ADS (app-agnostic) |
| `packages/warp_prism_catalog` | Gallery/catalog app for ADS validation |
| `apps/observatory` | ASW Observatory prototype |
| `apps/cybercore` | CyberCore pilot (fixture-backed, not a migration) |

Until Melos migration completes (Task 1107), packages are conceptual — no
scaffold is created in this task.

---

## 6. Acceptance Criteria for This Charter

- [x] Warp Prism is defined as a Ganthritor child project, not a generic folder.
- [x] Purpose, scope, and non-goals are explicit.
- [x] First proof target (ADS Gallery) is identified.
- [x] Voidframe is documented as historical and superseded.
- [x] Historical tasks (8210, 8220, 8230, 8240, 0583, 0590) are cited as source evidence.
- [x] Existing Flutter app state is acknowledged.
- [x] Monorepo architecture direction is referenced.
- [x] Tamagui code porting, Hyperion-first work, and full CC migration are explicit non-goals.

---

## 7. Source Evidence

| Source | Relevance |
|--------|-----------|
| `docs/prompt.txt` | Original product contract for the ASW Observatory |
| `docs/research.md` | Research synthesis: unified harness map + execution ledger |
| `docs/draft.md` | Diagnostic of v0-created codebase |
| `docs/mock-workspace-corpus-contract.md` | Mock data naming and schema contract |
| `docs/tasks/00-planning/1100-...epic.md` | Warp Prism operational ADS epic |
| `docs/tasks/00-planning/EPIC-00` through `EPIC-11` | Local epic planning |
| `docs/tasks/00-planning/ROADMAP-...md` | Active roadmap |
| Task 8210 (historical) | Control-surface inventory with Voidframe naming |
| Task 8220 (historical) | Voidframe Flutter ADS kernel concept — superseded |
| Task 8230 (historical) | CyberCore pilot concept under Voidframe — superseded |
| Task 8240 (historical) | Ivisa/Tamagui archaeology — reference only |
| Task 0583 (completed) | CyberCore admin design-system baseline documentation |
| Task 0590 (completed) | CyberCore admin design-system baseline implementation |
