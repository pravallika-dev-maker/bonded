import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'poke_menu.dart';
import 'poke_particles.dart';

/// Scenario 2 — Partner is connected but no separation has been started yet.
class ConnectedReadyHeroCard extends StatefulWidget {
  final String partnerName;
  final Map<String, dynamic>? latestPoke;
  final Future<void> Function(String gesture)? onSendPoke;
  final Future<void> Function(int pokeId)? onAcknowledgePoke;

  const ConnectedReadyHeroCard({
    super.key,
    required this.partnerName,
    this.latestPoke,
    this.onSendPoke,
    this.onAcknowledgePoke,
  });

  @override
  State<ConnectedReadyHeroCard> createState() => _ConnectedReadyHeroCardState();
}


class _ConnectedReadyHeroCardState extends State<ConnectedReadyHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breathe;
  late AnimationController _driftCtrl;
  late AnimationController _connectionCtrl;
  late Animation<double> _connection;
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  final PokeParticlesController _particlesController = PokeParticlesController();
  bool _forceOpenPokeMenu = false;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _breathe = CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOutSine);

    _driftCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 22),
    )..repeat();

    // Connection line pulse — slightly faster than breathe
    _connectionCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _connection = CurvedAnimation(parent: _connectionCtrl, curve: Curves.easeInOutSine);

    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.75, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic)),
    );
    _entranceCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant ConnectedReadyHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool hasNewPoke = widget.latestPoke != null &&
        (oldWidget.latestPoke == null ||
         widget.latestPoke!['id'] != oldWidget.latestPoke!['id']);
    if (hasNewPoke) {
      _particlesController.spawn(widget.latestPoke!['gesture'] ?? 'Love');
      setState(() {
        _forceOpenPokeMenu = false; // Reset force open if new poke is received
      });
    }
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _driftCtrl.dispose();
    _connectionCtrl.dispose();
    _entranceCtrl.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  Future<void> _handleSendPoke(String gesture) async {
    _particlesController.spawn(gesture);
    if (widget.onSendPoke != null) {
      await widget.onSendPoke!(gesture);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathe, _driftCtrl, _connection, _entranceCtrl]),
      builder: (context, _) {
        final breathe = _breathe.value;
        final drift = _driftCtrl.value;
        final conn = _connection.value;

        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  // Deep rose glow — breathes
                  BoxShadow(
                    color: const Color(0xFF8A2E55).withValues(alpha: 0.12 + breathe * 0.10),
                    blurRadius: 56,
                    spreadRadius: -8,
                    offset: const Offset(0, 18),
                  ),
                  // Soft gold halo
                  BoxShadow(
                    color: const Color(0xFF9E7E5A).withValues(alpha: 0.06 + breathe * 0.04),
                    blurRadius: 80,
                    spreadRadius: 4,
                    offset: const Offset(0, 24),
                  ),
                  if (widget.latestPoke != null)
                    BoxShadow(
                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.25 + 0.15 * math.sin(breathe * math.pi)),
                      blurRadius: 24 + 12 * math.sin(breathe * math.pi),
                      spreadRadius: 2 + 2 * math.sin(breathe * math.pi),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // ── Base gradient — matches app scaffold/card dark rose ──
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

                    // ── Top-left rose aurora ──
                    Positioned(
                      top: -60 + breathe * 12,
                      left: -40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFF8A2E55).withValues(alpha: 0.12 + breathe * 0.07),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Bottom-right gold aurora ──
                    Positioned(
                      bottom: -80 - breathe * 14,
                      right: -50,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            const Color(0xFF9E7E5A).withValues(alpha: 0.08 + breathe * 0.05),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),

                    // ── Particles ──
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ConnectedParticlesPainter(drift: drift, breathe: breathe),
                      ),
                    ),

                    // ── Poke Particles ──
                    Positioned.fill(
                      child: IgnorePointer(
                        child: PokeParticlesWidget(controller: _particlesController),
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
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.04 + breathe * 0.02),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Main content ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── CONNECTED badge — app rose theme ──
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2E55).withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.22 + breathe * 0.10),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.lerp(
                                          const Color(0xFF8A2E55),
                                          const Color(0xFFDD8F9F),
                                          breathe,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDD8F9F).withValues(alpha: 0.5 + breathe * 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    const Text(
                                      'CONNECTED',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Color(0xFF9E7E5A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Connected hearts illustration ──
                          _ConnectedHeartsIllustration(breathe: breathe, connection: conn),

                          const SizedBox(height: 12),

                          // ── Heading ──
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                const Color(0xFFF5E8ED),
                                Color.lerp(const Color(0xFFDD8F9F), const Color(0xFFECC8D4), breathe)!,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Your journey begins here',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "You are connected. Start a separation phase whenever you're ready.",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFD4C4CA).withValues(alpha: 0.75 + breathe * 0.10),
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Poking interaction ──
                          if (widget.latestPoke != null)
                            // Received gesture view
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2E55).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.22),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.05),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Pulsing Heart / Sparkle Icon
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.95, end: 1.05),
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeInOutSine,
                                      builder: (context, scale, child) {
                                        final gesture = (widget.latestPoke!['gesture'] ?? 'Love').toString();
                                        return Transform.scale(
                                          scale: scale + 0.05 * math.sin(breathe * math.pi * 2),
                                          child: GestureIcon(
                                            gesture: gesture,
                                            color: getGestureColor(gesture),
                                            size: 24,
                                            strokeWidth: 1.5,
                                            filled: true,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.partnerName} sent you a ${widget.latestPoke!['gesture'] ?? "Poke"}',
                                          style: const TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFECC8D4),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (PokeMenu.cooldownRemaining > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDD8F9F).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.20),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  size: 11,
                                                  color: const Color(0xFFECC8D4).withValues(alpha: 0.8),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Send back in ${PokeMenu.cooldownRemaining}s',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Georgia',
                                                    letterSpacing: 0.2,
                                                    color: const Color(0xFFECC8D4).withValues(alpha: 0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () {
                                              final pokeId = widget.latestPoke!['id'];
                                              if (widget.onAcknowledgePoke != null) {
                                                widget.onAcknowledgePoke!(pokeId);
                                              }
                                              setState(() {
                                                _forceOpenPokeMenu = true;
                                              });
                                            },
                                            child: Text(
                                              'Send Back',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Georgia',
                                                decoration: TextDecoration.underline,
                                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.95),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (widget.onSendPoke != null)
                            PokeMenu(
                              onSendPoke: _handleSendPoke,
                              partnerName: widget.partnerName,
                              startExpanded: _forceOpenPokeMenu,
                            ),

                          const SizedBox(height: 16),

                          // ── "Connected with [name]" footer ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 11,
                                color: const Color(0xFFDD8F9F).withValues(alpha: 0.55 + breathe * 0.25),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'Connected with ${widget.partnerName}',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.60 + breathe * 0.20),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
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

// ── Connected hearts with pulsing line ──────────────────────────────────────
class _ConnectedHeartsIllustration extends StatelessWidget {
  final double breathe;
  final double connection;

  const _ConnectedHeartsIllustration({required this.breathe, required this.connection});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        width: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing connection line
            CustomPaint(
              size: const Size(160, 2),
              painter: _ConnectionLinePainter(breathe: breathe, connection: connection),
            ),

            // Left heart — user (deep rose)
            Positioned(
              left: 8,
              child: _GlowingHeart(
                color: const Color(0xFFCA366C),
                size: 22,
                floatOffset: math.sin(connection * math.pi * 2) * 2,
                glowAlpha: 0.28 + breathe * 0.15,
              ),
            ),

            // Right heart — partner (soft pink, matching app theme)
            Positioned(
              right: 8,
              child: _GlowingHeart(
                color: const Color(0xFFDD8F9F),
                size: 22,
                floatOffset: -math.sin(connection * math.pi * 2) * 2,
                glowAlpha: 0.22 + breathe * 0.12,
              ),
            ),

            // Center merge glow
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.30 + connection * 0.25),
                    blurRadius: 12,
                    spreadRadius: 3,
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

class _GlowingHeart extends StatelessWidget {
  final Color color;
  final double size;
  final double floatOffset;
  final double glowAlpha;

  const _GlowingHeart({
    required this.color,
    required this.size,
    required this.floatOffset,
    required this.glowAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, floatOffset),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: glowAlpha), blurRadius: 18, spreadRadius: 2),
          ],
        ),
        child: Icon(Icons.favorite, size: size, color: color),
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  final double breathe;
  final double connection;

  _ConnectionLinePainter({required this.breathe, required this.connection});

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;

    // Glowing gradient line — rose to pink, matching app palette
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFCA366C).withValues(alpha: 0.6 + breathe * 0.2),
          const Color(0xFFDD8F9F).withValues(alpha: 0.7 + connection * 0.2),
          const Color(0xFFECC8D4).withValues(alpha: 0.5 + breathe * 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1.5 + connection * 0.8
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 + connection * 1.0);

    canvas.drawLine(Offset(36, cy), Offset(size.width - 36, cy), paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinePainter old) =>
      old.breathe != breathe || old.connection != connection;
}

class _ConnectedParticlesPainter extends CustomPainter {
  final double drift;
  final double breathe;

  _ConnectedParticlesPainter({required this.drift, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final rng = math.Random(77);

    for (int i = 0; i < 18; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.15 + 0.04;
      final radius = rng.nextDouble() * 1.5 + 0.5;
      // Gold particle every 3rd, pink otherwise — matching app theme
      final isGold = i % 3 == 0;

      double y = (baseY - drift * size.height * speed) % size.height;
      if (y < 0) y += size.height;
      final x = baseX + math.sin(drift * math.pi * 2 + i * 1.3) * 8;

      final fade = math.sin((y / size.height) * math.pi).clamp(0.0, 1.0);
      final alpha = fade * (isGold ? 0.18 : 0.12) * (0.6 + breathe * 0.4);

      paint.color = isGold
          ? Color.fromRGBO(158, 126, 90, alpha.clamp(0.0, 1.0))
          : Color.fromRGBO(221, 143, 159, alpha.clamp(0.0, 1.0));

      canvas.drawCircle(Offset(x.clamp(0.0, size.width), y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectedParticlesPainter old) =>
      old.drift != drift || old.breathe != breathe;
}
