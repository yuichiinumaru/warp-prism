# Layer Contracts — Normative Matrix

> **Status**: Active — canonical enforcement reference
> **Authority**: This file is the normative layer matrix for Warp Prism.
> `MISSION.md` states the product destination; this file states the law.
> **Enforcement**: `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
> mechanically checks most rows. A row with no mechanical check is documentation
> only, and is marked as such.

---

## 1. Layer Matrix

| Layer / package | MUST | MAY | MUST NOT |
|---|---|---|---|
| `warp_prism_ui` (ADS) | stay Flutter-only; expose `Prism*` publicly; keep `DS*` internal; consume only its own tokens/theme + `warp_prism_interaction` in dev | depend on `warp_prism_interaction`; host the gallery; own reusable operational visual primitives and proven compositions | import `flutter_rust_bridge`, `warp_prism_runtime`, `warp_prism_bindings`, `warp_prism_adapter_frb`; import consumer `src/`; own runtime/backend logic |
| `warp_prism_interaction` (IDS) | stay pure Dart; define intent **semantics**; be a11y-first | depend on `meta` only | import `package:flutter` / `dart:ui`; become a state-management framework; own visual concerns |
| `warp_prism_runtime` (contracts) | stay pure Dart + backend-agnostic; carry semantics only; own lifecycle/error/cancellation vocabulary | declare optional SLO fields | import `package:flutter` / `dart:ui`; import FRB or any adapter; contain presentation policy (auto-scroll, follow-tail, poll-every-X, retry policy, viewport) |
| `warp_prism_bindings` (projections) | be a thin projection `runtime/interaction → Prism presentation`; own `Offset`/layout at this edge | depend on `ui` + `interaction` + `runtime` | own backend logic or storage; import `flutter_rust_bridge` or generated FRB surfaces; be imported directly by UI components |
| `warp_prism_testkit` | ship a fake **and** a conformance suite per contract; stay pure Dart | be depended on by adapters and bindings for suite reuse | contain product expectations |
| `warp_prism_adapter_frb` | be the **only** Dart package importing `flutter_rust_bridge`; pass the **same** conformance suite as its fake | own FRB DTO mapping and shared stores | be imported by `warp_prism_ui`, `warp_prism_interaction`, or `warp_prism_runtime` |
| `warp_prism_host_exercise` | stay dependency-light; treat hosts as adapters | provide smoke/crawl/fuzz entrypoints | own product code |
| `warp_bridge_core` (Rust) | stay transport-independent; std-level dependencies only | own domain computation | depend on `flutter_rust_bridge`, `tokio`, or any transport crate |
| `warp_bridge_frb` (Rust) | own FRB projection, DTO mapping, shared stores, async runtime | own transport concerns | own business logic; leak domain into generated types |
| `apps/*` (consumers, proof labs) | compose everything; project domain onto generic contracts; keep domain types local | adopt any subset of Warp Prism | import consumer `src/`; fork Prism tokens; be required to stop when a Prism primitive is missing |

---

## 2. Dependency Direction

```
warp_prism_ui ◄───────────────┐
                              │  (bindings may import ui + interaction; the ui↔interaction link is dev-only from ui)
warp_prism_interaction ◄──────┤
                              │
                     warp_prism_bindings        (thin projection; may import ui + interaction + runtime)
                              │
                              ▼
                     warp_prism_runtime         (contracts; pure Dart)
                              ▲
                              │
                     warp_prism_testkit         (fakes + suites; pure Dart)
                              ▲
                              │
                     warp_prism_adapter_frb     (ONLY importer of flutter_rust_bridge)
                              │
                              ▼
                     warp_bridge_frb            (transport)
                              │
                              ▼
                     warp_bridge_core           (transport-independent domain)
```

Notes:

- `warp_prism_ui` need **not** depend on `warp_prism_interaction` in production.
  It currently does so only as a dev dependency.
- Bindings may import all three Dart layers; it is the projection seam.
- The dependency arrow points **toward** the domain: transport knows the
  transport; the domain core knows nothing.
- **§1 cross-reference (corrected 2026-10-11, rem-0004)**: the direction above
  is governed by the §1 matrix rows, not by this diagram's visual weight. §1 row
  1 (`warp_prism_ui`) forbids importing `bindings`; §1 row 4
  (`warp_prism_bindings`) grants depending on `ui` + `interaction` + `runtime`.
  All six pubspecs agree: `warp_prism_ui/pubspec.yaml` declares no
  `bindings` dependency (its only `warp_prism_*` entry is `warp_prism_interaction`
  under `dev_dependencies`), while `warp_prism_bindings/pubspec.yaml` lists
  `warp_prism_ui`, `warp_prism_interaction`, and `warp_prism_runtime` as
  dependencies. So the reading direction is **`bindings → ui`**, and a diagram
  arrow drawn from `ui` into `bindings` inverts the law. The earlier draft of
  this block used a downward arrow (`▼`) under the `ui`/`interaction` bracket,
  which read as `ui → bindings`; it is corrected here and the prior wording is
  preserved in this note so the supersession is auditable.

---

## 3. Global MUSTs

1. Every connected UI capability crosses a **declared** runtime contract. No
   ad-hoc bridge from a widget to a generated function.
2. Every runtime contract has a fake/reference implementation and a conformance
   suite.
3. Every FRB adapter passes the **same** suite as its fake.
4. Generated bindings are reproducible from source.
5. Large / data-plane payloads declare transfer and ownership semantics.
6. Layer purity is proven by the boundary harness, not asserted in prose.

## 4. Global MUST-NOTs

1. A widget MUST NOT call a generated FRB function directly.
2. A Prism component MUST NOT reference a consumer type directly.
3. A runtime contract MUST NOT contain a Flutter layout/presentation concept
   (`Offset`, `Widget`, `BuildContext`, `Color`) unless explicitly and
   deliberately marked presentation-layer.
4. `warp_prism_ui` MUST NOT import `flutter_rust_bridge` — ever, in any
   dependency scope.
5. Rust MUST NOT return a presentation type as domain.
6. No consumer domain type (`Warpblade*`, `Tempest*`, `CyberCore*`,
   `Ganthritor*`, `Cersei*`, `OmniRoute*`) may appear in the five core Dart
   packages.

---

## 5. Domain Leakage Rule

Bidirectional.

- **Into Warp Prism**: core exposes generic vocabulary
  (`HealthSource`, `EventStream`, `GraphSource`, `AsyncCommand`,
  `BackgroundJobRuntime`). It never exposes `GanthritorAgentRuntime`,
  `CyberCoreLease`, `OmniRouteProvider`, `WarpbladeTake`, or `TempestStem`.
- **Back into a consumer**: a generic Prism contract must not force a consumer's
  own core to speak Prism semantics. The consumer adapts at its own edge.

**Wrong**:

```dart
// in warp_prism_runtime
class ProviderHealthReport { final OmniRouteProvider provider; }
```

**Correct**:

```dart
// in warp_prism_runtime
abstract interface class HealthSource<T> { Future<T> getSnapshot(); }

// in the consumer
class OmniRouteHealthSource implements HealthSource<ProviderHealthViewModel> { /* projects domain */ }
```

---

## 6. Explicit Bypass Rule

A product MAY bypass a Warp Prism runtime contract when the interaction is
genuinely domain-specific and forcing it through a generic contract would be a
lie. Bypass is a **feature**, not a defect.

A bypassed capability is a legitimate harvest candidate later. It is never a
reason to block the consumer.

---

## 7. Model Separation

Runtime model ≠ presentation model.

```dart
// runtime (transport + domain safe)
class RuntimeGraphNode { final String id; final String type; final Map<String,String> metadata; }

// presentation (Flutter safe)
class PrismGraphNodeViewModel { final String label; final IconData icon; final StatusTone status; final Offset position; }
```

Rust MUST NOT return `Offset` as domain. The binding owns the mapper
(`graph_layout_strategy.dart` is the current owner).

---

## 8. Data Plane vs Control Plane

- **Control plane** — small, low-rate, semantically meaningful: status, health,
  commands, selections, graph topology. Modeled with runtime contracts.
- **Data plane** — high-rate, large-payload: media frames, audio peaks,
  waveform/spectral data, GPU texture surfaces. MUST declare transfer and
  ownership semantics.

A data plane MUST NOT be modeled as a high-rate stream of semantic events. A
native texture or audio-meter surface is frequently legitimately product-local.

---

## 9. Contract Lifecycle

```
PROPOSED → EXPERIMENTAL → PROVEN → STABLE
```

| Stage | Barrel export | Requires |
|---|---|---|
| PROPOSED | no | spec only |
| EXPERIMENTAL | no | spec + fake + suite (may be tested outside the barrel) |
| PROVEN | no | mandate coverage (MISSION.md §3.1) with a recorded macro-review decision, **or** ≥2 distinct consumers **or** ≥2 distinct domains; plus fake + suite PASS |
| STABLE | yes | all of the above + boundary clearance + host proof + independent review + API freeze |

No "must be core to be tested" circularity.

> **Mandate reconciliation (2026-10-19; Task 1847)**: the PROVEN bar above
> previously read `≥2 distinct consumers **or** ≥2 distinct domains + fake +
> suite PASS`. MISSION.md §3.1 (full-coverage mandate) and §6 item 1 superseded
> recurrence as a promotion gate for mandate-covered components, so this row now
> admits mandate coverage with a recorded macro-review decision as an
> alternative route. Both routes still require the fake/reference implementation
> and a green conformance suite, and the STABLE row is unchanged (boundary
> clearance + host proof + independent review + API freeze). MISSION.md §6 items
> 2–7 stand; this closes the reconciliation item that MISSION.md §11.4 lists
> for this row.

---

## 10. Mechanically Enforced Checks

`boundary_test.dart` registers **81** checks (16 layer rows + task seams +
Task 1867 harness upgrades). This list is reconciled against
that harness on 2026-11-01; every row below is mechanically enforced — no row
is documentation-only.

> **Task 1867 compaction (2026-11-01)**: the 16 import-direction assertions
> are compacted onto the generated layer table (`kLayerAllowedDeps` +
> `kLayerForbiddenRules` in `boundary_test.dart`) with the generic upward rule
> (`layer_table_1867_upward_rule`) as the single source. The six compacted
> legacy checks keep their names and delegate to table rows; the table —
> not prose — grants every `package:warp_prism_*` edge. Rows 17–20 below are
> the 1867 tranche (toast policy, capture tiers, junk conventions, table
> integrity), added in the same task as their harness checks per this
> section's law.

Current `boundary_test.dart` checks (as of the 2026-09-27 reset, reconciled
2026-10-11):

| # | Check | Status |
|---|---|---|
| 1 | Zero `DS*` in consumer code. | ENFORCED |
| 2 | Consumers do not import Prism `src/`. | ENFORCED |
| 3 | `ui` has no Riverpod / GoRouter. | ENFORCED |
| 4 | `ui` imports no app packages. | ENFORCED |
| 5 | `ui` has no persistence / IO imports. | ENFORCED |
| 6 | Prism alias completeness. | ENFORCED |
| 7 | Public barrel hides `DS*`. | ENFORCED |
| 8 | `PrismTokenRegistry` mutator scope. *(origin: archived `PLAN-task1807` §4.3)* | ENFORCED |
| 9 | No root scratch files. | ENFORCED |
| 10 | `runtime` imports no Flutter. | ENFORCED |
| 11 | `interaction` is pure Dart. | ENFORCED |
| 12 | `ui` imports no bindings. | ENFORCED |
| 13 | No adapter / FRB import in `ui`, `interaction`, or `runtime`. | ENFORCED |
| 14 | No consumer domain types in the five core packages. | ENFORCED |
| 15 | No direct `frb_generated` / `src/rust` imports outside the adapter. | ENFORCED |
| 16 | `bindings` never imports FRB generated surfaces. | ENFORCED |
| 17 | Task 1867 generic upward rule: every `package:warp_prism_*` edge granted by the layer table. | ENFORCED |
| 18 | Task 1867 toast policy: cap/hand-back/onDismiss-only-on-close vocabulary in `ds_toast_manager.dart`, seam dependency-light. | ENFORCED |
| 19 | Task 1867 capture tiers: two-tier reference present and exported from `warp_prism_host_exercise`. | ENFORCED |
| 20 | Task 1867 junk conventions: pure-Dart `junk_sweep.dart` (stable ids + corpus) exported from the testkit. | ENFORCED |

> **Drift note (2026-09-28)**: the superseded
> [`layer-contracts-v2.md`](layer-contracts-v2.md) carried a per-check
> **enforcement status** column (`ENFORCED NOW` vs `PHASED`) and per-check
> provenance. Both were dropped in this rewrite. The status column is
> semantically load-bearing — it distinguished active hard gates from merely
> specified law.
>
> **Recovered 2026-10-11 (rem-0001)**: the per-row status column above is that
> recovery, and row 16 is now a real harness check
> (`_checkBindingsNoFrbGenerated`, scoped to `packages/warp_prism_bindings/lib`).

Plus per-package purity tests: `runtime/test/purity_test.dart`,
`interaction/test/purity_test.dart`,
`bindings/test/boundary_isolation_test.dart`,
`ui/test/boundaries/public_barrel_no_ds_export_test.dart`.

**When you add a layer, a contract, or a new package, add its check here and to
the harness in the same task.** A contract with no mechanical purity check is
un-enforced law.
