import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

void main() {
  group('ExerciseActionPolicy', () {
    test('safe by default for navigation/tabs/theme/filter labels', () {
      expect(ExerciseActionPolicy.classify('sem:Overview'), ActionSafety.safe);
      expect(
        ExerciseActionPolicy.classify('key:catalog-nav-gallery'),
        ActionSafety.safe,
      );
      expect(
        ExerciseActionPolicy.classify('sem:Theme Switcher'),
        ActionSafety.safe,
      );
    });

    test('destructive patterns are disabled by default', () {
      expect(
        ExerciseActionPolicy.classify('sem:Delete provider'),
        ActionSafety.externalOrDestructive,
      );
      expect(
        ExerciseActionPolicy.classify('sem:Sign out'),
        ActionSafety.externalOrDestructive,
      );
      expect(
        ExerciseActionPolicy.classify('key:pay-now-button'),
        ActionSafety.externalOrDestructive,
      );
      expect(
        ExerciseActionPolicy.classify('sem:Reveal API credential'),
        ActionSafety.externalOrDestructive,
      );
    });
  });

  group('ExerciseTrace JSON roundtrip', () {
    test('trace survives toJson/fromJson with seed and ordered steps', () {
      const trace = ExerciseTrace(
        seed: 18473,
        host: 'catalog',
        mode: 'fuzz',
        initialRoute: 'gallery',
        viewport: <String, Object?>{
          'name': 'desktop-1280x800',
          'width': 1280,
          'height': 800,
          'device_pixel_ratio': 1.0,
        },
        themeRecipe: 'khalai-blue',
        actionBudget: 8,
        actions: <ExerciseStep>[
          ExerciseStep(
            index: 0,
            target: 'key:catalog-nav-connected-lab',
            action: 'tap',
            routeBefore: 'gallery',
            routeAfter: 'connected-lab',
            stateMarker: 'candidates=4',
          ),
        ],
      );
      final restored = ExerciseTrace.fromJson(trace.toJson());
      expect(restored.seed, 18473);
      expect(restored.host, 'catalog');
      expect(restored.actions.length, 1);
      expect(restored.actions.first.target, 'key:catalog-nav-connected-lab');
      expect(restored.actions.first.routeAfter, 'connected-lab');
    });
  });

  group('HostExerciseConfig eligibility', () {
    test('blocklist wins over discovery', () {
      const config = HostExerciseConfig(
        host: 'catalog',
        initialRoute: 'gallery',
        excludedIdSubstrings: <String>['connected-lab'],
      );
      const blocked = ExerciseCandidate(
        id: 'key:catalog-nav-connected-lab',
        label: 'Connected Bridge Lab',
      );
      const allowed = ExerciseCandidate(
        id: 'key:catalog-nav-gallery',
        label: 'ADS Gallery',
      );
      expect(config.isEligible(blocked), isFalse);
      expect(config.isEligible(allowed), isTrue);
    });
  });

  group('Viewport matrix', () {
    test('desktop matrix covers representative classes without explosion', () {
      expect(kExerciseDesktopMatrix.length, 4);
      expect(
        kExerciseDesktopMatrix.map((v) => v.name),
        contains('desktop-1280x800'),
      );
    });
  });
}
