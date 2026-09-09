import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('GraphSourceBinding', () {
    test(
      'initializes and computes layout coordinates for initial snapshot',
      () async {
        final initialNodes = [
          const GraphNode<String>(
            id: 'n1',
            kind: 'service',
            label: 'Auth Service',
            payload: 'auth-data',
          ),
          const GraphNode<String>(
            id: 'n2',
            kind: 'database',
            label: 'User DB',
            payload: 'db-data',
          ),
        ];

        final initialEdges = [
          const GraphEdge<String>(
            id: 'e1',
            kind: 'depends_on',
            fromNodeId: 'n1',
            toNodeId: 'n2',
            payload: 'conn-1',
          ),
        ];

        final fakeSource = FakeGraphSource<String, String>(
          initialNodes: initialNodes,
          initialEdges: initialEdges,
        );

        final binding = GraphSourceBinding<String, String>(
          source: fakeSource,
          layoutStrategy: const CircleGraphLayoutStrategy(
            radius: 100,
            center: Offset(200, 200),
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(binding.nodeCount, equals(2));
        expect(binding.edgeCount, equals(1));
        expect(binding.nodes.length, equals(2));
        expect(binding.edges.length, equals(1));

        final n1 = binding.viewModel.nodeById('n1');
        expect(n1, isNotNull);
        expect(n1!.label, equals('Auth Service'));
        expect(n1.type, equals('service'));
        expect(n1.position, isNot(equals(Offset.zero)));

        final n2 = binding.viewModel.nodeById('n2');
        expect(n2, isNotNull);
        expect(n2!.label, equals('User DB'));
        expect(n2.position, isNot(equals(Offset.zero)));
        expect(n1.position, isNot(equals(n2.position)));

        final edge = binding.viewModel.edgeBetween('n1', 'n2');
        expect(edge, isNotNull);
        expect(edge!.sourceId, equals('n1'));
        expect(edge.targetId, equals('n2'));

        binding.dispose();
      },
    );

    test(
      'supports GridGraphLayoutStrategy with predictable coordinates',
      () async {
        final initialNodes = [
          const GraphNode<String>(
            id: 'node-0',
            kind: 'task',
            label: 'Task 0',
            payload: '0',
          ),
          const GraphNode<String>(
            id: 'node-1',
            kind: 'task',
            label: 'Task 1',
            payload: '1',
          ),
          const GraphNode<String>(
            id: 'node-2',
            kind: 'task',
            label: 'Task 2',
            payload: '2',
          ),
          const GraphNode<String>(
            id: 'node-3',
            kind: 'task',
            label: 'Task 3',
            payload: '3',
          ),
        ];

        final fakeSource = FakeGraphSource<String, String>(
          initialNodes: initialNodes,
        );

        final binding = GraphSourceBinding<String, String>(
          source: fakeSource,
          layoutStrategy: const GridGraphLayoutStrategy(
            columns: 2,
            horizontalSpacing: 100,
            verticalSpacing: 80,
            origin: Offset(50, 50),
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(binding.positions['node-0'], equals(const Offset(50, 50)));
        expect(binding.positions['node-1'], equals(const Offset(150, 50)));
        expect(binding.positions['node-2'], equals(const Offset(50, 130)));
        expect(binding.positions['node-3'], equals(const Offset(150, 130)));

        binding.dispose();
      },
    );

    test(
      'handles incremental NodeAdded and assigns computed position',
      () async {
        final fakeSource = FakeGraphSource<String, String>();
        final binding = GraphSourceBinding<String, String>(source: fakeSource);

        await Future<void>.delayed(Duration.zero);
        expect(binding.nodeCount, equals(0));

        fakeSource.addNode(
          const GraphNode<String>(
            id: 'worker-1',
            kind: 'worker',
            label: 'Worker Node',
            payload: 'w1',
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(binding.nodeCount, equals(1));
        expect(binding.nodes.first.id, equals('worker-1'));
        expect(binding.positions.containsKey('worker-1'), isTrue);

        binding.dispose();
      },
    );

    test(
      'NodeUpdated preserves existing layout position while updating metadata/label',
      () async {
        final fakeSource = FakeGraphSource<String, String>(
          initialNodes: const [
            GraphNode<String>(
              id: 'n1',
              kind: 'pod',
              label: 'Pod Initial',
              status: 'starting',
              payload: 'p1',
            ),
          ],
        );

        final binding = GraphSourceBinding<String, String>(source: fakeSource);
        await Future<void>.delayed(Duration.zero);

        final initialPos = binding.positions['n1']!;

        fakeSource.updateNode(
          const GraphNode<String>(
            id: 'n1',
            kind: 'pod',
            label: 'Pod Running',
            status: 'ready',
            payload: 'p1-updated',
          ),
        );
        await Future<void>.delayed(Duration.zero);

        final updatedNode = binding.viewModel.nodeById('n1')!;
        expect(updatedNode.label, equals('Pod Running'));
        expect(updatedNode.status, equals('ready'));
        expect(binding.positions['n1'], equals(initialPos));
        expect(updatedNode.position, equals(initialPos));

        binding.dispose();
      },
    );

    test('NodeRemoved removes node, position, and connected edges', () async {
      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: const [
          GraphNode<String>(id: 'a', kind: 'step', label: 'A', payload: 'a'),
          GraphNode<String>(id: 'b', kind: 'step', label: 'B', payload: 'b'),
        ],
        initialEdges: const [
          GraphEdge<String>(
            id: 'e-ab',
            kind: 'next',
            fromNodeId: 'a',
            toNodeId: 'b',
            payload: 'ab',
          ),
        ],
      );

      final binding = GraphSourceBinding<String, String>(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.nodeCount, equals(2));
      expect(binding.edgeCount, equals(1));

      fakeSource.removeNode('a');
      await Future<void>.delayed(Duration.zero);

      expect(binding.nodeCount, equals(1));
      expect(binding.edgeCount, equals(0));
      expect(binding.positions.containsKey('a'), isFalse);
      expect(binding.viewModel.nodeById('a'), isNull);
      expect(binding.viewModel.nodeById('b'), isNotNull);

      binding.dispose();
    });

    test('handles EdgeAdded, EdgeUpdated, and EdgeRemoved events', () async {
      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: const [
          GraphNode<String>(id: '1', kind: 'n', label: '1', payload: '1'),
          GraphNode<String>(id: '2', kind: 'n', label: '2', payload: '2'),
        ],
      );

      final binding = GraphSourceBinding<String, String>(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.edgeCount, equals(0));

      fakeSource.addEdge(
        const GraphEdge<String>(
          id: 'e1',
          kind: 'flow',
          fromNodeId: '1',
          toNodeId: '2',
          payload: 'initial',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(binding.edgeCount, equals(1));

      fakeSource.updateEdge(
        const GraphEdge<String>(
          id: 'e1',
          kind: 'data_flow',
          fromNodeId: '1',
          toNodeId: '2',
          payload: 'updated',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(binding.edges.first.edgeType, equals('data_flow'));

      fakeSource.removeEdge('e1');
      await Future<void>.delayed(Duration.zero);
      expect(binding.edgeCount, equals(0));

      binding.dispose();
    });

    test(
      'GraphReset completely updates nodes, edges, and recomputes layout',
      () async {
        final fakeSource = FakeGraphSource<String, String>(
          initialNodes: const [
            GraphNode<String>(
              id: 'old',
              kind: 'old',
              label: 'Old',
              payload: 'o',
            ),
          ],
        );

        final binding = GraphSourceBinding<String, String>(source: fakeSource);
        await Future<void>.delayed(Duration.zero);
        expect(binding.viewModel.nodeById('old'), isNotNull);

        fakeSource.setGraph(
          nodes: const [
            GraphNode<String>(
              id: 'new1',
              kind: 'k',
              label: 'N1',
              payload: 'n1',
            ),
            GraphNode<String>(
              id: 'new2',
              kind: 'k',
              label: 'N2',
              payload: 'n2',
            ),
          ],
          edges: const [
            GraphEdge<String>(
              id: 'e-new',
              kind: 'rel',
              fromNodeId: 'new1',
              toNodeId: 'new2',
              payload: 'r',
            ),
          ],
        );
        await Future<void>.delayed(Duration.zero);

        expect(binding.nodeCount, equals(2));
        expect(binding.edgeCount, equals(1));
        expect(binding.viewModel.nodeById('old'), isNull);
        expect(binding.viewModel.nodeById('new1'), isNotNull);
        expect(binding.positions.containsKey('new1'), isTrue);

        binding.dispose();
      },
    );

    test('supports manual updateNodePosition and relayout', () async {
      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: const [
          GraphNode<String>(id: 'm1', kind: 'node', label: 'M1', payload: 'm'),
        ],
      );

      final binding = GraphSourceBinding<String, String>(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      binding.updateNodePosition('m1', const Offset(777, 888));
      expect(binding.positions['m1'], equals(const Offset(777, 888)));
      expect(
        binding.viewModel.nodeById('m1')!.position,
        equals(const Offset(777, 888)),
      );

      binding.relayout();
      expect(binding.positions['m1'], isNot(equals(const Offset(777, 888))));

      binding.dispose();
    });

    test('dispose cleans up subscription and closes modelStream', () async {
      final fakeSource = FakeGraphSource<String, String>();
      final binding = GraphSourceBinding<String, String>(source: fakeSource);

      binding.dispose();
      expect(binding.isDisposed, isTrue);

      fakeSource.addNode(
        const GraphNode<String>(
          id: 'after',
          kind: 'n',
          label: 'A',
          payload: 'a',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(binding.nodeCount, equals(0));
    });
  });

  group('GraphViewModel', () {
    test('preserves identity semantics for distinct snapshot instances', () {
      final node1 = PrismGraphNode(
        id: 'n1',
        label: 'Node 1',
        type: 'service',
        position: const Offset(10, 20),
      );
      const edge1 = PrismGraphEdge(
        sourceId: 'n1',
        targetId: 'n2',
        label: 'depends_on',
        edgeType: 'depends_on',
      );

      final vm1 = GraphViewModel(
        nodes: [node1],
        edges: const [edge1],
        positions: const {'n1': Offset(10, 20)},
      );

      final vm2 = GraphViewModel(
        nodes: [node1],
        edges: const [edge1],
        positions: const {'n1': Offset(10, 20)},
      );

      // Identity semantics: identical instance equals itself
      expect(identical(vm1, vm1), isTrue);
      expect(vm1 == vm1, isTrue);

      // Distinct snapshot instances have distinct identities
      expect(identical(vm1, vm2), isFalse);

      // Empty instances
      const empty1 = GraphViewModel.empty();
      const empty2 = GraphViewModel.empty();
      expect(identical(empty1, empty2), isTrue);
      expect(empty1.isEmpty, isTrue);
      expect(empty1.nodeCount, equals(0));
      expect(empty1.edgeCount, equals(0));
      expect(vm1.isEmpty, isFalse);
      expect(vm1.nodeCount, equals(1));
      expect(vm1.edgeCount, equals(1));
    });

    test('exposes nodeById, edgeBetween, and positionOf lookup helpers', () {
      final node = PrismGraphNode(
        id: 'node-target',
        label: 'Target',
        type: 'service',
        position: const Offset(50, 60),
      );
      const edge = PrismGraphEdge(
        sourceId: 'node-target',
        targetId: 'node-sink',
        edgeType: 'output',
      );

      final vm = GraphViewModel(
        nodes: [node],
        edges: const [edge],
        positions: const {'node-target': Offset(50, 60)},
      );

      expect(vm.nodeById('node-target'), equals(node));
      expect(vm.nodeById('nonexistent'), isNull);

      expect(vm.edgeBetween('node-target', 'node-sink'), equals(edge));
      expect(vm.edgeBetween('node-target', 'other'), isNull);

      expect(vm.positionOf('node-target'), equals(const Offset(50, 60)));
      expect(vm.positionOf('other'), isNull);
    });
  });
}
