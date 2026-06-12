import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ds_fallback_view.dart';

/// ASW Observatory Organism - Error Boundary
///
/// Wraps a child widget and catches build/render errors, replacing the
/// child with a [DSFallbackView] instead of crashing the entire app.
///
/// Contract:
/// - Overrides [FlutterError.onError] within its subtree scope.
/// - Displays [DSFallbackView] with error details and optional retry.
/// - In debug mode, shows real error message and stack trace.
/// - In release mode, shows a friendly message.
/// - Provides a retry callback that rebuilds the child.
/// - Every DSShell panel section SHOULD be wrapped in [DSErrorBoundary].
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
  FlutterExceptionHandler? _previousHandler;

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
    _previousHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Also call the previous handler so the error is still logged
      if (_previousHandler != null) {
        _previousHandler!(details);
      }
      // Defer setState to after the current build frame
      if (mounted) {
        final exception = details.exception;
        final stack = details.stack;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _error = exception;
              _stackTrace = stack;
            });
          }
        });
      }
    };
  }

  void _restoreErrorHandler() {
    if (FlutterError.onError == _handleFlutterError) {
      FlutterError.onError = _previousHandler;
    }
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    if (mounted) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    }
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
