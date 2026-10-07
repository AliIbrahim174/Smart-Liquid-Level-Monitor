import 'dart:async';
import 'package:flutter/material.dart';

import '../models/liquid_status.dart';
import '../services/esp_service.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.service});
  final EspService? service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EspService service = widget.service ?? EspService();
  LiquidStatus? data;
  Timer? timer;
  bool updating = false;
  int failedRequests = 0;
  DateTime? lastUpdated;

  String get connectionText {
    if (failedRequests >= 3) return 'ESP8266: Offline - retrying';
    if (failedRequests > 0) return 'ESP8266: Reading delayed - retrying';
    if (lastUpdated == null) return 'ESP8266: Connecting';
    return 'ESP8266: Online';
  }

  Color get connectionColor {
    if (failedRequests >= 3) return Colors.red;
    if (failedRequests > 0) return Colors.orange;
    return lastUpdated == null ? Colors.grey : Colors.green;
  }

  @override
  void initState() {
    super.initState();
    update();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  Future<void> update() async {
    if (updating || !mounted) return;
    updating = true;
    try {
      final result = await service.getStatus();
      if (!mounted) return;
      setState(() {
        data = result;
        failedRequests = 0;
        lastUpdated = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => failedRequests++);
    } finally {
      updating = false;
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
          Icon(failedRequests >= 3 ? Icons.wifi_off : Icons.wifi,
              color: connectionColor),
          const SizedBox(width: 15),
        ],
      ),
      body: data == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(connectionText),
                  if (failedRequests > 0) ...[
                    const Text(
                        'Connect to LiquidMonitor Wi-Fi to receive data.'),
                    TextButton(
                        onPressed: update, child: const Text('Retry now')),
                  ],
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.wifi, color: connectionColor),
                  title: Text(connectionText),
                  subtitle: Text([
                    if (lastUpdated != null)
                      'Last received: ${TimeOfDay.fromDateTime(lastUpdated!).format(context)}',
                    if (failedRequests > 0)
                      'Showing the last received reading; it is not live.',
                  ].join('\n')),
                ),
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
                                fontSize: 55, fontWeight: FontWeight.bold)),
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
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          backgroundColor:
                              statusColor(data!.status).withValues(alpha: .2),
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
