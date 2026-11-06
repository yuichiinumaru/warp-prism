# External Intelligence: Command-center Gap Inventory — vs LIVE Prism

> **Phase:** Read-only research verification (Phase 1 posture).
> **Report epoch:** 2026-10-20 (exact requested filename).
> **Command-center source (OBSERVED):** `references/ganthritor-command-center/apps/command_center/`
> **Warp Prism source (OBSERVED):** `packages/warp_prism_ui/`
> **Governing law:** `MISSION.md` §§3.1, §6, §11.4 — **MISSION WINS**.

## Header

- **Mission mandate under test:** Full-coverage central ADS + IDS (`MISSION.md` §3.1, amended 2026-10-19).
- **Governing posture:** Absorption is the default; recurrence never gates; evidence gates §6.2–§6.7 stand unchanged. MISSION WINS over consumer-local dispositions.
- **Context artifacts read (OBSERVED):** `docs/design/component-catalog.md`; `docs/bridge/command-center/prism-gap-components.md`; `docs/bridge/README.md`; `.project/architecture/cross-consumer-gap-matrix.md`.
- **Method constraint honored:** workspace-local paths only; no absolute paths in citations; no VCS operations; no execution; no delegation.

## Executive Summary

- **Verdict:** The gap inventory is **source-supported on both legs**, and the "~0 gaps" framing is **partially falsified** in the app-local direction but **clean** on the consumed-Prism direction.
- **Consumed-Prism leg (the "0 gaps" claim, negative direction):** All 10 consumed `Prism*` identifiers were OBSERVED present in live `packages/warp_prism_ui` (`prism_aliases.dart` typedefs + implementation classes) and OBSERVED actively used by the live command-center. No missing Prism reference behind what command-center already consumes.
- **App-local widget leg (the "15 widgets" claim):** All 15 command-center application widgets were OBSERVED present in the live command-center clone and OBSERVED absent from the live Prism package tree (word-boundary grep over `packages/warp_prism_ui` → 0 hits for all 15 names combined). The 15/15-absent gap list therefore holds against live source.
- **Mission-law overlay:** Under `MISSION.md` §3.1 the "product-local, not a Prism candidate" dispositions are now narrower than they were pre-amendment; the source finding stands, but the governance posture must route through absorption/macro-review/evidence gates rather than a blanket local-forever stance.

## Evidence Map

| Claim | Evidence | Confidence |
|---|---|---|
| Live Prism public alias surface exists and is the sole consumer API | `packages/warp_prism_ui/lib/src/prism_aliases.dart:14-143` (library doc), `:183` `PrismColors`, `:188` `PrismTheme`, `:204` `PrismNerazimTealSkin`, `:226` `PrismSpacing`, `:242` `PrismRadii`, `:266` `PrismStatusDot`, `:296` `PrismStateSurface`, `:299` `PrismStateType`, `:1149-1173` button/chip aliases | OBSERVED |
| Alias/impl class pairs used by command-center resolve in live Prism | `atoms/button/ds_button.dart:22` (`DSButton`), `:11-14` (enums); `atoms/ds_chip.dart:8` (`DSChip`), `:335` (`DSChipSize`); `molecules/ds_state_surface.dart:31` (`DSStateSurface`), `:294` (`DSStateType`); `atoms/ds_status_dot.dart:40` (`DSStatusDot`); `theme/ds_theme.dart:10, :16, :236-287`; `tokens/ds_colors.dart:20-121`; `tokens/ds_spacing.dart:4-75`; `tokens/ds_radii.dart:4-47`; `tokens/ds_nerazim_teal_skin.dart:22-103` | OBSERVED |
| Public barrel re-exports the alias surface | `packages/warp_prism_ui/lib/warp_prism_ui.dart:21` (`export 'src/prism_aliases.dart';`) | OBSERVED |
| Live command-center consumes the live Prism via path dependency | `references/ganthritor-command-center/apps/command_center/pubspec.yaml:20-21` (`warp_prism_ui: path: ../../warp-prism/packages/warp_prism_ui`), resolved via the `warp-prism` symlink inside that clone | OBSERVED |
| All 10 consumed identifiers used by live command-center (OBSERVED usage sites) | `main.dart:186` (`PrismButton.primary`), `control_panel.dart:94,102,128,164,400,414`, `sessions.dart:46,234`, `connection_panel.dart:221,306,386`, `event_stream.dart:144-164`, `theme.dart:30-45` | OBSERVED |
| None of the 15 command-center app widgets exist in live Prism | Word-boundary grep `\b(...)\b` over `packages/warp_prism_ui` → **0 matches** | OBSERVED (negative) |
| All 15 command-center app widgets exist in live command-center clone | `main.dart:35,81,123`; `integration/shell.dart:22`; `integration/loading.dart:17,42,69`; `features/control_panel.dart:25,172,252`; `features/connection_panel.dart:20`; `features/event_stream.dart:16`; `features/provenance_view.dart:55`; `features/sessions.dart:15,240` | OBSERVED |
| Bridge symlink route for command-center | `docs/bridge/command-center -> <consumer-docs>/docs/warp-prism` (symlink, live 2026-10-19; absolute-target form observed during ls) | OBSERVED; target currently unreadable from this workspace (external_directory denial) — resolved via workspace-local clone |

## Per-Widget Verification Table (15 command-center app widgets)

| # | Widget | Live CC source (OBSERVED) | Live Prism presence (OBSERVED) | Consumes Prism (OBSERVED) | Verdict |
|---|---|---|---|---|---|
| 1 | `AbortSection` | `references/ganthritor-command-center/apps/command_center/lib/features/control_panel.dart:172` | ABSENT from live Prism | `PrismButton.primary/.outline`, `PrismStateSurface.disabled` via `_GatedAction` (`control_panel.dart:49-138`) | GAP — product-local (capability-gated abort affordance) |
| 2 | `CommandCenterApp` | `references/ganthritor-command-center/apps/command_center/lib/main.dart:35` | ABSENT from live Prism | Theme composition via `PrismTheme.dark()` + `PrismNerazimTealSkin.nerazimTeal()` (`integration/theme.dart:29-33`) | GAP — app composition root |
| 3 | `CommandCenterShell` | `references/ganthritor-command-center/apps/command_center/lib/integration/shell.dart:22` | ABSENT from live Prism | `PrismChip`, `PrismSpacing`, `PrismColors` (`shell.dart:125-177`) | GAP — app shell composition |
| 4 | `ConnectionPanel` | `references/ganthritor-command-center/apps/command_center/lib/features/connection_panel.dart:20` | ABSENT from live Prism | `PrismStateSurface.error/.empty`, `PrismStatusDot.running/.degraded/.archived/.error/.unverified`, `PrismButton.primary`, `PrismSpacing`, `PrismRadii` (`connection_panel.dart:152-386`) | GAP — product-local (health/attach surface) |
| 5 | `ControlPanel` | `references/ganthritor-command-center/apps/command_center/lib/features/control_panel.dart:25` | ABSENT from live Prism | `PrismStateSurface.disabled/.empty/.error`, `PrismButton.primary/.outline/.danger`, `PrismChip`, `PrismChipSize` (`control_panel.dart:79-414`) | GAP — product-local (control surface) |
| 6 | `DaemonBootstrap` | `references/ganthritor-command-center/apps/command_center/lib/main.dart:81` | ABSENT from live Prism | `LoadingPane` (CC), theme via Prism (`main.dart:89-103`) | GAP — app composition / bootstrap state |
| 7 | `DaemonNotConnected` | `references/ganthritor-command-center/apps/command_center/lib/main.dart:123` | ABSENT from live Prism | `PrismButton.primary`, `PrismSpacing` (`main.dart:143-193`) | GAP — product-local (fail state) |
| 8 | `EventStreamView` | `references/ganthritor-command-center/apps/command_center/lib/features/event_stream.dart:16` | ABSENT from live Prism | `PrismStateSurface.error/.empty`, `PrismSpacing`, `PrismColors.accent*` (`event_stream.dart:27-164`) | GAP — product-local (stream view) |
| 9 | `LoadingPane` | `references/ganthritor-command-center/apps/command_center/lib/integration/loading.dart:42` | ABSENT from live Prism | `PrismSpacing`, `PrismStateSurface` (doc comment `loading.dart:55`) | GAP — generic loading surface (candidate) |
| 10 | `LoadingRow` | `references/ganthritor-command-center/apps/command_center/lib/integration/loading.dart:17` | ABSENT from live Prism | `PrismSpacing` (`loading.dart:29`) | GAP — generic loading surface (candidate) |
| 11 | `PermissionSection` | `references/ganthritor-command-center/apps/command_center/lib/features/control_panel.dart:252` | ABSENT from live Prism | `PrismStateSurface.disabled/.empty`, `PrismButton.primary/.outline`, `PrismChip`, `PrismChipSize` (`control_panel.dart:252-430`) | GAP — product-local (capability-gated permissions) |
| 12 | `ProvenanceView` | `references/ganthritor-command-center/apps/command_center/lib/features/provenance_view.dart:55` | ABSENT from live Prism | `PrismStateSurface.error/.empty`, `PrismSpacing` (`provenance_view.dart:65-94`) | GAP — product-local (causation grouping view) |
| 13 | `SessionDetail` | `references/ganthritor-command-center/apps/command_center/lib/features/sessions.dart:240` | ABSENT from live Prism | `PrismStateSurface.error/.empty`, `PrismChip`, `PrismChipSize`, `PrismSpacing`, `PrismColors` (`sessions.dart:216-314`) | GAP — product-local (detail surface) |
| 14 | `SessionList` | `references/ganthritor-command-center/apps/command_center/lib/features/sessions.dart:15` | ABSENT from live Prism | `PrismChip`, `PrismChipSize`, `PrismStateSurface.error/.empty`, `PrismSpacing`, `PrismColors` (`sessions.dart:15-186`) | GAP — product-local (list surface) |
| 15 | `StateRegion` | `references/ganthritor-command-center/apps/command_center/lib/integration/loading.dart:69` | ABSENT from live Prism | `PrismStateSurface` (doc comment `loading.dart:55`) | GAP — generic state chrome (candidate) |

**Falsification note:** The task's emphasized falsification target was the "~0 gaps" claim. Result:
- **Falsified-as-stated (over-broad reading):** one cannot say "command-center has zero UI gaps vs live Prism" if "gap" means "Prism lacks any surface the command-center needed". The 15 app widgets ARE gaps in the literal class-name-absence sense, but the doc's own §5 interpretation resolves this as product-local-by-design (ADR-001), which is a defensible reading.
- **Supported (precise reading):** there is **no missing Prism component** behind the consumed identifiers; the live command-center's Prism usage resolves entirely.

## Consumed Prism Identifier Resolution (10 identifiers from the gap doc §2.2)

| # | `Prism*` identifier | Live Prism resolution (OBSERVED) | Live CC usage (OBSERVED) | Status |
|---|---|---|---|---|
| 1 | `PrismButton` (+`primary`, `outline`, `danger`, `Size`, `Variant`) | `atoms/button/ds_button.dart:22`, `:49`, `:77`, `:11-14`; alias `prism_aliases.dart:1149-1155` | `main.dart:186`; `control_panel.dart:94,102,128,400,414`; `connection_panel.dart:386` | RESOLVES |
| 2 | `PrismChip` (+`ChipSize`) | `atoms/ds_chip.dart:8`, `:335`; alias `prism_aliases.dart:1170-1173` | `control_panel.dart:164`; `sessions.dart:46,234`; `shell.dart:135` | RESOLVES |
| 3 | `PrismColors` | `tokens/ds_colors.dart:20-121`; alias `prism_aliases.dart:183`; registry `tokens/prism_token_registry.dart:215-230` | `control_panel.dart:345-348`; `sessions.dart:135-174`; `connection_panel.dart:261-269`; `event_stream.dart:144-164` | RESOLVES |
| 4 | `PrismTheme` | `theme/ds_theme.dart:10, :16, :236-287`; alias `prism_aliases.dart:188` | `integration/theme.dart:31, :36-45` | RESOLVES |
| 5 | `PrismNerazimTealSkin` | `tokens/ds_nerazim_teal_skin.dart:22, :42, :103`; alias `prism_aliases.dart:204` | `integration/theme.dart:30` | RESOLVES |
| 6 | `PrismRadii` | `tokens/ds_radii.dart:4-47`; alias `prism_aliases.dart:242` | `control_panel.dart:346`; `connection_panel.dart:263,368` | RESOLVES |
| 7 | `PrismSpacing` | `tokens/ds_spacing.dart:4-75`; alias `prism_aliases.dart:226` | `main.dart:148-186`; `control_panel.dart:34-412`; `sessions.dart:29-314` | RESOLVES |
| 8 | `PrismStateSurface` (+`StateType`) | `molecules/ds_state_surface.dart:31, :70, :294`; alias `prism_aliases.dart:296-299` | `control_panel.dart:79,148,281,289,367`; `sessions.dart:65,75,249,258,267`; `event_stream.dart:49,57`; `provenance_view.dart:75,83`; `connection_panel.dart:152,162,206,209` | RESOLVES |
| 9 | `PrismStatusDot` | `atoms/ds_status_dot.dart:40`; alias `prism_aliases.dart:266` | `connection_panel.dart:221,306,308,310,312,314,316` | RESOLVES |
| 10 | `PrismOperationalState` family | `tokens/ds_operational_state.dart:18`; alias `prism_aliases.dart:153-172`; extension `prism_aliases.dart:163-173` | Not directly used by command-center in the read set | RESOLVES (declared, indirect use) |

**Consumed-side conclusion (OBSERVED):** 10/10 consumed identifiers resolve. The gap doc's line-52 claim ("All consumed Prism identifiers resolve against the donor ADS surface (no missing Prism reference)") is **CONFIRMED** against live source.

## Candidate List (harvest scoring — MISSION.md §5 loop)

| Score | Candidate | Local destination | Effort | Risk | Basis (OBSERVED) |
|---|---|---|---|---|---|
| GOLD | Generic loading/state chrome consolidation (`LoadingPane`/`LoadingRow`/`StateRegion` + `PrismStateSurface` loading/error/empty) | `packages/warp_prism_ui` molecule | low | low | CC self-declared non-animated loading rationale (`integration/loading.dart:3-11`); live `PrismStateSurface` already models empty/loading/error (`ds_state_surface.dart:5-30`) |
| SILVER | Session list/detail genericization vs existing `PrismTaskCard` / `PrismTimeline` / `PrismDataTable` organisms | `packages/warp_prism_ui` organisms | medium | medium | Live overlap: Prism already owns task/timeline/data-table organisms (`prism_aliases.dart:302,335,1031`) that CC does not use |
| SILVER | Capability-gated action seam (`AbortSection`, `_GatedAction`, `_DisabledButton`) → IDS/capability semantics | `packages/warp_prism_interaction` or runtime contract | medium | high | CC pattern of null-callback-disabled + `CapabilityState` gating is OBSERVED; mission requires semantics not presentation in IDS |
| BRONZE | Event-stream / log / timeline generic view alignment with `PrismLogViewer` / `PrismTimeline` / `PrismExecutionConsole` | `packages/warp_prism_ui` organisms | medium | medium | OBSERVED overlap in live Prism; CC built a bespoke stream view |
| IRON | Command-center app-shell layout (`CommandCenterShell` multi-pane/tab) | `packages/warp_prism_ui` organisms | high | high | `DSShell`, `DSSplitPane`, `DSTabBar` already exist (OBSERVED in aliases `:1064-1112`); CC composition is product-specific |

No candidate was promoted; all remain pre-implementation per `MISSION.md` §6.

## What Was Not Found (negative evidence)

- No `TODO`/`FIXME`/`HACK` markers were read in the CC UI source set during this pass (scope limited to the 15 widgets' files) — **not exhaustively swept**, so this is partial.
- No `Prism*` identifier used by the live command-center failed to resolve in the live alias/impl surface during the read set — i.e., no "missing Prism reference" was found in the inspected files.

## Unknowns and Blockers

1. **Revision state UNKNOWN** — no VCS operations permitted/allowed in this pass; no SHA/branch/dirty-state claim made.
2. **Live count re-validation UNKNOWN** — doc claims (296 identifiers, 197 widget classes) were generated 2026-10-19; this pass OBSERVED 296 alias/extension declaration lines and did not re-run an exhaustive widget-class count.
3. **Bridge route partially blocked** — `docs/bridge/command-center` symlink resolves to an absolute external path that is currently unreadable from this workspace (`external_directory` denial); the spot-check was completed via the workspace-local clone `references/ganthritor-command-center/`, so the task's spot-check condition ("if link exists else BLOCKED") resolved to **EXISTS → not blocked**, with the external read denied noted.
4. **Coupling-rule drift (OBSERVED)** — `integration/theme.dart:5-12` states features/ must not import `warp_prism_ui` directly, yet several `features/*.dart` files do import it directly (e.g. `control_panel.dart:16`, `event_stream.dart:10`, `sessions.dart:7`, `provenance_view.dart:10`, `connection_panel.dart:10`). Product-side inconsistency; not a Prism gap.
5. **Runtime behaviour UNKNOWN** — no execution performed (per task constraint); all findings are static reads.

## Recommended Next Tasks

1. Close the coupling-rule drift in `apps/command_center` (single seam via `integration/`).
2. Run the catalog diff called for in `docs/design/component-catalog.md` §"Canonical sources and maintenance".
3. Re-run the exhaustive live counts (296 identifiers / 197 widget classes) at the current revision.
4. Route the SILVER candidates through the `wp-component-absorption` workflow under mission authority.

## Compact Packet

- **Mission:** MISSION.md §3.1 — central ADS+IDS, absorption default, recurrence never gates, evidence gates stand. **MISSION WINS.**
- **Gap inventory vs LIVE Prism:** 10/10 consumed identifiers RESOLVE (clean); 15/15 app widgets ABSENT (gap-by-design).
- **Falsification result:** The "~0 gaps / all consumed resolve" claim is **CONFIRMED** for the consumed leg and **SUPPORTED** for the app-local leg; a literal "zero UI gap" reading is falsified only by broadening "gap" beyond consumed-identifier resolution.
- **Source of truth:** live `packages/warp_prism_ui` + live `references/ganthritor-command-center/apps/command_center`.
- **Blockers:** revision state UNKNOWN; external bridge symlink target unreadable from workspace.
