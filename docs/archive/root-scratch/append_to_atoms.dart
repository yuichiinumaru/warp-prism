
  group('DSSparkline contract', () {
    testWidgets('renders correctly with data', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DSSparkline(data: [0, 1, 2]))));
      expect(find.byType(DSSparkline), findsOneWidget);
    });
  });
