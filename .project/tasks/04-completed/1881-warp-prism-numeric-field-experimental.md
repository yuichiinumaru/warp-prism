# Task 1881: PrismNumericField atom EXPERIMENTAL with Set|Scrub commit typing

Change only the numeric seam in `warp_prism_ui`: add EXPERIMENTAL atom
`PrismNumericField` with typed commit (`Set|Scrub`), quantum, modifier rates,
release-frame no-op, and the ported donor parse-table suite. Ships proof-lab
only; STABLE only on host adoption. Success is the stated observable
behavior, verified by the relevant checks.

## Outcome and boundaries

- **Authorized outcome**: EXPERIMENTAL numeric atom exists with the commit
  invariant shared with P0 F-07 (one-gesture-one-history-step,
  live-vs-committed typed; `Set|Scrub` carried in the value type), quantum +
  modifier-rate + release-frame no-op mechanics, and Lead-as-name convention.
  Zero current consumers is expected — this is preempt EXPERIMENTAL, ranked
  on near-certain Warpblade transport / Tempest studio demand.
- **Subject**: `warp_prism_ui` atom layer + testkit-style table suite
  colocated with the atom tests.
- **Constraints**: no STABLE/barrel export in this task, no `DS*` leak, no
  domain math (BigInt/GCD rational arithmetic stays product-local; the atom
  takes injected parse/format/quantum). Junk/adversarial sweep (Task 1867
  nets) must stay green for this suite. Sibling-untouched rule: editing one
  field never mutates its siblings.
- **Non-goals**: no transport params adoption (that's the future host's job);
  no formatter-ontology work beyond the injected seam; no promotion gate work.

## Context / reliance

- Source evidence: backlog F-14 card (donor B3 `field_math.rs:8-43` typed/
  relative/div-zero/format bounds + `widgets.rs:20-133` Lead/Set-vs-Scrub/
  commit/quantum/modifier/release-frame + `field_tests.rs:18-52` parse table;
  WB `formatTime` params + TP studio/mastering params as rational anchors).
- Consumes read-only: F-07 commit invariant + F-19 test nets (do not
  relitigate; if F-07 invariant text is absent, copy the backlog wording and
  flag the gap rather than inventing ontology).
- MISSION §3.1 (preempt EXPERIMENTAL is mandate-compatible); §6 items 2–4, 7
  apply; items 5–6 n/a until a host adopts.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/atoms/text_field/` | Reference | Text-field conventions; read before atom work |
| `packages/warp_prism_ui/lib/src/atoms/` | Extend | New `PrismNumericField` atom home (new file) |
| `packages/warp_prism_interaction/lib/src/input/` | Read | Input-intent seam; keep mechanics in presentation |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read-only | No export added (EXPERIMENTAL, no STABLE) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness |
| `apps/catalog/lib/` | Proof lab | Proof-lab-only demo entry, clearly marked EXPERIMENTAL |

## Work / responsibility

- [ ] Read text-field atom + input intent + donor B3 ranges cited in backlog
  before mutation.
- [ ] Specify value type (`Set|Scrub`), quantum, modifier rates,
  release-frame no-op, Lead-as-name, keep-after-scrub, sibling-untouched.
- [ ] Implement atom + ported parse/scrub/keep-after-release/sibling suites.
- [ ] Junk/adversarial sweep over the new suite (fail-closed, not crash-free).
- [ ] Proof-lab demo only; run full validation below.

## Success and verification

- Ported table suite green (parse/scrub/keep-after-scrub/sibling-untouched);
  junk sweep green; no STABLE/barrel claim present in the diff.
- Determinism: no unbounded waits, no animation-dependent capture.
- MISSION §6: items 1 (mandate + macro candidacy), 2–3 (spec + fake/table
  suite), 4 (boundary), 7 (review). Items 5–6 explicitly n/a with reason
  (zero current consumers — promotion gated on Warpblade/Tempest adoption).
- Format/analyze/boundary clean.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here: suite outputs, sweep output, proof-lab path, review
  verdict, explicit no-promotion statement.

**Parallelizable with**: Task 1860, Task 1861 — disjoint seams. Consumes
F-07/F-19 read-only; does not wait on their lanes.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_1978ef071001r3sG5E5P0u3U7c`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: new `atoms/numeric_field/` + 62-test suite present; `boundary_test.dart` additive-only (4 `numeric_1881_*`); gallery trio additive (sections method + registry entry + 27→28 census); 1883's surfaces untouched; no barrel/alias exports.
- **Parent re-run (fresh, after return, with 1883 still active in tree)**: `dart format` on 6 touched paths → 0 changed exit 0; numeric suite → **62/62 pass exit 0**; gallery → **22/22 pass exit 0**; pure-dart boundary harness → **73/73 PASS exit 0**; `flutter analyze` on 6 seam paths → zero errors (205 pre-existing infos/warnings elsewhere).
- **Not re-run by parent**: full UI suite (worker ran +2173/−63 with all 63 attributed to pre-existing pixel-golden/env diffs, zero in worker files; re-proof belongs to independent review).
- **Known residuals**: F-07 invariant consumed read-only (present in Task 1874, no fallback needed); MISSION §6 items 5–6 n/a with reason (zero consumers, preempt EXPERIMENTAL); donor citations INHERITED-REPORT; headless-only proof (exact limitation recorded).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e5192d661ffemQV2UbY0p7uCQN` (independent — did not build). Report: `.project/reports/reviewers/1881-warp-prism-numeric-field-experimental-review-loop.md` (new file; carries cross-task blast-radius section).
- **Verdict**: PASS (88/100 diagnostic). No remediation. In-suite junk sweep recommended as template for future EXPERIMENTAL seams.
- **Accepted evidence**: numeric suite 62/62 incl. junk/adversarial sweep (fail-closed never-throws); analyze clean; boundary 81/81 (4/4 numeric checks); EXPERIMENTAL containment; conditional controller ownership correct; fully synchronous callbacks; fail-closed verified (div-zero→null, parser bounds, invalid-text restore).
- **Residual (non-blocking)**: adoption is the STABLE gate; package proof suffices at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 88/100; numeric 62/62 incl. junk sweep, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1881-warp-prism-numeric-field-experimental-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
