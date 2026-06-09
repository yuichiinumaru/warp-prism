import 'dart:convert';
import 'package:flutter/services.dart';
import 'dashboard_summary.dart';
import 'registry_agent.dart';
import 'registry_skill.dart';
import 'registry_workflow.dart';
import 'task_execution.dart';
import 'audit_event.dart';
import 'governance_diagnostics.dart';

/// Loads CyberCore fixture data from bundled JSON assets.
///
/// All fixtures are read-only. No network calls, no mutation.
/// Each loader method returns the parsed fixture or throws [FormatException]
/// if the JSON is malformed.
class FixtureLoader {
  static const _basePath = 'assets/cybercore_fixtures';

  /// Loads the dashboard summary fixture.
  static Future<DashboardSummary> loadDashboardSummary() async {
    final json = await _loadJson('$_basePath/dashboard_summary.json');
    return DashboardSummary.fromJson(json);
  }

  /// Loads the registry agents fixture.
  static Future<List<RegistryAgent>> loadRegistryAgents() async {
    final list = await _loadJsonList('$_basePath/registry_agents.json');
    return list.map(RegistryAgent.fromJson).toList();
  }

  /// Loads the registry skills fixture.
  static Future<List<RegistrySkill>> loadRegistrySkills() async {
    final list = await _loadJsonList('$_basePath/registry_skills.json');
    return list.map(RegistrySkill.fromJson).toList();
  }

  /// Loads the registry workflows fixture.
  static Future<List<RegistryWorkflow>> loadRegistryWorkflows() async {
    final list = await _loadJsonList('$_basePath/registry_workflows.json');
    return list.map(RegistryWorkflow.fromJson).toList();
  }

  /// Loads the task board fixture.
  static Future<List<TaskExecution>> loadTaskBoard() async {
    final list = await _loadJsonList('$_basePath/task_board.json');
    return list.map(TaskExecution.fromJson).toList();
  }

  /// Loads the audit trail fixture.
  static Future<List<AuditEvent>> loadAuditTrail() async {
    final list = await _loadJsonList('$_basePath/audit_trail.json');
    return list.map(AuditEvent.fromJson).toList();
  }

  /// Loads the governance diagnostics fixture.
  static Future<GovernanceDiagnostics> loadGovernanceDiagnostics() async {
    final json = await _loadJson('$_basePath/governance_diagnostics.json');
    return GovernanceDiagnostics.fromJson(json);
  }

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return json.decode(raw) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> _loadJsonList(String path) async {
    final raw = await rootBundle.loadString(path);
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}
