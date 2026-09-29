import 'dart:async';
import 'package:flutter/material.dart';

import '../models/monitor_device.dart';
import '../services/rooms_service.dart';
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

  Future<void> loadRooms() async {
    try {
      final result = await service.fetchRooms();
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
