import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Create user document in Firestore
    await _createUserDocument(userCredential.user!);
    
    return userCredential;
  }

  // Create user document
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'name': '',
      'phone': '',
      'preferredLanguage': 'en',
      'uid': user.uid,
    });
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
} 