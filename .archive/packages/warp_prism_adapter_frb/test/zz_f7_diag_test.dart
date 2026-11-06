import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/src/rust/frb_generated.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

void main() {
  setUpAll(() async {
    final c = Directory.current.path;
    await RustLib.init(externalLibrary: ExternalLibrary.open(
        '$c/../../rust/target/debug/libwarp_bridge_frb.so'));
  });

  test('diag: cancel-after-pause (expect upPaused=true: B still paused)', () async {
    final s = FrbNativeEventStream(nativeEventCount: 60, nativeEventPrefix: 'd');
    final a = s.subscribe(onData: (_) {});
    final b = s.subscribe(onData: (_) {});
    a.pause(); b.pause();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    print('DIAG both paused: live=${s.liveSubscriptionCount} paused=${s.pausedSubscriptionCount} upPaused=${s.isUpstreamPaused}');
    await a.cancel();
    print('DIAG after cancel A: live=${s.liveSubscriptionCount} paused=${s.pausedSubscriptionCount} upPaused=${s.isUpstreamPaused}');
    print('DIAG subA.isPaused=${a.isPaused} subB.isPaused=${b.isPaused}');
    await b.cancel();
    await s.close();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('diag: close while paused (resume-then-close should NOT hang)', () async {
    final s = FrbNativeEventStream(nativeEventCount: 60, nativeEventPrefix: 'd2');
    final a = s.subscribe(onData: (_) {});
    final b = s.subscribe(onData: (_) {});
    a.pause(); b.pause();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    print('DIAG upPaused=${s.isUpstreamPaused}');
    final t = s.close().timeout(const Duration(seconds: 5), onTimeout: () { print('DIAG close TIMED OUT'); });
    await t;
    print('DIAG closed: isClosed=${s.isClosed} cancels=${s.nativeSubscriptionCancellations}');
    await a.cancel(); await b.cancel();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('diag: close with only one of two paused', () async {
    final s = FrbNativeEventStream(nativeEventCount: 60, nativeEventPrefix: 'd4');
    final a = s.subscribe(onData: (_) {});
    final b = s.subscribe(onData: (_) {});
    a.pause();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    print('DIAG one paused: upPaused=${s.isUpstreamPaused}');
    await s.close().timeout(const Duration(seconds: 5), onTimeout: () { print('DIAG close(one paused) TIMED OUT'); });
    print('DIAG one-paused closed cancels=${s.nativeSubscriptionCancellations}');
    await a.cancel(); await b.cancel();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('diag: close with NO pause at all', () async {
    final s = FrbNativeEventStream(nativeEventCount: 60, nativeEventPrefix: 'd5');
    final a = s.subscribe(onData: (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await s.close().timeout(const Duration(seconds: 5), onTimeout: () { print('DIAG close(none paused) TIMED OUT'); });
    print('DIAG none-paused closed cancels=${s.nativeSubscriptionCancellations}');
    await a.cancel();
  }, timeout: const Timeout(Duration(seconds: 20)));

  test('diag: all-paused buffer with no prior delivery', () async {
    final s = FrbNativeEventStream(nativeEventCount: 40, nativeEventPrefix: 'd3',
        backpressurePolicy: const EventStreamBackpressurePolicy.dropNewest(2));
    final a = s.subscribe(onData: (_) {});
    final b = s.subscribe(onData: (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 100));
    print('DIAG before pause buffer=${s.currentEvents.length}');
    a.pause(); b.pause();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    print('DIAG after both paused buffer=${s.currentEvents.length} upPaused=${s.isUpstreamPaused}');
    await a.cancel(); await b.cancel(); await s.close();
  }, timeout: const Timeout(Duration(seconds: 20)));
}
