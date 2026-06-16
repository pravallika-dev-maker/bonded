import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FlyingFairyWidget extends StatefulWidget {
  final bool triggerSuccess;

  const FlyingFairyWidget({super.key, this.triggerSuccess = false});

  @override
  State<FlyingFairyWidget> createState() => _FlyingFairyWidgetState();
}

class _FlyingFairyWidgetState extends State<FlyingFairyWidget> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _wanderController;
  late AnimationController _flutterController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;

  late Animation<double> _idleAnimation;
  late Animation<double> _bounceAnimation;

  final math.Random _random = math.Random();
  final List<SparkleParticle> _sparkles = [];
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();

    // 2. Idle Animation (3 seconds)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _idleAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    // 2.5 Wander Animation (10 seconds for wavy figure-8 motion)
    _wanderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // 3. Wing/Flutter Animation
    _flutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scheduleFlutter();

    // 4. Blink Animation
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scheduleBlink();

    // 6. Response Completion Animation (1000ms)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // Gently rise up 15px and slowly return
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -15.0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -15.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_bounceController);

    // Start emitting idle sparkles immediately
    _emitIdleSparkles();

    if (widget.triggerSuccess) {
      _triggerSuccessAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant FlyingFairyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerSuccess && !oldWidget.triggerSuccess) {
      _triggerSuccessAnimation();
    }
  }

  void _scheduleFlutter() {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: 3000 + _random.nextInt(4000)), () {
      if (!mounted) return;
      _flutterController.forward().then((_) {
        _flutterController.reverse().then((_) {
          _flutterController.forward().then((_) {
            _flutterController.reverse().then((_) {
              _scheduleFlutter();
            });
          });
        });
      });
    });
  }

  void _scheduleBlink() {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: 4000 + _random.nextInt(4000)), () {
      if (!mounted) return;
      setState(() => _isBlinking = true);
      _blinkController.forward().then((_) {
        _blinkController.reverse().then((_) {
          setState(() => _isBlinking = false);
          _scheduleBlink();
        });
      });
    });
  }

  void _emitIdleSparkles() {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)), () {
      if (!mounted) return;
      _addSparkle(isTrail: false);
      _emitIdleSparkles();
    });
  }

  void _triggerSuccessAnimation() {
    _bounceController.forward(from: 0);
    for (int i = 0; i < 15; i++) {
      _addSparkle(isTrail: false, burst: true);
    }
  }

  Offset _getFairyCenter() {
    if (!mounted) return Offset.zero;
    final maxWanderX = MediaQuery.of(context).size.width * 0.35;
    final double wanderX = math.sin(_wanderController.value * math.pi * 2) * maxWanderX;
    final double wanderY = math.sin(_wanderController.value * math.pi * 4) * 40;
    return Offset(wanderX, wanderY + _idleAnimation.value + _bounceAnimation.value);
  }

  void _addSparkle({required bool isTrail, bool burst = false}) {
    if (!mounted) return;
    
    // Sparkle colors matching Bonded theme: soft pink, rose gold, warm gold
    final List<Color> colors = [
      const Color(0xFFDD8F9F),
      const Color(0xFFB76E79),
      const Color(0xFFE5C158),
    ];
    final color = colors[_random.nextInt(colors.length)];
    final fairyCenter = _getFairyCenter();

    setState(() {
      _sparkles.add(SparkleParticle(
        // Appear near wings (approximate offsets)
        x: fairyCenter.dx + (burst ? (_random.nextDouble() * 60 - 30) : (_random.nextBool() ? 25.0 : -25.0) + (_random.nextDouble() * 10 - 5)),
        y: fairyCenter.dy + (burst ? (_random.nextDouble() * 60 - 30) : -10.0 + (_random.nextDouble() * 20 - 10)),
        vx: burst ? (_random.nextDouble() * 2 - 1) : (_random.nextDouble() * 0.4 - 0.2),
        vy: burst ? (_random.nextDouble() * 2 - 1) : (_random.nextDouble() * 0.4 - 0.2),
        life: 1.0,
        decay: burst ? 0.015 + _random.nextDouble() * 0.01 : 0.005 + _random.nextDouble() * 0.01,
        size: 2 + _random.nextDouble() * 3,
        color: color,
      ));
    });
  }

  void _updateSparkles(Duration elapsed) {
    if (_sparkles.isEmpty) return;
    setState(() {
      for (var s in _sparkles) {
        s.x += s.vx;
        s.y += s.vy;
        s.life -= s.decay;
      }
      _sparkles.removeWhere((s) => s.life <= 0);
    });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _wanderController.dispose();
    _flutterController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width to wander across safely
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWanderX = screenWidth * 0.35; // Don't go entirely off screen

    return SizedBox(
      width: screenWidth, // Take full width
      height: 250, // Enough height for wavy motion
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Sparkles Layer
          SparkleTrailWidget(
            sparkles: _sparkles,
            onUpdate: _updateSparkles,
            currentOffset: _getFairyCenter,
          ),

          // Fairy Character Layer
          AnimatedBuilder(
            animation: Listenable.merge([
              _idleController,
              _wanderController,
              _flutterController,
              _blinkController,
              _bounceController,
            ]),
            builder: (context, child) {
              // 1. Wander Wavy Math
              final double wanderX = math.sin(_wanderController.value * math.pi * 2) * maxWanderX;
              final double wanderY = math.sin(_wanderController.value * math.pi * 4) * 40;

              // 2. Idle + Bounce Math
              final double yOffset = wanderY + _idleAnimation.value + _bounceAnimation.value;
              final double xOffset = wanderX;
              
              // 3. Wing Flutter & Subtle Rotation (-2 to +2 degrees = ~0.035 rad)
              // Also add tilt based on X movement direction
              final tiltDir = math.cos(_wanderController.value * math.pi * 2);
              final double rotation = (math.sin(_idleController.value * math.pi * 2) * 0.035) + (tiltDir * 0.08);

              // 4. Soft breathing scale (0.98 -> 1.02) combined with blink
              final double breatheScale = 1.0 + (math.sin(_idleController.value * math.pi) * 0.02);
              final double scaleY = breatheScale - (_blinkController.value * 0.15); 
              // Face left or right based on direction
              final double scaleX = breatheScale * (tiltDir > 0 ? 1 : -1);

              // 5. Ambient glow pulse
              final double glowOpacity = 0.15 + (math.sin(_idleController.value * math.pi) * 0.10);

              return Transform.translate(
                offset: Offset(xOffset, yOffset),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft glow behind the fairy
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFDD8F9F).withOpacity(glowOpacity.clamp(0.0, 1.0)),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // The fairy image itself
                          Image.asset(
                            'assets/images/fairy.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // If image fails to load, just show a blank space instead of a star
                              return const SizedBox(width: 120, height: 120);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SparkleParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double decay;
  double size;
  Color color;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.decay,
    required this.size,
    required this.color,
  });
}

class SparkleTrailWidget extends StatefulWidget {
  final List<SparkleParticle> sparkles;
  final Function(Duration) onUpdate;
  final Offset Function()? currentOffset;

  const SparkleTrailWidget({
    super.key,
    required this.sparkles,
    required this.onUpdate,
    this.currentOffset,
  });

  @override
  State<SparkleTrailWidget> createState() => _SparkleTrailWidgetState();
}

class _SparkleTrailWidgetState extends State<SparkleTrailWidget> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  final List<Offset> _pathHistory = [];
  final int _maxHistory = 60; // Approx 1 second of line trailing

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final delta = elapsed - _lastTime;
      _lastTime = elapsed;
      widget.onUpdate(delta);

      if (widget.currentOffset != null) {
        setState(() {
          _pathHistory.add(widget.currentOffset!());
          if (_pathHistory.length > _maxHistory) {
            _pathHistory.removeAt(0);
          }
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 250),
      painter: _SparklePainter(
        sparkles: widget.sparkles,
        pathHistory: _pathHistory,
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final List<SparkleParticle> sparkles;
  final List<Offset> pathHistory;

  _SparklePainter({required this.sparkles, required this.pathHistory});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw the continuous magic line
    if (pathHistory.length > 1) {
      for (int i = 0; i < pathHistory.length - 1; i++) {
        final double progress = i / pathHistory.length; 
        final Paint linePaint = Paint()
          ..color = const Color(0xFFDD8F9F).withOpacity(progress * 0.4)
          ..strokeWidth = 1.0 + (progress * 2.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        
        canvas.drawLine(
          center + pathHistory[i],
          center + pathHistory[i+1],
          linePaint,
        );
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    for (var s in sparkles) {
      if (s.life <= 0) continue;
      paint.color = s.color.withValues(alpha: s.life);
      
      final cx = center.dx + s.x;
      final cy = center.dy + s.y;
      
      canvas.drawCircle(Offset(cx, cy), s.size * s.life, paint);
      
      // Star cross for extra sparkle effect
      if (s.size > 4) {
        paint.color = Colors.white.withValues(alpha: s.life * 0.8);
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s.size * 2 * s.life, height: 1), paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 1, height: s.size * 2 * s.life), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return true; // Always repaint when animated
  }
}
