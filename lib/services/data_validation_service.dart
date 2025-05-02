import 'package:flutter/material.dart';

class DataValidationService {
  static bool isValidTemperature(double? temperature) {
    return temperature != null && temperature >= -50 && temperature <= 100;
  }

  static bool isValidHumidity(double? humidity) {
    return humidity != null && humidity >= 0 && humidity <= 100;
  }

  static bool isValidSoilMoisture(double? moisture) {
    return moisture != null && moisture >= 0 && moisture <= 100;
  }

  static bool isValidTimestamp(DateTime? timestamp) {
    return timestamp != null && 
           timestamp.isBefore(DateTime.now().add(const Duration(days: 1))) &&
           timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)));
  }

  static String? validateSensorData(Map<String, dynamic> data) {
    try {
      final temperature = data['temperature'] as double?;
      final humidity = data['humidity'] as double?;
      final soilMoisture = data['soilMoisture'] as double?;
      final timestamp = data['timestamp'] as DateTime?;

      if (!isValidTemperature(temperature)) {
        return 'Invalid temperature value';
      }
      if (!isValidHumidity(humidity)) {
        return 'Invalid humidity value';
      }
      if (!isValidSoilMoisture(soilMoisture)) {
        return 'Invalid soil moisture value';
      }
      if (!isValidTimestamp(timestamp)) {
        return 'Invalid timestamp';
      }

      return null;
    } catch (e) {
      return 'Error validating sensor data: $e';
    }
  }

  static String? validateActuatorData(Map<String, dynamic> data) {
    try {
      final motor = data['motor'] as bool?;
      final light = data['light'] as bool?;
      final waterSupply = data['waterSupply'] as bool?;
      final autoMode = data['autoMode'] as bool?;
      final lastUpdated = data['lastUpdated'] as DateTime?;

      if (motor == null || light == null || waterSupply == null || autoMode == null) {
        return 'Missing required actuator fields';
      }
      if (!isValidTimestamp(lastUpdated)) {
        return 'Invalid last updated timestamp';
      }

      return null;
    } catch (e) {
      return 'Error validating actuator data: $e';
    }
  }
} 