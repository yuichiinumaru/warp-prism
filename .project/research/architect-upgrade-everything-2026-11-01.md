# Architect Upgrade Plan — EVERYTHING Donor → Warp Prism (2026-11-01)

- **Lane:** Warp Prism architect — read-only planning synthesis, no implementation.
- **Donor root:** `references/everything/` (workspace-local; no absolute resolved paths used).
- **Governing law:** `MISSION.md` §3.1 full-coverage mandate + §11.4 amendment **WINS** over
  pre-amendment recurrence framing, stale bridge prose, and donor enthusiasm.
  `AGENTS.md` §§3–5, 7, 10–12 (readiness, source-reality, promotion discipline) apply.
- **Posture:** AMBITIOUS, not conservative. Absorb by default; unify via macro-review;
  improve, never blind-copy. Donor material is **inspiration only** — a donor-only idea with
  no Ganthritor product anchor is **not** a candidate (`macro-review §2.3`, `MISSION §10`).
  Ambition means: every donor mechanism that *attaches* to a real C-cluster or a real
  consumer component is pulled into the wave at the highest priority its evidence supports.
- **Inputs read (workspace-local):**
  1. `MISSION.md` §§1–11 (esp. §3.1, §5–6, §11.4) — governing law.
  2. `.project/research/donor-harvest-everything-2026-10-15.md` — 20 mechanisms (8H/8M/4L), §8 ranked seams.
  3. `.project/research/macro-review-unification-map-2026-10-20.md` — 11 clusters C1–C11, per-component dispositions (live Prism verified).
  4. `.project/architecture/cross-consumer-gap-matrix.md` — baseline (296 `Prism*` symbols, 0 consumer adoption) + recurrence rows.
  5. `docs/design/component-catalog.md` (2026-10-15) — canonical ADS index (atoms/molecules/organisms/templates).
  6. `references/everything/src/` directory listing this session (donor tree live-checked: `teamchat`, `spreadsheet`, `records`, `documents`, `pdf`, `whiteboard` UI files present).
  7. `packages/warp_prism_ui/lib/src/organisms/` + `packages/warp_prism_interaction/lib/src/` listings this session.
  8. `.project/research/figcraft-harvest.md` §§2–3 (A1–A10 architecture mechanisms — cross-donor corroboration).
  9. `docs/bridge/{warpblade,tempest,command-center,sentry}/` surfaces (presence-checked this session).

---

## 1. Mission §3.1 — what "ambitious" is allowed to mean

1. **Absorption is the default.** Every Ganthritor child-project UI component gets a Prism-native
   equivalent over time. Single-consumer UI is absorbed as CANDIDATE, never rejected for lack of recurrence.
2. **Macro review replaces selection.** Similar-purpose components unify (UNIFY), share chrome but keep
   ontology distinct (KEEP-DISTINCT), or stay local only when genuinely non-UI domain logic (KEEP_LOCAL-domain-only).
3. **Domain engines stay local.** Rational AV math, musical-grid math, DSP/plug-in hosting, LUFS/broadcast
   calibration, FFT/goniometer painters, credential storage, DAW orchestration — never enter Prism core.
4. **Evidence gates stand (§6 items 2–7):** fake/reference + conformance suite + boundary clearance +
   host-composition proof + FRB lifecycle proof where applicable + independent review.
5. **Coverage is bounded by real product components (§10).** Donor-only invention is out of scope no matter
   how elegant. Every wave below therefore cites its **consumer anchor** (C-cluster + named consumer component).
   Where no anchor exists the item is parked in §7 (inspiration backlog), not in the build wave.

## 2. Live Prism baseline (verified this session)

- **ADS (`warp_prism_ui`):** atoms (`PrismText/Icon/Badge/Chip/StatusDot/Divider/GlassPanel/Sparkline/Button/Checkbox/Switch/TextField/...`),
  molecules (`PrismStateSurface/Toast/HealthCard/AssetCard/MetricTile/ProvenancePill/EvidenceRow/TimelineMarker/Shimmer/Skeleton*/DraggableCard/DropTarget/Accordion/Dialog/Select/ColorField/...`),
  organisms (`PrismShell/Sidebar/Topbar/PageShell/Breadcrumbs/Tree/TabBar/SplitPane/LaneBoard(kanban)/DetailInspector/StoryPanel/FallbackView/ErrorBoundary/Timeline(log-list)/GraphCanvas/DataTable/VirtualList+Grid/StatusGrid/LogViewer/CommandPalette/MapHudWorkspace/ToolStripSlideout/FilterWorkbench/.../TimeMachineScrubber/ExecutionConsole/WorkflowCanvasStage/...`),
  templates (`MasterDetailTemplate` only).
- **IDS (`warp_prism_interaction`):** `input, inspection, query, selection, state_machine` — **no command-intent module**.
  Command intent is named in `MISSION.md:32` and currently unowned (macro-review §2.2 confirmed live).
- **Runtime/testkit/FRB:** 4 contracts exist as code (`AsyncCommand/EventStream/HealthSource/GraphSource`, all EXPERIMENTAL),
  fake + conformance per contract; FRB adapter is the only FRB importer; `warp_bridge_core` has 0 transport deps.
- **Known live gaps (macro-review §2.2, reconfirmed):** no transport organism (only private `_TransportButton` in
  time-machine scrubber); `DSStateType` has no honest-unknown member; `DSCommand` has no registry/shortcut index;
  `DSOperationalState` is binary (approved/rejected, no allow/constrain/deny, no reasoned-disabled);
  `PrismTimeline` is a log list not a lane; `PrismLaneBoard` is kanban not multitrack; table/list coverage is strong;
  meter geometry is linear/uncalibrated only.

## 3. EVERYTHING donor — what it actually is (source-grounded)

- **Donor:** Puter "Everything" monorepo, MIT (`references/everything/LICENSE`), vanilla JS/CSS/Vite — **not Flutter**.
  Value = *mechanisms and state machines*, never portable code. Donor accidents (A1–A11 in harvest §7:
  `el()/h()` helpers, store event-emitter, hash router, localStorage, Puter account dep, icon glyph set,
  WebRTC peer protocol, canvas painters, `structuredClone/debounce/keepFocus`, vite setup, domain coupling)
  are hard do-not-port.
- **Inspected:** 14 apps (teamchat, email, help-desk, crm-partial, projects, wiki, notes, documents, spreadsheet,
  records, whiteboard, presentation, pdf, tasks). **41 app dirs uninspected** — notably `audio-studio`,
  `video-studio`, `cad`, `calendar`, `meetings`, `time-tracking` — all directly relevant to Warpblade/Tempest
  and therefore a known future-harvest frontier (§8).
- **Counts:** 20 mechanisms (8 HIGH H1–H8, 8 MEDIUM M1–M8, 4 LOW L1–L4). Provisional HIGH ranking from harvest §2:
  shell state machine, sidebar section system, command triad, filter builder, presence layer, toolbar-panel framework,
  toast policy, composer.

## 4. Donor × macro-review join — the ambitious reading

The macro-review already did the hard join work. Every HIGH donor mechanism lands on a real C-cluster with a real
consumer anchor. There is **no orphan HIGH**. That is why this plan is ambitious: the donor is not a wishlist, it is
a second implementation sketch of seams Ganthritor consumers already independently demanded.

| Donor mech | Harvest value | C-cluster | Consumer anchor (why it is mandate-covered, not donor-only) | Verdict |
|---|---|---|---|---|
| H1 shell state machine (rail/sidebar/pane routing + focus restore) | HIGH | C10 | Tempest `MainShellLayout`, CC `CommandCenterShell`, Warpblade shell page | **P0 — IDS slot-router + focus-return token** |
| H2 sidebar section system (collapsible/drag-reorder/Starred/unread pills/kept-row fold) | HIGH | C10/C9 | Tempest nav, CC session list, Warpblade channel lists | **P0 — extend `PrismSidebar`** |
| H4 command catalog + palette + menubar + ribbon triad | HIGH | C5 | Warpblade `WarpbladeKeyboardRouter`, Tempest `CommandBarDialog`, CC `_GatedAction` | **P0 — IDS `CommandIntent` registry (unowned today)** |
| H5 rich filter builder (nested AND/OR, per-type editors, debounce-commit + flush) | HIGH | C9/C4 | `PrismFilterWorkbench` partial; logs/timelines/status grids everywhere | **P0 — `PrismFilterBuilder` organism** |
| H7 view-toolbar panel framework (button→popover→typed panel→flush→reanchor) | HIGH | C9 | Tempest library/models screens, CC session list, Warpblade takes | **P0 — `PrismToolbarPanel` framework** |
| H8 composer (autogrow + @mentions + emoji + formatting + attachment lifecycle + parked drafts) | HIGH | C4 | Warpblade comments, Tempest annotations, CC operator notes | **P1 — `PrismComposer` organism** |
| H3 thread side-panel (follow bell + also-send-to-channel + blocked states) | HIGH | C4 | Warpblade `ProposalPanel`, Tempest `CommandBarDialog`, CC `SessionDetail` | **P1 — decision-review surface already owns this; fold H3 into C4** |
| H6 presence layer (glide scaling, idle-name fold, per-user colour, culling) | HIGH | — (no current C) | Multi-user operational surfaces (Warpblade review, Tempest studio, CC ops) — anchor is *forthcoming multi-user*, not current single-user UI | **P1 — `PrismPresenceOverlay`, gated on first multi-user host** |
| M2 toast policy (cap-4, sticky, action, opener hand-back, onDismiss) | MED | C6 | Warpblade banners, Tempest `ProgressCard`, CC loading trio | **P0 — extend `PrismToastManager` (policy only, no new widget)** |
| M4 multi-view system (7 view types + per-view toolbar + typed-array grid) | MED | C9 | Tempest 7-branch shell, Warpblade takes matrix | **P1 — view-switcher + per-view toolbar contract (reuse `DSDataTable/VirtualGrid`)** |
| M7 ribbon (contextual tabs, priority collapse) | MED | C5 | Tempest declared `DawToolPalette`, documents-triad corroboration | **P2 — collapse-priority ribbon pattern (single-consumer until 2nd)** |
| M6 AI assistant panel (streaming + tool-call cards + approval modes + undo-per-reply) | MED | C4 | `PrismAiAnalystPanel` + `PrismToolCallCard` exist — donor adds approval-mode + cell-link mechanics | **P1 — extend analyst panel, do not duplicate** |
| M1 rail | MED | C10 | Tempest rail, CC shell | **P1 — rail as shell slot (fold into H1, not standalone)** |
| M3 field editor (type-first + per-type options + keepFocus) | MED | C9 | Tempest `QualityModeSelector`, Warpblade `GenerationDrawer` (P2) | **P2 — descriptor-driven form extension** |
| M5 attention/facilitation (raised hands, reactions, presenter-follow) | MED | — | No Ganthritor multi-user anchor today | **Park — inspiration only (§7)** |
| M8 tools panel (permission-gated tool list, take-view) | MED | C11 | CC `PermissionSection`, `_GatedAction` | **P1 — fold into `PrismActionGate` authority work** |
| L2 customer profile (segmented tabs + stats row) | LOW | C4 | CC `SessionDetail`, Warpblade `ProjectPanel` | **P2 — composition guidance, no new primitive** |
| L4 chart gallery grid | LOW | C9 | Tempest mastering-artist surfaces | **P2 — gallery-grid menu pattern** |
| L1 huddle dock / L3 ink tools | LOW | — | Audio/video + annotation domain | **KEEP_LOCAL — not Prism** |

Cross-donor corroboration (Figcraft, read 2026-10-15): A2 self-documenting command spec (5-field `id/label/params/history/run`,
one catalog for menus/shortcuts/palette/CLI/MCP) **directly corroborates H4** — build the registry once with agent-facing
`params` docs in the spec. A1 declarative layer table enforced in CI corroborates the boundary harness — adopt as a
harness hardening item, not a widget. B1 one-undo-per-gesture + B3 numeric-scrub field + B6 insertion-line reorder corroborate
H5/H2 interaction detail.

## 5. Ranked upgrade waves (impact order — ambitious, dependency-honest)

### WAVE P0 — shell + command + filter + toast (unblocks everything else)

1. **IDS shell-slot router + focus-return token (H1 → C10).** New IDS state machine: slot identity, active pane,
   focus-return token; organism `PrismShellRouter` over existing `DSShell/DSSplitPane`; molecule
   `PrismStartupFailureView` extending `DSFallbackView` (fail-closed bootstrap — Warpblade + CC anchors).
   Evidence: focus-restoration conformance; host proof in Command-center (real multi-pane host).
2. **IDS `CommandIntent` registry + shortcut index + dispatch router (H4+A2 → C5).**
   Pure-Dart registry: id/label/shortcut/applicability/enabled-reason + enumeration surface (the unowned IDS module);
   presentation stays `DSCommandPalette` + `DSToolStripSlideout`; router molecule carries the edit-focus guard
   (guard is presentation, eligibility is IDS — keep the split). Evidence: chord-collision/precedence + disabled-reason
   conformance; IDS purity test; host proof Warpblade + CC.
3. **`PrismFilterBuilder` organism + `PrismToolbarPanel` framework (H5+H7 → C9).**
   Nested AND/OR groups, per-type value editors, debounce-commit + flush-on-close, button→popover→typed-panel→reanchor.
   Evidence: fake model + per-type editor suite; determinism (no animation capture); host proof Tempest + CC.
4. **`PrismSidebar` section-model extension (H2 → C10/C9).** Custom sections, collapsible with kept-row fold
   (unread/current/badge rows survive collapse), drag-reorder with insertion line (Figcraft B6), Starred section,
   unread-edge pills. Evidence: keyboard-nav + kept-row conformance; host proof CC + Tempest.
5. **Toast policy layer (M2 → C6).** Cap, sticky, action button, opener focus hand-back, onDismiss-only-on-close-button.
   No new widget — extend `PrismToastManager`. Evidence: hand-back + cap conformance.
6. **State-vocabulary + capability-gate core (Sentry W6/W7 + C11 → C6/C11).**
   `DSStateType` gains honest-unknown + abstained/not-attempted with fail-closed rendering (unknown ≠ empty ≠ success ≠ disabled);
   IDS `ActionAvailability` (available | unavailable(reason) | terminal-for-dispatch | unknown) + `PrismActionGate`
   molecule (disabled-with-reason, never hidden). Highest-recurrence cluster in the corpus (4 independent re-inventions).
   Evidence: fail-closed suites; a11y reason propagation; host proof CC (`_GatedAction`) + Warpblade.

### WAVE P1 — review + composer + presence + meters/timelines chrome

7. **`PrismDecisionReviewSurface` organism (H3+M6 → C4).** Inspector sections + evidence rows + caller-supplied diff
   region + caller-supplied action bar; verdict pass-through invariant (unknown verdict → neutral, never accepted/pass —
   Warpblade's own rule generalized); AI-panel approval-mode + undo-per-reply folded in as options, not a rival surface.
   Evidence: pass-through-integrity suite; host proof in ≥2 hosts (Warpblade + Tempest).
8. **`PrismComposer` organism (H8 → C4).** Autogrow, @mentions, emoji, formatting bar, attachment lifecycle
   (inflight + parked-across-rebuild drafts), draft persistence per conversation key, caret preservation.
   Evidence: draft/caret conformance; host proof Warpblade + Tempest.
9. **`PrismPresenceOverlay` (H6 → new).** Viewport-cursor glide with room-size interval scaling, idle-name fold,
   stable-hash per-user colour, viewport culling, anonymous-input mode. Gated: needs first multi-user host proof;
   build behind the gate with fake room model. Evidence: glide/culling determinism (fixed-viewport goldens).
10. **Transport chrome + meter/fader geometry (→ C1/C2).** Organism `PrismTransportBar` (injected time model +
    injected formatter — Warpblade's `formatTime` shape is already correct; no time ontology in Prism);
    atom `PrismMeter` (injected scale + zone thresholds) + molecule `PrismFaderStrip`. Calibration (LUFS/dBFS/RMS),
    musical math, rational arithmetic stay product-local. Evidence: two-ontology fake suite (seconds + bars/beats);
    fixed-value goldens (no animation capture); Tempest studio host proof.
11. **Multitrack timeline chrome + IDS verbs (→ C3).** Molecule `PrismTimeRuler` + `PrismTrackLane` + playhead;
    IDS `TimelineIntent` verbs (seek/split/nudge/quantize over injected model). Blocking premise: validate injected-model
    seam on Warpblade side first (weaker layout, constructor-only `pixelsPerSecond`). Evidence: pixel↔time determinism;
    IDS purity; host proof Warpblade + Tempest.
12. **Provenance family (→ C7).** `PrismProvenanceBadge` (canonicity, existing pill) + `PrismWitnessBadge`
    (opaque hash + verified/unverified/mismatched/unknown — no hashing in Prism) + sealed rendering-mode contract
    (sealed ⇒ affordances **absent**, not disabled). Evidence: fail-closed verified-rendering suite; host proof CC + Warpblade.

### WAVE P2 — compositions, deferred, and parked

13. **Audition/compare matrix** (Warpblade takes over `DSVirtualGrid` + `DSLaneBoard`) — single-consumer composition.
14. **Descriptor-driven form** (M3 + Warpblade `GenerationDrawer`) — extend `DSAccordion` + `DSSelect`.
15. **Ribbon collapse-priority pattern** (M7) + **tool-mode palette** (declared `DawToolPalette`) — single-consumer.
16. **Graph/DAG proof** (C8): no new contract — prove real `GraphSource` consumer (Tempest `ProjectVersionDagTree`
    is DECLARED-not-built ⇒ blocked until a real DAG host exists); `PrismLineageStrip` molecule for SAME|DIFFER.
17. **PARKED — inspiration only, no build:** M5 attention/facilitation, L1 huddle, L3 ink, any donor-only widget with
    no Ganthritor anchor. Revisit only when a real product component demands it (§7 + §8 frontier).

## 6. Layer placement (normative — no leakage)

| New surface | Layer | Why |
|---|---|---|
| Shell-slot router, `CommandIntent` registry, `ActionAvailability`, `TimelineIntent` verbs | **IDS (pure Dart, no Flutter)** | User-intent semantics; IDS is the named owner (`MISSION §4.2`) |
| `PrismTransportBar`, `PrismFilterBuilder`, `PrismComposer`, `PrismPresenceOverlay`, `PrismDecisionReviewSurface`, `PrismTimeRuler/TrackLane`, `PrismToolbarPanel` | **ADS organisms/molecules** | Reusable visual + interaction chrome; `warp_prism_ui` only, no FRB/runtime imports |
| `PrismMeter` (geometry), `PrismActionGate`, `PrismJobBanner`, `PrismWitnessBadge`, `PrismStartupFailureView` | **ADS atoms/molecules** | Presentation of injected models; calibration/verification logic stays consumer-side |
| Command dispatch edit-focus guard, focus-return wiring | **ADS (presentation)** | Focus/DOM-equivalent concerns must not enter IDS |
| Data-plane hosts (`PrismSurfaceHost` for texture/media viewports) | **Adapter boundary, not ADS core** | Must declare transfer/ownership semantics (`MISSION §7`); highest gate burden — last in P1 |

## 7. What this plan deliberately does NOT do (non-goals)

- No porting of donor accidents (§3 table) — reimplement mechanisms, never donor code shapes.
- No time-ontology unification (SMPTE vs bars/beats vs wall-clock stay distinct; chrome unifies, models inject).
- No LUFS/dBFS/RMS calibration, DSP chains, FFT/goniometer painters, or credential stores in Prism.
- No speculative templates/scaffolds — crystallization requires validated integrations.
- No donor-only components without a Ganthritor product anchor, however polished (M5/L1/L3 parked).
- No consumer-frontend ownership — Catalog + host-exercise harness remain the only proof labs.

## 8. Evidence & tasking contract (for the builder wave)

- Per-candidate gates (`MISSION §6`): fake/reference + conformance + boundary clearance + host-composition proof
  (real host, real route, real interaction — package-local wrapper tests are necessary but **not sufficient** per
  `AGENTS.md §7.1`) + FRB lifecycle parity where applicable + independent review (no self-acceptance, `AGENTS.md §3.5`).
- Determinism: fixed viewports/values for goldens; indeterminate progress and animation-dependent capture excluded.
- A11y (each wave): semantics roles + text-scale + focus/keyboard-only path + reason-carrying disabled states.
- Suggested task split (one task per numbered item in §5; P0 items parallelizable except: shell-router and
  command-registry share no writesets — parallel-safe; sidebar-extension and toast-policy share no writesets —
  parallel-safe; filter-builder owns `FilterWorkbench` — serialize followers). Record `Parallelizable with`
  explicitly per task at creation time.
- Uninspected frontier (41 donor apps incl. `audio-studio`, `video-studio`, `cad`, `calendar`) is a **future harvest
  pass**, not a blocker — current waves proceed on the 14 inspected apps + macro-review anchors.

## 9. Traceability

- Donor harvest: `.project/research/donor-harvest-everything-2026-10-15.md` §§2–8 (§8 seams 1–8 all absorbed above).
- Macro-review: `.project/research/macro-review-unification-map-2026-10-20.md` C1–C11 (§4 per-component tables are the
  per-component authority; this plan adds only donor-mechanism detail, no re-disposition).
- Gap matrix: `.project/architecture/cross-consumer-gap-matrix.md` §§3–6 (recurrence rows now priority-only per §3.1).
- Figcraft corroboration: `.project/research/figcraft-harvest.md` A1/A2/B1/B3/B6.
- Consumer bridges: `docs/bridge/warpblade/ads-debt.md`, `docs/bridge/tempest/ads-debt.md`,
  `docs/bridge/command-center/prism-gap-components.md`, `docs/bridge/sentry/ui-component-requests.md`.
