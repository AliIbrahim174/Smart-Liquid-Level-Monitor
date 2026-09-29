import 'package:flutter/material.dart';

import '../models/monitor_device.dart';

class RoomDetailsScreen extends StatelessWidget {
  final MonitorDevice device;

  const RoomDetailsScreen({super.key, required this.device});

  Color statusColor() {
    switch (device.status) {
      case 'CRITICAL':
        return Colors.red;
      case 'LOW':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.liquid,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.circle, color: statusColor(), size: 14),
                        const SizedBox(width: 8),
                        Text(device.status,
                            style: TextStyle(
                                color: statusColor(),
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _item('Device Mode',
                        device.mode == DeviceMode.real ? 'REAL SENSOR' : 'SIMULATION'),
                    _item('Bottle Capacity', '${device.capacityMl} mL'),
                    _item('Remaining Volume', '${device.remainingMl} mL'),
                    _item('Current Level', '${device.level.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bottle Level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: device.level / 100,
                      minHeight: 14,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('QR Assignment'),
                subtitle: const Text('Bottle identity ready for future QR linking'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sensors),
                title: const Text('Sensor Health'),
                subtitle: const Text('Monitoring connection active'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
