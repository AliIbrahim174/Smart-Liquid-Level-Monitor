import 'dart:async';
import 'package:flutter/material.dart';

import '../models/monitor_device.dart';
import '../services/rooms_service.dart';
import '../services/notification_service.dart';
import 'room_details_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final RoomsService service = RoomsService();
  List<MonitorDevice> devices = [];
  bool loading = true;
  String error = '';
  Timer? refreshTimer;

  final Set<int> notifiedRooms = {};

  Color statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return Colors.green;
      case 'LOW':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> checkAlerts(List<MonitorDevice> rooms) async {
    for (final room in rooms) {
      if (room.status == 'LOW' || room.status == 'CRITICAL') {
        if (!notifiedRooms.contains(room.id)) {
          notifiedRooms.add(room.id);
          await NotificationService.showAlert(
            'Liquid Level Alert',
            '${room.name}\n${room.liquid}\nLevel: ${room.level.toStringAsFixed(0)}%\nStatus: ${room.status}',
          );
        }
      } else {
        notifiedRooms.remove(room.id);
      }
    }
  }

  Future<void> loadRooms() async {
    try {
      final result = await service.fetchRooms();
      await checkAlerts(result);
      if (!mounted) return;
      setState(() {
        devices = result;
        loading = false;
        error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadRooms();
    refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) => loadRooms());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Liquid Monitor')),
      body: RefreshIndicator(
        onRefresh: loadRooms,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (devices.any((d) => d.status != 'NORMAL'))
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.warning),
                            title: const Text('Active Alerts'),
                            subtitle: Text('${devices.where((d) => d.status != 'NORMAL').length} room(s) need attention'),
                          ),
                        ),
                      ...devices.map((device) => Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RoomDetailsScreen(device: device),
                                  ),
                                );
                              },
                              leading: Icon(
                                device.mode == DeviceMode.real ? Icons.sensors : Icons.developer_mode,
                                color: statusColor(device.status),
                              ),
                              title: Text(device.name),
                              subtitle: Text(
                                '${device.liquid}\n'
                                'Level: ${device.level.toStringAsFixed(0)}%\n'
                                'Remaining: ${device.remainingMl} mL\n'
                                'Status: ${device.status}',
                              ),
                              trailing: Icon(Icons.circle, color: statusColor(device.status)),
                            ),
                          )),
                    ],
                  ),
      ),
    );
  }
}
