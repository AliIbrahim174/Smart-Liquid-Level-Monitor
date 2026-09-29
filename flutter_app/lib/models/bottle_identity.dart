class BottleIdentity {
  final String bottleId;
  final String liquid;
  final int expectedVolumeMl;
  final DateTime? assignedAt;
  final bool assigned;

  BottleIdentity({
    required this.bottleId,
    required this.liquid,
    required this.expectedVolumeMl,
    this.assignedAt,
    this.assigned = false,
  });

  factory BottleIdentity.fromQr(String qr) {
    final parts = qr.split('|');
    return BottleIdentity(
      bottleId: parts.isNotEmpty ? parts[0] : 'UNKNOWN',
      liquid: parts.length > 1 ? parts[1] : 'IV Fluid',
      expectedVolumeMl: parts.length > 2 ? int.tryParse(parts[2]) ?? 500 : 500,
    );
  }

  String toQrData() {
    return '$bottleId|$liquid|$expectedVolumeMl';
  }
}
