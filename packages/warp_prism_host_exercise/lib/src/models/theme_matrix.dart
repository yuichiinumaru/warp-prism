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
  static const cybercoreTeal = ExerciseThemeRecipe(
    id: 'cybercore-teal',
    label: 'CyberCore Teal (scoped opt-in)',
  );

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'label': label};

  factory ExerciseThemeRecipe.fromJson(Map<String, Object?> json) {
    return ExerciseThemeRecipe(
      id: json['id']! as String,
      label: (json['label'] ?? json['id']!) as String,
    );
  }
}

/// Default recipe exercise set (A → B → C without reconstructing route
/// where the host supports it).
const kExerciseThemeRecipes = <ExerciseThemeRecipe>[
  ExerciseThemeRecipe.khalaiBlue,
  ExerciseThemeRecipe.taldarimRed,
  ExerciseThemeRecipe.talonPurple,
];
