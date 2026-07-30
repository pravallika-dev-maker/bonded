import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class Onboarding2Content extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding2Content({super.key, this.onNext, this.onSkip});

  @override
  State<Onboarding2Content> createState() => _Onboarding2ContentState();
}

class _Onboarding2ContentState extends State<Onboarding2Content> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _autoPlayTimer;

  // Animations
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // 1. Float Animation (for subtle icons floating)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 2. Pulse Animation (for heart icon)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutQuad),
    );

    // 3. Fade Controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();

    // Start auto-swipe play timer
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_currentSlide < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _autoPlayTimer?.cancel();
        }
      }
    });
  }

  void _nextSlide() {
    if (_currentSlide < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (widget.onNext != null) widget.onNext!();
    }
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 1. Swipable Pages
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                  _startAutoPlay();
                },
                children: [
                  _buildScreen1(constraints),
                  _buildScreen2(constraints),
                  _buildScreen3(constraints),
                ],
              ),
            ),

            // 2. Top Vignette (to blend illustrations softly)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: constraints.maxHeight * 0.32,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0A030E).withOpacity(0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Skip Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: widget.onSkip ?? () => _goToSlide(2),
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: GoogleFonts.quicksand(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B6774),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF8B6774),
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Pagination Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => GestureDetector(
                            onTap: () => _goToSlide(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: _currentSlide == index ? 24.0 : 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: _currentSlide == index
                                    ? const Color(0xFFE89FB8)
                                    : const Color(0xFF8B6774).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next Arrow Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8A2E55).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _nextSlide,
                                child: Ink(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF8A2E55), Color(0xFFB52B6E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Flow 2 Screen 1 ──
  Widget _buildScreen1(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // Background Image with Vignette
          _buildBackgroundImage('assets/onboarding/flow1/first_illustration.png'),

          // Foreground Text & Cards
          Column(
            children: [
              const SizedBox(height: 55),
              _buildHeaderIcon(Icons.heart_broken_rounded),

              // Headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          height: 1.25,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Love gets lost\n'),
                          TextSpan(
                            text: 'in routine.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFFE89FB8),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Busy lives. Endless distractions.\nSomewhere, we stop choosing each other.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Glassmorphic Card (Work, Notifications, Responsibilities, No Time)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCardItem(Icons.business_center_rounded, 'Work'),
                      _buildDivider(),
                      _buildCardItem(Icons.notifications_active_rounded, 'Notifications'),
                      _buildDivider(),
                      _buildCardItem(Icons.fact_check_rounded, 'Responsibilities'),
                      _buildDivider(),
                      _buildCardItem(Icons.access_time_filled_rounded, 'No Time'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Label with Heart
              Column(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE89FB8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It happens to every couple.',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "You're not alone.",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: const Color(0xFFE89FB8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 110), // Safe spacing above dots
            ],
          ),
        ],
      ),
    );
  }

  // ── Flow 2 Screen 2 ──
  Widget _buildScreen2(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // Background Image
          _buildBackgroundImage('assets/onboarding/flow1/second_illustration.png'),

          // Foreground Content
          Column(
            children: [
              const SizedBox(height: 55),
              _buildHeaderIcon(Icons.spa_rounded),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          height: 1.2,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'A little space\n'),
                          TextSpan(
                            text: 'can bring\nhearts closer.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFFE89FB8),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 3 Centered Circles: Peace, Understanding, Growth
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleIndicator(Icons.spa_rounded, 'Peace'),
                  const SizedBox(width: 24),
                  _buildCircleIndicator(Icons.favorite_rounded, 'Understanding'),
                  const SizedBox(width: 24),
                  _buildCircleIndicator(Icons.auto_awesome_rounded, 'Growth'),
                ],
              ),

              const SizedBox(height: 24),

              // Bottom subtitle lines
              Column(
                children: [
                  Text(
                    "Space isn't separation.",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "It's choosing love, differently.",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: const Color(0xFFE89FB8),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }

  // ── Flow 2 Screen 3 ──
  Widget _buildScreen3(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // Background Image
          _buildBackgroundImage('assets/onboarding/flow1/five_illustration.png'),

          // Foreground Content formatted statically to fit all devices with zero overflow/scroll
          Column(
            children: [
              const SizedBox(height: 12), // Reduced top padding to resolve overflow
              _buildHeaderIcon(Icons.trending_up_rounded),

              // Heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      fontSize: 28, // Reduced from 32
                      height: 1.2,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'Space today,\n'),
                      TextSpan(
                        text: 'stronger tomorrow.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFFE89FB8),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subheading Subtitle Description Copy
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 6.0, 32.0, 0.0),
                child: Text(
                  'Couples who take intentional space through Bonded reconnect with more love, respect and understanding.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5, // Reduced from 12
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              // Center Composition: Flowing Ribbon Line & Floating Glass Statistic Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  // Symmetrical, thin-outline Cupertino heart icon in larger size
                  Icon(
                    CupertinoIcons.heart,
                    size: 260,
                    color: const Color(0xFFE89FB8).withOpacity(0.18), // 18% opacity for clean backdrop
                  ),

                  // Centered statistic text (without circular container)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '80%',
                          style: GoogleFonts.quicksand(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFF8E6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 180,
                          child: Text(
                            'of couples reconnect\nafter intentional space',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFE89FB8).withOpacity(0.95),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Glassmorphic Card (More Empathy, Better Communication, Deeper Connection, Lasting Love)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCardItem(Icons.groups_rounded, 'More Empathy'),
                      _buildDivider(),
                      _buildCardItem(Icons.forum_rounded, 'Better Comm.'),
                      _buildDivider(),
                      _buildCardItem(Icons.favorite_rounded, 'Deeper Conn.'),
                      _buildDivider(),
                      _buildCardItem(Icons.thumb_up_rounded, 'Lasting Love'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Take space. Grow together. Reconnect.
              Text(
                'Take space. Grow together. Reconnect.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE89FB8),
                ),
              ),

              const SizedBox(height: 110), // Safe spacing above bottom controls to prevent overlap and align with screen 1 & 2
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2E0C1B).withOpacity(0.4),
        border: Border.all(
          color: const Color(0xFFB52B6E).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB52B6E).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFFE89FB8),
        size: 22,
      ),
    );
  }

  // Helper widget to build image background with gradient vignette
  Widget _buildBackgroundImage(String imagePath) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: const Color(0xFF0A030E).withOpacity(0.20),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A030E).withOpacity(0.65),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF0A030E).withOpacity(0.75),
                  ],
                  stops: const [0.0, 0.28, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build horizontal dividers inside card row
  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.white.withOpacity(0.08),
    );
  }

  // Helper widget for Slide 2 indicators (Lotus, Heart, Sparkles)
  Widget _buildCircleIndicator(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2E0C1B).withOpacity(0.5),
            border: Border.all(
              color: const Color(0xFFB52B6E).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB52B6E).withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE89FB8),
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Helper widget to build card item with icon & label
  Widget _buildCardItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFE89FB8),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build floating floating icons
  Widget _buildFloatingIcon(IconData icon, double x, double y, Offset extraOffset) {
    return Positioned(
      left: x + extraOffset.dx,
      top: y + extraOffset.dy,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2E0C1B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB52B6E).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB52B6E).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE89FB8),
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
