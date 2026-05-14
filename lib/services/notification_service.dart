import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging + local notification handler
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications setup
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifs.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotifTapped);

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      'safepath_alerts',
      'Safepath Alerts',
      description: 'Emergency and safety alerts from Safepath',
      importance: Importance.max,
    );
    await _localNotifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get FCM token
    _fcmToken = await _fcm.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundTap);
  }

  void _handleForegroundMessage(RemoteMessage msg) {
    debugPrint('FCM foreground: ${msg.notification?.title}');
    showLocalNotification(
      title: msg.notification?.title ?? 'Safepath Alert',
      body: msg.notification?.body ?? '',
    );
  }

  void _handleBackgroundTap(RemoteMessage msg) {
    debugPrint('FCM background tap: ${msg.notification?.title}');
  }

  void _onNotifTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'safepath_alerts',
      'Safepath Alerts',
      channelDescription: 'Emergency and safety alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifs.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showEmergencyAlert(
      {required String userName, required double distance}) async {
    await showLocalNotification(
      title: '🚨 Emergency Alert',
      body:
          '$userName has moved outside the safe zone by ${distance.toStringAsFixed(0)}m.',
      payload: 'emergency',
    );
  }
}
