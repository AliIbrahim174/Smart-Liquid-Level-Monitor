import 'package:flutter/material.dart';
import '../services/alert_history_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = AlertHistoryService.instance.alerts;

    return Scaffold(
      appBar: AppBar(title: const Text('Alert History')),
      body: alerts.isEmpty
          ? const Center(child: Text('No alerts yet'))
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${alert.type} - ${alert.deviceName}'),
                    subtitle: Text('${alert.message}\n${alert.timestamp}'),
                  ),
                );
              },
            ),
    );
  }
}
