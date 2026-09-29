class BottleConfig {
  final String id;
  final String liquid;
  final int capacityMl;
  final double warningThreshold;
  final double criticalThreshold;

  BottleConfig({
    required this.id,
    required this.liquid,
    required this.capacityMl,
    required this.warningThreshold,
    required this.criticalThreshold,
  });

  factory BottleConfig.fromJson(Map<String, dynamic> json) {
    return BottleConfig(
      id: json['id'] ?? '',
      liquid: json['liquid'] ?? 'Unknown',
      capacityMl: json['capacityMl'] ?? 0,
      warningThreshold: (json['warningThreshold'] ?? 25).toDouble(),
      criticalThreshold: (json['criticalThreshold'] ?? 10).toDouble(),
    );
  }

  Map<String, String> toRequest() {
    return {
      'liquid': liquid,
      'capacity': capacityMl.toString(),
      'warning': warningThreshold.toString(),
      'critical': criticalThreshold.toString(),
    };
  }
}
