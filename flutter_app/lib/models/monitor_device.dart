enum DeviceMode { real, simulation }

class MonitorDevice {
  final String name;
  final String liquid;
  final double level;
  final String status;
  final DeviceMode mode;

  MonitorDevice({
    required this.name,
    required this.liquid,
    required this.level,
    required this.status,
    required this.mode,
  });

  factory MonitorDevice.fromReal({
    required String name,
    required String liquid,
    required double level,
    required String status,
  }) {
    return MonitorDevice(
      name: name,
      liquid: liquid,
      level: level,
      status: status,
      mode: DeviceMode.real,
    );
  }
}
