/// Registry workflow fixture model.
///
/// Maps to CyberCore entity: WorkflowDefinition.
class RegistryWorkflow {
  final String id;
  final String name;
  final String kind;
  final List<String> skills;
  final List<String> agents;
  final List<String> triggers;

  const RegistryWorkflow({
    required this.id,
    required this.name,
    required this.kind,
    required this.skills,
    required this.agents,
    required this.triggers,
  });

  factory RegistryWorkflow.fromJson(Map<String, dynamic> json) {
    return RegistryWorkflow(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      skills: (json['skills'] as List<dynamic>).cast<String>(),
      agents: (json['agents'] as List<dynamic>).cast<String>(),
      triggers: (json['triggers'] as List<dynamic>).cast<String>(),
    );
  }

  bool get isOrphan => agents.isEmpty && skills.isEmpty;
}
