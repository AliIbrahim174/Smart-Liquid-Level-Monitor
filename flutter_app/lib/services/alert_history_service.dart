import '../models/alert_record.dart';

class AlertHistoryService {
  AlertHistoryService._();

  static final AlertHistoryService instance = AlertHistoryService._();

  final List<AlertRecord> _alerts = [];

  List<AlertRecord> get alerts => List.unmodifiable(_alerts);

  void addAlert({
    required String deviceName,
    required String type,
    required String message,
  }) {
    _alerts.insert(
      0,
      AlertRecord(
        deviceName: deviceName,
        type: type,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }

  void clear() {
    _alerts.clear();
  }
}
