class ActuatorStateModel {
  final bool motor;
  final bool light;
  final bool waterSupply;
  final DateTime lastUpdated;

  ActuatorStateModel({
    required this.motor,
    required this.light,
    required this.waterSupply,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'motor': motor,
      'light': light,
      'waterSupply': waterSupply,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ActuatorStateModel.fromMap(Map<String, dynamic> map) {
    return ActuatorStateModel(
      motor: map['motor'] as bool,
      light: map['light'] as bool,
      waterSupply: map['waterSupply'] as bool,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  ActuatorStateModel copyWith({
    bool? motor,
    bool? light,
    bool? waterSupply,
  }) {
    return ActuatorStateModel(
      motor: motor ?? this.motor,
      light: light ?? this.light,
      waterSupply: waterSupply ?? this.waterSupply,
      lastUpdated: DateTime.now(),
    );
  }
} 