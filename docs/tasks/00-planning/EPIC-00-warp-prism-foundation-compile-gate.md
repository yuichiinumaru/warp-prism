# EPIC 00 — Warp-Prism Foundation and Compile Gate

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Create executable tasks only after evidence agents identify exact failing files, imports, APIs, and Flutter commands.

## Goal

Recover the project foundation so future work is based on a compiling, analyzable Flutter app rather than disconnected generated fragments.

## Source Evidence

- `warp-prism/docs/draft.md` reports missing `lib/main.dart`, `lib/app/app.dart`, and `lib/app/router.dart`.
- `warp-prism/docs/draft.md` reports naming/API mismatches such as `DSColors` vs `DsColors`, `DSShell` vs `DsShell`, and mismatched sidebar/topbar/template parameters.
- `warp-prism/README.md` is reported as Next.js/v0 boilerplate while `warp-prism/pubspec.yaml` declares Flutter dependencies.

## Scope

- Establish the minimum Flutter app entrypoint and route skeleton.
- Normalize compile-breaking naming/API inconsistencies without building feature screens prematurely.
- Confirm local validation commands and expected outputs.
- Keep this epic focused on making later design/data/screen tasks safe.

## Out of Scope

- Full product screens.
- Full mock corpus generation.
- Visual polish beyond compile/analyze-critical adjustments.

## Candidate Stories

- Foundation audit: inventory actual `lib/` files, exports, missing entrypoints, and analyzer failures.
- App bootstrap: define minimal `main.dart`, app root, and router shell sufficient to launch.
- Design system API repair: reconcile DS class names and organism/template parameters.
- Validation baseline: document `flutter analyze` and `flutter test` expectations.

## Dependencies

- None. This is the first technical gate.

## Acceptance Criteria for Epic Completion

- A future executable task proves `flutter analyze` reaches a known passing or explicitly documented residual state.
- Flutter entrypoints and routing files exist or are deliberately deferred with evidence.
- DS naming/API mismatches that block analysis are fixed or isolated behind focused follow-up tasks.
- Builders can work on later epics without inventing project bootstrap behavior.
