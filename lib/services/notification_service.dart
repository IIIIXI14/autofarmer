import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      channelDescription: 'Notifications for critical sensor readings',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  void checkCriticalValues({
    required double temperature,
    required double humidity,
    required double soilMoisture,
  }) {
    if (soilMoisture < 30) {
      showNotification(
        title: 'Low Soil Moisture Alert!',
        body: 'Soil moisture is critically low (${soilMoisture.toStringAsFixed(1)}%). Plants need water!',
        id: 1,
      );
    }

    if (temperature > 40) {
      showNotification(
        title: 'High Temperature Alert!',
        body: 'Temperature is too high (${temperature.toStringAsFixed(1)}°C). Check your plants!',
        id: 2,
      );
    }

    if (humidity < 30) {
      showNotification(
        title: 'Low Humidity Alert!',
        body: 'Humidity is too low (${humidity.toStringAsFixed(1)}%). Consider using humidifier.',
        id: 3,
      );
    }
  }
} 