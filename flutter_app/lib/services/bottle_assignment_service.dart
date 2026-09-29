import '../models/bottle_identity.dart';

class BottleAssignmentService {
  BottleIdentity? _currentBottle;

  BottleIdentity? get currentBottle => _currentBottle;

  void assignBottle(String qrData) {
    _currentBottle = BottleIdentity.fromQr(qrData);
  }

  VolumeCheck compareVolume(double measuredVolume) {
    if (_currentBottle == null) {
      return VolumeCheck(
        status: 'NO_BOTTLE_ASSIGNED',
        differenceMl: 0,
      );
    }

    final difference =
        (_currentBottle!.expectedVolumeMl - measuredVolume).abs();

    return VolumeCheck(
      status: difference <= 20 ? 'NORMAL' : 'VOLUME_MISMATCH',
      differenceMl: difference,
    );
  }
}

class VolumeCheck {
  final String status;
  final double differenceMl;

  VolumeCheck({
    required this.status,
    required this.differenceMl,
  });
}
