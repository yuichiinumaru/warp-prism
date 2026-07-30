import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_cybercore/data/fixtures/fixtures.dart';

void main() {
  group('Pilot fixture model parsing', () {
    test('ProviderConnection.fromJson parses correctly', () {
      final json = {
        'id': 'prov-openai-prod',
        'provider': 'openai',
        'name': 'OpenAI Production',
        'authType': 'apikey',
        'priority': 1,
        'globalPriority': 10,
        'defaultModel': 'gpt-4o',
        'isActive': true,
        'testStatus': 'success',
        'lastTested': '2026-07-09T10:15:00Z',
        'lastError': null,
        'lastErrorAt': null,
        'errorCode': null,
        'createdAt': '2026-05-01T12:00:00Z',
        'updatedAt': '2026-07-09T10:15:00Z',
      };

      final provider = ProviderConnection.fromJson(json);
      expect(provider.id, 'prov-openai-prod');
      expect(provider.provider, 'openai');
      expect(provider.isActive, true);
      expect(provider.operationalLabel, 'active');
      expect(provider.defaultModel, 'gpt-4o');
    });

    test('ProviderConnection operationalLabel for error and inactive', () {
      final error = ProviderConnection.fromJson({
        'id': 'p1',
        'provider': 'azure',
        'name': 'Azure',
        'authType': 'apikey',
        'priority': 1,
        'isActive': true,
        'testStatus': 'error',
      });
      expect(error.operationalLabel, 'error');

      final inactive = ProviderConnection.fromJson({
        'id': 'p2',
        'provider': 'google',
        'name': 'Google',
        'authType': 'oauth',
        'priority': 2,
        'isActive': false,
        'testStatus': 'unknown',
      });
      expect(inactive.operationalLabel, 'inactive');

      final untested = ProviderConnection.fromJson({
        'id': 'p3',
        'provider': 'groq',
        'name': 'Groq',
        'authType': 'apikey',
        'priority': 3,
        'isActive': true,
        'testStatus': 'unknown',
      });
      expect(untested.operationalLabel, 'untested');
    });

    test('McpServer.fromJson parses correctly', () {
      final json = {
        'uuid': 'mcp-filesystem-01',
        'name': 'filesystem',
        'description': 'Local filesystem',
        'type': 'STDIO',
        'command': 'npx',
        'args': ['-y', '@modelcontextprotocol/server-filesystem'],
        'env': {'FOO': 'bar'},
        'url': null,
        'created_at': '2026-05-12T10:00:00Z',
        'bearerToken': null,
        'headers': {},
        'user_id': null,
        'error_status': 'NONE',
        'status': 'ACTIVE',
      };

      final server = McpServer.fromJson(json);
      expect(server.uuid, 'mcp-filesystem-01');
      expect(server.type, 'STDIO');
      expect(server.isActive, true);
      expect(server.hasError, false);
      expect(server.operationalLabel, 'active');
      expect(server.args.length, 2);
      expect(server.env['FOO'], 'bar');
    });

    test('McpServer operationalLabel for error and inactive', () {
      final errored = McpServer.fromJson({
        'uuid': 'u1',
        'name': 'postgres',
        'description': null,
        'type': 'STDIO',
        'command': null,
        'args': <String>[],
        'env': <String, String>{},
        'url': null,
        'created_at': '2026-01-01T00:00:00Z',
        'bearerToken': null,
        'headers': <String, String>{},
        'user_id': null,
        'error_status': 'ERROR',
        'status': 'ACTIVE',
      });
      expect(errored.operationalLabel, 'error');

      final inactive = McpServer.fromJson({
        'uuid': 'u2',
        'name': 'memory',
        'description': null,
        'type': 'SSE',
        'command': null,
        'args': <String>[],
        'env': <String, String>{},
        'url': 'https://example.com',
        'created_at': '2026-01-01T00:00:00Z',
        'bearerToken': null,
        'headers': <String, String>{},
        'user_id': null,
        'error_status': 'NONE',
        'status': 'INACTIVE',
      });
      expect(inactive.operationalLabel, 'inactive');
    });

    test('LiveLogEntry.fromJson parses correctly', () {
      final json = {
        'id': 'log-001',
        'timestamp': '2026-07-09T11:58:01.000Z',
        'serverName': 'filesystem',
        'level': 'info',
        'message': 'Listed /workspace',
        'error': null,
        'redacted': false,
      };

      final entry = LiveLogEntry.fromJson(json);
      expect(entry.id, 'log-001');
      expect(entry.serverName, 'filesystem');
      expect(entry.level, 'info');
      expect(entry.redacted, false);
      expect(entry.timestamp.isUtc, true);
    });

    test('LiveLogsFixture.fromJson parses response envelope', () {
      final json = {
        'success': true,
        'totalCount': 2,
        'data': [
          {
            'id': 'log-001',
            'timestamp': '2026-07-09T11:58:01.000Z',
            'serverName': 'filesystem',
            'level': 'info',
            'message': 'ok',
            'redacted': false,
          },
          {
            'id': 'log-002',
            'timestamp': '2026-07-09T11:59:00.000Z',
            'serverName': 'github',
            'level': 'error',
            'message': 'fail',
            'error': 'timeout',
            'redacted': true,
          },
        ],
      };

      final fixture = LiveLogsFixture.fromJson(json);
      expect(fixture.success, true);
      expect(fixture.totalCount, 2);
      expect(fixture.data.length, 2);
      expect(fixture.data.last.redacted, true);
      expect(fixture.data.last.error, 'timeout');
    });

    test('McpInspectorState.fromJson parses correctly', () {
      final json = {
        'connectionStatus': 'connected',
        'selectedServerUuid': 'mcp-filesystem-01',
        'selectedServerName': 'filesystem',
        'tools': [
          {
            'uuid': 'tool-list-dir',
            'name': 'list_directory',
            'description': 'List files',
            'enabled': true,
            'mcp_server_uuid': 'mcp-filesystem-01',
          },
        ],
        'notes': 'fixture',
      };

      final state = McpInspectorState.fromJson(json);
      expect(state.connectionStatus, 'connected');
      expect(state.tools.length, 1);
      expect(state.tools.first.enabled, true);
      expect(state.selectedServerName, 'filesystem');
    });
  });
}
