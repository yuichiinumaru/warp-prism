# Task 1886: Surface host + data-plane satellite seam (F-25) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-B). **Source:** backlog F-25 card (§2) + WB-U11/TP U-09 + Macro P2-8/P2-12 + MISSION §7.
> **State:** HOLD in `00-planning/`. **Unlock conditions (both required):** (1) written transfer/ownership declaration for texture/media viewports crossing the boundary (MISSION §7 data-plane law); (2) runtime-architect review of the seam. Highest gate burden in the wave by law.
> **Mandate note:** FFT/spectral/goniometer/RMS/DSP/automation painters stay product-local unconditionally — only the generic canvas-host seam may later crystallise as a satellite.

## Outcome and boundaries

Establish `PrismSurfaceHost` (aspect-locked texture host + placeholder canvas + HUD badge) strictly as an adapter-boundary seam, plus the narrow generic canvas-host contract (fixed-viewport determinism, bounded data, a11y numeric fallback). WB `TexturedPreviewHost` (`:3-178`, `WP-GAP-001`, presentation-only `Texture(textureId)` + HUD vs `CustomPaint` grid, `shouldRepaint false`) is the studied donor; the `NativeSurfaceController` spike is explicitly excluded (never harvest).

Scope: seam spec + placeholder-determinism suite. Non-goals: any painter port, GPU lifecycle, zero-copy (no measured product evidence — forbidden claim), `warp_prism_audio_ui` package split (no split until an import graph forces it).

## Success and verification

- Seam declares transfer/ownership semantics in writing (who allocates, who releases, what placeholder renders when no frame exists).
- Placeholder determinism proven (golden-stable without a real frame source); HUD badge never implies live data when placeholder is shown.
- Boundary clearance: seam lives at the adapter boundary, never in ADS core; no FRB import outside `warp_prism_adapter_frb`.

## Where

| Surface | Evidence / anchor |
|---|---|
| Warpblade donor (report-grade) | `TexturedPreviewHost` `:3-178`, `WP-GAP-001` (re-verify at promotion — U-REV) |
| Tempest data-plane anchors | FFT/spectral/goniometer/phase/DSP/automation — product-local, studied only for seam shape |
| Prism target | Adapter-boundary seam (not `warp_prism_ui` core); future satellite `warp_prism_audio_ui` iff import graph forces it |
| Layer law | `.project/architecture/layer-contracts.md` §§1, 8 (data plane vs control plane) + MISSION §7 |

## Work

- [ ] Re-verify donor paths at execution time; confirm spike exclusion (`NativeSurfaceController` NOT harvested).
- [ ] Draft transfer/ownership declaration; obtain runtime-architect review (the HOLD's second half).
- [ ] Specify `PrismSurfaceHost` + canvas-host contract (fixed viewport, bounded data, numeric fallback) + placeholder-determinism suite.
- [ ] Linux host-proof plan recorded (placeholder-level; real-frame proof waits on a product host with measured evidence).

## Validation

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; no data-plane type in ADS core; declaration + review recorded in-repo.

## Gates

- Declared prerequisites: written transfer/ownership declaration + runtime-architect review (both whole-outcome premises under MISSION §7).
- No zero-copy claims without measured product evidence — permanent constraint, not a deferrable gate.
- Parallelizable with: none on seam files until unblocked; disposition reads may proceed alongside 1852.
