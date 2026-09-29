import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Dashboard')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liquid Monitoring Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Card(child: ListTile(title: Text('Monitoring Nodes'), subtitle: Text('1 Real Sensor + Simulation Rooms'))),
            Card(child: ListTile(title: Text('Alert System'), subtitle: Text('LOW and CRITICAL monitoring enabled'))),
            Card(child: ListTile(title: Text('Network'), subtitle: Text('ESP8266 WiFi monitoring'))),
          ],
        ),
      ),
    );
  }
}
