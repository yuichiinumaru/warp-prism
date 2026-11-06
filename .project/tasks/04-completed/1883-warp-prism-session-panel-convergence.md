# Task 1883: Session/panel/screen convergence onto existing Prism compositions

Change only convergence composition (no new primitives): converge
SessionList/Detail, EventStreamView, Project/Media panels, Tempest
Library/Models/Providers/Settings/Separate/Create screens, and DropZoneCard
onto existing atoms/molecules/organisms. The work is host-proof, not
construction. Success is the stated observable behavior, verified by hosts.

## Outcome and boundaries

- **Authorized outcome**: every surface above is dispositioned onto existing
  Prism vocabulary with host-exercise proof: SessionList/Detail →
  `DSDataTable`/`VirtualList`/`StatusGrid` (+ F-01-gated rows where
  applicable); EventStreamView → `DSLogViewer`/`Timeline`/`ExecutionConsole`;
  Project/Media panels → `DSPropertyRow`/mono pattern; Tempest screens →
  `DSSearchBar`/`FilterChipGroup`/`AssetCard`/`StatusDot`/`MetricTile`/
  `StateSurface`/`Select`/`Accordion`; DropZoneCard → `DSDropTarget` +
  `AssetCard` extension; verification badges onto `DSStatusDot`/`DSBadge`.
- **Subject**: ADS compositions (REUSE + one `DSDropTarget` extension).
- **Constraints**: no new table/list/grid/board/tree primitive (macro-review
  C9 REUSE holds). Token/alias/barrel writes are owned by Task 1882 — this
  task treats them read-only. Verification/probe metadata stays
  product-local; only the labelled-field chrome converges. Credentials stay
  product-local by law.
- **Non-goals**: no FilterBuilder work (Task 1860); no review-surface work
  (P0 F-04); no provenance views beyond S8 badges; no CC orchestration/
  persistence/daemon changes.

## Context / reliance

- Source evidence: backlog F-16 card (WB-U9/U10 panels; TP-U08 REUSE sweep
  incl. DropZone, SongBlueprint energy bar excluded to P2; CC W3-A/W3-B
  sessions + event stream; Macro C9/REUSE-24 — the weakest-evidence area,
  catalog-read only, so host proof carries the verdict).
- MISSION §3.1 (absorption default; KEEP_LOCAL valid only for non-UI domain
  logic); bridge contract §4 (directional, no flag day).
- Depends read-only on Task 1882 token convergence for theme coherence; does
  not wait on its lane — record the theme baseline actually observed.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/organisms/data_table/` | Compose | SessionList grouped-list target |
| `packages/warp_prism_ui/lib/src/organisms/virtual_scroll/` | Compose | List/grid composition target |
| `packages/warp_prism_ui/lib/src/organisms/log_viewer/` | Compose | EventStreamView REUSE target |
| `packages/warp_prism_ui/lib/src/organisms/command_palette/` | Reference | Execution-console adjacency only |
| `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart` | Extend | DropZoneCard metadata extension (sole extension) |
| `packages/warp_prism_ui/lib/src/molecules/ds_asset_card.dart` | Compose | Card composition target |
| `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` | Compose | Library/search composition |
| `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart` | Compose | Preset/filter composition |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Compose | State chrome composition |
| `docs/bridge/tempest/` | Evidence | Screen debt rows |
| `docs/bridge/command-center/` | Evidence | Session/stream/panel rows |
| `apps/catalog/lib/` | Proof lab | Composition gallery entries |

## Work / responsibility

- [x] Read target organisms + bridge debt rows before composing.
- [x] Disposition every listed surface (REUSE row or the single drop-target
  extension); record per-surface mapping, not a blanket claim.
- [ ] Prove each composition in real-host exercise (Tempest + Command-center
  as applicable): enter route, interact, observe framework/runtime errors,
  viewport/layout, theme/focus propagation.
- [x] Keep token/alias/barrel read-only; report any drift found as findings,
  not drive-by fixes beyond the touched surface.
- [ ] Run full validation; bind per-host evidence below.

## Success and verification

- Per-surface disposition table complete; no new primitive smuggled in
  (new-file scan shows composition/test/gallery only, plus the one
  drop-target extension).
- Real-host exercise evidence per AGENTS.md §7.1 for every affected host:
  interact, no framework errors / ErrorWidget / RenderFlex overflow,
  required ancestor/capability present, theme/focus intact.
- MISSION §6: item 1 (mandate + Macro C9), item 4 (boundary clearance holds
  — no new contract), item 5 (host proof is the verdict), item 7 (review).
  Items 2–3, 6 n/a with reason (REUSE compositions; existing suites cover).
- Format/analyze/boundary clean.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here: per-surface table + per-host exercise logs + review
  verdict. Weak-evidence areas stay explicit until host-proven.

**Parallelizable with**: Task 1882 owns token/alias/barrel — this task is
read-only on those guards, so the pair can run concurrently with that
discipline. Disjoint from Tasks 1858/1860/1861 seams.

## Builder evidence — Task 1883 worker pass (2026-11-01)

### Per-surface disposition (REUSE unless noted)

| Surface | Disposition | Composition target |
|---|---|---|
| SessionList | REUSE, F-01-gated rows | `DSSessionListView` → `DSDataTable` (sort/select/paginate) + `DSSearchBar`/`DSFilterChipGroup` toolbar + `DSStatusCell` + `DSVerificationBadge` + `DSActionGate` action column (allow/constrain/deny; denied rows visible, never dispatch) |
| Session Detail | REUSE | `DSSessionDetailView` → `DSDetailInspector` + `DSPropertyRow` + mono pattern (`DSTextVariant.codeSmall` inspector rows) + `DSVerificationBadge`; `DSStatusDot.operational(animated: false)` |
| EventStreamView | REUSE | `DSEventStreamView` → `DSAccordion` sections: `DSLogViewer` (autoScroll off, deterministic) + `DSTimeline` (filters off) + `DSExecutionConsole` (output panel off, autoScroll off); command palette is adjacency-only reference (no change) |
| Project panels | REUSE | `DSProjectPanelView` → `DSDetailInspector` + `DSPropertyRow` + mono + `DSVerificationBadge`; loading/error via `DSStateSurface` |
| Media panels | REUSE | `DSMediaPanelView` → `DSAssetCard` + `DSPropertyRow` + `DSVerificationBadge`; overlay stays host-triggered (adjacency only) |
| Tempest Library | REUSE | `DSTempestLibraryView` → `DSSearchBar` + `DSFilterChipGroup` + `DSVirtualGrid` (shrinkWrap, never-scroll) of `DSAssetCard` + `DSStateSurface.empty` |
| Tempest Models | REUSE | `DSTempestModelsView` → `DSMetricTile` wrap + `DSProviderHealthMatrix` (fixture cells only) |
| Tempest Providers | REUSE | `DSTempestProvidersView` → `DSProviderHealthMatrix` + `DSStatusGrid` (embed mode) |
| Tempest Settings | REUSE | `DSTempestSettingsView` → `DSSelect` + `DSAccordion` |
| Tempest Separate | REUSE | `DSTempestSeparateView` → `DSFilterChipGroup` + `DSVirtualList` of `DSAssetCard` (self-bounded viewport; no energy bar — P2 exclusion holds) |
| Tempest Create | REUSE, F-01-gated | `DSTempestCreateView` → `DSSearchBar` + `DSSelect` + `DSAccordion` + `DSActionGate` create action |
| DropZoneCard | EXTEND (sole extension) | `DSDropZoneCard` + `DSDropZoneMetadata` in `lib/src/molecules/ds_drop_zone_card.dart` (relocated unchanged out of barrel-exported `ds_drop_target.dart` per fixer turn — Task 1868 precedent; same seam, still out of all barrels/aliases): `DSDropTarget` mechanics unchanged + `DSAssetCard` header + `DSStateSurface.empty` when empty |
| Verification badges | REUSE | `DSVerificationBadge` → `DSStatusDot.operational(animated: false)` + `DSBadge.operational`; fail-closed (`verified: false` → unverified) |
| Command-center sessions + event stream | REUSE | `DSSessionEventSplitHost` → `DSSplitPane` (list beside stream) |

No new table/list/grid/board/tree primitive: new files are
composition/test/gallery only, plus the single drop-target extension.
Verification/probe metadata stays product-local (labels only); credentials
never cross the seam. No FilterBuilder work, no review-surface work, no
provenance views beyond S8 badges, no CC orchestration/persistence/daemon
changes. No token/alias/barrel/registry edits (Task 1882 owns those; observed
read-only, zero drift found). No numeric-atom/input-intent/numeric-proof-lab
edits (Task 1881 owns those; untouched).

### Theme baseline actually observed (Task 1882 read-only)

- `DSTheme.dark()` factory (`packages/warp_prism_ui/lib/src/theme/ds_theme.dart`).
- `PrismTokenRegistry` + 47-row Tempest token ledger (`test/tokens/tempest_token_map_test.dart`: 33 AppColors + 14 M3 roles).
- Catalog theme switcher defaults to Khalai Blue (`apps/catalog/lib/main.dart`).
- No token/alias/barrel/registry file was modified by this pass.

### Writeset (disjoint per wave collision guard)

- NEW `packages/warp_prism_ui/lib/src/organisms/session_panel/ds_session_panel_compositions.dart` (compositions only; EXPERIMENTAL, no barrel export, no Prism alias).
- EDIT `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart` (restored to pristine; extension relocated out per fixer turn).
- CREATE `packages/warp_prism_ui/lib/src/molecules/ds_drop_zone_card.dart` (sole extension relocated unchanged + rationale header; EXPERIMENTAL, no barrel export, no Prism alias).
- EDIT `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` (ADDITIVE: `session-1883-panels` entry).
- EDIT `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (ADDITIVE: import + `buildSession1883PanelsSection` + `session_1883_*` fixtures; no existing section touched).
- EDIT `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` (count 28→29 ×3 + reason/comment updates).
- EDIT `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (ADDITIVE: 3× `session_1883_*` checks + registrations; no existing check touched).
- NEW `packages/warp_prism_ui/test/organisms/session_1883_session_panel_convergence_test.dart` (headless host-proof sweeps: Tempest Library route + CC split host + per-surface interaction; no display pixels claimed).

### Host exercise (AGENTS.md §7.1) — HEADLESS SWEEP ONLY, host proof PENDING

- Written (not executed here — no shell/toolchain in this worker
  environment): Tempest Library route (1400×900 + 500×900 viewport
  variants; search + chip + select interaction; theme propagation check) and
  CC split host (1440×900; session open interaction; theme check), plus
  per-surface interaction tests (sort/paginate/search/filter/gate refusal/
  accordion expand/select/matrix cell/grid card/drop-zone empty).
- Bridge evidence attempted: `docs/bridge/tempest/` and
  `docs/bridge/command-center/` contain only `README.md` (symlink targets
  absent); `references/` carries no `ganthritor-tempest`/command-center
  checkout. Donor shapes are INHERITED REPORT from Task 1882
  (`tempest_studio_convergence_test.dart` header). Revision: UNKNOWN.
- Weak-evidence areas (explicit until host-proven): real-host framework
  errors, `ErrorWidget`/error-boundary activation, `RenderFlex` overflow on
  real viewports, theme/focus propagation on device, screen-reader traversal
  order. Headless sweeps assert `takeException() == null` + `ErrorWidget`
  absence only; pixel overflow is NOT observable in `flutter_tester`.

### Validation — BLOCKED (no toolchain in this worker environment)

- `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`
  (all four task validation commands) could not be executed: this worker
  session has no shell tool (direct shell invocation returns
  `permission.rejected`; Code Mode exposes no command runner). No fresh
  command output exists; exit codes: NOT RUN.
- Mitigation applied instead: every composed API was verified by reading
  its declaration before use (ctor signatures, named/positional params,
  const-ness); new code avoids wall-clock/timers/randomness and animated
  loopers (`animated: false` on all operational dots; no `running`/`exposed`
  fixtures); formatting done by hand to 80-column convention (a
  `dart format` pass over the touched files is still required before
  review).
- Boundary delta: 3 additive `session_1883_*` checks (no-new-primitive,
  no-barrel-export, deterministic) registered; existing checks untouched.
- Determinism: all fixtures use fixed UTC wall labels / pre-formatted
  strings; no `DateTime.now`/`Timer(`/`Random(` in the new seam.
- A11y: explicit `Semantics` labels on every composition root; 48px targets
  inherited from underlying widgets; focus/keyboard inherited (select,
  accordion, chips, table sort all keyboard-operable).

## Parent verification — 2026-11-01 (builders lane; PARTIAL, one residual)

- **Worker**: `gtb-engineer-flutter` (original `sh_197a1213a001LZ7XrMadB7d1Jj`, no toolchain) + fixer (`sh_197ad8a25001pjPecowT72pN7I`, same session `ses_e685edd7effeB9QS2WoqcXVYnI`: 1868-precedent relocation of the drop-zone extension out of the barrel-exported file + `(?<!DS)` regex narrowing) + import fixer (`sh_197b0d8690014y6EgTq60oaJ0w`: 4 missing src imports) + fixer-2 fresh session (`sh_197b2ce09001ZyPUOkNTNb4PR9`: 22/23, documented residual).
- **Parent re-run (fresh, after return, tree quiet, `--no-pub` where flutter runs — pub network stalls in this env)**: `dart format` on 6 touched paths → 0 changed; pure-dart boundary harness → **76/76 PASS** (3 `session_1883_*` + generic alias gate green after relocation); convergence suite → **22/23** (sole residual below); `flutter analyze` on 3 seam files → **No issues found**; no barrel/alias exports; 1881's files untouched.
- **Residual (genuine product-widget bug, out of writeset, NOT weakened)**: `ds_asset_card.dart:56` inner `Column` overflows 3.3px bottom in 212.0×119.8 cells (narrow-viewport Tempest Library test). Minimal repro + assertion in fixer handoff. Follow-up materialized as **Task 1889** (`01-open`, card-internals only, immediately actionable); unblocks this task's final green.
- **Lane**: stays in `02-doing/` with explicit residual + follow-up link. No promotion, no independent-review claim. Task 1883's own seam is fully proven; only the external card bug stands between it and green.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e517e97e8ffeIZ1D2JvbZ6cmNN` (independent — did not build). Report: `.project/reports/reviewers/1883-warp-prism-session-panel-convergence-review-loop.md`.
- **Verdict**: PASS (80/100 diagnostic). No remediation. Promotion task: display-host exercise per AGENTS.md §7.1 (STABLE gate).
- **Accepted evidence**: format 0-changed; analyze clean; session suite 23/23 incl. `narrow viewport keeps Tempest Library clean` green unmodified (explicit independent link to 1889's fix); gallery 22/22; boundary 81/81 (3/3 session checks); 10 setState sites all synchronous; zero controllers/timers; F-01 deny fail-closed verified.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 80/100; session 23/23 incl. narrow-viewport green via 1889, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1883-warp-prism-session-panel-convergence-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
