class AlertRecord {
  final String deviceName;
  final String type;
  final String message;
  final DateTime timestamp;

  AlertRecord({
    required this.deviceName,
    required this.type,
    required this.message,
    required this.timestamp,
  });
}
