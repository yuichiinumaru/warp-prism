/// IDS command module (Task 1870, F-03) — module barrel, EXPERIMENTAL.
///
/// Deliberately NOT re-exported from `warp_prism_interaction.dart`: the
/// contract lifecycle is EXPERIMENTAL (spec + fake + suite, no barrel export,
/// no STABLE promotion). Import via the `src/command/` path in tests and
/// composition sites, mirroring the Task 1868 precedent
/// (`src/input/action_availability.dart`).
library;

export 'command_chord.dart';
export 'command_context.dart';
export 'command_intent.dart';
export 'command_registry.dart';
export 'command_router.dart';
