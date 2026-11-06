import 'package:meta/meta.dart';

/// Injectable assurance-data loader reference shape.
///
/// The bridge-backed default loads from the native substrate; tests inject a
/// fake that drives error/empty/populated states without a live native
/// library. Source shape: the consumer `AssuranceLoader` typedef
/// (`assurance_panel.dart:21-23`), which exists explicitly "so a widget test
/// can drive every documented state without a live native library".
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
typedef AssuranceLoader<T> = Future<T> Function();

/// Injectable assurance-repair reference shape.
///
/// The bridge-backed default requests repair from the native substrate;
/// tests inject a fake that records params and returns scripted outcomes.
/// Source shape: the consumer `AssuranceRepairer` typedef
/// (`assurance_panel.dart:21-23`).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
typedef AssuranceRepairer<T> =
    Future<T> Function(T current, Map<String, Object?> params);
