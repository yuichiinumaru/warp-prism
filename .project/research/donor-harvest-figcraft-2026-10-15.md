# FigCraft Donor Inspiration Harvest — Phase 1

- **Host:** Warp Prism · **Donor:** FigCraft via `references/storytold-figcraft/`
- **Revision 4** — corrective continuation of Revision 3, same session. Closed four of the five
  loci Revision 3 listed as unresolved.
- **Terminal phase:** Phase 1 research only (`wp-component-absorption.md` phase 1).
- **Non-normative.** Inspiration evidence. No adoption, disposal, Task creation, implementation or
  promotion is proposed or authorized here.

Evidence labels: `IMPL` = implementation body read · `TEST-DEF` = test definition read ·
`DOC` = donor documentation only · `UNVERIFIED` = claimed but not re-attested.

---

## 0. Correction log (F1–F9, from Revision 3 — preserved)

| ID | Classification | Disposition | Status now |
|---|---|---|---|
| F1 | **CURRENT_REAL** | Revision 2's "workspace-local only" provenance claim was false. History corrected; earlier-pass reads marked `UNVERIFIED` | stands |
| F2 | **CURRENT_REAL** | Revision pin withdrawn as inadmissible; not re-read. Snapshot identity `UNKNOWN` | stands |
| F3 | **CURRENT_REAL** | Working copy + shell `cp` + scratch file disclosed, left in place, not repeated | stands |
| F4 | **CURRENT_REAL** | Mechanisms relabelled `IMPL`/`TEST-DEF`/`DOC`; donor figures attributed; coverage counts removed; universal race claim withdrawn | stands |
| F5 | **CURRENT_REAL** | `engine.execute` vs `ui.menu.invoke` split; stale citations corrected | **now fully closed** — both bodies read, see A3 |
| F6 | **FALSE_POSITIVE** | Transitive-dependency claim withdrawn; checker is direct-deps only | stands |
| F7 | **PARTIAL_TRUE** | Licence noted once; trademark fact separated from our re-expression choice | stands |
| F8 | **CURRENT_REAL** | Four selected mechanisms deepened; other rows downgraded | **now closed for B1/B3; B2/B6 body-deep, tests partial** |
| F9 | **CURRENT_REAL** | Widget inventory was the wrong instrument; B2 gap withdrawn as already-covered | **now closed** — correct instrument applied, see §5 |

---

## 1. Provenance history (F1, F3)

Revision 2's line-4 claim — "read only through the workspace-local symlink" — was **false**. An earlier
pass read donor files through resolved absolute external paths. Later reads were compliant; that does
not retroactively make them so.

**Re-attested through `references/storytold-figcraft/...`:** `Cargo.toml`; `xtask/src/layers.rs`
(complete); `control.rs` lines 1–24, 60–159, 205–236, 378–417; `field_math.rs` 1–70; `field_tests.rs`
1–52; `right.rs` 14–57; `a11y.rs` 1–135; `list_drag.rs` 1–60; `widgets.rs` 20–135;
`windows_qa_tests.rs` 60–83. Warp Prism local: `packages/warp_prism_ui/lib/**`,
`packages/warp_prism_runtime/lib/src/async_command/async_command_contract.dart`,
`.project/architecture/layer-contracts.md`.

**Still `UNVERIFIED`, excluded from usable findings:** B5 (guides / smart guides), B7 (gap affordance),
B8 (asset tiles), B9 (colour picker), B10 (align/distribute); `docs/architecture.md`;
`crates/engine/src/cmd/*`.

**File effects (F3).** Disclosed and left in place: `.project/research/figcraft-harvest.md` (working
copy), `.project/research/test-write.md`. Created in earlier passes, outside the single-file write
constraint. Not cleaned up. Ownership of other files in that directory is not proven and no claim is
made. **No new scratch files in this continuation; only the sole canonical report was written.**

---

## 2. Source state

### 2.1 Snapshot identity — UNKNOWN (F2)

The Revision 2 pin (from `.git/HEAD` / `.git/refs/heads/main`) is **withdrawn as inadmissible** —
outside the authorized no-VCS scope. Those files were not re-read or re-validated here or since. The
approved snapshot identity of this donor remains **`UNKNOWN`**. No SHA, branch or cleanliness
assertion is carried. A ref value would not establish worktree identity in any case.

### 2.2 Declared version — corrected offsets (F2)

`references/storytold-figcraft/Cargo.toml`, re-read: `version` `:9` = `0.6.0`; `edition` `:10` =
`2024`; `license` `:11` = `MIT OR Apache-2.0`; `rust-version` `:12` = `1.95`; `repository` `:13` =
`https://github.com/storytold/figcraft`. Revision 2's `:8` / `:9-10` citations were wrong. This is a
*declared package version*, not a snapshot identity.

### 2.3 Licence — noted once (F7)

**Declared: MIT or Apache-2.0, at the user's option** (`Cargo.toml:11`, donor `NOTICE`). That is the
whole finding. Not hunted, not a gate, no legal immunity claimed, per
`.opencode/skills/knowledge/SKILL.md` §"Donor inspiration and reuse".

Two facts previously conflated, now separated:

1. *Trademark fact* — the donor's `NOTICE` states the ArtCraft name, wordmark and logos under
   `docs/brand/` are trademarks, not open source. That concerns those specific marks.
2. *Our own choice* — we will not copy donor brand or icon glyphs. This is a re-expression policy,
   **not** a legal conclusion that the code-drawn glyphs are excluded from the software licence.
   `NOTICE` calls them original FigCraft work; it does not itself establish exclusion.

### 2.4 Coverage this pass

**Inspected (workspace-local):** as listed in §1.
**Uninspected:** all non-UI crates; `control.rs` lines 160–204 and 237–377, 418–725 (incl. the
`ui.render` arm); `a11y.rs` 136–1021 (node writers, traversal resolution); `list_drag.rs` 61–240;
`field_math.rs` 71–163; `field_tests.rs` 53–475; `a11y_tests.rs`; `right.rs` 58+; `docs/control-protocol.md`;
`crates/engine/src/cmd/*`; the B5/B7–B10 file set.

**Validation performed:** source reading only. **Validation NOT run:** no donor build, test run, CI
execution or runtime observation; no network, no VCS. Donor execution is not authorized, so **no PASS
is claimed for any donor behaviour**, and no donor CI gate is described as observed.

---

## 3. Architecture-level mechanisms

Not widget-level. **Adjacent leads only** (F9) — never candidate components.

| # | Mechanism | Evidence | Label | What the evidence proves |
|---|---|---|---|---|
| A1 | Declarative crate→layer table; three direct-dep rules (no UI crate below L6, no networking crate below L6, no same-or-higher layer dep except a 3-entry allowlist) | `layers.rs:8-26`, `:29`, `:31-69`, `:71-75` | `IMPL` | Enumerates every workspace package and inspects its **direct** `dependencies` from `cargo metadata --no-deps`. Fails closed if cargo or JSON parsing fails (`:36-37`). **No transitive closure** |
| A2 | Command's agent-facing parameter documentation ships in the discovery response | `control.rs:221-226` | `IMPL` | `engine.commands` serialises `{id, label, params, menu, shortcut, undoable}` per command — the doc string is a response field, so it cannot drift from the catalog |
| A3 | Dialog-request boundary differs per programmatic route | `control.rs:212-220` vs `:381-385` | `IMPL` | **`engine.execute`**: runs the command, then `ui_requests.retain(|u| !u.kind.starts_with("dialog."))`, then `handle_ui_requests()` — pending dialog requests are *dropped*. **`ui.menu.invoke`**: delegates to `crate::menus::invoke(app, id)` with **no** dialog-drop and returns `app.ui.last_error` in the reply. Both are programmatic; the "never open dialogs" property holds for `engine.execute` only |
| A4 | Queued requests drained at a frame boundary, with window routing | `control.rs:73-122` | `IMPL` | Queue is `mem::take`n (`:96`); per-request target-window routing requeues and `request_repaint_of` when the window isn't current (`:102-111`); unknown window replies `Err("no window {target}")` (`:108`) |
| A5 | Cooperative cancellation | `control.rs:50`, `:98`, `:156` | `IMPL` | `is_cancelled()` reads an `AtomicBool`, checked at the top of both `drain` (`:98`) and `drain_hidden` (`:156`) before processing |
| A6 | Two-tier capture with a bounded wait | `control.rs:19-20` (doc), `:67`, `:86-95`, `:112-118`, `:126-136` | `IMPL` + `DOC` | `ui.screenshot` special-cased: queued as `PendingShot`, answered later from an egui screenshot event, errors after `SHOT_TIMEOUT = 60.0` with "the window didn't deliver a screenshot (is it visible?)". `ui.render` documented at `:20`, listed in `NO_FRAME` at `:140`; **its body unread** |
| A7 | Region-based keyboard model as explicit state | `a11y.rs:29-58`, `:64-83`, `:86-99`, `:101-108`, `:110-135` | `IMPL` | `Region` = Toolbar/Layers/Canvas/Properties, `Canvas` default, ordered `ALL`, stable ids, case-insensitive `parse`; per-region parallel arrays via `of`/`of_mut`; `Move::{Step,To}`; `Nav::step` coalesces repeated presses with `saturating_add` into a `pending` move (`:131-135`) |
| A8 | Keyboard/a11y target derived from the **previous frame's draw**, not separate registration | `a11y.rs:86-99` | `IMPL` | `struct Drawn` — "What a frame drew that the next frame's keyboard navigation needs": `rects: [Option<Rect>;4]`, `preferred: [Option<Id>;4]` (the control F6 lands on per region), `canvas`, `popup: Option<(Id,Id)>` (opener + area), `row_focused`. `Nav` holds `last`/`next: Drawn` double-buffering, plus `refocus: u8` for rows laid out a frame late and `scroll_to: Option<Id>` so the properties panel can reveal the target |
| A9 | Documented lock-reentrancy hazard in accessibility node writers | `a11y.rs:16-19` | `DOC` | States egui runs node writers with its context locked; a nested context call deadlocks, debug builds panic after 10 s; read state first; `a11y_tests` runs every path with the tree on. Node-writer bodies unread |

**Withdrawn from Revision 2 (F4, F6):**

- *Transitive dependency validation.* Withdrawn. `cargo metadata --no-deps` returns workspace members
  with direct dependencies; the loop at `:43-63` reads `pkg["dependencies"]` and never builds a closure.
  Indirect-violation coverage relies only on every workspace member being enumerated — a weaker
  property, and blind to a violation introduced purely through an external non-workspace crate. I did
  not execute the checker or observe CI; "enforced in CI" is `DOC`.
- *Donor-reported figures.* "455 ids after #101" and "~108,800 lines" are the donor's own claims from
  `docs/architecture.md` (dated 2026-10-10/11), not my census, not restated as fact.
- *Coverage counts.* Removed.
- *"External input never races the UI thread."* Withdrawn as universal. `IMPL` supports that requests
  are queued and processed in `drain`/`drain_hidden`; no full concurrency argument was established.

**Most transferable idea.** A2 — the machine-readable catalog and the agent-facing discovery surface
are one object, so they cannot drift.

---

## 4. Interaction mechanisms

### B3 — Number field as a reusable primitive · `IMPL` + `TEST-DEF`

**Value model** (`field_math.rs`): `Typed` = `Value(f64)` | `Rel(Rel)` (`:29-32`); `Rel` =
`Add|Mul|Div` (`:8-12`); `apply()` returns `None` on division by zero (`:21`) and rejects non-finite
results (`:23`); bounds `MAX_LEN = 256` (`:35`), `MAX_DEPTH = 32` (`:37`); `percent_unit` makes `%` a
unit on a percentage field and a relative edit otherwise (`:39-43`).

**Gesture and commit state machine** (`widgets.rs:20-133`) — the substantive part:

- `Lead` (`:20-25`) doubles as the accessible name; `Lead::Named` is "no lead, only a name for screen
  readers". `name()` expands `"W"`→`Width`, `"H"`→`Height` (`:29-37`).
- `FieldEdit` (`:41-46`) makes the commit boundary explicit in the type: `Set(f64)` = committed
  (Enter, Tab, focus loss, or an arrow-key step); `Scrub(f64, bool)` = live scrub, `.1` true when the
  drag ended.
- `Edit` (`:51-54`) = `All(FieldEdit)` | `Each(Rel)` for a mixed-value field.
- `Edit::settled()` (`:59-65`): with no per-layer value to work from, `+10` becomes `Set(10)` "as typed
  into an empty field"; **every other relative edit yields `None`** — a real edge rule.
- `key_steps` (`:77-84`): arrow-key steps come from nudge preferences for pixel fields only, else the
  field's own step and 10×; nudge values are `.filter()`ed for finite and > 0 (`:79`).
- `scrub_amount` (`:88-95`): `dx × step × rate`, where Shift = 10×, Alt = 0.1×, and **Shift+Alt falls
  through to 1×** rather than composing.
- `scrubbed` (`:99-101`): quantum-snapped — `stepped(from, (amount/quantum).round(), quantum)`; a
  non-positive or non-finite quantum returns `from` unchanged.
- `scrub(...)` (`:105-133`): `let v = value?` — a `None` value cannot be scrubbed (`:106`). Start
  position and accumulated amount live in temp UI state keyed `id.with("scrub")` (`:112`).
  Modifier rates may change mid-gesture — "each stretch counts at its own rate" (`:107-108`).
  **Screen-edge continuation** (`:117-121`): when the pointer stalls within 1px of a content edge, the
  platform-reported raw motion continues the scrub; elsewhere it stops. **Release frame moves nothing**
  (`:124-128`): accumulation is guarded by `response.dragged()`, so the `drag_stopped()` frame does not
  add motion and the value settles where the last live frame left it.

**States and edges established:** no-value → no gesture; empty-field relative edit → `None`;
division by zero / non-finite → no value; quantum guard; Shift+Alt not composing; screen-edge
continuation; release-frame no-op; live-vs-committed distinction in the type.

**Test definitions:**
- `field_tests.rs:18-52` (table-driven): whitespace, comma decimals, `.5`, spaced unary minus;
  precedence (`2+3*4`→14 vs `2*3+4`→10), nested parens, `2*-3`→-6, `10--2`→12; units `px`/`°`/`x`/
  `ms` incl. `10px + 2px`→12; relatives `+10`, `*2`, `/4`, `*(1+1)`, `50%`→`Mul(0.5)`, `+10%`→
  `Mul(1.1)`, `-10%`→`Mul(0.9)`; and `("50%", true, Value(50.0))` — same text, absolute value inside a
  percentage field.
- `windows_qa_tests.rs:63-78` `a_scrubbed_field_keeps_its_value_when_the_pointer_lets_go`: reaches the
  field by accessible name `Width` via `tab_to`, presses 8px left of the field's min-x (the label
  strip), moves 40 points, asserts width becomes `80.0` mid-drag, releases, asserts `80.0` is **kept**
  after release, and asserts the sibling `height` stayed `30.0`. That test pins the live-preview →
  commit contract and the no-collateral-mutation property in one place.

### B1 — Gesture commit / one undo step per gesture · `IMPL` + `TEST-DEF`

- `right.rs:26-32` `set_props` — "one undo step"; empty `ids` returns early.
- `right.rs:34-40` `field` — "scrubs are live previews committed as one step"; empty `ids` returns.
- `right.rs:42-57` `field_of` — a relative edit on a mixed field edits each layer **from its own
  value** in one undo step; routing `Edit::Each` per-layer, `Edit::All` delegates to `field`,
  `None` returns (`:45-49`).
- Edges: values collected with `?`, so a layer whose `rel.apply` yields `None` is dropped (`:51`); the
  gesture aborts only if **all** layers fail (`values.is_empty()`) or `begin_interaction("Edit")` errors
  (`:52-54`); a failing per-layer `node.set` routes to `self.failed(...)` (`:56-57`).
  **Partial failure therefore yields partial application** — observed behaviour, not a claim it is
  handled correctly.
- Commit boundary carried by `FieldEdit` above (`widgets.rs:41-46`), and pinned by
  `windows_qa_tests.rs:63-78`.

### B2 — Accessibility/focus as a first-class model · `IMPL` + `DOC`

Region model and draw-derived navigation are `IMPL` (A7, A8). The keyboard contract in
`a11y.rs:4-10` — F6/Shift+F6 region traversal, Tab/Shift+Tab within a region with wrapping,
Enter/Space activate, arrows along toolbar and layer rows, focus hand-off into an opened menu/flyout
returned on close, Escape to canvas, focus ring persisting until the next pointer press — is `DOC`;
the resolution bodies (`a11y.rs:136-1021`) were not read. `a11y.rs:16-19` (A9) is `DOC`.

`a11y_tests.rs` exists and its name mirrors the mechanism; contents unread, so no claim about what it
asserts or whether it passes.

### B6 — Reorder with insertion affordance · `DOC` + `IMPL`

`list_drag.rs:1-7`: row dragged by its grip strip (page by whole row); an insertion line shows where it
lands and its label follows the pointer; dropping moves it with **one command (one undo step)**. Also a
view/model ordering split — the Design panel shows topmost first while the model keeps lists
bottom-first (`:5-7`). `ListDrag` holds `reversed`, `dragging: Option<usize>`, laid-out
`rows: Vec<(usize, Rect)>`, carried `label` (`:37-48`), with `new()`/`in_order()` (`:52-58`). A
`#[cfg(test)] grip_id` exists specifically so tests can locate rows (`:26-29`) — a deliberate test
seam. The insertion-line primitive itself lives in the shared widget layer
(`widgets.rs:845 pub fn insertion_line(...)`).

**Unverified:** drag/commit implementation beyond line 60, and reorder test assertions.

### Rows still `UNVERIFIED`

B4 is now **partly** re-attested — `right.rs:18-23` `common()` is `IMPL` (returns `Some` only when all
selected nodes match on `f`; `None` when mixed or empty). B5, B7, B8, B9, B10 remain `UNVERIFIED` —
earlier-pass reads only, not repeated here. **The harvest's usable finding set is therefore B1, B2,
B3, B6 (deep) and B4 (partial).** B5/B7–B10 are excluded pending re-attestation.

---

## 5. Local fit against Warp Prism (F9)

Revision 3 left the A-row fit unresolved because it had used a widget inventory. The correct
instruments are `.project/architecture/layer-contracts.md` and the runtime contracts. Both are now read.

### 5.1 A1 (layer enforcement) — **already present locally; the donor offers a compactness variant**

`layer-contracts.md:6` names the enforcement file
`packages/warp_prism_ui/test/boundaries/boundary_test.dart`; `:192-218` states it registers **16**
mechanically enforced checks, reconciled 2026-10-11, with "every row below is mechanically enforced —
no row is documentation-only". `:231-234` adds four per-package purity tests (`runtime/test/purity_test.dart`,
`interaction/test/purity_test.dart`, `bindings/test/boundary_isolation_test.dart`,
`ui/test/boundaries/public_barrel_no_ds_export_test.dart`). `:86` states the principle: "Layer purity
is proven by the boundary harness, not asserted in prose."

The relevant checks are the same *class* as the donor's: #4 `ui` imports no app packages, #10 `runtime`
imports no Flutter, #11 `interaction` pure Dart, #12 `ui` imports no bindings, #13 no adapter/FRB import
in `ui`/`interaction`/`runtime`, #15 no direct `frb_generated`/`src/rust` imports outside the adapter.

**Fit finding:** the capability exists. The donor's variation is *representational* — a declarative
crate→layer number table with a generic upward-dependency rule, instead of sixteen hand-written
per-package assertions. Whether collapsing the sixteen into a table is worthwhile is an architecture
owner's call about maintenance economics, **not** a missing capability and **not** a component. Note
also that both mechanisms are the same evidence class: direct-dependency checks. Neither performs
transitive closure.

Worth recording: `layer-contracts.md:220-234` carries a drift note — an enforcement-status column was
dropped in a rewrite, judged semantically load-bearing, and recovered on 2026-10-11. The donor's
`layers.rs` makes the same class of drift structurally harder by deriving status from a table.

### 5.2 A2 (self-documenting command catalog) — **no local equivalent; precise, narrow lead**

`packages/warp_prism_runtime/lib/src/async_command/async_command_contract.dart:57` defines
`AsyncCommand<TParam, TResult>` with `status`, `execute(param, {cancellationToken})`, `watchStatus()`,
`isClosed`, `close()` (`:57-78`).

What is already present: substantial *design rationale in the contract's own doc comment* (`:30-56`) —
authoritative-execution semantics, cancel-and-replace, explicit "Why not reject?" and "Why not
multi-flight?" sections, a PURGE LAW forbidding re-invocation loops and progress-UI logic, and
`@experimental` lifecycle. So documentation living beside the contract is already the local habit.

What is absent: a **machine-readable parameter-documentation field**, and any enumeration or discovery
surface in the interface. `TParam` carries no documentation, and nothing in the contract lists commands
with their parameters the way `engine.commands` returns `{id,label,params,menu,shortcut,undoable}`.

**Fit finding:** a narrow architectural lead about how Warp Prism runtime contracts expose
self-description to agents and tools — not a widget, not a component, not a confirmed gap, and not a
proposed API. Layer-contracts `:185` places `AsyncCommand` at most at `EXPERIMENTAL`, so this is
early enough to consider without pressure.

### 5.3 A3 (dialog-request boundary) — **no local home by design; architecturally excluded**

`AsyncCommand` has no dialog or UI-request concept, and must not have one:
`layer-contracts.md:18` requires `warp_prism_runtime` to carry "semantics only" and **MUST NOT**
"contain presentation policy"; `:92-94` forbids Flutter presentation concepts in a runtime contract.
The donor's dialog-drop is a **UI-crate** concern (it filters `app.session.ui_requests`).

**Fit finding:** transplanting A3 into `warp_prism_runtime` would violate the layer law. Any local
analogue would have to live in a presentation/bindings layer. Recorded as architecturally excluded
rather than unresolved — and no replacement is proposed.

### 5.4 B2 (accessibility as a contract) — **already covered locally; gap withdrawn**

Rev 3 established this and it holds after further reading. `PrismSemantics` alias
(`prism_aliases.dart:254-257`); `Semantics`/`ExcludeSemantics` applied inside components across
`ds_text_field.dart:221-283`, `ds_select.dart:218-596`, `ds_color_field.dart:336-339`,
`ds_toast.dart:63-229`, `ds_accordion.dart:265-309`, `ds_state_surface.dart:170-330`,
`ds_scale_measure_bar.dart:122-158`, `ds_draggable_card.dart:207-209`, `theme_editor/…:442-530`;
`semanticsLabel` hooks (`ds_text_field.dart:34`, `ds_select.dart:85`, `ds_color_field.dart:58`);
decorative loading excluded (`ds_shimmer.dart:112-113`); gallery section `accessibility-focus`
(`design_system_gallery_registry.dart:198-200`). `layer-contracts.md:17` additionally makes
`warp_prism_interaction` **"a11y-first"** in the normative matrix. **Not a gap.**

The donor pattern with no local equivalent either way is **A8** — deriving the focus/keyboard target
from the previous frame's draw (`Drawn` struct) instead of a parallel registration. Not assessed here;
architecture-adjacent.

### 5.5 B3 (numeric field) — **name-level lead, NOT a confirmed gap**

`packages/warp_prism_ui/lib/src/atoms/` and `.../molecules/` were enumerated: no numeric input field.
`ds_metric_tile.dart` is a read-only numeric display; `ds_text_field.dart` / `ds_color_field.dart` are
text and colour entry. `organisms/` and `templates/` were not enumerated, so absence is not established.
Per `layer-contracts.md:185`, promotion to `PROVEN` would need ≥2 consumers or ≥2 domains plus fake
and suite — but that gate governs **stable promotion**, not idea collection, and no recurrence check
was attempted here.

### 5.6 Recurrence

Not attempted. Nothing here shows Warblade, Tempest, Hyperion or Sentry need anything harvested. No
consumer demand is claimed. `layer-contracts.md:134-141` (Explicit Bypass Rule) notes a bypassed
capability is itself a legitimate harvest candidate later, which is the mechanism by which such
evidence would eventually enter — not something this report invokes.

---

## 6. Donor accidents — not transferable

Fit guidance, not licence conclusions (F7).

- **Figma-shaped ontology** — auto-layout modes, constraints, components/variants, prototypes, vector
  editing, variables — is donor domain. Runtime contracts stay backend-agnostic; adapters project.
  Carried from the donor's own framing, not re-verified this pass.
- **Rust/egui/wgpu coupling.** Transfer the mechanism, never the code.
- **Figma parity as a target.** The donor grades itself against Figma parity; that is its criterion,
  explicitly not Warp Prism's (`layer-contracts.md:178-186`).
- **Brand and icon glyphs.** We choose not to copy them (§2.3).

---

## 7. Separate outcomes

| Outcome | State |
|---|---|
| **Source harvest** | **PARTIAL.** B1, B3 deep (`IMPL` + `TEST-DEF`); B2, B6 body-deep with tests partial; B4 partial. A1–A8 `IMPL`, A9 `DOC`. **B5, B7–B10 `UNVERIFIED` and excluded** |
| **Local fit** | **Resolved for the mechanisms assessed.** A1 already present (compactness variant only); A2 narrow lead; A3 architecturally excluded; B2 already covered; B3 name-level lead. §5 |
| **Retention / disposal** | **NOT REQUESTED.** No retention assessment performed; no disposal conclusion exists |
| **Validation not run** | No donor build, test run, CI execution or runtime observation. **No PASS claimed for any donor behaviour** |
| **Implementation** | Not performed, not authorized |
| **Stable promotion** | Not assessed; out of Phase 1 scope |

**Overall: PARTIAL.** The A-row local-fit question that Revision 3 left open is now answered, and four
of the five open loci are closed. What remains is the excluded B5/B7–B10 set and the deeper a11y
node-writer layer.

---

## 8. Remaining unresolved loci (exact)

1. **B5, B7, B8, B9, B10** — `guides.rs`, `measure_overlay.rs`, `layout_panel.rs`, `assets_panel.rs`,
   `colorpicker.rs`, `right.rs:594-599`, `icons.rs:74-81,640-680`. Re-attest through the
   workspace-local route or drop explicitly. Currently excluded from usable findings.
2. **A9 / A8 depth** — `a11y.rs:136-1021`: node writers and traversal resolution; `a11y_tests.rs`
   assertions.
3. **A6 remainder** — `control.rs` `ui.render` arm; whether a headless render path exists independent
   of the window.
4. **B6 remainder** — `list_drag.rs:61-240` and any reorder test definitions.
5. **B3 remainder** — `field_tests.rs:53-475` (the file's own doc declares scope over scrub distance,
   Shift/Alt, arrows, Tab/Escape, Mixed fields and undo-per-scrub; only 1–52 verified).

All five are ordinary workspace-local reads. None needs donor execution, build, network or VCS.

---

## 9. Sources reread

**Methods:** `.opencode/workflows/wp-component-absorption.md` ·
`.opencode/skills/knowledge/SKILL.md` (§"Donor inspiration and reuse", 244–250) ·
`.opencode/skills/knowledge/workflows/sw-knowledge-donor-harvest-lifecycle.md` ·
`.opencode/skills/code-quality/sub-skills/review-reconciliation/SUBSKILL.md`.

**Donor (workspace-local):** `Cargo.toml`; `xtask/src/layers.rs`; `crates/ui-egui/src/{control.rs,
field_math.rs, field_tests.rs, right.rs, a11y.rs, list_drag.rs, widgets.rs, windows_qa_tests.rs}`.

**Local:** `docs/design/component-catalog.md`; `.project/architecture/layer-contracts.md`;
`packages/warp_prism_runtime/lib/src/async_command/async_command_contract.dart`;
`packages/warp_prism_ui/lib/**`.

No terminal leaf was selected from `analyze/` or `developer-lookup/` — direct file reads sufficed at
this depth and no semantic-lookup question arose. Gortex not used; this wave is not opted in.

## 10. Method compliance

- Default outcome for inspiration-only study: **native re-expression**, not port/wrap/code copying.
- Licence noted **once**; not hunted; not a gate.
- Phase 1 terminal; no implementation, Task creation, promotion or disposal.
- Comparison kept separate from harvest; retention not assessed.
- All donor reads used workspace-local `references/storytold-figcraft/…` paths.
- Sole written artifact: this report.
