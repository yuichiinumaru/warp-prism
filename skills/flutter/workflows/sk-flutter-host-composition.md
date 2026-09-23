---
name: sk-flutter-host-composition
description: |
  Host-composition workflow for shared/reusable Flutter surfaces: declared-contract
  probes, contract-minimal wrappers, real consumer shells, constraint/viewport
  discrimination, and claim-matched evidence.
---

# Host-Composition Workflow

## Trigger

Use when:
- a reusable/shared/design-system widget or package is materially changed and a
  claim is made about consumer composition; or
- a failure appears only in a real app/shell; or
- review must prove that a shared surface works in one or more consumers.

Do not require this workflow for every app-local widget.

## 1. Establish the Declared Contract

Read the component API and actual implementation. Identify material prerequisites:

- inherited widgets / `Material` / `MediaQuery` / `Directionality`;
- theme/localizations;
- routing/navigation;
- focus/scroll context;
- providers/custom `InheritedWidget`s;
- supported size/constraint assumptions.

Do **not** assume that a `Material` requirement is itself a component bug.
A component may legitimately require an ancestor.

If implementation requires more than the declared contract, classify:

`UNDOCUMENTED_PREREQUISITE`

Then choose deliberately:
- document/enforce the prerequisite;
- make the component provide it;
- remove the requirement;
- or update the supported host contract.

Debug assertions such as `debugCheckHasMaterial` can make an accepted prerequisite
explicit. They do not decide ownership by themselves.

## 2. Build a Contract-Minimal Wrapper

Construct the smallest wrapper that supplies **exactly the accepted contract**.

Do not default every reusable widget test to:

```dart
MaterialApp(
  home: Scaffold(
    body: child,
  ),
)
```

unless those capabilities are part of the declared contract.

A baseline may begin with `Directionality`/`MediaQuery` where required, then add
only accepted prerequisites.

Probe both:
- valid contract → expected behavior, no unexpected framework/layout errors;
- missing declared prerequisite → loud, intentional failure when the contract is
  meant to be enforced.

## 3. Prove a Real Consumer

For a shared/reusable surface, exercise at least the affected consumer shell
required by the claim.

The proof should use the real app composition for:
- routing;
- DI/provider wiring;
- theme/localizations;
- ancestor structure.

External network/storage/services may be replaced by project-approved fakes when
they are not the property under test. Do not fake the shared component or host
composition being claimed.

Project-specific choices such as canonical shell, routes, viewports, theme modes,
and supported consumers remain project policy.

## 4. Classify Constraint Sensitivity Before Ownership

When layout fails, run discriminating sizes/constraints appropriate to the
supported contract.

Typical interpretation:

```text
wide passes + narrow fails
→ CONSTRAINT-SENSITIVE FAILURE

wide fails + narrow fails
→ BROAD LAYOUT/COMPOSITION FAILURE
```

Neither result assigns ownership automatically.

Inspect:
- supported-size contract;
- actual incoming constraints;
- parent/child flex/scroll relationships;
- unbounded/ParentData conditions;
- text scaling where relevant.

Then assign component/host/shared ownership from the contract and source reality.

## 5. Cheap Discriminating Probes

| Symptom | Probe | What it tells you |
|---|---|---|
| missing `Material`/ancestor | contract-minimal wrapper + declared-prerequisite check | whether contract and real host agree |
| overflow | representative wide + constrained size + inspect actual constraints | sensitivity class; ownership still requires contract inspection |
| route/theme issue | real host, navigate representative routes, mutate theme/state | wiring/composition propagation |
| scroll ownership assertion | reproduce inside the actual nested scroll contract | which scroll/controller assumption is violated |
| host-only crash | package proof vs real host with same semantic action | whether the missing oracle is composition-specific |

A probe discriminates hypotheses; it does not become a review verdict.

## 6. Framework Error Visibility

Follow:

`../references/host-composition/test-error-guard.spec.md`

Never install a handler that swallows an error merely to keep the suite green.
Any override used for observation must preserve/restore prior framework behavior.

## 7. Evidence Record

For each relevant claim record:

```yaml
claim:
evidence_class: real-host-composition
consumer:
route_or_surface:
declared_contract:
host_contract:
viewport_or_constraints:
theme_or_mode:
command:
exit_status:
framework_errors:
result:
unproven_dimensions:
```

Use the evidence vocabulary from
`../sub-skills/testing/SUBSKILL.md`.

## Completion

The workflow is complete when:
- prerequisites are explicit enough to test;
- contract-minimal proof is honest;
- required affected consumer proof has run or is explicitly blocked;
- layout/constraint failures were classified before ownership was assigned;
- framework errors were not hidden;
- evidence states exactly what was and was not proven.

This workflow produces evidence. Independent task acceptance remains with the
active review/code-quality governance.
