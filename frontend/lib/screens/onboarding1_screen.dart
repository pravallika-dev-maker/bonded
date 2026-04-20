import 'package:flutter/material.dart';

class Onboarding1Content extends StatelessWidget {
  const Onboarding1Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),

        // ── Two overlapping circles graphic ──
        const Center(child: _TwoCirclesWidget()),

        const Spacer(flex: 1),

        // ── Title: "Absence makes the heart remember" ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Absence makes\nthe heart\n',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                TextSpan(
                  text: 'remember',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFD94480),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Body text (justified quote representation) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD94480).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Bonded holds space for two people to grow — not by staying close, but by choosing to come back.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF9E7A85),
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Small heart icon ──
        const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Icon(
            Icons.favorite_rounded,
            color: Color(0xFF7A1E40),
            size: 18,
          ),
        ),

        const Spacer(flex: 4), // Added space for the fixed footer in wrapper
      ],
    );
  }
}

class _TwoCirclesWidget extends StatelessWidget {
  const _TwoCirclesWidget();

  @override
  Widget build(BuildContext context) {
    const double circleSize = 100.0;
    const double overlap = 28.0;
    const double totalWidth = circleSize * 2 - overlap;

    return SizedBox(
      width: totalWidth,
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0, child: _Circle(size: circleSize)),
          Positioned(right: 0, child: _Circle(size: circleSize)),
          Positioned(left: circleSize / 2 - 5, top: circleSize / 2 - 5, child: const _PinkDot()),
          Positioned(right: circleSize / 2 - 5, top: circleSize / 2 - 5, child: const _PinkDot()),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  const _Circle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E0810),
        border: Border.all(color: const Color(0xFF6B1A38), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB52B6E).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _PinkDot extends StatelessWidget {
  const _PinkDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD94480),
        boxShadow: [
          BoxShadow(color: Color(0xFFD94480), blurRadius: 8, spreadRadius: 1),
        ],
      ),
    );
  }
}
