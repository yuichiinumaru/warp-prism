# Build-Gate Review: Task 1126 — README Monorepo Reality Alignment

**Date**: 2026-06-17
**Reviewer**: reviewers / Wave 0 package-gate triage
**Task file reviewed**: `docs/tasks/03-review/1126-warp-prism-readme-monorepo-reality-alignment.md`

## Score: 68/100 — Debt

## Findings

### HIGH — Documented setup and validation commands are not executable in the live repository

- **Evidence**: `README.md:78,84-88,96-102` instructs users to run global `melos` and says global installation is a prerequisite. Live `melos --version` returns `command not found`. Root `pubspec.yaml:11-12` instead declares Melos as a workspace dev dependency and its scripts recursively use `dart run melos` (`pubspec.yaml:20-58`). `dart pub get` and `dart run melos run analyze` currently fail before execution because `pubspec.yaml:7-9` includes `apps/observatory/tmp/pub-cache/.../flutter_lints-4.0.0/pubspec.yaml` in workspace discovery.
- **Impact**: The README's primary setup and validation workflow cannot be followed in the live checkout, directly violating the task objective to align documentation with monorepo reality and the exit condition that setup/validation commands be correct.
- **Path to 100**: Document repository-local commands (`dart run melos bootstrap`, `dart run melos run analyze`, `dart run melos run test`, `dart run melos run validate`) or intentionally establish the global Melos prerequisite. Separately fix/narrow workspace discovery so `dart pub get` and Melos commands can execute without including nested cache packages. Rerun every documented setup/validation command and record live output.

### MEDIUM — README names a nonexistent public token API

- **Evidence**: `README.md:61` documents `PrismTokens.colors`, `PrismTokens.typography`, and `PrismTokens.spacing`. No `PrismTokens` symbol exists in `packages/warp_prism_ui/lib`; live public aliases are `PrismColors`, `PrismTypography`, and `PrismSpacing` at `packages/warp_prism_ui/lib/src/prism_aliases.dart:99-115`.
- **Impact**: Builders following the README will write code against an API that does not compile.
- **Path to 100**: Replace the nonexistent examples with exported live symbols and verify them against `packages/warp_prism_ui/lib/warp_prism_ui.dart` plus `src/prism_aliases.dart`.

### MEDIUM — Mock corpus path is wrong from the documented repository root

- **Evidence**: `README.md:92` establishes commands/paths from the repository root, while `README.md:115-116` says the Observatory corpus is under `assets/mock_workspace/`. No root `assets/mock_workspace/` exists; the live corpus and app declaration are at `apps/observatory/assets/mock_workspace/` (`apps/observatory/pubspec.yaml:32-42`).
- **Impact**: The README still sends builders to a nonexistent root path, preserving the exact class of monorepo-reality drift this task was intended to remove.
- **Path to 100**: Change the README path to `apps/observatory/assets/mock_workspace/` and rerun exact path-existence validation.

### MEDIUM — Claimed changelog-gate failure is current but the task does not classify it precisely

- **Evidence**: `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` fails with `ERROR: Missing 'timestamp' in 1302-public-barrel-audit.md`. Task header only says a generic pre-existing issue and Completion Evidence does not provide before/after output, failing area, task touch set, or baseline reference required by `.agents/rules/pre-existing-failure-policy.md:34-43`.
- **Impact**: The `Package Gate Failed` justification is incomplete under the mandatory policy. The changelog failure appears unrelated to README Task 1126, but the task packet does not provide the required evidence to carry it forward.
- **Path to 100**: Record the exact failing file/diagnostic, establish before-task or baseline evidence, list Task 1126 touched files, state regression count, and classify it as unrelated only if supported by that evidence.

## Diagnostics

| Command | Result | Details |
|---|---:|---|
| README documented-directory existence check | PASS | All listed app/package/docs directories exist. |
| `melos --version` | FAIL | `melos: command not found`. |
| `dart pub get` | FAIL | Workspace glob includes nested `apps/observatory/tmp/pub-cache/.../flutter_lints-4.0.0` package lacking `resolution: workspace`. |
| `dart run melos run analyze` | FAIL | Same workspace-resolution failure before Melos dispatch. |
| `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` | FAIL | `Missing 'timestamp' in 1302-public-barrel-audit.md`. |
| Search for `PrismTokens` in live Dart code | FAIL | No symbol found. |

## Exit Conditions

| Condition | Result | Evidence |
|---|---:|---|
| README accurately describes root/apps/packages | PARTIAL | Main tree is accurate, but corpus path remains wrong. |
| Correct setup commands | FAIL | Global Melos command unavailable; `dart pub get` blocked by workspace glob contamination. |
| Correct validation commands | FAIL | Documented global commands unavailable and repository-local command is blocked before dispatch. |
| No stale task status/blocker references | PASS | No stale task status or SDK blocker remains. |
| `warp_prism_ui` and `Prism*` public API documented | PARTIAL | Namespace intent is correct; `PrismTokens` examples are fabricated/nonexistent. |
| Changelog entry | PASS WITH EVIDENCE GAP | Entry exists, but package-gate failure classification is incomplete. |
| Completion Evidence filled | PARTIAL | Filled but validation only checks two words and does not prove path/API/command accuracy. |

## Verdict

NEEDS FIX. Score 68/100. Move task back to `docs/tasks/02-doing/` under the orchestration routing contract.
