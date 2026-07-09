import 'package:flutter/material.dart';
import 'dart:math' as math;

class Onboarding1Content extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding1Content({super.key, this.onNext, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  Color(0xFF14080D),
                  Color(0xFF090204),
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top Progress Bar ──
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                        child: const SizedBox(height: 3), // Maintains the same top padding but removes the indicators
                      ),

                      const Spacer(flex: 2),

                      // ── Graphic (Mathematically exact radiating waves) ──
                      const Center(child: _TwoCirclesGraphic()),

                      const Spacer(flex: 2),

                      // ── Title ──
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
                                  color: Color(0xFFE27E9F),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Body text ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: const Text(
                          'Bonded holds space for two people\nto grow — not by staying close, but\nby choosing to come back.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7B5C66),
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ── Buttons ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SizedBox(
                          height: 140, // Fixed height for consistent CTA placement across screens
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 58,
                                  child: ElevatedButton.icon(
                                  onPressed: onNext ?? () {},
                                  icon: const Icon(
                                    Icons.favorite,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Begin our story',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8A2E55),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: onSkip ?? () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'skip for now',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF3D1B28),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        height: 1,
                                        width: 80,
                                        color: const Color(0xFF261019),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48), // Match bottom padding of onboarding2
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}

class _TwoCirclesGraphic extends StatelessWidget {
  const _TwoCirclesGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: _RadiatingWavesPainter(),
      ),
    );
  }
}

class _RadiatingWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // 1. Outer Background Rings
    final ringPaint = Paint()
      ..color = const Color(0xFF1B0A13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawCircle(Offset(cx, cy), size.height * 0.35, ringPaint);
    canvas.drawCircle(Offset(cx, cy), size.height * 0.48, ringPaint);
    
    // Parameters
    final overlapOffset = size.height * 0.17; // Distance from center
    final leftCenter = Offset(cx - overlapOffset, cy);
    final rightCenter = Offset(cx + overlapOffset, cy);
    
    final outerRadius = size.height * 0.23;
    final innerArcRadius = size.height * 0.11;
    final dotRadius = size.height * 0.04;

    // 2. Main Circles (Outer Waves)
    final fillPaint = Paint()
      ..color = const Color(0xFF280B17).withOpacity(0.65)
      ..style = PaintingStyle.fill;
      
    final strokePaint = Paint()
      ..color = const Color(0xFF4F1A30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(leftCenter, outerRadius, fillPaint);
    canvas.drawCircle(rightCenter, outerRadius, fillPaint);
    
    canvas.drawCircle(leftCenter, outerRadius, strokePaint);
    canvas.drawCircle(rightCenter, outerRadius, strokePaint);

    // 3. Inner Arcs (Radiating Waves)
    // Left arc facing right
    canvas.drawArc(
      Rect.fromCircle(center: leftCenter, radius: innerArcRadius),
      -0.8, // Start angle
      1.6,  // Sweep angle
      false,
      strokePaint,
    );
    
    // Right arc facing left
    canvas.drawArc(
      Rect.fromCircle(center: rightCenter, radius: innerArcRadius),
      math.pi - 0.8,
      1.6,
      false,
      strokePaint,
    );
    
    // 4. Pink Dots
    final dotPaint = Paint()
      ..color = const Color(0xFF974967)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(leftCenter, dotRadius, dotPaint);
    canvas.drawCircle(rightCenter, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
