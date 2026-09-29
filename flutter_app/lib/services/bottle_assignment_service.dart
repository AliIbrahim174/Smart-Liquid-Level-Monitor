import '../models/monitor_device.dart';

class BottleAssignment {
  final String bottleId;
  final double expectedVolume;

  BottleAssignment({
    required this.bottleId,
    required this.expectedVolume,
  });
}

class BottleAssignmentService {
  BottleAssignment? _currentBottle;

  BottleAssignment? get currentBottle => _currentBottle;

  void assignBottle(String qrData) {
    final parts = qrData.split('|');
    if (parts.length < 2) {
      throw Exception('Invalid QR format');
    }

    _currentBottle = BottleAssignment(
      bottleId: parts[0],
      expectedVolume: double.tryParse(parts[1]) ?? 0,
    );
  }

  String compareVolume(double measuredVolume) {
    if (_currentBottle == null) {
      return 'NO_BOTTLE_ASSIGNED';
    }

    final difference = (_currentBottle!.expectedVolume - measuredVolume).abs();

    if (difference <= 20) {
      return 'NORMAL';
    }

    return 'VOLUME_MISMATCH';
  }
}
