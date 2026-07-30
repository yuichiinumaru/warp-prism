/// LLM provider connection fixture model.
///
/// Mirrors live `ProviderConnectionSchema` (cybernetics-core
/// `packages/zod-types/src/llm-providers.zod.ts`) for Pilot A `/providers`.
class ProviderConnection {
  final String id;
  final String provider;
  final String name;
  final String authType;
  final int priority;
  final int? globalPriority;
  final String? defaultModel;
  final bool isActive;
  final String? testStatus;
  final String? lastTested;
  final String? lastError;
  final String? lastErrorAt;
  final String? errorCode;
  final String? createdAt;
  final String? updatedAt;

  const ProviderConnection({
    required this.id,
    required this.provider,
    required this.name,
    required this.authType,
    required this.priority,
    this.globalPriority,
    this.defaultModel,
    required this.isActive,
    this.testStatus,
    this.lastTested,
    this.lastError,
    this.lastErrorAt,
    this.errorCode,
    this.createdAt,
    this.updatedAt,
  });

  /// Derived operational label for UI status cells.
  String get operationalLabel {
    if (!isActive) return 'inactive';
    switch (testStatus) {
      case 'success':
        return 'active';
      case 'error':
        return 'error';
      default:
        return 'untested';
    }
  }

  factory ProviderConnection.fromJson(Map<String, dynamic> json) {
    return ProviderConnection(
      id: json['id'] as String,
      provider: json['provider'] as String,
      name: json['name'] as String,
      authType: json['authType'] as String,
      priority: (json['priority'] as num).toInt(),
      globalPriority: (json['globalPriority'] as num?)?.toInt(),
      defaultModel: json['defaultModel'] as String?,
      isActive: json['isActive'] as bool,
      testStatus: json['testStatus'] as String?,
      lastTested: json['lastTested'] as String?,
      lastError: json['lastError'] as String?,
      lastErrorAt: json['lastErrorAt'] as String?,
      errorCode: json['errorCode'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
