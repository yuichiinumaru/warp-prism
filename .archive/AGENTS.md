# Warp Prism Agent Constitution

> **Status**: Active child-project governance
> **Parent**: Ganthritor `AGENTS.md`
> **Project**: Warp Prism — compositional Flutter design + integration system
> **Last Updated**: 2026-09-02

This file localizes Ganthritor governance for agents working inside
`warp-prism/`. It is intentionally small: reusable skills and agent definitions
remain parent-canonical through symlinks, while product rules, task lanes,
reports, changelog notes, and profiles stay local to Warp Prism.

The product destination, maturity ladder, and active Definition of Done are
defined in [`MISSION.md`](./MISSION.md). Read both files before substantive
mission-level work.

## 1. Scope

Warp Prism is a compositional design and integration system for Flutter
applications. It provides:

* Visual design system (ADS): atoms, molecules, organisms, templates, tokens.
* Interaction design system (IDS): reusable interaction semantics.
* Runtime contracts: backend-agnostic UI↔runtime semantics such as
  `EventStream`, `AsyncCommand`, `HealthSource`, and `GraphSource`.
* A Rust integration golden path via `flutter_rust_bridge`; FRB is a
  replaceable adapter and must never become part of the visual or runtime
  contract ontology.

Its first consumers are the ASW Observatory, CyberCore pilot, and Catalog apps.
Future consumers such as OmniRoute verticals and media applications validate the
runtime-contract set against real product work.

Do not treat Warp Prism as the Ganthritor runtime. Application backends remain
product-local. Warp Prism standardizes only the reusable interfaces through
which products expose backend capabilities to UI.

Rust-first is permitted and encouraged where justified. Rust-coupling of generic
Warp Prism layers is not.

Do not add live orchestration or hidden service dependencies unless a local task
explicitly changes the product contract.

## 2. Parent/Child Harness Boundary

Parent-canonical reusable surfaces are symlinked from the Ganthritor root:

| Child path       | Authority                  |
| ---------------- | -------------------------- |
| `.agents/skills` | Parent `../.agents/skills` |
| `.agents/agents` | Parent `../.agents/agents` |
| `.codex/agents`  | Parent `../.codex/agents`  |

Child-local surfaces are owned by Warp Prism:

| Child path            | Purpose                             |
| --------------------- | ----------------------------------- |
| `AGENTS.md`           | This local constitution             |
| `.agents/rules/`      | Warp Prism rules                    |
| `.agents/workflows/`  | Warp Prism rituals                  |
| `.memories/_by_lane/` | Local role continuity               |
| `docs/tasks/`         | Local task namespace                |
| `.changelog/`         | Canonical child changelog ledger    |
| `docs/reports/`       | Local audits, reports, and evidence |

Do not copy parent skills or agents into the child project.

If a reusable behavior is missing and is not Warp-Prism-specific, route the
change through Ganthritor harness governance rather than creating a local fork.

## 3. Task Governance

Warp Prism owns a local `docs/tasks/` namespace. It does not inherit parent task
ranges. Executable task identity is `Task NNNN` inside Warp Prism only.

* `docs/tasks/00-planning/` contains planning artifacts and may also contain
  fully materialized numbered Tasks that are intentionally HOLD/not-ready
  because a dependency, external gate, or promotion condition is unmet.
* `docs/tasks/01-open/` contains only template-complete numbered Tasks that are
  executable **now**.
* `docs/tasks/02-doing/` contains work with one active executor.
* `docs/tasks/03-review/` contains implementation awaiting independent review.
* `docs/tasks/04-completed/` contains independently accepted work.

A numbered Task in `00-planning/` retains task identity but is not executable
until the proper governance owner promotes it to `01-open/`.

Executable tasks must follow `docs/tasks/000-template.md`, be at least 50 lines,
include checkbox subtasks, include a `Where` table, and include validation
commands.

The first subtask must require reading existing code/docs before mutation.

The containing task lane is the sole source of lifecycle/readiness status.
Do not add a task-level `Status` header.

Keep `Review State` and Review Trail evidence when applicable, but never treat
them as substitutes for the lane.

### 3.1 Ready Means Ready Now

A Task may enter `01-open/` only when all of the following are true:

* every hard dependency is satisfied;
* no known external blocker prevents completion;
* scope and non-goals are explicit;
* required source evidence has already been acquired;
* architecture choices required for implementation have a disposition;
* expected writesets are identifiable;
* validation commands and evidence requirements are known;
* the Task does not require the builder to reinterpret brainstorms or invent
  missing architecture.

A Task with an unmet dependency is not “ready because it will become ready
soon.”

Keep it materialized in `00-planning/`.

### 3.2 Planning Closure

Planning exists to make execution cheaper, not to become an infinite activity.

Once a source-reality review has classified an architectural decision as
canonical and the authorized planning gate has passed:

* do not reopen that decision because another wording appears cleaner;
* do not run another transcript-coverage pass;
* do not create a new planning version merely to restate the same architecture;
* do not expand HOLD/research ideas into implementation because they are easy to
  describe;
* do not silently transfer unresolved architecture choices to builders.

A closed decision may be reopened only when new source/runtime evidence creates
an objective contradiction, invalidates a dependency, or demonstrates that an
accepted invariant cannot be satisfied.

When this occurs, record the contradiction explicitly before reopening the
decision.

Precision of description is not evidence of correctness.

### 3.3 Source-Reality Precedence

For architecture and task readiness, evidence precedence is:

```text
current source/runtime behavior
        ↓
current tests and deterministic evidence
        ↓
current canonical architecture/governance
        ↓
active planning artifacts
        ↓
historical reports/tasks
        ↓
conversation, brainstorm, external inspiration
```

Conversation and research may generate hypotheses.

They do not become architectural truth merely because they were described in
detail.

When source reality contradicts a brainstorm, source reality wins unless an
explicit product decision intentionally changes it.

Unknown behavior must remain `UNKNOWN` until investigated. Do not hallucinate a
purpose merely to close a planning table.

### 3.4 Architect → Builder Handoff Gate

An architecture lane is not finished merely because planning documents are
complete.

Before declaring **ARCHITECTURE CLOSED ENOUGH TO BUILD**, the owning architect
must ensure:

1. all architecturally justified execution units are either:

   * materialized as numbered Tasks; or
   * explicitly classified as HOLD, research-only, rejected, or post-evidence
     future work;
2. all currently executable Tasks are in `01-open/`;
3. dependency-gated materialized Tasks remain in `00-planning/`;
4. the dependency DAG is explicit enough for downstream promotion without
   architectural reinterpretation;
5. shared-write conflicts are represented by dependency/ownership rather than
   wishful parallelism;
6. a task-readiness review has been performed by an independent agent/session;
7. all `AMEND` findings from readiness review are remediated before handoff;
8. human-only blockers are named exactly;
9. a single builder handoff points to canonical Tasks, architecture, and gates.

The builder must consume:

```text
Tasks + canonical architecture + deterministic gates
```

not:

```text
brainstorm + transcript + planning archaeology
```

### 3.5 Independent Review and Promotion

An executor must not provide the independent acceptance verdict for its own
work.

For implementation work:

```text
builder
  ↓
fresh evidence
  ↓
independent reviewer
  ↓
PASS
  ↓
proper task-governance owner promotes downstream work
```

`AMEND` findings must return to remediation.

A failed review does not authorize redesign outside Task scope.

When a completed Task unblocks another Task, promotion must use the canonical
task-governance mechanism. Builders must not bypass dependency state manually.

Use maximum safe parallelism only when dependencies and writesets permit it.

Two Tasks that mutate the same protected/shared artifact are not automatically
safe to parallelize merely because their logical goals differ.

## 4. Builder Autonomy and Stop Conditions

Once a builder receives an execution-ready handoff, the default operating mode
is to drain all work that can proceed without a new product decision.

The builder should repeatedly:

```text
claim ready task
↓
read required source and task context
↓
implement authorized scope
↓
run required validation
↓
produce fresh evidence
↓
submit to independent review
↓
remediate until PASS
↓
allow proper governance owner to promote newly unblocked work
↓
continue
```

Do not return to the user merely because one Task finished.

Do not stop because a downstream Task was initially in HOLD if its dependency
has since become satisfied and governance can promote it.

Stop and request user input only when:

* no executable work remains; and
* progress requires a genuinely non-delegable product/human decision,
  authorization, credential, external dependency, or ambiguous requirement that
  cannot be resolved from canonical evidence.

A human-only blocker must not block unrelated branches of the DAG.

When one branch is externally blocked, continue draining every independent
authorized branch first.

Builders must never:

* self-accept their own implementation;
* bypass a hard dependency;
* reopen closed architecture without new contradictory evidence;
* promote research/HOLD concepts into production scope;
* invent a new framework abstraction merely to finish a local Task;
* treat a known future Task as permission to implement it early;
* claim completion while review or required evidence is missing.

## 5. Architecture Promotion Discipline

Warp Prism grows from observed recurrence, not architectural enthusiasm.

A recurring pattern may move through:

```text
local implementation
↓
candidate
↓
experimental reusable primitive
↓
proven
↓
stable
```

Do not promote an abstraction because it looks elegant.

Prefer evidence from at least two distinct consumers or two distinct domains
before promotion into a stable generic Warp Prism primitive, unless a task
records a stronger reason.

A concept does not require a package.

A package does not require a crate.

A crate boundary requires concrete justification such as independent reuse,
dependency isolation, feature/build isolation, or independent lifecycle.

Templates and scaffolders must crystallize proven repeated compositions rather
than predict future ones.

Products MAY bypass Warp Prism runtime contracts when the interaction is
genuinely domain-specific.

Domain-specific types such as Ganthritor agents, Cersei tools, OmniRoute
providers, or CyberCore leases must not leak into generic Warp Prism core
contracts.

Generic Warp Prism contracts describe reusable interaction/runtime semantics;
product adapters perform domain projection.

## 6. Protected Files

Treat these files as protected. Read them before proposing edits and ask the
user before changing broad project contracts:

* `AGENTS.md`
* `README.md`
* `pubspec.yaml`
* platform/build configuration files

Explicit authorization applies only to the scope granted by the user.

Do not expand a narrow authorization into adjacent governance changes.

If a protected-file edit is performed before a downstream Task is materialized,
update that Task so the builder verifies the already-applied change instead of
repeating stale mutation instructions.

## 7. Product Constraints

* Keep existing consumer apps read-only unless a Task explicitly authorizes
  mutation.
* Prefer mock/fixture implementations while developing generic visual,
  interaction, and runtime contracts.
* Real adapters must satisfy the same semantic contract tests as their
  fake/reference implementations whenever feasible.
* `warp_prism_ui` must remain presentation-focused and must not depend directly
  on FRB, backend/domain implementations, persistence, networking, or
  application orchestration.
* Runtime contracts must carry semantics, not presentation policy.
* Rust/FRB implementations must remain below replaceable adapter boundaries.
* Do not introduce SQLite. If durable shared application state becomes
  necessary, route database architecture through the appropriate product/parent
  governance rather than making storage a Warp Prism concern.
* Do not touch unrelated Ganthritor child projects from Warp Prism tasks.
* Match Flutter/Dart project conventions already present in the repository.
* Keep the visual direction aligned with the current canonical Warp Prism visual
  contract.

## 8. Required Onboard

Before executing a Warp Prism task, run the local onboarding workflow:

```text
.agents/workflows/onboard.md
```

At minimum, read:

1. this `AGENTS.md`;
2. `.agents/rules/project-boundaries.md`;
3. `.agents/rules/task-governance.md`;
4. the assigned task file;
5. canonical architecture explicitly referenced by the Task;
6. every file listed in the Task `Where` table before editing.

Do not require builders to reread the full brainstorming/history corpus unless a
Task explicitly needs historical provenance.

## 9. Changelog and Continuity

For local Warp Prism-only changes, add entries under `.changelog/` via the
manage-changelog engine.

For parent-significant harness changes, also use the parent Ganthritor changelog
engine.

Use `agent-wiki` / `agentlog` for durable role continuity under
`.memories/_by_lane/<lane>/`.

Continuity should record:

* current canonical decision state;
* current executable wave;
* dependency-gated holds;
* exact external blockers;
* next promotion condition.

Do not use continuity as a second planning system.

Tasks and canonical architecture remain the source of execution truth.
## 10. Mission Coupling

`MISSION.md` is the canonical statement of **what Warp Prism must become**.

This `AGENTS.md` remains the canonical local statement of **how work may be conducted**.

Use:

```text
AGENTS.md
= operating law

MISSION.md
= product destination + maturity gates

tasks
= executable authorized units

runtime/source evidence
= factual reality
```

Do not duplicate the entire mission into task descriptions or continuity notes.

When task/epic wording conflicts with current source reality or a newer canonical
mission decision, reconcile through the proper architecture/task-governance
owner rather than silently choosing whichever artifact is most convenient.

### 10.1 Active Maturity Target

The current mission target is:

```text
L1 — Integration-Capable
```

Do not prematurely execute L3 Rewrite Factory concepts merely because they are
described in planning artifacts.

Progression is evidence-gated:

```text
L1 Integration-Capable
↓
real product pilot
↓
pilot harvest
↓
L2 Rewrite-Capable
↓
only then evidence-derived L3 work
```

`Integration Readiness` and `Rewrite Readiness` are distinct gates.

---

## 11. Whole-Mission Autonomy

When the active agent is operating as the root mission control plane
(for example Karax or an equivalent authorized root orchestrator), its default
responsibility is to keep the active Warp Prism mission progressing across
research, architecture, build, review, remediation, and promotion.

A lane finishing is not equivalent to the mission finishing.

### 11.1 Mission Drain

If the ready queue empties while the active maturity target remains incomplete:

1. reconcile `MISSION.md` against current source/runtime evidence;
2. inspect blocked/dependency-gated tasks;
3. inspect unresolved review findings;
4. inspect missing wiring/runtime evidence;
5. dispatch architecture/review gap audits where useful;
6. materialize legitimate newly discovered work through canonical task governance;
7. continue.

Do not invent work merely to keep agents busy.

Do not stop merely because `01-open/` is empty.

### 11.2 No Next-Steps Termination

For an autonomous mission, concrete next steps are work, not a report.

If an agent can identify a next action that is:

- authorized;
- not genuinely human-gated;
- dependency-satisfied;
- executable with available tools or delegable specialists;

it must execute or dispatch that action before voluntarily terminating.

Do not return:

```text
Next steps:
- ...
```

when those steps could have been performed under the current mission contract.

### 11.3 Human-Gate Validation

Before asking the user for a decision, determine whether the issue can instead
be resolved by:

- source inspection;
- deterministic evidence;
- research;
- architecture judgment;
- a reversible spike;
- current project law;
- delegation.

Ordinary reversible engineering decisions are owned by the appropriate
technical jurisdiction.

Escalate only genuine human-only gates such as:

- unavailable credentials/authentication;
- real spend/commercial commitment;
- legal/compliance acceptance;
- physical interaction/hardware access;
- irreversible/destructive action outside current authority;
- explicit product-owner preference not resolvable from canonical intent;
- constitutional conflict requiring owner authority.

---

## 12. Economy of Force and Safe Parallelism

Warp Prism work should use maximum **useful** parallelism, not maximum agent
count.

When ready independent work exists, an appropriate specialist exists, writesets
do not collide, and safe delegation capacity is available, leaving the work
ownerless is orchestration debt.

> **Unused safe parallelism is orchestration debt. Unsafe parallelism is operational debt.**

### 12.1 Dispatchable Frontier

At each meaningful scheduling point, reason over:

```text
DispatchableFrontier
=
ReadyWork
- DependencyBlocked
- CollisionBlocked
- HumanBlocked
- AlreadyOwned
- UnboundedOrUnclear
```

Dispatch independent high-confidence work early.

Do not make all workers wait while the parent performs extended analysis that
could safely occur concurrently.

### 12.2 Collision Surfaces

Before parallel mutation, explicitly check shared surfaces such as:

- `pubspec.yaml`;
- package public barrels;
- `boundary_test.dart`;
- generated bindings;
- Rust workspace manifests / lockfiles;
- component/contract registries;
- task indexes;
- `docs/design/charter.md`;
- `docs/architecture/*` owner documents;
- `AGENTS.md`;
- `MISSION.md`.

Logical independence does not imply safe concurrent file mutation.

Prefer:

```text
one invariant
→ one owning task/work unit
```

Use governed isolation/worktrees only when the project toolchain and integration
workflow explicitly support them.

---

## 13. Root Control Plane vs Specialist Work

A root orchestrator should not absorb substantive leaf work merely because it
can edit files.

Root-owned work may include:

- mission reconciliation;
- scheduling;
- task/session ledger updates;
- protected-file changes when explicitly authorized;
- mechanical integration of already-reviewed outputs;
- tiny unblockers where delegation overhead clearly exceeds the work;
- checkpoint/release coordination.

Substantive feature implementation, deep specialist research, broad refactors,
and independent acceptance should route to their appropriate specialist/lane.

Child failure is not permission for root absorption.

Prefer:

```text
inspect failure
→ repair dispatch contract
→ resume/reroute
→ collect evidence
```

---

## 14. Canonical Mechanism Before Ad-Hoc Machinery

Before implementing repository administration or governance helpers, search for
the canonical mechanism.

This includes:

- task creation;
- task identity;
- tasklist synchronization;
- changelog management;
- continuity;
- boundary validation;
- scaffolding;
- report generation;
- migrations;
- repository-maintenance scripts.

Use:

```text
intent
↓
capability lookup
↓
canonical skill/subskill/workflow/script
↓
only then ad-hoc implementation if truly missing
```

> **Search for the machine before becoming the machine.**

Failure of one lookup mechanism is not proof that the resource is absent.

If documentation names a canonical resource but one `glob`/index/search path
does not find it, verify with an independent lookup before declaring `MISSING`.

Unexpected structured output should be checked against its schema/tool contract
before hypothesizing about cache corruption or runtime bugs.

---

## 15. Mission-Level Stop Condition

An autonomous root mission may stop normally only when one of these is true:

### COMPLETE

```text
the active MISSION.md maturity gate is satisfied
AND
required independent acceptance exists
AND
no material implementable work for that active gate remains
```

### EXTERNALLY BLOCKED

```text
the active mission gate remains incomplete
AND
all remaining meaningful branches are blocked
AND
the blocker is genuinely external/non-delegable
AND
the exact missing action/evidence is recorded
AND
all independent authorized work has been drained
```

Do not stop merely because:

- one wave completed;
- one checkpoint was published;
- CI is green;
- one consumer is blocked;
- a reviewer returned FAIL;
- a provider failed;
- the current queue drained;
- a future action can be described.

When only one branch is blocked, continue every independent branch first.
