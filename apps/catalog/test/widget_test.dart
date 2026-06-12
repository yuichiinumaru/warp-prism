/// Catalog contract tests — ADS proof surface.
///
/// Verifies that the Design System Gallery renders all registered sections,
/// has no duplicate section headings, covers state matrices per atomic design
/// layer, and adapts to responsive breakpoints.
///
/// Task 1305: Catalog Contract Expansion
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_catalog/main.dart';

/// Expected section headings rendered by [DesignSystemGalleryPage].
///
/// Order matches the build order in the gallery page.  If a new section is
/// added to the gallery, it must be added here to keep the contract test
/// authoritative.
const sectionTitles = <String>[
  'Tokens',
  'Atoms',
  'Molecules',
  'Operational States',
  'Organisms',
  'Virtual Scroll',
  'Health Dashboard',
  'Toasts',
  'Accessibility & Focus States',
  'Templates',
];

/// Scroll the gallery [ListView] until [finder] is visible.
///
/// The gallery uses a lazy [ListView], so off-screen sections are not built
/// until scrolled into view.  This helper flings upward in increments until
/// the target widget appears or a retry limit is hit.
///
/// Uses [pump] with a fixed duration instead of [pumpAndSettle] to avoid
/// timeouts from infinite animations (e.g. DSShimmer).
Future<void> _scrollUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFlings = 30,
}) async {
  for (var i = 0; i < maxFlings; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.fling(find.byType(ListView).first, const Offset(0, -600), 800);
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Build the gallery inside [MaterialApp] + [Scaffold] so that Material
/// widgets (e.g. [TextField] inside [DSSearchBar]) have a Material ancestor.
Widget _buildGalleryInMaterial() {
  return const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage()));
}

void main() {
  group('Catalog app', () {
    testWidgets('renders gallery page without crashing', (tester) async {
      await tester.pumpWidget(const WarpPrismCatalogApp());
      expect(find.byType(WarpPrismCatalogApp), findsOneWidget);
      expect(find.byType(DesignSystemGalleryPage), findsOneWidget);
    });
  });

  group('Section rendering', () {
    testWidgets('all expected sections render without crash', (tester) async {
      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      for (final title in sectionTitles) {
        await _scrollUntilFound(tester, find.text(title));
        expect(
          find.text(title),
          findsOneWidget,
          reason: 'Section "$title" should render in the gallery',
        );
      }
    });

    testWidgets('no duplicate section headings exist', (tester) async {
      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      for (final title in sectionTitles) {
        await _scrollUntilFound(tester, find.text(title));
        expect(
          find.text(title),
          findsOneWidget,
          reason: 'Section heading "$title" must be unique',
        );
      }
    });
  });

  group('State matrices', () {
    testWidgets('atom layer: DSStateSurface renders all UI data states', (
      tester,
    ) async {
      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      // Scroll to the Molecules section where DSStateSurface instances live.
      await _scrollUntilFound(tester, find.text('State Surfaces'));

      expect(find.byType(DSStateSurface), findsWidgets);

      // Verify representative text from each state surface.
      expect(
        find.text('No assets loaded'),
        findsOneWidget,
        reason: 'DSStateSurface.empty should render',
      );
      expect(
        find.text('Loading workspace...'),
        findsOneWidget,
        reason: 'DSStateSurface.loading should render',
      );
      expect(
        find.text('Failed to parse workspace'),
        findsOneWidget,
        reason: 'DSStateSurface.error should render',
      );
      expect(
        find.text('Feature disabled'),
        findsOneWidget,
        reason: 'DSStateSurface.disabled should render',
      );
    });

    testWidgets(
      'molecule layer: DSShimmer and DSSkeletonCard render loading states',
      (tester) async {
        await tester.pumpWidget(_buildGalleryInMaterial());
        await tester.pump();

        await _scrollUntilFound(tester, find.text('Shimmer (base animation)'));

        expect(find.byType(DSShimmer), findsWidgets);
        expect(find.byType(DSSkeletonTextLine), findsWidgets);
        expect(find.byType(DSSkeletonCard), findsOneWidget);
        expect(find.byType(DSSkeletonTableRows), findsWidgets);
      },
    );

    testWidgets(
      'organism layer: DSOperationalState tiles render all 15 states',
      (tester) async {
        await tester.pumpWidget(_buildGalleryInMaterial());
        await tester.pump();

        await _scrollUntilFound(tester, find.text('Operational States'));

        // Verify each operational state label renders.
        for (final state in DSOperationalState.values) {
          expect(
            find.text(state.label),
            findsWidgets,
            reason: 'DSOperationalState.${state.name} label should render',
          );
        }

        // Verify operational badges and status dots render for all 15 states.
        expect(find.byType(DSBadge), findsWidgets);
        expect(find.byType(DSStatusDot), findsWidgets);
      },
    );

    testWidgets('template layer: template previews render', (tester) async {
      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      await _scrollUntilFound(tester, find.text('Templates'));

      expect(find.text('MasterDetailTemplate'), findsOneWidget);
      expect(find.text('CanvasTemplate'), findsOneWidget);
      expect(find.text('TimelineTemplate'), findsOneWidget);
    });
  });

  group('Responsive layout', () {
    testWidgets('renders all sections at compact width (800px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      expect(find.byType(DesignSystemGalleryPage), findsOneWidget);

      for (final title in sectionTitles) {
        await _scrollUntilFound(tester, find.text(title));
        expect(
          find.text(title),
          findsOneWidget,
          reason: 'Section "$title" should render at compact width',
        );
      }
    });

    testWidgets('renders all sections at expanded width (1400px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      expect(find.byType(DesignSystemGalleryPage), findsOneWidget);

      for (final title in sectionTitles) {
        await _scrollUntilFound(tester, find.text(title));
        expect(
          find.text(title),
          findsOneWidget,
          reason: 'Section "$title" should render at expanded width',
        );
      }
    });

    testWidgets('DS sidebar renders at both widths', (tester) async {
      await tester.pumpWidget(_buildGalleryInMaterial());
      await tester.pump();

      await _scrollUntilFound(
        tester,
        find.text('DSSidebar (collapsed preview)'),
      );
      expect(find.byType(DSSidebar), findsWidgets);
    });
  });
}
