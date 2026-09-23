---
name: testing
parent: flutter
description: Design and verify Flutter/Dart unit, widget, golden, package-integration, real-host-composition, e2e, and regression evidence with claim-matched oracles.
---

# Flutter and Dart Testing

Use this route when writing/reviewing tests, coverage, golden evidence, widget
behavior, integration flows, host-composition proof, or completion evidence.

## Evidence Classes

These classes describe **what an observation can prove**:

1. **`static`** — analyzer/lints/import/codegen consistency.
2. **`unit`** — pure Dart logic, reducers/state machines, mappers, repositories
   with controlled dependencies.
3. **`widget`** — one Flutter widget/subtree under its declared test contract:
   visible states, semantics, interaction, routing triggers, error/loading/empty
   behavior.
4. **`golden`** — deterministic visual regression evidence for surfaces where a
   snapshot is an appropriate oracle.
5. **`package-integration`** — multiple package components/tokens/themes working
   together *inside the package*. Proves package coherence, not app embedding.
6. **`real-host-composition`** — the real consumer app/shell, with its actual
   routing/DI/theme/ancestor composition, exercising representative affected
   surfaces.
7. **`e2e`** — realistic device/emulator/application user flows where platform
   behavior or end-to-end state matters.

Human visual/product judgment may be an additional acceptance surface. It is not
silently replaced by any automated class above.

## Claim → Oracle

| Claim | Minimum relevant evidence |
|---|---|
| logic/mapper/state machine behaves | `unit` |
| widget handles documented visible states | `widget` |
| stable visual surface matches approved baseline | `golden` + underlying behavioral evidence |
| package components compose together | `package-integration` |
| shared component works in consumer app A | `real-host-composition` for A |
| shared theme/token change works in affected apps | `real-host-composition` for affected consumers |
| platform/user journey works | `e2e` when the claim truly needs it |

A large number of weaker green tests does not substitute for a missing evidence
class.

## Test Quality Axioms

- **Test behavior, not implementation trivia.**
- **Fakes are preferred for controlled domain/boundary behavior** when they
  preserve the claim; mocks are appropriate when they are the clearest boundary
  probe.
- **Wrapper richness must match the declared contract.** A widget test that
  supplies `MaterialApp`, `Scaffold`, navigation, theme, localization, or
  providers that real consumers do not guarantee can hide a composition bug.
- **Package PASS != host PASS.**
- **Do not swallow framework/runtime errors to preserve green output.**
- **No arbitrary sleeps for synchronization.** Wait/pump for observable
  conditions with bounded timeouts; use a fixed duration only when duration is
  itself under test.
- **Golden updates require intent and review appropriate to the project.**
- **Every fixed bug should gain a regression oracle** when deterministic proof
  is feasible.
- **Historical PASS and current authorization are different questions.**
  Revalidation/acceptance semantics belong to `code-quality`; this skill only
  identifies the required Flutter evidence.

## Isolation by Evidence Class

| Class | Typical isolation |
|---|---|
| `unit` | fakes/test doubles around external dependencies |
| `widget` | contract-minimal Flutter wrapper; isolated state container when applicable |
| `golden` | deterministic fonts/locale/time/size/theme + behavioral setup |
| `package-integration` | real package components together; external services may be faked |
| `real-host-composition` | real consumer shell/composition; fake only true app-boundary services when project policy allows |
| `e2e` | real application/platform flow appropriate to the claim |

A reusable widget does **not** need every possible shell. Shell/viewport coverage
follows its declared contract and actual consumers.

## Host Composition

For reusable/shared/design-system surfaces, use:

`../../workflows/sk-flutter-host-composition.md`

That workflow owns:
- declared-prerequisite inspection;
- contract-minimal wrapper probes;
- consumer-shell proof;
- constraint/viewport discrimination;
- real-host evidence recording.

Do not reference archived reform-packet filenames from active praxis; use the
canonical live workflow/spec paths above.

## Framework Error Discipline

Use:

`../../references/host-composition/test-error-guard.spec.md`

The durable rule is simple: a relevant uncaught framework/runtime error,
`ErrorWidget` substitution, or layout overflow is failure evidence unless the
test deliberately asserts that negative path. Instrumentation must preserve and
restore framework handlers rather than swallowing errors.

## Affected Consumers

When a shared change may affect multiple apps, use the derivation/reference
contract:

`../../references/host-composition/consumer-graph-gate.spec.md`

A project may implement it mechanically. Until then, affected-host selection
must come from actual package/consumer evidence or explicit project policy, not
an invented universal shell matrix.

## Commands and Evidence

Prefer project-defined commands. Common evidence collectors include:

```bash
dart analyze
dart test
flutter test
flutter test --coverage
```

`integration_test`/device commands require the appropriate host/device setup.

Record:
- package/app root;
- test scenario and evidence class;
- command + exit status;
- skipped/blocked dimensions;
- host/shell/viewport/theme when relevant;
- golden-update authority when applicable.

If the required environment is unavailable, report the unproven claim instead of
promoting lower evidence to PASS.
