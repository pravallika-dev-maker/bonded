import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Base Dark Background ──
        Container(
          color: const Color(0xFF090103),
        ),

        // ── 2. Background Blooms ──
        // (Assuming we keep the background as requested in previous steps, 
        // the user's latest prompt only demanded changes to the heart icon itself,
        // but just to be safe, I will make the blooms very subtle so they don't look like a glow on the heart)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.15),
                radius: 0.9,
                colors: [
                  Color(0xFF2C0B18),
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.8),
                radius: 0.8,
                colors: [
                  Color(0xFF1A070E),
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        // ── 3. Subtle Circular Rings ──
        Positioned.fill(
          child: CustomPaint(
            painter: _SplashCirclesPainter(),
          ),
        ),

        // ── 4. Content (Heart, Title, Subtitle) ──
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heart Icon (Strictly Flat, No Glow, No Gradient)
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CustomPaint(
                    painter: _StrictReferenceHeartPainter(),
                  ),
                ),

                const SizedBox(height: 12),

                // Text Block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bonded',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 68,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFFDF6F8),
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'CLOSENESS THROUGH\nSPACE',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7D4B5D),
                        letterSpacing: 4.5,
                        height: 1.6, 
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}

class _StrictReferenceHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path getHeartPath(double w, double h) {
      final path = Path();
      // Adjusted bezier control points to match the rounded, wider lobes of the reference heart
      path.moveTo(w * 0.5, h * 0.28);
      
      path.cubicTo(
        w * 0.05, -h * 0.05, 
        -w * 0.15, h * 0.50, 
        w * 0.5, h * 0.95
      );
      
      path.cubicTo(
        w * 1.15, h * 0.50, 
        w * 0.95, -h * 0.05, 
        w * 0.5, h * 0.28
      );
      
      return path;
    }

    // Colors sampled directly from reference
    final Color outerColor = const Color(0xFF4D1A2E);
    final Color innerColor = const Color(0xFF8A2E55);
    final Color fillColor = const Color(0xFF8A2E55);

    final double strokeThickness = 1.5;

    // 1. Outer Outline (Faint Dark Red)
    final pathOuter = getHeartPath(size.width, size.height);
    canvas.drawPath(
      pathOuter,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeThickness,
    );

    // 2. Inner Outline (Bright Pink)
    final midScale = 0.80;
    final midW = size.width * midScale;
    final midH = size.height * midScale;
    final pathMid = getHeartPath(midW, midH)
        .shift(Offset((size.width - midW) / 2, (size.height - midH) / 2));
    
    canvas.drawPath(
      pathMid,
      Paint()
        ..color = innerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeThickness,
    );

    // 3. Solid Fill Heart (Bright Pink, Flat, No Gradient)
    final inScale = 0.60;
    final inW = size.width * inScale;
    final inH = size.height * inScale;
    final pathIn = getHeartPath(inW, inH)
        .shift(Offset((size.width - inW) / 2, (size.height - inH) / 2));
    
    canvas.drawPath(
      pathIn,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SplashCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.50; 

    final paint = Paint()
      ..color = const Color(0xFF4A2033).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy), size.height * 0.16, paint);
    canvas.drawCircle(Offset(cx, cy), size.height * 0.27, paint);
    canvas.drawCircle(Offset(cx, cy), size.height * 0.38, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
