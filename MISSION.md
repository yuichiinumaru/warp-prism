# Warp Prism Mission

> **Status**: Active — canonical product destination
> **Epoch**: Post-reset (2026-09-27). Supersedes the L0–L3 maturity ladder and the
> Rewrite-Factory framing. See §11 for the supersession record.
> **Scope**: This file states *what Warp Prism is*. `AGENTS.md` states *how work is
> conducted*. Layer-by-layer detail lives in `.project/architecture/layer-contracts.md`.

---

## 1. What Warp Prism Is

Warp Prism is the **reusable Flutter-side substrate shared by real products**: a
visual vocabulary, an interaction vocabulary, a small set of backend-independent
runtime contracts, and a Rust integration golden path.

It is a library and proof-laboratory project. It is **not** a product, and it
does not host or own product frontends — and it will not become the home for
any project's frontend (see §2).

Warp Prism is the **central ADS + IDS for Ganthritor**. Under the full-coverage
mandate (§3.1), it must eventually provide Prism-native equivalents of all UI
components in Ganthritor child projects, and all Ganthritor projects are
expected to converge toward it over time. Coverage is bounded by real product
components, not open-ended invention.

Four owned responsibilities:

| | Responsibility | Package |
|---|---|---|
| **A** | **ADS** — Visual Design System: tokens, themes, typography, atoms, molecules, organisms, reusable operational visual primitives | `warp_prism_ui` |
| **B** | **IDS** — Interaction Design System: user-intent semantics (selection, inspection, command intent, query/filter, focus/keyboard) | `warp_prism_interaction` |
| **C** | **Flutter ↔ Runtime semantic integration**: runtime contracts, bindings/projections, semantic DTOs, lifecycle/error/cancellation semantics | `warp_prism_runtime`, `warp_prism_bindings`, `warp_prism_testkit` |
| **D** | **Flutter ↔ Rust golden path**: Rust as the primary/native runtime integration route, with a replaceable transport | `warp_prism_adapter_frb`, `rust/warp_bridge_core`, `rust/warp_bridge_frb` |

Working shorthand for A+B+C is sometimes "AIDS". **Canonical documentation uses
the explicit architectural names above**, not the acronym.

Two owned proof laboratories:

- **Catalog** (`apps/catalog`) — gallery + connected bridge lab. Evidence surface
  for reusable primitives and for the runtime/FRB path.
- **Host-exercise harness** (`packages/warp_prism_host_exercise`) — smoke/crawl/fuzz
  runner that proves a real host can consume a reusable capability.

---

## 2. What Warp Prism Does Not Own

- **Product frontends.** Observatory, CyberCore, and any other historical app in
  this tree are *not* product destinations. They are classified by current
  function: proof surface, fixture/demo, legacy compatibility surface,
  still-valid consumer, or retirement candidate. Classification is evidence-gated
  and deliberately not asserted in advance. Closed 2026-10-19: no in-tree app
  will become a product frontend home; any frontend-home pretension is
  superseded (see §11.4).
- **Application backends.** Warp Prism standardizes only the interfaces through
  which a product exposes backend capability to UI.
- **Domain ontology.** No product's domain types (agent runtimes, leases,
  providers, tracks, takes, audio DSP, editorial commands) belong in Warp Prism
  core.
- **Its own skills tree.** Reusable harness assets are parent-canonical
  (`.agents/skills/`, `.agents/agents/`, `.agents/rules/`). Warp Prism owns
  `.project/`, `docs/`, `packages/`, `apps/`, `rust/`.
- **A second design system in any consumer.** Consumers adopt Prism tokens and
  primitives; they do not fork them.
- **SQLite or any embedded datastore.** Persistence is product-local.

---

## 3. Consumers

The intended consumer family:

| Consumer | State | Bridge surface |
|---|---|---|
| **Warpblade** | Flutter + Rust/FRB, AV/NLE, provisional local UI | `docs/bridge/warpblade/` (`ads-debt.md`) |
| **Tempest** | Flutter + Rust/FRB, audio DAW, provisional local UI | `docs/bridge/tempest/` (`ads-debt.md`) |
| **Sentry** | Rust + UI requests; decision-reconstruction semantics | `docs/bridge/sentry/` (`ui-component-requests.md`) |
| **Command-center** | Flutter host; gap inventory present | `docs/bridge/command-center/` (`prism-gap-components.md`) |
| **Hyperion** | Intended; no product code yet | **absent** — not fabricated |

Other consumers remain valid **only** where current source reality proves them
useful. A consumer does not remain a mission anchor because a historical plan
named it. In particular, OmniRoute is **no longer a mission anchor**; it survives
only as an ordinary consumer candidate.

**Consumers are never blocked by a missing Warp Prism primitive.** They implement
locally. Warp Prism absorbs their components natively (see §3.1).

### 3.1 Full-coverage mandate (2026-10-19 product-owner decision)

Warp Prism is the central ADS + IDS for Ganthritor. It must eventually contain
Prism-native equivalents of **all UI components** in Ganthritor child projects —
not only components that recur across ≥2 consumers. Every Ganthritor project is
a convergence target: products implement locally when Prism lacks something, and
Prism closes the gap natively over time.

What this changes:

- **Absorption is the default.** A child-project UI component is absorbed unless
  a macro-review decision unifies it into a better shared primitive — never
  rejected merely for being single-consumer. The §5 recurrence check no longer
  gates extraction, and §6 item 1 no longer gates promotion of
  mandate-covered components (evidence gates §6 items 2–7 stand).
- **Macro review replaces selection.** Similar-purpose components across
  consumers are reviewed together: unify, improve, or keep distinct on evidence —
  never copy blindly and never reject for lack of recurrence.
- **Domain engines stay local.** The mandate covers UI components and reusable
  interaction semantics. Domain models, engines, persistence, and product
  workflows stay product-local per §4.5 and the domain leakage rule. `KEEP_LOCAL`
  remains valid only for genuinely non-UI domain logic — never as a terminal
  disposition for a UI component.
- **Convergence is directional, not instant.** Consumers adopt Prism equivalents
  on their own schedule (bridge contract §4: non-blocking, no forced adoption).
  The mandate sets the destination, not a flag day.

---

## 4. Layer Contracts

The normative MUST / MAY / MUST-NOT matrix, the dependency direction, and the
Global MUSTs live in **[`.project/architecture/layer-contracts.md`](.project/architecture/layer-contracts.md)**.
That file is the enforcement reference; this section is the summary.

### 4.1 ADS owns

Visual vocabulary only: tokens, themes, typography, atoms, molecules, organisms,
reusable operational visual primitives, and compositions **only when recurrence
is proven**. Plus accessibility, responsive behavior, host-composition
correctness, and the catalog/proof surface.

`warp_prism_ui` MUST NOT import `flutter_rust_bridge`, `warp_prism_runtime`,
`warp_prism_bindings`, or any adapter. Public API is `Prism*`; `DS*` is internal.

### 4.2 IDS owns

Reusable user-intent **semantics**, distinct from widget mechanics. Selection,
inspection, command intent, query/filter, focus/keyboard. Anything else enters
only when recurrence is demonstrated. IDS is **not** a state-management framework.

Pure Dart: no Flutter widget dependency.

### 4.3 Runtime contracts and bindings own

Backend-independent interfaces — currently `AsyncCommand<I,O>`, `EventStream<E>`,
`HealthSource<T>`, `GraphSource<N,E>` — plus fakes and a conformance testkit.

**Purge law**: contracts carry semantics, not presentation policy. Auto-scroll,
follow-tail, poll-every-X, exponential retry, and viewport behavior are **out**;
they live in widgets or a composition/policy layer.

**Runtime model ≠ presentation model.** `Offset` is owned by the binding, never by
a contract and never returned by Rust as domain.

Bindings are thin projections. They MUST NOT own backend logic or storage.

### 4.4 Flutter ↔ Rust integration owns

Rust is the primary/native runtime integration route for this product family.

- **FRB is transport, not ontology.** A replaceable transport implementation.
- Generated bindings MUST NOT become application architecture.
- UI widgets MUST NOT directly depend on generated bridge surfaces.
- `warp_bridge_core` is a transport-independent domain core (zero transport
  dependencies). `warp_bridge_frb` is the FRB projection.
- The FRB version pin is a **candidate, never a canon**.
- If Flutter↔Rust integration is not justified for a case, that is a legitimate
  outcome; do not force it.

### 4.5 What remains product-local

Everything else. Domain types, domain workflows, product routes, product state,
persistence, and product-specific UI composition stay in the consumer. Domain
types projected onto generic contracts is the consumer's job, not Warp Prism's.

**Domain Leakage Rule** (bidirectional): no `Warpblade*`/`Tempest*`/`CyberCore*`/
`Ganthritor*` types in Warp Prism core; and Warp Prism generic contracts must not
leak product semantics back into a consumer's core.

**Explicit bypass**: a product MAY bypass a Warp Prism contract when the
interaction is genuinely domain-specific. Bypass is a feature, not a defect.

---

## 5. Consumer Harvest Loop

```
consumer-local implementation
  → bridge evidence / candidate description      (docs/bridge/<consumer>/)
  → Warp Prism classification                    (REUSE / EXTEND / CANDIDATE / GAP; KEEP_LOCAL only for non-UI domain logic)
  → macro review                                  (unify across similar-purpose components; improve, don't just copy)
  → candidate extraction                          (experimentally, not "core")
  → reusable implementation + proof               (fake + conformance suite + host proof)
  → consumer convergence                          (adoption on the consumer's schedule)
  → governed promotion                            (barrel export + API freeze)
```

Contract lifecycle, applied to every reusable unit:

```
LOCAL → CANDIDATE → EXPERIMENTAL → PROVEN → STABLE
```

A unit may be created and tested as EXPERIMENTAL without being core. There is no
"must be core to be tested" circularity.

---

## 6. Evidence Required Before Promotion

A candidate becomes a stable Warp Prism primitive only when **all** hold:

1. **Mandate coverage + macro review** (supersedes recurrence, 2026-10-19): the
   candidate is a mandate-covered component (or a unification of several) with a
   recorded macro-review decision. Recurrence across ≥2 consumers/domains is no
   longer required; where it exists, it prioritizes unification work.
2. **Fake/reference implementation** passing the contract suite.
3. **Conformance suite** defined and green.
4. **Boundary clearance**: the boundary harness proves the new unit respects the
   layer contracts.
5. **Host-composition proof** for anything that can materially affect a real
   consumer host. A package-local widget test wrapper is **not** sufficient when
   it supplies ancestors, constraints, theme, routing, focus, or runtime
   capabilities the real consumer does not supply.
6. **Flutter↔Rust lifecycle proof**, when the candidate crosses that boundary:
   same suite passes for the real adapter and for its fake.
7. **Independent review** with an explicit verdict.

**Crystallization rule**: no *speculative* template, scaffold, or generic
framework — crystallization still requires validated integrations, not
anticipation. This rule never blocks absorbing an existing product-proven
component or composition.

**Anti-fragile ordering**: generators scaffold contract + fake + suite *before* an
adapter.

---

## 7. Control Plane vs Data Plane

- **Control plane**: small, low-rate, semantically meaningful — status, health,
  commands, selections, graph topology.
- **Data plane**: high-rate, large-payload — media frames, audio peaks, waveform
  and spectral data, texture surfaces.

Data-plane payloads crossing the boundary MUST declare transfer and ownership
semantics. Do not model a data plane as an event stream of semantic events. A
high-rate native surface may be legitimately product-local.

---

## 8. Source Reality and Evidence Precedence

```
current source/runtime
  → current deterministic evidence
  → independent accepted review
  → current canonical architecture
  → active planning
  → historical artifacts
  → conversation / brainstorm
```

An old EPIC never overrides source reality. A tool warning is a candidate, not
authority. A review score is diagnostic; mandatory acceptance evidence controls
the verdict.

**Evidence invalidation**: when newer authoritative evidence materially contradicts
a claim that contributed to acceptance, the historical verdict stays valid *for its
snapshot* and the active claim becomes `REVALIDATION_REQUIRED`. Identify exactly
which dimensions broke, preserve unaffected evidence, re-run invalidated
verification, and require independent re-review.

---

## 9. Quality Gates

| Gate | Requirement |
|---|---|
| Format | `dart format --set-exit-if-changed` clean on touched paths |
| Analysis | `flutter analyze` / `dart analyze` clean on touched packages |
| Boundary | `boundary_test.dart` harness green — layer purity is mechanically enforced, not documented |
| Barrel | Public barrel exports no `DS*`; alias set complete |
| Contract | Every runtime contract has a fake + conformance suite |
| Determinism | Same input ⇒ same output; no unbounded waits, no animation-dependent capture |
| Accessibility | Semantics, focus, contrast, text-scale, reduced motion |
| Host composition | Real-host exercise when the change can affect a real consumer |
| Independent review | Fresh reviewer, no self-acceptance |

---

## 10. Non-Goals

- Not a product. Not a product frontend host.
- Not an unbounded "design system of everything": coverage is bounded by real
  Ganthritor product components (§3.1), not speculative invention. (The former
  blanket prohibition is superseded to this extent; see §11.4.)
- Not a state-management framework.
- Not a framework imposed on consumers who do not need it.
- Not a rewrite/porting engine for legacy products.
- Not a place to accumulate speculative future architecture.

---

## 11. Supersession Record

### 11.1 Superseded: the L0–L3 maturity ladder and "Rewrite Factory"

The former ladder (`L0 — ADS` → `L1 — Integration-Capable` → `L2 —
Rewrite-Capable` → `L3 — Rewrite Factory`) is **superseded as mission
architecture**.

Rationale: the ladder encoded Warp Prism as a rewrite/porting engine for legacy
products. That is not this project's purpose. It also created a fake-progress
dynamic where a gate flip was treated as the goal.

What survives:

- The **retained, non-ceremonial** invariants it encoded — layer purity, domain
  leakage, fixture-first, promotion gating, the L3 prohibition, evidence
  precedence. All are now stated directly in §4–§8 and enforced by the boundary
  harness.
- The **honest historical record**. The `L1 PASSED` snapshot of 2026-09-02
  remains valid for its snapshot. Its real-host dimensions were moved to
  `REVALIDATION_REQUIRED` by owner evidence of 2026-09-03/04, and that state is
  still open.

What is gone: the gates themselves, and the rewrite-factory/port/migration
methodology it implied (former §21 Product Archaeology, §22 Rewrite Manifest,
§40 Rewrite Economics).

### 11.2 Superseded: consumer anchoring

Former consumers Catalog / Observatory / CyberCore / OmniRoute-as-pilot-anchor
are superseded by the family in §3. Catalog remains as an owned proof laboratory.
Observatory and CyberCore are subject to evidence-gated classification (§2).

### 11.3 Superseded: active planning corpus

The pre-reset `00-planning/` corpus (27 EPIC files + roadmaps + story packets +
superseded plans) is archived. See
[`.project/archive/epoch-reset-manifest.md`](.project/archive/epoch-reset-manifest.md)
for the per-artifact disposition, epoch, reason, and canonical replacement.

### 11.4 Amendment: central ADS/IDS role and full-coverage mandate (2026-10-19)

Product-owner decision (current conversation, 2026-10-19): Warp Prism is the
central ADS + IDS for Ganthritor (§3.1). It must eventually hold Prism-native
equivalents of all UI components in Ganthritor child projects; all Ganthritor
projects converge toward it over time. Any pretension of Warp Prism becoming a
product frontend home is closed (§1, §2).

Superseded by this amendment:

- §5 recurrence check as a gate to extraction; §6 item 1 recurrence as a gate to
  promotion of mandate-covered components.
- §10 "not a design system of everything" as a blanket prohibition (now bounded
  by real product components).
- `AGENTS.md` §10.1 "single-consumer work stays product-local by default" and the
  recurrence promotion gate restated there; `AGENTS.md` §5 recurrence preference
  for mandate-covered components.

Evidence gates stand unchanged: fake/reference, conformance suite, boundary
clearance, host-composition proof, FRB lifecycle proof where applicable, and
independent review (§6 items 2–7). Domain leakage, bypass, purge, and model
separation rules stand unchanged (§4.5, layer contracts).

Reconciliation still required through task governance (not silently assumed):
`layer-contracts.md` §9 PROVEN row, `docs/bridge/README.md` harvest loop and
classification vocabulary, and `docs/design/token-theme-catalog-policy.md`
promotion gates still state recurrence. They must be reconciled to this mandate;
until then, this file governs on conflict.

---

## 12. Current Authority Map

**Current authority** — read these:

| Document | Owns |
|---|---|
| `MISSION.md` (this file) | Product destination, ownership boundary, promotion evidence |
| `AGENTS.md` | Execution law, lanes, review, evidence discipline |
| `.project/architecture/layer-contracts.md` | Normative layer matrix + dependency law |
| `docs/bridge/README.md` | Consumer bridge contract and harvest loop |
| `docs/design/charter.md` | Product charter (v2) |
| `docs/design/black-obsidian-visual-contract.md` | Visual canon + golden freeze policy |
| `docs/design/token-theme-catalog-policy.md` | Token layers, naming, promotion gates |
| `docs/design/component-catalog.md` | Current source-backed index of shared ADS components, categorized by layer |
| `docs/design/public-barrel-audit.md` | Public API manifest and barrel lock |
| `docs/governance/promotion-state-model.md` | Lane lifecycle and promotion states |
| `.project/architecture/cross-consumer-gap-matrix.md` | Accepted gap matrix (current) |
| `.project/tasks/tasklist.md` | Generated task index |

**Historical only** — never cite as current authority:

- `.archive/**` — archived planning and superseded artifacts
- `.project/tasks/04-completed/**` — completed task records (evidence, not authority)
- `.project/reports/**` dated before 2026-09-27 — superseded analysis
- `.project/memories/**` — role continuity, not product truth
- `docs/reference/**` — external reference harvest, provenance unverified

---

## 13. Stop Conditions

A Warp Prism mission pass may stop normally only when:

**COMPLETE** — the stated objective is satisfied, required independent acceptance
exists, and no material implementable work remains for it.

**EXTERNALLY BLOCKED** — the objective remains incomplete, every remaining
branch is blocked by something genuinely non-delegable (a recorded human
decision, a product-repository governance lane, credentials, or unavailable
evidence), the exact missing action is recorded, and all independent authorized
work is drained.

Do not stop merely because a queue emptied, CI is green, a reviewer returned
FAIL, or a future action can be described. When one branch is blocked, continue
every independent branch first.
