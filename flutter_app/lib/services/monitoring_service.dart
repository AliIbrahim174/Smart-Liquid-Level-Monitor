import 'dart:async';
import 'rooms_service.dart';
import 'notification_service.dart';

class MonitoringService {
  static Timer? _timer;
  static bool _checking = false;
  static final Set<int> _notified = {};
  static final RoomsService _roomsService = RoomsService();

  static void start() {
    _timer?.cancel();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  static Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final rooms = await _roomsService.fetchRooms();
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
    } catch (_) {
      // Retry on the next monitoring interval.
    } finally {
      _checking = false;
    }
  }
}
