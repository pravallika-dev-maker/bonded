import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; // For ImageFilter

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  // --- Simulation Flags ---
  // In a real app, _isLastDay would be calculated based on separation dates.
  bool _isLastDay = true;
  bool _isInsightUnlocked = false;

  void _unlockInsights() {
    setState(() {
      _isInsightUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              const Text(
                'YOUR BOND',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF9E7E5A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sofia & Mihail',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '“This is where you both are right now”',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
              const SizedBox(height: 32),

              // --- Bond Progress Card ---
              _BondProgressCard(),
              const SizedBox(height: 24),

              // --- Status Chips ---
              Row(
                children: [
                  const _StatusChip(
                    label: 'Quietly growing',
                    bgColor: Color(0xFF3F1629),
                    textColor: Color(0xFFECAABB),
                    isItalic: true,
                  ),
                  const SizedBox(width: 12),
                  const _StatusChip(
                    label: 'Learning each other',
                    bgColor: Colors.transparent,
                    textColor: Color(0xFF9E7E5A),
                    borderColor: Color(0xFF322315),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Last Day Banner (Notification style) ---
              if (_isLastDay && !_isInsightUnlocked) ...[
                GestureDetector(
                  onTap: _unlockInsights, // Banner tap also unlocks
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F0A13),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF911746).withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF911746).withOpacity(0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Color(0xFFDD8F9F), size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Your insights are ready",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Something beautiful was noticed.",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFDD8F9F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- Locked Insights Vault ---
              _LockedInsightsVault(
                isLastDay: _isLastDay,
                isUnlocked: _isInsightUnlocked,
                onUnlock: _unlockInsights,
              ),
              
              const SizedBox(height: 32),

              // --- Bottom Quote ---
              const Center(
                child: Text(
                  '“You’re not the same as when you started… even if it feels quiet.”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF5A3C47),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Next Steps Section ---
              const _NextStepsCard(),
              const SizedBox(height: 32),

              // --- Final Line ---
              const Center(
                child: Text(
                  '“This connection still has space to grow”',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF331521),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedInsightsVault extends StatefulWidget {
  final bool isLastDay;
  final bool isUnlocked;
  final VoidCallback onUnlock;

  const _LockedInsightsVault({
    required this.isLastDay,
    required this.isUnlocked,
    required this.onUnlock,
  });

  @override
  State<_LockedInsightsVault> createState() => _LockedInsightsVaultState();
}

class _LockedInsightsVaultState extends State<_LockedInsightsVault> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _teaserController;
  int _currentTeaserIndex = 0;
  final List<String> _teasers = [
    "Something important is forming…",
    "Small steps create deep shifts…",
    "Your honest reflections are taking root…",
  ];

  late AnimationController _unlockController;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _shatterAnimation;
  late Animation<double> _blurLiftAnimation;
  
  // Staggered slide up animations for content
  late Animation<Offset> _slideSection1;
  late Animation<Offset> _slideSection2;
  late Animation<Offset> _slideSection3;
  late Animation<double> _fadeSection1;
  late Animation<double> _fadeSection2;
  late Animation<double> _fadeSection3;

  late Animation<double> _celebrationAnimation;

  bool _isAnimatingUnlock = false;
  bool _fullyUnlocked = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the locked state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Teaser text crossfade
    _teaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Every 4 seconds
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentTeaserIndex = (_currentTeaserIndex + 1) % _teasers.length;
          });
          _teaserController.forward(from: 0.0);
        }
      });
    _teaserController.forward();

    // Master unlock sequence controller
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _fullyUnlocked = true;
          });
        }
      });

    // Sequence timing:
    // 0.0 - 0.2: Heartbeat 1 (Scale up)
    // 0.2 - 0.4: Heartbeat 2
    // 0.4 - 0.6: Lock shatter / fade out
    // 0.5 - 0.8: Blur lifting
    // 0.6 - 1.0: Staggered reveal of content
    
    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 20), // shrink away smoothly
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 40),
    ]).animate(_unlockController);

    _shatterAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _unlockController, curve: const Interval(0.4, 0.6, curve: Curves.easeOut)),
    );

    _blurLiftAnimation = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _unlockController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );

    final slideBegin = const Offset(0, 0.2);
    _slideSection1 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic)));
    _fadeSection1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.55, 0.75, curve: Curves.easeIn)));

    _slideSection2 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic)));
    _fadeSection2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.65, 0.85, curve: Curves.easeIn)));

    _slideSection3 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.75, 0.95, curve: Curves.easeOutCubic)));
    _fadeSection3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.75, 0.95, curve: Curves.easeIn)));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)));
  }

  @override
  void didUpdateWidget(_LockedInsightsVault oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked && !_isAnimatingUnlock && !_fullyUnlocked) {
      _startUnlockSequence();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _teaserController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  void _startUnlockSequence() {
    setState(() {
      _isAnimatingUnlock = true;
    });
    _pulseController.stop();
    _teaserController.stop();
    _unlockController.forward();
    
    // Call parent unlock if it wasn't triggered by parent
    if (!widget.isUnlocked) {
      widget.onUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fullyUnlocked) {
      return _buildUnlockedContent();
    }

    return AnimatedBuilder(
      animation: _unlockController,
      builder: (context, child) {
        final blurValue = _isAnimatingUnlock ? _blurLiftAnimation.value : 12.0;
        final lockOpacity = _isAnimatingUnlock ? _shatterAnimation.value : 1.0;
        
        return GestureDetector(
          onTap: () {
            if (widget.isLastDay && !_isAnimatingUnlock) {
              _startUnlockSequence();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The underlying content, blurred out
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                  child: Opacity(
                    opacity: _isAnimatingUnlock ? 1.0 : 0.15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF160A0E),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF322315).withOpacity(0.3)),
                      ),
                      child: _buildUnlockedContent(isRevealing: _isAnimatingUnlock),
                    ),
                  ),
                ),
              ),

              // The Lock UI overlay (fades out during unlock)
              if (!_isAnimatingUnlock || lockOpacity > 0.0)
                Opacity(
                  opacity: lockOpacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      // Subtle gradient overlay for the locked state
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF090204).withOpacity(0.4),
                          const Color(0xFF1F0A13).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Elegant lock with subtle breathing glow
                        AnimatedBuilder(
                          animation: _isAnimatingUnlock ? _unlockController : _pulseController,
                          builder: (context, child) {
                            // Only scale during the unlock sequence, NOT during idle state
                            final scale = _isAnimatingUnlock ? _heartbeatAnimation.value : 1.0;
                            // Use pulse for a soft glowing aura when idle
                            final glowIntensity = _isAnimatingUnlock ? 0.0 : (_pulseAnimation.value - 0.8) / 0.4; // 0.0 to 1.0

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (!_isAnimatingUnlock)
                                      BoxShadow(
                                        color: const Color(0xFF9E7E5A).withOpacity(0.15 * glowIntensity),
                                        blurRadius: 30,
                                        spreadRadius: 5 * glowIntensity,
                                      ),
                                    if (_isAnimatingUnlock)
                                      BoxShadow(
                                        color: const Color(0xFF9E7E5A).withOpacity(0.3),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(36),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF9E7E5A).withOpacity(0.05),
                                        border: Border.all(
                                          color: const Color(0xFF9E7E5A).withOpacity(0.2 + (0.1 * glowIntensity)),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _isAnimatingUnlock ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                          color: const Color(0xFFD4C4CA).withOpacity(0.9),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.isLastDay ? "Tap to reveal your insights" : "Your insights seal on Day 21",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isLastDay ? Colors.white : const Color(0xFF866571),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Teaser crossfade
                        SizedBox(
                          height: 40, // Fixed height to prevent jumping
                          child: AnimatedBuilder(
                            animation: _teaserController,
                            builder: (context, child) {
                              // Simple sine wave fade: 0 to 1 and back to 0
                              final fade = math.sin(_teaserController.value * math.pi);
                              return Opacity(
                                opacity: fade,
                                child: Text(
                                  _teasers[_currentTeaserIndex],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFDD8F9F),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              // Particles effect during shatter (optional, simple burst)
              if (_isAnimatingUnlock && _unlockController.value > 0.4 && _unlockController.value < 0.7)
                 _buildShatterParticles(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShatterParticles() {
    // A very simple particle burst effect using the shatter animation progress
    final progress = (_unlockController.value - 0.4) / 0.3; // 0.0 to 1.0
    final particleOpacity = 1.0 - progress;
    final radius = progress * 100.0;
    
    return Stack(
      children: List.generate(8, (index) {
        final angle = (index / 8) * math.pi * 2;
        return Transform.translate(
          offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
          child: Opacity(
            opacity: particleOpacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF9E7E5A),
                boxShadow: [
                  BoxShadow(color: Color(0xFFDD8F9F), blurRadius: 4, spreadRadius: 1),
                ]
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUnlockedContent({bool isRevealing = false}) {
    // If not revealing (fully unlocked), show normally without translation/opacity
    // We reuse existing card widgets from JourneyScreen
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E), // Base background for the vault
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF26181E)), // Subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1
          _buildRevealWrapper(
            isRevealing: isRevealing,
            slideAnim: _slideSection1,
            fadeAnim: _fadeSection1,
            child: const _InsightCard(
              title: 'WHAT WE SEE BETWEEN YOU',
              content: '“You’re beginning to understand each other — not just react to feelings.”',
              titleColor: Color(0xFF5A3C47),
              isVaultContent: true,
            ),
          ),
          
          Container(height: 1, color: const Color(0xFF26181E)), // Separator
          
          // Section 2
          _buildRevealWrapper(
            isRevealing: isRevealing,
            slideAnim: _slideSection2,
            fadeAnim: _fadeSection2,
            child: const _ListCard(
              title: 'WHAT WE SEE IN YOU',
              items: [
                _ListItem(text: 'You’ve been honest with your emotions', dotColor: Color(0xFF8A2E55)),
                _ListItem(text: 'You are trying to pause before reacting', dotColor: Color(0xFF9E7E5A)),
                _ListItem(text: 'You are showing up consistently', dotColor: Color(0xFF8A2E55)),
                _ListItem(text: 'You’re becoming more aware of what matters', dotColor: Color(0xFF9E7E5A)),
              ],
              isVaultContent: true,
            ),
          ),

          Container(height: 1, color: const Color(0xFF26181E)), // Separator

          // Section 3
          _buildRevealWrapper(
            isRevealing: isRevealing,
            slideAnim: _slideSection3,
            fadeAnim: _fadeSection3,
            child: const _ReflectionCard(
              title: 'REFLECTION',
              content: 'Your relationship is slowly shifting from reaction to understanding. Even small pauses are creating space for better connection.',
              isVaultContent: true,
            ),
          ),

          // Celebration line at the bottom
          if (isRevealing || _fullyUnlocked)
            Opacity(
              opacity: isRevealing ? _celebrationAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F0A13),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFF9E7E5A), size: 16),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You showed up — and it shaped something.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF9E7E5A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevealWrapper({
    required bool isRevealing,
    required Animation<Offset> slideAnim,
    required Animation<double> fadeAnim,
    required Widget child,
  }) {
    if (!isRevealing) return child;
    return Transform.translate(
      offset: slideAnim.value * 50, // 50 pixels slide
      child: Opacity(
        opacity: fadeAnim.value,
        child: child,
      ),
    );
  }
}

class _BondProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A13),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Stack(
               alignment: Alignment.center,
               children: [
                 CustomPaint(
                   size: const Size(220, 110),
                   painter: _ArcPainter(),
                 ),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: const [
                     SizedBox(height: 40),
                     Text(
                       'Growing',
                       style: TextStyle(
                         fontFamily: 'Georgia',
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                     Text(
                       'steadily',
                       style: TextStyle(
                         fontFamily: 'Georgia',
                         fontSize: 14,
                         fontStyle: FontStyle.italic,
                         color: Color(0xFF866571),
                       ),
                     ),
                   ],
                 ),
               ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('where you began', style: TextStyle(fontSize: 10, color: Color(0xFF4A343D))),
              Text('still becoming', style: TextStyle(fontSize: 10, color: Color(0xFF4A343D))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              _MiniProgressBar(label: 'Check-ins', progress: 0.6, color: Color(0xFF8A2E55)),
              SizedBox(width: 8),
              _MiniProgressBar(label: 'Openness', progress: 0.4, color: Color(0xFF9E7E5A)),
              SizedBox(width: 8),
              _MiniProgressBar(label: 'Presence', progress: 0.7, color: Color(0xFF8A2E55)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26151B)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8A2E55), Color(0xFFDD8F9F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * 0.7,
      false,
      progressPaint,
    );

    // Draw indicator dot
    final dotPaint = Paint()..color = const Color(0xFFDD8F9F);
    final dotAngle = math.pi + (math.pi * 0.7);
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(dotOffset, 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _MiniProgressBar({required this.label, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6E565E))),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26151B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final bool isItalic;

  const _StatusChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    this.isItalic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 13,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: textColor,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final bool isVaultContent;

  const _InsightCard({
    required this.title,
    required this.content,
    required this.titleColor,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF1F0A13),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<_ListItem> items;
  final bool isVaultContent;

  const _ListCard({
    required this.title,
    required this.items,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF160A0E),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
        border: isVaultContent ? null : Border.all(color: const Color(0xFF1F0A13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF4A343D),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;
  final Color dotColor;

  const _ListItem({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFFC8B3A8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isVaultContent;

  const _ReflectionCard({
    required this.title,
    required this.content,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF160A0E),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
        border: isVaultContent ? null : Border.all(color: const Color(0xFF322315).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF6E565E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Color(0xFF9E7E5A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF26151B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "WHAT'S NEXT FOR YOU BOTH",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF331521),
            ),
          ),
          SizedBox(height: 20),
          _NextStepItem(text: 'Keep choosing to listen a little more'),
          SizedBox(height: 16),
          _NextStepItem(text: 'There’s more to understand, together'),
        ],
      ),
    );
  }
}

class _NextStepItem extends StatelessWidget {
  final String text;
  const _NextStepItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF331521)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF5A3C47),
            ),
          ),
        ),
      ],
    );
  }
}
