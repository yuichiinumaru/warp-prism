// TEMPORARY FIXTURE for rem-0002 fixture-proof (PHASE B). Revert after proof.
// Contains NO bare token: only doc-comment mentions. The scan must stay GREEN.
// This separates the doc-comment direction from the bare-token direction that
// Phase A already proved is detected.

/// Fixture proof for rem-0002 (doc-comment direction).
///
/// Documents the law in prose: a runtime contract must not own Flutter layout
/// or presentation state. Concepts described here — (`position: Offset`),
/// Widget identity, BuildContext access, Color palette entries — are prose, not
/// code, and must not be scanned as violations.
class FixtureProof {
  /// Anchor coordinate. Deliberately NOT a Flutter Offset.
  final double x;

  const FixtureProof({required this.x});
}
