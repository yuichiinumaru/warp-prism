import 'package:meta/meta.dart';

/// Theme/recipe identity for the exercise matrix.
///
/// The harness proves functional theme propagation and role behavior, not
/// human aesthetic approval. Recipes are opaque string ids — the host
/// adapter owns the mapping from id to actual skin application.
@immutable
class ExerciseThemeRecipe {
  final String id;
  final String label;

  const ExerciseThemeRecipe({required this.id, required this.label});

  static const khalaiBlue = ExerciseThemeRecipe(
    id: 'khalai-blue',
    label: 'Khalai Blue (default dark)',
  );
  static const taldarimRed = ExerciseThemeRecipe(
    id: 'taldarim-red',
    label: 'Taldarim Red',
  );
  static const talonPurple = ExerciseThemeRecipe(
    id: 'talon-purple',
    label: 'Talon Purple',
  );
  // Wire-ID migration (Task 1842): the serialized id moved from the legacy
  // CyberCore-era spelling to 'nerazim-teal' together with every consumer in
  // one atomic change, so no deprecated old-ID alias remains. The old value was a
  // cross-package wire contract (apps/catalog + apps/cybercore host-exercise
  // harnesses); Task 1839 intentionally deferred it, and Task 1842 completed it
  // once the owner confirmed the surface is repo-internal and regenerated on
  // every run. The frozen Task 1838 trace captures under
  // .project/reports/architects/traces/ still embed the old literal by design:
  // they are cited-only historical evidence and are never loaded by code.
  static const nerazimTeal = ExerciseThemeRecipe(
    id: 'nerazim-teal',
    label: 'Nerazim Teal (scoped opt-in)',
  );

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'label': label};

  factory ExerciseThemeRecipe.fromJson(Map<String, Object?> json) {
    return ExerciseThemeRecipe(
      id: json['id']! as String,
      label: (json['label'] ?? json['id']!) as String,
    );
  }
}
