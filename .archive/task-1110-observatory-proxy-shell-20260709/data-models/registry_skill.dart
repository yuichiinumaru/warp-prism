/// Registry skill fixture model.
///
/// Maps to CyberCore entity: Capability.
class RegistrySkill {
  final String id;
  final String name;
  final List<String> triggers;
  final List<String> subSkills;
  final String canonicality;

  const RegistrySkill({
    required this.id,
    required this.name,
    required this.triggers,
    required this.subSkills,
    required this.canonicality,
  });

  factory RegistrySkill.fromJson(Map<String, dynamic> json) {
    return RegistrySkill(
      id: json['id'] as String,
      name: json['name'] as String,
      triggers: (json['triggers'] as List<dynamic>).cast<String>(),
      subSkills: (json['subSkills'] as List<dynamic>).cast<String>(),
      canonicality: json['canonicality'] as String,
    );
  }

  bool get hasTriggers => triggers.isNotEmpty;
}
