/// Registry agent fixture model.
///
/// Maps to CyberCore entity: AgentProfile.
class RegistryAgent {
  final String id;
  final String name;
  final String? model;
  final String mode;
  final String description;
  final List<String> skills;
  final List<String> workflows;
  final String operationalState;

  const RegistryAgent({
    required this.id,
    required this.name,
    this.model,
    required this.mode,
    required this.description,
    required this.skills,
    required this.workflows,
    required this.operationalState,
  });

  factory RegistryAgent.fromJson(Map<String, dynamic> json) {
    return RegistryAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      model: json['model'] as String?,
      mode: json['mode'] as String,
      description: json['description'] as String,
      skills: (json['skills'] as List<dynamic>).cast<String>(),
      workflows: (json['workflows'] as List<dynamic>).cast<String>(),
      operationalState: json['operationalState'] as String,
    );
  }
}
