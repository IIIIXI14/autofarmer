import 'package:cloud_firestore/cloud_firestore.dart';

class ActuatorStateModel {
  final bool motor;
  final bool light;
  final bool waterSupply;
  final bool autoMode;
  final DateTime lastUpdated;

  ActuatorStateModel({
    required this.motor,
    required this.light,
    required this.waterSupply,
    required this.autoMode,
    required this.lastUpdated,
  });

  factory ActuatorStateModel.fromMap(Map<String, dynamic> data) {
    return ActuatorStateModel(
      motor: data['motor'] ?? false,
      light: data['light'] ?? false,
      waterSupply: data['waterSupply'] ?? false,
      autoMode: data['autoMode'] ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motor': motor,
      'light': light,
      'waterSupply': waterSupply,
      'autoMode': autoMode,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  ActuatorStateModel copyWith({
    bool? motor,
    bool? light,
    bool? waterSupply,
    bool? autoMode,
  }) {
    return ActuatorStateModel(
      motor: motor ?? this.motor,
      light: light ?? this.light,
      waterSupply: waterSupply ?? this.waterSupply,
      autoMode: autoMode ?? this.autoMode,
      lastUpdated: DateTime.now(),
    );
  }
} 