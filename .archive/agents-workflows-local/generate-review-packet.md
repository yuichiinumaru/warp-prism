# Generate Review Packet Workflow

> **Purpose**: Step-by-step guide for generating a review packet.
> **Origin**: Task 1207 (Review Packet Generator)

## Steps

1.  **Prepare Task Evidence**
    *   Ensure your task file has a filled `Completion Evidence` section.
    *   Ensure you have run all required gates per the Gate Matrix.

2.  **Create Packet File**
    *   Create a new file named `review-packet-{task-id}.md` in the task directory or a shared `docs/reviews/` directory.

3.  **Fill Header**
    *   Copy the template from `docs/governance/review-packet-template.md`.
    *   Fill in `Task ID`, `Date`, `Executor`, and `Task Type`.

4.  **Summarize Changes**
    *   Write a 1-paragraph summary of the work done.
    *   List all files modified/created in the `Files Changed` table.

5.  **Record Gate Results**
    *   For each gate you ran, add a row to the `Gate Results` table.
    *   **Command**: The exact command run.
    *   **Result**: PASS or FAIL.
    *   **Classification**: Use the Failure Taxonomy from `promotion-state-model.md` (e.g., `stale test`, `pre-existing`).

6.  **Document Known Failures**
    *   If any tests failed but were classified as `pre-existing` or `stale test` (and fixed elsewhere), list them in `Known Failures`.
    *   **Justification**: Explain why this failure does not block promotion (e.g., "Existing failure tracked in Task 1234").

7.  **Add Risk Notes**
    *   Note any risks or areas the reviewer should focus on.
    *   Note any skipped gates (and why).

8.  **Recommend Promotion State**
    *   Based on the results, recommend a state:
        *   **Ready For Review**: All required gates pass.
        *   **Needs Fix**: You found issues during gating that you are fixing.
        *   **Blocked**: External dependency prevents gating.

## Failure Classification Guide

| Class | Meaning | Action |
|-------|---------|--------|
| `pre-existing` | Failure existed before this task. | Do not block promotion, but document in "Known Failures". |
| `stale test` | Test expects old behavior, code is correct. | Do not block promotion if the test is being fixed in a follow-up task. Document in "Known Failures". |
| `real regression` | Task broke something that was working. | **BLOCK PROMOTION**. Fix the regression before submitting the packet. |
| `broken compile` | Code does not compile. | **BLOCK PROMOTION**. Fix the compile error. |
| `contract drift` | API signature mismatch. | **BLOCK PROMOTION** if related to the task. Fix or update consumers. |
