import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data_model.dart';
import '../models/actuator_state_model.dart';
import '../services/notification_service.dart';
import 'sensor_history_screen.dart';

class SensorDataScreen extends StatefulWidget {
  final String deviceId;

  const SensorDataScreen({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<SensorDataScreen> createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  SensorDataModel? _sensorData;
  ActuatorStateModel? _actuatorState;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    NotificationService.instance.initialize();
  }

  void _setupListeners() {
    // Listen to sensor data updates
    FirebaseFirestore.instance
        .collection('sensors_data')
        .doc(widget.deviceId)
        .snapshots()
        .listen(
      (snapshot) {
        setState(() {
          if (snapshot.exists) {
            _sensorData = SensorDataModel.fromMap(snapshot.data()!);
            _error = null;

            // Check for critical values
            NotificationService.instance.checkCriticalValues(
              temperature: _sensorData!.temperature,
              humidity: _sensorData!.humidity,
              soilMoisture: _sensorData!.soilMoisture,
            );
          }
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _error = 'Error loading sensor data: $error';
          _isLoading = false;
        });
      },
    );

    // Listen to actuator state updates
    FirebaseFirestore.instance
        .collection('actuators')
        .doc(widget.deviceId)
        .snapshots()
        .listen(
      (snapshot) {
        setState(() {
          if (snapshot.exists) {
            _actuatorState = ActuatorStateModel.fromMap(snapshot.data()!);
          } else {
            // Initialize with default values if document doesn't exist
            _actuatorState = ActuatorStateModel(
              motor: false,
              light: false,
              waterSupply: false,
              lastUpdated: DateTime.now(),
            );
          }
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading actuator states: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Store current reading in history
    if (_sensorData != null) {
      FirebaseFirestore.instance
          .collection('sensors_data_history')
          .doc(widget.deviceId)
          .collection('readings')
          .add(_sensorData!.toMap());
    }
  }

  Future<void> _toggleActuator(String type, bool value) async {
    try {
      final actuatorRef = FirebaseFirestore.instance
          .collection('actuators')
          .doc(widget.deviceId);

      Map<String, dynamic> updates = {
        type: value,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await actuatorRef.set(updates, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating $type: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SensorHistoryScreen(deviceId: widget.deviceId),
      ),
    );
  }

  Widget _buildSensorCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_sensorData == null) {
      return const Center(
        child: Text('No sensor data available'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sensor Readings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _navigateToHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
            const Divider(),
            _buildDataRow(
              'Temperature',
              '${_sensorData!.temperature.toStringAsFixed(1)} °C',
              Icons.thermostat,
              _sensorData!.temperature > 40 ? Colors.red : Colors.blue,
            ),
            _buildDataRow(
              'Humidity',
              '${_sensorData!.humidity.toStringAsFixed(1)} %',
              Icons.water_drop,
              _sensorData!.humidity < 30 ? Colors.red : Colors.blue,
            ),
            _buildDataRow(
              'Soil Moisture',
              '${_sensorData!.soilMoisture.toStringAsFixed(1)} %',
              Icons.grass,
              _sensorData!.soilMoisture < 30 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${_formatDateTime(_sensorData!.timestamp)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActuatorControls() {
    if (_actuatorState == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Motor'),
              subtitle: Text(_actuatorState!.motor ? 'Running' : 'Stopped'),
              value: _actuatorState!.motor,
              onChanged: (value) => _toggleActuator('motor', value),
              secondary: const Icon(Icons.electric_meter),
            ),
            SwitchListTile(
              title: const Text('Light'),
              subtitle: Text(_actuatorState!.light ? 'On' : 'Off'),
              value: _actuatorState!.light,
              onChanged: (value) => _toggleActuator('light', value),
              secondary: const Icon(Icons.lightbulb),
            ),
            SwitchListTile(
              title: const Text('Water Supply'),
              subtitle: Text(_actuatorState!.waterSupply ? 'Open' : 'Closed'),
              value: _actuatorState!.waterSupply,
              onChanged: (value) => _toggleActuator('waterSupply', value),
              secondary: const Icon(Icons.water),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${_formatDateTime(_actuatorState!.lastUpdated)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _setupListeners();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          _setupListeners();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSensorCard(),
              const SizedBox(height: 16),
              _buildActuatorControls(),
            ],
          ),
        ),
      ),
    );
  }
} 