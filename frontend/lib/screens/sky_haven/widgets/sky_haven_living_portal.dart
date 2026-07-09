import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sky_haven_screen.dart';
import '../sky_haven_onboarding_screen.dart';
import '../../../services/sky_haven_service.dart';
import 'living_world/world_ticker.dart';
import 'living_world/composition_engine.dart';
import 'living_world/asset_registry.dart';
import 'living_world/layer_renderer.dart';
import 'living_world/atmosphere_layers.dart';

class SkyHavenLivingPortal extends StatefulWidget {
  const SkyHavenLivingPortal({super.key});

  @override
  State<SkyHavenLivingPortal> createState() => _SkyHavenLivingPortalState();
}

class _SkyHavenLivingPortalState extends State<SkyHavenLivingPortal> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late AnimationController _glowController;
  
  bool _isVisible = false;
  bool _isLoading = true;
  Map<String, dynamic>? _islandData;
  List<ComposedObject> _composedObjects = [];
  int _islandSeed = 0;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    final islandRes = await SkyHavenService.getIsland();
    if (mounted) {
      setState(() {
        _islandData = islandRes;
        _isLoading = false;
        
        final rawObjects = _islandData?['objects'] as List? ?? [];
        _islandSeed = _islandData?['id']?.hashCode ?? 12345;
        _composedObjects = CompositionEngine.compose(rawObjects, 12);
      });
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_transitionController.isAnimating) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_sky_haven_onboarding') ?? false;
    
    _transitionController.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              hasSeenOnboarding ? const SkyHavenScreen() : const SkyHavenOnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      ).then((_) {
        if (mounted) {
          _transitionController.reset();
          _loadData();
        }
      });
    });
  }

  String _getDynamicSubtitle() {
    if (_isLoading) return "Loading your shared haven...";
    return "🌸 Maya planted something beautiful.";
  }

  Widget _buildInfoTag(String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFF8BC2).withOpacity(0.12)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFFF8BC2).withOpacity(0.3)
              : Colors.white.withOpacity(0.12),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          color: isHighlight ? const Color(0xFFFF8BC2) : Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(double fadeOutOpacity) {
    final glowIntensity = 0.3 + (_glowController.value * 0.5);
    final glowSpread = 4.0 + (_glowController.value * 8.0);
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F071B), Color(0xFF1B0C32), Color(0xFF0F071B)],
          ),
          border: Border.all(
            color: const Color(0xFFFF8BC2).withOpacity(0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFFF8BC2).withOpacity(glowIntensity * 0.06),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.0),
          child: Stack(
            children: [
              // Cosmic starfield background
              Positioned.fill(
                child: CustomPaint(
                  painter: _PortalTwinklePainter(_glowController.value),
                ),
              ),
              
              // Central breathing dream island artwork
              Center(
                child: Opacity(
                  opacity: fadeOutOpacity,
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final scale = 1.0 + (_glowController.value * 0.04);
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: 160,
                          height: 120,
                          child: CustomPaint(
                            painter: _DreamIslandPainter(_glowController.value),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 3. Elegant Centered Content Column
              Positioned.fill(
                child: Opacity(
                  opacity: fadeOutOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top row: Brand title & Live indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFF8BC2), Color(0xFFFFD700)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    'SKY HAVEN',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'SHARED SANCTUARY',
                                  style: GoogleFonts.quicksand(
                                    color: const Color(0xFFE5D5FA).withOpacity(0.6),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8BC2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF8BC2).withOpacity(0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                "LIVE",
                                style: GoogleFonts.quicksand(
                                  color: const Color(0xFFFF8BC2),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Center space (handled by MainAxisAlignment.spaceBetween)
                        const SizedBox(height: 10),

                        // Bottom Section: Status subtitle & Info pills
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getDynamicSubtitle(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.philosopher(
                                color: const Color(0xFFE5D5FA),
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildInfoTag("${_composedObjects.length} Memories"),
                                const SizedBox(width: 8),
                                _buildInfoTag("Your Turn", isHighlight: true),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('sky_haven_portal'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        } else if (info.visibleFraction <= 0.1 && _isVisible) {
          setState(() => _isVisible = false);
        }
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_transitionController, _glowController]),
          builder: (context, child) {
            final transitionValue = _transitionController.value;
            final fadeOutOpacity = (1.0 - (transitionValue * 2)).clamp(0.0, 1.0);
            return _buildCard(fadeOutOpacity);
          },
        ),
      ),
    );
  }
}

class _PortalTwinklePainter extends CustomPainter {
  final double progress;
  _PortalTwinklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);
    final paint = Paint();

    // Soft celestial purple nebulae
    for (int i = 0; i < 3; i++) {
      double cx = random.nextDouble() * size.width;
      double cy = random.nextDouble() * size.height;
      double radius = 80.0 + random.nextDouble() * 60.0;
      
      final nebulaColor = (i % 2 == 0)
          ? const Color(0xFF2D1B4E).withOpacity(0.3)
          : const Color(0xFF180710).withOpacity(0.25);

      paint.color = nebulaColor;
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    // Twinkling stars
    paint.maskFilter = null;
    for (int i = 0; i < 40; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double starSize = random.nextDouble() * 1.5 + 0.5;

      // Soft twinkle animation based on math.sin
      double twinkle = math.sin((progress * math.pi * 2) + i) * 0.4 + 0.6;

      final color = (i % 3 == 0)
          ? const Color(0xFFFF8BC2).withOpacity(twinkle * 0.7)  // Twinkling Pink
          : (i % 3 == 1)
              ? const Color(0xFFE5D5FA).withOpacity(twinkle * 0.5)  // Twinkling Lavender
              : const Color(0xFFFFD700).withOpacity(twinkle * 0.5); // Twinkling Gold

      paint.color = color;
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PortalTwinklePainter oldDelegate) => true;
}

class _DreamIslandPainter extends CustomPainter {
  final double progress;
  _DreamIslandPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // We center the island. Ground level is around h * 0.65
    final groundY = h * 0.65;
    final centerX = w / 2;
    
    final paint = Paint();
    
    // 1. Draw floating cloud mist below the island
    final cloudPaint = Paint()
      ..color = const Color(0xFFE5D5FA).withOpacity(0.12 + math.sin(progress * math.pi * 2) * 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(centerX - 25, groundY + 15), 18, cloudPaint);
    canvas.drawCircle(Offset(centerX + 25, groundY + 15), 18, cloudPaint);
    canvas.drawCircle(Offset(centerX, groundY + 22), 22, cloudPaint);

    // 2. Draw the floating island base (rocky, with roots)
    final islandPath = Path();
    islandPath.moveTo(centerX - 45, groundY);
    islandPath.quadraticBezierTo(centerX, groundY - 6, centerX + 45, groundY); // Top grass level
    
    // Bottom rock shape tapering down
    islandPath.quadraticBezierTo(centerX + 35, groundY + 15, centerX + 15, groundY + 24);
    islandPath.quadraticBezierTo(centerX, groundY + 32, centerX - 15, groundY + 24);
    islandPath.quadraticBezierTo(centerX - 35, groundY + 15, centerX - 45, groundY);
    islandPath.close();

    final islandGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF3D2A5A).withOpacity(0.85),
        const Color(0xFF1B0C32).withOpacity(0.9),
      ],
    );
    paint.shader = islandGrad.createShader(Rect.fromLTWH(centerX - 45, groundY - 10, 90, 45));
    paint.maskFilter = null;
    canvas.drawPath(islandPath, paint);
    
    // Roots hanging down from the rock base
    final rootPaint = Paint()
      ..color = const Color(0xFFFF8BC2).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    
    // Draw 3 tiny root paths
    final rootPath1 = Path()
      ..moveTo(centerX - 10, groundY + 20)
      ..quadraticBezierTo(centerX - 12, groundY + 26, centerX - 8, groundY + 34);
    
    final rootPath2 = Path()
      ..moveTo(centerX + 8, groundY + 20)
      ..quadraticBezierTo(centerX + 12, groundY + 28, centerX + 6, groundY + 36);
      
    final rootPath3 = Path()
      ..moveTo(centerX, groundY + 24)
      ..quadraticBezierTo(centerX - 3, groundY + 32, centerX + 2, groundY + 40);
      
    canvas.drawPath(rootPath1, rootPaint);
    canvas.drawPath(rootPath2, rootPaint);
    canvas.drawPath(rootPath3, rootPaint);

    // 3. Draw Grass highlight
    final grassPaint = Paint()
      ..color = const Color(0xFFFF8BC2).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final grassPath = Path()
      ..moveTo(centerX - 42, groundY)
      ..quadraticBezierTo(centerX, groundY - 5, centerX + 42, groundY);
    canvas.drawPath(grassPath, grassPaint);

    // 4. Draw the Tree in the center
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 3, groundY - 2);
    trunkPath.quadraticBezierTo(centerX - 2, groundY - 16, centerX - 6, groundY - 26); // trunk left side
    trunkPath.quadraticBezierTo(centerX - 15, groundY - 32, centerX - 22, groundY - 38); // left branch
    trunkPath.quadraticBezierTo(centerX - 20, groundY - 40, centerX - 14, groundY - 36); // inner left branch
    trunkPath.lineTo(centerX - 2, groundY - 28);
    
    // right branch
    trunkPath.quadraticBezierTo(centerX + 12, groundY - 34, centerX + 20, groundY - 40);
    trunkPath.quadraticBezierTo(centerX + 18, groundY - 42, centerX + 10, groundY - 37);
    trunkPath.lineTo(centerX + 3, groundY - 26);
    trunkPath.lineTo(centerX + 3, groundY - 2);
    trunkPath.close();

    final trunkGrad = LinearGradient(
      colors: [
        const Color(0xFFFF8BC2).withOpacity(0.8),
        const Color(0xFFE5D5FA).withOpacity(0.9),
      ],
    );
    paint.shader = trunkGrad.createShader(Rect.fromLTWH(centerX - 22, groundY - 42, 44, 42));
    canvas.drawPath(trunkPath, paint);

    // Tree Foliage (dreamy glowing clouds of leaves)
    final leafPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    // Left foliage cloud
    leafPaint.color = const Color(0xFFFF8BC2).withOpacity(0.4 + math.sin(progress * math.pi) * 0.05);
    canvas.drawCircle(Offset(centerX - 20, groundY - 40), 14, leafPaint);
    
    // Right foliage cloud
    leafPaint.color = const Color(0xFFE5D5FA).withOpacity(0.35 + math.cos(progress * math.pi) * 0.05);
    canvas.drawCircle(Offset(centerX + 18, groundY - 41), 14, leafPaint);
    
    // Center foliage cloud
    leafPaint.color = const Color(0xFFFF8BC2).withOpacity(0.45);
    canvas.drawCircle(Offset(centerX, groundY - 45), 18, leafPaint);

    // 5. Two glowing partner sparks orbiting/hovering
    paint.shader = null;
    paint.maskFilter = null;
    
    // Spark 1 (Pink) - pulses on left foliage
    final spark1X = centerX - 18 + math.sin(progress * math.pi * 2) * 5;
    final spark1Y = groundY - 45 + math.cos(progress * math.pi * 2) * 4;
    final sparkGlow1 = Paint()
      ..color = const Color(0xFFFF8BC2).withOpacity(0.3 + (math.sin(progress * math.pi * 2) * 0.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(spark1X, spark1Y), 10, sparkGlow1);
    
    final sparkCore1 = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(spark1X, spark1Y), 2.2, sparkCore1);

    // Spark 2 (Gold) - pulses on right foliage
    final spark2X = centerX + 16 - math.sin(progress * math.pi * 2) * 5;
    final spark2Y = groundY - 43 - math.cos(progress * math.pi * 2) * 4;
    final sparkGlow2 = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.3 + (math.cos(progress * math.pi * 2) * 0.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(spark2X, spark2Y), 10, sparkGlow2);
    
    final sparkCore2 = Paint()..color = const Color(0xFFFFFAEE);
    canvas.drawCircle(Offset(spark2X, spark2Y), 2.2, sparkCore2);
  }

  @override
  bool shouldRepaint(covariant _DreamIslandPainter oldDelegate) => true;
}

