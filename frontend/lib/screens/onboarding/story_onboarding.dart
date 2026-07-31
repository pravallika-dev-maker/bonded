import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

class StoryOnboarding extends StatefulWidget {
  final VoidCallback onFinish;
  final Map<String, dynamic>? config;

  const StoryOnboarding({
    super.key,
    required this.onFinish,
    this.config,
  });

  @override
  State<StoryOnboarding> createState() => _StoryOnboardingState();
}

class _StoryOnboardingState extends State<StoryOnboarding> {
  final PageController _carouselController = PageController();
  int _currentSlide = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_currentSlide >= _slideImages.length - 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        if (_currentSlide < _slideImages.length - 1) {
          _carouselController.animateToPage(
            _currentSlide + 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        } else {
          timer.cancel();
        }
      }
    });
  }

  final List<String> _slideImages = [
    'assets/onboarding/flow1/first.png',
    'assets/onboarding/flow1/second.png',
    'assets/onboarding/flow1/three.png',
    'assets/onboarding/flow1/four.png',
    'assets/onboarding/flow1/five.png',
  ];

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < _slideImages.length - 1) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  void _goToSlide(int index) {
    _carouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.0,
          colors: [Color(0xFF260814), Color(0xFF090204)],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24), // Top spacing

                      // ── Premium Glassmorphism Card Container ──
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB52B6E).withOpacity(0.08),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: SizedBox(
                                      height: constraints.maxHeight * 0.68,
                                      child: PageView.builder(
                                        controller: _carouselController,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentSlide = index;
                                          });
                                          _startAutoScroll(); // Reset timer on manual swipe
                                        },
                                        itemCount: _slideImages.length,
                                        itemBuilder: (context, index) {
                                          return ClipRect(
                                            clipper: OnboardingImageClipper(),
                                            child: Image.asset(
                                              _slideImages[index],
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: const Color(0xFF1B0711),
                                                  child: Center(
                                                    child: Text(
                                                      'Slide ${index + 1}',
                                                      style: const TextStyle(
                                                        fontFamily: 'Georgia',
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Pagination Dots (Exactly 5 dots) ──
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slideImages.length,
                            (index) => GestureDetector(
                              onTap: () => _goToSlide(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentSlide == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentSlide == index
                                      ? const Color(0xFFE27E9F)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Buttons CTA ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                        child: SizedBox(
                          height: 120,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: _nextSlide,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8A2E55),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    _currentSlide == _slideImages.length - 1
                                        ? 'Begin our story'
                                        : 'Continue',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: widget.onFinish,
                                child: const Text(
                                  'skip for now',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF5E3A4B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Precise Image Clipper ──
// Crops exactly the top 6% (slide count/skip) and bottom 8% (dots/arrows)
class OnboardingImageClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    final topCrop = size.height * 0.06;
    final bottomCrop = size.height * 0.08;
    return Rect.fromLTRB(
      0,
      topCrop,
      size.width,
      size.height - bottomCrop,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}


