import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot B — `/mcp-servers` installed MCP servers list.
///
/// [loader] overrides the default [FixtureLoader.loadMcpServers] for tests.
class McpServersPage extends StatefulWidget {
  final Future<List<McpServer>> Function()? loader;

  const McpServersPage({super.key, this.loader});

  @override
  State<McpServersPage> createState() => _McpServersPageState();
}

class _McpServersPageState extends State<McpServersPage> {
  List<McpServer>? _servers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final load = widget.loader ?? FixtureLoader.loadMcpServers;
      final servers = await load();
      if (mounted) {
        setState(() {
          _servers = servers;
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
        title: 'Loading MCP servers...',
        subtitle: 'Fetching installed servers from fixtures',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load MCP servers',
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

    final servers = _servers!;
    if (servers.isEmpty) {
      return const PrismStateSurface.empty(
        title: 'No MCP servers installed',
        subtitle: 'MCP server fixtures are empty',
      );
    }

    final active = servers.where((s) => s.isActive).length;
    final errored = servers.where((s) => s.hasError).length;

    return PrismErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: PrismStoryPanel(
              title: 'MCP Servers',
              subtitle:
                  'Pilot B — fixture-backed read-only mirror of /mcp-servers',
              icon: Icons.dns_outlined,
              accentColor: PrismTheme.accentOf(context),
              insights: [
                PrismStoryInsight(
                  text: '${servers.length} servers',
                  detail: '$active active, $errored with errors',
                  value: '${servers.length}',
                  color: PrismTheme.accentOf(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 800
                    ? 800.0
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
                          id: 'type',
                          label: 'Type',
                          sortable: true,
                          width: 140,
                        ),
                        PrismDataColumn(
                          id: 'description',
                          label: 'Description',
                        ),
                        PrismDataColumn(
                          id: 'status',
                          label: 'Status',
                          width: 120,
                        ),
                      ],
                      rows: servers.map((s) {
                        return PrismDataRow(
                          id: s.uuid,
                          cells: {
                            'name': s.name,
                            'type': s.type,
                            'description': s.description ?? '—',
                            'status': s.operationalLabel,
                          },
                          onTap: () => context.go('/mcp-servers/${s.uuid}'),
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
