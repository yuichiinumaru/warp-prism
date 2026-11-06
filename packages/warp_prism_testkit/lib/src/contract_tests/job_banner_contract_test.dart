import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../fakes/fake_job_banner_model.dart';

/// Reusable contract compliance suite for staged job-banner models
/// (Task 1858, F-10).
///
/// Verifies the banner transition law headlessly: staged progress ordering
/// and determinism, cancel offered only when cancellable with reason
/// propagation, terminal receipt-slot rules (receipt only on success,
/// verbatim consumer bytes), and the fail-closed indeterminate contract
/// (withheld determination never maps to success or disabled presentation).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
void verifyJobBannerModelContract({
  required FakeJobBannerModel Function({
    required List<String> stageLabels,
    bool cancellable,
    String? cancelReason,
  })
  createModel,
  String description = 'JobBanner Model Contract Compliance',
}) {
  group(description, () {
    group('staged progress is ordered and deterministic', () {
      test('starts queued with caller stages pending', () {
        final model = createModel(
          stageLabels: const ['Prepare', 'Render', 'Export'],
        );
        expect(model.phase, equals(JobBannerPhase.queued));
        expect(model.phase.isTerminal, isFalse);
        expect(
          model.stages.map((s) => s.label).toList(),
          equals(const ['Prepare', 'Render', 'Export']),
        );
        expect(
          model.stages.map((s) => s.state),
          everyElement(equals(JobBannerStageState.pending)),
        );
      });

      test('start moves queued to running exactly once', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        expect(model.phase, equals(JobBannerPhase.running));
        expect(() => model.start(), throwsStateError);
      });

      test('stage progress is clamped and stage-scoped', () {
        final model = createModel(stageLabels: const ['Prepare', 'Render']);
        model.start();
        model.setStageProgress(0, 2.5);
        model.setStageProgress(1, -0.5);
        expect(model.stages[0].progress, equals(1.0));
        expect(model.stages[1].progress, equals(0.0));
        // Stage 0 untouched by stage 1 writes.
        model.setStageProgress(1, 0.5);
        expect(model.stages[0].progress, equals(1.0));
        expect(model.stages[1].progress, equals(0.5));
      });

      test('completeStage marks one stage done at full progress', () {
        final model = createModel(stageLabels: const ['Prepare', 'Render']);
        model.start();
        model.activateStage(0);
        model.completeStage(0);
        expect(model.stages[0].state, equals(JobBannerStageState.done));
        expect(model.stages[0].progress, equals(1.0));
        expect(model.stages[1].state, equals(JobBannerStageState.pending));
      });

      test('stage writes from a terminal phase throw', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        model.complete(receiptLines: const ['DEST out/']);
        expect(() => model.activateStage(0), throwsStateError);
        expect(() => model.setStageProgress(0, 0.5), throwsStateError);
        expect(() => model.completeStage(0), throwsStateError);
      });
    });

    group('cancel is offered only when cancellable', () {
      test('non-cancellable banner never offers cancel', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        expect(model.cancelOffered, isFalse);
        expect(
          () => model.requestCancel(reason: 'Operator stop'),
          throwsStateError,
        );
        expect(model.phase, equals(JobBannerPhase.running));
      });

      test('cancellable banner requires a non-empty reason at build', () {
        expect(
          () => createModel(stageLabels: const ['Prepare'], cancellable: true),
          throwsArgumentError,
        );
      });

      test('cancel propagates the reason and terminates', () {
        final model = createModel(
          stageLabels: const ['Prepare'],
          cancellable: true,
          cancelReason: 'Takes too long',
        );
        model.start();
        expect(model.cancelOffered, isTrue);
        model.requestCancel(reason: 'Operator pressed stop');
        expect(model.phase, equals(JobBannerPhase.cancelled));
        expect(model.cancelReason, equals('Operator pressed stop'));
        expect(model.cancelOffered, isFalse);
      });

      test('cancel with an empty reason throws and stays running', () {
        final model = createModel(
          stageLabels: const ['Prepare'],
          cancellable: true,
          cancelReason: 'Too slow',
        );
        model.start();
        expect(() => model.requestCancel(reason: ''), throwsArgumentError);
        expect(model.phase, equals(JobBannerPhase.running));
      });

      test('cancel from a terminal phase throws', () {
        final model = createModel(
          stageLabels: const ['Prepare'],
          cancellable: true,
          cancelReason: 'Too slow',
        );
        model.start();
        model.fail(reason: 'Render error');
        expect(model.cancelOffered, isFalse);
        expect(() => model.requestCancel(reason: 'Too late'), throwsStateError);
      });
    });

    group('terminal receipt slot is success-only and verbatim', () {
      test('receipt attaches only on complete, stored verbatim', () {
        final model = createModel(stageLabels: const ['Prepare']);
        expect(model.receiptLines, isNull);
        expect(model.hasReceipt, isFalse);
        model.start();
        const lines = [
          'DEST out/take-03.wav',
          'FRAMES 1048576',
          'BYTES 8388608',
        ];
        model.complete(receiptLines: lines);
        expect(model.phase, equals(JobBannerPhase.succeeded));
        expect(model.receiptLines, equals(lines));
        expect(model.hasReceipt, isTrue);
      });

      test('complete requires at least one receipt line', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        expect(
          () => model.complete(receiptLines: const []),
          throwsArgumentError,
        );
        expect(model.phase, equals(JobBannerPhase.running));
      });

      test('fail clears any staged receipt and carries no receipt', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        model.fail(reason: 'Render error');
        expect(model.phase, equals(JobBannerPhase.failed));
        expect(model.failureReason, equals('Render error'));
        expect(model.receiptLines, isNull);
        expect(model.hasReceipt, isFalse);
      });

      test('cancel clears any staged receipt and carries no receipt', () {
        final model = createModel(
          stageLabels: const ['Prepare'],
          cancellable: true,
          cancelReason: 'Too slow',
        );
        model.start();
        model.requestCancel(reason: 'Operator stop');
        expect(model.receiptLines, isNull);
        expect(model.hasReceipt, isFalse);
      });

      test('terminal phases are absorbing', () {
        final model = createModel(stageLabels: const ['Prepare']);
        model.start();
        model.complete(receiptLines: const ['DEST out/']);
        expect(
          () => model.complete(receiptLines: const ['DEST other/']),
          throwsStateError,
        );
        expect(() => model.fail(reason: 'late'), throwsStateError);
        expect(() => model.markUnknown(), throwsStateError);
        expect(model.receiptLines, equals(const ['DEST out/']));
      });
    });

    group('fail-closed indeterminate contract', () {
      test('unknown is the only indeterminate phase', () {
        for (final phase in JobBannerPhase.values) {
          if (phase == JobBannerPhase.unknown) {
            expect(phase.isIndeterminate, isTrue);
          } else {
            expect(
              phase.isIndeterminate,
              isFalse,
              reason: '$phase must stay determinate',
            );
          }
        }
      });

      test('markUnknown withholds determination and clears receipts', () {
        final model = createModel(
          stageLabels: const ['Prepare'],
          cancellable: true,
          cancelReason: 'Too slow',
        );
        model.start();
        model.markUnknown();
        expect(model.phase, equals(JobBannerPhase.unknown));
        expect(model.phase.isTerminal, isFalse);
        expect(model.receiptLines, isNull);
        // Withheld determination is not terminal: cancel stays offered.
        expect(model.cancelOffered, isTrue);
      });

      test('indeterminate semantics never claim success or disabled', () {
        final label = JobBannerPhase.unknown.semanticLabel;
        expect(label.toLowerCase(), contains('not yet determined'));
        for (final banned in [
          'succeed',
          'success',
          'complet',
          'disabl',
          'verifi',
        ]) {
          expect(
            label.toLowerCase(),
            isNot(contains(banned)),
            reason: 'indeterminate semantics must never claim `$banned`',
          );
        }
      });

      test('terminal success semantics stay distinct from indeterminate', () {
        expect(JobBannerPhase.succeeded.isIndeterminate, isFalse);
        expect(JobBannerPhase.unknown.isTerminal, isFalse);
      });
    });
  });
}

void main() {}
