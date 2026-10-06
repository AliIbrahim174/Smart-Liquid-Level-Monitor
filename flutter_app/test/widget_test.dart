import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_monitor/main.dart';

void main() {
  testWidgets('Dashboard opens and navigation switches to Settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LiquidMonitorApp());

    expect(find.text('System Overview'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('System Overview'), findsNothing);
    expect(find.text('ESP8266 + C43 Level Sensor'), findsOneWidget);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4);
    expect(tester.takeException(), isNull);

    // Dispose the app so polling timers cannot outlive the test.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
