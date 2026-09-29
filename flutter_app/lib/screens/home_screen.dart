import 'dart:async';
import 'package:flutter/material.dart';
import '../models/liquid_status.dart';
import '../services/esp_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EspService service = EspService();
  LiquidStatus? data;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    update();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  Future<void> update() async {
    try {
      final result = await service.getStatus();
      if (mounted) setState(() => data = result);
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Monitor')),
      body: Center(
        child: data == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${data!.level.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 60)),
                  Text('Status: ${data!.status}',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  Text('Liquid: ${data!.liquid}'),
                  Text('ADC: ${data!.adc}'),
                ],
              ),
      ),
    );
  }
}
