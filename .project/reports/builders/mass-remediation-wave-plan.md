# Mass Remediation Wave Plan — 02-doing Drain

> **Date**: 2026-06-29
> **Owner**: builders
> **Purpose**: Drain the remaining `docs/tasks/02-doing/` backlog through bounded specialized builder waves, while avoiding CPU/RAM crashes.

---

## Safety Policy

This plan inherits `docs/reports/builders/oom-risk-and-safe-execution-plan.md`.

### Prohibited in builder waves

Builders must not run:

- `dart run melos run validate`
- `dart run melos run test`
- `dart run melos run analyze`
- `dart run melos run test-ui`
- `dart run melos run test-observatory`
- unscoped `flutter test`
- `flutter test --coverage`
- full golden suite unless the task is explicitly golden-only and the command is scoped
- full app/package analyze such as `flutter analyze lib/` or `flutter analyze apps/observatory/`

### Allowed low-risk checks

- `dart format --output=none --set-exit-if-changed <small-path>`
- `dart analyze <specific-file-or-small-path>`
- `rg <pattern> <bounded-path>`
- `dart run melos run test-boundaries`
- `dart run melos run test-contamination`

### Conditional checks

Only if task-scoped and cheap:

- `flutter test --concurrency=1 --no-pub <single-test-file>`
- `flutter test --concurrency=1 --no-pub <small-test-directory>`

If a validation would be broad, builders must skip it, record `validation-deferred-due-oom-safety`, and provide the exact safe command for the later reviewer wave.

---

## Current State Summary

Already promoted to `03-review/` during the stabilization wave:

- EPIC-12/13: `1203`, `1204`, `1205`, `1207`, `1301`, `1302`, `1303`, `1304`, `1305`, `1306`, `1307`, `1309`.

Remaining in `02-doing/`: 83 tasks.

The remaining tasks are mostly historical backlog and Observatory reconciliation. Prior evidence shows many have stale `100/100` claims followed by independent review rejection. Builders must prefer latest independent review reports and live code over old task claims.

---

## Wave A — 10 Specialized Builder Packs

Each pack owns a mostly non-overlapping domain and up to five tasks. Builders leave tasks in `02-doing/` and update task evidence/review ledger. Reviewers run only after the builder wave finishes.

| Pack | Agent | Tasks | Domain | Primary Paths |
| --- | --- | --- | --- | --- |
| A1 | `gt-flutter-engineer` | `1401`, `1402`, `1403` | Observatory baseline/corpus/parser | `apps/observatory/test/data`, `docs/reports/*observatory*`, parser/data files |
| A2 | `gt-flutter-engineer` | `1404`, `1405`, `1408` | Observatory mappers/detail/import cleanup | `apps/observatory/lib/data`, `apps/observatory/lib/features/asset_detail`, import paths |
| A3 | `gt-flutter-engineer` | `0001`, `0004`, `0006`, `0019`, `0020` | Mock workspace corpus and snapshots | `apps/observatory/assets/mock_workspace`, corpus fixture docs |
| A4 | `gt-flutter-engineer` | `0010`, `0011`, `0012`, `0013` | Foundation/bootstrap/router/validation | app bootstrap, router shell, README/validation docs |
| A5 | `gt-flutter-engineer` | `0014`, `0015`, `0016`, `0017`, `0018` | Legacy design-system baseline | `packages/warp_prism_ui/lib/src/tokens`, atoms/molecules/organisms/gallery/a11y |
| A6 | `gt-flutter-engineer` | `0310`, `0311`, `0312`, `0313`, `0314` | Data backbone and graph inference | `apps/observatory/lib/data`, parser/repository/graph/metrics tests |
| A7 | `gt-flutter-engineer` | `0410`, `0411`, `0412`, `0413`, `1020` | App shell, navigation, overview, responsive shell | `apps/observatory/lib/app`, shell/router/overview tests |
| A8 | `gt-flutter-engineer` | `0510`, `0511`, `0512`, `0513`, `0514` | Map workspace surfaces | `apps/observatory/lib/features/map`, map tests |
| A9 | `gt-flutter-engineer` | `0610`, `0611`, `0612`, `0613`, `1120` | Operate board and drag/drop | `apps/observatory/lib/features/operate`, task board, DnD tests |
| A10 | `gt-flutter-engineer` | `0710`, `0711`, `0712`, `0713`, `1050` | History and demo narrative | `apps/observatory/lib/features/history`, timeline/story tests |

---

## Later Waves

### Wave B — Governance/detail/polish/control surface

- Governance: `0810`, `0811`, `0812`, `0813`, `1070`.
- Detail: `0901`, `0902`, `0903`, `0904`, `0905`.
- Polish: `1000`, `1010`, `1030`, `1040`, `1060`.
- Control/CyberCore components: `1102`, `1104`, `1105`, `1106`, `1107`, `1108`, `1109`, `1110`, `1111`, `1112`, `1113`, `1114`, `1115`, `1116`, `1117`, `1119`, `1121`, `1122`, `1123`, `1126`.
- Remaining data task: `0315`.
- Remaining Observatory after dependencies: `1406`, `1407`.

### Review wave

After each builder wave, launch reviewers in parallel by domain:

- `gt-flutter-code-reviewer` for Flutter package/app code tasks.
- `gt-code-quality-reviewer` for docs/governance/corpus-heavy tasks.

Reviewers may promote to `03-review/` only at `100/100` or after applying a minimal path-to-100 patch from `90 <= S < 100`.

---

## Builder Prompt Contract

Every builder prompt must include:

1. Use local symlinks only: `.agents/agents`, `.agents/skills`, `.agents/workflows`; do not search parent repo manually.
2. Read assigned task files and latest review reports before editing.
3. Fix only assigned tasks and domain paths.
4. No broad commands; apply OOM safety policy.
5. Update each task's Completion Evidence and Review Ledger.
6. Leave in `02-doing/`; do not promote.
7. Return files changed, validations run/skipped, blockers, and proposed reviewer commands.
