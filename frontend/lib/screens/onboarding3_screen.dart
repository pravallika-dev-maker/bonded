import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class Onboarding3Screen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding3Screen({super.key, this.onNext, this.onSkip});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _autoPlayTimer;

  late AnimationController _fadeController;

  // Colors mapping from HTML/CSS variables
  final Color bgApp = const Color(0xFF0A030E);
  final Color bgCardBase = const Color(0xFF0F0610);
  final Color roseDeep = const Color(0xFF8B1A4A);
  final Color roseMid = const Color(0xFFC2185B);
  final Color roseHero = const Color(0xFFE8829A);
  final Color cream = const Color(0xFFFDE8F0);
  final Color textHigh = const Color(0xFFF0D0DE);
  final Color textMid = const Color(0xFFD4A0B8);
  final Color goldAccent = const Color(0xFFC9954A);
  final Color goldCream = const Color(0xFFFFF8E6);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
            duration: const Duration(milliseconds: 600),
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
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      if (widget.onNext != null) widget.onNext!();
    }
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: bgApp,
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -1.0), // top center
                radius: 1.4,
                colors: [
                  Color(0xFF150810),
                  Color(0xFF050206),
                ],
                stops: [0.0, 0.75],
              ),
            ),
            child: Stack(
              children:[
              // 1. Full-bleed background image on Slide 1 (Fades out when swiped)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _currentSlide == 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(
                    'assets/onboarding/flow3/illustration_1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              // Gradient Overlay on the background image to merge it seamlessly into bgApp
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _currentSlide == 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgApp.withOpacity(0.88),
                          bgApp.withOpacity(0.18),
                          bgApp.withOpacity(0.92),
                        ],
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Ambient Glow Orbs (Background layer)
              // Glow Top-Right
              Positioned(
                top: -46,
                right: -46,
                width: 210,
                height: 210,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB41E50).withOpacity(0.30),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
              // Glow Bottom-Left
              Positioned(
                bottom: -40,
                left: -36,
                width: 160,
                height: 160,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC9954A).withOpacity(0.16),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),
              // Glow Bottom-Right
              Positioned(
                bottom: -24,
                right: -30,
                width: 120,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB41E50).withOpacity(0.14),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                ),
              ),

              // 2. Main Content Stack
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      // Top Bar (Dots indicator & Skip button)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dots Indicator
                          Row(
                            children: List.generate(
                              3,
                              (index) => GestureDetector(
                                onTap: () => _goToSlide(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                  width: _currentSlide == index ? 18.0 : 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    color: _currentSlide == index
                                        ? roseMid
                                        : roseHero.withOpacity(0.28),
                                    borderRadius: BorderRadius.circular(3.0),
                                    boxShadow: _currentSlide == index
                                        ? [
                                            BoxShadow(
                                              color: roseMid.withOpacity(0.6),
                                              blurRadius: 8,
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Skip button
                          GestureDetector(
                            onTap: widget.onSkip ?? () {},
                            child: Text(
                              'Skip',
                              style: TextStyle(fontFamily: 'Georgia', 
                                fontSize: 13,
                                color: roseHero.withOpacity(0.55),
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor: roseHero.withOpacity(0.20),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 3. Swipable Body
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
                            _buildScreen1(constraints),
                            _buildScreen2(constraints),
                            _buildScreen3(constraints),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Footer controls (Step marker & Button)
                      Column(
                        children: [
                          // Step Marker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 1,
                                color: roseHero.withOpacity(0.28),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '0${_currentSlide + 1}',
                                style: TextStyle(fontFamily: 'Georgia', 
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: roseHero.withOpacity(0.45),
                                  letterSpacing: 0.04,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: 1,
                                color: roseHero.withOpacity(0.28),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Continue Button
                          ElevatedButton(
                            onPressed: _nextSlide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: roseDeep.withOpacity(0.90),
                              foregroundColor: cream,
                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                              shape: const StadiumBorder(),
                              elevation: 4,
                              shadowColor: roseDeep.withOpacity(0.28),
                              side: BorderSide(
                                color: const Color(0xFFFFB4D2).withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: cream.withOpacity(0.9),
                                  size: 14,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Continue',
                                  style: TextStyle(fontFamily: 'Georgia', 
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
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
        ),
      );
    },
  );
}

  // ── Screen 1 Layout (Text only, floats on top of background image) ──
  Widget _buildScreen1(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Headings
          Text(
            'Healthy separation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', 
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: textHigh,
              height: 1.15,
            ),
          ),
          Text(
            'Stronger relationships.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', 
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: roseHero,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 12),

          // Divider
          _buildHeartDivider(),

          const SizedBox(height: 12),

          // Description Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              'Bonded guides you through time apart while keeping you emotionally connected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Georgia', 
                fontSize: 14.5,
                fontStyle: FontStyle.italic,
                height: 1.75,
                color: textMid,
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  // ── Screen 2 Layout (Before / After Comparison List) ──
  Widget _buildScreen2(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Headings
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontFamily: 'Georgia', 
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: textHigh,
                height: 1.15,
              ),
              children: [
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'Bonded',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: roseHero,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'transforms your relationship',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', 
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: roseHero,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 16),

          // Transformation Column Label Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BEFORE',
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: roseHero.withOpacity(0.55),
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'AFTER',
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: goldAccent.withOpacity(0.65),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Transformation List
          Expanded(
            child: Stack(
              children: [
                // Dotted vertical thread line in the center background
                Align(
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: DottedLinePainter(
                      color: roseHero.withOpacity(0.32),
                    ),
                  ),
                ),

                // Transition Rows
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTransformRow('Routine', 'Reflection', true),
                    _buildTransformRow('Assumptions', 'Understanding', false),
                    _buildTransformRow('Emotional Distance', 'Emotional Connection', false),
                    _buildTransformRow('Taken for Granted', 'Greater Appreciation', true),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _buildHeartDivider(),

          // Bottom Quote text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontFamily: 'Georgia', 
                  fontSize: 14.5,
                  fontStyle: FontStyle.italic,
                  color: textMid,
                  height: 1.7,
                ),
                children: [
                  const TextSpan(text: 'Small moments apart can create\n'),
                  TextSpan(
                    text: 'stronger moments together.',
                    style: TextStyle(
                      color: roseHero,
                      fontWeight: FontWeight.w600,
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

  // ── Screen 3 Layout (Responsive Statistic Ring) ──
  Widget _buildScreen3(BoxConstraints constraints) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Headings
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontFamily: 'Georgia', 
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: textHigh,
                height: 1.15,
              ),
              children: [
                const TextSpan(text: 'Relationships bloom\n'),
                const TextSpan(text: 'with '),
                TextSpan(
                  text: 'Bonded.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: roseHero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Central Conic statistics ring
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, ringConstraints) {
                  // Dynamically scale the ring size to avoid vertical overflows
                  double diameter = ringConstraints.maxHeight * 0.98;
                  if (diameter > 275) diameter = 275;
                  if (diameter < 225) diameter = 225;

                  return Container(
                    width: diameter,
                    height: diameter,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        center: Alignment.center,
                        startAngle: 3.5, // Approx 200 degrees in radians
                        colors: [
                          Color(0xFF8B1A4A),
                          Color(0xFF6B1240),
                          Color(0xFFC9954A),
                          Color(0xFF8B1A4A),
                        ],
                        stops: [0.0, 0.25, 0.62, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x408B1A4A),
                          blurRadius: 40,
                        ),
                        BoxShadow(
                          color: Color(0x1AE8829A),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -0.2),
                          radius: 0.75,
                          colors: [
                            const Color(0xFF14060F),
                            bgApp,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large 80% Number (responsive font sizing)
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Georgia', 
                                fontSize: diameter * 0.22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF7C97A),
                                height: 1.0,
                              ),
                              children: [
                                const TextSpan(text: '80'),
                                WidgetSpan(
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: diameter * 0.09,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF7C97A),
                                    ),
                                  ),
                                  alignment: PlaceholderAlignment.top,
                                ),
                              ],
                            ),
                          ),

                          // Heart mini divider
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: diameter * 0.03),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: roseMid.withOpacity(0.55),
                              size: diameter * 0.06,
                            ),
                          ),

                          // Stat description (responsive font sizing and safe margins)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'felt more connected after healthy separation.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Georgia', 
                                fontSize: diameter * 0.05,
                                fontStyle: FontStyle.italic,
                                color: textMid,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),

          const SizedBox(height: 10),

          _buildHeartDivider(),

          // Bottom Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontFamily: 'Georgia', 
                  fontSize: 14.5,
                  fontStyle: FontStyle.italic,
                  color: textMid,
                  height: 1.7,
                ),
                children: [
                  const TextSpan(text: 'Reconnect with greater understanding\nand a '),
                  TextSpan(
                    text: 'stronger bond.',
                    style: TextStyle(
                      color: roseHero,
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

  // Helper widget to build comparison thread list rows
  Widget _buildTransformRow(String beforeText, String afterText, bool isArrowIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: roseHero.withOpacity(0.14),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF640832).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            const Color(0xFF641032).withOpacity(0.38),
            const Color(0xFF1A0816).withOpacity(0.30),
            const Color(0xFFC9954A).withOpacity(0.18),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
      child: Row(
        children: [
          // Before Text
          Expanded(
            child: Text(
              beforeText,
              textAlign: TextAlign.left,
              style: TextStyle(fontFamily: 'Georgia', 
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: roseHero.withOpacity(0.65),
              ),
            ),
          ),

          // Central badge
          Container(
            width: 25,
            height: 25,
            padding: const EdgeInsets.all(1.4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFC2185B), Color(0xFFC9954A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x73C2185B),
                  blurRadius: 9,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgCardBase,
              ),
              alignment: Alignment.center,
              child: isArrowIcon
                  ? Icon(
                      Icons.arrow_forward_rounded,
                      color: roseHero,
                      size: 10,
                    )
                  : Icon(
                      Icons.favorite_rounded,
                      color: roseMid,
                      size: 9,
                    ),
            ),
          ),

          // After Text
          Expanded(
            child: Text(
              afterText,
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Georgia', 
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: goldCream.withOpacity(0.90),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build thin line-heart-line divider
  Widget _buildHeartDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                roseHero.withOpacity(0.35),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.favorite_rounded,
          color: roseMid.withOpacity(0.55),
          size: 12,
        ),
        const SizedBox(width: 10),
        Container(
          width: 44,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                roseHero.withOpacity(0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for dashed connector thread
class DottedLinePainter extends CustomPainter {
  final Color color;
  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashHeight = 3.0;
    const dashSpace = 5.0;
    double startY = 16.0;
    final endY = size.height - 16.0;

    while (startY < endY) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
