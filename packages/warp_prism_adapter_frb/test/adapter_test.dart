import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/src/rust/api.dart' as rust_api;
import 'package:warp_prism_adapter_frb/src/rust/frb_generated.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

void main() {
  setUpAll(() async {
    // Locate the compiled cdylib
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

  group('FRB Substrate FFI Smoke', () {
    test('1. Sync call: add(19, 23) == 42', () {
      final result = rust_api.add(a: 19, b: 23);
      expect(result, equals(42));
    });

    test('2. Async call: echo("warp-prism") == "echo: warp-prism"', () async {
      final result = await rust_api.echo(msg: 'warp-prism');
      expect(result, equals('echo: warp-prism'));
    });

    test('3. Stream call: countStream(n: 5) emits [1, 2, 3, 4, 5]', () async {
      final events = <int>[];
      final stream = rust_api.countStream(n: 5);
      await for (final val in stream) {
        events.add(val);
      }
      expect(events, equals([1, 2, 3, 4, 5]));
    });
  });

  group('FrbAsyncCommand Contract Adapter', () {
    test('executes echo command successfully', () async {
      final cmd = FrbAsyncCommand(commandType: 'echo');
      final result = await cmd.execute('ping');

      expect(result, isA<CommandSuccess<String>>());
      final success = result as CommandSuccess<String>;
      expect(success.value, equals('echo: ping'));
      expect(cmd.status, equals(AsyncCommandStatus.succeeded));
      await cmd.close();
    });

    test('handles failure execution', () async {
      final cmd = FrbAsyncCommand(commandType: 'fail');
      final result = await cmd.execute('error payload');

      expect(result, isA<CommandFailure<String>>());
      final failure = result as CommandFailure<String>;
      expect(failure.error.message, contains('error payload'));
      expect(cmd.status, equals(AsyncCommandStatus.failed));
      await cmd.close();
    });

    test('handles preflight cancellation', () async {
      final cmd = FrbAsyncCommand(commandType: 'echo');
      final token = CancellationToken()..cancel('aborted before flight');

      final result = await cmd.execute('ping', cancellationToken: token);
      expect(result, isA<CommandCancelled<String>>());
      final cancelled = result as CommandCancelled<String>;
      expect(cancelled.reason, equals('aborted before flight'));
      expect(cmd.status, equals(AsyncCommandStatus.cancelled));
      await cmd.close();
    });

    test('handles in-flight cooperative cancellation across FFI', () async {
      final cmd = FrbAsyncCommand(commandType: 'long_running');
      final token = CancellationToken();

      final future = cmd.execute('long task payload', cancellationToken: token);

      // Brief delay to ensure command has entered running state in Rust substrate
      await Future.delayed(const Duration(milliseconds: 30));
      expect(cmd.status, equals(AsyncCommandStatus.running));

      // Cancel in-flight
      token.cancel('aborted mid-flight');

      final result = await future;
      expect(result, isA<CommandCancelled<String>>());
      final cancelled = result as CommandCancelled<String>;
      expect(cancelled.reason, equals('aborted mid-flight'));
      expect(cmd.status, equals(AsyncCommandStatus.cancelled));
      await cmd.close();
    });
  });

  group('FrbEventStream Contract Adapter', () {
    test('emits, buffers, and subscribes events', () async {
      final eventStream = FrbLocalEventStream();
      final received = <RuntimeEvent<String>>[];

      final sub = eventStream.subscribe(
        onData: (event) {
          received.add(event);
        },
      );

      final evt = RuntimeEvent<String>(
        id: 'evt-1',
        timestamp: DateTime.now(),
        payload: 'test payload',
        severity: EventSeverity.info,
      );

      eventStream.emit(evt);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(eventStream.currentEvents.length, equals(1));
      expect(received.length, equals(1));
      expect(received.first.id, equals('evt-1'));

      await sub.cancel();
      await eventStream.close();
    });

    test('FrbNativeEventStream is fed by the native substrate at construction', () async {
      // WP-003: the native variant wires the FRB source in its constructor, so
      // no explicit pipe call is required to receive native events.
      final eventStream = FrbNativeEventStream(
        nativeEventCount: 3,
        nativeEventPrefix: 'pipe-evt',
      );
      final received = <RuntimeEvent<String>>[];

      final sub = eventStream.subscribe(
        onData: (event) {
          received.add(event);
        },
      );

      // Wait for 3 events
      await Future.delayed(const Duration(milliseconds: 80));

      expect(received.length, equals(3));
      expect(received[0].payload, equals('pipe-evt-1'));
      expect(received[1].payload, equals('pipe-evt-2'));
      expect(received[2].payload, equals('pipe-evt-3'));

      await sub.cancel();
      await eventStream.close();
    });
  });

  group('FrbHealthSource Contract Adapter', () {
    test('retrieves sample health snapshot from native substrate', () async {
      final healthSource = FrbHealthSource();
      final snapshot = await healthSource.getSnapshot();

      expect(snapshot.cells.length, equals(2));
      expect(snapshot.aggregateState, equals(HealthState.healthy));
      expect(snapshot.getCell('cell-lat'), isNotNull);
      expect(snapshot.getCell('cell-mem'), isNotNull);

      await healthSource.close();
    });

    test('watches native health transitions stream', () async {
      final healthSource = FrbHealthSource();
      final snapshots = <HealthSnapshot>[];

      final stream = healthSource.watch();
      final sub = stream.listen(snapshots.add);

      await Future.delayed(const Duration(milliseconds: 20));

      const cellDegraded = HealthCell(
        id: 'cell-lat',
        providerId: 'native-core',
        providerLabel: 'Native Core Substrate',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.degraded,
        latency: Duration(milliseconds: 250),
      );
      await healthSource.updateCell(cellDegraded);

      const cellHealthy = HealthCell(
        id: 'cell-lat',
        providerId: 'native-core',
        providerLabel: 'Native Core Substrate',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.healthy,
        latency: Duration(milliseconds: 1),
      );
      await healthSource.updateCell(cellHealthy);

      // Wait for native Rust broadcast to reach Dart StreamSink
      await Future.delayed(const Duration(milliseconds: 50));

      expect(snapshots.length, greaterThanOrEqualTo(2));
      expect(snapshots[0].aggregateState, equals(HealthState.degraded));
      expect(snapshots[1].aggregateState, equals(HealthState.healthy));

      await sub.cancel();
      await healthSource.close();
    });
  });

  group('FrbGraphSource Contract Adapter', () {
    test('retrieves and mutates semantic graph snapshot', () async {
      final graphSource = FrbGraphSource(maxEvents: 1);
      final initialSnapshot = await graphSource.getSnapshot();

      expect(initialSnapshot.nodes.length, greaterThanOrEqualTo(2));
      expect(initialSnapshot.edges.length, greaterThanOrEqualTo(1));

      const newNode = GraphNode<String>(
        id: 'node-dynamic',
        kind: 'service.plugin',
        label: 'Dynamic Plugin',
        payload: '{}',
      );

      await graphSource.addNode(newNode);
      final updatedSnapshot = await graphSource.getSnapshot();

      expect(updatedSnapshot.nodes.length, greaterThanOrEqualTo(3));
      expect(updatedSnapshot.getNode('node-dynamic'), isNotNull);

      await graphSource.close();
    });

    test('watchUpdates receives NodeAdded from native substrate when addNode is called', () async {
      final graphSource = FrbGraphSource(maxEvents: 1);
      final updates = <GraphUpdate<String, String>>[];

      final sub = graphSource.watchUpdates().listen(updates.add);

      // Allow native watcher stream initialization to subscribe
      await Future.delayed(const Duration(milliseconds: 50));

      const newNode = GraphNode<String>(
        id: 'node-stream-test',
        kind: 'service.worker',
        label: 'Worker Stream Node',
        payload: '{}',
      );

      await graphSource.addNode(newNode);

      // Wait for native broadcast to reach Dart StreamSink
      await Future.delayed(const Duration(milliseconds: 50));

      expect(updates.length, greaterThanOrEqualTo(1));
      final addedUpdate = updates.firstWhere(
        (u) => u is NodeAdded && (u as NodeAdded).node.id == 'node-stream-test',
      );
      expect(addedUpdate, isA<NodeAdded<String, String>>());
      final nodeAdded = addedUpdate as NodeAdded<String, String>;
      expect(nodeAdded.node.id, equals('node-stream-test'));
      expect(nodeAdded.node.label, equals('Worker Stream Node'));

      await sub.cancel();
      await graphSource.close();
    });
  });
}

