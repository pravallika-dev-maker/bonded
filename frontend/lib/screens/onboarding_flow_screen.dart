import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'onboarding1_screen.dart';
import 'onboarding2_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'main_dashboard_screen.dart';

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
    
    _checkAuthAndRoute();
  }

  Future<void> _checkAuthAndRoute() async {
    // 1. Wait a minimum time for the splash to be visible (e.g., 2.5s)
    final splashTimer = Future.delayed(const Duration(milliseconds: 2500));
    
    // 2. Perform network/auth check
    bool isLoggedInAndOnboarded = false;
    bool isPartnerConnected = false;
    String? userName;
    String? partnerName;
    
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Optimistically assume we are logged in if we have a token
        isLoggedInAndOnboarded = true;
        
        // Try to fetch cached data first if available
        userName = await ApiService.getUserName();
        partnerName = await ApiService.getPartnerName(); // We only cache partner name currently, will update below if api succeeds
        
        try {
          final profileResponse = await ApiService.getUserMe();
          final profile = profileResponse['data'] ?? profileResponse;
          
          // Check if onboarding fields exist (guard against empty strings)
          final rawUserName = profile['userName'] ?? profile['name'];
          if (rawUserName != null && rawUserName.toString().trim().isNotEmpty) {
            userName = rawUserName.toString().trim();
            partnerName = (profile['partnerName'] ?? '').toString().trim();

            // Try to get hero data to check partner connection status
            try {
              final heroData = await ApiService.getHomeHero();
              isPartnerConnected =
                  heroData['partner_connected'] == true ||
                  heroData['partnerConnected'] == true ||
                  heroData['is_partner_connected'] == true;
                  
              // If they started a solo separation, they should also go to the dashboard
              if (!isPartnerConnected) {
                final activeSep = await ApiService.getActiveSeparation().catchError((_) => null);
                if (activeSep != null && (activeSep['is_active'] == true || activeSep['isActive'] == true || activeSep['status'] == 'active')) {
                  isPartnerConnected = true; // Force navigation to main dashboard
                }
              }
                  
              if (!isPartnerConnected && (heroData['partner_name'] != null || heroData['partnerName'] != null)) {
                partnerName = heroData['partner_name'] ?? heroData['partnerName'] ?? partnerName;
              }
            } catch (_) {
              // Fallback: check partner connected from profile
              isPartnerConnected =
                  profile['isPartnerConnected'] == true ||
                  profile['is_partner_connected'] == true ||
                  profile['partner_connected'] == true ||
                  (profile['partner'] != null && profile['partner'] is Map);
                  
              if (!isPartnerConnected) {
                try {
                  final activeSep = await ApiService.getActiveSeparation().catchError((_) => null);
                  if (activeSep != null && (activeSep['is_active'] == true || activeSep['isActive'] == true || activeSep['status'] == 'active')) {
                    isPartnerConnected = true;
                  }
                } catch (_) {}
              }
            }
          }
        } catch (e) {
          // Network failed (likely Render server waking up)
          // We keep isLoggedInAndOnboarded = true because we have a token
          // We will route them to the dashboard/home and the components will show loaders
          debugPrint("Offline or server waking up, but token exists. Proceeding optimistically.");
          
          // Try to get cached user and partner names and connection status
          userName = await ApiService.getUserName();
          partnerName = await ApiService.getPartnerName();
          isPartnerConnected = await ApiService.getIsPartnerConnected();
        }
      }
    } catch (e) {
      // SharedPreferences failure? Fall back to onboarding
      isLoggedInAndOnboarded = false;
    }

    await splashTimer;

    if (!mounted) return;

    if (isLoggedInAndOnboarded) {
      if (isPartnerConnected) {
        // Partner already connected or active solo separation — go straight to the main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainDashboardScreen(
              userName: userName ?? '',
              partnerName: partnerName ?? '',
            ),
          ),
        );
      } else {
        // Still waiting for partner
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userName: userName ?? '',
              partnerName: partnerName ?? '',
            ),
          ),
        );
      }
    } else {
      // Hide splash and show onboarding
      setState(() {
        _splashOpacity = 0.0;
        _splashScale = 1.05; // Expands outward smoothly as it fades
      });
    }
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
