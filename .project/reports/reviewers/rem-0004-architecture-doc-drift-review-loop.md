# Review loop — rem-0004: architecture-doc drift corrections

- **Task**: rem-0004 (`01-open/rem-0004-architecture-doc-drift-corrections.md`)
- **Mode**: independent review on explicit user dispatch (fresh session; no lane authority exercised; no lane move performed)
- **contract_revision**: task file as executed 2026-10-11 (Completion Evidence filled; Exit Conditions unchecked) + live tree 2026-10-16
- **Reviewer**: Implacable Flutter Reviewer (fresh session; not the executor; zero product mutations — read-only reads plus analyzer/test runs only)
- **Counterpart journals**: builder journal N/A (none exists under `.project/reports/builders/` for rem-0004); prior reviewer report: none (this is Round 1)

## Current State

- **verdict**: PASS
- **score**: 95/100 (diagnostic only; does not gate acceptance)

## Open Items (all non-blocking; routed to parent, none requires rem-0004 remediation)

- O1 — Root generated changelog surfaces were rebuilt by both rem closeouts pre-acceptance (parent/engine ownership question).
- O2 — Gap-matrix §1 "Zero consumer" row is unqualified vs in-tree path-deps (follow-up clarification; out of rem-0004 contract).
- O3 — `host_config.dart:21` dangling doc ref (rem-0005 residue; tracked in rem-0005 report; listed here only for cross-task visibility).

## Round 1 — initial independent review (2026-10-16)

### Verdict: PASS

All four contracted drift sites are corrected, verified against live source and layer law. Writeset discipline held (docs + changelog + task file only; `MISSION.md` untouched by this task; no source/test/config touched). Completion Evidence is accurate on every checkable claim; two disclosed process deviations are real but immaterial to content correctness.

### Diagnostic score: 95/100

| Deduction | Points | Basis |
|---|---|---|
| Shared generated-surface mutation pre-acceptance (engine-default closeout rebuild; disclosed, archived, since superseded) | −4 | O1; ownership routes to parent/engine, not builder remediation |
| Artifact hygiene (Exit Conditions boxes unchecked despite filled evidence; git validation substituted by mtime after permission deny) | −1 | Cosmetic; reviewer closed the git loop with the original commands |
| Adjacent drift / contention handling | −0 | Exemplary (re-verified after neighbor pass; recorded contention + limitation honestly) |

### Diff ownership (this task vs neighbors)

| File / surface | Owner | Evidence |
|---|---|---|
| `.project/architecture/layer-contracts.md` §2 + §1 note | rem-0004 (diagram + cross-ref) | mtime Oct 11 15:54; §10 (rem-0001) untouched, 16-row table intact |
| `.project/architecture/package-topology.md` §3.2 rule 9 carve-out | rem-0004 | mtime Oct 11 15:39 |
| `.project/architecture/runtime-consumer-audit.md` v2 annotations | rem-0004 | mtime Oct 11 15:43 |
| `.project/architecture/cross-consumer-gap-matrix.md` resolved rows + header | rem-0004 | mtime Oct 11 15:56 |
| `layer-contracts.md` §2 label-indent reformat ~15:54 | attributed to rem-0005's session (per rem-0004 evidence; NOT in rem-0005's Where table; unrecorded in rem-0005's evidence) | cosmetic; direction verified intact (see V1) |
| Root `CHANGELOG.md` / `CHANGELOG-FULL.md` / `.project/changelog/index.md` / `views/*` | shared engine effect of BOTH rem closeouts (parent-owned surface) | archives at both timestamps; centrally rebuilt 2026-10-15 (superseding) |

### Per-site verification (fresh evidence, current session)

**V1 — §2 diagram direction (layer-contracts.md:31–52).** PASS.
Direction now reads `bindings → ui` / `bindings → interaction` / `bindings → runtime`: `◄` heads face `ui` (L32) and `interaction` (L34), bracket spine uniform at column 31 (own codepoint audit), chain `testkit → runtime`, `adapter_frb → testkit (dev)`, `adapter_frb → warp_bridge_frb → warp_bridge_core` coherent. §1 cross-reference note (L61–73) quotes governing rows accurately against the live matrix (L16 ui MUST NOT incl. `bindings`; L19 bindings MAY depend on `ui`+`interaction`+`runtime`).
Source ground truth re-verified: `packages/warp_prism_ui/pubspec.yaml` full-read — `dependencies:` is Flutter SDK only (zero `warp_prism_*`, zero `bindings`); `warp_prism_interaction` appears ONLY under `dev_dependencies:` (L18–19). `packages/warp_prism_bindings/pubspec.yaml` — `dependencies:` lists `warp_prism_interaction`, `warp_prism_runtime`, `warp_prism_ui` (L14–19). No other package pubspec references `bindings`. rem-0001 §10 table intact (all 16 rows read).

**V2 — package-topology.md rule 9 carve-out (L73–86).** PASS.
Original rule text preserved verbatim (L73); appended carve-out quotes current law rather than paraphrasing (§1 row-1 MAY + "consume only its own tokens/theme + interaction in dev"; §2 "dev dependency" note). Matches `layer-contracts.md:16` and `:56–57` exactly; matches the ui pubspec reality above.

**V3 — runtime-consumer-audit.md v2 citations.** PASS.
`rg -n "layer-contracts-v2"` returns exactly the claimed **11 lines** (L6, L8, L9, L69, L79, L104, L108, L109, L110, L131, L142); every one carries either a `current owner:` repoint or an explicit historical/SUPERSEDED marker, plus the `law baseline updated 2026-10-11` note (L9). Repoint mapping verified structurally against v2 headings (v2 §2 = Canonical Layer Contract Matrix → §1; v2 §3.2 = Explicit Lifecycle Tags → §9; v2 §4.3 = Model Ownership Rule → §7; v2 §5 = Boundary Enforcement & Harness Matrix → §10). Current-law quotes verified verbatim against layer-contracts.md (§1 runtime MUST NOT row; §9 PROVEN row; §7 Offset rule; §10 16-row table).

**V4 — gap-matrix resolved UNKNOWNs.** PASS, no broader than the reviewed in-repo evidence.
Tempest/Sentry §2 rows (L56–57), §6 rows (L160–161), §3 row-28 Tempest cell (L102), header note (L17–22) all state resolved answers with method + date, prior values preserved in place, frontmatter `date: 2026-09-27` and AMEND history intact. Wording matches the parent-verified, independently-reviewed in-repo carrier (`future-capability-program-inventory-2026-10-10.md` §0.1/§2: Tempest manifests+lockfile+rg-exit-1; Sentry Rust-only/3-crates/no-FRB/zero-matches). Residual UNKNOWNs are all explained: §3 Sentry-capability cells (covered by the L64 note — no surface exists to inspect), §7 checklist criterion. Per dispatch boundary, no sibling-workspace re-scan was performed; the resolutions rest on the reviewed carrier and stay within its scope.

**V5 — Finding 5 protected-surface record.** Verified accurate where checkable; no `MISSION.md` edit by this task.
Observatory first-hand claims all confirm: `version: 1.0.0+1`, `flutter_riverpod`/`graphview`/`fl_chart`/`go_router` present, `warp_prism_ui` path dep under `dependencies:`, `warp_prism_host_exercise` under `dev_dependencies:`, `router.dart` exists with 17 GoRoute/GoRouterState matches. `MISSION.md` bulk working-tree diff vs HEAD is the Sep-27/28 epoch-reset rewrite (1849→349 lines), not Oct-11 work; the Finding-5-cited withholding language is intact verbatim today; last mtime (Oct 15) belongs to a later actor. **Correction the parent must absorb**: the carrier's F15 parenthetical ("observatory declares no `warp_prism_*` dep") is factually wrong — observatory production-depends on `warp_prism_ui` (49 lib files import it). rem-0004's Finding 5 record is the correct one. F15's *conclusion* (zero-EXTERNAL-adoption unaffected) still holds — observatory is in-tree, not external.

**V6 — writeset / validation commands (reviewer ran the originals).**
`git status --porcelain -- .project/architecture/` → 3 M + 3 ??: the four rem-0004 files are exactly the Oct-11-touched set (2 M + 2 ?? — `layer-contracts.md` and the gap matrix are untracked vs old HEAD, which confounds the task's "exactly 4 modified" expectation but confirms the touch-set via mtime); the other two entries (`layer-contracts-v2.md` M, `warp-prism-test-failure-baseline.md` ??) are Sep-28 pre-existing, not rem-0004. No source/test/config path touched. Changelog entry exists and is indexed (`.project/changelog/index.md:10`); root `CHANGELOG.md` carries both rem entries ( consultation lines 31/53).

### Findings

**Task-specific: none blocking.** All contracted Test Requirements satisfied with fresh evidence.

**Cross-cutting / NEW (for parent triage, not rem-0004 remediation):**

- **N1 — Changelog-engine closeout rebuilds parent-owned generated surfaces (shared, disclosed).** Both rem closeouts rebuilt root `CHANGELOG.md`/`CHANGELOG-FULL.md`/`index.md`/`views/*` (archives `.archive/changelog/CHANGELOG-before-rebuild-20261011-154708.md` and `-155639.md` confirm both). rem-0004 disclosed it; rem-0005 used the same engine path without restating it. Current root changelog was centrally rebuilt 2026-10-15, superseding byte state. Material consequence: LOW (regenerable + archived + superseded). Ownership question for parent: the task contract *requires* a changelog entry while the code-quality gate says workers don't publish generated surfaces and parents rebuild centrally once per wave — the engine's default closeout does the rebuild anyway. No redesign proposed (per dispatch); decision belongs to parent/engine owner.
- **N2 — `layer-contracts.md` §2 label-indent touched from rem-0005's session window (shared, unattributed in rem-0005).** mtime 15:54 corroborates timing. Current-geometry audit shows zero content effect (direction, spine, chain all correct). No action; recorded for writeset-attribution hygiene.
- **N3 (NEW) — Gap-matrix §1 "Consumers: Zero. No consumer depends on any `warp_prism_*` package" is unqualified vs in-repo reality.** All three in-tree labs production-depend on `warp_prism_ui` (catalog additionally on runtime/bindings/adapter_frb; all three dev-dep host_exercise). The row's intended scope is clearly *external* adoption (consistent with the "dominant fact" paragraph and F15's conclusion), but the text doesn't say so, and F15's parenthetical justification is wrong (see V5). Out of rem-0004's contracted rows — follow-up clarification task recommended, not rem-0004 remediation. SCOPE note, not FAIL.
- **N4 (minor)** — Exit Conditions boxes left unchecked while Completion Evidence is complete (inverse pattern in rem-0005). Cosmetic; lane governs status.

### Remediation targets

None mandatory — verdict is PASS. Non-blocking suggestions (parent-owned): decide N1 engine/closeout ownership; file a micro-task for N3 §1-row scoping (+ one-line `host_config.dart:21` doc reword, see rem-0005 report O3); triage the `dart test` VM/FFI environment defect (see rem-0005 report).

### Commands run (reviewer, fresh 2026-10-16)

| Command | Result |
|---|---|
| `git status --porcelain -- .project/architecture/` / `git diff --stat -- .project/architecture/` | exit 0; 3 M + 3 ?? as analyzed above |
| `rg -n "layer-contracts-v2" .project/architecture/runtime-consumer-audit.md` | 11 lines, all annotated (exit 0) |
| `rg -n "UNKNOWN\|unverified" .project/architecture/cross-consumer-gap-matrix.md` | residuals as analyzed (exit 0) |
| full reads: 4 architecture docs, 6 package pubspecs (ui read in full), observatory/catalog/cybercore pubspecs, carrier report §0.1/§2/§10, both task files, both changelog entries, changelog index | all findings above sourced to file:line |
| `rg -l "package:warp_prism_ui" apps/observatory/lib/` | 49 importing files (F15 correction) |
| `rg -c "GoRoute\|GoRouterState" apps/observatory/lib/app/router.dart` | 17 (matches Finding 5) |
| codepoint geometry audit of layer-contracts.md L31–52 (python) | spine col 31 uniform; `◄` heads at ui/interaction; chain coherent |

### Old-tmp triage (parent use)

No scratch was created by this review (analysis stayed in pipes/tool results; `.archive/tmp/rem-0004-0005-review-current/` was not needed and not created). Pre-existing files relevant to this bundle's evidence: `.archive/tmp/rem-0005-retry.sh`, `.archive/tmp/rem-0005-app-tests.sh` (rem-0005 method scripts; raw `tmp/rem-0005-*.txt` outputs were NOT preserved — see rem-0005 report). Other `.archive/tmp/` contents (1840/1843/1844 artifacts, reviewer logs) are unrelated to this bundle. Repo-root `tmp/` contains no rem-0004/0005 outputs. `.opencode/tmp/` is empty.

### Skill attestation (truthful)

Loaded and applied: `code-quality` (bundled-review per-task verdicts + evidence isolation; verdict-gate: score never chose verdict), `flutter` (source-reality-first, project commands, no phantom validation), `code-quality/sub-skills/documentation-audit` (doc-vs-implementation accuracy method), `code-quality/workflows/sw-code-quality-review-flutter` + `gt-global-subagent-review` (claim-first verdict protocol), report-lineage (additive per-task loop files). Rules applied: 30 (claim-scoped evidence, epistemic honesty on delegated controls), 33 (no nested delegation — no child launched), 40/41/42 succession (lane neutrality; no lane move). `flutter` lifecycle/state subskills were deliberately NOT loaded — neither task touches widget/controller/Riverpod lifecycle. No score-route, no remediation, no VCS/lane/changelog/harness edits performed.

### Cross-Task Blast Radius (shared rem-0004/rem-0005 section; duplicated verbatim in both loop files)

- **Shared files**: `layer-contracts.md` (rem-0004 owns the §2/diagram+note edit; rem-0005's session made a cosmetic label-indent pass at 15:54 — verified zero content effect); root `CHANGELOG.md` / `CHANGELOG-FULL.md` / `.project/changelog/index.md` / `views/*` (BOTH closeouts rebuilt them; parent-owned generated surface; archived at both timestamps; centrally rebuilt Oct 15 — no residual conflict); `.project/changelog/index.md` rows for both tasks coexist additively (lines 9–10).
- **Shared interfaces/types/constructors**: NONE. rem-0004 is docs-only; rem-0005 removed three zero-referrer exports (barrel file-set unchanged). No coupling.
- **Generated surfaces**: changelog views/index as above; no tasklist/index edits by either task.
- **Regression risk if only one task is accepted**: NONE either way — the tasks are content-independent (doc corrections vs dead-export removal); neither depends on the other's output. The only shared exposure is the changelog-engine rebuild behavior (process, already superseded).
- **Serial vs parallel residual**: no remaining serial work between these two tasks. Open follow-ups (N1 engine ownership, N3 §1-row scope, host_config:21 doc nit, `dart test` env defect) are independent micro-items for parent triage.
- **Diff ownership map**: 4 architecture docs → rem-0004; 3 host_exercise model files → rem-0005; `host_config.dart` → untouched by both (residue recorded); generated changelog surfaces → engine/parent shared effect.
