// Contract tests for DSActionAuthority (Task 1868, F-01).
//
// Generic allow / constrain / deny vocabulary only: no palette additions,
// colors reuse existing DSColors semantic aliases.
// Run: flutter test packages/warp_prism_ui/test/tokens/ds_action_authority_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';
import 'package:warp_prism_ui/src/tokens/ds_operational_state.dart';

void main() {
  group('DSActionAuthority vocabulary', () {
    test('has exactly allow, constrain, deny', () {
      expect(
        DSActionAuthority.values,
        equals([
          DSActionAuthority.allow,
          DSActionAuthority.constrain,
          DSActionAuthority.deny,
        ]),
      );
    });

    test('every outcome has a unique label', () {
      final labels = DSActionAuthority.values.map((a) => a.label).toSet();
      expect(labels.length, equals(DSActionAuthority.values.length));
    });

    test('every outcome has a non-empty semantic label', () {
      for (final authority in DSActionAuthority.values) {
        expect(authority.semanticLabel, isNotEmpty);
      }
    });

    test('only deny refuses dispatch', () {
      expect(DSActionAuthority.allow.mayDispatch, isTrue);
      expect(DSActionAuthority.constrain.mayDispatch, isTrue);
      expect(DSActionAuthority.deny.mayDispatch, isFalse);
    });

    test('constrain and deny require a reason; allow does not', () {
      expect(DSActionAuthority.allow.requiresReason, isFalse);
      expect(DSActionAuthority.constrain.requiresReason, isTrue);
      expect(DSActionAuthority.deny.requiresReason, isTrue);
    });

    test('does not change the 15-state DSOperationalState vocabulary', () {
      expect(DSOperationalState.values.length, equals(15));
    });
  });
}
