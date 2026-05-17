import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../providers/dream_house_providers.dart';
import 'dream_house_world_screen.dart';

class DreamHouseEntryScreen extends ConsumerStatefulWidget {
  const DreamHouseEntryScreen({super.key});

  @override
  ConsumerState<DreamHouseEntryScreen> createState() => _DreamHouseEntryScreenState();
}

class _DreamHouseEntryScreenState extends ConsumerState<DreamHouseEntryScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _cinematicController;
  late AnimationController _zoomController;
  late AnimationController _particleController;

  // Cinematic sequence animations
  late Animation<double> _blueprintProgress;
  late Animation<double> _windowGlow;
  late Animation<double> _text1Fade;
  late Animation<double> _text2Fade;
  late Animation<double> _ctaFade;

  bool _isZooming = false;

  @override
  void initState() {
    super.initState();

    // 15-second exact cinematic timeline
    _cinematicController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    // High speed particle loops
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Camera zoom controller on button tap
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Exact timeline mapping:
    // 0.0 - 2.0s (progress 0.0 -> 0.13): Silent Sky
    // 2.0 - 5.0s (progress 0.13 -> 0.33): Blueprint drawing
    _blueprintProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cinematicController,
        curve: const Interval(2.0 / 15.0, 5.0 / 15.0, curve: Curves.easeInOutCubic),
      ),
    );

    // 5.0 - 7.0s (progress 0.33 -> 0.47): Windows warm glow
    _windowGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cinematicController,
        curve: const Interval(5.0 / 15.0, 7.0 / 15.0, curve: Curves.easeOut),
      ),
    );

    // 7.0 - 10.0s (progress 0.47 -> 0.67): Text line 1
    _text1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cinematicController,
        curve: const Interval(7.0 / 15.0, 9.5 / 15.0, curve: Curves.easeIn),
      ),
    );

    // 10.0 - 13.0s (progress 0.67 -> 0.87): Text line 2
    _text2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cinematicController,
        curve: const Interval(10.0 / 15.0, 12.5 / 15.0, curve: Curves.easeIn),
      ),
    );

    // 13.0 - 15.0s (progress 0.87 -> 1.0): Music swell & Moonlight CTA
    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cinematicController,
        curve: const Interval(13.0 / 15.0, 14.8 / 15.0, curve: Curves.easeOut),
      ),
    );

    // Start cinematic intro immediately
    _cinematicController.forward();
  }

  void _enterWorld() {
    setState(() {
      _isZooming = true;
    });

    _zoomController.forward().then((_) {
      ref.read(dreamHouseStateProvider.notifier).completeOnboarding();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1400),
          pageBuilder: (_, __, ___) => const DreamHouseWorldScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _cinematicController.dispose();
    _zoomController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060307),
      body: AnimatedBuilder(
        animation: Listenable.merge([_cinematicController, _zoomController, _particleController]),
        builder: (context, _) {
          final zoomVal = _zoomController.value;
          final cinematicVal = _cinematicController.value;
          
          // Camera zoom visual modifiers
          final scale = 1.0 + (zoomVal * 3.8);
          final opacity = (1.0 - zoomVal * 1.4).clamp(0.0, 1.0);
          final blur = zoomVal * 16.0;

          return Stack(
            children: [
              // Atmospheric cozy twilight starfield background
              Positioned.fill(
                child: CustomPaint(
                  painter: _CinematicBackgroundPainter(time: _particleController.value),
                ),
              ),

              // Soft radial orange sunset flare
              Positioned(
                bottom: -80, left: 0, right: 0,
                child: Opacity(
                  opacity: (0.15 + 0.35 * _windowGlow.value) * (1.0 - zoomVal),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 0.95,
                        colors: [
                          const Color(0xFFD4864A).withOpacity(0.4),
                          const Color(0xFF1E0A12).withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating cozy stardust
              ..._buildStardust(size, zoomVal),

              // Main Screen components with zoom transformation
              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sound wave/Piano visual indicator in top header
                        Opacity(
                          opacity: _ctaFade.value * opacity,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSoundWaveBar(1.0, 18),
                                const SizedBox(width: 3),
                                _buildSoundWaveBar(0.7, 12),
                                const SizedBox(width: 3),
                                _buildSoundWaveBar(0.9, 15),
                                const SizedBox(width: 8),
                                const Text(
                                  'Soft Piano playing softly... 🎶',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF9E7E5A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(),

                        // Center Blueprint house
                        Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: ImageFiltered(
                              imageFilter: blur > 0 ? ColorFilter.mode(Colors.transparent, BlendMode.multiply) : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                              child: SizedBox(
                                width: 230,
                                height: 210,
                                child: CustomPaint(
                                  painter: _BlueprintPainter(
                                    progress: _blueprintProgress.value,
                                    windowGlow: _windowGlow.value,
                                    flickerTime: _particleController.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Fading narrative texts
                        SizedBox(
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Line 1
                              Opacity(
                                opacity: (_text1Fade.value - _text2Fade.value).clamp(0.0, 1.0) * opacity,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '“Some homes are built with bricks.\nYours will be built with little moments.”',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 17.5,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFE8C5A0),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              // Line 2
                              Opacity(
                                opacity: _text2Fade.value * opacity,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '“For the next 7 days,\nleave pieces of love for each other here.”',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 17.5,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFFFD59A),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Moonlight capsule CTA button
                        Opacity(
                          opacity: _ctaFade.value * opacity,
                          child: IgnorePointer(
                            ignoring: _ctaFade.value < 0.8 || _isZooming,
                            child: GestureDetector(
                              onTap: _enterWorld,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.14), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFB366).withOpacity(0.06),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Start Building Together',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFFFE3C2),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Final screen flash during entry
              if (_isZooming)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: const Color(0xFF060307).withOpacity((zoomVal * 1.5).clamp(0.0, 1.0)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSoundWaveBar(double heightFactor, double baseHeight) {
    double factor = heightFactor * (0.6 + 0.4 * math.sin(_particleController.value * math.pi * 6 + baseHeight));
    return Container(
      width: 2.5,
      height: baseHeight * factor,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB366).withOpacity(0.75),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  List<Widget> _buildStardust(Size size, double zoom) {
    final rand = math.Random(1234);
    final list = <Widget>[];
    for (int i = 0; i < 20; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = rand.nextDouble() * math.pi * 2;
      double y = baseY + math.sin(_particleController.value * math.pi * 2 + phase) * 12;

      // Accelerate y-axis flight during camera zoom-in
      if (_isZooming) {
        y = baseY - (zoom * 380 * (1.2 + i % 2));
      }

      final op = (0.2 + 0.5 * math.sin(_particleController.value * math.pi * 2 + phase)).clamp(0.0, 1.0) * (1.0 - zoom);
      final sizeVal = rand.nextDouble() * 2 + 1;

      list.add(Positioned(
        left: x,
        top: y,
        child: Opacity(
          opacity: op,
          child: Container(
            width: sizeVal,
            height: sizeVal,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE3C2),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFE3C2).withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
        ),
      ));
    }
    return list;
  }
}

class _CinematicBackgroundPainter extends CustomPainter {
  final double time;
  _CinematicBackgroundPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky deep gradient
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F060F), Color(0xFF060307)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(Offset.zero & size, sky);

    // 2. Stars twinkling
    final rand = math.Random(555);
    final star = Paint();
    for (int i = 0; i < 18; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final blink = 0.15 + 0.85 * math.sin(time * math.pi * 2 + i);
      star.color = const Color(0xFFFFE3C2).withOpacity(blink.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 0.6 + rand.nextDouble() * 0.8, star);
    }

    // 3. Drifting soft clouds
    final cloud = Paint()
      ..color = const Color(0xFFE8C5A0).withOpacity(0.015)
      ..style = PaintingStyle.fill;

    double c1X = (time * size.width * 0.3) - 40;
    canvas.drawCircle(Offset(c1X, size.height * 0.22), 65, cloud);
    canvas.drawCircle(Offset(c1X + 40, size.height * 0.25), 50, cloud);

    double c2X = size.width - (time * size.width * 0.25) + 40;
    canvas.drawCircle(Offset(c2X, size.height * 0.76), 80, cloud);
  }

  @override
  bool shouldRepaint(_CinematicBackgroundPainter old) => old.time != time;
}

class _BlueprintPainter extends CustomPainter {
  final double progress;
  final double windowGlow;
  final double flickerTime;

  _BlueprintPainter({
    required this.progress,
    required this.windowGlow,
    required this.flickerTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blueprint grid (faint lines that draw as project completes)
    final grid = Paint()
      ..color = const Color(0xFFFFB366).withOpacity(0.03 * progress)
      ..strokeWidth = 0.8;
    for (double i = 0; i <= w; i += 22) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), grid);
    }
    for (double i = 0; i <= h; i += 22) {
      canvas.drawLine(Offset(0, i), Offset(w, i), grid);
    }

    final blueprint = Paint()
      ..color = const Color(0xFFD4864A).withOpacity(0.42 * progress)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Sub-components driven by drawing timeline progress
    final housePath = Path()
      ..moveTo(w * 0.15, h * 0.85)
      ..lineTo(w * 0.15, h * 0.42)
      ..lineTo(w * 0.85, h * 0.42)
      ..lineTo(w * 0.85, h * 0.85)
      ..lineTo(w * 0.15, h * 0.85);

    final roofPath = Path()
      ..moveTo(w * 0.10, h * 0.44)
      ..lineTo(w * 0.50, h * 0.12)
      ..lineTo(w * 0.90, h * 0.44)
      ..close();

    final doorPath = Path()
      ..moveTo(w * 0.42, h * 0.85)
      ..lineTo(w * 0.42, h * 0.62)
      ..arcToPoint(Offset(w * 0.58, h * 0.62), radius: Radius.circular(w * 0.08))
      ..lineTo(w * 0.58, h * 0.85);

    final winLeft = Path()
      ..moveTo(w * 0.24, h * 0.50)
      ..lineTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.38, h * 0.64)
      ..lineTo(w * 0.24, h * 0.64)
      ..close();

    final winRight = Path()
      ..moveTo(w * 0.62, h * 0.50)
      ..lineTo(w * 0.76, h * 0.50)
      ..lineTo(w * 0.76, h * 0.64)
      ..lineTo(w * 0.62, h * 0.64)
      ..close();

    final chimney = Path()
      ..moveTo(w * 0.72, h * 0.30)
      ..lineTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.80, h * 0.18)
      ..lineTo(w * 0.80, h * 0.36);

    // Progressive assembly of paths
    final activePath = Path();
    if (progress > 0.0) {
      double baseProgress = (progress / 0.3).clamp(0.0, 1.0);
      activePath.addPath(housePath, Offset.zero);
    }
    if (progress > 0.3) {
      activePath.addPath(roofPath, Offset.zero);
    }
    if (progress > 0.5) {
      activePath.addPath(chimney, Offset.zero);
    }
    if (progress > 0.65) {
      activePath.addPath(doorPath, Offset.zero);
    }
    if (progress > 0.8) {
      activePath.addPath(winLeft, Offset.zero);
      activePath.addPath(winRight, Offset.zero);
    }

    canvas.drawPath(activePath, blueprint);

    // Warm glowing window lights materialize
    if (windowGlow > 0.0) {
      double flicker = windowGlow * (0.85 + 0.15 * math.sin(flickerTime * math.pi * 8));
      final fill = Paint()..color = const Color(0xFFFFB366).withOpacity(0.68 * flicker);

      final leftRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.50, w * 0.14, h * 0.14), const Radius.circular(3));
      final rightRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.62, h * 0.50, w * 0.14, h * 0.14), const Radius.circular(3));

      // 1. Halo behind windows
      canvas.drawRRect(leftRect, Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.24 * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawRRect(rightRect, Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.24 * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));

      // 2. Draw actual window shapes
      canvas.drawRRect(leftRect, fill);
      canvas.drawRRect(rightRect, fill);

      // Window dividers
      final divider = Paint()
        ..color = const Color(0xFF060307)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(w * 0.31, h * 0.50), Offset(w * 0.31, h * 0.64), divider);
      canvas.drawLine(Offset(w * 0.24, h * 0.57), Offset(w * 0.38, h * 0.57), divider);

      canvas.drawLine(Offset(w * 0.69, h * 0.50), Offset(w * 0.69, h * 0.64), divider);
      canvas.drawLine(Offset(w * 0.62, h * 0.57), Offset(w * 0.76, h * 0.57), divider);

      // Moving stardust particles inside the imagined glow
      final dust = Paint()..color = const Color(0xFF060307).withOpacity(0.3);
      double offsetFactor = math.sin(flickerTime * math.pi * 2);
      canvas.drawCircle(Offset(w * 0.28 + offsetFactor * 4, h * 0.55), 1.5, dust);
      canvas.drawCircle(Offset(w * 0.68 - offsetFactor * 4, h * 0.58), 1.5, dust);
    }
  }

  @override
  bool shouldRepaint(_BlueprintPainter old) =>
      old.progress != progress || old.windowGlow != windowGlow || old.flickerTime != flickerTime;
}
