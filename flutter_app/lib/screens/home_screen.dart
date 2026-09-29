import 'dart:async';
import 'package:flutter/material.dart';

import '../models/liquid_status.dart';
import '../services/esp_service.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EspService service = EspService();
  LiquidStatus? data;
  Timer? timer;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    update();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => update(),
    );
  }

  Future<void> update() async {
    try {
      final result = await service.getStatus();
      if (!mounted) return;

      setState(() {
        data = result;
        connected = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => connected = false);
    }
  }

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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Monitor'),
        centerTitle: true,
        actions: [
          Icon(
            connected ? Icons.wifi : Icons.wifi_off,
            color: connected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Text(
                    '${data!.level.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                LinearProgressIndicator(
                  value: (data!.level / 100).clamp(0, 1),
                  minHeight: 20,
                ),

                const SizedBox(height: 25),

                Center(
                  child: Chip(
                    label: Text(
                      data!.status,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor:
                        statusColor(data!.status).withOpacity(0.2),
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bottle Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Text('Liquid: ${data!.liquid}'),
                        Text('Capacity: ${data!.capacityMl} mL'),
                        Text('Warning: ${data!.warningThreshold}%'),
                        Text('Critical: ${data!.criticalThreshold}%'),
                      ],
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Sensor ADC'),
                    trailing: Text('${data!.adc}'),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Bottle QR'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QrScreen(
                          espService: service,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
