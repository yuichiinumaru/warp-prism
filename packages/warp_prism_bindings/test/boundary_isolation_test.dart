import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

File _resolveRepoFile(String relativePath) {
  var file = File(relativePath);
  if (file.existsSync()) return file;

  final siblingPath = relativePath.startsWith('packages/')
      ? '../${relativePath.substring('packages/'.length)}'
      : '../$relativePath';
  file = File(siblingPath);
  if (file.existsSync()) return file;

  final testSiblingPath = '../$siblingPath';
  file = File(testSiblingPath);
  if (file.existsSync()) return file;

  var dir = Directory.current.absolute;
  while (true) {
    final candidate = File('${dir.path}/$relativePath');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  return File(relativePath);
}

String _stripComments(String source) {
  final withoutMultiLine =
      source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  return withoutMultiLine
      .split('\n')
      .where((line) => !line.trim().startsWith('//'))
      .join('\n');
}

void main() {
  group('Boundary and Architectural Isolation', () {
    test('all core bindings instantiate cleanly with test doubles', () {
      final fakeEventStream = FakeEventStream<String>();
      final eventBinding = EventStreamBinding<String>(source: fakeEventStream);

      final fakeGraphSource = FakeGraphSource<String, String>();
      final graphBinding = GraphSourceBinding<String, String>(
        source: fakeGraphSource,
      );

      final fakeCommand = FakeAsyncCommand<String, String>(initialResult: 'ok');
      final commandBinding = AsyncCommandBinding<String, String>(
        command: fakeCommand,
      );

      final fakeHealthSource = FakeHealthSource();
      final healthBinding = HealthSourceBinding(source: fakeHealthSource);

      expect(eventBinding.status, equals(EventStreamBindingStatus.active));
      expect(graphBinding.nodeCount, equals(0));
      expect(commandBinding.status, equals(AsyncCommandStatus.idle));
      expect(healthBinding.isDisposed, isFalse);
      expect(healthBinding.cellCount, equals(0));

      eventBinding.dispose();
      graphBinding.dispose();
      commandBinding.dispose();
      healthBinding.dispose();
    });

    test(
      'GraphSourceBinding preserves layout state outside runtime models',
      () async {
        // 1. Structural source-scan assertion: runtime models contain NO Offset, Flutter, or UI imports
        final runtimeModelsFile = _resolveRepoFile(
          'packages/warp_prism_runtime/lib/src/graph_source/graph_source_models.dart',
        );
        expect(
          runtimeModelsFile.existsSync(),
          isTrue,
          reason:
              'Runtime graph models file must exist at ${runtimeModelsFile.path}',
        );
        final runtimeSource = runtimeModelsFile.readAsStringSync();
        final runtimeCodeOnly = _stripComments(runtimeSource);
        expect(
          runtimeCodeOnly.contains('Offset'),
          isFalse,
          reason: 'Runtime graph models code must not contain Offset tokens',
        );
        expect(
          runtimeSource.contains('package:flutter'),
          isFalse,
          reason: 'Runtime graph models must not import package:flutter',
        );
        expect(
          runtimeSource.contains('dart:ui'),
          isFalse,
          reason: 'Runtime graph models must not import dart:ui',
        );

        // 2. Structural source-scan assertion: bindings view model DOES own Offset positions
        final bindingViewModelFile = _resolveRepoFile(
          'packages/warp_prism_bindings/lib/src/graph_source_binding/graph_view_model.dart',
        );
        expect(
          bindingViewModelFile.existsSync(),
          isTrue,
          reason:
              'Binding graph view model file must exist at ${bindingViewModelFile.path}',
        );
        final bindingSource = bindingViewModelFile.readAsStringSync();
        expect(
          bindingSource.contains('Offset'),
          isTrue,
          reason: 'Binding view model must own Offset positions',
        );

        // 3. Behavioral verification with runtime models and binding projection
        final fakeSource = FakeGraphSource<String, String>(
          initialNodes: const [
            GraphNode<String>(
              id: 'n-boundary',
              kind: 'service',
              label: 'Boundary Node',
              payload: 'data',
            ),
          ],
        );

        final binding = GraphSourceBinding<String, String>(source: fakeSource);
        await Future<void>.delayed(Duration.zero);

        final runtimeNode =
            (await fakeSource.getSnapshot()).nodes['n-boundary']!;
        expect(runtimeNode.label, equals('Boundary Node'));

        final viewNode = binding.viewModel.nodeById('n-boundary')!;
        expect(viewNode.position, isNotNull);
        expect(binding.positions.containsKey('n-boundary'), isTrue);

        binding.dispose();
      },
    );
  });
}
