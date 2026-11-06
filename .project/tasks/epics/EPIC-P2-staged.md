# EPIC-P2-staged — Warp Prism P2 staged tranche (F-20..F-27)

> **Source:** `.project/research/final-upgrade-backlog-2026-11-01.md` §§2–7 (F-20..F-27 detail cards + build order).
> **Authority:** `MISSION.md` §3.1 (full-coverage mandate — single-consumer UI is absorbed, never rejected) + §6 evidence gates 2–7 + §6 crystallization rule; layer law `.project/architecture/layer-contracts.md`.
> **Posture:** Ambitious, no invented blockers. A HOLD below exists only where the backlog names a genuine missing host, gate, or prerequisite outcome — each with an explicit unlock condition.
> **Status:** All member tasks materialized in `00-planning/`. None is executable until its lane/promotion condition is met.

## Intent

Absorb the P2 tail of the upgrade backlog natively into Warp Prism: single-consumer compositions that still ship under the mandate (F-20..F-23), gated overlays and the data-plane seam that must not outrun their hosts (F-24, F-25), and the Sentry-derived views that render only over already-landed trust primitives (F-26, F-27).

## Non-goals (from backlog §6, binding on every member task)

- No `warp_prism_av` / `warp_prism_audio_ui` package split in this wave; split only when an import graph forces it.
- No time-ontology unification, no domain painters/math (FFT, spectral, goniometer, DSP, LUFS/RMS calibration), no credentials/orchestration/persistence in Prism.
- No speculative templates/scaffolds; no flag-day migration; no zero-copy claims without measured product evidence.
- No transitive-coverage claims for either layer checker (direct-dep class only).

## Stories

### Story P2-A — Single-consumer compositions (EXPERIMENTAL guidance, promote on adoption)

| Task | F-item | Outcome |
|---|---|---|
| 1849 | F-20 | Audition/compare matrix composition over `DSVirtualGrid` + `DSLaneBoard` + F-01/F-04/F-05 — **HOLD** until F-01 + F-04 + F-05 land |
| 1850 | F-21 | Descriptor-driven disclosure form as `DSAccordion` + `DSSelect` extension pattern — materialized, no hard dep |
| 1851 | F-22 | Ribbon collapse-priority + tool-mode palette pattern over S2 registry — **HOLD** until F-03 registry contract exists |
| 1852 | F-23 | Energy-curve editor disposition — **HOLD** until architecture rules on `DSGraphCanvas` sufficiency |

### Story P2-B — Gated overlays & data-plane seam

| Task | F-item | Outcome |
|---|---|---|
| 1885 | F-24 | Presence overlay EXPERIMENTAL on fake room model; STABLE gated on first multi-user host |
| 1886 | F-25 | Surface host + data-plane satellite seam — **HOLD** until written transfer/ownership declaration + runtime-architect review |

### Story P2-C — Sentry-derived views (request-only consumer, no Flutter surface)

| Task | F-item | Outcome |
|---|---|---|
| 1887 | F-26 | Sealed decision views + phase rail + epistemic lens over F-04/F-05 — **HOLD** until F-04 + F-05 land and a real host route exists |
| 1888 | F-27 | Authority explainer + partial-fill remainder views over F-01 — **HOLD** until F-01 lands (remainder needs runtime review) |

## Dependency DAG (real prerequisites only, not ceremony)

```text
Tasks 1868/1871/1872 (F-01/F-04/F-05, 01-open P0 wave)
  ├─→ 1849 (F-20 composes on all three)
  ├─→ 1887 (F-26 renders over 1871/1872)
  └─→ 1888 (F-27 renders over 1868)
Task 1870 (F-03 registry contract, 01-open P0 wave)
  └─→ 1851 (F-22 pattern over S2 registry)
Architecture disposition: DSGraphCanvas topology sufficiency
  └─→ 1852 (F-23 build vs new-primitive decision)
Written transfer/ownership declaration + runtime-architect review
  └─→ 1886 (F-25, MISSION §7 data-plane law)
First multi-user host (DECLARED/forthcoming, backlog U-DAG)
  └─→ 1885 STABLE promotion only (EXPERIMENTAL construction on fake room model is not gated)
Real host route for Sentry views (Sentry has no Flutter surface, backlog U-SENTRY)
  └─→ 1887 STABLE promotion
```

## Parallelism

- Story P2-A ∥ Story P2-B-construction ∥ Story P2-C-prep-reads (disjoint writesets; HOLDs are per-task gates, not story locks).
- Within P2-A: 1850 ∥ 1851-prep ∥ 1852-disposition-read (1851 construction waits on F-03; 1852 waits on disposition).
- 1887 and 1888 serialize after their named landings; they share no writeset with each other (distinct views) so may proceed in parallel once unblocked.
- Shared-write guards (one owner per invariant, backlog §7): `prism_aliases.dart`/barrels, gallery registry, `layer-contracts.md`, `component-catalog.md` — tasks that touch them coordinate in task order 1849→1888, never concurrently.

## Global success criteria

1. Every member task exits EXPERIMENTAL only via MISSION §6 gates 2–7 (fake + conformance + boundary + host proof + FRB lifecycle where applicable + independent review + barrel export + API freeze).
2. No task promotes `00-planning → 01-open` until injected-model seams, writeset/owner, validation commands, and host-proof exit criteria are explicit (backlog §7 per-item rule).
3. Donor accidents never port (backlog coverage map, Donors row): no `el()/h()` helpers, hash router, localStorage, account dep, glyph sets, WebRTC, canvas painters, vite setup, egui/wgpu/Figma coupling, brand/glyphs.
4. Re-verify at promotion time (backlog unknowns carried): consumer revision UNKNOWN (U-REV), Tempest 4-row arithmetic (U-ARITH), 295-vs-296 alias count (U-COUNT), CC symlink provenance (U-SYMLINK).
