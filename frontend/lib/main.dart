import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/onboarding_flow_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // If you ever configure Firebase for Web using flutterfire, you'll pass options here.
    // For now, this try-catch prevents the app from crashing on Chrome.
    await Firebase.initializeApp();
    
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request permission for push notifications
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get the token each time the application loads
      String? token = await messaging.getToken();
      if (token != null) {
        ApiService.registerFcmToken(token).catchError((_) {});
      }

      // Any time the token refreshes, store this in the database too.
      messaging.onTokenRefresh.listen((newToken) {
        ApiService.registerFcmToken(newToken).catchError((_) {});
      });
    }
  } catch (e) {
    debugPrint("Firebase initialization failed (expected on Chrome without Web config): $e");
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
