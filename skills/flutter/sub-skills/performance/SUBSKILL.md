---
name: performance
parent: flutter
description: Diagnose Flutter widget rebuilds, frame budget, layout cost, scroll performance, Dart runtime efficiency, isolates, async concurrency, memoization, and caching.
---

# Flutter Performance

Use this route for jank, slow screens, rebuild storms, layout overflow/perf, scroll issues, startup time, runtime async bottlenecks, caching, isolate work, and performance-review claims.

## Performance Axioms

- **Measure before claiming.** Use project tests, profile traces, devtools evidence, frame timings, benchmark harnesses, or reproducible before/after observations.
- **Keep build cheap.** Avoid heavy computation, I/O, allocations, sync parsing, and side effects in `build()`.
- **Constrain rebuild propagation.** Watch/select narrow state, split widgets, and use const constructors where they meaningfully reduce churn.
- **Choose the right list primitive.** Large/unknown collections need builder/sliver patterns and stable keys when stateful children matter.
- **Respect the UI thread.** Heavy CPU or parsing work belongs in isolates/compute/background pipeline when measurement shows frame pressure.
- **Cache with invalidation.** Memoization and caches must define ownership, lifetime, invalidation, and memory bounds.

## Review Checklist

- [ ] Rebuild hot spots are identified, not guessed.
- [ ] Scroll/list layout uses lazy builders and avoids shrink-wrapped unbounded large lists unless justified.
- [ ] Expensive paints, clips, opacity layers, and `saveLayer`-like effects are intentional.
- [ ] Async calls are parallelized where independent and sequenced where dependencies require it.
- [ ] Isolates are used for large CPU tasks, not trivial overhead.
- [ ] Metrics/evidence are attached for performance improvements.

## Common Anti-Patterns

- Network/file/database work from widgets.
- `setState`/provider updates that rebuild whole pages for tiny changes.
- `ListView` inside unbounded parents without clear constraints.
- Recomputing derived collections on every build instead of using memoized/derived state.
- Claiming performance improvement after only running analyzer.

## Scoped Audit References (from reference corpus)

The RobertAlvv auditor suite provides non-overlapping scoped audit methodologies:

- **Widget rebuild audit**: detect unnecessary rebuilds, expensive `build()`, inefficient lists, `saveLayer` misuse, InheritedWidget propagation, Sliver perf, GC pressure → `references/RobertAlvv-flutter-skills/widget-performance-analyzer/`
- **Runtime efficiency audit**: main-thread blocking, sequential async, missing memoization, cache absence, microtask misuse, Timer saturation → `references/RobertAlvv-flutter-skills/runtime-performance-auditor/`
- **Performance patterns**: `.select()`, `const` constructors, `ListView.builder`, large list compute → `references/building-flutter-apps/references/performance.md` + `flutter-optimizations.md`
