import 'dart:async';
import 'package:flutter/material.dart';

import '../models/monitor_device.dart';
import '../services/rooms_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RoomsService service = RoomsService();
  List<MonitorDevice> devices = [];
  Timer? timer;

  Future<void> loadData() async {
    try {
      final result = await service.fetchRooms();
      if (!mounted) return;
      setState(() => devices = result);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    loadData();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => loadData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normal = devices.where((d) => d.status == 'NORMAL').length;
    final alerts = devices.length - normal;
    final real = devices.where((d) => d.mode == DeviceMode.real).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Liquid Monitor'),
        actions: [
          Icon(Icons.circle, color: devices.isNotEmpty ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('System Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            statCard('Normal', '$normal', Icons.check_circle, Colors.green),
            const SizedBox(width: 8),
            statCard('Alerts', '$alerts', Icons.warning, Colors.red),
            const SizedBox(width: 8),
            statCard('Sensors', '$real', Icons.sensors, Colors.blue),
          ]),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('ESP8266 Network'),
              subtitle: Text('${devices.length} monitoring nodes connected'),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Live Bottles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...devices.map((d) => Card(
                child: ListTile(
                  leading: Icon(
                    Icons.local_drink,
                    color: d.status == 'NORMAL' ? Colors.green : Colors.red,
                  ),
                  title: Text(d.name),
                  subtitle: Text('${d.liquid}\nLevel: ${d.level.toStringAsFixed(0)}% | ${d.status}'),
                  isThreeLine: true,
                ),
              )),
        ],
      ),
    );
  }
}
