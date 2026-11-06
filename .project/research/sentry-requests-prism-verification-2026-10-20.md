# External Intelligence: Sentry UI Requests vs LIVE Prism — W-Items Verification

- **Artifact:** `.project/research/sentry-requests-prism-verification-2026-10-20.md`
- **Date:** 2026-10-20
- **Lane:** External Intelligence Analyst — read-only research worker (Warp Prism)
- **Subject:** SENTRY → warp-prism ADS component requests
  (`docs/bridge/sentry/ui-component-requests.md`, 14 W-items) re-verified against
  LIVE `warp_prism_ui` sources.
- **Governing law:** `MISSION.md` §3.1 (central ADS+IDS; absorption default; recurrence
  never gates; evidence gates stand). MISSION wins over stale docs.
- **Verdict discipline:** every claim classified OBSERVED / INFERRED / UNKNOWN; negative
  evidence recorded; no fabrication; partiality disclosed beats fabrication.

## 1. Header

- Consumer lane: Sentry — Rust semantic core + outbound UI requests (decision-
  reconstruction semantics; not a trading dashboard).
- Consuming artifact: `docs/bridge/sentry/ui-component-requests.md` + `docs/bridge/sentry/README.md`.
- Verification targets (workspace-local paths only; no external absolute paths):
  - `packages/warp_prism_ui/lib/src/{atoms,molecules,organisms,templates,tokens}/`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/warp_prism_ui.dart`
  - `packages/warp_prism_runtime/lib/src/event_stream/`
  - `packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart`
  - `apps/observatory/` (graph / history / task-provenance surfaces)
- Consumer-side negative scope check: `references/ganthritor-sentry/` only.

## 2. Governing-law and context reconciliation

- `MISSION.md` §3.1 (lines 91–116): full-coverage mandate; absorption default;
  recurrence no longer gates; evidence gates (§6 items 2–7) stand.
- `MISSION.md` §4 (lines 120–183): ADS owns visual vocabulary only (126–134); IDS owns
  interaction semantics (136–142); runtime contracts (144–156); Flutter↔Rust (158–169);
  product-local remainder (171–183).
- `MISSION.md` §5 (186–206) and §6 (210–236): harvest loop and evidence-before-promotion
  gates.
- MISSION-over-stale-docs check: `docs/bridge/README.md:32` still lists the `sentry/`
  bridge as "**empty**" (2026-09-27) while `docs/bridge/sentry/` is populated (2026-10-15).
  Recorded as stale projection; not treated as law.

## 3. Method

- Read-only source reads only. No exec, no VCS, no delegation, no external absolute paths.
- Live-surface citations below; negative evidence = searched-for-and-not-found.

## 4. Per-request verification (W1–W14)

| W | Tier | Claimed (2026-10-15) | LIVE re-verification (this pass) | Fresh verdict | Core evidence |
|---|---|---|---|---|---|
| W1 | T1 | PARTIAL — layout exists; dual-authority semantics missing | OBSERVED: `MasterDetailTemplate` two-pane layout (`templates/master_detail_template.dart:27-266`), `TimelineTemplate` timeline+detail (`:397-542`), `DSSplitPane` (`organisms/split_pane/ds_split_pane.dart:31-92`), `DSTimeline` (`organisms/ds_timeline.dart:9-67`); dual-authority second lane / sealed-vs-now / mutation-proof mode still absent | **PARTIAL (unchanged)** | `templates/master_detail_template.dart:144-156`, `:527-535`; `organisms/split_pane/ds_split_pane.dart:31-92`; `organisms/ds_timeline.dart:9-67` |
| W2 | T1 | MISSING (composable parts only) | OBSERVED: `DSOperationalState.archived` terminal + `allowsActions=false` (`tokens/ds_operational_state.dart:41`, `:241-242`, `:280-281`) but no `sealed`/`open`/`sealed_at`/`root_hash`/`OPEN→SEALED`; `DSProvenancePill` = canonicity, not tamper-evidence (`molecules/ds_provenance_pill.dart:8-130`); `DSDetailInspector` property rows, no seal vocab (`organisms/ds_detail_inspector.dart:10-287`) | **MISSING (confirmed)** | `tokens/ds_operational_state.dart:18-78`; `molecules/ds_provenance_pill.dart:8-130`; `organisms/ds_detail_inspector.dart:10-287 |
| W3 | T1 | PARTIAL — advisory parts exist; view_cutoff/confidence/invalidation missing | OBSERVED: `DSStoryPanel` + `DSStoryNarrativeInsight(evidence/riskLevel/connection)` + `InsightRiskLevel` (`organisms/ds_story_panel.dart:9-292`, `:231-292`, `:249-264`); no view_cutoff/confidence/invalidation/claim≠knowledge framing | **PARTIAL (unchanged)** | `organisms/ds_story_panel.dart:9-292`; `:231-292`; `:249-264` |
| W4 | T1 | PARTIAL — scrubber precedent exists; five-clock family missing | OBSERVED: `DSTimeMachineScrubber` domain/playhead/`onRangeChanged(DateTimeRange)`/`showClock`/`domainOf`/`clampToDomain` (`organisms/time_machine_scrubber/ds_time_machine_scrubber.dart:146-221`, `:242-277`, `:341-351`); five-clock family + per-artifact clock identity + eligibility predicate absent | **PARTIAL (unchanged)** | `organisms/time_machine_scrubber/ds_time_machine_scrubber.dart:146-221`; `:242-277`; `:341-351` |
| W5 | T1 | MISSING — no lens/badge concept | OBSERVED: grep over `warp_prism_ui/lib` (`epistemic\|view.?cutoff\|lens\|belief\|authority\|sealed\|episode\|hypothesis\|lineage\|decision.?case\|sideeffect\|attempt\|dispatch`) → only incidental hits (error-boundary dispatch, toast dispatch, attempt loop, markdown sealed class); no `EpistemicView`/lens/belief/authority/sealed/decision-case/hypothesis vocabulary | **MISSING (confirmed)** | `packages/warp_prism_ui/lib/**`; `tokens/ds_operational_state.dart:10-13` (`DSStateType` = data-loading only) |
| W6 | T1 | PARTIAL (substrate yes, semantics no) — highest priority | OBSERVED: substrate `EventStream`/`EventStreamSink`/`RuntimeEvent{id,timestamp,severity,source,runGroupId,payload,metadata}` (`packages/warp_prism_runtime/lib/src/event_stream/event_stream_contract.dart:55-117`, `event_stream_models.dart:105-136`); status-fold vocab `DSMessageStatusStepState{pend,run,succ,err}` lacks `unknown` (`organisms/message_status_history/ds_message_status_history.dart:10-22`); `DSStateType` lacks unknown (`molecules/ds_state_surface.dart:294-315`); `AsyncCommandStatus` lacks unknown/attempt-fold (`packages/warp_prism_runtime/lib/src/async_command/async_command_models.dart:7-22`); honest-gap precedent `_GapNode` (`apps/observatory/lib/features/history/presentation/widgets/history_impact_view.dart:273-307`) | **PARTIAL (unchanged)** | `event_stream_contract.dart:55-117`; `event_stream_models.dart:105-136`; `ds_message_status_history.dart:10-22`; `ds_state_surface.dart:294-315`; `async_command_models.dart:7-22`; `history_impact_view.dart:273-307` |
| W7 | T1 | MISSING — no disposition/reason vocab | OBSERVED: `DSStateSurface.empty` → `DSStateType.empty`, semantic label `'Empty: no data available'` (`molecules/ds_state_surface.dart:70-79`, `:235-252`, `:238`); no reasoned-abstention-with-zero-attempts expression | **MISSING (confirmed)** | `molecules/ds_state_surface.dart:31-159`; `:294-315` |
| W8 | T2 | MISSING — no Allow/Constrain/Deny; error taxonomy is execution, not authority | OBSERVED: no `Allow`/`Constrain`/`Deny`/`subject_hash`/constraint-list in ADS; `DSOperationalState.approved/rejected` binary gate outcomes (`tokens/ds_operational_state.dart:30-34`); FRB taxonomy = execution/validation/timeout/transport/duplicate/generic (`packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart:59-71`) — execution, not authority | **MISSING (confirmed)** | `tokens/ds_operational_state.dart:18-78`; `packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart:59-71` |
| W9 | T2 | MISSING — no partial-fill remainder / terminality concept | OBSERVED: `AsyncCommandStatus{idle,running,succeeded,failed,cancelled}`; `CommandResult{Success,Failure,Cancelled}` (`packages/warp_prism_runtime/lib/src/async_command/async_command_models.dart:7-22`, `:316-456`); no `remainder`/`authorized`/`filled`/partial-confirmation semantics | **MISSING (confirmed)** | `packages/warp_prism_runtime/lib/src/async_command/async_command_models.dart:7-22`; `:316-327` |
| W10 | T2 | MISSING — no episode closure vocab | OBSERVED: no `Episode`/`outcome_refs`/`closure_at`/`PortfolioObservation`; nearest = `TaskMetadata.proofState{none,partial,complete,verified}` (`apps/observatory/...`) | **MISSING (confirmed)** | grep over `packages/` + `apps/observatory` (`TaskMetadata`/`ProofState`) |
| W11 | T2 | MISSING — no `Hypothesis`/`PROPOSED` epistemic artifact | OBSERVED: `InspectionLifecycle{proposed,active,dismissed}` is a UI preview phase (`packages/warp_prism_interaction/lib/src/inspection/inspection_state.dart:8`, `:40-73`); no `Hypothesis`/`PROPOSED`/`derived_from_episode` epistemic artifact | **MISSING (confirmed)** | `packages/warp_prism_interaction/lib/src/inspection/inspection_state.dart:8`, `:40-73` |
| W12 | T2 | PARTIAL (right structure, wrong ontology) | OBSERVED: `EdgeKind{contains,routesTo,dependsOn,references,changedBy,proves,uses}` (`apps/observatory/.../workspace_graph.dart:32-53`); `GraphEdge.edgeType{uses,triggers,references}` (`packages/warp_prism_ui/.../graph_model.dart:130-146`); `DSWorkflowEdgeKind{sequence,data,conditionTrue,conditionFalse,error}` (`organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart:53`, `:131-158`) | **PARTIAL (confirmed)** | `apps/observatory/lib/data/models/workspace_graph.dart:32-53`; `packages/warp_prism_ui/lib/src/organisms/graph/graph_model.dart:130-146`; `organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart:53`, `:131-158` |
| W13 | T2 | MISSING — no hash/tamper-evidence state | OBSERVED: grep over `packages/` for `content_hash\|root_hash\|hashWitness\|tamper\|verificationState` → no ADS hits; `DSProvenancePill` = canonicity-only (`molecules/ds_provenance_pill.dart:9-41`, `:110-127`) | **MISSING (confirmed)** | grep over `packages/`; `molecules/ds_provenance_pill.dart:8-130` |
| W14 | T2 | MISSING — no phase rail/legal-act marker | OBSERVED: no phase rail/`SEAL` legal-act marker; FRB async-command lifecycle tuple = command-execution facts (`owner/creation/running/cancellation/terminal/cleanup`) (`packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart:73-97`) — not a SEAL legal act | **MISSING (confirmed)** | `packages/warp_prism_adapter_frb/lib/src/frb_async_command.dart:73-97` |

- **Reconciled totals (fresh pass):** 0 EXISTS / 5 PARTIAL (W1, W3, W4, W6, W12) / 9 MISSING (W2, W5, W7, W8, W9, W10, W11, W13, W14). No status flip versus the 2026-10-15 reconciled pass; every row re-confirmed live.

## 5. Candidate list (from this verification pass)

1. **CAND-1 (P0):** Extend `DSOperationalState` / `DSStateType` + `warp_prism_interaction` with SENTRY epistemic vocabulary — `SEALED`, `UNKNOWN`/not-knowable, `NO_ACTION`, authority dispositions, terminal-for-dispatch. Targets W2, W5, W6, W7, W8, W13.
2. **CAND-2 (P0):** Sealed rendering-mode contract (render-time immutability; no affordance on sealed artifacts; past-is-mutation-proof mode). Targets W1, W2, CAND-1.
3. **CAND-3 (P0):** Hash/tamper-evidence witness badge vocabulary (`content_hash` + verification state). Target W13.
4. **CAND-4 (P1):** Sealed DecisionCase card + then/now dual-authority panes. Targets W1, W2, W14.
5. **CAND-5 (P1):** AuthorityDecision explainer (Allow/Constrain/Deny + `subject_hash` + constraints). Target W8.
6. **CAND-6 (P1):** Partial-fill remainder + terminal-for-dispatch widget. Target W9.
7. **CAND-7 (P2):** Episode closure + outcome evidence view. Target W10.
8. **CAND-8 (P2):** Hypothesis `PROPOSED` advisory card. Target W11.
9. **CAND-9 (P2):** Typed SENTRY epistemic lineage verbs over the closed verb set. Target W12.

## 6. Unknowns / blockers

- Live pass = static source reads only (task constraint: no exec/VCS/delegation). No
  compile/test/execution evidence produced.
- Revision state UNKNOWN (no VCS access).
- Sentry-side frozen bootstrap docs not re-litigated here (immutable, cited anchors).
- Consumer-side negative scope check (`references/ganthritor-sentry/`): Rust crates
  (`crates/sentry-core`, `crates/sentry-slice0`, `crates/sentry-storage-surreal`) show zero
  Flutter/FRB references (per sentry-side reports' greps); only Flutter surface is the
  fixture-local `apps/sentry_reconstruction/` (pubspec: "SENTRY T1 read-only reconstruction
  screen (fixture-local, zero-dep)").
- Stale-doc finding recorded (`docs/bridge/README.md:32`) but not treated as law.

## 7. Compact packet (return)

- **Scope:** Sentry W-items W1–W14 vs LIVE Prism (2026-10-20 pass).
- **Governing law:** MISSION.md §3.1 — central ADS+IDS; absorption default; recurrence
  never gates; evidence gates stand; MISSION wins over stale docs.
- **Result:** no status flip. 0 EXISTS / 5 PARTIAL / 9 MISSING — identical distribution to
  the 2026-10-15 reconciled pass; all 14 re-confirmed against live sources this pass.
- **PARTIAL (confirmed):** W1, W3, W4, W6, W12.
- **MISSING (confirmed):** W2, W5, W7, W8, W9, W10, W11, W13, W14.
- **Top priority (unchanged):** W6 — event-fold/`UNKNOWN`/dispatch semantics; substrate
  present, fail-closed vocabulary absent.
- **Candidates:** CAND-1..CAND-9 (P0/P1/P2) enumerated in §5.
- **Blockers:** static-evidence-only pass; no compile/test execution; revision state UNKNOWN.
