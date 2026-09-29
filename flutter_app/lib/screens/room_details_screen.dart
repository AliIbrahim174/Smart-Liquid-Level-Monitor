import 'package:flutter/material.dart';

import '../models/monitor_device.dart';

class RoomDetailsScreen extends StatelessWidget {
  final MonitorDevice device;

  const RoomDetailsScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.liquid,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _item('Mode', device.mode == DeviceMode.real ? 'REAL SENSOR' : 'SIMULATION'),
            _item('Current Level', '${device.level.toStringAsFixed(0)}%'),
            _item('Capacity', '${device.capacityMl} mL'),
            _item('Remaining', '${device.remainingMl} mL'),
            _item('Status', device.status),
            const SizedBox(height: 30),
            LinearProgressIndicator(value: device.level / 100),
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
          Text(title, style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
