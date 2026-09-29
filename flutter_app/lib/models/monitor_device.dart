enum DeviceMode { real, simulation }

class MonitorDevice {
  final int id;
  final String name;
  final String liquid;
  final double level;
  final String status;
  final DeviceMode mode;
  final int capacityMl;

  MonitorDevice({
    required this.name,
    required this.liquid,
    required this.level,
    required this.status,
    required this.mode,
    this.capacityMl = 500,
  }) : id = name.hashCode;

  int get remainingMl => ((level / 100) * capacityMl).round();

  factory MonitorDevice.fromReal({
    required String name,
    required String liquid,
    required double level,
    required String status,
    int capacityMl = 500,
  }) {
    return MonitorDevice(
      name: name,
      liquid: liquid,
      level: level,
      status: status,
      capacityMl: capacityMl,
      mode: DeviceMode.real,
    );
  }
}
