# Warp Prism Agent Constitution

> **Status**: Active child-project governance
> **Parent**: Ganthritor `AGENTS.md`
> **Project**: Warp Prism — compositional Flutter design + integration system
> **Last Updated**: 2026-09-03

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

| Child path                  | Purpose                             |
| --------------------------- | ----------------------------------- |
| `AGENTS.md`                 | This local constitution             |
| `.agents/rules/`            | Warp Prism rules                    |
| `.agents/workflows/`        | Warp Prism rituals                  |
| `.project/memories/<lane>/` | Local role continuity               |
| `.project/tasks/`           | Local task namespace                |
| `.project/changelog/`       | Canonical child changelog ledger    |
| `.project/reports/`         | Local audits, reports, and evidence |

Do not copy parent skills or agents into the child project.

If a reusable behavior is missing and is not Warp-Prism-specific, route the
change through Ganthritor harness governance rather than creating a local fork.

## 3. Task Governance

Warp Prism owns a local `.project/tasks/` namespace. It does not inherit parent task
ranges. Executable task identity is `Task NNNN` inside Warp Prism only.

* `.project/tasks/00-planning/` contains planning artifacts and may also contain
  fully materialized numbered Tasks that are intentionally HOLD/not-ready
  because a dependency, external gate, or promotion condition is unmet.
* `.project/tasks/01-open/` contains only template-complete numbered Tasks that are
  executable **now**.
* `.project/tasks/02-doing/` contains work with one active executor.
* `.project/tasks/03-review/` contains implementation awaiting independent review.
* `.project/tasks/04-completed/` contains independently accepted work.

A numbered Task in `00-planning/` retains task identity but is not executable
until the proper governance owner promotes it to `01-open/`.

Executable tasks must follow `.project/tasks/000-template.md`, be at least 50 lines,
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

### 3.6 Post-Acceptance Evidence Invalidation

Acceptance is always relative to an evidence snapshot.

A previously recorded `PASS` remains historically valid for the evidence that
supported it. It does not become retroactively dishonest merely because newer
evidence appears.

However, when newer authoritative source/runtime evidence materially
contradicts a claim that contributed to active task, milestone, or maturity
acceptance:

```text
historical PASS
+
new contradictory material evidence
↓
active claim = REVALIDATION_REQUIRED
```

Do not erase the historical verdict.

Do not ignore the newer evidence.

Instead:

1. identify exactly which acceptance dimensions were invalidated;
2. preserve unaffected evidence;
3. materialize or reopen the minimum remediation/evidence work necessary;
4. rerun invalidated verification;
5. require independent re-review for the affected claim;
6. restore active acceptance only after the contradictory evidence is resolved.

A new host/runtime failure discovered after package-local green tests is internal
work unless it is proven genuinely external/non-applicable.

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

### 7.1 Consumer Composition Evidence

Warp Prism is a reusable system consumed by real applications.

For changes to shared ADS, IDS, bindings, shells, theme/token propagation,
navigation/layout primitives, or runtime-integration surfaces:

> **Package-local proof is necessary but not sufficient when the change can
> materially affect a real consumer host.**

Acceptance MUST include affected real-host evidence when host composition can
change.

A widget/package test wrapper may not be treated as proof of composability when
it supplies ancestors, constraints, theme state, routing state, focus state,
runtime capabilities, or other prerequisites that the real consumer does not
supply.

Affected-host evidence should exercise, as applicable:

```text
launch real host
↓
enter affected primary route
↓
perform at least one meaningful interaction
↓
observe framework/runtime errors
↓
exercise representative viewport/layout conditions
↓
verify theme/focus/navigation propagation
```

Material evidence failures include, where applicable:

- uncaught Flutter/framework errors attributable to Warp Prism;
- `ErrorWidget`/error-boundary activation caused by reusable Prism behavior;
- material `RenderFlex`/constraint overflow;
- missing required widget/ancestor capability;
- stale or inconsistent theme propagation;
- broken shared navigation/focus semantics;
- connected binding/runtime failures hidden by fixture-only proof.

Human visual judgment and deterministic host composition evidence are different
gates. One does not substitute for the other.

### 7.2 Affected Consumer Classification

Before accepting a shared UI/integration change, explicitly classify the
consumer impact.

For changes touching shared Prism widgets, shells, layout primitives,
theme/token propagation, routing/navigation primitives, bindings, or reusable
interaction primitives, record:

```text
affected_consumers:
  - <real host / route / surface>
```

or:

```text
affected_consumers: NONE
reason: <why the change cannot materially affect a real consumer>
```

Do not leave consumer impact implicit.

When multiple hosts consume the changed invariant, test enough representative
hosts to prove the shared contract rather than merely the package laboratory.

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

For local Warp Prism-only changes, add entries under `.project/changelog/` via the
manage-changelog engine.

For parent-significant harness changes, also use the parent Ganthritor changelog
engine.

Use `agent-wiki` / `agentlog` for durable role continuity under
`.project/memories/<lane>/`.

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

---

## 16. Session Ledger and Persistent Fleet Convention

*(Operator-adopted convention, 2026-09-07.)*

### 16.1 Session Ledger

Every subagent session ID returned by a dispatch MUST be recorded in:

```text
.projects/sessions/sessions.md
```

immediately after the dispatch returns. That ledger is the single source of
truth for subagent session identity, fleet status, per-task additive report
destinations, and provider-failure model fallback ladders.

Consult the ledger BEFORE dispatching any subagent. Update it AFTER every
dispatch that yields a session ID.

### 16.2 Persistent Fleet — Reuse Before Fresh Launch

Prefer reusing existing fleet sessions over launching fresh workers:

- One engineer session, one expert session (may be the same session as the
  engineer — cross-role continuation in one session is valid), and one
  dedicated reviewer session form the default fleet.
- The reviewer session must remain dedicated: do not send build-side work
  into it.
- On provider failure when resuming a fleet session, retry the same session
  with an alternative model from the ladder recorded in the ledger. Do not
  use models outside the recorded ladders.
- Fleet sessions are reused ACROSS tasks when the domain is roughly the
  same — the accumulated context is the point of the fleet, not a cost.
- The reuse policy covers researchers and architects as well: onboard a
  fleet session for that role when a domain needs it, record it, and reuse
  it the same way.
- The ledger tracks at most 30 agents (≈10 per role). When over capacity,
  retire least-recently-used lineage rows first; their provenance remains
  in task ledgers and reports.
- When resuming a session after repository changes, the dispatching parent
  MUST briefly inform the agent which areas changed since the agent's last
  turn, and the agent must verify those areas before relying on prior
  context.

### 16.3 Per-Task Additive Reports

For a single task, builders and reviewers persist their iterations in one
additive file each:

```text
.project/reports/builders/<task>-<slug>-builder-report.md   (newest entry on top)
.project/reports/reviewers/<task>-<slug>-review-loop.md    (newest entry on top;
                                                        still-open findings at
                                                        top, resolved at end)
```

Prior entries are never overwritten. One-shot historical reports under
`.project/reports/builders/` and `.project/reports/reviewers/` remain valid evidence.

### 16.4 Fresh-Subagent Onboarding

Fresh subagents receive `.agents/workflows/wp-warp-prism-onboarding.md`
(bounded ~10-read onboarding) before their first task. Grandfathered
deep-context sessions may be waived by explicit dispatch instruction.
