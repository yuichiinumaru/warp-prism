# ADS Harvest — OmniRoute visual-reference — 2026-07-10

> **Analyst role**: design-system harvest (read-only)  
> **Source**: `/home/sephiroth/working/ganthritor/omniroute-2/visual-reference/`  
> **Nature of source**: full mock / visual demo prototype only — **not** production backend  
> **Local target**: Warp Prism Prism ADS (`packages/warp_prism_ui`)  
> **Product constraints**: read-only Observatory; ultradark obsidian glass + cyan/violet/gold accents  
> **Method**: evidence from local files with path references; no code copied into WP

---

## Source map

| Area | Path | Role |
| --- | --- | --- |
| Entry / shell demo | `src/App.tsx` | Large mono-file composite demos (agents, policies, tools, settings) plus routing host |
| Design tokens | `src/design/tokens.ts` | Canonical `PRISM_TOKENS` (colors, fonts, glows, borders, spacing, motion) |
| CSS / Tailwind theme | `src/index.css` | `@theme` CSS vars mirroring tokens; body; scrollbar; `.scanlines` |
| State vocabulary | `src/design/states.ts` | `STATE_VOCABULARY` (healthy/degraded/offline/…) with tone, glow, motion |
| Navigation taxonomy | `src/design/navigation.ts` | Sectioned IA for OmniProxy/Cybernetics Core |
| Fixtures | `src/data/fixtures.ts` | Mock combos, logs, routes, agents |
| Organisms | `src/components/organisms/*` | 7 exported organisms (see inventory) |
| Molecules | `src/components/molecules/*` | StatusBadge, MetricTile, NavItem, SearchInput, ActionButton |
| Atoms | `src/components/atoms/*` | Text, Icon, Button, Badge, Divider |
| Views | `src/views/*` | 14 product screens composing organisms |
| Spec docs | `docs/001-visual-id.md` … `docs/022-*.md` | Prism ADS contracts; includes `016-flutter-warp-prism-migration.md` |
| Glow policy | `docs/010-motion-and-glow-budget.md` | Hard limits on pulse/glow |
| Layout patterns | `docs/013-layout-patterns.md` | Approved page skeletons |

**Proven**: source is intentionally ADS-shaped (atoms → molecules → organisms → views) and documents a Flutter migration mapping (`docs/016-flutter-warp-prism-migration.md`).  
**Inference**: visual-reference is the **Cybernetics Core / OmniProxy** product skin, not the ASW Observatory product skin — shared “Prism” language, different accent monism and IA.

---

## Color / theme extraction

### Canonical tokens (`src/design/tokens.ts` + `src/index.css`)

| Token | Hex / value | CSS var |
| --- | --- | --- |
| `obsidian` | `#030506` | `--color-obsidian` |
| `panel` | `#080c0e` | `--color-panel` |
| `panelHover` | `#0c1215` | `--color-panel-hover` |
| `panelBorder` | `#121d22` | `--color-panel-border` |
| `coreCyan` | `#00FFCC` | `--color-core-cyan` |
| `coreCyanDim` | `rgba(0, 255, 204, 0.05)` | `--color-core-cyan-dim` |
| `textMuted` | `#a0aec0` | (body color in CSS) |
| `textDim` | `#64748b` | (TS only) |
| `white` | `#ffffff` | — |

### Typography (reference only)

| Role | Family | Notes |
| --- | --- | --- |
| Display / logos | **Orbitron** | Uppercase tracking-widest headers |
| Tactical UI | **Rajdhani** | Body + headers (`body { font-family: Rajdhani }`) |
| Mono / logs | **JetBrains Mono** | Shared with WP mono stack |

### Glow ladder (`PRISM_TOKENS.glows`)

| Name | Effect (approx.) |
| --- | --- |
| `soft` | `0 0 8px rgba(0,255,204,0.3)` |
| `strong` | `0 0 15px rgba(0,255,204,0.6)` + cyan border 50% |
| `successSoft/Strong` | green-500 family `rgba(34,197,94,…)` |
| `warningSoft/Strong` | amber `rgba(245,158,11,…)` |
| `dangerSoft/Strong` | red `rgba(239,68,68,…)` |
| `infoSoft/Strong` | cyan-500 `rgba(6,182,212,…)` (note: **not** core `#00FFCC`) |

### Hardcoded / ad-hoc palette (views + composites)

Not in `PRISM_TOKENS`, but repeated in screens:

| Use | Values | Where |
| --- | --- | --- |
| Chart stroke/fill | `#00ffcc`, area stops 0.3→0 | `views/dashboard.tsx`, `usage-analytics.tsx` |
| Chart chrome | stroke `#333`, tick `#666`, tooltip `#0a0a0a` | same + `cache-analytics.tsx` |
| Graph nodes | `#c084fc` (purple-400), `#4ade80` (green-400) | `views/knowledge-graph.tsx` |
| Status dots | `#facc15` yellow, `#ef4444` red | `views/swarm-status.tsx` |
| Policy mode chips | red / yellow / blue / purple Tailwind 400–500 | `App.tsx` policy board |
| Grid background | cyan grid at **1%** opacity, 20×20 | nearly all views |
| Outer shell | `shadow-[0_0_20px_rgba(0,0,0,0.5)]` | view roots |
| Selection left rail | `bg-core-cyan/5` + `border-l-core-cyan` | `PrismDataTable`, `PrismTree` |
| L-corner accent | 12×2 + 2×4 bars top-left | `PrismPanel`; drawer uses top-right |
| Scanlines | 4px stripe overlay `rgba(0,0,0,0.15)` | `index.css` `.scanlines` |

### Semantic status via Tailwind (not formal tokens)

`states.ts` maps operational labels → Tailwind utility classes:

| State (examples) | Tone | Color classes (approx.) |
| --- | --- | --- |
| healthy | success | `text-green-400`, `border-green-500/20`, `bg-green-500/10` |
| degraded | warning | amber-400 / amber-500 |
| offline / danger | danger | red-500 |
| active | info | core-cyan utilities |
| disabled | neutral | gray-500 / gray-700 |

**Negative evidence**: no violet primary token, no gold/protoss accent token, no governance/lane/asset-kind palette, no multi-step surface elevation ladder beyond panel/hover. The system is **mono-accent teal-cyan** with Tailwind semantic fallbacks.

---

## Diff vs DSColors (quick-win only)

### Surface / text / accent hex comparison

| Role | OmniRoute | Warp Prism (`ds_colors.dart`) | Δ / verdict |
| --- | --- | --- | --- |
| Deepest bg | `#030506` | `obsidianDeep` `#050508` | OR cooler green-black (−2 R, −2 G, −2 B-ish). **Negligible**; WP already ultra-dark. |
| Base / panel | `#080c0e` | `obsidianBase` `#0A0A0F` | OR greener; WP slightly purple-black (fits violet secondary). **Keep WP.** |
| Elevated / hover | `#0c1215` | `obsidianHover` `#14141C` | WP has clearer 5-step ladder (Deep→Base→Elevated→Hover→Active). **WP superior.** |
| Panel border | `#121d22` | `borderSubtle` `#1E1E28` / `borderDefault` `#2A2A38` | OR greener + dimmer; WP more neutral glass edge. **Keep WP** for multi-accent glass. |
| Primary energy | `#00FFCC` (teal) | `accentCyan` `#00D4FF` (sky) | **Hue fork, not a bug.** Changing WP primary = rebrand. **Do not retoken.** |
| Cyan muted/dim | only `rgba(…,0.05)` wash | `accentCyanMuted` `#0099B8`, `accentCyanDim` `#006680` | **WP superior** structured mutes. |
| Secondary accent | *(absent)* | `accentViolet` `#8B5CF6` (+ muted/dim) | OR missing. **Keep WP.** |
| Tertiary accent | *(absent)* | `accentGold` `#FFB800` (+ muted/dim) | OR missing. **Keep WP.** |
| Body text | `#a0aec0` | `textSecondary` `#A0A0B0` | Near-parity (OR cooler slate). **No change required.** |
| Dim text | `#64748b` | `textTertiary` `#8888A0` / `textDisabled` `#505060` | Different roles; WP tertiary is a11y-annotated (~6:1 on deep). **Keep WP.** |
| Primary text | `#ffffff` | `textPrimary` `#F0F0F5` | WP off-white reduces harsh bloom on OLED. **Keep WP.** |
| Success | Tailwind green-500 / `#22c55e` family | `statusSuccess` `#10B981` | Both valid; WP already fixed. **No quick-win.** |
| Warning | amber `#F59E0B` family | `statusWarning` `#F59E0B` | **Exact match** on warning base. |
| Error | red `#EF4444` family | `statusError` `#EF4444` | **Exact match.** |
| Info | mixed cyan-500 / core-cyan | `statusInfo` `#3B82F6` | WP deliberately separates **info blue** from **energy cyan**. **Keep WP.** |

### Shadows / glass / motion (related tokens)

| Concern | OmniRoute | Warp Prism | Quick-win? |
| --- | --- | --- | --- |
| Cyan glow | 8px / 15px hard ladder | `DSShadows.glowCyan(intensity)` dual-layer 12/24 | **No hex change** — intensity API already more flexible |
| Multi-hue glow | success/warn/danger only | cyan + **violet** + **gold** + status glows | WP richer |
| Glass | `bg-panel/30`, blur on table header | `DSGlassPanel` subtle/elevated/modal + blur budget | WP richer |
| Radii | mostly `rounded` / `rounded-sm` (2–4px) | `DSRadii` xs→modal + semantic card/panel | WP richer; OR is **sharper** cyber |
| Motion policy | docs budget: 1 hero / 3 pulse / 1 critical blink | `DSMotion` durations/curves; no hard screen budget in tokens | **Policy harvest**, not hex |
| Fonts | Orbitron + Rajdhani + JetBrains | Inter + JetBrainsMono | **Do not swap** — display fonts fight dense Observatory IA |

### Quick-win token recommendations

**Verdict: no mandatory hex retoken of `DSColors`.**  
Warp Prism already covers (and exceeds) the reference for multi-accent ultradark glass. OmniRoute’s strength is **mono-teal product identity**, not a better Observatory palette.

| Priority | Recommendation | Why | Risk |
| --- | --- | --- | --- |
| **None (default)** | Leave `accentCyan = #00D4FF` | Sky cyan + violet + gold is WP constitution visual direction; `#00FFCC` is a product rebrand | High if changed globally |
| **Optional later (not quick-win ADS)** | CyberCore **skin** token alias `coreTeal = #00FFCC` for CyberCore package only | Preserve OmniRoute DNA without Observatory rebrand | Medium (two skins) |
| **Docs / policy only** | Import glow budget rules from `docs/010-motion-and-glow-budget.md` into WP design docs | “Everything that glows must mean state”; max 3 pulses; no row-loop glow | Low |
| **Optional polish (not new hex)** | Use existing `DSColors.accentCyan.withValues(alpha: 0.05)` for selected row wash | Matches OR `coreCyanDim` pattern without new token | Low |
| **Explicit non-goals** | Orbitron/Rajdhani; scanlines; teal-tinted global borders; collapsing violet/gold | Conflicts with density, a11y, and constitution accents | — |

**Hex diff summary (primary accents only):**

```
OmniRoute coreCyan:  #00FFCC  H≈165°  S=100%  L≈50%  (teal)
WP accentCyan:       #00D4FF  H≈190°  S=100%  L≈50%  (sky)
Δhue ≈ +25° toward blue on WP — intentional Observatory/hacker read.
```

---

## Component inventory (ranked steal candidates)

Organism-first ranking. Transfer fit: **Observatory** (ASW map/operate/history/governance) vs **CyberCore** (ops proxy / matrix).

### GOLD

| # | Item | Path | What it does | Transfer fit | Novelty vs WP organisms |
| ---: | --- | --- | --- | --- | --- |
| 1 | **PrismPageShell** | `src/components/organisms/PrismPageShell.tsx` | Page chrome: tone-colored icon well + Orbitron title + subtitle + header `actions` + optional **toolbar row** (search + `toolbarActions`) + fluid/constrained content; enter motion | **Observatory + CyberCore** | **True gap.** WP has `DSShell`/`DSTopbar`/`MasterDetailTemplate` but **no first-class page-level content shell** with icon/title/subtitle/actions/toolbar contract. Docs map → `WpPageShell`. |
| 2 | **PrismTree** | `src/components/organisms/PrismTree.tsx` | Hierarchical tree: expand/collapse, type→icon map, status badge, secondary `info`, `fallbackOrder` chip, selection border wash, nest guide line | **CyberCore (route/combo graphs)**; secondary **Observatory** (skill/agent dependency trees, governance fan-in) | **True gap.** No tree organism under `organisms/`. Graph canvas is spatial, not indented hierarchy. |

### SILVER

| # | Item | Path | What it does | Transfer fit | Novelty vs WP |
| ---: | --- | --- | --- | --- | --- |
| 3 | **PrismPanel** | `src/components/organisms/PrismPanel.tsx` | Modular section container: tone→border/header color, **L-bracket corner accents**, optional `state`→StatusBadge, header actions, divider, body | Both | Partial: `DSGlassPanel` (atom) + `DSStoryPanel` (narrative insights only). Missing **generic toned section panel + corner motif**. |
| 4 | **Layout: Tree + Inspector** | `docs/013-layout-patterns.md` + `views/combo-studio.tsx` | Combo list + PrismTree + detail/simulation panels under PageShell | CyberCore primary; Observatory secondary | Pattern, not widget. Compose with future tree + existing `DSDetailInspector` / `DSSplitPane`. |
| 5 | **Layout: Table + Inspector Drawer** | `views/execution-stream.tsx` + organisms | Metrics row + filterable dense table + row-click drawer dossier | Both | WP has pieces (`DSDataTable`, `DSDetailInspector`, shell responsive drawer). Steal **composition recipe** + row selection chrome. |
| 6 | **Glow / motion budget policy** | `docs/010-motion-and-glow-budget.md` + `tokens.ts` glows | Screen-level limits; glow only for state | Both | Policy gap more than component gap; aligns with epic-10 glass budget thinking. |
| 7 | **Corner accent motif** (derive molecule/atom) | `PrismPanel` L-bars; `PrismInspectorDrawer` top-right; `PrismMetricTile` top bar grow-on-hover | Cheap cyber identity without full font rebrand | Both | Not present as reusable WP atom; could be `DSCornerAccent` / panel chrome option. |

### BRONZE (polish / already mostly covered)

| # | Item | Path | Notes |
| ---: | --- | --- | --- |
| 8 | **PrismDataTable** selection chrome | `PrismDataTable.tsx` | Sticky mono headers, sort, empty copy. WP `DSDataTable` is **more advanced** (virtual scroll, toolbar, selection model). Steal only: **3px left accent + cyan/5 wash** on selected row if gallery lacks it. |
| 9 | **PrismInspectorDrawer** | `PrismInspectorDrawer.tsx` | Full-height right drawer, backdrop, spring enter, header, footer actions. WP: `DSDetailInspector` + `DSShellResponsive` overlay/scrim. Steal footer **actions strip** + corner accents if missing. |
| 10 | **PrismSidebar** branding block | `PrismSidebar.tsx` | Radial cyan glow logo well, sectioned mono labels, footer system link. WP `DSSidebar` already has header/footer/items/collapse. Polish only. |
| 11 | **PrismHeader** | `PrismHeader.tsx` | Breadcrumbs + search + notif dot + user initials. WP `DSTopbar` covers structure; notif/avatar are product chrome. |
| 12 | **PrismMetricTile** | `molecules/PrismMetricTile.tsx` | Label/value/trend/sub + corner bar. WP `DSMetricTile` already has health matrix + trend. Steal corner-bar polish only. |
| 13 | **PrismStatusBadge** + `STATE_VOCABULARY` | `PrismStatusBadge.tsx` + `states.ts` | Glow/motion keyed to state. WP `DSOperationalState` is broader (15 states) and better for ASW. Steal **motion/glow binding table** idea, not duplicate vocabulary. |
| 14 | **Cyan grid page wash** | repeated in views | `linear-gradient` 20px grid at 1% cyan. Optional `DSScaffoldBackground.grid` decoration — **optional, performance-sensitive**. |

### Molecule / atom notes (not primary harvest)

| Item | Path | Disposition |
| --- | --- | --- |
| PrismNavItem | `molecules/PrismNavItem.tsx` | Covered by sidebar item widgets |
| PrismSearchInput | `molecules/PrismSearchInput.tsx` | Covered by `DSSearchBar` + command palette |
| PrismActionButton | `molecules/PrismActionButton.tsx` | Low novelty |
| PrismText / Button / Badge / Icon / Divider | `atoms/*` | WP atoms exist; display-font variants are **skip** |

### Views inventory (composites, not steal-as-organism unless noted)

| View | Path | Steal as organism? |
| --- | --- | --- |
| dashboard | `views/dashboard.tsx` | No — metrics + Recharts area; compose existing tiles |
| execution-stream | `views/execution-stream.tsx` | **Layout pattern** only (see SILVER #5) |
| combo-studio | `views/combo-studio.tsx` | **Layout + tree** (see GOLD/SILVER) |
| knowledge-graph | `views/knowledge-graph.tsx` | No — decorative CSS graph; WP has real graph stack |
| command-grid | `views/command-grid.tsx` | No — product dashboard |
| credentials / endpoints / providers / quota | various | No — product admin |
| usage-analytics / cache-analytics | various | No — chart pages |
| swarm-status | `views/swarm-status.tsx` | Weak — status cards; WP health/status grid exists |
| psionic-matrix | `views/psionic-matrix.tsx` | Skip — hero visual + mode cards; mutation-leaning |
| twilight-council | `views/twilight-council.tsx` | Skip — approval **mutation** UX (ALLOW/BLOCK) vs read-only |
| App.tsx embedded boards | `App.tsx` | Skip as mega-composites; extract patterns only |

**Documented but not implemented as organism:** `PrismToolbar` listed in `docs/002-organisms.md` — no `PrismToolbar.tsx` in `src/components/organisms/`. PageShell’s toolbar row partially absorbs this.

---

## Organisms already covered / false gaps

| OmniRoute name | WP counterpart(s) | False gap? |
| --- | --- | --- |
| PrismSidebar | `ds_sidebar.dart` | **Yes** — covered; branding polish only |
| PrismHeader | `ds_topbar.dart` | **Yes** |
| PrismPageShell | *(none equivalent)* | **No** — real gap |
| PrismPanel | `ds_glass_panel.dart` + `ds_story_panel.dart` | **Partial** — glass atom ≠ toned section organism |
| PrismDataTable | `data_table/ds_data_table.dart` | **Yes** — WP ahead; chrome only |
| PrismInspectorDrawer | `ds_detail_inspector.dart` + shell responsive inspector | **Mostly yes** — footer actions / accents optional |
| PrismTree | *(none)* | **No** — real gap |
| App shell (sidebar+header+content) | `ds_shell.dart` / `DSShellResponsive` | **Yes** — WP more mature (breakpoints, focus order) |
| Table+inspector | `MasterDetailTemplate` + data table | **Mostly yes** |
| Status / metrics | `ds_status_grid`, `ds_metric_tile`, operational state | **Yes** |
| Logs stream | `log_viewer/*` | **Yes** — superior to mock table |
| Graph | `graph/*`, `ds_graph_canvas.dart` | **Yes** — do not steal CSS mock |
| Command palette | `command_palette/*` | **Yes** — OR only shows CTRL+K affordance |
| Toasts | `ds_toast*` | OR has no toast organism found |
| Tabs / split / virtual scroll | WP organisms | OR lacks equivalents |

Migration doc `docs/016-flutter-warp-prism-migration.md` names:

```
PrismPageShell → WpPageShell
PrismPanel → WpPanel
PrismStatusBadge → WpStatusBadge
PrismMetricTile → WpMetricTile
PrismDataTable → WpDataTable
PrismInspectorDrawer → WpInspectorDrawer
PrismTree → WpTree
```

**Proven**: mapping was anticipated; **inference**: several targets already exist under `DS*` names — only **PageShell, Panel (generic), Tree** remain high-value net-new organisms.

---

## Top recommendations

### 1. Implement `DSPageShell` / Prism PageShell (GOLD) — Observatory first

- **What**: content-region organism: `icon`, `title`, `subtitle`, `tone`, `actions`, optional toolbar (`search` + trailing tools), `fluid` flag, child slot.
- **Why**: every OR view and migration doc centers on this; WP routes still hand-roll headers.
- **Where**: `packages/warp_prism_ui/lib/src/organisms/` + gallery section.
- **Do not**: pull Orbitron; use `DSTypography.heading*` / label styles; tone maps to existing `DSColors` accents/status.

### 2. Implement `DSTree` / Prism Tree (GOLD) — CyberCore first, Observatory reuse

- **What**: expandable hierarchy, node type→icon, `DSOperationalState` badge, secondary meta, selection, optional order chip (genericize `fallbackOrder` → `badge` / `rank`).
- **Why**: unique OR organism; routegraphs, ASW dependency trees, governance fan-in lists.
- **Where**: new organism package under `organisms/tree/`; pair with `DSSplitPane` + `DSDetailInspector`.
- **Do not**: hardcode combo/provider/credential types into ADS — inject type registry.

### 3. Promote generic `DSSectionPanel` (SILVER) — polish layer

- **What**: glass/panel with tone border, optional status chip, actions, body; optional **corner accent** decoration.
- **Why**: bridges atom glass ↔ story panel; matches OR modular dashboards without Recharts.
- **Risk**: low if it wraps `DSGlassPanel` rather than forking.

### 4. Adopt glow budget as design rule (SILVER docs)

- Codify in WP design docs (not necessarily new hex): max 1 hero motion, ≤3 pulses, no per-row loop glow, default panels unlit, selection soft glow only.
- Aligns with existing `DSShadows.glow*` and epic-10 glass performance work.

### 5. DataTable / Inspector polish only (BRONZE)

- Selected-row left energy border; inspector footer action strip; sticky mono header density cues — **only if** gallery audit shows absence.
- Do **not** replace `DSDataTable` with OR’s simpler table.

### 6. Color tokens — explicit no-op (this harvest)

- Keep WP cyan/violet/gold stack.
- Optional future: CyberCore package-level teal skin — **out of scope** for Observatory ADS quick-win.

---

## Skips

| Item | Why skip |
| --- | --- |
| **Full teal rebrand** (`#00FFCC` as global primary) | Conflicts constitution accents; full rebrand, not quick-win |
| **Orbitron / Rajdhani** as system fonts | Density/legibility; WP Inter + mono is correct for Observatory |
| **Scanline overlay** (`.scanlines`) | Decorative noise; a11y/perf; fails glow-budget spirit |
| **Recharts wrappers** / analytics chart pages | Product charts; not ADS core; use existing sparklines/metrics |
| **CSS fake knowledge graph** | WP already has force layout + graph painter |
| **Twilight Council ALLOW/BLOCK mutation UI** | Conflicts Warp Prism **read-only** product contract |
| **Live toggles / grant-lease / revoke** patterns in App.tsx | Mutation / ops-write semantics |
| **Credentials, quota, endpoints, providers as organisms** | OmniProxy product surfaces — compose, don’t elevate |
| **Psionic Matrix hero SVG spectacle** | One-off marketing visual; motion budget violation if copied as pattern |
| **Port React Motion spring drawer as-is** | Reimplement with Flutter animation; keep behavior contract only |
| **Gemini / AI Studio scaffolding** (`README`, API key) | Irrelevant to ADS |
| **God-file `App.tsx` demos** | Harvest layout recipes only |
| **Copy STATE_VOCABULARY wholesale** | WP `DSOperationalState` is authoritative and broader |
| **PrismToolbar as separate organism** | Not implemented in source; PageShell toolbar slot covers need |
| **Mono-cyan info tone** replacing `statusInfo` blue | WP correctly separates energy vs informational blue |
| **Implementing OmniRoute navigation taxonomy in Observatory** | Different IA (Core Pulse, Combo Studio, …) — CyberCore app concern |

---

## Evidence map

| Claim | Evidence | Confidence |
| --- | --- | --- |
| Canonical palette is 6 colors + text | `src/design/tokens.ts` L7–17; `src/index.css` L9–14 | Proven |
| Primary accent is teal `#00FFCC` | same | Proven |
| WP primary cyan is `#00D4FF` with violet/gold | `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` L30–44 | Proven |
| Warning/error bases match WP | OR Tailwind amber/red vs WP L53–59 | Proven (family match) |
| 7 organisms exported | `src/components/organisms/index.ts` | Proven |
| PrismToolbar missing from code | listed in `docs/002-organisms.md`; absent from `organisms/` listing | Proven (negative) |
| Glow budget rules exist | `docs/010-motion-and-glow-budget.md` L7–14 | Proven |
| WP lacks tree organism | `organisms/` listing — no tree package | Proven (negative) |
| WP has shell/sidebar/topbar/inspector/table | `ds_shell.dart`, `ds_sidebar.dart`, `ds_topbar.dart`, `ds_detail_inspector.dart`, `data_table/` | Proven |
| Source is mock-only | mission context + fixture-driven views; no backend services in `src/` | Proven |
| Migration anticipated PageShell/Tree | `docs/016-flutter-warp-prism-migration.md` L5–11 | Proven |
| OR is mono-accent vs WP multi-accent | tokens vs `ds_colors.dart` energy section | Proven |
| Teal skin useful for CyberCore only | product naming Cybernetics Core / OmniProxy in sidebar + docs | Inference |

---

## What was not found

- Formal gold/violet design tokens in OmniRoute visual-reference  
- Production API client / real auth flows in this tree  
- Toast / notification center organism  
- Implemented `PrismToolbar.tsx`  
- Accessibility contrast annotations comparable to WP `textTertiary` comments  
- Responsive shell breakpoints as rigorous as `DSShellResponsive`  
- Virtualized table or log stream organism  
- Drag-and-drop lane board (WP has `DSLaneBoard`)  

---

## Recommended next tasks (candidate → Warp Prism `docs/tasks/`)

| Priority | Candidate task | Outcome |
| --- | --- | --- |
| P0 | **ADS: DSPageShell organism** | Port contract from `PrismPageShell`; Inter/DS tokens; gallery + widget tests |
| P0 | **ADS: DSTree organism** | Generic hierarchical tree + operational status; type icon registry; gallery |
| P1 | **ADS: DSSectionPanel + corner accent** | Tone panel wrapping glass; optional L-bracket decoration |
| P1 | **Design doc: glow/motion screen budget** | Translate `010-motion-and-glow-budget.md` into WP design rules |
| P2 | **DSDataTable selection chrome audit** | Left energy border + wash parity check |
| P2 | **DSDetailInspector footer actions slot audit** | Match drawer actions row if missing |
| — | **No task: DSColors rebrand to #00FFCC** | Explicit non-task from this harvest |

---

## Harvest scores (summary table)

| Score | Item | Local destination | Effort | Risk |
| --- | --- | --- | --- | --- |
| **GOLD** | PageShell organism | `organisms/` + gallery | M | Low |
| **GOLD** | Tree organism | `organisms/tree/` + gallery | M–L | Med (API design) |
| **SILVER** | Section panel + corner accent | `organisms/` or molecule chrome | S–M | Low |
| **SILVER** | Tree+inspector / table+drawer layout recipes | app templates / docs | S | Low |
| **SILVER** | Glow budget policy | `docs/design/` | S | Low |
| **BRONZE** | Table/inspector/sidebar/header polish | existing organisms | S | Low |
| **BRONZE** | Status motion binding table | operational state docs | S | Low |
| **IRON** | Teal global rebrand, Orbitron, scanlines, mutation UIs, Recharts ports, fake graph | — | — | High / out of contract |

---

*End of report. No source files modified outside this report path. No OmniRoute implementation code transplanted.*
