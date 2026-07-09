import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'world_ticker.dart';

class CloudLayer extends StatelessWidget {
  final bool isForeground;
  final int seed;

  const CloudLayer({super.key, required this.isForeground, required this.seed});

  @override
  Widget build(BuildContext context) {
    final time = WorldTicker.of(context);
    final random = math.Random(seed);
    
    // Cloud properties
    final speed = isForeground ? 15.0 : 8.0;
    final scale = isForeground ? 1.2 : 0.6;
    final opacity = isForeground ? 0.7 : 0.4;
    final yOffset = random.nextDouble() * 150 - 50.0;
    
    // Infinite drifting logic
    // The screen width is roughly 400. We loop over 800px.
    final rawX = (time * speed) % 800;
    final startX = -200.0; 
    final currentX = startX + rawX;

    return Positioned(
      left: currentX,
      bottom: 100 + yOffset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Color(0xFFEAF8FF), BlendMode.darken),
            child: Image.asset(
              'assets/sky_haven/cloud_soft.png',
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class ParticleEngine extends StatelessWidget {
  const ParticleEngine({super.key});

  @override
  Widget build(BuildContext context) {
    final time = WorldTicker.of(context);
    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(time: time),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double time;
  _ParticlePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Deterministic seed for particles
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw falling petals
    for (int i = 0; i < 15; i++) {
      final speedY = 15.0 + random.nextDouble() * 10;
      final speedX = 5.0 + random.nextDouble() * 10;
      final startX = random.nextDouble() * size.width * 1.5 - size.width * 0.25;
      final startY = random.nextDouble() * size.height;
      
      final currentY = (startY + time * speedY) % size.height;
      final currentX = startX + math.sin(time * 0.5 + i) * 30 + (time * speedX) % size.width;

      final mappedX = currentX % size.width;
      
      paint.color = const Color(0xFFFFB7C5).withOpacity(0.4 + random.nextDouble() * 0.4);
      final petalSize = 2.0 + random.nextDouble() * 2.0;
      
      canvas.drawCircle(Offset(mappedX, currentY), petalSize, paint);
    }
    
    // Draw magical glowing mist/dust near the island
    for (int i = 0; i < 20; i++) {
      final centerX = size.width / 2 + (random.nextDouble() - 0.5) * 200;
      final centerY = size.height / 2 + 50 + (random.nextDouble() - 0.5) * 80;
      
      final bobY = math.sin(time + i) * 10;
      final bobX = math.cos(time * 0.8 + i) * 5;
      
      final opacity = (math.sin(time * 0.5 + i) + 1) / 2 * 0.5; // Pulse 0 to 0.5
      
      paint.color = Colors.white.withOpacity(opacity);
      final dustSize = 1.0 + random.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(centerX + bobX, centerY + bobY), dustSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
