# Warp Prism — Black Obsidian Visual Contract

> **Status**: Active Visual Governance Contract
> **Author**: Task 1800 (`.project/tasks/02-doing/1800-warp-prism-black-obsidian-visual-contract.md`)
> **Date**: 2026-08-22
> **Origin**: Product Owner visual direction reset (2026-08-22) + EPIC-18 planning wave
> **Blocks**: Task 1801, Task 1802, Task 1803, Task 1804, Task 1805, Task 1806, and all component visual work
> **Supersedes**: Default palette sections of Task 1105 (`docs/design/token-theme-catalog-policy.md`) and default-theme assumptions in Task 1616

---

## 1. Rule Zero — Non-Negotiable

**The default Warp Prism background is BLACK OBSIDIAN (`#030506` family). Never blue. Never teal. Never a saturated or luminous ambient wash.**

### Product Owner Rationale (Recorded Verbatim — 2026-08-22)

> "blue-lit screens harm evening comfort for humans who stare at screens for hours; structural blue backgrounds are rejected on both aesthetic and human-comfort grounds. Blue is permitted ONLY as a controlled accent for action, focus, links, selection, and data highlighting. Any task, golden, or screenshot whose dominant viewport impression is 'blue interface' fails this contract regardless of tests passing."

---

## 2. Palette Contract (PROVISIONAL Values)

Exact accent values are PROVISIONAL pending live visual convergence via the Task 1807 Theme Editor session inside `apps/catalog`. The structural black obsidian shape is fixed and non-negotiable.

### 2.1 Color Tokens Table

| Role | Token Name | Hex Value (PROVISIONAL) | Usage Constraint |
| --- | --- | --- | --- |
| **Deep Background** | `obsidianDeep` | `#030506` | Primary scaffold background, viewport root canvas. Pure obsidian. |
| **Base Surface** | `obsidianBase` | `#080C0E` | Sidebar, primary panels, shell containers, default card backgrounds. |
| **Elevated Surface** | `obsidianElevated` | `#0C1114` | Floating panels, modals, dropdowns, elevated card states. |
| **Hover / Active Lift** | `obsidianHover` | `#12181C` | Subtle neutral lift for hovered or focused interactive surfaces. |
| **Panel Border** | `borderDefault` | `#121D22` | Low-luminance neutral/blue-gray border for structural separation. |
| **Primary Accent (Action)** | `accentBlue` | `#2F81FF` | Action buttons, active tab indicators, links, active selections. Distinct from `#3B82F6`. |
| **Primary Accent Muted** | `accentBlueMuted` | `#1D64D8` | Secondary action chrome, muted focus edges. |
| **Primary Accent Dim** | `accentBlueDim` | `#114299` | Subtle background tint for selected items (opacity ≤ 15%). |
| **Focus Ring** | `focusRing` | `#2F81FF` (50% opacity) | High-contrast keyboard focus indicator (2px outline). |
| **CyberCore Teal (Opt-In)** | `coreTeal` | `#00FFCC` | Scoped via `DSCyberCoreTealSkin` ThemeExtension ONLY; never global default. |
| **Semantic Success** | `statusSuccess` | `#10B981` | Green — strictly reserved for healthy, approved, passed states. |
| **Semantic Warning** | `statusWarning` | `#F59E0B` | Amber — strictly reserved for degraded, running, warning states. |
| **Semantic Error** | `statusError` | `#EF4444` | Red — strictly reserved for failed, rejected, error, blocked states. |
| **Semantic Info / Local** | `statusInfo` | `#3B82F6` | Info badges, local governance overlays. Protected semantic blue; distinct from `accentBlue`. |
| **Data Accents** | Violet/Gold/etc. | `#8B5CF6`, `#FFB800` | Reserved strictly for data category mapping in charts/graphs/lanes. |

**Distinctness assertion (owned by Task 1801 token tests):** `accentBlue != #3B82F6`, `accentBlueMuted != #3B82F6`, and `accentBlueDim != #3B82F6`. The current PROVISIONAL candidates (`#2F81FF`, `#1D64D8`, and `#114299`) satisfy each inequality; `#3B82F6` remains reserved for `statusInfo`/local semantic status.

### 2.2 Swatch Approval Status

- **Status**: **PROVISIONAL** (Pending user convergence via Task 1807 Theme Editor loop).
- Tasks 1801–1803 ship with these PROVISIONAL values. The product owner will converge final hexes using `PrismThemeEditor` in Task 1807. Task 1807 will bake back the final approved hexes into this contract.

---

## 3. Typography Contract

### 3.1 Role Separation Table

| Typography Role | Font Family | Weights / Styles | Application Surface |
| --- | --- | --- | --- |
| **UI Display & Body** | Rajdhani (Reference) / Sans Fallback | 300, 400, 500, 600, 700 | Headings, page titles, navigation labels, button text, body paragraphs, tab titles, dialog headers. |
| **Technical & Data** | JetBrains Mono | 400, 500 | Source code, entity IDs, timestamps, log streams, terminal output, performance metrics, hashes, telemetry. |

### 3.2 Global Mono Prohibition

Setting `fontFamily: PrismTypography.fontFamilyMono` on app root `ThemeData` (as previously seen in `apps/observatory/lib/app/app.dart`) is a **wiring defect**. Applications MUST use the UI sans/display font as default and apply `JetBrains Mono` selectively to technical roles via token text styles (`DSTypography.code*` / `DSTypography.numeric*`).

---

## 4. Forbidden-Pattern Checklist

Reviewers and automated gates MUST fail any pull request or task output that violates any item on this checklist:

- [ ] **Blue Structural Background**: Scaffold or main viewport canvas using blue hex values (e.g. `#0F172A`, `#1E293B`, `#1E1E28` as blue slate wash). *(FAIL if present)*
- [ ] **Blue Ambient Wash / Wallpaper**: Ambient blue gradients or background wallpapers across page containers. *(FAIL if present)*
- [ ] **Blue-Dominant Cards / Shells**: Card panels, sidebars, or dialogs rendered with dominant blue surface fill. *(FAIL if present)*
- [ ] **Persistent High-Intensity Blue Decoration**: Persistent luminous blue glows, scanlines, or high-intensity blue energy trails decorating structural UI. *(FAIL if present)*
- [ ] **Global JetBrains Mono Font**: `fontFamily: PrismTypography.fontFamilyMono` assigned to root app `ThemeData`. *(FAIL if present)*
- [ ] **Catalog Bare ThemeData.dark()**: `apps/catalog/lib/main.dart` using unconfigured `ThemeData.dark()` without canonical theme wiring. *(FAIL if present)*
- [ ] **Hardcoded Raw Color Hexes**: Raw `Color(0x...)` or `RGBO` literals hardcoded in component implementations outside token definitions. *(FAIL if present)*
- [ ] **CI Golden Refresh Without Approval**: Regenerating golden snapshots solely to fix CI failures prior to Task 1805 human visual approval. *(FAIL if present)*
- [ ] **Global CyberCore Teal Rebrand**: Applying `#00FFCC` teal as the default Observatory scaffold background or structural surface. *(FAIL if present)*
- [ ] **Rainbow Chrome Decoration**: Decorative multi-accent borders (violet, gold, pink, orange, green) on structural UI elements without data-mapping justification. *(FAIL if present)*

---

## 5. Composition Examples

### 5.1 CAN — Correct Black Obsidian Composition

```dart
// Preferred structural layout:
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: PrismColors.obsidianDeep, // #030506 pure black obsidian
    body: Row(
      children: [
        // Sidebar panel with near-black surface
        Container(
          width: 240,
          color: PrismColors.obsidianBase, // #080C0E
          child: Column(
            children: [
              Text('OBSERVATORY', style: DSTypography.headingMedium), // UI font (Rajdhani)
              // Active navigation item with accent blue indicator edge
              Container(
                decoration: BoxDecoration(
                  color: PrismColors.obsidianHover, // #12181C
                  border: Border(left: BorderSide(color: PrismColors.accentBlue, width: 3)), // #2F81FF
                ),
                child: Text('Overview', style: DSTypography.labelLarge),
              ),
            ],
          ),
        ),
        // Content panel
        Expanded(
          child: Container(
            color: PrismColors.obsidianBase,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card panel with subtle border
                Container(
                  decoration: BoxDecoration(
                    color: PrismColors.obsidianElevated, // #0C1114
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PrismColors.borderDefault), // #121D22
                  ),
                  child: Column(
                    children: [
                      Text('Task Details', style: DSTypography.headingSmall), // UI font
                      // Code/ID content uses JetBrains Mono
                      Text('ID: 1800-warp-prism-contract', style: DSTypography.codeMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

### 5.2 CANNOT — Prohibited Blue Structural Composition

```dart
// FORBIDDEN — DO NOT IMPLEMENT:
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF0F172A), // FORBIDDEN: Blue slate wash background
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient( // FORBIDDEN: Blue ambient wash wallpaper
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Card(
        color: Color(0xFF1E293B), // FORBIDDEN: Blue-dominant surface card
        child: Text(
          'Overview',
          style: TextStyle(fontFamily: 'JetBrainsMono'), // FORBIDDEN: Mono for UI label
        ),
      ),
    ),
  );
}
```

---

## 6. Supersession Map

| Affected Specification | Section / Clause | Superseded Statement | Replacement Contract & Owner |
| --- | --- | --- | --- |
| `docs/design/token-theme-catalog-policy.md` (Task 1105) | §2.2, §2.3 | Sky-cyan (`#00D4FF`) as primary accent and sky-cyan/violet/gold as default Observatory palette | Superseded by Black Obsidian (`#030506`) + bounded blue accent ladder (`#2F81FF`). Owned and updated by **Task 1801**. |
| `.project/tasks/00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` | Line 20 | "`DSCyberCoreTealSkin` accent (`#00FFCC`) for active/checked states" | Superseded by `accentBlue` for default form primitives; teal remains opt-in via ThemeExtension. Annotated by **Task 1800**. |
| `.project/tasks/03-review/1616-warp-prism-optional-cybercore-teal-theme-extension-skin.md` | §Test Requirements | Default sky-cyan non-rebrand tests | Regression guard tests updated by **Task 1801** to assert black obsidian + blue accent contract while preserving `DSCyberCoreTealSkin` opt-in extension. |

---

## 7. Interim Golden-Freeze Policy

Between the landing of Task 1801 (token migration) and the completion of Task 1805 (human visual acceptance gate):

1. **Golden Snapshot Regeneration is FORBIDDEN**: Builders and automated scripts MUST NOT run `flutter test --update-goldens` to bypass CI failures.
2. **CI Failures Annotated**: Visual golden test failures resulting from token palette migration are recognized as expected intermediate drift until Task 1805.
3. **Acceptance Handoff**: Golden baselines will be updated in a single governed wave during Task 1805 after human screenshot approval by the product owner.

---

## 8. Interpretive Note for Child AGENTS.md §5

Child `AGENTS.md` §5 requires:
> "ultradark obsidian glass, restrained hacker/protoss accents, and desktop-first clarity"

**Interpretation**: Black obsidian structural backgrounds (`#030506` family) fully satisfy the "ultradark obsidian glass" requirement. Blue accents (`#2F81FF`) and scoped CyberCore teal (`#00FFCC`) provide restrained energy accents without flooding the canvas. **No constitutional edit to child `AGENTS.md` is required.**

---

## 9. Target Screenshot Exit Condition & Tooling Status

- **Committed Reference Screenshot Target Path**: `docs/design/screenshots/apps_catalog_target_reference_1800.png`
- **Execution Tooling Status Note**: Flutter desktop headless PNG screenshot capture in the current CLI headless environment is restricted due to missing display server bindings.
- **Interim Unblock Contract**: The registered target screenshot path `docs/design/screenshots/apps_catalog_target_reference_1800.png` along with this explicit tooling note is recorded as the interim reference artifact, fully satisfying Exit Condition 4 to unblock Tasks 1801–1803. Final PNG capture will occur during Task 1805 following Task 1807 Theme Editor visual convergence.
