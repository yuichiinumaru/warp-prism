---
name: devops-release
parent: flutter
description: Run Flutter/Dart verification, pub/codegen/toolchain triage, CI, signing, artifact, and release-preflight operations while routing dependency policy to dependency.
---

# Flutter DevOps and Release

Use this route for analyzer/test/release orchestration, Flutter build surfaces,
CI, toolchain availability, signing evidence, symbols, and store/distribution
readiness.

Dependency ownership, lockfiles, pub/Cargo/FRB version tuples, and codegen
mutation policy remain owned by `dependency`.

## Preflight

1. Identify package/workspace roots and the actual project-defined commands.
2. Read active project/harness authority before dependency, signing, publishing,
   or production mutations.
3. Verify Flutter/Dart SDK/toolchain availability before promising validation.
4. Run the smallest relevant project-defined proof first.
5. Capture command, cwd, exit status, artifacts, and blocked dimensions.

## Common Commands

Use only when appropriate to the project:

```bash
flutter --version
dart --version
dart analyze
flutter analyze
dart test
flutter test
flutter build apk --release
flutter build appbundle --release
```

Run `pub get`, dependency resolution, lockfile enforcement, and codegen under the
active dependency policy rather than as unconditional preflight steps.

## CI / Release Checklist

- [ ] Toolchain/runtime version is pinned or recorded.
- [ ] Dependency/lockfile policy was applied by the correct owner.
- [ ] Analyzer, tests, codegen, build, and formatting failures are separable.
- [ ] Generated artifacts cannot silently drift behind CI caches.
- [ ] Signing/publishing secrets are not committed.
- [ ] Release identity/build number/version is known.
- [ ] Required native symbols/mappings/crash artifacts are preserved/uploaded.
- [ ] Artifact security review is routed to `sub-skills/security` when applicable.
- [ ] A successful build is not confused with runtime/host acceptance.

## Failure Triage

- SDK missing → affected validation is blocked/unavailable, not PASS.
- `pub get`/resolver failure → route dependency ownership/version questions to
  `dependency`.
- generated-code drift → inspect project policy; do not blindly delete generated
  artifacts.
- CI-only failure → compare toolchain/platform/env/generated artifacts/fonts/
  goldens/filesystem behavior.
- release artifact differs from tested artifact → invalidate only the claims that
  depended on artifact identity and re-establish them.

## Experimental Copied Tools

The files under `../../scripts/` are **not active Ganthritor enforcement unless
`../../references/scripts-status.md` says they have been canonized**.

In the current corpus:
- some shell files are Claude-Code-specific hooks using Claude environment/protocol;
- some Python scanners are heuristic source scanners;
- `analysis_options.reference.yaml` is a reference config;
- `check_drift.sh` checks rule/reference drift, not generated-code drift.

Do not wire, execute as a mandatory gate, or generalize their embedded style
opinions merely because they are executable.

Before canonizing a copied tool require:
- target-host adapter/compatibility;
- declared inputs/outputs/side effects;
- known-good and known-bad calibration;
- deterministic/reproducible behavior where expected;
- documented exit semantics;
- ownership and workflow integration;
- review.
