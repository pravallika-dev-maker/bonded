import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Scenario 3 — Separation journey completed. Peaceful, reflective sanctuary.
class PostJourneySanctuaryCard extends StatefulWidget {
  final String partnerName;
  final VoidCallback? onBeginNewJourney;
  final VoidCallback? onSharedMemories;

  const PostJourneySanctuaryCard({
    super.key,
    required this.partnerName,
    this.onBeginNewJourney,
    this.onSharedMemories,
  });

  @override
  State<PostJourneySanctuaryCard> createState() => _PostJourneySanctuaryCardState();
}

class _PostJourneySanctuaryCardState extends State<PostJourneySanctuaryCard>
    with TickerProviderStateMixin {
  // Slow breathe for glow and text shimmer
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;

  // Sparkle drift
  late AnimationController _driftCtrl;

  // Rotating glow ring
  late AnimationController _ringCtrl;

  // Heart completion pulse
  late AnimationController _heartCtrl;
  late Animation<double> _heartPulse;

  // Entrance
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _breathe = CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOutSine);

    _driftCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 18),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 12),
    )..repeat();

    _heartCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _heartPulse = CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOutSine);

    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _driftCtrl.dispose();
    _ringCtrl.dispose();
    _heartCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathe, _driftCtrl, _ringCtrl, _heartPulse, _entranceCtrl]),
      builder: (context, _) {
        final breathe = _breathe.value;
        final drift = _driftCtrl.value;
        final ring = _ringCtrl.value;
        final pulse = _heartPulse.value;

        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A0E2E).withValues(alpha: 0.15 + breathe * 0.10),
                    blurRadius: 60,
                    spreadRadius: -8,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.06 + pulse * 0.06),
                    blurRadius: 80,
                    spreadRadius: 4,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // ── Base gradient — deeper, more peaceful ──
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A0A11),
                            Color(0xFF120810),
                            Color(0xFF080408),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),

                    // ── Top aurora — warm rose gold ──
                    Positioned(
                      top: -80 + breathe * 16,
                      left: -50,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFF6B2040).withValues(alpha: 0.15 + breathe * 0.07),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Bottom-right soft gold aurora ──
                    Positioned(
                      bottom: -80,
                      right: -40,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFFCCA060).withValues(alpha: 0.07 + pulse * 0.05),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Falling sparkles ──
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _FallingSparklesPainter(drift: drift, breathe: breathe, pulse: pulse),
                      ),
                    ),

                    // ── Glass border ──
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFFDD8F9F).withValues(alpha: 0.10 + breathe * 0.05),
                              width: 1.2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.35],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Main content ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Badge ──
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D1627).withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.16 + breathe * 0.06),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.nights_stay_rounded,
                                  size: 9,
                                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'POST-JOURNEY SANCTUARY',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Color(0xFFDD8F9F),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ── Completed heart with glowing ring ──
                          _CompletedHeartRing(breathe: breathe, pulse: pulse, ring: ring),

                          const SizedBox(height: 26),

                          // ── Heading ──
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                const Color(0xFFF5E8ED),
                                Color.lerp(const Color(0xFFDD8F9F), const Color(0xFFCCA060), breathe)!,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Congratulations!',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "You've successfully completed this space. The sanctuary is open whenever you need it.",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.10),
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Partner attribution ──
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.55 + pulse * 0.25),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'A space shared with ${widget.partnerName}',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.65 + pulse * 0.15),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ── CTA buttons ──
                          _SanctuaryButton(
                            label: 'Begin a New Journey',
                            isPrimary: true,
                            breathe: breathe,
                            onTap: widget.onBeginNewJourney ?? () {},
                          ),

                          if (widget.onSharedMemories != null) ...[
                            const SizedBox(height: 12),
                            _SanctuaryButton(
                              label: 'Shared Memories',
                              isPrimary: false,
                              breathe: breathe,
                              onTap: widget.onSharedMemories!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Completed heart with slow rotating glow ring ─────────────────────────────
class _CompletedHeartRing extends StatelessWidget {
  final double breathe;
  final double pulse;
  final double ring;

  const _CompletedHeartRing({required this.breathe, required this.pulse, required this.ring});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating dashed ring
            Transform.rotate(
              angle: ring * math.pi * 2,
              child: CustomPaint(
                size: const Size(88, 88),
                painter: _RotatingRingPainter(breathe: breathe, pulse: pulse),
              ),
            ),

            // Static outer glow
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A1C4A).withValues(alpha: 0.20 + breathe * 0.15),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),

            // Glass orb
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6B2040).withValues(alpha: 0.12 + breathe * 0.06),
                    border: Border.all(
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.22 + breathe * 0.10),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: 1.0 + pulse * 0.08,
                    child: Icon(
                      Icons.favorite,
                      size: 28,
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.85 + pulse * 0.15),
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

class _RotatingRingPainter extends CustomPainter {
  final double breathe;
  final double pulse;

  _RotatingRingPainter({required this.breathe, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Draw arc segments to simulate dashes
    const segmentAngle = math.pi / 8;
    const gapAngle = math.pi / 24;
    double startAngle = 0;

    while (startAngle < math.pi * 2) {
      final alpha = (0.20 + breathe * 0.18 + pulse * 0.10).clamp(0.0, 1.0);
      paint.color = const Color(0xFFDD8F9F).withValues(alpha: alpha);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
      startAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _RotatingRingPainter old) =>
      old.breathe != breathe || old.pulse != pulse;
}

// ── Falling sparkles painter ──────────────────────────────────────────────────
class _FallingSparklesPainter extends CustomPainter {
  final double drift;
  final double breathe;
  final double pulse;

  _FallingSparklesPainter({required this.drift, required this.breathe, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    for (int i = 0; i < 22; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.12 + 0.04;
      final radius = rng.nextDouble() * 1.8 + 0.5;
      final isGold = i % 5 == 0;
      final isRose = i % 3 == 0 && !isGold;

      // Falling downward (positive drift direction)
      double y = (baseY + drift * size.height * speed) % size.height;
      final x = baseX + math.sin(drift * math.pi * 2 + i * 1.2) * 6;

      final fade = math.sin((y / size.height) * math.pi).clamp(0.0, 1.0);
      double alpha;
      Color color;

      if (isGold) {
        alpha = fade * 0.20 * (0.6 + breathe * 0.4);
        color = Color.fromRGBO(204, 160, 96, alpha.clamp(0.0, 1.0));
      } else if (isRose) {
        alpha = fade * 0.18 * (0.6 + pulse * 0.4);
        color = Color.fromRGBO(221, 143, 159, alpha.clamp(0.0, 1.0));
      } else {
        alpha = fade * 0.10 * (0.6 + breathe * 0.4);
        color = Color.fromRGBO(212, 196, 202, alpha.clamp(0.0, 1.0));
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      // Alternate between circles and tiny crosses for variety
      if (i % 7 == 0) {
        // Tiny sparkle cross
        final crossPaint = Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(x.clamp(0.0, size.width) - radius, y),
          Offset(x.clamp(0.0, size.width) + radius, y),
          crossPaint,
        );
        canvas.drawLine(
          Offset(x.clamp(0.0, size.width), y - radius),
          Offset(x.clamp(0.0, size.width), y + radius),
          crossPaint,
        );
      } else {
        canvas.drawCircle(Offset(x.clamp(0.0, size.width), y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FallingSparklesPainter old) =>
      old.drift != drift || old.breathe != breathe || old.pulse != pulse;
}

// ── Sanctuary button ──────────────────────────────────────────────────────────
class _SanctuaryButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final double breathe;
  final VoidCallback onTap;

  const _SanctuaryButton({
    required this.label,
    required this.isPrimary,
    required this.breathe,
    required this.onTap,
  });

  @override
  State<_SanctuaryButton> createState() => _SanctuaryButtonState();
}

class _SanctuaryButtonState extends State<_SanctuaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _tap, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tap.forward(),
      onTapUp: (_) { _tap.reverse(); widget.onTap(); },
      onTapCancel: () => _tap.reverse(),
      child: AnimatedBuilder(
        animation: _tap,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      const Color(0xFF8A1C4A).withValues(alpha: 0.70 + widget.breathe * 0.15),
                      const Color(0xFF5A0E2E).withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFFDD8F9F).withValues(alpha: 0.28 + widget.breathe * 0.10)
                  : const Color(0xFFDD8F9F).withValues(alpha: 0.12 + widget.breathe * 0.05),
              width: 1,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF8A1C4A).withValues(alpha: 0.30 + widget.breathe * 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: widget.isPrimary ? Colors.white : const Color(0xFFD4B8C2),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
