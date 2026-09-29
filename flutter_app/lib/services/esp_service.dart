import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/liquid_status.dart';
import '../models/bottle_config.dart';

class EspService {
  static const String baseUrl = 'http://192.168.4.1';

  Future<LiquidStatus> getStatus() async {
    final response = await http
        .get(Uri.parse('$baseUrl/status'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('ESP8266 error');
    }

    return LiquidStatus.fromJson(jsonDecode(response.body));
  }

  Future<void> sendBottleConfig(BottleConfig config) async {
    final response = await http.post(
      Uri.parse('$baseUrl/config'),
      body: config.toRequest(),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Configuration failed');
    }
  }
}
