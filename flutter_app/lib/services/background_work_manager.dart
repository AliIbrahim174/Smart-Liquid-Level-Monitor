import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'rooms_service.dart';
import 'notification_service.dart';

final Set<int> _notified = {};

const String liquidMonitorTask = 'liquidMonitorBackgroundTask';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == liquidMonitorTask) {
      await NotificationService.init();

      try {
        final rooms = await RoomsService().fetchRooms();

        for (final room in rooms) {
          if ((room.status == 'LOW' || room.status == 'CRITICAL') &&
              !_notified.contains(room.id)) {
            _notified.add(room.id);

            await NotificationService.showAlert(
              'Liquid Level Alert',
              '${room.name}\n${room.liquid}\nLevel: ${room.level.toStringAsFixed(0)}%\nStatus: ${room.status}',
            );
          }

          if (room.status == 'NORMAL') {
            _notified.remove(room.id);
          }
        }
      } catch (_) {}
    }

    return Future.value(true);
  });
}

Future<void> initializeBackgroundMonitoring() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  await Workmanager().registerPeriodicTask(
    'liquid_monitor_periodic',
    liquidMonitorTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}
