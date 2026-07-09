import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'poke_menu.dart';

class PokeParticle {
  double x; // 0..1 relative width
  double y; // 0..1 relative height
  double vx; // relative X velocity per second
  double vy; // relative Y velocity per second
  double rotation; // current rotation angle in radians
  final double rotationSpeed; // radians per second
  final double swayAmplitude; // horizontal sway amplitude
  final double swayFrequency; // horizontal sway speed
  final double baseScale; // scale multiplier
  final double maxLifetime; // lifetime in seconds
  final double maxOpacity; // target base opacity (subtle)
  double age = 0.0; // age in seconds
  final String gestureName;
  final Color color;

  PokeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.baseScale,
    required this.maxLifetime,
    required this.maxOpacity,
    required this.gestureName,
    required this.color,
  });
}

class PokeParticlesController extends ChangeNotifier {
  String? _lastSpawnedType;
  int _triggerCount = 0;

  String? get lastSpawnedType => _lastSpawnedType;
  int get triggerCount => _triggerCount;

  void spawn(String gestureName) {
    _lastSpawnedType = gestureName;
    _triggerCount++;
    notifyListeners();
  }
}

class PokeParticlesWidget extends StatefulWidget {
  final PokeParticlesController controller;

  const PokeParticlesWidget({
    super.key,
    required this.controller,
  });

  @override
  State<PokeParticlesWidget> createState() => _PokeParticlesWidgetState();
}

class _PokeParticlesWidgetState extends State<PokeParticlesWidget>
    with SingleTickerProviderStateMixin {
  final List<PokeParticle> _particles = [];
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.controller.addListener(_onSpawnTriggered);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSpawnTriggered);
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    _updateParticles(dt);
  }

  void _onSpawnTriggered() {
    final gesture = widget.controller.lastSpawnedType ?? 'Love';
    final Color color = getGestureColor(gesture);

    // Spawn 5-7 particles (very subtle and elegant)
    final int count = 5 + _random.nextInt(3);
    for (int i = 0; i < count; i++) {
      // Gentle launch angles (between -25 and +25 degrees)
      final double launchAngle = ( -25 + _random.nextDouble() * 50 ) * math.pi / 180;
      // Slower upward float speeds
      final double speed = 0.12 + _random.nextDouble() * 0.12; 

      _particles.add(
        PokeParticle(
          x: 0.46 + _random.nextDouble() * 0.08, // start near center X
          y: 0.82, // start near bottom Y
          vx: speed * math.sin(launchAngle),
          vy: -speed * math.cos(launchAngle),
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: -1.0 + _random.nextDouble() * 2.0, // gentle spinning
          swayAmplitude: 0.008 + _random.nextDouble() * 0.010, // tiny drift sway
          swayFrequency: 1.8 + _random.nextDouble() * 2.0,
          baseScale: 0.7 + _random.nextDouble() * 0.4, // smaller sizes
          maxLifetime: 2.0 + _random.nextDouble() * 0.8, // gentle float duration
          maxOpacity: 0.35 + _random.nextDouble() * 0.20, // soft transparent limits
          gestureName: gesture,
          color: color,
        ),
      );
    }

    if (!_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    }
  }

  void _updateParticles(double dt) {
    if (_particles.isEmpty) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
      return;
    }

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.age += dt;

        if (p.age >= p.maxLifetime) {
          _particles.removeAt(i);
          continue;
        }

        // Apply physics
        // Decelerate the initial thrust quickly and drift upwards at a slow, constant float speed
        p.vx = p.vx * math.pow(0.10, dt);
        p.vy = p.vy * math.pow(0.12, dt) + (-0.05) * (1.0 - math.pow(0.12, dt));

        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.rotation += p.rotationSpeed * dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: _PokeParticlesPainter(particles: _particles),
    );
  }
}

class _PokeParticlesPainter extends CustomPainter {
  final List<PokeParticle> particles;

  _PokeParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double progress = p.age / p.maxLifetime;
      
      double scale = p.baseScale;
      double opacity = 1.0;

      if (progress < 0.15) {
        final double entry = progress / 0.15;
        // Soft ease entry instead of high-elastic pop
        scale = p.baseScale * Curves.easeOutCubic.transform(entry);
        opacity = entry;
      } else if (progress > 0.65) {
        final double exit = (1.0 - progress) / 0.35;
        scale = p.baseScale * exit;
        opacity = exit;
      }

      final double finalOpacity = opacity * p.maxOpacity;
      final Color particleColor = p.color.withValues(alpha: finalOpacity);

      // Instantiate custom outline painter
      final iconPainter = GestureIconPainter(
        gesture: p.gestureName,
        color: particleColor,
        strokeWidth: 1.8 * scale,
        filled: true,
      );

      final double particleSize = 18.0 * scale;
      final double sway = p.swayAmplitude * math.sin(p.age * p.swayFrequency) * size.width;
      final double dx = (p.x * size.width) + sway - (particleSize / 2);
      final double dy = (p.y * size.height) - (particleSize / 2);

      canvas.save();
      final double centerX = dx + particleSize / 2;
      final double centerY = dy + particleSize / 2;
      canvas.translate(centerX, centerY);
      canvas.rotate(p.rotation);
      
      iconPainter.paint(canvas, Size(particleSize, particleSize));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PokeParticlesPainter oldDelegate) {
    return true;
  }
}
