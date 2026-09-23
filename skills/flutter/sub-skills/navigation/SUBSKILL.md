---
name: navigation
parent: flutter
description: Govern Flutter routing, GoRouter typed routes, deep links, modal boundaries, route guards, redirect behavior, and state restoration.
---

# Flutter Navigation

Use this route for GoRouter, Navigator, typed routes, deep links, auth redirects, route parameters, local modals, back behavior, and navigation tests.

## Navigation Axioms

- **Routes have one source of truth.** Prefer project-defined typed route declarations or centralized route objects; avoid scattered raw string paths.
- **Parameters are typed and validated.** Convert untrusted route/query params at boundaries and handle invalid/missing values intentionally.
- **Redirects are finite and testable.** Auth/onboarding/feature-flag redirects must not loop and must preserve intended destinations where required.
- **Local UI is not global navigation.** Dialogs, sheets, menus, and popovers should use semantic local helpers and dismissal contracts.
- **Deep links are security-sensitive.** Links into auth/account/payment/reset flows require validation and tests.
- **Navigation is observable.** Widget/integration tests should verify resulting screen/state, not only that a mock router method was called.

## Checklist

- [ ] Route definitions are centralized or generated according to project convention.
- [ ] Route params have typed parsing/fallback behavior.
- [ ] Redirect guards cover logged-out/logged-in/loading/error/unknown states.
- [ ] Back button and desktop keyboard navigation are intentional.
- [ ] Deep link handling includes cold start and already-running app behavior when applicable.
- [ ] Tests assert visible outcome and state restoration for critical flows.

## Common Anti-Patterns

- Inline `context.go('/string')` scattered through widgets when typed routes exist.
- Redirects that read async state unsafely or loop during loading.
- Losing query params or intended destination after auth.
- Sensitive deep links without validation or auth re-check.

## Concrete Navigation Rules (from reference corpus)

- **Typed routes SSOT**: Define routes once with `go_router_builder`, navigate with generated helpers `SomeRoute(...).go(context)` / `.push<T>(context)`. Keep route paths inside definitions, not scattered as strings.
- **Local UI ≠ global navigation**: Dialogs, sheets, menus use semantic helpers and `Navigator.pop` for dismissal.
- **Auth redirects must preserve destination**: after login redirect, send user to the originally intended route.
- **Cold start deep links**: handle the case where the app is not running and a deep link launches it.

### Reference corpus paths

- `references/building-flutter-apps/references/architecture.md` — GoRouter typed routes setup.
- `references/building-flutter-apps/references/deep-linking.md` — deep link handling.
- `references/mad-agents-skills/flutter-navigation/` — GoRouter, Navigator, passing/returning data examples.
- `references/antigravity-ai-kit-for-flutter/.agent/rules/routing.md` — GoRouter with auth redirects example.
