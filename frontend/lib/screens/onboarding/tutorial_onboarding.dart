import 'package:flutter/material.dart';
import 'dart:async';

class TutorialOnboarding extends StatefulWidget {
  final VoidCallback onFinish;
  final Map<String, dynamic>? config;

  const TutorialOnboarding({
    super.key,
    required this.onFinish,
    this.config,
  });

  @override
  State<TutorialOnboarding> createState() => _TutorialOnboardingState();
}

class _TutorialOnboardingState extends State<TutorialOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<Map<String, dynamic>> _steps;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _steps = [
      {
        'image': 'assets/images/tutorial_1.png',
        'icon': Icons.chat_bubble_outline,
        'title': widget.config?['tutorial_1_title'] ?? 'Daily Reflections',
        'desc': widget.config?['tutorial_1_text'] ??
            'Every day, you and your partner receive one question. Answer it to reveal each other\'s thoughts and spark meaningful conversations.',
      },
      {
        'image': 'assets/images/tutorial_2.png',
        'icon': Icons.mail_outline,
        'title': widget.config?['tutorial_2_title'] ?? 'Letters in a Bottle',
        'desc': widget.config?['tutorial_2_text'] ??
            'Write letters to each other and seal them. Set a future unlock date, creating exciting moments of anticipation.',
      },
      {
        'image': 'assets/images/tutorial_3.png',
        'icon': Icons.eco_outlined,
        'title': widget.config?['tutorial_3_title'] ?? 'Shared Sanctuary',
        'desc': widget.config?['tutorial_3_text'] ??
            'Build and decorate your own virtual space. Plants grow and objects unlock as you maintain your daily connection habits.',
      },
      {
        'image': 'assets/images/tutorial_4.png',
        'icon': Icons.favorite_border,
        'title': widget.config?['tutorial_4_title'] ?? 'Emotional Journey',
        'desc': widget.config?['tutorial_4_text'] ??
            'Track your moods, map separations, and share reassuring nudges that show your partner they are on your mind.',
      },
    ];
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        if (_currentPage < _steps.length - 1) {
          _pageController.animateToPage(
            _currentPage + 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        } else {
          // Loop back to the first page
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090204),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Header & Page Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'How Bonded Works',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_currentPage + 1}/${_steps.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B6774),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _startAutoScroll(); // Reset timer on manual scroll
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glassmorphism Mockup Image Container
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      step['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback if image fails to load
                                        return Center(
                                          child: Icon(
                                            step['icon'],
                                            size: 80,
                                            color: const Color(0xFFE27E9F).withOpacity(0.4),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Soft Vignette overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(step['icon'], color: const Color(0xFFE27E9F), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              step['title'],
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            step['desc'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B6774),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFFE27E9F)
                        : Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
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
                    _currentPage == _steps.length - 1 ? 'Start Connecting' : 'Next Feature',
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
            ),
          ],
        ),
      ),
    );
  }
}
