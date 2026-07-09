import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sky_haven_service.dart';
import 'engine/sky_haven_3d_engine.dart';
import 'widgets/whisper_dialog.dart';
import 'sky_haven_screen.dart';

// =============================================================================
// SHARED DESIGN SYSTEM — All stages use EXACTLY these constants
// =============================================================================
class _DS {
  // Background
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0518), Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF180710)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Card
  static BoxDecoration card() => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.35), width: 1.2),
    boxShadow: [BoxShadow(color: const Color(0xFFFF8BC2).withOpacity(0.12), blurRadius: 40, spreadRadius: 8)],
  );

  // Button
  static BoxDecoration button() => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF8BC2), Color(0xFFB176F2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(32),
    border: Border.all(
      color: Colors.white.withOpacity(0.25),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFFF8BC2).withOpacity(0.35),
        blurRadius: 24,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Text styles
  // 1st screen unique and pretty style
  static TextStyle get stage1TitleStyle => GoogleFonts.cinzel(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 6.0,
    shadows: [
      Shadow(
        color: const Color(0xFFFF8BC2).withOpacity(0.6),
        blurRadius: 20,
      ),
    ],
  );

  static TextStyle get stage1SubtitleStyle => GoogleFonts.philosopher(
    color: const Color(0xFFE5D5FA),
    fontSize: 18,
    height: 2.0,
    fontStyle: FontStyle.italic,
    letterSpacing: 1.2,
  );

  static TextStyle get titleStyle => GoogleFonts.cinzel(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subtitleStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 16,
    height: 1.8,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 18,
    height: 1.8,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyBoldStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 18,
    height: 1.8,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get buttonStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 1.2,
  );

  static TextStyle get labelStyle => GoogleFonts.quicksand(
    color: const Color(0xFFE5D5FA),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get giftCardStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
}

class SkyHavenOnboardingScreen extends StatefulWidget {
  const SkyHavenOnboardingScreen({super.key});

  @override
  State<SkyHavenOnboardingScreen> createState() => _SkyHavenOnboardingScreenState();
}

class _SkyHavenOnboardingScreenState extends State<SkyHavenOnboardingScreen> with TickerProviderStateMixin {
  int _currentStage = 1;
  late final WebViewController _webViewController;
  List<dynamic> _assets = [];
  bool _isLoading = true;

  // New placement fields
  int? _selectedAssetId;
  List<dynamic> _placedObjects = [];
  bool _isPlaced = false;

  // Global Fade Controller for stage transitions
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
    if (!kIsWeb) {
      _webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent);
    }

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeController.forward();
    
    _loadData();
  }

  Future<void> _loadData() async {
    final assetsRes = await SkyHavenService.getAssets();
    if (mounted) {
      setState(() {
        _assets = assetsRes ?? [];
        _isLoading = false;
      });
    }
  }

  void _nextStage() {
    _fadeController.reverse().then((_) {
      setState(() {
        _currentStage++;
      });
      _fadeController.forward();
    });
  }

  void _onPlacementConfirmed(Map<String, dynamic> data) {
    if (_currentStage != 6 || _isPlaced) return;
    
    // Save to local list so Three.js renders the persistent placed model
    setState(() {
      _placedObjects = [{
        'id': 'first_memory',
        'asset_id': _selectedAssetId ?? 1,
        'position_x': data['x'],
        'position_y': data['y'],
        'rotation': data['rotation'],
        'scale': 1.0,
        'has_unread_whisper': false,
      }];
      _isPlaced = true;
    });

    // Save to server database immediately to persist the memory
    SkyHavenService.placeObject(
      assetId: _selectedAssetId ?? 1,
      positionX: data['x'],
      positionY: data['y'],
      rotation: data['rotation'],
      scale: 1.0,
      whisper: "First memory bloomed during onboarding.",
    ).then((success) {
      debugPrint("First memory placed to backend: $success");
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_sky_haven_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SkyHavenScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1200),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_currentStage) {
      case 1:
        return OnboardingStage1(onNext: _nextStage);
      case 2:
        return OnboardingStage2(onNext: _nextStage);
      case 3:
        return OnboardingStage3(onNext: _nextStage);
      case 4:
        return OnboardingStage4(onNext: _nextStage);
      case 5:
        return OnboardingStage5(
          onSelected: (assetIndex) {
            final assetId = assetIndex + 1;
            setState(() {
              _selectedAssetId = assetId;
            });
            _webViewController.runJavaScript(
              "window.enterPlacementMode('{\"id\": $assetId}');"
            );
            _nextStage();
          },
        );
      case 6:
        return OnboardingStage6(
          isPlaced: _isPlaced,
          onNext: _completeOnboarding,
        );
      default:
        return Container(color: Colors.black); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: Stack(
        children: [
          // Background 3D Engine only active late in the flow
          if (!_isLoading && _currentStage >= 3)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _currentStage < 6 || _isPlaced, // Stop stealing taps once placed
                child: SkyHaven3DEngine(
                  objects: _placedObjects, 
                  onPlacementConfirmed: _onPlacementConfirmed, 
                  onObjectTapped: (id) {}, 
                  externalController: _webViewController,
                ),
              ),
            ),
            
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeController,
              child: _buildStageContent(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}

// ============================================================================
// STAGE 1: WELCOME TO SKY HAVEN
// ============================================================================
class OnboardingStage1 extends StatefulWidget {
  final VoidCallback onNext;
  const OnboardingStage1({super.key, required this.onNext});

  @override
  State<OnboardingStage1> createState() => _OnboardingStage1State();
}

class _OnboardingStage1State extends State<OnboardingStage1> with TickerProviderStateMixin {
  late AnimationController _cameraController;
  late AnimationController _uiFadeController;
  late AnimationController _cloudTransitionController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _isTappable = false;

  @override
  void initState() {
    super.initState();
    
    // Endless forward flight animation
    _cameraController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _cameraController.repeat();

    // Breathing celestial elements animation
    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _breathingAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);

    // UI Fade in after 2 seconds
    _uiFadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _uiFadeController.forward();
        setState(() => _isTappable = true);
      }
    });

    // Cloud cover transition on tap
    _cloudTransitionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  void _handleBegin() {
    if (!_isTappable) return;
    setState(() => _isTappable = false);
    _cloudTransitionController.forward().then((_) {
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Dark Atmospheric Sky Background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: _DS.bgGradient,
            ),
          ),
        ),

        // 2. Animated Clouds and Flight (Parallax)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _cameraController,
            builder: (context, child) {
              return CustomPaint(
                painter: _FlightCloudPainter(_cameraController.value),
              );
            },
          ),
        ),

        // 3. Floating Sparkles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _cameraController,
            builder: (context, child) {
              return CustomPaint(
                painter: _SparklePainter(_cameraController.value),
              );
            },
          ),
        ),

        // 4. UI Layer (Fades in)
        Positioned.fill(
          child: FadeTransition(
            opacity: _uiFadeController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                
                // Celestial Portal visual
                SizedBox(
                  width: 250,
                  height: 250,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_cameraController, _breathingAnimation]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CelestialPortalPainter(
                          _cameraController.value,
                          _breathingAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Shimmering Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFFB7D5),
                      Color(0xFFE5D5FA),
                      Color(0xFFB3C5FF),
                      Color(0xFFFFD700),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'SKY HAVEN',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 8.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF8BC2).withOpacity(0.4),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "A quiet place in the stars",
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFCDBCF6),
                    fontSize: 13,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Glassmorphic Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFF8BC2).withOpacity(0.2),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8BC2).withOpacity(0.03),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "A tiny floating sanctuary built together,\none magical memory at a time.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.philosopher(
                      color: const Color(0xFFE5D5FA),
                      fontSize: 16,
                      height: 1.8,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Pulsing Gradient Button
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingAnimation.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: _handleBegin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                      decoration: _DS.button(),
                      child: Text(
                        'Begin Our Haven',
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),

        // 5. Cloud Transition Cover
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _cloudTransitionController,
            builder: (context, child) {
              if (_cloudTransitionController.value == 0) return const SizedBox.shrink();
              return CustomPaint(
                painter: _CloudCoverPainter(_cloudTransitionController.value),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _breathingController.dispose();
    _uiFadeController.dispose();
    _cloudTransitionController.dispose();
    super.dispose();
  }
}

class _CelestialPortalPainter extends CustomPainter {
  final double progress;
  final double breath;
  _CelestialPortalPainter(this.progress, this.breath);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final baseRadius = size.width * 0.28 * breath;

    // Deep Celestial Ambient Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF9E77F7).withOpacity(0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(center, baseRadius * 1.5, glowPaint);

    final pinkGlow = Paint()
      ..color = const Color(0xFFFF8BC2).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, baseRadius * 1.1, pinkGlow);

    // Dynamic Sweeping Gradient Ring
    final rect = Rect.fromCircle(center: center, radius: baseRadius);
    final ringPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF8BC2),
          Color(0xFFB176F2),
          Color(0xFF8BE4FF),
          Color(0xFFFF8BC2),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawCircle(center, baseRadius, ringPaint);

    // White core thin ring
    final coreRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, baseRadius, coreRingPaint);

    // Orbiting Sparks
    final random = math.Random(12345);
    final orbitPaint = Paint();
    for (int i = 0; i < 12; i++) {
      final angleOffset = (i * math.pi * 2 / 12);
      final speedMult = random.nextDouble() * 0.5 + 0.5;
      final angle = (progress * math.pi * 2 * speedMult) + angleOffset;
      final radiusVariation = baseRadius + math.sin(progress * math.pi * 2 + i) * 6;
      
      final ox = cx + math.cos(angle) * radiusVariation;
      final oy = cy + math.sin(angle) * radiusVariation;
      
      final sizeVal = random.nextDouble() * 3.0 + 1.2;
      final opacity = (0.2 + 0.8 * math.sin(progress * math.pi * 4 + i)).clamp(0.0, 1.0);
      
      orbitPaint.color = const Color(0xFFFFEFA7).withOpacity(opacity);
      canvas.drawCircle(Offset(ox, oy), sizeVal, orbitPaint);
    }

    // Centered Crescent Moon
    final moonPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(cx - 3, cy - 2), radius: 18));
    final clipPath = Path();
    clipPath.addOval(Rect.fromCircle(center: Offset(cx + 4, cy - 5), radius: 18));
    
    final finalMoon = Path.combine(PathOperation.difference, path, clipPath);
    canvas.drawPath(finalMoon, moonPaint);
    
    // Radiant Star inside moon cradle
    final starPaint = Paint()..color = const Color(0xFFFFFAEC);
    canvas.drawCircle(Offset(cx + 8, cy + 5), 2.2, starPaint);
  }

  @override
  bool shouldRepaint(covariant _CelestialPortalPainter oldDelegate) => true;
}

// ============================================================================
// STAGE 2: STORY INTRODUCTION
// ============================================================================
class OnboardingStage2 extends StatefulWidget {
  final VoidCallback onNext;
  const OnboardingStage2({super.key, required this.onNext});

  @override
  State<OnboardingStage2> createState() => _OnboardingStage2State();
}

class _OnboardingStage2State extends State<OnboardingStage2> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _textFadeController;
  late Animation<double> _text1Opacity;
  late Animation<double> _text2Opacity;
  late Animation<double> _text3Opacity;

  @override
  void initState() {
    super.initState();
    
    // Gentle floating zero-gravity animation
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _floatController.repeat(reverse: true);

    // Staggered text fade in
    _textFadeController = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _text1Opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textFadeController, curve: const Interval(0.1, 0.4, curve: Curves.easeIn)));
    _text2Opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textFadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeIn)));
    _text3Opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textFadeController, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)));
    
    _textFadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Dark Atmospheric Background (matches app theme)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(gradient: _DS.bgGradient),
          ),
        ),

        // 2. Tiny Distant Island Silhouette
        Positioned.fill(
          child: CustomPaint(
            painter: _IslandSilhouettePainter(),
          ),
        ),

        // 3. Light Blur Overlay for depth
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
        ),

        // 4. Floating Storybook Card
        Center(
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final dy = math.sin(_floatController.value * math.pi) * 10.0;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: _DS.card(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _text1Opacity,
                    builder: (context, child) => Opacity(
                      opacity: _text1Opacity.value,
                      child: Text(
                        "When two hearts spend time apart,\n\n"
                        "they leave little pieces of themselves\n"
                        "inside a place only they can build.",
                        textAlign: TextAlign.center,
                        style: _DS.bodyStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _text2Opacity,
                    builder: (context, child) => Opacity(
                      opacity: _text2Opacity.value,
                      child: Text(
                        "Every flower,\nevery lantern,\nevery whisper",
                        textAlign: TextAlign.center,
                        style: _DS.bodyStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _text3Opacity,
                    builder: (context, child) => Opacity(
                      opacity: _text3Opacity.value,
                      child: Text(
                        "becomes part of your shared story.",
                        textAlign: TextAlign.center,
                        style: _DS.bodyBoldStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: _DS.button(),
                      child: Text('Continue', style: _DS.buttonStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }
}

// ============================================================================
// STAGE 3: YOUR HAVEN IS BORN
// ============================================================================
class OnboardingStage3 extends StatefulWidget {
  final VoidCallback onNext;
  const OnboardingStage3({super.key, required this.onNext});

  @override
  State<OnboardingStage3> createState() => _OnboardingStage3State();
}

class _OnboardingStage3State extends State<OnboardingStage3> with TickerProviderStateMixin {
  late AnimationController _cloudSplitController;
  late AnimationController _uiFadeController;

  @override
  void initState() {
    super.initState();
    
    // Clouds separating slowly
    _cloudSplitController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    
    // UI elements fading in after clouds clear
    _uiFadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Start sequence
    _cloudSplitController.forward().then((_) {
      if (mounted) _uiFadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: The 3D Engine is underneath us! We just need to peel away the clouds.
    return Stack(
      children: [
        // 1. Splitting Clouds (Left and Right)
        AnimatedBuilder(
          animation: _cloudSplitController,
          builder: (context, child) {
            final val = Curves.easeInOut.transform(_cloudSplitController.value);
            final screenWidth = MediaQuery.of(context).size.width;
            return Stack(
              children: [
                // Left cloud mass sliding left
                Positioned(
                  left: -screenWidth * val,
                  top: 0,
                  bottom: 0,
                  width: screenWidth / 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [const Color(0xFF1A0B2E), const Color(0xFF0D0518).withOpacity(0)],
                        center: const Alignment(1.0, 0.0),
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
                // Right cloud mass sliding right
                Positioned(
                  right: -screenWidth * val,
                  top: 0,
                  bottom: 0,
                  width: screenWidth / 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [const Color(0xFF1A0B2E), const Color(0xFF0D0518).withOpacity(0)],
                        center: const Alignment(-1.0, 0.0),
                        radius: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 2. UI Overlay (Title, Card, and Button)
        Positioned.fill(
          child: FadeTransition(
            opacity: _uiFadeController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Elegant Top Title
                  Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF8BC2), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'OUR SANCTUARY',
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A quiet place in the stars',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFE5D5FA).withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Section: Poetic card and CTA button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF180710).withOpacity(0.65),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFF8BC2).withOpacity(0.25),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF8BC2).withOpacity(0.08),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "A peaceful sanctuary floating in the cosmos. Here, you will plant memories, whispers, and light that grow together.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.philosopher(
                                    color: const Color(0xFFE5D5FA),
                                    fontSize: 16,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: widget.onNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8BC2), Color(0xFFFF70A6)],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8BC2).withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'Create Our Haven',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cloudSplitController.dispose();
    _uiFadeController.dispose();
    super.dispose();
  }
}

// ============================================================================
// CUSTOM PAINTERS FOR ANIMATIONS
// ============================================================================

class _FlightCloudPainter extends CustomPainter {
  final double progress;
  _FlightCloudPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark purple/indigo nebula mist clouds — cinematic dark theme
    for (int i = 0; i < 5; i++) {
      double p = (progress + (i * 0.2)) % 1.0;
      double scale = 1.0 + (p * 5.0);
      double opacity = (1.0 - p).clamp(0.0, 1.0);

      // Alternate between deep purple and dark indigo mist
      final color = (i % 2 == 0)
          ? const Color(0xFF2D1B4E).withOpacity(opacity * 0.6)  // Rich purple mist
          : const Color(0xFF1A0B2E).withOpacity(opacity * 0.5); // Deep indigo mist

      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(scale);
      canvas.drawCircle(Offset(math.cos(i) * 50, math.sin(i) * 50), 70, paint);
      canvas.drawCircle(Offset(math.cos(i + 1) * -70, math.sin(i + 1) * -40), 90, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlightCloudPainter oldDelegate) => true;
}

class _SparklePainter extends CustomPainter {
  final double progress;
  _SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 25; i++) {
      double x = random.nextDouble() * size.width;
      double y = (random.nextDouble() * size.height) - (progress * 80);
      if (y < 0) y += size.height;

      double twinkle = math.sin((progress * math.pi * 10) + i) * 0.5 + 0.5;

      // Alternate between pink sparkles and soft gold stars
      final color = (i % 3 == 0)
          ? const Color(0xFFFF8BC2).withOpacity(twinkle * 0.7)  // Pink
          : (i % 3 == 1)
              ? const Color(0xFFE5D5FA).withOpacity(twinkle * 0.5)  // Lavender
              : const Color(0xFFFFD700).withOpacity(twinkle * 0.4); // Gold

      paint.color = color;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2.5 + 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}

class _CloudCoverPainter extends CustomPainter {
  final double progress;
  _CloudCoverPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark indigo/purple wipe — matches the dark theme perfectly
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A0B2E), // Deep indigo core
          const Color(0xFF0D0518), // Near-black edges
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: size.height * 1.5,
      ));

    double radius = size.height * progress * 1.8;
    canvas.drawCircle(Offset(size.width / 2, size.height), radius, paint);
    canvas.drawCircle(Offset(0, size.height * 0.8), radius * 0.8, paint);
    canvas.drawCircle(Offset(size.width, size.height * 0.8), radius * 0.8, paint);
  }

  @override
  bool shouldRepaint(covariant _CloudCoverPainter oldDelegate) => true;
}

class _IslandSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0A8B9).withOpacity(0.4) // Soft distant purple
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
    // Draw a tiny island shape in the background
    final path = Path();
    double cx = size.width * 0.7;
    double cy = size.height * 0.3;
    
    path.moveTo(cx - 30, cy);
    path.quadraticBezierTo(cx, cy + 20, cx + 30, cy);
    path.quadraticBezierTo(cx + 40, cy - 10, cx + 10, cy - 15);
    path.quadraticBezierTo(cx, cy - 25, cx - 15, cy - 10);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add a tiny tree
    canvas.drawCircle(Offset(cx - 5, cy - 25), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// STAGE 4: MEET YOUR SPARK
// ============================================================================
class OnboardingStage4 extends StatefulWidget {
  final VoidCallback onNext;
  const OnboardingStage4({super.key, required this.onNext});

  @override
  State<OnboardingStage4> createState() => _OnboardingStage4State();
}

class _OnboardingStage4State extends State<OnboardingStage4> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _sparkFloatController;

  @override
  void initState() {
    super.initState();
    
    // UI Fade
    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeController.forward();

    // Spark hovering/circling animation
    _sparkFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _sparkFloatController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Stack(
        children: [
          // 1. Soft Darken/Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // 2. The Animated Spark
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkFloatController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CirclingSparkPainter(_sparkFloatController.value),
                );
              },
            ),
          ),

          // 3. UI Card and Button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: _DS.card(),
                  child: Column(
                    children: [
                      const Text("✨", style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 24),
                      Text(
                        "Every time it's your turn,\nyou'll receive One Spark.\n\n"
                        "One Spark lets you place\none beautiful memory.\n\n"
                        "Slowly,\nyour island becomes\nsomething only the two of you share.",
                        textAlign: TextAlign.center,
                        style: _DS.bodyStyle,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: _DS.button(),
                    child: Text('I Understand', style: _DS.buttonStyle),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sparkFloatController.dispose();
    super.dispose();
  }
}

class _CirclingSparkPainter extends CustomPainter {
  final double progress;
  _CirclingSparkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // We want the spark to circle slowly around the upper-middle section of the screen
    final cx = size.width / 2;
    final cy = size.height * 0.35; // Hovering above the text card
    
    // Circular path
    final angle = progress * math.pi * 2;
    final radiusX = size.width * 0.2;
    final radiusY = size.height * 0.05;
    
    final x = cx + math.cos(angle) * radiusX;
    final y = cy + math.sin(angle) * radiusY;

    // The Spark Glow
    final paint = Paint()
      ..color = const Color(0xFFFF8BC2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(Offset(x, y), 25, paint);
    
    // The Spark Core
    paint.color = Colors.white;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(x, y), 8, paint);

    // Tiny particle trail
    final random = math.Random(42);
    for (int i = 0; i < 8; i++) {
      // Trail follows the path slightly delayed
      final delay = (i + 1) * 0.05;
      var trailAngle = (progress - delay) * math.pi * 2;
      
      // Random drift
      final driftX = (random.nextDouble() - 0.5) * 20;
      final driftY = (random.nextDouble() - 0.5) * 20;

      final tx = cx + math.cos(trailAngle) * radiusX + driftX;
      final ty = cy + math.sin(trailAngle) * radiusY + driftY;
      
      final opacity = (1.0 - (delay * 2)).clamp(0.0, 1.0);
      paint.color = const Color(0xFFFF8BC2).withOpacity(opacity);
      paint.maskFilter = null;
      
      canvas.drawCircle(Offset(tx, ty), random.nextDouble() * 3 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CirclingSparkPainter oldDelegate) => true;
}

// ============================================================================
// STAGE 5: FIRST SPARK GIFT
// ============================================================================
class OnboardingStage5 extends StatefulWidget {
  final Function(int) onSelected;
  const OnboardingStage5({super.key, required this.onSelected});

  @override
  State<OnboardingStage5> createState() => _OnboardingStage5State();
}

class _OnboardingStage5State extends State<OnboardingStage5> with TickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    // Bouncy spring slide up for the drawer
    _slideController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1200),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideController.forward();
    });
  }

  void _handleSelectAsset(int index) {
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay so drawer pops out
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        
        // Sliding Drawer
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              final dy = (1.0 - Curves.elasticOut.transform(_slideController.value)) * 400.0;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
              decoration: BoxDecoration(
                color: const Color(0xFF180710).withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8BC2).withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                    offset: const Offset(0, -10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your First Gift",
                    style: _DS.titleStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose one memory to plant on your island.",
                    style: _DS.labelStyle,
                  ),
                  const SizedBox(height: 32),
                  
                  // The 3 beginner items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGiftCard(0, "🌸", "Blossom Tree"),
                      _buildGiftCard(1, "🏮", "Stone Lantern"),
                      _buildGiftCard(2, "🪑", "Wooden Bench"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftCard(int index, String emoji, String name) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleSelectAsset(index),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: _DS.giftCardStyle,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
}

// ============================================================================
// STAGE 6: PLACE YOUR FIRST MEMORY
// ============================================================================
class OnboardingStage6 extends StatefulWidget {
  final bool isPlaced;
  final VoidCallback onNext;
  const OnboardingStage6({super.key, required this.isPlaced, required this.onNext});

  @override
  State<OnboardingStage6> createState() => _OnboardingStage6State();
}

class _OnboardingStage6State extends State<OnboardingStage6> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaced) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingStage6 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaced && !oldWidget.isPlaced) {
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaced) {
      // Entire screen is the island. Nothing else.
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Premium vignette to focus on the newly bloomed memory
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
                radius: 1.2,
              ),
            ),
          ),
        ),
        
        // Shimmering Text "A new memory has bloomed."
        FadeTransition(
          opacity: _fadeController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFB7D5), Color(0xFFE5D5FA), Color(0xFFB3C5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "A new memory has bloomed.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF8BC2).withOpacity(0.6),
                          blurRadius: 20,
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                
                // Complete Button
                GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8BC2), Color(0xFFB176F2)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8BC2).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Text(
                      'Enter Our Sanctuary',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
