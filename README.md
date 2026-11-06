# Warp Prism

**The reusable Flutter-side substrate shared by real products.**

Warp Prism is not a product and does not host product frontends. It is a library
and proof-laboratory project: a visual vocabulary, an interaction vocabulary, a
small set of backend-independent runtime contracts, and a Rust integration
golden path that real products build on.

---

## What lives here

| Package | Responsibility |
|---|---|
| `packages/warp_prism_ui` | **ADS** — tokens, themes, typography, atoms, molecules, organisms, reusable operational visual primitives |
| `packages/warp_prism_interaction` | **IDS** — user-intent semantics: selection, inspection, command intent, query/filter, focus/keyboard |
| `packages/warp_prism_runtime` | Backend-independent runtime contracts: `AsyncCommand`, `EventStream`, `HealthSource`, `GraphSource` |
| `packages/warp_prism_bindings` | Thin projections from contracts to Prism presentation |
| `packages/warp_prism_testkit` | Fakes and conformance suites for every contract |
| `packages/warp_prism_adapter_frb` | The **only** Dart package that imports `flutter_rust_bridge` |
| `packages/warp_prism_host_exercise` | Smoke / crawl / fuzz runner proving a real host can consume a capability |
| `rust/warp_bridge_core` | Transport-independent Rust domain core (zero transport deps) |
| `rust/warp_bridge_frb` | FRB projection / transport layer |
| `apps/catalog` | Owned proof laboratory: component gallery + connected bridge lab |
| `docs/bridge/` | Consumer bridge surfaces (symlinks into consumer-owned docs) |

---

## The one rule that shapes everything

**`warp_prism_ui` must never import `flutter_rust_bridge`, `warp_prism_runtime`,
`warp_prism_bindings`, or any adapter.**

Visual vocabulary and runtime integration are separate layers. This is not a
convention — it is mechanically enforced by
`packages/warp_prism_ui/test/boundaries/boundary_test.dart`.

The full normative matrix is in
[`.project/architecture/layer-contracts.md`](.project/architecture/layer-contracts.md).

---

## Consumers

Intended consumer family: **Warpblade**, **Tempest**, **Hyperion**, **Sentry**.

A missing Warp Prism primitive never blocks a consumer. Consumers implement
locally; Warp Prism harvests what genuinely recurs across consumers.

- Warp Prism never authors consumer documentation.
- Bridge content is owned by the consumer repository.
- A candidate becomes a stable Prism primitive only with recurrence evidence
  (≥2 distinct consumers or ≥2 distinct domains), a fake, a conformance suite, a
  boundary check, host-composition proof, and independent review.

See [`docs/bridge/README.md`](docs/bridge/README.md).

---

## Working on Warp Prism

```bash
# analyze
flutter analyze

# test a package
cd packages/warp_prism_ui && flutter test

# layer purity + boundary enforcement
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .

# Rust
cd rust && cargo test
```

Read before you change:

1. [`AGENTS.md`](AGENTS.md) — execution law
2. [`MISSION.md`](MISSION.md) — product destination and ownership boundary
3. [`.project/architecture/layer-contracts.md`](.project/architecture/layer-contracts.md)
4. The task file you were given, and every path in its `Where` table

---

## Documentation map

**Current authority**

| Path | Owns |
|---|---|
| `MISSION.md` | Product destination, ownership boundary, promotion evidence |
| `AGENTS.md` | Execution law, lanes, review, evidence discipline |
| `.project/architecture/layer-contracts.md` | Normative layer matrix |
| `docs/bridge/README.md` | Consumer bridge + harvest contract |
| `docs/design/charter.md` | Product charter |
| `docs/design/black-obsidian-visual-contract.md` | Visual canon + golden freeze policy |
| `docs/design/token-theme-catalog-policy.md` | Token layers, naming, promotion gates |
| `docs/governance/promotion-state-model.md` | Lane lifecycle |
| `.project/architecture/cross-consumer-gap-matrix.md` | Current accepted gap matrix |

**Historical only — never cite as current authority**

- `.archive/**` — archived planning and superseded artifacts
- `.project/tasks/04-completed/**` — completed task records
- `.project/memories/**` — role continuity
- `docs/reference/**` — external reference harvest, provenance unverified

The pre-reset planning corpus (L0–L3 maturity ladder, Rewrite-Factory framing,
27 EPIC files) is archived. See
[`.project/archive/epoch-reset-manifest.md`](.project/archive/epoch-reset-manifest.md)
for the per-artifact disposition and its canonical replacement.

---

## Governance

Parent: Ganthritor `AGENTS.md`. Reusable skills, agents, and rules are
parent-canonical under `.agents/` (symlinked). Warp Prism owns `AGENTS.md`,
`.project/`, `docs/`, `packages/`, `apps/`, and `rust/`.

Protected files — read before editing, ask before changing:
`AGENTS.md`, `README.md`, `MISSION.md`, `pubspec.yaml`, platform/build config.
