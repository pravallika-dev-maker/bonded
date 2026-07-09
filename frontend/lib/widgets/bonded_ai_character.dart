import 'dart:math' as math;
import 'package:flutter/material.dart';

class BondedAiCharacterWidget extends StatefulWidget {
  final bool triggerSuccess;

  const BondedAiCharacterWidget({super.key, this.triggerSuccess = false});

  @override
  State<BondedAiCharacterWidget> createState() => _BondedAiCharacterWidgetState();
}

class _BondedAiCharacterWidgetState extends State<BondedAiCharacterWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _breatheController;
  late AnimationController _blinkController;
  late AnimationController _jumpController;
  late AnimationController _walkController;
  late AnimationController _flutterController;

  late Animation<double> _floatAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _jumpAnimation;
  late Animation<double> _walkAnimation;

  bool _isBlinking = false;
  final math.Random _random = math.Random();
  List<_Sparkle> _sparkles = [];

  @override
  void initState() {
    super.initState();

    // 1. Floating Animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 2. Breathing Animation (Scale)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // 3. Blinking Controller
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scheduleBlink();

    // 4. Jump & Sparkle Animation (Success)
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -40.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -40.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_jumpController);

    // 5. Walking (Translation X)
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _walkAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOutSine),
    );

    // 6. Wing Fluttering
    _flutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);

    if (widget.triggerSuccess) {
      _triggerSuccessAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant BondedAiCharacterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerSuccess && !oldWidget.triggerSuccess) {
      _triggerSuccessAnimation();
    }
  }

  void _scheduleBlink() {
    if (!mounted) return;
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(4000)), () {
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

  void _triggerSuccessAnimation() {
    _jumpController.forward(from: 0);
    _generateSparkles();
  }

  void _generateSparkles() {
    _sparkles = List.generate(8, (index) {
      return _Sparkle(
        angle: _random.nextDouble() * 2 * math.pi,
        distance: 40 + _random.nextDouble() * 40,
        size: 4 + _random.nextDouble() * 8,
        delay: _random.nextDouble() * 0.2,
      );
    });
    setState(() {});
  }

  @override
  void dispose() {
    _floatController.dispose();
    _breatheController.dispose();
    _blinkController.dispose();
    _jumpController.dispose();
    _walkController.dispose();
    _flutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _breatheController, _jumpController, _walkController, _flutterController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Sparkles Layer
            if (_jumpController.isAnimating)
              ..._sparkles.map((sparkle) {
                final progress = math.max(0.0, (_jumpController.value - sparkle.delay) / (1 - sparkle.delay));
                final currentDist = sparkle.distance * Curves.easeOutQuint.transform(progress);
                final opacity = 1.0 - Curves.easeIn.transform(progress);
                
                return Positioned(
                  left: 60 + math.cos(sparkle.angle) * currentDist, // Centered horizontally (120/2)
                  top: 60 + math.sin(sparkle.angle) * currentDist, // Centered vertically
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.favorite,
                      color: const Color(0xFFECAABB),
                      size: sparkle.size,
                    ),
                  ),
                );
              }).toList(),

            // Character Layer
            Transform.translate(
              offset: Offset(_walkAnimation.value, _floatAnimation.value + _jumpAnimation.value),
              child: Transform.rotate(
                angle: _walkAnimation.value * 0.008, // Head tilt based on movement direction
                child: Transform.scale(
                  scale: _breatheAnimation.value,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow aura
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFDD8F9F).withValues(alpha: 0.35),
                              const Color(0xFFDD8F9F).withValues(alpha: 0.0),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Left Wing
                      Positioned(
                        left: -5,
                        top: 35,
                        child: Transform.rotate(
                          angle: -math.sin(_flutterController.value * math.pi) * 0.5 - 0.3,
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 25,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECAABB).withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              border: Border.all(color: const Color(0xFFFFF0F3).withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ),
                      // Right Wing
                      Positioned(
                        right: -5,
                        top: 35,
                        child: Transform.rotate(
                          angle: math.sin(_flutterController.value * math.pi) * 0.5 + 0.3,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 25,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECAABB).withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              border: Border.all(color: const Color(0xFFFFF0F3).withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ),
                      // Body
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFF9D1DC), // Softer, friendlier pink
                              Color(0xFFDD8F9F),
                              Color(0xFFA1406C), // Deep shadow edge
                            ],
                            center: Alignment(-0.3, -0.3),
                            radius: 0.85,
                            stops: [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Eyes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEye(),
                          const SizedBox(width: 20),
                          _buildEye(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
      },
    );
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final scaleY = 1.0 - _blinkController.value;
        return Transform.scale(
          scaleY: scaleY.clamp(0.05, 1.0),
          child: Container(
            width: 8,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF260D1A),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

class _Sparkle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}
