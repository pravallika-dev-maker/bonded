import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_heart_icon.dart';

import 'home_screen.dart';

class SeparationTransitionScreen extends StatefulWidget {
  final String partnerName;
  const SeparationTransitionScreen({super.key, required this.partnerName});

  @override
  State<SeparationTransitionScreen> createState() => _SeparationTransitionScreenState();
}

class _SeparationTransitionScreenState extends State<SeparationTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breatheAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
              userName: 'You', // Hardcoded for demo, normally passed from state
              partnerName: widget.partnerName,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _breatheAnimation,
                child: const AppHeartIcon(size: 80),
              ),
              const SizedBox(height: 48),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'A new separation\nhas just begun...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFE89FB8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Distance gives the heart room to remember.\nBreathe, and trust this time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4C4CA),
                        height: 1.6,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
