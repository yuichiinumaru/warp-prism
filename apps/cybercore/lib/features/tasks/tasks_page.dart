import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// CyberCore Tasks route — execution board.
///
/// Displays tasks in a lane board using DSLaneBoard with DSTaskCard
/// from warp_prism_ui. All data is loaded from fixtures.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<TaskExecution>? _tasks;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await FixtureLoader.loadTaskBoard();
      if (mounted) {
        setState(() {
          _tasks = tasks;
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
      return const DSStateSurface.loading(
        title: 'Loading task board...',
        subtitle: 'Fetching execution lanes from fixtures',
      );
    }

    if (_error != null) {
      return DSStateSurface.error(
        title: 'Failed to load tasks',
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

    final lanes = _buildLanes();

    return DSErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lane board header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg, DSSpacing.md, DSSpacing.lg, 0,
            ),
            child: Row(
              children: [
                const DSText.headingMedium(
                  'Execution Board',
                  color: DSColors.textPrimary,
                ),
                const SizedBox(width: DSSpacing.md),
                DSBadge.count(
                  _tasks!.length,
                  color: DSColors.accentCyan,
                ),
                const Spacer(),
                const DSText.bodySmall(
                  'Read-only — drag disabled',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),

          // Lane board
          Expanded(
            child: DSLaneBoard(
              lanes: lanes,
              onTaskTap: (_) {
                // Read-only: no task selection action
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DSLane> _buildLanes() {
    final laneOrder = [
      '00-planning',
      '01-open',
      '02-doing',
      '03-review',
      '04-completed',
    ];

    final laneLabels = {
      '00-planning': 'Planning',
      '01-open': 'Open',
      '02-doing': 'Doing',
      '03-review': 'Review',
      '04-completed': 'Completed',
    };

    return laneOrder.map((laneId) {
      final laneTasks = _tasks!
          .where((t) => t.lane == laneId)
          .map((t) => DSLaneTask(
                id: int.tryParse(t.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                title: t.title,
                priority: t.priority,
                owner: t.owner,
                proofState: t.proofState,
                reviewScore: t.reviewScore?.toInt(),
                linkedSkills: null,
                dependencyCount: t.dependsOn.isEmpty ? null : t.dependsOn.length,
              ))
          .toList();

      return DSLane(
        id: laneId,
        label: laneLabels[laneId] ?? laneId,
        tasks: laneTasks,
      );
    }).toList();
  }
}
