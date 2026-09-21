# Task 1522 Independent Adversarial Review — Keyboard / Scale / Risk Toast Optional Pack

- **Review date**: 2026-08-23
- **Reviewer**: `reviewers`
- **Previous report**: `docs/reports/review/formal-2026-07-18-task-1522.md` (100/100)
- **Current score**: **88/100**
- **Verdict**: **REJECT — route to `docs/tasks/02-doing/`**

## Contract and accessibility proof

- Keyboard cheatsheet has real Escape, backdrop, and dismiss callbacks; modal semantics use `scopesRoute` and `namesRoute`; dismiss control is 48dp.
- Scale bar is correctly classified/documented as a read-only molecule, has region semantics, safe empty-segment rendering, positive segment assertions, and no MapLibre coupling.
- Risk toast extends `DSToastEntry` and uses the existing `DSToastManager`; no second stack was found. Risk colors are distinct (`info`, warning, orange rule, error) and high does not collapse onto critical red.
- Public Prism aliases/gallery registration are present; the previously run live sibling pack was recorded as 23/23 tests and boundary 7/7.

## Current review evidence

Fresh live checks for the sibling scopes in this batch passed, including boundary harness `7/7`, but the review was stopped by the 1617 migration runtime failure before a dedicated 1522 format command could complete. No fresh 1522 non-mutating format PASS/FAIL is claimed here.

The prior 100/100 evidence is therefore insufficient for this current adversarial gate because the mandatory fresh format proof is missing, not because the optional pack behavior failed.

## Findings

### HIGH — Mandatory non-mutating format proof is missing (EVIDENCE_GAP)

The batch format invocation short-circuited after the preceding token-scope format failure, so the 1522 source/test paths were not independently checked. The task’s accepted ledger does not contain an independent current format packet. Do not retain 100/100 without this proof.

### MODERATE — Current review did not re-run 1522 tests after the stop boundary (EVIDENCE_GAP)

The historical pack proof says keyboard 8 + scale 6 + risk 9 = 23/23 and boundary 7/7, and source inspection corroborates the intended contracts. Per the stop-on-runtime-failure rule, this review does not re-claim those historical tests as fresh current evidence.

### PASS — No semantic/token safety defect found by source inspection

Risk styling stays on the existing manager; keyboard/scale surfaces use ADS tokens; no teal-global default or black-obsidian violation was found in the reviewed code.

## Path to 100

1. Run dedicated 1522 scoped analyzer and tests with `--no-pub`.
2. Run dedicated non-mutating `dart format --output=none --set-exit-if-changed` for all 1522 source/test/gallery/API paths.
3. Re-run boundary harness 7/7 and inspect the single-manager integration test.
4. Preserve regression guards: no second toast manager, scale bar remains molecule, cheatsheet modal semantics remain scoped/named, and risk high remains orange rather than status error red.

## Routing

Score is below 90 due to mandatory fresh evidence gaps. Move to `docs/tasks/02-doing/` collision-safely. No code was changed by this review.
