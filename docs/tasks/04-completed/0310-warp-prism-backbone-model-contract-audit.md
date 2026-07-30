# Task 0310: Warp-Prism Backbone Model Contract Audit

> **Status**: `[x]` Completed — independent path100 re-review 2026-07-18 S=100/100
> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0310-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC 03 promotion from `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
> **Blocks**: Task 0311, Task 0312, Task 0313, Task 0314, Task 0315
> **Depends on**: Stable mock corpus contract from EPIC 02, or equivalent reviewed asset-path decision

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0310` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references.
>
> **Path note (monorepo)**: Implementation lives under `apps/observatory/` after package
> layout migration. Task `Where` rows retain original relative names; live paths are
> `apps/observatory/lib/data/models/*` and `apps/observatory/test/data/models/*`.

---

## Objective

Replace the current generic `Asset` / `AssetType` / `AssetEdge` data model with the normalized Warp-Prism backbone required by the product contract: `AssetKind`, `EdgeKind`, `Canonicality`, `WorkspaceAsset`, `WorkspaceEdge`, task lane metadata, changelog metadata, and governance diagnostic primitives. This task is only complete when downstream parser, repository, graph, and provider work can target a stable typed contract instead of inventing ad-hoc maps or reusing the current incomplete enums.

## Background Context

### O que ja existe:
- `warp-prism/lib/data/models/models.dart` defines broad `Agent`, `Skill`, `Workflow`, `Task`, `ChangelogEntry`, and `AssetEdge` classes.
- `warp-prism/docs/prompt.txt` already defines the intended graph backbone concepts and required asset kinds.
- `warp-prism/docs/research.md` recommends one normalized graph shared by Harness Map and Execution Ledger.

### O que esta faltando / quebrado:
- `AssetType` only covers `agent`, `skill`, `workflow`, `task`, and `doc`, which omits `subskill`, `changelog`, `script`, `reference`, and `rule`.
- There is no `Canonicality` model even though the prompt and research require canonical/generated/archive/mock provenance.
- Task- and changelog-specific metadata are mixed into bespoke classes rather than normalized graph-friendly asset payloads.
- There is no typed diagnostic surface for proof gaps, stale references, orphan assets, or review pressure.

---

## Test Requirements

- The backbone DEVE expose enums/classes covering every required prompt concept: `AssetKind`, `EdgeKind`, `Canonicality`, `WorkspaceAsset`, and `WorkspaceEdge`.
- The model layer DEVE represent task lane, verification, dependency, and completion-evidence metadata without forcing UI code to parse markdown bodies directly.
- The model layer DEVE represent changelog project/task/type/evidence linkage as typed metadata rather than loose string blobs.
- The model layer DEVE support governance diagnostics through typed severity/category payloads that later services can compute.

---

## Exit Conditions (GDD/TDD)

- [x] Normalized backbone models are implemented under `apps/observatory/lib/data/models/` and exported through the local model barrel.
- [x] Legacy generic graph primitives are either removed or clearly superseded so downstream code has one canonical contract.
- [x] `flutter analyze lib/data/models test/data/models` passes without errors. **PASS 2026-07-09: No issues found**
- [x] `flutter test test/data/models/workspace_graph_models_test.dart` passes with 0 failures. **PASS 2026-07-09: +27 All tests passed**
- [x] Entry in changelog is added under `docs/changelog/`. **PASS: `docs/changelog/20260709-122047-0310-backbone-model-contract-audit-builders.md`**

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: Read prompt contract + all backbone files under `apps/observatory/lib/data/models/`. Confirmed AssetKind=9/9, EdgeKind=7/7, Canonicality=6/6; legacy AssetType remains superseded.
- [x] Define the normalized asset/edge backbone and decide whether existing specialized classes remain wrappers or are rewritten to compose `WorkspaceAsset` metadata. **Decision**: Legacy models.dart retained but superseded; new backbone is canonical.
- [x] Add typed metadata objects for task lanes, changelog linkage, and governance diagnostics that downstream services can consume without reparsing markdown.
- [x] Create model tests that assert enum coverage, canonicality handling, and metadata serialization/equality expectations.
- [x] **Refactoring pass**: Implementation focused across backbone files + barrel. No bloat detected.
- [x] **Documentation update**: Audit report at docs/reports/0310-backbone-model-contract-audit.md. models.dart doc comment has SUPERSEDED notice.
- [x] **Verificacao de regressao**: `flutter analyze` clean; `flutter test` 27/27 green (2026-07-09 revalidation).

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - confirmar o contrato do backbone exigido pelo produto |
| `warp-prism/docs/research.md` | Ler - confirmar a recomendacao de grafo unificado |
| `warp-prism/docs/draft.md` | Ler - confirmar gaps do modelo atual |
| `apps/observatory/lib/data/models/models.dart` | Ler/Modificar - legacy SUPERSEDED notice retained |
| `apps/observatory/lib/data/models/workspace_graph.dart` | Backbone: AssetKind, EdgeKind, Canonicality, WorkspaceAsset, WorkspaceEdge |
| `apps/observatory/lib/data/models/task_contracts.dart` | TaskLane, ProofState, TaskMetadata, parsing extensions |
| `apps/observatory/lib/data/models/changelog_contracts.dart` | ChangelogType, ChangelogMetadata, parsing extension |
| `apps/observatory/lib/data/models/governance_diagnostics.dart` | DiagnosticSeverity, DiagnosticCategory, GovernanceDiagnostic |
| `apps/observatory/lib/data/models/data_models.dart` | Barrel export for backbone |
| `apps/observatory/test/data/models/workspace_graph_models_test.dart` | Backbone contract tests (27 cases) |

### How

1. Compare the prompt contract against the current `models.dart` surface and write the missing type inventory first.
2. Introduce one canonical backbone model that all later parsers and repositories can target.
3. Keep compatibility shims only if they are required by already-existing callers inside `warp-prism/lib`; otherwise prefer one clean contract.
4. Lock the contract with focused unit tests before moving to parser/repository tasks.

### Why

Every later Warp-Prism screen depends on one shared graph backbone. If this task is skipped or left vague, parsers, repositories, graph builders, and providers will each invent their own partial structure, making EPIC 04-09 harder to test and easier to break.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT leave both a legacy generic graph contract and a new normalized contract active without an explicit ownership decision. Downstream tasks need one source of truth.

> [!IMPORTANT]
> Read every file in `Where` before writing, and verify the model names against `warp-prism/docs/prompt.txt` instead of paraphrasing them from memory.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (implementation)**:
  - `apps/observatory/lib/data/models/workspace_graph.dart` — AssetKind, EdgeKind, Canonicality, WorkspaceAsset, WorkspaceEdge
  - `apps/observatory/lib/data/models/task_contracts.dart` — TaskLane, ProofState, TaskMetadata, parsing extensions
  - `apps/observatory/lib/data/models/changelog_contracts.dart` — ChangelogType, ChangelogMetadata, parsing extension
  - `apps/observatory/lib/data/models/governance_diagnostics.dart` — DiagnosticSeverity, DiagnosticCategory, GovernanceDiagnostic
  - `apps/observatory/lib/data/models/data_models.dart` — barrel export
  - `apps/observatory/lib/data/models/models.dart` — SUPERSEDED doc notice retained
  - `apps/observatory/test/data/models/workspace_graph_models_test.dart` — 27 test cases
  - `docs/reports/0310-backbone-model-contract-audit.md` — audit report (validation section refreshed)
- **Arquivos criados/modificados (2026-07-09 revalidation)**:
  - `docs/changelog/20260709-122047-0310-backbone-model-contract-audit-builders.md`
  - this task file (exit conditions unblocked, evidence filled, path notes)
  - `.agents/profiles/builders/continuity-260709122100-task-0310-backbone-model-contract-review-handoff.md`
- **Testes que verificam o trabalho**: `workspace_graph_models_test.dart` — 27 tests covering enum counts, all required values, WorkspaceAsset/WorkspaceEdge construction/equality/copyWith, TaskLane parsing round-trip, ProofState parsing, TaskMetadata, ChangelogMetadata, GovernanceDiagnostic severity ordering, DiagnosticCategory coverage
- **Resultado dos comandos de validacao** (cwd `apps/observatory`, 2026-07-09):
  - `flutter analyze lib/data/models test/data/models` → **No issues found!**
  - `flutter test test/data/models/workspace_graph_models_test.dart` → **+27 All tests passed!**
- **Entrada no CHANGELOG**: `docs/changelog/20260709-122047-0310-backbone-model-contract-audit-builders.md`
- **Agent-wiki / docs institucionalizacao**: `docs/reports/0310-backbone-model-contract-audit.md`; builders continuity handoff under `.agents/profiles/builders/`
- **Builder self-score**: **100/100**
  - Contract fidelity vs `docs/prompt.txt`: 25/25
  - Typed metadata (task/changelog/governance): 20/20
  - Legacy ownership explicit (SUPERSEDED): 15/15
  - Unit tests green (27/27): 20/20
  - Scoped analyze clean: 10/10
  - Changelog + evidence + report: 10/10
- **Agente executor**: builders (omniroute/builder) — revalidation + promotion; original implementation Hermes Agent 2026-06-07
- **Data de conclusao**: 2026-07-09

## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0310-backbone-model-contract-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Low residual: legacy `models.dart` SUPERSEDED surface.

#### Path-to-100 Summary
- Optional legacy retirement/honesty on dual-surface; re-run scoped gates.

### Previous Reports
- `2026-06-17` — `72/100` — `docs/reports/review-wave-3/0310-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0310-review.md` (superseded)

(End of file)


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Retired dual-surface legacy `models.dart` + `workspace_parser.dart` to `.archive/legacy-yaml-parser-20260718/`; barrels are backbone-only.
- **Commands**:
  - `flutter analyze lib/data/models` (apps/observatory) → No issues found / INFO only on related
  - `flutter test test/data/models/workspace_graph_models_test.dart` → PASS
  - `test ! -f apps/observatory/lib/data/models/models.dart` → OK
- **Remaining**: None — dual surface removed from live package.
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0310-path100-rereview.md` |

