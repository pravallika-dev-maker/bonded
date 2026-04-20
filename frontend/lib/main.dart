import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_flow_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
