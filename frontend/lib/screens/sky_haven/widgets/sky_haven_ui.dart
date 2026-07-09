import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─────────────────────────────────────────────
// SkyBackground — premium animated gradient sky
// ─────────────────────────────────────────────
class SkyBackground extends StatefulWidget {
  final bool isNight;

  const SkyBackground({super.key, this.isNight = false});

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimCtrl,
      child: Stack(
        children: [
          if (widget.isNight) const _StarField(),
          // Floating atmospheric mist particles
          ...List.generate(15, (index) => _FloatingMist(index: index)),
        ],
      ),
      builder: (_, child) {
        final t = _shimCtrl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: widget.isNight
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF030310),
                      Color(0xFF070725),
                      Color(0xFF0F102B),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(const Color(0xFF1E153A), const Color(0xFF281F48), t)!,
                      Color.lerp(const Color(0xFF382C5F), const Color(0xFF453574), t)!,
                      Color.lerp(const Color(0xFF5A448C), const Color(0xFF6E56A3), t)!,
                    ],
                  ),
          ),
          child: child,
        );
      },
    );
  }
}

class _FloatingMist extends StatelessWidget {
  final int index;
  const _FloatingMist({required this.index});

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(index * 100);
    return Positioned(
      left: rng.nextDouble() * MediaQuery.of(context).size.width,
      top: rng.nextDouble() * MediaQuery.of(context).size.height,
      child: Container(
        width: 150 + rng.nextDouble() * 200,
        height: 150 + rng.nextDouble() * 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.015 + rng.nextDouble() * 0.02),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .move(
            duration: Duration(seconds: 10 + rng.nextInt(10)),
            begin: const Offset(0, 50),
            end: const Offset(0, -50),
            curve: Curves.easeInOutSine,
          ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(77);
    return Stack(
      children: List.generate(70, (i) {
        final x = rng.nextDouble();
        final y = rng.nextDouble() * 0.8;
        final size = 1.0 + rng.nextDouble() * 2.0;
        return Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: Duration(milliseconds: 1000 + rng.nextInt(2000)))
              .then()
              .fadeOut(duration: Duration(milliseconds: 1000 + rng.nextInt(2000))),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// SkyHavenTopNav
// ─────────────────────────────────────────────
class SkyHavenTopNav extends StatelessWidget {
  const SkyHavenTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
            const Text(
              'Sky Haven',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SkyHavenFloatingButton
// ─────────────────────────────────────────────
class SkyHavenFloatingButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const SkyHavenFloatingButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Color(0xFF282442), size: 20),
            SizedBox(width: 8),
            Text(
              'Add Item',
              style: TextStyle(
                color: Color(0xFF282442),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SkyHavenOnboardingCard
// ─────────────────────────────────────────────
class SkyHavenOnboardingCard extends StatelessWidget {
  final VoidCallback onChooseIsland;

  const SkyHavenOnboardingCard({super.key, required this.onChooseIsland});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌤', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to\nSky Haven',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create your own peaceful floating world.\n\nEverything begins with choosing your floating island.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: onChooseIsland,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Choose Island Base',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF282442),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

// ─────────────────────────────────────────────
// IslandGlowRing — subtle glow under island
// ─────────────────────────────────────────────
class IslandGlowRing extends StatelessWidget {
  final bool isNight;

  const IslandGlowRing({super.key, this.isNight = false});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GlowPainter(
          color: isNight
              ? const Color(0xFF5C9EE8).withOpacity(0.15)
              : const Color(0xFFA8D5A2).withOpacity(0.18),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color color;
  _GlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.55),
        width: size.width * 0.8,
        height: size.height * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.color != color;
}
