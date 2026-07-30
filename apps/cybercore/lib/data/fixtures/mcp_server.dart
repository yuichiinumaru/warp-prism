/// MCP server fixture model.
///
/// Mirrors live `McpServerSchema` (cybernetics-core
/// `packages/zod-types/src/mcp-servers.zod.ts`) for Pilot B `/mcp-servers`.
/// [status] is a pilot convenience field (ACTIVE/INACTIVE) used by the UI.
class McpServer {
  final String uuid;
  final String name;
  final String? description;
  final String type;
  final String? command;
  final List<String> args;
  final Map<String, String> env;
  final String? url;
  final String createdAt;
  final String? bearerToken;
  final Map<String, String> headers;
  final String? userId;
  final String errorStatus;
  final String status;

  const McpServer({
    required this.uuid,
    required this.name,
    this.description,
    required this.type,
    this.command,
    required this.args,
    required this.env,
    this.url,
    required this.createdAt,
    this.bearerToken,
    required this.headers,
    this.userId,
    required this.errorStatus,
    required this.status,
  });

  bool get isActive => status == 'ACTIVE';
  bool get hasError => errorStatus == 'ERROR';

  String get operationalLabel {
    if (hasError) return 'error';
    if (!isActive) return 'inactive';
    return 'active';
  }

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      command: json['command'] as String?,
      args: (json['args'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      env: _stringMap(json['env']),
      url: json['url'] as String?,
      createdAt: json['created_at'] as String,
      bearerToken: json['bearerToken'] as String?,
      headers: _stringMap(json['headers']),
      userId: json['user_id'] as String?,
      errorStatus: (json['error_status'] as String?) ?? 'NONE',
      status: (json['status'] as String?) ?? 'ACTIVE',
    );
  }

  static Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
}
