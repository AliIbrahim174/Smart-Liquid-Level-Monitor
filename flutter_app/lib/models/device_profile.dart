class DeviceProfile {
  final String name;
  final String id;
  final String liquid;
  final int capacityMl;
  final double warningThreshold;
  final double criticalThreshold;

  // Current state for dashboard simulation/monitoring
  final double level;
  final String status;
  final bool isReal;

  DeviceProfile({
    required this.name,
    required this.id,
    required this.liquid,
    required this.capacityMl,
    required this.warningThreshold,
    required this.criticalThreshold,
    this.level = 0,
    this.status = 'UNKNOWN',
    this.isReal = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'liquid': liquid,
        'capacityMl': capacityMl,
        'warningThreshold': warningThreshold,
        'criticalThreshold': criticalThreshold,
        'level': level,
        'status': status,
        'isReal': isReal,
      };

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      name: json['name'] ?? 'Unknown Device',
      id: json['id'] ?? '',
      liquid: json['liquid'] ?? 'Not Set',
      capacityMl: json['capacityMl'] ?? 0,
      warningThreshold: (json['warningThreshold'] ?? 25).toDouble(),
      criticalThreshold: (json['criticalThreshold'] ?? 10).toDouble(),
      level: (json['level'] ?? 0).toDouble(),
      status: json['status'] ?? 'UNKNOWN',
      isReal: json['isReal'] ?? false,
    );
  }
}
