---
name: state-management
parent: flutter
description: Choose, implement, and audit Flutter state-management lifecycle, rebuild scope, async guards, and mutation flow.
---

# Flutter State Management

Use this route for Riverpod, BLoC/Cubit, Provider, state lifecycles, rebuild boundaries, async notifiers, mutation methods, and state propagation.

## Routing Rule

Use the project’s current state-management system. For Warp Prism, current evidence points to Flutter Riverpod usage; do not introduce BLoC/Cubit/GetX/MobX/Redux unless a task explicitly asks.

## Core Axioms

- **State has an owner**: identify whether the state is local widget state, derived UI state, feature state, app session state, persisted state, or remote cache state.
- **Async lifecycle is guarded**: after `await`, verify the owning context/provider is still mounted where the framework requires it.
- **Watch narrowly**: use selectors/derived providers where broad watches cause rebuild churn.
- **No prop-drilling of provider-derived state**: pass identifiers/callbacks to leaf widgets unless the design-system contract intentionally accepts value props.
- **Mutation flow is explicit**: UI event → state action/notifier/cubit → repository/service → result state. Do not hide writes inside builders.
- **Failures are states**: loading/error/empty/partial/retry states must be representable and testable.

## Checklist

- [ ] Provider/cubit/notifier scope matches lifecycle and feature ownership.
- [ ] Async cancellation and mounted guards are handled.
- [ ] Rebuild-sensitive widgets watch the smallest useful state.
- [ ] Error states include enough information for UI and telemetry without leaking secrets.
- [ ] Tests cover success, failure, cancellation/disposal, and duplicate mutation handling.
- [ ] State does not import concrete storage/network SDKs directly.

## Common Anti-Patterns

- Creating providers manually when the project uses codegen for all providers.
- Keeping provider-derived caches in `State` fields.
- Calling writes from `build()`.
- Letting widgets construct repositories or SDK clients.
- Tests that assert only notifier creation, not state transitions.

## Concrete Riverpod Rules (from reference corpus)

When the project uses Riverpod codegen:
- Use `@riverpod` / `@Riverpod` codegen for **every** provider. Never manual `Provider`, `FutureProvider`, `StreamProvider`, `StateProvider`, `StateNotifierProvider`, `NotifierProvider`, `AsyncNotifierProvider`, `ChangeNotifierProvider`.
- After every `await` in notifiers/repositories: `if (!ref.mounted) return;`.
- After every `await` in widgets/State: `if (!context.mounted) return;`.
- Inside `finally` blocks, use guard form: `if (ref.mounted) { ... }` — never `if (!ref.mounted) return;`.
- Use single `Ref` type, not `AutoDisposeRef` or typed refs.
- Notifier class extends `_$ClassName` (codegen pattern).
- No prop-drilling of provider-derived state through constructors; child widgets read providers directly.
- `ConsumerState` may own lifecycle handles, not provider-derived cache fields; use computed providers or local `build` values.

### Reference corpus paths

- `references/building-flutter-apps/references/state-management.md` — full Riverpod notifier/mutation rules.
- `references/building-flutter-apps/references/riverpod-codegen.md` — codegen patterns and family providers.
- `references/flutter-ai-rules/combined/flutter_with_riverpod.md` — 375-line combined Riverpod rule preset.
- `references/flutter-ai-rules/combined/flutter_with_bloc.md` — combined BLoC rule preset.
- `references/RobertAlvv-flutter-skills/state-management-auditor/` — state management audit methodology.
