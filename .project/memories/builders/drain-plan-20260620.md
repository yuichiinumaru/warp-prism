# Drain Plan — 2026-06-20

> Parent orchestrator: `builders`
> Source workflow: `.agents/workflows/gt-builder-orchestrator-drain.md`
> Inputs: live task lanes, `docs/dependency-tree.md`, `docs/reports/builders/harness-upgrades.md`, and batch triage packets under `.agents/profiles/builders/`.

## Summary

- 01-open tasks: 1 (`1103`, superseded)
- 02-doing tasks: 84
- 03-review tasks: 15
- 04-completed tasks: 8
- duplicate task IDs across lanes: 0
- hard global blocker: repo-local workspace contamination (`apps/observatory/tmp/pub-cache` captured by workspace globs) breaks Melos/Dart/Flutter proof commands.
- high-risk governance blocker: `1202` promotion-state evidence drift blocks `1203`, `1206`, `1208`, `1301`, `1401`, and downstream reviews.
- critical pattern: prior build-gate 100/100 scores are not reliable; independent reviews returned many tasks to `02-doing`.

## Triage Reports

| Batch | Path | Coverage | Completeness |
| --- | --- | --- | --- |
| 1 | `.agents/profiles/builders/drain-analysis-20260620-batch-1-foundation.md` | `1103`, `0001`, `0004`, `0006`, `0010-0020`, `0310-0315` | Partial, high-level |
| 2 | `.agents/profiles/builders/drain-analysis-20260620-batch-2-feature-lanes.md` | `0610-0613`, `0710-0713`, `0810-0813` | Complete-enough |
| 3 | `.agents/profiles/builders/drain-analysis-20260620-batch-3-polish-cybercore.md` | `1000-1070`, `1102` | Partial |
| 3b | `.agents/profiles/builders/drain-analysis-20260620-batch-3b-cybercore-components.md` | `1104-1115` | Partial-complete |
| 3c | `.agents/profiles/builders/drain-analysis-20260620-batch-3c-ui-returned.md` | `1116`, `1117`, `1119`, `1120` | Partial-complete |
| 3d | `.agents/profiles/builders/drain-analysis-20260620-batch-3d-highrisk-components.md` | `1121`, `1122`, `1123`, `1126` | Partial-complete |
| 4 | `.agents/profiles/builders/drain-analysis-20260620-batch-4-governance-ads.md` | `1202-1208`, `1301-1307`, `1309` | Complete-enough |
| 5 | `.agents/profiles/builders/drain-analysis-20260620-batch-5-observatory.md` | `1401-1408` | Partial-complete |

## Dependency Order

| Cluster | Root | Dependents | Decision |
| --- | --- | --- | --- |
| Governance truth | `1202` | `1203`, `1206`, `1208`, `1301`, `1401` | First wave; small docs/evidence fix with high unblock value. |
| Workspace/tooling truth | `1107`, `1204` | `1205`, `1303`, `1306`, `1309`, `1401`, `1408`, many validations | First or second wave; must avoid blind deletion and prefer config/path proof. |
| Boundary/barrel | `1301` | `1302`, `1205` | After `1202`; serialize with public barrel edits. |
| Component contract | `1303` | `1304`, `1305`, `1306`, `1307`, `1309` | After workspace cleanup; Flutter serialized. |
| Gallery/goldens | `1304` | `1305`, `1306` | After `1303`; Flutter serialized. |
| Observatory | `1401 -> 1402 -> 1403 -> 1404 -> 1405 -> 1406 -> 1407`; `1408` after `1403` | EPIC-14 | Wait until `1202` and workspace proof are stable. |
| Data/diagnostics | `0314` | `0610`, `0711`, `0810`, `0811`, `0812` | Fix before historical feature lanes. |
| Operate | `0610 -> 0611 -> 0612 -> 0613` | Feature lane | Serialize under one Flutter builder after `0314`. |
| History | `0710 -> 0711 -> 0712 -> 0713` | Feature lane | `0710` may be early evidence refresh; rest after `0314`/data. |
| Governance feature UI | `0810`, `0811`, `0812 -> 0813` | Feature lane | After `0314`; route/a11y. |
| CyberCore | `1102 -> 1108 -> 1109 -> 1110 -> 1111` | CyberCore lane | `1102` blocked on evidence contract; needs explicit source/screenshot evidence. |
| DS component returned tasks | `1105`, `1107` | `1112-1120` | Do not promote components until hard gates are resolved or formally revised. |
| High-risk widgets | `1121`, `1123` | independent component correctness | Can fix later but strict lifecycle/a11y/perf review required. |

## File / Domain Collision Matrix

| File/Domain | Tasks | Collision Risk | Serialization Decision |
| --- | --- | --- | --- |
| `docs/governance/promotion-state-model.md`, `.agents/rules/promotion-state-model.md`, task lane counts | `1202`, `1206`, `1208`, `1401` | High truth dependency | Bundle `1202/1206/1208` under one evidence/governance fixer; `1401` later. |
| Root `pubspec.yaml`, Melos/tooling docs, workspace globs | `1107`, `1204`, `1126`, `1401`, `1408` | High, protected file | Bundle only if one tooling builder owns it; read protected files first; no blind cleanup/deletion. |
| Public barrel `packages/warp_prism_ui/lib/warp_prism_ui.dart` | `1301`, `1302`, `1205`, `1305` | High | Serialize. |
| Component contract / state surface | `1303`, `1307`, `1309` | High | Serialize or same Flutter builder. |
| Gallery/goldens | `1304`, `1305`, `1306` | High | Serialize after `1303`. |
| `workspace_parser.dart` / corpus models | `0311`, `0610`, `0711`, `1403` | High | Serialize by dependency phase. |
| Operate feature | `0610-0613`, `1406` | High | `0610-0613` bundle later; coordinate `1406`. |
| History feature | `0710-0713`, `1406` | High | `0710` early possible; rest later. |
| Governance UI | `0810-0813`, `1402` | Medium/High | Later bundle after diagnostics/data proof. |
| DS organisms/lifecycle | `1116-1123`, `1307` | Medium | Parallel only when file sets distinct; strict lifecycle/a11y gates. |

## Wave Plan

### Wave A — Truth / Validation Unblockers

| Bundle | Tasks | Builder Agent | Reason | Files/Domains |
| --- | --- | --- | --- | --- |
| A1 Governance truth | `1202`, `1206`, `1208` | `gt-evidence-refresher` | Small docs/evidence fixes unblock many tasks; no app code expected. | promotion model, pre-existing policy, lane snapshot evidence |
| A2 Gate matrix / review packet | `1203`, `1207` | `gt-evidence-refresher` or `gt-archivist` | `1203`/`1207` are governance artifacts; need lane/header/path drift repair. | gate matrix, review packet generator docs/scripts |
| A3 Workspace tooling truth | `1107`, `1204` | `gt-gitops-engineer` or `gt-devops-engineer` | Shared workspace contamination and missing Melos contract block validation. | root `pubspec.yaml`, Melos/tooling, repo-local tmp/pub-cache classification |

Notes:
- A3 must not delete files blindly. It should prefer config/glob fixes and explicit evidence. If cleanup of repo-local generated tmp is necessary, the task/parent must explicitly authorize deletion before action.
- A1 and A2 may run concurrently if they do not edit the same files. If both touch the task template or promotion-state docs, serialize A1 before A2.

### Wave B — ADS Boundary / Contract Stabilization

| Bundle | Tasks | Builder Agent | Reason | Files/Domains |
| --- | --- | --- | --- | --- |
| B1 Barrel boundary | `1301`, `1302`, `1205` | `gt-flutter-engineer` | Public-barrel DS leak blocks boundary proof and ADS downstream. | `warp_prism_ui.dart`, prism aliases, boundary tests |
| B2 Component contract | `1303`, `1309`, `1307` | `gt-flutter-engineer` | Component/state/a11y chain; serialize internally. | state surface, operational states, semantics |
| B3 Gallery / goldens / catalog | `1304`, `1305`, `1306` | `gt-flutter-engineer` | Gallery analyzer, catalog proof, golden failures. | gallery, catalog tests, goldens |

### Wave C — Observatory Reconciliation

| Bundle | Tasks | Builder Agent | Reason | Files/Domains |
| --- | --- | --- | --- | --- |
| C1 Baseline/corpus truth | `1401`, `1402` | `gt-evidence-refresher` + `gt-flutter-engineer` if code needed | Fix current baseline and corpus contradiction. | observatory tests, mock corpus reports |
| C2 Parser/view model chain | `1403`, `1404`, `1408` | `gt-flutter-engineer` | Parser/import cleanup before downstream UI proof. | observatory parser, mapper, imports |
| C3 Feature flows/audit | `1405`, `1406`, `1407` | `gt-flutter-engineer` / `gt-archivist` | Responsive/detail/feature flow and legacy test audit. | observatory UI/tests/reports |

### Wave D — Historical Data / Feature Lanes

| Bundle | Tasks | Builder Agent | Reason |
| --- | --- | --- | --- |
| D1 Data diagnostics root | `0310-0315` especially `0314` | `gt-flutter-engineer` | `0314` blocks Operate/History/Governance features. |
| D2 Operate | `0610-0613` | `gt-flutter-engineer` | Serial Operate chain. |
| D3 History | `0710-0713` | `gt-flutter-engineer` | Serial History chain. |
| D4 Governance UI | `0810-0813` | `gt-flutter-engineer` | Depends on diagnostics and route wiring. |

### Wave E — DS Components / CyberCore / Polish

| Bundle | Tasks | Builder Agent | Reason |
| --- | --- | --- | --- |
| E1 CyberCore evidence chain | `1102`, `1108-1111` | `gt-evidence-refresher` / `gt-flutter-engineer` | Current blockers are evidence-domain drift and unapproved inventory. |
| E2 DS component hard gate | `1105`, `1106`, `1112-1120` | `gt-flutter-engineer` | Component promotion blocked by rejected hard gates. |
| E3 High-risk components | `1121`, `1122`, `1123` | `gt-flutter-engineer` | Lifecycle/a11y/performance failures; strict review. |
| E4 Polish / acceptance | `1000-1070`, `1126` | `gt-evidence-refresher` / `gt-flutter-engineer` | Broad cleanup after roots stabilize. |

## Blockers Requiring User / Architecture Decision

| Task | Blocker | Needed Decision |
| --- | --- | --- |
| `1102` | Approved CyberCore screenshot/source evidence missing; task says blocked. | Provide/authorize source evidence or revise task contract. |
| `1107` / workspace contamination | Repo-local generated `tmp/pub-cache` is breaking workspace discovery. | Decide if deletion of repo-local generated tmp/cache artifacts is authorized, or require config-only exclusion. |
| `1126` | Touches protected `README.md` and potentially `pubspec.yaml`. | Task appears to authorize docs/tooling reality alignment; still serialize and read protected files. |
| `0410`, `0510-0514` in `03-review` | Headers say Doing despite review lane. | Reviewer/orchestrator lane-state decision; parent builder should not move review-lane tasks directly. |

## Review/Fix Handoff Plan

After Wave A builder fixes, use `.agents/workflows/gt-build-orchestrator-rfloop.md`:

| Review Batch | Tasks | Reviewer Agent | Reason |
| --- | --- | --- | --- |
| R-A1 | `1202`, `1206`, `1208` | `gt-architect-reviewer` or `gt-documentation-accuracy-reviewer` | Governance docs/evidence. |
| R-A2 | `1203`, `1207` | `gt-architect-reviewer` or `gt-documentation-accuracy-reviewer` | Gate/review packet governance. |
| R-A3 | `1107`, `1204` | `gt-devops-runtime-reviewer` plus `gt-flutter-code-reviewer` if Flutter commands touched | Tooling/workspace validation. |

## First Dispatch Recommendation

Start with Wave A because it has the highest unblock value and minimal app-code collision:

1. Dispatch `gt-evidence-refresher` for `1202`, `1206`, `1208`.
2. Dispatch `gt-evidence-refresher` or `gt-archivist` for `1203`, `1207` only if no shared file conflict after reading task Where tables.
3. Dispatch `gt-gitops-engineer` for `1107`, `1204` as a bounded tooling remediation, with explicit instruction: **do not delete/move cache/tmp files unless task text explicitly authorizes it or parent/user approves; prefer workspace config/path fixes**.

Then run rfloop on completed Wave A tasks.
