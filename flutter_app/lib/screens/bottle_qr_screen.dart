import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/bottle_identity.dart';

class BottleQrScreen extends StatelessWidget {
  BottleQrScreen({super.key});

  final BottleIdentity bottle = BottleIdentity(
    bottleId: 'BOTTLE-001',
    liquid: 'Normal Saline',
    expectedVolumeMl: 500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Bottle QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: bottle.toQrData(),
              size: 220,
            ),
            const SizedBox(height: 25),
            Text(bottle.bottleId,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${bottle.liquid} - ${bottle.expectedVolumeMl} mL'),
          ],
        ),
      ),
    );
  }
}
