import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_cybercore/main.dart';

void main() {
  testWidgets('CyberCore app renders app shell with sidebar', (tester) async {
    await tester.pumpWidget(const WarpPrismCyberCoreApp());
    await tester.pump();
    await tester.pump();

    // App shell should render with CyberCore branding
    expect(find.text('CyberCore'), findsWidgets);

    // Sidebar navigation items should be present
    // DSShellResponsive renders both expanded and collapsed sidebars,
    // so navigation labels appear multiple times
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Registry'), findsWidgets);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Audit'), findsWidgets);
    expect(find.text('Governance'), findsWidgets);

    // Read-Only Observatory subtitle should be present
    expect(find.text('Read-Only Observatory'), findsOneWidget);
  });

  testWidgets('CyberCore app shows loading state on dashboard', (tester) async {
    await tester.pumpWidget(const WarpPrismCyberCoreApp());
    await tester.pump();
    await tester.pump();

    // Dashboard is the initial route — should show loading state
    // since fixture loading is async and we haven't settled
    expect(find.text('Loading dashboard...'), findsOneWidget);
  });
}
