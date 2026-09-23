# Flutter Test Error-Visibility Contract

This reference defines the behavior expected from a future/canonized Flutter
test-error guard. It is **not enforcement merely because this file exists**.

## Goal

Tests must not report PASS while relevant Flutter framework/runtime errors,
`ErrorWidget` substitutions, or layout failures are being swallowed.

Instrumentation must preserve the framework's own error semantics and restore any
handler it temporarily overrides.

## Widget Tests

`flutter_test` already has native failure semantics for many build/layout/paint
errors. Prefer those semantics rather than redispatching errors through arbitrary
zones.

When a test/helper explicitly consumes `tester.takeException()`, it must assert
the expected exception or assert that the result is null. Do not consume and
discard an unexpected exception.

### `ErrorWidget.builder`

If instrumentation overrides `ErrorWidget.builder`:

1. save the previous builder;
2. record the `FlutterErrorDetails`;
3. delegate rendering to the **previous builder**, rather than replacing the
   error with a benign widget;
4. restore the previous builder in teardown/finally;
5. fail the test from the recorded evidence unless the scenario deliberately
   expects that error path.

This preserves project/framework customization instead of assuming one hardcoded
"correct default" builder.

### `FlutterError.onError`

Do not replace it with an empty/log-only handler.
If an override is needed for observation, preserve the previous handler/behavior
and restore it afterward.

Do not use `Zone.current.handleUncaughtError` in ordinary `testWidgets` merely to
re-dispatch an error the Flutter test binding already handles.

## Integration / Real-Host Tests

Capture the error channels relevant to the actual test host, including
`PlatformDispatcher.instance.onError` where appropriate.

Any temporary handler must:
- record the error;
- preserve/chaining behavior required by the active harness;
- restore the previous handler;
- make the recorded error fail the scenario unless deliberately expected.

A zone fallback may be used for integration-host errors that are genuinely
outside Flutter framework callbacks, but it must not double-report normal
framework failures.

## Overflow

Prefer framework diagnostics/layout evidence over brittle matching of human error
strings.

The durable rule is not "search for this exact sentence"; it is:

> an unexpected layout overflow is failure evidence.

## Static Scanner Candidates

A future scanner may flag:

| ID | Candidate check |
|---|---|
| G1 | `FlutterError.onError` replaced by empty/log-only body |
| G2 | error-handler override without restoration |
| G3 | `ErrorWidget.builder` replaced with benign output that hides the error |
| G4 | brittle exact-string matching used as the only overflow oracle |
| G5 | `Zone.current.handleUncaughtError` used inside ordinary widget tests to redispatch framework errors |
| G6 | helpers whose purpose is to ignore/filter overflow/framework errors |

These checks are **implementation candidates**, not active gates until a script
is implemented, calibrated against known-good and known-bad fixtures, and
admitted by harness governance.

## Explicit Limits

This contract does not:
- decide whether a negative-path test is semantically correct;
- replace `flutter_test`/`integration_test`;
- prove real-host composition by itself;
- authorize task PASS.
