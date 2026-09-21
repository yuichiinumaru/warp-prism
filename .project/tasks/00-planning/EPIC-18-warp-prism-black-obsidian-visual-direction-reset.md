# EPIC 18 — Warp Prism Black Obsidian Visual Direction Reset

> **Planning Status**: Active Epic — validated 2026-08-22 by architect orchestrator wave (task-architect governance audit + Flutter expert technical audit). Executable Tasks 1800–1806 promoted to `docs/tasks/01-open/` (expanded versions; original seeds archived under `.archive/planning-seeds-epic18-2026-08-22/`).
> **Executable?**: Yes — via promoted Tasks 1800–1806.
> **Priority**: Critical
> **Owner for approval**: Product/user visual sign-off, then architect orchestrator
> **Origin**: User visual review after running the ADS Catalog/gallery; comparison against `references/cc-reference-images`, `references/cc-visual-id`, and the current Cybernetics Core / OmniRoute-2 visual implementation.
> **Depends on**: Architect validation of the visual contract and task decomposition.
> **Blocks**: New visual component work, visual golden regeneration, and promotion of visual-polish tasks that depend on the current palette.

---

## Executive Decision Requested

Replace the current default visual direction with a **black-obsidian-first** product identity.

The default Warp Prism background and structural surfaces MUST remain black/near-black
obsidian. Blue is allowed as a controlled action, focus, link, or data-highlight accent,
but MUST NOT become the background, dominant surface family, or ambient luminous wash.

This is a deliberate correction to the current visual contract, not a request to delete
the component library. Existing component structure, behavior, accessibility work, and
public `Prism*` API should be preserved where possible; the shared visual token/theme
layer and visual evidence need to be corrected first.

---

## Non-Negotiable Visual Rules

1. **Default background is black obsidian.** No blue background, blue wallpaper, or blue
   structural canvas.
2. **Structural surfaces stay black/near-black.** Cards, sidebars, shells, dialogs, and
   gallery framing use the black-obsidian family with restrained elevation differences.
3. **Blue is an accent, not a substrate.** Approved blue may identify actions, focus,
   links, selections, or data categories; it must not flood the viewport.
4. **Green is semantic.** Reserve green for success/healthy/approved states unless an
   explicitly approved data-visualization mapping says otherwise.
5. **Amber is semantic.** Reserve amber for warning/running/degraded states.
6. **Red is semantic.** Reserve red for errors/rejected/failure states.
7. **Teal remains scoped.** OmniRoute/CyberCore teal (`#00FFCC`) may remain an opt-in
   CyberCore skin or controlled highlight; it is not the default Observatory background
   or global structural accent.
8. **No rainbow chrome.** Violet, gold, pink, orange, green, teal, and blue may
   differentiate data categories when their mapping is meaningful, but not as arbitrary
   decoration across structural UI.
9. **Avoid unnecessary luminous blue exposure.** Do not use high-intensity blue glows,
   blue scanlines, or blue ambient gradients as persistent viewport decoration. This is a
   human-comfort/product-design constraint, not a medical claim.
10. **Typography is role-based.** A UI sans/display face is used for normal interface
    content; JetBrains Mono is reserved for technical/data roles.
11. **No hardcoded structural colors.** Components consume approved semantic tokens.
12. **Visual acceptance is human-gated.** Passing analyzer/tests is necessary but does
    not approve a visual change. No golden refresh is accepted without screenshot review.

---

## Reference Evidence

| Evidence | Live finding | Interpretation |
|---|---|---|
| `references/cc-visual-id/src/index.css` | `#030506` obsidian, `#080c0e` panel, `#121d22` border, `#00FFCC` core teal; Rajdhani + JetBrains Mono | Black/near-black structural base with controlled teal energy |
| `references/cc-visual-id/src/App.tsx` | Uses obsidian/panel surfaces; accent is concentrated in active/focus/telemetry states | Accent is not a background replacement |
| `references/main-yuichiinumaru-cybernetics-core/` | Repository contains Cybernetics Core frontend and screenshot/reference material | Direct CyberCore reference family |
| `cybernetics-core/omniroute-2/src/app/globals.css` | Current VR theme uses `#030506`, `#06080a`, `#080c0e`, `#121d22`, `#00FFCC` | Confirms black-obsidian structural direction |
| `cybernetics-core/omniroute-2/src/app/rajdhani.css` | Rajdhani weights 300–700 are explicitly bundled | Confirms font-role evidence |
| `warp-prism/packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Current defaults are `#050508/#0A0A0F/#0F1015`, sky cyan `#00D4FF`, violet/gold multi-accent stack | Existing implementation diverges from requested identity |
| `warp-prism/packages/warp_prism_ui/lib/src/tokens/ds_typography.dart` | Declares Inter + JetBrains Mono | Current sans role does not match the reference direction |
| `warp-prism/apps/observatory/lib/app/app.dart` | Sets entire app `fontFamily` to `PrismTypography.fontFamilyMono` | Global mono typography is a wiring defect |
| `warp-prism/apps/catalog/lib/main.dart` | Uses bare `ThemeData.dark()` | Catalog is not a reliable canonical visual host |
| `warp-prism/packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart` | Teal is already modeled as opt-in ThemeExtension | Preserve scoped skin semantics; do not globally rebrand |

The reference images in `references/cc-reference-images/` are raster evidence and may be
used for composition/palette comparison. They must not be treated as a substitute for a
human-approved target screenshot.

---

## Proposed Palette Shape

Exact hex values require architect/task-architect review and product sign-off. The shape
is fixed now:

| Role | Constraint | Candidate direction |
|---|---|---|
| Deep background | Black obsidian; no blue cast | Existing obsidian family, potentially closer to `#030506` |
| Base surface | Near-black neutral obsidian | `#080C0E`-like, not blue slate |
| Elevated surface | Slight neutral lift only | `#0C1114`-like |
| Hover/active | Small neutral lift plus accent edge | Avoid blue fill |
| Border | Low-luminance neutral/blue-gray allowed | `#121D22`-like |
| Primary accent | Approved electric blue for action/focus/highlight only | Candidate `#2F81FF` / `#3B82F6`, pending visual approval |
| Teal | CyberCore/OmniRoute optional highlight | `#00FFCC`, scoped via ThemeExtension |
| Success | Semantic green | Existing status-success family or approved equivalent |
| Warning | Semantic amber | Existing status-warning family or approved equivalent |
| Error | Semantic red | Existing status-error family or approved equivalent |
| Secondary data accent | Violet/gold/etc. only when mapped to data meaning | Existing semantic mappings may remain after audit |

The candidate blue values are placeholders for task-architect evaluation, not an
implementation instruction. The key non-negotiable is **black obsidian background**.

---

## Typography Contract

- UI body, headings, navigation, labels: approved Rajdhani-like UI face or another
  explicitly signed-off display/UI face.
- Code, IDs, logs, terminal, timestamps, telemetry: JetBrains Mono.
- Do not apply JetBrains Mono globally to Observatory or Catalog.
- Do not introduce Orbitron solely because it appears in one visual reference; it must be
  a deliberate product decision, not an automatic port.
- Font assets must be declared by consuming apps and tested in the actual catalog/demo host.

---

## Task Graph

| Task | Scope | Depends on |
|---|---|---|
| 1800 | Black-obsidian visual contract and approval packet *(Closed: `docs/design/black-obsidian-visual-contract.md` created)* | This epic / product sign-off |
| 1801 | Black-obsidian token migration and semantic palette mapping | 1800 |
| 1802 | Typography roles and font-asset correctness | 1800 |
| 1803 | Canonical ThemeData and app-host wiring | 1800, 1801, 1802 |
| 1804 | Hardcoded visual-value and structural-color audit | 1801 |
| 1805 | Screenshot-based visual acceptance gate and golden policy | 1803, 1804, 1807 (converged palette) |
| 1806 | Component/gallery visual reconciliation | 1805 |
| 1807 | Token override layer (`PrismTokenRegistry`) + `PrismThemeEditor` organism + live Catalog iteration + palette bake-back | 1800, 1803 |
| 1808 | `PrismColorField` molecule (hex input + swatches; optional HSV) — P2 accelerator for 1807 | 1800, 1801 |

Tasks 1801 and 1802 may run in parallel after Task 1800 approval. Task 1803 follows
both. Task 1804 may begin after token contract approval but must finish before acceptance.

> **Convergence loop amendment (2026-08-22)**: exact accent hexes are no longer picked
> from static swatches upfront. Tasks 1801–1803 ship with PROVISIONAL ladder values;
> the product owner converges visually via the Task 1807 Theme Editor inside the
> Catalog; converged hexes are baked back into token defaults + the Task 1800 contract;
> only then does Task 1805 capture final approval screenshots and refresh goldens.
> The registry is tooling-facing; production code paths never mutate tokens.

---

## Existing Work That Requires Reconciliation

- Task 1105 and `docs/design/token-theme-catalog-policy.md` describe the current
  obsidian + sky-cyan/violet/gold palette. They remain historical policy until this epic
  is approved; Task 1801 must update the authoritative sections rather than silently
  contradicting them.
- Task 1616 correctly keeps CyberCore teal opt-in, but its non-goals and default-theme
  statements must be reconciled with the approved black-obsidian/blue-accent contract.
- EPIC-17 currently mentions teal for active/checked states. Its visual clauses must be
  amended after 1800 approval so form primitives do not accidentally force teal or blue
  structural surfaces.
- Existing goldens must not be regenerated before Task 1805 human visual approval.

---

## Acceptance Gate for This Epic

The architect orchestrator should not promote this plan into executable builder work
until task architects confirm:

- the black-obsidian default is explicit and unambiguous;
- blue is limited to accent/highlight roles;
- semantic status colors are protected from decorative misuse;
- typography roles are testable;
- app theme composition has one canonical source;
- screenshot review is a mandatory gate;
- prior tasks/policies are reconciled rather than silently overridden;
- the task graph is atomic enough for independent builders and reviewers.

---

## Out of Scope

- Deleting `warp_prism_ui` or the component library.
- Rebuilding component behavior before token/theme approval.
- Adding a light theme.
- Porting Widgetbook, MapLibre, Recharts, or React components.
- Making CyberCore teal the default Observatory theme.
- Making blue the default background.
- Updating goldens solely to make CI green.

---

## Architect Review Questions — CLOSED (2026-08-22)

Decisions recorded by the architect orchestrator after the validation wave:

1. **Authority boundary**: Task 1800 is a NEW authority surface
   (`docs/design/black-obsidian-visual-contract.md`). Task 1105 is NOT edited directly;
   its authoritative doc sections are updated BY Task 1801 with a supersession note.
2. **Blue shape**: bounded ladder `accentBlue` / `accentBlueMuted` / `accentBlueDim` +
   focus color. Exact hexes require user swatch pick (candidates must be distinct from
   `#3B82F6`, which is already `statusInfo`/`governanceLocal`/`laneOpen`). Distinctness
   is asserted by token tests in Task 1801.
3. **Rajdhani**: default reference choice with an explicit, tested fallback contract.
   Not "mandatory forever"; changing it requires a new user decision. OFL 1.1 licensing
   permits bundling; ship `OFL.txt`.
4. **Teal skin**: `DSCyberCoreTealSkin` remains a public opt-in ThemeExtension,
   unchanged in role; Task 1801 amends only its hex-guard regression tests with
   provenance.
5. **Canonical screenshot host**: `apps/catalog` via deterministic desktop
   `integration_test` runs; Observatory and CyberCore captured as secondary evidence.
   Widget goldens cannot validate fonts (Ahem) — typography proof is host-level only.
6. **Human approval artifact**: committed PNG screenshots + signed checklist section in
   the approving task's Completion Evidence + changelog entry reference. No golden
   refresh without all three.

### Validation-wave amendments folded into promoted tasks

- Rule Zero (BLACK OBSIDIAN background, blue accent-only, human-comfort rationale)
  leads Task 1800 and every downstream task restates it where relevant.
- `accentCyan` migration strategy: additive blue ladder; cyan remains a documented
  data-category accent until Task 1806 migrates it; `statusPromoted` re-pointing only
  in 1806 with recorded semantic decision (347 call sites inventoried).
- Unbundled-Inter defect: sans role currently renders via platform fallback; Task 1802
  includes asset acquisition + `ds_token_contract_test.dart` family updates.
- Task 1803 factory emits a COMPLETE M3 ColorScheme; component-level non-mono
  assertion required (app-root checks alone insufficient).
- Task 1804 uses the corrected audit pattern (`fromARGB|fromRGBO|Color(0x|HSLColor`,
  tokens exempt); ground truth ~9 raw values, 4 genuine candidates.
- Interim golden freeze between 1801 and 1805 approval published by Task 1800.
- Superseded-text reconciliation ownership assigned: policy doc + purity checklist →
  1801; EPIC-17 clause annotation → 1800; 1616 guard tests → 1801; child `AGENTS.md`
  §5 resolved via interpretive note in 1800 (no constitutional edit).
