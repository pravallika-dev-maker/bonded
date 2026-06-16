import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class UnconnectedHeroCard extends StatefulWidget {
  final VoidCallback onCreateInvite;
  final VoidCallback onJoinInvite;
  final bool isWaitingState;

  const UnconnectedHeroCard({
    super.key,
    required this.onCreateInvite,
    required this.onJoinInvite,
    this.isWaitingState = false,
  });

  @override
  State<UnconnectedHeroCard> createState() => _UnconnectedHeroCardState();
}

class _UnconnectedHeroCardState extends State<UnconnectedHeroCard>
    with TickerProviderStateMixin {
  // Slow breathe — glow, aura, text opacity
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;

  // Particle drift
  late AnimationController _driftCtrl;

  // Hearts approach / waiting envelope float
  late AnimationController _heartCtrl;
  late Animation<double> _heartFloat;

  // Entrance
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  // Waiting dots
  late AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _breathe = CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOutSine);

    _driftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _heartFloat = CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOutSine);

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<double>(begin: 32.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _driftCtrl.dispose();
    _heartCtrl.dispose();
    _dotsCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathe, _driftCtrl, _heartFloat, _entranceCtrl, _dotsCtrl]),
      builder: (context, _) {
        final breathe = _breathe.value;
        final drift = _driftCtrl.value;
        final heartFloat = _heartFloat.value;

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
                    color: const Color(0xFF8A1C4A).withValues(alpha: 0.12 + breathe * 0.10),
                    blurRadius: 56,
                    spreadRadius: -8,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.04 + breathe * 0.03),
                    blurRadius: 80,
                    spreadRadius: 2,
                    offset: const Offset(0, 28),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // ── Base gradient ──
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E0B14),
                            Color(0xFF150910),
                            Color(0xFF0B0407),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),

                    // ── Top-left pink aurora ──
                    Positioned(
                      top: -70 + breathe * 14,
                      left: -50 - breathe * 6,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFF8A1C4A).withValues(alpha: 0.18 + breathe * 0.06),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Bottom-right rose glow ──
                    Positioned(
                      bottom: -90 - breathe * 16,
                      right: -60 + breathe * 10,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFFDD8F9F).withValues(alpha: 0.09 + breathe * 0.05),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Floating particles ──
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _HeartParticlesPainter(drift: drift, breathe: breathe),
                      ),
                    ),

                    // ── Glass border ──
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFFDD8F9F).withValues(alpha: 0.10 + breathe * 0.04),
                              width: 1.2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.06),
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.02),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Main content ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: widget.isWaitingState
                          ? _buildWaiting(breathe, heartFloat)
                          : _buildNotConnected(breathe, heartFloat),
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

  // ─── Scenario 1: Not connected ───────────────────────────────────────────
  Widget _buildNotConnected(double breathe, double heartFloat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        _Badge(label: 'START YOUR CONNECTION', breathe: breathe),
        const SizedBox(height: 22),

        // Animated hearts illustration
        _TwoHeartsConnecting(breathe: breathe, heartFloat: heartFloat),
        const SizedBox(height: 22),

        // Heading
        _GradientHeading(text: 'Your shared journey\nawaits', breathe: breathe),
        const SizedBox(height: 12),

        // Description
        Text(
          'Invite your partner and enter their code to create your private space together.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.10),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),

        // Buttons
        Row(
          children: [
            Expanded(
              child: _GlowButton(
                label: 'Invite Partner',
                isPrimary: true,
                breathe: breathe,
                onTap: widget.onCreateInvite,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlowButton(
                label: 'Enter Code',
                isPrimary: false,
                breathe: breathe,
                onTap: widget.onJoinInvite,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Helper text
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 12,
              color: const Color(0xFF866571).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Both partners need to connect before starting a separation phase.',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF866571).withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Scenario 4: Waiting for partner ─────────────────────────────────────
  Widget _buildWaiting(double breathe, double heartFloat) {
    // Dots animation: 3 dots fading in/out sequentially
    final dotsProgress = _dotsCtrl.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        _Badge(label: 'WAITING FOR CONNECTION', breathe: breathe, isWaiting: true),
        const SizedBox(height: 22),

        // Floating envelope + heart illustration
        _FloatingEnvelope(breathe: breathe, heartFloat: heartFloat),
        const SizedBox(height: 22),

        // Heading
        _GradientHeading(text: 'Your journey\nbegins here', breathe: breathe),
        const SizedBox(height: 12),

        // Description
        Text(
          'When your partner joins, your shared reflection space will unlock just for the two of you.',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.10),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 22),

        // Waiting pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF8A1C4A).withValues(alpha: 0.10 + breathe * 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDD8F9F).withValues(alpha: 0.18 + breathe * 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                size: 14,
                color: const Color(0xFFDD8F9F).withValues(alpha: 0.8 + breathe * 0.2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Waiting for your partner',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.85),
                  ),
                ),
              ),
              // Animated dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final dotFade = math.sin(
                    (dotsProgress * math.pi * 2) - (i * math.pi / 2),
                  ).clamp(0.2, 1.0) as double;
                  return Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDD8F9F).withValues(alpha: dotFade * 0.9),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // "Invite sent" notice
        Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: const Color(0xFF9E7E5A).withValues(alpha: 0.80),
            ),
            const SizedBox(width: 7),
            Text(
              'Invite sent successfully',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF9E7E5A).withValues(alpha: 0.80),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Resend invite button
        _GlowButton(
          label: 'Resend Invite',
          isPrimary: true,
          breathe: breathe,
          onTap: widget.onCreateInvite,
          icon: Icons.send_rounded,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final double breathe;
  final bool isWaiting;

  const _Badge({required this.label, required this.breathe, this.isWaiting = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1627).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDD8F9F).withValues(alpha: 0.18 + breathe * 0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWaiting
                  ? const Color(0xFFDD8F9F).withValues(alpha: 0.5 + breathe * 0.5)
                  : const Color(0xFFDD8F9F).withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.4 + breathe * 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFFDD8F9F),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientHeading extends StatelessWidget {
  final String text;
  final double breathe;

  const _GradientHeading({required this.text, required this.breathe});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          const Color(0xFFF5E8ED),
          Color.lerp(const Color(0xFFDD8F9F), const Color(0xFFECC8D4), breathe)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.15,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final double breathe;
  final VoidCallback onTap;
  final IconData? icon;

  const _GlowButton({
    required this.label,
    required this.isPrimary,
    required this.breathe,
    required this.onTap,
    this.icon,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> with SingleTickerProviderStateMixin {
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
      onTapUp: (_) {
        _tap.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tap.reverse(),
      child: AnimatedBuilder(
        animation: _tap,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
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
            color: widget.isPrimary ? null : Colors.transparent,
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFFDD8F9F).withValues(alpha: 0.30 + widget.breathe * 0.10)
                  : const Color(0xFFDD8F9F).withValues(alpha: 0.14 + widget.breathe * 0.06),
              width: 1,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF8A1C4A).withValues(alpha: 0.30 + widget.breathe * 0.15),
                      blurRadius: 18,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary
                      ? Colors.white
                      : const Color(0xFFE8D5DD),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hearts connecting illustration (Scenario 1)
// ─────────────────────────────────────────────────────────────────────────────
class _TwoHeartsConnecting extends StatelessWidget {
  final double breathe;
  final double heartFloat;

  const _TwoHeartsConnecting({required this.breathe, required this.heartFloat});

  @override
  Widget build(BuildContext context) {
    // Hearts move toward each other as heartFloat increases
    final separation = 38.0 - heartFloat * 16.0; // 38px apart → 22px apart
    final glowPulse = heartFloat > 0.75 ? (heartFloat - 0.75) / 0.25 : 0.0;

    return Center(
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Central glow pulse when hearts are close
            if (glowPulse > 0)
              Container(
                width: 60 * glowPulse,
                height: 60 * glowPulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFDD8F9F).withValues(alpha: 0.30 * glowPulse),
                    Colors.transparent,
                  ]),
                ),
              ),

            // Dotted line between hearts
            CustomPaint(
              size: const Size(160, 2),
              painter: _DottedLinePainter(breathe: breathe, heartFloat: heartFloat),
            ),

            // Left heart
            Transform.translate(
              offset: Offset(-separation, math.sin(heartFloat * math.pi * 2) * 3),
              child: _HeartIcon(
                size: 28,
                color: const Color(0xFFCA366C),
                glowAlpha: 0.25 + breathe * 0.15 + glowPulse * 0.3,
              ),
            ),

            // Right heart
            Transform.translate(
              offset: Offset(separation, -math.sin(heartFloat * math.pi * 2) * 3),
              child: _HeartIcon(
                size: 28,
                color: const Color(0xFFE89FB8),
                glowAlpha: 0.20 + breathe * 0.12 + glowPulse * 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double glowAlpha;

  const _HeartIcon({required this.size, required this.color, required this.glowAlpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: glowAlpha),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.favorite, size: size, color: color),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final double breathe;
  final double heartFloat;

  _DottedLinePainter({required this.breathe, required this.heartFloat});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDD8F9F).withValues(alpha: 0.25 + breathe * 0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.fill;

    const dotSpacing = 8.0;
    const dotRadius = 1.5;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final lineHalf = 50.0 - heartFloat * 18.0; // shrinks as hearts approach

    double x = centerX - lineHalf;
    while (x < centerX + lineHalf) {
      canvas.drawCircle(Offset(x, centerY), dotRadius, paint);
      x += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter old) =>
      old.breathe != breathe || old.heartFloat != heartFloat;
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating envelope illustration (Scenario 4)
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingEnvelope extends StatelessWidget {
  final double breathe;
  final double heartFloat;

  const _FloatingEnvelope({required this.breathe, required this.heartFloat});

  @override
  Widget build(BuildContext context) {
    final floatY = math.sin(heartFloat * math.pi * 2) * 5.0;

    return Center(
      child: Transform.translate(
        offset: Offset(0, floatY),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A1C4A).withValues(alpha: 0.20 + breathe * 0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Glass orb
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8A1C4A).withValues(alpha: 0.12 + breathe * 0.06),
                    border: Border.all(
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.22 + breathe * 0.10),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mail_outline_rounded,
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.85 + breathe * 0.15),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            // Small floating heart
            Positioned(
              top: 0,
              right: 0,
              child: Transform.scale(
                scale: 0.8 + breathe * 0.2,
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFDD8F9F),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating heart particles painter
// ─────────────────────────────────────────────────────────────────────────────
class _HeartParticlesPainter extends CustomPainter {
  final double drift;
  final double breathe;

  _HeartParticlesPainter({required this.drift, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final rng = math.Random(13);

    for (int i = 0; i < 14; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.18 + 0.04;
      final radius = rng.nextDouble() * 1.6 + 0.5;
      final isRose = i % 3 == 0;

      double y = (baseY - drift * size.height * speed) % size.height;
      if (y < 0) y += size.height;
      final x = baseX + math.sin(drift * math.pi * 2 + i * 1.4) * 9;

      final fade = math.sin((y / size.height) * math.pi).clamp(0.0, 1.0);
      final alpha = fade * (isRose ? 0.18 : 0.10) * (0.6 + breathe * 0.4);

      paint.color = isRose
          ? Color.fromRGBO(221, 143, 159, alpha.clamp(0.0, 1.0))
          : Color.fromRGBO(212, 196, 202, alpha.clamp(0.0, 1.0));

      canvas.drawCircle(Offset(x.clamp(0.0, size.width), y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartParticlesPainter old) =>
      old.drift != drift || old.breathe != breathe;
}
