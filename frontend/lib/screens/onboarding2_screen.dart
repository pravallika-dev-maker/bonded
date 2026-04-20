import 'package:flutter/material.dart';

class Onboarding2Content extends StatelessWidget {
  const Onboarding2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),

        // ── Graphic: Journal Card with Clock ──
        const Center(child: _JournalGraphic()),

        const Spacer(flex: 1),

        // ── Title: "Honest check-ins, not surveillance" ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Honest',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const Text(
                'check-ins,',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'not surveillance',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFAC7827),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Body Text ──
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Your moods, your reflections — private as a journal, gentle as a nudge. We ask because we care.',
            style: TextStyle(
              fontSize: 14.5,
              color: Color(0xFF9E7A85),
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ),

        const Spacer(flex: 5), // Added space for the fixed footer in wrapper
      ],
    );
  }
}

class _JournalGraphic extends StatelessWidget {
  const _JournalGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF200C14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3D2028), width: 1.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _line(60),
                const SizedBox(height: 6),
                _line(80),
                const SizedBox(height: 6),
                _line(40),
              ],
            ),
          ),
          Positioned(
            top: -10,
            right: 15,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3D1A25),
                border: Border.all(color: const Color(0xFF5A2C3A), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.access_time_filled, color: Color(0xFF8B6421), size: 24),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3D2028)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double width) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(color: const Color(0xFF3D2028), borderRadius: BorderRadius.circular(2)),
    );
  }
}
