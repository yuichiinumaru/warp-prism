import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

/// Known-bad calibration controls.
///
/// A crawler that cannot fail on an intentionally bad control is not an
/// evidence gate. These controls prove the oracle fails visibly instead of
/// swallowing exceptions into PASS.
class KnownBadMaterialTextField extends StatelessWidget {
  const KnownBadMaterialTextField({super.key});

  @override
  Widget build(BuildContext context) {
    // Deliberate Task-1831-class defect: raw TextField with no Material
    // ancestor. Must produce "No Material widget found".
    return const TextField(decoration: InputDecoration(hintText: 'bad'));
  }
}

class KnownBadOverflowColumn extends StatelessWidget {
  const KnownBadOverflowColumn({super.key});

  @override
  Widget build(BuildContext context) {
    // Deliberate Task-1832-class defect: fixed-height Column that overflows.
    return const SizedBox(
      height: 50,
      child: Column(
        children: <Widget>[
          SizedBox(height: 40, child: Text('row-one')),
          SizedBox(height: 40, child: Text('row-two')),
        ],
      ),
    );
  }
}

class KnownBadThrowOnBuild extends StatelessWidget {
  const KnownBadThrowOnBuild({super.key});

  @override
  Widget build(BuildContext context) {
    throw StateError('KNOWN_BAD_CONTROL: deliberate build throw');
  }
}

void main() {
  group('Known-bad calibration (oracle must fail)', () {
    testWidgets('oracle detects missing-Material control', (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: KnownBadMaterialTextField(),
          ),
        ),
      );
      await tester.pump();
      final pending = tester.takeException();
      if (pending != null) oracle.asyncErrors.add(pending);
      expect(
        oracle.hasMaterialError,
        isTrue,
        reason: 'oracle must capture the No-Material failure',
      );
      expect(
        oracle.materialMessages.any(
          ExerciseErrorCollector.isMissingAncestorMessage,
        ),
        isTrue,
      );
      expect(
        () => oracle.failIfMaterial('calibration:no-material'),
        throwsFlutterError,
      );
    });

    testWidgets('oracle detects fixed-height overflow control', (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: KnownBadOverflowColumn())),
      );
      await tester.pump();
      final pending = tester.takeException();
      if (pending != null) oracle.asyncErrors.add(pending);
      expect(oracle.hasMaterialError, isTrue);
      expect(
        oracle.materialMessages.any(ExerciseErrorCollector.isOverflowMessage),
        isTrue,
      );
      expect(
        () => oracle.failIfMaterial('calibration:overflow'),
        throwsFlutterError,
      );
    });

    testWidgets('oracle detects deliberate build throw', (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: KnownBadThrowOnBuild())),
      );
      await tester.pump();
      final pending = tester.takeException();
      if (pending != null) oracle.asyncErrors.add(pending);
      expect(oracle.hasMaterialError, isTrue);
      expect(
        () => oracle.failIfMaterial('calibration:throw'),
        throwsFlutterError,
      );
    });

    testWidgets('oracle stays silent on a healthy control', (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('healthy control'))),
      );
      await tester.pump();
      final pending = tester.takeException();
      if (pending != null) oracle.asyncErrors.add(pending);
      expect(oracle.hasMaterialError, isFalse);
      oracle.failIfMaterial('calibration:healthy');
    });
  });

  group('Discovery smoke on synthetic tree', () {
    testWidgets('discovers keyed nav + semantics buttons deterministically', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Semantics(
                  label: 'Overview',
                  button: true,
                  enabled: true,
                  child: InkWell(onTap: () {}, child: const Text('Overview')),
                ),
                IconButton(
                  key: const Key('nav-gallery'),
                  onPressed: () {},
                  icon: const Icon(Icons.palette),
                  tooltip: 'Gallery',
                ),
                IconButton(
                  key: const Key('delete-provider'),
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete provider',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      final first = ExerciseActionDiscovery.discover(tester);
      final second = ExerciseActionDiscovery.discover(tester);
      expect(
        first.map((c) => c.id).toList(),
        second.map((c) => c.id).toList(),
        reason: 'discovery order must be deterministic across calls',
      );
      expect(first.any((c) => c.id == 'key:nav-gallery'), isTrue);
      // Destructive control must never surface as an eligible candidate.
      expect(first.any((c) => c.id.contains('delete')), isFalse);
    });
  });
}
