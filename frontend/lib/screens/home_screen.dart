import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../widgets/premium_sheen.dart';
import '../services/api_service.dart';
import 'main_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String partnerName;
  const HomeScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late String _userName;
  late String _partnerName;
  late AnimationController _entryController;
  bool _isLoading = true;
  
  late Animation<double> _bgFade;
  late Animation<double> _glowScale;
  late Animation<double> _heartsScale;
  late Animation<double> _greetingFade;
  late Animation<double> _titleFadeUp;
  late Animation<double> _cardSlideUp;
  late Animation<double> _ctaFade;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _partnerName = widget.partnerName;
    WidgetsBinding.instance.addObserver(this);
    _checkConnectionStatus();
    
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _glowScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    _heartsScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.25, 0.65, curve: Curves.elasticOut),
      ),
    );

    _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _titleFadeUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    _cardSlideUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );

    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entryController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectionStatus();
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final response = await ApiService.getUserMe();
      final profile = response['data'] ?? response;

      Map<String, dynamic>? heroResponse;
      try {
        heroResponse = await ApiService.getHomeHero();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? profile['userName'] ?? _userName;
          _partnerName = heroResponse?['partner_name'] ?? heroResponse?['partnerName'] ??
              profile['partnerName'] ?? _partnerName;
        });

        // Check partner connection from heroResponse first (preferred source of truth),
        // then fall back to profile data — covering all possible field names the backend may use.
        bool isPartnerConnected = false;
        if (heroResponse != null) {
          isPartnerConnected =
              heroResponse['partner_connected'] == true ||
              heroResponse['partnerConnected'] == true ||
              heroResponse['is_partner_connected'] == true;
        }
        
        // If they started a solo separation, they should also go to the dashboard
        if (!isPartnerConnected) {
          try {
            final activeSep = await ApiService.getActiveSeparation().catchError((_) => null);
            if (activeSep != null && (activeSep['is_active'] == true || activeSep['isActive'] == true || activeSep['status'] == 'active')) {
              isPartnerConnected = true; // Force navigation to main dashboard
            }
          } catch (_) {}
        }
        
        // Always also check from profile as a fallback
        if (!isPartnerConnected) {
          isPartnerConnected =
              profile['isPartnerConnected'] == true ||
              profile['is_partner_connected'] == true ||
              profile['partner_connected'] == true ||
              (profile['partner'] != null && profile['partner'] is Map);
              
          if (!isPartnerConnected) {
            try {
              final activeSep = await ApiService.getActiveSeparation().catchError((_) => null);
              if (activeSep != null && (activeSep['is_active'] == true || activeSep['isActive'] == true || activeSep['status'] == 'active')) {
                isPartnerConnected = true;
              }
            } catch (_) {}
          }
        }

        if (isPartnerConnected) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainDashboardScreen(
                userName: _userName,
                partnerName: _partnerName,
              ),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          _entryController.forward();
        }
      }
    } catch (e) {
      // Ignore API errors and remain on the waiting screen
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _entryController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF090204),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Color(0xFF090204),
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCA366C)),
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090204),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 1.0,
              colors: [Color(0xFF2A0814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _bgFade,
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                        // ── Top greeting ──
                        FadeTransition(
                          opacity: _greetingFade,
                          child: _AnimatedGreeting(userName: _userName),
                        ),

                        const SizedBox(height: 24),

                        // ── Souls Connecting Centerpiece ──
                        Center(
                          child: FadeTransition(
                            opacity: _heartsScale,
                            child: ScaleTransition(
                              scale: _heartsScale,
                              child: _SoulsConnectingCenterpiece(
                                entryProgress: _entryController.value,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Rotating Text (Title + dynamic details) ──
                        FadeTransition(
                          opacity: _titleFadeUp,
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - _titleFadeUp.value) * 16.0),
                            child: Center(
                              child: _RotatingText(partnerName: _partnerName),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Glassmorphic Waiting card ──
                        FadeTransition(
                          opacity: _cardSlideUp,
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - _cardSlideUp.value) * 20.0),
                            child: _WaitingCard(partnerName: _partnerName),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── While You Wait section with Liquid Gradient CTA ──
                        FadeTransition(
                          opacity: _ctaFade,
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - _ctaFade.value) * 16.0),
                            child: _WhileYouWaitCard(
                              onPressedCTA: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => MainDashboardScreen(
                                      userName: _userName,
                                      isWaitingForPartner: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Bottom quote ──
                        FadeTransition(
                          opacity: _ctaFade,
                          child: const Center(
                            child: Text(
                              'Some connections are worth pausing for.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF5E3A4B),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}

// ── Animated Greeting ─────────────────────────────────────────────────────────
class _AnimatedGreeting extends StatelessWidget {
  final String userName;
  const _AnimatedGreeting({required this.userName});

  @override
  Widget build(BuildContext context) {
    // Defensively clean the userName to remove any leading punctuation like ";"
    final cleanName = userName.replaceAll(RegExp(r'^[\s;,\.-]+'), '').trim();
    return Text(
      "Hello, $cleanName ✨",
      style: const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 15,
        fontStyle: FontStyle.italic,
        color: Color(0xFF8B6774),
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Souls Connecting Centerpiece ──────────────────────────────────────────────
class _SoulsConnectingCenterpiece extends StatefulWidget {
  final double entryProgress;
  const _SoulsConnectingCenterpiece({required this.entryProgress});

  @override
  State<_SoulsConnectingCenterpiece> createState() => _SoulsConnectingCenterpieceState();
}

class _SoulsConnectingCenterpieceState extends State<_SoulsConnectingCenterpiece>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _sweepController;

  late ValueNotifier<double> _timeNotifier;
  late Ticker _particleTicker;

  final List<_ThreadParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _timeNotifier = ValueNotifier(0.0);
    _particleTicker = createTicker((elapsed) {
      if (mounted) {
        _timeNotifier.value = elapsed.inMicroseconds / 1000000.0;
      }
    })..start();

    final rand = math.Random(1234);
    for (int i = 0; i < 25; i++) {
      _particles.add(_ThreadParticle(
        tOffset: rand.nextDouble(),
        speed: 0.08 + rand.nextDouble() * 0.12,
        size: 1.0 + rand.nextDouble() * 2.2,
        color: const Color(0xFFE89FB8),
        driftOffset: Offset(
          -10.0 + rand.nextDouble() * 20.0,
          -10.0 + rand.nextDouble() * 20.0,
        ),
      ));
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _sweepController.dispose();
    _particleTicker.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _pulseController, _sweepController]),
      builder: (context, child) {
        return ValueListenableBuilder<double>(
          valueListenable: _timeNotifier,
          builder: (context, time, child) {
            return CustomPaint(
              size: const Size(260, 160),
              painter: _SoulsConnectingCenterpiecePainter(
                time: time,
                floatVal: _floatController.value,
                pulseVal: _pulseController.value,
                sweepVal: _sweepController.value,
                particles: _particles,
              ),
            );
          },
        );
      },
    );
  }
}

class _ThreadParticle {
  double tOffset;
  final double speed;
  final double size;
  final Color color;
  final Offset driftOffset;

  _ThreadParticle({
    required this.tOffset,
    required this.speed,
    required this.size,
    required this.color,
    required this.driftOffset,
  });
}

class _SoulsConnectingCenterpiecePainter extends CustomPainter {
  final double time;
  final double floatVal;
  final double pulseVal;
  final double sweepVal;
  final List<_ThreadParticle> particles;

  _SoulsConnectingCenterpiecePainter({
    required this.time,
    required this.floatVal,
    required this.pulseVal,
    required this.sweepVal,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Concentric background rings (matches onboarding1_screen.dart waves)
    final ringPaint = Paint()
      ..color = const Color(0xFF1B0A13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(centerX, centerY), size.height * 0.55, ringPaint);
    canvas.drawCircle(Offset(centerX, centerY), size.height * 0.75, ringPaint);

    final double orbDistance = 60.0;
    final double orbADriftY = 4.0 * math.sin(time * 2 * math.pi * 0.25);
    final double orbBDriftY = 4.0 * math.cos(time * 2 * math.pi * 0.25 + 1.0);

    final Offset orbACenter = Offset(centerX - orbDistance, centerY + orbADriftY);
    final Offset orbBCenter = Offset(centerX + orbDistance, centerY + orbBDriftY);

    // 1. Connection Thread (Path)
    final path = Path();
    path.moveTo(orbACenter.dx, orbACenter.dy);
    final controlX = centerX;
    final controlY = centerY + 12.0 * math.sin(time * 2 * math.pi * 0.35);
    path.quadraticBezierTo(controlX, controlY, orbBCenter.dx, orbBCenter.dy);

    // Blurred glowing stroke beneath the solid stroke
    final threadGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFFCA366C).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, threadGlowPaint);

    final threadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF5C233B); // Slightly brighter/warmer than before
    canvas.drawPath(path, threadPaint);

    // 2. Animate small connecting particles along the path
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      for (final p in particles) {
        final currentT = (p.tOffset + time * p.speed) % 1.0;
        final pos = metric.getTangentForOffset(metric.length * currentT)?.position ?? Offset.zero;
        
        // Comet trail effect
        final trailT = (currentT - 0.05).clamp(0.0, 1.0);
        final trailPos = metric.getTangentForOffset(metric.length * trailT)?.position ?? pos;
        
        final double sparkleOpacity = (0.2 + 0.8 * math.sin(time * 2 * math.pi * 1.0 + p.tOffset).abs()).clamp(0.0, 1.0);
        
        final trailPaint = Paint()
          ..color = const Color(0xFFCA366C).withOpacity(sparkleOpacity * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = p.size * 0.7
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(trailPos, pos, trailPaint);

        final particlePaint = Paint()
          ..color = const Color(0xFFFFFFFF).withOpacity(sparkleOpacity);

        canvas.drawCircle(pos, p.size * 0.6, particlePaint);
        
        // Sparkle glow
        canvas.drawCircle(pos, p.size * 1.5, Paint()..color = const Color(0xFFE89FB8).withOpacity(sparkleOpacity * 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));
      }
    }

    // 3. Draw Left Orb (User - Active/Connected state in onboarding style)
    final double radiusA = 22.0 + 1.5 * math.sin(time * 2 * math.pi * 0.5);
    
    // Add soft breathing radial gradient glow behind it
    final glowPaintA = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFCA366C).withOpacity(0.4),
          const Color(0xFFCA366C).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: orbACenter, radius: radiusA * 2.5));
    canvas.drawCircle(orbACenter, radiusA * 2.5, glowPaintA);

    // Fill left orb with dark burgundy
    final fillPaintA = Paint()
      ..color = const Color(0xFF41182B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbACenter, radiusA, fillPaintA);

    // Border of left orb (bright rose)
    final strokePaintA = Paint()
      ..color = const Color(0xFFCA366C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(orbACenter, radiusA, strokePaintA);

    // Heart icon inside active user orb (using Path to avoid web font issues)
    final double hw = 16.0;
    final double hh = 16.0;
    final Path heartPath = Path();
    heartPath.moveTo(0, hh * 0.35);
    heartPath.cubicTo(0, 0, hw * 0.5, 0, hw * 0.5, hh * 0.35);
    heartPath.cubicTo(hw * 0.5, 0, hw, 0, hw, hh * 0.35);
    heartPath.cubicTo(hw, hh * 0.7, hw * 0.5, hh * 0.9, hw * 0.5, hh);
    heartPath.cubicTo(hw * 0.5, hh * 0.9, 0, hh * 0.7, 0, hh * 0.35);
    heartPath.close();

    final Paint heartFillPaint = Paint()
      ..color = const Color(0xFFE89FB8)
      ..style = PaintingStyle.fill;
      
    canvas.save();
    canvas.translate(orbACenter.dx - hw / 2, orbACenter.dy - hh / 2 - 2); // Shifted slightly up for visual center
    canvas.drawPath(heartPath, heartFillPaint);
    canvas.restore();

    // 4. Draw Right Orb (Waiting Partner - Muted/Outline state in onboarding style)
    final double radiusB = 20.0 + 1.0 * math.sin(time * 2 * math.pi * 0.8);
    
    // Pulsating empty glow instead of flat dark fill
    final glowPaintB = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE89FB8).withOpacity(0.15 + 0.1 * math.sin(time * 2 * math.pi * 0.8)),
          const Color(0xFFE89FB8).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: orbBCenter, radius: radiusB * 2.5));
    canvas.drawCircle(orbBCenter, radiusB * 2.5, glowPaintB);

    final fillPaintB = Paint()
      ..color = const Color(0xFF180710)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbBCenter, radiusB, fillPaintB);

    final strokePaintB = Paint()
      ..color = const Color(0xFFE89FB8).withOpacity(0.4 + 0.2 * math.sin(time * 2 * math.pi * 0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(orbBCenter, radiusB, strokePaintB);
    
    // Draw a rippling inner circle
    final double rippleRadius = 4.0 + 8.0 * ((time * 0.8) % 1.0);
    final double rippleOpacity = 1.0 - ((time * 0.8) % 1.0);
    final innerStrokePaintB = Paint()
      ..color = const Color(0xFFE89FB8).withOpacity(0.6 * rippleOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(orbBCenter, rippleRadius, innerStrokePaintB);

    // Heart outline icon inside waiting partner orb
    final heartPainterB = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.favorite_border.codePoint),
        style: TextStyle(
          fontSize: 18,
          fontFamily: Icons.favorite_border.fontFamily,
          package: Icons.favorite_border.fontPackage,
          color: const Color(0xFFE89FB8).withOpacity(0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    heartPainterB.layout();
    heartPainterB.paint(canvas, Offset(orbBCenter.dx - heartPainterB.width / 2, orbBCenter.dy - heartPainterB.height / 2));
  }

  @override
  bool shouldRepaint(_SoulsConnectingCenterpiecePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.floatVal != floatVal ||
        oldDelegate.pulseVal != pulseVal ||
        oldDelegate.sweepVal != sweepVal;
  }
}

// ── Rotating Text (Headline + Subtext) ──────────────────────────────────────────
class _RotatingText extends StatefulWidget {
  final String partnerName;
  const _RotatingText({required this.partnerName});

  @override
  State<_RotatingText> createState() => _RotatingTextState();
}

class _RotatingTextState extends State<_RotatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _headlineController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _headlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headlineController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headlineController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _headlineController.forward();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _headlineController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your story is',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'about to begin.',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE89FB8), // Standard light pink italic accent
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _StaggeredSubtext(
                  text: 'We’ve sent ${widget.partnerName} an invitation to enter your shared space.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StaggeredSubtext extends StatefulWidget {
  final String text;
  const _StaggeredSubtext({required this.text});

  @override
  State<_StaggeredSubtext> createState() => _StaggeredSubtextState();
}

class _StaggeredSubtextState extends State<_StaggeredSubtext>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.text.split(' ');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5.0,
      runSpacing: 4.0,
      children: List.generate(words.length, (index) {
        final double start = (index * 0.05).clamp(0.0, 0.6);
        final double end = (start + 0.35).clamp(0.0, 1.0);
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, 8.0 * (1.0 - animation.value)),
                child: Text(
                  words[index],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7B5C66), // Matches onboarding1 subtext
                    letterSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Waiting Card ──────────────────────────────────────────────────────────────
class _WaitingCard extends StatefulWidget {
  final String partnerName;
  const _WaitingCard({required this.partnerName});

  @override
  State<_WaitingCard> createState() => _WaitingCardState();
}

class _WaitingCardState extends State<_WaitingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF331C24),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF180710),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3D1627),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                '⏳',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (widget.partnerName == null || widget.partnerName!.trim().isEmpty) ? 'Waiting for partner' : 'Waiting for ${widget.partnerName}',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your shared world will unlock once they accept.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B5C66),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const _ActivityIndicator(),
          ],
        ),
      ),
      builder: (context, child) {
        final floatY = math.sin(_floatController.value * 2 * math.pi) * 3.0;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: child,
        );
      },
    );
  }
}

class _HourglassParticles extends StatefulWidget {
  const _HourglassParticles();

  @override
  State<_HourglassParticles> createState() => _HourglassParticlesState();
}

class _HourglassParticlesState extends State<_HourglassParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(44, 44),
          painter: _HourglassPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final double progress;
  _HourglassPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF331C24);
    canvas.drawCircle(Offset(cx, cy), w / 2, ringPaint);

    final frameGlowPaint = Paint()
      ..color = const Color(0xFFCA366C).withOpacity(0.2 + 0.1 * math.sin(progress * 2 * math.pi))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final framePaint = Paint()
      ..color = const Color(0xFFE89FB8).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final glassPath = Path()
      ..moveTo(cx - 10, cy - 14)
      ..lineTo(cx + 10, cy - 14)
      ..lineTo(cx + 2, cy)
      ..lineTo(cx + 10, cy + 14)
      ..lineTo(cx - 10, cy + 14)
      ..lineTo(cx - 2, cy)
      ..close();
    
    canvas.drawPath(glassPath, frameGlowPaint);
    canvas.drawPath(glassPath, framePaint);

    canvas.drawLine(Offset(cx - 12, cy - 14), Offset(cx + 12, cy - 14), framePaint);
    canvas.drawLine(Offset(cx - 12, cy + 14), Offset(cx + 12, cy + 14), framePaint);

    final sandColor = const Color(0xFFE89FB8);
    final sandPaint = Paint()..color = sandColor;

    final double streamProgress = (progress * 3) % 1.0;
    for (double y = cy - 10; y < cy + 12; y += 3) {
      final double offset = (y - (cy - 10)) / 22.0;
      final double alpha = math.sin((offset + streamProgress) * math.pi);
      
      final particlePos = Offset(cx + 0.8 * math.sin(y * 2.0 + progress * 10.0), y);
      
      // Glow for falling sand
      canvas.drawCircle(
        particlePos,
        1.5,
        Paint()
          ..color = sandColor.withOpacity(0.4 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
      );

      canvas.drawCircle(
        particlePos,
        0.8,
        sandPaint..color = Colors.white.withOpacity((0.3 + 0.7 * alpha).clamp(0.0, 1.0)),
      );
    }

    final double topHeight = 10 * (1.0 - (progress % 1.0));
    final topSandPath = Path()
      ..moveTo(cx - 8 * (1.0 - (progress % 1.0)), cy - 14 + topHeight)
      ..lineTo(cx + 8 * (1.0 - (progress % 1.0)), cy - 14 + topHeight)
      ..lineTo(cx + 2, cy)
      ..lineTo(cx - 2, cy)
      ..close();
    canvas.drawPath(
      topSandPath,
      Paint()..color = sandColor.withOpacity(0.5)..style = PaintingStyle.fill,
    );

    final double bottomHeight = 10 * (progress % 1.0);
    final bottomSandPath = Path()
      ..moveTo(cx - 2, cy)
      ..lineTo(cx + 2, cy)
      ..lineTo(cx + 8 * (progress % 1.0), cy + 14 - bottomHeight)
      ..lineTo(cx - 8 * (progress % 1.0), cy + 14 - bottomHeight)
      ..close();
    
    // Bottom sand glow
    canvas.drawPath(
      bottomSandPath,
      Paint()
        ..color = const Color(0xFFCA366C).withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    canvas.drawPath(
      bottomSandPath,
      Paint()..color = sandColor.withOpacity(0.6)..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(cx, cy + 11),
      4.0 * (progress % 1.0),
      Paint()
        ..color = sandColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    canvas.drawCircle(
      Offset(cx, cy + 11),
      4.0 * (progress % 1.0),
      Paint()..color = Colors.white.withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(_HourglassPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ActivityIndicator extends StatefulWidget {
  const _ActivityIndicator();

  @override
  State<_ActivityIndicator> createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<_ActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(40, 24),
          painter: _ActivityPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _ActivityPainter extends CustomPainter {
  final double progress;
  _ActivityPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final path = Path();
    path.moveTo(0, cy);
    path.lineTo(w * 0.25, cy);
    
    path.lineTo(w * 0.35, cy - 8);
    path.lineTo(w * 0.45, cy + 8);
    path.lineTo(w * 0.55, cy - 10);
    path.lineTo(w * 0.65, cy + 4);
    path.lineTo(w * 0.75, cy);
    path.lineTo(w, cy);

    // Thicker, blurred glowing stroke
    final pulseOpacity = (0.3 + 0.7 * math.sin(progress * 2 * math.pi)).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFFCA366C).withOpacity(0.4 * pulseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE89FB8).withOpacity(0.5 + 0.5 * pulseOpacity);
    canvas.drawPath(path, linePaint);

    // The Moving Signal (glowing spark)
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final currentT = progress % 1.0;
      final pos = metric.getTangentForOffset(metric.length * currentT)?.position ?? Offset(w * 0.5, cy);
      
      // Spark aura
      final sparkAuraPaint = Paint()
        ..color = const Color(0xFFCA366C).withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(pos, 3.5, sparkAuraPaint);

      // Spark core
      final sparkCorePaint = Paint()
        ..color = Colors.white;
      canvas.drawCircle(pos, 1.5, sparkCorePaint);
    }
  }

  @override
  bool shouldRepaint(_ActivityPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ── While You Wait Card ────────────────────────────────────────────────────────
class _WhileYouWaitCard extends StatefulWidget {
  final VoidCallback onPressedCTA;
  const _WhileYouWaitCard({required this.onPressedCTA});

  @override
  State<_WhileYouWaitCard> createState() => _WhileYouWaitCardState();
}

class _WhileYouWaitCardState extends State<_WhileYouWaitCard> {
  int _quoteIndex = 0;
  late Timer _timer;
  final List<String> _quotes = [
    "“Love grows quietly before it blooms.”",
    "“Sometimes connection begins in silence.”",
    "“You already took the first step.”",
    "“This space will soon hold two hearts.”",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF180710),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3D1627),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'WHILE YOU WAIT',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF8A6530), // Gold
                ),
              ),
              _FloatingStar(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              reverseDuration: const Duration(milliseconds: 700),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: Alignment.topLeft,
                key: ValueKey<int>(_quoteIndex),
                child: Text(
                  _quotes[_quoteIndex],
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE8C6D3), // Matches quotes in Promise/Transition screens
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _OnboardingStyleCTAButton(onPressed: widget.onPressedCTA),
        ],
      ),
    );
  }
}

class _FloatingStar extends StatefulWidget {
  const _FloatingStar();

  @override
  State<_FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<_FloatingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;
        final floatY = 3.0 * math.sin(_controller.value * 2 * math.pi);
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.rotate(
            angle: angle,
            child: const Icon(
              Icons.star_border_rounded,
              color: Color(0xFF8A6530),
              size: 14,
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingStyleCTAButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _OnboardingStyleCTAButton({required this.onPressed});

  @override
  State<_OnboardingStyleCTAButton> createState() => _OnboardingStyleCTAButtonState();
}

class _OnboardingStyleCTAButtonState extends State<_OnboardingStyleCTAButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Align(
          alignment: Alignment.center,
          child: PremiumSheen(
            animationDuration: const Duration(milliseconds: 1500),
            pauseDuration: const Duration(seconds: 8),
            sheenOpacity: 0.15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1214),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: const Color(0xFF911746).withOpacity(0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.spa_outlined,
                color: Color(0xFFDD8F9F),
                size: 18,
              ),
              const SizedBox(width: 12),
              const Text(
                'Prepare Your Space',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFDD8F9F),
                ),
              ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }
}
