import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot B nested — `/mcp-servers/:uuid` read-only detail.
class McpServerDetailPage extends StatefulWidget {
  final String uuid;

  const McpServerDetailPage({super.key, required this.uuid});

  @override
  State<McpServerDetailPage> createState() => _McpServerDetailPageState();
}

class _McpServerDetailPageState extends State<McpServerDetailPage> {
  McpServer? _server;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final server = await FixtureLoader.loadMcpServerByUuid(widget.uuid);
      if (mounted) {
        setState(() {
          _server = server;
          _loading = false;
          if (server == null) {
            _error = 'MCP server ${widget.uuid} not found in fixtures';
          }
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
        title: 'Loading MCP server...',
        subtitle: 'Resolving server fixture',
      );
    }

    if (_error != null || _server == null) {
      return PrismStateSurface.error(
        title: 'MCP server not found',
        subtitle: _error ?? 'Missing fixture',
        actionLabel: 'Back to MCP servers',
        onAction: () => context.go('/mcp-servers'),
      );
    }

    final s = _server!;
    return PrismErrorBoundary(
      child: ListView(
        padding: const EdgeInsets.all(PrismSpacing.lg),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/mcp-servers'),
                icon: const Icon(Icons.arrow_back),
                color: PrismColors.textSecondary,
                tooltip: 'Back to MCP servers',
              ),
              const SizedBox(width: PrismSpacing.sm),
              Expanded(
                child: PrismText.headingMedium(
                  s.name,
                  color: PrismColors.textPrimary,
                ),
              ),
              PrismBadge(
                label: s.operationalLabel,
                color: s.hasError
                    ? PrismColors.statusError
                    : (s.isActive
                          ? PrismColors.statusSuccess
                          : PrismColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: PrismSpacing.lg),
          _DetailRow(label: 'UUID', value: s.uuid),
          _DetailRow(label: 'Type', value: s.type),
          _DetailRow(label: 'Description', value: s.description ?? '—'),
          _DetailRow(label: 'Command', value: s.command ?? '—'),
          _DetailRow(
            label: 'Args',
            value: s.args.isEmpty ? '—' : s.args.join(' '),
          ),
          _DetailRow(label: 'URL', value: s.url ?? '—'),
          _DetailRow(label: 'Status', value: s.status),
          _DetailRow(label: 'Error status', value: s.errorStatus),
          _DetailRow(label: 'Bearer token', value: s.bearerToken ?? '—'),
          _DetailRow(
            label: 'Env keys',
            value: s.env.isEmpty ? '—' : s.env.keys.join(', '),
          ),
          _DetailRow(label: 'Created', value: s.createdAt),
          const SizedBox(height: PrismSpacing.lg),
          const PrismText.labelSmall(
            'Read-only fixture detail — secrets are redacted; no mutations.',
            color: PrismColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: PrismText.labelMedium(
              label,
              color: PrismColors.textTertiary,
            ),
          ),
          Expanded(
            child: PrismText.bodyMedium(value, color: PrismColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
