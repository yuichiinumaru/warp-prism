# Task 1818: Runtime Consumer and Source Audit

> **Priority**: 🔴 P0 · **Type**: `verification`
> **Origin**: EPIC-21 (S21-01 / Consumer Audit) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1819
> **Depends on**: Task 1811 (Layer Boundaries), Task 1812 (Package Topology)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 21-A runtime-consumer audit (the evidence input for the runtime contracts)
- **Strategic why**: the 4 contracts (EventStream/HealthSource/GraphSource/AsyncCommand) must be shaped by real consumer evidence, not planning hypotheses; this audit is that evidence.
- **Consequence if absent**: 1819 designs contracts blind; presentation-purge and semantic/layout separation stay unverified.

## Non-Goals

- **Do not**: modify any component, organism, or app source — this is an audit/read-only task; the files listed in "Read before modifying" are read for evidence, not mutated.
- **Do not**: design or implement the contracts themselves — that is Task 1819's scope.
- **Do not**: propose health polling — presentation/polling policies are classified OUT of runtime contracts (layer-contracts law).

## Objective

Conduct an evidence-driven source audit across `warp_prism_ui`, `apps/observatory`, `apps/catalog`, and `apps/cybercore` to map existing runtime and data-flow patterns, establish the exact consumer requirements for the 4 core runtime contracts (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`), and isolate presentation-only policies (auto-scroll, follow-tail, polling intervals, UI retry) from pure runtime semantics.

## Background Context

### What already exists

- `EventStream` candidates: `ExecutionConsole` (`ds_execution_console.dart:285-406, :538-665` — append-only buffer + auto-scroll) and `LogViewer` (`ds_log_viewer.dart:122-157` — filter + scroll presentation). Both currently mix stream consumption with UI viewport control.
- `GraphSource` candidates: `GraphCanvas` and `WorkflowCanvasStage` (currently mix layout `position: Offset` with semantic graph identity).
- `HealthSource` status: 0 current consumers in `apps/*/lib` (zero `Timer.periodic`). Needs future candidate profiling without speculative framework bloat.
- `AsyncCommand` status: ad-hoc in 3 apps (Observatory Riverpod `AsyncValue`, Catalog `ValueNotifier`, CyberCore local state).
- `docs/architecture/layer-contracts-v2.md` — layer boundaries and presentation purity invariants (from Task 1811).

### What is missing or broken

- No unified audit document maps existing component data contracts to backend-agnostic interfaces.
- Presentation policies are entangled with stream/command data structures in existing components.
- No semantic DTO boundary separating layout fields (`Offset`) from domain graph node models.

## Subtasks

- [ ] **Read before modifying** (read-only evidence pass; this task creates only the audit doc): `ds_execution_console.dart`, `ds_log_viewer.dart`, `graph_canvas.dart`, `workflow_canvas_stage.dart`, `ds_provider_health_matrix.dart`, `apps/observatory/lib/`, `apps/cybercore/lib/`.
- [ ] **Audit stream consumers**: document exact buffer, ordering, backpressure, and error handling needs of `ExecutionConsole` and `LogViewer`. Identify presentation-only fields (`followTail`, `autoScroll`, `expandedIndex`).
- [ ] **Audit graph consumers**: identify separation point between semantic graph nodes/edges and presentation layout state (`position`, `physics`, `pan/zoom`).
- [ ] **Audit command consumers**: catalog all async command triggers, loading states, cancellations, and error representations across apps.
- [ ] **Audit health consumers**: evaluate `ProviderHealthMatrix` and status surfaces; document how snapshot/watch contracts will project without embedded polling loops.
- [ ] **Create audit report**: produce `docs/architecture/runtime-consumer-audit.md` with explicit data-contract inventory, presentation-purge rules, and consumer mapping.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
grep -E "EventStream|HealthSource|GraphSource|AsyncCommand" docs/architecture/runtime-consumer-audit.md
grep -E "Presentation Purge|Auto-Scroll|Follow-Tail|Polling" docs/architecture/runtime-consumer-audit.md
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `docs/architecture/runtime-consumer-audit.md` | Create — runtime consumer audit + presentation purge map |

## Exit Conditions

- [ ] Audit covers all 4 contract candidates (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`) across `warp_prism_ui` and apps.
- [ ] Presentation policies (auto-scroll, follow-tail, polling intervals, retry) explicitly identified and assigned to widget/IDS layers.
- [ ] Semantic vs layout separation documented for graph models.
- [ ] Audit report committed at `docs/architecture/runtime-consumer-audit.md`.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: `docs/architecture/runtime-consumer-audit.md` (created: 141 lines; 25 file:line evidence citations; §6 = direct requirements table for 1819). ZERO source files modified (read-only audit honored).
- **Consumer counts UPDATED with evidence** (vs prior recorded): EventStream = 2 organisms/1 domain, but only 1 live app consumer (cybercore /live-logs, static fixture list); ExecutionConsole app consumers = 0 (gallery/tests). GraphSource = 2 stages/1 domain; 1 live app consumer (observatory → PrismGraphCanvas via 3 Offset-free projection layers; WorkflowCanvasStage app consumers 0; observatory `WorkspaceAsset` is already Offset-free de-facto). HealthSource = 0 confirmed (Timer.periodic in apps/*/lib = 0 physical). AsyncCommand = 3 paradigms, 2 real async apps (observatory AsyncValue ~6 provider families; cybercore 6 pages identical boilerplate; catalog ValueNotifier is a sync theme toggle, NOT a command consumer).
- **Presentation-purge map**: 6 consumer rows with file:line (ExecutionConsole auto-scroll/_userScrolledUp/resume-chip :542-544,:627-670,:969-1004; LogViewer filters/_expandedIds/auto-scroll :60-68,:122-143,:150-158; GraphCanvas pan/zoom/physics :130-131,:151-158; WorkflowCanvasStage layout; HealthMatrix cell width/scroll :200,:246-257; app retry buttons) + 4 MUST-ONLY purge rules tied to layer-contracts-v2 §2 + rejected-idea ledger §G.
- **Open question recorded (not decided — 1819's input)**: kind-vocabulary mapping for graph nodes/edges (3 node vocabularies, 3 edge vocabularies).
- **Tests or validation commands**: greps → 19/4/4/25/141; `grep -rn "Timer.periodic" apps/*/lib/` → **0** (0-polling claim physically confirmed); boundary harness → **8/8 PASS, 0 FAIL**; `flutter analyze packages/warp_prism_ui` → 0 errors/warnings (214 pre-existing info lints untouched)
- **Local changelog entry**: pending parent publication
- **Executor**: gt-architects-architect-general (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
- **Residual risks**: gallery-only consumers flagged (§9 Limitations — WorkflowCanvasStage/ExecutionConsole/HealthMatrix have zero app-runtime consumers; requirements inferred from component contracts); tech-debt noted: cybercore 6× duplicated _loadData boilerplate (AsyncCommand's strongest unification evidence, out of 1818 scope)
