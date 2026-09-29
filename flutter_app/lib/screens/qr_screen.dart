import 'package:flutter/material.dart';

import '../models/bottle_config.dart';
import '../services/esp_service.dart';

class QrScreen extends StatelessWidget {
  final EspService espService;

  const QrScreen({super.key, required this.espService});

  // Temporary parser example.
  // Camera scanner will replace this in the next step.
  BottleConfig parseQr(String text) {
    final parts = text.split('|');

    return BottleConfig(
      id: parts[0],
      liquid: parts[1],
      capacityMl: int.parse(parts[2]),
      warningThreshold: double.parse(parts[3]),
      criticalThreshold: double.parse(parts[4]),
    );
  }

  Future<void> sendExample() async {
    final config = parseQr(
      'IV001|Normal Saline|500|25|10',
    );

    await espService.sendBottleConfig(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Bottle')),
      body: Center(
        child: ElevatedButton(
          onPressed: sendExample,
          child: const Text('Send Test Bottle Config'),
        ),
      ),
    );
  }
}
