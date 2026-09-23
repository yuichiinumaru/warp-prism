# Casebook — Recurring Project Patterns

This is a curated pattern reference, not project-specific law.

## Warp Prism pattern

Recurring architectural lesson:
- backend-agnostic runtime contracts should remain above transport;
- FRB/generated APIs belong under a replaceable adapter;
- Dart adapter tests and real native boundary tests prove different claims;
- streams and in-flight cancellation require true FFI/native evidence;
- real consumer hosts can falsify package-local confidence.

## Tempest pattern

Recurring architectural lesson:
- Flutter owns presentation/control surfaces;
- Rust owns project/job/audio/model/persistence semantics;
- FRB is well suited to commands/events/progress/metadata/handles;
- heavy audio/model data should remain native;
- JSON-string fallback can accidentally recreate an untyped IPC protocol over a typed bridge;
- fake/demo success paths must not masquerade as production integration.

## Warpblade pattern

Recurring architectural lesson:
- media/video workloads make control-plane/data-plane separation non-optional;
- decoded frames/GPU surfaces should generally remain native and be represented to Flutter by a suitable native surface/handle path;
- transport is replaceable; semantic contracts are durable.

## Generalized jurisprudence

Across the three:
1. Rust commonly owns canonical semantics.
2. Flutter commonly owns presentation and ephemeral view state.
3. FRB is a projection/transport layer.
4. Generated bindings must not become domain vocabulary.
5. Heavy data placement is an architectural decision.
6. "Tests green" must be decomposed by what each test can observe.
