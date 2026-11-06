# Warp Prism Upgrade Architect — FIGCRAFT-DONOR Wave (2026-11-01)

- **Role:** Warp Prism upgrade architect, ambitious posture (not conservative)
- **Donor:** FIGCRAFT via workspace-local `references/storytold-figcraft/` (live-verified this session)
- **Root:** `/home/sephiroth/working/ganthritor/warp-prism`
- **Governing law:** `MISSION.md` §3.1 full-coverage mandate + §11.4 amendment. MISSION WINS over stale recurrence prose.
- **Output:** exactly `.project/research/architect-upgrade-figcraft-2026-11-01.md` (this file). No code, no task creation, no promotion authorized here.

## 0. Sources read (evidence, not vibes)

| # | Source | Class | What was taken |
|---|---|---|---|
| 1 | `MISSION.md` §§3–6, §10, §11.4 | governing law | §3.1 absorption default, recurrence = priority not gate, evidence gates §6.2–6.7 stand, domain engines stay local §4.5, coverage bounded by real product components §10 |
| 2 | `docs/design/component-catalog.md` (102 lines) | canonical index | 36 atoms/molecules listed + 3 organism groups; no numeric field, no transport organism, no command registry; gallery sections are not components |
| 3 | `.project/research/macro-review-unification-map-2026-10-20.md` (§§1–10 incl. compact packet) | read-only synthesis, OBSERVED-LIVE Prism side / INHERITED-REPORT consumer side, zero execution | 11 clusters C1–C11, 98 UI units, P0 backlog (C11/C6/C1/C7), P1 backlog (command registry, timeline chrome, decision-review, job banner, meter/fader, shell slot router, timeline verbs), Held table of 10 donor-only mechanisms |
| 4 | `.project/research/donor-harvest-figcraft-2026-10-15.md` **Revision 4** (canonical rev4, corrective continuation) | `IMPL`/`TEST-DEF`/`DOC` mix, partial; inspiration only | A1–A9 architecture rows, B1/B2/B3/B6 deep + B4 partial, B5/B7–B10 `UNVERIFIED` and excluded, §5 local-fit resolutions (A1 present, A2 narrow lead, A3 excluded, B2 covered, B3 name-level lead), §8 five unresolved loci |
| 5 | `.project/research/figcraft-harvest.md` (Phase 1 rev2) | superseded-by-rev4 detail source, retained for A-list shape | A1 declarative layer table, A2 spec! macro catalog, A3–A10 runtime rows, B1–B10 widget rows, test-surface naming observation |
| 6 | **Live Prism this session** | OBSERVED-LIVE | `packages/warp_prism_interaction/lib/src/` = `input, inspection, query, selection, state_machine` — **no command module**; `packages/warp_prism_ui/lib/src/atoms/` = no numeric field; grep `PrismNumeric\|NumericField\|ActionAvailability\|CommandIntent\|insertion_line\|Drawn` over `packages/` = **zero hits**; `async_command_contract.dart:1-50` = single-flight cancel-and-replace, params carry no documentation, no enumeration surface |
| 7 | **Live donor this session** | OBSERVED-LIVE workspace-local | `references/storytold-figcraft/Cargo.toml`, `xtask/src/layers.rs:8-75` (TABLE + NETWORK + direct-deps loop, fail-closed), `crates/ui-egui/src/control.rs:205-230` (`engine.execute` dialog-drop + `engine.commands` self-doc `{id,label,params,menu,shortcut,undoable}`), `crates/ui-egui/src/field_math.rs` present |

**Revision honesty:** rev2's `.git/HEAD` SHA pin (`7459cc7…`) was withdrawn as inadmissible in rev4 §2.1. Snapshot identity remains `UNKNOWN`. All donor citations below are worktree-grade, not commit-grade. No donor build, test run, CI execution, or runtime observation was performed — no PASS claimed for any donor behaviour.

## 1. Architect thesis (why this wave is ambitious)

Macro-review correctly held 10 donor-only mechanisms out of the **consumer backlog** — §3.1/§10 bounds *stable widget coverage* by real product components, and a donor idea is not demand. **That holding governs widgets. It does not govern architecture, harness, testkit, or proof-lab upgrades.**

The ambitious reading, lawful under MISSION:

1. **Six of the ten "Held" items are not widgets at all.** They are contract shapes (A2), focus-restoration correctness (A7/A8), commit-boundary semantics (B1), test-seam conventions (B6 `grip_id`, `x_tests` naming, `windows_qa` tab-to pattern), enforcement economics (A1 table form), and determinism harnesses (A4/A5/A6). These land in IDS, runtime contracts, `warp_prism_testkit`, boundary harness, and Catalog proof-lab — **none requires consumer demand** because none claims stable widget promotion.
2. **One Held item (B3 numeric field) has no consumer today but has two certain future consumers.** Warpblade (`formatTime` injection already proves param editing exists) and Tempest (studio transport, mastering panels, track controls) will both need typed numeric entry with scrub/commit the moment P0-3/P1-6 land. Building it now as **EXPERIMENTAL proof-lab + conformance suite** (not STABLE, not barrel) is anticipation with a validated integration target, not speculative invention — the crystallization rule bars speculative *templates/frameworks*, never absorption of a product-proven shape, and here the shape preempts a known collision.
3. **The P0 backlog is under-powered without the donor.** P1-1 (command registry) without A2's drift-proof discovery field repeats the exact drift the donor eliminated. P1-7 (shell slot router) without A7/A8's draw-derived focus model repeats the hardest correctness bug in the corpus. P1-2/P1-8 (timeline chrome + verbs) without B1's commit boundary ships gestures with undefined undo.

**Therefore:** this wave proposes **8 ranked upgrades U1–U8**, every one mapped to a P0/P1 consumer backlog item or to a standing evidence gate. Nothing here creates a stable widget from donor inspiration alone. Everything here makes the consumer-backed backlog cheaper, more correct, or mechanically enforced.

## 2. Impact ranking (highest first)

> Ordered by: correctness stakes × backlog unblock × breadth of reuse × gate burden removed. Cost/risk noted per item, never used to demote a trust-critical fix.

### U1 — Self-describing command catalog (donor A2 → P1-1 command registry) · HIGHEST IMPACT

**Donor evidence (rev4 §3, `IMPL`):** `control.rs:221-226` — `engine.commands` serialises `{id, label, params, menu, shortcut, undoable}` per command. The agent-facing `params` doc string **is a response field of the catalog**, so discovery surface and machine catalog cannot drift. Rev2 corroborates the `spec!` macro shape (`cmd/mod.rs:34-56`, 455 ids, one path for menus/shortcuts/palette/CLI/control/MCP/WASM).

**Live Prism gap (confirmed):** `async_command_contract.dart:57-78` — `AsyncCommand<TParam,TResult>` has `status/execute/watchStatus/isClosed/close` with rich doc rationale but **no parameter-documentation field, no enumeration, no discovery surface**. Macro-review C5/P1-1 independently found the same hole from the consumer side: `DSCommand` carries `id/label/shortcut` but there is no registry, no applicability predicate, no shortcut index.

**Upgrade (architectural lead, not a widget):**
- Add an **opt-in self-description seam** to the runtime contract family: a machine-readable `describe()` / discovery enumeration returning `{id, label, params-doc, applicability, enabled-reason, shortcut, undoable}` — shape to be designed by the IDS/runtime owner, **no API proposed here**.
- Bind it to P1-1 acceptance: the P1-1 conformance suite MUST assert discovery↔catalog non-drift (the donor property), chord collision/precedence, and disabled-reason propagation.
- Presentation stays in `DSCommandPalette` + `DSToolStripSlideout`; the guard (`EditableText` focus check, Warpblade `keyboard_shortcuts.dart:62-64`) stays a widget concern, never enters IDS.

**Why first:** every command surface (palette, menubar, toolstrip, keyboard, control channel, MCP, WASM plugins) fans out from one catalog. A drifting catalog corrupts all of them at once. This is the cheapest trust defect to prevent and the most expensive to retrofit. It also converts rev4's "narrow lead" into the **backbone of the highest-recurrence consumer cluster's command face (C5 + C11)**.

**Law fit:** runtime-semantics enrichment, `warp_prism_runtime` stays presentation-free (dialog concepts stay out per rev4 §5.3). No domain leakage. Evidence gates §6.2–6.7 apply at P1-1 build time.

**Risk:** medium (IDS is `PROVEN`-labelled; extension needs its own review — macro-review UNKNOWN-12). **Blocking premise:** none.

### U2 — Draw-derived focus restoration + explicit region model (donor A7/A8 → P1-7 shell slot router) · CORRECTNESS-CRITICAL

**Donor evidence (rev4 §3, `IMPL`):** `a11y.rs:29-58` — `Region = Toolbar/Layers/Canvas/Properties`, `Canvas` default, stable ids, `Move::{Step,To}`, coalesced `pending` moves. `a11y.rs:86-99` — `struct Drawn`: **keyboard target derived from the previous frame's draw** (`rects/preferred/canvas/popup/row_focused`), `Nav` double-buffers `last/next: Drawn`, plus `refocus` counter for late-laid-out rows and `scroll_to` reveal. This is the only focus model in either corpus that survives layout churn without parallel registration.

**Live Prism gap (confirmed):** C10/P1-7 names focus-restoration as "the genuinely hard part" with a conformance gate and **no existing implementation**; donor H1's focus-tracking is cited as reference *idea*. Prism shells (`DSShell/DSSidebar/DSSplitPane`) have no slot state machine and no focus-return token.

**Upgrade:**
- Design the P1-7 IDS shell-slot state machine **around a `Drawn`-equivalent**: slot identity + active pane + **focus-return token derived from last committed layout**, not from a separately registered focus map. Carry the `refocus`-for-late-layout and `scroll_to`-reveal edge rules as explicit conformance cases.
- Adopt the `Region` pattern (ordered, stable ids, default region) for the four Prism shell slots.
- Keep the keyboard contract's *resolution bodies* (`a11y.rs:136-1021`, unread) as an explicit follow-up read — do not design traversal from the `DOC`-grade header alone (`a11y.rs:4-10`).

**Why second:** focus loss on layout change is the defect users feel in every multi-pane host (Command-center is the real host; Tempest the second). Everything else in P1-7 is composition; this is the correctness core. Donor gives us the only proven shape.

**Law fit:** IDS pure-Dart semantics; widget router owns the `EditableText`/focus-node mechanics. No `Drawn` code port — native re-expression. **Risk:** medium-high (hardest part of P1-7). **Blocking premise:** none, but traversal-resolution bodies must be read before detailed design (rev4 locus #2).

### U3 — Numeric field primitive as EXPERIMENTAL proof-lab (donor B3 → preempts P0-3/P1-6 param editing) · HIGHEST LEVERAGE WIDGET BET

**Donor evidence (rev4 §4, `IMPL` + `TEST-DEF`):** `field_math.rs:8-43` — `Typed = Value|Rel(Add|Mul|Div)`, division-by-zero → `None`, non-finite rejected, `%` unit-vs-relative rule, `MAX_LEN/MAX_DEPTH` bounds. `widgets.rs:20-133` — `Lead` doubles as accessible name (`W`→`Width`); `FieldEdit = Set|Scrub(live, ended)` makes the **commit boundary a type**; `Edit::settled` empty-field edge rule; `key_steps`/`scrub_amount` (Shift 10×, Alt 0.1×, **Shift+Alt falls through to 1×**); quantum-snapped `scrubbed`; screen-edge continuation; **release-frame moves nothing**. Tests: `field_tests.rs:18-52` (whitespace, comma decimals, precedence, units, relatives, `%` duality) + `windows_qa_tests.rs:63-78` (scrub → keep-after-release → no-collateral-mutation in one test).

**Live Prism gap (confirmed):** atoms contain `ds_text_field`/`ds_color_field` only; no numeric/scrub/arithmetic entry. `ds_metric_tile` is read-only display. Catalog has zero numeric-entry surface.

**Upgrade (deliberately EXPERIMENTAL, not STABLE):**
- Build `PrismNumericField` (atom) in Catalog proof-lab with the donor's **state machine, not its code**: `Set`-vs-`Scrub` commit boundary in the type, empty-field relative-edit rule, modifier-rate rules, quantum guard, release-frame no-op, `Lead`-as-accessible-name.
- Ship with a **ported test-definition suite** (table-driven parse cases + scrub-keeps-value + sibling-untouched) as the conformance seed. Table cases are re-expressible without copying donor source.
- Promotion path: EXPERIMENTAL → PROVEN only when Warpblade transport params or Tempest studio/mastering adopt it (mandate coverage will arrive; do not force it). Barrel export waits for that adoption.

**Why third:** this is the single most transferable widget mechanism in the donor, with the deepest test evidence, landing exactly where two P0/P1 hosts are about to need it. Waiting until both hosts hand-roll incompatible numeric fields and then unifying is more expensive than seeding the correct shape now.

**Law fit:** lawful EXPERIMENTAL candidate under §5 lifecycle; §6 gates apply before any promotion. No Figma-shaped ontology, no egui coupling. **Risk:** low-medium (isolated atom, no data plane). **Blocking premise:** none.

### U4 — Gesture-commit / one-undo-step boundary as IDS + review-surface invariant (donor B1 → P1-3 decision-review + P1-8 timeline verbs)

**Donor evidence (rev4 §4, `IMPL` + `TEST-DEF`):** `right.rs:26-57` — `set_props`/`field`/`field_of` each declare "one undo step"; mixed-field relative edits route per-layer from each layer's own value; **partial failure yields partial application** (observed, flagged as needing a correctness verdict). Commit boundary carried by `FieldEdit`; pinned by `windows_qa_tests:63-78`.

**Consumer need:** C3 timeline verbs (seek/split/ripple/nudge/quantize) and C4 decision-review (accept/reject/bounded-override) both require a defined commit point: when does a live preview become history? Warpblade already states "semantics live outside the widget" (`timeline_intents.dart:5-8`); Tempest's 1289-line `StudioController` is the cost of not doing it.

**Upgrade:**
- Make **one-gesture-one-history-step with explicit live-vs-committed typing** a cross-cluster invariant (extends macro-review invariant #4): timeline verbs, decision-review actions, and U3's numeric scrub all share the `Set|Scrub` commit shape.
- Record the partial-application observation as an **explicit design question** for the IDS owner (fail-closed vs all-or-nothing per verb) — do not silently inherit donor behaviour.
- Conformance: scrub-keeps-value, release-frame-settles, mixed-field per-layer routing, and unknown-verdict-never-passes (P1-3 pass-through integrity).

**Why fourth:** converts three separate P1 conformance suites into one shared invariant, and answers UNKNOWN-12's IDS-scope question with a concrete, bounded proposal (commit boundary is semantics, not state management).

**Risk:** medium (spans IDS + two organisms). **Blocking premise:** P1-2's injected time model for the timeline-verb half.

### U5 — Reorder with insertion affordance + deliberate test seams (donor B6 → C9 matrix + LaneBoard/VirtualGrid composition)

**Donor evidence (rev4 §4, `DOC` + `IMPL`):** `list_drag.rs:1-60` — grip-strip drag, insertion line following pointer, drop moves with **one command (one undo step)**, Design-panel-reversed vs model-bottom-first ordering split, `ListDrag{reversed, dragging, rows, label}`, `widgets.rs:845 insertion_line`, and a `#[cfg(test)] grip_id` **deliberate test seam**.

**Live Prism fit:** `PrismDraggableCard` + `PrismDropTarget` exist; reorder-with-indicator does not. The P2-1 audition/compare matrix (Warpblade takes) composes over `DSVirtualGrid` + `DSLaneBoard` and needs exactly this insertion semantic.

**Upgrade:**
- Specify insertion-line behaviour (position, label-follows-pointer, reversed-view rule) as part of the matrix composition guidance and any future LaneBoard reorder extension.
- Adopt the **test-seam practice**, not the code: stable test ids for draggable rows, `x_tests.rs`-mirrors-mechanism naming (rev2 §4 observation), and `tab_to`-by-accessible-name reaching (windows_qa pattern) as standing Catalog proof-lab conventions.
- One-command-per-drop inherits U4's commit invariant.

**Why fifth:** small, cheap, immediately reusable in composition guidance; the test-seam habit pays off across every interactive primitive. **Risk:** low. **Blocking premise:** none (P2-1 itself waits on P1-3 verdict discipline, but the insertion semantic and test seams do not).

### U6 — Declarative layer-table enforcement as maintenance economics (donor A1 → boundary harness) · CHEAPEST WIN

**Donor evidence (rev4 §3 + live re-read, `IMPL`):** `layers.rs:8-75` — crate→layer number TABLE, three direct-dep rules, 3-entry same-layer allowlist, fail-closed on cargo/JSON failure. Direct-deps only (`cargo metadata --no-deps`); transitive claim withdrawn (rev4 F6).

**Live Prism fit (rev4 §5.1, confirmed):** capability already present — `layer-contracts.md:192-234`, 16 mechanically enforced checks + 4 purity tests, reconciled 2026-10-11. Both mechanisms are the same evidence class (direct-dep checks, no transitive closure).

**Upgrade (owner's economics call, explicitly not a gap):**
- Evaluate collapsing the 16 hand-written assertions toward a **generated table + generic upward-dependency rule** in `boundary_test.dart`, keeping every current check green during migration.
- Preserve the drift lesson both sides learned: Prism's recovered enforcement-status column (2026-10-11) and the donor's table-derived status are the same defence against silent documentation drift.
- Do NOT claim transitive coverage either side lacks.

**Why sixth:** zero semantic risk, permanent maintenance saving, hardens the exact harness that guards every other upgrade in this wave. **Risk:** negligible (mechanical, fully gated by existing greens). **Blocking premise:** none.

### U7 — Deterministic capture + frame-boundary drain + cooperative cancellation as testkit/host-exercise upgrades (donor A4/A5/A6 → §6 gates 5–6)

**Donor evidence (rev4 §3, `IMPL` + `DOC`):**
- A4 `control.rs:73-122` — queue `mem::take`n at frame boundary, per-request window routing with requeue + repaint, unknown-window error.
- A5 `control.rs:50,98,156` — `AtomicBool` cancellation checked at both `drain` entries.
- A6 `control.rs:19-20,67,86-136,140` — `ui.screenshot` (window PNG, needs visible window, `SHOT_TIMEOUT=60s` bounded error) vs `ui.render` (document PNG, no chrome, headless-capable — **body unread, locus #3**); `document.inspect{depth}/node.get/ui.inspect` structured state alongside pixels.

**Live Prism need:** §6 gates 5 (host-composition proof) and 2–3 (fake + conformance) plus macro-review UNKNOWN-4 (no host proof anywhere) and invariant #5 (determinism before goldens). Meters/progress/timelines are the animation-capture traps.

**Upgrade:**
- Testkit: adopt the **two-tier capture discipline** (chrome-free deterministic render for goldens + windowed screenshot for chrome proof + structured inspect alongside pixels) in `warp_prism_testkit` and the host-exercise harness. Bounded waits with explicit visible-window errors, never unbounded.
- Runtime/binding guidance: frame-boundary drain shape + cooperative-cancellation check placement as reference patterns for FRB adapter work (P0-adjacent hardening, not a contract change — `AsyncCommand` cancel-and-replace already owns the semantic).
- Read the `ui.render` arm + `docs/control-protocol.md` (rev4 loci #3) before designing the headless path — do not extrapolate from the doc header.

**Why seventh:** unblocks the single largest program blocker (UNKNOWN-4: zero host-composition proof) with proven harness shapes. Ranked here only because U1–U6 change what ships; U7 changes how we prove it — essential, but downstream of having things to prove.

**Risk:** low-medium (harness-only). **Blocking premise:** locus #3 read for the headless arm.

### U8 — Standing regression nets: junk-parameter sweep + mechanism-mirrored test files (donor arch-doc + test-surface → quality gates)

**Donor evidence:** `docs/architecture.md:77-78` + donor `AGENTS.md` "Never crash" (rev2 A8, `DOC`-grade — junk-param sweep over every command as standing net); rev2 §4 test-surface finding (`a11y_tests`, `field_tests`, `layers_drag/keyboard/rename`, `panel_reorder/width`, `guide_release`, `live_*` — **naming mirrors mechanism**, making "is there a test for X?" answerable by filename).

**Upgrade:**
- Add a **junk-parameter / adversarial-input sweep** to every IDS verb suite and runtime contract fake suite (timeline verbs, command registry, numeric parse, availability transitions): every entry point run with bad input as a standing net, asserting fail-closed (unknown≠empty≠verified≠enabled) rather than crash-freedom alone.
- Adopt mechanism-mirrored test filenames as a Catalog/testkit convention.
- Note honestly: donor test *presence* ≠ *quality* (assertions and pass state unread — rev2 §4 caveat stands). We adopt the net shape and naming, not a quality claim.

**Why eighth:** pure process upgrade, near-zero cost, compounds every other U-item's conformance suite. Ranked last only because it hardens rather than enables.

**Risk:** negligible. **Blocking premise:** none.

## 3. What this wave deliberately does NOT upgrade (with reasons)

| Donor item | Disposition | Reason |
|---|---|---|
| A3 dialog-request boundary into `warp_prism_runtime` | **Architecturally excluded** (rev4 §5.3 stands) | `layer-contracts.md:18,92-94` forbids presentation policy in runtime contracts. Any analogue lives in presentation/bindings — and no consumer has asked for it. No replacement proposed. |
| B4 mixed-selection `common()` beyond its `IMPL` core | **Defer to consumer evidence** | `right.rs:18-23` only. No consumer inventory shows a mixed-property panel. Revisit if Warpblade/Tempest inspector work surfaces one. |
| B5 guides/smart-guides, B7 gap affordance, B8 asset tiles, B9 colour picker, B10 align/distribute | **Remain `UNVERIFIED`/excluded** (rev4 §4) | Earlier-pass reads only, not re-attested. Re-attest through workspace-local route or drop explicitly (rev4 locus #1). B9/B10 are covered-by-name in Prism anyway. |
| A9 lock-reentrancy hazard | **Carry as advisory** | `DOC`-grade (`a11y.rs:16-19`), bodies unread. Relevant only if Prism adopts egui-style locked-context node writers — record the hazard, do not design around an unread body. |
| Figma-shaped ontology, Rust/egui/wgpu coupling, Figma parity target, brand/glyphs | **Do-not-port** (rev2 §6 / rev4 §6 stand) | Domain, transport coupling, foreign promotion criterion, trademark + re-expression policy. Transfer mechanism, never code, never brand. |
| Any STABLE promotion | **Not assessed, out of scope** | Phase-1 terminal. §6 gates (fake, suite, boundary, host proof, FRB lifecycle where applicable, independent review) apply at build time per candidate. |

## 4. Backlog mapping (donor upgrades × consumer backlog)

| Upgrade | Feeds | Macro-review disposition honoured |
|---|---|---|
| U1 self-doc catalog | P1-1 command registry (C5) + C11 command face | Held "unified command catalog" → **inspiration for P1-1 only** becomes the P1-1 backbone. Consumer demand (Warpblade router, CC `_GatedAction`, Tempest declared palette) already exists — donor supplies the drift-proof shape. |
| U2 draw-derived focus | P1-7 shell slot router (C10) | Held "region-based keyboard / draw-derived focus" → **idea for P1-7** becomes the conformance core. Consumer hosts (CC, Tempest) already exist. |
| U3 numeric field | Preempts P0-3 formatter hosts + P1-6 meter/fader params | Held (no consumer) → **EXPERIMENTAL proof-lab**, promotion gated on Warpblade/Tempest adoption. Honest about current demand: zero. Honest about future demand: near-certain. |
| U4 commit boundary | P1-3 decision-review (C4) + P1-8 timeline verbs (C3/C5) | Strengthens two P1 suites with one invariant. Consumer demand already P1. |
| U5 insertion + test seams | C9 matrix composition (P2-1) + LaneBoard/VirtualGrid guidance | Held (reorder) → composition guidance + lab convention, not a new primitive. |
| U6 layer table | Boundary harness (§6 gate 4) | rev4 "compactness variant, not a gap" → economics proposal. |
| U7 two-tier capture/drain/cancel | §6 gates 2/5/6, host-exercise harness, FRB adapter reference | Harness-only. No contract change. |
| U8 junk sweep + naming | Quality gates for all of the above | Process-only. |

**Net effect on Held table:** 6 of 10 Held rows (command catalog, region keyboard, draw-derived focus, number field, reorder, toast-policy-adjacent capture discipline) are absorbed as **architecture/harness/EXPERIMENTAL upgrades**, not as stable widgets. The remaining 4 (rich filter builder, toolbar panel framework, sidebar section model, presence overlay, composer organism — Everything-side) stay Held: no consumer demand, no harness leverage, Prism already covers the adjacent surface (`DSFilterWorkbench`, `DSToolStripSlideout`, `DSToastManager`).

## 5. Sequencing (dependency order, not priority order)

```
U6 (harness economics — independent, do first; 1-session win)
 ↓
U8 (net shape — adopt alongside U6; governs all suites below)
 ↓
U1 (catalog self-doc — unlocks P1-1 design) ─┐
U2 (focus model — unlocks P1-7 design) ──────┤ parallelisable (different layers/files)
U4 (commit invariant — constrains P1-3/P1-8) ┘
 ↓
U3 (numeric EXPERIMENTAL — consumes U4 commit shape + U8 nets)
U5 (insertion guidance + seams — consumes U4)
 ↓
U7 (capture/drain harness — proves all of the above in host)
```

U1/U2/U4 are mutually parallelisable (runtime contract vs IDS shell vs IDS verbs — distinct seams, distinct files). U3/U5 depend on U4's invariant. U7 is last because it proves the wave, and host proof without built candidates is theatre (UNKNOWN-4 warning honoured).

## 6. Live-verification ledger (this session)

| Claim | Oracle | Result |
|---|---|---|
| Donor present workspace-local | `ls references/storytold-figcraft/{Cargo.toml, xtask/src/layers.rs, crates/ui-egui/src/{control,field_math}.rs}` | EXISTS (all four) |
| Layer table + direct-dep loop | `sed layers.rs:1-75` | CONFIRMED (TABLE, NETWORK, fail-closed, allowlist) |
| Dialog-drop + self-doc discovery split | `sed control.rs:205-230` | CONFIRMED (`engine.execute` retains-non-dialog; `engine.commands` returns params/menu/shortcut/undoable) |
| No command module in IDS | `ls warp_prism_interaction/lib/src/` | CONFIRMED (`input/inspection/query/selection/state_machine` only) |
| No numeric/ActionAvailability/CommandIntent/insertion/Drawn in Prism | grep over `packages/` | CONFIRMED (zero hits) |
| AsyncCommand has no params-doc/enumeration | `async_command_contract.dart:1-50` | CONFIRMED (single-flight cancel-and-replace + rationale, no discovery) |
| Consumer-side citations | macro-review INHERITED-REPORT | NOT re-read this session (recorded as report-grade per macro-review §1.2) |
| Donor bodies beyond cited ranges | — | NOT read (rev4 loci #1–#5 stand as exact follow-up reads) |

## 7. Exact follow-up reads (inherited from rev4 §8, still open)

1. B5/B7–B10 file set (`guides.rs`, `measure_overlay.rs`, `layout_panel.rs`, `assets_panel.rs`, `colorpicker.rs`, `right.rs:594-599`, `icons.rs`) — re-attest or drop explicitly.
2. `a11y.rs:136-1021` node writers + traversal resolution; `a11y_tests.rs` assertions — required before U2 detailed design.
3. `control.rs` `ui.render` arm + `docs/control-protocol.md` — required before U7 headless path.
4. `list_drag.rs:61-240` + reorder test definitions — required before U5 detailed spec.
5. `field_tests.rs:53-475` remainder (scrub distance, Shift/Alt, arrows, Tab/Escape, mixed, undo-per-scrub) — required before U3 suite port.

All five are ordinary workspace-local reads. None needs donor execution, build, network, or VCS.

## 8. Risks and non-goals restated

- **No stable widget is created by this document.** Every widget-bearing upgrade (U3) is EXPERIMENTAL proof-lab with promotion gated on consumer adoption + full §6 evidence.
- **No recurrence gate is reintroduced.** Recurrence ranks backlog priority (P0 first) but never blocks mandate-covered absorption.
- **No domain leakage.** Time/musical-grid/rational-AV/DSP/spectral/credential/lyric/generation ontologies stay product-local. Prism owns chrome, injected models, and interaction semantics.
- **No transitive-coverage claim.** Both layer checkers are direct-dep class; neither performs closure (rev4 F6).
- **No donor PASS.** Zero execution on either side; every "covers" claim is a static-read claim (macro-review UNKNOWN-5).
- **UNKNOWN-12 (IDS scope) is narrowed, not closed:** U1/U2/U4 give the architecture owner three bounded IDS proposals (availability/command eligibility, slot/focus tokens, commit boundary) to accept or reject — the question "can IDS absorb this without becoming state management" is now answerable per-item instead of in the abstract.

## 9. Packet (for the return message)

- **Scope:** MISSION §3.1 + catalog + macro-review (98 units, 11 clusters, P0–P2 backlog) + FigCraft rev4 (A1–A9, B1–B4/B6 usable) + live re-verification (donor 4 files EXISTS, Prism gaps CONFIRMED) → 8 ranked upgrades.
- **Thesis:** 6 of 10 Held donor items are architecture/harness/EXPERIMENTAL upgrades that need no consumer demand; 1 (B3) is an EXPERIMENTAL preempt with certain future demand; 3 Everything-side items stay Held.
- **Ranking:** U1 self-doc catalog (P1-1 backbone) → U2 draw-derived focus (P1-7 core) → U3 numeric EXPERIMENTAL → U4 commit invariant (P1-3/P1-8) → U5 insertion + test seams → U6 layer-table economics → U7 capture/drain harness (proves the wave) → U8 junk nets + naming.
- **Sequence:** U6+U8 first (independent) → U1/U2/U4 parallel → U3/U5 (consume U4) → U7 (proves all).
- **Honesty:** snapshot UNKNOWN, zero execution, consumer side report-grade, 5 exact follow-up reads named, no STABLE promotion assessed, A3 excluded by layer law, domain stays local.
