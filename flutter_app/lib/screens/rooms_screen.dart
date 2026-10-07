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
  bool fetching = false;
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
    if (fetching || !mounted) return;
    fetching = true;
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
    } finally {
      fetching = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadRooms();
    refreshTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => loadRooms());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor(status).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: statusColor(status), fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Monitoring Rooms')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty && devices.isEmpty
              ? Center(child: Text(error))
              : RefreshIndicator(
                  onRefresh: loadRooms,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (error.isNotEmpty)
                        const ListTile(
                          leading: Icon(Icons.wifi_off, color: Colors.orange),
                          title: Text('Reading delayed - retrying'),
                          subtitle: Text(
                              'Showing the last received readings; they are not live.'),
                        ),
                      ...devices.map((device) => Card(
                            elevation: 3,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        RoomDetailsScreen(device: device)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(device.name,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        statusBadge(device.status),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(device.mode == DeviceMode.real
                                            ? Icons.sensors
                                            : Icons.developer_mode),
                                        const SizedBox(width: 8),
                                        Text(device.mode == DeviceMode.real
                                            ? 'REAL DEVICE'
                                            : 'SIMULATION'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        '${device.liquid}  •  ${device.remainingMl} mL remaining'),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                        value:
                                            (device.level / 100).clamp(0, 1)),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Level: ${device.level.toStringAsFixed(0)}%'),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
    );
  }
}
