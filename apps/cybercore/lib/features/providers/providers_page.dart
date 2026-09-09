import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot A — `/providers` provider connections list.
///
/// Fixture-backed, read-only. Mutations are not wired.
///
/// [loader] overrides the default [FixtureLoader.loadProviders] for tests.
class ProvidersPage extends StatefulWidget {
  final Future<List<ProviderConnection>> Function()? loader;

  const ProvidersPage({super.key, this.loader});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  List<ProviderConnection>? _providers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final load = widget.loader ?? FixtureLoader.loadProviders;
      final providers = await load();
      if (mounted) {
        setState(() {
          _providers = providers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PrismStateSurface.loading(
        title: 'Loading providers...',
        subtitle: 'Fetching provider connections from fixtures',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load providers',
        subtitle: _error,
        onAction: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _loadData();
        },
      );
    }

    final providers = _providers!;
    if (providers.isEmpty) {
      return const PrismStateSurface.empty(
        title: 'No provider connections',
        subtitle: 'Provider fixtures are empty',
      );
    }

    final active = providers.where((p) => p.isActive).length;
    final errored = providers.where((p) => p.testStatus == 'error').length;

    return PrismErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: PrismStoryPanel(
                    title: 'Provider Connections',
                    subtitle:
                        'Pilot A — fixture-backed read-only mirror of /providers',
                    icon: Icons.cloud_outlined,
                    accentColor: PrismTheme.accentOf(context),
                    insights: [
                      PrismStoryInsight(
                        text: '${providers.length} connections',
                        detail: '$active active, $errored with test errors',
                        value: '${providers.length}',
                        color: PrismTheme.accentOf(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PrismSpacing.md),
                // Read-only affordance — navigates to new form fixture only.
                OutlinedButton.icon(
                  onPressed: () => context.go('/providers/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New (read-only)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PrismTheme.accentOf(context),
                    side: const BorderSide(color: PrismColors.borderSubtle),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 960
                    ? 960.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    height: constraints.maxHeight,
                    child: PrismDataTable(
                      columns: const [
                        PrismDataColumn(
                          id: 'name',
                          label: 'Name',
                          sortable: true,
                        ),
                        PrismDataColumn(
                          id: 'provider',
                          label: 'Provider',
                          sortable: true,
                          width: 120,
                        ),
                        PrismDataColumn(
                          id: 'authType',
                          label: 'Auth',
                          width: 100,
                        ),
                        PrismDataColumn(
                          id: 'defaultModel',
                          label: 'Default Model',
                          width: 200,
                        ),
                        PrismDataColumn(
                          id: 'priority',
                          label: 'Priority',
                          width: 90,
                        ),
                        PrismDataColumn(
                          id: 'status',
                          label: 'Status',
                          width: 120,
                        ),
                      ],
                      rows: providers.map((p) {
                        return PrismDataRow(
                          id: p.id,
                          cells: {
                            'name': p.name,
                            'provider': p.provider,
                            'authType': p.authType,
                            'defaultModel': p.defaultModel ?? '—',
                            'priority': '${p.priority}',
                            'status': p.operationalLabel,
                          },
                          onTap: () => context.go('/providers/${p.id}'),
                        );
                      }).toList(),
                      showPagination: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
