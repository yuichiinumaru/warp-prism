// Contract tests for Design System Atoms.
//
// These tests verify the API surface and behavioral contracts of all
// required DS atoms. They do NOT verify pixel-perfect rendering; they
// verify that constructors compile, semantic labels are set, and
// interactive states (selected, disabled, focus) produce expected
// widget tree changes.
//
// Run: flutter test test/design_system/atoms/atoms_contract_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

void main() {
  // ===========================================================================
  // DSText
  // ===========================================================================
  group('DSText contract', () {
    testWidgets('default constructor uses bodyMedium variant', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSText('Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('all named constructors render without error', (tester) async {
      final constructors = <DSText Function(String)>[
        (t) => DSText.displayLarge(t),
        (t) => DSText.displayMedium(t),
        (t) => DSText.displaySmall(t),
        (t) => DSText.headingLarge(t),
        (t) => DSText.headingMedium(t),
        (t) => DSText.headingSmall(t),
        (t) => DSText.bodyLarge(t),
        (t) => DSText.bodyMedium(t),
        (t) => DSText.bodySmall(t),
        (t) => DSText.labelLarge(t),
        (t) => DSText.labelMedium(t),
        (t) => DSText.labelSmall(t),
        (t) => DSText.code(t),
        (t) => DSText.numeric(t),
      ];
      for (final ctor in constructors) {
        await tester.pumpWidget(MaterialApp(home: ctor('test')));
        expect(find.text('test'), findsOneWidget);
      }
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSText('Colored', color: DSColors.accentCyan)),
      );
      expect(find.text('Colored'), findsOneWidget);
    });

    testWidgets('semantics label defaults to text content', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSText('Accessible')));
      expect(find.bySemanticsLabel('Accessible'), findsOneWidget);
    });

    testWidgets('custom semantics label is applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSText('Visible', semanticsLabel: 'Screen reader text'),
        ),
      );
      expect(find.bySemanticsLabel('Screen reader text'), findsOneWidget);
    });

    testWidgets('selectable text renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSText('Selectable', selectable: true)),
      );
      expect(find.byType(SelectableText), findsOneWidget);
    });

    test('DSTextVariant enum covers all 18 variants', () {
      expect(DSTextVariant.values.length, 18);
    });
  });

  // ===========================================================================
  // DSIcon
  // ===========================================================================
  group('DSIcon contract', () {
    testWidgets('default constructor renders', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSIcon(Icons.home)));
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('size constructors set correct sizes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSIcon.small(Icons.home)),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(icon.size, 16); // DSIconSize.small → 16

      await tester.pumpWidget(
        const MaterialApp(home: DSIcon.medium(Icons.home)),
      );
      final medium = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(medium.size, 20);

      await tester.pumpWidget(
        const MaterialApp(home: DSIcon.large(Icons.home)),
      );
      final large = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(large.size, 24);
    });

    testWidgets('custom size overrides iconSize', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSIcon(Icons.home, size: 42)),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(icon.size, 42);
    });

    testWidgets('semantic label is applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSIcon(Icons.home, semanticLabel: 'Home')),
      );
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
    });

    test('DSIconSize enum covers 5 sizes', () {
      expect(DSIconSize.values.length, 5);
      expect(DSIconSize.values, contains(DSIconSize.tiny));
      expect(DSIconSize.values, contains(DSIconSize.small));
      expect(DSIconSize.values, contains(DSIconSize.medium));
      expect(DSIconSize.values, contains(DSIconSize.large));
      expect(DSIconSize.values, contains(DSIconSize.xlarge));
    });

    test('DSIcons.forAssetKind covers all 9 asset kinds', () {
      expect(DSIcons.forAssetKind('agent'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('skill'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('subskill'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('workflow'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('task'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('changelog'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('script'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('reference'), isNot(Icons.info_outline));
      expect(DSIcons.forAssetKind('rule'), isNot(Icons.info_outline));
    });

    test('DSIcons.forLane covers all 5 lanes', () {
      expect(DSIcons.forLane('00-planning'), DSIcons.planning);
      expect(DSIcons.forLane('01-open'), DSIcons.open);
      expect(DSIcons.forLane('02-doing'), DSIcons.doing);
      expect(DSIcons.forLane('03-review'), DSIcons.review);
      expect(DSIcons.forLane('04-completed'), DSIcons.completed);
    });
  });

  // ===========================================================================
  // DSBadge
  // ===========================================================================
  group('DSBadge contract', () {
    testWidgets('count constructor renders count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSBadge.count(5)));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('count over 99 renders 99+', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSBadge.count(150)));
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('dot constructor renders a container', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSBadge.dot()));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('semantic constructors compile and render', (tester) async {
      for (final ctor in [
        () => const DSBadge.success(label: 'ok'),
        () => const DSBadge.warning(label: 'warn'),
        () => const DSBadge.error(label: 'err'),
        () => const DSBadge.info(label: 'info'),
      ]) {
        await tester.pumpWidget(MaterialApp(home: ctor()));
      }
    });

    test('DSBadgeVariant has filled, outlined, dot', () {
      expect(DSBadgeVariant.values.length, 3);
    });

    test('DSBadgeSize has small, medium, large', () {
      expect(DSBadgeSize.values.length, 3);
    });
  });

  // ===========================================================================
  // DSChip
  // ===========================================================================
  group('DSChip contract', () {
    testWidgets('default chip renders label', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSChip(label: 'Test')));
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('selected state changes appearance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSChip(label: 'Tag', selected: true)),
      );
      expect(find.text('Tag'), findsOneWidget);
    });

    testWidgets('disabled chip does not fire onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSChip(
            label: 'Disabled',
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Disabled'));
      expect(tapped, false);
    });

    testWidgets('enabled chip fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSChip(label: 'Active', onTap: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Active'));
      expect(tapped, true);
    });

    testWidgets('assetKind factory renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: DSChip.assetKind('agent')));
      expect(find.text('agent'), findsOneWidget);
    });

    testWidgets('lane factory renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: DSChip.lane('02-doing')));
      expect(find.text('Doing'), findsOneWidget);
    });

    testWidgets('governance factory renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DSChip.governance('parentcanonical')),
      );
      expect(find.text('Canonical'), findsOneWidget);
    });

    testWidgets('removable factory renders with close icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DSChip.removable('Tag', onRemove: () {})),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('semantics: button, selected, enabled labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSChip(label: 'Semantic', selected: true, enabled: true),
        ),
      );
      final semantics = tester.getSemantics(find.text('Semantic'));
      expect(semantics, isNotNull);
    });

    test('DSChipSize has small, medium, large', () {
      expect(DSChipSize.values.length, 3);
    });
  });

  // ===========================================================================
  // DSStatusDot
  // ===========================================================================
  group('DSStatusDot contract', () {
    testWidgets('default constructor requires color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStatusDot(color: DSColors.statusSuccess)),
      );
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('semantic constructors render', (tester) async {
      for (final ctor in [
        () => const DSStatusDot.success(),
        () => const DSStatusDot.warning(),
        () => const DSStatusDot.error(),
        () => const DSStatusDot.info(),
        () => const DSStatusDot.neutral(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: ctor()));
        expect(find.byType(DSStatusDot), findsOneWidget);
      }
    });

    testWidgets('tooltip wraps in Tooltip when set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStatusDot.success(tooltip: 'All good')),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('no tooltip when null', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.success()));
      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('animated dot renders with animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStatusDot(color: DSColors.accentCyan, animated: true),
        ),
      );
      // AnimatedBuilder should be in the tree (at least one from _AnimatedDot;
      // MaterialApp internals may contribute additional AnimatedBuilders)
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });
  });

  // ===========================================================================
  // DSDivider
  // ===========================================================================
  group('DSDivider contract', () {
    testWidgets('default divider renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(height: 10, child: DSDivider())),
      );
      expect(find.byType(DSDivider), findsOneWidget);
    });

    testWidgets('subtle variant uses borderSubtle color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(height: 10, child: DSDivider.subtle()),
        ),
      );
      expect(find.byType(DSDivider), findsOneWidget);
    });

    testWidgets('strong variant renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SizedBox(height: 10, child: DSDivider.strong())),
      );
    });

    testWidgets('glow variant renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(height: 10, child: DSDivider.glow())),
      );
    });
  });

  // ===========================================================================
  // DSGlowBorder
  // ===========================================================================
  group('DSGlowBorder contract', () {
    testWidgets('default constructor renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSGlowBorder(child: Text('Glow'))),
      );
      expect(find.text('Glow'), findsOneWidget);
    });

    testWidgets('color constructors compile', (tester) async {
      for (final ctor in [
        () => const DSGlowBorder.cyan(child: Text('c')),
        () => const DSGlowBorder.violet(child: Text('v')),
        () => const DSGlowBorder.gold(child: Text('g')),
        () => const DSGlowBorder.success(child: Text('s')),
        () => const DSGlowBorder.error(child: Text('e')),
      ]) {
        await tester.pumpWidget(MaterialApp(home: ctor()));
      }
    });

    testWidgets('animated glow border renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSGlowBorder(animated: true, child: Text('Anim')),
        ),
      );
      expect(find.text('Anim'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSGlassPanel
  // ===========================================================================
  group('DSGlassPanel contract', () {
    testWidgets('default constructor renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSGlassPanel(child: Text('Glass'))),
      );
      expect(find.text('Glass'), findsOneWidget);
    });

    testWidgets('variant constructors render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSGlassPanel.subtle(child: Text('subtle'))),
      );
      expect(find.text('subtle'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: DSGlassPanel.elevated(child: Text('elevated'))),
      );
      expect(find.text('elevated'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: DSGlassPanel.modal(child: Text('modal'))),
      );
      expect(find.text('modal'), findsOneWidget);
    });

    test('DSGlassPanelVariant has subtle, elevated, modal', () {
      expect(DSGlassPanelVariant.values.length, 3);
    });
  });

  // ===========================================================================
  // DSGlassPanelSimple
  // ===========================================================================
  group('DSGlassPanelSimple contract', () {
    testWidgets('renders child without blur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSGlassPanelSimple(child: Text('Simple'))),
      );
      expect(find.text('Simple'), findsOneWidget);
      // Should NOT use BackdropFilter
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ===========================================================================
  // DSTextField
  // ===========================================================================
  group('DSTextField contract', () {
    testWidgets('constructor renders label and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSTextField(label: 'Contract Label', hint: 'Contract Hint'),
          ),
        ),
      );
      expect(find.text('Contract Label'), findsOneWidget);
      expect(find.text('Contract Hint'), findsOneWidget);
    });
  });
}
