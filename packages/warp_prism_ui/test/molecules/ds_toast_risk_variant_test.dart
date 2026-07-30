import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1522: risk toast variant tests (O-28)
///
/// Proves risk-styled entries use existing DSToast + DSToastManager only.
void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  Widget wrapWithManager(Widget child) {
    return MaterialApp(
      home: Scaffold(body: DSToastManager(child: child)),
    );
  }

  group('DSToastRiskTier', () {
    test('defines four tiers with four distinct colors', () {
      expect(DSToastRiskTier.values.length, equals(4));
      final colors = DSToastRiskTier.values.map((t) => t.color).toSet();
      // high must not collapse onto critical (statusExposed aliases statusError).
      expect(colors.length, equals(4));
    });

    test('maps to base toast severities', () {
      expect(DSToastRiskTier.low.asToastSeverity, DSToastSeverity.info);
      expect(DSToastRiskTier.moderate.asToastSeverity, DSToastSeverity.warning);
      expect(DSToastRiskTier.high.asToastSeverity, DSToastSeverity.error);
      expect(DSToastRiskTier.critical.asToastSeverity, DSToastSeverity.error);
    });

    test('high tier uses distinct orange, not statusExposed/error red', () {
      expect(DSToastRiskTier.high.color, equals(DSColors.assetRule));
      expect(
        DSToastRiskTier.high.color,
        isNot(equals(DSToastRiskTier.critical.color)),
      );
      expect(DSToastRiskTier.high.color, isNot(equals(DSColors.statusExposed)));
    });
  });

  group('DSToastEntry.risk', () {
    test('factory sets riskTier and base severity', () {
      final entry = DSToastEntry.risk(
        id: 'r1',
        riskTier: DSToastRiskTier.critical,
        title: 'Critical geo risk',
        riskRegion: 'Sector-7',
      );

      expect(entry.isRiskVariant, isTrue);
      expect(entry.riskTier, DSToastRiskTier.critical);
      expect(entry.riskRegion, 'Sector-7');
      expect(entry.severity, DSToastSeverity.error);
      expect(entry.duration, const Duration(seconds: 6));
    });

    test('copyWith preserves and clears risk fields', () {
      final entry = DSToastEntry.risk(
        id: 'r2',
        riskTier: DSToastRiskTier.moderate,
        title: 'Mod',
        riskRegion: 'Bay',
      );
      final cleared = entry.copyWith(
        clearRiskTier: true,
        clearRiskRegion: true,
      );
      expect(cleared.isRiskVariant, isFalse);
      expect(cleared.riskRegion, isNull);
    });
  });

  group('DSToast risk rendering', () {
    testWidgets('shows risk badge and region chrome', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSToast(
            entry: DSToastEntry.risk(
              id: 'risk-ui',
              riskTier: DSToastRiskTier.high,
              riskRegion: 'Sector-7',
              title: 'Perimeter risk elevated',
              message: 'Fixture notice',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('Perimeter risk elevated'), findsOneWidget);
      expect(find.textContaining('HIGH RISK'), findsOneWidget);
      expect(find.textContaining('Sector-7'), findsOneWidget);
    });

    testWidgets('risk live region includes tier label', (tester) async {
      await tester.pumpWidget(
        wrap(
          DSToast(
            entry: DSToastEntry.risk(
              id: 'risk-a11y',
              riskTier: DSToastRiskTier.moderate,
              title: 'Feed lag',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSToast));
      expect(semantics.label, contains('Moderate risk'));
      expect(semantics.label, contains('Feed lag'));
    });
  });

  group('DSToastManager risk integration', () {
    testWidgets('shows risk entry via single manager stack', (tester) async {
      await tester.pumpWidget(
        wrapWithManager(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DSToastManager.of(context).show(
                    DSToastEntry.risk(
                      id: 'mgr-risk',
                      riskTier: DSToastRiskTier.low,
                      title: 'Low residual risk',
                      duration: Duration.zero,
                    ),
                  );
                },
                child: const Text('Show risk'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show risk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Low residual risk'), findsOneWidget);
      expect(find.byType(DSToast), findsOneWidget);
      // No second toast manager type — only DSToastManager.
      expect(find.byType(DSToastManager), findsOneWidget);
    });

    testWidgets('Prism aliases resolve to same types', (tester) async {
      expect(PrismToastRiskTier.high, same(DSToastRiskTier.high));
      final entry = PrismToastEntry.risk(
        id: 'alias',
        riskTier: PrismToastRiskTier.critical,
        title: 'Alias risk',
      );
      expect(entry, isA<DSToastEntry>());
      expect(entry.isRiskVariant, isTrue);
    });
  });
}
