import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ds_fallback_view.dart';

/// ASW Observatory Organism - Error Boundary
///
/// Wraps a child widget and surfaces build/render errors via a
/// [DSFallbackView] instead of leaving a permanent red/error surface in
/// a panel.
///
/// ## Isolation model (honest contract)
///
/// Flutter does not provide React-style true subtree error isolation.
/// [DSErrorBoundary] participates in a **nested stack** of active
/// boundaries and installs:
/// - [FlutterError.onError] — tear-off dispatcher (identity-safe restore)
/// - [ErrorWidget.builder] — hides framework ErrorWidget while the
///   innermost active boundary captures the failure
///
/// The **innermost** mounted boundary captures the next reported error.
/// Nested dispose order restores the previous stack frame; when the stack
/// is empty, the original global handlers are restored.
///
/// This is suitable for panel-level wrapping (every DSShell section), not
/// as a guarantee that only errors originating inside [child] are caught.
///
/// Usage:
/// ```dart
/// DSErrorBoundary(
///   child: SomePanel(),
/// )
///
/// DSErrorBoundary.withDefaultFallback(
///   child: SomePanel(),
/// )
/// ```
class DSErrorBoundary extends StatefulWidget {
  /// The child widget to protect.
  final Widget child;

  /// Custom fallback builder. If null, uses [DSFallbackView].
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  fallbackBuilder;

  const DSErrorBoundary({super.key, required this.child, this.fallbackBuilder});

  /// Convenience constructor that uses [DSFallbackView] as the default fallback.
  const DSErrorBoundary.withDefaultFallback({super.key, required this.child})
    : fallbackBuilder = null;

  @override
  State<DSErrorBoundary> createState() => _DSErrorBoundaryState();
}

class _DSErrorBoundaryState extends State<DSErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  /// Nested boundary stack — last element is the active capture target.
  static final List<_DSErrorBoundaryState> _stack = [];

  /// Global handlers saved by the outermost boundary only.
  static FlutterExceptionHandler? _rootPreviousHandler;
  static ErrorWidgetBuilder? _rootPreviousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    _installErrorHandler();
  }

  @override
  void dispose() {
    _restoreErrorHandler();
    super.dispose();
  }

  void _installErrorHandler() {
    if (_stack.isEmpty) {
      _rootPreviousHandler = FlutterError.onError;
      _rootPreviousErrorWidgetBuilder = ErrorWidget.builder;
      // Named static tear-offs so identity checks / stack restore are reliable.
      FlutterError.onError = _dispatchFlutterError;
      ErrorWidget.builder = _dispatchErrorWidget;
    }
    _stack.add(this);
  }

  void _restoreErrorHandler() {
    _stack.remove(this);
    if (_stack.isEmpty) {
      // Only restore globals when this was the last active boundary.
      if (FlutterError.onError == _dispatchFlutterError) {
        FlutterError.onError = _rootPreviousHandler;
      }
      if (ErrorWidget.builder == _dispatchErrorWidget) {
        ErrorWidget.builder =
            _rootPreviousErrorWidgetBuilder ?? ErrorWidget.builder;
      }
      _rootPreviousHandler = null;
      _rootPreviousErrorWidgetBuilder = null;
    }
  }

  /// Static dispatcher so [FlutterError.onError] identity is stable.
  static void _dispatchFlutterError(FlutterErrorDetails details) {
    final target = _stack.isNotEmpty ? _stack.last : null;
    target?._capture(details);

    final previous = _rootPreviousHandler;
    if (previous != null) {
      previous(details);
    }
  }

  /// Static ErrorWidget builder — hides red screen while boundary rebuilds.
  static Widget _dispatchErrorWidget(FlutterErrorDetails details) {
    final target = _stack.isNotEmpty ? _stack.last : null;
    if (target != null) {
      target._capture(details);
      // Placeholder until the boundary setStates to its fallback UI.
      return const SizedBox.shrink();
    }
    final previous = _rootPreviousErrorWidgetBuilder;
    if (previous != null) {
      return previous(details);
    }
    return ErrorWidget(details.exception);
  }

  void _capture(FlutterErrorDetails details) {
    final exception = details.exception;
    final stack = details.stack;
    // Defer setState past the failing build frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Keep first error until retry clears it.
      if (_error != null) return;
      setState(() {
        _error = exception;
        _stackTrace = stack;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _error!, _stackTrace);
      }
      return DSFallbackView(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _handleRetry,
      );
    }

    return widget.child;
  }

  void _handleRetry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}
