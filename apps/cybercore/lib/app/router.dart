import 'package:go_router/go_router.dart';
import 'cybercore_shell.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/registry/registry_page.dart';
import '../features/tasks/tasks_page.dart';
import '../features/audit/audit_page.dart';
import '../features/governance/governance_page.dart';

/// Canonical [GoRouter] for CyberCore.
///
/// All route paths are defined here. Product surfaces use
/// [StatefulShellRoute] so each branch preserves its navigation state
/// behind the persistent [CyberCoreShell] sidebar + topbar.
///
/// Route contract:
///   /              → redirects to /dashboard
///   /dashboard     → System health overview
///   /registry      → Capabilities & providers catalog
///   /tasks         → Execution board (lane view)
///   /audit         → Audit trail timeline
///   /governance    → Diagnostics & compliance
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CyberCoreShell(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        // Registry
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/registry',
              builder: (context, state) => const RegistryPage(),
            ),
          ],
        ),
        // Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksPage(),
            ),
          ],
        ),
        // Audit
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/audit',
              builder: (context, state) => const AuditPage(),
            ),
          ],
        ),
        // Governance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/governance',
              builder: (context, state) => const GovernancePage(),
            ),
          ],
        ),
      ],
    ),
    // Root redirect
    GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
  ],
);
