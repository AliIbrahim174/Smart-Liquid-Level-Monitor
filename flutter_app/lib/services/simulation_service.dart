import '../models/device_profile.dart';

class SimulationService {
  final List<DeviceProfile> simulatedDevices = [
    DeviceProfile(
      name: 'Room 2',
      id: 'SIM002',
      liquid: 'Glucose 5%',
      capacityMl: 1000,
      warningThreshold: 25,
      criticalThreshold: 10,
      level: 80,
      status: 'NORMAL',
    ),
    DeviceProfile(
      name: 'Room 3',
      id: 'SIM003',
      liquid: 'Normal Saline',
      capacityMl: 500,
      warningThreshold: 25,
      criticalThreshold: 10,
      level: 5,
      status: 'CRITICAL',
    ),
  ];

  void setScenario(String command) {
    command = command.trim().toUpperCase();

    if (command.length < 2) return;

    final state = command[0];
    final roomNumber = int.tryParse(command.substring(1));

    if (roomNumber == null) return;

    final index = simulatedDevices.indexWhere(
      (device) => device.name == 'Room $roomNumber',
    );

    if (index == -1) return;

    double level;
    String status;

    switch (state) {
      case 'N':
        level = 80;
        status = 'NORMAL';
        break;
      case 'L':
        level = 20;
        status = 'LOW';
        break;
      case 'C':
        level = 5;
        status = 'CRITICAL';
        break;
      default:
        return;
    }

    final old = simulatedDevices[index];

    simulatedDevices[index] = DeviceProfile(
      name: old.name,
      id: old.id,
      liquid: old.liquid,
      capacityMl: old.capacityMl,
      warningThreshold: old.warningThreshold,
      criticalThreshold: old.criticalThreshold,
      level: level,
      status: status,
    );
  }
}
