import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/bottle_config.dart';
import '../services/esp_service.dart';

class QrScreen extends StatefulWidget {
  final EspService espService;

  const QrScreen({super.key, required this.espService});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool locked = false;
  String message = 'Scan bottle QR code';

  Future<void> processQr(String value) async {
    if (locked) return;

    locked = true;

    try {
      final json = jsonDecode(value);
      final bottle = BottleConfig.fromJson(json);

      setState(() {
        message = 'Sending configuration...';
      });

      await widget.espService.sendBottleConfig(bottle);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bottle configuration sent successfully'),
        ),
      );

      Navigator.pop(context, bottle);

    } catch (e) {
      locked = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bottle QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;

              final value = capture.barcodes.first.rawValue;

              if (value != null) {
                processQr(value);
              }
            },
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
