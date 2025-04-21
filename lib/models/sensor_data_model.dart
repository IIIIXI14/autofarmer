class SensorDataModel {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime timestamp;

  SensorDataModel({
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
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      soilMoisture: (map['soil_moisture'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
} 