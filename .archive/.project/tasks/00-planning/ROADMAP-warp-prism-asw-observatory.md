# ROADMAP — Warp-Prism ASW Observatory

> **Planning Status**: Active Roadmap
> **Executable?**: No — roadmap artifact only.
> **Task Namespace**: `warp-prism/docs/tasks/` local namespace starts at `0001` when executable tasks are promoted.
> **Naming Rule**: Planning artifacts use `ROADMAP-*`, `EPIC-*`, `STORY-*`, `PLAN-*`, `HOLD-*`, or `CANDIDATE-*`; executable tasks use `NNNN-warp-prism-*.md` only in `01-open/` or later lanes.

## Source Evidence

- `warp-prism/docs/prompt.txt` — original product contract for a Flutter desktop-first ASW Observatory.
- `warp-prism/docs/research.md` — research synthesis: unified harness map + execution ledger over one normalized graph.
- `warp-prism/docs/draft.md` — diagnostic of the v0-created codebase: partial design system, incomplete mock corpus, missing app shell/screens, probable compile breakage.

## Product Goal

Build a read-only Flutter desktop-first observability console for an Agent System Workspace. The app should visualize mocked `.agents/` and `docs/` assets as one graph-backed system spanning agents, skills, workflows, tasks, changelog entries, governance diagnostics, and historical evidence.

## Local Governance Decisions

1. Warp-prism owns a project-local task ledger under `warp-prism/docs/tasks/`.
2. Parent Ganthritor task ranges such as `4xxx`-`7xxx` are not inherited.
3. Executable warp-prism tasks start at `0001` only after promotion to `01-open/`.
4. `00-planning/` stores roadmap/epic/story/hold/candidate context and is not a builder queue.
5. All executable tasks promoted later must follow the full Ganthritor task template requirements adapted to Flutter validation commands.

## Epic Order

| Order | Planning Artifact | Core Gate |
| --- | --- | --- |
| 0 | `EPIC-00-warp-prism-foundation-compile-gate.md` | Project builds/analyzes enough for safe work. |
| 1 | `EPIC-01-warp-prism-atomic-design-system.md` | Design system complete and coherent before screens. |
| 2 | `EPIC-02-warp-prism-mock-workspace-corpus.md` | Required markdown/frontmatter corpus exists in `assets/mock_workspace/`. |
| 3 | `EPIC-03-warp-prism-data-layer-graph-backbone.md` | Normalized asset/edge graph and parsers exist. |
| 4 | `EPIC-04-warp-prism-product-shell-overview.md` | App entrypoint, router, shell, providers, overview dashboard exist. |
| 5 | `EPIC-05-warp-prism-map-surface.md` | Harness Map catalog/graph/inspector works over repositories. |
| 6 | `EPIC-06-warp-prism-operate-surface.md` | Task lane board and task detail work over mock tasks. |
| 7 | `EPIC-07-warp-prism-history-surface.md` | Changelog timeline/story/impact views work. |
| 8 | `EPIC-08-warp-prism-governance-surface.md` | Diagnostics for drift, canonicality, orphaning, proof gaps work. |
| 9 | `EPIC-09-warp-prism-universal-asset-detail.md` | Universal detail surface supports every asset kind. |
| 10 | `EPIC-10-warp-prism-polish-accessibility-demo-coherence.md` | Responsive, accessible, coherent demo-quality prototype. |
| **11** | **`EPIC-11-warp-prism-cybercore-frontend.md`** | **CyberCore frontend pilot and ADS expansion (existing).** |
| **12** | **`EPIC-12-warp-prism-test-suite-stabilization-and-promotion-gates.md`** | **Test suite becomes governance system. Promotion states, gate matrix, boundary tests, review packets.** |
| **13** | **`EPIC-13-warp-prism-ads-public-contract-and-catalog-hardening.md`** | **ADS package green gate. Prism namespace, contracts, gallery, catalog, goldens, toast, state vocabulary.** |
| **14** | **`EPIC-14-warp-prism-observatory-legacy-contract-reconciliation.md`** | **Observatory test suite green. Corpus, parsers, view-models, detail views, feature flows.** |

> **Note (2026-06-09)**: EPICs 12-14 are the **stabilization wave**. They do NOT
> add product features. They fix the governance layer (promotion semantics),
> the ADS contract (31 failures), and the Observatory integration (64 failures).
> Product expansion (EPICs 05-10, EPIC-11) resumes only after the stabilization
> wave completes. See `docs/reports/warp-prism-stabilization-strategy.md`.

## RF8 Framing

- **Goal**: Make governed agentic workspace structure understandable at a glance.
- **Domain**: Read-only ASW Observatory over mocked `.agents/` and `docs/` assets.
- **Feature**: Roadmap is decomposed into foundational, data, shell, screen, and polish epics.
- **Representation**: Atomic design system plus Design System Gallery; graph/story surfaces act as cognitive interfaces.
- **Specs**: `WorkspaceAsset`, `WorkspaceEdge`, `AssetKind`, `EdgeKind`, and `Canonicality` backbone.
- **Behaviour**: Search/filter/select assets, inspect links, view task lanes, read changelog stories, diagnose governance issues.
- **Test**: `flutter analyze`, `flutter test`, parser fixture tests, widget tests for core surfaces.
- **Eval**: Acceptance criteria in `prompt.txt` plus accessibility/readability/demo coherence.

## Promotion Policy

Future executable tasks should be created only after evidence-gathering agents compare each epic against the current codebase. Candidate tasks listed inside epics are not executable until promoted into `01-open/` with a local number and full template.
