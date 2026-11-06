// Task 1844 hardening tests.
//
// Scope of this file:
//   * WP-003 — FrbNativeEventStream is native-fed at construction (no explicit
//              pipe call), and FrbLocalEventStream never touches native.
//   * WP-011 — execution failures are CommandExecutionError, NOT transport.
//   * WP-012 — close() cancels the retained native subscription (no leak).
//   * WP-016 — FrbHealthSource mutation methods (updateCell/setCells/setSnapshot).
//   * WP-017 — FrbGraphSource mutation methods return a FRESH snapshot.
//   * WP-018 — the native pipe honours backpressurePolicy.
//
// NEW FINDING discovered while writing WP-016 (REPORTED, NOT FIXED — outside
// this task's writeset, which limits rust changes to `api.rs` registry cleanup
// and limits `frb_health_source.dart` to tests):
//   Native `set_health_snapshot` discards the caller-declared aggregate state.
//   It rebuilds the snapshot via `CoreHealthSnapshot::new(timestamp, cells)`,
//   whose constructor always derives `aggregate_state` from the cells
//   (rust/warp_bridge_core/src/health.rs:59) and exposes no setter. The
//   `aggregate_state` field therefore crosses the FRB boundary and is dropped.
//   Consequence: `FrbHealthSource.setSnapshot` cannot persist an aggregate that
//   disagrees with the fold of its own cells.
//
// These tests run against the REAL native library (libwarp_bridge_frb.so), not
// a mock. The Rust substrate keeps process-global shared stores, so every test
// restores the state it observes before finishing to avoid leaking into sibling
// test files.

import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/src/rust/frb_generated.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Baseline health state the native substrate is seeded with.
const _seedCells = <HealthCell>[
  HealthCell(
    id: 'cell-lat',
    providerId: 'native-core',
    providerLabel: 'Native Core Substrate',
    dimensionId: 'latency',
    dimensionLabel: 'Latency',
    state: HealthState.healthy,
    latency: Duration(milliseconds: 1),
  ),
  HealthCell(
    id: 'cell-mem',
    providerId: 'native-core',
    providerLabel: 'Native Core Substrate',
    dimensionId: 'memory',
    dimensionLabel: 'Memory',
    state: HealthState.healthy,
  ),
];

void main() {
  setUpAll(() async {
    final current = Directory.current.path;
    final candidates = [
      '$current/../../rust/target/debug/libwarp_bridge_frb.so',
      '$current/../../rust/target/release/libwarp_bridge_frb.so',
      '$current/rust/target/debug/libwarp_bridge_frb.so',
      '$current/rust/target/release/libwarp_bridge_frb.so',
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
        'WP-008: could not locate libwarp_bridge_frb.so. Build it with '
        '`cd rust && cargo build -p warp_bridge_frb`. Probed: $candidates',
      );
    }

    await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
  });

  // =========================================================================
  // WP-003 — honest native vs local construction paths
  // =========================================================================
  group('WP-003: native vs local event stream construction', () {
    test('FrbNativeEventStream receives native events with no explicit pipe call', () async {
      // The core defect was that the default construction path never touched
      // native. Construction alone must now suffice.
      final stream = FrbNativeEventStream(
        nativeEventCount: 4,
        nativeEventPrefix: 'wp003',
      );
      final received = <String>[];

      final sub = stream.subscribe(onData: (e) => received.add(e.payload));

      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(received, equals(['wp003-1', 'wp003-2', 'wp003-3', 'wp003-4']));
      expect(stream.currentEvents.length, equals(4));

      await sub.cancel();
      await stream.close();
    });

    test('FrbLocalEventStream never touches native and only carries emitted events', () async {
      final stream = FrbLocalEventStream();
      final received = <String>[];

      final sub = stream.subscribe(onData: (e) => received.add(e.payload));

      // Even after a generous wait, no native event can appear.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(received, isEmpty);
      expect(stream.currentEvents, isEmpty);

      stream.emit(
        RuntimeEvent<String>(
          id: 'local-1',
          timestamp: DateTime.now(),
          payload: 'local-payload',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 15));

      expect(received, equals(['local-payload']));

      await sub.cancel();
      await stream.close();
    });
  });

  // =========================================================================
  // WP-012 — close() cancels the retained native subscription
  // =========================================================================
  group('WP-012: native subscription retention and cancellation', () {
    test('close() cancels the native subscription and stops native delivery', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: 20,
        nativeEventPrefix: 'wp012',
      );
      final received = <String>[];

      final sub = stream.subscribe(onData: (e) => received.add(e.payload));
      await Future<void>.delayed(const Duration(milliseconds: 25));

      // Subscription is retained by the instance (pre-fix it was never stored).
      expect(stream.hasActiveNativeSubscription, isTrue);
      expect(stream.nativeSubscriptionCancellations, equals(0));

      await stream.close();
      expect(stream.hasActiveNativeSubscription, isFalse);
      expect(stream.isClosed, isTrue);
      // The native subscription must have been genuinely cancelled, not merely
      // orphaned. This is the assertion that discriminates the WP-012 fix:
      // `isClosed` alone cannot tell the two apart, because a leaked native
      // producer's events are dropped by the `isClosed` guard either way.
      expect(
        stream.nativeSubscriptionCancellations,
        equals(1),
        reason: 'close() must actually cancel the retained native subscription',
      );

      final countAtClose = received.length;
      // Allow plenty of time for a leaked native producer to keep pushing.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(
        received.length,
        equals(countAtClose),
        reason: 'no native event may arrive after close()',
      );

      await sub.cancel();
    });

    test('close() is idempotent on a native stream', () async {
      final stream = FrbNativeEventStream(nativeEventCount: 2);
      await stream.close();
      await stream.close();
      expect(stream.isClosed, isTrue);
      expect(stream.hasActiveNativeSubscription, isFalse);
    });
  });

  // =========================================================================
  // WP-018 — the native pipe honours backpressurePolicy
  // =========================================================================
  group('WP-018: backpressure on the native pipe', () {
    test('dropOldest bounds the retained buffer for natively sourced events', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: 6,
        nativeEventPrefix: 'bp',
        backpressurePolicy: const EventStreamBackpressurePolicy.dropOldest(2),
      );

      await Future<void>.delayed(const Duration(milliseconds: 150));

      // All 6 native events were produced, but the policy bounds retention to 2.
      expect(stream.currentEvents.length, equals(2));
      expect(
        stream.currentEvents.map((e) => e.payload),
        equals(['bp-5', 'bp-6']),
        reason: 'dropOldest must retain the newest native events',
      );

      await stream.close();
    });

    test('dropNewest drops natively sourced events beyond capacity', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: 5,
        nativeEventPrefix: 'bn',
        backpressurePolicy: const EventStreamBackpressurePolicy.dropNewest(3),
      );

      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(stream.currentEvents.length, equals(3));
      expect(
        stream.currentEvents.map((e) => e.payload),
        equals(['bn-1', 'bn-2', 'bn-3']),
        reason: 'dropNewest must retain the first native events',
      );

      await stream.close();
    });
  });

  // =========================================================================
  // WP-011 — execution vs transport error taxonomy
  // =========================================================================
  group('WP-011: execution vs transport error separation', () {
    test('a rejected native command is an EXECUTION error, not a transport error', () async {
      final cmd = FrbAsyncCommand(commandType: 'fail');
      final result = await cmd.execute('wp011-execution');

      expect(result, isA<CommandFailure<String>>());
      final failure = result as CommandFailure<String>;

      expect(failure.error, isA<CommandExecutionError>());
      expect(
        failure.error,
        isNot(isA<CommandTransportError>()),
        reason: 'a domain rejection must not be reported as a transport failure',
      );
      expect(failure.error.message, contains('wp011-execution'));
      expect(cmd.status, equals(AsyncCommandStatus.failed));

      await cmd.close();
    });

    test('validation rejection is distinct from transport and from success', () async {
      final cmd = FrbAsyncCommand(commandType: 'validate');
      final result = await cmd.execute('');

      expect(result, isA<CommandFailure<String>>());
      final failure = result as CommandFailure<String>;
      expect(failure.error, isA<CommandExecutionError>());
      expect(failure.error, isNot(isA<CommandTransportError>()));

      await cmd.close();
    });

    test('CommandTransportError is a distinct sealed subtype usable for discrimination', () {
      // Not a vacuous assertion: proves consumers can branch on the type rather
      // than on message text, which is the contract WP-011 requires.
      const transport = CommandTransportError(message: 'bridge down');
      const execution = CommandExecutionError(message: 'rejected');

      expect(transport, isA<CommandError>());
      expect(transport, isNot(isA<CommandExecutionError>()));
      expect(execution, isNot(isA<CommandTransportError>()));
      expect(transport, isNot(equals(execution)));
    });
  });

  // =========================================================================
  // WP-016 — FrbHealthSource mutation methods
  // =========================================================================
  group('WP-016: FrbHealthSource mutation methods', () {
    test('updateCell mutates native state and is visible in getSnapshot', () async {
      final source = FrbHealthSource();

      const degraded = HealthCell(
        id: 'cell-lat',
        providerId: 'native-core',
        providerLabel: 'Native Core Substrate',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.degraded,
        latency: Duration(milliseconds: 777),
      );

      await source.updateCell(degraded);

      final snapshot = await source.getSnapshot();
      expect(snapshot.getCell('cell-lat')?.state, equals(HealthState.degraded));
      expect(
        snapshot.getCell('cell-lat')?.latency,
        equals(const Duration(milliseconds: 777)),
      );
      expect(
        snapshot.aggregateState,
        equals(HealthState.degraded),
        reason: 'native aggregate must fold the degraded cell',
      );

      // restore
      await source.updateCell(_seedCells[0]);
      await source.close();
    });

    test('updateCell adds a previously unknown cell id', () async {
      final source = FrbHealthSource();
      final before = await source.getSnapshot();
      final beforeLen = before.cells.length;

      const fresh = HealthCell(
        id: 'cell-wp016-new',
        providerId: 'prov-wp016',
        providerLabel: 'WP016 Provider',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.unreachable,
      );

      await source.updateCell(fresh);

      final after = await source.getSnapshot();
      expect(after.cells.length, equals(beforeLen + 1));
      expect(after.getCell('cell-wp016-new')?.state, equals(HealthState.unreachable));
      expect(after.aggregateState, equals(HealthState.unreachable));

      // restore the seed set exactly
      await source.setCells(_seedCells);
      await source.close();
    });

    test('setCells replaces the whole native cell set', () async {
      final source = FrbHealthSource();

      const replacement = <HealthCell>[
        HealthCell(
          id: 'cell-wp016-only',
          providerId: 'prov-wp016',
          providerLabel: 'WP016 Provider',
          dimensionId: 'conn',
          dimensionLabel: 'Connection',
          state: HealthState.degraded,
        ),
      ];

      await source.setCells(replacement);

      final after = await source.getSnapshot();
      expect(after.cells.length, equals(1));
      expect(after.getCell('cell-wp016-only'), isNotNull);
      expect(after.getCell('cell-lat'), isNull);
      expect(after.aggregateState, equals(HealthState.degraded));

      // restore
      await source.setCells(_seedCells);
      await source.close();
    });

    test('setSnapshot round-trips cells, timestamp and TTL; aggregate is DERIVED', () async {
      final source = FrbHealthSource();

      // Deliberately declares `degraded` while every cell is healthy.
      final snapshot = HealthSnapshot(
        timestamp: DateTime(2026, 9, 29, 12, 0),
        cells: _seedCells,
        aggregateState: HealthState.degraded,
        freshnessTtl: const Duration(seconds: 42),
      );

      await source.setSnapshot(snapshot);

      final after = await source.getSnapshot();

      // Cells, timestamp and TTL round-trip correctly.
      expect(after.cells.length, equals(2));
      expect(after.getCell('cell-lat')?.id, equals('cell-lat'));
      expect(after.getCell('cell-mem')?.id, equals('cell-mem'));
      expect(
        after.timestamp,
        equals(DateTime(2026, 9, 29, 12, 0)),
        reason: 'timestamp must round-trip through the native store',
      );
      expect(after.freshnessTtl, equals(const Duration(seconds: 42)));

      // NEW FINDING (not in Task 1844's finding list, NOT fixed here — out of
      // writeset): the declared `aggregateState` does NOT survive. Native
      // `set_health_snapshot` rebuilds the snapshot with
      // `CoreHealthSnapshot::new(timestamp, cells)`, and that constructor always
      // computes `aggregate_state = derive_aggregate_state(&cells)`
      // (rust/warp_bridge_core/src/health.rs:59) with no setter. So the
      // `aggregate_state` field crossing the FRB boundary is silently discarded
      // and the aggregate is always the fold of the supplied cells.
      //
      // This assertion therefore pins the REAL observed behaviour, so the
      // divergence is visible and will start failing loudly if the native side
      // is ever corrected to honour the declared aggregate.
      expect(
        after.aggregateState,
        equals(HealthState.healthy),
        reason:
            'native recomputes aggregate from cells and ignores the declared '
            'aggregateState; see NEW FINDING in this file header',
      );

      // restore a neutral baseline for sibling tests
      await source.setSnapshot(
        HealthSnapshot(
          timestamp: DateTime(2026, 9, 29, 12, 0),
          cells: _seedCells,
          aggregateState: HealthState.healthy,
          freshnessTtl: const Duration(seconds: 5),
        ),
      );
      await source.close();
    });

    test('mutation methods reject use after close', () async {
      final source = FrbHealthSource();
      await source.close();

      expect(
        () => source.updateCell(_seedCells[0]),
        throwsA(isA<StateError>()),
      );
      expect(
        () => source.setCells(const []),
        throwsA(isA<StateError>()),
      );
    });
  });

  // =========================================================================
  // WP-017 — FrbGraphSource mutations must return a FRESH snapshot
  // =========================================================================
  group('WP-017: FrbGraphSource mutations return a fresh snapshot', () {
    test('addNode is visible in the immediately following getSnapshot', () async {
      final source = FrbGraphSource();
      await source.setGraph(nodes: const [], edges: const []);

      final empty = await source.getSnapshot();
      expect(empty.nodes, isEmpty);

      const node = GraphNode<String>(
        id: 'n-fresh-1',
        kind: 'test.node',
        label: 'Fresh One',
        payload: '{}',
      );

      await source.addNode(node);

      // A stale cache would still report zero nodes here.
      final afterAdd = await source.getSnapshot();
      expect(afterAdd.nodes.length, equals(1));
      expect(afterAdd.getNode('n-fresh-1')?.label, equals('Fresh One'));

      await source.removeNode('n-fresh-1');

      // A stale cache would still report the node here.
      final afterRemove = await source.getSnapshot();
      expect(afterRemove.getNode('n-fresh-1'), isNull);
      expect(afterRemove.nodes, isEmpty);

      await source.close();
    });

    test('updateNode refreshes the retained snapshot', () async {
      final source = FrbGraphSource();
      await source.setGraph(nodes: const [], edges: const []);

      const before = GraphNode<String>(
        id: 'n-fresh-2',
        kind: 'test.node',
        label: 'Before',
        payload: '{}',
      );
      await source.addNode(before);
      expect((await source.getSnapshot()).getNode('n-fresh-2')?.label, equals('Before'));

      const after = GraphNode<String>(
        id: 'n-fresh-2',
        kind: 'test.node',
        label: 'After',
        payload: '{}',
      );
      await source.updateNode(after);

      final snapshot = await source.getSnapshot();
      expect(snapshot.getNode('n-fresh-2')?.label, equals('After'));
      expect(snapshot.nodes.length, equals(1), reason: 'update must not duplicate');

      await source.setGraph(nodes: const [], edges: const []);
      await source.close();
    });

    test('edge mutations return a fresh snapshot', () async {
      final source = FrbGraphSource();
      await source.setGraph(
        nodes: const [
          GraphNode<String>(
            id: 'n-a',
            kind: 'test.node',
            label: 'A',
            payload: '{}',
          ),
          GraphNode<String>(
            id: 'n-b',
            kind: 'test.node',
            label: 'B',
            payload: '{}',
          ),
        ],
        edges: const [],
      );

      const edge = GraphEdge<String>(
        id: 'e-fresh-1',
        kind: 'test.edge',
        fromNodeId: 'n-a',
        toNodeId: 'n-b',
        payload: '{}',
      );

      await source.addEdge(edge);
      final afterAdd = await source.getSnapshot();
      expect(afterAdd.edges.length, equals(1));
      expect(afterAdd.outgoingEdges('n-a').map((e) => e.id), equals(['e-fresh-1']));

      const updatedEdge = GraphEdge<String>(
        id: 'e-fresh-1',
        kind: 'test.edge.updated',
        fromNodeId: 'n-a',
        toNodeId: 'n-b',
        payload: '{}',
      );
      await source.updateEdge(updatedEdge);
      final afterUpdate = await source.getSnapshot();
      expect(afterUpdate.getEdge('e-fresh-1')?.kind, equals('test.edge.updated'));
      expect(afterUpdate.edges.length, equals(1));

      await source.removeEdge('e-fresh-1');
      final afterRemove = await source.getSnapshot();
      expect(afterRemove.edges, isEmpty);
      expect(afterRemove.getEdge('e-fresh-1'), isNull);

      await source.setGraph(nodes: const [], edges: const []);
      await source.close();
    });

    test('watchUpdates invalidates the cache so getSnapshot is never stale', () async {
      final source = FrbGraphSource(maxEvents: 1);
      await source.setGraph(nodes: const [], edges: const []);

      final updates = <GraphUpdate<String, String>>[];
      final sub = source.watchUpdates().listen(updates.add);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      const node = GraphNode<String>(
        id: 'n-invalidate',
        kind: 'test.node',
        label: 'Invalidate',
        payload: '{}',
      );
      await source.addNode(node);

      // Drain the native broadcast.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(updates.whereType<NodeAdded<String, String>>().isNotEmpty, isTrue);

      // Whether or not the broadcast invalidated the cache, the snapshot must
      // reflect the mutation: no stale read is observable.
      final snapshot = await source.getSnapshot();
      expect(snapshot.getNode('n-invalidate'), isNotNull);

      await sub.cancel();
      await source.setGraph(nodes: const [], edges: const []);
      await source.close();
    });
  });
}
