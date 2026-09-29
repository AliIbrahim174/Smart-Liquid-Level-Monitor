import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.water_drop),
              title: Text('Smart Liquid Monitor'),
              subtitle: Text('IV Fluid + Flow Monitoring System'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active),
              title: Text('Notifications'),
              subtitle: Text('Critical and low level alerts enabled'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.memory),
              title: Text('Hardware'),
              subtitle: Text('ESP8266 + C43 Level Sensor'),
            ),
          ),
        ],
      ),
    );
  }
}
