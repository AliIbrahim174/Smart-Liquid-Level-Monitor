import 'package:flutter/material.dart';

import '../models/monitor_device.dart';
import '../services/simulation_service.dart';

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
    final simulation = SimulationService();

    final devices = simulation.simulatedDevices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Liquid Monitor'),
      ),
      body: Column(
        children: [
          if (devices.any((d) => d.status == 'LOW' || d.status == 'CRITICAL'))
            Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Active Alerts'),
                subtitle: Text(
                  '${devices.where((d) => d.status != 'NORMAL').length} room(s) need attention',
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      device.mode == DeviceMode.real
                          ? Icons.sensors
                          : Icons.developer_mode,
                      color: statusColor(device.status),
                    ),
                    title: Text(device.name),
                    subtitle: Text(
                      '${device.liquid}\n'
                      'Level: ${device.level.toStringAsFixed(0)}%\n'
                      'Status: ${device.status}\n'
                      'Mode: ${device.mode == DeviceMode.real ? 'REAL SENSOR' : 'SIMULATION'}',
                    ),
                    isThreeLine: true,
                    trailing: Icon(
                      Icons.circle,
                      color: statusColor(device.status),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
