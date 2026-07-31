import 'package:flutter/material.dart';
import 'dart:async';

class StatsOnboarding extends StatefulWidget {
  final VoidCallback onFinish;
  final Map<String, dynamic>? config;

  const StatsOnboarding({
    super.key,
    required this.onFinish,
    this.config,
  });

  @override
  State<StatsOnboarding> createState() => _StatsOnboardingState();
}

class _StatsOnboardingState extends State<StatsOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  late final List<Map<String, dynamic>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = [
      {
        'value': widget.config?['stats_1_value'] ?? 87,
        'suffix': '%',
        'title': widget.config?['stats_1_title'] ?? 'Deeper Understanding',
        'subtitle': widget.config?['stats_1_text'] ??
            'of active partners report feeling a significantly stronger emotional connection by dedicating just 5 minutes a day to answering daily reflections.',
      },
      {
        'value': widget.config?['stats_2_value'] ?? 250,
        'suffix': 'k+',
        'title': widget.config?['stats_2_title'] ?? 'Overcoming Separation',
        'subtitle': widget.config?['stats_2_text'] ??
            'letters have been written and sealed, creating moments of joy and shared memories that partners unlock together across time zones.',
      },
      {
        'value': widget.config?['stats_3_value'] ?? 94,
        'suffix': '%',
        'title': widget.config?['stats_3_title'] ?? 'Sanctuary Growth',
        'subtitle': widget.config?['stats_3_text'] ??
            'of couples experience a reduction in distance-induced anxiety when cultivating their shared virtual environments together.',
      },
    ];
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_currentPage >= _stats.length - 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        if (_currentPage < _stats.length - 1) {
          _pageController.animateToPage(
            _currentPage + 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
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
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _stats.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
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
          colors: [Color(0xFF1E0A1B), Color(0xFF090204)],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _stats.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFB52B6E)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
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
                itemCount: _stats.length,
                itemBuilder: (context, index) {
                  final stat = _stats[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Ticking Number Counter Card
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                key: ValueKey(index),
                                tween: Tween<double>(begin: 0, end: stat['value'].toDouble()),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeOutQuart,
                                builder: (context, val, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        val.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -2,
                                        ),
                                      ),
                                      Text(
                                        stat['suffix'],
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE27E9F),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                stat['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Explanation subtitle
                        Text(
                          stat['subtitle'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B6774),
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation CTA
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
                        _currentPage == _stats.length - 1 ? 'Enter Bonded' : 'Next Insight',
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
                  if (_currentPage < _stats.length - 1)
                    GestureDetector(
                      onTap: widget.onFinish,
                      child: const Text(
                        'skip details',
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
