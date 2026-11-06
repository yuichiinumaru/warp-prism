# Task 1875: Transport bar + injected formatter + timecode badges (F-08)

> **Epic**: [EPIC-P0-trust-core](../epics/EPIC-P0-trust-core.md) · **Story**: [P0-S04](../stories/P0-S04-shell-timeline-transport.md)
> **Source**: `.project/research/final-upgrade-backlog-2026-11-01.md` F-08 (I=45, seam S3) — WB-U2, TP U-02, EV-10, Macro P0-3/C1.
> **Priority**: P0 · **Parallelizable with**: Task 1868, Task 1869 (disjoint writesets — foundation wave).

Highest visible win per line of code. WB `TransportBar` (`formatTime` injected — correct decision trapped in local chrome); TP `StudioTransportBar`; Prism has only private `_TransportButton` + `_buildTransportRow` + `showTransport` flag. This task promotes the injected-formatter discipline to the shared organism.

## Outcome and boundaries

Land organism `PrismTransportBar` (chrome only, slots for record/loop/metronome/BPM) + `PrismTimecodeBadge`/`PrismTimebaseBadge` + injected `formatTime`/`formatRange`. Step sizes/labels/slots caller-supplied; no SMPTE/BPM ontology in Prism. Fake + conformance (steps/disabled/formatter/a11y). EXPERIMENTAL, no barrel export.

Non-goals: time ontology, SMPTE/BPM semantics, transport *behavior*/orchestration (product-local); meter/fader (P1 F-13); no STABLE promotion.

## Where

| Path | Why |
|---|---|
| `packages/warp_prism_ui/lib/src/organisms/` | `PrismTransportBar` home (note existing private `_TransportButton`/`_buildTransportRow` — read before mutating) |
| `packages/warp_prism_ui/lib/src/atoms/` or `molecules/` | Badge homes (`PrismTimecodeBadge`/`PrismTimebaseBadge`) — place by size, one invariant per file |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Purity check in-task |
| `docs/bridge/warpblade/ads-debt.md` | WB `TransportBar` injected-`formatTime` citation — re-verify live |
| `docs/bridge/tempest/ads-debt.md` | TP `StudioTransportBar` citation — re-verify live |

## Work

- [ ] Re-verify both donor transports live (record injected-formatter shape + slot structure; INHERITED-REPORT where unreadable).
- [ ] Implement organism + badges with fully injected formatting; conformance suite: step behavior, disabled states (through 1868's outcome type where frozen — interface reliance, not duplication), formatter determinism (same input ⇒ same string), a11y labels.
- [ ] Fake/reference green; determinism (no wall-clock in rendering — time arrives injected).
- [ ] Format/analyze clean; boundary green; host proof BOTH hosts (backlog gate — WB + TP studio route, AGENTS §7.1 evidence).

## Success and verification

Success = transport chrome + badges render from injected models/formatters, no time ontology in Prism, suite green, MISSION §6 gates (2)(3)(4)(5 both hosts)(7 review) hold. Barrel/API-freeze deferred.

```bash
dart format --set-exit-if-changed packages/warp_prism_ui/lib/src/organisms packages/warp_prism_ui/lib/src/atoms packages/warp_prism_ui/lib/src/molecules
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/organisms packages/warp_prism_ui/test/boundaries/boundary_test.dart
```

Expected evidence: green suites with formatter-determinism tests, both host-exercise logs, reviewer verdict.

## Context / reliance

Depends on nothing (foundation wave). Feed-out: Task 1874 consumes the formatter seam (integration waits for this task's implementation). Eligibility rendering follows 1868's interface once frozen.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_196e52b7c001Q8H00KbcnP1BDR`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: 3 new lib files (`transport_bar/ds_transport_bar.dart`, `ds_timecode_badge.dart`, `ds_timebase_badge.dart`) + new 28-test suite present; `boundary_test.dart` additive-only (`transport_1875_*`); no barrel/alias exports (grep over `organisms.dart`/`atoms.dart`/`prism_aliases.dart` empty); 1870's in-progress files (`interaction/src/command/`, palette edit) untouched by this worker.
- **Parent re-run (fresh, after return, with 1870 still active in tree)**: `dart format` on 5 touched paths → 0 changed exit 0; transport suite → **28/28 pass exit 0**; pure-dart boundary harness → 25/26, the single FAIL owned by 1870's in-flight `command_context.dart` doc comment (`Warpblade*`/`Tempest*` token tripping the no-domain-types check) — all 4 `transport_1875_*` checks PASS, all 1868/1869 checks PASS. No 1875 regression; 1870 owns its leak until its own handoff.
- **Not re-run by parent**: full organisms 735 green (worker-fresh output accepted as evidence input; re-proof belongs to independent review).
- **Known residual**: real-host WB/Tempest studio-route exercise substituted with headless sweep (sibling repos outside workspace boundary + headless env; exact limitation recorded by worker).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e51a3ee20ffeYG7d29XMBfAPf0` (independent — did not build). Report: `.project/reports/reviewers/1875-warp-prism-transport-bar-formatter-badges-review-loop.md`.
- **Verdict**: PASS (91/100 diagnostic). No remediation; only optional STABLE-stage suggestions.
- **Accepted evidence**: transport suite 28/28; format sweep 0-changed; analyzer 0 errors (1 pre-existing unrelated 1860 warning); boundary 81/81 incl. 4× `transport_1875_*`; EXPERIMENTAL containment; stateless-only, no-clock rules verified.
- **Residual (non-blocking)**: real WB/TP studio-route host proof owed before STABLE; recorded, not a verdict blocker at EXPERIMENTAL.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 91/100; transport 28/28, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1875-warp-prism-transport-bar-formatter-badges-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
