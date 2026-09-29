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
    // Commands prepared for Arduino Serial Monitor scenarios:
    // N1 = Room 1 normal, L1 = low, C1 = critical
    // The real ESP8266 will provide Room 1 data.
    // Additional simulated rooms will use this logic.
  }
}
