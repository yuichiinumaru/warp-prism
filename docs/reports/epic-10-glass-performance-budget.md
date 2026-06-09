# EPIC 10 — Glass Performance Budget

> **Generated**: 2026-06-07 by Task 1040
> **Scope**: Blur, BackdropFilter, and glass panel usage audit
> **Method**: Full-text search for `DSGlassPanel`, `DSGlassPanelSimple`, `BackdropFilter`, and `blur` in `lib/`

---

## 1. Executive Summary

The Warp-Prism design system is **already well-aligned** with the research brief's "sparse glassmorphism" guidance. Of 40 design-system files, only **one host** uses the expensive `DSGlassPanel` (with BackdropFilter blur): `DSStoryPanel`. All other surfaces use `DSGlassPanelSimple` (solid color, no blur) or plain `Container` with `BoxDecoration`.

No surgical swaps are needed. This report codifies the current state as a **policy** so future work does not reintroduce gratuitous blur.

---

## 2. Budget Policy

### 2.1 Surface Classification

| Category | Panel Type | Blur Level | Where Allowed |
|----------|-----------|------------|---------------|
| **Narrative / Story** | `DSGlassPanel.elevated` | sigma 15 | `DSStoryPanel` — low-count, high-value insight surface |
| **Detail / Inspector** | `DSGlassPanelSimple` | none | `DSDetailInspector`, `DSPropertyRow` — dense data, no blur benefit |
| **Cards / Lists** | `DSGlassPanelSimple` or plain `Container` | none | `DSAssetCard`, `DSTaskCard`, `DSMetricTile`, `DSStoryCardQuick` — high-frequency surfaces |
| **Board / Lanes** | plain `Container` | none | `DSLaneBoard`, `_LaneColumn` — horizontal scroll, many items |
| **Graph / Canvas** | plain `Container` | none | `DSGraphCanvas` — 60fps physics, no blur overhead |
| **Shell / Navigation** | plain `Container` | none | `DSShell`, `DSSidebar`, `DSTopbar` — always-visible, must be fast |
| **Modals / Overlays** | `DSGlassPanel.modal` | sigma 20 | Reserved for future modal dialogs — justified by single-instance usage |

### 2.2 Rules

1. **Default is simple.** New surfaces MUST use `DSGlassPanelSimple` or plain `Container` unless explicitly justified.
2. **Blur requires justification.** Any new `DSGlassPanel` usage must be documented in this budget with a reason.
3. **No blur nesting.** Never place a `DSGlassPanel` inside another `DSGlassPanel`. The `ClipRRect` + `BackdropFilter` stack compounds GPU cost.
4. **No blur on scrollable lists.** `ListView.builder`, `GridView.builder`, and horizontal `SingleChildScrollView` surfaces MUST NOT contain `BackdropFilter` children.
5. **High-frequency = simple.** Any surface rendered once-per-item in a list (cards, markers, chips) must use the simple path.
6. **Modal blur is acceptable.** `DSGlassPanel.modal` (sigma 20) is reserved for true modals/overlays where only one instance is visible at a time.

### 2.3 Blur Inventory (current)

| Host | Panel Used | Blur Sigma | Justification | Status |
|------|-----------|------------|---------------|--------|
| `DSStoryPanel` | `DSGlassPanel.elevated` | 15 | Primary narrative insight surface. Low count (1-3 per screen). High visual value for "observatory" feel. | **KEEP** |
| `DSStoryCardQuick` | `DSGlassPanelSimple` | 0 | Dashboard metric tiles — high frequency | ✅ Already simple |
| `DSMetricTile` | `DSGlassPanelSimple` | 0 | Metric display — high frequency | ✅ Already simple |
| `DSAssetCard` | plain `Container` | 0 | List cards — high frequency | ✅ No glass |
| `DSTaskCard` | plain `Container` | 0 | Lane cards — high frequency, scrollable | ✅ No glass |
| `DSLaneBoard` | plain `Container` | 0 | Board columns — horizontal scroll | ✅ No glass |
| `DSGraphCanvas` | plain `Container` | 0 | Physics canvas — 60fps target | ✅ No glass |
| `DSDetailInspector` | plain `Container` | 0 | Detail sections — dense data | ✅ No glass |
| `DSShell` | plain `Container` | 0 | App shell — always visible | ✅ No glass |
| `DSSidebar` | plain `Container` | 0 | Navigation — always visible | ✅ No glass |
| `DSTopbar` | plain `Container` | 0 | Search/actions — always visible | ✅ No glass |

**Total BackdropFilter instances in hosts: 1** (DSStoryPanel only)

### 2.4 Glass Panel Tier Reference

| Constructor | Blur Sigma | Shadows | Intended Use |
|-------------|-----------|---------|--------------|
| `DSGlassPanel.subtle` | 5 | none | Hover emphasis, subtle elevation |
| `DSGlassPanel` (default) | 10 | none | General-purpose (use sparingly) |
| `DSGlassPanel.elevated` | 15 | elevation2 | Story panels, hero surfaces |
| `DSGlassPanel.modal` | 20 | elevation4 | Modal overlays (single instance) |
| `DSGlassPanelSimple` | 0 | configurable | Default for all other surfaces |

---

## 3. Performance Notes

### 3.1 BackdropFilter Cost Model

`BackdropFilter` with `ImageFilter.blur()` requires Flutter to rasterize the area behind the widget and apply a Gaussian blur shader. The cost scales with:
- **Area**: Larger blur regions cost more.
- **Sigma**: Higher blur radius requires more texture samples.
- **Nesting**: Nested `BackdropFilter` widgets multiply the rasterization cost.

On desktop (the primary target), a single `BackdropFilter` with sigma 15 on a ~400x600px story panel is well within budget. The risk arises only if blur surfaces proliferate into lists or boards.

### 3.2 Current Risk Assessment

**Risk: LOW.** The codebase has exactly one BackdropFilter host. No further optimization is needed.

### 3.3 GlowBorder Animation

`DSGlowBorder` uses `AnimationController` with continuous animation. This is acceptable for 1-3 instances but should not be used on every card in a list. Current usage is limited to decorative borders on selected/hovered items.

---

## 4. Enforcement

The regression test `test/design_system/glass_budget_test.dart` verifies:
- `DSStoryPanel` uses `DSGlassPanel.elevated` (blur justifiied)
- `DSStoryCardQuick` uses `DSGlassPanelSimple` (no blur)
- `DSMetricTile` uses `DSGlassPanelSimple` (no blur)
- The `DSGlassPanel` class documents its sparse-usage contract

---

## 5. Recommendations for Future Work

1. **If adding a new host**: Start with `DSGlassPanelSimple`. Only upgrade to `DSGlassPanel` if the surface meets all criteria: low count (<5 per screen), non-scrollable, high visual value.
2. **Gallery/demo page**: When the demo gallery is built, it should include a glass budget section showing which surfaces use blur and why.
3. **Profiling**: Once a runnable app exists, use Flutter DevTools to verify BackdropFilter cost on the story panel. If GPU frame time exceeds 8ms on the target hardware, consider reducing the blur to `DSGlassPanel.subtle` (sigma 5).
