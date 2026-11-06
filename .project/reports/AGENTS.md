# `.project/reports/` — Project Report Contract

> **Scope**: project-local reports under `.project/reports/**` in a repository
> that installs this baseline. The nearest `AGENTS.md` and active rules remain
> higher authority. This file is a distributable baseline, not an inventory of
> existing reports or a record of a different project's operator decisions.

## 1. Purpose and destination

A report records evidence, analysis, or decisions with enough provenance to
verify its claims. A report is historical evidence, not current policy; promote
reusable decisions through the project's canonical documentation/governance
process.

New reports use `.project/reports/<lane>/`, with this closed writable set:

| Lane | Work |
|---|---|
| `architects/` | architecture |
| `builders/` | implementation and implementation evidence |
| `reviewers/` | independent review and re-review |

The authorized bootstrap creates these three directories together with this
contract. During normal report writing, an absent destination requires an
explicitly authorized repair, not an improvised `mkdir`. Do not create nested
report directories for tasks, dates, or runs; encode those distinctions in the
filename. Existing legacy report directories remain read-only evidence, not
new write roots, and are not created by bootstrap.

Researchers and orchestrators follow their own governing routes and are exempt
from the persistence obligation below; this contract does not establish those
routes or grant permission to create them.

## 2. Preserve existing records

- Read the applicable local instructions and inspect the destination before
  writing.
- Do not rewrite historical reports to make them agree with current state.
- Do not rename or move existing reports without explicit scope. When an
  authorized transition retires an artifact, preserve it under `.archive/`
  with provenance; deletion is not the recovery path.
- Keep reports free of secrets and credentials.

## 3. Naming and evidence

New reports follow `YYYYMMDD-HHMMSS-<action>-<object>.md`, using UTC creation
time and lowercase kebab-case action/object. Actions are `review`, `rereview`,
`implement`, `fix`, `pathto100`, `audit`, `investigate`, `verify`, `synthesis`,
`closeout`, `smoke`, or `benchmark`. Use `task-<ID>-<slug>` for task work, or a
short object slug otherwise. Do not rename historical reports for conformity.
JSON/log sidecars require explicit authorization and the same basename.

A report should state, as applicable:

- the work or question covered;
- what was observed or changed, with repository-relative paths;
- exact validation performed and its result, or why it was not run;
- evidence sources and prior-report lineage;
- blockers, residual risks, and the next action.

Distinguish observed facts from inference and recommendation. A skipped,
unavailable, or partial validation is not a pass.

## 4. Worker persistence

At completion, a worker writes exactly one report under its declared lane in
the naming convention above, unless the current dispatch explicitly requests
otherwise. Researchers and orchestrators are exempt from this contract's
obligation. In a task ledger, record a compact pointer instead of copying the
entire report. Author implementation evidence is not independent acceptance.

## 5. References

- Repository authority: nearest `AGENTS.md` and applicable active rules.
- Project task/report contracts: local files under `.project/`, when present.
- Harness methods: workspace-accessible assets under `.opencode/`, when present.
- Path ownership: `.opencode/rules/20-path-economy.md`.
- Evidence: `.opencode/rules/30-evidence-and-partiality.md`.

Do not resolve any reference by reading another project's `.project/` tree.
