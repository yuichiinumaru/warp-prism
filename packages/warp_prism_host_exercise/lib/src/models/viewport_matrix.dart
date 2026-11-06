import 'package:meta/meta.dart';

/// Named viewport for the exercise matrix.
///
/// Viewport/window configuration is first-class: the harness does not
/// hardcode one universe. The default matrix targets representative desktop
/// classes to expose fixed-height assumptions, unbounded constraints,
/// overflow, stretch/max-width errors, and responsive composition defects.
@immutable
class ExerciseViewport {
  final String name;
  final double width;
  final double height;
  final double devicePixelRatio;

  const ExerciseViewport({
    required this.name,
    required this.width,
    required this.height,
    this.devicePixelRatio = 1.0,
  });

  /// Canonical capture baseline (matches existing visual capture harness).
  static const desktop1280x800 = ExerciseViewport(
    name: 'desktop-1280x800',
    width: 1280,
    height: 800,
  );

  /// Wide desktop class (user-reported overflow context).
  static const wide1920x1080 = ExerciseViewport(
    name: 'wide-1920x1080',
    width: 1920,
    height: 1080,
  );

  /// Laptop class.
  static const laptop1366x768 = ExerciseViewport(
    name: 'laptop-1366x768',
    width: 1366,
    height: 768,
  );

  /// Narrow class — exercises collapsed sidebar paths.
  static const narrow800x600 = ExerciseViewport(
    name: 'narrow-800x600',
    width: 800,
    height: 600,
  );

  /// Compact class — exercises bottom-navigation fallback (< 600px).
  static const compact390x844 = ExerciseViewport(
    name: 'compact-390x844',
    width: 390,
    height: 844,
    devicePixelRatio: 2.0,
  );

  /// Compact 500x900 class — CyberCore F6 divergence surface.
  static const compact500x900 = ExerciseViewport(
    name: 'compact-500x900',
    width: 500,
    height: 900,
    devicePixelRatio: 1.0,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'width': width,
    'height': height,
    'device_pixel_ratio': devicePixelRatio,
  };

  factory ExerciseViewport.fromJson(Map<String, Object?> json) {
    return ExerciseViewport(
      name: json['name']! as String,
      width: (json['width']! as num).toDouble(),
      height: (json['height']! as num).toDouble(),
      devicePixelRatio: ((json['device_pixel_ratio'] ?? 1.0) as num).toDouble(),
    );
  }
}

/// Default representative desktop matrix (no combinatorial explosion).
const kExerciseDesktopMatrix = <ExerciseViewport>[
  ExerciseViewport.desktop1280x800,
  ExerciseViewport.wide1920x1080,
  ExerciseViewport.laptop1366x768,
  ExerciseViewport.narrow800x600,
];
