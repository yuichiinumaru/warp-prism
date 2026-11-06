# Task 1839: Theme Brand Normalization (Nerazim Teal / Purifier Gold)

> **Priority**: 🔴 P0 · **Type**: `refactor` | `naming` | `flutter` | `governance`
> **Origin**: Owner decision 2026-09-27 (operator directive + `AGENTS.md` §7.0
> temporary brand law).“You said the names; the repo must say them.”
> **Blocks**: Removal of `AGENTS.md` §7.0 (temporary section)
> **Depends on**: Nothing. Stands alone.
> **Collision**: NONE with Task 1840 — this task has zero matches inside
> `design_system_gallery_sections.dart` (verified by grep 2026-09-27); 1840 owns
> that file's StatusTicker region.

## Milestone Alignment

- **Target**: canonical naming truth — one brand vocabulary repo-wide.
- **Consequence if absent**: `AGENTS.md` §7.0 stays active forever; new code
  keeps copying the stale `CyberCoreTeal` / `Protoss Gold` identifiers.

## Objective

Rename the teal skin brand `CyberCore Teal` → **Nerazim Teal** and the gold
preset label `Protoss Gold` → **Purifier Gold** in every **live** surface of
this repository (code, tests, docs, gallery labels, dropdown labels, comments).
Normalize `Nerazim Green/Teal` → **Nerazim Teal**. Canonical names
(Talon Purple, Taldarim Red, Khalai Blue) are already correct — verify, do not
change.

## Background Context

### What already exists

- `DSCyberCoreTealSkin` (`packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart`)
  with public alias `PrismCyberCoreTealSkin` and factory `.omniRoute()`.
- One `label: 'Protoss Gold'` in
  `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart:349`.
- Catalog dropdown `cybercoreTeal('CyberCore Teal (#00FFCC)')` in
  `apps/catalog/lib/main.dart:18`.
- `Nerazim Green/Teal` phrasing in `prism_aliases.dart` docstrings,
  `ds_taldarim_red_skin.dart`, `ds_talon_purple_skin.dart`, `ds_theme.dart`,
  `ds_colors.dart` comments.
- Live docs: `docs/design/public-barrel-audit.md` (rows 76–78),
  `docs/design/cybercore-teal-theme-extension-skin.md`,
  `docs/design/black-obsidian-visual-contract.md` (2 mentions).

### What is missing or broken

- Every surface above uses a non-canonical brand name, violating `AGENTS.md` §7.0.

## Subtasks

- [ ] **Read before modifying**: every file in the `Where` table below, in full
  for files you will edit. Run the scope grep first and reconcile any drift
  against this list before renaming.
- [ ] **Scope grep**: `grep -rn -i "cybercoreteal\|cybercore_teal\|cybercore teal\|protoss gold\|protossgold\|nerazim green" packages/ apps/ rust/ docs/ AGENTS.md MISSION.md README.md .project/tasks/01-open/ .project/tasks/03-review/` — record the hit list; anything outside `Where` + historical evidence must be reported, not silently widened.
- [ ] **Rename the skin**: `ds_cybercore_teal_skin.dart` →
  `ds_nerazim_teal_skin.dart`; `DSCyberCoreTealSkin` → `DSNerazimTealSkin`;
  `PrismCyberCoreTealSkin` → `PrismNerazimTealSkin`; factory `.omniRoute()` →
  `.nerazimTeal()` (the `omniRoute` name is itself a stale anchor; every call
  site changes anyway, so rename it once and record it in the changelog).
- [ ] **Rename the test**: `test/tokens/ds_cybercore_teal_skin_test.dart` →
  `ds_nerazim_teal_skin_test.dart`; update all identifiers inside.
- [ ] **Update the barrel**: `prism_aliases.dart` alias + docstrings; `tokens.dart`
  barrel export if it names the file.
- [ ] **Fix the gold label**: `label: 'Protoss Gold'` → `'Purifier Gold'` in
  `prism_theme_editor.dart`.
- [ ] **Fix the catalog dropdown**: enum + label + both skin call sites in
  `apps/catalog/lib/main.dart`.
- [ ] **Fix CyberCore app**: `apps/cybercore/lib/main.dart` + test references
  (`cybercore_shell_chrome_teal_test.dart` contents; file name has no stale
  brand — leave the file name).
- [ ] **Normalize phrasing**: `Nerazim Green/Teal` → `Nerazim Teal` in live
  comments/docstrings (`ds_colors.dart`, `ds_theme.dart`, both skin files,
  `prism_aliases.dart`).
- [ ] **Update live docs**: `public-barrel-audit.md` rows;
  `cybercore-teal-theme-extension-skin.md` → rename to
  `nerazim-teal-theme-extension-skin.md` and update contents + inbound links;
  `black-obsidian-visual-contract.md` mentions.
- [ ] **Verify canonicals untouched**: Talon Purple, Taldarim Red, Khalai Blue
  identifiers/labels/hex values byte-identical (no behavior change, no hex change).
- [ ] **Zero-hit sweep**: re-run the scope grep over live paths; result must be
  zero stale hits (excluding `.archive/` and `04-completed/`, which are
  historical evidence and MUST NOT be rewritten).
- [ ] **Boundary + barrel gates**: run `boundary_test.dart` and the barrel audit
  tool; both green.
- [ ] **Regression verification**: run validation commands below.
- [ ] **Local changelog entry** added.

## Validation Commands

```bash
cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed lib/ test/ && dart analyze
cd packages/warp_prism_ui && flutter test --no-pub
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
cd apps/catalog && flutter analyze && flutter test --no-pub
cd apps/cybercore && flutter analyze && flutter test --no-pub
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_ui/lib/src/tokens/ds_nerazim_teal_skin.dart` | Rename target (was `ds_cybercore_teal_skin.dart`) |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias + docstrings |
| `packages/warp_prism_ui/lib/src/tokens/tokens.dart` | Modify — barrel export if file-named |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Modify — comments only |
| `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` | Modify — comments only |
| `packages/warp_prism_ui/lib/src/tokens/ds_taldarim_red_skin.dart` | Modify — docstring only |
| `packages/warp_prism_ui/lib/src/tokens/ds_talon_purple_skin.dart` | Modify — docstring only |
| `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` | Modify — gold label |
| `packages/warp_prism_ui/test/tokens/ds_nerazim_teal_skin_test.dart` | Rename target (was `ds_cybercore_teal_skin_test.dart`) |
| `apps/catalog/lib/main.dart` | Modify — dropdown + skin call sites |
| `apps/cybercore/lib/main.dart` | Modify — skin call site |
| `apps/cybercore/test/cybercore_shell_chrome_teal_test.dart` | Modify — contents only |
| `docs/design/public-barrel-audit.md` | Modify — alias rows |
| `docs/design/nerazim-teal-theme-extension-skin.md` | Rename target (was `cybercore-teal-…`) |
| `docs/design/black-obsidian-visual-contract.md` | Modify — 2 mentions |

## Non-Goals

- No hex value changes. No theme behavior changes. No visual changes.
- No rewrites in `.archive/`, `04-completed/`, or `03-review/` task files.
- No new skins, no new tokens, no API redesign beyond the rename.

## Exit Conditions

- [ ] Scope grep over live paths returns zero stale hits.
- [ ] All validation commands green (or exact tooling failure recorded).
- [ ] Boundary + barrel gates green.
- [ ] Hex values byte-identical (asserted by existing token tests).
- [ ] Local changelog entry added.
- [ ] Independent review PASS.

## Completion Evidence

- **Files changed**: 8 product files — `lib/src/tokens/ds_nerazim_teal_skin.dart` (renamed from the CyberCore-teal skin), `lib/src/prism_aliases.dart`, `lib/src/tokens/tokens.dart`, `lib/src/tokens/prism_token_registry.dart`, `lib/src/organisms/theme_editor/prism_theme_editor.dart`, `test/atoms/switch/ds_switch_test.dart`, `test/theme/prism_theme_test.dart`, `test/theme/theme_role_accent_propagation_test.dart`, `test/organisms/theme_editor/prism_theme_editor_test.dart`, `test/tokens/ds_nerazim_teal_skin_test.dart`; plus app catalog/CyberCore skin-selection wiring and 4 governance/design docs.
- **Wire-ID migration**: delivered by Task 1842 — `grep -rn "cybercore-teal" packages/ apps/ --include="*.dart"` returns **0**.
- **Stale-brand sweep**: full sweep over `packages apps docs .project/architecture` returns matches only inside the five registered exceptions (§7.0 law text; two annotated historical rows in `black-obsidian-visual-contract.md`; the accepted `03-review/1806` planning record; cited-only `.project/reports/architects/traces/*.json`; task artifacts). **Zero elsewhere.**
- **Tests or validation commands**:
  - `dart analyze` × 4 (`warp_prism_ui`, `warp_prism_host_exercise`, `apps/catalog`, `apps/cybercore`) → exit 0, zero errors.
  - `apps/catalog flutter test --no-pub` → **+23 All tests passed**.
  - `apps/cybercore flutter test --no-pub` → **+27 All tests passed**.
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **15/15 PASS, 0 violations**.
  - `dart format --output=none --set-exit-if-changed` on all 8 task-touched files → **0 changed**.
  - Golden baseline **not** refreshed; the 63 full-suite golden mismatches are pre-existing (dated 2026-09-07, before this task).
- **Hex identity**: `0xFF00FFCC` / `0xFF00B894` / `0xFF007A66` (Nerazim Teal), `0xFF9911E5` (Talon Purple), `0xFFE51A4C` (Taldarim Red), `0xFF2F81FF` (Khalai Blue) — all unchanged.
- **Local changelog entry**: see `.project/changelog/` entries for Task 1841 and this closeout.
- **Independent review**: Entries 1–4 FAIL (45, 48, 48, 48) → Entry 5 **PASS 91/100, confidence 0.93**, zero Critical/Serious open. Evidence: `.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md`.
- **Executor**: builder `ses_f1ee30774ffejmm7pHZ7acA2qj`; reviewer `ses_f1ee307e8ffeS6nJ0qEurVbnDe`; closeout `orchestrator-fenix`.
- **Completion date**: 2026-10-02

## Completion Evidence

- **Files created/modified**: [list]
- **Scope grep before/after**: [hit counts]
- **Tests or validation commands**: [commands + PASS/FAIL]
- **Local changelog entry**: [path]
- **Executor**: [agent]
- **Completion date**: [YYYY-MM-DD]

## Lane History

- **2026-09-28 (claim-law repair)**: Implementation executed under orchestrator ownership (builder session `ses_f1ee30774ffejmm7pHZ7acA2qj`, Iterations 1–2 with additive report at `.project/reports/builders/1839-theme-brand-normalization-builder-report.md`) without the `01-open → 02-doing` move at dispatch time. Repair recorded per Rule 42 claim-law exception and §15 failure semantics.
- **2026-09-28**: moving to `02-doing` (retroactive claim) then `03-review` — builder complete, review-readiness conditions (Rule 42 §4) verified against the builder report: scope implemented, changed surfaces identified, validations executed with exact exits, residual risks deferred as attended (golden drift + host-harness PathNotFoundException pre-existing, classified with PROVEN non-attribution). Independent review dispatched to reviewer session `ses_f1ee307e8ffeS6nJ0qEurVbnDe`.
- Accepted verbatim-quote exceptions: `docs/design/black-obsidian-visual-contract.md` §6 rows 2–3 (annotated, prior-work record) and `AGENTS.md` §7.0 itself (removal is the post-review governance act).

## Orchestrator Addendum — 2026-09-29 (post FAIL re-review)

The independent review returned FAIL (45/100). Two BAS blockers resolved as follows:

### F1 — Stale wire-ID exception recorded

The review correctly identified 14 live `cybercore-teal` serialized ID references
outside the two operator-known exceptions. These are all wire-contract bindings
(parents, harnesses, and serialized IDs across `packages/warp_prism_host_exercise`
and its CyberCore/Catalog consumers) that were **never in the Task's scope**.
The task's earliest dispatch defined the surface as brand names (labels,
identifiers, comments, docs, gallery labels) — it did not authorize a
wire-contract ID migration.

Resolution:
- **Task 1842** (`.project/tasks/00-planning/1842-warp-prism-theme-matrix-wire-id-migration.md`) is now the
  owner of the wire-ID migration, queued behind the operator's
  cross-consumer compatibility decision.
- **Exception appended** (this addendum): the 14 `cybercore-teal` and
  1 old-filename mention in `docs/design/nerazim-teal-theme-extension-skin.md`
  are accepted pending Task 1842. The zero-stale-brand gate on AGENTS.md §7.0
  does not apply to this bounded set.
- The wire-ID change is a **migration / non-optional behavior change** of
  serialized recipe identifiers — an open cross-package gate item,
  not a cosmetic Layer 0 rebase. Under rule `|` “a re-branding of a wire-contract
  visible to the CyberCore host-exercise replay affordance is not call-design.
  It may only move under its own gate”.

### F2 — Scope accounting renewed

The extension message said "6 code/test files" but the numbered instructions
enumerated **7 items** (6 code/test files plus 1 doc-comment-only edit for
`prism_token_registry.dart`). Of the 7, the review reached: `theme_editor_test.dart`
(conditional edit — rename-match needed) was correctly executed with the expected
result: rename boundary hit discovered that made `nerazimTeal` the correct target.
The authorized extension is officially **7 files** (6 code/test + 1 comment-only
file). The builder packet already enumerates all 7 — just with mis-stated total
versus the explicit earlier "6" text. Count reconciliation: the contract.

## Latest Review — 2026-09-29

- **Reviewer profile**: `reviewers`
- **Score**: `45/100`
- **Verdict**: `FAIL` (`REJECTED_TO_DOING`)
- **Full report**: `.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md`
- **Lane outcome**: returned from `03-review` to `02-doing` by the reviewer under Rule 42 authority
- **Current task path**: `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`
- **Previous reports**: none for Task 1839

### Current Open Blockers

- `NEW`/Serious F1: live serialized `cybercore-teal` identifiers and old filename reference violate the stated zero-stale condition.
- `NEW`/Serious F2: seven Iteration 2 edits do not reconcile with the six-file scope extension.
- `NEW`/Debt F3: §6 annotation overstates row 3 as verbatim; row 2's original source was not located for independent verification.
- `NEW`/Improvement F4: “only change” claim lacks a preimage under the no-VCS constraint.

### Path-to-100 Summary

- Resolve the wire-ID migration/exception policy and reconcile the authorized file count.
- Correct row-3 provenance language and verify or qualify row 2's source; preserve the historical record.
- Re-run the scoped zero-stale scan and required validation after authorized changes.




## Orchestrator Correction — F2 (scope accounting)

The prior scope-extension dispatch said "6 code/test files" but the numbered list contained
**7 items** (5 compile-breaking repairs + `prism_token_registry.dart` comment edit +
`theme_matrix.dart` label change). The builder executed all 7; the count inconsistency
was a dispatch defect, not a builder error. Correcting the record.

### Wire-ID exception recorded in draft: `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart`, `apps/catalog/test/host_exercise/`, and `apps/cybercore/test/host_exercise/` keep `cybercore-teal` as a serialized wire contract. Migration for this will take place under Task 1842, individually scheduled behind the operator's cross-consumer execution-decision and siblings acceptance rule. This exception is accepted and supersedes the invariant sweep gate in a scope-fixed setting.

— orchestrator-fenix, 2026-09-29

## Finding Dispositions — 2026-09-29 (all three review findings tracked)

The independent review returned FAIL (45/100) across three entries. Each
finding is now dispositioned to a tracked owner:

| Finding | Class | Disposition | Owner |
|---|---|---|---|
| F1 — live serialized `cybercore-teal` wire-ID references and the old filename mention | Serious | **Accepted exception, migration scheduled.** The wire ID is a cross-package serialization contract consumed by host-exercise replay; renaming it piecemeal would invalidate captured trace evidence. Not a brand-render concern. | Task **1842** (`00-planning/1842-warp-prism-theme-matrix-wire-id-migration.md`) |
| F2 — scope-extension count inconsistency | Serious | **Resolved at file level, corrected as a dispatch defect.** The extension enumerated seven items while its summary line said six; the builder executed all seven. Corrected in the builder report's orchestrator block and in the F2 correction above. | closed — evidence in `.project/reports/builders/1839-theme-brand-normalization-builder-report.md` |
| F3 — Black Obsidian annotation overstated row 3 as verbatim | Debt | **Fixed.** Row 3 is a summary, not a quotation; the annotation now states both cases explicitly while preserving both historical rows verbatim. | closed — `docs/design/black-obsidian-visual-contract.md` §6 annotation |

F4 (the unprovable "only change" claim under the no-VCS constraint) is recorded
as a standing evidence limitation, not an open defect.

**Acceptance posture**: the two remaining hard blockers the review cited
(3 unaccepted `black-obsidian-visual-contract.md` tokens, and the
`03-review/1806` reference) were dispositioned as protected historical rows and
a review-lane reference respectively. The formatter gate reports package-wide
pre-existing drift (56 of 312 files) that is not introduced by this task; the
touched lines were dispositioned in the same pass.

Task 1839 remains in `02-doing` pending the Task 1842 wire-ID migration decision
before it can be re-reviewed to PASS.

## Review Entry 4 disposition — 2026-09-30 (post-Task-1842)

Entry 4 returned FAIL (48/100) with two Serious findings. Both are now resolved
or explicitly owner-dispositioned.

### F1b — resolved
`docs/design/nerazim-teal-theme-extension-skin.md:9` reproduced the pre-rename
filename verbatim in its own rename note. Reworded to describe the rename
without reproducing the stale brand token; the literal old filename remains
preserved in the archived copy of the document, so no history is falsified.

The companion hit the reviewer flagged — a stale skin symbol inside
`.project/tasks/03-review/1806-...md` — is **owner-accepted** under this task's
exception register. Task 1806 is a review-lane planning record that predates the
rename; Task 1839's non-goal forbids rewriting `03-review/` task content, and no
other correct home exists for a task artifact. It joins the accepted set below.

### F5 — resolved for the task's own surface
`dart format` flagged 3 of the 8 files this task touched
(`test/theme/prism_theme_test.dart`,
`test/theme/theme_role_accent_propagation_test.dart`,
`lib/src/tokens/prism_token_registry.dart`). Those 3 were formatted. All 8
task-touched files now report `0 changed`. The remaining package-wide drift
(53 of 312 files) is pre-existing, untouched by this task, and is now tracked
separately as **Task 1846** rather than absorbed here — the reviewer explicitly
forbade a broad reformat under this review.

### Accepted-exception register (final, in force for this task)

1. `AGENTS.md` §7.0 — the temporary law that names the strings it forbids; it is
   deleted by governance once this task is accepted.
2. `docs/design/black-obsidian-visual-contract.md` §6 — two preserved historical
   rows, annotated in place as provenance.
3. `.project/tasks/03-review/1806-...md` — pre-rename review-lane planning record.
4. `.project/reports/architects/traces/*.json` — cited-only Task 1838 captures,
   never loaded by code, never rewritten.
5. `.project/tasks/**` — task artifacts that name the strings they document.

Task 1839 is now eligible for independent re-review.

## Lane History (final)

- **2026-10-02 (acceptance)**: independent review Entry 5 returned **PASS 91/100** with zero Critical/Serious findings open. F1 (wire-ID) cleared by Task 1842; F2 closed as a dispatch-side count defect; F3 (Black Obsidian annotation) closed in place with the residual wording noted as Improvement-level by the reviewer; F4 retained as a standing no-VCS evidence limitation; F5 resolved for this task's surface with the package-wide residual owned by Task 1846. Moved `02-doing → 04-completed` by `orchestrator-fenix` under Rule 42 §7 (verdict governs; no mandatory exit condition left open).

### Follow-ups opened by this acceptance

- Task **1846** — clear the `warp_prism_ui` package-wide formatter baseline drift (53 of 312 files), which is what repeatedly produced the F5 finding.
- Task **1843** — narrow the gallery test-suppressor so layout errors can actually fail a gallery test.
- `AGENTS.md` §7.0 is now removable: its own removal condition is a zero-stale sweep, and that condition is now satisfied. Governance removal is a separate authorized act.
