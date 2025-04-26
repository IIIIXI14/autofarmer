import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final Timestamp lastActive;
  final Timestamp addedAt;

  Device({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.lastActive,
    required this.addedAt,
  });

  factory Device.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Device(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Device',
      location: data['location'] ?? 'Unknown Location',
      isOnline: data['isOnline'] ?? false,
      lastActive: data['lastActive'] ?? Timestamp.now(),
      addedAt: data['addedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'addedAt': addedAt,
    };
  }
} 