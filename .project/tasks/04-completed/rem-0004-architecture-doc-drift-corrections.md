# rem-0004: Architecture-doc drift corrections

> **Remediation namespace**: `rem-NNNN` (overnight remediation wave 2). Source finding: Inv-6a (`ses_ed3edd6fbffeNKkncheQjsRWK5`) — four documentation-drift findings with operational consequence.
> **Review State**: `Review Approved`
> **Review Trail**: independent `gtr-reviewer-flutter` PASS 95/100 on 2026-10-16; report `.project/reports/reviewers/rem-0004-architecture-doc-drift-review-loop.md`; no mandatory remediation; N1/N3/N4 + host_config doc nit are parent-owned follow-ups.
> **Promotion**: `01-open` → `04-completed` by parent after independent PASS; no product files changed in promotion.
> **Priority**: 🟡 P1 | **Type**: `remediation` | **Origin**: architect investigation
> **Blocks**: N/A | **Depends on**: N/A
> **parallel-safe**: file-level distinct from wave-1 files; **but `layer-contracts.md` §10 was edited by rem-0001 — re-read the file immediately before editing §2 (drift guard)**.
> **Writeset constraint**: docs only. No source code, no tests, no lane moves.

---

## Finding (evidence)

1. **`layer-contracts.md` §2 dependency-direction diagram arrow is inverted for `ui`↔`bindings`.** The diagram (`:31–52`) draws an arrow from `warp_prism_ui` into `warp_prism_bindings`; the §1 matrix (`,:16` "MUST NOT import … bindings") and reality (all 6 pubspecs verified: `ui` has zero `bindings` dep; `bindings:14–19` deps on ui+interaction+runtime) both say the reverse. A reader following the diagram concludes `bindings` cannot depend on `ui` — the opposite of the law.
2. **`package-topology.md:93` over-strict ban contradicts accepted law.** It says `ui` "MUST NOT import interaction"; current law (`layer-contracts.md:16`, `:56–57`) permits interaction as a **dev-only** dependency, and `warp_prism_ui/pubspec.yaml:18–19` declares exactly that (verified dev_dependencies). The doc is stricter than both the law and the code — an implementer reading it would remove a sanctioned arrangement.
3. **`runtime-consumer-audit.md` cites superseded law.** It treats `layer-contracts-v2.md` as governing (`:8`, `:68`, `:103`, `:107–108`) and never cites current `layer-contracts.md`; v2 itself (`:7–8`) declares layer-contracts.md the owner. A reader trusting the audit inherits superseded row semantics.
4. **`cross-consumer-gap-matrix.md` still carries two UNKNOWNs resolved on 2026-10-10**, plus stale crate/adoption rows: `:50` "Tempest … UNKNOWN (import scan denied)", `:149` "Tempest → Warp Prism import check | UNKNOWN", `:148` "Sentry UI/integration surface | unverified", `:51`/`:4` dated 2026-09-27. Resolutions: Tempest `flutter/pubspec.yaml` + `pubspec.lock` + repo-wide grep = **zero** warp_prism matches (parent-verified via rg exit 1); Sentry = **no `pubspec.yaml` anywhere, Rust-only, 3 crates, no FRB, zero warp_prism matches** (parent-verified).
5. **`MISSION.md:43–47` / `:294` deliberately withhold app classification** ("evidence-gated … not asserted in advance") while the January evidence now exists (observatory = 12+ routes, real riverpod/fl_chart/graphview, v1.0.0+1; cybercore = 4 pilot routes, fixture JSON). **Out of scope for this rem task**: MISSION.md is a protected surface (`AGENTS.md` §6) — record the evidence, do not edit. This rem task fixes items 1–4 only.

### Finding 5 — protected-surface evidence record (rem-0004, 2026-10-11; no MISSION.md edit authorized or made)

`MISSION.md` §2 (`:43–47`) and §11.2 (`:294`) withhold Observatory/CyberCore classification by design ("evidence-gated … deliberately not asserted in advance"). For the protected-surface owner to act on, the January evidence recorded here is **in-repo, re-verified by this executor on 2026-10-11** (observation, not inference):

- **Observatory** — `apps/observatory/pubspec.yaml`: `version: 1.0.0+1` (the only non-`0.1.0` in the tree), real dependencies `flutter_riverpod: ^2.5.0`, `graphview: ^1.2.0`, `fl_chart: ^0.68.0`; path dependency on `warp_prism_ui` (`../../packages/warp_prism_ui`) plus `warp_prism_host_exercise` in dev. GoRouter usage observed at machine-searched groups (`lib/app/router.dart` contains 17 GoRoute/GoRouterState matches; additional matches in `app_shell.dart`, `asset_selection_controller.dart`, `governance_overview_page.dart`). This matches the independently-reviewed classification record in `.project/reports/architects/future-capability-program-inventory-2026-10-10.md` §1.2 ("STILL-VALID CONSUMER … 12+ routes").
- **CyberCore** — recorded as fixture/demo in the same report §1.2 (self-described "fixture-backed read-only observatory"; 4 pilot routes; hardcoded JSON fixtures). Not independently re-verified line-by-line by this executor; cited from that reviewed carrier, so treat the 4-route/fixture detail as **carrier-cited**, while the Observatory pubspec/route facts above are **first-hand**.

**Note on the adoption nuance** (worth carrying into any MISSION.md amendment, so the classification is not over-read): that report's §10 amendment F15 records that "genuine product frontend" is true only as *visual composition* — `apps/observatory/pubspec.yaml` declaring no `warp_prism_*` production *consumer* dep is itself a scoped fact, and the in-repo `rg` confirms a `warp_prism_ui` path dependency exists. The zero-external-adoption claim (§0.1) concerns **external** consumers (Warpblade/Tempest/Sentry/Hyperion), not the in-tree labs.

This evidence is filed for the `MISSION.md` owner; **no edit to `MISSION.md` was made by this task**.

## Objective

Correct four drift sites in architecture documentation so a reader deciding from these files decides correctly:

- fix the §2 diagram arrow direction in `layer-contracts.md`;
- align `package-topology.md:93` with the dev-only law;
- repoint `runtime-consumer-audit.md` law citations from v2 to current `layer-contracts.md`;
- update `cross-consumer-gap-matrix.md` resolved-UNKNOWN rows with the 2026-10-10 verified resolutions, marking each with its verification method and date.

## Background Context

- `layer-contracts.md` §10 was edited 2026-10-11 by rem-0001 (16-row status table) — **re-read before editing**; `layer-contracts-v2.md:3–15` self-declares SUPERSEDED/historical-only (correctly, currently).
- All source claims below were parent-verified or investigator-verified with cited lines; see Finding.

## Test Requirements

- `layer-contracts.md` §2 diagram direction now matches its own §1 matrix text AND all 6 pubspecs (ui has no bindings dep; bindings deps on ui).
- `package-topology.md` no longer asserts a blanket interaction ban without the dev-only carve-out.
- Every v2 citation in `runtime-consumer-audit.md` is either repointed to current law or explicitly marked historical.
- `cross-consumer-gap-matrix.md` rows for Tempest imports and Sentry surface state the resolved answer + verification method + date, and no longer read as open UNKNOWNs.

## Exit Conditions

- [ ] Four doc edits confined to the named sections; `MISSION.md` untouched.
- [ ] Each edit preserves the surrounding record (supersession/history text retained, not overwritten).
- [ ] A drift-guard pass: re-read each edited file's diff before handoff; no other section silently changed.
- [ ] No source/test/config file touched (`git status --porcelain` scoped to the 4 docs).
- [ ] Local changelog entry added under `.project/changelog/`.
- [ ] Completion Evidence filled before handoff.

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: `layer-contracts.md` §1 + §2 (post-rem-0001 state), `package-topology.md` §3 around `:93`, `runtime-consumer-audit.md` around `:8/:68/:103/:107`, `cross-consumer-gap-matrix.md` rows `:50/:148/:149` + header `:4`.
- [ ] Edit 1: `layer-contracts.md` §2 diagram arrow direction (bindings→ui), with §1 cross-reference.
- [ ] Edit 2: `package-topology.md:93` dev-only carve-out wording matching `layer-contracts.md:16/:56–57` verbatim.
- [ ] Edit 3: `runtime-consumer-audit.md` — repoint or annotate each v2 citation; add a one-line "law baseline updated 2026-10-11" note.
- [ ] Edit 4: `cross-consumer-gap-matrix.md` — replace resolved-UNKNOWN rows with verified answers + method + date; keep the 2026-09-27 history note.
- [ ] **Simplicity pass**: no editorializing beyond the four findings; no new sections.
- [ ] **Regression verification**: drift-guard diffs + changelog entry.

### Where

| File | Purpose |
|---|---|
| `.project/architecture/layer-contracts.md` (§2 only) | Modify — diagram arrow direction (re-read after rem-0001 edit) |
| `.project/architecture/package-topology.md` (~:93) | Modify — dev-only carve-out |
| `.project/architecture/runtime-consumer-audit.md` (cited lines) | Modify — law citations |
| `.project/architecture/cross-consumer-gap-matrix.md` (rows 50/51/148/149 + header) | Modify — resolved-UNKNOWN updates |
| `MISSION.md:43–47`, `:294` | **READ ONLY — protected surface; evidence recorded in this task, no edit authorized** |
| `.project/changelog/` | Create — entry |

### How

1. Re-read `layer-contracts.md` FIRST (rem-0001 touched it today) — no blind edits.
2. Quote-equal wording: the package-topology carve-out must match current law, not paraphrase it.
3. In the gap matrix, preserve historical rows (supersession law); append resolution notes rather than deleting the audit trail.
4. `MISSION.md` evidence stays in this task file for the protected-surface owner to act on.

### Why

Four architecture files that a reader would use to make dependency or adoption decisions currently point the wrong way (inverted arrow, over-strict ban, superseded citations, stale UNKNOWNs). Wrong-direction reading material is worse than absence: it produces confidently wrong decisions.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not edit `MISSION.md` (protected, no authorization). Do not delete historical rows — annotate them. Do not touch source/config/test files. Re-read `layer-contracts.md` before editing (rem-0001 edited §10 on 2026-10-11).

---

## Validation Commands

```bash
git status --porcelain -- .project/architecture/
git diff --stat -- .project/architecture/
```

Expect exactly 4 architecture-doc paths modified (plus this task file + a new changelog entry). Any source/test path appearing = FAIL.

---

## Completion Evidence

- **Files created/modified**:
  - `.project/architecture/layer-contracts.md` — §2 diagram corrected (`ui ◄──` bracket replaced the inverting `▼`) + §1 cross-reference note appended (Lines 12–74 region; §10 untouched).
  - `.project/architecture/package-topology.md` — §3.2 rule 9 dev-only carve-out added under the original rule text.
  - `.project/architecture/runtime-consumer-audit.md` — 9 v2 citation sites annotated with current owner + "law baseline updated 2026-10-11" note.
  - `.project/architecture/cross-consumer-gap-matrix.md` — §2 Tempest/Sentry rows, §6 two rows, §3 row 28, and header status note; 2026-09-27 date + AMEND history preserved.
  - `.project/tasks/01-open/rem-0004-architecture-doc-drift-corrections.md` — this file (Finding 5 evidence record + this evidence block).
  - `.project/changelog/20261011-154708-rem-0004-architecture-doc-drift-corrections-remediation-executed-flutter-dart-builder.md` — created.
- **Tests or validation commands**:
  - `rg -n "layer-contracts-v2" .project/architecture/runtime-consumer-audit.md` → 11 lines, every one annotated/repointed or explicitly historical. PASS
  - `rg -n "UNKNOWN|unverified" .project/architecture/cross-consumer-gap-matrix.md` → §2/§6/§3-28 all resolved; residual UNKNOWNs are §3 Sentry capability cells + §7 checklist, both explained. PASS
  - Diagram geometry check (python codepoint audit) → bracket column 31 aligned; arrowheads face `ui`/`interaction`; chain arrows uniform. PASS
  - `rg -n "^\| 1[0-6]" .project/architecture/layer-contracts.md` → rem-0001's 16-row §10 table intact. PASS
  - Source verification: all 6 package pubspecs read; `warp_prism_ui` has no `bindings` dep; `bindings` deps on ui+interaction+runtime; `warp_prism_ui/pubspec.yaml:14–19` dev-only `warp_prism_interaction`. PASS
- **Local changelog entry**: `.project/changelog/20261011-154708-rem-0004-architecture-doc-drift-corrections-remediation-executed-flutter-dart-builder.md`
- **Executor**: builder-engineer (`flutter-dart-builder` agent identity; model `omniroute/builder-engineer`)
- **Completion date**: 2026-10-11
- **Known side effect (disclosed, out of writeset)**: the changelog engine's `action=closeout` internally rebuilt root `CHANGELOG.md`, `CHANGELOG-FULL.md`, `.project/changelog/index.md`, and `.project/changelog/views/*.md`. `action=build` was **not** invoked. The engine archived the pre-rebuild root changelog (`.archive/changelog/CHANGELOG-before-rebuild-20261011-154708.md`), so the effect is reversible; flagged for parent review.
- **Contention observed (not created by this task)**: a concurrent worker (rem-0005, `01-open/rem-0005-host-exercise-dead-exports.md`) wrote `packages/warp_prism_host_exercise/lib/src/models/{exercise_trace,theme_matrix,viewport_matrix}.dart` at 15:48–15:50 and reformatted the §2 diagram block's label indent in `layer-contracts.md` at 15:54. All four of my edits were re-verified intact after that writer's pass (grep for each marker string + codepoint audit of the diagram), and the reformat preserved the arrow column and direction. Neither this task nor rem-0005 was instructed to serialize on these files; flagged for the parent to confirm the lane-level contention rule.
- **Verification method limitation (disclosed)**: `git status --porcelain -- <path>` and `git diff --stat -- <path>` (the task's own Validation Commands) were **denied by the permission layer** on this session (`bash` rule: `git status *` / `git diff *` blocked). Writeset verification was therefore performed by mtime/`stat` and `find -newermt` auditing instead, which is a weaker guarantee than the intended git diff. The reviewer should run the original git commands.
- **Independent review**: REQUIRED before promotion — this task was executed, not self-accepted.
- **Lane**: unchanged (`01-open`). No lane move was performed by this executor.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 95/100; all four doc-drift sites verified, writeset held (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-rem-0004-architecture-doc-drift-corrections-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
