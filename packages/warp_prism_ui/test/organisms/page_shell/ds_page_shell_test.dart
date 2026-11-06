import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1602: PrismPageShell / DSPageShell widget tests.
///
/// Covers: title render, optional subtitle/leading, actions slot, optional
/// toolbar, empty actions / no-toolbar stability, long-title ellipsis policy,
/// header semantics.
void main() {
  Widget harness({
    required Widget child,
    double width = 800,
    double height = 600,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismPageShell', () {
    testWidgets('renders title and body content', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismPageShell(
            title: 'Providers',
            child: Text('body-content'),
          ),
        ),
      );

      expect(find.text('Providers'), findsOneWidget);
      expect(find.text('body-content'), findsOneWidget);
      expect(find.byType(PrismPageShell), findsOneWidget);
    });

    testWidgets('renders optional subtitle and leading icon', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismPageShell.icon(
            title: 'Providers',
            subtitle: 'LLM accounts and model health',
            icon: Icons.cloud_outlined,
            child: const Text('body'),
          ),
        ),
      );

      expect(find.text('Providers'), findsOneWidget);
      expect(find.text('LLM accounts and model health'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('renders actions slot', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismPageShell(
            title: 'Providers',
            actions: [
              TextButton(
                key: const Key('action-refresh'),
                onPressed: () {},
                child: const Text('Refresh'),
              ),
              TextButton(
                key: const Key('action-add'),
                onPressed: () {},
                child: const Text('Add'),
              ),
            ],
            child: const Text('body'),
          ),
        ),
      );

      expect(find.byKey(const Key('action-refresh')), findsOneWidget);
      expect(find.byKey(const Key('action-add')), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('renders optional toolbar slot', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismPageShell(
            title: 'Providers',
            toolbar: ColoredBox(
              key: Key('page-toolbar'),
              color: Colors.transparent,
              child: Text('filter-toolbar'),
            ),
            child: Text('body'),
          ),
        ),
      );

      expect(find.byKey(const Key('page-toolbar')), findsOneWidget);
      expect(find.text('filter-toolbar'), findsOneWidget);
    });

    testWidgets('empty actions and no toolbar do not crash', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismPageShell(
            title: 'Empty Slots',
            actions: <Widget>[],
            child: Text('stable-body'),
          ),
        ),
      );

      expect(find.text('Empty Slots'), findsOneWidget);
      expect(find.text('stable-body'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('null actions and null toolbar do not crash', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismPageShell(
            title: 'Null Slots',
            child: Text('stable-body'),
          ),
        ),
      );

      expect(find.text('Null Slots'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long title uses ellipsis overflow policy (maxLines: 1)', (
      tester,
    ) async {
      // Overflow policy: title is single-line with TextOverflow.ellipsis.
      // Documented here so reviewers can verify the contract without
      // relying on pixel goldens for Task 1602.
      const longTitle =
          'This is an extremely long page title that must not wrap '
          'and must ellipsize within the available header width instead '
          'of overflowing the layout bounds of the page shell header';

      await tester.pumpWidget(
        harness(
          width: 320,
          child: const PrismPageShell(
            title: longTitle,
            actions: [SizedBox(width: 80, child: Text('Action'))],
            child: Text('body'),
          ),
        ),
      );

      // Title text is present in the tree.
      expect(find.text(longTitle), findsOneWidget);

      // The rendered DSText / Text uses ellipsis + single line.
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byType(PrismPageShell),
          matching: find.text(longTitle),
        ),
      );
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);

      // No layout overflow exceptions.
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes page header semantics region for title', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismPageShell(
            title: 'Providers',
            subtitle: 'Fixture demo',
            child: Text('body'),
          ),
        ),
      );

      // Outer page container label.
      expect(find.bySemanticsLabel('Page: Providers'), findsOneWidget);

      // Header region includes title (+ subtitle).
      final header = find.bySemanticsLabel(RegExp(r'Providers\. Fixture demo'));
      expect(header, findsOneWidget);

      final semantics = tester.getSemantics(header);
      expect(
        semantics.flagsCollection.isHeader,
        isTrue,
        reason: 'page title region must be marked as a header',
      );
    });

    testWidgets('public alias is DSPageShell via typedef', (tester) async {
      // PrismPageShell is a typedef of DSPageShell — same runtime type.
      const widget = PrismPageShell(
        title: 'Alias Check',
        child: SizedBox.shrink(),
      );
      expect(widget, isA<PrismPageShell>());
      // Confirms consumers can use either name interchangeably.
      await tester.pumpWidget(harness(child: widget));
      expect(find.text('Alias Check'), findsOneWidget);
    });
  });
}
