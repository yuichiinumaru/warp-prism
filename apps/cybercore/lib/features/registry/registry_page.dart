import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// CyberCore Registry route — capabilities & providers catalog.
///
/// Displays agents, skills, and workflows using DSDataTable with
/// DSStatusCell renderers from warp_prism_ui.
/// All data is loaded from fixtures — no live API calls.
class RegistryPage extends StatefulWidget {
  const RegistryPage({super.key});

  @override
  State<RegistryPage> createState() => _RegistryPageState();
}

class _RegistryPageState extends State<RegistryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<RegistryAgent>? _agents;
  List<RegistrySkill>? _skills;
  List<RegistryWorkflow>? _workflows;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final agents = await FixtureLoader.loadRegistryAgents();
      final skills = await FixtureLoader.loadRegistrySkills();
      final workflows = await FixtureLoader.loadRegistryWorkflows();
      if (mounted) {
        setState(() {
          _agents = agents;
          _skills = skills;
          _workflows = workflows;
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
        title: 'Loading registry...',
        subtitle: 'Fetching capabilities, providers, and workflows from fixtures',
      );
    }

    if (_error != null) {
      return DSStateSurface.error(
        title: 'Failed to load registry',
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

    return DSErrorBoundary(
      child: Column(
        children: [
          // Tab bar
          Container(
            color: DSColors.obsidianBase,
            child: TabBar(
              controller: _tabController,
              labelColor: DSColors.accentCyan,
              unselectedLabelColor: DSColors.textTertiary,
              indicatorColor: DSColors.accentCyan,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smart_toy_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('Agents (${_agents!.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.extension_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('Skills (${_skills!.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_tree_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('Workflows (${_workflows!.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAgentsTable(),
                _buildSkillsTable(),
                _buildWorkflowsTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsTable() {
    return DSDataTable(
      columns: const [
        DSDataColumn(id: 'name', label: 'Agent', sortable: true),
        DSDataColumn(id: 'mode', label: 'Mode', sortable: true, width: 100),
        DSDataColumn(id: 'model', label: 'Model', width: 200),
        DSDataColumn(id: 'skills', label: 'Skills'),
        DSDataColumn(id: 'status', label: 'Status', width: 120),
      ],
      rows: _agents!.map((agent) {
        final state = _parseOperationalState(agent.operationalState);
        return DSDataRow(
          id: agent.id,
          cells: {
            'name': agent.name,
            'mode': agent.mode,
            'model': agent.model ?? '—',
            'skills': agent.skills.join(', '),
            'status': state,
          },
          onTap: () {},
        );
      }).toList(),
      showPagination: false,
    );
  }

  Widget _buildSkillsTable() {
    return DSDataTable(
      columns: const [
        DSDataColumn(id: 'name', label: 'Skill', sortable: true),
        DSDataColumn(id: 'triggers', label: 'Triggers'),
        DSDataColumn(id: 'subSkills', label: 'Sub-skills'),
        DSDataColumn(id: 'canonicality', label: 'Canonicality', width: 140),
      ],
      rows: _skills!.map((skill) {
        return DSDataRow(
          id: skill.id,
          cells: {
            'name': skill.name,
            'triggers': skill.triggers.isEmpty ? '(none)' : skill.triggers.join(', '),
            'subSkills': skill.subSkills.isEmpty ? '—' : skill.subSkills.join(', '),
            'canonicality': skill.canonicality,
          },
          onTap: () {},
        );
      }).toList(),
      showPagination: false,
    );
  }

  Widget _buildWorkflowsTable() {
    return DSDataTable(
      columns: const [
        DSDataColumn(id: 'name', label: 'Workflow', sortable: true),
        DSDataColumn(id: 'kind', label: 'Kind', sortable: true, width: 120),
        DSDataColumn(id: 'skills', label: 'Skills'),
        DSDataColumn(id: 'agents', label: 'Agents'),
        DSDataColumn(id: 'triggers', label: 'Triggers'),
      ],
      rows: _workflows!.map((workflow) {
        return DSDataRow(
          id: workflow.id,
          cells: {
            'name': workflow.name,
            'kind': workflow.kind,
            'skills': workflow.skills.join(', '),
            'agents': workflow.agents.join(', '),
            'triggers': workflow.triggers.isEmpty ? '(none)' : workflow.triggers.join(', '),
          },
          onTap: () {},
        );
      }).toList(),
      showPagination: false,
    );
  }

  DSOperationalState _parseOperationalState(String state) {
    return DSOperationalState.values.firstWhere(
      (s) => s.name == state,
      orElse: () => DSOperationalState.healthy,
    );
  }
}
