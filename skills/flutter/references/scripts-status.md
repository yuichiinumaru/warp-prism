# Flutter Harness — Copied Tool Status

This file is the status authority for files copied into `flutter/scripts/`.

**Presence is not canonization.** Unless a row says `canonized`, the file is a
reference/candidate and MUST NOT be wired as Ganthritor enforcement without
host adaptation, calibration, and review.

## Inventory

| File | Actual observed purpose | Host assumptions | Status |
|---|---|---|---|
| `dart_gate.sh` | PostToolUse-style grep/awk rule checker for edited Dart files; emits Claude-Code-style JSON block feedback and exits 0 | Claude Code env/input protocol (`CLAUDE_TOOL_INPUT_FILE_PATH`/stdin JSON), project `pubspec.yaml` | experimental |
| `preflight_audit.sh` | Claude Code Stop-hook-style repo preflight that can emit JSON `decision:block` feedback | `CLAUDE_PROJECT_DIR`, Claude stop-hook semantics, Flutter project | experimental |
| `check_drift.sh` | TAP-style regression checker for rule/reference-corpus drift in the source skill; does **not** prove generated-code drift | bash, `rg`, source-skill file layout | experimental |
| `analysis_options.reference.yaml` | Example analyzer/linter configuration to compare with project policy | Dart/Flutter analyzer; may mention version-sensitive plugins | experimental-reference |
| `owasp_scan_secrets.py` | Heuristic source scan for hardcoded secret/credential patterns | Python; regex false positives/negatives possible | experimental |
| `owasp_check_deps.py` | Pubspec/version/outdated-package heuristic using Flutter tooling when available | Python + PyYAML + optional Flutter/FVM | experimental |
| `owasp_check_network.py` | Heuristic scan of network URLs/configuration/platform manifests | Python; source/config heuristics | experimental |
| `owasp_analyze_storage.py` | Heuristic scan of local storage/database/backup patterns | Python; source/config heuristics | experimental |

Do not use the copied scripts' internal OWASP-number labels as canonical
taxonomy. The copied files and earlier inventory used inconsistent numbering;
classify findings semantically unless/until the security skill adopts one
versioned taxonomy.

## Canonization Requirements

A tool may become `canonized` only after all applicable items hold:

1. **Correct host contract** — inputs/environment/output protocol match Ganthritor/OpenCode
   or an explicit adapter exists.
2. **Behavioral calibration** — known-bad fixtures fail and known-good fixtures
   pass with acceptable false positives.
3. **Documented contract** — inputs, outputs, side effects, timeout, dependencies,
   exit semantics, determinism/idempotency expectations.
4. **Scoped doctrine** — embedded style/project opinions have been separated from
   universal Flutter correctness.
5. **Workflow/subskill owner** — invocation point and evidence scope are explicit.
6. **Independent review** — confirms the tool proves only the claim it advertises.

A failed candidate should be deprecated/archived rather than silently left as a
"gate".

## Current Operational Rule

Treat all files listed above as **experimental/reference-only** until this table
is explicitly changed through harness governance.
