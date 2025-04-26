import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device.dart';

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all devices for current user
  Stream<List<Device>> getDevices() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Device.fromFirestore(doc)).toList();
    });
  }

  // Add a new device
  Future<void> addDevice(String deviceId, String name, String location) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .set({
      'name': name,
      'location': location,
      'isOnline': true,
      'lastActive': Timestamp.now(),
      'addedAt': Timestamp.now(),
    });
  }

  // Update device status
  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update({
      'isOnline': isOnline,
      'lastActive': Timestamp.now(),
    });
  }

  // Delete device
  Future<void> deleteDevice(String deviceId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }

  // Update device details
  Future<void> updateDevice(String deviceId, String name, String location) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update({
      'name': name,
      'location': location,
    });
  }
} 