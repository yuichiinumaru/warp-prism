# Architect Upgrade — Command-Center → Warp Prism (Full-Coverage, Ambitious)

- **Artifact:** `.project/research/architect-upgrade-commandcenter-2026-11-01.md`
- **Date:** 2026-11-01
- **Lane:** Architect (read-only synthesis + upgrade decision map — no implementation, no tasks created here)
- **Governing law:** `MISSION.md` §3.1 + §11.4 (full-coverage central ADS/IDS, absorption default, recurrence = priority not gate, evidence gates §6.2–§6.7 stand, domain engines stay local). **MISSION WINS** over all pre-amendment dispositions.
- **Posture:** Ambitious, NOT conservative. Every mandate-covered command-center UI surface is absorbed or unified — none is left product-local by default.
- **Inputs read (all workspace-local, OBSERVED unless marked):**
  - `MISSION.md` §§3–6, §11.4
  - `.project/research/command-center-inventory-verification-2026-10-20.md` (both-legs live verification)
  - `.project/research/macro-review-unification-map-2026-10-20.md` (11 clusters, C1–C11 + P0/P1/P2 backlog)
  - `docs/bridge/command-center/prism-gap-components.md` (generated 2026-10-19; pre-amendment dispositions — superseded where they say product-local)
  - `docs/design/component-catalog.md` (checked 2026-10-15)
  - `.project/architecture/cross-consumer-gap-matrix.md` (accepted-with-amendments 2026-09-27; pre-amendment recurrence framing — superseded on conflict)
  - `.project/architecture/layer-contracts.md` (normative matrix, 16 enforced checks)
  - Live Prism: `packages/warp_prism_ui/lib/src/prism_aliases.dart` (295 `typedef/class Prism` declarations counted this session), `packages/warp_prism_ui/lib/src/{atoms,molecules,organisms}/`, `packages/warp_prism_interaction/lib/src/` (`input, inspection, query, selection, state_machine` — no command module), `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart:294-315`
  - Live command-center clone: `references/ganthritor-command-center/apps/command_center/lib/{features,integration}/` (1850 total LOC across 9 files, this session `wc -l`)
  - Live catalog host: `apps/catalog/lib/` (`main.dart` + `connected/`)

## 1. Mandate verdict (why this document overturns the bridge prose)

`docs/bridge/command-center/prism-gap-components.md` §4 says all 15 command-center widgets are "product-local; not a Prism candidate" (with 3 weak "candidate only if desired" hedges for `LoadingPane`/`LoadingRow`/`StateRegion`).

That disposition is **pre-amendment law and is superseded**. Under `MISSION.md` §3.1:

- **Absorption is the default.** A child-project UI component is absorbed unless a macro-review decision unifies it into a better shared primitive — never rejected for being single-consumer.
- **`KEEP_LOCAL` is valid ONLY for genuinely non-UI domain logic** — never a terminal disposition for a UI component.
- The §5 recurrence check no longer gates extraction; §6 item 1 no longer gates promotion of mandate-covered components. Evidence gates §6.2–§6.7 stand.

The verification report (2026-10-20) already records this overlay explicitly (§21 "Mission-law overlay"): the source finding (15/15 absent) stands, but governance **must route through absorption/macro-review/evidence gates, never blanket product-local**.

**Therefore: all 15 command-center widgets are in scope for Prism-native equivalents.** The only question is *shape* (REUSE / EXTEND / CANDIDATE / UNIFY), never *whether*. The per-widget shape decisions below inherit macro-review C6/C7/C10/C11 dispositions and extend them ambitiously.

Consumed-leg baseline (clean, no work needed): 10/10 consumed `Prism*` identifiers RESOLVE live (`PrismButton`, `PrismChip`+`ChipSize`, `PrismColors`, `PrismTheme`, `PrismNerazimTealSkin`, `PrismRadii`, `PrismSpacing`, `PrismStateSurface`+`StateType`, `PrismStatusDot`, `PrismOperationalState` family) — verification report §§31–33, 60–75. No missing-Prism-reference repair is in this upgrade.

## 2. Live baselines (what exists today — no inference)

### 2.1 Live Prism (OBSERVED this session)

- **Alias surface:** `packages/warp_prism_ui/lib/src/prism_aliases.dart` — 295 `typedef/class Prism` declaration lines counted via grep this session (doc claims 296; delta of 1 is UNKNOWN, immaterial to this plan — barrel is the authority, not the count).
- **Atoms present:** button, checkbox, text-field, badge, chip, divider, glass-panel, glow-border, icon, sparkline, status-dot, switch, text (`atoms/` listing this session).
- **Molecules present:** asset-card, draggable-card, drop-target, evidence-row, filter-chip-group, health-card, interactive-surface, metric-tile, provenance-pill (canonicity-only), search-bar, shimmer, skeleton-card/rows/text-line, **state-surface**, task-card, timeline-marker, toast/manager, uptime-bar, scale-measure-bar, accordion, color-field, dialog, select.
- **Organisms present (60+ dirs):** detail-inspector, error-boundary, fallback-view, graph-canvas, lane-board (kanban, NOT multitrack), shell, sidebar, status-grid, story-panel, timeline (**log list**, NOT lane), topbar, log-viewer, command-palette (no registry), execution-console, tool-call-card, provider-health-matrix, traffic-inspector, timing-waterfall, workflow-canvas-stage, time-machine-scrubber (only transport chrome in package — private `_TransportButton` + `_buildTransportRow`, `showTransport` flag), split-pane, tab-bar, shell-responsive, page-shell, plus map/ops/osint/terminal/media overlays.
- **`DSStateType` live enum** (`ds_state_surface.dart:294-315`): `empty, loading, error, disabled, stale, degraded, excluded`. **No `unknown`. No `abstained/not-attempted`.** Sentry W6/W7 complaint confirmed live.
- **`DSOperationalState`** (`tokens/ds_operational_state.dart:18-34`): binary `approved/rejected` + `archived` terminal. **No Allow/Constrain/Deny, no reasoned-disabled.**
- **IDS live dirs:** `input, inspection, query, selection, state_machine`. **No command-intent module.** Command *intent* (MISSION §32 named responsibility) is unowned.
- **`DSProvenancePill`** (`molecules/ds_provenance_pill.dart:8-41,110-127`): canonicity only. No hash, no verification state, no sealed mode (confirmed by input 3 grep + this pass's read).
- **Table/list coverage genuinely strong:** `DSDataTable` (sort/state/status/badge/timestamp/secret cells), `DSVirtualList`/`DSVirtualGrid`, `DSStatusGrid`, `DSLogViewer` + filter-bar + severity, `DSTree`, `DSBreadcrumbs`, `DSViewPresets`.

### 2.2 Live command-center (OBSERVED via workspace-local clone this session)

- 9 files, 1850 LOC: `features/connection_panel.dart` (394), `features/control_panel.dart` (431), `features/event_stream.dart` (167), `features/provenance_view.dart` (141), `features/sessions.dart` (340), `integration/loading.dart` (101), `integration/shell.dart` (189), `integration/theme.dart` (48), `integration/finder_anchors.dart` (39).
- 15 app widgets, all OBSERVED present in clone, all OBSERVED absent from Prism (word-boundary grep → 0 hits): `AbortSection`, `CommandCenterApp`, `CommandCenterShell`, `ConnectionPanel`, `ControlPanel`, `DaemonBootstrap`, `DaemonNotConnected`, `EventStreamView`, `LoadingPane`, `LoadingRow`, `PermissionSection`, `ProvenanceView`, `SessionDetail`, `SessionList`, `StateRegion` (verification report §§36–55).
- Richest real implementations in corpus: `_GatedAction`/`_DisabledButton` (`control_panel.dart:49-138`) — capability-gated abort with null-callback-as-capability; `PermissionSection` (`control_panel.dart:252-430`) — authority face; non-animated loading rationale (`integration/loading.dart:3-11`).
- Product-side inconsistency (not a Prism gap, noted for convergence): `integration/theme.dart:5-12` declares features/ must not import `warp_prism_ui` directly, yet `features/*.dart` do (`control_panel.dart:16`, `event_stream.dart:10`, `sessions.dart:7`, `provenance_view.dart:10`, `connection_panel.dart:10`).

### 2.3 Macro-review inheritance (this plan does not re-litigate)

- 98 UI units + 10 consumption rows across Warpblade/Tempest/CC/Sentry; dispositions REUSE 24 / EXTEND 20 / CANDIDATE 35 / KEEP_LOCAL-domain-only 19.
- Command-center §4.4 dispositions inherited as *starting* shapes: `AbortSection` CANDIDATE→C11; `CommandCenterShell` REUSE+EXTEND→C10; `ConnectionPanel` REUSE+EXTEND→C11; `ControlPanel` EXTEND→C4/C11; `DaemonBootstrap`/`DaemonNotConnected` EXTEND→C6/C10; `EventStreamView` REUSE (`DSLogViewer`); `LoadingPane`/`LoadingRow`/`StateRegion` EXTEND→C6 (GOLD); `PermissionSection` CANDIDATE→C11; `ProvenanceView` CANDIDATE→C7; `SessionDetail`/`SessionList` REUSE-composition (+C11-gated rows).
- Cross-cluster invariants enforced on every wave: inject-the-model-own-the-chrome; fail-closed-on-absence; disabled-with-reason-never-hidden; semantics-outside-widget; determinism-before-goldens; data-plane-separate-decision (macro-review §7).

## 3. Ambitious reinterpretation — all 15 widgets, ranked by impact

Ranked by (1) trust-defect prevention, (2) multi-consumer recurrence, (3) unblock of downstream waves. Impact rank, not build order (build order in §5).

| Impact | Widget(s) | Ambitious disposition (overturns bridge prose) | Prism seam | Multi-consumer proof |
|---|---|---|---|---|
| **I-1** | `AbortSection`, `PermissionSection`, `_GatedAction` | **CANDIDATE → flagship IDS + molecule.** The corpus's highest-recurrence cluster (4 re-inventions: Warpblade null-callback, CC gated-action, Tempest `onPressed:null`, Sentry W8/W9). A hidden action masquerading as not-applicable is a trust defect. | IDS `ActionAvailability`/`CapabilityState` (pure Dart) + molecule `PrismActionGate` + authority outcome extension | Warpblade + CC + Tempest + Sentry |
| **I-2** | `StateRegion`, `LoadingPane`, `LoadingRow`, `DaemonBootstrap`, `DaemonNotConnected` | **EXTEND → state vocabulary + startup-failure primitive.** `DSStateType` gains honest-unknown + abstained; loading chrome converges into `DSStateSurface` modes; fail-closed bootstrap becomes a molecule. | `DSStateType` extension + `DSStateSurface` convergence + `PrismStartupFailureView` (extends `DSFallbackView`/`DSErrorBoundary`) | CC + Warpblade (`WarpbladeStartupErrorPage`) + Sentry W6/W7 (#1 priority) |
| **I-3** | `ProvenanceView` (+ Warpblade strips, Sentry W2/W13) | **CANDIDATE → provenance family.** Canonicity-only pill is a trust defect when witness/immutability exist. | Atom `PrismWitnessBadge` (opaque hash + verification state) + sealed-rendering-mode contract + molecule `PrismLineageStrip` | CC + Warpblade (digest/fingerprint/SHA-256) + Sentry |
| **I-4** | `CommandCenterShell` (+ `CommandCenterApp` composition) | **EXTEND → shell slot router.** Multi-pane operator shell is the only real multi-pane host in corpus (Warpblade is negative evidence: single scrolling column). Slot state machine + focus-return is the hard, high-value part. | IDS shell-slot state machine + organism `PrismShellRouter` over existing `DSShell`/`DSSplitPane` | CC + Tempest (`MainShellLayout`) |
| **I-5** | `SessionList`, `SessionDetail` | **REUSE-composition + gated-row convergence.** No new table primitive — grouped list with per-row gated actions composes `DSDataTable`/`DSVirtualList` + `PrismActionGate` (I-1). Detail composes `DSDetailInspector`. Host-proof is the work, not construction. | Composition guidance + `PrismActionGate` rows; no new organism | CC primary; Warpblade takes-matrix as P2 composition |
| **I-6** | `EventStreamView` | **REUSE (`DSLogViewer`/`DSTimeline`/`DSExecutionConsole`).** Bespoke stream view is convergent duplication. Convergence + host proof, not a new viewer. | None new — adoption of existing organisms | CC + Warpblade banners + Tempest `ProgressCard` (job banner P1-5) |
| **I-7** | `ConnectionPanel`, `ControlPanel` | **EXTEND → decision-review surface + action-gate rows.** Review-before-commit surface (status header + evidence + computed diff + constraint list + bounded-override + accept/reject) composed from existing inspector/evidence rows + I-1 gates. | Organism `PrismDecisionReviewSurface` (C4) | CC + Warpblade (`ProposalPanel`/`AssurancePanel`) + Tempest (`CommandBarDialog`) |

`CommandCenterApp` root itself is **REUSE-composition** (`PrismTheme.dark()` + `PrismNerazimTealSkin`) — no new primitive; convergence only.

## 4. Upgrade waves (ambitious — build ALL of this)

### WAVE 1 — Trust core: availability + honest-unknown + witness (highest impact, unblocks everything)

**W1-A. IDS `ActionAvailability` / `CapabilityState` + `PrismActionGate` molecule (macro-review P0-1, I-1).**
- IDS pure-Dart semantics: `available | unavailable(reason) | terminal-for-dispatch | unknown`. Authority outcome vocabulary: `allow | constrain | deny` as generic semantics (NOT Sentry's decision model — domain leakage rule).
- Molecule renders disabled-with-reason (never silently hidden) + terminal-for-dispatch styling; reason propagated to semantics/a11y label.
- Absorbs: `AbortSection`, `PermissionSection`, `_GatedAction`/`_DisabledButton`; unifies Warpblade null-callback pattern, Tempest `onPressed:null`, Sentry W8/W9.
- Evidence gates: IDS purity test; conformance denied≠hidden≠enabled + reason propagation; keyboard-only + screen-reader path; host proof in **command-center** (richest implementation) + Warpblade; boundary clearance (no `Warpblade*`/`CommandCenter*`/`Sentry*` types in core); independent review.
- Risk: medium (IDS is `PROVEN`-labelled — extension needs architecture-owner review; UNKNOWN-12).

**W1-B. Honest-unknown + reasoned-abstention in state vocabulary (P0-2, I-2 core).**
- Extend `DSStateType` with `unknown` (system does not know — distinct from empty/error/disabled) + `abstained/not-attempted` (zero attempts — Sentry W7). Fail-closed rendering rule: unknown must NEVER degrade to empty/success/disabled styling.
- Converge `LoadingPane`/`LoadingRow`/`StateRegion` into `DSStateSurface` modes (GOLD candidate's own non-animated rationale `loading.dart:3-11` is the reusable invariant — determinism).
- Evidence gates: fail-closed conformance (unknown ≠ empty ≠ success ≠ disabled in both semantics label AND styling — dedicated test); determinism (indeterminate progress excluded from goldens); a11y state announcements; host proof in command-center (GOLD host) + Warpblade; independent review.
- Risk: low-medium. Blocking premise: none.

**W1-C. Provenance family (P0-4, I-3).**
- Atom `PrismWitnessBadge`: opaque hash string + verification state (`verified | unverified | mismatched | unknown`) — hashing/verification logic stays in consumer/backend. Fail-closed: unverified/unknown/mismatched NEVER renders as verified.
- Sealed-rendering-mode contract (presentation-level rule): when artifact is sealed, interactive affordances are ABSENT (not merely disabled) — asserted by test.
- Molecule `PrismLineageStrip` for SAME|DIFFER / derived-from / causation-grouping (covers `ProvenanceView` + Warpblade `_CompareStrip`/`_ProvenanceStrip`).
- Evidence gates: witness conformance (fail-closed); sealed-mode absence test; host proof CC + Warpblade; independent review.
- Risk: low (presentation), highest semantic consequence.

### WAVE 2 — Operator shell + fail-closed bootstrap (I-2 shell face, I-4)

**W2-A. IDS shell-slot state machine + `PrismShellRouter` organism (P1-7).**
- IDS: slot identity, active pane, focus-return token (pure Dart). Organism composes existing `DSShell`/`DSSplitPane`/`DSSidebar`/`DSTopbar` — no new layout primitives.
- Absorbs `CommandCenterShell` multi-pane/tab composition as convergence target; Tempest `MainShellLayout` converges (DUPLICATE — no extension for Tempest's shape).
- Evidence gates: focus-restoration conformance (the hard part — donor H1 focus-tracking is inspiration only, never code); multi-pane host proof in **command-center** (only real multi-pane host — Warpblade cannot supply it); determinism across layout transitions; a11y focus order.
- Risk: medium-high. Warpblade is negative evidence for workbench layout — do not count it as recurrence.

**W2-B. `PrismStartupFailureView` molecule (extends `DSFallbackView`/`DSErrorBoundary`, P1-7 + P1-4).**
- Fail-closed bootstrap: opaque fatal-startup surface, actionable message, no stack-trace leak. Absorbs `DaemonBootstrap` + `DaemonNotConnected` + Warpblade `WarpbladeStartupErrorPage` (now 2 consumers — recurrence satisfied AND mandate-covered regardless).
- Evidence gates: host proof in command-center; leak-negative test (no exception text in render); a11y.
- Risk: low.

### WAVE 3 — Operator compositions: sessions + event stream + control/connection panels (I-5, I-6, I-7)

**W3-A. Session compositions (REUSE — no new organism).**
- `SessionList` → `DSDataTable`/`DSVirtualList` + `DSStatusGrid` + `PrismActionGate` per-row actions (I-1 dependency) + grouped-section composition. `SessionDetail` → `DSDetailInspector` + `DSEvidenceRow` + witness badges (W1-C).
- The work is **host-composition proof** (weakest-evidence area of corpus — every REUSE claim is catalog-grade today), not construction: prove existing organisms compose in the real command-center host without wrapper-supplied ancestors/constraints/theme/routing/focus.
- Evidence gates: real-host exercise (launch host → sessions route → interact → no framework errors, no `ErrorWidget`, no `RenderFlex` overflow, theme/focus propagation intact); grouped-list + gated-row conformance; independent review of the composition (not of a new primitive).

**W3-B. Event-stream convergence (REUSE).**
- `EventStreamView` → `DSLogViewer` (+ filter-bar + severity) / `DSTimeline` / `DSExecutionConsole` per content shape. Bespoke stream view retired as convergent duplication.
- Evidence gates: same real-host exercise; filter + severity + empty/error/unknown states via W1-B vocabulary; determinism (no animation-dependent capture).
- Companion (multi-consumer, same wave): persistent job banner with staged progress + cancel + deterministic terminal receipt (`DEST/FRAMES/BYTES/SHA256` shape from Warpblade `banners.dart:95-155` generalized — receipt *content* stays consumer) unifying Warpblade export banners + Tempest `ProgressCard` (P1-5).

**W3-C. Decision-review surface organism `PrismDecisionReviewSurface` (P1-3, I-7).**
- Composes inspector sections + evidence rows + caller-supplied diff region + caller-supplied action bar. Verdict/status values pass through VERBATIM — unknown/absent verdict can never render as accepted/pass (Warpblade invariant `take_tiles.dart:5-11,29-63` generalized).
- Absorbs `ControlPanel` + `ConnectionPanel` gated-invocation shape + Warpblade `ProposalPanel`/`AssurancePanel` + Tempest `CommandBarDialog`.
- Evidence gates: pass-through-integrity conformance; host proof ≥2 hosts (command-center + Warpblade); tooltip-reason on every verdict (a11y); independent review.
- Risk: medium (composition breadth).

### WAVE 4 — Command registry + keyboard dispatch (P1-1, cross-consumer command face)

- IDS `CommandIntent` registry (pure Dart): command identity, label, shortcut chord, applicability predicate, enabled/disabled reason, enumeration surface. Presentation stays `DSCommandPalette` + `DSToolStripSlideout`. Dispatch router molecule with edit-focus guard (Warpblade `keyboard_shortcuts.dart:62-64` guard shape generalized; guard itself is presentation — eligibility predicate is IDS).
- Absorbs command-center `_GatedAction` invocation + Warpblade `WarpbladeKeyboardRouter` + Tempest declared `FloatingContextCommandBar`/`DawToolPalette`.
- Evidence gates: IDS purity; chord collision/precedence + disabled-reason propagation + enumeration-stability conformance; keyboard-only a11y path; host proof Warpblade + command-center.
- Risk: medium (second IDS extension — same UNKNOWN-12 review as W1-A; batch the IDS review).

### WAVE 5 — Full convergence: command-center deletes local copies (the ambitious flag-plant)

- Command-center adopts every Prism-native equivalent on its own schedule (bridge contract: non-blocking, no flag day) — then **deletes** the superseded local widget in favor of the Prism composition. Target end-state: `features/` + `integration/` contain only domain projection (health-source adapters, daemon wiring, causation grouping *data*) and zero generic chrome.
- Fix the product-side coupling-rule drift (`integration/theme.dart:5-12` vs direct `warp_prism_ui` imports in `features/`) as part of convergence: single seam via `integration/`.
- Catalog gains a command-center-flavored gallery section per new/changed primitive (visual discovery, not a second component list); `docs/design/component-catalog.md` updated in the same change as each primitive (catalog maintenance law).
- `PrismTokenRegistry` + M3 factory convergence for any residual command-center token duplication (none observed at scale — theme already consumes `PrismTheme`+skin; verify, don't invent).
- Evidence gates per MISSION §6: fake + suite + boundary clearance + **real-host exercise in command-center for every wave** + FRB lifecycle proof where the seam crosses the boundary (none of the CC seams cross FRB — record the negative explicitly per seam) + independent review + barrel export + API freeze before STABLE.

## 5. Build order (dependencies, not impact order)

```
W1-A (ActionGate IDS) ─┬─→ W3-A sessions (gated rows need gates)
                       ├─→ W3-C decision-review (action bar needs gates)
                       └─→ W4 registry (eligibility needs availability vocabulary)
W1-B (unknown/state) ──┬─→ W3-B event stream (states need vocabulary)
                       ├─→ W3-C (verdict fail-closed needs state discipline)
                       └─→ W2-B startup-failure (fail-closed needs unknown)
W1-C (witness/sealed) ───→ W3-A detail + W3-C review (evidence rows need badges)
W2-A (shell router) ───→ W5 convergence (shell adoption last — highest-blast-radius composition)
W3-* ─────────────────→ W5 (compositions proven before deletion of locals)
W4 ───────────────────→ W5 (registry adoption with palette)
```

Maximum safe parallelism: W1-A / W1-B / W1-C proceed concurrently (disjoint writesets: `interaction/` vs `ds_state_surface` vs provenance files). W2-A needs the W1 IDS review batched or sequenced — shared `interaction/` surface, serialize or split ownership. W3 never starts before its W1 dependency lands. W5 never starts before host proof for its wave exists.

## 6. Layer-law compliance (every wave)

- `warp_prism_ui` stays Flutter-only, `Prism*` public / `DS*` internal, no FRB/runtime/bindings imports (`layer-contracts.md` §1 row 1; checks 3–7, 12–13).
- IDS stays pure Dart, no Flutter/`dart:ui`, never a state-management framework (§1 row 2; check 11). Availability/capability/slot/command/timeline-intent are *semantics* — stores, controllers, and dispatchers stay in consumers.
- Runtime contracts carry semantics, never presentation policy (purge law). No auto-scroll/follow-tail/poll-every-X in any new seam.
- Bindings stay thin projections; `Offset` owned at binding edge only. No widget calls generated FRB directly (Global MUSTs 1/4/6).
- Domain leakage bidirectional: no `CommandCenter*`/`Warpblade*`/`Tempest*`/`Sentry*` types in the five core Dart packages (check 14); generic contracts never force consumer-core semantics (explicit bypass remains a feature).
- Data plane: none of the command-center seams carry data-plane payloads (no texture/peak/spectral). If a future waveform/peak surface is proposed from Tempest/Warpblade, it declares transfer + ownership first (MISSION §7) — out of this upgrade's scope.
- Every new layer/surface ships its boundary-harness check in the same task (layer-contracts §10 law).

## 7. Proof required (MISSION §6 — no wave is STABLE without all of these)

Per candidate: (1) mandate coverage + recorded macro-review decision (this document IS that decision for command-center scope — cite §3 rows); (2) fake/reference + conformance suite green; (3) boundary clearance; (4) **real-host exercise in command-center** (launch → sessions/connection/control/provenance routes → interact → framework-error/render-overflow/theme/focus/runtime checks); (5) FRB lifecycle proof where applicable (record negative explicitly — CC seams are UI/IDS-only); (6) independent review with explicit verdict; (7) barrel export + API freeze for STABLE.

Weakest-evidence warning (macro-review UNKNOWN-4): no host-composition proof exists anywhere in the corpus. Command-center is the first real host that both consumes Prism AND offers multi-pane/routes to prove against — this upgrade makes command-center the proof host, not just the donor. Schedule host-exercise harness work (`warp_prism_host_exercise` smoke/crawl/fuzz) as part of W3, not as an afterthought.

## 8. Explicit non-goals (ambitious does not mean unbounded)

- No app-root or router absorption: `CommandCenterApp`, `AppRouter`-equivalents, daemon wiring, persistence, credentials, and orchestration stay product-local (§4.5).
- No domain ontology: session/daemon/provenance *models*, causation computation, capability *evaluation* stay in command-center; Prism owns chrome + interaction semantics + rendering rules.
- No transport/meter/timeline-lane construction in this upgrade: P0-3/P1-2/P1-6/P1-8 are Warpblade/Tempest-led and proceed on their own tracks; command-center neither blocks nor donates to them.
- No donor-only construction: the 10 held donor mechanisms (macro-review §6-Held) stay held — no consumer demand, no candidacy.
- No flag-day migration: convergence is directional (MISION §3.1). Command-center adopts on its schedule; W5 deletion waits for STABLE + host proof per surface.
- No speculative templates/scaffolds: crystallization rule stands. Absorbing 15 product-proven components is not speculation.

## 9. Risks, unknowns, reconciliation debt

- **IDS scope question (UNKNOWN-12, load-bearing):** whether `ActionAvailability`, `TimelineIntent`, command registry, and shell-slot machine keep IDS "not a state-management framework" (MISSION §4.2). Owner decision required before W1-A/W2-A/W4 implementation. Batch into one IDS architecture review.
- **No host proof anywhere (UNKNOWN-4):** every REUSE claim is catalog-grade. Mitigation: this plan makes W3 host exercise the centerpiece, and command-center is the designated proof host.
- **Consumer revision states UNKNOWN** (macro-review UNKNOWN-2, verification §94-95): consumer citations are report-grade at 2026-10-15/20. Re-verify command-center paths at implementation time; record SHAs when VCS-authorized reads become available.
- **Count delta:** 295 vs claimed 296 alias declarations — immaterial; barrel is authority. Re-run exhaustive counts at implementation kickoff (verification §103).
- **Reconciliation debt (UNKNOWN-9):** `layer-contracts.md` §9 PROVEN row already reconciled (Task 1847); `docs/bridge/README.md` harvest loop + classification vocabulary and `docs/design/token-theme-catalog-policy.md` promotion gates still state recurrence. Downstream tasks must cite MISSION §3.1/§6-item-1 on conflict until those docs are reconciled. This document governs on conflict per MISSION §11.4.
- **Sentry evidence weakness (UNKNOWN-3):** Sentry has no Flutter UI surface — its W-items are DECLARED requests. Sentry-derived requirements (W8/W9/W6/W7/W2/W13) strengthen priority but never substitute for command-center/Warpblade host proof.
- **Bridge symlink unreadable from workspace** (verification §93, UNKNOWN-8): `docs/bridge/command-center` symlink target denied `external_directory`; this plan used the workspace-local clone `references/ganthritor-command-center/`. Note provenance on every downstream task.
- **Coupling-rule drift** (verification §94): fix in W5, not as a drive-by in W1–W4.

## 10. What the next owner does (handoff)

1. Batch IDS architecture review (W1-A + W2-A + W4 scope question) — one decision, three consumers.
2. Materialize W1-A/B/C as numbered tasks (one invariant per task, bounded writesets, exact validation commands, host-proof exit criteria naming command-center routes).
3. Keep W2/W3/W4 materialized in `00-planning/` as HOLD until their W1 premises land — promotion via canonical task-governance owner, never by builders.
4. Run the catalog diff (`component-catalog.md` §"Canonical sources and maintenance") at each wave landing.
5. Reconcile the three stale-recurrence docs (UNKNOWN-9) through task governance.

---

## Packet (return)

- **Mission:** MISSION §3.1 full-coverage absorption — all 15 command-center widgets in scope; bridge "product-local" dispositions superseded; recurrence = priority only.
- **Consumed leg:** 10/10 `Prism*` identifiers RESOLVE live — no repair work.
- **Absorption leg:** 15/15 absent — all routed: I-1 ActionGate (flagship, 4-consumer), I-2 honest-unknown + loading + startup-failure, I-3 provenance/witness/sealed, I-4 shell router, I-5 sessions REUSE, I-6 event-stream REUSE, I-7 decision-review surface.
- **Waves by build order:** W1 trust core (A gate / B unknown / C witness, parallel) → W2 shell + bootstrap → W3 compositions (sessions / stream+job-banner / review surface) → W4 command registry → W5 full convergence + local deletion.
- **Highest impact first:** W1-A capability-gated action (trust defect, 4 re-inventions) > W1-B honest-unknown (epistemic risk, Sentry #1) > W1-C provenance family > W2 shell > W3 compositions > W4 registry.
- **Proof host:** command-center is the designated real-host proof surface (multi-pane, consuming host, richest gated-action + loading implementations).
- **Laws enforced:** layer purity (16 checks), IDS pure-Dart, purge law, domain-leakage bidirectional, data-plane separation, MISSION §6 evidence gates, no flag day.
- **Blockers named:** IDS scope review (UNKNOWN-12); zero host proof corpus-wide (UNKNOWN-4); stale recurrence prose in 2 docs (UNKNOWN-9); consumer revision UNKNOWN; symlink provenance caveat.
- **Sources:** live `packages/warp_prism_ui` + `packages/warp_prism_interaction` + live clone `references/ganthritor-command-center/apps/command_center` + `docs/bridge/command-center/prism-gap-components.md` + `docs/design/component-catalog.md` + `.project/research/command-center-inventory-verification-2026-10-20.md` + `.project/research/macro-review-unification-map-2026-10-20.md` + `MISSION.md` + `layer-contracts.md`.
