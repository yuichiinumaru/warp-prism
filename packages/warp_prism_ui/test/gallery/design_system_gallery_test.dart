import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

import 'gallery_test_oracle.dart';

/// Task 0017 / Task 1304 / Task 1613: Design System Gallery
///
/// Widget tests proving that the gallery page renders and demonstrates
/// all atomic design layers. Public barrel only — no `src/` imports.
///
/// The gallery page uses a lazy [ListView].  Tests that need to find
/// off-screen widgets must scroll before asserting.  The
/// [_findByScrolling] helper scrolls downward until the target text
/// is found or the maximum number of scroll attempts is exhausted.
void main() {
  group('DesignSystemGalleryPage', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Header renders immediately (first visible item)
      expect(find.text('Design System Gallery'), findsOneWidget);
      // TOC / section index is part of the showability surface (Task 1601)
      expect(find.text('Section index'), findsOneWidget);
    });

    testWidgets('renders all five atomic layer sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Tokens appears in the TOC chip and the section header
      expect(find.text('Tokens'), findsWidgets);

      // Remaining sections are below the fold — scroll to each
      await _findByScrolling(tester, 'Atoms');
      await _findByScrolling(tester, 'Molecules');
      await _findByScrolling(tester, 'Organisms');
      await _findByScrolling(tester, 'Templates');
    });

    testWidgets('section index exposes a TOC chip per registry section', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );
      await tester.pump();

      for (final section in dsGallerySections) {
        expect(
          find.byKey(ValueKey('gallery-toc-${section.id}')),
          findsOneWidget,
          reason: 'TOC chip for section ${section.id} must be present',
        );
      }
    });

    testWidgets('renders all registry section titles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Prove render-without-crash while scrolling; ignore known demo noise.
      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );
      await tester.pump();

      // 10 base layers + 9 EPIC-15 families (Task 1519 incl. optional-polish)
      // + 4 EPIC-16 families (Task 1613) + 1 Theme Editor (Task 1807)
      // + 1 job banner EXPERIMENTAL (Task 1858)
      // + 1 meter/fader EXPERIMENTAL (Task 1861)
      // + 1 composer EXPERIMENTAL (Task 1866)
      // + 1 numeric field EXPERIMENTAL (Task 1881)
      // + 1 session & panels EXPERIMENTAL (Task 1883)
      expect(
        dsGallerySectionTitles.length,
        29,
        reason:
            'Registry must expose 29 gallery sections '
            '(10 base + 9 EPIC-15 + 4 EPIC-16 + 1 Theme Editor + 1 banner 1858 + 1 meter 1861 + 1 composer 1866 + 1 numeric 1881 + 1 session 1883)',
      );

      for (final title in dsGallerySectionTitles) {
        await _findByScrolling(tester, title);
        expect(
          find.text(title),
          findsWidgets,
          reason: 'Registry section "$title" must render without crash',
        );
      }
    });

    testWidgets('each registry section builder renders independently', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      // Keep count aligned with dsGallerySections (operational-states + EPIC-15/16 families + Theme Editor + banner 1858 + meter 1861 + composer 1866 + numeric 1881 + session 1883).
      expect(dsGallerySections.length, 29);

      for (final section in dsGallerySections) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: section.builder()),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.text(section.title),
          findsWidgets,
          reason: 'Builder for section ${section.id} must render title',
        );
      }
    });

    testWidgets('registry section IDs are unique', (tester) async {
      final ids = dsGallerySectionIds;
      expect(
        ids.length,
        ids.toSet().length,
        reason: 'Section IDs must be unique',
      );
      // 26 pre-composer sections + 1 composer EXPERIMENTAL (Task 1866) + 1 numeric EXPERIMENTAL (Task 1881) + 1 session & panels EXPERIMENTAL (Task 1883).
      // (Pre-existing drift: this assertion read 25 after Task 1861 added
      // the 26th section; corrected to the actual count here.)
      expect(ids.length, 29);
    });

    testWidgets('EPIC-15 family section IDs are registered', (tester) async {
      final ids = dsGallerySectionIds.toSet();
      for (final id in const [
        'epic15-hud',
        'epic15-layers-filters',
        'epic15-intel',
        'epic15-stage-chrome',
        'epic15-cybercore-recon',
        'epic15-stage-relations',
        'epic15-ops',
        'epic15-terminal',
      ]) {
        expect(ids.contains(id), isTrue, reason: 'Missing EPIC-15 section $id');
      }
    });

    testWidgets('gallery host ListView scrolls to late EPIC-15 ops + terminal', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );
      await tester.pump();

      // Host scroll path (not isolated builders) for late EPIC-15 sections.
      // Section titles first, then Prism labels further down each family body.
      await _findByScrolling(tester, 'Ops Pack');
      expect(find.text('Ops Pack'), findsWidgets);
      await _findByScrollingContaining(tester, 'PrismWorkspaceShareCard');
      expect(find.textContaining('PrismWorkspaceShareCard'), findsWidgets);
      expect(find.textContaining('PrismViewPresets'), findsWidgets);

      await _findByScrolling(tester, 'Terminal');
      expect(find.text('Terminal'), findsWidgets);
      await _findByScrollingContaining(tester, 'PrismAgentShellPanel');
      expect(find.textContaining('PrismAgentShellPanel'), findsWidgets);
    });

    testWidgets('EPIC-16 family section IDs are registered', (tester) async {
      final ids = dsGallerySectionIds.toSet();
      for (final id in const [
        'epic16-content-chrome',
        'epic16-agent-transcript',
        'epic16-cybercore-ops',
        'epic16-workflow-execution',
      ]) {
        expect(ids.contains(id), isTrue, reason: 'Missing EPIC-16 section $id');
      }
    });

    testWidgets('EPIC-15 family builders render Prism labels', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15HudSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismMapHudWorkspace'), findsWidgets);
      expect(find.textContaining('PrismToolStripSlideout'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15LayersFiltersSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismLayerControlPanel'), findsWidgets);
      expect(find.textContaining('PrismFilterWorkbench'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15IntelSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismEntityIntelPanel'), findsWidgets);
      expect(find.textContaining('PrismEntityLocateSearch'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15StageChromeSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismTimeMachineScrubber'), findsWidgets);
      expect(find.textContaining('PrismStatusTicker'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15CyberCoreReconSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismOsintWorkbench'), findsWidgets);
      expect(find.textContaining('PrismAiAnalystPanel'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15StageRelationsSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismMapCanvasStage'), findsWidgets);
      expect(find.textContaining('PrismEntityRelationCard'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15OpsSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismFloatingAnalyticsHud'), findsWidgets);
      expect(find.textContaining('PrismOpsControlCluster'), findsWidgets);
      expect(find.textContaining('PrismViewPresets'), findsWidgets);
      expect(find.textContaining('PrismWorkspaceShareCard'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildEpic15TerminalSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismTerminalWorkspace'), findsWidgets);
      expect(find.textContaining('PrismAgentShellPanel'), findsWidgets);
    });

    testWidgets('EPIC-16 family builders render Prism labels', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildContentChromeSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismPageShell'), findsWidgets);
      expect(find.textContaining('PrismTree'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildAgentTranscriptSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismAgentTranscript'), findsWidgets);
      expect(find.textContaining('PrismToolCallCard'), findsWidgets);
      expect(find.textContaining('PrismMessageStatusHistory'), findsWidgets);
      expect(find.textContaining('PrismArtifactWorkbench'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildCyberCoreOpsSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismProviderHealthMatrix'), findsWidgets);
      expect(find.textContaining('PrismMcpCapabilityInspector'), findsWidgets);
      expect(find.textContaining('PrismTimingWaterfall'), findsWidgets);
      expect(find.textContaining('PrismTrafficInspector'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildWorkflowExecutionSection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('PrismWorkflowCanvasStage'), findsWidgets);
      expect(find.textContaining('PrismExecutionConsole'), findsWidgets);
    });

    testWidgets('renders token color swatches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // TOC pushes Tokens slightly below the fold on default test surfaces
      await _findByScrolling(tester, 'Color Palette');
      expect(find.text('Color Palette'), findsOneWidget);
      expect(find.text('accentCyan'), findsOneWidget);
      expect(find.text('accentViolet'), findsOneWidget);
    });

    testWidgets('renders atom samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Atom section labels — scroll to the Atoms section first
      await _findByScrolling(tester, 'Text Variants');
      expect(find.text('Icons'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);
      expect(find.text('Chips'), findsOneWidget);
      expect(find.text('Status Dots'), findsOneWidget);
      expect(find.text('Dividers'), findsOneWidget);
      expect(find.text('Glass Panels'), findsOneWidget);
    });

    testWidgets('renders molecule samples', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(tester, 'Search Bar');
      expect(
        find.text('Accordion Multi-Expand (two sections open)'),
        findsOneWidget,
      );
      expect(find.text('Multi Section A content visible.'), findsOneWidget);
      expect(find.text('Multi Section B content visible.'), findsOneWidget);
      expect(find.text('Filter Chip Group'), findsOneWidget);
      expect(find.text('Metric Tile'), findsOneWidget);
      expect(find.text('Provenance Pill'), findsOneWidget);
      expect(find.text('State Surfaces'), findsOneWidget);
    });

    testWidgets('renders organism previews', (tester) async {
      _suppressGalleryDemoNoise();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      // Sidebar items
      await _findByScrolling(tester, 'Overview');
      expect(find.text('Map'), findsWidgets); // sidebar + topbar
      expect(find.text('Operate'), findsOneWidget);

      // Lane board
      await _findByScrolling(tester, 'Align organism APIs');
      expect(find.text('Create gallery route'), findsOneWidget);

      // Timeline
      await _findByScrolling(tester, 'Project initialized');

      // Story panel
      await _findByScrolling(tester, 'Workspace Health');
    });

    testWidgets('renders template descriptions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(tester, 'MasterDetailTemplate');
      expect(find.text('CanvasTemplate'), findsOneWidget);
      expect(find.text('TimelineTemplate'), findsOneWidget);
    });

    testWidgets('renders footer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressGalleryDemoNoise();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );

      await _findByScrolling(
        tester,
        'ASW Observatory · Warp Prism · Design System v0.1.0',
      );
    });
  });

  group('PrismGallerySections', () {
    testWidgets('buildTokensSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [PrismGallerySections.buildTokensSection()],
            ),
          ),
        ),
      );

      expect(find.text('Tokens'), findsOneWidget);
      expect(find.text('Color Palette'), findsOneWidget);
    });

    testWidgets('buildAtomsSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [PrismGallerySections.buildAtomsSection()],
            ),
          ),
        ),
      );

      expect(find.text('Atoms'), findsOneWidget);
    });

    testWidgets('buildMoleculesSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [PrismGallerySections.buildMoleculesSection()],
            ),
          ),
        ),
      );

      expect(find.text('Molecules'), findsOneWidget);
    });

    testWidgets('buildOrganismsSection renders independently', (tester) async {
      _suppressGalleryDemoNoise();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismGallerySections.buildOrganismsSection(),
            ),
          ),
        ),
      );

      expect(find.text('Organisms'), findsOneWidget);
    });

    testWidgets('buildTemplatesSection renders independently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [PrismGallerySections.buildTemplatesSection()],
            ),
          ),
        ),
      );

      expect(find.text('Templates'), findsOneWidget);
    });
  });
}

/// Narrowed gallery noise suppressor (Task 1843).
///
/// Delegates to the shared, independently tested oracle in
/// `gallery_test_oracle.dart` so the mask policy has exactly one owner and the
/// regression test can assert against the very function installed here.
///
/// Before Task 1843 this also swallowed anything containing `overflow`,
/// `RenderFlex`, or `A RenderFlex overflowed`, which left the gallery suite
/// unable to fail on the layout-error class the gallery exists to prove absent.
/// Measured at the time: the old filter set suppressed **zero** messages across
/// the 22-test gallery suite, so it was inert — but latent, and now closed.
void _suppressGalleryDemoNoise() => installGalleryBenignHintSuppressor();

/// Scrolls the main gallery [ListView] until [text] is visible on screen.
///
/// Uses [pump] instead of [pumpAndSettle] to avoid timing out on
/// infinite animations (e.g. [DSShimmer]).
///
/// Finds the gallery ListView by looking for the outermost [ListView]
/// (the one that is a direct child of the gallery page [Container]).
Future<void> _findByScrolling(
  WidgetTester tester,
  String text, {
  // Scroll budget grows with the registry: 27 sections (Task 1866 added the
  // composer entry) need headroom beyond the original 100-fling budget.
  int maxScrolls = 140,
}) async {
  // Use the Scaffold body as the scrollable — the gallery's ListView
  // is nested inside it.
  final listView = find.byType(ListView).first;
  for (var i = 0; i < maxScrolls; i++) {
    if (tester.any(find.text(text))) return;
    await tester.fling(listView, const Offset(0, -500), 10000);
    await tester.pump();
  }
  // Final check — will throw TestFailure if still not found
  expect(find.text(text), findsWidgets);
}

/// Like [_findByScrolling] but matches substring labels (Prism demos).
Future<void> _findByScrollingContaining(
  WidgetTester tester,
  String substring, {
  int maxScrolls = 100,
}) async {
  final listView = find.byType(ListView).first;
  final finder = find.textContaining(substring);
  for (var i = 0; i < maxScrolls; i++) {
    if (tester.any(finder)) return;
    await tester.fling(listView, const Offset(0, -500), 10000);
    await tester.pump();
  }
  expect(finder, findsWidgets);
}
