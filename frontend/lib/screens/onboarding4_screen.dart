import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class Onboarding4Screen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding4Screen({super.key, this.onNext, this.onSkip});

  @override
  State<Onboarding4Screen> createState() => _Onboarding4ScreenState();
}

class _Onboarding4ScreenState extends State<Onboarding4Screen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _autoPlayTimer;

  late AnimationController _fadeController;

  // Colors mapping from HTML/CSS variables
  final Color bgApp = const Color(0xFF0A030E);
  final Color roseDeep = const Color(0xFF8B1A4A);
  final Color roseMid = const Color(0xFFC2185B);
  final Color roseHero = const Color(0xFFE8829A);
  final Color cream = const Color(0xFFFDE8F0);
  final Color textMid = const Color(0xFFD4A0B8);
  final Color goldAccent = const Color(0xFFC9954A);
  final Color goldCream = const Color(0xFFFFF8E6);
  final Color headingPink = const Color(0xFFF9C4D9);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeController.forward();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentSlide < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOutQuart,
          );
        } else {
          _autoPlayTimer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutQuart,
      );
    } else {
      if (widget.onNext != null) widget.onNext!();
    }
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: bgApp,
          body: Stack(
            children: [
              // Ambient Glow Orbs (Background layer)
              // Glow Top-Right
              Positioned(
                top: -65,
                right: -60,
                width: 270,
                height: 270,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB41E50).withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
              // Glow Bottom-Left
              Positioned(
                bottom: -50,
                left: -50,
                width: 200,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC9954A).withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
              // Glow Bottom-Right
              Positioned(
                bottom: -35,
                right: -30,
                width: 150,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB41E50).withOpacity(0.07),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),

              // Main Content Stack
              SafeArea(
                child: Column(
                  children: [
                    // Header Bar (Slide index count, Progress lines, Skip button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          // Step Count
                          Text(
                            '${_currentSlide + 1}/3',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: roseHero,
                              letterSpacing: 0.02,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Progress Dots/Lines
                          Expanded(
                            child: Row(
                              children: List.generate(
                                3,
                                (index) => Expanded(
                                  child: Container(
                                    height: 3,
                                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                    decoration: BoxDecoration(
                                      color: roseHero.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _currentSlide >= index ? 1.0 : 0.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [roseMid.withOpacity(0.9), roseMid],
                                          ),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: widget.onSkip ?? () => _goToSlide(2),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontFamily: 'Georgia', 
                                fontSize: 13,
                                color: roseHero.withOpacity(0.55),
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor: roseHero.withOpacity(0.25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Swipable Main Container
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentSlide = index;
                          });
                          _fadeController.reset();
                          _fadeController.forward();
                          _startAutoPlay(); // Restart timer on swipe
                        },
                        children: [
                          _buildSlide1(),
                          _buildSlide2(),
                          _buildSlide3(),
                        ],
                      ),
                    ),

                    // Slide Footer (Nav Button)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _nextSlide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: roseDeep.withOpacity(0.90),
                              foregroundColor: cream,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              shape: const StadiumBorder(),
                              elevation: 4,
                              shadowColor: roseDeep.withOpacity(0.22),
                              side: BorderSide(
                                color: const Color(0xFFFFB4D2).withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentSlide == 2 ? 'Get Started' : 'Continue',
                                  style: TextStyle(fontFamily: 'Georgia', 
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: cream,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Slide 1 Layout ──
  Widget _buildSlide1() {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Hero Illustration Box
          _buildHeroArt('assets/onboarding/flow4/illustration_1.jpeg', height: 290.0),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Healthy distance\nstrengthens relationships.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.15,
                      color: headingPink,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFF4A0BC).withOpacity(0.35),
                          blurRadius: 18,
                        ),
                        Shadow(
                          color: const Color(0xFFC2185B).withOpacity(0.18),
                          blurRadius: 42,
                        ),
                      ],
                    ),
                  ),

                  // Heart Divider
                  _buildHeartDivider(),

                  // Copy text
                  Text(
                    'Time apart helps couples reconnect with greater understanding and appreciation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5,
                      height: 1.65,
                      color: textMid,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Stat Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9954A).withOpacity(0.07),
                      border: Border.all(
                        color: const Color(0xFFC9954A).withOpacity(0.28),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '💛',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '80%',
                          style: TextStyle(fontFamily: 'Georgia', 
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: goldCream,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'feel closer after healthy time apart.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: const Color(0xFFFFDC96).withOpacity(0.65),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Privacy Note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: roseHero.withOpacity(0.35),
                        size: 14,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Recommended by relationship experts.',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: roseHero.withOpacity(0.35),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Slide 2 Layout ──
  Widget _buildSlide2() {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Hero Illustration Box
          _buildHeroArt('assets/onboarding/flow4/illustration_2.jpeg', height: 290.0),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Distance with purpose.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.15,
                      color: headingPink,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFF4A0BC).withOpacity(0.35),
                          blurRadius: 18,
                        ),
                        Shadow(
                          color: const Color(0xFFC2185B).withOpacity(0.18),
                          blurRadius: 42,
                        ),
                      ],
                    ),
                  ),

                  // Heart Divider
                  _buildHeartDivider(),

                  // Copy text
                  Text(
                    'Understand each other better, appreciate what routine hid, and rediscover your connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5,
                      height: 1.65,
                      color: textMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Slide 3 Layout ──
  Widget _buildSlide3() {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Hero Illustration Box (slightly shorter per web spec: 330px)
          _buildHeroArt('assets/onboarding/flow4/illustration_3.jpeg', height: 260.0),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  // Feature List Rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureItem(Icons.playlist_add_check_rounded, 'Mood\nCheck-ins'),
                      const SizedBox(width: 24),
                      _buildFeatureItem(Icons.edit_note_rounded, 'Reflections'),
                      const SizedBox(width: 24),
                      _buildFeatureItem(Icons.auto_awesome_rounded, 'Relationship\nInsights'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    'Reconnect,\nstronger than before.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.15,
                      color: headingPink,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFF4A0BC).withOpacity(0.35),
                          blurRadius: 18,
                        ),
                        Shadow(
                          color: const Color(0xFFC2185B).withOpacity(0.18),
                          blurRadius: 42,
                        ),
                      ],
                    ),
                  ),

                  // Heart Divider
                  _buildHeartDivider(),

                  // Copy text
                  Text(
                    'A guided journey of check-ins, reflections, and insights to help you reconnect stronger.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Georgia', 
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5,
                      height: 1.65,
                      color: textMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build illustration box
  Widget _buildHeroArt(String imagePath, {double height = 360.0}) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF150A18),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: roseHero.withOpacity(0.10),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Helper widget to build horizontal heart line divider
  Widget _buildHeartDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 1,
            color: roseHero.withOpacity(0.25),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.favorite_rounded,
            color: roseMid.withOpacity(0.5),
            size: 14,
          ),
          const SizedBox(width: 10),
          Container(
            width: 70,
            height: 1,
            color: roseHero.withOpacity(0.25),
          ),
        ],
      ),
    );
  }

  // Helper widget to build features inside slide 3
  Widget _buildFeatureItem(IconData icon, String labelText) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldAccent.withOpacity(0.15),
              border: Border.all(
                color: goldAccent.withOpacity(0.30),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: goldAccent,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            labelText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFE6BE).withOpacity(0.75),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
