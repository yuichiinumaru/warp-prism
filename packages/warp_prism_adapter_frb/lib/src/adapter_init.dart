import 'package:meta/meta.dart';
import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'rust/frb_generated.dart';

/// Helper to initialize the native Flutter Rust Bridge library.
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract final class WarpBridge {
  static bool _initialized = false;

  /// Whether the native bridge library has been initialized.
  static bool get isInitialized => _initialized;

  /// Initializes the RustLib instance, optionally loading from [dylibPath] or [externalLibrary].
  static Future<void> init({
    String? dylibPath,
    ExternalLibrary? externalLibrary,
  }) async {
    if (_initialized) return;

    if (externalLibrary != null) {
      await RustLib.init(externalLibrary: externalLibrary);
    } else if (dylibPath != null) {
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      // Default resolution or fallback to standard library search
      final defaultPath = _resolveDefaultDylibPath();
      if (defaultPath != null && File(defaultPath).existsSync()) {
        await RustLib.init(externalLibrary: ExternalLibrary.open(defaultPath));
      } else {
        await RustLib.init();
      }
    }

    _initialized = true;
  }

  static String? _resolveDefaultDylibPath() {
    final current = Directory.current.path;
    // Check local target directory paths
    final candidates = [
      '$current/rust/target/release/libwarp_bridge_frb.so',
      '$current/rust/target/debug/libwarp_bridge_frb.so',
      '$current/../../rust/target/release/libwarp_bridge_frb.so',
      '$current/../../rust/target/debug/libwarp_bridge_frb.so',
      '$current/../rust/target/release/libwarp_bridge_frb.so',
      '$current/../rust/target/debug/libwarp_bridge_frb.so',
    ];
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }
}
