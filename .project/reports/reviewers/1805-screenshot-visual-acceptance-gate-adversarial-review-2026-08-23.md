# Task 1805 Adversarial Review — Screenshot Visual Acceptance Gate and Golden Policy

- **Review date:** 2026-08-23
- **Reviewer profile:** `reviewers`
- **Review mode:** independent adversarial visual QA/editor review; infrastructure claims separated from human approval
- **Score:** **90/100**
- **Verdict:** **PASS FOR INFRASTRUCTURE HANDOFF; EXTERNAL_BLOCKER / EVIDENCE_GAP**
- **Lane:** remains `docs/tasks/03-review/`

## Lineage and claim reconciliation

Previous report: `docs/reports/review/1805-screenshot-visual-acceptance-gate-independent-review-2026-08-23.md` (builder-context `100/100`). The current review confirms its Option A interpretation but independently re-runs the relevant checks. No user visual sign-off, approved target PNG, candidate PNG, or golden refresh authorization is present. The prior report is not evidence of human acceptance; it explicitly says the gate is pending.

## Infrastructure / human gate separation

Infrastructure proven:

- Existing plain `matchesGoldenFile` harness retained.
- Canonical `PrismTheme.dark()` wrappers and host capture test files exist.
- Catalog, Observatory, and CyberCore capture suites declare deterministic 1280x800 / DPR 1.0 settings.
- Freeze policy forbids golden regeneration before user approval.
- Capture helpers preserve failures via logging and do not claim PNGs when unavailable.

Human approval **not proven**:

- `PENDING-USER` remains on target artifact, checklist, before/after report, rejected-output preservation, and golden refresh.
- `docs/design/screenshots/apps_catalog_target_reference_1800.png` is absent.
- `docs/reports/captures/` is absent; no candidate or rejected PNG exists.
- Frozen golden suite still fails 59 tests; this is expected interim drift under the contract, not a passing visual gate.

## Runtime capture result

Previously completed evidence preserved:

- Catalog typography capture: 1/1 passed, but `takeScreenshot` raised `MissingPluginException`; no PNG produced.
- Observatory integration capture: **EXTERNAL_BLOCKER** — `Bad state: Cannot close sink while adding stream` / test-device timeout.
- CyberCore capture remains infrastructure-only based on existing report; no screenshot is independently claimed here.

The Observatory failure is a tooling/runtime blocker, not a product pass. It prevents host-level rendered proof in this environment and must remain visible in the report lineage.

## Axiom matrix

| Axiom | Status | Evidence |
|---|---|---|
| Deterministic harness | ✅ | Host tests, fixed viewport/DPR, canonical theme wiring, and bounded specimen fixtures exist. |
| Screenshot ground truth | ❌ | No PNG target/candidate artifact exists; Catalog driver unavailable; Observatory runtime blocked. |
| Golden freeze safety | ✅ | No `--update-goldens` run; 59 failures remain against frozen PNGs. |
| Rejected-output preservation | ⚠️ | Policy is documented, but no rejection artifact exists because no candidate PNG was produced. |
| Human approval distinction | ✅ | Task and report explicitly preserve `PENDING-USER`; no self-signing found. |
| Analyzer/tests | ✅ | Package analyzer 0 errors; scoped 189/189; boundary 7/7; Catalog analyzer clean; Observatory/CyberCore analyzers no errors. |

## Findings

### F1 — No visual artifact can be approved (EXTERNAL_BLOCKER / EVIDENCE_GAP; blocking human gate)

The acceptance gate has no committed or generated screenshot artifact. The target reference path is missing, the candidate capture directory is missing, Catalog's driver capture is unavailable, and Observatory's runtime capture fails with a stream-channel shutdown error. The policy is honest, but visual acceptance is not proven.

**Path to 100:** run the capture suite on a supported desktop/integration device, preserve candidate and rejected PNGs under the documented paths, record user sign-off, then perform exactly one approved golden refresh.

### F2 — Golden suite remains red (policy-expected, not silently green)

Live `flutter test test/goldens/ --concurrency=1 --no-pub` reports **59 failures** against frozen baselines. The task correctly labels this expected drift, but any downstream promotion must not describe the visual suite as passing until post-approval refresh succeeds.

**Path to 100:** after F1 user approval only, run the single deliberate refresh and prove the suite green; preserve pre-refresh and rejected artifacts.

## Validation evidence

- Package analyzer: PASS, 218 infos/0 errors.
- Scoped package tests: PASS, 189/189.
- Boundary harness: PASS, 7/7.
- Golden suite: FAIL, 59 frozen-baseline failures; no refresh.
- Catalog typography capture: PASS test harness, screenshot `MissingPluginException`, no PNG.
- Observatory capture: EXTERNAL_BLOCKER, `stream_channel` Bad state / timeout.
- Non-mutating format check: red; formatter reports 9 changed reviewed files. No formatting mutation performed.

## Score rationale

90/100: infrastructure policy is strong and evidence is honest, but the actual visual acceptance artifacts and host runtime proof are absent. Score is high enough to remain in review, but this is not visual approval or golden acceptance.

## Path to 100

1. Resolve or move Observatory capture to a supported device/runtime; rerun without timeout.
2. Produce Catalog/Observatory/CyberCore candidate PNGs, or record a durable external blocker with a supported capture plan.
3. Obtain explicit product-owner visual sign-off tied to artifact hashes/paths.
4. Preserve rejected output and perform one authorized golden refresh.
5. Prove goldens pass after refresh; rerun non-mutating format gate.