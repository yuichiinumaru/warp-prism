// Task F7 — FrbNativeEventStream multi-subscriber pause semantics.
//
// Model under test: (b) reference-counted upstream pause. The shared native
// producer pauses ONLY when every live subscriber is paused.
//
// Each test names the numbered proof it pins.

import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/src/rust/frb_generated.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Long native run so the producer stays alive long enough to observe pausing.
const _count = 60;
const _prefix = 'f7';

Future<void> _settle([int ms = 90]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

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
        'F7: libwarp_bridge_frb.so not found. Build with '
        '`cd rust && cargo build -p warp_bridge_frb`. Probed: $candidates',
      );
    }
    await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
  });

  group('F7 proof 1: A paused + B active -> B still receives', () {
    test('pausing one of two subscribers does not starve the other', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );

      final a = <String>[];
      final b = <String>[];
      final subA = stream.subscribe(onData: (e) => a.add(e.payload));
      final subB = stream.subscribe(onData: (e) => b.add(e.payload));

      await _settle(120);

      // Baseline: both flowing.
      expect(a.length, greaterThan(0));
      expect(b.length, greaterThan(0));
      expect(b.length, equals(a.length));

      final aBefore = a.length;
      final bBefore = b.length;

      subA.pause();
      expect(subA.isPaused, isTrue);

      // The single pause must NOT pause the shared producer (F7 model b).
      expect(
        stream.isUpstreamPaused,
        isFalse,
        reason: 'one paused subscriber of two must not pause upstream',
      );

      await _settle(150);

      expect(
        a.length,
        equals(aBefore),
        reason: 'paused subscriber A receives nothing new',
      );
      expect(
        b.length,
        greaterThan(bBefore),
        reason: 'active subscriber B must keep receiving (no starvation)',
      );

      await subA.cancel();
      await subB.cancel();
      await stream.close();
    });
  });

  group('F7 proof 2: A+B paused -> documented upstream behavior happens', () {
    test('upstream pauses only when all live subscribers are paused', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});

      expect(stream.liveSubscriptionCount, equals(2));
      expect(stream.isUpstreamPaused, isFalse);

      subA.pause();
      await _settle(40);
      expect(
        stream.isUpstreamPaused,
        isFalse,
        reason: 'B is still active, so upstream keeps flowing',
      );

      subB.pause();
      await _settle(40);

      // All live subscribers paused -> upstream paused. This is the documented
      // producer flow-control, and it is bounded, not an unbounded queue.
      expect(stream.pausedSubscriptionCount, equals(2));
      expect(stream.liveSubscriptionCount, equals(2));
      expect(
        stream.isUpstreamPaused,
        isTrue,
        reason: 'all subscribers paused must pause the shared producer',
      );

      await subA.cancel();
      await subB.cancel();
      await stream.close();
    });
  });

  group('F7 proof 3: B resumes while A paused -> A remains logically paused', () {
    test('resuming B re-opens upstream without un-pausing A', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final a = <String>[];
      final b = <String>[];
      final subA = stream.subscribe(onData: (e) => a.add(e.payload));
      final subB = stream.subscribe(onData: (e) => b.add(e.payload));

      await _settle(120);

      subA.pause();
      subB.pause();
      await _settle(50);
      expect(stream.isUpstreamPaused, isTrue);

      final aAtPause = a.length;

      subB.resume();

      // Upstream re-opens because B is active again...
      expect(stream.isUpstreamPaused, isFalse);
      // ...but A is still logically paused and must stay that way.
      expect(subA.isPaused, isTrue);
      expect(stream.pausedSubscriptionCount, equals(1));

      await _settle(150);

      expect(
        a.length,
        equals(aAtPause),
        reason: 'A must remain paused even though upstream resumed for B',
      );
      expect(b.length, greaterThan(0));

      // A still receives its buffered backlog in order once resumed.
      subA.resume();
      await _settle(120);
      expect(
        a.length,
        greaterThan(aAtPause),
        reason: 'A resumes and drains its per-subscription buffer',
      );
      expect(
        a.take(3).toList(),
        equals(['$_prefix-1', '$_prefix-2', '$_prefix-3']),
        reason: 'per-subscription buffering preserves FIFO ordering',
      );

      await subA.cancel();
      await subB.cancel();
      await stream.close();
    });
  });

  group('F7 proof 4: cancel A does not disrupt B', () {
    test('cancelling one subscriber leaves the other and upstream intact', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final b = <String>[];
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (e) => b.add(e.payload));

      await _settle(120);
      expect(b.length, greaterThan(0));

      await subA.cancel();
      await _settle(30);

      // A is gone from the live count; B is untouched.
      expect(stream.liveSubscriptionCount, equals(1));
      expect(stream.pausedSubscriptionCount, equals(0));
      expect(
        stream.isUpstreamPaused,
        isFalse,
        reason: 'cancelling a subscriber must not pause upstream for others',
      );

      final bBefore = b.length;
      await _settle(150);
      expect(b.length, greaterThan(bBefore));

      await subB.cancel();
      await stream.close();
    });

    test('cancelling a paused subscriber keeps upstream paused while another is paused', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});

      subA.pause();
      subB.pause();
      await _settle(40);
      expect(stream.isUpstreamPaused, isTrue);

      await subA.cancel();
      await _settle(40);

      // B is STILL paused, so "all live subscribers paused" remains true and the
      // upstream correctly stays paused. Cancelling A neither resumed nor paused
      // the producer for B — it only removed A from the count.
      expect(stream.liveSubscriptionCount, equals(1));
      expect(stream.pausedSubscriptionCount, equals(1));
      expect(
        stream.isUpstreamPaused,
        isTrue,
        reason: 'B is still paused, so the reference count says stay paused',
      );

      // Resuming B re-opens upstream: the count now reaches zero paused.
      subB.resume();
      await _settle(40);
      expect(stream.isUpstreamPaused, isFalse);

      await subB.cancel();
      await stream.close();
    });
  });

  group('F7 proof 5: close stops the native producer and both consumers', () {
    test('close cancels upstream exactly once and stops all delivery', () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final a = <String>[];
      final b = <String>[];
      final subA = stream.subscribe(onData: (e) => a.add(e.payload));
      final subB = stream.subscribe(onData: (e) => b.add(e.payload));

      await _settle(120);
      expect(stream.hasActiveNativeSubscription, isTrue);
      expect(stream.nativeSubscriptionCancellations, equals(0));

      await stream.close();

      // Deterministic stop for both consumers and the producer.
      expect(stream.isClosed, isTrue);
      expect(stream.hasActiveNativeSubscription, isFalse);
      expect(
        stream.nativeSubscriptionCancellations,
        equals(1),
        reason: 'close() must genuinely cancel the native subscription once',
      );
      expect(stream.liveSubscriptionCount, equals(0));

      final aAtClose = a.length;
      final bAtClose = b.length;
      await _settle(150);

      expect(a.length, equals(aAtClose), reason: 'no delivery after close');
      expect(b.length, equals(bAtClose), reason: 'no delivery after close');

      await subA.cancel();
      await subB.cancel();
    });

    test('close while all subscribers are paused still cancels upstream', () async {
      // Regression: a paused subscription must not make close() a no-op.
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: _prefix,
      );
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});

      subA.pause();
      subB.pause();
      await _settle(40);
      expect(stream.isUpstreamPaused, isTrue);

      await stream.close();
      expect(stream.hasActiveNativeSubscription, isFalse);
      expect(
        stream.nativeSubscriptionCancellations,
        equals(1),
        reason: 'a paused upstream must still be cancelled by close()',
      );

      await subA.cancel();
      await subB.cancel();
    });

    test('close is idempotent with live subscribers', () async {
      final stream = FrbNativeEventStream(nativeEventCount: _count);
      final subA = stream.subscribe(onData: (_) {});
      await _settle(60);

      await stream.close();
      await stream.close();

      expect(stream.nativeSubscriptionCancellations, equals(1));
      await subA.cancel();
    });
  });

  group('F7 proof 6: backpressure stays bounded under multi-subscriber pause', () {
    test('retained buffer honours the policy with a paused subscriber present',
        () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: 40,
        nativeEventPrefix: 'bp',
        backpressurePolicy: const EventStreamBackpressurePolicy.dropOldest(3),
      );
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});

      // Pause A for the whole run: the retained buffer must still be bounded by
      // the policy, i.e. pausing must not open an unbounded memory path.
      subA.pause();
      await _settle(250);

      expect(
        stream.currentEvents.length,
        equals(3),
        reason: 'retained buffer must stay policy-bounded while A is paused',
      );
      expect(
        stream.liveSubscriptionCount,
        equals(2),
        reason: 'subscriptions are held, not spooled into memory here',
      );

      await subA.cancel();
      await subB.cancel();
      await stream.close();
    });

    test('all-paused upstream keeps the retained buffer policy-bounded',
        () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: 40,
        nativeEventPrefix: 'bp2',
        backpressurePolicy: const EventStreamBackpressurePolicy.dropNewest(2),
      );
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});

      // Let the buffer reach its policy capacity BEFORE pausing, so the
      // assertion below is meaningful: pausing must freeze a full buffer at
      // capacity, not observe an empty one.
      await _settle(100);
      expect(stream.currentEvents.length, equals(2));

      subA.pause();
      subB.pause();
      await _settle(200);

      expect(stream.isUpstreamPaused, isTrue);
      expect(
        stream.currentEvents.length,
        equals(2),
        reason: 'all-paused must not grow the retained buffer either',
      );

      await subA.cancel();
      await subB.cancel();
      await stream.close();
    });

    test('three subscribers: two paused still leaves the third receiving',
        () async {
      final stream = FrbNativeEventStream(
        nativeEventCount: _count,
        nativeEventPrefix: 'f7x',
      );
      final c = <String>[];
      final subA = stream.subscribe(onData: (_) {});
      final subB = stream.subscribe(onData: (_) {});
      final subC = stream.subscribe(onData: (e) => c.add(e.payload));

      await _settle(120);
      subA.pause();
      subB.pause();
      expect(stream.isUpstreamPaused, isFalse);

      final cBefore = c.length;
      await _settle(150);
      expect(c.length, greaterThan(cBefore));

      await subA.cancel();
      await subB.cancel();
      await subC.cancel();
      await stream.close();
    });
  });
}