import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Strict error oracle for host exercise runs.
///
/// Fails visibly on material evidence:
/// - [FlutterError] reports (including RenderFlex overflow, missing
///   Material/MediaQuery ancestors, layout protocol violations);
/// - [ErrorWidget] creation triggered by a UI defect;
/// - uncaught synchronous exceptions surfaced via `tester.takeException`.
///
/// The oracle never swallows an exception and reports PASS. In particular,
/// a missing screenshot/capture capability must surface as BLOCKED/FAIL,
/// never as a log-and-pass (the Task 1834 anti-pattern).
class ExerciseErrorCollector {
  final List<FlutterErrorDetails> flutterErrors = <FlutterErrorDetails>[];
  final List<String> errorWidgetEvents = <String>[];
  final List<Object> asyncErrors = <Object>[];

  FlutterExceptionHandler? _previousOnError;
  bool _installed = false;

  /// Installs the collector. Must be paired with [uninstall] (usually via
  /// `addTearDown`).
  ///
  /// Only [FlutterError.onError] is intercepted (identity-safe restore).
  /// [ErrorWidget] surfaces are detected by scanning the tree with
  /// [collectTreeState] — the global `ErrorWidget.builder` is deliberately
  /// left untouched because `flutter_test` fails any test that mutates it.
  void install() {
    if (_installed) return;
    _installed = true;
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      flutterErrors.add(details);
      // Still forward so logs preserve the original diagnostics.
      _previousOnError?.call(details);
    };
  }

  /// Restores the previous global handler.
  void uninstall() {
    if (!_installed) return;
    _installed = false;
    FlutterError.onError = _previousOnError;
    _previousOnError = null;
  }

  /// Scans the current tree for [ErrorWidget] surfaces left by UI defects
  /// and records one event per instance. Call after each pump.
  void collectTreeState(WidgetTester tester) {
    final finder = find.byType(ErrorWidget);
    final count = finder.evaluate().length;
    for (var i = 0; i < count; i++) {
      final widget = tester.widget<ErrorWidget>(finder.at(i));
      errorWidgetEvents.add('ErrorWidget present: ${widget.message}');
    }
  }

  /// All collected material messages (Flutter errors + ErrorWidget events).
  List<String> get materialMessages => <String>[
    for (final e in flutterErrors) e.exceptionAsString(),
    ...errorWidgetEvents,
    for (final e in asyncErrors) e.toString(),
  ];

  bool get hasMaterialError =>
      flutterErrors.isNotEmpty ||
      errorWidgetEvents.isNotEmpty ||
      asyncErrors.isNotEmpty;

  /// Throws a [TestFailure]-compatible [FlutterError] when any material
  /// error was collected. Call after each pump and at run end.
  void failIfMaterial(String context) {
    if (!hasMaterialError) return;
    final buffer = StringBuffer()
      ..writeln('HOST-EXERCISE ORACLE FAILURE ($context):')
      ..writeln('  flutter_errors: ${flutterErrors.length}')
      ..writeln('  error_widget_events: ${errorWidgetEvents.length}')
      ..writeln('  async_errors: ${asyncErrors.length}');
    for (final message in materialMessages.take(8)) {
      buffer.writeln('  - ${_firstLine(message)}');
    }
    throw FlutterError(buffer.toString());
  }

  /// Resets the error registers (keeps handlers installed). Used when a
  /// caller wants to scope error attribution per-phase (e.g. calibration
  /// blocks that expect a known defect and then assert a clean phase).
  void clear() {
    flutterErrors.clear();
    errorWidgetEvents.clear();
    asyncErrors.clear();
  }

  static String _firstLine(String message) {
    final index = message.indexOf('\n');
    if (index < 0) return message.trim();
    return message.substring(0, index).trim();
  }

  /// True for the Task 1831 defect class (component/host ancestry gap).
  static bool isMissingAncestorMessage(String message) {
    return message.contains('No Material widget found') ||
        message.contains('No MediaQuery widget found') ||
        message.contains('No Directionality widget found') ||
        message.contains('No Scaffold widget found') ||
        message.contains('No Overlay widget found');
  }

  /// True for the Task 1832 defect class (fixed-height layout contracts).
  static bool isOverflowMessage(String message) {
    return message.contains('RenderFlex overflowed') ||
        message.contains('overflowed by') ||
        message.contains('RenderBox was not laid out') ||
        message.contains('Incorrect use of ParentDataWidget');
  }

  /// True for route-transition failures.
  static bool isRouteMessage(String message) {
    return message.contains('GoRouter') ||
        message.contains('route') && message.contains('not found') ||
        message.contains('Unknown route');
  }
}
