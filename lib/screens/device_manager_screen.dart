import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';
import '../services/device_service.dart';
import '../models/device.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceManagerScreen extends StatefulWidget {
  const DeviceManagerScreen({Key? key}) : super(key: key);

  @override
  _DeviceManagerScreenState createState() => _DeviceManagerScreenState();
}

class _DeviceManagerScreenState extends State<DeviceManagerScreen> {
  bool isScanning = false;
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _handleQRScan(String qrData) async {
    try {
      final data = Map<String, dynamic>.from(json.decode(qrData));
      final deviceId = data['deviceId'] as String;
      final secretKey = data['secretKey'] as String;

      if (secretKey == 'farm123secure') {
        final deviceService = Provider.of<DeviceService>(context, listen: false);
        await deviceService.addDevice(
          deviceId,
          'New Device',
          'Set Location',
        );
        setState(() {
          isScanning = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid device key')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code format')),
      );
    }
  }

  Future<void> _showAddDeviceDialog() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        await _handleQRScan(result.rawContent);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning QR code: ${e.toString()}')),
      );
    }
  }

  void _showEditDeviceDialog(Device device) {
    final nameController = TextEditingController(text: device.name);
    final locationController = TextEditingController(text: device.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Device Name'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final deviceService =
                  Provider.of<DeviceService>(context, listen: false);
              await deviceService.updateDevice(
                device.id,
                nameController.text,
                locationController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDeviceDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<List<Device>>(
        stream: Provider.of<DeviceService>(context).getDevices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final devices = snapshot.data!;

          if (devices.isEmpty) {
            return const Center(
              child: Text('No devices added yet. Tap + to add a device.'),
            );
          }

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                leading: const Icon(Icons.memory),
                title: Text(device.name),
                subtitle: Text(device.location),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      device.isOnline ? Icons.circle : Icons.circle_outlined,
                      color: device.isOnline ? Colors.green : Colors.grey,
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditDeviceDialog(device);
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Device'),
                              content: Text(
                                  'Are you sure you want to delete ${device.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final deviceService =
                                Provider.of<DeviceService>(context, listen: false);
                            await deviceService.deleteDevice(device.id);
                          }
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to device dashboard
                  // TODO: Implement device dashboard navigation
                },
              );
            },
          );
        },
      ),
    );
  }
} 