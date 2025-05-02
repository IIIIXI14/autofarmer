import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_reading.dart';
import '../utils/chart_utils.dart';
import '../services/alerts_service.dart';

class SensorChartPage extends StatelessWidget {
  final String deviceId;

  const SensorChartPage({super.key, required this.deviceId});

  Stream<List<SensorReading>> getSensorData() {
    return FirebaseFirestore.instance
        .collection('sensors')
        .doc(deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SensorReading.fromMap(doc.data()))
            .toList()
            .reversed
            .toList());
  }

  Widget _buildAlertBanners(List<AlertInfo> alerts) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: alert.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                alert.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              alert.severity == AlertSeverity.critical 
                ? Icons.warning_amber_rounded
                : Icons.info_outline,
              color: Colors.white,
            ),
          ],
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Sensor Dashboard'),
        elevation: 2,
      ),
      body: StreamBuilder<List<SensorReading>>(
        stream: getSensorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No sensor data available'),
            );
          }

          final readings = snapshot.data!;
          final currentReading = readings.last;
          final alerts = AlertsService.checkAlerts(currentReading);
          
          // Log alerts to Firestore if any
          if (alerts.isNotEmpty) {
            for (var alert in alerts) {
              AlertsService.logAlert(deviceId, alert);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAlertBanners(alerts),
                const SizedBox(height: 16),
                _buildLatestReadings(readings.last),
                const SizedBox(height: 24),
                _buildChart(
                  'Temperature (°C)',
                  readings,
                  Colors.red,
                  (reading) => reading.temperature,
                  minY: 0,
                  maxY: 50,
                ),
                const SizedBox(height: 24),
                _buildChart(
                  'Humidity (%)',
                  readings,
                  Colors.blue,
                  (reading) => reading.humidity,
                ),
                const SizedBox(height: 24),
                _buildChart(
                  'Soil Moisture (%)',
                  readings,
                  Colors.green,
                  (reading) => reading.soilMoisture,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestReadings(SensorReading reading) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Readings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReadingIndicator(
                  'Temperature',
                  '${reading.temperature.toStringAsFixed(1)}°C',
                  Colors.red,
                ),
                _buildReadingIndicator(
                  'Humidity',
                  '${reading.humidity.toStringAsFixed(1)}%',
                  Colors.blue,
                ),
                _buildReadingIndicator(
                  'Soil Moisture',
                  '${reading.soilMoisture.toStringAsFixed(1)}%',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(
    String label,
    List<SensorReading> readings,
    Color color,
    double Function(SensorReading) getValue, {
    double minY = 0,
    double maxY = 100,
  }) {
    final spots = ChartUtils.createSpots(readings, getValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ChartUtils.buildLineChart(
            label: label,
            spots: spots,
            color: color,
            minY: minY,
            maxY: maxY,
          ),
        ),
      ],
    );
  }
} 