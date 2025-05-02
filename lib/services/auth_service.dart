import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get AppUser stream
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      
      return AppUser.fromMap(user.uid, doc.data()!);
    });
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _firestore.collection('users').doc(result.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return result;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      await _createUserDocument(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
      );

      return result;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Create user document
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? fcmToken,
  }) async {
    if (currentUser == null) throw Exception('No authenticated user!');

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (fcmToken != null) updates['fcmToken'] = fcmToken;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(updates);
  }

  // Register device for user
  Future<void> registerDevice(String deviceId) async {
    if (currentUser == null) throw Exception('No authenticated user!');
    
    // Create device ownership record
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('devices')
        .doc(deviceId)
        .set({
      'registeredAt': FieldValue.serverTimestamp(),
    });

    // Initialize actuator state
    await _firestore.collection('actuators').doc(deviceId).set({
      'motor': false,
      'light': false,
      'waterSupply': false,
      'autoMode': false,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Initialize sensors data document
    await _firestore.collection('sensors_data').doc(deviceId).set({
      'humidity': 0,
      'soil_moisture': 0,
      'temperature': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
} 