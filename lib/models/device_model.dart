import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime addedAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.lastActive,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'isOnline': isOnline,
      'lastActive': Timestamp.fromDate(lastActive),
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      isOnline: map['isOnline'] as bool,
      lastActive: (map['lastActive'] as Timestamp).toDate(),
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }

  DeviceModel copyWith({
    String? name,
    String? location,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return DeviceModel(
      id: this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      addedAt: this.addedAt,
    );
  }

  bool get isActiveNow {
    return DateTime.now().difference(lastActive).inMinutes < 2;
  }
} 