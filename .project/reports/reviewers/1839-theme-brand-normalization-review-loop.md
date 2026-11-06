# Task 1839 — Theme Brand Normalization — Review Loop

## Review Entry 5 — 2026-10-02 (F1b/F5 Verification + Adversarial Sweep)

### Review Lineage

- **Current task**: Task 1839, `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`.
- **Prior entries read**: Entry 4 (`48/100`, FAIL); Entries 1–3 preserved below unchanged.
- **New evidence read**: Task 1839 `Review Entry 4 disposition` + `Accepted-exception register` (`:250-288`); `.project/reports/builders/1842-theme-matrix-wire-id-migration-builder-report.md`; `.project/tasks/01-open/1846-warp-prism-formatter-baseline-drift.md`; `.project/reports/reviewers/1837-golden-suite-tagging-review-loop.md` Entry 1 (2026-09-07 golden baseline).
- **Review mode**: independent re-review of Entry 4's two Serious findings (F1b, F5) against current sources, plus a full adversarial sweep for stale hits outside the five registers and for wire-ID fallout. No VCS command was run.

### Structured Result

```yaml
verdict: PASS
score: 91
confidence: 0.93
findings:
  - id: F1b
    class: RESOLVED
    severity: Serious
    status: closed
    finding: "Nerazim design note carries zero stale tokens (verified); Task 1806 reference is owner-accepted in the register and untouched per the 03-review non-goal."
  - id: F5
    class: RESOLVED
    severity: Serious
    status: closed
    finding: "Task-surface formatter gate verified: the 3 named files plus the full 8-file remediation set report 0 changed. Residual package-wide drift (53/312) is pre-existing and owned by Task 1846, not this task."
  - id: F2
    class: RESOLVED
    severity: Debt
    status: closed
    finding: "Seven-file authorization verified at file level against live source; all 7 files carry the post-rename state. Remaining prose-categorization nit is immaterial to acceptance."
  - id: F3
    class: PERSISTENT
    severity: Improvement
    status: open
    finding: "Black Obsidian annotation still opens with an overbroad 'both rows verbatim' sentence, immediately qualified by the accurate row-3 summary note. Provenance harm neutralized in place; residual is redundant wording."
  - id: F4
    class: PERSISTENT
    severity: Improvement
    status: open
    finding: "Catalog-showability 'only change' claim still lacks a verified preimage (standing limitation, owner-recorded as non-defect)."
  - id: F6
    class: NEW
    severity: Debt
    status: open
    finding: "Adversarial find: apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart:5-6 still reads 'CyberCore / Teal' (line-wrapped), a stale brand phrase in live test commentary that evades the literal sweep. Comment-only, one-line fix, needs owner authorization."
```

| Severity | Open findings |
|---|---|
| Critical | None |
| Serious | None (F1b, F5 closed this entry) |
| Debt | F6 (NEW, open) |
| Improvement | F3, F4 (PERSISTENT, open) |

Score: `100 − 5 (F6) − 2 (F3) − 2 (F4) = 91/100`. No Serious/Critical finding is open, so the score cap does not engage and the PASS verdict is coherent. Task remains in `02-doing`; **no lane move** (Rule 42 builder-gate matrix permits a reviewer move only at `S = 100`; promotion is parent-owned).

### Exact Commands And Exit Codes

| # | Command / working directory | Result |
|---|---|---|
| 1 | `rg -n -i "DSCyberCoreTealSkin\|PrismCyberCoreTealSkin\|CyberCoreTeal\|cybercore_teal\|cybercore-teal\|CyberCore Teal\|Protoss Gold\|ProtossGold\|Nerazim Green" packages apps docs .project/architecture` + the 8 supplied globs (repo root) | Exit 0; **2 matching lines** (`black-obsidian-visual-contract.md:180-181`, 3 tokens). Zero elsewhere. |
| 2 | `grep -rn "cybercore-teal" packages/ apps/ --include='*.dart'` (repo root) | No output; **0 matches** (GNU `grep` exit 1 = no-match). |
| 3 | Same stale pattern against `docs/design/nerazim-teal-theme-extension-skin.md` | No output (exit 1). File clean. |
| 4 | Same stale pattern against `AGENTS.md MISSION.md README.md` | Exit 0; hits only in `AGENTS.md:435,436,446,447` (§7.0 law text). `MISSION.md`/`README.md` zero. |
| 5 | Same stale pattern against `.project/tasks/03-review/1806-...md` | 1 hit at `:75` (owner-accepted register item 3; file untouched). |
| 6 | `rg -n '0xFF00FFCC\|0xFF00B894\|0xFF007A66\|0xFF9911E5\|0xFFE51A4C\|0xFF2F81FF'` over the 4 token files | All 6 literals at the expected lines; no other values. |
| 7 | `dart analyze` — `packages/warp_prism_ui` | Exit 0; 212 info diagnostics, **zero `error -` lines**. |
| 8 | `dart analyze` — `packages/warp_prism_host_exercise` | Exit 0; no issues. |
| 9 | `flutter analyze --no-pub` — `apps/catalog` / `apps/cybercore` | Exit 0 both; no issues. |
| 10 | `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | Exit 0; **15/15 PASS**, 0 violations. |
| 11 | `flutter test test/boundaries/public_barrel_no_ds_export_test.dart --no-pub` — `packages/warp_prism_ui` | Exit 0; `+3: All tests passed!` (barrel gate). |
| 12 | `dart format` on the 8-file remediation set (7 Iteration-2 files + `ds_nerazim_teal_skin.dart`) | Exit 0; `Formatted 8 files (0 changed)`. |
| 13 | `dart format` on the 3 disposition-named files | Exit 0; `Formatted 3 files (0 changed)`. |
| 14 | `dart format --output=none --set-exit-if-changed lib/ test/` — `packages/warp_prism_ui` | Exit 1; `Formatted 312 files (53 changed)` — matches Task 1846's recorded 53; pre-existing drift, separately owned. Check writes nothing. |
| 15 | `cd apps/catalog && flutter test --no-pub` | Exit 0; `+23: All tests passed!` |
| 16 | `cd apps/cybercore && flutter test --no-pub` | Exit 0; `+27: All tests passed!` |
| 17 | `cd packages/warp_prism_host_exercise && flutter test --no-pub` | Exit 0; `+10: All tests passed!` |
| 18 | Golden census: `rg --files ... -g '*.png' -g '!**/failures/**' \| wc -l` + `stat` newest mtime | Exit 0; **73 baseline PNGs**, newest mtime **2026-08-24**. No `--update-goldens` run. |
| 19 | `rg -n -F 'architects/traces' packages/ apps/ rust/` (dart/rs) | Exit 0; single source-**comment** hit (`theme_matrix.dart:34`); no executable loader. |
| 20 | Anchor checks: `rg -n "\.omniRoute\|omniRoute\(\)\|cybercoreTeal\|PrismCyberCore\|DSCyberCore" packages apps` | Only `WarpPrismCyberCoreApp`/`cybercore_app` (app class name); **zero** old factory/const/skin references. |
| 21 | Old filenames: `glob **/*cybercore*teal*` over `packages/`, `docs/` | No files (renames complete; originals archived). `apps/` hit is `cybercore_shell_chrome_teal_test.dart`, whose name the task explicitly preserves. |

### Per-Claim Verification (user items 1–7 + falsification)

1. **Sweep vs five registers — PASS.** Every remaining sweep hit falls inside the registers: (1) `AGENTS.md:435-447` = register item 1; (2) `black-obsidian-visual-contract.md:180-181` = register item 2, rows byte-preserved with the in-place annotation; Task 1806 `:75` is outside command 1's paths but inside register items 3/5 (verified present, file untouched); architect-trace JSON old literals are register item 4 (4 files, mtimes still 2026-09-08, never rewritten). **No literal-sweep hit exists outside the five registers.** Adversarial note: one *semantic* (non-literal) residue found — F6 below.
2. **App suites — PASS.** Catalog `+23`, CyberCore `+27`, host-exercise `+10`, all exit 0. Live `host-exercise` traces now record `"theme_recipe": "nerazim-teal"` in all four revalidation scenarios; frozen architect traces untouched. No dangling consumer: all five migrated files reference only `nerazim-teal` (verified per-file); `toJson`/`fromJson` signatures unchanged.
3. **Analyzers — PASS.** All four exit 0; UI reports 212 pre-existing infos, zero errors.
4. **Boundary — PASS.** 15/15 plus the barrel export test `+3`.
5. **Task-surface format — PASS.** The 3 disposition-named files and the full 8-file remediation set each report `0 changed` (exit 0). The 5 other task-touched files still flagged by the package-wide check (`ds_taldarim_red_skin.dart`, `ds_talon_purple_skin.dart`, `apps/catalog/lib/main.dart`, `cybercore_shell_chrome_teal_test.dart`, `cybercore_revalidation_test.dart`) were diffed hunk-by-hunk: every flagged hunk sits in regions this task never edited (old-formatter-version reflow style, EOF newline) and is pre-existing drift now owned by Task 1846 — which records exactly the current 53-file count. No task-edited line remains unformatted.
6. **Hex identity — PASS.** Teal `0xFF00FFCC`/`0xFF00B894`/`0xFF007A66`, Talon `0xFF9911E5`, Taldarim `0xFFE51A4C`, Khalai `0xFF2F81FF` — all present at the canonical lines; no other values.
7. **Golden baseline — NOT REFRESHED.** 73 baseline PNGs, newest mtime 2026-08-24 (pre-task). Task 1837 Entry 1 (2026-09-07) independently documents the same `+1703/−63` golden-only state before Task 1839 began. The full UI suite was deliberately not rerun here (its `failures/*.png` diagnostics from prior runs are artifacts, not baselines); the golden-excluded gate state (`+1692`) is carried from Entry 4 evidence, and this task changed no color or pixel.
- **Falsification attempts that failed (good):** old-ID grep zero; old-factory/const/skin grep zero; old filenames zero live; `architects/traces` loaded by no code (comment-only mention; writer targets `host-exercise/traces/`); bare-word `protoss` hits are all StarCraft-lore/aesthetic prose (`Protoss lore`, `protoss influence`), never the `Protoss Gold` brand; bare `CyberCore` hits name the consumer app/host, never the teal brand — except F6.
- **Falsification attempt that succeeded:** F6 — `catalog_theme_matrix_test.dart:5-6` still reads `→ CyberCore` / `Teal → back`, a line-wrapped `CyberCore Teal` brand phrase in live test commentary, factually stale since the ladder entry is now `nerazim-teal` (`:32`). Flagged by the Task 1842 builder as out-of-census and left unauthored. It evades the literal gate (newline split) but violates the task's comments objective.

### Findings And Path To 100

- **F1b RESOLVED.** Nerazim note verified token-free; Task 1806 accepted in the register and unedited. F1's code-side migration stands verified (0 old-ID matches; new ID asserted end-to-end by green suites).
- **F5 RESOLVED (task surface).** 8-file set green; package-wide residual owned by Task 1846 with matching count. No broad reformat performed under this review.
- **F2 RESOLVED.** Seven-file authorization reconciles file-for-file (task correction 7 items = builder table 7 rows = 7 live files in post-rename state, all re-verified above). The `comment-only vs const+label` and `compile-breaking vs assertion` phrasing tensions are immaterial to acceptance — the precise per-file record exists in the builder's Item-7 section — and Task 1842's internal count wording belongs to Task 1842's owner, not this task's score.
- **F3 downgraded Debt → Improvement, still open.** The explicit row-3 summary note neutralizes the provenance harm in place; what remains is redundant wording, not a misleading record. Both rows stay preserved.
- **F4 open, Improvement.** Standing limitation per owner record; no preimage obtainable without VCS (prohibited).
- **F6 NEW, Debt, open.** One-line comment fix in `catalog_theme_matrix_test.dart:5-6` (`CyberCore Teal` → `Nerazim Teal`), requiring owner authorization since the file sits outside Task 1839's `Where` table (a Task 1842 consumer file). Suggested follow-up owner: Task 1842 lane or a micro-task; do not bundle into this review.
- **Path to 100:** (1) authorize + apply the F6 one-line comment fix; (2) optionally tighten the F3 sentence; (3) Task 1846 clears package format drift; Task 1805 owns golden reconciliation. None blocks product acceptance.

### Scope/State Closeout

- No source, task, or changelog file was edited; no Git/Jujutsu command was run. The only manual write is this review-loop entry. Test runs persist live `host-exercise` trace artifacts by design (frozen architect traces untouched — mtimes verified 2026-09-08).
- Changelog entry present: `.project/changelog/20260928-133500-1839-theme-brand-normalization-gt-builders-engineer-flutter.md`.
- **No lane move performed.** Task 1839 stays in `02-doing`; promotion is parent-owned (reviewer matrix requires `S = 100` for a reviewer move).

## Review Entry 4 — 2026-09-30 (Post-Task-1842 Re-review)

### Review Lineage

- **Current task**: Task 1839, `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`.
- **Prior entry read**: Entry 3 (`48/100`, FAIL); Entries 1–2 and the prior F1–F7 evidence remain preserved below.
- **New migration evidence read**: `.project/reports/builders/1842-theme-matrix-wire-id-migration-builder-report.md` and Task 1839’s `Finding Dispositions` table at `:226-248`.
- **Review mode**: independent verification of the Task 1842 post-migration state against the user’s A–E checklist. No VCS command was run.

### Structured Result

```yaml
verdict: FAIL
score: 48
confidence: 0.97
findings:
  - id: F1a
    class: RESOLVED
    severity: Serious
    status: closed
    finding: "The 14 old serialized-ID occurrences are gone from packages/ and apps/ Dart source; the new ID is present in the live ThemeMatrix and consumers, and the requested app/host tests pass."
  - id: F1b
    class: PERSISTENT
    severity: Serious
    status: open
    finding: "The current accepted exception set does not include docs/design/nerazim-teal-theme-extension-skin.md:9, which still names the old filename. Task 1839's Finding Dispositions table still treats that filename as accepted pending Task 1842, and its broader required scope grep still finds the protected Task 1806 reference."
  - id: F2
    class: EVIDENCE_GAP
    severity: Debt
    status: open
    finding: "The seven-file count is verified, but Task 1839 and the Task 1839 builder correction still describe ThemeMatrix and the compile/assertion repairs inconsistently; the Task 1842 report's '0 references' search overlooks a source comment, its validation header says five commands while its table lists six plus a grep, and Task 1842's rationale misattributes 14 total sites to a file containing nine."
  - id: F3
    class: PERSISTENT
    severity: Debt
    status: open
    finding: "The Black Obsidian note still says both rows are verbatim before explicitly identifying row 3 as a summary."
  - id: F4
    class: PERSISTENT
    severity: Improvement
    status: open
    finding: "The Catalog-showability 'only change' claim still lacks a verified preimage."
  - id: F5
    class: PERSISTENT
    severity: Serious
    status: open
    finding: "The task-required UI formatter check still exits nonzero: 56 files would be reformatted, including touched test lines."
```

Serious findings cap the score at 50; deductions are F1b −20, F5 −20, F2 −5, F3 −5, and F4 −2 = **48/100**. Task 1839 remains in `02-doing`; no lane move was made.

| Severity | Open findings |
|---|---|
| Critical | None |
| Serious | F1b, F5 |
| Debt | F2, F3 |
| Improvement | F4 |

### Exact Commands And Exit Codes

| Command / working directory | Result |
|---|---|
| `grep -rn "cybercore-teal" packages/ apps/ --include='*.dart'` (repo root) | No output; **0 matches**. GNU `grep` returns 1 for no matches. |
| User-specified `rg -n -i "DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green" packages apps docs .project/architecture` with all supplied exclusions | Exit 0; 3 matching lines / 4 token occurrences. |
| `rg -o -i --no-heading 'cybercore-teal' .project/reports/architects/traces --glob='*.json'` | Exit 0; 4 frozen trace files contain the old value. |
| `rg -n -F 'architects/traces' packages/ apps/ rust/ --glob='*.dart' --glob='*.rs'` | Exit 0; one source-comment hit (`theme_matrix.dart:34`); no executable loader reference found. |
| `cd apps/catalog && flutter test --no-pub` | Exit 0; `+23: All tests passed!`. |
| `cd apps/cybercore && flutter test --no-pub` | Exit 0; `+27: All tests passed!`. |
| `cd packages/warp_prism_host_exercise && flutter test --no-pub` | Exit 0; `+10: All tests passed!`. |
| `cd packages/warp_prism_ui && flutter test test/ --no-pub --exclude-tags=golden` | Exit 0; `+1692: All tests passed!`. |
| `cd packages/warp_prism_ui && dart analyze` | Exit 0; 212 info diagnostics, no errors. |
| `cd packages/warp_prism_host_exercise && dart analyze` | Exit 0; no issues. |
| `cd apps/catalog && flutter analyze --no-pub`; `cd apps/cybercore && flutter analyze --no-pub` | Exit 0 for both; no issues. |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (repo root) | Exit 0; 15/15 PASS, 0 violations. |
| `cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed lib/ test/` | Exit 1; 56 of 312 files would be reformatted. This check does not write formatted files. |
| `rg --files packages/warp_prism_ui/test/goldens -g '*.png' -g '!**/failures/**' | wc -l` | Exit 0; 73 baseline PNGs. |
| `stat -c '%y %n' packages/warp_prism_ui/test/goldens/*.png packages/warp_prism_ui/test/goldens/goldens/*.png | sort -r` | Exit 0; newest baseline mtime 2026-08-24. |

### Verification Results

#### Wire-ID Migration And Frozen Evidence

- The requested `grep -rn "cybercore-teal" packages/ apps/ --include='*.dart'` produced **no output** (0 matches; GNU `grep` returns status 1 for the no-match case). The code-side serialized-ID exception set is now empty.
- Current live source confirms `ExerciseThemeRecipe.nerazimTeal.id == 'nerazim-teal'` (`packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:36-38`), the Catalog ladder/switch uses `nerazim-teal` (`apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart:28-34`, `catalog_host.dart:86-90`), and CyberCore defaults/asserts use the new ID (`cybercore_host.dart:31`, `cybercore_revalidation_test.dart:42-58,68-87,97-122,132-153`).
- The four frozen files under `.project/reports/architects/traces/` still contain the old ID; their mtimes remain 2026-09-08. They were not rewritten. The code search for `architects/traces` found one **comment** at `theme_matrix.dart:34`, not a loader. The active `ExerciseTraceWriter` writes under `.project/reports/host-exercise/traces/` instead. Thus “not loaded by code” is supported, while the Task 1842 report’s literal claim of “0 references” is too broad because of the comment.
- The three requested test runs passed: Catalog `+23`, CyberCore `+27`, and `warp_prism_host_exercise` `+10`. The current live CyberCore host-exercise traces record `nerazim-teal` for the four revalidation scenarios. These tests exercise the migrated recipe end-to-end; they also write/update the live `host-exercise` trace artifacts as designed. Architect-trace mtimes remained unchanged.

#### Exact Stale-Brand Scan And Current Exceptions

- The user-specified A command returned three matching **lines** and four matching **tokens**. The 14 code-side IDs are absent.
- The two historical rows in `docs/design/black-obsidian-visual-contract.md:180-181` are allowed by the current user instruction. `AGENTS.md` §7.0 has four matches and is allowed by the current instruction.
- `docs/design/nerazim-teal-theme-extension-skin.md:9` is an additional old-filename occurrence **not included in the current accepted set**. It contradicts the claim that the only remaining repository occurrences are architect traces and violates Task 1839’s zero-stale condition.
- Separately, the Task 1839 original scope grep includes `.project/tasks/03-review/`; a fresh scoped check still finds `DSCyberCoreTealSkin` at `.project/tasks/03-review/1806-warp-prism-component-gallery-visual-reconciliation.md:75`. This is outside user command A’s paths but remains in the Task’s own sweep, with no current accepted exception. Task 1839’s no-rewrite rule for `03-review` still prevents a local repair.
- The Task’s `Finding Dispositions` table still calls F1 an accepted exception with migration scheduled. That disposition is stale for the code ID (now migrated) and does not resolve the remaining design-note filename or Task 1806 reference.

#### Analyzer, Boundary, Formatting, And Colors

| Command / check | Result |
|---|---|
| `dart analyze` — `packages/warp_prism_ui` | Exit 0; 212 info diagnostics, no errors. |
| `dart analyze` — `packages/warp_prism_host_exercise` | Exit 0; no issues. |
| `flutter analyze --no-pub` — `apps/catalog`, `apps/cybercore` | Exit 0 for both; no issues. |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | Exit 0; 15/15 PASS, 0 violations. |
| `flutter test test/ --no-pub --exclude-tags=golden` — `packages/warp_prism_ui` | Exit 0; `+1692: All tests passed!`. |
| `dart format --output=none --set-exit-if-changed lib/ test/` — `packages/warp_prism_ui` | **Exit 1**; `Formatted 312 files (56 changed)`. No files were formatted/written by this command. |
| Color literals | Nerazim `0xFF00FFCC / 0xFF00B894 / 0xFF007A66`; Talon `0xFF9911E5`; Taldarim `0xFFE51A4C`; Khalai `0xFF2F81FF` — all current values match. |

- Golden baseline: 73 baseline PNGs were enumerated from the top-level and nested `goldens` directories (excluding `failures/`). Their newest mtime is 2026-08-24; the generated `failures/*.png` images dated 2026-09-29 are diagnostics, not baselines. No `--update-goldens` command was run. Task 1837’s 2026-09-07 report predates Task 1839 and documents the same 63 golden mismatches. The full UI suite was not rerun in this pass; the golden-excluded suite was.
- Boilerplate scan: no TODO/FIXME/lorem/replace-me template was found in the changed files. The remaining `Placeholder` occurrences are the illustrative `const Placeholder()` widget in the skin document and fixture-specific API comments, not unfinished implementation boilerplate.
- VCS: no Git/Jujutsu command was run. No source, task, or changelog file was edited; only this reviewer loop was manually appended.

### Findings And Path To 100

1. **F1b — Serious**: remove or otherwise resolve the old filename mention at `docs/design/nerazim-teal-theme-extension-skin.md:9` under the current exception set. Resolve the Task 1806 hit through the owner-authorized scope path; do not edit that `03-review` task under Task 1839’s existing non-goal.
2. **F5 — Serious**: reconcile the nonzero formatter gate and the touched test lines; do not broad-format unrelated files under this review.
3. **F2 — Debt**: align the Task 1839 correction, builder correction block, and detailed table with the actual ThemeMatrix const/label edits and assertion-only test edit. Correct Task 1842’s stale per-file count in its task record through its owner.
4. **F3 — Debt**: correct the annotation’s “both rows verbatim” sentence so it agrees with the explicit row-3 summary note; keep the historical rows preserved.
5. **F4 — Improvement**: retain the Catalog-showability “only change” claim only if an authorized preimage can verify it.

## Review Entry 3 — 2026-09-29 (Independent Verification A–E)
## Review Entry 3 — 2026-09-29 (Independent Verification A–E)

### Review Lineage

- **Current task**: Task 1839, `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`.
- **Previous review read**: this file, Entry 2 (`48/100`, FAIL), and Entry 1 (`45/100`, FAIL); earlier entries are preserved below unchanged.
- **Current user scope**: re-run the specified stale-brand scan, verify the three permitted exception classes and color literals, re-run analyzer/boundary gates, inspect Iteration 2 scope, and inspect the changed files for boilerplate. No source, task, or changelog edits were authorized.
- **Review mode**: independent A–E verification against current sources and the current user’s narrower accepted-exception list.

### Structured Result

```yaml
verdict: FAIL
score: 48
confidence: 0.97
findings:
  - id: F1
    class: PERSISTENT
    severity: Serious
    status: open
    finding: "Three stale-name tokens remain in black-obsidian-visual-contract.md outside the user's current exception set; Task 1839's wider required scan also still finds the Task 1806 reference."
  - id: F2
    class: PERSISTENT
    severity: Debt
    status: open
    finding: "The seven-entry count is confirmed, but the builder correction still misdescribes the ThemeMatrix changes and the edit categories do not map precisely to the table."
  - id: F3
    class: PERSISTENT
    severity: Debt
    status: open
    finding: "The Black Obsidian annotation says rows 2–3 are verbatim, then says row 3 is a summary."
  - id: F4
    class: PERSISTENT
    severity: Improvement
    status: open
    finding: "The Catalog-showability 'only change' claim still lacks a verified preimage."
  - id: F5
    class: PERSISTENT
    severity: Serious
    status: open
    finding: "The required UI-package formatter command remains nonzero: 56 files would be reformatted, including task-touched test lines."
```

The Serious findings cap the score at 50; deductions are F1 −20, F5 −20, F2 −5, F3 −5, and F4 −2. The task remains in `02-doing`; no lane move was made.

### A–E Verification

#### A–B. Exact stale-brand sweep and allowed exceptions

I ran the exact user-specified `rg -n -i` command over `packages`, `apps`, `docs`, and `.project/architecture` with all supplied globs. It returned **17 matching lines containing 18 token occurrences**:

- **14** `cybercore-teal` occurrences are confined to the five named wire-ID/host-exercise files: `theme_matrix.dart` (2), Catalog theme-matrix test (1), Catalog host (1), CyberCore host (1), and CyberCore revalidation test (**9**).
- **1** old-filename mention is at `docs/design/nerazim-teal-theme-extension-skin.md:9`.
- **3 unaccepted occurrences** are in `docs/design/black-obsidian-visual-contract.md`: line 180 has `DSCyberCoreTealSkin`; line 181 has both the old `cybercore-teal` task filename and `DSCyberCoreTealSkin`. These are historical rows previously treated as accepted, but the current user’s exception list no longer accepts them. They fail the current zero-stale claim.

I separately scanned `AGENTS.md`; its four matches are confined to §7.0 and are the explicitly permitted law text. `MISSION.md` and `README.md` returned no matches. The 14 wire-ID occurrences and line-9 filename match satisfy the other two permitted exception classes.

The Task’s own broader legacy scope grep also includes `.project/tasks/03-review/`; a targeted check still finds `.project/tasks/03-review/1806-warp-prism-component-gallery-visual-reconciliation.md:75` with `DSCyberCoreTealSkin`. It is outside user command A’s paths, but remains a persistent Task 1839 scope/exit-condition issue because the Task itself includes that lane in its grep and forbids rewriting `03-review` tasks. No edit was made.

#### C. Theme values

Current source literals match the requested values:

- Nerazim Teal: `0xFF00FFCC`, `0xFF00B894`, `0xFF007A66` — `ds_nerazim_teal_skin.dart:25,28,31`.
- Talon Purple: `0xFF9911E5` — `ds_talon_purple_skin.dart:26`.
- Taldarim Red: `0xFFE51A4C` — `ds_taldarim_red_skin.dart:26`.
- Khalai Blue: `0xFF2F81FF` — `prism_token_registry.dart:70`.

These are current-value observations; no VCS preimage was used to claim byte-for-byte historical identity.

#### D. Analyzer, boundary, and boilerplate checks

- `dart analyze` — `packages/warp_prism_ui`: exit 0, **212 info** diagnostics and no errors.
- `dart analyze` — `packages/warp_prism_host_exercise`: exit 0, no issues.
- `flutter analyze --no-pub` — `apps/catalog` and `apps/cybercore`: exit 0, no issues.
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`: exit 0, **15/15 PASS**, 0 violations.
- A targeted placeholder scan found no TODO/FIXME/lorem/replace-me boilerplate. Its only “Placeholder” hits were intentional: the minimal `const Placeholder()` in the theme-document example (`docs/design/nerazim-teal-theme-extension-skin.md:68`) and fixture-specific placeholder descriptions in `prism_aliases.dart:955,1395`. Those are not unfilled templates or nonsensical implementation stubs.

`dart format --output=none --set-exit-if-changed lib/ test/` remains **exit 1** with `Formatted 312 files (56 changed)`. It is non-writing, but the required formatter gate is not green; `prism_theme_test.dart:125-127` and `theme_role_accent_propagation_test.dart:77` are among the touched lines the formatter would reflow.

No tests were run in this pass: the user restricted this round to read-only commands, and the host-exercise tests persist trace JSON. Entry 2 contains the latest test results; no claim of a fresh test run is made here.

#### E. Iteration 2 scope

The current Task correction and builder table both enumerate **seven** Iteration 2 file entries, so the cardinality is confirmed. The exact action record is still inconsistent: Task 1839 says `theme_matrix.dart` label change, the builder correction says serialized-ID comment-only, and the detailed builder table plus live `theme_matrix.dart:27-35` show the const and label changed. The table’s `prism_theme_editor_test.dart` entry is two `find.text` assertion updates, not a compile-breaking repair, so the correction’s “five compile-breaking repairs” wording also does not precisely describe the listed operations. Record this as an evidence-precision debt, not as a proved unauthorized source edit.

### Findings And Path To 100

1. **F1 — Serious, persistent**: update or otherwise disposition the three black-obsidian stale tokens under the current strict exception set; resolve the Task 1806 reference under the Task’s wider scope without violating its `03-review` no-rewrite rule.
2. **F5 — Serious, persistent**: have the task owner reconcile the nonzero formatter gate and the touched test lines; do not broad-format unrelated files under this review.
3. **F2 — Debt, persistent**: make the Task correction and builder correction match the actual ThemeMatrix const+label changes and accurately categorize the assertion-only test edit.
4. **F3 — Debt, persistent**: correct the contradictory quotation annotation while preserving its historical references.
5. **F4 — Improvement, persistent**: retain the “only change” claim only if an authorized preimage can verify it.

### Scope/State Closeout

- No source, task, or changelog file was edited; no Git/Jujutsu command or test command was run in this pass.
- No lane transition was performed. Task 1839 remains in `02-doing`.
- Current results are not PASS: the user-defined zero-hit contract and the Task’s formatter exit condition remain unsatisfied.

## Review Entry 2 — 2026-09-29 (Independent Full Re-review)

### Review Lineage

- **Current task**: Task 1839; live path `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`.
- **Previous report read**: this file, Entry 1 — 45/100 FAIL (2026-09-29).
- **Related evidence read**:
  - `.project/reports/builders/1839-theme-brand-normalization-builder-report.md` — Iteration 2 and post-review correction.
  - `.project/tasks/00-planning/1842-warp-prism-theme-matrix-wire-id-migration.md` — owner and gated migration for the serialized recipe ID.
  - `.project/reports/reviewers/1837-golden-suite-tagging-review-loop.md` — 2026-09-07 evidence for the frozen 63-golden baseline.
  - `.project/reports/1805-visual-rejudgment-runbook.md` — human visual gate and prohibition on refreshing the baseline before its conditions.
  - `.project/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md` — earlier host-exercise evidence and trace contract.
- **Review mode**: full review restart, not a narrow delta patch. Entry 1 did not enumerate the Task 1839 scope command's `.project/tasks/03-review/` results and did not independently resolve the required formatter gate. The current review therefore rechecked the full task scope; the findings below are not claimed to be regressions from the immediately preceding fix.
- **Mutation boundary**: no product source, task, or changelog file was edited; no Git/Jujutsu command was run; this entry is the only manual file write. Required host-exercise tests use their existing trace persistence helper; see Side Effects below.

### Score And Verdict

- **Score**: **48/100** — Serious band. Deductions: F1 −20, F5 −20, F2 evidence-precision debt −5, F3 −5, F4 −2. Serious findings cap the score at 50.
- **Verdict**: **FAIL** — Task 1839's literal zero-hit/validation exit conditions are not all satisfied.
- **Lane recommendation**: **no move**. The task remains in `02-doing`; the reviewer does not move it because the score is not 100. No `04-completed/` transition was attempted.
- **Confidence**: high for current command results and the observed stale-token locations; medium for per-file formatter-history attribution because no VCS preimage was inspected.

### Delta Summary

#### Resolved Since Entry 1

- **F1 wire-ID / filename exception**: Task 1839 now records 14 `cybercore-teal` occurrences and the one old-filename mention as accepted pending Task 1842. The source census below verifies 14 occurrences across the five named Dart files, and the design-note path contains the separate filename mention. The serialized `id` remains `cybercore-teal`; it was not migrated here.
- **F2 file-count authorization**: Task 1839's later correction records seven Iteration 2 files, and the builder's detailed table has seven entries. The original six-versus-seven authorization-count blocker is resolved at the file-count level. A contradictory builder correction remains an evidence-quality debt (F2b).
- **Catalog/CyberCore host-test failures**: the prior `PathNotFoundException` failures did not reproduce in this review. Current full app suites and focused host-exercise suites pass (exact results below); do not carry Entry 1's test failure as a current failure.
- **Golden-failure attribution**: the 63 full-suite UI failures are established as pre-existing baseline drift: Task 1837 recorded the same `+1703/-63` golden-only state on 2026-09-07, before Task 1839's 2026-09-28 implementation. The user-provided `2026-09-30` date is future-dated relative to this review (2026-09-29); no support for that date was found in the reviewed repository records, and it is not needed for the pre-existing conclusion. No golden refresh was run.

#### Persistent Findings And Findings Surfaced By The Full-review Restart

- **F1 — `03-review/` scope conflict remains**: the required full scope scan also finds `DSCyberCoreTealSkin` at `.project/tasks/03-review/1806-warp-prism-component-gallery-visual-reconciliation.md:75`. This is not among the newly recorded wire-ID, old-filename, two visual-record, or `AGENTS.md` exceptions. Task 1839 prohibits rewriting `03-review/` task files (`:123`); its zero-hit exit text names `.archive/` and `04-completed/` as historical exclusions (`:79-81`), and its later addenda do not name this Task 1806 row. The task therefore cannot satisfy the literal scan and its no-rewrite rule without an explicit owner disposition. Do not edit Task 1806 under Task 1839.
- **F3 — provenance wording remains contradictory**: `docs/design/black-obsidian-visual-contract.md:183-190` calls both rows verbatim quotations, then `:192-197` says row 3 is a summary and not an exact quotation. Task 1616 `:55-58` confirms the row-3 wording is summarized, not verbatim. The cited EPIC-17 source path was not found by the workspace glob, so row 2's exact provenance remains unverified.
- **F4 — “only change” claim remains unproved**: Entry 1 found the Catalog-showability wording correct but could not verify exclusivity without a preimage. No VCS preimage was obtained in this re-review.
- **F5 — required formatter gate is still red**: the task's `dart format --output=none --set-exit-if-changed lib/ test/` command reports `Formatted 312 files (56 changed)` and exits nonzero. A narrower check also shows formatter changes on task-touched test lines, including `test/theme/prism_theme_test.dart:125-127` and `test/theme/theme_role_accent_propagation_test.dart:77`. The builder reports a package-wide count of 57 before the extension and 56 afterward, supporting pre-existing aggregate drift, but this does not prove those specific touched lines were already formatted before the rename. The task's all-validation-green exit condition remains unsatisfied until the changed lines and baseline disposition are reconciled.

### Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
|---|---|---|---|---|---|---|
| F1 | `NEW` on full-review restart (pre-existing state, not a regression) | **Serious** | Open | The exact task scope scan includes a stale `DSCyberCoreTealSkin` reference in Task 1806. Task 1839's `03-review/` non-goal conflicts with the literal zero-hit gate; owner disposition is required. | Full-review restart, 2026-09-29 | `.project/tasks/03-review/1806-warp-prism-component-gallery-visual-reconciliation.md:75`; Task 1839 `:79-81,123`; current text scan. |
| F2a | `RESOLVED` | Serious | Closed | The six/seven-file authorization-count discrepancy is repaired at file level: Task 1839's later correction records seven items and the builder table enumerates seven files. | Entry 1 / 2026-09-29 correction | Task 1839 `:215-222`; builder report `:30-40`. |
| F2b | `EVIDENCE_GAP` | Debt | Open | The builder's post-review correction says `theme_matrix.dart` was a comment-only update (`builder report:13-14`), while its own detailed table says the const and label changed (`:35`) and live source confirms `nerazimTeal` plus label with the serialized ID preserved (`theme_matrix.dart:25-35`). Task 1839's correction names the ThemeMatrix label change but does not explicitly mention the const rename, so the file count is reconciled but the exact action record is not. Task 1842 also says there are 14 references in `cybercore_revalidation_test.dart` (`:15`); the current exact count is 9 in that file and 14 across the five Dart files. | Full-review restart, 2026-09-29 | Task 1839 `:215-222`; builder report `:13-14,30-40`; `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:25-35`; Task 1842 `:15`. |
| F3 | `PERSISTENT` | Debt | Open | The Black Obsidian annotation makes mutually inconsistent provenance claims for row 3; row 2's cited source remains unavailable in the live task tree. | Entry 1 / 2026-09-29 | `docs/design/black-obsidian-visual-contract.md:183-197`; Task 1616 `:53-58`. |
| F4 | `PERSISTENT` | Improvement | Open | The current Catalog-showability wording is semantically correct, but the claim that it was the only change still lacks a verified preimage. | Entry 1 / 2026-09-29 | Entry 1 `:44`; no VCS preimage in this review. |
| F5 | `EVIDENCE_GAP` | **Serious** | Open | The required formatter command exits nonzero, and current formatter output flags changed test files/lines. The aggregate 57→56 history does not establish the pre-task formatting state of each changed line. | Full-review restart, 2026-09-29 | Current `dart format` output; builder report `:71`; `packages/warp_prism_ui/test/theme/prism_theme_test.dart:125-127`; `.../theme_role_accent_propagation_test.dart:76-78`. |
| F6 | `RESOLVED` | Info | Closed | The prior Catalog/CyberCore `PathNotFoundException` test failures are no longer observed: full app suites and focused host-exercise suites now pass. This proves current pass state, not when or why the earlier path failure ceased. | Entry 1 / 2026-09-29 | Current test outputs listed below. |
| F7 | `RESOLVED` (attribution only) | Info | Recorded | The 63 UI failures are current but pre-date Task 1839 and are golden-only; full suite remains exit 1, while the golden-excluded suite passes. Do not refresh snapshots under this task. | Entry 1 / 2026-09-29 | Task 1837 report `:29-35,52-58`; Task 1805 runbook `:84-97`; current UI test outputs. |

### Stale-Name Scan Detail

- The exact Task 1839 grep was invoked:

  ```bash
  grep -rn -i "cybercoreteal\|cybercore_teal\|cybercore teal\|protoss gold\|protossgold\|nerazim green" packages/ apps/ rust/ docs/ AGENTS.md MISSION.md README.md .project/tasks/01-open/ .project/tasks/03-review/
  ```

  The terminal response was auto-truncated because the command also traversed generated build binaries. A complete text-surface follow-up used the same term family plus the hyphenated wire-ID term, included `.project/architecture/`, and excluded generated/build, archived, completed-task, changelog, and graph-map surfaces.
- The Task's original pattern does **not** contain `cybercore-teal`, so it cannot detect the serialized IDs or the hyphenated old filename. The expanded pass found **14** wire-ID token occurrences across five Dart files; **9** are in `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart`. The separate filename hit is `docs/design/nerazim-teal-theme-extension-skin.md:9`.
- Other observed hits: the two protected historical rows at `docs/design/black-obsidian-visual-contract.md:180-181`; the temporary-name rule in `AGENTS.md:435-447`; and the additional Task 1806 row at `.project/tasks/03-review/1806-warp-prism-component-gallery-visual-reconciliation.md:75` (F1). The first three categories are already recorded as accepted/protected by Task 1839; the Task 1806 row is not explicitly named in the F1 addendum.
- Task 1842's migration structure names the five code/test locations, but its per-file count at `:15` is inaccurate (9 in the revalidation test, 14 total). The old design-note filename is covered only by the generic “other references” sweep at `:31`, not explicitly listed in its structure.

### Toolchain, Host, And Lifecycle Evidence

| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib/ test/` (`packages/warp_prism_ui`) | **Exit 1**; `Formatted 312 files (56 changed)`. |
| `dart analyze` (`packages/warp_prism_ui`) | **Exit 0**; 212 `info` lints, no errors. |
| `dart analyze` (`packages/warp_prism_host_exercise`) | **Exit 0**; no issues. |
| `flutter analyze` (`apps/catalog`) | **Exit 0**; no issues. |
| `flutter analyze` (`apps/cybercore`) | **Exit 0**; no issues. |
| `flutter test --no-pub` (`packages/warp_prism_ui`) | **Exit 1**; `+1703/-63`, all 63 are the documented frozen golden mismatches. |
| `flutter test test/ --no-pub --exclude-tags=golden` (`packages/warp_prism_ui`) | **Exit 0**; `+1692: All tests passed!`. |
| `flutter test --no-pub` (`apps/catalog`) | **Exit 0**; `+23: All tests passed!`. |
| `flutter test --no-pub` (`apps/cybercore`) | **Exit 0**; `+27: All tests passed!`. |
| `flutter test test/host_exercise/ --no-pub` (`apps/catalog`) | **Exit 0**; `+9: All tests passed!`. |
| `flutter test test/host_exercise/ --no-pub` (`apps/cybercore`) | **Exit 0**; `+8: All tests passed!`. |
| `flutter test --no-pub` (`packages/warp_prism_host_exercise`) | **Exit 0**; `+10: All tests passed!`. |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | **Exit 0**; 15/15 PASS, 0 violations. |

An additional duplicate run of the golden-excluded UI command was interrupted while emitting verbose output; it is not used as evidence. The completed `+1692` run above is the result relied upon.

- **Consumer classification**: `apps/catalog` and `apps/cybercore`. Current host-exercise widget suites prove their affected theme-selection compositions pass; the earlier `PathNotFoundException` failures do not reproduce. No Linux desktop `flutter run`, mobile-device, web, or human visual assessment was performed. The task claims no visual change; Task 1805's visual sign-off remains separate.
- **Theme values observed**: Nerazim Teal `0xFF00FFCC`, `0xFF00B894`, `0xFF007A66` at `ds_nerazim_teal_skin.dart:25,28,31`; the default Khalai Blue registry value is `0xFF2F81FF` at `prism_token_registry.dart:66-70`. Current-source values were verified; no Git preimage was used to claim historical byte identity.
- **Lifecycle/state audit**: the task delta is naming, label, comment, and test-reference work. No new controllers, timers, subscriptions, provider lifecycle, async state writes, or `setState`-after-`await` path was observed in the reviewed task changes. Riverpod `AsyncValue` and navigation state are not touched.
- **Gortex**: source-assisted reads succeeded, but later targeted Gortex searches timed out. Gortex was stopped per soft-failure policy; native source reads and scoped text search supplied the findings. This did not block deterministic validation.
- **Test side effect**: host-exercise tests call their existing persistence helper, which writes trace JSON under `.project/reports/host-exercise/traces/`. The test commands were required by Task 1839 and were run; I made no manual trace edits or cleanup. No pre-run trace hashes were captured, so any overwrite delta cannot be established here. No golden-update command was run.

### Path To 100

1. Resolve the Task 1839 zero-hit/no-rewrite conflict: either obtain an explicit owner disposition making the Task 1806 `03-review` reference an accepted historical exception, or route a separately authorized update. Do not edit Task 1806 under this task.
2. Reconcile the formatter gate: format the task-modified lines (at minimum the current Nerazim call sites flagged in `prism_theme_test.dart` and `theme_role_accent_propagation_test.dart`) and have the task owner explicitly disposition the remaining package-wide baseline. Do not run a broad formatter rewrite of unrelated files under this review.
3. Correct the builder report's `theme_matrix.dart` “comment update only” correction and Task 1839's action list to match the detailed table and live const/label changes. Correct Task 1842's per-file count and list the old-filename path explicitly if that is part of its planned sweep.
4. Resolve F3 by making the annotation internally consistent: do not call row 3 verbatim; verify row 2's source or state that its provenance is unverified. Preserve historical rows.
5. Preserve the golden baseline. The 63 failures predate Task 1839 and the golden-excluded suite passes; any refresh still requires Task 1805's owner gate. Update Task 1839's acceptance evidence only through its owner if the known baseline is accepted instead of requiring the full suite to go green.
6. Keep F4 as a non-blocking evidence improvement unless the “only change” claim is still required; if so, obtain an authorized preimage/change record.

### Task Ledger Patch Suggestion (not applied)

```markdown
### Latest Review — 2026-09-29 (Entry 2)

- **Reviewer profile**: `reviewers`
- **Score**: `48/100`
- **Verdict**: `FAIL`
- **Full report**: `.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md` (Entry 2)
- **Lane outcome**: no move; task remains in `02-doing`
- **Previous report**: Entry 1 — 45/100 FAIL

#### Current Open Blockers

- `NEW`/Serious F1: Task 1839's exact scan includes a stale skin symbol in Task 1806, while Task 1839 prohibits rewriting `03-review` and has no explicit exception for this hit.
- `EVIDENCE_GAP`/Serious F5: mandatory package formatter gate remains nonzero (56 files); touched test lines also need formatter disposition.
- `EVIDENCE_GAP`/Debt F2b: builder correction text contradicts its detailed ThemeMatrix edit table and current source.
- `PERSISTENT`/Debt F3: Black Obsidian annotation contradicts its row-3 provenance note.
- `PERSISTENT`/Improvement F4: “only change” preimage remains unavailable.

#### Resolved / verified

- F2's six-versus-seven file-count authorization is reconciled at file level.
- The 14 wire-ID occurrences and old-filename mention are explicitly accepted pending Task 1842.
- Catalog and CyberCore app/host-exercise tests pass on current rerun.
- The 63 full-suite UI golden mismatches are documented before Task 1839 (2026-09-07); no snapshot refresh was run.

#### Path-to-100 Summary

- Resolve the `03-review/1806` scope exception without editing it under Task 1839.
- Reconcile the format gate and the builder/Task1842 evidence counts.
- Correct the Black Obsidian annotation without rewriting its historical rows.
```

The task file's previous `Current Open Blockers` block (`:199-210`) still reflects Entry 1 and was not edited; the parent should reconcile it against this entry through the task owner.

## Review Entry 1 — 2026-09-29 (Independent Reviewer)

### Review Lineage

- **Current task**: Task 1839 (`1839-warp-prism-theme-brand-normalization`); current path `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`. It was in `03-review` at review intake and returned to `02-doing` after rejection.
- **Previous reports for Task 1839**: none found. The builder claim source read was `.project/reports/builders/1839-theme-brand-normalization-builder-report.md`.
- **Related report considered**: `.project/reports/reviewers/1838-real-host-revalidation-evidence-review-loop.md` — historical host-exercise evidence; its trace paths and date differ from the current failures, so it does not prove current failures were pre-existing.
- **Review mode**: initial independent review; this is not a post-fix delta re-review.

### Score And Verdict

- **Verdict**: **FAIL**.
- **Diagnostic score**: **45/100** (Serious acceptance blockers; score is diagnostic). Deductions: F1 −25, F2 −23, F3 −5, F4 −2; both Serious findings remain within their 20–30 point range and the result is below the Serious cap of 50.
- **Confidence**: **High (0.95)** that the current zero-stale-brand acceptance claim is false.
- **Lane outcome**: returned to `02-doing` under the reviewer-lane Rule 42 rejection authority after the FAIL verdict.

### Delta Summary

- **Resolved since previous review**: none; no earlier Task 1839 reviewer report was found.
- **Persistent findings**: none applicable to this first independent review.
- **Regressions**: none established; this was not a post-fix re-review.
- **New findings**: F1 and F2 are Serious acceptance blockers; F3 is Debt; F4 is Improvement. F1/F2 were visible in the builder packet, but were not previously recorded as independent-review findings.

This is the first independent review entry for Task 1839, against the Iteration 2 builder packet and current source. The requested reviewer-loop path did not exist at intake. No product source was edited and no Git/Jujutsu command was run.

## Scope and attribution

- I accept the operator's chronology correction as **user-provided historical context**: the builder used `docs/architecture/layer-contracts.md` while it existed, and a later operator-directed relocation invalidated those references. I did not independently verify the 13:36/16:49 chronology because VCS use was prohibited.
- The product-surface stale-name sweep covered `packages/`, `apps/`, `rust/`, `docs/`, `.project/architecture/`, and root `AGENTS.md`, `MISSION.md`, and `README.md`, excluding the paths specified by the task. The current Task1839 file and builder report are evidence records and necessarily mention the strings being reviewed; a separate whole-worktree scan is reported below to make this boundary explicit.
- **Affected consumers**: `apps/catalog` and `apps/cybercore` (both skin-selection call sites and their host-exercise test surfaces). Their package/app tests were run but exited 1 on trace-write `PathNotFoundException`s, so they are not clean host-suite PASS evidence. No device/emulator launch was performed; no visual/layout change is claimed by the task.
- **Lane-move correction**: Task 1839 was in `03-review` at intake. After scoring FAIL 45/100, this reviewer returned it to `.project/tasks/02-doing/` under the assigned reviewer-lane Rule 42 authority; the move completed successfully (exit 0). The earlier draft statement that no reviewer move occurred and that the actor was unknown was incorrect. A later check against the original path found it absent because the successful move had already occurred. No task content was edited and no tasklist projection was regenerated; do not move the task again.

## Per-claim epistemic status

| Claim | Status | Evidence and caveat |
|---|---|---|
| 1. Zero stale-brand occurrences except the stated records | **FAIL — contradicted** | The allowed AGENTS §7.0 and visual-contract rows were found. Outside those, the live product-surface scan finds 14 `cybercore-teal` code/test occurrences plus the old filename mention in `docs/design/nerazim-teal-theme-extension-skin.md:9`. The serialized ID is still present in `theme_matrix.dart:34` and its Catalog/CyberCore consumers. |
| 2. Hex/behavior/golden non-goals | **PARTIAL / strongly supported** | The new teal skin and archived original retain identical `#00FFCC`, `#00B894`, `#007A66` constants. Current Talon Purple, Taldarim Red, and Khalai Blue literals match the specified values. The archived/current Teal diff shows identifier/comment changes and two formatting-only differences, with no changed method logic. `ds_colors.dart` and `ds_theme.dart` contain no stale-brand hits and have mtimes before Task 1839. The 73 baseline golden PNGs had the same SHA-256 before and after this review's tests; newest baseline mtime is 2026-08-24. Without VCS, I cannot prove the entire historical changed-file set byte-for-byte. |
| 3. UI/Catalog failure classification | **PASS for current failure type; historical “pre-existing” attribution is not fully independently proven** | UI test run: 1703 passed/63 failed; a reviewer rerun captured 63 `[E]` progress lines, all containing “golden”. Catalog and CyberCore each fail with four `PathNotFoundException` trace writes. The related 1838 report records earlier successful host-exercise runs using `docs/reports/host-exercise/traces/`; those historical runs predate the current task and use different trace paths, so they do not establish when current path failures began. The before-run `-70` and exact pre-existing chronology remain unverified without a pre-task output/VCS baseline. |
| 4. Boundary harness | **PASS** | 15/15 checks; exit 0. |
| 5. Analyzers | **PASS** | All four `dart analyze` commands exited 0. `warp_prism_ui` reported 212 `info` lints but no analyzer errors. |
| 6. Orchestrator Catalog-showability edit | **PARTIAL** | `docs/governance/catalog-showability-2026-07-10.md:81` now describes the optional Nerazim teal skin and contains no stale-brand hit. The current line is semantically correct. Whether that was the *only* change to the file cannot be proved without a before-state diff; VCS was prohibited. |
| 7. Black Obsidian §6 exception annotation | **PARTIAL — row 3 is not verbatim; row 2 provenance is unverified** | The annotation exists at `docs/design/black-obsidian-visual-contract.md:183-190`. Row 2 remains presented as a historical quote, but a workspace glob for `**/*EPIC*17*` found no source file, so its exact wording could not be independently checked. Row 3's “Default sky-cyan non-rebrand tests” is a summary, not exact wording in Task 1616 (`.project/tasks/04-completed/1616-warp-prism-optional-cybercore-teal-theme-extension-skin.md:55-58`); therefore the annotation's claim that both rows are verbatim is inaccurate. |
| 8. Public barrel / brand treatments | **PASS with model distinction** | Public aliases exist for Nerazim Teal, Taldarim Red, and Talon Purple. Khalai Blue is the default `PrismColors.accentBlue` / `PrismTheme` treatment (`0xFF2F81FF`), not a separate `PrismKhalaiBlueSkin` ThemeExtension. The top-level barrel exports `prism_aliases.dart`. |

## Findings

| ID | Class | Severity | Status | Finding | Minimal path to 100 |
|---|---|---|---|---|---|
| F1 | `NEW` | **Serious** | Open | The zero-stale-brand condition is false. `cybercore-teal` remains as a serialized recipe ID and in consumers/tests: `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart:29,34`; `apps/catalog/test/host_exercise/catalog_theme_matrix_test.dart:32`; `apps/catalog/test/host_exercise/catalog_host.dart:86`; `apps/cybercore/test/host_exercise/cybercore_host.dart:31`; `apps/cybercore/test/host_exercise/cybercore_revalidation_test.dart:6,42,58,68,87,97,122,132,153` (14 live references). `ExerciseThemeRecipe.toJson/fromJson` serializes the ID (`theme_matrix.dart:38-45`). The live Nerazim design note also retains `cybercore-teal-theme-extension-skin.md` at `docs/design/nerazim-teal-theme-extension-skin.md:9`. These are not among the two user-accepted visual rows or AGENTS §7.0. | The wire ID is compatibility-sensitive; do not rename it piecemeal. Obtain an authorized migration covering all consumers or an explicit accepted exception, and remove/neutralize the old filename mention if the strict zero-hit condition remains. Until then Task 1839 cannot PASS. |
| F2 | `NEW` | **Serious** | Open | The scope-extension evidence does not reconcile. The current user-defined extension is six files; the builder report says seven were edited (`.project/reports/builders/1839-theme-brand-normalization-builder-report.md:18,22-28`). Item 1 is a comment-only change in `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart:5`, absent from Task 1839's `Where` table (`:104-118`) and not one of the compile-breaking repairs. Task 1839:53 says out-of-Where files must be reported rather than silently widened. | Parent must explicitly ratify the seventh-file edit or record the authorized scope accurately. Reviewer made no code change. |
| F3 | `NEW` | **Debt** | Open | `docs/design/black-obsidian-visual-contract.md:183-190` says both rows 2–3 are verbatim. Row 3 summarizes Task 1616's requirements rather than quoting them. Row 2's cited EPIC-17 source was not found in the current workspace, so its verbatim provenance is unknown. | Keep the historical rows if owner-approved; describe row 3 accurately as a summary and verify row 2 against the original source if it can be recovered. |
| F4 | `NEW` | **Improvement** | Open | The current Catalog-showability claim is correct, but its “only change” history cannot be independently verified under the no-VCS constraint. | Preserve a preimage/change record if exclusive-delta proof is required. |

## Failure names and classification

`flutter test --no-pub` in `packages/warp_prism_ui` exited **1**, with `+1703 -63`. All 63 `[E]` progress lines contained “golden”; `E_LINES_WITHOUT_GOLDEN=0`, and no compile/load-error pattern matched. Failing names grouped by file:

| Test file | Count | Failing cases (names from test output) |
|---|---:|---|
| `test/atoms/checkbox/ds_checkbox_test.dart` | 4 | DSCheckbox golden: unchecked, checked, indeterminate, disabled. |
| `test/goldens/ds_badge_golden_test.dart` | 12 | success label; warning count; error label; info label; filled; outlined; dot; small/medium/large; count overflow 99+; all operational states. |
| `test/goldens/ds_data_table_golden_test.dart` | 1 | default 3-column/3-row DSDataTable. |
| `test/goldens/ds_glass_panel_golden_test.dart` | 7 | simple default; custom cyan border; elevation shadow; subtle/elevated/modal blur variants; multiple panels stacked. |
| `test/goldens/ds_metric_tile_golden_test.dart` | 11 | default; healthy; degraded; error; disabled; up/down/flat trends; subtitle; compact; compact with health. |
| `test/goldens/ds_status_dot_golden_test.dart` | 20 | success, warning, error, info, neutral, pending, running, approved, rejected, promoted, archived, healthy, degraded, disabled, unverified, exposed, redacted, stale, excluded, enlarged 15-state grid. |
| `test/goldens/ds_shell_golden_test.dart` | 1 | default DSShell fixed viewport. |
| `test/goldens/ds_text_golden_test.dart` | 1 | default DSText.bodyMedium. |
| `test/goldens/prism_page_shell_golden_test.dart` | 1 | default PrismPageShell chrome. |
| `test/goldens/prism_agent_transcript_golden_test.dart` | 1 | default multi-role PrismAgentTranscript. |
| `test/goldens/prism_provider_health_matrix_golden_test.dart` | 1 | default PrismProviderHealthMatrix fixture. |
| `test/goldens/prism_map_hud_workspace_golden_test.dart` | 1 | default PrismMapHudWorkspace. |
| `test/goldens/prism_entity_intel_panel_golden_test.dart` | 1 | default PrismEntityIntelPanel. |
| `test/goldens/prism_osint_workbench_golden_test.dart` | 1 | default PrismOsintWorkbench. |
| **Total** | **63** | All are golden assertions; zero compile/load failures observed. |

The captured UI output was filtered with `rg -c '\[E\]'` (63), `rg '\[E\]' | rg -i -c 'golden'` (63), `rg '\[E\]' | rg -vi 'golden' | wc -l` (0), and `rg -i 'failed to load|error when reading|compilation failed|compile error|not found:.*\.dart|unable to load'` (no matches). The filters were applied to the output captured from `flutter test --no-pub`; the Flutter command itself exited 1.

The earlier draft abbreviated repeated prefixes with `...` while calling these names exact. The following list is corrected from a reviewer rerun's 63 `[E]` progress lines; every case name is written in full:

- `ds_checkbox_test.dart`: `DSCheckbox golden tests renders unchecked golden`; `DSCheckbox golden tests renders checked golden`; `DSCheckbox golden tests renders indeterminate golden`; `DSCheckbox golden tests renders disabled golden`.
- `ds_badge_golden_test.dart`: `DSBadge golden — semantic constructors renders success badge with label`; `DSBadge golden — semantic constructors renders warning badge with count`; `DSBadge golden — semantic constructors renders error badge with label`; `DSBadge golden — semantic constructors renders info badge with label`; `DSBadge golden — variants renders filled variant`; `DSBadge golden — variants renders outlined variant`; `DSBadge golden — variants renders dot variant`; `DSBadge golden — sizes renders small size`; `DSBadge golden — sizes renders medium size`; `DSBadge golden — sizes renders large size`; `DSBadge golden — count overflow renders 99+ for count over 99`; `DSBadge golden — operational state badges renders all operational state badges in a row`.
- `ds_data_table_golden_test.dart`: `DSDataTable golden — default state renders default DSDataTable with 3 columns and 3 rows`.
- `ds_glass_panel_golden_test.dart`: `DSGlassPanelSimple golden — variants renders default glass panel simple`; `DSGlassPanelSimple golden — variants renders with custom border color (cyan glow)`; `DSGlassPanelSimple golden — variants renders with elevation shadow`; `DSGlassPanel golden — variants with blur renders subtle variant`; `DSGlassPanel golden — variants with blur renders elevated variant`; `DSGlassPanel golden — variants with blur renders modal variant`; `DSGlassPanel golden — compositional layout renders multiple panels stacked`.
- `ds_metric_tile_golden_test.dart`: `DSMetricTile golden — default and health states renders default metric tile (cyan accent)`; `DSMetricTile golden — default and health states renders healthy state`; `DSMetricTile golden — default and health states renders degraded state with status dot`; `DSMetricTile golden — default and health states renders error state with animated dot`; `DSMetricTile golden — default and health states renders disabled state`; `DSMetricTile golden — trend indicators renders upward trend`; `DSMetricTile golden — trend indicators renders downward trend`; `DSMetricTile golden — trend indicators renders flat trend`; `DSMetricTile golden — subtitle renders with subtitle`; `DSMetricTile golden — compact variant renders compact metric tile`; `DSMetricTile golden — compact variant renders compact metric tile with health`.
- `ds_status_dot_golden_test.dart`: `DSStatusDot golden — operational states renders success state`; `DSStatusDot golden — operational states renders warning state`; `DSStatusDot golden — operational states renders error state`; `DSStatusDot golden — operational states renders info state`; `DSStatusDot golden — operational states renders neutral state`; `DSStatusDot golden — operational states renders pending state`; `DSStatusDot golden — operational states renders running state`; `DSStatusDot golden — operational states renders approved state`; `DSStatusDot golden — operational states renders rejected state`; `DSStatusDot golden — operational states renders promoted state`; `DSStatusDot golden — operational states renders archived state`; `DSStatusDot golden — operational states renders healthy state`; `DSStatusDot golden — operational states renders degraded state`; `DSStatusDot golden — operational states renders disabled state`; `DSStatusDot golden — operational states renders unverified state`; `DSStatusDot golden — operational states renders exposed state`; `DSStatusDot golden — operational states renders redacted state`; `DSStatusDot golden — operational states renders stale state`; `DSStatusDot golden — operational states renders excluded state`; `DSStatusDot golden — enlarged for visibility renders all 15 states in a grid (16px)`.
- Singleton suites: `DSShell golden — default state renders default DSShell with fixed viewport`; `DSText golden — default state renders default DSText.bodyMedium`; `PrismPageShell golden — default state renders default PrismPageShell content chrome`; `PrismAgentTranscript golden — default state renders default multi-role PrismAgentTranscript`; `PrismProviderHealthMatrix golden — default state renders default PrismProviderHealthMatrix fixture`; `PrismMapHudWorkspace golden — default state renders default PrismMapHudWorkspace with HUD regions`; `PrismEntityIntelPanel golden — default state renders default agent dossier PrismEntityIntelPanel`; `PrismOsintWorkbench golden — default state renders default idle PrismOsintWorkbench fixture tools`.

Catalog exited **1** with four `PathNotFoundException` failures: three 1838 revalidation runs (SMOKE desktop, CRAWL desktop, SMOKE laptop) and the seeded FUZZ replay. Each failed to write a JSON trace under `apps/catalog/docs/reports/host-exercise/traces/`; the revalidation cases use `khalai-blue`. CyberCore's extra `flutter test --no-pub` run also exited **1** with four `PathNotFoundException` trace writes under `apps/cybercore/docs/reports/host-exercise/traces/`. These are host-exercise output-path failures, not brand-resolution failures. Their precise pre-existing chronology is not independently baselined here.

## Commands and exits

Exact stale-sweep command used on product surfaces (exit 0, matches found):

```bash
rg -n -i --no-heading 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' packages apps rust docs .project/architecture \
  --glob '!**/.archive/**' --glob '!**/.dart_tool/**' --glob '!**/build/**' \
  --glob '!**/rust/target/**' --glob '!**/.project/tasks/04-completed/**' \
  --glob '!**/.project/changelog/**' --glob '!CHANGELOG*.md' \
  --glob '!**/.project/maps/graph.json' --glob '!**/.project/maps/GRAPH_REPORT.md'
```

Root instruction surfaces were checked separately with the same regex: `rg -n -i --no-heading 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' AGENTS.md MISSION.md README.md`; `MISSION.md`/`README.md` returned no matches (exit 1), and the AGENTS hits were confined to §7.0.

The matching-token count was obtained with this exact command (18):

```bash
rg -o -i --no-heading 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' packages apps rust docs .project/architecture \
  --glob '!**/.archive/**' --glob '!**/.dart_tool/**' --glob '!**/build/**' \
  --glob '!**/rust/target/**' --glob '!**/.project/tasks/04-completed/**' \
  --glob '!**/.project/changelog/**' --glob '!CHANGELOG*.md' \
  --glob '!**/.project/maps/graph.json' --glob '!**/.project/maps/GRAPH_REPORT.md' | wc -l
```

The exact hyphen-ID count used:

```bash
rg -o -i --no-heading 'cybercore-teal' packages apps rust docs .project/architecture \
  --glob '!**/.archive/**' --glob '!**/.dart_tool/**' --glob '!**/build/**' \
  --glob '!**/rust/target/**' --glob '!**/.project/tasks/04-completed/**' \
  --glob '!**/.project/changelog/**' --glob '!CHANGELOG*.md' \
  --glob '!**/.project/maps/graph.json' --glob '!**/.project/maps/GRAPH_REPORT.md' | wc -l
```

It returned 16. The broad hidden-tree sweep used the same term regex with `--hidden` and the same exclusions (plus `.git` metadata); it returned 629 tokens across 61 files because task/report/memory/generated-map artifacts are also present.

| Command | Working directory / result |
|---|---|
| Stale-brand `rg -n -i` over `packages apps rust docs .project/architecture` with stated artifact exclusions | Repo root; exit **0** (matches found). 17 matching lines outside AGENTS, including the two designated visual rows and 15 other live matches. |
| `rg -o -i 'cybercore-teal'` over product paths | Repo root; exit **0**, 16 matches (14 live code/test IDs, one new-doc old filename, one match in an accepted visual-record row). |
| `rg -n -i` over `AGENTS.md` | Repo root; 10 token matches, all in §7.0 (accepted). |
| `rg -n -F 'Default sky-cyan non-rebrand tests'` against Task 1616 | Repo root; exit **1** (phrase absent; source lines 55–58 use different wording). |
| `diff -u .archive/packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart packages/warp_prism_ui/lib/src/tokens/ds_nerazim_teal_skin.dart` | Repo root; exit **1** (expected rename/doc/format diffs; the three teal hex constants are unchanged). |
| `flutter test --no-pub` | `packages/warp_prism_ui`; exit **1**, 1703 pass / 63 golden failures. |
| `flutter test --no-pub` | `apps/catalog`; exit **1**, four PathNotFoundException failures. Repeated to capture exception paths; same classification. |
| `flutter test --no-pub` | `apps/cybercore`; exit **1**, four PathNotFoundException failures (extra verification). |
| `set -o pipefail; flutter test --no-pub 2>&1 | rg '\[E\]'` | `packages/warp_prism_ui`; exit **1**, reviewer rerun emitted all 63 full failing-case labels. |
| `dart analyze` | `packages/warp_prism_ui`; exit **0**, 212 `info` lints, no errors. |
| `dart analyze` | `packages/warp_prism_host_exercise`; exit **0**, no issues. |
| `dart analyze` | `apps/catalog`; exit **0**, no issues. |
| `dart analyze` | `apps/cybercore`; exit **0**, no issues. |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | Repo root; exit **0**, 15/15 PASS. |

Golden baseline census: 73 baseline PNGs; SHA-256 before and after this review's tests was identical: `14fa4474d08e6155cfe802e50d87eabbf75ef9e689172c69c74107c40189e36e`; newest baseline mtime was 2026-08-24. No `--update-goldens` command was run. This proves no baseline golden change during this review and strongly supports no Task-time refresh, but no VCS preimage is available to prove historical byte identity absolutely.

## Scope caveat and path to 100

- A broader hidden-tree scan applying the listed exclusions returned 629 raw matches across 61 files, including task/report/memory and generated-map artifacts. Those are evidence/administrative surfaces, not product brand surfaces; they necessarily record the old strings. The product-surface findings above remain sufficient to FAIL even without counting those records. The requested review report itself is also an evidence artifact.
- Exact broad-scan command (run before creating this review report):

  ```bash
  rg -n --hidden -i --no-heading 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' . \
    --glob '!**/.git/**' --glob '!**/.archive/**' --glob '!**/.dart_tool/**' \
    --glob '!**/build/**' --glob '!**/rust/target/**' \
    --glob '!**/.project/tasks/04-completed/**' --glob '!**/.project/changelog/**' \
    --glob '!CHANGELOG*.md' --glob '!**/.project/maps/graph.json' \
    --glob '!**/.project/maps/GRAPH_REPORT.md'
  ```

- To reproduce the pre-report census after this report existed, the token/file count commands used the same exclusions plus an explicit exclusion for this new report. Both pipelines exited **0** and returned **629 tokens** / **61 matching files**:

  ```bash
  rg -o --hidden -i --no-heading 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' . \
    --glob '!**/.git/**' --glob '!**/.archive/**' --glob '!**/.dart_tool/**' \
    --glob '!**/build/**' --glob '!**/rust/target/**' \
    --glob '!**/.project/tasks/04-completed/**' --glob '!**/.project/changelog/**' \
    --glob '!CHANGELOG*.md' --glob '!**/.project/maps/graph.json' \
    --glob '!**/.project/maps/GRAPH_REPORT.md' \
    --glob '!**/.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md' | wc -l

  rg -l --hidden -i 'DSCyberCoreTealSkin|PrismCyberCoreTealSkin|CyberCoreTeal|cybercore_teal|cybercore-teal|CyberCore Teal|Protoss Gold|ProtossGold|Nerazim Green' . \
    --glob '!**/.git/**' --glob '!**/.archive/**' --glob '!**/.dart_tool/**' \
    --glob '!**/build/**' --glob '!**/rust/target/**' \
    --glob '!**/.project/tasks/04-completed/**' --glob '!**/.project/changelog/**' \
    --glob '!CHANGELOG*.md' --glob '!**/.project/maps/graph.json' \
    --glob '!**/.project/maps/GRAPH_REPORT.md' \
    --glob '!**/.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md' | wc -l
  ```

- The requested source scan covered product code/tests/docs plus AGENTS/mission/architecture; `.project/tasks/03-review` and `.project/reports/builders` were read as evidence, not treated as customer-facing brand surfaces.
- Task 1839 was initially read from `03-review`; after the FAIL 45/100 verdict, this reviewer returned it to `02-doing` under Rule 42 reviewer-lane authority (successful move, exit 0). A later check against the old path found it absent because that move had already completed. No task-content edit or generated tasklist sync was performed.
- **Path to 100:** resolve the `cybercore-teal` wire-ID policy and its consumers in authorized scope; reconcile the seven-file Iteration 2 list with the six-file authorization; correct row 3's provenance description and verify or qualify row 2's source; then re-run the explicit stale scan. Do not refresh goldens as part of this remediation.

## Task Ledger Patch Suggestion

```markdown
### Latest Review — 2026-09-29

- **Reviewer profile**: `reviewers`
- **Score**: `45/100`
- **Verdict**: `FAIL` (`REJECTED_TO_DOING`)
- **Full report**: `.project/reports/reviewers/1839-theme-brand-normalization-review-loop.md`
- **Lane outcome**: returned from `03-review` to `02-doing` by the reviewer under Rule 42 authority
- **Current task path**: `.project/tasks/02-doing/1839-warp-prism-theme-brand-normalization.md`
- **Previous reports**: none for Task 1839

#### Current Open Blockers

- `NEW`/Serious F1: live serialized `cybercore-teal` identifiers and old filename reference violate the stated zero-stale condition.
- `NEW`/Serious F2: seven Iteration 2 edits do not reconcile with the six-file scope extension.
- `NEW`/Debt F3: §6 annotation overstates row 3 as verbatim; row 2's original source was not located for independent verification.
- `NEW`/Improvement F4: “only change” claim lacks a preimage under the no-VCS constraint.

#### Path-to-100 Summary

- Resolve the wire-ID migration/exception policy and reconcile the authorized file count.
- Correct row-3 provenance language and verify or qualify row 2's source; preserve the historical record.
- Re-run the scoped zero-stale scan and required validation after authorized changes.
```
