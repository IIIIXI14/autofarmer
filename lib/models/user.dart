import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.fcmToken,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: map['lastLoginAt'] != null 
        ? (map['lastLoginAt'] as Timestamp).toDate()
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? fcmToken,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
} 