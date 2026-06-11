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
  late Animation<double> _glowAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.03, end: 0.10).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
              userName: 'You',
              partnerName: widget.partnerName,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1200),
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
        resizeToAvoidBottomInset: false,
        body: AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            return Stack(
              children: [
                // ── Breathing ambient glow ──
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFDD8F9F).withOpacity(_glowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Ambient glow bottom corner ──
                Positioned(
                  bottom: -80,
                  right: -60,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF9E7E5A).withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Pulsing glow ring + heart ──
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 80 * _breatheAnimation.value * 1.8,
                              height: 80 * _breatheAnimation.value * 1.8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFDD8F9F).withOpacity(_glowAnimation.value * 0.6),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Inner ring
                            Container(
                              width: 80 * _breatheAnimation.value * 1.35,
                              height: 80 * _breatheAnimation.value * 1.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFDD8F9F).withOpacity(_glowAnimation.value * 0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Heart icon
                            ScaleTransition(
                              scale: _breatheAnimation,
                              child: const AppHeartIcon(size: 72),
                            ),
                          ],
                        ),

                        const SizedBox(height: 52),

                        // ── Text content ──
                        const Text(
                          'A new separation\nhas just begun...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Distance gives the heart room to remember.\nBreathe, and trust this time.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF7A5C67),
                              height: 1.6,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 64),

                        // ── Subtle gold label ──
                        const Text(
                          'TAKING YOU TO YOUR SPACE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF3D1627),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
