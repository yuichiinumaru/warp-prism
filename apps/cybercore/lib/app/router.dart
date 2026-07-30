import 'package:go_router/go_router.dart';
import 'cybercore_shell.dart';
import '../features/providers/providers_page.dart';
import '../features/providers/provider_detail_page.dart';
import '../features/providers/provider_new_page.dart';
import '../features/mcp_servers/mcp_servers_page.dart';
import '../features/mcp_servers/mcp_server_detail_page.dart';
import '../features/mcp_inspector/mcp_inspector_page.dart';
import '../features/live_logs/live_logs_page.dart';

/// Creates a fresh [GoRouter] for CyberCore pilot shell.
///
/// A factory (not a shared singleton) so widget tests do not share
/// navigation state across [pumpWidget] invocations.
///
/// Route contract aligned to Task 1108 pilots A/B/C:
///   /                  → redirects to /providers
///   /providers         → Pilot A — provider connections list
///   /providers/new     → Pilot A nested — read-only create form
///   /providers/:id     → Pilot A nested — connection detail
///   /mcp-servers       → Pilot B — installed MCP servers
///   /mcp-servers/:uuid → Pilot B nested — server detail
///   /mcp-inspector     → Pilot B — inspector (no live STDIO)
///   /live-logs         → Pilot C — live log buffer
///
/// Observatory-proxy paths (/dashboard, /registry, /tasks, /audit,
/// /governance) are intentionally not registered as primary nav.
GoRouter createAppRouter() => GoRouter(
  initialLocation: '/providers',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CyberCoreShell(navigationShell: navigationShell);
      },
      branches: [
        // Pilot A — Providers
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/providers',
              builder: (context, state) => const ProvidersPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const ProviderNewPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ProviderDetailPage(
                    providerId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Pilot B — MCP Servers
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mcp-servers',
              builder: (context, state) => const McpServersPage(),
              routes: [
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) =>
                      McpServerDetailPage(uuid: state.pathParameters['uuid']!),
                ),
              ],
            ),
          ],
        ),
        // Pilot B — MCP Inspector
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mcp-inspector',
              builder: (context, state) => const McpInspectorPage(),
            ),
          ],
        ),
        // Pilot C — Live Logs
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/live-logs',
              builder: (context, state) => const LiveLogsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/', redirect: (context, state) => '/providers'),
  ],
);

/// Default app router for production entry. Prefer [createAppRouter] in tests.
final appRouter = createAppRouter();
