# Task 1882: Token and shell convergence sweep onto Prism primitives

Change only convergence wiring (no new primitives): map Tempest's 47-token
layer onto `PrismTokenRegistry`, converge `MainShellLayout` onto
`DSShell`/`DSSidebar`, and verify (never reinvent) the Command-center theme
baseline. Success is the stated observable behavior, verified by host proof.

## Outcome and boundaries

- **Authorized outcome**: Tempest `AppTheme` (290 lines) + `AppColors`
  (47 tokens) converge onto `PrismTokenRegistry` + M3 factory + skins (stem
  colours injected, never owned); `MainShellLayout` (7 branches) converges
  onto `DSShell`/`DSSidebar`/`DSSplitPane`; Command-center theme baseline
  verified as already-consuming (fix drift only, no new primitive).
  Mechanical, widest touch, unblocks every later visual.
- **Subject**: tokens + ADS compositions (REUSE). This is convergence work,
  not construction work.
- **Constraints**: no new token primitive; no forked Prism tokens in any
  consumer; stem/domain colours stay injected. Warpblade is negative evidence
  for layout (single column) — never counted as a layout host. Token/skins
  + `prism_aliases.dart` + barrel are shared-write guards: this task owns
  them for the tranche; sibling tasks treat them read-only.
- **Non-goals**: no shell-router new contract (P0 F-06 owns the slot machine);
  no focus-wiring redesign beyond convergence; no CC coupling-drift fix
  beyond the theme baseline (`integration/theme.dart:5-12` vs direct
  `warp_prism_ui` imports reconciled here only where the sweep touches).

## Context / reliance

- Source evidence: backlog F-15 card (TP U-01 token map + `MainShellLayout`
  `core/layout/main_shell.dart:9-203`; CC theme baseline already consuming;
  Macro C10); bridge surfaces `docs/bridge/tempest/`, `docs/bridge/
  command-center/`; component catalog checked 2026-10-15.
- MISSION §3.1 (convergence destination, no flag day; bridge contract §4:
  non-blocking, no forced adoption); layer-contracts §§1, 10.
- Unknown carried: Tempest revision UNKNOWN (re-verify paths at kickoff;
  record actual `path:line` observed).

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/tokens/` | Extend | Registry + factory + skins convergence home; inspect first |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Compose | Shell convergence target; read before wiring |
| `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` | Compose | Sidebar convergence target |
| `packages/warp_prism_ui/lib/src/organisms/split_pane/` | Compose | Split-pane target for multi-pane hosts |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Extend | Alias completeness held green (owned here) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Checks 6/7/8 (alias, barrel, registry mutator) |
| `docs/bridge/tempest/` | Evidence | Debt/convergence notes for the Tempest leg |
| `docs/bridge/command-center/` | Evidence | Baseline verification for the CC leg |
| `apps/catalog/lib/` | Proof lab | Token/skin gallery coherence |

## Work / responsibility

- [ ] Re-scan Tempest token/shell sources at kickoff; reconcile the 43/50
  vs 39+12 inventory arithmetic (backlog U-ARITH) and record actuals.
- [ ] Map all 47 tokens onto the registry (stems injected); converge shell
  layout; verify CC baseline.
- [ ] Keep barrel + alias checks green through the migration (same-task
  boundary check per layer-contracts §10).
- [ ] Host proof: Tempest studio route (theme/focus/navigation per AGENTS
  §7.1) — interact, no framework errors, theme/focus intact.
- [ ] Run full validation; record host, route, interaction, and verdict.

## Success and verification

- Token map complete and reviewed (47/47 dispositioned: owned vs injected);
  shell converges without forked tokens; `format` + `analyze` + barrel clean.
- Real-host exercise evidence for Tempest studio route (AGENTS.md §7.1
  checklist: launch, enter route, interact, framework-error absence,
  viewport/layout, theme/focus/navigation propagation).
- MISSION §6: item 1 (mandate + Macro C10), items 2–4 (REUSE needs no new
  fake; boundary clearance is the gate), item 5 (host proof), item 7
  (review). Items 2–3, 6 n/a with reason (no new contract, no FRB crossing).
- No flag-day claim: consumer adoption stays on the consumer's schedule.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here: token disposition table, host-exercise log, review
  verdict. CC drift fixed only where touched; remainder stays backlog.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_1978ef07b001pHpnwrbf3MbSuc`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: new `tokens/ds_tempest_token_map.dart` + 2 test files present; tokens barrel +1 export, `prism_aliases.dart` +1 import + tail `PrismTempestTokenMap` typedef (authorized alias per task Where table; alias-completeness green); `boundary_test.dart` additive-only (3 `token_1882_*`); 1881's numeric files untouched; no other barrel changes.
- **Parent re-run (fresh, after return, with 1881 still active in tree)**: `dart format` on 6 touched paths → 0 changed exit 0; token map + studio host suites → **12/12 pass exit 0** (8 + 4); pure-dart boundary harness → **73/73 PASS exit 0** (3 token checks green; only FAIL at worker time was 1881's in-flight gate, since fixed by its owner); `flutter analyze` on 6 seam paths → **No issues found**.
- **Not re-run by parent**: full UI suite (worker ran +2173/−63 with all 63 attributed to pre-existing pixel-golden/env diffs, zero in worker files; re-proof belongs to independent review).
- **Known residuals**: Tempest revision UNKNOWN carried explicitly (sibling reads denied; observed via workspace-local symlinks with path:line recorded); U-ARITH gap unresolvable in-scope (actuals 33 named + 14 mapped = 47 recorded); real-display hosts substituted with headless sweep (limitation recorded). Parallel-sibling interference handled by narrow src-path test imports (precedent now in repo).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e517e97e8ffeIZ1D2JvbZ6cmNN` (independent — did not build). Report: `.project/reports/reviewers/1882-warp-prism-token-shell-convergence-review-loop.md`.
- **Verdict**: PASS (82/100 diagnostic). No remediation. Promotion tasks: pin Tempest revision + real-display host proof (STABLE gates).
- **Accepted evidence**: format 0-changed; analyze clean; token map 8 + studio 4 = 12/12; boundary 81/81 (3/3 token checks + alias gate green); shell/sidebar/split-pane composed read-only, never edited; no new token primitive; `warp_prism_ui.dart` untouched; donor revision UNKNOWN carried explicitly.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

**Parallelizable with**: Task 1883 touches different surfaces (session/panel
compositions) but shares token/barrel guards — coordinate writes: this task
owns token/alias/barrel writes for the tranche; Task 1883 treats them
read-only.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 82/100; token map 8 + studio 4 = 12/12, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1882-warp-prism-token-shell-convergence-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
