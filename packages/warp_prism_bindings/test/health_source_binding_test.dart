import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('HealthSourceBinding', () {
    test('initializes and projects initial snapshot from HealthSource', () async {
      final initialSnapshot = HealthSnapshot(
        timestamp: DateTime.now(),
        cells: const [
          HealthCell(
            id: 'cell-1',
            providerId: 'p-openai',
            providerLabel: 'OpenAI',
            dimensionId: 'd-chat',
            dimensionLabel: 'Chat API',
            state: HealthState.healthy,
            latency: Duration(milliseconds: 120),
            metadata: {'region': 'us-east-1'},
          ),
          HealthCell(
            id: 'cell-2',
            providerId: 'p-openai',
            providerLabel: 'OpenAI',
            dimensionId: 'd-embed',
            dimensionLabel: 'Embeddings API',
            state: HealthState.degraded,
            latency: Duration(milliseconds: 650),
            metadata: {'region': 'us-west-2'},
          ),
        ],
        aggregateState: HealthState.degraded,
        freshnessTtl: const Duration(seconds: 30),
      );

      final fakeSource = FakeHealthSource(initialSnapshot: initialSnapshot);
      final binding = HealthSourceBinding(source: fakeSource);

      await Future<void>.delayed(Duration.zero);

      expect(binding.status, equals(HealthSourceBindingStatus.active));
      expect(binding.isInitialized, isTrue);
      expect(binding.isDisposed, isFalse);
      expect(binding.cellCount, equals(2));
      expect(binding.aggregateState, equals(HealthState.degraded));
      expect(binding.isStale, isFalse);
      expect(binding.isFresh, isTrue);
      expect(binding.error, isNull);

      final vm = binding.viewModel;
      expect(vm.cellCount, equals(2));
      expect(vm.providerIds, equals(['p-openai']));
      expect(vm.dimensionIds, equals(['d-chat', 'd-embed']));
      expect(vm.cellById('cell-1')?.state, equals(HealthState.healthy));
      expect(vm.cellById('cell-2')?.state, equals(HealthState.degraded));
      expect(vm.cellById('nonexistent'), isNull);

      // Provider projection for PrismProviderHealthMatrix
      final providers = binding.providers;
      expect(providers.length, equals(1));
      expect(providers.first.id, equals('p-openai'));
      expect(providers.first.label, equals('OpenAI'));
      expect(providers.first.cells.length, equals(2));
      expect(
        providers.first.aggregateState,
        equals(PrismOperationalState.degraded),
      );

      final chatCell = providers.first.cells.first;
      expect(chatCell.id, equals('cell-1'));
      expect(chatCell.operationalState, equals(PrismOperationalState.healthy));
      expect(chatCell.latency, equals(const Duration(milliseconds: 120)));
      expect(chatCell.meta, equals('us-east-1'));

      binding.dispose();
    });

    test('receives reactive watch-driven updates and notifies listeners', () async {
      final fakeSource = FakeHealthSource();
      final binding = HealthSourceBinding(source: fakeSource);

      await Future<void>.delayed(Duration.zero);
      expect(binding.cellCount, equals(0));

      final notificationSnapshots = <HealthSourceViewModel>[];
      binding.addListener(() {
        notificationSnapshots.add(binding.viewModel);
      });

      fakeSource.updateCell(
        const HealthCell(
          id: 'cell-claude',
          providerId: 'anthropic',
          providerLabel: 'Anthropic',
          dimensionId: 'claude-3-5',
          dimensionLabel: 'Claude 3.5 Sonnet',
          state: HealthState.healthy,
          latency: Duration(milliseconds: 250),
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(binding.cellCount, equals(1));
      expect(binding.aggregateState, equals(HealthState.healthy));
      expect(notificationSnapshots.isNotEmpty, isTrue);
      expect(notificationSnapshots.last.cellById('cell-claude'), isNotNull);

      // Mutate to degraded state
      fakeSource.simulateDegradation(
        'cell-claude',
        latency: const Duration(milliseconds: 1200),
      );

      await Future<void>.delayed(Duration.zero);

      expect(binding.aggregateState, equals(HealthState.degraded));
      expect(
        binding.viewModel.cellById('cell-claude')?.latency,
        equals(const Duration(milliseconds: 1200)),
      );

      binding.dispose();
    });

    test('correctly calculates worst-state rollup across multiple providers', () async {
      final initialSnapshot = HealthSnapshot(
        timestamp: DateTime(2026, 9, 2, 11, 0, 0),
        cells: const [
          HealthCell(
            id: 'c1',
            providerId: 'p1',
            providerLabel: 'Provider 1',
            dimensionId: 'd1',
            dimensionLabel: 'Dim 1',
            state: HealthState.healthy,
          ),
          HealthCell(
            id: 'c2',
            providerId: 'p2',
            providerLabel: 'Provider 2',
            dimensionId: 'd1',
            dimensionLabel: 'Dim 1',
            state: HealthState.unknown,
          ),
          HealthCell(
            id: 'c3',
            providerId: 'p3',
            providerLabel: 'Provider 3',
            dimensionId: 'd1',
            dimensionLabel: 'Dim 1',
            state: HealthState.degraded,
          ),
          HealthCell(
            id: 'c4',
            providerId: 'p4',
            providerLabel: 'Provider 4',
            dimensionId: 'd1',
            dimensionLabel: 'Dim 1',
            state: HealthState.unreachable,
          ),
        ],
        aggregateState: HealthState.unreachable,
      );

      final fakeSource = FakeHealthSource(initialSnapshot: initialSnapshot);
      final binding = HealthSourceBinding(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.aggregateState, equals(HealthState.unreachable));

      final providers = binding.providers;
      expect(providers.length, equals(4));

      final p1 = providers.firstWhere((p) => p.id == 'p1');
      expect(p1.aggregateState, equals(PrismOperationalState.healthy));

      final p2 = providers.firstWhere((p) => p.id == 'p2');
      expect(p2.aggregateState, equals(PrismOperationalState.unverified));

      final p3 = providers.firstWhere((p) => p.id == 'p3');
      expect(p3.aggregateState, equals(PrismOperationalState.degraded));

      final p4 = providers.firstWhere((p) => p.id == 'p4');
      expect(p4.aggregateState, equals(PrismOperationalState.error));

      binding.dispose();
    });

    test('freshness tracking and stale state transitions with TTL', () async {
      final baseTime = DateTime(2026, 9, 2, 12, 0, 0);
      final snapshot = HealthSnapshot(
        timestamp: baseTime,
        cells: const [
          HealthCell(
            id: 'fresh-cell',
            providerId: 'prov',
            providerLabel: 'Provider',
            dimensionId: 'dim',
            dimensionLabel: 'Dimension',
            state: HealthState.healthy,
          ),
        ],
        aggregateState: HealthState.healthy,
        freshnessTtl: const Duration(seconds: 10),
      );

      final fakeSource = FakeHealthSource(initialSnapshot: snapshot);
      final binding = HealthSourceBinding(
        source: fakeSource,
        autoInitialize: false,
      );

      // Initialize with asOf within TTL
      await binding.initialize(
        asOf: baseTime.add(const Duration(seconds: 5)),
      );

      expect(binding.isStale, isFalse);
      expect(binding.isFresh, isTrue);

      var freshnessNotifications = 0;
      binding.addListener(() {
        freshnessNotifications++;
      });

      // Calling checkFreshness within TTL causes no change
      binding.checkFreshness(asOf: baseTime.add(const Duration(seconds: 8)));
      expect(binding.isStale, isFalse);
      expect(freshnessNotifications, equals(0));

      // Calling checkFreshness beyond TTL marks snapshot stale and notifies
      binding.checkFreshness(asOf: baseTime.add(const Duration(seconds: 15)));
      expect(binding.isStale, isTrue);
      expect(binding.isFresh, isFalse);
      expect(freshnessNotifications, equals(1));

      // With markStaleAsStale = true, projected provider states map to stale
      final staleProviders = binding.viewModel.toProviderHealthProviders(
        markStaleAsStale: true,
      );
      expect(
        staleProviders.first.cells.first.operationalState,
        equals(PrismOperationalState.stale),
      );
      expect(
        staleProviders.first.aggregateState,
        equals(PrismOperationalState.stale),
      );

      // When markStaleAsStale = false, preserves underlying operational state
      final rawProviders = binding.viewModel.toProviderHealthProviders(
        markStaleAsStale: false,
      );
      expect(
        rawProviders.first.cells.first.operationalState,
        equals(PrismOperationalState.healthy),
      );

      binding.dispose();
    });

    test(
      'watch-error resilience surfaces error while keeping source connection and recovers on next snapshot',
      () async {
        final fakeSource = FakeHealthSource();
        final binding = HealthSourceBinding(source: fakeSource);
        await Future<void>.delayed(Duration.zero);

        expect(binding.status, equals(HealthSourceBindingStatus.active));
        expect(binding.error, isNull);

        final streamErrors = <Object>[];
        binding.viewModelStream.listen(
          (_) {},
          onError: (e) => streamErrors.add(e),
        );

        // Inject watch error (G5 semantics)
        fakeSource.emitWatchError(Exception('Telemetry stream socket timeout'));
        await Future<void>.delayed(Duration.zero);

        expect(binding.status, equals(HealthSourceBindingStatus.error));
        expect(binding.error, isNotNull);
        expect(
          binding.error.toString(),
          contains('Telemetry stream socket timeout'),
        );
        expect(streamErrors.length, equals(1));

        // Source remains usable — emit a valid snapshot and verify recovery
        fakeSource.setSnapshot(
          HealthSnapshot(
            timestamp: DateTime.now(),
            cells: const [
              HealthCell(
                id: 'recovered-cell',
                providerId: 'p-rec',
                providerLabel: 'Recovered Provider',
                dimensionId: 'dim',
                dimensionLabel: 'Dim',
                state: HealthState.healthy,
              ),
            ],
            aggregateState: HealthState.healthy,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(binding.status, equals(HealthSourceBindingStatus.active));
        expect(binding.error, isNull);
        expect(binding.cellCount, equals(1));
        expect(
          binding.viewModel.cellById('recovered-cell')?.state,
          equals(HealthState.healthy),
        );

        binding.dispose();
      },
    );

    test('manual refresh queries underlying source and updates view model', () async {
      final fakeSource = FakeHealthSource();
      final binding = HealthSourceBinding(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.cellCount, equals(0));
      expect(fakeSource.snapshotQueryCount, equals(1));

      fakeSource.setSnapshot(
        HealthSnapshot(
          timestamp: DateTime.now(),
          cells: const [
            HealthCell(
              id: 'c-manual',
              providerId: 'prov',
              providerLabel: 'Provider',
              dimensionId: 'dim',
              dimensionLabel: 'Dim',
              state: HealthState.healthy,
            ),
          ],
          aggregateState: HealthState.healthy,
        ),
      );

      final vm = await binding.refresh();

      expect(fakeSource.snapshotQueryCount, equals(2));
      expect(vm.cellCount, equals(1));
      expect(binding.cellCount, equals(1));
      expect(binding.viewModel.cellById('c-manual'), isNotNull);

      binding.dispose();
    });

    test('handles empty snapshot and zero cells safely without throwing', () async {
      final emptySnapshot = HealthSnapshot(
        timestamp: DateTime(2026, 1, 1),
        cells: const [],
        aggregateState: HealthState.unknown,
      );

      final fakeSource = FakeHealthSource(
        initialSnapshot: emptySnapshot,
      );
      final binding = HealthSourceBinding(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.isEmpty, isTrue);
      expect(binding.cellCount, equals(0));
      expect(binding.cells, isEmpty);
      expect(binding.providers, isEmpty);
      expect(binding.aggregateState, equals(HealthState.unknown));
      expect(binding.viewModel.providerIds, isEmpty);
      expect(binding.viewModel.dimensionIds, isEmpty);
      expect(binding.viewModel.cellsForProvider('none'), isEmpty);
      expect(binding.viewModel.cellsForDimension('none'), isEmpty);
      expect(binding.viewModel.toProviderHealthCells(), isEmpty);
      expect(binding.viewModel.toProviderHealthProviders(), isEmpty);

      final emptyVm = HealthSourceViewModel.empty();
      expect(emptyVm.isEmpty, isTrue);
      expect(emptyVm.cellCount, equals(0));
      expect(emptyVm.aggregateState, equals(HealthState.unknown));

      binding.dispose();
    });

    test('dispose cancels stream subscription and closes broadcast controllers', () async {
      final fakeSource = FakeHealthSource();
      final binding = HealthSourceBinding(source: fakeSource);
      await Future<void>.delayed(Duration.zero);

      expect(binding.isDisposed, isFalse);

      binding.dispose();

      expect(binding.isDisposed, isTrue);
      expect(binding.status, equals(HealthSourceBindingStatus.disposed));

      // Subsequent source updates after disposal do not mutate binding
      fakeSource.updateCell(
        const HealthCell(
          id: 'after-dispose',
          providerId: 'p',
          providerLabel: 'P',
          dimensionId: 'd',
          dimensionLabel: 'D',
          state: HealthState.healthy,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(binding.cellCount, equals(0));

      // Refresh on disposed binding throws StateError
      expect(() => binding.refresh(), throwsStateError);
    });

    test('HealthSourceViewModel equality, copyWith, and lookup helpers', () {
      final time = DateTime(2026, 9, 2, 13, 0, 0);
      const cell1 = HealthCell(
        id: 'cell-1',
        providerId: 'openai',
        providerLabel: 'OpenAI',
        dimensionId: 'dim-1',
        dimensionLabel: 'Dimension 1',
        state: HealthState.healthy,
      );
      const cell2 = HealthCell(
        id: 'cell-2',
        providerId: 'anthropic',
        providerLabel: 'Anthropic',
        dimensionId: 'dim-2',
        dimensionLabel: 'Dimension 2',
        state: HealthState.degraded,
      );

      final vm1 = HealthSourceViewModel(
        timestamp: time,
        cells: const [cell1, cell2],
        aggregateState: HealthState.degraded,
        freshnessTtl: const Duration(seconds: 60),
        isStale: false,
      );

      final vm2 = HealthSourceViewModel(
        timestamp: time,
        cells: const [cell1, cell2],
        aggregateState: HealthState.degraded,
        freshnessTtl: const Duration(seconds: 60),
        isStale: false,
      );

      expect(vm1, equals(vm2));
      expect(vm1.hashCode, equals(vm2.hashCode));
      expect(vm1.toString(), contains('cells: 2'));

      final updated = vm1.copyWith(isStale: true);
      expect(updated.isStale, isTrue);
      expect(updated.isFresh, isFalse);
      expect(updated, isNot(equals(vm1)));

      expect(vm1.cellsForProvider('openai'), equals([cell1]));
      expect(vm1.cellsForProvider('anthropic'), equals([cell2]));
      expect(vm1.cellsForDimension('dim-1'), equals([cell1]));
      expect(vm1.cellsForDimension('dim-2'), equals([cell2]));
    });

    test('HealthSourceMappers converts all states and metadata bidirectionally', () {
      expect(
        HealthSourceMappers.healthStateToOperationalState(HealthState.healthy),
        equals(PrismOperationalState.healthy),
      );
      expect(
        HealthSourceMappers.healthStateToOperationalState(HealthState.degraded),
        equals(PrismOperationalState.degraded),
      );
      expect(
        HealthSourceMappers.healthStateToOperationalState(HealthState.unreachable),
        equals(PrismOperationalState.error),
      );
      expect(
        HealthSourceMappers.healthStateToOperationalState(HealthState.unknown),
        equals(PrismOperationalState.unverified),
      );
      expect(
        HealthSourceMappers.healthStateToOperationalState(
          HealthState.healthy,
          isStale: true,
        ),
        equals(PrismOperationalState.stale),
      );

      expect(
        HealthSourceMappers.operationalStateToHealthState(
          PrismOperationalState.healthy,
        ),
        equals(HealthState.healthy),
      );
      expect(
        HealthSourceMappers.operationalStateToHealthState(
          PrismOperationalState.degraded,
        ),
        equals(HealthState.degraded),
      );
      expect(
        HealthSourceMappers.operationalStateToHealthState(
          PrismOperationalState.error,
        ),
        equals(HealthState.unreachable),
      );
      expect(
        HealthSourceMappers.operationalStateToHealthState(
          PrismOperationalState.unverified,
        ),
        equals(HealthState.unknown),
      );

      const cell = HealthCell(
        id: 'cell-meta',
        providerId: 'p',
        providerLabel: 'Provider',
        dimensionId: 'd',
        dimensionLabel: 'Dimension',
        state: HealthState.healthy,
        latency: Duration(milliseconds: 45),
        metadata: {'meta': 'zone-a'},
      );

      final prismCell = HealthSourceMappers.cellToProviderHealthCell(cell);
      expect(prismCell.id, equals('cell-meta'));
      expect(prismCell.meta, equals('zone-a'));
      expect(prismCell.latency, equals(const Duration(milliseconds: 45)));
      expect(prismCell.operationalState, equals(PrismOperationalState.healthy));
    });
  });
}
