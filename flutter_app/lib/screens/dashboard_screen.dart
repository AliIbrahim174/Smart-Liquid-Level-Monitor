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
      setState(() {
        devices = result;
      });
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

  @override
  Widget build(BuildContext context) {
    final alerts = devices.where((d) => d.status != 'NORMAL').length;
    final real = devices.where((d) => d.mode == DeviceMode.real).length;

    return Scaffold(
      appBar: AppBar(title: const Text('System Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Liquid Monitoring Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: const Text('Monitoring Nodes'),
              subtitle: Text('$real Real Sensor + ${devices.length - real} Simulation Rooms'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                alerts > 0 ? Icons.warning : Icons.check_circle,
                color: alerts > 0 ? Colors.red : Colors.green,
              ),
              title: const Text('Active Alerts'),
              subtitle: Text(
                alerts == 0
                    ? 'All rooms are normal'
                    : '$alerts room(s) need attention',
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Network'),
              subtitle: const Text('ESP8266 WiFi monitoring'),
            ),
          ),
          if (devices.isNotEmpty)
            Card(
              child: Column(
                children: devices.map((d) {
                  return ListTile(
                    title: Text(d.name),
                    subtitle: Text('${d.liquid} - ${d.level.toStringAsFixed(0)}% - ${d.status}'),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
