import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_cybercore/data/fixtures/fixtures.dart';
import 'package:warp_prism_cybercore/features/mcp_servers/mcp_servers_page.dart';
import 'package:warp_prism_cybercore/features/providers/providers_page.dart';
import 'package:warp_prism_cybercore/main.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  testWidgets('CyberCore app renders pilot shell with sidebar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(WarpPrismCyberCoreApp());
    await tester.pump();

    // App shell should render with CyberCore branding
    expect(find.text('CyberCore'), findsWidgets);

    // Task 1108 pilot nav items (A/B/C)
    expect(find.text('Providers'), findsWidgets);
    expect(find.text('MCP Servers'), findsWidgets);
    expect(find.text('MCP Inspector'), findsWidgets);
    expect(find.text('Live Logs'), findsWidgets);

    // Observatory-proxy labels must not be primary nav
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Registry'), findsNothing);
    expect(find.text('Governance'), findsNothing);

    // Read-Only Observatory subtitle should be present
    expect(find.text('Read-Only Observatory'), findsOneWidget);
  });

  testWidgets('CyberCore app shows loading state on providers pilot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(WarpPrismCyberCoreApp());
    // Single pump keeps the first async frame in loading state.
    await tester.pump();

    expect(find.text('Loading providers...'), findsOneWidget);
  });

  testWidgets('CyberCore navigates to Live Logs pilot branch', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(WarpPrismCyberCoreApp());
    await tester.pump();

    await tester.tap(find.text('Live Logs').first);
    await tester.pump();

    // Either loading or settled pilot content is acceptable for navigation proof.
    final loading = find.text('Loading live logs...');
    final settled = find.textContaining('Pilot C');
    expect(
      loading.evaluate().isNotEmpty || settled.evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected Live Logs loading or pilot content after nav',
    );
  });

  testWidgets('Providers page renders injected fixture success content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<ProviderConnection>> loader() async => const [
      ProviderConnection(
        id: 'prov-openai-prod',
        provider: 'openai',
        name: 'OpenAI Production',
        authType: 'apikey',
        priority: 1,
        defaultModel: 'gpt-4o',
        isActive: true,
        testStatus: 'success',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: ProvidersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Provider Connections'), findsWidgets);
    expect(find.text('OpenAI Production'), findsOneWidget);
  });

  testWidgets('Providers page renders error non-happy state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<ProviderConnection>> loader() async {
      throw StateError('fixture missing');
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: ProvidersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed to load providers'), findsOneWidget);
  });

  testWidgets('Providers page renders empty non-happy state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<ProviderConnection>> loader() async => const [];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: ProvidersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No provider connections'), findsOneWidget);
    expect(find.text('Provider fixtures are empty'), findsOneWidget);
  });

  // --- Pilot B: MCP Servers list ---

  testWidgets('MCP Servers page renders injected fixture success content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<McpServer>> loader() async => const [
      McpServer(
        uuid: 'mcp-fs-1',
        name: 'Filesystem Server',
        description: 'Local FS tools',
        type: 'stdio',
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-filesystem'],
        env: {},
        createdAt: '2026-01-01T00:00:00Z',
        headers: {},
        errorStatus: 'NONE',
        status: 'ACTIVE',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: McpServersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('MCP Servers'), findsWidgets);
    expect(find.text('Filesystem Server'), findsOneWidget);
    expect(find.textContaining('Pilot B'), findsOneWidget);
  });

  testWidgets('MCP Servers page renders empty non-happy state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<McpServer>> loader() async => const [];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: McpServersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No MCP servers installed'), findsOneWidget);
    expect(find.text('MCP server fixtures are empty'), findsOneWidget);
  });

  testWidgets('MCP Servers page renders error non-happy state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<List<McpServer>> loader() async {
      throw StateError('mcp fixture missing');
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: PrismColors.obsidianDeep,
        ),
        home: Scaffold(body: McpServersPage(loader: loader)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed to load MCP servers'), findsOneWidget);
  });
}
