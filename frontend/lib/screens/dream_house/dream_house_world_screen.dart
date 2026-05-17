import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dream_house_providers.dart';
import 'dream_house_bottom_sheet.dart';
import 'dream_house_cinematic_reveal_screen.dart';

class DreamHouseWorldScreen extends ConsumerStatefulWidget {
  const DreamHouseWorldScreen({super.key});

  @override
  ConsumerState<DreamHouseWorldScreen> createState() => _DreamHouseWorldScreenState();
}

class _DreamHouseWorldScreenState extends ConsumerState<DreamHouseWorldScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _roomCycleController;
  late AnimationController _noteUnfoldController;
  late AnimationController _particleController;

  // Reveal screen state
  DreamObject? _revealObject;
  bool _isUnfolding = false;
  String? _selectedReaction;
  
  // Custom reaction burst particles
  final List<_BurstParticle> _burstParticles = [];
  late AnimationController _burstController;

  @override
  void initState() {
    super.initState();

    // Loop for ambient elements (clouds, fireplaces, coffee steam, fairy lights)
    _roomCycleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // 1-second delay notes unfolding controller
    _noteUnfoldController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // General particle floater
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Reaction burst controller
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _burstController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _roomCycleController.dispose();
    _noteUnfoldController.dispose();
    _particleController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _triggerBurst(Offset origin, String emoji) {
    _burstParticles.clear();
    final rand = math.Random();
    for (int i = 0; i < 18; i++) {
      double angle = rand.nextDouble() * math.pi * 2;
      double speed = 40 + rand.nextDouble() * 90;
      _burstParticles.add(_BurstParticle(
        emoji: emoji,
        xDir: math.cos(angle) * speed,
        yDir: math.sin(angle) * speed - 30, // upward bias
        origin: origin,
        rotation: rand.nextDouble() * math.pi,
        scale: 0.5 + rand.nextDouble() * 0.8,
      ));
    }
    _burstController.forward(from: 0.0);
  }

  void _openNoteReveal(DreamObject obj) {
    setState(() {
      _revealObject = obj;
      _isUnfolding = true;
      _selectedReaction = obj.reaction;
    });

    _noteUnfoldController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isUnfolding = false;
        });
      }
    });
  }

  void _submitReaction(String emoji) {
    if (_revealObject == null) return;
    
    setState(() {
      _selectedReaction = emoji;
    });

    // Burst particles originating from tapped emoji
    _triggerBurst(const Offset(0, 80), emoji);

    // Save reaction to global state
    ref.read(dreamHouseStateProvider.notifier).addReactionToObject(_revealObject!.id, emoji);

    // After 1.2s delay, close overlay and advance turn
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        setState(() {
          _revealObject = null;
        });
        // If partner discovered, acknowledge it
        final gameState = ref.read(dreamHouseStateProvider);
        if (gameState.step == 'discover') {
          ref.read(dreamHouseStateProvider.notifier).acknowledgeDiscovery();
        }
      }
    });
  }

  void _showDecorTray() {
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DreamHouseBottomSheet(),
    ).then((result) {
      if (result != null && mounted) {
        final gameState = ref.read(dreamHouseStateProvider);
        String currentRoom = 'living_room';
        if (gameState.day == 3) currentRoom = 'kitchen';
        else if (gameState.day == 4) currentRoom = 'bedroom';
        else if (gameState.day == 5) currentRoom = 'hobby_corner';
        else if (gameState.day == 6) currentRoom = 'future_corner';

        ref.read(dreamHouseStateProvider.notifier).placeObject(
          result['name'] as String,
          result['icon'] as IconData,
          result['meaning'] as String,
          currentRoom,
          customAmbience: result['ambience'] as String?,
        );
      }
    });
  }

  // ── PRETTIEST GROUNDING POSITION LOGIC ──
  Offset _getGroundedPosition(DreamObject obj, Size size) {
    final w = size.width - 48; // accounting for horizontal page padding
    final h = (size.height * 0.55) - 16; // approximate room illustrator height bounds

    final name = obj.name.toLowerCase();
    
    // Low jitter so multiple additions don't overlap perfectly
    final jitterX = (obj.xPos - 0.5) * 32;
    final jitterY = (obj.yPos - 0.5) * 16;

    if (name.contains('lights') || name.contains('lamp') || name.contains('fairy')) {
      // Swung overhead the arched window
      return Offset(w * 0.48 + jitterX, h * 0.14);
    } else if (name.contains('plant') || name.contains('monstera') || name.contains('flower')) {
      // Nestles beautifully in the right floor corner
      return Offset(w * 0.78 + jitterX, h * 0.72);
    } else if (name.contains('coffee') || name.contains('table') || name.contains('mug')) {
      // Restful directly on the central coffee table
      return Offset(w * 0.48 + jitterX, h * 0.76);
    } else if (name.contains('player') || name.contains('record') || name.contains('vinyl')) {
      // Rests on the Ghibli record sideboard
      return Offset(w * 0.78 + jitterX, h * 0.58);
    } else if (name.contains('bookshelf') || name.contains('book') || name.contains('shelf')) {
      // Placed on the left wooden wall shelf
      return Offset(w * 0.18 + jitterX, h * 0.42);
    } else if (name.contains('fireplace') || name.contains('log') || name.contains('candle')) {
      // Grounded center-left near the window drape
      return Offset(w * 0.24 + jitterX, h * 0.74);
    } else if (name.contains('cushion') || name.contains('cuddly') || name.contains('pillow') || name.contains('couch') || name.contains('armchair')) {
      // Tucked exactly inside the cushions of the plush sofa!
      return Offset(w * 0.42 + jitterX, h * 0.62);
    } else if (name.contains('polaroid') || name.contains('photo') || name.contains('wall')) {
      // Pinched on the Polaroid wire top right
      return Offset(w * 0.74 + jitterX, h * 0.26);
    } else {
      // Cozily distributed floor and shelf bounds
      return Offset(
        w * 0.18 + obj.xPos * w * 0.64 + jitterX,
        h * 0.45 + obj.yPos * h * 0.32 + jitterY,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(dreamHouseStateProvider);
    final size = MediaQuery.of(context).size;

    // Filter placed objects for the active room theme
    String activeRoomId = 'living_room';
    if (gameState.day == 3) activeRoomId = 'kitchen';
    else if (gameState.day == 4) activeRoomId = 'bedroom';
    else if (gameState.day == 5) activeRoomId = 'hobby_corner';
    else if (gameState.day == 6) activeRoomId = 'future_corner';

    final roomObjects = gameState.placedObjects.where((o) => o.roomId == activeRoomId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060307),
      body: Stack(
        children: [
          // Atmosphere background particles
          Positioned.fill(
            child: CustomPaint(
              painter: _HubParticlesPainter(time: _particleController.value),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header back navigation & breathing soundvisualizer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFFE8C5A0)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OUR COZY SHELTER',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.8,
                              color: Color(0xFF9E7E5A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            gameState.step == 'final_reveal' ? 'Not just a house. A feeling.' : 'Async love space ✨',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFFFE3C2),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Breathing sound wave visualizer
                      Row(
                        children: [
                          _buildSoundBar(0.9, 14),
                          const SizedBox(width: 2.5),
                          _buildSoundBar(0.6, 10),
                          const SizedBox(width: 2.5),
                          _buildSoundBar(0.8, 12),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Area Timeline Progression
                _buildTimeline(gameState.day),

                // Center Hero Cozy Room Stage (Takes 70%+ of screen area)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Central Ghibli-Style Cozy Room Custom Painter
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CustomPaint(
                              painter: _CozyRoomPainter(
                                day: gameState.day,
                                time: _roomCycleController.value,
                                objects: roomObjects,
                              ),
                            ),
                          ),
                        ),

                        // Grounded placed object highlights inside coordinates
                        ...roomObjects.map((obj) {
                          final isUnreadPartner = gameState.step == 'discover' && 
                                                 gameState.latestDiscoveredObject?.id == obj.id;
                          final pos = _getGroundedPosition(obj, size);
                          
                          return Positioned(
                            left: pos.dx,
                            top: pos.dy,
                            child: _buildPlacedItemHotspot(obj, isUnreadPartner),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom Panel Control Area
                _buildBottomControlsPanel(gameState),
              ],
            ),
          ),

          // ── SCREEN 3: NOTE REVEAL OVERLAY SCREEN ──
          if (_revealObject != null)
            _buildNoteRevealOverlay(size),
        ],
      ),
    );
  }

  // Timeline Progress builder
  Widget _buildTimeline(int currentDay) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final dayNum = index + 1;
            final isActive = dayNum == currentDay;
            final isPassed = dayNum < currentDay;

            Color textColor = const Color(0xFF6E4555);
            if (isActive) textColor = const Color(0xFFFFB366);
            else if (isPassed) textColor = const Color(0xFFE8C5A0).withOpacity(0.5);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFFFB366).withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? const Color(0xFFFFB366).withOpacity(0.24) : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'Day $dayNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                      letterSpacing: 0.5,
                      shadows: isActive ? [
                        BoxShadow(
                          color: const Color(0xFFFFB366).withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ] : null,
                    ),
                  ),
                ),
                if (index < 6)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '•',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF4A2535).withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Breathing Soundbar helper
  Widget _buildSoundBar(double mult, double base) {
    double scale = mult * (0.55 + 0.45 * math.sin(_particleController.value * math.pi * 6 + base));
    return Container(
      width: 2.2,
      height: base * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB366).withOpacity(0.7),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // Placed Object Hotspot builder
  Widget _buildPlacedItemHotspot(DreamObject obj, bool isUnreadPartner) {
    return GestureDetector(
      onTap: () => _openNoteReveal(obj),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Pulse halo if partner object is unread - upgraded to MAGICAL GOLDEN SHADOWS
          if (isUnreadPartner)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, val, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD59A).withOpacity(0.42 * (1.0 - val)),
                            blurRadius: 16,
                            spreadRadius: 12 * val,
                          ),
                        ],
                      ),
                    ),
                    // Floating golden orbit sparkles surrounding the item
                    ...List.generate(4, (index) {
                      double angle = (val * math.pi * 2) + (index * math.pi / 2);
                      double radius = 24.0 * val;
                      return Positioned(
                        left: 20 + math.cos(angle) * radius,
                        top: 20 + math.sin(angle) * radius,
                        child: Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFD59A),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

          // Core circular item button
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E0E15),
              border: Border.all(
                color: isUnreadPartner 
                    ? const Color(0xFFFFD59A) 
                    : const Color(0xFFFFB366).withOpacity(0.4),
                width: isUnreadPartner ? 1.8 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD59A).withOpacity(0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              obj.icon,
              size: 16,
              color: isUnreadPartner ? const Color(0xFFFFD59A) : const Color(0xFFFFE3C2),
            ),
          ),

          // Float partner bubble
          if (isUnreadPartner)
            Positioned(
              top: -30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0810),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD59A).withOpacity(0.42), width: 0.8),
                ),
                child: const Text(
                  'Your person left something... ✨',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFFFD59A),
                  ),
                ),
              ),
            ),

          // Small floating emoji reaction if set
          if (obj.reaction != null)
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E0E15),
                  border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.2), width: 0.8),
                ),
                child: Text(
                  obj.reaction!,
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Note Reveal Screen modal layout
  Widget _buildNoteRevealOverlay(Size size) {
    final revealVal = _noteUnfoldController.value;
    final isDoneUnfolding = !_isUnfolding;

    // Simulated folded paper scale visual
    double noteScale = 0.85 + (revealVal * 0.15);
    double noteRotation = (1.0 - revealVal) * 0.12;

    return Stack(
      children: [
        // Cozy blur background
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (isDoneUnfolding) {
                setState(() => _revealObject = null);
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.68),
            ),
          ),
        ),

        // Unfolding paper container
        Center(
          child: ScaleTransition(
            scale: _noteUnfoldController,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(noteRotation),
              child: Container(
                width: size.width * 0.82,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  // Handwritten note paper texture visual
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFB366).withOpacity(0.1),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spark icon header
                    Icon(
                      _revealObject!.icon,
                      size: 26,
                      color: const Color(0xFF6E4555),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      _revealObject!.name,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF3C232B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Georgia Italic Handwritten reflection
                    Container(
                      constraints: const BoxConstraints(maxHeight: 110),
                      child: SingleChildScrollView(
                        child: Text(
                          '“${_revealObject!.emotionalMeaning}”',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15.5,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF6E4555),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Faded timestamp
                    Text(
                      "${_revealObject!.timestamp.hour.toString().padLeft(2, '0')}:${_revealObject!.timestamp.minute.toString().padLeft(2, '0')} • ${_revealObject!.addedBy == 'me' ? 'Written by you' : 'Written by your partner'}",
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF9E7E5A).withOpacity(0.7),
                      ),
                    ),

                    const Divider(height: 32, color: Color(0xFFE8C5A0), thickness: 0.8),

                    // Reactions row (♡ ✨ ☾ 🌸)
                    const Text(
                      'Let them feel understood... 👇',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E7E5A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['♡', '✨', '☾', '🌸'].map((emoji) {
                        final isSel = _selectedReaction == emoji;
                        return GestureDetector(
                          onTap: () => _submitReaction(emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF6E4555).withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSel ? const Color(0xFF6E4555).withOpacity(0.4) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle(
                                fontSize: 24,
                                color: isSel ? const Color(0xFF6E4555) : const Color(0xFF9E7E5A).withOpacity(0.7),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Reaction sparks canvas layer
        if (_burstController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BurstParticlesPainter(
                  particles: _burstParticles,
                  progress: _burstController.value,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Daily task cards & Submit lock screens bottom panel
  Widget _buildBottomControlsPanel(DreamHouseState state) {
    if (state.step == 'final_reveal') {
      // Climax Final sunrise reveal
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E1B).withOpacity(0.4),
          border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.08), width: 1.2),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const Text(
              'A feeling is complete. Not just a house.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFFE8C5A0),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 1400),
                      pageBuilder: (_, __, ___) => const DreamHouseCinematicRevealScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB366).withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                    side: const BorderSide(color: Color(0xFFFFB366), width: 1.2),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Step into the Sunrise Climax ✨',
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
          ],
        ),
      );
    } else if (state.step == 'passed') {
      // SCREEN 7: Submit Lock Screen
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E).withOpacity(0.5),
          border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.05), width: 1.2),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Today’s little moment is complete.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFFE8C5A0),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tomorrow, your home grows again.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF9E7E5A),
              ),
            ),
            const SizedBox(height: 16),

            // Simulated Lock screen countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nights_stay, size: 14, color: Color(0xFFFFB366)),
                const SizedBox(width: 8),
                Text(
                  'Next moment unlocks in 18h 12m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB366).withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Celestial Developer Fast-forward button
            GestureDetector(
              onTap: () {
                ref.read(dreamHouseStateProvider.notifier).simulatePartnerAction();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Simulated: Your person added their beautiful piece! 💌',
                      style: TextStyle(fontFamily: 'Georgia', fontStyle: FontStyle.italic),
                    ),
                    backgroundColor: const Color(0xFFD4864A).withOpacity(0.8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.18)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fast_forward, size: 12, color: Color(0xFFFFB366)),
                    const SizedBox(width: 8),
                    Text(
                      'Simulate Partner Action ☾',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB366),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state.step == 'discover') {
      // Reveal state waiting
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E1B).withOpacity(0.35),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const Text(
              'Your partner left a warm trace...',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFFFFE3C2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap their pulsing item in the room to reveal their note 🎁',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9E7E5A),
              ),
            ),
          ],
        ),
      );
    }

    // Default 'play' step: Screen 4 Daily Task Card
    String taskTitle = 'Choose a Warm Corner 🛋️';
    String taskPrompt = 'Select something that brings cozy warmth to your beginnings outline.';

    if (state.day == 2) {
      taskTitle = 'Comfort Fireplace ☕';
      taskPrompt = 'Add something cozy beside our fireplace for rainy evenings.';
    } else if (state.day == 3) {
      taskTitle = 'Care Morning Sunlight 🥞';
      taskPrompt = 'Place a quiet care detail in our kitchen for sunrise breakfasts.';
    } else if (state.day == 4) {
      taskTitle = 'Starry Intimacy fairy lights 🌌';
      taskPrompt = 'Select a tiny item for starry vulnerability night-chats.';
    } else if (state.day == 5) {
      taskTitle = 'Spinning Growth corner 🌱';
      taskPrompt = 'Add a moving growth piece that sway-grows as we dream.';
    } else if (state.day == 6) {
      taskTitle = 'Floating Future Polaroid 🗺️';
      taskPrompt = 'Leave a tiny dream artifact for our travels together.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E1B).withOpacity(0.45),
        border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.08), width: 1.2),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                taskTitle,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFFFE3C2),
                ),
              ),
              const Spacer(),
              const Text(
                'Today\'s prompt',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: Color(0xFF9E7E5A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            taskPrompt,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF9E7E5A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Translucent Moonlight CTA Card Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _showDecorTray,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: Colors.white12, width: 1.2),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Leave today\'s little piece',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFFFE3C2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTERS ──

class _HubParticlesPainter extends CustomPainter {
  final double time;
  _HubParticlesPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Atmospheric dark gradient backdrop
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F060F), Color(0xFF060307)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final rand = math.Random(123);
    final paint = Paint();
    for (int i = 0; i < 15; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final blink = 0.2 + 0.8 * math.sin(time * math.pi * 2 + i);
      paint.color = const Color(0xFFFFB366).withOpacity(blink.clamp(0.0, 0.4));
      canvas.drawCircle(Offset(x, y), 0.8 + rand.nextDouble() * 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(_HubParticlesPainter old) => old.time != time;
}

// ── GHIBLI/PINTEREST INSPIRED PROCEDURAL COZY ROOM ILLUSTRATOR ──
class _CozyRoomPainter extends CustomPainter {
  final int day;
  final double time;
  final List<DreamObject> objects;

  _CozyRoomPainter({
    required this.day,
    required this.time,
    required this.objects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1. Cozy wall background gradient based on active day/feeling
    final bgPaint = Paint();
    if (day == 1) { // Deep beginnings twilight
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF0F1524), Color(0xFF050810)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (day == 2) { // Living room fireplace terracotta
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF1E0E1B), Color(0xFF090309)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (day == 3) { // Sunny kitchen sand
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF2B1C15), Color(0xFF0E0704)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (day == 4) { // Bedroom starry indigo
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF0D061C), Color(0xFF03010B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else if (day == 5) { // Hobby corner green monstera
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF0A1813), Color(0xFF020705)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    } else { // Travel snaps sunset ochre
      bgPaint.shader = const LinearGradient(
        colors: [Color(0xFF261812), Color(0xFF090503)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), bgPaint);

    // 2. High-fidelity Cozy wooden floor at bottom 40%
    final floorY = h * 0.62;
    final floorPaint = Paint()..color = const Color(0xFF22110B); // warm walnut mahogany
    canvas.drawRect(Rect.fromLTRB(0, floorY, w, h), floorPaint);

    // Baseboard shadow accent line
    canvas.drawRect(Rect.fromLTRB(0, floorY - 3, w, floorY), Paint()..color = const Color(0xFF140704));

    // Wooden planks grain lines
    final woodLines = Paint()
      ..color = const Color(0xFF0D0503).withOpacity(0.35)
      ..strokeWidth = 1.0;
    for (double i = floorY + 14; i < h; i += 22) {
      canvas.drawLine(Offset(0, i), Offset(w, i), woodLines);
    }

    // 3. Cozy circular plush Squashed Rose Rug (in lower center)
    final rugPaint = Paint()..color = const Color(0xFF5A2A38); // rich dusty burgundy rose
    final rugRect = Rect.fromLTRB(w * 0.20, h * 0.68, w * 0.80, h * 0.82);
    canvas.drawOval(rugRect, rugPaint);
    
    // Tiny rug border fringe circles
    final fringePaint = Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.3);
    for (int i = 0; i < 30; i++) {
      double angle = i * math.pi * 2 / 30;
      double rx = w * 0.50 + math.cos(angle) * (w * 0.30);
      double ry = h * 0.75 + math.sin(angle) * (h * 0.07);
      canvas.drawCircle(Offset(rx, ry), 1.2, fringePaint);
    }

    // 4. Plush Rounded Ghibli double-seat Sofa (couch) sitting in room center
    final couchBackPaint = Paint()..color = const Color(0xFF2F453B); // cozy dark sage green Ghibli feel
    final couchAccent = Paint()..color = const Color(0xFFD58C58); // warm cushion terracotta
    final couchAccentRose = Paint()..color = const Color(0xFFBA768A); // soft rose cushion

    // Couch Backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.26, h * 0.50, w * 0.74, h * 0.68), const Radius.circular(16)),
      couchBackPaint,
    );

    // Left round couch armrest
    canvas.drawCircle(Offset(w * 0.24, h * 0.65), 14, couchBackPaint);
    // Right round couch armrest
    canvas.drawCircle(Offset(w * 0.76, h * 0.65), 14, couchBackPaint);

    // Couch seat cushion
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.22, h * 0.60, w * 0.78, h * 0.70), const Radius.circular(10)),
      couchBackPaint,
    );

    // Throw pillows sitting in sofa center
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.32, h * 0.58, w * 0.42, h * 0.65), const Radius.circular(6)),
      couchAccent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.58, h * 0.58, w * 0.68, h * 0.65), const Radius.circular(6)),
      couchAccentRose,
    );

    // 5. Large arched back window (always visible to establish cozy illustrated boundaries)
    final winWidth = w * 0.28;
    final winHeight = h * 0.32;
    final winRect = Rect.fromLTWH(w * 0.36, h * 0.14, winWidth, winHeight);

    // Double frame outline
    final framePaint = Paint()
      ..color = const Color(0xFFFFB366).withOpacity(0.12)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(14)), framePaint);

    // Window back fill showing active day themes
    final skyPaint = Paint();
    if (day == 3) {
      skyPaint.color = const Color(0xFF3D2A1F); // morning warm beige
    } else if (day == 4) {
      skyPaint.color = const Color(0xFF03010B); // deep bedroom space
    } else {
      skyPaint.color = const Color(0xFF130A14); // twilight evening purple
    }
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(14)), skyPaint);

    // Cross pane wood grid lines
    canvas.drawLine(Offset(w * 0.50, h * 0.14), Offset(w * 0.50, h * 0.14 + winHeight), framePaint);
    canvas.drawLine(Offset(w * 0.36, h * 0.30), Offset(w * 0.36 + winWidth, h * 0.30), framePaint);

    // Swaying soft translucent curtains drapes
    final curtainPaint = Paint()..color = const Color(0xFF6E4555).withOpacity(0.38);
    double curtainSway = math.sin(time * math.pi * 2) * 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.36, h * 0.14, w * 0.42 + curtainSway, h * 0.14 + winHeight), const Radius.circular(4)),
      curtainPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.64 - curtainSway, h * 0.14, w * 0.64, h * 0.14 + winHeight), const Radius.circular(4)),
      curtainPaint,
    );

    // 6. Clay flower pot with green Monsteras (Left Corner Floor)
    final potX = w * 0.16;
    final potY = h * 0.70;
    final clayPaint = Paint()..color = const Color(0xFF8E4E42); // soft terracotta Ghibli pot
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(potX - 8, potY, potX + 8, potY + 12), const Radius.circular(2)),
      clayPaint,
    );
    
    // Swaying Ghibli leaves
    final leafPaint = Paint()..color = const Color(0xFF1C3A2B); // rich organic sage green
    double plantSway = math.sin(time * math.pi * 2) * 0.08;
    canvas.save();
    canvas.translate(potX, potY);
    canvas.rotate(plantSway);
    canvas.drawOval(const Rect.fromLTWH(-14, -18, 10, 18), leafPaint);
    canvas.drawOval(const Rect.fromLTWH(4, -16, 12, 16), leafPaint);
    canvas.drawOval(const Rect.fromLTWH(-5, -24, 10, 22), leafPaint);
    canvas.restore();

    // 7. Right Corner Standing Brass Lamp (with massive breathing yellow radial halo)
    final lampX = w * 0.82;
    final lampY = h * 0.32;
    final polePaint = Paint()..color = const Color(0xFF8E7158)..strokeWidth = 1.8;
    // Pole extending down to wood floor
    canvas.drawLine(Offset(lampX, lampY + 12), Offset(lampX, h * 0.75), polePaint);
    // Base footprint on floor
    canvas.drawOval(Rect.fromCenter(center: Offset(lampX, h * 0.75), width: 14, height: 4), polePaint);
    // Cute trapezoid Ghibli lamp shade
    final shadePath = Path()
      ..moveTo(lampX - 8, lampY + 12)
      ..lineTo(lampX + 8, lampY + 12)
      ..lineTo(lampX + 16, lampY + 24)
      ..lineTo(lampX - 16, lampY + 24)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = const Color(0xFFE8C5A0));

    // Breathing warm lamp radial glow
    double lampBreathe = 0.22 + 0.08 * math.sin(time * math.pi * 4);
    final lampGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFD59A).withOpacity(lampBreathe), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(lampX, lampY + 18), radius: 95));
    canvas.drawCircle(Offset(lampX, lampY + 18), 95, lampGlowPaint);

    // ── 8. ACTIVE THEMATIC DAILY ATMOSPHERE OVERLAYS ──
    if (day == 1) {
      // Blueprint draft grid lines (Empty beginnings indicator)
      final bluePaint = Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.04)
        ..strokeWidth = 0.8;
      for (double i = 0; i < w; i += 20) {
        canvas.drawLine(Offset(i, 0), Offset(i, h), bluePaint);
      }
    } else if (day == 2) {
      // Comfort window diagonal sliding rain
      final rainPaint = Paint()
        ..color = const Color(0xFFFFD59A).withOpacity(0.12)
        ..strokeWidth = 1.0;
      final rand = math.Random(1234);
      for (int i = 0; i < 8; i++) {
        double rx = winRect.left + rand.nextDouble() * (winRect.width);
        double ry = winRect.top + ((rand.nextDouble() + time * 1.5) % 1.0) * (winRect.height);
        canvas.drawLine(Offset(rx, ry), Offset(rx - 2.5, ry + 5), rainPaint);
      }

      // Red-hot fireplace logs glowing on center-left floor
      final fireX = w * 0.22;
      final fireY = h * 0.74;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(fireX, fireY), width: 22, height: 8), const Radius.circular(2)),
        Paint()..color = const Color(0xFF140804),
      );
      double flameBreathe = 4.0 + 3.0 * math.sin(time * math.pi * 12);
      canvas.drawCircle(Offset(fireX, fireY - 2), flameBreathe, Paint()..color = const Color(0xFFFF4500));
      canvas.drawCircle(Offset(fireX, fireY - 2), flameBreathe * 0.7, Paint()..color = const Color(0xFFFFBB00));

    } else if (day == 3) {
      // Morning golden sunlight shafts diagonal beaming
      final sunPaint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFFD59A).withOpacity(0.08), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      final sunPath = Path()
        ..moveTo(w * 0.38, h * 0.14)
        ..lineTo(w * 0.78, h * 0.85)
        ..lineTo(w * 0.52, h * 0.85)
        ..lineTo(w * 0.22, h * 0.14)
        ..close();
      canvas.drawPath(sunPath, sunPaint);

      // Coffee table & hot steaming coffee mug resting in front of sofa
      final tblX = w * 0.48;
      final tblY = h * 0.76;
      // Round wooden coffee table
      canvas.drawOval(Rect.fromCenter(center: Offset(tblX, tblY + 8), width: 44, height: 12), Paint()..color = const Color(0xFF381C15));
      canvas.drawLine(Offset(tblX - 16, tblY + 12), Offset(tblX - 16, tblY + 20), Paint()..color = const Color(0xFF26100C)..strokeWidth = 2.5);
      canvas.drawLine(Offset(tblX + 16, tblY + 12), Offset(tblX + 16, tblY + 20), Paint()..color = const Color(0xFF26100C)..strokeWidth = 2.5);

      // Tiny cup of coffee
      canvas.drawRect(Rect.fromLTWH(tblX - 5, tblY, 10, 8), Paint()..color = const Color(0xFFF9F6F0));
      // Steam
      final steamPaint = Paint()
        ..color = const Color(0xFFFFE3C2).withOpacity(0.24)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 2; i++) {
        double sx = tblX - 2.5 + i * 5;
        double sy = tblY - 4 - (time * 12 % 12);
        double dev = math.sin(time * math.pi * 4 + i) * 1.5;
        canvas.drawLine(Offset(sx, tblY - 1), Offset(sx + dev, sy), steamPaint);
      }

    } else if (day == 4) {
      // Bedroom starry galaxy background inside the arched window frame
      final starPaint = Paint()..color = const Color(0xFFFFE3C2);
      final rand = math.Random(888);
      for (int i = 0; i < 10; i++) {
        double sx = winRect.left + rand.nextDouble() * winRect.width;
        double sy = winRect.top + rand.nextDouble() * winRect.height;
        double blink = 0.2 + 0.8 * math.sin(time * math.pi * 5 + i);
        canvas.drawCircle(Offset(sx, sy), 0.7, starPaint..color = const Color(0xFFFFE3C2).withOpacity(blink.clamp(0.0, 1.0)));
      }

      // Fairy light bulb swoop swooping on top wall
      final wirePaint = Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.2)
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
        canvas.drawCircle(Offset(lx, ly), 1.5, Paint()..color = const Color(0xFFFFD59A).withOpacity(intensity.clamp(0.0, 1.0)));
      }

    } else if (day == 5) {
      // Spinning record turntable console sideboard on right floor corner
      final ttX = w * 0.78;
      final ttY = h * 0.58;
      
      // Sideboard cabinet box
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(ttX - 22, ttY, 44, 16), const Radius.circular(2)),
        Paint()..color = const Color(0xFF1E0E1B),
      );
      
      // Record plate disk spinning
      canvas.drawCircle(Offset(ttX, ttY + 4), 9, Paint()..color = const Color(0xFF0C070C));
      canvas.drawCircle(Offset(ttX, ttY + 4), 5, Paint()..color = const Color(0xFFFFB366).withOpacity(0.2));
      
      double recordSpin = time * math.pi * 8;
      canvas.drawLine(
        Offset(ttX, ttY + 4),
        Offset(ttX + math.cos(recordSpin) * 8, ttY + 4 + math.sin(recordSpin) * 8),
        Paint()..color = const Color(0xFFFFB366).withOpacity(0.4),
      );

    } else if (day == 6) {
      // Polaroid clothesline hanging wall snaps
      final wirePaint = Paint()
        ..color = const Color(0xFFFFB366).withOpacity(0.18)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(w * 0.15, h * 0.24), Offset(w * 0.85, h * 0.24), wirePaint);

      for (int i = 0; i < 3; i++) {
        double px = w * 0.24 + i * w * 0.22;
        double py = h * 0.26 + math.sin(time * math.pi * 2 + i) * 1.5;
        // Polaroid paper background
        canvas.drawRect(Rect.fromLTWH(px, py, 18, 24), Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.85));
        // Miniature snapshot inner box
        canvas.drawRect(Rect.fromLTWH(px + 2, py + 2, 14, 14), Paint()..color = const Color(0xFF0F0810));
      }
    }
  }

  @override
  bool shouldRepaint(_CozyRoomPainter old) =>
      old.day != day || old.time != time || old.objects != objects;
}

class _BurstParticlesPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final double progress;

  _BurstParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (final p in particles) {
      double curX = p.origin.dx + (p.xDir * progress);
      double curY = p.origin.dy + (p.yDir * progress) + (0.5 * 180 * progress * progress); // gravity pull

      double opacity = (1.0 - progress).clamp(0.0, 1.0);
      double curScale = p.scale * (0.8 + 0.2 * progress);

      canvas.save();
      canvas.translate(size.width / 2 + curX, size.height / 2 + curY);
      canvas.rotate(p.rotation + progress * 4);
      canvas.scale(curScale);

      textPainter.text = TextSpan(
        text: p.emoji,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white.withOpacity(opacity),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstParticlesPainter old) => old.progress != progress;
}

class _BurstParticle {
  final String emoji;
  final double xDir;
  final double yDir;
  final Offset origin;
  final double rotation;
  final double scale;

  _BurstParticle({
    required this.emoji,
    required this.xDir,
    required this.yDir,
    required this.origin,
    required this.rotation,
    required this.scale,
  });
}
