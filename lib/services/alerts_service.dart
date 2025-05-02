import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';

class AlertsService {
  // Threshold constants
  static const double moistureThresholdLow = 30.0;
  static const double tempThresholdHigh = 40.0;
  static const double tempThresholdLow = 10.0;
  static const double humidityThresholdLow = 20.0;

  // Alert check methods
  static bool checkMoistureLow(SensorReading reading) {
    return reading.soilMoisture < moistureThresholdLow;
  }

  static bool checkTemperatureHigh(SensorReading reading) {
    return reading.temperature > tempThresholdHigh;
  }

  static bool checkTemperatureLow(SensorReading reading) {
    return reading.temperature < tempThresholdLow;
  }

  static bool checkHumidityLow(SensorReading reading) {
    return reading.humidity < humidityThresholdLow;
  }

  // Get alert message and color based on conditions
  static List<AlertInfo> checkAlerts(SensorReading reading) {
    final alerts = <AlertInfo>[];
    
    if (checkMoistureLow(reading)) {
      alerts.add(
        AlertInfo(
          message: "⚠️ Soil moisture too low! (${reading.soilMoisture.toStringAsFixed(1)}%)",
          color: const Color(0xFFFF9800), // Orange
          severity: AlertSeverity.warning,
        ),
      );
    }

    if (checkTemperatureHigh(reading)) {
      alerts.add(
        AlertInfo(
          message: "🔥 Temperature too high! (${reading.temperature.toStringAsFixed(1)}°C)",
          color: const Color(0xFFF44336), // Red
          severity: AlertSeverity.critical,
        ),
      );
    }

    if (checkTemperatureLow(reading)) {
      alerts.add(
        AlertInfo(
          message: "❄️ Temperature too low! (${reading.temperature.toStringAsFixed(1)}°C)",
          color: const Color(0xFF2196F3), // Blue
          severity: AlertSeverity.warning,
        ),
      );
    }

    if (checkHumidityLow(reading)) {
      alerts.add(
        AlertInfo(
          message: "💧 Humidity too low! (${reading.humidity.toStringAsFixed(1)}%)",
          color: const Color(0xFF9C27B0), // Purple
          severity: AlertSeverity.warning,
        ),
      );
    }

    return alerts;
  }

  // Save alert to Firestore for history
  static Future<void> logAlert(String deviceId, AlertInfo alert) async {
    await FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .collection('alerts')
        .add({
      'message': alert.message,
      'severity': alert.severity.toString(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical
}

// Alert information class
class AlertInfo {
  final String message;
  final Color color;
  final AlertSeverity severity;

  AlertInfo({
    required this.message,
    required this.color,
    required this.severity,
  });
} 