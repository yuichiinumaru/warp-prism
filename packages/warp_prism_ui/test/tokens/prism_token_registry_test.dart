import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  setUp(() {
    PrismTokenRegistry.instance.reset();
  });

  tearDown(() {
    PrismTokenRegistry.instance.reset();
  });

  group('PrismTokenRegistry', () {
    test('defaults match Task 1800 Black Obsidian contract values', () {
      final registry = PrismTokenRegistry.instance;

      expect(registry.obsidianDeep, equals(const Color(0xFF030506)));
      expect(registry.obsidianBase, equals(const Color(0xFF080C0E)));
      expect(registry.obsidianElevated, equals(const Color(0xFF0C1114)));
      expect(registry.obsidianHover, equals(const Color(0xFF12181C)));
      expect(registry.borderDefault, equals(const Color(0xFF121D22)));
      expect(registry.accentBlue, equals(const Color(0xFF2F81FF)));
      expect(registry.accentBlueMuted, equals(const Color(0xFF1D64D8)));
      expect(registry.accentBlueDim, equals(const Color(0xFF114299)));
      expect(registry.focusRing, equals(const Color(0x802F81FF)));

      expect(registry.hasOverrides, isFalse);
    });

    test('setColor updates token value and notifies listeners', () {
      final registry = PrismTokenRegistry.instance;
      var notified = false;

      registry.addListener(() {
        notified = true;
      });

      const newAccent = Color(0xFF00FFCC);
      registry.setColor(PrismColorRole.accentBlue, newAccent);

      expect(registry.accentBlue, equals(newAccent));
      expect(PrismColors.accentBlue, equals(newAccent));
      expect(notified, isTrue);
      expect(registry.hasOverrides, isTrue);
      expect(
        registry.currentOverrides[PrismColorRole.accentBlue],
        equals(newAccent),
      );
    });

    test('resetRole restores single role to default', () {
      final registry = PrismTokenRegistry.instance;

      registry.setColor(PrismColorRole.accentBlue, const Color(0xFF00FFCC));
      registry.setColor(PrismColorRole.obsidianDeep, const Color(0xFF111111));

      expect(registry.accentBlue, equals(const Color(0xFF00FFCC)));
      expect(registry.obsidianDeep, equals(const Color(0xFF111111)));

      registry.resetRole(PrismColorRole.accentBlue);

      expect(registry.accentBlue, equals(const Color(0xFF2F81FF)));
      expect(registry.obsidianDeep, equals(const Color(0xFF111111)));
    });

    test('reset clears all overrides and notifies listeners', () {
      final registry = PrismTokenRegistry.instance;
      var notified = false;

      registry.setColor(PrismColorRole.accentBlue, const Color(0xFF00FFCC));
      registry.setColor(PrismColorRole.borderDefault, const Color(0xFF333333));

      registry.addListener(() {
        notified = true;
      });

      registry.reset();

      expect(registry.accentBlue, equals(const Color(0xFF2F81FF)));
      expect(registry.borderDefault, equals(const Color(0xFF121D22)));
      expect(registry.hasOverrides, isFalse);
      expect(notified, isTrue);
    });

    test('parseHex parses #RGB, #RRGGBB, #AARRGGBB correctly', () {
      expect(
        PrismTokenRegistry.parseHex('#FFF'),
        equals(const Color(0xFFFFFFFF)),
      );
      expect(
        PrismTokenRegistry.parseHex('#2F81FF'),
        equals(const Color(0xFF2F81FF)),
      );
      expect(
        PrismTokenRegistry.parseHex('#802F81FF'),
        equals(const Color(0x802F81FF)),
      );
      expect(PrismTokenRegistry.parseHex('invalid'), isNull);
    });

    test('generateBakeBackSnippet produces valid formatted output', () {
      final registry = PrismTokenRegistry.instance;
      registry.setColor(PrismColorRole.accentBlue, const Color(0xFF00FFCC));

      final snippet = registry.generateBakeBackSnippet();
      expect(snippet, contains('Converged Theme Token Values'));
      expect(snippet, contains('accentBlue'));
      expect(snippet, contains('#00FFCC'));
      expect(snippet, contains('0xFF00FFCC'));
      expect(snippet, contains('[OVERRIDDEN]'));
    });

    testWidgets(
      'golden-safety rendering isolation: consumer widget reflects mutation and recovers contract default on reset',
      (tester) async {
        final registry = PrismTokenRegistry.instance;

        Widget buildConsumer() {
          return ListenableBuilder(
            listenable: registry,
            builder: (context, _) {
              return MaterialApp(
                theme: PrismTheme.dark(),
                home: Container(
                  key: const ValueKey('consumer-canvas'),
                  color: PrismColors.obsidianDeep,
                  child: Center(
                    child: PrismButton(
                      key: const ValueKey('consumer-button'),
                      label: 'Action',
                      onPressed: () {},
                    ),
                  ),
                ),
              );
            },
          );
        }

        // 1. Initial render — contract defaults
        await tester.pumpWidget(buildConsumer());
        var canvas = tester.widget<Container>(
          find.byKey(const ValueKey('consumer-canvas')),
        );
        expect(canvas.color, equals(const Color(0xFF030506)));
        expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));

        // 2. Mutate registry — live theme update
        registry.setColor(PrismColorRole.obsidianDeep, const Color(0xFF112233));
        registry.setColor(PrismColorRole.accentBlue, const Color(0xFF00FFCC));
        await tester.pump();

        canvas = tester.widget<Container>(
          find.byKey(const ValueKey('consumer-canvas')),
        );
        expect(canvas.color, equals(const Color(0xFF112233)));
        expect(PrismColors.accentBlue, equals(const Color(0xFF00FFCC)));

        // 3. Reset — contract default restoration
        registry.reset();
        await tester.pump();

        canvas = tester.widget<Container>(
          find.byKey(const ValueKey('consumer-canvas')),
        );
        expect(canvas.color, equals(const Color(0xFF030506)));
        expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));
      },
    );
  });
}
