import 'dart:math' as math;
import 'package:flutter/material.dart';

class InteractionAnimator extends StatefulWidget {
  final String gesture;
  final Color color;
  final VoidCallback onComplete;
  final Offset center;

  const InteractionAnimator({
    super.key,
    required this.gesture,
    required this.color,
    required this.onComplete,
    required this.center,
  });

  @override
  State<InteractionAnimator> createState() => _InteractionAnimatorState();
}

class _InteractionAnimatorState extends State<InteractionAnimator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 1.5 - 2.5s duration
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _InteractionEffectPainter(
                gesture: widget.gesture.toLowerCase(),
                color: widget.color,
                progress: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ).value,
                center: widget.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InteractionEffectPainter extends CustomPainter {
  final String gesture;
  final Color color;
  final double progress;
  final Offset center;

  _InteractionEffectPainter({
    required this.gesture,
    required this.color,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    if (gesture == 'love') {
      _paintLove(canvas);
    } else if (gesture == 'hug') {
      _paintHug(canvas);
    } else if (gesture == 'kiss') {
      _paintKiss(canvas);
    } else if (gesture == 'flower') {
      _paintFlower(canvas);
    } else if (gesture == 'sparkle') {
      _paintSparkle(canvas);
    } else if (gesture == 'sunshine') {
      _paintSunshine(canvas);
    }
  }

  void _paintLove(Canvas canvas) {
    // 3-4 tiny sparkles appear and fade
    final double alpha = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
    final Paint sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    
    _drawStar(canvas, center + const Offset(-30, -40), 6, sparklePaint);
    _drawStar(canvas, center + const Offset(35, -20), 4, sparklePaint);
    _drawStar(canvas, center + const Offset(-20, 30), 5, sparklePaint);
  }

  void _paintHug(Canvas canvas) {
    // Gentle golden ripple expands once
    final double rippleRadius = progress * 60;
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    
    final Paint ripplePaint = Paint()
      ..color = const Color(0xFFECC45C).withValues(alpha: alpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(center, rippleRadius, ripplePaint);

    // Small floating hearts fade upward
    final double yOffset = progress * -50;
    final Paint heartPaint = Paint()
      ..color = const Color(0xFFDD8F9F).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    _drawTinyHeart(canvas, center + Offset(-25, yOffset - 10), 6, heartPaint);
    _drawTinyHeart(canvas, center + Offset(25, yOffset - 5), 8, heartPaint);
  }

  void _paintKiss(Canvas canvas) {
    // Tiny glowing kiss mark flies toward the emoji
    // Sparkle trail
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    final Paint trailPaint = Paint()
      ..color = const Color(0xFFE25B6F).withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      double t = (progress - (i * 0.05)).clamp(0.0, 1.0);
      if (t > 0 && t < 1) {
        Offset trailPos = center + Offset(-40 + (t * 40), 20 - (t * 20));
        canvas.drawCircle(trailPos, 2 + (i * 0.5), trailPaint);
      }
    }
  }

  void _paintFlower(Canvas canvas) {
    // A few petals drift downward naturally
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    final Paint petalPaint = Paint()
      ..color = const Color(0xFFECC8D4).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    double yOffset1 = progress * 40;
    double xOffset1 = math.sin(progress * math.pi * 2) * 15;
    
    double yOffset2 = progress * 50;
    double xOffset2 = math.cos(progress * math.pi * 2) * 20;

    canvas.drawCircle(center + Offset(-15 + xOffset1, 10 + yOffset1), 4, petalPaint);
    canvas.drawCircle(center + Offset(20 + xOffset2, 5 + yOffset2), 3, petalPaint);
  }

  void _paintSparkle(Canvas canvas) {
    // Tiny sparkles orbit once, one shoots upward
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    final Paint sparklePaint = Paint()
      ..color = const Color(0xFFECC45C).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final double angle = progress * math.pi * 2;
    final double radius = 35;
    
    Offset orbit1 = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    Offset orbit2 = center + Offset(math.cos(angle + math.pi) * radius, math.sin(angle + math.pi) * radius);

    _drawStar(canvas, orbit1, 5, sparklePaint);
    _drawStar(canvas, orbit2, 3, sparklePaint);

    Offset shoot = center + Offset(0, -progress * 60);
    _drawStar(canvas, shoot, 6, sparklePaint);
  }

  void _paintSunshine(Canvas canvas) {
    // Soft golden rays expand, tiny floating dust particles rise
    final double alpha = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
    final Paint rayPaint = Paint()
      ..color = const Color(0xFFEAA15F).withValues(alpha: alpha * 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, 80 + (progress * 40), rayPaint);

    final Paint dustPaint = Paint()
      ..color = const Color(0xFFECC45C).withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center + Offset(-40, -10 - (progress * 30)), 2, dustPaint);
    canvas.drawCircle(center + Offset(35, 20 - (progress * 25)), 1.5, dustPaint);
    canvas.drawCircle(center + Offset(-15, 40 - (progress * 40)), 2.5, dustPaint);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final Path path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawTinyHeart(Canvas canvas, Offset c, double r, Paint paint) {
    final Path path = Path()
      ..moveTo(c.dx, c.dy - r * 0.3)
      ..cubicTo(c.dx - r, c.dy - r * 0.9, c.dx - r * 1.3, c.dy + r * 0.2, c.dx, c.dy + r)
      ..moveTo(c.dx, c.dy - r * 0.3)
      ..cubicTo(c.dx + r, c.dy - r * 0.9, c.dx + r * 1.3, c.dy + r * 0.2, c.dx, c.dy + r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InteractionEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
