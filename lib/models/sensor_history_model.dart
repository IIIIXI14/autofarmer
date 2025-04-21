import 'package:cloud_firestore/cloud_firestore.dart';

class SensorHistoryModel {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime timestamp;

  SensorHistoryModel({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soil_moisture': soilMoisture,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory SensorHistoryModel.fromMap(Map<String, dynamic> map) {
    return SensorHistoryModel(
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      soilMoisture: (map['soil_moisture'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  static List<SensorHistoryModel> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((map) => SensorHistoryModel.fromMap(map)).toList();
  }
} 