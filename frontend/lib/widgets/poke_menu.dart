import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color getGestureColor(String name) {
  switch (name.toLowerCase()) {
    case 'hug':
      return const Color(0xFF9E7E5A);
    case 'kiss':
      return const Color(0xFFE25B6F);
    case 'flower':
      return const Color(0xFFECC8D4);
    case 'sparkle':
      return const Color(0xFFECC45C);
    case 'sunshine':
      return const Color(0xFFEAA15F);
    case 'love':
    default:
      return const Color(0xFFDD8F9F);
  }
}

String getFeedbackText(String gesture, String? partnerName) {
  final name = partnerName ?? 'Emma';
  switch (gesture.toLowerCase()) {
    case 'love':
      return 'Sent Love to $name';
    case 'hug':
      return 'Sent Hugs to $name';
    case 'kiss':
      return 'Sent a Kiss to $name';
    case 'flower':
      return 'Sent a Flower to $name';
    case 'sparkle':
      return 'Sent Sparkles to $name';
    case 'sunshine':
      return 'Sent Sunshine to $name';
    default:
      return 'Sent gesture to $name';
  }
}

class GestureIcon extends StatelessWidget {
  final String gesture;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool filled;

  const GestureIcon({
    super.key,
    required this.gesture,
    required this.color,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GestureIconPainter(
          gesture: gesture,
          color: color,
          strokeWidth: strokeWidth,
          filled: filled,
        ),
      ),
    );
  }
}

class GestureIconPainter extends CustomPainter {
  final String gesture;
  final Color color;
  final double strokeWidth;
  final bool filled;

  GestureIconPainter({
    required this.gesture,
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  // App palette
  static const Color _roseRed    = Color(0xFFE25B6F);
  static const Color _roseGold   = Color(0xFFDD8F9F);
  static const Color _softPink   = Color(0xFFECC8D4);
  static const Color _goldYellow = Color(0xFFECC45C);
  static const Color _apricot    = Color(0xFFEAA15F);
  static const Color _sage       = Color(0xFF8EA893);
  static const Color _cloudWhite = Color(0xFFF4F8F9);
  static const Color _cloudLine  = Color(0xFFD4E2E4);
  static const Color _deepRose   = Color(0xFF8A2E55);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = math.min(size.width, size.height) / 2 * 0.9;
    final Rect bounds = Rect.fromCircle(center: c, radius: r);
    final g = gesture.toLowerCase();

    if (g == 'love') {
      _drawHeart(canvas, c, r, bounds, _roseRed, _deepRose, _softPink, _goldYellow);
    } else if (g == 'hug') {
      _drawHug(canvas, c, r, bounds);
    } else if (g == 'kiss') {
      _drawKiss(canvas, c, r, bounds);
    } else if (g == 'flower') {
      _drawFlower(canvas, c, r, bounds);
    } else if (g == 'sparkle') {
      _drawSparkle(canvas, c, r, bounds);
    } else if (g == 'sunshine') {
      _drawSunshine(canvas, c, r, bounds);
    }
  }

  void _drawHeart(Canvas canvas, Offset c, double r, Rect bounds, Color primary, Color deep, Color shine, Color sparkle) {
    final path = _heartPath(c, r * 0.78);
    // Glow
    canvas.drawPath(path, Paint()
      ..color = primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Fill
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [primary.withValues(alpha: 0.92), deep.withValues(alpha: 0.72)]).createShader(bounds));
    // Sheen
    canvas.drawPath(path, Paint()
      ..color = shine.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round);
    _star(canvas, c + Offset(r * 0.68, -r * 0.68), r * 0.13, sparkle);
    canvas.drawCircle(c + Offset(-r * 0.72, r * 0.60), r * 0.07, Paint()..color = sparkle.withValues(alpha: 0.80)..style = PaintingStyle.fill);
  }

  void _drawHug(Canvas canvas, Offset c, double r, Rect bounds) {
    // Left person (warmer peach/apricot gradient)
    final Offset head1 = c + Offset(-r * 0.18, -r * 0.28);
    final double head1R = r * 0.20;
    
    final body1 = Path()
      ..moveTo(c.dx - r * 0.55, c.dy + r * 0.75)
      ..quadraticBezierTo(c.dx - r * 0.40, c.dy - r * 0.05, c.dx - r * 0.18, c.dy - r * 0.05)
      ..quadraticBezierTo(c.dx + r * 0.05, c.dy - r * 0.05, c.dx + r * 0.10, c.dy + r * 0.75)
      ..close();

    // Right person (soft rose gold/red gradient, slightly smaller and wrapping around)
    final Offset head2 = c + Offset(r * 0.18, -r * 0.24);
    final double head2R = r * 0.18;
    
    final body2 = Path()
      ..moveTo(c.dx - r * 0.10, c.dy + r * 0.75)
      ..quadraticBezierTo(c.dx + r * 0.15, c.dy + r * 0.02, c.dx + r * 0.35, c.dy + r * 0.02)
      ..quadraticBezierTo(c.dx + r * 0.52, c.dy + r * 0.02, c.dx + r * 0.58, c.dy + r * 0.75)
      ..close();

    // Draw Left Person Body
    canvas.drawPath(body1, Paint()
      ..color = _apricot.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill);
    canvas.drawPath(body1, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [_apricot.withValues(alpha: 0.88), _goldYellow.withValues(alpha: 0.60)]).createShader(bounds));
    canvas.drawPath(body1, Paint()
      ..color = _apricot.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85);

    // Draw Left Person Head
    canvas.drawCircle(head1, head1R, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [_apricot.withValues(alpha: 0.90), _goldYellow.withValues(alpha: 0.65)]).createShader(Rect.fromCircle(center: head1, radius: head1R)));
    canvas.drawCircle(head1, head1R, Paint()
      ..color = _apricot.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85);

    // Draw Right Person Body
    canvas.drawPath(body2, Paint()
      ..color = _roseGold.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill);
    canvas.drawPath(body2, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [_roseGold.withValues(alpha: 0.85), _deepRose.withValues(alpha: 0.55)]).createShader(bounds));
    canvas.drawPath(body2, Paint()
      ..color = _roseGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85);

    // Draw Right Person Head
    canvas.drawCircle(head2, head2R, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [_roseGold.withValues(alpha: 0.90), _deepRose.withValues(alpha: 0.60)]).createShader(Rect.fromCircle(center: head2, radius: head2R)));
    canvas.drawCircle(head2, head2R, Paint()
      ..color = _roseGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85);

    // Hugging arms (curved lines wrapping around each other)
    final arm1 = Path()
      ..moveTo(c.dx - r * 0.38, c.dy + r * 0.25)
      ..quadraticBezierTo(c.dx + r * 0.05, c.dy + r * 0.15, c.dx + r * 0.30, c.dy + r * 0.38);
    canvas.drawPath(arm1, Paint()
      ..color = _apricot.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.3
      ..strokeCap = StrokeCap.round);

    final arm2 = Path()
      ..moveTo(c.dx + r * 0.38, c.dy + r * 0.28)
      ..quadraticBezierTo(c.dx - r * 0.05, c.dy + r * 0.18, c.dx - r * 0.32, c.dy + r * 0.42);
    canvas.drawPath(arm2, Paint()
      ..color = _roseGold.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.3
      ..strokeCap = StrokeCap.round);

    // Sparkles of warmth around the embrace
    _star(canvas, c + Offset(-r * 0.62, -r * 0.62), r * 0.12, _goldYellow);
    _star(canvas, c + Offset(r * 0.65, r * 0.50), r * 0.09, _softPink);
  }

  void _drawKiss(Canvas canvas, Offset c, double r, Rect bounds) {
    // 1. Winking Face (head)
    final Offset faceCenter = c + Offset(-r * 0.08, r * 0.08);
    final double faceR = r * 0.65;
    final Rect faceBounds = Rect.fromCircle(center: faceCenter, radius: faceR);

    // Face Glow
    canvas.drawCircle(faceCenter, faceR, Paint()
      ..color = _goldYellow.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Face Fill
    canvas.drawCircle(faceCenter, faceR, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [_goldYellow, _apricot],
        center: const Alignment(-0.3, -0.3),
      ).createShader(faceBounds));
    // Face Outline
    canvas.drawCircle(faceCenter, faceR, Paint()
      ..color = _apricot.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85);

    // 2. Face Features
    // Left Eye (smiling arc)
    final leftEyePath = Path()
      ..moveTo(faceCenter.dx - faceR * 0.45, faceCenter.dy - faceR * 0.15)
      ..quadraticBezierTo(faceCenter.dx - faceR * 0.28, faceCenter.dy - faceR * 0.30, faceCenter.dx - faceR * 0.12, faceCenter.dy - faceR * 0.15);
    canvas.drawPath(leftEyePath, Paint()
      ..color = _deepRose
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2
      ..strokeCap = StrokeCap.round);

    // Right Eye (winking > shape, but smooth and elegant)
    final rightEyePath = Path()
      ..moveTo(faceCenter.dx + faceR * 0.15, faceCenter.dy - faceR * 0.22)
      ..lineTo(faceCenter.dx + faceR * 0.38, faceCenter.dy - faceR * 0.12)
      ..lineTo(faceCenter.dx + faceR * 0.15, faceCenter.dy - faceR * 0.02);
    canvas.drawPath(rightEyePath, Paint()
      ..color = _deepRose
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Rosy Cheeks (soft blush)
    canvas.drawCircle(faceCenter + Offset(-faceR * 0.42, faceR * 0.12), faceR * 0.16, Paint()
      ..color = _roseRed.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill);
    canvas.drawCircle(faceCenter + Offset(faceR * 0.38, faceR * 0.12), faceR * 0.14, Paint()
      ..color = _roseRed.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill);

    // Puckered Mouth (kissing shape)
    final Offset mouthCenter = faceCenter + Offset(0, faceR * 0.22);
    final double mouthR = faceR * 0.12;
    canvas.drawCircle(mouthCenter, mouthR, Paint()
      ..color = _deepRose
      ..style = PaintingStyle.fill);
    canvas.drawCircle(mouthCenter, mouthR, Paint()
      ..color = _softPink.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6);

    // 3. Flying Heart (The Kiss)
    final Offset heartCenter = c + Offset(r * 0.46, -r * 0.38);
    final double heartR = r * 0.38;
    final heartPath = _heartPath(heartCenter, heartR);

    // Heart Glow
    canvas.drawPath(heartPath, Paint()
      ..color = _roseRed.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    // Heart Fill
    canvas.drawPath(heartPath, Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [_roseRed.withValues(alpha: 0.95), _deepRose.withValues(alpha: 0.70)]).createShader(Rect.fromCircle(center: heartCenter, radius: heartR)));
    // Heart Shine
    canvas.drawPath(heartPath, Paint()
      ..color = _softPink.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.75
      ..strokeCap = StrokeCap.round);

    // 4. Dot trail from mouth to heart
    final Offset dot1 = faceCenter + Offset(faceR * 0.35, -faceR * 0.20);
    final Offset dot2 = faceCenter + Offset(faceR * 0.62, -faceR * 0.48);
    canvas.drawCircle(dot1, r * 0.05, Paint()..color = _softPink.withValues(alpha: 0.70)..style = PaintingStyle.fill);
    canvas.drawCircle(dot2, r * 0.03, Paint()..color = _softPink.withValues(alpha: 0.45)..style = PaintingStyle.fill);
  }

  void _drawFlower(Canvas canvas, Offset c, double r, Rect bounds) {
    // Stem
    final stem = Path()
      ..moveTo(c.dx, c.dy + r * 0.26)
      ..quadraticBezierTo(c.dx - r * 0.08, c.dy + r * 0.65, c.dx - r * 0.05, c.dy + r * 0.95);
    canvas.drawPath(stem, Paint()..color = _sage..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.90..strokeCap = StrokeCap.round);
    // Leaf
    final leaf = Path()
      ..moveTo(c.dx - r * 0.06, c.dy + r * 0.60)
      ..quadraticBezierTo(c.dx - r * 0.38, c.dy + r * 0.50, c.dx - r * 0.06, c.dy + r * 0.75);
    canvas.drawPath(leaf, Paint()..color = _sage.withValues(alpha: 0.42)..style = PaintingStyle.fill);
    canvas.drawPath(leaf, Paint()..color = _sage..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.90..strokeCap = StrokeCap.round);
    // Petals
    final double pr = r * 0.33, dist = r * 0.40;
    for (int i = 0; i < 5; i++) {
      final double ang = i * 2 * math.pi / 5 - math.pi / 2;
      final Offset pc = Offset(c.dx + dist * math.cos(ang), c.dy + dist * math.sin(ang));
      final Rect pb = Rect.fromCircle(center: pc, radius: pr);
      canvas.drawCircle(pc, pr, Paint()..color = _softPink.withValues(alpha: 0.16)..style = PaintingStyle.stroke..strokeWidth = strokeWidth + 2.5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      canvas.drawCircle(pc, pr, Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [_softPink.withValues(alpha: 0.82), _roseGold.withValues(alpha: 0.58)]).createShader(pb));
      canvas.drawCircle(pc, pr, Paint()..color = _roseGold.withValues(alpha: 0.38)..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.70);
    }
    // Center
    final Rect cb = Rect.fromCircle(center: c, radius: r * 0.22);
    canvas.drawCircle(c, r * 0.22, Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [_goldYellow, _apricot]).createShader(cb));
    canvas.drawCircle(c, r * 0.22, Paint()..color = _goldYellow.withValues(alpha: 0.58)..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.80);
    _star(canvas, c + Offset(r * 0.66, -r * 0.68), r * 0.12, _goldYellow);
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Rect bounds) {
    final path1 = _starPath(c + Offset(-r * 0.18, -r * 0.18), r * 0.62);
    final path2 = _starPath(c + Offset(r * 0.35, r * 0.35), r * 0.36);
    // Glows
    canvas.drawPath(path1, Paint()..color = _goldYellow.withValues(alpha: 0.22)..style = PaintingStyle.stroke..strokeWidth = strokeWidth + 3.5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path2, Paint()..color = _apricot.withValues(alpha: 0.22)..style = PaintingStyle.stroke..strokeWidth = strokeWidth + 3.5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Fills
    canvas.drawPath(path1, Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [_goldYellow.withValues(alpha: 0.90), _apricot.withValues(alpha: 0.65)]).createShader(bounds));
    canvas.drawPath(path1, Paint()..color = _goldYellow.withValues(alpha: 0.38)..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.75..strokeCap = StrokeCap.round);
    canvas.drawPath(path2, Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [_apricot.withValues(alpha: 0.88), _roseGold.withValues(alpha: 0.62)]).createShader(bounds));
    canvas.drawPath(path2, Paint()..color = _apricot.withValues(alpha: 0.38)..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.75..strokeCap = StrokeCap.round);
    // Dots
    canvas.drawCircle(c + Offset(-r * 0.60, r * 0.50), r * 0.09, Paint()..color = _roseGold..style = PaintingStyle.fill);
    canvas.drawCircle(c + Offset(r * 0.52, -r * 0.52), r * 0.07, Paint()..color = _roseGold..style = PaintingStyle.fill);
  }

  void _drawSunshine(Canvas canvas, Offset c, double r, Rect bounds) {
    final double innerR = r * 0.42;
    // Outer ambient glow
    canvas.drawCircle(c, innerR * 1.6, Paint()..color = _goldYellow.withValues(alpha: 0.14)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    // Rays
    final double startRay = innerR + r * 0.12, endRay = innerR + r * 0.38;
    final Paint rayPaint = Paint()..color = _apricot..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final double ang = i * 2 * math.pi / 8;
      canvas.drawLine(Offset(c.dx + startRay * math.cos(ang), c.dy + startRay * math.sin(ang)), Offset(c.dx + endRay * math.cos(ang), c.dy + endRay * math.sin(ang)), rayPaint);
    }
    // Sun disk
    canvas.drawCircle(c, innerR, Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [_goldYellow, _apricot]).createShader(Rect.fromCircle(center: c, radius: innerR)));
    canvas.drawCircle(c, innerR, Paint()..color = _apricot.withValues(alpha: 0.50)..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
    // Cloud
    final Offset cc = c + Offset(-r * 0.28, r * 0.28);
    final double cs = r * 0.26;
    final cloudPath = Path()
      ..moveTo(cc.dx - cs, cc.dy + cs * 0.3)
      ..quadraticBezierTo(cc.dx - cs * 0.8, cc.dy - cs * 0.5, cc.dx - cs * 0.2, cc.dy - cs * 0.3)
      ..quadraticBezierTo(cc.dx + cs * 0.3, cc.dy - cs * 0.8, cc.dx + cs * 0.8, cc.dy - cs * 0.2)
      ..quadraticBezierTo(cc.dx + cs * 1.3, cc.dy + cs * 0.3, cc.dx, cc.dy + cs * 0.3)
      ..close();
    canvas.drawPath(cloudPath, Paint()..color = _cloudWhite.withValues(alpha: 0.84)..style = PaintingStyle.fill);
    canvas.drawPath(cloudPath, Paint()..color = _cloudLine..style = PaintingStyle.stroke..strokeWidth = strokeWidth * 0.85..strokeCap = StrokeCap.round);
  }

  Path _heartPath(Offset c, double r) {
    return Path()
      ..moveTo(c.dx, c.dy - r * 0.3)
      ..cubicTo(c.dx - r, c.dy - r * 0.9, c.dx - r * 1.3, c.dy + r * 0.2, c.dx, c.dy + r)
      ..moveTo(c.dx, c.dy - r * 0.3)
      ..cubicTo(c.dx + r, c.dy - r * 0.9, c.dx + r * 1.3, c.dy + r * 0.2, c.dx, c.dy + r);
  }

  Path _starPath(Offset c, double r) {
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
  }

  void _star(Canvas canvas, Offset pos, double r, Color col) {
    canvas.drawPath(_starPath(pos, r), Paint()..color = col.withValues(alpha: 0.82)..style = PaintingStyle.fill);
  }


  @override
  bool shouldRepaint(covariant GestureIconPainter oldDelegate) {
    return oldDelegate.gesture != gesture ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.filled != filled;
  }
}

class PokeMenu extends StatefulWidget {
  final Future<void> Function(String gesture) onSendPoke;
  final String? partnerName;
  final bool startExpanded;

  static DateTime? lastSentTime;
  static const Duration cooldownDuration = Duration(seconds: 30);

  static int get cooldownRemaining {
    if (lastSentTime == null) return 0;
    final diff = DateTime.now().difference(lastSentTime!);
    final remaining = cooldownDuration.inSeconds - diff.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  const PokeMenu({
    super.key,
    required this.onSendPoke,
    this.partnerName,
    this.startExpanded = false,
  });

  @override
  State<PokeMenu> createState() => _PokeMenuState();
}

class _PokeMenuState extends State<PokeMenu> {
  bool _isSending = false;
  String? _sentGestureFeedback;
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;

  int get _cooldownRemaining => PokeMenu.cooldownRemaining;

  void _startCooldownTimer(int seconds) {
    _cooldownTimer?.cancel();
    setState(() { _remainingSeconds = seconds; });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final remaining = _cooldownRemaining;
      setState(() { _remainingSeconds = remaining; });
      if (remaining <= 0) timer.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    final remaining = _cooldownRemaining;
    if (remaining > 0) _startCooldownTimer(remaining);

    if (widget.startExpanded && remaining <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverlayDialog();
      });
    }
  }

  @override
  void didUpdateWidget(covariant PokeMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startExpanded && !oldWidget.startExpanded && _remainingSeconds <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverlayDialog();
      });
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _showOverlayDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.65), // Soft dark overlay
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return _PokeOverlayDialog(
          partnerName: widget.partnerName,
          onSend: (gesture) async {
            await _handleSendGesture(gesture);
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final double scale = 0.82 + 0.18 * CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value;
        final double opacity = CurvedAnimation(parent: anim1, curve: Curves.easeIn).value;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleSendGesture(String name) async {
    if (_isSending) return;
    setState(() { _isSending = true; });
    try {
      await widget.onSendPoke(name);
      PokeMenu.lastSentTime = DateTime.now();
      setState(() { _isSending = false; _sentGestureFeedback = name; });
      _startCooldownTimer(PokeMenu.cooldownDuration.inSeconds);
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() { _sentGestureFeedback = null; });
      });
    } catch (e) {
      setState(() { _isSending = false; });
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: Network error: Exception: ', '').replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg.contains('do not have a partner') ? 'Connect a partner first to send gestures 💕' : 'Could not send — please try again',
              style: const TextStyle(fontFamily: 'Georgia', color: Color(0xFFECC8D4)),
            ),
            backgroundColor: const Color(0xFF1C0A11),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sentGestureFeedback != null) {
      final Color feedbackColor = getGestureColor(_sentGestureFeedback!);
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - v)),
              child: child,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF8A2E55).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDD8F9F).withValues(alpha: 0.22), width: 1),
              boxShadow: [BoxShadow(color: const Color(0xFFDD8F9F).withValues(alpha: 0.10), blurRadius: 16, spreadRadius: 1)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureIcon(gesture: _sentGestureFeedback!, color: feedbackColor, size: 18, strokeWidth: 1.6, filled: true),
                const SizedBox(width: 10),
                Text(
                  getFeedbackText(_sentGestureFeedback!, widget.partnerName),
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFFECC8D4)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool isOnCooldown = _remainingSeconds > 0;

    return Center(
      child: GestureDetector(
        onTap: isOnCooldown ? null : _showOverlayDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOnCooldown
                  ? [
                      const Color(0xFFDD8F9F).withValues(alpha: 0.04),
                      const Color(0xFF8A2E55).withValues(alpha: 0.02),
                    ]
                  : [
                      const Color(0xFFDD8F9F).withValues(alpha: 0.10),
                      const Color(0xFF8A2E55).withValues(alpha: 0.04),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOnCooldown
                  ? const Color(0xFFDD8F9F).withValues(alpha: 0.12)
                  : const Color(0xFFDD8F9F).withValues(alpha: 0.32),
              width: 1.2,
            ),
            boxShadow: [
              if (!isOnCooldown)
                BoxShadow(
                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: isOnCooldown
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: const Color(0xFFECC8D4).withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Wait ${_remainingSeconds}s',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 12.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFECC8D4).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureIcon(gesture: 'Love', color: const Color(0xFFDD8F9F),
                      size: 14, strokeWidth: 1.6, filled: true),
                    const SizedBox(width: 8),
                    const Text('Send Love',
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
                        letterSpacing: 0.4, fontWeight: FontWeight.w600,
                        color: Color(0xFFECC8D4))),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; // 0.0 to 1.0

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      if (p.life <= 0) continue;
      paint.color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      // Draw inner glowing core
      canvas.drawCircle(p.position, p.size * p.life, paint);
      
      // Draw outer glowing halo
      final Paint glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = p.color.withValues(alpha: (p.life * 0.35).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);
      canvas.drawCircle(p.position, p.size * 2 * p.life, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PokeOverlayDialog extends StatefulWidget {
  final String? partnerName;
  final Function(String gesture) onSend;

  const _PokeOverlayDialog({
    required this.partnerName,
    required this.onSend,
  });

  @override
  State<_PokeOverlayDialog> createState() => _PokeOverlayDialogState();
}

class _PokeOverlayDialogState extends State<_PokeOverlayDialog> with SingleTickerProviderStateMixin {
  List<_Particle> _particles = [];
  late AnimationController _particleController;
  bool _isSelecting = false;
  String? _selectedGesture;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _particleController.addListener(() {
      setState(() {
        for (final p in _particles) {
          p.position += p.velocity;
          p.velocity *= 0.93; // simulated friction
          p.velocity += const Offset(0, 0.16); // light gravity pull
          p.life = 1.0 - _particleController.value;
        }
      });
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _spawnParticles(Offset center, Color color) {
    final rand = math.Random();
    _particles = List.generate(28, (i) {
      final double angle = rand.nextDouble() * 2 * math.pi;
      final double speed = 3.0 + rand.nextDouble() * 6.0;
      return _Particle(
        position: center,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: color,
        size: 3.5 + rand.nextDouble() * 4.5,
        life: 1.0,
      );
    });
    _particleController.forward(from: 0.0);
  }

  Offset _getGridCenter(int index) {
    final int col = index % 3;
    final int row = index ~/ 3;
    // Estimated positions relative to card content
    final double x = 24 + col * 85 + 42.5; // col 0: 66.5, col 1: 151.5, col 2: 236.5
    final double y = 100 + row * 92 + 35; // row 0: 135, row 1: 227
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gestures = [
      {'name': 'Love'},
      {'name': 'Hug'},
      {'name': 'Kiss'},
      {'name': 'Flower'},
      {'name': 'Sparkle'},
      {'name': 'Sunshine'},
    ];

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDD8F9F).withValues(alpha: 0.15),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // ── Glowing Background Spots ──
                Positioned(
                  top: -30,
                  left: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  right: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8A2E55).withValues(alpha: 0.14),
                    ),
                  ),
                ),
                // Frosted Glass Layer
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF13080C).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFDD8F9F).withValues(alpha: 0.28),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [Color(0xFFECC8D4), Color(0xFFDD8F9F)],
                            ).createShader(b),
                            child: const Text(
                              'Send some love ✦',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.10),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Send a real-time whisper to ${widget.partnerName ?? "Partner"}',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFECC8D4).withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Grid of gestures
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: gestures.length,
                        itemBuilder: (context, index) {
                          final String name = gestures[index]['name']!;
                          final Color color = getGestureColor(name);
                          final bool isSelected = _selectedGesture == name;
                          
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isSelecting && !isSelected ? 0.3 : 1.0,
                            child: _GestureButton(
                              name: name,
                              color: color,
                              onTap: _isSelecting
                                  ? () {}
                                  : () {
                                      setState(() {
                                        _isSelecting = true;
                                        _selectedGesture = name;
                                      });
                                      final center = _getGridCenter(index);
                                      _spawnParticles(center, color);
                                      
                                      // Play light haptic feedback
                                      HapticFeedback.mediumImpact();
                                      
                                      // Wait for particle explosion to finish before closing
                                      Timer(const Duration(milliseconds: 550), () {
                                        Navigator.pop(context);
                                        widget.onSend(name);
                                      });
                                    },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDD8F9F).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDD8F9F).withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 14,
                              color: const Color(0xFFDD8F9F).withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lights up their screen instantly to show they\'re on your mind.',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 10.5,
                                  height: 1.35,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFECC8D4).withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Particle paint layer overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ParticlePainter(_particles),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GestureButton extends StatefulWidget {
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _GestureButton({
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  State<_GestureButton> createState() => _GestureButtonState();
}

class _GestureButtonState extends State<_GestureButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTap: () { setState(() => _isPressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    widget.color.withValues(alpha: _isPressed ? 0.22 : 0.13),
                    widget.color.withValues(alpha: 0.03),
                  ]),
                  border: Border.all(
                    color: widget.color.withValues(alpha: _isPressed ? 0.55 : 0.28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _isPressed ? 0.25 : 0.12),
                      blurRadius: _isPressed ? 10 : 6,
                      spreadRadius: _isPressed ? 2 : 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: GestureIcon(
                  gesture: widget.name,
                  color: widget.color,
                  size: 26,
                  strokeWidth: 1.6,
                  filled: true,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: widget.color.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
