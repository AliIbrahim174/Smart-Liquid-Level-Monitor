import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_profile.dart';

class DeviceStorage {
  static const key = 'device_profiles';

  Future<List<DeviceProfile>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((e) => DeviceProfile.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveDevice(DeviceProfile device) async {
    final devices = await loadDevices();
    devices.removeWhere((d) => d.id == device.id);
    devices.add(device);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      devices.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }

  Future<void> deleteDevice(String id) async {
    final devices = await loadDevices();
    devices.removeWhere((d) => d.id == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      devices.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }
}
