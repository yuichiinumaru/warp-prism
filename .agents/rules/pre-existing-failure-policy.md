---
id: pre-existing-failure-policy
title: Pre-existing Failure Classification Policy
scope: warp-prism/docs/tasks
status: active
---

# Pre-existing Failure Classification Policy

This builder-facing source rule defines when a test failure can be treated as
pre-existing and when it blocks promotion. It is mirrored in
`docs/governance/pre-existing-failure-policy.md` for canonical governance.

## 1. Classify every failure

| Class | Definition | Promotion effect |
| --- | --- | --- |
| **Pre-existing (unrelated)** | The failure existed before the task and the task did not touch the failing file, module, or contract. | Does **not** block this task, but must be recorded in the failure baseline. |
| **Pre-existing (related)** | The failure existed before the task, but the task touched the same file, module, or contract boundary. | **Blocks** promotion unless the reviewer explicitly justifies the deferral in the task evidence. |
| **Regression (caused)** | The task introduced the failure. | **Always blocks** promotion. No override. |

## 2. Decision rule

1. If the failure was not present before the task changed the code, it is a
   **regression** and must be fixed before `Builder Done`.
2. If the failure was present before and the task touched the failing area, it
   is **related pre-existing** and blocks promotion unless the reviewer signs off
   with a concrete justification.
3. If the failure was present before and the task did not touch the failing area,
   it is **unrelated pre-existing** and may be carried forward only when the
   failure is classified in `docs/reports/warp-prism-test-failure-baseline.md` or
   its successor.

## 3. Builder evidence

A pre-existing claim is incomplete unless completion evidence includes:

- before/after test output or baseline inventory reference;
- failing area and classification;
- files touched by the task;
- regression count, normally `NONE`;
- reviewer justification if a related pre-existing failure is deferred.

Saying only "pre-existing failure" is not evidence.
