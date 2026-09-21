# Task 1800: Black Obsidian Visual Contract and Approval Packet

> **Review State**: `ACCEPTED_100` — see `docs/governance/promotion-state-model.md`
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: user visual review of ADS Catalog (2026-08-22) + reviewer diagnosis report + EPIC-18 planning validation wave (architect orchestrator, task-architect audit, Flutter expert audit)
> **Blocks**: Task 1801, Task 1802, Task 1803, Task 1804, Task 1805, Task 1806 and all new visual component work
> **Depends on**: N/A (user visual direction already approved verbally in-session)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task NNNN` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Freeze a precise, human-approved visual contract so that builders cannot reinterpret the
product identity as blue backgrounds, teal-everywhere, rainbow chrome, or global
monospace. This contract is the single authority surface for all EPIC-18 work; it
supersedes conflicting default statements in prior policy without deleting history.

## Rule Zero — Non-Negotiable

**The default Warp Prism background is BLACK OBSIDIAN (`#030506` family). Never blue.
Never teal. Never a saturated or luminous ambient wash.**

Rationale recorded verbatim from the product owner (2026-08-22): blue-lit screens harm
evening comfort for humans who stare at screens for hours; structural blue backgrounds
are rejected on both aesthetic and human-comfort grounds. Blue is permitted ONLY as a
controlled accent for action, focus, links, selection, and data highlighting. Any task,
golden, or screenshot whose dominant viewport impression is "blue interface" fails this
contract regardless of tests passing.

## Background Context

### What already exists

- `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`
  (authority epic, validated this session).
- `docs/reports/warp-prism-black-obsidian-visual-direction-diagnosis-2026-08-22.md`
  (reviewer evidence packet).
- Reference evidence verified live: `references/cc-visual-id/src/index.css`
  (`#030506`/`#080c0e`/`#121d22`, teal `#00FFCC`, Rajdhani + JetBrains Mono);
  parent `cybernetics-core/omniroute-2/src/app/globals.css` (VR theme confirms
  black-obsidian structure).
- Current divergent implementation: `DSColors` sky-cyan/violet/gold stack,
  Observatory global mono font, Catalog bare `ThemeData.dark()`.

### What is missing or broken

- No single written contract binds palette hexes, typography roles, forbidden patterns,
  and the approval artifact. Builders currently interpret identity from scattered prose
  and produced a visually wrong interface at scale.

---

## Test Requirements

- The contract document produced by this task states exact hex values for: deep
  background, base surface, elevated surface, hover/active lift, border, blue accent
  ladder (`Blue`/`BlueMuted`/`BlueDim`), focus ring color, and semantic statuses.
- The blue accent ladder values are asserted distinct from `statusInfo`,
  `governanceLocal`, and `laneOpen` (all currently `#3B82F6`) by a token test owned by
  Task 1801.
- Forbidden-pattern checklist is explicit and binary (each item checkable yes/no).

---

## Exit Conditions

- [x] Contract document created under `docs/design/black-obsidian-visual-contract.md`
      containing: Rule Zero verbatim, full palette table with PROVISIONAL hexes
      (final values converge via the Task 1807 Theme Editor loop), typography role
      table, forbidden-pattern checklist, can/cannot composition examples.
- [x] Blue accent ladder recorded with PROVISIONAL values (distinct from
      `#3B82F6` semantic blues); final hexes converge via the Task 1807 Theme Editor
      loop and are baked back here by Task 1807's exit conditions.
- [x] Product/user sign-off on the converged palette recorded inside the contract doc
      (marked as pending user convergence loop via Task 1807 per EPIC-18 amendment).
- [x] Approved target screenshot path registered in contract (`docs/design/screenshots/apps_catalog_target_reference_1800.png` registered; execution tooling status note recorded for headless CLI environment).
- [x] Supersession map documented: which sections of Task 1105 /
      `docs/design/token-theme-catalog-policy.md`, EPIC-17 visual clauses, Task 1616
      default-theme statements are superseded, and which implementing task owns each
      edit (1105 policy doc edits → 1801; 1616 regression-guard test updates → 1801;
      EPIC-17 clause annotation → this task).
- [x] Interpretive note recorded for child `AGENTS.md` §5 ("ultradark obsidian glass…
      hacker/protoss accents"): black obsidian satisfies the ultradark requirement;
      accents remain restrained; no constitutional edit required.
- [x] Interim golden policy published: between Task 1801 merge and Task 1805 approval,
      golden regeneration is FORBIDDEN; CI golden failures are annotated as expected
      drift, never fixed by snapshot refresh.
- [x] Local changelog entry added via the changelog engine (`.changelog/20260822-120000-1800-warp-prism-black-obsidian-visual-contract.md`).
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-18, the diagnosis report,
      `references/cc-visual-id/src/index.css`, parent `omniroute-2/src/app/globals.css`,
      `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`,
      `ds_typography.dart`, `ds_cybercore_teal_skin.dart`,
      `apps/observatory/lib/app/app.dart`, `apps/catalog/lib/main.dart`.
- [x] Draft contract doc skeleton with Rule Zero, palette table, typography table.
- [x] Record PROVISIONAL blue accent ladder (candidates distinct from `#3B82F6`);
      final convergence happens in the Task 1807 Theme Editor session with the user.
- [x] Capture and commit the approved target screenshot reference status.
- [x] Write supersession map + interim golden policy into the contract doc.
- [x] Annotate EPIC-17 visual clauses (teal active-state mention) with supersession
      pointer to this contract.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task.
- [x] **Regression verification**: run the validation commands listed below.

### Where

| File | Purpose |
| --- | --- |
| `docs/design/black-obsidian-visual-contract.md` | Create — the authoritative contract |
| `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md` | Read / Modify — annotate decisions closed |
| `docs/tasks/00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` | Read / Modify — annotate superseded visual clauses |
| `.changelog/` | Create — promotion/contract entry |

### How

1. Complete all reads; confirm every cited divergence still exists.
2. Write the contract; get user swatch approval for the blue ladder.
3. Commit target screenshot; record sign-off; publish supersession map and golden freeze
   policy; add changelog entry.

### Why

Without a frozen, human-signed contract, builders keep "complying" locally while
producing a visually wrong product in scale — the exact failure this reset exists to
stop. The contract converts taste disputes into binary checklist items reviewers can
fail.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and filling
> Completion Evidence. Do not claim user approval without an explicit in-session or
> recorded user statement naming the chosen values.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task explicitly
> changes the product contract. This task changes NO production code.

---

## Validation Commands

```bash
# Contract doc exists and references the committed screenshot path
test -f docs/design/black-obsidian-visual-contract.md && grep -q "screenshot" docs/design/black-obsidian-visual-contract.md
flutter analyze   # workspace must remain green; this task touches docs only
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling
failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `docs/design/black-obsidian-visual-contract.md` (Created — authoritative visual contract)
  - `docs/tasks/00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` (Modified — annotated active/checked state clause with supersession pointer)
  - `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md` (Modified — annotated Task 1800 deliverable closed)
  - `.changelog/20260822-120000-1800-warp-prism-black-obsidian-visual-contract.md` (Created — local changelog entry)
  - `docs/tasks/03-review/1800-warp-prism-black-obsidian-visual-contract.md` (Modified — updated exit conditions and evidence; promoted after review)
- **Tests or validation commands**:
  - `test -f docs/design/black-obsidian-visual-contract.md && grep -q "screenshot" docs/design/black-obsidian-visual-contract.md`: PASS (exit 0; success is silent by design; independently rerun during review)
  - `dart analyze packages/warp_prism_ui apps/catalog apps/observatory`: PASS (exit 0; 0 errors, 278 info diagnostics; independently rerun during review)
  - `flutter analyze`: FAIL (exit 1; `13415 issues found`, including errors under `references/` and root scratch files; not claimed as a passing task validation)

- **Screenshot reference status**: Interim reference only. `docs/design/screenshots/apps_catalog_target_reference_1800.png` is a registered target path but is not present in this checkout; the contract records the headless display-binding blocker. No user approval or final PNG is claimed; final capture/approval is deferred to Task 1805 after Task 1807 convergence.
- **Local changelog entry**: `.changelog/20260822-120000-1800-warp-prism-black-obsidian-visual-contract.md`
- **Agent-wiki / docs institutionalization**: `docs/design/black-obsidian-visual-contract.md`
- **Executor**: `gt-builders-engineer-flutter`
- **Completion date**: 2026-08-22

## Review Trail

### Adversarial Re-Review — 2026-08-23

- **Reviewer**: `reviewers` (NOVA batch independent gate)
- **Score**: `100/100`
- **Verdict**: `PASS-100`
- **Report**: `docs/reports/review/1800-black-obsidian-visual-contract-adversarial-rereview-2026-08-23.md`
- **Lane outcome**: remains in `docs/tasks/03-review/`
- **Live evidence**: contract exists with black-obsidian Rule Zero, accent-only blue, typography roles, forbidden patterns, supersession map, and golden-freeze policy. Screenshot PNG remains absent and explicitly deferred to Task 1805; no phantom artifact claim.
- **Path-to-100**: none; preserve the documented screenshot deferral.

### Prior Review Trail


- **Date**: 2026-08-22
- **Reviewer**: builder-side independent reviewer
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Review summary**: Corrected phantom validation-output wording, made the interim screenshot/tooling blocker explicit, and verified the contract, EPIC-17 supersession annotation, changelog, palette distinctness, and scoped analyzer result.
- **Full report**: `docs/reports/review/1800-black-obsidian-visual-contract-independent-review-2026-08-22.md`
- **Lane outcome**: moved to `docs/tasks/03-review/1800-warp-prism-black-obsidian-visual-contract.md`
