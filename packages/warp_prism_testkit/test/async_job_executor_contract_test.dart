import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('FakeAsyncJobExecutor Contract Verification (Task 1859)', () {
    verifyAsyncJobExecutorContract<String, String>(
      createExecutor: () =>
          FakeAsyncJobExecutor<String, String>(initialResult: 'fake-ok'),
      sampleParam: (index) => 'param-$index',
      sampleResult: 'fake-ok',
      description: 'FakeAsyncJobExecutor Contract Compliance',
    );

    test('mints one FakeAsyncCommand per execution in submit order', () async {
      final executor = FakeAsyncJobExecutor<String, String>(
        initialResult: 'fake-ok',
      );

      final handleA = executor.submit('first');
      final handleB = executor.submit('second');

      expect(executor.createdCommands.length, equals(2));
      expect(executor.createdCommands[0].lastParam, equals('first'));
      expect(executor.createdCommands[1].lastParam, equals('second'));

      expect(await handleA.result, isA<CommandSuccess<String>>());
      expect(await handleB.result, isA<CommandSuccess<String>>());

      await executor.close();
    });

    test(
      'AssuranceLoader/AssuranceRepairer drive states without a backend',
      () async {
        Future<String> fakeBridgeLoad() async => 'populated';
        Future<String> fakeBridgeRepair(
          String current,
          Map<String, Object?> params,
        ) async => 'repaired:$current:${params['mode']}';

        final AssuranceLoader<String> loader = fakeBridgeLoad;
        final AssuranceRepairer<String> repairer = fakeBridgeRepair;

        expect(await loader(), equals('populated'));
        expect(
          await repairer('populated', {'mode': 'bounded'}),
          equals('repaired:populated:bounded'),
        );

        Future<String> failingLoad() async => throw StateError('backend down');
        expect(failingLoad(), throwsA(isA<StateError>()));
      },
    );
  });
}
