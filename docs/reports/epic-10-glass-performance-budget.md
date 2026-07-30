# EPIC 10 — Glass Performance Budget

> **Generated**: 2026-06-07 by Task 1040  
> **Last re-audit**: 2026-07-09 (path-to-100 fix after code-quality review)  
> **Scope**: Blur, `BackdropFilter`, and glass panel usage in `packages/warp_prism_ui`  
> **Method**: Full-text search for `DSGlassPanel`, `DSGlassPanelSimple`, `BackdropFilter`, and `ImageFilter.blur` under `packages/warp_prism_ui/lib`

---

## 1. Executive Summary

Warp Prism follows sparse glassmorphism: heavyweight blur is allowed only on a
small allow-list of low-count, high-value hosts. High-frequency list/card
surfaces stay on `DSGlassPanelSimple` / plain `Container`.

**Live blur hosts after 2026-07-09 re-audit (product UI, not gallery demos):**

| Host | Mechanism | Sigma | Status |
|------|-----------|-------|--------|
| `DSStoryPanel` / `PrismStoryPanel` | `DSGlassPanel.elevated` | 15 | **KEEP** — justified narrative surface |
| `DSCommandPalette` / `PrismCommandPalette` | manual `BackdropFilter` (modal styling) | 20 | **KEEP** — single-instance modal overlay |
| `DSToast` / `PrismToast` | was `DSGlassPanel` elevated; now `DSGlassPanelSimple` | 0 | **DEMOTED** — multi-instance stack (up to `maxVisible`) |

Atom implementation only: `DSGlassPanel` itself owns `BackdropFilter`. That is
not a host — hosts compose the atom.

Gallery pages may demo blur for documentation; they are not production list
surfaces and are out of scope for host allow-list enforcement.

---

## 2. Budget Policy

### 2.1 Surface Classification

| Category | Panel Type | Blur Level | Where Allowed |
|----------|-----------|------------|---------------|
| **Narrative / Story** | `DSGlassPanel.elevated` / `PrismGlassPanel.elevated` | sigma 15 | `DSStoryPanel` — low-count, high-value insight surface |
| **Modal / Command overlay** | modal-equivalent blur (panel or manual) | sigma 20 | `DSCommandPalette` — single-instance, keyboard-driven overlay |
| **Detail / Inspector** | `DSGlassPanelSimple` | none | `DSDetailInspector`, dense data surfaces |
| **Cards / Lists** | `DSGlassPanelSimple` or plain `Container` | none | asset/task/metric/story-quick cards |
| **Toasts / multi-stack overlays** | `DSGlassPanelSimple` | none | `DSToast` — up to N simultaneous instances |
| **Board / Lanes** | plain `Container` | none | lane boards and scroll columns |
| **Graph / Canvas** | plain `Container` | none | physics canvas (60fps target) |
| **Shell / Navigation** | plain `Container` | none | shell, sidebar, topbar |

### 2.2 Rules

1. **Default is simple.** New surfaces MUST use `DSGlassPanelSimple` /
   `PrismGlassPanelSimple` or plain `Container` unless explicitly justified.
2. **Blur requires justification.** Any new blur host must be named in §2.3
   and covered by `packages/warp_prism_ui/test/glass_budget_test.dart`.
3. **No blur nesting.** Never place a blur panel inside another blur panel.
4. **No blur on scrollable list items.** `ListView` / `GridView` item builders
   MUST NOT introduce `BackdropFilter` children.
5. **High-frequency = simple.** Once-per-item surfaces (cards, markers, chips)
   use the simple path.
6. **Modal blur is acceptable** for true single-instance overlays
   (`DSCommandPalette`, future modal dialogs).
7. **Stackable overlays stay simple.** Toasts, banners, and similar multi-instance
   overlays MUST NOT use `BackdropFilter` (stack budget would scale with N).
8. **Public API.** Consumer tests and apps use `Prism*` names from
   `warp_prism_ui.dart`. Raw `DS*` types remain package-private.

### 2.3 Blur Inventory (hosts, 2026-07-09)

| Host (DS / Prism) | Panel / Mechanism | Blur Sigma | Justification | Status |
|-------------------|-------------------|------------|---------------|--------|
| `DSStoryPanel` / `PrismStoryPanel` | `DSGlassPanel.elevated` | 15 | Primary narrative insight surface. Low count (1–3 per screen). High observatory visual value. | **KEEP** |
| `DSCommandPalette` / `PrismCommandPalette` | manual `BackdropFilter` (modal styling parity with `DSGlassPanel.modal`) | 20 | Single-instance keyboard modal; only one palette open at a time. | **KEEP** |
| `DSToast` / `PrismToast` | `DSGlassPanelSimple` + elevation2 shadow | 0 | Multi-instance (default `maxVisible: 5`). Near-opaque fill (`alpha: 0.95`) already reads elevated; blur would stack. | **SIMPLE** |
| `DSStoryCardQuick` / `PrismStoryCardQuick` | `DSGlassPanelSimple` | 0 | Dashboard metric tiles — high frequency | ✅ simple |
| `DSMetricTile` / `PrismMetricTile` | `DSGlassPanelSimple` | 0 | Metric display — high frequency | ✅ simple |
| `DSAssetCard` / `PrismAssetCard` | plain `Container` | 0 | List cards — high frequency | ✅ no glass blur |
| `DSTaskCard` / `PrismTaskCard` | plain `Container` | 0 | Lane cards — high frequency, scrollable | ✅ no glass blur |
| `DSLaneBoard` | plain `Container` | 0 | Board columns — horizontal scroll | ✅ no glass blur |
| `DSGraphCanvas` | plain `Container` | 0 | Physics canvas — 60fps target | ✅ no glass blur |
| `DSDetailInspector` | plain `Container` | 0 | Detail sections — dense data | ✅ no glass blur |
| `DSShell` / `DSSidebar` / `DSTopbar` | plain `Container` | 0 | Always-visible chrome | ✅ no glass blur |
| Other simple hosts (`DSHealthCard`, `DSCodeBlock`, `DSDataTable` chrome, `DSFallbackView`, …) | `DSGlassPanelSimple` | 0 | Non-list or bounded chrome | ✅ simple |

**Allow-listed product blur hosts: 2** (`PrismStoryPanel`, `PrismCommandPalette`).

### 2.4 Glass Panel Tier Reference

| Constructor | Blur Sigma | Shadows | Intended Use |
|-------------|-----------|---------|--------------|
| `DSGlassPanel.subtle` / `PrismGlassPanel.subtle` | 5 | none | Hover emphasis, rare lightweight blur |
| `DSGlassPanel` (default) | 10 | none | General-purpose (use sparingly) |
| `DSGlassPanel.elevated` / `PrismGlassPanel.elevated` | 15 | elevation2 | Story panels, justified hero surfaces |
| `DSGlassPanel.modal` / `PrismGlassPanel.modal` | 20 | elevation4 | Modal overlays (single instance) |
| `DSGlassPanelSimple` / `PrismGlassPanelSimple` | 0 | configurable | **Default** for all other surfaces |

---

## 3. Performance Notes

### 3.1 BackdropFilter Cost Model

`BackdropFilter` with `ImageFilter.blur()` rasterizes the area behind the widget
and applies a Gaussian blur. Cost scales with:

- **Area** — larger regions cost more.
- **Sigma** — higher radius needs more samples.
- **Instance count / nesting** — multiple or nested filters multiply work.

Desktop targets tolerate a single sigma-15 story panel and one sigma-20 command
palette. Risk rises when blur lands in lists, boards, or stacked toasts.

### 3.2 Current Risk Assessment

**Risk: LOW** after toast demotion. Two single-instance (or low-count story)
blur hosts; stackable toasts are blur-free.

### 3.3 GlowBorder Animation

`DSGlowBorder` uses continuous animation. Acceptable for 1–3 instances; do not
put on every card in a list.

---

## 4. Enforcement

Regression suite: `packages/warp_prism_ui/test/glass_budget_test.dart`

- Tier blur contracts on public `PrismGlassPanel`
- `PrismGlassPanelSimple` is blur-free under widget pump
- High-frequency cards (`PrismStoryCardQuick`, `PrismMetricTile`,
  `PrismAssetCard`, `PrismTaskCard`) have no `BackdropFilter`
- `PrismToast` is blur-free (`PrismGlassPanelSimple` path)
- `PrismStoryPanel` retains justified elevated blur (exactly one filter)
- `PrismCommandPalette` retains justified modal blur (exactly one filter)
- Allow-list documentation group fails closed if hosts diverge from §2.3

Public barrel: tests use `Prism*` only. Do not export raw `DS*` from
`warp_prism_ui.dart` (boundary hide contract).

---

## 5. Recommendations for Future Work

1. **New host**: start with `PrismGlassPanelSimple`. Upgrade to blur only if
   low count (&lt;5 per screen), non-scrollable item, high visual value, and
   inventory + test updates land in the same change.
2. **Command palette**: optional later refactor to compose `PrismGlassPanel.modal`
   instead of a hand-rolled `BackdropFilter` (behavior-equivalent).
3. **Gallery**: show blur vs simple side-by-side for education; gallery demos
   do not expand the production allow-list.
4. **Profiling**: with a runnable app, DevTools-check story + palette GPU cost;
   if frame budget breaks, drop story to `subtle` (sigma 5) before removing
   palette modal blur.
