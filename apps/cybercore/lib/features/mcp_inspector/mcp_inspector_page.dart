import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot B — `/mcp-inspector` fixture-backed inspector shell.
///
/// No live STDIO execution. Connection status and tools are fixed fixtures.
class McpInspectorPage extends StatefulWidget {
  const McpInspectorPage({super.key});

  @override
  State<McpInspectorPage> createState() => _McpInspectorPageState();
}

class _McpInspectorPageState extends State<McpInspectorPage> {
  McpInspectorState? _state;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final state = await FixtureLoader.loadMcpInspector();
      if (mounted) {
        setState(() {
          _state = state;
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
        title: 'Loading MCP inspector...',
        subtitle: 'Restoring fixture connection snapshot',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load inspector',
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

    final state = _state!;
    final enabled = state.tools.where((t) => t.enabled).length;

    return PrismErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: PrismStoryPanel(
              title: 'MCP Inspector',
              subtitle:
                  state.notes ??
                  'Pilot B — fixture connection; no live STDIO in Warp Prism',
              icon: Icons.bug_report_outlined,
              accentColor: PrismColors.accentGold,
              insights: [
                PrismStoryInsight(
                  text: 'Server: ${state.selectedServerName}',
                  detail: 'Connection: ${state.connectionStatus}',
                  value: state.connectionStatus,
                  color: PrismColors.accentGold,
                ),
                PrismStoryInsight(
                  text: '${state.tools.length} tools',
                  detail: '$enabled enabled',
                  value: '$enabled',
                  color: PrismColors.accentViolet,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PrismSpacing.lg),
            child: Row(
              children: [
                PrismBadge(
                  label: state.connectionStatus,
                  color: state.connectionStatus == 'connected'
                      ? PrismColors.statusSuccess
                      : PrismColors.statusWarning,
                ),
                const SizedBox(width: PrismSpacing.sm),
                PrismText.labelMedium(
                  state.selectedServerUuid,
                  color: PrismColors.textTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: PrismSpacing.md),
          Expanded(
            child: state.tools.isEmpty
                ? const PrismStateSurface.empty(
                    title: 'No tools in fixture',
                    subtitle: 'Inspector tool list is empty',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final tableWidth = constraints.maxWidth < 720
                          ? 720.0
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
                                label: 'Tool',
                                sortable: true,
                              ),
                              PrismDataColumn(
                                id: 'description',
                                label: 'Description',
                              ),
                              PrismDataColumn(
                                id: 'enabled',
                                label: 'Enabled',
                                width: 100,
                              ),
                            ],
                            rows: state.tools.map((t) {
                              return PrismDataRow(
                                id: t.uuid,
                                cells: {
                                  'name': t.name,
                                  'description': t.description,
                                  'enabled': t.enabled ? 'yes' : 'no',
                                },
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
