import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'onboarding1_screen.dart';
import 'onboarding2_screen.dart';
import 'login_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Bulletproof Splash State ──
  bool _showSplash = true;
  double _splashOpacity = 1.0;
  double _splashScale = 1.0;

  @override
  void initState() {
    super.initState();
    
    // Hold splash screen for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Trigger the elegant fade + scale animation
        setState(() {
          _splashOpacity = 0.0;
          _splashScale = 1.05; // Expands outward smoothly as it fades
        });

      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainFlow = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090204),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: Container(
          // Unified Background for the whole flow
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 0.95,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ── The Swipable Sequence ──
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disables swiping back or forward
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    Onboarding1Content(
                      onNext: () {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart,
                        );
                      },
                      onSkip: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart,
                        );
                      },
                    ),
                    Onboarding2Content(
                      onNext: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart,
                        );
                      },
                      onSkip: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutQuart,
                        );
                      },
                    ),
                    const LoginContent(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // ── Root Stack with Bulletproof Splash Overlay ──
    return Stack(
      children: [
        // The main app underneath
        mainFlow,

        // The Splash Screen overlays everything and animates away
        if (_showSplash)
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: _splashOpacity),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                onEnd: () {
                  if (_splashOpacity == 0.0 && mounted) {
                    setState(() {
                      _showSplash = false;
                    });
                  }
                },
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 1.0 + (1.0 - value) * 0.05, // Scales from 1.0 up to 1.05 smoothly
                      child: child,
                    ),
                  );
                },
                child: const Scaffold(
                  backgroundColor: Color(0xFF090103),
                  body: SplashContent(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
