import 'dart:convert';
import 'esp_http_client.dart';
import '../models/monitor_device.dart';

class RoomsService {
  final String baseUrl;

  RoomsService({this.baseUrl = 'http://192.168.4.1', EspHttpClient? client})
      : _client = client ?? EspHttpClient.shared;
  final EspHttpClient _client;

  Future<List<MonitorDevice>> fetchRooms() async {
    final response = await _client.get(Uri.parse('$baseUrl/rooms'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load rooms');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) {
      return MonitorDevice(
        name: item['name'] ?? 'Room ${item['room']}',
        liquid: item['liquid'] ?? 'Unknown',
        level: (item['level'] ?? 0).toDouble(),
        status: item['status'] ?? 'NORMAL',
        mode: item['mode'] == 'REAL' ? DeviceMode.real : DeviceMode.simulation,
      );
    }).toList();
  }
}
