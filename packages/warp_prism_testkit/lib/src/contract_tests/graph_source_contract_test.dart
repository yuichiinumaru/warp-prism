import 'dart:async';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Reusable contract compliance test suite for [GraphSource] implementations.
///
/// Verifies snapshot retrieval, structural adjacency queries, incremental
/// node/edge update streams, and whole-graph reset events.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
void verifyGraphSourceContract<TNodePayload, TEdgePayload>({
  required GraphSource<TNodePayload, TEdgePayload> Function() createSource,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source,
    GraphNode<TNodePayload> node,
  )?
  addNode,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source,
    GraphNode<TNodePayload> node,
  )?
  updateNode,
  void Function(GraphSource<TNodePayload, TEdgePayload> source, String nodeId)?
  removeNode,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source,
    GraphEdge<TEdgePayload> edge,
  )?
  addEdge,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source,
    GraphEdge<TEdgePayload> edge,
  )?
  updateEdge,
  void Function(GraphSource<TNodePayload, TEdgePayload> source, String edgeId)?
  removeEdge,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source, {
    Iterable<GraphNode<TNodePayload>>? nodes,
    Iterable<GraphEdge<TEdgePayload>>? edges,
  })?
  setGraph,
  void Function(
    GraphSource<TNodePayload, TEdgePayload> source,
    Object error, [
    StackTrace? stackTrace,
  ])?
  emitUpdateError,
  required GraphNode<TNodePayload> Function(String id, String label)
  createSampleNode,
  required GraphEdge<TEdgePayload> Function(
    String id,
    String fromNodeId,
    String toNodeId,
  )
  createSampleEdge,
  String description = 'GraphSource Contract Compliance',
}) {
  group(description, () {
    late GraphSource<TNodePayload, TEdgePayload> source;

    setUp(() {
      source = createSource();
    });

    tearDown(() async {
      if (!source.isClosed) {
        await source.close();
      }
    });

    test('getSnapshot returns a valid GraphSnapshot', () async {
      final snapshot = await source.getSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot.timestamp, isNotNull);
      expect(snapshot.nodes, isA<Map<String, GraphNode<TNodePayload>>>());
      expect(snapshot.edges, isA<Map<String, GraphEdge<TEdgePayload>>>());
    });

    test('GraphSnapshot adjacency query helpers evaluate graph topology', () {
      final nodeA = createSampleNode('A', 'Node A');
      final nodeB = createSampleNode('B', 'Node B');
      final nodeC = createSampleNode('C', 'Node C');

      final edgeAB = createSampleEdge('e_ab', 'A', 'B');
      final edgeBC = createSampleEdge('e_bc', 'B', 'C');
      final edgeAC = createSampleEdge('e_ac', 'A', 'C');

      final snapshot = GraphSnapshot<TNodePayload, TEdgePayload>(
        nodes: {'A': nodeA, 'B': nodeB, 'C': nodeC},
        edges: {'e_ab': edgeAB, 'e_bc': edgeBC, 'e_ac': edgeAC},
        timestamp: DateTime.now(),
      );

      expect(snapshot.getNode('A'), equals(nodeA));
      expect(snapshot.getNode('missing'), isNull);
      expect(snapshot.getEdge('e_ab'), equals(edgeAB));

      final outA = snapshot.outgoingEdges('A');
      expect(outA.length, equals(2));
      expect(outA.map((e) => e.id), containsAll(['e_ab', 'e_ac']));

      final inC = snapshot.incomingEdges('C');
      expect(inC.length, equals(2));
      expect(inC.map((e) => e.id), containsAll(['e_bc', 'e_ac']));

      final adjA = snapshot.adjacentNodes('A');
      expect(adjA.length, equals(2));
      expect(adjA.map((n) => n.id), containsAll(['B', 'C']));

      final edgesAC = snapshot.edgesBetween('A', 'C');
      expect(edgesAC.length, equals(1));
      expect(edgesAC.first.id, equals('e_ac'));
    });

    if (addNode != null && updateNode != null && removeNode != null) {
      test(
        'incremental node updates emit structured events on watchUpdates',
        () async {
          final updates = <GraphUpdate<TNodePayload, TEdgePayload>>[];
          final sub = source.watchUpdates().listen(updates.add);

          final node = createSampleNode('n1', 'Test Node 1');
          addNode(source, node);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.isNotEmpty, isTrue);
          expect(updates.last, isA<NodeAdded<TNodePayload, TEdgePayload>>());
          expect(
            (updates.last as NodeAdded<TNodePayload, TEdgePayload>).node.id,
            equals('n1'),
          );

          final updatedNode = createSampleNode('n1', 'Updated Test Node 1');
          updateNode(source, updatedNode);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.last, isA<NodeUpdated<TNodePayload, TEdgePayload>>());

          removeNode(source, 'n1');
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.last, isA<NodeRemoved<TNodePayload, TEdgePayload>>());
          expect(
            (updates.last as NodeRemoved<TNodePayload, TEdgePayload>).nodeId,
            equals('n1'),
          );

          await sub.cancel();
        },
      );
    }

    if (addEdge != null && removeEdge != null) {
      test(
        'incremental edge updates emit structured events on watchUpdates',
        () async {
          final updates = <GraphUpdate<TNodePayload, TEdgePayload>>[];
          final sub = source.watchUpdates().listen(updates.add);

          final edge = createSampleEdge('e1', 'src', 'dst');
          addEdge(source, edge);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.isNotEmpty, isTrue);
          expect(updates.last, isA<EdgeAdded<TNodePayload, TEdgePayload>>());

          if (updateEdge != null) {
            final updatedEdge = createSampleEdge('e1', 'src', 'dst_updated');
            updateEdge(source, updatedEdge);
            await Future<void>.delayed(const Duration(milliseconds: 10));

            expect(updates.last, isA<EdgeUpdated<TNodePayload, TEdgePayload>>());
            final edgeUpdated =
                updates.last as EdgeUpdated<TNodePayload, TEdgePayload>;
            expect(edgeUpdated.edge.id, equals('e1'));
          }

          removeEdge(source, 'e1');
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.last, isA<EdgeRemoved<TNodePayload, TEdgePayload>>());

          await sub.cancel();
        },
      );
    }

    if (setGraph != null) {
      test(
        'whole-graph reset emits GraphReset event with new snapshot',
        () async {
          final updates = <GraphUpdate<TNodePayload, TEdgePayload>>[];
          final sub = source.watchUpdates().listen(updates.add);

          final nA = createSampleNode('A', 'Alpha');
          final nB = createSampleNode('B', 'Beta');
          final edge = createSampleEdge('e_ab', 'A', 'B');

          setGraph(source, nodes: [nA, nB], edges: [edge]);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(updates.isNotEmpty, isTrue);
          expect(updates.last, isA<GraphReset<TNodePayload, TEdgePayload>>());

          final resetEvent =
              updates.last as GraphReset<TNodePayload, TEdgePayload>;
          expect(resetEvent.snapshot.nodes.length, equals(2));
          expect(resetEvent.snapshot.edges.length, equals(1));

          await sub.cancel();
        },
      );
    }

    if (emitUpdateError != null) {
      test(
        'watchUpdates stream emits errors to subscriber without corrupting snapshot state',
        () async {
          Object? capturedError;
          final sub = source.watchUpdates().listen(
            (_) {},
            onError: (err, st) => capturedError = err,
          );

          final testError = StateError('Graph update stream sync failure');
          emitUpdateError(source, testError);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(capturedError, equals(testError));
          expect(source.isClosed, isFalse);

          // Subsequent snapshot retrieval remains valid and uncorrupted
          final snapshot = await source.getSnapshot();
          expect(snapshot, isNotNull);
          expect(snapshot.nodes, isA<Map<String, GraphNode<TNodePayload>>>());

          await sub.cancel();
        },
      );
    }

    test(
      'source close terminates watchUpdates stream, updates isClosed, and post-close queries fail',
      () async {
        final testSource = createSource();
        var streamDone = false;
        final sub = testSource.watchUpdates().listen(
          (_) {},
          onDone: () => streamDone = true,
        );

        expect(testSource.isClosed, isFalse);
        await testSource.close();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(testSource.isClosed, isTrue);
        expect(streamDone, isTrue);

        // Subsequent close() call is idempotent
        await testSource.close();
        expect(testSource.isClosed, isTrue);

        // Post-close queries fail deterministically
        expect(() => testSource.getSnapshot(), throwsA(isA<StateError>()));

        await sub.cancel();
      },
    );
  });
}

void main() {}
