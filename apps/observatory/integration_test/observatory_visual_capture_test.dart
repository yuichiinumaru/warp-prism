// Deterministic visual acceptance capture test suite for Observatory host.
// Viewport: 1280x800 desktop, DPR 1.0.
// Captures Observatory Shell / Overview Dashboard.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:warp_prism_observatory/app/app.dart';

const _captureRootKey = Key('visual-acceptance-capture-root');

class VisualCaptureArtifact {
  final String name;
  final File file;
  final int byteLength;
  final int width;
  final int height;

  const VisualCaptureArtifact({
    required this.name,
    required this.file,
    required this.byteLength,
    required this.width,
    required this.height,
  });
}

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

VisualCaptureArtifact _verifyPngArtifact(
  File file,
  String name, {
  int? expectedWidth,
  int? expectedHeight,
}) {
  if (!file.existsSync()) {
    fail('BLOCKED: Visual capture artifact does not exist on disk: ${file.path}');
  }
  final bytes = file.readAsBytesSync();
  if (bytes.isEmpty) {
    fail('BLOCKED: Visual capture artifact is empty (0 bytes): ${file.path}');
  }
  if (bytes.length < 24) {
    fail(
      'BLOCKED: Visual capture artifact is too small to be a valid PNG '
      '(${bytes.length} bytes): ${file.path}',
    );
  }
  const pngMagic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (var i = 0; i < 8; i++) {
    if (bytes[i] != pngMagic[i]) {
      fail(
        'BLOCKED: Visual capture artifact does not contain a valid PNG signature: '
        '${file.path}',
      );
    }
  }
  final byteData = ByteData.sublistView(bytes);
  final width = byteData.getUint32(16, Endian.big);
  final height = byteData.getUint32(20, Endian.big);

  if (expectedWidth != null && width != expectedWidth) {
    fail(
      'Visual capture artifact width mismatch for $name: '
      'expected $expectedWidth but got $width',
    );
  }
  if (expectedHeight != null && height != expectedHeight) {
    fail(
      'Visual capture artifact height mismatch for $name: '
      'expected $expectedHeight but got $height',
    );
  }

  return VisualCaptureArtifact(
    name: name,
    file: file,
    byteLength: bytes.length,
    width: width,
    height: height,
  );
}

Future<VisualCaptureArtifact> _captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name, {
  int expectedWidth = 1280,
  int expectedHeight = 800,
  bool disableRasterForTesting = false,
}) async {
  Object? rasterError;
  File? writtenFile;

  // 1. Primary path: local RepaintBoundary rasterization.
  if (disableRasterForTesting) {
    rasterError = StateError('Rasterization deliberately disabled for testing');
  } else {
    try {
      final boundaryFinder = find.byKey(_captureRootKey);
      if (boundaryFinder.evaluate().isEmpty) {
        throw StateError(
          'Capture root RepaintBoundary ($_captureRootKey) not found in widget tree',
        );
      }
      final boundary = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
      final image = await boundary.toImage(pixelRatio: 1.0);
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null || byteData.lengthInBytes == 0) {
          throw StateError('Flutter returned no PNG bytes for $name');
        }
        final output = File(
          '${_repositoryRoot().path}/docs/reports/captures/candidates/$name.png',
        );
        await output.parent.create(recursive: true);
        await output.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
        writtenFile = output;
      } finally {
        image.dispose();
      }
    } catch (error, stack) {
      rasterError = error;
      debugPrint('Local RepaintBoundary rasterization failed for $name: $error\n$stack');
    }
  }

  // 2. Best-effort fallback / driver hook: binding.takeScreenshot.
  Object? driverError;
  try {
    await binding.takeScreenshot(name);
  } catch (error) {
    driverError = error;
    debugPrint(
      'Integration driver screenshot unavailable for $name '
      '(runner missing capability plugins.flutter.io/integration_test): $error',
    );
  }

  // 3. Honest proof verification:
  // If local rasterization failed AND driver capture also failed / produced nothing:
  if (writtenFile == null) {
    fail(
      'BLOCKED: Visual capture unavailable for "$name". '
      'Missing capability: local RepaintBoundary rasterization failed ($rasterError) '
      'and integration driver takeScreenshot unavailable ($driverError). '
      'No verified screenshot bytes were produced.',
    );
  }

  // 4. Assert primary artifact integrity: existence, non-emptiness, PNG signature, dimensions.
  final artifact = _verifyPngArtifact(
    writtenFile,
    name,
    expectedWidth: expectedWidth,
    expectedHeight: expectedHeight,
  );
  debugPrint(
    'Verified visual capture artifact: ${artifact.file.path} '
    '(${artifact.byteLength} bytes, ${artifact.width}x${artifact.height})',
  );

  return artifact;
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
            child: TickerMode(
              enabled: false,
              child: ProviderScope(child: WarpPrismApp()),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        final artifact = await _captureScreenshot(
          binding,
          tester,
          'observatory_overview_dashboard',
        );
        expect(artifact.file.existsSync(), isTrue);
        expect(artifact.byteLength, greaterThan(0));
        expect(artifact.width, equals(1280));
        expect(artifact.height, equals(800));
        expect(find.byType(WarpPrismApp), findsOneWidget);
      },
    );

    testWidgets(
      'fails honestly with BLOCKED when visual capture is unavailable',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const RepaintBoundary(
            key: _captureRootKey,
            child: SizedBox(width: 100, height: 100),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          () => _captureScreenshot(
            binding,
            tester,
            'observatory_sabotage_unavailable_check',
            disableRasterForTesting: true,
          ),
          throwsA(
            isA<TestFailure>().having(
              (e) => e.message,
              'message',
              allOf([
                contains('BLOCKED: Visual capture unavailable'),
                contains('Missing capability'),
                contains('plugins.flutter.io/integration_test'),
              ]),
            ),
          ),
        );
      },
    );
  });
}
