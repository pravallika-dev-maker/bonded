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

  @override
  void initState() {
    super.initState();
    _startAutoProgression();
  }

  void _startAutoProgression() {
    // ── Timer for Splash (Page 0) -> Onboarding 1 (Page 1) ──
    Timer(const Duration(seconds: 3), () {
      if (mounted && _currentPage == 0) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
        
        // ── Timer for Onboarding 1 (Page 1) -> Onboarding 2 (Page 2) ──
        Timer(const Duration(seconds: 3), () {
          if (mounted && _currentPage == 1) {
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutQuart,
            );

            // ── Timer for Onboarding 2 (Page 2) -> Login (Page 3) ──
            Timer(const Duration(seconds: 3), () {
              if (mounted && _currentPage == 2) {
                _pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutQuart,
                );
              }
            });
          }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0408),
        body: Container(
          // Unified Background for the whole flow
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 0.95,
              colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ── The Swipable Sequence ──
                PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(), // Better back/forward feel
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: const [
                    SplashContent(),
                    Onboarding1Content(),
                    Onboarding2Content(),
                    LoginContent(), // Now integrated as the last page
                  ],
                ),

                // ── Fixed Footer Dots & Skip ──
                // Hidden on the Login page (Page 3)
                if (_currentPage < 3)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // "skip" link on far left
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                3,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutQuart,
                              );
                            },
                            child: Text(
                              'skip',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: _currentPage == 2
                                    ? const Color(0xFFAC7827)
                                    : const Color(0xFF7A4060).withOpacity(0.85),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),

                        // Dots (3 Dots for the 3 Onboarding steps)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _sharedDot(active: _currentPage == 0),
                            const SizedBox(width: 8),
                            _sharedDot(active: _currentPage == 1),
                            const SizedBox(width: 8),
                            _sharedDot(active: _currentPage == 2),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sharedDot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 22 : 7,
      height: 5,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFF3A1525),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
