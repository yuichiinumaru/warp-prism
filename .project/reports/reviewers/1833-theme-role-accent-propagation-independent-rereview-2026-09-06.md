# Review Report: Task 1833 — Theme-Role and Accent Propagation Remediation Round 2 — 2026-09-06

## Review Lineage

- **Current task**: Task 1833 (`1833-warp-prism-theme-role-accent-propagation.md`); live path: `docs/tasks/01-open/1833-warp-prism-theme-role-accent-propagation.md`
- **Previous reports read**:
  - `docs/reports/review/1833-theme-role-accent-propagation-independent-review-2026-09-04.md` — Review 1, score `48/100`, verdict `FAIL` (findings F1–F5)
- **Related reports considered**:
  - `docs/reports/review/1807-token-override-theme-editor-independent-review-2026-08-23.md` — analyzer-policy and registry-boundary precedent.
  - `docs/architecture/layer-contracts-v2.md` — Check 8 ownership contract now updated by this remediation.
- **Review mode**: `re-review` (delta-aware, Remediation Round 2). Score-only; no lane move performed.
- **Review dispatch**: `REVIEW-1833-R2`.

## Score And Verdict

- **Score**: **50/100** — Serious band (capped by the one open Serious regression below; the numeric cap, not remediation quality, holds the score down — see deduction rationale)
- **Verdict**: **FAIL** → `REJECTED_TO_DOING`
- **Evidence confidence**: **high** (source-verified, re-run-verified, independently sabotage-verified)
- **Lane recommendation**: `return-to-doing` for one narrow builder-owned remediation; task remains in its current lane; **no lane move performed by this reviewer**.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` **F1** — CyberCore production registry mutations removed. `apps/cybercore/lib/main.dart` now contains zero `PrismTokenRegistry` calls; teal installs strictly via `PrismCyberCoreTealSkin.omniRoute().applyToTheme(PrismTheme.dark())` at `main.dart:21-23`. Greps over `apps/cybercore/lib/**` and `apps/observatory/lib/**` for `applySkin|setAccentRecipe|setColor|resetRole|.reset(` return **zero hits**; the only consumer-app mutators are the 4 allowlisted tooling calls in `apps/catalog/lib/main.dart:234-246`.
- `RESOLVED` **F2** — all 20 dynamic-role references in the 7 named widgets migrated to context recipe helpers:
  - `ds_button.dart:122` → `DSTheme.accentOf(context)`
  - `ds_switch.dart:32` → `DSTheme.accentOf(context)`
  - `ds_checkbox.dart:84-85` → `accentOf`/`borderGlowOf` (checked glow `:91`, fill `:99`, indeterminate border `:115`, bar `:122`)
  - `ds_text_field.dart:136-137` → `accentOf`/`focusRingOf` (border `:145`, label `:156`, icon `:165`, glow `:183`, cursor `:242`)
  - `ds_tab_bar.dart:294-295` → `accentOf`/`focusRingOf` (bg `:301`, text `:303`, icon `:304`, border `:306`, badge `:377`, focus indicator `:402,:421`)
  - `ds_sidebar.dart:187` → `accentOf`; `:256` → `focusRingOf`
  - `ds_interactive_surface.dart:135` → `focusRingOf`
  - Grep for `DSColors.accentBlue|DSColors.focusRing|DSCyberCoreTealSkin.maybeOf` across the 7 widget files: **zero hits**.
  - Categorical role preserved: inactive tab badge `DSColors.accentViolet` retained at `ds_tab_bar.dart:378`; `mcp_inspector_page.dart:95` `accentViolet` tool-count insight retained as data role.
- `RESOLVED` **F3** — regression oracle strengthened:
  - New no-registry widget test (`theme_role_accent_propagation_test.dart:133-258`) pumps `DSButton`, `DSSwitch`, `DSCheckbox`, `DSTextField` under `PrismTheme.taldarimRed()` and `PrismTheme.talonPurple()` with **zero registry mutation**, asserting button glow, switch track fill, checkbox glow, and text-field cursor all resolve `0xFFE51A4C` / `0xFF9911E5`.
  - New theme-replacement test (`:260-360`) swaps `ThemeData` in the same subtree (blue → red → purple → teal → blue) via `_ThemeSwapper` with no global state, asserting visible role updates each swap.
  - `applySkin` appears only in the 4 registry-intent token tests and the `ListenableBuilder` tooling-mode test (`:362-431`) — all legitimate registry-scoped proofs.
  - Pre-fix failure evidence is **coherent with the mechanism**: pre-migration `DSButton`/`DSSwitch` used `DSCyberCoreTealSkin.maybeOf(context)?.accent ?? DSColors.accentBlue`; under `taldarimRed()` there is no teal extension, so the fallback hit the untouched registry → Khalai Blue `0xFF2F81FF` instead of `0xFFE51A4C`. Exactly matches the builder's recorded pre-fix failure.
  - Registry discipline: `setUp`/`tearDown` resets at `:30-36`; also verified in `prism_token_registry_test.dart:6-13` and `prism_theme_editor_test.dart:8-13`.
- `RESOLVED` **F4** — Completion Evidence wording now reads "zero errors under the repository non-fatal-info gate" with explicit 212/124 info baselines (`task:181-191`); no "clean analyzer" claim remains.
- `RESOLVED` **F5** — boundary Check 8 hardened (`boundary_test.dart:503-558`): scans `packages/warp_prism_ui/lib`, `apps/cybercore/lib`, `apps/observatory/lib`, `apps/catalog/lib`; app pattern `\b(applySkin|setAccentRecipe|setColor|resetRole|reset)\b`; UI pattern additionally covers `registry.reset` forms; allowlist = `prism_token_registry.dart`, `theme_editor/`, `apps/catalog/lib/main.dart` exactly.

### Regressions

- `REGRESSION` **F6 (new this round)** — CyberCore host shell chrome no longer renders teal; Completion Evidence claim now false. Detailed below. Caused by the F1 fix itself (registry mutation removed without migrating the host-side consumers of the mutated role).

### Persistent Findings

- None. F1–F5 are all closed with proof.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP` — Real-host live composition evidence across Catalog, CyberCore, Observatory remains outstanding. Per dispatch, the parent runs this separately; its absence is **not** the basis of this verdict. What it must still prove for Task 1805 is listed under Criteria Mapping.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Serious | Closed | CyberCore production registry mutations | R1 2026-09-04 | `apps/cybercore/lib/main.dart:6-8,21-23` (clean); greps zero-hit |
| F2 | RESOLVED | Serious | Closed | 20 widget role references bypassed helpers | R1 2026-09-04 | 7 widget files, all migrated; grep zero-hit |
| F3 | RESOLVED | Serious (gap) | Closed | Missing no-registry + theme-replacement oracle | R1 2026-09-04 | `theme_role_accent_propagation_test.dart:133-360` |
| F4 | RESOLVED | Debt | Closed | Analyzer wording | R1 2026-09-04 | `task:181-191` |
| F5 | RESOLVED | Serious | Closed | Check 8 blind to consumer apps | R1 2026-09-04 | `boundary_test.dart:503-558`; sabotage-verified this round |
| **F6** | **REGRESSION** | **Serious** | **Open** | CyberCore shell chrome reverts to Khalai Blue; Completion Evidence affected_consumers claim false | **this review** | `apps/cybercore/lib/app/cybercore_shell.dart:154,228`; `providers_page.dart:99,105,117`; `mcp_servers_page.dart:94,100`; `mcp_inspector_page.dart:83,89`; `live_logs_page.dart:101,107`; vs claim at `task:178` |

### F6 — CyberCore host shell chrome diverges from its installed teal recipe — REGRESSION, Serious, Open

**Mechanism.** Before the F1 fix, `main()` mutated `PrismTokenRegistry`, so `PrismColors.accentBlue` (a registry-backed getter, `ds_colors.dart:34`) resolved teal `#00FFCC` everywhere in CyberCore, including host-authored chrome. F1 correctly removed the mutation — but the host-side chrome that *depended* on the mutated role was never migrated to the theme-context contract:

- `cybercore_shell.dart:154` — `_CyberCoreHeader` logo gradient `[PrismColors.accentBlue, PrismColors.accentBlueMuted]` → **Khalai Blue**, not teal.
- `cybercore_shell.dart:228` — `_CompactShell` `BottomNavigationBar.selectedItemColor: PrismColors.accentBlue` → **Khalai Blue** selected nav in compact mode, while wide-mode sidebar selection resolves **teal** via `DSTheme.accentOf` — the same navigation role renders two different recipes depending on viewport width.
- Feature story panels (`providers_page.dart:99,105,117`, `mcp_servers_page.dart:94,100`, `mcp_inspector_page.dart:83,89`, `live_logs_page.dart:101,107`) pass `accentColor: PrismColors.accentBlue` → **Khalai Blue** panel accents.

**Why this is Serious.** (a) It is a regression introduced by the immediately preceding fix (delta law). (b) The Completion Evidence `affected_consumers` claim — "sidebar, header, bottom nav, and story panels render in unified teal (#00FFCC)" (`task:178`) — is **directly contradicted by current source**; phantom closeout claims block acceptance. (c) The compact bottom-nav divergence is exactly the task's target defect class: equivalent interactive chrome (navigation selection) not using the recipe-driven role, reopening criterion 3/11 at host level for the chrome classes this task governs.

**Required change (small, narrow).** Migrate the 10 host-side reads in `cybercore_shell.dart:154,228` and the 4 feature pages to `PrismTheme.accentOf(context)` / `PrismTheme.accentMutedOf(context)` (theme is already teal via `applyToTheme`), or explicitly re-declare Khalai-Blue shell chrome as the product decision and correct the Completion Evidence — but a mixed teal/blue identity is neither. Then correct `task:178` to describe actual behavior. The Where table already authorizes narrow CyberCore mutation "if evidence proves host-side defect" — it now does.

## Evidence Reviewed

### Commands re-run this review (exact exits)

| Command | Result |
|---|---|
| `flutter test test/theme/theme_role_accent_propagation_test.dart --no-pub` (run 1) | **Exit 0**, `+9: All tests passed!` |
| same (run 2, pollution check) | **Exit 0**, `+9: All tests passed!` |
| `flutter test test/tokens/ test/theme/ test/accessibility/ --no-pub` (run 1) | **Exit 0**, `+202: All tests passed!` |
| same (run 2, pollution check) | **Exit 0**, `+202: All tests passed!` |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **Exit 0**, `15/15 PASS, 0 FAIL, 0 violation(s)` (Check 8 renamed "...and authorized tooling") |
| **Sabotage** (injected `applySkin` into `apps/cybercore/lib/main.dart`, ran harness, removed it) | **Exit 1**, `14/15 PASS, 1 FAIL` — flagged `apps/cybercore/lib/main.dart:8:PrismTokenRegistry.instance.applySkin(...)` at exact file:line; post-removal re-run **Exit 0**, `15/15 PASS` (file byte-identical restored, re-read verified) |
| `dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart` | **Exit 0**, `Public barrel audit lock: PASS (4-export barrel)`, 302 public top-level symbols |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` (package) | **Exit 0**, 212 issues (accepted info baseline, 0 errors/0 warnings under gate) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` (catalog) | **Exit 0**, `No issues found!` |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` (cybercore) | **Exit 0**, `No issues found!` |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` (observatory) | **Exit 0**, 124 issues (accepted info baseline, 0 errors/0 warnings under gate) |
| `flutter build linux --debug` (catalog) | **Exit 0**, `✓ Built build/linux/x64/debug/bundle/warp_prism_catalog` |
| `flutter build linux --debug` (cybercore) | **Exit 0**, `✓ Built build/linux/x64/debug/bundle/warp_prism_cybercore` |
| `flutter test --no-pub` (catalog) | **Exit 0**, `+20: All tests passed!` |
| `flutter test --no-pub` (cybercore) | **Exit 0**, `+20: All tests passed!` |
| `flutter test --no-pub` (observatory) | **Exit 0**, `+816: All tests passed!` |

### Static verifications

- Registry mutator greps (F1): `apps/cybercore/lib/**` → 0 hits; `apps/observatory/lib/**` → 0 hits; `apps/catalog/lib/**` → 4 hits, all in allowlisted `main.dart:234-246`.
- Widget migration grep (F2): `DSColors.accentBlue|DSColors.focusRing|DSCyberCoreTealSkin.maybeOf` across the 7 named widget files → 0 hits.
- Semantic/data freeze (F-confirmation): `ds_colors.dart` categorical/status const hexes unchanged (`accentCyan 0xFF00D4FF`, `accentViolet 0xFF8B5CF6`, `accentGold 0xFFFFB800`, `statusSuccess 0xFF10B981`, `statusError 0xFFEF4444`, ...); freeze assertions pass inside the 202.
- Golden freeze: committed baselines untouched — 0 PNGs under `test/goldens/` (top level) and `test/goldens/goldens/` newer than 2026-09-04 (newest baseline mtime 2026-06-09 / 2026-08-24); only `test/goldens/failures/` runtime artifacts (236 files, expected interim-drift outputs per Task 1800 §7) and `docs/reports/captures/candidates/` host-exercise candidates were regenerated. No `--update-goldens` usage found.
- Registry test discipline: `setUp`/`tearDown` resets verified in all three mutating test files plus `apps/catalog/test/host_exercise/catalog_host.dart:49`.
- Task wording (F4): "zero errors under the repository non-fatal-info gate" present at `task:181-191`; corroborated by my analyze re-runs (212/124 info baselines, 0 errors under gate).

### Commands not run and why

- Real-host live composition (launch + route + viewport + framework-error capture) across the three hosts: dispatched separately by the parent per the review contract; not a basis for this verdict.

## Criteria Mapping (Task 1805 revalidation, package vs host level)

| Criterion | Package level | Host level | Notes |
|---|---|---|---|
| **3** — accent limited to interaction/focus; consistent recipe | **RE-ESTABLISHED** — all 7 named widgets resolve from the theme context; no-registry red/purple + theme-swap tests prove it | **NOT fully re-established** — CyberCore compact bottom-nav selection and shell/panel accents render Khalai Blue against teal widgets (F6) | Real-host run must confirm route-level behavior; F6 will be visible in compact viewport |
| **5** — no rainbow/decorative chrome | **RE-ESTABLISHED** — per-route cyan/violet/gold identities eliminated (R1); no new rainbow introduced; categorical accents preserved intentionally | Re-established at source level; mixed blue/teal (F6) is an identity inconsistency, not rainbow | Live run should confirm |
| **9** — contrast/focus | **RE-ESTABLISHED** — contrast ladder re-proof passes for all 4 recipes (9.38/10.36/12.87/5.64 ≥ 4.5:1); focus rings now resolve per-theme (`focusRingOf`) | Package-level proof sound; live focus rendering pending real-host run | — |
| **11** — same contract across hosts | **RE-ESTABLISHED** — one theme-context contract: Observatory default `PrismTheme.dark()`, Catalog tooling switcher (allowlisted), CyberCore teal via `applyToTheme` only | **Outstanding** — F6 host-shell divergence + real-host live evidence (parent's separate dispatch) must confirm cross-host equivalence | The shared-widget contract is uniform; host-authored chrome is the remaining gap |

## Positive Evidence

- All five Round-1 findings are genuinely closed with mechanically verifiable proof — not prose.
- The sabotage verification this round was performed **by this reviewer independently** (inject → detect at exact `file:line` → exit 1 → restore → exit 0), not by trusting the builder's sabotage claim.
- The new tests are real oracles: they pump actual widgets under red/purple `ThemeData` with the registry provably untouched, and the recorded pre-fix failure (blue instead of red) is exactly what the pre-migration mechanism would produce.
- 202 scoped package tests, 20+20 app tests, 816 Observatory tests, both Linux debug builds, and the 15-check boundary harness all pass on repeated runs.

## Path To 100

1. **Fix F6** (builder, narrow): migrate `apps/cybercore/lib/app/cybercore_shell.dart:154` (header gradient → `PrismTheme.accentOf`/`accentMutedOf`) and `:228` (compact bottom-nav `selectedItemColor` → `PrismTheme.accentOf`), plus the story-panel `accentColor` reads in `providers_page.dart:99`, `mcp_servers_page.dart:94`, `mcp_inspector_page.dart:83`, `live_logs_page.dart:101` — or record an explicit product decision that CyberCore shell chrome is Khalai Blue and correct the evidence accordingly.
2. **Correct the Completion Evidence `affected_consumers` claim** (`task:178`) so it describes the post-F1 reality, whichever way (1) resolves.
3. Re-run: scoped suites ×2, boundary harness, cybercore analyze + test + linux build. A tiny widget test asserting CyberCore-shell chrome resolves teal from the installed theme would lock the regression guard.
4. Real-host live composition across the three hosts (parent-dispatched) with representative viewports (the compact-mode path must be exercised), focus/theme propagation checks, and uncaught-framework-error capture — this closes criteria 3/5/9/11 at host level for Task 1805.
5. Optional polish: refresh stale doc-comments in `ds_switch.dart:8-9` / `ds_checkbox.dart:9-11` ("blue active fill (`DSColors.accentBlue`)") to describe theme-driven resolution; note `ds_sidebar.dart:123` `_DefaultHeader` gradient is registry-backed (correct for Observatory today; latent only if a non-blue-recipe host ever uses the default header).

## Deduction Rationale (score transparency)

Round 1: three Serious findings + one Debt → 48. Round 2 closes all five findings with high-quality, sabotage-proven remediation, but introduces one Serious REGRESSION with a materially false closeout claim (F6). An open Serious acceptance blocker caps the score in the Serious band (≤50) and forces REJECT under the score-verdict coherence law. **50/100** reflects the top of that band: the remediation itself is verified excellent; the cap is owed solely to F6, whose fix is small and precisely enumerated above.

## Task Ledger Patch Suggestion

```markdown
### Latest Review — 2026-09-06 (Review 2, Remediation Round 2)

- **Reviewer profile**: `reviewers`
- **Score**: `50/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review/1833-theme-role-accent-propagation-independent-rereview-2026-09-06.md`
- **Lane outcome**: returned to doing for F6 only

#### Current Open Blockers

- `REGRESSION / Serious`: F6 — CyberCore host shell chrome (header gradient, compact bottom-nav selection, 4 story-panel accents) renders Khalai Blue after F1 removed the registry mutation; Completion Evidence "unified teal" claim now false.

#### Resolved Since Review 1

- F1–F5 all RESOLVED with re-run + independent sabotage proof.

#### Path-to-100 Summary

- Migrate 10 CyberCore host-side reads to PrismTheme helpers (or record explicit blue-shell decision) + correct task:178 + re-run gates; then parent-dispatched real-host exercise for 1805 criteria 3/5/9/11.
```

**No task file, product implementation (beyond the authorized, restored sabotage injection), golden, lane, or VCS surface was modified by this review.**
