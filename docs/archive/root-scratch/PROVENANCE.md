# Root Scratch Archive Provenance

This document records the provenance, purpose, and classification of all 22 historical scratch scripts moved from the repository root under **Task 1813** in accordance with the **Archive-First Law** (zero deletion).

## Inventory and Classification

| Filename | Original Location | Purpose / Summary | Task Provenance | Classification | Rationale |
|---|---|---|---|---|---|
| `start-tmux.sh` | `/start-tmux.sh` | Detached tmux session launcher with 10-pane grid layout | Environment tooling (July 2026) | `scripts/` | Reusable developer utility for multi-pane tmux session setup. Moved to `scripts/start-tmux.sh`. |
| `append_to_atoms.dart` | `/append_to_atoms.dart` | Widget test group snippet for `DSSparkline` contract | Task 0001 / atoms test expansion (June 2026) | `docs/archive/root-scratch/` | One-off test snippet appended to atoms test suite. |
| `append_to_molecules.dart` | `/append_to_molecules.dart` | Widget test group snippet for `DSUptimeBar` and `DSCmdPalette` | Task 0001 / molecules test expansion (June 2026) | `docs/archive/root-scratch/` | One-off test snippet appended to molecules test suite. |
| `fix2.py` | `/fix2.py` | Regex replacement for string quotes in `apps/catalog/test/widget_test.dart` | Task 1305 / catalog test remediation (June 2026) | `docs/archive/root-scratch/` | One-off test syntax fix. |
| `fix_0001.py` | `/fix_0001.py` | String replacement fixing mock workspace manifest path in Task 0001 doc | Task 0001 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_0010.py` | `/fix_0010.py` | String replacement updating Flutter SDK blocker status in Task 0010 doc | Task 0010 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_0011.py` | `/fix_0011.py` | String replacement updating Flutter SDK blocker status in Task 0011 doc | Task 0011 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_0610.sh` | `/fix_0610.sh` | Sed script updating Task 0610 review state and subtask checkboxes | Task 0610 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_0611.sh` | `/fix_0611.sh` | Sed script updating Task 0611 review state and subtask checkboxes | Task 0611 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_evidence.py` | `/fix_evidence.py` | Script updating Completion Evidence block in Task 1305 doc | Task 1305 doc remediation (June 2026) | `docs/archive/root-scratch/` | One-off task document text fix. |
| `fix_imports.py` | `/fix_imports.py` | Regex script updating `ds_compat.dart` and `router.dart` imports in Observatory | Task 0011 / observatory ds import migration (June 2026) | `docs/archive/root-scratch/` | One-off code migration script. |
| `fix_test.py` | `/fix_test.py` | Script updating `sectionTitles` in `apps/catalog/test/widget_test.dart` | Task 1305 / catalog test remediation (June 2026) | `docs/archive/root-scratch/` | One-off test fix script. |
| `patch_ds_chip.py` | `/patch_ds_chip.py` | Script wrapping `AnimatedContainer` in `ds_chip.dart` for minimum hit target | Task 0001 / ds_chip height patch (June 2026) | `docs/archive/root-scratch/` | One-off component patch script. |
| `patch2_ds_chip.py` | `/patch2_ds_chip.py` | Script adjusting `AnimatedContainer` layout in `ds_chip.dart` | Task 0001 / ds_chip hit target patch (June 2026) | `docs/archive/root-scratch/` | One-off component patch script. |
| `replace_ds.sh` | `/replace_ds.sh` | Batch sed script replacing `DS*` with `Prism*` tokens across Observatory map feature | Task 1800 / Prism token migration (June 2026) | `docs/archive/root-scratch/` | One-off migration sed script. |
| `snippet_molecules_tests.dart` | `/snippet_molecules_tests.dart` | Test group snippet for `DSUptimeBar` contract tests | Task 0001 / molecules test suite (June 2026) | `docs/archive/root-scratch/` | One-off test snippet. |
| `test_molecules_append.dart` | `/test_molecules_append.dart` | Standalone test file for `DSUptimeBar` contract tests | Task 0001 / molecules test suite (June 2026) | `docs/archive/root-scratch/` | One-off test snippet. |
| `test_public_api.dart` | `/test_public_api.dart` | Quick verification script for `PrismOperationalState` API | Task 1800 / public API verification (June 2026) | `docs/archive/root-scratch/` | One-off API test scratch script. |
| `test_shell.dart` | `/test_shell.dart` | Dart scratch widget snippet for `MapPageShell` in Observatory | Task 0011 / observatory router shell (June 2026) | `docs/archive/root-scratch/` | One-off UI scratch script. |
| `tmp_fix_heights.py` | `/tmp_fix_heights.py` | Script adjusting section heights in `design_system_gallery_sections.dart` | Task 1305 / gallery layout fix (June 2026) | `docs/archive/root-scratch/` | One-off gallery fix script. |
| `tmp_fix_sizedboxes.py` | `/tmp_fix_sizedboxes.py` | Script adjusting SizedBox heights in `design_system_gallery_sections.dart` | Task 1305 / gallery layout fix (June 2026) | `docs/archive/root-scratch/` | One-off gallery fix script. |
| `tmp_height_patch.py` | `/tmp_height_patch.py` | Regex script replacing numeric heights in `design_system_gallery_sections.dart` | Task 1305 / gallery layout fix (June 2026) | `docs/archive/root-scratch/` | One-off gallery fix script. |

## Classification Summary

- **Reusable Scripts (`scripts/`)**: 1 file (`start-tmux.sh`)
- **Reusable Tooling (`tool/`)**: 0 new files (existing `tool/validate_mock_workspace.py` preserved)
- **Historical Archive (`docs/archive/root-scratch/`)**: 21 files
- **Deletions**: 0 (zero deletions per Archive-First Law)
