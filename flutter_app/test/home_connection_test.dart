import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_monitor/models/liquid_status.dart';
import 'package:liquid_monitor/screens/home_screen.dart';
import 'package:liquid_monitor/services/esp_service.dart';

class ControlledEspService extends EspService {
  final requests = <Completer<LiquidStatus>>[];

  @override
  Future<LiquidStatus> getStatus() {
    final result = Completer<LiquidStatus>();
    requests.add(result);
    return result.future;
  }
}

LiquidStatus reading(double level) => LiquidStatus.fromJson({
      'level': level,
      'status': 'NORMAL',
      'liquid': 'Saline',
      'capacityMl': 500,
    });

void main() {
  testWidgets('slow polls do not overlap and disposal stops polling',
      (tester) async {
    final service = ControlledEspService();
    await tester.pumpWidget(MaterialApp(home: HomeScreen(service: service)));
    await tester.pump(const Duration(seconds: 4));
    expect(service.requests, hasLength(1));
    service.requests.first.complete(reading(72));
    await tester.pump();
    expect(find.text('ESP8266: Online'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(service.requests, hasLength(2));

    await tester.pumpWidget(const SizedBox.shrink());
    service.requests.last.complete(reading(73));
    await tester.pump(const Duration(seconds: 3));
    expect(service.requests, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'failures label old data; repeated failures go offline and recover',
      (tester) async {
    final service = ControlledEspService();
    await tester.pumpWidget(MaterialApp(home: HomeScreen(service: service)));
    service.requests.first.complete(reading(72));
    await tester.pump();

    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 1));
      service.requests.last.completeError(TimeoutException('ESP unavailable'));
      await tester.pump();
      await tester.pump();
      expect(find.text('72%'), findsOneWidget);
      expect(
          find.textContaining(
              'Showing the last received reading; it is not live.'),
          findsOneWidget);
      expect(
          find.text(i < 2
              ? 'ESP8266: Reading delayed - retrying'
              : 'ESP8266: Offline - retrying'),
          findsOneWidget);
    }

    await tester.pump(const Duration(seconds: 1));
    service.requests.last.complete(reading(65));
    await tester.pump();
    await tester.pump();
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('ESP8266: Online'), findsOneWidget);
    expect(
        find.textContaining(
            'Showing the last received reading; it is not live.'),
        findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
