import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ActuatorControlScreen extends StatefulWidget {
  final String deviceId;
  
  const ActuatorControlScreen({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<ActuatorControlScreen> createState() => _ActuatorControlScreenState();
}

class _ActuatorControlScreenState extends State<ActuatorControlScreen> {
  late final Stream<DocumentSnapshot> _deviceStream;
  final AuthService _authService = AuthService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceAccess();
    _deviceStream = getDeviceStream();
  }

  // Check if user has access to this device
  Future<void> _checkDeviceAccess() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        // Navigate to login screen if not authenticated
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final deviceDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(widget.deviceId)
          .get();

      if (!deviceDoc.exists && mounted) {
        // Show error if user doesn't own this device
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You don\'t have access to this device'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking device access: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get real-time device state stream
  Stream<DocumentSnapshot> getDeviceStream() {
    return FirebaseFirestore.instance
        .collection('actuators')
        .doc(widget.deviceId)
        .snapshots();
  }

  // Update device state
  Future<void> updateDeviceState(String key, bool value) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);
    
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Map the UI fields to database fields
      final Map<String, String> fieldMapping = {
        'waterPump': 'waterSupply',
        'lights': 'light',
        'siren': 'motor',  // Assuming motor is used as siren
        'autoMode': 'autoMode',
      };

      await FirebaseFirestore.instance
          .collection('actuators')
          .doc(widget.deviceId)
          .update({
            fieldMapping[key]!: value,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildControlCard({
    required String title,
    required String field,
    required bool value,
    required Icon icon,
    required bool isAutoMode,
    String? subtitle,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle ?? (value ? 'ON' : 'OFF'),
        ),
        value: value,
        onChanged: isAutoMode || _isUpdating 
            ? null 
            : (val) => updateDeviceState(field, val),
        secondary: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Control'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isUpdating ? null : _checkDeviceAccess,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _deviceStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkDeviceAccess,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading device status...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.device_unknown, size: 48),
                  const SizedBox(height: 16),
                  const Text('Device not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkDeviceAccess,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          // Map database fields to UI fields
          final bool isAutoMode = data['autoMode'] ?? false;
          final lastUpdated = data['lastUpdated'] as Timestamp?;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Auto Mode Switch
                  _buildControlCard(
                    title: 'Auto Mode',
                    field: 'autoMode',
                    value: isAutoMode,
                    icon: const Icon(Icons.auto_mode, color: Colors.purple),
                    isAutoMode: false,
                    subtitle: isAutoMode 
                        ? 'System will operate automatically'
                        : 'Manual control enabled',
                  ),
                  const SizedBox(height: 16),

                  // Water Supply Control
                  _buildControlCard(
                    title: 'Water Supply',
                    field: 'waterPump',
                    value: data['waterSupply'] ?? false,
                    icon: const Icon(Icons.water_drop, color: Colors.blue),
                    isAutoMode: isAutoMode,
                  ),
                  const SizedBox(height: 8),

                  // Light Control
                  _buildControlCard(
                    title: 'Light',
                    field: 'lights',
                    value: data['light'] ?? false,
                    icon: const Icon(Icons.lightbulb, color: Colors.amber),
                    isAutoMode: isAutoMode,
                  ),
                  const SizedBox(height: 8),

                  // Motor Control
                  _buildControlCard(
                    title: 'Motor',
                    field: 'siren',
                    value: data['motor'] ?? false,
                    icon: const Icon(Icons.settings_input_component, color: Colors.red),
                    isAutoMode: isAutoMode,
                  ),

                  if (lastUpdated != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Last updated: ${lastUpdated.toDate().toString()}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              if (_isUpdating)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x80FFFFFF),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
} 