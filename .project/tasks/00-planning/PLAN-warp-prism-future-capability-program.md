# PLAN — Warp Prism Future Capability Program (Phase 2 materialization)

> **Planning Status**: Strategically Deferred (program-level). All tasks below are HOLD — see individual `HOLD-warp-prism-*.md` files.
> **Authority**: Phase 1 inventory `future-capability-program-inventory-2026-10-10.md` (REVIEWED — PASS, `ses_edbfcec4dffeX44ZMBOaLDsRWR`, §10 amendments) + mission of 2026-10-10.
> **Scope**: planning-only. No builder lane, no `01-open` moves, no implementation. Program EPICs below are mission-sense EPICs, NOT `E##` files (per `gt-architects-task-governance.md` §2.2 anti-spread gate: no Epic file without ≥5 stories; stories are enumerated here, not filed as `S##`).
> **Non-duplication**: disjoint from 02-doing (1840 gallery overflow, 1843 suppressor narrowing, 1846 formatter drift) and 03-review (1844 adapter-frb hardening — E-H1 coordinates, does not duplicate).

---

## Program EPICs (smallest coherent set)

### EPIC-A — Adoption & host-composition proof (G0/G1/G2)

- **Recurring problem**: zero external adoption + zero host-composition proof gates every STABLE promotion; recurrence detection is blind on Sentry/Hyperion (empty/absent surfaces).
- **Justifying consumers**: Warpblade + Tempest as proof hosts; Sentry + Hyperion as surface providers (evidence sources, not implementers).
- **Owning layer**: `warp_prism_testkit` + `warp_prism_host_exercise` (evidence machinery) + bridge process (consumer-owned).
- **Informing references**: host-exercise harness (existing method); ivisa `verify_components.py` (oracle method only); `AGENTS.md` §7.1 (affected-host evidence law).
- **Out of scope**: any primitive extraction; any consumer-side implementation (their governance); unifying ontologies.
- **Promotion/evidence conditions**: proof protocol accepted by program owner; ≥1 consumer host exercised per candidate; bridge requests answered by consumer governance.
- **Stories**: A-S1 host-proof protocol spec → `HOLD-warp-prism-host-proof-protocol`; A-S2 bridge-surface request package → `HOLD-warp-prism-bridge-surface-request`.

### EPIC-B — Machine-readable component/contract registry (G3)

- **Recurring problem**: catalog consumable only inside Dart; no verification loop; agents cannot discover components without hallucination.
- **Justifying consumers**: none (substrate prerequisite for verifying G4–G7, not consumer-demanded; stated as infrastructure risk, not recurrence).
- **Owning layer**: `apps/catalog` + taxonomy description.
- **Informing references**: ivisa `component-registry.json` (shape) + `harvest.ts` ts-morph AST→validate→write (method); explicitly NOT its React field types.
- **Out of scope**: mass-rename of code; replacing the Dart const registry (projection, not replacement); adopting TS/React content.
- **Promotion/evidence conditions**: schema accepted; harvest→validate→write loop reproducible from source; registry stays true without hand-maintenance.
- **Stories**: B-S1 registry schema + projection design → `HOLD-warp-prism-component-registry-schema`; B-S2 harvest/verify loop design → `HOLD-warp-prism-registry-harvest-verify-loop` (gated on B-S1).

### EPIC-C — Command-plan review lifecycle (G4+G9)

- **Recurring problem**: two substantial local propose→inspect→confirm/reject implementations + two diff viewers, no shared lifecycle.
- **Justifying consumers**: Warpblade (`ProposalPanel` 467 lines, Rust-computed diff) + Tempest (`CommandBarDialog` 385 lines + `PromptDiffViewer`).
- **Owning layer**: `warp_prism_interaction` (lifecycle semantics) + `warp_prism_ui` (diff surface).
- **Informing references**: ag-ui 4-phase tool-call envelope (`toolCallId`-owned); deepchat artifact envelope + pending-interaction terminal guards (pattern only, not chat taxonomy).
- **Out of scope**: unifying AV/musical time ontologies; extracting either consumer's widget; NLE/DAW edit verbs; desktop contracts.
- **Promotion/evidence conditions**: lifecycle spec + fake + conformance suite + host proof in one cooperating host (via EPIC-A protocol); IDS-PROVEN change care (lifecycle edits need owner review).
- **Stories**: C-S1 lifecycle semantic spec → `HOLD-warp-prism-review-lifecycle-spec`; C-S2 operational diff-viewer spec → `HOLD-warp-prism-diff-viewer-spec` (gated on C-S1).

### EPIC-D — Persistent operational state surfaces (G5+G6)

- **Recurring problem**: toast ≠ persistent staged job (cancel + deterministic receipt); health matrix missing keyring/quota axis.
- **Justifying consumers**: Warpblade (`ExportProgressBanner` + SHA-256 receipt; `DiagnosticsPanel`) + Tempest (`ProgressCard` prepare→chunk→post + cancel; `ProviderConnectionCard`).
- **Owning layer**: `warp_prism_ui` (surfaces) + `warp_prism_runtime` (`HealthSource` axis extension).
- **Informing references**: Tempest `ProgressCard` (consumer proof of shape); open-webui StatusHistory (corroboration only — existing organisms already cover it).
- **Out of scope**: generic notification system; LUFS/studio specifics; provider credential storage (consumer-side); unifying badge ontologies.
- **Promotion/evidence conditions**: spec + conformance + host proof; runtime-axis change needs runtime owner review.
- **Stories**: D-S1 staged job-progress spec → `HOLD-warp-prism-job-progress-spec`; D-S2 capability-badge axis spec → `HOLD-warp-prism-health-badge-axis-spec`.

### EPIC-E — Data-plane transfer & ownership contract (G7)

- **Recurring problem**: transfer/ownership rule declared (layer-contracts §8), contract type missing; transport vocabulary lives FRB-side only.
- **Justifying consumers**: Warpblade (`textureId` + metadata) + Tempest (peak/FFT native doctrine) — recurrence at contract level, never widget level.
- **Owning layer**: `warp_prism_runtime` (contract) + `warp_prism_adapter_frb` (projection). Coordinates with 03-review 1844 (adapter hardening — disjoint: hardening vs new contract type; sequence after 1844 resolves).
- **Informing references**: FRB zero-copy/codecs + `StreamSink` (transport facts); sim `ExecutionContext` pause/snapshot vocabulary (method only).
- **Out of scope**: media widgets; unifying data/control planes; modeling data plane as high-rate semantic events (forbidden by layer-contracts §8); any consumer texture/meter extraction.
- **Promotion/evidence conditions**: EXPERIMENTAL contract + fake + suite + native (true-FFI) evidence requirement; 1844 resolved first.
- **Stories**: E-S1 data-plane contract spec → `HOLD-warp-prism-data-plane-contract-spec`.

### Watch-list (no EPIC, no task)

- **G8 fail-closed startup surface**: single-consumer (Warpblade implemented; Tempest planned-only). Unlock = second consumer lands. Recorded, not materialized.

---

## Dependency DAG

```text
EPIC-A S1 (proof protocol) ── gates host-proof for ──► C-S1, D-S1, D-S2, E-S1
EPIC-A S2 (bridge requests) ── feeds ──► recurrence re-detection (future candidates)
EPIC-B S1 (schema) ── gates ──► B-S2 (loop) ── enables verification of ──► C/D/E specs
C-S1 ── gates ──► C-S2
1844 (in 03-review) ── resolves before ──► E-S1 promotion
Active hardening (1840/1843/1846) ── shares catalog writeset ──► B-S1/B-S2 sequence after
G8 ── no edges (watch)
```

## Task index (all HOLD in 00-planning/)

| HOLD file | EPIC/Story | Promotion gate (concrete unlock) |
|---|---|---|
| `HOLD-warp-prism-host-proof-protocol.md` | A-S1 | program acceptance (this doc) + host-exercise owner bandwidth |
| `HOLD-warp-prism-bridge-surface-request.md` | A-S2 | Sentry + Hyperion governance response (external) |
| `HOLD-warp-prism-component-registry-schema.md` | B-S1 | program acceptance; sequences after active catalog hardening |
| `HOLD-warp-prism-registry-harvest-verify-loop.md` | B-S2 | B-S1 schema accepted |
| `HOLD-warp-prism-review-lifecycle-spec.md` | C-S1 | program acceptance + IDS owner review (PROVEN surface) |
| `HOLD-warp-prism-diff-viewer-spec.md` | C-S2 | C-S1 lifecycle accepted |
| `HOLD-warp-prism-job-progress-spec.md` | D-S1 | program acceptance |
| `HOLD-warp-prism-health-badge-axis-spec.md` | D-S2 | program acceptance + runtime owner review (HealthSource axis) |
| `HOLD-warp-prism-data-plane-contract-spec.md` | E-S1 | program acceptance + 1844 review resolution |

Promotion target for all: `01-open` when gate met AND `AGENTS.md` §3.1 readiness holds (dependency satisfied, no blocker, scope explicit, writeset identifiable, validation known). No `E##`/`S##` files created (anti-spread §2.2). No `tasklist.md` rebuild (not requested, per §3.7).
