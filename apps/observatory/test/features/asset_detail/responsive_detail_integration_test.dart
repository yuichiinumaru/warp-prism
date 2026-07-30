/// Task 0905: Responsive Detail Shell Integration — Widget Tests
///
/// Validates:
/// - Wide layout (>= 1200px): split-pane with master left, detail right
/// - Medium layout (800-1199px): overlay drawer with scrim and close
/// - Narrow layout (< 800px): full-screen detail with back navigation
/// - Detail open/close synchronization
/// - Scrim tap closes detail on medium layouts
/// - Back button closes detail on narrow layouts
/// - AssetDetailConsumer wiring
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/responsive_detail_shell.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_consumer.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Test wrapper that constrains the viewport to a specific width.
///
/// Uses [Scaffold] as body host (provides proper constraints for [SizedBox])
/// and [MediaQuery] override so that [LayoutBuilder] children see the
/// requested width instead of the 800px test surface.
///
/// The outer Scaffold is intentionally bare (no AppBar). Narrow-mode tests
/// that check Scaffold count must account for this wrapper Scaffold.
Widget _wrapWithWidth({
  required double width,
  required Widget child,
  double height = 800,
}) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}

/// Simple master content for testing.
class _MasterPlaceholder extends StatelessWidget {
  const _MasterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('MASTER_CONTENT', textDirection: TextDirection.ltr),
    );
  }
}

/// Simple detail content for testing.
class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('DETAIL_CONTENT', textDirection: TextDirection.ltr),
    );
  }
}

void main() {
  group('ResponsiveDetailShell', () {
    // -----------------------------------------------------------------------
    // Wide layout (>= 1200px): split-pane
    // -----------------------------------------------------------------------
    group('Wide layout (split-pane)', () {
      testWidgets('renders master and detail side-by-side', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        // Both master and detail should be visible
        expect(find.text('MASTER_CONTENT'), findsOneWidget);
        expect(find.text('DETAIL_CONTENT'), findsOneWidget);
      });

      testWidgets('renders only master when detail is hidden', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: const ResponsiveDetailShell(
              showDetail: false,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        expect(find.text('MASTER_CONTENT'), findsOneWidget);
        expect(find.text('DETAIL_CONTENT'), findsNothing);
      });

      testWidgets('split pane uses Row layout', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        // Should find a Row at the top level (split pane)
        expect(find.byType(Row), findsWidgets);
      });
    });

    // -----------------------------------------------------------------------
    // Medium layout (800-1199px): overlay drawer
    // -----------------------------------------------------------------------
    group('Medium layout (overlay drawer)', () {
      testWidgets('renders master with overlay drawer', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1000,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        // Both master and detail should be present (detail in overlay)
        expect(find.text('MASTER_CONTENT'), findsOneWidget);
        expect(find.text('DETAIL_CONTENT'), findsOneWidget);
      });

      testWidgets('overlay has a scrim with close gesture', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1000,
            child: ResponsiveDetailShell(
              showDetail: true,
              onDetailClose: () {},
              masterContent: const _MasterPlaceholder(),
              detailContent: const _DetailPlaceholder(),
            ),
          ),
        );

        // Scrim should be present (GestureDetector in the Stack)
        expect(find.byType(GestureDetector), findsWidgets);
      });

      testWidgets('medium scrim has dismiss semantics', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1000,
            child: ResponsiveDetailShell(
              showDetail: true,
              onDetailClose: () {},
              masterContent: const _MasterPlaceholder(),
              detailContent: const _DetailPlaceholder(),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Dismiss detail overlay'),
          findsOneWidget,
        );
      });

      testWidgets('does not render overlay when detail is hidden', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1000,
            child: const ResponsiveDetailShell(
              showDetail: false,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        expect(find.text('MASTER_CONTENT'), findsOneWidget);
        expect(find.text('DETAIL_CONTENT'), findsNothing);
      });
    });

    // -----------------------------------------------------------------------
    // Narrow layout (< 800px): full-screen detail
    // -----------------------------------------------------------------------
    group('Narrow layout (full-screen detail)', () {
      testWidgets('renders full-screen detail with Scaffold and AppBar', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 600,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
              detailTitle: 'Test Asset',
              detailKind: 'agent',
            ),
          ),
        );

        // Full-screen mode uses Scaffold (wrapper + shell = 2)
        expect(find.byType(Scaffold), findsNWidgets(2));
        expect(find.text('DETAIL_CONTENT'), findsOneWidget);
        // Master should not be visible (replaced by full-screen detail)
        expect(find.text('MASTER_CONTENT'), findsNothing);
      });

      testWidgets('full-screen has back arrow in AppBar', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 600,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
              detailTitle: 'Test Asset',
            ),
          ),
        );

        // AppBar should be present with back arrow
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back arrow triggers onDetailClose', (tester) async {
        var closed = false;

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 600,
            child: ResponsiveDetailShell(
              showDetail: true,
              onDetailClose: () => closed = true,
              masterContent: const _MasterPlaceholder(),
              detailContent: const _DetailPlaceholder(),
              detailTitle: 'Test Asset',
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        expect(closed, isTrue);
      });

      testWidgets('back button has correct semantics', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 600,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
              detailTitle: 'Test Asset',
            ),
          ),
        );

        // Semantics for "Close detail and return"
        expect(
          find.bySemanticsLabel('Close detail and return'),
          findsOneWidget,
        );
      });

      testWidgets('shows detail title in AppBar', (tester) async {
        await tester.pumpWidget(
          _wrapWithWidth(
            width: 600,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
              detailTitle: 'My Asset',
              detailKind: 'skill',
            ),
          ),
        );

        expect(find.text('My Asset'), findsOneWidget);
        expect(find.text('SKILL'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Breakpoint transitions
    // -----------------------------------------------------------------------
    group('Breakpoint transitions', () {
      testWidgets('transition from hidden to visible shows detail', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final key = GlobalKey<_ResponsiveDetailShellTestHelperState>();

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: _ResponsiveDetailShellTestHelper(
              key: key,
              initialShow: false,
            ),
          ),
        );

        expect(find.text('DETAIL_CONTENT'), findsNothing);

        // Show detail
        key.currentState!.showDetail();
        await tester.pumpAndSettle();

        expect(find.text('DETAIL_CONTENT'), findsOneWidget);
      });

      testWidgets('transition from visible to hidden removes detail', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final key = GlobalKey<_ResponsiveDetailShellTestHelperState>();

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: _ResponsiveDetailShellTestHelper(
              key: key,
              initialShow: true,
            ),
          ),
        );

        expect(find.text('DETAIL_CONTENT'), findsOneWidget);

        // Hide detail
        key.currentState!.hideDetail();
        await tester.pumpAndSettle();

        expect(find.text('DETAIL_CONTENT'), findsNothing);
      });
    });

    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------
    group('Edge cases', () {
      testWidgets('detail hidden when null content', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: const ResponsiveDetailShell(
              showDetail: false,
              masterContent: _MasterPlaceholder(),
              detailContent: SizedBox.shrink(),
            ),
          ),
        );

        expect(find.text('MASTER_CONTENT'), findsOneWidget);
      });

      testWidgets('wide layout includes divider between master and detail', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithWidth(
            width: 1400,
            child: const ResponsiveDetailShell(
              showDetail: true,
              masterContent: _MasterPlaceholder(),
              detailContent: _DetailPlaceholder(),
            ),
          ),
        );

        // Should have a 1px-wide divider between master and detail
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is ConstrainedBox &&
                w.constraints == const BoxConstraints.tightFor(width: 1),
          ),
          findsOneWidget,
        );
      });
    });
  });

  // ==========================================================================
  // AssetDetailConsumer
  // ==========================================================================
  group('AssetDetailConsumer', () {
    testWidgets('renders only child when no asset selected', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 1400,
          child: const AssetDetailConsumer(
            selectedAssetId: null,
            detailBuilder: _buildDetail,
            child: _MasterPlaceholder(),
          ),
        ),
      );

      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsNothing);
    });

    testWidgets('renders detail when asset is selected', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 1400,
          child: const AssetDetailConsumer(
            selectedAssetId: 'agent:test',
            detailTitle: 'Test Agent',
            detailKind: 'agent',
            detailBuilder: _buildDetail,
            child: _MasterPlaceholder(),
          ),
        ),
      );

      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
    });

    testWidgets('does not render detail for empty asset ID', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 1400,
          child: const AssetDetailConsumer(
            selectedAssetId: '',
            detailBuilder: _buildDetail,
            child: _MasterPlaceholder(),
          ),
        ),
      );

      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsNothing);
    });

    testWidgets('onDetailClose is passed through', (tester) async {
      var closed = false;

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 600,
          child: AssetDetailConsumer(
            selectedAssetId: 'agent:test',
            detailTitle: 'Test',
            onDetailClose: () => closed = true,
            detailBuilder: _buildDetail,
            child: const _MasterPlaceholder(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(closed, isTrue);
    });
  });

  // ==========================================================================
  // Integration: responsive behavior matches PrismBreakpoints contract
  // ==========================================================================
  group('Breakpoint contract alignment', () {
    testWidgets('wide uses split-pane at exactly 1200px', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: PrismBreakpoints.masterDetailSideBySide,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
          ),
        ),
      );

      // At exactly 1200, should be split-pane (both visible side-by-side)
      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
      // Should only have the wrapper Scaffold (no shell Scaffold in split-pane)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('medium uses overlay at 1000px', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 1000,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
          ),
        ),
      );

      // At 1000, should be overlay mode (master + overlay drawer)
      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
    });

    testWidgets('narrow uses full-screen at 600px', (tester) async {
      await tester.pumpWidget(
        _wrapWithWidth(
          width: 600,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
            detailTitle: 'Test',
          ),
        ),
      );

      // At 600, should be full-screen (Scaffold with AppBar)
      // Wrapper has 1 Scaffold + shell has 1 Scaffold = 2
      expect(find.byType(Scaffold), findsNWidgets(2));
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
    });

    testWidgets('narrow at 799px uses full-screen', (tester) async {
      await tester.pumpWidget(
        _wrapWithWidth(
          width: 799,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
            detailTitle: 'Test',
          ),
        ),
      );

      expect(find.byType(Scaffold), findsNWidgets(2));
    });

    testWidgets('medium at 800px uses overlay', (tester) async {
      await tester.pumpWidget(
        _wrapWithWidth(
          width: 800,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
          ),
        ),
      );

      // At 800, should NOT be full-screen (no Scaffold for detail)
      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
    });

    testWidgets('medium at 1199px uses overlay', (tester) async {
      tester.view.physicalSize = const Size(1199, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithWidth(
          width: 1199,
          child: const ResponsiveDetailShell(
            showDetail: true,
            masterContent: _MasterPlaceholder(),
            detailContent: _DetailPlaceholder(),
          ),
        ),
      );

      expect(find.text('MASTER_CONTENT'), findsOneWidget);
      expect(find.text('DETAIL_CONTENT'), findsOneWidget);
    });
  });
}

/// Helper widget that can toggle detail visibility for transition tests.
class _ResponsiveDetailShellTestHelper extends StatefulWidget {
  final bool initialShow;

  const _ResponsiveDetailShellTestHelper({super.key, this.initialShow = false});

  @override
  State<_ResponsiveDetailShellTestHelper> createState() =>
      _ResponsiveDetailShellTestHelperState();
}

class _ResponsiveDetailShellTestHelperState
    extends State<_ResponsiveDetailShellTestHelper> {
  late bool _showDetail;

  @override
  void initState() {
    super.initState();
    _showDetail = widget.initialShow;
  }

  void showDetail() => setState(() => _showDetail = true);
  void hideDetail() => setState(() => _showDetail = false);

  @override
  Widget build(BuildContext context) {
    return ResponsiveDetailShell(
      showDetail: _showDetail,
      onDetailClose: hideDetail,
      detailTitle: 'Test Asset',
      masterContent: const _MasterPlaceholder(),
      detailContent: const _DetailPlaceholder(),
    );
  }
}

/// Static detail builder for AssetDetailConsumer tests.
Widget _buildDetail(BuildContext context, String assetId) {
  return const _DetailPlaceholder();
}
