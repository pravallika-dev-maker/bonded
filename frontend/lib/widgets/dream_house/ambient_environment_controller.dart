import 'package:flutter/material.dart';
import 'dart:math' as math;

enum AmbienceType { warmEvening, rainyNight, goldenHour, moonlit, cozyAfternoon }

class AmbientEnvironmentController extends StatefulWidget {
  final AmbienceType ambience;
  final Widget child;
  final double extraWarmth;

  const AmbientEnvironmentController({
    super.key,
    required this.ambience,
    required this.child,
    this.extraWarmth = 0.0,
  });

  @override
  State<AmbientEnvironmentController> createState() =>
      _AmbientEnvironmentControllerState();
}

class _AmbientEnvironmentControllerState
    extends State<AmbientEnvironmentController> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _rainController;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat();
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _rainController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particleController, _rainController, _breathController]),
      builder: (context, _) {
        return SizedBox.expand(
          child: Stack(
            children: [
              // Breathing background glow
              Positioned.fill(
                child: _buildBreathingGlow(),
              ),
              // Rain overlay
              if (widget.ambience == AmbienceType.rainyNight)
                Positioned.fill(child: _buildRain()),
              // Floating dust particles
              Positioned.fill(child: _buildParticles()),
              // The actual content
              Positioned.fill(
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreathingGlow() {
    final breathValue = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ).value;

    Color glowColor;
    switch (widget.ambience) {
      case AmbienceType.warmEvening:
        glowColor = Color.lerp(const Color(0xFFAA5525), const Color(0xFFFF8A50), widget.extraWarmth)!;
      case AmbienceType.rainyNight:
        glowColor = Color.lerp(const Color(0xFF2A4A7A), const Color(0xFF5A7AB5), widget.extraWarmth)!;
      case AmbienceType.goldenHour:
        glowColor = Color.lerp(const Color(0xFFBB8833), const Color(0xFFFFB74D), widget.extraWarmth)!;
      case AmbienceType.moonlit:
        glowColor = Color.lerp(const Color(0xFF445577), const Color(0xFF7A9BB5), widget.extraWarmth)!;
      case AmbienceType.cozyAfternoon:
        glowColor = Color.lerp(const Color(0xFF996644), const Color(0xFFD4864A), widget.extraWarmth)!;
    }

    final double baseOpacity = 0.04 + breathValue * 0.04;
    final double finalOpacity = (baseOpacity + widget.extraWarmth * 0.18).clamp(0.0, 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, 0.6),
          radius: 1.2 + widget.extraWarmth * 0.4,
          colors: [
            glowColor.withOpacity(finalOpacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildRain() {
    final droplets = <Widget>[];
    final size = MediaQuery.of(context).size;
    final rand = math.Random(7);
    for (int i = 0; i < 50; i++) {
      final x = rand.nextDouble() * size.width;
      final speed = rand.nextDouble() * 0.5 + 0.5;
      final t = (_rainController.value * speed + rand.nextDouble()) % 1.0;
      final y = t * (size.height + 80) - 40;
      droplets.add(Positioned(
        left: x + t * 15,
        top: y,
        child: Opacity(
          opacity: (0.12 + rand.nextDouble() * 0.12).clamp(0.0, 1.0),
          child: Container(
            width: 0.8,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF8EB4D8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ));
    }
    return Stack(children: droplets);
  }

  Widget _buildParticles() {
    final particles = <Widget>[];
    final size = MediaQuery.of(context).size;
    final rand = math.Random(13);
    final count = (widget.ambience == AmbienceType.warmEvening ? 14 : 8) + (widget.extraWarmth * 16).toInt();
    for (int i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = rand.nextDouble() * math.pi * 2;
      final drift = math.sin(_particleController.value * math.pi * 2 + phase) * 20;
      final baseOpacity = math.sin(_particleController.value * math.pi * 2 + phase) * 0.2 + 0.25;
      final opacity = (baseOpacity + widget.extraWarmth * 0.3).clamp(0.0, 0.85);
      final s = rand.nextDouble() * (2.5 + widget.extraWarmth * 1.5) + 1.0;
      particles.add(Positioned(
        left: x,
        top: baseY + drift,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8C5A0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8C5A0).withOpacity(0.3 + widget.extraWarmth * 0.3),
                  blurRadius: 5 + widget.extraWarmth * 3,
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return Stack(children: particles);
  }
}
