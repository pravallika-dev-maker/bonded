import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/onboarding_flow_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔥 [FCM BACKGROUND] onBackgroundMessage fired: ${message.messageId}");
  debugPrint("🔥 [FCM BACKGROUND] Notification: title=${message.notification?.title}, body=${message.notification?.body}");
  debugPrint("🔥 [FCM BACKGROUND] Data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // ── Init local notification channel + iOS foreground options ──
      await LocalNotificationService.instance.init();

      // ── Show a pop-up banner when a push arrives while the app is OPEN ──
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔥 [FCM FOREGROUND] onMessage fired: ${message.messageId}");
        debugPrint("🔥 [FCM FOREGROUND] Notification: title=${message.notification?.title}, body=${message.notification?.body}");
        debugPrint("🔥 [FCM FOREGROUND] Data: ${message.data}");
        LocalNotificationService.instance.showFromRemoteMessage(message);
      });

      // ── Handle when user taps notification from tray ──
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("🔥 [FCM TAP] onMessageOpenedApp fired: ${message.messageId}");
      });
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BondedApp());
}


class BondedApp extends StatelessWidget {
  const BondedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonded',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0608),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB52B6E),
          brightness: Brightness.dark,
        ),
      ),
      home: const OnboardingFlowScreen(),
    );
  }
}
