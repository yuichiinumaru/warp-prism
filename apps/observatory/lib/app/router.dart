import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import 'pages/overview_page.dart';
import 'pages/map_page.dart';
import 'pages/operate_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/governance/presentation/governance_overview_page.dart';
import 'pages/asset_detail_page.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../features/workspace_snapshot/workspace_snapshot_page.dart';

/// Canonical [GoRouter] for ASW Observatory.
///
/// All route names and paths are defined here. Product surfaces use
/// [StatefulShellRoute] so each branch preserves its navigation state
/// behind the persistent [AppShell] sidebar + topbar.
///
/// Route contract:
///   /              → redirects to /overview
///   /overview      → Overview dashboard
///   /map           → Asset graph (Map workspace)
///   /operate       → Task lanes (Operate workspace)
///   /history       → Changelog timeline (History workspace)
///   /governance    → Provenance & staleness (Governance workspace)
///   /assets/:assetId → Universal asset detail (canonical route)
///   /asset/:id       → Legacy alias → redirects to /assets/:id
///   /design-system → Design System Gallery (DS proof surface)
///   /workspace-snapshot                        → Workspace snapshot (base)
///   /workspace-snapshot/agent/:id              → Deep-link to agent detail
///   /workspace-snapshot/skill/:id              → Deep-link to skill detail
///   /workspace-snapshot/workflow/:id           → Deep-link to workflow detail
///   /workspace-snapshot/task/:id               → Deep-link to task detail
///   /workspace-snapshot/changelog/:id          → Deep-link to changelog detail
final appRouter = GoRouter(
  initialLocation: '/design-system',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Overview
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/overview',
              builder: (context, state) => const OverviewPageShell(),
            ),
          ],
        ),
        // Map
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPageShell(),
            ),
          ],
        ),
        // Operate
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/operate',
              builder: (context, state) => const OperatePage(),
            ),
          ],
        ),
        // History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryWorkspacePage(),
            ),
          ],
        ),
        // Governance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/governance',
              builder: (context, state) => const GovernanceOverviewPage(),
            ),
          ],
        ),
      ],
    ),
    // Asset detail — canonical route (outside shell for focused inspection)
    //
    // Route contract:
    //   Path parameter: assetId (stable, derived from normalized backbone)
    //   Deep-link restore: URL-driven, no widget-local parsing
    //   Close/back: navigates to /overview (or origin surface if recorded)
    //   Unknown asset: renders fallback without crash or navigation loop
    GoRoute(
      path: '/assets/:assetId',
      builder: (context, state) {
        final assetId = state.pathParameters['assetId'] ?? 'unknown';
        return AssetDetailPage(assetId: assetId);
      },
    ),
    // Legacy alias — redirects to canonical /assets/:id
    GoRoute(
      path: '/asset/:id',
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return '/assets/$id';
      },
    ),
    // Design System Gallery — DS proof surface, outside shell
    GoRoute(
      path: '/design-system',
      builder: (context, state) => const DesignSystemGalleryPage(),
    ),
    // Workspace Snapshot — read-only filesystem scanner, outside shell
    GoRoute(
      path: '/workspace-snapshot',
      builder: (context, state) => const WorkspaceSnapshotPage(),
    ),
    // Deep-link routes for individual asset inspection
    GoRoute(
      path: '/workspace-snapshot/agent/:id',
      builder: (context, state) {
        final id = 'agent:${state.pathParameters['id'] ?? 'unknown'}';
        return WorkspaceSnapshotPage(assetId: id);
      },
    ),
    GoRoute(
      path: '/workspace-snapshot/skill/:id',
      builder: (context, state) {
        final id = 'skill:${state.pathParameters['id'] ?? 'unknown'}';
        return WorkspaceSnapshotPage(assetId: id);
      },
    ),
    GoRoute(
      path: '/workspace-snapshot/workflow/:id',
      builder: (context, state) {
        final id = 'workflow:${state.pathParameters['id'] ?? 'unknown'}';
        return WorkspaceSnapshotPage(assetId: id);
      },
    ),
    GoRoute(
      path: '/workspace-snapshot/task/:id',
      builder: (context, state) {
        final id = 'task:${state.pathParameters['id'] ?? 'unknown'}';
        return WorkspaceSnapshotPage(assetId: id);
      },
    ),
    GoRoute(
      path: '/workspace-snapshot/changelog/:id',
      builder: (context, state) {
        final id = 'changelog:${state.pathParameters['id'] ?? 'unknown'}';
        return WorkspaceSnapshotPage(assetId: id);
      },
    ),
    // Root redirect
    GoRoute(
      path: '/',
      redirect: (context, state) => '/overview',
    ),
  ],
);
