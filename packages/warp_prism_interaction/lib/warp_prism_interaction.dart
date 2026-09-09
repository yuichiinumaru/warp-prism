/// Warp Prism Interaction Design System (IDS) Kernel.
///
/// Provides pure Dart interaction semantics:
/// - Selection model (single, multi, toggle, anchor, bus/notifier)
/// - Inspection model (intent, payload, lifecycle states)
/// - Query model (search/filter intent, state machine, result references)
/// - State machine vocabulary & transition table validation
/// - Normalized input contract (pointer, keyboard, a11y)
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
library warp_prism_interaction;

export 'src/input/input.dart';
export 'src/inspection/inspection.dart';
export 'src/query/query.dart';
export 'src/selection/selection.dart';
export 'src/state_machine/state_machine.dart';
