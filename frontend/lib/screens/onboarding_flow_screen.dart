import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'onboarding1_screen.dart';
import 'onboarding2_screen.dart';
import 'onboarding3_screen.dart';
import 'onboarding4_screen.dart';
import 'onboarding/tutorial_onboarding.dart';
import 'onboarding/emotional_onboarding.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _assignedFlowKey = 'stats_based'; // default fallback config key

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
    // 1. Start the minimum 2-second timer for the splash screen
    final splashTimer = Future.delayed(const Duration(milliseconds: 2000));
    
    // 2. Start the network/auth check and config fetch in parallel
    final Future<Map<String, dynamic>?> configFuture = () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        String? deviceId = prefs.getString('device_id');
        if (deviceId == null) {
          deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(900000) + 100000}';
          await prefs.setString('device_id', deviceId);
        }
        return await ApiService.getOnboardingConfig(deviceId)
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("Failed to fetch backend onboarding config: $e");
        return null;
      }
    }();

    bool isLoggedInAndOnboarded = false;
    bool isPartnerConnected = false;
    String? userName;
    String? partnerName;

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        isLoggedInAndOnboarded = true;
        userName = await ApiService.getUserName();
        partnerName = await ApiService.getPartnerName();
        
        try {
          final profileResponse = await ApiService.getUserMe()
              .timeout(const Duration(seconds: 2));
          final profile = profileResponse['data'] ?? profileResponse;
          final rawUserName = profile['userName'] ?? profile['name'];
          if (rawUserName != null && rawUserName.toString().trim().isNotEmpty) {
            userName = rawUserName.toString().trim();
            final fetchedPartnerName = (profile['partnerName'] ?? '').toString().trim();
            if (fetchedPartnerName.isNotEmpty) {
              partnerName = fetchedPartnerName;
            }

            try {
              final heroData = await ApiService.getHomeHero()
                  .timeout(const Duration(seconds: 2));
              isPartnerConnected =
                  heroData['partner_connected'] == true ||
                  heroData['partnerConnected'] == true ||
                  heroData['is_partner_connected'] == true;
                  
              if (!isPartnerConnected) {
                final activeSep = await ApiService.getActiveSeparation()
                    .timeout(const Duration(seconds: 2))
                    .catchError((_) => null);
                if (activeSep != null && (activeSep['is_active'] == true || activeSep['isActive'] == true || activeSep['status'] == 'active')) {
                  isPartnerConnected = true;
                }
              }
            } catch (_) {
              isPartnerConnected =
                  profile['isPartnerConnected'] == true ||
                  profile['is_partner_connected'] == true ||
                  profile['partner_connected'] == true;
            }
          }
        } catch (_) {
          isPartnerConnected = await ApiService.getIsPartnerConnected();
        }
      }
    } catch (_) {
      isLoggedInAndOnboarded = false;
    }

    // Wait for BOTH the minimum splash timer and the config response
    final results = await Future.wait([splashTimer, configFuture]);
    final Map<String, dynamic>? configResponse = results[1] as Map<String, dynamic>?;

    String flowKey = 'stats_based'; // default fallback
    if (configResponse != null && configResponse.containsKey('flow_key')) {
      flowKey = configResponse['flow_key'].toString();
    }

    if (!mounted) return;

    setState(() {
      _assignedFlowKey = flowKey;
    });

    if (isLoggedInAndOnboarded) {
      if (isPartnerConnected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainDashboardScreen(
              userName: userName ?? '',
              partnerName: partnerName ?? '',
            ),
          ),
        );
        return;
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userName: userName ?? '',
              partnerName: partnerName ?? '',
            ),
          ),
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
    
    if (hasSeen) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(1);
      }
      setState(() {
        _currentPage = 1;
      });
    } else {
      await prefs.setBool('has_seen_onboarding', true);
    }

    // Hide splash and show onboarding/login
    setState(() {
      _splashOpacity = 0.0;
      _splashScale = 1.05; // Expands outward smoothly as it fades
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
                    _buildActiveOnboardingWidget(() {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutQuart,
                      );
                    }),
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
    return PopScope(
      canPop: !_showSplash && _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_showSplash && _currentPage > 0) {
          _pageController.animateToPage(
            _currentPage - 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
          );
        }
      },
      child: Stack(
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
      ),
    );
  }

  Widget _buildActiveOnboardingWidget(VoidCallback onFinish) {
    switch (_assignedFlowKey) {
      case 'story_based':
        return Onboarding1Content(
          onNext: onFinish,
          onSkip: onFinish,
        );
      case 'tutorial':
        return Onboarding3Screen(
          onNext: onFinish,
          onSkip: onFinish,
        );
      case 'emotional':
        return Onboarding4Screen(
          onNext: onFinish,
          onSkip: onFinish,
        );
      case 'stats_based':
      default:
        return Onboarding2Content(
          onNext: onFinish,
          onSkip: onFinish,
        );
    }
  }
}
