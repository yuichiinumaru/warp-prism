// Deterministic visual acceptance capture test suite for Observatory host.
// Viewport: 1280x800 desktop, DPR 1.0.
// Captures Observatory Shell / Overview Dashboard.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:warp_prism_observatory/app/app.dart';

const _captureRootKey = Key('visual-acceptance-capture-root');

Directory _repositoryRoot() {
  var directory = Directory.current;
  while (directory.parent.path != directory.path) {
    if (Directory('${directory.path}/docs/reports').existsSync()) {
      return directory;
    }
    directory = directory.parent;
  }
  return Directory.current;
}

Future<String> _captureRenderedPng(WidgetTester tester, String name) async {
  await tester.binding.endOfFrame;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureRootKey),
  );
  final image = await boundary.toImage(pixelRatio: 1.0);
  try {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Flutter returned no PNG bytes for $name');
    }
    final output = File(
      '${_repositoryRoot().path}/docs/reports/captures/candidates/$name.png',
    );
    await output.parent.create(recursive: true);
    await output.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return output.path;
  } finally {
    image.dispose();
  }
}

Future<void> _captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  try {
    final path = await _captureRenderedPng(tester, name);
    debugPrint('Rendered candidate screenshot: $path');
  } catch (error) {
    debugPrint('Rendered candidate screenshot unavailable for $name: $error');
  }
  try {
    await binding.takeScreenshot(name);
  } catch (error) {
    debugPrint('Integration driver screenshot unavailable for $name: $error');
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Observatory Host — Visual Acceptance Capture Harness', () {
    testWidgets(
      'captures Observatory Overview dashboard at 1280x800 desktop viewport',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const RepaintBoundary(
            key: _captureRootKey,
            child: ProviderScope(child: WarpPrismApp()),
          ),
        );
        await tester.pumpAndSettle();
        await _captureScreenshot(
          binding,
          tester,
          'observatory_overview_dashboard',
        );
        expect(find.byType(WarpPrismApp), findsOneWidget);
      },
    );
  });
}
