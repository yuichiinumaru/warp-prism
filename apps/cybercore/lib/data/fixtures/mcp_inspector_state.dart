/// MCP inspector fixture model for Pilot B `/mcp-inspector`.
///
/// Read-only connection snapshot — no live STDIO execution.
class McpInspectorTool {
  final String uuid;
  final String name;
  final String description;
  final bool enabled;
  final String mcpServerUuid;

  const McpInspectorTool({
    required this.uuid,
    required this.name,
    required this.description,
    required this.enabled,
    required this.mcpServerUuid,
  });

  factory McpInspectorTool.fromJson(Map<String, dynamic> json) {
    return McpInspectorTool(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      enabled: json['enabled'] as bool,
      mcpServerUuid: json['mcp_server_uuid'] as String,
    );
  }
}

class McpInspectorState {
  final String connectionStatus;
  final String selectedServerUuid;
  final String selectedServerName;
  final List<McpInspectorTool> tools;
  final String? notes;

  const McpInspectorState({
    required this.connectionStatus,
    required this.selectedServerUuid,
    required this.selectedServerName,
    required this.tools,
    this.notes,
  });

  factory McpInspectorState.fromJson(Map<String, dynamic> json) {
    final rawTools = json['tools'] as List<dynamic>? ?? const [];
    return McpInspectorState(
      connectionStatus: json['connectionStatus'] as String,
      selectedServerUuid: json['selectedServerUuid'] as String,
      selectedServerName: json['selectedServerName'] as String,
      tools: rawTools
          .cast<Map<String, dynamic>>()
          .map(McpInspectorTool.fromJson)
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}
