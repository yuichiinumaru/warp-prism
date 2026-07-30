import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('DSUptimeBar contract', () {
    testWidgets('renders track and percentage label by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSUptimeBar(uptimePercent: 0.999))));
      expect(find.text('100%'), findsOneWidget);
    });
    testWidgets('hides label when showLabel=false', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSUptimeBar(uptimePercent: 0.95, showLabel: false))));
      expect(find.text('95%'), findsNothing);
    });
  });

  group('DSHealthCard contract', () {
    testWidgets('renders serviceName and state', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSHealthCard(
        serviceName: 'Redis API',
        operationalState: DSOperationalState.running,
      ))));
      expect(find.text('Redis API'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
    });
  });

  group('DSShimmer contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSShimmer(height: 50))));
      expect(find.byType(DSShimmer), findsOneWidget);
    });
  });

  group('DSSkeletonTextLine contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSSkeletonTextLine(height: 10, widthFactor: 0.5))));
      expect(find.byType(DSSkeletonTextLine), findsOneWidget);
    });
  });

  group('DSSkeletonCard contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSSkeletonCard())));
      expect(find.byType(DSSkeletonCard), findsOneWidget);
    });
  });

  group('DSSkeletonTableRows contract', () {
    testWidgets('renders row count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSSkeletonTableRows(rowCount: 3))));
      expect(find.byType(DSSkeletonTableRows), findsOneWidget);
    });
  });

  group('DSToast contract', () {
    testWidgets('renders toast entry', (tester) async {
      final entry = DSToastEntry(
        id: '1',
        severity: DSToastSeverity.success,
        title: 'Success',
      );
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: DSToast(entry: entry))));
      expect(find.text('Success'), findsOneWidget);
    });
  });

  group('DSToastManager contract', () {
    testWidgets('renders wrapper', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSToastManager(child: Text('App')))));
      expect(find.text('App'), findsOneWidget);
    });
  });

  group('DSDraggableCard contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSDraggableCard(
        card: DSTaskCard(taskId: 1, title: 'Task', priority: 'high', owner: 'Test'),
        laneId: 'a',
        index: 0,
      ))));
      expect(find.text('Task'), findsOneWidget);
    });
  });

  group('DSDropTarget contract', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSDropTarget(
        laneId: 'b',
        taskCount: 1,
        child: Text('Drop zone'),
      ))));
      expect(find.text('Drop zone'), findsOneWidget);
    });
  });
}
