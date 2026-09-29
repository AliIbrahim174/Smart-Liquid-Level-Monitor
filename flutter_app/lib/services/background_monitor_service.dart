import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'rooms_service.dart';
import 'notification_service.dart';

final Set<int> _backgroundNotified = {};

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: backgroundEntryPoint,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: NotificationService.monitoringChannelId,
      initialNotificationTitle: 'Liquid Monitor',
      initialNotificationContent: 'Monitoring liquid levels',
      initialNotificationIcon: 'ic_launcher',
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void backgroundEntryPoint(ServiceInstance service) {
  Timer.periodic(const Duration(seconds: 5), (_) async {
    try {
      final rooms = await RoomsService().fetchRooms();

      for (final room in rooms) {
        if ((room.status == 'LOW' || room.status == 'CRITICAL') &&
            !_backgroundNotified.contains(room.id)) {
          _backgroundNotified.add(room.id);

          await NotificationService.showAlert(
            'Liquid Level Alert',
            '${room.name}\n${room.liquid}\nLevel: ${room.level.toStringAsFixed(0)}%\nStatus: ${room.status}',
          );
        }

        if (room.status == 'NORMAL') {
          _backgroundNotified.remove(room.id);
        }
      }
    } catch (_) {}
  });
}
