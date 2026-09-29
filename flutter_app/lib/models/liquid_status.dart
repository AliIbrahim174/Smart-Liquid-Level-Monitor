class LiquidStatus {
  final int adc;
  final double level;
  final String status;
  final String liquid;
  final int capacityMl;
  final double warningThreshold;
  final double criticalThreshold;

  LiquidStatus({
    required this.adc,
    required this.level,
    required this.status,
    required this.liquid,
    required this.capacityMl,
    required this.warningThreshold,
    required this.criticalThreshold,
  });

  factory LiquidStatus.fromJson(Map<String, dynamic> json) {
    return LiquidStatus(
      adc: json['adc'] ?? 0,
      level: (json['level'] ?? 0).toDouble(),
      status: json['status'] ?? 'UNKNOWN',
      liquid: json['liquid'] ?? 'Not Set',
      capacityMl: json['capacityMl'] ?? 0,
      warningThreshold: (json['warningThreshold'] ?? 25).toDouble(),
      criticalThreshold: (json['criticalThreshold'] ?? 10).toDouble(),
    );
  }
}
