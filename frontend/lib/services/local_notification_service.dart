import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that bridges FCM foreground messages to
/// local notification pop-ups (heads-up banners).
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final _androidChannel = AndroidNotificationChannel(
    'bonded_urgent_alerts', // must match channel_id sent from backend
    'Bonded Notifications',
    description: 'Bonded partner activity and relationship updates',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  Future<void> init() async {
    // ── Android: create the high-importance channel ──
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // ── Request Notification Permissions (Android 13+ & iOS) ──
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // ── iOS: request display alerts while app is foregrounded ──
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Init plugin ──
    final initSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(initSettings);
  }

  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    debugPrint("🔥 [LOCAL] showFromRemoteMessage called");
    final notification = message.notification;
    if (notification == null) return;

    try {
      debugPrint("🔥 [LOCAL] Attempting to show local notification: ${notification.title}");
      await _plugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      debugPrint("🔥 [LOCAL] Local notification shown successfully!");
    } catch (e) {
      debugPrint("🔥 [LOCAL] Failed to show local notification: $e");
    }
  }
}
