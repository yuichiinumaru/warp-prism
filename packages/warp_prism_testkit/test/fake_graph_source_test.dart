import 'dart:async';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('FakeGraphSource Contract Verification', () {
    verifyGraphSourceContract<String, String>(
      createSource: () => FakeGraphSource<String, String>(),
      addNode: (source, node) =>
          (source as FakeGraphSource<String, String>).addNode(node),
      updateNode: (source, node) =>
          (source as FakeGraphSource<String, String>).updateNode(node),
      removeNode: (source, nodeId) =>
          (source as FakeGraphSource<String, String>).removeNode(nodeId),
      addEdge: (source, edge) =>
          (source as FakeGraphSource<String, String>).addEdge(edge),
      updateEdge: (source, edge) =>
          (source as FakeGraphSource<String, String>).updateEdge(edge),
      removeEdge: (source, edgeId) =>
          (source as FakeGraphSource<String, String>).removeEdge(edgeId),
      setGraph: (source, {nodes, edges}) =>
          (source as FakeGraphSource<String, String>).setGraph(
            nodes: nodes,
            edges: edges,
          ),
      emitUpdateError: (source, error, [st]) =>
          (source as FakeGraphSource<String, String>).emitUpdateError(
            error,
            st,
          ),
      createSampleNode: (id, label) => GraphNode<String>(
        id: id,
        kind: 'test.node',
        label: label,
        payload: 'payload_$id',
      ),
      createSampleEdge: (id, from, to) => GraphEdge<String>(
        id: id,
        kind: 'test.edge',
        fromNodeId: from,
        toNodeId: to,
        payload: 'payload_$id',
      ),
    );

    test(
      'FakeGraphSource tracks query count and cascaded edge deletion',
      () async {
        final source = FakeGraphSource<String, String>();

        const nA = GraphNode<String>(
          id: 'A',
          kind: 'node',
          label: 'Alpha',
          payload: 'dataA',
        );
        const nB = GraphNode<String>(
          id: 'B',
          kind: 'node',
          label: 'Beta',
          payload: 'dataB',
        );
        const edge = GraphEdge<String>(
          id: 'e1',
          kind: 'edge',
          fromNodeId: 'A',
          toNodeId: 'B',
          payload: 'dataE',
        );

        source.addNode(nA);
        source.addNode(nB);
        source.addEdge(edge);

        expect(source.snapshotQueryCount, equals(0));
        final s1 = await source.getSnapshot();
        expect(source.snapshotQueryCount, equals(1));
        expect(s1.nodes.length, equals(2));
        expect(s1.edges.length, equals(1));

        // Removing node A cascades to removing edge e1
        source.removeNode('A');
        final s2 = await source.getSnapshot();
        expect(s2.nodes.containsKey('A'), isFalse);
        expect(s2.edges.containsKey('e1'), isFalse);
        expect(s2.nodes.containsKey('B'), isTrue);

        await source.close();
      },
    );

    test(
      'FakeGraphSource emitUpdateError delivers error to watchUpdates subscribers',
      () async {
        final source = FakeGraphSource<String, String>();
        Object? capturedError;
        final sub = source.watchUpdates().listen(
          (_) {},
          onError: (err, st) => capturedError = err,
        );

        const error = FormatException('Corrupt graph diff');
        source.emitUpdateError(error);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(capturedError, equals(error));
        expect(source.isClosed, isFalse);

        await sub.cancel();
        await source.close();

        expect(
          () => source.emitUpdateError(StateError('Closed')),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
