import 'package:flutter/material.dart';
import 'dart:async';

class EmotionalOnboarding extends StatefulWidget {
  final VoidCallback onFinish;
  final Map<String, dynamic>? config;

  const EmotionalOnboarding({
    super.key,
    required this.onFinish,
    this.config,
  });

  @override
  State<EmotionalOnboarding> createState() => _EmotionalOnboardingState();
}

class _EmotionalOnboardingState extends State<EmotionalOnboarding> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Breathing animation controller
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  String _breathingText = "Inhale slowly...";

  late final List<Map<String, String>> _pages;

  @override
  void initState() {
    super.initState();
    
    _pages = [
      {
        'title': widget.config?['emotional_1_title'] ?? 'Pause and breathe',
        'text': widget.config?['emotional_1_text'] ??
            'Before you enter this space, take a moment to be present. Distance is a physical fact, but closeness is an emotional choice.',
      },
      {
        'title': widget.config?['emotional_2_title'] ?? 'A quiet canvas',
        'text': widget.config?['emotional_2_text'] ??
            'In the busyness of life, it\'s easy to feel drifting. Bonded is a gentle canvas where you write what remains unexpressed.',
      },
      {
        'title': widget.config?['emotional_3_title'] ?? 'Step closer today',
        'text': widget.config?['emotional_3_text'] ??
            'No rushing, no pressure. Just a quiet commitment to return to each other, one day, one reflection at a time.',
      },
    ];

    // Setup breathing animation (4 seconds inhale, 4 seconds exhale)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _breathingText = "Exhale gently...";
          });
          _breathingController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _breathingText = "Inhale slowly...";
          });
          _breathingController.forward();
        }
      });

    _breathingController.forward();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_currentPage >= _pages.length - 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        if (_currentPage < _pages.length - 1) {
          _pageController.animateToPage(
            _currentPage + 1,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutQuart,
          );
        } else {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _breathingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutQuart,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.0,
          colors: [Color(0xFF260814), Color(0xFF0E0608)],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top page indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 3,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFE27E9F)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _startAutoScroll(); // Reset timer on manual swipe
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // If page 0, show breathing coach
                        if (index == 0) ...[
                          Center(
                            child: AnimatedBuilder(
                              animation: _breathingAnimation,
                              builder: (context, child) {
                                return Column(
                                  children: [
                                    Container(
                                      width: 140 * _breathingAnimation.value,
                                      height: 140 * _breathingAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF911746).withOpacity(0.08),
                                        border: Border.all(
                                          color: const Color(0xFFE27E9F).withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB52B6E).withOpacity(0.15),
                                            blurRadius: 30 * _breathingAnimation.value,
                                            spreadRadius: 5,
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF911746).withOpacity(0.35),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 48),
                                    Text(
                                      _breathingText,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFE27E9F),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ] else if (index == 1) ...[
                          // Minimalist poetic graphic
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF4F1A30),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [Color(0xFFE27E9F), Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Elegant final star/heart spark
                          Center(
                            child: Icon(
                              Icons.favorite,
                              size: 80,
                              color: const Color(0xFF8A2E55).withOpacity(0.75),
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            page['title']!,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Body text
                        Text(
                          page['text']!,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF8B6774),
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom CTA buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2E55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Step Inside' : 'Breathe & Continue',
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
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: widget.onFinish,
                      child: const Text(
                        'skip reflection',
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
          ],
        ),
      ),
    );
  }
}
