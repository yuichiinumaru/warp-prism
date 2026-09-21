# ADS Harvest Session Synthesis — 2026-07-10

Inputs:
- OmniRoute-2 `visual-reference` → `ads-harvest-omniroute-visual-reference-2026-07-10.md`
- Judatop / Ahmedm / Villa atomic DS → `ads-harvest-atomic-ds-references-2026-07-10.md`
- `warp-prism/references/` catalog triage → `ads-harvest-references-catalog-triage-2026-07-10.md`

---

## 1. OmniRoute visual-reference (theme + components)

### Theme / colors — quick win?

| Verdict | Detail |
| --- | --- |
| **No mandatory retoken** | WP already has richer multi-accent stack (cyan + violet + gold + status/governance/lanes). |
| OmniRoute palette | Mono teal-cyan `#00FFCC` on greener blacks `#030506` / `#080c0e` / border `#121d22`. |
| WP primary cyan | `#00D4FF` (`DSColors.accentCyan`) — keep for Observatory. |
| Optional later | CyberCore-only **teal skin** ThemeExtension — **not** Observatory default rebrand. |

Quick wins that are **not** color-swap: adopt OmniRoute’s **glow budget / motion restraint** notes if not already policy; L-corner panel chrome as molecule polish.

### Components worth stealing

| Priority | Candidate | Gap vs WP |
| --- | --- | --- |
| **GOLD** | `PrismPageShell` (content page chrome: icon+title+subtitle+actions+toolbar) | `DSShell`/`DSTopbar` are app chrome, not in-content page headers |
| **GOLD** | `PrismTree` hierarchical tree (status/meta/selection) | No tree organism |
| **SILVER** | `PrismPanel` toned section + L-corner accents | Partial glass atom; recipe polish |
| **SILVER** | Tree+inspector / table+drawer **layout recipes** | Composition patterns, not new engines |

### Skip
Teal rebrand, Orbitron/Rajdhani, scanlines, Recharts / CSS fake graphs, ALLOW/BLOCK mutation UIs, product admin pages as organisms.

---

## 2. “Maluco” atomic design systems (judatop / ahmedm / villa)

| Source | Yield |
| --- | --- |
| **Judatop** | Structural: `tokens → foundations → atoms/molecules/organisms/templates`. Steal discipline, not widgets. |
| **Ahmedm** | README architecture: ThemeExtension families, abstract interactive bases, **pages-only** state/routing. |
| **Villa** | External controllers, `isLoading` surfaces — **LICENSE TODO** → pattern only. |

**Product organisms from these?** Essentially **none** for EPIC-15.  
**P0 hygiene** instead: package purity (no routing/prefs in UI package), interactive state matrix, callback contracts on organisms.  
**P1**: optional control ThemeExtensions, loading on actions.  
**Skip**: login forms, Fibonacci spacing, bottom-sheet dropdown ports, Widgetbook until catalog needs it.

Harmonize: keep Prism* barrel + ultradark tokens; use their **layer taxonomy language** in docs/tasks, not their Material skins.

---

## 3. Rest of `references/` catalog (net-new for CyberCore era)

Orthogonal to EPIC-15 Map HUD. Best harvests:

| Theme | Sources | Candidate organisms |
| --- | --- | --- |
| Agent chat / transcript | DeepChat, Open WebUI | `PrismAgentTranscript`, `PrismToolCallCard`, `PrismMessageStatusHistory`, `PrismArtifactWorkbench` |
| Ops / providers | OmniRoute, CyberCore FE | `PrismProviderHealthMatrix`, `PrismTrafficInspector`, `PrismMcpCapabilityInspector`, `PrismTimingWaterfall` |
| Workflow | Sim Studio | `PrismWorkflowCanvasStage` contract (not MapLibre/O-17), `PrismExecutionConsole` |
| Flutter monorepos | ACDG etc. | Low organism yield |

Suggested follow-on epic name: **EPIC-16 — CyberCore Ops + Agent Transcript Organisms** (fixture-first while Go backend lands).

---

## Recommended action order

1. **Continue EPIC-15** (Map HUD organism waves) — do not block on these harvests.  
2. **Optional micro-task (quick win)**: document “no teal rebrand”; optional L-corner `PrismPanel` recipe if trivial.  
3. **Add to backlog (not EPIC-15)**: `PrismPageShell` + `PrismTree` from OmniRoute visual-ref.  
4. **After Wave A–F or parallel with CyberCore**: draft **EPIC-16** shortlist (transcript + health matrix + MCP inspector).  
5. **Judatop/Ahmedm**: feed **API hygiene** into builder checklist / future governance task, not a component sprint.

---

*Sources not modified. Pattern transfer only.*
