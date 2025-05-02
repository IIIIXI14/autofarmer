import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> devices;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.preferredLanguage,
    required this.createdAt,
    required this.lastLoginAt,
    required this.devices,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'devices': devices,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is String) {
          return DateTime.parse(value);
        }
        return DateTime.now();
      }
      
      return UserModel(
        id: map['id']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        preferredLanguage: map['preferredLanguage']?.toString() ?? 'en',
        createdAt: parseDateTime(map['createdAt']),
        lastLoginAt: parseDateTime(map['lastLoginAt']),
        devices: List<String>.from(map['devices'] ?? []),
      );
    } catch (e) {
      debugPrint('Error parsing UserModel from map: $e');
      debugPrint('Map data: $map');
      rethrow;
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      debugPrint('Fetching user data for ID: $userId');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = userId; // Ensure ID is included in the data
        debugPrint('User document found: $data');
        return UserModel.fromMap(data);
      }
      debugPrint('No user document found for ID: $userId');
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, phone: $phone, preferredLanguage: $preferredLanguage)';
  }
} 