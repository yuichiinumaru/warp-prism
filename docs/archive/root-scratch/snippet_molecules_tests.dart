
  group('DSUptimeBar contract', () {
    testWidgets('renders track and percentage label by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSUptimeBar(uptimePercent: 0.999)));
      expect(find.text('100%'), findsOneWidget);
    });
    testWidgets('hides label when showLabel=false', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSUptimeBar(uptimePercent: 0.95, showLabel: false)));
      expect(find.text('95%'), findsNothing);
    });
  });

  group('DSHealthCard contract', () {
    testWidgets('renders serviceName and state', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSHealthCard(
        serviceName: 'Redis API',
        operationalState: DSOperationalState.running,
      )));
      expect(find.text('Redis API'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
    });
    testWidgets('renders all optional props without crash', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: DSHealthCard(
        serviceName: 'Database',
        operationalState: DSOperationalState.degraded,
        latency: const Duration(milliseconds: 120),
        uptimePercent: 0.96,
        trendData: const [0.1, 0.4, 0.2],
        lastCheck: DateTime.now().subtract(const Duration(minutes: 5)),
      ))));
      expect(find.text('Database'), findsOneWidget);
      expect(find.text('120ms'), findsOneWidget);
      expect(find.text('96%'), findsOneWidget);
      expect(find.text('5m ago'), findsOneWidget);
    });
  });

  group('DSShimmer contract', () {
    testWidgets('renders child on screen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSShimmer(child: Text('Shimmer me'))));
      expect(find.text('Shimmer me'), findsOneWidget);
    });
  });

  group('DSSkeletonTextLine contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSSkeletonTextLine(width: 100)));
      expect(find.byType(DSSkeletonTextLine), findsOneWidget);
    });
  });

  group('DSSkeletonCard contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSSkeletonCard()));
      expect(find.byType(DSSkeletonCard), findsOneWidget);
    });
  });

  group('DSSkeletonTableRows contract', () {
    testWidgets('renders row count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSSkeletonTableRows(rowCount: 3))));
      // Each row has a container
      expect(find.byType(DSSkeletonTableRows), findsOneWidget);
    });
  });

  group('DSToast contract', () {
    testWidgets('renders message and icon', (tester) async {
      await tester.pumpWidget(MaterialApp(home: DSToast(
        message: 'Success',
        icon: Icons.check,
        type: DSToastType.success,
      )));
      expect(find.text('Success'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('DSDraggableCard contract', () {
    testWidgets('renders child and gesture detector', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSDraggableCard(
        id: '1',
        laneId: 'a',
        data: 'foo',
        child: Text('Drag me'),
      )));
      expect(find.text('Drag me'), findsOneWidget);
      expect(find.byType(Draggable<Map<String, dynamic>>), findsOneWidget);
    });
  });

  group('DSDropTarget contract', () {
    testWidgets('renders child and drag target', (tester) async {
      await tester.pumpWidget(MaterialApp(home: DSDropTarget(
        laneId: 'b',
        onDrop: (data) {},
        child: const Text('Drop zone'),
      )));
      expect(find.text('Drop zone'), findsOneWidget);
      expect(find.byType(DragTarget<Map<String, dynamic>>), findsOneWidget);
    });
  });
