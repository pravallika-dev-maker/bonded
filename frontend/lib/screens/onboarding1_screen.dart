import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class Onboarding1Content extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding1Content({super.key, this.onNext, this.onSkip});

  @override
  State<Onboarding1Content> createState() => _Onboarding1ContentState();
}

class _Onboarding1ContentState extends State<Onboarding1Content> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  Timer? _autoPlayTimer;

  // Animation Controllers
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Soft floating animation for illustrations
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 2. Heart/icon pulse animation inside progress circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutQuad),
    );

    // 3. Card entrance transition fade
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
        if (_currentSlide < 3) {
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
    if (_currentSlide < 3) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0E0608),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. Full-screen PageView for Swiping Onboarding Pages
              Positioned.fill(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                    // Restart fade animation on change
                    _fadeController.reset();
                    _fadeController.forward();
                    // Restart auto-swipe timer on interaction
                    _startAutoPlay();
                  },
                  children: [
                    // Page 1: Native screen built entirely in Flutter
                    _buildScreen1(constraints),

                    // Page 2: Native Screen 2 built entirely in Flutter
                    _buildScreen2(constraints),

                    // Page 3: Native Screen 3 built entirely in Flutter
                    _buildScreen3(constraints),

                    // Page 4: Native Screen 5 built entirely in Flutter
                    _buildScreen5(constraints),
                  ],
                ),
              ),

              // 2. Top Dark Gradient Vignette for text readability
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
                          Colors.black.withOpacity(0.45),
                          Colors.black.withOpacity(0.18),
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Bottom Navigation Row (Skip on Left, Dots in Center, Next on Right)
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
                        // Skip Button (Aligned to the Left)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: widget.onSkip ?? () {},
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

                        // Centered Dots (Exactly 4 dots)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
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

                        // Next Button (Aligned to the Right)
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
      ),
    );
  }

  Widget _buildScreen1(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Background Illustration (Full bleed)
Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/onboarding/flow1/first_illustration.png',
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
          ),

          // 2. Foreground Content
          Column(
            children: [
              const SizedBox(height: 55),

              // Title & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        height: 1.25,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Love gets\n'),
                        TextSpan(
                          text: 'lost in routine.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: const Color(0xFFE89FB8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFB52B6E).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'Busy lives, endless distractions.\nSomewhere, we stop choosing each other.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE89FB8).withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Glassmorphic Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassShimmerOverlay(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB52B6E).withOpacity(0.06),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Stat Ring
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(80, 80),
                                    painter: GlassCircleProgressPainter(
                                      progress: 0.72,
                                      progressColor: const Color(0xFFB52B6E),
                                      trackColor: const Color(0xFF1B0711),
                                      strokeWidth: 6.0,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ScaleTransition(
                                        scale: _pulseAnimation,
                                        child: const Icon(
                                          Icons.people_outline_rounded,
                                          color: Color(0xFFE89FB8),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '72%',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Right text
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                  children: [
                                    const TextSpan(text: 'of couples say busy\nroutines reduce '),
                                    TextSpan(
                                      text: 'meaningful\nconversations.',
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFE89FB8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreen2(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Background Illustration (Full bleed)
Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/onboarding/flow1/second_illustration.png',
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
          ),

          // 2. Foreground Content
          Column(
            children: [
              const SizedBox(height: 55),

              // Title & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        height: 1.25,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Sometimes,\n'),
                        TextSpan(
                          text: 'growth needs room.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: const Color(0xFFE89FB8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFB52B6E).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "Stepping back isn't giving up.\nIt's creating space to grow together.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE89FB8).withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),

          const Spacer(),

          // Glassmorphic Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GlassShimmerOverlay(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB52B6E).withOpacity(0.06),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left side: Heart Circle
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(80, 80),
                                painter: GlassCircleHeartPainter(
                                  ringColor: const Color(0xFFB52B6E),
                                  strokeWidth: 2.0,
                                ),
                              ),
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB52B6E).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB52B6E).withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border_rounded,
                                    color: Color(0xFFE89FB8),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Right side text
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.quicksand(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(text: 'Experts recommend\n'),
                                TextSpan(
                                  text: 'intentional time',
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFE89FB8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' together\nto strengthen relationships.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 110),
        ],
      ),
    ],
  ),
);
}
  // Helper widget to build premium glassmorphism card
  Widget _buildGlassmorphicFeatureCard(IconData icon, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          width: 112,
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFFE27E9F), // Premium soft Bonded Pink
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Screen 3 Builder (100% Native Elements over Clean Illustration) ──
  Widget _buildScreen3(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Background Illustration (Full bleed)
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/onboarding/flow1/three_illustration.png',
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
          ),

          // 2. Foreground Content
          Column(
            children: [
              const SizedBox(height: 55),

              // Heading & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        height: 1.25,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Bonded becomes\n'),
                        TextSpan(
                          text: 'your safe space.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: const Color(0xFFE89FB8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFB52B6E).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "A private place to reflect, express\nand understand each other.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE89FB8).withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Glassmorphic Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassShimmerOverlay(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB52B6E).withOpacity(0.06),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left side: People Icon
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(80, 80),
                                    painter: GlassCirclePeoplePainter(
                                      ringColor: const Color(0xFFB52B6E),
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  ScaleTransition(
                                    scale: _pulseAnimation,
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB52B6E).withOpacity(0.12),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB52B6E).withOpacity(0.2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.people_rounded,
                                        color: Color(0xFFE89FB8),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Right side text
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Communicate, reflect and\nunderstand each other\n'),
                                    TextSpan(
                                      text: 'only through Bonded.',
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFE89FB8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }

  // ── Screen 4 Builder (100% Native Elements over Clean Illustration) ──
  Widget _buildScreen4(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Background Illustration (Full bleed)
Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/onboarding/flow1/four_illustration.jpg',
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
          ),

          // 2. Foreground Content
          Column(
            children: [
              const SizedBox(height: 20),

              // Title & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        height: 1.25,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Small moments\n'),
                        TextSpan(
                          text: 'create big changes.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: const Color(0xFFE89FB8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFB52B6E).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "Check-in, share and grow together\nwith everyday moments.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE89FB8).withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Glassmorphic Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassShimmerOverlay(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB52B6E).withOpacity(0.06),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionChip(
                              icon: Icons.edit_rounded,
                              label: 'Reflect',
                            ),
                            _buildVerticalDivider(),
                            _buildActionChip(
                              icon: Icons.mood_rounded,
                              label: 'Check-in',
                            ),
                            _buildVerticalDivider(),
                            _buildActionChip(
                              icon: Icons.mail_rounded,
                              label: 'Share',
                            ),
                            _buildVerticalDivider(),
                            _buildActionChip(
                              icon: Icons.star_rounded,
                              label: 'Grow',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFE89FB8),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ── Screen 5 Builder (100% Native Elements over Clean Illustration) ──
  Widget _buildScreen5(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Background Illustration (Full bleed)
Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/onboarding/flow1/five_illustration.png',
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
          ),

          // 2. Foreground Content
          Column(
            children: [
              const SizedBox(height: 20),

              // Title & Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        height: 1.25,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Understanding\n'),
                        TextSpan(
                          text: 'brings us back\nstronger.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: const Color(0xFFE89FB8),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFB52B6E).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "Every conversation, every apology,\nevery listen — builds a deeper bond.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE89FB8).withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Glassmorphic Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassShimmerOverlay(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB52B6E).withOpacity(0.06),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left side: Progress Ring
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(80, 80),
                                    painter: GlassCircleProgressPainter(
                                      progress: 0.80,
                                      progressColor: const Color(0xFFB52B6E),
                                      trackColor: const Color(0xFF1B0711),
                                      strokeWidth: 6.0,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ScaleTransition(
                                        scale: _pulseAnimation,
                                        child: const Icon(
                                          Icons.people_outline_rounded,
                                          color: Color(0xFFE89FB8),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '80%',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Right side text
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                  children: [
                                    const TextSpan(text: 'of couples who took\n'),
                                    TextSpan(
                                      text: 'intentional time apart,',
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFE89FB8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: '\nreconnected with a\nhealthier relationship.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1.5,
      height: 32,
      color: Colors.white.withOpacity(0.08),
    );
  }

  // ── High Fidelity Placeholder Page Builder ──
  Widget _buildPlaceholderPage(
    BoxConstraints constraints, {
    required int slideNum,
    required String titleText1,
    required String titleText2,
    required String subtitle,
    required String illustrationAsset,
  }) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                      height: 1.25,
                    ),
                    children: [
                      TextSpan(
                        text: '$titleText1\n',
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: titleText2,
                        style: const TextStyle(
                          color: Color(0xFFE89FB8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF8B6774),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Illustration
          Expanded(
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Image.asset(
                  illustrationAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Temporary Glass Card to maintain page layout consistency
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Card details for screen $slideNum will go here',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: const Color(0xFF8B6774),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Custom Painter for the Glassmorphic Circular Progress Arc ──
class GlassCircleProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  GlassCircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start angle is -pi / 2 (top of circle)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw sparkle star at the end point of the progress arc
    if (progress > 0) {
      final endAngle = startAngle + sweepAngle;
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);

      final sparklePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // Draw simple 4-point star/sparkle shape
      final path = Path();
      const sparkleSize = 4.0;
      path.moveTo(endX, endY - sparkleSize); // Top
      path.quadraticBezierTo(endX, endY, endX + sparkleSize, endY); // Right
      path.quadraticBezierTo(endX, endY, endX, endY + sparkleSize); // Bottom
      path.quadraticBezierTo(endX, endY, endX - sparkleSize, endY); // Left
      path.quadraticBezierTo(endX, endY, endX, endY - sparkleSize); // Top back
      path.close();

      // Add a small glow under the star
      canvas.drawCircle(
        Offset(endX, endY),
        sparkleSize * 1.8,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      canvas.drawPath(path, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Custom Painter for the Glassmorphic Circular Heart Outline ──
class GlassCircleHeartPainter extends CustomPainter {
  final Color ringColor;
  final double strokeWidth;

  GlassCircleHeartPainter({
    required this.ringColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = ringColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);

    // Draw sparkle star on the ring at -45 degrees (top-right)
    const angle = -math.pi / 4;
    final endX = center.dx + radius * math.cos(angle);
    final endY = center.dy + radius * math.sin(angle);

    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const sparkleSize = 4.0;
    path.moveTo(endX, endY - sparkleSize); // Top
    path.quadraticBezierTo(endX, endY, endX + sparkleSize, endY); // Right
    path.quadraticBezierTo(endX, endY, endX, endY + sparkleSize); // Bottom
    path.quadraticBezierTo(endX, endY, endX - sparkleSize, endY); // Left
    path.quadraticBezierTo(endX, endY, endX, endY - sparkleSize); // Top back
    path.close();

    canvas.drawCircle(
      Offset(endX, endY),
      sparkleSize * 1.8,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(path, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom Painter for the Glassmorphic Circular People Outline ──
class GlassCirclePeoplePainter extends CustomPainter {
  final Color ringColor;
  final double strokeWidth;

  GlassCirclePeoplePainter({
    required this.ringColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = ringColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);

    // Draw sparkle star on the ring at -45 degrees (top-right)
    const angle = -math.pi / 4;
    final endX = center.dx + radius * math.cos(angle);
    final endY = center.dy + radius * math.sin(angle);

    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    const sparkleSize = 4.0;
    path.moveTo(endX, endY - sparkleSize); // Top
    path.quadraticBezierTo(endX, endY, endX + sparkleSize, endY); // Right
    path.quadraticBezierTo(endX, endY, endX, endY + sparkleSize); // Bottom
    path.quadraticBezierTo(endX, endY, endX - sparkleSize, endY); // Left
    path.quadraticBezierTo(endX, endY, endX, endY - sparkleSize); // Top back
    path.close();

    canvas.drawCircle(
      Offset(endX, endY),
      sparkleSize * 1.8,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(path, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Glass Shimmer/Glow Animation Overlay ──
class GlassShimmerOverlay extends StatefulWidget {
  final Widget child;
  const GlassShimmerOverlay({super.key, required this.child});

  @override
  State<GlassShimmerOverlay> createState() => _GlassShimmerOverlayState();
}

class _GlassShimmerOverlayState extends State<GlassShimmerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _controller.value - 0.2,
                _controller.value,
                _controller.value + 0.2,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class PremiumBLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w / 2;
    double cy = h / 2;

    // 1. Draw perfectly circular, evenly spaced orbit lines
    Paint orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy), w * 0.26, orbitPaint);
    canvas.drawCircle(Offset(cx, cy), w * 0.38, orbitPaint);

    // 2. Draw a few subtle floating particles (reduced count, minimal)
    Paint particlePaint = Paint()
      ..color = const Color(0xFFE27E9F).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx + w * 0.26 * 0.7, cy - w * 0.26 * 0.7), 2.0, particlePaint);
    canvas.drawCircle(Offset(cx - w * 0.26 * 0.5, cy + w * 0.26 * 0.86), 1.5, particlePaint);
    canvas.drawCircle(Offset(cx - w * 0.38 * 0.86, cy - w * 0.38 * 0.5), 2.5, particlePaint);
    canvas.drawCircle(Offset(cx + w * 0.38 * 0.9, cy + w * 0.38 * 0.4), 1.5, particlePaint);

    // 3. Draw premium symmetrical B logo with soft bloom outline
    // Outer soft glow (bloom) - reduced by 70%
    Paint glowPaint = Paint()
      ..color = const Color(0xFFE27E9F).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Crisp foreground line
    Paint linePaint = Paint()
      ..color = const Color(0xFFE27E9F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    
    // Proportional sizing for the B logo
    double bTop = cy - 32;
    double bBottom = cy + 32;
    double bLeft = cx - 15;
    double bMid = cy;

    // Stem
    path.moveTo(bLeft, bTop);
    path.lineTo(bLeft, bBottom);

    // Top loop
    path.moveTo(bLeft, bTop);
    path.cubicTo(
      bLeft + 28, bTop, 
      bLeft + 28, bMid, 
      bLeft, bMid
    );

    // Bottom loop
    path.cubicTo(
      bLeft + 30, bMid, 
      bLeft + 30, bBottom, 
      bLeft, bBottom
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
