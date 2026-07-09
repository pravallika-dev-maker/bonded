import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'premium_sheen.dart';

class LivingJourneyCard extends StatefulWidget {
  final int currentDay;
  final int totalDays;
  final String moodPhrase;
  final String statusLine;
  final String? partnerName;
  final bool isEmpty;
  final bool isCompleted;
  final bool isMissedDayFlow;
  final VoidCallback? onClose;

  const LivingJourneyCard({
    super.key,
    required this.currentDay,
    this.totalDays = 21,
    required this.moodPhrase,
    required this.statusLine,
    this.partnerName,
    this.isEmpty = false,
    this.isCompleted = false,
    this.isMissedDayFlow = false,
    this.onClose,
  });

  @override
  State<LivingJourneyCard> createState() => _LivingJourneyCardState();
}

class _LivingJourneyCardState extends State<LivingJourneyCard>
    with TickerProviderStateMixin {
  // Slow breathing — drives glow, aurora, and orb pulse
  late AnimationController _breatheController;
  late Animation<double> _breathe;

  // Continuous drift — drives particle float and shimmer shift
  late AnimationController _driftController;

  // Tap spring
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _breathe = CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOutSine,
    );

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _tapScale = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _driftController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) => _tapController.reverse(),
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathe, _driftController, _tapController]),
        builder: (context, _) {
          final breathe = _breathe.value; // 0..1
          final drift = _driftController.value; // 0..1

          return Transform.scale(
            scale: _tapScale.value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  // Deep rose glow — breathes
                  BoxShadow(
                    color: const Color(0xFF8A2E55)
                        .withValues(alpha: 0.12 + breathe * 0.12),
                    blurRadius: 48,
                    spreadRadius: -8,
                    offset: const Offset(0, 16),
                  ),
                  // Wide gold halo
                  BoxShadow(
                    color: const Color(0xFF9E7E5A)
                        .withValues(alpha: 0.06 + breathe * 0.04),
                    blurRadius: 80,
                    spreadRadius: 4,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  children: [
                    // ── BASE GRADIENT ──
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1C0A11),
                            Color(0xFF110308),
                            Color(0xFF0D0206),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),

                    // ── TOP-LEFT ROSE AURORA ──
                    Positioned(
                      top: -60 + breathe * 18,
                      left: -40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF8A2E55)
                                  .withValues(alpha: 0.10 + breathe * 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── BOTTOM-RIGHT GOLD AURORA ──
                    Positioned(
                      bottom: -80 - breathe * 12,
                      right: -60,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF9E7E5A)
                                  .withValues(alpha: 0.07 + breathe * 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── GOLDEN DUST PARTICLES ──
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DustPainter(
                          drift: drift,
                          breathe: breathe,
                        ),
                      ),
                    ),

                    // ── MAIN CONTENT ──
                    PremiumSheen(
                      animationDuration: const Duration(milliseconds: 2000),
                      pauseDuration: const Duration(seconds: 9),
                      sheenOpacity: 0.25,
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOP ROW — label + floating heart
                          if (!widget.isEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Label
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A2E55)
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8A2E55)
                                          .withValues(alpha: 0.20),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.lerp(
                                            const Color(0xFF8A2E55),
                                            const Color(0xFFDD8F9F),
                                            breathe,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFDD8F9F)
                                                  .withValues(alpha: 0.6 + breathe * 0.4),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.isCompleted ? 'COMPLETED · SEPARATION' : 'ACTIVE · SEPARATION',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.6,
                                          color: Color(0xFF9E7E5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Floating heart orb
                                _FloatingHeartOrb(
                                  breathe: breathe,
                                  drift: drift,
                                  progress: (widget.totalDays > 0 ? widget.currentDay / widget.totalDays : 0.0).clamp(0.0, 1.0),
                                ),
                              ],
                            ),

                          if (widget.isCompleted) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Journey Completed',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Congratulations! You've successfully completed this space with ${widget.partnerName ?? 'your partner'}.",
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.15),
                                height: 1.45,
                              ),
                            ),
                            if (widget.onClose != null) ...[
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: widget.onClose,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A2E55).withValues(alpha: 0.15 + breathe * 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8A2E55).withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFDD8F9F),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: const Color(0xFFDD8F9F),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                          ] else if (widget.isEmpty) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Your journey begins here',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "When you're ready, begin a journey of reflection, growth, and connection.",
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.15),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else ...[
                            const SizedBox(height: 18),

                            // BIG DAY COUNTER
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'Day ',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white
                                        .withValues(alpha: 0.35 + breathe * 0.15),
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFECC8D4),
                                      const Color(0xFFDD8F9F),
                                      Color.lerp(
                                        const Color(0xFF9E7E5A),
                                        const Color(0xFFDD8F9F),
                                        breathe,
                                      )!,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    '${widget.currentDay}',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.0,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // PARTNER NAME — "a space with [name]"
                            if (widget.partnerName != null &&
                                widget.partnerName!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 10,
                                    color: const Color(0xFFDD8F9F)
                                        .withValues(alpha: 0.5 + breathe * 0.3),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'a space with ${widget.partnerName}',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFFDD8F9F)
                                          .withValues(alpha: 0.55 + breathe * 0.2),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 10),

                            // MOOD PHRASE
                            if (widget.moodPhrase.isNotEmpty)
                              Text(
                                widget.moodPhrase,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFD4C4CA)
                                      .withValues(alpha: 0.75 + breathe * 0.15),
                                  height: 1.45,
                                ),
                              ),

                            const SizedBox(height: 18),

                            // MISSED DAY MESSAGE
                            if (widget.isMissedDayFlow) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2E55).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 16,
                                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "You missed a few days of reflection. Take a moment to catch up on the previous check-ins to continue your journey together.",
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFFD4C4CA).withValues(alpha: 0.85),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],

                            // PROGRESS LINE
                            _ProgressLine(
                              progress: (widget.totalDays > 0 ? widget.currentDay / widget.totalDays : 0.0).clamp(0.0, 1.0),
                              breathe: breathe,
                            ),

                            const SizedBox(height: 10),

                            // BOTTOM STATUS ROW
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 11,
                                  color: const Color(0xFF9E7E5A)
                                      .withValues(alpha: 0.6 + breathe * 0.3),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    widget.statusLine,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(0xFF866571)
                                          .withValues(alpha: 0.8 + breathe * 0.1),
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'of ${widget.totalDays}',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF9E7E5A)
                                        .withValues(alpha: 0.5 + breathe * 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      ),
                    ),

                    // ── GLASS BORDER HIGHLIGHT ──
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.04 + breathe * 0.03),
                              width: 1.0,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white
                                    .withValues(alpha: 0.04 + breathe * 0.02),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Floating Heart Orb (right side of top row)
// ────────────────────────────────────────────────────────────────────────────

class _FloatingHeartOrb extends StatelessWidget {
  final double breathe;
  final double drift;
  final double progress;

  const _FloatingHeartOrb({
    required this.breathe,
    required this.drift,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = math.sin(drift * math.pi * 2) * 4;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient glow
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2E55)
                        .withValues(alpha: 0.18 + breathe * 0.18),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            // Progress ring
            CustomPaint(
              size: const Size(60, 60),
              painter: _RingPainter(
                progress: progress,
                breathe: breathe,
                drift: drift,
              ),
            ),

            // Glassmorphic orb
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8A2E55)
                        .withValues(alpha: 0.08 + breathe * 0.06),
                    border: Border.all(
                      color: const Color(0xFFDD8F9F)
                          .withValues(alpha: 0.18 + breathe * 0.12),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      size: 15,
                      color: Color.lerp(
                        const Color(0xFFDD8F9F),
                        const Color(0xFFECC8D4),
                        breathe,
                      ),
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

// ────────────────────────────────────────────────────────────────────────────
// Progress Line
// ────────────────────────────────────────────────────────────────────────────

class _ProgressLine extends StatelessWidget {
  final double progress;
  final double breathe;

  const _ProgressLine({required this.progress, required this.breathe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // Track
              Container(
                width: double.infinity,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill with glow
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8A2E55)
                            .withValues(alpha: 0.8),
                        Color.lerp(
                          const Color(0xFFDD8F9F),
                          const Color(0xFF9E7E5A),
                          breathe,
                        )!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDD8F9F)
                            .withValues(alpha: 0.4 + breathe * 0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ────────────────────────────────────────────────────────────────────────────

class _DustPainter extends CustomPainter {
  final double drift;
  final double breathe;

  _DustPainter({required this.drift, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(7);

    for (int i = 0; i < 18; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.3 + 0.08;
      final radius = rng.nextDouble() * 1.4 + 0.4;
      final isGold = i % 3 == 0;

      double y = (baseY - drift * size.height * speed) % size.height;
      if (y < 0) y += size.height;
      final x = baseX + math.sin(drift * math.pi * 2 + i * 1.3) * 8;

      final fade = math.sin((y / size.height) * math.pi).clamp(0.0, 1.0);
      final alpha = fade * (isGold ? 0.20 : 0.12) * (0.6 + breathe * 0.4);

      paint.color = isGold
          ? Color.fromRGBO(158, 126, 90, alpha.clamp(0.0, 1.0))
          : Color.fromRGBO(221, 143, 159, alpha.clamp(0.0, 1.0));

      canvas.drawCircle(Offset(x.clamp(0, size.width), y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) =>
      old.drift != drift || old.breathe != breathe;
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double breathe;
  final double drift;

  _RingPainter({
    required this.progress,
    required this.breathe,
    required this.drift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    if (progress <= 0) return;

    // Glow layer
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [
            const Color(0xFF8A2E55).withValues(alpha: 0.2),
            const Color(0xFFDD8F9F).withValues(alpha: 0.7 + breathe * 0.3),
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Crisp arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [
            const Color(0xFF8A2E55),
            const Color(0xFFDD8F9F),
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5,
    );

    // Tip dot
    final tipAngle = -math.pi / 2 + math.pi * 2 * progress;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      3.5,
      Paint()
        ..color = const Color(0xFFDD8F9F).withValues(alpha: 0.9 + breathe * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      2.0,
      Paint()..color = const Color(0xFFECC8D4),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.breathe != breathe ||
      old.drift != drift;
}
