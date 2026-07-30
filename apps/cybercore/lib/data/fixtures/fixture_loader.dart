import 'dart:convert';
import 'package:flutter/services.dart';
import 'provider_connection.dart';
import 'mcp_server.dart';
import 'live_log_entry.dart';
import 'mcp_inspector_state.dart';

/// Loads CyberCore pilot fixture data from bundled JSON assets.
///
/// All fixtures are read-only. No network calls, no mutation.
/// Each loader method returns the parsed fixture or throws [FormatException]
/// if the JSON is malformed.
///
/// Pilot contract (Task 1108 A/B/C):
///   providers, mcp_servers, mcp_inspector, live_logs
class FixtureLoader {
  static const _basePath = 'assets/cybercore_fixtures';

  /// Loads provider connections (Pilot A).
  static Future<List<ProviderConnection>> loadProviders() async {
    final list = await _loadJsonList('$_basePath/providers.json');
    return list.map(ProviderConnection.fromJson).toList();
  }

  /// Loads a single provider by id, or null if missing.
  static Future<ProviderConnection?> loadProviderById(String id) async {
    final all = await loadProviders();
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Loads MCP servers (Pilot B).
  static Future<List<McpServer>> loadMcpServers() async {
    final list = await _loadJsonList('$_basePath/mcp_servers.json');
    return list.map(McpServer.fromJson).toList();
  }

  /// Loads a single MCP server by uuid, or null if missing.
  static Future<McpServer?> loadMcpServerByUuid(String uuid) async {
    final all = await loadMcpServers();
    for (final s in all) {
      if (s.uuid == uuid) return s;
    }
    return null;
  }

  /// Loads MCP inspector connection snapshot (Pilot B).
  static Future<McpInspectorState> loadMcpInspector() async {
    final json = await _loadJson('$_basePath/mcp_inspector.json');
    return McpInspectorState.fromJson(json);
  }

  /// Loads live logs payload (Pilot C).
  static Future<LiveLogsFixture> loadLiveLogs() async {
    final json = await _loadJson('$_basePath/live_logs.json');
    return LiveLogsFixture.fromJson(json);
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
