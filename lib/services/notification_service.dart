import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  NotificationService._();

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NotificationService: Already initialized');
      return;
    }

    try {
      debugPrint('NotificationService: Starting initialization...');

      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('NotificationService: Permission settings - ${settings.authorizationStatus}');

      // Configure message handling first
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('NotificationService: Received foreground message');
        if (message.notification != null) {
          _showNotification(message);
        }
      }).onError((error) {
        debugPrint('NotificationService: Error in message stream: $error');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('NotificationService: App opened from background message');
        _handleBackgroundMessage(message);
      }).onError((error) {
        debugPrint('NotificationService: Error in background message stream: $error');
      });

      // Get the token last
      try {
        String? token = await _messaging.getToken();
        debugPrint('NotificationService: FCM Token obtained: ${token?.substring(0, 10)}...');
      } catch (e) {
        debugPrint('NotificationService: Error getting FCM token: $e');
        // Continue even if token retrieval fails
      }

      _isInitialized = true;
      debugPrint('NotificationService: Initialization completed successfully');
    } catch (e) {
      debugPrint('NotificationService: Error during initialization - $e');
      // Mark as initialized to prevent retry loops
      _isInitialized = true;
    }
  }

  void _showNotification(RemoteMessage message) {
    if (message.notification == null) return;
    debugPrint('NotificationService: Showing notification: ${message.notification!.title}');
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: Handling background message');
  }

  void checkCriticalValues({
    required double temperature,
    required double humidity,
    required double soilMoisture,
  }) {
    if (!_isInitialized) {
      debugPrint('NotificationService: Warning - checkCriticalValues called before initialization');
      return;
    }

    if (soilMoisture < 30) {
      debugPrint('NotificationService: Low Soil Moisture Alert! (${soilMoisture.toStringAsFixed(1)}%)');
    }

    if (temperature > 40) {
      debugPrint('NotificationService: High Temperature Alert! (${temperature.toStringAsFixed(1)}°C)');
    }

    if (humidity < 30) {
      debugPrint('NotificationService: Low Humidity Alert! (${humidity.toStringAsFixed(1)}%)');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('NotificationService: Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('NotificationService: Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('NotificationService: Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('NotificationService: Error unsubscribing from topic: $e');
    }
  }
} 