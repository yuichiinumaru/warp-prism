/// Gallery test oracle — the single narrow noise suppressor for the gallery
/// surface (Task 1843).
///
/// This lives in its own file so the *contract* is independently testable:
/// a test that asserts on the suppressor must be able to import the very
/// function the gallery suite installs. Keeping it private to
/// `design_system_gallery_test.dart` would make such a test impossible to write
/// honestly.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// The gallery suite masks no message classes (fail-closed oracle).
///
/// Task 1843 iteration 1 retained two benign Flutter/Material **debug hints**
/// (`ListTile background color…`, `ink splashes may be invisible`) as an exact
/// enumerated allow-list. The 2026-10-04 adversarial-review census then proved
/// zero occurrences of either class across every exercised gallery surface and
/// viewport — with a positive control catching the real SDK hint (≥1) and a
/// negative control silent on the Task 1840 fix shape (0), so the zero is
/// non-vacuous — and Task 1840 fixed the underlying Material ancestry. The
/// retained masks were therefore masking defects already fixed, exactly what
/// the review delta forbids, so finding F1 deleted them: the allow-list below
/// is intentionally empty and every framework message is forwarded to the
/// previously installed handler (under `flutter_test`, a failing handler).
///
/// A new masked class must never be added by widening a substring pattern —
/// that is what created the original oracle gap. Any future entry must be an
/// exact enumerated string with a stated reason AND a live census proving the
/// class actually occurs in the current tree.
const List<String> kBenignGalleryFrameworkHints = <String>[];

/// Whether [msg] is one of the benign framework hints in
/// [kBenignGalleryFrameworkHints].
///
/// The allow-list is currently empty (fail-closed), so this returns `false`
/// for every message — crucially including every layout-error class such as
/// `A RenderFlex overflowed …` AND the two former benign-hint classes — and
/// all of them propagate to the test binding and fail the calling test.
bool isBenignGalleryFrameworkHint(String msg) {
  for (final hint in kBenignGalleryFrameworkHints) {
    if (msg.contains(hint)) {
      return true;
    }
  }
  return false;
}

/// Installs the narrowed suppressor for the current test and restores the
/// previous handler on teardown.
///
/// With the fail-closed empty allow-list, every message — including every
/// `RenderFlex`/overflow layout error — is forwarded to the handler that was
/// active at install time. Under `flutter_test` that handler fails the test, so
/// a real layout defect can no longer be hidden here.
///
/// The audit `print` below fires only if a future allow-list entry is added; it
/// exists so a re-added mask can never go silent in test output again.
void installGalleryBenignHintSuppressor() {
  final FlutterExceptionHandler? previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final String msg = details.exceptionAsString();
    if (isBenignGalleryFrameworkHint(msg)) {
      // ignore: avoid_print
      print('===GALLERY-BENIGN-HINT-MASKED=== ${msg.split('\n').first}');
      return;
    }
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
}
