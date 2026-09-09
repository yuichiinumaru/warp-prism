# Warp Prism Mission

> **Status**: Active product mission  
> **Project**: Warp Prism  
> **Mission Epoch**: v2 — Compositional Design + Integration System  
> **Current Active Maturity Target**: **L1 — Integration-Capable**  
> **Last Updated**: 2026-09-02  
> **Operating Constitution**: [`AGENTS.md`](./AGENTS.md)

---

# 0. Purpose

This document defines **what Warp Prism is ultimately trying to become and what must be proven before claims of maturity are valid**.

`AGENTS.md` defines **how agents may work**.

`MISSION.md` defines **what the project must make true**.

Tasks, epics, reports, conversations, research, and implementation plans are subordinate to this mission and to current source/runtime evidence.

Warp Prism must not become a framework whose architecture is justified only by its own planning documents.

Its abstractions must survive contact with real consumers.

---

# 1. Mission Statement

Warp Prism is a **compositional design and integration system for Flutter applications**.

It must let a product team move from:

```text
user intent
→ reusable interaction semantics
→ backend-agnostic runtime contracts
→ typed adapters
→ production UI
```

without forcing the product to:

- rebuild visual primitives;
- reinvent common interaction semantics;
- couple widgets directly to backend transports;
- leak application-domain types into reusable design-system packages;
- duplicate orchestration/state wiring for recurring UI↔runtime patterns;
- surrender product-specific semantics to a totalizing framework.

Warp Prism exists to standardize the **reusable middle** between product intent and product implementation.

It provides:

```text
Visual vocabulary
+
Interaction vocabulary
+
Runtime integration vocabulary
+
Proof machinery
+
Consumer-driven promotion discipline
```

It does **not** provide the application's backend, business domain, persistence model, provider fabric, agent runtime, or canonical product state.

> **Warp Prism does not provide the backend. It provides standardized sockets where backends plug in.**

---

# 2. Product Identity

Warp Prism is simultaneously:

1. a **Visual Design System (ADS)**;
2. an **Interaction Design System (IDS)**;
3. a **Runtime Contract System**;
4. a set of **replaceable integration adapters**;
5. a **catalog and test laboratory** for reusable primitives;
6. a **consumer-driven extraction system** that learns reusable patterns from real products;
7. eventually, when evidence supports it, a **rewrite accelerator/factory** for Ganthritor-family products.

It is **not**:

- the Ganthritor runtime;
- the Cersei runtime;
- OmniRoute;
- Cybernetics Core;
- Warpblade;
- Hyperion;
- a generic backend framework;
- a state-management framework;
- a database abstraction;
- an RPC framework;
- a provider SDK;
- a mandatory application architecture.

Products own their domains.

Warp Prism owns only cross-product abstractions that have earned reusable status.

---

# 3. Initial Consumers and Proof Surfaces

The initial proof surfaces are:

- **Warp Prism Catalog** — design/interaction/component proof;
- **ASW Observatory** — operational UI consumer;
- **CyberCore pilot** — product integration consumer;
- **Integration Lab** — Rust/FRB/runtime contract proof.

Future real consumers may include:

- OmniRoute;
- Ganthritor / Cersei surfaces;
- Warpblade;
- Hyperion;
- other Flutter operational products.

A consumer is valuable because it can **falsify** an abstraction.

Do not count a consumer merely because a mock/demo imports a package.

A real consumer exercises meaningful behavior, failure states, and integration boundaries.

---

# 4. Permanent Architectural Model

The intended permanent decomposition is conceptual:

```text
Product / App
│
├── Product Domain
│
├── Product State / Routing / Persistence
│
├── Product-Specific Adapters
│
│
▼
Warp Prism Composition
│
├── Visual Design System (ADS)
│
├── Interaction Design System (IDS)
│
├── Runtime Contracts
│
├── Bindings / Presentation Mapping
│
└── Replaceable Runtime Adapters
     └── Rust / flutter_rust_bridge golden path
```

Physical package/crate topology may evolve.

The **ownership boundaries must not collapse** merely because two concepts are currently implemented in one package.

Likewise, a conceptual distinction does not automatically justify a physical package or crate.

---

# 5. Layer Contract — Visual Design System (ADS)

The ADS is the presentation vocabulary.

Its canonical reusable Flutter package is currently:

```text
packages/warp_prism_ui
```

The ADS MUST own or provide reusable equivalents for:

- tokens;
- theme semantics;
- typography;
- spacing/layout primitives;
- color roles;
- elevation/surface semantics;
- accessibility-aware visual states;
- atoms;
- molecules;
- organisms;
- templates;
- visual feedback;
- focus/hover/pressed/selected/disabled presentation;
- reusable operational visualization components where genuinely generic.

The ADS MUST remain usable without a live backend.

It must support deterministic visual and behavioral verification through:

- widget tests;
- semantic/accessibility tests;
- boundary tests;
- catalog examples;
- golden/reference tests where appropriate.

The ADS MUST NOT own:

- FRB;
- generated Rust bindings;
- networking;
- database access;
- application persistence;
- product routing/state;
- provider logic;
- application-domain business semantics.

A component may remain purely visual forever.

Not every component needs a runtime contract.

---

# 6. Visual Direction and Quality

The current canonical visual direction is the **Black Obsidian** family established by the v1/EPIC-18 visual contract and subsequent accepted artifacts.

Warp Prism should remain:

- minimal;
- high-signal;
- operational rather than decorative;
- consistent;
- keyboard/focus friendly;
- information-dense without becoming visually noisy;
- friendly to sustained expert use;
- accessible;
- deterministic enough for visual regression testing.

Do not casually replace the visual language with:

- generic SaaS pastel dashboards;
- arbitrary Material defaults;
- visual novelty that reduces operational clarity;
- per-app styling forks that should have remained token/theme composition.

Visual evolution is allowed.

Visual drift without evidence/review is not.

---

# 7. Layer Contract — Interaction Design System (IDS)

The IDS owns reusable **human intent and interaction semantics**.

Its purpose is to prevent products from repeatedly reinventing:

- selection semantics;
- inspect semantics;
- command invocation semantics;
- query/filter intent;
- focus/keyboard traversal patterns;
- multi-select semantics;
- navigation/viewport interaction models;
- reusable gesture intent where the semantic recurrence is real.

The initial candidate kernel should remain deliberately small.

Representative candidates include:

```text
Selection
Inspect
Command
Query
```

These names are candidates until proven by implementation and consumers.

The IDS SHOULD be pure Dart where practical.

Flutter-specific gesture adapters MAY exist around a semantic core.

The IDS MUST NOT own:

- application-domain behavior;
- backend implementation;
- FRB;
- persistence;
- networking;
- provider semantics.

Interaction semantics describe **what the user means**, not how one specific backend performs it.

---

# 8. Layer Contract — Runtime Contracts

Runtime Contracts define reusable, backend-agnostic UI↔runtime semantics.

Candidate contracts include:

```text
AsyncCommand<I, O>
EventStream<E>
HealthSource
GraphSource<N, E>
```

Later candidates may include patterns such as:

```text
BackgroundJob
CollectionSource<T>
MetricSource
TelemetrySource
FilesystemSource
MediaSource
```

Later candidates are not pre-authorized stable architecture.

A Runtime Contract MUST describe semantics such as:

- request/response;
- lifecycle;
- state;
- progress;
- cancellation where meaningful;
- errors;
- freshness;
- delivery/order;
- subscription;
- availability/capability;
- typed identifiers/handles.

A Runtime Contract MUST NOT encode arbitrary presentation policy.

Examples:

```text
EventStream
MAY own:
  subscribe/unsubscribe
  delivery
  ordering
  completion/error
  backpressure semantics

EventStream
MUST NOT own:
  auto-scroll
  viewport layout
  follow-tail UI policy
```

```text
HealthSource
MAY own:
  snapshot
  watch
  freshness
  source state

HealthSource
MUST NOT arbitrarily own:
  poll every 5 seconds
  retry exponential forever
  refresh when widget gains focus
```

```text
AsyncCommand
MAY own:
  execute
  result
  typed error
  cancellation when supported

AsyncCommand
MUST NOT silently own:
  arbitrary product retry policy
  presentation notifications
```

Runtime model is not presentation model.

---

# 9. Domain Leakage Rule

Generic Warp Prism layers MUST NOT acquire product-domain ownership.

Types such as these must not become generic Warp Prism core vocabulary:

```text
GanthritorAgentRuntime
CerseiDynamicTool
OmniRouteProvider
CyberCoreModelLease
WarpbladeTake
```

Products should project domain concepts onto reusable primitives when the semantic fit is genuine.

Example:

```text
OmniRoute provider health
        ↓ project adapter
HealthSource
        ↓ binding
Prism presentation
```

When the fit is not genuine:

```text
domain-specific semantic
→ product-local contract
```

Do not distort product semantics merely to increase reuse statistics.

---

# 10. Explicit Bypass Rule

Warp Prism is not a totalizing framework.

Products MAY bypass Warp Prism IDS/runtime contracts for genuinely domain-specific UI↔runtime interactions.

The decision rule is:

```text
recurring cross-domain pattern
→ candidate Warp primitive

product-specific semantic
→ product-local by default
```

Bypass is not architectural failure.

It is an escape hatch protecting both the product and Warp Prism from false abstraction.

---

# 11. Bindings Layer

Bindings connect generic interaction/runtime semantics to presentation.

A binding layer MAY depend on:

- ADS;
- IDS;
- Runtime Contracts.

It MAY map:

```text
runtime state
→ Prism visual state

interaction intent
→ runtime command

runtime event
→ reusable presentation behavior
```

Bindings MUST NOT own:

- product backend logic;
- provider logic;
- persistence;
- product business rules.

Bindings should make integration cheap without making widgets transport-aware.

---

# 12. Rust Integration Golden Path

Rust is a **first-class and preferred integration path**, not an ontological dependency of the generic Dart layers.

The initial golden transport is:

```text
Flutter
  ↓
Warp Prism runtime/bindings boundary
  ↓
flutter_rust_bridge adapter
  ↓
Rust bridge surface
  ↓
Rust runtime/product
```

`flutter_rust_bridge` is a replaceable adapter.

It must never become the ontology of Runtime Contracts.

Generic packages MUST remain transport-independent.

The first Rust topology should stay small.

Conceptually:

```text
rust/
├ warp_bridge_core
└ warp_bridge_frb
```

with internal modules for needed contract families.

Do not create a crate garden in advance.

A module becomes a crate only for a demonstrated reason such as:

- independent reuse;
- dependency isolation;
- feature/build isolation;
- separate lifecycle.

Future transports such as resident RPC/daemon integration are allowed only after they solve a demonstrated problem.

The FRB Integration Lab must test FRB, not simultaneously attempt to prove every possible transport architecture.

---

# 13. Control Plane vs Data Plane

Typed contracts should carry control-plane semantics.

Large media/data payloads should not be copied through Dart merely because a bridge can serialize them.

For large payloads, frames, textures, tensors, media buffers, or similarly heavy data:

- measure before optimizing;
- keep ownership native-side where appropriate;
- pass handles/references/typed buffers when justified;
- use shared/native memory only after evidence supports the complexity.

Optimization ladder:

```text
L0 correctness with typed bridge
L1 fewer crossings / batching / coalescing
L2 typed binary buffers / handles / zero-copy where supported
L3 shared memory / native or GPU ownership
L4 allocator/cache/atomics/SIMD/affinity/LTO/PGO
L5 manual prefetch/assembly
```

Do not jump levels because low-level optimization is interesting.

Optimize measured end-to-end bottlenecks.

---

# 14. Fake / Reference Implementations and Contract Testkit

Every generic Runtime Contract that is promoted beyond proposal should have a deterministic fake/reference implementation where feasible.

The same semantic contract suite should be reusable against:

```text
fake/reference implementation
and
real adapter implementation
```

For FRB:

```text
Fake Runtime
      │
      ├── same semantic contract suite
      │
FRB Adapter → Rust Runtime
```

The purpose is to prove:

```text
transport changes
!= semantic contract changes
```

Mocks may prove contract semantics.

Mocks do not prove real integration.

A connected claim requires connected evidence.

---

# 15. Catalog as a Contract Laboratory

The Catalog is not merely a component gallery.

It should become a progressive proof surface.

Useful modes include:

```text
STATIC
→ visual/component demonstration

INTERACTIVE
→ local/fake interaction behavior

CONNECTED
→ real adapter/runtime behavior
```

Do not implement a giant generalized registry before the minimum connected proof exists.

The Catalog should help answer:

- What reusable primitives exist?
- What states do they support?
- What interaction intents do they expose?
- Which runtime contracts can connect to them?
- Which adapters have been proven?
- Which examples are fake vs connected?

Catalog truth must reflect actual implementation status.

---

# 16. Component Contract Metadata

Warp Prism should eventually maintain machine-readable component/contract metadata sufficient to support discovery and composition.

Candidate metadata dimensions include:

```text
component_id
public_name
atomic_level
visual_category
interaction_intents
runtime_contracts
contract_versions
states
supported_adapters
maturity
```

This registry must emerge from proven components.

Do not build a generalized resolver/exporter merely because the schema can be imagined.

Minimum metadata needed for testing/discovery may precede a full resolver.

---

# 17. Promotion Lifecycle

Reusable primitives advance through evidence.

Canonical lifecycle:

```text
PROPOSED
   ↓
EXPERIMENTAL
   ↓
PROVEN
   ↓
STABLE
```

A package may contain experimental APIs.

A stable public barrel must not silently expose a candidate as stable.

Promotion requires evidence proportional to the abstraction.

## Runtime Contract promotion evidence

Prefer evidence including:

- real consumers;
- more than one domain where practical;
- fake/reference implementation;
- contract tests;
- failure semantics;
- real adapter proof;
- recurrence evidence.

## IDS promotion evidence

Prefer evidence including:

- repeated interaction need;
- semantic consistency across consumers;
- accessibility implications;
- deterministic behavior;
- absence of unnecessary product-domain coupling.

## ADS promotion evidence

Prefer evidence including:

- visual contract alignment;
- accessibility;
- catalog proof;
- semantics/widget tests;
- recurrence;
- stable public API discipline.

> **Promotion by evidence, not promotion by beauty.**

---

# 18. Consumer Recurrence Heuristic

Prefer at least:

```text
2 meaningful consumers
or
2 meaningfully different domains
```

before declaring a generic abstraction stable, unless a stronger product reason is recorded.

This is a heuristic, not an excuse to create fake consumers.

A fake and its integration lab do not automatically equal two independent product domains.

---

# 19. Templates and Scaffolding

Templates, generators, scaffolders, resolvers, and rewrite automation must crystallize proven repeated compositions.

Do not build them to predict architecture.

The sequence is:

```text
implement real consumer
↓
observe repeated composition
↓
extract reusable primitive
↓
prove it again
↓
only then scaffold/generate
```

A generator that freezes the wrong abstraction creates structural debt faster than manual work.

---

# 20. Source Reality and Behavioral Truth

When adopting or rewriting a product, distinguish:

```text
Implementation Truth
= what source currently does

Behavioral Truth
= what users/systems can actually observe

Claimed Truth
= what docs/plans say should happen
```

A discrepancy must be explicit.

Do not silently substitute claimed truth for behavioral truth.

For a fixed source revision/environment, a serious rewrite assessment should be able to build a Capability Census using redundant discovery:

1. scope freeze;
2. mechanical artifact census;
3. surface census;
4. state/effect census;
5. runtime capture where possible;
6. capability synthesis;
7. forward and reverse reconciliation;
8. adversarial missingness pass;
9. behavioral oracle freeze;
10. explicit disposition.

Unknown remains `UNKNOWN`.

---

# 21. Product Archaeology and Rewrite Method

Warp Prism's rewrite capability is not "port the old app to Flutter/Rust".

The method is:

```text
Freeze truth
↓
Extract capabilities
↓
Classify ownership / control-plane / data-plane
↓
Resolve reusable Warp primitives
↓
Define target architecture
↓
Implement vertical slices
↓
Shadow / parity / behavioral oracle checks
↓
Harvest repeated patterns
↓
Promote only survivors
```

Do not port screens, files, endpoints, or folder structures as architecture.

Preserve observable capability and intentional product semantics.

Replace implementation when justified.

---

# 22. Rewrite Manifest

A rewrite-ready workflow should eventually produce a machine-readable manifest that can answer, for each capability:

- source evidence;
- behavioral oracle;
- disposition;
- target owner;
- reused Warp primitives;
- product-local components;
- migration dependency;
- parity evidence;
- acceptance state.

The manifest should make rewrite progress inspectable.

Do not build a universal resolver before the methodology is proven manually/semi-automatically.

---

# 23. Existing → Ideal Mapping

Rewrite analysis should explicitly distinguish:

```text
Existing
→ Preserve
→ Improve
→ Replace
→ Reject
→ Remove
```

Architectural decisions should record why an old design may have seemed reasonable, not merely label it bad.

The purpose is to build a durable architectural judgment corpus, not a blame corpus.

---

# 24. Warp Prism Learns From Consumers

Every serious consumer is both:

```text
consumer of Warp Prism
and
teacher of Warp Prism
```

The desired loop is:

```text
Warp Prism primitive
→ real product
→ friction / gap / success evidence
→ product retrospective
→ candidate improvement
→ second proof
→ governed promotion
→ stronger Warp Prism
```

The framework should become more useful because products exist.

Products must not be distorted merely to make Warp Prism look reusable.

---

# 25. First Real Product Pilot

After L1 Integration-Capable is achieved, run a **real product vertical pilot** before declaring Warp Prism Rewrite-Capable.

The preferred initial pilot may be an OmniRoute provider-management/provider-foundation vertical if it remains a good source-reality fit at execution time.

It is a candidate, not an axiom.

The selected pilot should include enough real behavior to test:

- visual composition;
- IDS semantics;
- runtime contracts;
- fake/reference parity;
- real adapter behavior;
- errors;
- health/status;
- async command flow;
- event flow where applicable;
- product-domain projection;
- boundary purity.

Do not start by rewriting the entire product.

Choose one bounded vertical.

---

# 26. Pilot Harvest

After the first real pilot:

STOP.

Perform a structured harvest before broad rewrite work.

Ask:

- Which abstractions fit cleanly?
- Which were awkward?
- Which needed bypass?
- Which contracts were missing?
- Which "generic" concepts were actually product-specific?
- Which boundaries prevented bugs?
- Which boundaries caused unnecessary friction?
- Which recurring compositions justify promotion?
- Which tooling would now save repeated work?
- Which ideas should be rejected?

Only survivors may shape L2 and later L3 work.

---

# 27. Maturity Model

Warp Prism matures through four levels.

These levels are evidence states, not branding.

---

## L0 — ADS

Meaning:

> Warp Prism is a credible reusable Flutter visual design system.

Expected evidence includes:

- governed visual tokens/themes;
- stable reusable component vocabulary;
- accessibility discipline;
- catalog/gallery;
- deterministic tests;
- public API discipline;
- package purity;
- accepted visual contract.

L0 largely exists from the v1 program, subject to current source/review truth.

L0 is not sufficient for general runtime integration or rewrite claims.

---

## L1 — Integration-Capable

**CURRENT ACTIVE TARGET**

Meaning:

> Warp Prism can connect reusable Flutter interaction/presentation primitives to a real Rust runtime through backend-agnostic contracts without collapsing layer boundaries.

L1 requires, at minimum:

### Foundation

- v2 charter/current mission alignment;
- explicit layer contracts;
- deterministic boundary enforcement for enforceable invariants;
- package/topology ownership clear enough for implementation;
- state-based active/historical governance;
- current visual baseline not falsely claimed.

### IDS

- current interaction inventory;
- a small candidate IDS kernel;
- evidence-backed promotion disposition;
- no unnecessary product-domain coupling.

### Runtime Contracts

- current consumer/runtime audit;
- small experimental contract set;
- typed semantic DTO/lifecycle model;
- fake/reference implementations;
- reusable contract testkit;
- binding proof.

### Rust / FRB Golden Path

- compatible toolchain spike;
- minimal Rust bridge substrate;
- FRB adapter isolated from generic packages;
- Dart→Rust typed async command proof;
- Rust→Dart event/stream proof where required;
- typed error propagation;
- cancellation semantics where applicable;
- fake/real semantic parity;
- reproducible generated bindings;
- Linux integration-lab build/run evidence.

### Boundary invariants

At L1:

```text
warp_prism_ui
MUST NOT import flutter_rust_bridge

generic runtime contracts
MUST NOT know application-domain types

generic runtime contracts
MUST NOT encode Flutter presentation concepts

Rust FRB glue
MUST NOT own application business logic

connected presentation
MUST cross a declared runtime/binding boundary
```

### L1 Exit

The L1 exit is:

> **Integration Readiness Gate**

It is NOT Rewrite Readiness.

L1 proves integration capability.

It does not yet prove systematic product rewrite capability.

---

## L2 — Rewrite-Capable

Meaning:

> Warp Prism plus its rewrite methodology have survived a real consumer pilot and can be used with evidence to recompose a product capability rather than merely build isolated integration examples.

L2 requires:

```text
L1 PASS
+
one successful real product vertical pilot
+
post-pilot harvest
+
behavioral freeze / capability census methodology proven
+
contract testkit useful against real product work
+
product-domain bypass demonstrated when appropriate
+
migration/rewrite receipts sufficient to judge parity
```

The L2 exit is:

> **Rewrite Readiness Gate**

Do not call the L1 Integration Lab "Rewrite Ready".

A real product must come first.

---

## L3 — Rewrite Factory

Meaning:

> Repeated rewrite experience has produced enough proven recurrence that substantial parts of capability mapping, primitive resolution, scaffolding, contract selection, and migration planning can be mechanized without freezing speculative architecture.

Possible L3 capabilities include:

- component/contract registry;
- resolver;
- rewrite manifest compiler;
- scaffolding;
- templates;
- boundary doctor;
- performance recipes;
- automatic or semi-automatic candidate mapping;
- migration DAG tooling.

None of these is required merely because it is imaginable.

L3 must be extracted from L2 evidence.

> **Never implement the Rewrite Factory in order to become Rewrite-Capable.**

---

# 28. Automatic Maturity Progression

The active mission should advance without unnecessary user ceremony when evidence gates are objective and current governance authorizes continuation.

Expected progression:

```text
L1 work
↓
Integration Readiness PASS
↓
select bounded real pilot from current source reality
↓
execute pilot
↓
independent acceptance
↓
Pilot Harvest
↓
Rewrite Readiness / L2 evaluation
↓
if PASS:
    enter L2
```

Do not ask the user merely:

```text
"Should I continue to the pilot?"
```

if the mission, milestone and current governance already authorize it.

A real product decision, scope commitment, external credential, spend, or other genuine human-only gate still requires the proper authority.

---

# 29. Current Active Mission — L1

As of this mission epoch, the project should prioritize:

```text
Foundation
→ IDS candidate kernel
→ Runtime Contract MVP
→ Bindings
→ FRB compatibility spike
→ Minimal Rust bridge
→ Integration Lab
→ Integration Readiness
```

Independent branches may proceed in parallel where dependencies and writesets allow.

Do not serialize IDS and Runtime Contract discovery merely because they are listed sequentially.

Do not allow premature FRB implementation to redefine the generic contract model.

Do not allow speculative L3 tooling to steal attention from L1 proof.

---

# 30. Connected Catalog Progression

Catalog maturity should grow approximately as:

```text
Static
↓
Interactive / fake
↓
Minimal connected proof
↓
real consumer-informed connected examples
↓
registry/resolver only when recurrence justifies
```

A minimal connected Catalog proof may occur before the first real product pilot.

A generalized registry/resolver should not.

---

# 31. Quality Gates

Every reusable layer should have gates appropriate to its claims.

Expected categories include:

- formatting/lint;
- unit tests;
- widget tests;
- semantics/accessibility tests;
- golden/visual tests where appropriate;
- package boundary tests;
- dependency direction checks;
- contract tests;
- fake/reference tests;
- real adapter integration tests;
- generated-surface reproducibility;
- Linux build/run evidence for the Rust/FRB path;
- performance baseline where a performance claim exists.

Green tests prove only their own scope.

Do not derive system maturity from aggregate test count.

---

# 32. Boundary Enforcement

Documentation explains architecture.

Deterministic gates enforce everything mechanically enforceable.

Examples suitable for deterministic enforcement include:

- forbidden imports;
- dependency direction;
- direct FRB imports from UI;
- direct product-domain type leakage;
- unauthorized token-registry mutation;
- root scratch hygiene;
- generated binding drift;
- package purity.

A grep being possible does not automatically make it a valid hard gate.

Every hard gate should be precise enough to avoid known false positives.

Classify proposed checks as:

```text
MECHANIZABLE_NOW
READY_TO_ENFORCE_NOW
PHASED
```

---

# 33. Public API Discipline

Warp Prism is a reusable system.

Public APIs are contracts.

Preserve or intentionally migrate:

- public `Prism*` APIs;
- stable package barrels;
- component semantics;
- token/theme roles.

Internal implementation namespaces may evolve more freely.

Do not accidentally make generated, adapter-specific, or experimental surfaces permanent public API.

Breaking public contract changes require explicit migration rationale and evidence.

---

# 34. Accessibility

Accessibility is part of product correctness.

Reusable components and interaction semantics should preserve:

- semantic labeling;
- keyboard reachability;
- focus visibility;
- logical traversal;
- sufficient contrast;
- understandable disabled/error/loading states;
- predictable selection behavior.

An IDS abstraction that damages accessibility is not reusable excellence.

Catalog and tests should make accessibility failures visible.

---

# 35. Determinism and Testability

Reusable primitives should be testable without hidden service dependencies.

Prefer:

- injected sources;
- fake/reference runtimes;
- deterministic fixtures;
- explicit clocks/schedulers where timing matters;
- controlled event streams;
- typed errors.

Do not require live Ganthritor/CyberCore/OmniRoute infrastructure merely to test Warp Prism core semantics.

---

# 36. Performance Discipline

Performance claims require measurements.

For UI/runtime integration, measure when relevant:

- frame responsiveness;
- event throughput;
- bridge crossing count;
- serialization overhead;
- memory pressure;
- large-payload behavior;
- stream backpressure;
- startup/connection cost.

Do not optimize one micro-operation while end-to-end interaction remains bottlenecked elsewhere.

Baseline first.

Optimize second.

Re-benchmark third.

---

# 37. Cross-Platform Discipline

Warp Prism is a Flutter system and should avoid unnecessary platform coupling in generic packages.

The initial Rust/FRB proof may prioritize modern Linux desktop because it is a critical Ganthritor-family target.

Do not turn Linux-specific bridge/runtime implementation details into generic ADS/IDS/runtime ontology.

Future desktop/mobile/web support is allowed when product evidence justifies it.

Do not claim support that has not been built and exercised.

---

# 38. Consumer-Driven Upstream Policy

When a consumer needs a reusable capability that Warp Prism lacks:

```text
consumer need
↓
does a proven Warp primitive already fit?
  yes → reuse
  no  → is semantic cross-domain recurrence already evidenced?
          yes → candidate upstream primitive
          no  → product-local/provisional implementation
↓
record gap
↓
continue product work
↓
harvest evidence later
```

A missing Warp abstraction should not automatically block the consumer.

Do not prematurely upstream product-specific code.

---

# 39. Architecture Economy

Prefer the minimum structure that preserves correct ownership.

Rules:

```text
concept
!= package

package
!= crate

one conceptual layer
!= mandatory physical repository subtree

future use
!= present boundary justification
```

Create structure when it buys:

- independent reuse;
- clearer dependency direction;
- test isolation;
- build isolation;
- ownership;
- lifecycle separation.

Do not create folders/crates/packages as architecture theater.

---

# 40. Rewrite Economics

The long-term success condition is increasing reuse without decreasing semantic fit.

A healthy trajectory may look like:

```text
Product A:
60% reusable / 40% product-specific

Product B:
75% reusable / 25% product-specific

Product C:
85% reusable / 15% product-specific
```

These percentages are illustrative, not KPIs.

Do not game reuse rate.

The goal is:

> more real capability assembled from proven primitives with less repeated glue.

---

# 41. Non-Goals

Warp Prism MUST NOT expand merely because adjacent capabilities are interesting.

Unless explicitly promoted by evidence/current mission, Warp Prism is not responsible for:

- product business logic;
- domain databases;
- durable product state;
- provider/model routing;
- agent orchestration;
- project memory;
- authentication;
- application networking;
- application routing;
- domain-specific graph models;
- media processing engines;
- inference runtimes;
- generic RPC/daemon platform;
- every possible runtime contract;
- automatic rewrite machinery before L2 evidence;
- universal scaffolding before recurrence;
- rewriting consumers wholesale merely to prove Warp Prism.

---

# 42. Mission Evidence Precedence

For determining whether this mission is satisfied:

```text
current observed runtime/source
        ↓
fresh deterministic test/evidence
        ↓
independent review/acceptance
        ↓
canonical architecture/governance
        ↓
active task/epic plan
        ↓
historical artifact
        ↓
conversation / brainstorm
```

A plan does not prove a feature.

A package does not prove adoption.

A fake does not prove a real adapter.

A connected demo does not prove rewrite capability.

A pilot does not prove a rewrite factory.

---

# 43. Completion Semantics

Do not say:

```text
Warp Prism complete
Rewrite Ready
Rewrite Factory ready
production-ready
fully generalized
```

unless the corresponding maturity gate is satisfied.

Use exact language:

```text
L0 ADS accepted
L1 Integration-Capable
L2 Rewrite-Capable
L3 Rewrite Factory
```

A higher level implies the required lower-level evidence remains valid or has been re-established after material semantic changes.

---

# 44. Mission Stop Conditions

The mission control plane must not stop merely because:

- one epic completed;
- one task wave completed;
- current `01-open/` drained;
- Integration Lab passed;
- a checkpoint was published;
- CI is green;
- a consumer is externally blocked;
- a future step can be described.

If the active maturity target remains open:

```text
queue empty
↓
audit mission gaps
↓
materialize legitimate work
↓
continue
```

A human blocker on one branch must not block independent work.

---

# 45. Current Definition of Done — L1 Integration-Capable

The **current active mission gate** is complete only when all applicable items below are established by fresh evidence.

## Product / Architecture

- [ ] v2 charter/mission are canonical and mutually consistent.
- [ ] ADS / IDS / Runtime / Bindings / FRB adapter / Rust ownership boundaries are documented.
- [ ] mechanically enforceable high-confidence boundaries are enforced.
- [ ] `warp_prism_ui` remains presentation-pure.
- [ ] domain leakage into generic core is prevented.

## ADS

- [ ] current accepted visual contract remains intact or intentionally superseded.
- [ ] Catalog builds independently of live backend services.
- [ ] required accessibility/widget/visual gates remain green.
- [ ] public ADS contract remains controlled.

## IDS

- [ ] current interactions are inventoried.
- [ ] a deliberately small candidate IDS kernel exists.
- [ ] semantics are tested deterministically.
- [ ] Flutter-specific mechanics do not unnecessarily contaminate the semantic core.
- [ ] each candidate has a promotion disposition.

## Runtime

- [ ] real consumer needs have been audited.
- [ ] minimal experimental Runtime Contract set exists.
- [ ] contracts encode runtime semantics rather than presentation policy.
- [ ] fake/reference implementations exist where feasible.
- [ ] contract testkit exists and passes against reference implementations.
- [ ] typed error/failure semantics are explicit.
- [ ] binding layer proves runtime semantics can map to Prism presentation.

## Rust / FRB

- [ ] actual toolchain compatibility spike passes.
- [ ] FRB version/toolchain compatibility is pinned only after proof.
- [ ] minimal Rust bridge substrate exists without speculative microcrate expansion.
- [ ] generated bindings are reproducible and not hand-maintained.
- [ ] Dart→Rust typed async command is exercised.
- [ ] Rust→Dart event/stream path is exercised where required.
- [ ] errors propagate truthfully.
- [ ] cancellation is proven where contract semantics require it.
- [ ] fake and FRB-backed implementations satisfy the same semantic contract suite where applicable.
- [ ] Linux Integration Lab builds and runs.

## Purity Invariants

- [ ] no Prism UI component imports FRB directly.
- [ ] no generic Runtime Contract owns application-domain business types.
- [ ] no generic Runtime Contract owns Flutter presentation/layout concepts.
- [ ] no Rust FRB adapter owns product business logic.
- [ ] product-specific semantics may bypass Warp rather than distort generic contracts.

## Evidence / Acceptance

- [ ] required implementation tasks have fresh evidence.
- [ ] independent review has accepted the L1 gate.
- [ ] semantic remediation invalidated/re-executed affected evidence.
- [ ] known material findings are closed or explicitly external/non-applicable.
- [ ] Integration Readiness is recorded without falsely claiming Rewrite Readiness.

When these are all true:

```text
WARP PRISM = L1 INTEGRATION-CAPABLE
```

Then proceed to the first real product pilot.

Do not stop for ceremony.

---

# 46. L2 Definition of Done — Rewrite-Capable

L2 may be claimed only when:

- [ ] L1 remains valid.
- [ ] one real bounded product vertical pilot has completed.
- [ ] pilot used real product-domain projection, not only fixtures.
- [ ] pilot exercised meaningful success and failure behavior.
- [ ] independent pilot acceptance passed.
- [ ] post-pilot harvest was performed.
- [ ] Capability Census / Behavioral Freeze methodology was exercised on real source.
- [ ] source capabilities were reconciled bidirectionally with target implementation.
- [ ] behavioral oracles/parity evidence were sufficient to judge the pilot.
- [ ] reusable vs product-local decisions were recorded.
- [ ] at least one abstraction was validated, amended, bypassed, or rejected because of pilot evidence.
- [ ] rewrite process can be repeated without rereading the original brainstorm as execution authority.

When these are true:

```text
WARP PRISM = L2 REWRITE-CAPABLE
```

Only then may broad rewrite-factory work become eligible.

---

# 47. L3 Definition of Done — Rewrite Factory

L3 is not pre-materialized by this mission.

It becomes a valid active target only after L2 evidence identifies repeated mechanizable work.

If/when activated, L3 should require evidence that:

- [ ] repeated rewrite compositions exist;
- [ ] automation targets known repetition rather than hypothetical repetition;
- [ ] registry/resolver data models are based on real primitives;
- [ ] generated plans preserve product-specific escape hatches;
- [ ] scaffolding/templates do not silently introduce architecture;
- [ ] generated outputs are reviewable and deterministic;
- [ ] boundary validation remains mechanized;
- [ ] rewrite manifests preserve source/provenance/parity traceability;
- [ ] at least two real rewrite experiences validate the factory mechanisms or an explicit stronger rationale exists.

Only then:

```text
WARP PRISM = L3 REWRITE FACTORY
```

---

# 48. Final Mission Maxim

Warp Prism succeeds when product teams can say:

```text
"I need Selection + Inspect + AsyncCommand + HealthSource
with a Rust implementation"
```

and assemble most of that from **proven reusable primitives** without:

- compromising the product domain;
- coupling presentation to transport;
- rebuilding common behavior;
- hiding failure states;
- inventing architecture from scratch.

The framework becomes stronger by surviving real products.

Not by becoming larger.

> **Build the minimum framework. Apply it to a real product. Harvest what repeats. Promote what survives. Repeat.**
