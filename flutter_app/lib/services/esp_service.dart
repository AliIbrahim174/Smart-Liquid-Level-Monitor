import 'dart:convert';
import 'esp_http_client.dart';

import '../models/liquid_status.dart';
import '../models/bottle_config.dart';

class EspService {
  static const String baseUrl = 'http://192.168.4.1';
  EspService({EspHttpClient? client})
      : _client = client ?? EspHttpClient.shared;
  final EspHttpClient _client;

  Future<LiquidStatus> getStatus() async {
    final response = await _client.get(Uri.parse('$baseUrl/status'));

    if (response.statusCode != 200) {
      throw Exception('ESP8266 error');
    }

    return LiquidStatus.fromJson(jsonDecode(response.body));
  }

  Future<void> sendBottleConfig(BottleConfig config) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/config'),
      body: config.toRequest(),
    );

    if (response.statusCode != 200) {
      throw Exception('Configuration failed');
    }
  }
}
