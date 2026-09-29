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
    timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
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
    if (status == 'NORMAL') return Colors.green;
    if (status == 'LOW') return Colors.orange;
    if (status == 'CRITICAL') return Colors.red;
    return Colors.grey;
  }

  int remainingVolume(LiquidStatus value) =>
      ((value.level / 100) * value.capacityMl).round();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Liquid Monitor'),
        centerTitle: true,
        actions: [
          Icon(connected ? Icons.wifi : Icons.wifi_off,
              color: connected ? Colors.green : Colors.red),
          const SizedBox(width: 15),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.water_drop,
                            size: 70, color: Colors.blue),
                        Text('${data!.level.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 55,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: (data!.level / 100).clamp(0, 1),
                            minHeight: 22,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Chip(
                          label: Text(data!.status,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          backgroundColor:
                              statusColor(data!.status).withOpacity(.2),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _infoCard('Bottle Information', [
                  'Liquid: ${data!.liquid}',
                  'Capacity: ${data!.capacityMl} mL',
                  'Remaining: ${remainingVolume(data!)} mL',
                  'Warning level: ${data!.warningThreshold}%',
                  'Critical level: ${data!.criticalThreshold}%',
                ]),
                _infoCard('Sensor Information', [
                  'Sensor: C43 Level Sensor',
                  'ADC Reading: ${data!.adc}',
                  connected ? 'ESP8266: Online' : 'ESP8266: Offline',
                ]),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Bottle QR'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => QrScreen(espService: service)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(e),
                )),
          ],
        ),
      ),
    );
  }
}
