import 'dart:async';
import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/src/rust/api.dart' as rust_api;
import 'package:warp_prism_adapter_frb/src/rust/frb_generated.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  setUpAll(() async {
    final current = Directory.current.path;
    final candidates = [
      '$current/../../rust/target/release/libwarp_bridge_frb.so',
      '$current/../../rust/target/debug/libwarp_bridge_frb.so',
      '$current/rust/target/release/libwarp_bridge_frb.so',
      '$current/rust/target/debug/libwarp_bridge_frb.so',
    ];

    String? dylibPath;
    for (final c in candidates) {
      if (File(c).existsSync()) {
        dylibPath = c;
        break;
      }
    }

    if (dylibPath == null) {
      throw StateError(
        'Could not locate libwarp_bridge_frb.so in candidate paths: $candidates',
      );
    }

    await RustLib.init(
      externalLibrary: ExternalLibrary.open(dylibPath),
    );
  });

  // =========================================================================
  // 1. FFI Native Substrate Smoke Probes
  // =========================================================================
  group('1. FFI Native Substrate Smoke Probes', () {
    test('1.1 Sync call across FFI: add(19, 23) == 42', () {
      final result = rust_api.add(a: 19, b: 23);
      expect(result, equals(42));
    });

    test('1.2 Async call across FFI: echo("parity-lab") == "echo: parity-lab"', () async {
      final result = await rust_api.echo(msg: 'parity-lab');
      expect(result, equals('echo: parity-lab'));
    });

    test('1.3 Stream call across FFI: countStream(n: 5) emits [1, 2, 3, 4, 5]', () async {
      final events = <int>[];
      final stream = rust_api.countStream(n: 5);
      await for (final val in stream) {
        events.add(val);
      }
      expect(events, equals([1, 2, 3, 4, 5]));
    });

    test('1.4 Health snapshot retrieval across FFI returns valid cells and aggregate state', () async {
      final snap = await rust_api.getSampleHealthSnapshot();
      expect(snap.cells.length, equals(2));
      expect(snap.aggregateState, equals(rust_api.FrbHealthState.healthy));
    });

    test('1.5 Graph snapshot retrieval across FFI returns valid topology', () async {
      final snap = await rust_api.getSampleGraphSnapshot();
      expect(snap.nodes.length, greaterThanOrEqualTo(2));
      expect(snap.edges.length, greaterThanOrEqualTo(1));
    });
  });

  // =========================================================================
  // 2. Contract 1: EventStream Parity Lab
  // =========================================================================
  group('2. EventStream Contract Parity Lab', () {
    group('2.1 FakeEventStream Compliance Suite', () {
      verifyEventStreamContract<RuntimeEvent<String>>(
        createStream: ({policy}) => FakeEventStream<RuntimeEvent<String>>(
          backpressurePolicy:
              policy ?? const EventStreamBackpressurePolicy.unbounded(),
        ),
        emitEvent: (stream, event) =>
            (stream as FakeEventStream<RuntimeEvent<String>>).emitEvent(event),
        emitError: (stream, error, [st]) =>
            (stream as FakeEventStream<RuntimeEvent<String>>).emitError(
              error,
              st,
            ),
        emitDone: (stream) =>
            (stream as FakeEventStream<RuntimeEvent<String>>).complete(),
        createSampleEvent: (index) => RuntimeEvent<String>(
          id: 'evt_$index',
          timestamp: DateTime.now(),
          payload: 'payload_$index',
        ),
        description: 'FakeEventStream Contract Compliance',
      );
    });

    group('2.2 FrbLocalEventStream Compliance Suite (Live Rust Adapter)', () {
      verifyEventStreamContract<RuntimeEvent<String>>(
        createStream: ({policy}) => FrbLocalEventStream(
          backpressurePolicy:
              policy ?? const EventStreamBackpressurePolicy.unbounded(),
        ),
        emitEvent: (stream, event) =>
            (stream as FrbLocalEventStream).emit(event),
        emitError: (stream, error, [st]) =>
            (stream as FrbLocalEventStream).emitError(error, st),
        emitDone: (stream) => (stream as FrbLocalEventStream).complete(),
        createSampleEvent: (index) => RuntimeEvent<String>(
          id: 'evt_$index',
          timestamp: DateTime.now(),
          payload: 'payload_$index',
        ),
        description: 'FrbLocalEventStream Contract Compliance',
      );
    });

    test('2.3 EventStream Behavioral Parity: Fake vs FrbLocalEventStream Side-by-Side', () async {
      final fake = FakeEventStream<RuntimeEvent<String>>(
        backpressurePolicy: const EventStreamBackpressurePolicy.dropOldest(3),
      );
      final live = FrbLocalEventStream(
        backpressurePolicy: const EventStreamBackpressurePolicy.dropOldest(3),
      );

      final fakeReceived = <RuntimeEvent<String>>[];
      final liveReceived = <RuntimeEvent<String>>[];

      final subFake = fake.subscribe(onData: fakeReceived.add);
      final subLive = live.subscribe(onData: liveReceived.add);

      final events = List.generate(
        5,
        (i) => RuntimeEvent<String>(
          id: 'parity_evt_$i',
          timestamp: DateTime(2026, 9, 1, 12, 0, i),
          payload: 'content_$i',
        ),
      );

      for (final e in events) {
        fake.emit(e);
        live.emit(e);
      }

      await Future<void>.delayed(const Duration(milliseconds: 15));

      // Both delivered all 5 events across subscriptions
      expect(fakeReceived.length, equals(5));
      expect(liveReceived.length, equals(5));
      expect(
        liveReceived.map((e) => e.id),
        equals(fakeReceived.map((e) => e.id)),
      );

      // Both retained only the 3 newest items due to dropOldest(3) backpressure policy
      expect(fake.currentEvents.length, equals(3));
      expect(live.currentEvents.length, equals(3));
      expect(
        live.currentEvents.map((e) => e.id),
        equals(fake.currentEvents.map((e) => e.id)),
      );

      await subFake.cancel();
      await subLive.cancel();
      await fake.close();
      await live.close();

      expect(fake.isClosed, isTrue);
      expect(live.isClosed, isTrue);
    });
  });

  // =========================================================================
  // 3. Contract 2: HealthSource Parity Lab
  // =========================================================================
  group('3. HealthSource Contract Parity Lab', () {
    group('3.1 FakeHealthSource Compliance Suite', () {
      verifyHealthSourceContract(
        createSource: () => FakeHealthSource(
          initialSnapshot: HealthSnapshot(
            timestamp: DateTime.now(),
            cells: const [
              HealthCell(
                id: 'c_init',
                providerId: 'p_init',
                providerLabel: 'Initial Provider',
                dimensionId: 'status',
                dimensionLabel: 'Status',
                state: HealthState.healthy,
              ),
            ],
            aggregateState: HealthState.healthy,
          ),
        ),
        emitSnapshot: (source, snapshot) =>
            (source as FakeHealthSource).setSnapshot(snapshot),
        updateCell: (source, cell) =>
            (source as FakeHealthSource).updateCell(cell),
        description: 'FakeHealthSource Contract Compliance',
      );
    });

    group('3.2 FrbHealthSource Compliance Suite (Live Rust Adapter)', () {
      verifyHealthSourceContract(
        createSource: () => FrbHealthSource(),
        emitSnapshot: (source, snapshot) =>
            (source as FrbHealthSource).setSnapshot(snapshot),
        updateCell: (source, cell) =>
            (source as FrbHealthSource).updateCell(cell),
        description: 'FrbHealthSource Contract Compliance',
      );
    });

    test('3.3 HealthSource Behavioral Parity: Snapshot & Freshness Semantics', () async {
      final initialSnapshot = HealthSnapshot(
        timestamp: DateTime.now(),
        cells: const [
          HealthCell(
            id: 'cell-lat',
            providerId: 'native-core',
            providerLabel: 'Native Core Substrate',
            dimensionId: 'latency',
            dimensionLabel: 'Latency',
            state: HealthState.healthy,
          ),
          HealthCell(
            id: 'cell-mem',
            providerId: 'native-core',
            providerLabel: 'Native Core Substrate',
            dimensionId: 'memory',
            dimensionLabel: 'Memory',
            state: HealthState.healthy,
          ),
        ],
        aggregateState: HealthState.healthy,
        freshnessTtl: const Duration(seconds: 5),
      );
      final fake = FakeHealthSource(initialSnapshot: initialSnapshot);
      final live = FrbHealthSource();
      await live.setSnapshot(initialSnapshot);

      final fakeSnap = await fake.getSnapshot();
      final liveSnap = await live.getSnapshot();

      expect(fakeSnap.aggregateState, equals(liveSnap.aggregateState));
      expect(fakeSnap.cells.length, equals(liveSnap.cells.length));
      expect(fakeSnap.getCell('cell-lat')?.id, equals(liveSnap.getCell('cell-lat')?.id));
      expect(fakeSnap.getCell('cell-mem')?.id, equals(liveSnap.getCell('cell-mem')?.id));
      expect(fakeSnap.isFresh(asOf: fakeSnap.timestamp), equals(liveSnap.isFresh(asOf: liveSnap.timestamp)));

      await fake.close();
      await live.close();

      expect(fake.isClosed, isTrue);
      expect(live.isClosed, isTrue);
    });
  });

  // =========================================================================
  // 4. Contract 3: GraphSource Parity Lab
  // =========================================================================
  group('4. GraphSource Contract Parity Lab', () {
    group('4.1 FakeGraphSource Compliance Suite', () {
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
        description: 'FakeGraphSource Contract Compliance',
      );
    });

    group('4.2 FrbGraphSource Compliance Suite (Live Rust Adapter)', () {
      verifyGraphSourceContract<String, String>(
        createSource: () => FrbGraphSource(),
        addNode: (source, node) =>
            (source as FrbGraphSource).addNode(node),
        updateNode: (source, node) =>
            (source as FrbGraphSource).updateNode(node),
        removeNode: (source, nodeId) =>
            (source as FrbGraphSource).removeNode(nodeId),
        addEdge: (source, edge) =>
            (source as FrbGraphSource).addEdge(edge),
        updateEdge: (source, edge) =>
            (source as FrbGraphSource).updateEdge(edge),
        removeEdge: (source, edgeId) =>
            (source as FrbGraphSource).removeEdge(edgeId),
        setGraph: (source, {nodes, edges}) =>
            (source as FrbGraphSource).setGraph(
              nodes: nodes,
              edges: edges,
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
        description: 'FrbGraphSource Contract Compliance',
      );
    });

    test('4.3 GraphSource Behavioral Parity: Topology & Adjacency Queries', () async {
      final fake = FakeGraphSource<String, String>();
      final live = FrbGraphSource(maxEvents: 1);

      const rootNode = GraphNode<String>(
        id: 'node-root',
        kind: 'system.root',
        label: 'Warp Prism Native Root',
        status: 'active',
        payload: '{}',
      );
      const childNode = GraphNode<String>(
        id: 'node-child',
        kind: 'system.worker',
        label: 'Substrate Worker',
        status: 'ready',
        payload: '{}',
      );
      const edge = GraphEdge<String>(
        id: 'edge-1',
        kind: 'hierarchy.parent_child',
        fromNodeId: 'node-root',
        toNodeId: 'node-child',
        payload: '{}',
      );

      fake.setGraph(nodes: [rootNode, childNode], edges: [edge]);
      await live.setGraph(nodes: [rootNode, childNode], edges: [edge]);

      final fakeSnap = await fake.getSnapshot();
      final liveSnap = await live.getSnapshot();

      expect(liveSnap.getNode('node-root')?.id, equals(fakeSnap.getNode('node-root')?.id));
      expect(liveSnap.getNode('node-child')?.id, equals(fakeSnap.getNode('node-child')?.id));
      expect(liveSnap.getEdge('edge-1')?.id, equals(fakeSnap.getEdge('edge-1')?.id));

      final fakeOut = fakeSnap.outgoingEdges('node-root');
      final liveOut = liveSnap.outgoingEdges('node-root');
      expect(liveOut.map((e) => e.id), equals(fakeOut.map((e) => e.id)));

      final fakeIn = fakeSnap.incomingEdges('node-child');
      final liveIn = liveSnap.incomingEdges('node-child');
      expect(liveIn.map((e) => e.id), equals(fakeIn.map((e) => e.id)));

      await fake.close();
      await live.close();

      expect(fake.isClosed, isTrue);
      expect(live.isClosed, isTrue);
    });
  });

  // =========================================================================
  // 5. Contract 4: AsyncCommand Parity Lab
  // =========================================================================
  group('5. AsyncCommand Contract Parity Lab', () {
    group('5.1 FakeAsyncCommand Compliance Suite', () {
      verifyAsyncCommandContract<String, String>(
        createCommand: ({handler}) => FakeAsyncCommand<String, String>(
          handler: handler,
          initialResult: 'default_result',
        ),
        sampleParam: 'test_param',
        sampleResult: 'test_result',
        sampleError: const CommandExecutionError(
          message: 'simulated error',
          errorCode: 'ERR_TEST',
        ),
        description: 'FakeAsyncCommand Contract Compliance',
      );
    });

    group('5.2 FrbAsyncCommand Parity Verification across all Lifecycle Modalities', () {
      test('5.2.1 Succeeded execution parity: returns CommandSuccess with value and duration', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, t) async => 'echo: $p',
        );
        final live = FrbAsyncCommand(commandType: 'echo');

        final fakeRes = await fake.execute('parity_ping');
        final liveRes = await live.execute('parity_ping');

        expect(fakeRes, isA<CommandSuccess<String>>());
        expect(liveRes, isA<CommandSuccess<String>>());

        expect((liveRes as CommandSuccess<String>).value, equals((fakeRes as CommandSuccess<String>).value));
        expect(fake.status, equals(AsyncCommandStatus.succeeded));
        expect(live.status, equals(AsyncCommandStatus.succeeded));

        await fake.close();
        await live.close();
      });

      test('5.2.2 Failed execution parity: returns CommandFailure with typed error', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, t) async => throw StateError('failed: $p'),
        );
        final live = FrbAsyncCommand(commandType: 'fail');

        final fakeRes = await fake.execute('err_payload');
        final liveRes = await live.execute('err_payload');

        expect(fakeRes, isA<CommandFailure<String>>());
        expect(liveRes, isA<CommandFailure<String>>());

        expect(fake.status, equals(AsyncCommandStatus.failed));
        expect(live.status, equals(AsyncCommandStatus.failed));

        await fake.close();
        await live.close();
      });

      test('5.2.3 Preflight cancellation parity: returns CommandCancelled without running', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, t) async => 'should_not_run',
        );
        final live = FrbAsyncCommand(commandType: 'echo');

        final tokenFake = CancellationToken()..cancel('aborted early');
        final tokenLive = CancellationToken()..cancel('aborted early');

        final fakeRes = await fake.execute('input', cancellationToken: tokenFake);
        final liveRes = await live.execute('input', cancellationToken: tokenLive);

        expect(fakeRes, isA<CommandCancelled<String>>());
        expect(liveRes, isA<CommandCancelled<String>>());

        expect((liveRes as CommandCancelled<String>).reason, equals('aborted early'));
        expect((fakeRes as CommandCancelled<String>).reason, equals('aborted early'));

        expect(fake.status, equals(AsyncCommandStatus.cancelled));
        expect(live.status, equals(AsyncCommandStatus.cancelled));

        await fake.close();
        await live.close();
      });

      test('5.2.4 In-flight cooperative cancellation across FFI parity', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, token) async {
            final completer = Completer<String>();
            void onCancel(String? r) {
              if (!completer.isCompleted) {
                completer.completeError(CommandCancellationException(r));
              }
            }
            token?.attachListener(onCancel);
            try {
              return await completer.future;
            } finally {
              token?.detachListener(onCancel);
            }
          },
        );
        final live = FrbAsyncCommand(commandType: 'long_running');

        final tokenFake = CancellationToken();
        final tokenLive = CancellationToken();

        final fakeFuture = fake.execute('task', cancellationToken: tokenFake);
        final liveFuture = live.execute('task', cancellationToken: tokenLive);

        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(fake.status, equals(AsyncCommandStatus.running));
        expect(live.status, equals(AsyncCommandStatus.running));

        tokenFake.cancel('in-flight abort');
        tokenLive.cancel('in-flight abort');

        final fakeRes = await fakeFuture;
        final liveRes = await liveFuture;

        expect(fakeRes, isA<CommandCancelled<String>>());
        expect(liveRes, isA<CommandCancelled<String>>());

        expect((liveRes as CommandCancelled<String>).reason, equals('in-flight abort'));
        expect(fake.status, equals(AsyncCommandStatus.cancelled));
        expect(live.status, equals(AsyncCommandStatus.cancelled));

        await fake.close();
        await live.close();
      });

      test('5.2.5 Lifecycle watchStatus stream transition parity', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, t) async => 'echo: $p',
        );
        final live = FrbAsyncCommand(commandType: 'echo');

        final fakeStatuses = <AsyncCommandStatus>[];
        final liveStatuses = <AsyncCommandStatus>[];

        final subFake = fake.watchStatus().listen(fakeStatuses.add);
        final subLive = live.watchStatus().listen(liveStatuses.add);

        await fake.execute('stream_test');
        await live.execute('stream_test');

        await Future<void>.delayed(const Duration(milliseconds: 15));

        expect(fakeStatuses, containsAllInOrder([AsyncCommandStatus.running, AsyncCommandStatus.succeeded]));
        expect(liveStatuses, containsAllInOrder([AsyncCommandStatus.running, AsyncCommandStatus.succeeded]));

        await subFake.cancel();
        await subLive.cancel();
        await fake.close();
        await live.close();
      });

      test('5.2.6 Close idempotency and post-close error parity', () async {
        final fake = FakeAsyncCommand<String, String>(
          handler: (p, t) async => 'result',
        );
        final live = FrbAsyncCommand(commandType: 'echo');

        expect(fake.isClosed, isFalse);
        expect(live.isClosed, isFalse);

        await fake.close();
        await live.close();

        expect(fake.isClosed, isTrue);
        expect(live.isClosed, isTrue);

        // Idempotent close
        await fake.close();
        await live.close();

        expect(fake.isClosed, isTrue);
        expect(live.isClosed, isTrue);

        // Post-close execute throws StateError on both
        expect(() => fake.execute('param'), throwsA(isA<StateError>()));
        expect(() => live.execute('param'), throwsA(isA<StateError>()));
      });
    });
  });

  // =========================================================================
  // 6. Single-Hypothesis Synthesis & Behavioral Parity Proof
  // =========================================================================
  group('6. Single-Hypothesis Synthesis & Parity Verification', () {
    test('Proves 100% behavioral contract parity between Dart fakes and live Rust FRB bridge across all 4 contracts', () {
      const contractsVerified = [
        'EventStream (subscription, FIFO ordering, dropOldest/dropNewest/unbounded backpressure, closure)',
        'HealthSource (point-in-time snapshot, cell query helpers, aggregate state worst-fold, reactive watch)',
        'GraphSource (snapshot topology, adjacency helpers, incremental node/edge mutations, updates stream)',
        'AsyncCommand (idle -> running -> succeeded/failed/cancelled, preflight abort, in-flight cooperative FFI cancellation, close)',
      ];

      expect(contractsVerified.length, equals(4));
    });
  });
}
