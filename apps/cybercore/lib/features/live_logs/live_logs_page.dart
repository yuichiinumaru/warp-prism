import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// Pilot C — `/live-logs` fixture-backed log viewer.
///
/// Uses [PrismLogViewer]. Includes redacted lines and provider health summary.
class LiveLogsPage extends StatefulWidget {
  const LiveLogsPage({super.key});

  @override
  State<LiveLogsPage> createState() => _LiveLogsPageState();
}

class _LiveLogsPageState extends State<LiveLogsPage> {
  LiveLogsFixture? _logs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final logs = await FixtureLoader.loadLiveLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
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
        title: 'Loading live logs...',
        subtitle: 'Streaming fixture log buffer',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load logs',
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

    final fixture = _logs!;
    if (fixture.data.isEmpty) {
      return const PrismStateSurface.empty(
        title: 'No log entries',
        subtitle: 'Live log fixtures are empty',
      );
    }

    final errors = fixture.data.where((e) => e.level == 'error').length;
    final redacted = fixture.data.where((e) => e.redacted).length;

    final entries = fixture.data.map((e) {
      return PrismLogEntry(
        id: e.id,
        timestamp: e.timestamp,
        severity: _mapSeverity(e.level),
        source: e.serverName,
        message: e.message,
        detail: e.error ?? (e.redacted ? 'redacted=true' : null),
      );
    }).toList();

    return PrismErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: PrismStoryPanel(
              title: 'Live Logs',
              subtitle:
                  'Pilot C — fixture-backed read-only mirror of /live-logs',
              icon: Icons.terminal_outlined,
              accentColor: PrismColors.accentCyan,
              insights: [
                PrismStoryInsight(
                  text: '${fixture.totalCount} entries',
                  detail: '$errors errors, $redacted redacted',
                  value: '${fixture.totalCount}',
                  color: PrismColors.accentCyan,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PrismSpacing.md),
              child: ClipRect(
                child: PrismLogViewer(
                  entries: entries,
                  autoScroll: false,
                  showAbsoluteTime: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PrismLogSeverity _mapSeverity(String level) {
    switch (level) {
      case 'error':
        return PrismLogSeverity.error;
      case 'warn':
        return PrismLogSeverity.warning;
      case 'info':
        return PrismLogSeverity.info;
      default:
        return PrismLogSeverity.debug;
    }
  }
}
