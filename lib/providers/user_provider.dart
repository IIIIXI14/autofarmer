import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(UserModel user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUser() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        clearUser();
        return;
      }

      debugPrint('Loading user data for ID: ${currentUser.uid}');
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        _error = 'User profile not found. Please try logging in again.';
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        final userData = doc.data()!;
        debugPrint('User data retrieved: $userData');
        _user = UserModel.fromMap(userData);
        _error = null;
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        _error = 'Error loading user profile. Please try logging in again.';
        _user = null;
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase error loading user: ${e.code} - ${e.message}');
      _error = 'Error loading user profile: ${e.message}';
      _user = null;
    } catch (e) {
      debugPrint('Unexpected error loading user: $e');
      _error = 'An unexpected error occurred. Please try again.';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      clearUser();
    } catch (e) {
      debugPrint('Error signing out: $e');
      _error = 'Error signing out. Please try again.';
      notifyListeners();
    }
  }
} 