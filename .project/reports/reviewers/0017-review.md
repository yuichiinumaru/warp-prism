# Review Report: Task 0017 — Design System Gallery Route Bootstrap — 2026-06-17

## Review Lineage

- **Current task**: Task 0017 (`0017-warp-prism-design-system-gallery-route-bootstrap`); live path initially `docs/tasks/03-review/0017-warp-prism-design-system-gallery-route-bootstrap.md`, routed back to `docs/tasks/02-doing/0017-warp-prism-design-system-gallery-route-bootstrap.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0017-review.md` — prior `100/100`, stale/missing-SDK approval.
- **Related reports/tasks considered**:
  - Task 0011 latest ledger: `docs/reports/review-wave-3/0011-review.md` — `68/100`, `REJECTED_TO_DOING`.
  - Task 0016 latest ledger: `docs/reports/review-wave-0/0016-review.md` — `62/100`, rejected to doing.
  - Task 0015 latest ledger: `docs/reports/build-gate-review/0015-review-wave-2.md` — `76/100`, rejected to doing.
  - Task 0010 latest ledger: `docs/reports/review-wave-3/0010-review.md` — `58/100`, rejected to doing.
- **Review mode**: cascade re-review / prerequisite gate.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Targeted gallery widget tests now run under the live SDK and pass: `flutter test --no-pub test/gallery/design_system_gallery_test.dart test/accessibility/design_system_accessibility_test.dart` in `packages/warp_prism_ui/` reported `33 passed`.

### Persistent Findings
- `PERSISTENT`: Prior approval accepted blocked/missing-SDK analyzer evidence as pass-equivalent.

### Regressions
- `REGRESSION`: The task remains in review while both declared prerequisites are currently rejected to `02-doing`.

### New Findings
- `NEW`: Live analyzer proof for the gallery/accessibility surface fails under the current SDK.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Current task text still names pre-monorepo root paths under `lib/` and `test/`, while live implementation resides in `packages/warp_prism_ui/` and app router wiring in `apps/observatory/`.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Rejected prerequisites block approval. | Task 0017 declares `Depends on: Task 0011, Task 0016` at `docs/tasks/03-review/0017-warp-prism-design-system-gallery-route-bootstrap.md:9`; Task 0011 ledger is `68/100` / `REJECTED_TO_DOING` at `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md:139-153`; Task 0016 ledger is rejected at `docs/tasks/02-doing/0016-warp-prism-ds-organisms-templates-alignment.md:169-176`. |
| F2 | EVIDENCE_GAP | Medium | Open | Analyzer exit condition is not satisfied on the live task surface. | Command `HOME=$(pwd)/../../tmp/home PUB_CACHE=$(pwd)/../../tmp/pub-cache flutter analyze --no-pub lib/src/gallery test/gallery test/accessibility` in `packages/warp_prism_ui/` exited nonzero with `333 issues found`, including deprecated API and lint diagnostics in `lib/src/gallery/design_system_gallery_sections.dart` and `test/accessibility/design_system_accessibility_test.dart`. |

## Evidence Reviewed

- Task files: Task 0017, Task 0011, Task 0016, Task 0015, Task 0010.
- Source/test files: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `apps/observatory/lib/app/router.dart`, `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart`, `packages/warp_prism_ui/test/accessibility/design_system_accessibility_test.dart`.
- Runtime wiring proof: `apps/observatory/lib/app/router.dart:112-116` registers `/design-system` to `DesignSystemGalleryPage`; `apps/observatory/lib/app/router.dart:35-36` sets initial location to `/design-system`.
- Commands run:
  - `flutter analyze --no-pub lib/src/gallery test/gallery test/accessibility` in `packages/warp_prism_ui/` — failed, `333 issues found`.
  - `flutter test --no-pub test/gallery/design_system_gallery_test.dart test/accessibility/design_system_accessibility_test.dart` in `packages/warp_prism_ui/` — passed, `33 passed`.
- Commands not run: full monorepo validation; out of scope for this cascade gate.

## Path To 100

1. Resolve and approve prerequisite Task 0011 and Task 0016; Task 0016 also requires Task 0015 resolution.
2. Migrate Task 0017 evidence/Where paths to current monorepo locations (`packages/warp_prism_ui/`, `apps/observatory/`).
3. Clear exact-scope analyzer diagnostics for gallery/accessibility or update the exit condition with an explicit accepted residual policy.
4. Re-run and record exact analyzer and targeted widget-test output after fixes.

## Task Ledger Patch Suggestion

Add/update Task 0017 Review Ledger with this latest report, `58/100`, `REJECTED_TO_DOING`, blockers F1-F2, and the path-to-100 above.
