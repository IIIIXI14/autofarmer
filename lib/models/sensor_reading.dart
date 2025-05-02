import 'package:cloud_firestore/cloud_firestore.dart';

class SensorReading {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.timestamp,
  });

  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      temperature: map['temperature']?.toDouble() ?? 0.0,
      humidity: map['humidity']?.toDouble() ?? 0.0,
      soilMoisture: map['soilMoisture']?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
} 