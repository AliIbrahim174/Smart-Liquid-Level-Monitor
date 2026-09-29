import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/bottle_config.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool locked = false;

  void processQr(String value) {
    if (locked) return;

    locked = true;

    try {
      final json = jsonDecode(value);
      final bottle = BottleConfig.fromJson(json);

      Navigator.pop(context, bottle);
    } catch (_) {
      locked = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR format'),
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
      body: MobileScanner(
        onDetect: (capture) {
          if (capture.barcodes.isEmpty) return;

          final value = capture.barcodes.first.rawValue;

          if (value != null) {
            processQr(value);
          }
        },
      ),
    );
  }
}
