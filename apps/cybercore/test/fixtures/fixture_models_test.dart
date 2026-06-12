import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_cybercore/data/fixtures/fixtures.dart';

void main() {
  group('Fixture model parsing', () {
    test('DashboardSummary.fromJson parses correctly', () {
      final json = {
        'agentMetrics': {'total': 9, 'healthy': 7, 'degraded': 2},
        'skillMetrics': {'total': 13, 'withTriggers': 10, 'noTriggers': 3},
        'workflowMetrics': {'total': 11, 'active': 8, 'orphaned': 3},
        'executionMetrics': {
          'planning': 3,
          'open': 5,
          'doing': 5,
          'review': 4,
          'completed': 5,
        },
        'recentActivity': {
          'total': 36,
          'lastWeek': 12,
          'types': {'feature': 14, 'fix': 8},
        },
      };

      final summary = DashboardSummary.fromJson(json);
      expect(summary.agentMetrics.total, 9);
      expect(summary.agentMetrics.healthy, 7);
      expect(summary.agentMetrics.degraded, 2);
      expect(summary.skillMetrics.total, 13);
      expect(summary.workflowMetrics.orphaned, 3);
      expect(summary.executionMetrics.totalTasks, 22);
      expect(summary.recentActivity.types['feature'], 14);
      expect(summary.totalEntities, 55);
    });

    test('RegistryAgent.fromJson parses correctly', () {
      final json = {
        'id': 'agent:builders',
        'name': 'builders',
        'model': 'claude-sonnet-4-20250514',
        'mode': 'code',
        'description': 'Primary implementation agent',
        'skills': ['flutter-harness'],
        'workflows': ['onboard'],
        'operationalState': 'healthy',
      };

      final agent = RegistryAgent.fromJson(json);
      expect(agent.id, 'agent:builders');
      expect(agent.name, 'builders');
      expect(agent.skills, ['flutter-harness']);
      expect(agent.operationalState, 'healthy');
    });

    test('RegistrySkill.fromJson parses correctly', () {
      final json = {
        'id': 'skill:flutter-harness',
        'name': 'flutter-harness',
        'triggers': ['flutter', 'dart'],
        'subSkills': ['flutter-test'],
        'canonicality': 'parentCanonical',
      };

      final skill = RegistrySkill.fromJson(json);
      expect(skill.id, 'skill:flutter-harness');
      expect(skill.hasTriggers, true);
      expect(skill.canonicality, 'parentCanonical');
    });

    test('RegistrySkill.hasTriggers is false when empty', () {
      final json = {
        'id': 'skill:empty',
        'name': 'empty',
        'triggers': <String>[],
        'subSkills': <String>[],
        'canonicality': 'childLocal',
      };

      final skill = RegistrySkill.fromJson(json);
      expect(skill.hasTriggers, false);
    });

    test('RegistryWorkflow.fromJson parses correctly', () {
      final json = {
        'id': 'workflow:onboard',
        'name': 'onboard',
        'kind': 'ritual',
        'skills': ['development-methodologies'],
        'agents': ['builders'],
        'triggers': ['task-start'],
      };

      final workflow = RegistryWorkflow.fromJson(json);
      expect(workflow.id, 'workflow:onboard');
      expect(workflow.isOrphan, false);
    });

    test('RegistryWorkflow.isOrphan when no agents and skills', () {
      final json = {
        'id': 'workflow:orphan',
        'name': 'orphan',
        'kind': 'maintenance',
        'skills': <String>[],
        'agents': <String>[],
        'triggers': <String>[],
      };

      final workflow = RegistryWorkflow.fromJson(json);
      expect(workflow.isOrphan, true);
    });

    test('TaskExecution.fromJson parses correctly', () {
      final json = {
        'id': 'T001',
        'title': 'Test task',
        'lane': '02-doing',
        'priority': 'P0',
        'owner': 'builders',
        'proofState': 'partial',
        'reviewScore': 8.5,
        'dependsOn': ['T000'],
        'operationalState': 'running',
      };

      final task = TaskExecution.fromJson(json);
      expect(task.id, 'T001');
      expect(task.laneName, 'doing');
      expect(task.reviewScore, 8.5);
      expect(task.dependsOn.length, 1);
    });

    test('TaskExecution.fromJson handles null optional fields', () {
      final json = {
        'id': 'T002',
        'title': 'Test task 2',
        'lane': '00-planning',
        'proofState': 'none',
        'dependsOn': <String>[],
        'operationalState': 'pending',
      };

      final task = TaskExecution.fromJson(json);
      expect(task.priority, null);
      expect(task.owner, null);
      expect(task.reviewScore, null);
    });

    test('AuditEvent.fromJson parses correctly', () {
      final json = {
        'id': 'CL001',
        'date': '2026-06-08T14:30:00Z',
        'project': 'warp-prism',
        'task': 'T010',
        'type': 'feature',
        'impact': 'high',
        'skills': ['flutter-harness'],
        'body': 'Test event',
      };

      final event = AuditEvent.fromJson(json);
      expect(event.id, 'CL001');
      expect(event.type, 'feature');
      expect(event.displayDate, contains('2026-06-08'));
    });

    test('GovernanceDiagnostics.fromJson parses correctly', () {
      final json = {
        'orphanWorkflows': ['workflow-a'],
        'noTriggerSkills': ['skill-b'],
        'unverifiedTasks': [
          {'taskId': 'T001', 'title': 'Test', 'priority': 'P0'},
        ],
        'canonicalityBoundary': {'parentCanonical': 5, 'childLocal': 8},
        'fanInHotspots': [
          {'skillName': 'flutter-harness', 'referenceCount': 8},
        ],
      };

      final diag = GovernanceDiagnostics.fromJson(json);
      expect(diag.orphanWorkflows.length, 1);
      expect(diag.noTriggerSkills.length, 1);
      expect(diag.unverifiedTasks.length, 1);
      expect(diag.unverifiedTasks.first.taskId, 'T001');
      expect(diag.canonicalityBoundary['parentCanonical'], 5);
      expect(diag.fanInHotspots.first.referenceCount, 8);
      expect(diag.totalIssues, 3);
    });
  });
}
