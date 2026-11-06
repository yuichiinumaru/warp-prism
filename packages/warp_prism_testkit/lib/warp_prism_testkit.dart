/// Warp Prism Runtime Contract Testkit.
///
/// Provides in-memory test doubles (fakes) and reusable contract compliance
/// test suites for Warp Prism runtime contracts:
/// - Fakes: [FakeEventStream], [FakeHealthSource], [FakeGraphSource], [FakeAsyncCommand]
/// - Contract Suites: [verifyEventStreamContract], [verifyHealthSourceContract],
///   [verifyGraphSourceContract], [verifyAsyncCommandContract]
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
library warp_prism_testkit;

export 'src/contract_tests/contract_tests.dart';
export 'src/fakes/fakes.dart';
export 'src/junk/junk_sweep.dart';
