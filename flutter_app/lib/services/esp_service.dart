import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/liquid_status.dart';

class EspService {
  static const String baseUrl = 'http://192.168.4.1';

  Future<LiquidStatus> getStatus() async {
    final response = await http
        .get(Uri.parse('$baseUrl/status'))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode != 200) {
      throw Exception('ESP8266 error');
    }

    return LiquidStatus.fromJson(jsonDecode(response.body));
  }
}
