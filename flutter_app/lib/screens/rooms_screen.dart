import 'package:flutter/material.dart';

import '../models/monitor_device.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  Color statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return Colors.green;
      case 'LOW':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simulation devices for demonstration.
    // Later these values will come from Arduino IDE commands.
    final devices = [
      MonitorDevice(
        name: 'Room 1 - Real Sensor',
        liquid: 'Normal Saline',
        level: 72,
        status: 'NORMAL',
        mode: DeviceMode.real,
      ),
      MonitorDevice(
        name: 'Room 2 - Simulation',
        liquid: 'Glucose 5%',
        level: 18,
        status: 'LOW',
        mode: DeviceMode.simulation,
      ),
      MonitorDevice(
        name: 'Room 3 - Simulation',
        liquid: 'Medication',
        level: 5,
        status: 'CRITICAL',
        mode: DeviceMode.simulation,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Monitored Rooms'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];

          return Card(
            child: ListTile(
              title: Text(device.name),
              subtitle: Text(
                '${device.liquid}\n${device.level.toStringAsFixed(0)}%  ${device.status}',
              ),
              isThreeLine: true,
              trailing: Icon(
                device.mode == DeviceMode.real
                    ? Icons.sensors
                    : Icons.code,
                color: statusColor(device.status),
              ),
            ),
          );
        },
      ),
    );
  }
}
