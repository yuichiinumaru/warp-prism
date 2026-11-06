# Task 1884: Graph/Health first-host proofs, DAG-gated (no host means HOLD with evidence)

Change only the graph/health proof seam: extend `DSGraphCanvas` input to a
caller-supplied projected node/edge model, add the `PrismLineageStrip`
molecule for SAME|DIFFER / derived-from, and prove `GraphSource` with a real
consumer plus `HealthSource` cost/quota + provider-matrix axis. DAG-gated:
with no observed DAG host the task records HOLD with evidence instead of
building on speculation. Success is proof or an honest HOLD, never a fake host.

## Outcome and boundaries

- **Authorized outcome**: EITHER (a) real-host proof — `GraphSource`
  exercised by a real DAG consumer (Tempest `ProjectVersionDagTree` if it
  exists by kickoff, else any real DAG host found by evidence) + HealthSource
  cost-axis + `PrismProviderHealthMatrix` credential-free axis with fake +
  conformance green; OR (b) HOLD record with the blocking premise intact
  (no observed consumer DAG surface), fake + conformance landed, host proof
  explicitly deferred. Both outcomes keep the edge ontology per-domain
  (no fixed verb set in Prism core).
- **Subject**: runtime contracts (unchanged) + bindings projection +
  `DSGraphCanvas` input extension + `PrismLineageStrip` molecule.
- **Constraints**: no domain verbs in core (boundary B14); no credentials in
  Prism (providers' secrets stay product-local); no new contract — the
  rendering substrate exists, the missing thing is a real consumer
  (macro-review C8). Warpblade lineage is textual SAME|DIFFER — never
  over-read as graph demand. Rust MUST NOT return presentation types.
- **Non-goals**: no DAG construction in Prism; no `ProjectVersionDagTree`
  implementation; no DSP curves; no P2 energy-curve editor (F-23).

## Context / reliance

- Source evidence: backlog F-17 card (rendering substrate present:
  `DSGraphCanvas`, `GraphEdge`, `WorkflowCanvasStage`; runtime `GraphSource`
  contract exists; `ProjectVersionDagTree` DECLARED-not-built → HOLD;
  `ProviderQuotaUsageTracker` → cost axis; `HardwareStatusIndicator` →
  provider-health matrix; Macro C8/P2-2; U-DAG unknown).
- Backlog §2: this task stays HOLD until the host exists. That premise is
  sourced, not invented — validate at kickoff, don't assume.
- MISSION §§4.3, 6, 7; layer-contracts §§1–3, 5, 7–8.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Extend | Input extension: caller-supplied kinds; read first |
| `packages/warp_prism_ui/lib/src/organisms/graph/` | Reference | Edge/model conventions (`graph_model.dart:130-146`) |
| `packages/warp_prism_runtime/lib/src/graph_source/` | Contract | Unchanged contract; conformance target |
| `packages/warp_prism_runtime/lib/src/health_source/` | Contract | Cost-axis proposal target |
| `packages/warp_prism_bindings/lib/src/` | Extend | `graph_source_binding`, `health_source_binding` projection |
| `packages/warp_prism_testkit/lib/src/` | Extend | Fake `GraphSource` + conformance (exists per gap-matrix — verify, extend) |
| `packages/warp_prism_ui/lib/src/organisms/provider_health_matrix/` | Reference | Matrix axis conventions; credentials stay out |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness |
| `docs/bridge/tempest/` | Evidence | DAG host existence check at kickoff |

## Work / responsibility

- [ ] Kickoff host check: does a real DAG consumer exist in source today?
  Record observed paths or the verified absence — no speculation.
- [ ] If host exists: extend canvas input + lineage strip + bindings with
  fake + conformance + real-DAG host proof + boundary clearance.
- [ ] If absent: land fake + conformance + canvas input extension behind the
  HOLD flag, record the blocking premise verbatim, and stop — do not invent
  a demo DAG as host proof.
- [ ] Prove no domain verbs / credentials enter core (grep evidence).
- [ ] Run full validation; bind host-or-HOLD evidence below.

## Success and verification

- EITHER host proof (real DAG host, route, interaction, no framework errors,
  edge ontology caller-supplied) OR honest HOLD with: kickoff scan output,
  absent-host statement, landed fake + conformance, deferred-proof condition.
- Boundary clearance: no domain verbs in core; no credentials; grep evidence.
- MISSION §6: items 1 (mandate + Macro C8), 2–4 (fake + conformance +
  boundary), 5 (host proof OR recorded HOLD), 7 (review). Item 6 applies to
  the binding leg if FRB crossed, else n/a with reason.
- Format/analyze/boundary clean.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_runtime/lib packages/warp_prism_bindings/lib packages/warp_prism_testkit/lib
dart analyze packages/warp_prism_runtime packages/warp_prism_bindings packages/warp_prism_testkit
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_testkit
```

## Evidence / assessment

- Bind results here: host-check output, suite outputs, host-proof log or HOLD
  record, review verdict. A demo DAG never counts as host proof.

**Parallelizable with**: all P1 siblings — disjoint seam; HOLD outcome needs
no host coordination. **Blocked only by**: genuine absence of a real DAG host
(sourced premise, validated at kickoff).

## Parent verification + HOLD record — 2026-11-01 (builders lane)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_197c32466002sNhcaXzYAa8kG3`. Handoff `status: partial` = **HOLD branch executed as authorized** (proof OR honest HOLD; host absent → HOLD with evidence).
- **Kickoff premise validated (sourced, not invented)**: Tempest `ProjectVersionDagTree` is planned-only (`docs/bridge/tempest/ads-debt.md` §2.3.2, backlog F-17 DECLARED-not-built, macro-review UNKNOWN-6); workspace grep finds only governance-DAG mentions + mock fixture T007 + planned layouts — **no real consumer DAG surface observed**. HOLD premise intact.
- **HOLD-branch seam landed**: `DSGraphCanvas` +2 optional caller-supplied kind resolvers (backward compatible, no fixed verb set, no contract change) + 3-test projection suite. Fake `GraphSource`/`HealthSource`, both conformance suites, both bindings, `DSLineageStrip` verified already-landed and green; no credentials anywhere in seam.
- **Parent re-run (fresh, after return)**: `dart format` on 2 touched paths → 0 changed exit 0; projection + backward-compat + lineage suites → **24/24 pass exit 0**; pure-dart boundary harness → **76/76 PASS exit 0**. Shared `boundary_test.dart` untouched by this worker per collision guard (parent-owned serial guard holds).
- **Unlock condition (deferred proof)**: a real DAG host appears (Tempest `ProjectVersionDagTree` built, or any evidenced consumer DAG surface) → then host proof: real-DAG route + interaction, no framework errors, caller-supplied edge ontology.
- **Lane**: stays in `02-doing/` as HOLD-with-evidence (not actionable until unlock; not blocked-on-failure). Independent review still required for the landed seam — NOT self-granted.
