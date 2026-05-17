import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dream_house_providers.dart';

class DreamHouseCinematicRevealScreen extends ConsumerStatefulWidget {
  const DreamHouseCinematicRevealScreen({super.key});

  @override
  ConsumerState<DreamHouseCinematicRevealScreen> createState() =>
      _DreamHouseCinematicRevealScreenState();
}

class _DreamHouseCinematicRevealScreenState
    extends ConsumerState<DreamHouseCinematicRevealScreen> with TickerProviderStateMixin {
  
  late AnimationController _cinematicController;
  late AnimationController _audioWaveController;
  late AnimationController _badgeGlowController;

  // Active steps:
  // 0: Initial Pitch Black / Widescreen slow build
  // 1: Room sequence panning
  // 2: Sunrise pay-off climax card
  // 3: Scrapbook memory scrapbook list
  int _climaxStage = 0;
  int _activePanRoom = 0; // 0: Living Room, 1: Kitchen, 2: Bedroom, 3: Hobby, 4: Future

  final List<String> _narrationLines = [
    'For the past 7 quiet days…',
    'you left pieces of your heart in this home.',
    'Every corner now holds a feeling.',
    'Let’s step inside and remember…',
  ];
  int _currentNarration = 0;

  @override
  void initState() {
    super.initState();

    _cinematicController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );

    _audioWaveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _badgeGlowController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    // Initial narration line-by-line build timer
    _animateNarrations();
  }

  void _animateNarrations() async {
    for (int i = 0; i < _narrationLines.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentNarration = i;
      });
      await Future.delayed(const Duration(milliseconds: 2800));
    }

    // Start room panning sequence
    if (mounted) {
      setState(() {
        _climaxStage = 1;
      });
      _startRoomPanning();
    }
  }

  void _startRoomPanning() async {
    for (int i = 0; i < 5; i++) {
      if (!mounted) return;
      setState(() {
        _activePanRoom = i;
      });
      await Future.delayed(const Duration(milliseconds: 3200));
    }

    // Trigger sunrise climax card
    if (mounted) {
      setState(() {
        _climaxStage = 2;
      });
      _cinematicController.forward();
    }
  }

  @override
  void dispose() {
    _cinematicController.dispose();
    _audioWaveController.dispose();
    _badgeGlowController.dispose();
    super.dispose();
  }

  String _evaluateRelationshipType(List<DreamObject> objects) {
    int cozyCount = 0;
    int natureCount = 0;
    int dreamyCount = 0;

    for (final obj in objects) {
      final name = obj.name.toLowerCase();
      if (name.contains('candle') || name.contains('fireplace') || name.contains('book')) {
        cozyCount++;
      } else if (name.contains('plant') || name.contains('monstera') || name.contains('flower')) {
        natureCount++;
      } else if (name.contains('light') || name.contains('star') || name.contains('moon')) {
        dreamyCount++;
      }
    }

    if (cozyCount >= natureCount && cozyCount >= dreamyCount) {
      return 'Cozy Souls';
    } else if (natureCount >= cozyCount && natureCount >= dreamyCount) {
      return 'Calm Builders';
    } else if (dreamyCount >= cozyCount && dreamyCount >= natureCount) {
      return 'Soft Dreamers';
    } else {
      return 'Golden Hour Lovers';
    }
  }

  String _getRelationshipDescription(String badge) {
    switch (badge) {
      case 'Cozy Souls':
        return 'Your shared space is built on quiet comforts, rainy evenings, warm coffee, and fireplace moments. You find intimacy in calm retreats.';
      case 'Calm Builders':
        return 'You build together with steady care, houseplants, vinyl records, and growth. Your love grows naturally like a living home.';
      case 'Soft Dreamers':
        return 'You thrive under starlight, fairy lights, moon lit vulnerable chats, and celestial promises. Your future is a dreamy canvas.';
      default:
        return 'You spent 7 days finding beauty in daily golden hours and warm polaroids. Every moment feels like a warm snapshot.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(dreamHouseStateProvider);
    final size = MediaQuery.of(context).size;
    final relationshipBadge = _evaluateRelationshipType(gameState.placedObjects);

    return Scaffold(
      backgroundColor: const Color(0xFF060307),
      body: Stack(
        children: [
          // Dynamic Sunrise canvas backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _cinematicController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SunriseSkyPainter(
                    climaxProgress: _cinematicController.value,
                    stage: _climaxStage,
                    time: _audioWaveController.value,
                  ),
                );
              },
            ),
          ),

          // Widescreen ambient stardust
          Positioned.fill(
            child: _buildStardustParticles(size),
          ),

          // Main stage switcher
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Top header close button
                    Row(
                      children: [
                        const Text(
                          'CLIMAX WALKTHROUGH',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.8,
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
                            ),
                            child: const Icon(Icons.close, size: 14, color: Color(0xFFE8C5A0)),
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 900),
                        child: _buildStageContent(gameState, relationshipBadge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent(DreamHouseState state, String badge) {
    if (_climaxStage == 0) {
      // Stage 0: Pitch black / Narration build
      return Center(
        key: const ValueKey('stage0'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating music waveforms
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPianoWaveBar(1.0, 24),
                const SizedBox(width: 4),
                _buildPianoWaveBar(0.7, 16),
                const SizedBox(width: 4),
                _buildPianoWaveBar(0.9, 20),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Text(
                _narrationLines[_currentNarration],
                key: ValueKey(_currentNarration),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFE8C5A0),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_climaxStage == 1) {
      // Stage 1: Room sequence panning
      String roomName = 'Living Room';
      if (_activePanRoom == 1) roomName = 'Kitchen';
      else if (_activePanRoom == 2) roomName = 'Bedroom';
      else if (_activePanRoom == 3) roomName = 'Hobby Corner';
      else if (_activePanRoom == 4) roomName = 'Future Corner';

      // Find object for active room to show its note
      String targetRoom = 'living_room';
      if (_activePanRoom == 1) targetRoom = 'kitchen';
      else if (_activePanRoom == 2) targetRoom = 'bedroom';
      else if (_activePanRoom == 3) targetRoom = 'hobby_corner';
      else if (_activePanRoom == 4) targetRoom = 'future_corner';

      final roomObj = state.placedObjects.firstWhere(
        (o) => o.roomId == targetRoom, 
        orElse: () => DreamObject(
          id: 'mock', roomId: 'mock', name: 'Imagine Space', 
          icon: Icons.auto_awesome_outlined, type: 'decor', 
          addedBy: 'partner', emotionalMeaning: 'A quiet potential detail.', 
          timestamp: DateTime.now(), xPos: 0.5, yPos: 0.5,
        ),
      );

      return Center(
        key: const ValueKey('stage1'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Panning through the $roomName...',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xFF9E7E5A),
              ),
            ),
            const SizedBox(height: 28),

            // Active panned room canvas
            Container(
              height: 210,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(
                  painter: _ClimaxRoomPainter(
                    roomIndex: _activePanRoom,
                    time: _audioWaveController.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Floating handwritten paper note left in this room
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 18),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(roomObj.icon, size: 16, color: const Color(0xFF6E4555)),
                      const SizedBox(width: 8),
                      Text(
                        roomObj.name,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF3C232B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${roomObj.emotionalMeaning}”',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6E4555),
                      height: 1.45,
                    ),
                  ),
                  if (roomObj.reaction != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Reaction left: ',
                          style: TextStyle(fontSize: 10, color: Color(0xFF9E7E5A)),
                        ),
                        Text(
                          roomObj.reaction!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else if (_climaxStage == 2) {
      // Stage 2: Sunrise pay-off & relationship badge
      return Center(
        key: const ValueKey('stage2'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Glassmorphism personality card badge
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB366).withOpacity(0.06 + _badgeGlowController.value * 0.04),
                    blurRadius: 35,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Glowing crown of stardust
                  Icon(
                    Icons.auto_awesome,
                    size: 38,
                    color: const Color(0xFFFFD59A).withOpacity(0.7 + _badgeGlowController.value * 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'YOUR SOUL BADGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.2,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge title
                  Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFFE3C2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cozy description
                  Text(
                    _getRelationshipDescription(badge),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFFE8C5A0),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Text(
              'Not just a house. A feeling.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF9E7E5A),
              ),
            ),
            const SizedBox(height: 20),

            // Button to open Stage 3 Scrapbook memory journal
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _climaxStage = 3;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.03),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                    side: const BorderSide(color: Colors.white12, width: 1.2),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Open Memory Scrapbook Journal ✨',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFFFE3C2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      // Stage 3: Scrapbook Memory Journal list
      return Column(
        key: const ValueKey('stage3'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'OUR MEMORY SCRAPBOOK',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.8,
              color: Color(0xFF9E7E5A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Every trace we left behind.',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14.5,
              fontStyle: FontStyle.italic,
              color: Color(0xFFFFE3C2),
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable Scrapbook lists
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.placedObjects.length,
              itemBuilder: (context, idx) {
                final obj = state.placedObjects[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Cozy paper texture card backgrounds
                    color: const Color(0xFFF9F6F0).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E0E15).withOpacity(0.08),
                        ),
                        child: Icon(obj.icon, size: 20, color: const Color(0xFF6E4555)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              obj.name,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF3C232B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '“${obj.emotionalMeaning}”',
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF6E4555),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Left by ${obj.addedBy == 'me' ? 'you' : 'partner'}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: const Color(0xFF9E7E5A).withOpacity(0.8),
                                  ),
                                ),
                                if (obj.reaction != null) ...[
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6E4555).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('Reaction: ', style: TextStyle(fontSize: 8.5, color: Color(0xFF6E4555))),
                                        Text(obj.reaction!, style: const TextStyle(fontSize: 10.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Return back to climax card
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _climaxStage = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: Colors.white10, width: 1.2),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Return to Climax Card',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFFFE3C2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
  }

  Widget _buildPianoWaveBar(double mult, double maxH) {
    double scale = mult * (0.6 + 0.4 * math.sin(_audioWaveController.value * math.pi * 6 + maxH));
    return Container(
      width: 3,
      height: maxH * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB366).withOpacity(0.7),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildStardustParticles(Size size) {
    final rand = math.Random(999);
    final particles = <Widget>[];
    for (int i = 0; i < 22; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = rand.nextDouble() * math.pi * 2;
      final drift = math.sin(_audioWaveController.value * math.pi * 2 + phase) * 12;
      final opacity = (math.sin(_audioWaveController.value * math.pi * 2 + phase) * 0.15 + 0.22).clamp(0.0, 0.45);
      final s = rand.nextDouble() * 2 + 1;
      particles.add(Positioned(
        left: x, top: baseY + drift,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: s, height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE3C2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFE3C2).withOpacity(0.3), blurRadius: 4)],
            ),
          ),
        ),
      ));
    }
    return Stack(children: particles);
  }
}

class _SunriseSkyPainter extends CustomPainter {
  final double climaxProgress;
  final int stage;
  final double time;

  _SunriseSkyPainter({
    required this.climaxProgress,
    required this.stage,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Transition sky based on Stage and climax progress
    final Paint skyPaint = Paint();
    final rect = Offset.zero & size;

    if (stage == 0) {
      // Pitch black night
      skyPaint.shader = const LinearGradient(
        colors: [Color(0xFF0F060F), Color(0xFF060307)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (stage == 1) {
      // Panning twilight atmosphere
      skyPaint.shader = const LinearGradient(
        colors: [Color(0xFF1E0A1A), Color(0xFF0A030A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else {
      // Sunrise Climax payload (Stage 2 & 3)
      final Color topNight = Color.lerp(const Color(0xFF1E0A1A), const Color(0xFF381A2D), climaxProgress)!;
      final Color middleOrange = Color.lerp(const Color(0xFF0A030A), const Color(0xFF6E3E26), climaxProgress)!;
      final Color bottomGold = Color.lerp(Colors.transparent, const Color(0xFFFFB366).withOpacity(0.72), climaxProgress)!;

      skyPaint.shader = LinearGradient(
        colors: [topNight, middleOrange, bottomGold],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    }

    canvas.drawRect(rect, skyPaint);

    // Subtle sun flare rising from the bottom
    if (stage >= 2 && climaxProgress > 0.0) {
      final sunGlow = Paint()
        ..color = const Color(0xFFFFE3C2).withOpacity(0.24 * climaxProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
      canvas.drawCircle(Offset(w * 0.5, h * 0.95), 180 + climaxProgress * 80, sunGlow);
    }
  }

  @override
  bool shouldRepaint(_SunriseSkyPainter old) =>
      old.climaxProgress != climaxProgress || old.stage != stage || old.time != time;
}

class _ClimaxRoomPainter extends CustomPainter {
  final int roomIndex;
  final double time;

  _ClimaxRoomPainter({required this.roomIndex, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1. Cozy wall background gradient based on active room pan
    final bgPaint = Paint();
    if (roomIndex == 0) { // Living room fireplace terracotta
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF1E0E1B), Color(0xFF090309)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (roomIndex == 1) { // Kitchen morning sand
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF2B1C15), Color(0xFF0E0704)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (roomIndex == 2) { // Bedroom starry indigo
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF0D061C), Color(0xFF03010B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (roomIndex == 3) { // Hobby corner green monstera
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF0A1813), Color(0xFF020705)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else { // Sunset future ochre
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF261812), Color(0xFF090503)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    }
    canvas.drawRect(rect, bgPaint);

    // 2. Wooden floor at bottom 40%
    final floorY = h * 0.62;
    final floorPaint = Paint()..color = const Color(0xFF22110B); // warm walnut
    canvas.drawRect(Rect.fromLTRB(0, floorY, w, h), floorPaint);

    // Baseboard shadow accent line
    canvas.drawRect(Rect.fromLTRB(0, floorY - 3, w, floorY), Paint()..color = const Color(0xFF140704));

    // Wooden planks grain lines
    final woodLines = Paint()
      ..color = const Color(0xFF0D0503).withOpacity(0.35)
      ..strokeWidth = 1.0;
    for (double i = floorY + 12; i < h; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(w, i), woodLines);
    }

    // 3. Cozy circular squashed Rose Rug
    final rugPaint = Paint()..color = const Color(0xFF5A2A38); 
    final rugRect = Rect.fromLTRB(w * 0.20, h * 0.68, w * 0.80, h * 0.82);
    canvas.drawOval(rugRect, rugPaint);
    
    // Fringe circles
    final fringePaint = Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.3);
    for (int i = 0; i < 24; i++) {
      double angle = i * math.pi * 2 / 24;
      double rx = w * 0.50 + math.cos(angle) * (w * 0.30);
      double ry = h * 0.75 + math.sin(angle) * (h * 0.07);
      canvas.drawCircle(Offset(rx, ry), 1.0, fringePaint);
    }

    // 4. Plush Couch
    final couchBackPaint = Paint()..color = const Color(0xFF2F453B); // dark sage green
    final couchAccent = Paint()..color = const Color(0xFFD58C58); // warm ochre
    final couchAccentRose = Paint()..color = const Color(0xFFBA768A); // soft rose

    // Couch Backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.26, h * 0.50, w * 0.74, h * 0.68), const Radius.circular(14)),
      couchBackPaint,
    );

    // Left and right armrests
    canvas.drawCircle(Offset(w * 0.24, h * 0.65), 12, couchBackPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.65), 12, couchBackPaint);

    // Cushion
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.22, h * 0.60, w * 0.78, h * 0.70), const Radius.circular(8)),
      couchBackPaint,
    );

    // Cushions
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.32, h * 0.58, w * 0.42, h * 0.65), const Radius.circular(5)),
      couchAccent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.58, h * 0.58, w * 0.68, h * 0.65), const Radius.circular(5)),
      couchAccentRose,
    );

    // 5. Arched back window
    final winWidth = w * 0.28;
    final winHeight = h * 0.32;
    final winRect = Rect.fromLTWH(w * 0.36, h * 0.14, winWidth, winHeight);

    final framePaint = Paint()
      ..color = const Color(0xFFFFB366).withOpacity(0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(12)), framePaint);

    final skyPaint = Paint();
    if (roomIndex == 1) {
      skyPaint.color = const Color(0xFF3D2A1F); // morning warm beige
    } else if (roomIndex == 2) {
      skyPaint.color = const Color(0xFF03010B); // deep space
    } else {
      skyPaint.color = const Color(0xFF130A14); // twilight evening purple
    }
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(12)), skyPaint);

    // Wood pane lines
    canvas.drawLine(Offset(w * 0.50, h * 0.14), Offset(w * 0.50, h * 0.14 + winHeight), framePaint);
    canvas.drawLine(Offset(w * 0.36, h * 0.30), Offset(w * 0.36 + winWidth, h * 0.30), framePaint);

    // Soft curtains drapes
    final curtainPaint = Paint()..color = const Color(0xFF6E4555).withOpacity(0.35);
    double curtainSway = math.sin(time * math.pi * 2) * 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.36, h * 0.14, w * 0.42 + curtainSway, h * 0.14 + winHeight), const Radius.circular(4)),
      curtainPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.64 - curtainSway, h * 0.14, w * 0.64, h * 0.14 + winHeight), const Radius.circular(4)),
      curtainPaint,
    );

    // 6. Clay flower pot with Monstera (Left Corner Floor)
    final potX = w * 0.16;
    final potY = h * 0.70;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(potX - 7, potY, potX + 7, potY + 10), const Radius.circular(2)),
      Paint()..color = const Color(0xFF8E4E42),
    );
    final leafPaint = Paint()..color = const Color(0xFF1C3A2B);
    double plantSway = math.sin(time * math.pi * 2) * 0.08;
    canvas.save();
    canvas.translate(potX, potY);
    canvas.rotate(plantSway);
    canvas.drawOval(const Rect.fromLTWH(-12, -16, 8, 16), leafPaint);
    canvas.drawOval(const Rect.fromLTWH(3, -14, 10, 14), leafPaint);
    canvas.drawOval(const Rect.fromLTWH(-4, -20, 8, 18), leafPaint);
    canvas.restore();

    // 7. Right Corner Standing Brass Lamp & radial glow
    final lampX = w * 0.82;
    final lampY = h * 0.32;
    canvas.drawLine(Offset(lampX, lampY + 12), Offset(lampX, h * 0.75), Paint()..color = const Color(0xFF8E7158)..strokeWidth = 1.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(lampX, h * 0.75), width: 12, height: 3), Paint()..color = const Color(0xFF8E7158));
    final shadePath = Path()
      ..moveTo(lampX - 7, lampY + 12)
      ..lineTo(lampX + 7, lampY + 12)
      ..lineTo(lampX + 14, lampY + 22)
      ..lineTo(lampX - 14, lampY + 22)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = const Color(0xFFE8C5A0));

    double lampBreathe = 0.20 + 0.08 * math.sin(time * math.pi * 4);
    final lampGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD59A).withOpacity(lampBreathe), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(lampX, lampY + 18), radius: 80));
    canvas.drawCircle(Offset(lampX, lampY + 18), 80, lampGlowPaint);

    // 8. Room silhouetted overlays
    if (roomIndex == 0) { // Living Room Fireplace
      final fireX = w * 0.22;
      final fireY = h * 0.74;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fireX, fireY), width: 18, height: 6), const Radius.circular(2)),
        Paint()..color = const Color(0xFF140804),
      );
      double flameBreathe = 3.5 + 2.5 * math.sin(time * math.pi * 12);
      canvas.drawCircle(Offset(fireX, fireY - 2), flameBreathe, Paint()..color = const Color(0xFFFF4500));
      canvas.drawCircle(Offset(fireX, fireY - 2), flameBreathe * 0.7, Paint()..color = const Color(0xFFFFBB00));
    } else if (roomIndex == 1) { // Kitchen Table & Coffee Steam
      final tblX = w * 0.48;
      final tblY = h * 0.76;
      canvas.drawOval(Rect.fromCenter(center: Offset(tblX, tblY + 8), width: 36, height: 10), Paint()..color = const Color(0xFF381C15));
      canvas.drawLine(Offset(tblX - 12, tblY + 10), Offset(tblX - 12, tblY + 18), Paint()..color = const Color(0xFF26100C)..strokeWidth = 2.0);
      canvas.drawLine(Offset(tblX + 12, tblY + 10), Offset(tblX + 12, tblY + 18), Paint()..color = const Color(0xFF26100C)..strokeWidth = 2.0);

      // Cup of coffee
      canvas.drawRect(Rect.fromLTWH(tblX - 4, tblY, 8, 6), Paint()..color = const Color(0xFFF9F6F0));
      final steamPaint = Paint()
        ..color = const Color(0xFFFFE3C2).withOpacity(0.20)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 2; i++) {
        double sx = tblX - 2.0 + i * 4;
        double sy = tblY - 3 - (time * 10 % 10);
        double dev = math.sin(time * math.pi * 4 + i) * 1.2;
        canvas.drawLine(Offset(sx, tblY - 1), Offset(sx + dev, sy), steamPaint);
      }
    } else if (roomIndex == 2) { // Bedroom Starfield & Fairy Lights
      final starPaint = Paint()..color = const Color(0xFFFFE3C2);
      final rand = math.Random(999);
      for (int i = 0; i < 8; i++) {
        double sx = winRect.left + rand.nextDouble() * winRect.width;
        double sy = winRect.top + rand.nextDouble() * winRect.height;
        double blink = 0.2 + 0.8 * math.sin(time * math.pi * 4 + i);
        canvas.drawCircle(Offset(sx, sy), 0.6, starPaint..color = const Color(0xFFFFE3C2).withOpacity(blink.clamp(0.0, 1.0)));
      }

      final wirePaint = Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.18)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      final swoop = Path()
        ..moveTo(w * 0.15, h * 0.14)
        ..quadraticBezierTo(w * 0.5, h * 0.22, w * 0.85, h * 0.14);
      canvas.drawPath(swoop, wirePaint);

      for (int i = 0; i <= 5; i++) {
        double t = i / 5.0;
        double lx = (1 - t) * (1 - t) * (w * 0.15) + 2 * (1 - t) * t * (w * 0.5) + t * t * (w * 0.85);
        double ly = (1 - t) * (1 - t) * (h * 0.14) + 2 * (1 - t) * t * (h * 0.22) + t * t * (h * 0.14);
        
        double intensity = 0.35 + 0.65 * math.sin(time * math.pi * 6 + i);
        canvas.drawCircle(Offset(lx, ly), 1.2, Paint()..color = const Color(0xFFFFD59A).withOpacity(intensity.clamp(0.0, 1.0)));
      }
    } else if (roomIndex == 3) { // Hobby Turntable Cabinet
      final ttX = w * 0.78;
      final ttY = h * 0.58;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(ttX - 18, ttY, 36, 14), const Radius.circular(2)),
        Paint()..color = const Color(0xFF1E0E1B),
      );
      canvas.drawCircle(Offset(ttX, ttY + 3), 7, Paint()..color = const Color(0xFF0C070C));
      double recordSpin = time * math.pi * 8;
      canvas.drawLine(
        Offset(ttX, ttY + 4),
        Offset(ttX + math.cos(recordSpin) * 6, ttY + 4 + math.sin(recordSpin) * 6),
        Paint()..color = const Color(0xFFFFB366).withOpacity(0.4),
      );
    } else if (roomIndex == 4) { // Future Clothesline Hanging
      final wirePaint = Paint()..color = const Color(0xFFFFB366).withOpacity(0.15);
      canvas.drawLine(Offset(w * 0.15, h * 0.24), Offset(w * 0.85, h * 0.24), wirePaint);
      for (int i = 0; i < 3; i++) {
        double px = w * 0.24 + i * w * 0.22;
        double py = h * 0.26 + math.sin(time * math.pi * 2 + i) * 1.2;
        canvas.drawRect(Rect.fromLTWH(px, py, 14, 20), Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.8));
        canvas.drawRect(Rect.fromLTWH(px + 2, py + 2, 10, 12), Paint()..color = const Color(0xFF0F0810));
      }
    }
  }

  @override
  bool shouldRepaint(_ClimaxRoomPainter old) =>
      old.roomIndex != roomIndex || old.time != time;
}
