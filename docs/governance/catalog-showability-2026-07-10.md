# Catalog / Gallery Showability — 60-second Demo

> **Status**: Live show path (Task 1601)  
> **Date**: 2026-07-10  
> **Policy**: No Widgetbook — custom catalog MVP (`docs/design/token-theme-catalog-policy.md`)  
> **Audience**: Stakeholder handoff for ADS visibility (EPIC-16 Wave V)

---

## 60-second script

| Step | Action | What you should see |
| --- | --- | --- |
| 1 | From monorepo root: `dart pub get && dart run melos bootstrap` (if not already bootstrapped) | Workspace packages resolve |
| 2 | `cd apps/catalog && flutter run` | Prefer desktop target (`-d linux` / macOS / Windows) when available |
| 3 | App opens on **Design System Gallery** | Header: “Design System Gallery” · badge “DS Layer” |
| 4 | Use **Section index** chips at the top | Jump chips for every registry section (Tokens → Templates) |
| 5 | Tap **Organisms** (or scroll) | Shell / board / timeline organism previews |
| 6 | Optional: open Observatory and route to `/design-system` | Same gallery page embedded in product shell |

**Stop claim**: You have shown the ADS proof surface without Widgetbook, live APIs, or MapLibre.

---

## Canonical commands

```bash
# From warp-prism/
dart pub get
dart run melos bootstrap

# Primary show path (also in README Setup step 4)
cd apps/catalog && flutter run

# Optional desktop pin
cd apps/catalog && flutter run -d linux
```

**Melos smoke (optional):**

```bash
# From warp-prism/
dart run melos run test-catalog
```

---

## What the catalog is

| Layer | Path | Role |
| --- | --- | --- |
| Host app | `apps/catalog/lib/main.dart` | Thin `MaterialApp` → `DesignSystemGalleryPage` |
| Gallery page | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Header + **Section index** TOC + scroll body |
| Registry | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Stable section **ids** + titles + builders |
| Sections | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Visual builders per layer |

### Registry section IDs (stable — do not rename casually)

| id | Title |
| --- | --- |
| `tokens` | Tokens |
| `atoms` | Atoms |
| `molecules` | Molecules |
| `operational-states` | Operational States |
| `organisms` | Organisms |
| `virtual-scroll` | Virtual Scroll |
| `health-dashboard` | Health Dashboard |
| `toasts` | Toasts |
| `accessibility-focus` | Accessibility & Focus States |
| `templates` | Templates |

EPIC-16 organism registration completeness is **Task 1613**, not this demo.

---

## Keyboard / demo tips

- **Mouse / trackpad**: Scroll the main list; use **Section index** chips to jump.
- **Keyboard**: Tab into section chips and activate with Enter/Space (chip focus targets).
- **Do not** demo live network, OmniRoute teal rebrand, MapLibre, Recharts, or Widgetbook.
- Palette stays **obsidian + cyan/violet/gold** accents — Nerazim teal skin is optional Task 1616 only.

---

## Alternate surface

| Surface | Command / route | Notes |
| --- | --- | --- |
| Catalog app (preferred) | `cd apps/catalog && flutter run` | Standalone ADS proof |
| Observatory | Run observatory, navigate `/design-system` | Same `DesignSystemGalleryPage` |

Product walkthrough for Observatory Map/Operate/History/Governance is separate:  
`docs/demo/epic-10-demo-script.md`.

---

## Smoke gates (Task 1601)

Recorded live on 2026-07-10:

```bash
cd apps/catalog && dart analyze          # EXIT 0 — No issues found
cd packages/warp_prism_ui && dart analyze lib/src/gallery test/gallery  # EXIT 0
cd packages/warp_prism_ui && flutter test test/gallery/  # all pass
cd apps/catalog && flutter test          # all pass
```

README still documents:

```bash
cd apps/catalog && flutter run
```

---

## Out of scope

- Widgetbook / external storybook packages  
- Rebranding gallery colors  
- Renaming registry section IDs  
- Full EPIC-16 organism gallery completeness (Task 1613)  
- Observatory product route rewrites  
