# Task 1866: PrismComposer organism EXPERIMENTAL (autogrow, mentions, attachments, drafts)

Change only the composer seam in `warp_prism_ui`: add EXPERIMENTAL organism
`PrismComposer` (autogrow, @mentions, emoji, format, attachment lifecycle,
parked drafts). Anchors (Warpblade comments, Tempest annotations,
Command-center operator notes) are forthcoming — ship EXPERIMENTAL and
promote on second-host adoption. Success is the stated observable behavior.

## Outcome and boundaries

- **Authorized outcome**: reusable composer organism exists as EXPERIMENTAL
  (spec + fake + conformance, no barrel export): autogrow input, @mentions,
  emoji, format controls, attachment lifecycle states, parked-draft
  persistence-in-memory with restore, draft/caret conformance.
- **Subject**: `warp_prism_ui` organism layer only.
- **Constraints**: no backend/persistence (drafts are in-memory; durable
  store is product-local — no SQLite, no IO imports in UI per boundary B4/B5).
  No domain types (comments/annotations/notes models stay consumer-side;
  Prism takes injected descriptors). Determinism: no unbounded waits;
  goldens at fixed draft states only. a11y: caret/focus contract, screen
  reader announcements for attachment states.
- **Non-goals**: no presence overlay (P2 F-24, gated HOLD); no second-host
  adoption work; no STABLE/barrel/API freeze in this task.

## Context / reliance

- Source evidence: backlog F-18 card (donor HIGH H8 1108-line reference:
  autogrow/@mentions/emoji/format/attachment lifecycle/parked drafts;
  Macro Held→CANDIDATE upgrade; anchors forthcoming, not yet inventoried).
- MISSION §3.1 (mandate covers the composition once anchors land; donor-only
  would be inspiration — here the anchors are named forthcoming product
  surfaces, so EXPERIMENTAL is honest); §6 gates 1–4, 7 apply; 5–6 n/a until
  anchors land (record reason).
- Layer-contracts §§1, 4, 10.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_ui/lib/src/organisms/` | Extend | New composer home (new dir/files); read neighbour conventions first |
| `packages/warp_prism_ui/lib/src/molecules/dialog/` | Reference | Dialog/popover adjacency patterns only |
| `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` | Reference | Mention-query input pattern only |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Compose | Attachment-state chrome reuse |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read-only | No export added (EXPERIMENTAL) |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness |
| `packages/warp_prism_testkit/lib/src/` | Suite home | Fake composer model + conformance |
| `apps/catalog/lib/` | Proof lab | EXPERIMENTAL gallery entry |

## Work / responsibility

- [ ] Read neighbouring organism conventions + dialog/search/state-surface
  patterns before mutation.
- [ ] Specify composer model (draft, caret, mentions, attachments, parked
  drafts) as injected descriptors; no product types.
- [ ] Implement organism + fake + conformance (draft/caret restore,
  attachment lifecycle, determinism, a11y).
- [ ] Fixed-state goldens; gallery entry marked EXPERIMENTAL.
- [ ] Run full validation; record anchor status (forthcoming → no host proof
  claimed).

## Success and verification

- Fake + conformance green; draft/caret restore proven; attachment lifecycle
  states covered; no persistence/IO import in the diff.
- Explicit statement: zero host adoptions today; STABLE gated on
  second-host adoption (promotion condition recorded, not met).
- MISSION §6: items 1 (mandate-covered composition + macro decision), 2–3
  (spec + fake + suite), 4 (boundary), 7 (review). Items 5–6 n/a with reason
  (anchors forthcoming — no host proof claimed).
- Format/analyze/boundary clean.

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_ui/lib packages/warp_prism_testkit/lib
flutter analyze packages/warp_prism_ui packages/warp_prism_testkit
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_testkit
flutter test packages/warp_prism_ui
```

## Evidence / assessment

- Bind results here: suite + golden paths, gallery path, anchor-status
  statement, review verdict, explicit no-promotion condition.

**Parallelizable with**: all P1 siblings — isolated new-dir seam.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_19753bcf5001vg51z6tZELKPnj` + text-only handoff extract `sh_1976abf84001oFziA9ZZpHHl4J` (same opencode session `ses_e68ac427ffexHs2K0yJXGuNHd`). Handoff claims `complete`; packet is thin/generic (no file list, no anchor detail) and wrongly claims task-file evidence — task file untouched (`??` from parent claim move only, never `M`). Parent verification below compensates for the thin packet.
- **Filesystem check**: new `organisms/composer/` (model + organism + barrel) + testkit fake/contract + 2 test files + 4 golden PNGs present; gallery registry +1 entry + sections +1 method + gallery test counts 26→27 present; `boundary_test.dart` additive-only (3 `composer_1866_*`); 1861's meter/fader files untouched; no barrel/alias exports (grep over barrels + cross-check into meter seam empty).
- **Parent re-run (fresh, after return, tree quiet)**: `dart format` on 7 touched paths → 0 changed exit 0; conformance → **56/56 pass**; composer model + golden → **30/30 pass**; gallery → **22/22 pass**; pure-dart boundary harness → **66/66 PASS exit 0**. Counts match the worker's claims exactly.
- **Not re-run by parent**: full testkit 130 + full UI suite (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: anchors forthcoming (Warpblade comments / Tempest annotations / CC operator notes) — EXPERIMENTAL honest, no host proof claimed; full-suite SIGTERM-teardown flake is environment noise, not task evidence.
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e5192d661ffemQV2UbY0p7uCQN` (independent — did not build). Report: `.project/reports/reviewers/1866-warp-prism-composer-experimental-review-loop.md` (new file).
- **Verdict**: PASS (87/100 diagnostic). No remediation. Lifecycle verified under closest scrutiny (owned-vs-injected controller disposal, synchronous park, listener removal, conditional focus-node ownership, mounted post-frame guards).
- **Accepted evidence**: conformance 56/56; golden 4/4 (pre-existing freeze honored, no refresh); testkit fake 27/27; analyze clean; boundary 81/81 (3/3 composer checks); EXPERIMENTAL containment; no IO/SQLite/timers/domain types.
- **Non-blocking observation**: testkit barrel asymmetry (banner via barrels, composer via direct src imports) — align at promotion.
- **Residual (non-blocking)**: anchors forthcoming (consumers NONE today, honestly stated); adoption is the STABLE gate.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 87/100; conformance 56/56, golden 4/4, fake 27/27, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1866-warp-prism-composer-experimental-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
