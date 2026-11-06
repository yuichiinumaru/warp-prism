# Figcraft Donor Inspiration Harvest — Phase 1

- **Date:** 2026-10-15 · **Revision 2** (supersedes the thin first pass of the same day)
- **Donor:** FigCraft, read only through the workspace-local symlink `references/storytold-figcraft/`
- **Status:** inspiration evidence, non-normative.

This file does not authorize implementation, does not establish recurrence, demand, compatibility
or production quality, and does not decide any seam disposition. Disposition belongs to the
architecture owner. Where this document says a Warp Prism surface "lacks" something, it means
**not found in the named inventory** — see §5 for why that is weak evidence.

## 1. Source state

### Revision — ESTABLISHED

| Field | Value | Source |
|---|---|---|
| Commit SHA | `7459cc7f866d457792773a9ec992c9f32d3258c3` | `.git/refs/heads/main` |
| Branch | `main` | `.git/HEAD` |
| Workspace version | `0.6.0` | `Cargo.toml:8` |
| Upstream | `https://github.com/storytold/figcraft` | `Cargo.toml:11` |
| Architecture doc last updated | 2026-10-11 | `docs/architecture.md:3` |
| Size | ~108,800 lines Rust | `docs/architecture.md:6` |
| Rust edition | 2024, MSRV 1.95 | `Cargo.toml:9-10` |

*Method note:* SHA and branch were obtained by reading `.git/HEAD` and `.git/refs/heads/main` as
plain files, not by invoking any VCS command. No VCS operation was performed.

*Correction:* the first pass of this report recorded revision as **UNKNOWN**. It is now resolved.

### License — VERIFIED

- `LICENSE-MIT` — MIT, © 2026 ArtCraft Team and the FigCraft contributors.
- `LICENSE-APACHE` — Apache License 2.0.
- `NOTICE` — dual licensed "at your option".
- `Cargo.toml:9` — `license = "MIT OR Apache-2.0"` (machine-readable confirmation).

**Carve-outs (hard do-not-port):**
- The ArtCraft name, wordmark and logos under `docs/brand/` are **trademarks, not open source**
  (`NOTICE`; donor `AGENTS.md` "Assets" section).
- All UI icons are original FigCraft artwork drawn in code (`NOTICE`, `crates/ui-egui/src/icons.rs`).
  The donor's own rule: never copy or "lookalike-redraw" third-party product iconography.
- Every asset must have an `ATTRIBUTION.md` row; `cargo xtask assets` fails the build otherwise.

Mechanisms are permissively licensed and safe to study and reimplement from scratch. Brand and
glyph artwork are not, at any score.

*Correction:* the first pass recorded "LICENSE does not exist / unverified". That was wrong.

### Coverage

**Read:** README, NOTICE, both licenses, `Cargo.toml`, donor `AGENTS.md`/`CLAUDE.md`, `docs/architecture.md`
(86 lines), `xtask/src/layers.rs` (head), `crates/engine/src/cmd/mod.rs` (head),
`crates/ui-egui/src/control.rs` (head), `crates/ui-egui/` file listing with test counts, and ~40
earlier-pass UI source files. Donor `references/AGENTS.md` and Warp Prism's
`docs/design/component-catalog.md` (102 lines, read in full) were also read.

**Not read:** the ~20 non-UI crates' internals, `docs/ui-parity.md`, `docs/control-protocol.md`,
`docs/mcp.md`, `docs/gaps.md` (62KB), `ROADMAP.md` (108KB), `ATTRIBUTION.md`, `docs/brand/`,
`crates/engine/src/tests.rs` body. Those are the next inputs if this harvest is deepened.

**Evidence strength varies by row and is marked.** Rows citing `docs/architecture.md` or a file head
are stronger than rows citing only a `//!` header.

## 2. Harvest — part A: architecture-level mechanisms

These are the highest-value findings and the first pass missed them entirely because it only read
source file headers. **None of these are widget-level**, so none can be assessed against Warp Prism's
component catalog. They must be assessed against Warp Prism's architecture law instead.

| # | Mechanism | Evidence | Strength |
|---|---|---|---|
| A1 | **Declarative layer table enforced in CI.** Crate→layer map plus rules: no UI crate (egui/eframe/rfd/winit) below L6, no networking crate below L6, no upward dependency. Runs in `cargo xtask ci`. | `xtask/src/layers.rs:7-24` (TABLE), `:27` (NETWORK), `:29-60` (check); `docs/architecture.md:11-13` | strong — executable rule source + CI gate |
| A2 | **Self-documenting command spec.** Each command is a 5-field record — `id`, `label`, `params` (a *documentation string for agents*), `history` (undoable bool), `run` — declared one line via a `spec!` macro. The same catalog is dispatched by menus, shortcuts, palette, CLI, control channel, MCP and WASM plugins. | `crates/engine/src/cmd/mod.rs:34-40` (struct), `:50-56` (macro), `docs/architecture.md:47-54` (455 ids, one path for every surface) | strong |
| A3 | **Programmatic calls never open dialogs.** Commands only *request* UI; the control channel drops dialog requests. | `docs/architecture.md:52-53`; donor `AGENTS.md` "Architecture"; `crates/ui-egui/src/control.rs:20` (`ui.menu.invoke` is the one path that *may* open a dialog) | strong — corroborated in two places |
| A4 | **Deterministic frame-boundary queue drain.** External requests are queued as `ControlRequest` and drained at the start of a frame so replies reflect real UI state; external input never races the UI thread. | `crates/ui-egui/src/control.rs:1-3`, `:36-46` | strong |
| A5 | **Cooperative cancellation of queued work.** `ControlRequest.is_cancelled()` — an `AtomicBool` checked before processing; the transport discards still-queued requests after its timeout. | `crates/ui-egui/src/control.rs:40-46` | strong |
| A6 | **Two-tier verification surfaces.** `ui.screenshot` (window PNG, needs a visible window) vs `ui.render` (document PNG, no UI chrome, works headless); plus `document.inspect{depth}` / `node.get` / `ui.inspect` for *structured* state, not only pixels. | `crates/ui-egui/src/control.rs:18-19`, `:11-13` | strong |
| A7 | **Cheap structural-sharing snapshots → unlimited undo, one step per gesture.** `Arc` + persistent maps make snapshots cheap enough to undo every gesture. | `docs/architecture.md:42-45` | strong — this is the *enabling mechanism* behind interaction law B1 |
| A8 | **Junk-parameter sweep over every command.** Every command is run with bad input as a standing regression net. | `docs/architecture.md:77-78`; donor `AGENTS.md` "Never crash" | strong |
| A9 | **Retained rendering with a differential correctness check.** Canvas keeps its last image and re-renders only the region a pan uncovers or an edit touches; a **seeded random walk** checks the retained canvas against full renders. | `docs/architecture.md:58-62` | strong |
| A10 | **Thin UI as a stated architecture rule.** "Panels read engine state and act through `app.run(id, params)` / `app.set_props(ids, props)`; colours come from `theme::Tokens`." | donor `AGENTS.md` "Architecture"; `docs/architecture.md:5` | strong |

**A2 is the most transferable idea in the whole donor.** The `params` doc field being *part of the
spec* rather than a separate manual means the machine-readable catalog and the agent-facing
discovery surface cannot drift apart. Any Warp Prism command/contract surface is a candidate host
for this shape.

**A1 is the second.** It is a declarative table plus ~30 lines of checks — cheap, and it catches
both upward dependencies and forbidden transitive dependencies (a UI crate below the UI layer).
That second class of check is the one that actually keeps a presentation layer swappable; a plain
"no imports from X" test does not catch it.

## 3. Harvest — part B: interaction / widget-level mechanisms

Carried forward from the first pass, now with corrected coverage context.

| # | Mechanism | Evidence | Interest |
|---|---|---|---|
| B1 | One undo step per user gesture, incl. live-preview scrubs committed as one step | `crates/ui-egui/src/right.rs:18-40`; `crates/ui-egui/src/list_drag.rs:1-7`; enabled by A7 | high |
| B2 | Accessibility as an explicit obligation for custom-painted controls (AccessKit) | `crates/ui-egui/src/a11y.rs:1-10`; `docs/architecture.md:30` | high |
| B3 | Numeric field as a reusable primitive: label-drag scrub + keyboard edits on the *value* + arithmetic/relative expressions | `crates/ui-egui/src/widgets.rs:1-2,40-46,215-217`; `crates/ui-egui/src/field_math.rs:1-3,5-23` | high |
| B4 | Mixed-selection "common property" panel operating on the shared subset | `crates/ui-egui/src/right.rs:18-40` | high |
| B5 | Persistent constraint (guides) vs transient feedback (smart guides + zoom-stable non-overlapping labels) | `crates/ui-egui/src/guides.rs:1-5`; `crates/ui-egui/src/measure_overlay.rs:1-3,15-17` | med-high |
| B6 | Reorder via grip/row drag with a visible insertion line | `crates/ui-egui/src/list_drag.rs:1-7` | med-high |
| B7 | Gap as a first-class layout affordance rather than a margin field | `crates/ui-egui/src/layout_panel.rs:347,356,431` | med |
| B8 | Searchable asset tiles; drag-to-place; virtualized list; cached thumbnails | `crates/ui-egui/src/assets_panel.rs:1-12` | med |
| B9 | Colour picker with an explicit target-state model | `crates/ui-egui/src/colorpicker.rs:1-3,18-49` | med |
| B10 | Align (6) + distribute/tidy, icon-only with tooltips | `crates/ui-egui/src/right.rs:594-599,612`; glyphs `crates/ui-egui/src/icons.rs:74-81,640-680` | low — standard editor furniture |

**Interaction states (hover/active/focus/disabled) remain UNKNOWN for every B row.** The first pass
flagged this; the second pass did not fix it. It needs body-level reads of the widget functions.

## 4. Test-surface finding (corrects the first pass)

The first pass said "correctness and test coverage UNKNOWN". Partly corrected.

`crates/ui-egui/src/` carries **dedicated behaviour-test files whose names mirror the mechanisms**:
`a11y_tests.rs` (15 `#[test]`), `field_tests.rs` (9), `comments_tests.rs` (8), `cursors_tests.rs` (6),
`credits_tests.rs` (6), `canvas_drag_tests.rs` (3), `canvas_fixes_tests.rs` (3),
`dev_mode_tests.rs` (3), `export_preview_tests.rs` (3), `colorpicker_selection_tests.rs` (2),
`frame_label_tests.rs` (2), `gap_handle_tests.rs` (2), plus `layers_drag_tests.rs`,
`layers_keyboard_tests.rs`, `layers_rename_tests.rs`, `panel_reorder_tests.rs`,
`panel_width_tests.rs`, `guide_release_tests.rs`, `live_*_tests.rs` and others.

Two observations:

1. **B2, B3, B5, B6 each have a directly corresponding test file** (`a11y_tests`, `field_tests`,
   `guide_release_tests`, `panel_reorder_tests`, `layers_drag_tests`). That is real evidence these
   are treated as behaviours with contracts, not incidental paint.
2. **The naming convention makes coverage discoverable by mechanism name** — you can ask "is there a
   test for X?" by looking for `x_tests.rs`. That is a cheap, transferable harness practice.

What is still unknown: whether the tests pass, what they assert, and coverage depth. Test *presence*
is not test *quality*. `crates/engine/src/tests.rs` (33KB) was not read.

## 5. Coverage check against Warp Prism — and why it is weaker than it looks

`docs/design/component-catalog.md` was read in full (102 lines) and *is* usable for a first pass,
correcting the first report's claim that it was unreadable/truncated. It is simply short.

**The critical caveat:** that catalog scopes itself to "Reusable Flutter UI widgets owned by the ADS
package" (line 4). Part A of this harvest is **architecture-level** — a layer table, a command
registry, an undo model, a control channel. **None of that would appear in a widget inventory, and
its absence there is not a gap.** Comparing part A against the catalog is an apples-to-oranges
comparison and this report does not do it.

Warp Prism also already owns runtime contracts (`AsyncCommand`, `EventStream`, `HealthSource`,
`GraphSource` per `AGENTS.md` §1) which live *outside* the widget catalog. So several apparent gaps
below are likely scope artefacts.

Part B against the catalog, at name level only:

| Mechanism | Warp Prism name found | Reading |
|---|---|---|
| B2 accessibility-as-contract | gallery has an "accessibility/focus" section; 1 "accessib" hit, 0 "a11y", 0 "semantic" | **not named as a component.** Catalog line 92 says a gallery section "is not automatically a separately owned component". Needs source check before any gap claim. |
| B3 numeric field primitive | `PrismTextField`, `PrismColorField`, `PrismSelect` exist | **not named.** No numeric/scrub/arith field appears. Strongest genuine candidate — but still "not in a 102-line inventory", not proven absent. |
| B1 undo contract | **zero** "undo" hits in the catalog | Expected: undo is app/runtime-level, likely out of catalog scope. Checked against runtime contracts, not here. |
| B6 reorder + insertion | `PrismDraggableCard`, `PrismDropTarget` exist; 0 "reorder" | Adjacent primitives exist; reorder-with-insertion-indicator not named. Candidate. |
| B8 virtualization | `PrismVirtualList`, `PrismVirtualGrid` | **Covered by name.** Donor adds caching + thumbnail specifics, not the pattern. |
| drag/drop | `PrismDraggableCard`, `PrismDropTarget` | **Covered by name.** |
| B9 colour | `PrismColorField` | **Covered by name.** |
| keyboard contract | `PrismKeyboardCheatsheet` only; 1 "keyboard" hit | Cheatsheet is *documentation*, not an interaction contract. Candidate. |

**Net:** two candidates worth a source-level check (B3 numeric field, B2 a11y-as-contract), two
weak candidates (B6, keyboard), the rest covered or out of scope. And critically, **part A is
entirely unassessed** because the wrong instrument was used.

## 6. Donor accidents and do-not-port

- **Never port the brand or the icon glyphs.** Trademarked (`NOTICE`), and the donor's own rule bans
  third-party iconography including "lookalike" redraws. Study the *pattern* of a compact
  icon+tooltip control strip; do not copy a single shape.
- **Do not port the property/ontology model.** Auto layout modes, constraints, components/variants,
  prototypes, vector editing, variables, comments are Figma-shaped domain. Warp Prism runtime
  contracts stay backend-agnostic; adapters do the projection.
- **Do not port Rust/egui/wgpu coupling upward.** The donor is a Rust/egui desktop+wasm app; Warp
  Prism is a Flutter-side substrate. Transfer the mechanism, never the code. The donor reinforces
  this itself: sibling repos "never code — repos don't share code" (donor `AGENTS.md`).
- **Do not treat Figma parity as a target.** The donor's roadmap is graded against Figma parity
  (`docs/architecture.md`, `docs/parity-checklist.md`). That is correct *for the donor* and is
  explicitly not Warp Prism's promotion criterion.
- **Not product surface:** `dev_mode.rs`, `dev_compare.rs`, `home.rs`, `credits.rs` — donor-internal
  or own-product features. Observed in passing, no analysis, no harvest value.

## 7. Unknowns (still open)

- **Interaction states for every B row** — hover/active/focus/disabled/edge cases. Needs body reads.
- **Test quality** — presence observed, assertions and passing status unknown.
- **Control protocol depth** — `docs/control-protocol.md` (22KB) unread; A4/A5/A6 rest on
  `control.rs`'s doc header.
- **Engine internals** — the command *implementation* layer was never read; A2 is about the spec
  shape, not command behaviour.
- **Consumer recurrence — NOT ATTEMPTED.** Nothing here shows Warblade, Tempest, Hyperion or Sentry
  need any of A1-A10 or B1-B10. The two consumer inventories in `.project/research/` are the next
  input.
- **Runtime-contract overlap** — whether Warp Prism's `AsyncCommand` already embodies A2/A3 is
  unchecked, and that check would invalidate several "candidate" readings above.

## 8. Recommended next tasks

Not authorized by this report; listed for the architecture owner.

1. **Read `docs/control-protocol.md`** and `crates/ui-egui/src/control.rs` in full. A4/A5/A6 are the
   strongest runtime-contract items and rest on a doc header today.
2. **Check A2/A3 against Warp Prism's existing runtime contracts.** If `AsyncCommand` already carries
   a self-documenting spec and a dialog-request boundary, A2/A3 are corroboration, not new work.
3. **Assess A1 against `boundary_test.dart` and the layer law.** The question is specifically
   whether Warp Prism checks *forbidden transitive* deps (presentation imported below the
   presentation layer), which a naive import test misses.
4. **Source-level check on B2 and B3 only** before any gap claim. Do not promote from a
   102-line inventory.
5. **Then** run consumer recurrence against the two existing inventories. Only then classify seams.

**Do not** deepen donor reading before steps 2-4 — more donor source will not answer any of these,
and the first pass already showed the marginal value of additional `//!` headers is near zero.
