import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

Future<void> getFCMToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
    } else {
      print("Failed to get FCM token");
    }
  } catch (e) {
    print("Error getting FCM token: $e");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
    announcement: false,
    carPlay: false,
    criticalAlert: false
    );
    print('permission status: ${settings.authorizationStatus}');


    // Get FCM token
    String? token = await _messaging.getToken();
    print("FCM Token: $token"); // Copy this and paste in Firebase console to test

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

    // Handle background & terminated state notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification clicked!');
    // You can navigate or handle logic here
  }

  init() {}
}
