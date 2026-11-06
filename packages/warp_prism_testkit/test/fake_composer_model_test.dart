// Runs the composer model contract suite against the in-memory fake
// (Task 1866, F-18 — EXPERIMENTAL).
//
// Run: dart test packages/warp_prism_testkit/test/fake_composer_model_test.dart
// (or `dart test` from packages/warp_prism_testkit/).
import 'package:warp_prism_testkit/src/contract_tests/composer_contract_test.dart';
import 'package:warp_prism_testkit/src/fakes/fake_composer_model.dart';

void main() {
  verifyComposerModelContract(
    createModel:
        ({
          required FakeComposerDraftStore store,
          required String draftKey,
          List<String> mentionCandidates = const [],
        }) => FakeComposerModel(
          store: store,
          draftKey: draftKey,
          mentionCandidates: mentionCandidates,
        ),
  );
}
