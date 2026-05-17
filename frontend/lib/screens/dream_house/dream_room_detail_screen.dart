import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/dream_house/ambient_environment_controller.dart';
import '../../widgets/dream_house/partner_presence_overlay.dart';
import '../../widgets/dream_house/memory_fragment_widget.dart';
import '../../providers/dream_house_providers.dart';
import 'dream_house_bottom_sheet.dart';

class _HotspotLocation {
  final String id;
  final double xPos;
  final double yPos;
  final String label;

  const _HotspotLocation({
    required this.id,
    required this.xPos,
    required this.yPos,
    required this.label,
  });
}

class DreamRoomDetailScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;
  final AmbienceType ambience;

  const DreamRoomDetailScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.ambience,
  });

  @override
  ConsumerState<DreamRoomDetailScreen> createState() => _DreamRoomDetailScreenState();
}

class _DreamRoomDetailScreenState extends ConsumerState<DreamRoomDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _objectController;
  late AnimationController _placementController;
  
  late Animation<double> _fade;
  late Animation<double> _scale;
  late ScrollController _horizontalScrollController;

  // Hotspots definitions per room
  final Map<String, List<_HotspotLocation>> _roomHotspots = {
    'living_room': const [
      _HotspotLocation(id: 'lr_h1', xPos: 0.3, yPos: 0.78, label: 'Sofa Corner'),
      _HotspotLocation(id: 'lr_h2', xPos: 0.5, yPos: 0.45, label: 'Center Window'),
      _HotspotLocation(id: 'lr_h3', xPos: 0.8, yPos: 0.70, label: 'Lamp Table'),
    ],
    'bedroom': const [
      _HotspotLocation(id: 'br_h1', xPos: 0.5, yPos: 0.60, label: 'Fluffy Bedside'),
      _HotspotLocation(id: 'br_h2', xPos: 0.15, yPos: 0.48, label: 'Mahogany Shelf'),
      _HotspotLocation(id: 'br_h3', xPos: 0.45, yPos: 0.84, label: 'Cozy Rug Corner'),
    ],
    'balcony': const [
      _HotspotLocation(id: 'bl_h1', xPos: 0.5, yPos: 0.62, label: 'Balcony Railing'),
      _HotspotLocation(id: 'bl_h2', xPos: 0.2, yPos: 0.80, label: 'Left Plant Corner'),
      _HotspotLocation(id: 'bl_h3', xPos: 0.65, yPos: 0.40, label: 'Starry Sky View'),
    ],
    'kitchen': const [
      _HotspotLocation(id: 'kt_h1', xPos: 0.5, yPos: 0.68, label: 'Counter Center'),
      _HotspotLocation(id: 'kt_h2', xPos: 0.25, yPos: 0.30, label: 'Left Shelf'),
      _HotspotLocation(id: 'kt_h3', xPos: 0.75, yPos: 0.68, label: 'Counter Right'),
    ],
  };

  // Reflection Input Overlay Flow state
  bool _showingReflectionInput = false;
  Map<String, dynamic>? _selectedItemToPlace;
  _HotspotLocation? _selectedHotspotToPlace;
  final TextEditingController _reflectionController = TextEditingController();
  
  String _emotionalPrompt = '';
  final List<String> _emotionalPrompts = [
    'What kind of moments live here?',
    'Why does this belong in our space?',
    'What do you imagine happening here someday?',
    'This feels like our future mornings...',
  ];

  // Cinematic Placement Animation state
  bool _placementActive = false;
  double _placementProgress = 0.0;
  Offset _placementCenter = Offset.zero;
  IconData? _placementIcon;
  String? _placementName;
  String? _placementMeaning;

  // Active object memory revealed overlay card
  DreamObject? _activeRevealedObject;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _objectController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _placementController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..addListener(() {
        setState(() {
          _placementProgress = _placementController.value;
        });
      });

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 1.06, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalScrollController.hasClients) {
        final maxScroll = _horizontalScrollController.position.maxScrollExtent;
        _horizontalScrollController.jumpTo(maxScroll / 2);
      }

      final state = ref.read(dreamHouseStateProvider);
      if (state.step == 'discover' && state.latestDiscoveredObject != null) {
        final latest = state.latestDiscoveredObject!;
        if (latest.roomId == widget.roomId) {
          _onObjectTap(latest, isInitialDiscovery: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _entryController.dispose();
    _objectController.dispose();
    _placementController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _onObjectTap(DreamObject obj, {bool isInitialDiscovery = false}) {
    setState(() {
      _activeRevealedObject = obj;
    });

    if (isInitialDiscovery && mounted) {
      ref.read(dreamHouseStateProvider.notifier).acknowledgeDiscovery();
    }
  }

  void _showSoftLockSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Color(0xFF0F0814),
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E7E5A).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              // Soft pulsing celestial icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween<double>(begin: 0.9, end: 1.1),
                curve: Curves.easeInOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB366).withOpacity(0.08),
                  ),
                  child: const Icon(
                    Icons.nights_stay,
                    size: 32,
                    color: Color(0xFFFFB366),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tonight, let this space rest a little.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFFFD59A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You’ve already left something meaningful here today.\nMore moments will unfold tomorrow ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E7E5A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD59A),
                    side: BorderSide(
                      color: const Color(0xFFFFB366).withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'Rest peacefully ✨',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _onHotspotTap(_HotspotLocation hotspot) {
    final step = ref.read(dreamHouseStateProvider).step;
    if (step == 'passed') {
      _showSoftLockSheet(context);
      return;
    }

    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DreamHouseBottomSheet(),
    ).then((result) {
      if (result != null && mounted) {
        setState(() {
          _selectedItemToPlace = result;
          _selectedHotspotToPlace = hotspot;
          _reflectionController.clear();
          _emotionalPrompt = _emotionalPrompts[math.Random().nextInt(_emotionalPrompts.length)];
          _showingReflectionInput = true;
        });
      }
    });
  }

  void _confirmPlacement() {
    if (_selectedItemToPlace == null || _selectedHotspotToPlace == null) return;
    
    final item = _selectedItemToPlace!;
    final hotspot = _selectedHotspotToPlace!;
    final text = _reflectionController.text.trim();
    final meaning = text.isNotEmpty ? text : 'Placed with love in our shared space.';

    setState(() {
      _showingReflectionInput = false;
    });

    _triggerCinematicPlacement(item, hotspot, meaning);
  }

  void _triggerCinematicPlacement(Map<String, dynamic> item, _HotspotLocation hotspot, String meaning) {
    final size = MediaQuery.of(context).size;
    final canvasWidth = size.width * 2.0;

    setState(() {
      _placementActive = true;
      _placementIcon = item['icon'] as IconData;
      _placementName = item['name'] as String;
      _placementMeaning = meaning;
      _placementCenter = Offset(
        canvasWidth * hotspot.xPos,
        size.height * hotspot.yPos,
      );
    });

    _placementController.forward(from: 0.0).then((_) {
      // Completed! Commit to Provider State
      ref.read(dreamHouseStateProvider.notifier).placeObject(
        _placementName!,
        _placementIcon!,
        _placementMeaning!,
        widget.roomId,
        xPos: hotspot.xPos,
        yPos: hotspot.yPos,
      );

      setState(() {
        _placementActive = false;
        _selectedItemToPlace = null;
        _selectedHotspotToPlace = null;
        _placementIcon = null;
        _placementName = null;
        _placementMeaning = null;
      });

      // Gorgeous confirmation HUD
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_placementIcon ?? Icons.auto_awesome, color: const Color(0xFFD4864A), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Passed to your partner 💌 Touch is waiting for them.',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE8C5A0),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF160A10),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4864A), width: 0.5),
          ),
        ),
      );
    });
  }

  void _addNewObject() {
    final hotspots = _roomHotspots[widget.roomId] ?? [];
    final roomObjects = ref.read(dreamHouseStateProvider).placedObjects.where((o) => o.roomId == widget.roomId).toList();
    
    _HotspotLocation? targetHotspot;
    for (final h in hotspots) {
      bool occupied = false;
      for (final obj in roomObjects) {
        final dx = obj.xPos - h.xPos;
        final dy = obj.yPos - h.yPos;
        if (math.sqrt(dx * dx + dy * dy) < 0.08) occupied = true;
      }
      if (!occupied) {
        targetHotspot = h;
        break;
      }
    }
    
    targetHotspot ??= _HotspotLocation(id: 'default', xPos: 0.5, yPos: 0.5, label: 'Center');

    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DreamHouseBottomSheet(),
    ).then((result) {
      if (result != null && mounted) {
        setState(() {
          _selectedItemToPlace = result;
          _selectedHotspotToPlace = targetHotspot;
          _reflectionController.clear();
          _emotionalPrompt = _emotionalPrompts[math.Random().nextInt(_emotionalPrompts.length)];
          _showingReflectionInput = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(dreamHouseStateProvider);
    final roomObjects = gameState.placedObjects.where((o) => o.roomId == widget.roomId).toList();
    final size = MediaQuery.of(context).size;
    final double canvasWidth = size.width * 2.0;

    // Environmental warmth multiplier calculation
    double extraWarmth = 0.0;
    if (_placementActive) {
      if (_placementProgress < 0.4) {
        extraWarmth = _placementProgress / 0.4;
      } else {
        extraWarmth = (1.0 - _placementProgress) / 0.6;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060307),
      body: AmbientEnvironmentController(
        ambience: widget.ambience,
        extraWarmth: extraWarmth,
        child: AnimatedBuilder(
          animation: Listenable.merge([_entryController, _objectController, _placementController]),
          builder: (context, _) {
            return Stack(
              children: [
                // Scrollable Room Canvas (360-degree panning environment)
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width: canvasWidth,
                          height: size.height,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Room visual background artwork
                              Positioned.fill(
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    size: Size(canvasWidth, size.height),
                                    painter: _RoomPainter(roomId: widget.roomId, ambience: widget.ambience),
                                  ),
                                ),
                              ),

                              // Render glowing interaction hotspots
                              ..._buildHotspots(context, roomObjects, canvasWidth),

                              // Placed interactive objects (scrolling in sync!)
                              ..._buildObjects(context, roomObjects, gameState.latestDiscoveredObject, canvasWidth),

                              // Memory fragments for this room (scrolling in sync!)
                              _buildRoomMemories(context, canvasWidth),

                              // Cinematic active placing object ghost fade
                              if (_placementActive && _placementIcon != null && _placementProgress >= 0.3)
                                Positioned(
                                  left: _placementCenter.dx - 30,
                                  top: _placementCenter.dy - 30,
                                  child: Opacity(
                                    opacity: ((_placementProgress - 0.3) / 0.7).clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: 0.6 + 0.4 * ((_placementProgress - 0.3) / 0.7),
                                      child: Container(
                                        width: 60, height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF331422),
                                          border: Border.all(color: const Color(0xFFFFB366), width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFB366).withOpacity(0.4),
                                              blurRadius: 30,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(_placementIcon, size: 28, color: const Color(0xFFFFB366)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Starry fountain particle painter overlay during placement
                              if (_placementActive)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _PlacementParticlePainter(
                                      progress: _placementProgress,
                                      center: _placementCenter,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Partner presence overlay
                PartnerPresenceOverlay(
                  hasUpdate: gameState.step == 'discover' && gameState.latestDiscoveredObject?.roomId == widget.roomId,
                  updateMessage: 'Something feels warmer here tonight.',
                ),

                // Header
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fade,
                      child: _buildHeader(),
                    ),
                  ),
                ),

                // Bottom action bar
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _buildBottomBar(gameState),
                  ),
                ),

                // Full-screen Blurred Emotional Reflection Input Overlay
                _buildReflectionOverlay(size),

                // Custom Floating Memory Aura Discovery Card
                _buildMemoryRevealOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHotspots(BuildContext context, List<DreamObject> placedObjects, double canvasWidth) {
    final hotspots = _roomHotspots[widget.roomId] ?? [];
    final size = MediaQuery.of(context).size;

    final availableHotspots = hotspots.where((h) {
      for (final obj in placedObjects) {
        final dx = obj.xPos - h.xPos;
        final dy = obj.yPos - h.yPos;
        if (math.sqrt(dx * dx + dy * dy) < 0.08) return false; // hide if close to object
      }
      return true;
    }).toList();

    return availableHotspots.map((h) {
      final x = canvasWidth * h.xPos - 19;
      final y = size.height * h.yPos - 19;
      return Positioned(
        left: x, top: y,
        child: RepaintBoundary(
          child: _HotspotWidget(
            hotspot: h,
            onTap: () => _onHotspotTap(h),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildObjects(BuildContext context, List<DreamObject> objects, DreamObject? latest, double canvasWidth) {
    final size = MediaQuery.of(context).size;
    return objects.map((obj) {
      final x = canvasWidth * obj.xPos - 30;
      final y = size.height * obj.yPos - 30;
      final isNew = latest?.id == obj.id;

      return Positioned(
        left: x, top: y - 24, // offset upward slightly to clear preview text
        child: RepaintBoundary(
          child: _InteractiveObjectWidget(
            object: obj,
            isNew: isNew,
            onTap: () => _onObjectTap(obj, isInitialDiscovery: isNew),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRoomMemories(BuildContext context, double canvasWidth) {
    if (widget.roomId != 'living_room') return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: canvasWidth * 0.05,
      top: size.height * 0.3,
      child: const RepaintBoundary(
        child: MemoryFragmentWidget(
          fragment: MemoryFragment(
            id: 'r1',
            text: 'I imagined us drinking coffee here during rain.',
            author: 'partner',
            xFraction: 0.05,
            yFraction: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A0C12).withOpacity(0.75),
                border: Border.all(color: const Color(0xFF3D1627).withOpacity(0.5)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF9E7E5A)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ROOM', style: TextStyle(fontSize: 9, letterSpacing: 2.5, color: Color(0xFF6E4555))),
              const SizedBox(height: 2),
              Text(widget.roomName, style: const TextStyle(fontFamily: 'Georgia', fontSize: 17, fontStyle: FontStyle.italic, color: Color(0xFFE8C5A0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DreamHouseState state) {
    final bool isMyTurn = state.step == 'play';
    if (!isMyTurn) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, const Color(0xFF060307).withOpacity(0.97)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: GestureDetector(
            onTap: _addNewObject,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A1E0F), Color(0xFF1A0C12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4864A).withOpacity(0.25), width: 1),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4864A).withOpacity(0.08), blurRadius: 24),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 18, color: Color(0xFFD4864A)),
                  SizedBox(width: 12),
                  Text('Add something meaningful', style: TextStyle(fontFamily: 'Georgia', fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFFE8C5A0))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionOverlay(Size size) {
    if (!_showingReflectionInput || _selectedItemToPlace == null) return const SizedBox.shrink();

    final item = _selectedItemToPlace!;
    final icon = item['icon'] as IconData;
    final name = item['name'] as String;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top close button and preview of object
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showingReflectionInput = false;
                                _selectedItemToPlace = null;
                                _selectedHotspotToPlace = null;
                              });
                            },
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E0C15).withOpacity(0.8),
                                border: Border.all(color: const Color(0xFF3D1627).withOpacity(0.5)),
                              ),
                              child: const Icon(Icons.close, size: 14, color: Color(0xFF9E7E5A)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Blurred object card preview
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F0A13).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD4864A).withOpacity(0.2), width: 1.2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFD4864A).withOpacity(0.06), blurRadius: 28),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFD4864A).withOpacity(0.12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4864A).withOpacity(0.15),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                                child: Icon(icon, size: 36, color: const Color(0xFFFFB366)),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFE8C5A0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Center prompts and reflection multiline text area
                    Column(
                      children: [
                        Text(
                          _emotionalPrompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFFFC085),
                            height: 1.4,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF120610).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFF3D1627).withOpacity(0.6), width: 1.2),
                          ),
                          child: TextField(
                            controller: _reflectionController,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFE8C5A0),
                              height: 1.5,
                            ),
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: '“I imagined us drinking coffee here during rain…”',
                              hintStyle: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF6E4555).withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Placement button
                    GestureDetector(
                      onTap: _confirmPlacement,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5A2A18), Color(0xFF1E0C15)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFB366).withOpacity(0.4), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB366).withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Place into our space ✨',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFE8C5A0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryRevealOverlay() {
    if (_activeRevealedObject == null) return const SizedBox.shrink();

    final obj = _activeRevealedObject!;
    final timeStr = DreamHouseNotifier.formatEmotionalTimestamp(obj.timestamp);

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeRevealedObject = null;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.78),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * val,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glowing breathing object icon
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E0C15),
                                border: Border.all(
                                  color: const Color(0xFFFFB366).withOpacity(0.5 * val),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFB366).withOpacity(0.2 * val),
                                    blurRadius: 28,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                obj.icon,
                                size: 42,
                                color: const Color(0xFFFFB366),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Handwritten floating memory aura text
                            Text(
                              obj.name,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 24,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFE8C5A0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Emotional author context
                            Text(
                              obj.addedBy == 'partner' ? 'Left behind by them ✨' : 'Placed by you',
                              style: const TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 2.0,
                                color: Color(0xFF6E4555),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Cursive elegant handwritten message aura glass card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0810).withOpacity(0.65),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFD4864A).withOpacity(0.12 * val),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Curved subtle cursive message
                                  Text(
                                    '"${obj.emotionalMeaning}"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFFFD59A),
                                      height: 1.6,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  
                                  // Intimate Timestamp
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF9E7E5A).withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Close hint
                            const Text(
                              'Tap anywhere to close the memory',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.5,
                                color: Color(0xFF3D2030),
                              ),
                            ),
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
      ),
    );
  }
}

class _HotspotWidget extends StatefulWidget {
  final _HotspotLocation hotspot;
  final VoidCallback onTap;

  const _HotspotWidget({required this.hotspot, required this.onTap});

  @override
  State<_HotspotWidget> createState() => _HotspotWidgetState();
}

class _HotspotWidgetState extends State<_HotspotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.2, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing ring outline
              Container(
                width: 38 * _scale.value,
                height: 38 * _scale.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4864A).withOpacity(_glowOpacity.value * 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4864A).withOpacity(_glowOpacity.value * 0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Inner solid glowing dot
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1F0A13),
                  border: Border.all(
                    color: const Color(0xFFD4864A).withOpacity(0.7),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4864A).withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InteractiveObjectWidget extends StatefulWidget {
  final DreamObject object;
  final bool isNew;
  final VoidCallback onTap;

  const _InteractiveObjectWidget({
    required this.object,
    this.isNew = false,
    required this.onTap,
  });

  @override
  State<_InteractiveObjectWidget> createState() => _InteractiveObjectWidgetState();
}

class _InteractiveObjectWidgetState extends State<_InteractiveObjectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    _breathScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, _) {
        final scale = widget.isNew ? (_breathScale.value * 1.15) : _breathScale.value;
        final borderGlow = widget.isNew ? const Color(0xFFFFB366) : const Color(0xFFD4864A);

        final hasMeaning = widget.object.emotionalMeaning.isNotEmpty;
        final previewText = widget.object.emotionalMeaning.length > 28
            ? '${widget.object.emotionalMeaning.substring(0, 26)}...'
            : widget.object.emotionalMeaning;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cursive floating handwritten memory trace above object
            if (hasMeaning)
              Opacity(
                opacity: (0.45 + 0.15 * math.sin(_breathController.value * math.pi * 2)).clamp(0.0, 0.9),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0810).withOpacity(0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFC085).withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    previewText.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 8.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFFD59A),
                    ),
                  ),
                ),
              ),

            // Pulsating circle icon
            GestureDetector(
              onTap: widget.onTap,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isNew ? const Color(0xFF331422) : const Color(0xFF1F0A13),
                    border: Border.all(
                      color: borderGlow.withOpacity(widget.isNew ? 0.8 : 0.4),
                      width: widget.isNew ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: borderGlow.withOpacity((widget.isNew ? 0.45 : 0.2) * _breathScale.value),
                        blurRadius: widget.isNew ? 32 : 20,
                        spreadRadius: widget.isNew ? 5 : 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.object.icon,
                        size: 22,
                        color: widget.isNew ? const Color(0xFFFFB366) : const Color(0xFFD4864A),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.object.name,
                        style: TextStyle(
                          fontSize: 6,
                          color: widget.isNew ? const Color(0xFFE8C5A0) : const Color(0xFF9E7E5A),
                          fontWeight: widget.isNew ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlacementParticlePainter extends CustomPainter {
  final double progress;
  final Offset center;
  _PlacementParticlePainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;
    
    final rand = math.Random(42);
    final count = 35;
    final paint = Paint();

    for (int i = 0; i < count; i++) {
      final double angle = rand.nextDouble() * 2 * math.pi;
      final double speed = rand.nextDouble() * 120 + 40;
      final double distance = speed * progress;

      final double px = center.dx + math.cos(angle) * distance;
      final double py = center.dy + math.sin(angle) * distance - (progress * 30);
      
      final double opacity = (1.0 - progress).clamp(0.0, 1.0);
      final double s = rand.nextDouble() * 4.5 * (1.0 - progress) + 1.5;

      paint.color = const Color(0xFFFFD54F).withOpacity(opacity);
      canvas.drawCircle(Offset(px, py), s, paint);

      if (i % 3 == 0) {
        final haloPaint = Paint()
          ..color = const Color(0xFFFFB74D).withOpacity(opacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(px, py), s * 3.5, haloPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PlacementParticlePainter old) => old.progress != progress;
}

class _RoomPainter extends CustomPainter {
  final String roomId;
  final AmbienceType ambience;
  _RoomPainter({required this.roomId, required this.ambience});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Color baseColor, accentColor;
    switch (ambience) {
      case AmbienceType.warmEvening:
        baseColor = const Color(0xFF331E29); accentColor = const Color(0xFFE69C5E);
      case AmbienceType.rainyNight:
        baseColor = const Color(0xFF0C1420); accentColor = const Color(0xFF3E6090);
      case AmbienceType.goldenHour:
        baseColor = const Color(0xFF362216); accentColor = const Color(0xFFEAA63D);
      case AmbienceType.moonlit:
        baseColor = const Color(0xFF0F0F1A); accentColor = const Color(0xFF556E9B);
      case AmbienceType.cozyAfternoon:
        baseColor = const Color(0xFF2E2018); accentColor = const Color(0xFFD4864A);
    }

    final bool isDayTime = ambience == AmbienceType.cozyAfternoon || 
                           ambience == AmbienceType.goldenHour || 
                           ambience == AmbienceType.warmEvening;

    // 1. Full rich background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor, 
          isDayTime ? const Color(0xFF160E0B) : const Color(0xFF060307)
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Room specific architectural illustration
    if (roomId == 'living_room') {
      final beamPaint = Paint()..color = const Color(0xFF12080C);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, 28), beamPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.15, 0, 24, h * 0.15), beamPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.82, 0, 24, h * 0.15), beamPaint);

      final windowOutline = Paint()
        ..color = const Color(0xFF331622)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final windowBg = Paint()..color = const Color(0xFF0B0508);
      
      canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.3), windowBg);
      canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.33, w * 0.56, h * 0.27), windowBg);
      
      canvas.drawLine(Offset(w * 0.5, h * 0.18), Offset(w * 0.5, h * 0.6), windowOutline);
      canvas.drawLine(Offset(w * 0.22, h * 0.38), Offset(w * 0.78, h * 0.38), windowOutline);

      if (isDayTime) {
        final sunPaint = Paint()..color = const Color(0xFFFFF59D).withOpacity(0.4);
        canvas.drawCircle(Offset(w * 0.5, h * 0.33), 32, sunPaint);
      } else {
        final starPaint = Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.5);
        canvas.drawCircle(Offset(w * 0.35, h * 0.25), 1.2, starPaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.28), 1.5, starPaint);
        canvas.drawCircle(Offset(w * 0.42, h * 0.34), 1.0, starPaint);
        canvas.drawCircle(Offset(w * 0.58, h * 0.22), 1.3, starPaint);
      }

      final floorPaint = Paint()..color = const Color(0xFF14070C);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), floorPaint);
      
      final rugPaint = Paint()..color = const Color(0xFF2E131E);
      canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.78, w * 0.7, h * 0.12), rugPaint);
      
      final lampGlow = Paint()
        ..color = accentColor.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawCircle(Offset(w * 0.84, h * 0.45), 60, lampGlow);
      
      final standPaint = Paint()..color = const Color(0xFF29111C)..strokeWidth = 2;
      canvas.drawLine(Offset(w * 0.84, h * 0.45), Offset(w * 0.84, h * 0.76), standPaint);
      canvas.drawCircle(Offset(w * 0.84, h * 0.45), 10, Paint()..color = accentColor);

    } else if (roomId == 'bedroom') {
      final tableBorder = Paint()..color = const Color(0xFF381B2B)..strokeWidth = 1.5..style = PaintingStyle.stroke;
      final goldHandle = Paint()..color = const Color(0xFFFFCC80);
      final shadePaint = Paint()..color = const Color(0xFFD4864A);
      final potPaint = Paint()..color = const Color(0xFFC76B4E);
      final monsteraColor = const Color(0xFF2D5C3E);
      
      final beamPaint = Paint()..color = const Color(0xFF2C1915);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, 32), beamPaint);
      
      final windowRect = Rect.fromLTWH(w * 0.18, h * 0.13, w * 0.64, h * 0.42);
      
      canvas.save();
      final archPath = Path()
        ..moveTo(w * 0.18, h * 0.55)
        ..lineTo(w * 0.18, h * 0.30)
        ..quadraticBezierTo(w * 0.50, h * 0.10, w * 0.82, h * 0.30)
        ..lineTo(w * 0.82, h * 0.55)
        ..close();
      canvas.clipPath(archPath);
      
      final skyGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF07050E), const Color(0xFF1D172E)],
      ).createShader(windowRect);
      canvas.drawRect(windowRect, Paint()..shader = skyGradient);

      final starPaint = Paint()..color = const Color(0xFFFFF9C4).withOpacity(0.4);
      canvas.drawCircle(Offset(w * 0.32, h * 0.26), 1.2, starPaint);
      canvas.drawCircle(Offset(w * 0.44, h * 0.22), 1.0, starPaint);
      canvas.drawCircle(Offset(w * 0.68, h * 0.24), 1.5, starPaint);
      canvas.drawCircle(Offset(w * 0.58, h * 0.30), 1.1, starPaint);

      final moonPaint = Paint()..color = const Color(0xFFE8C5A0).withOpacity(0.7);
      canvas.drawCircle(Offset(w * 0.65, h * 0.22), 18, moonPaint);
      canvas.drawCircle(Offset(w * 0.62, h * 0.21), 18, Paint()..color = const Color(0xFF07050E));

      final mtPaint = Paint()..color = const Color(0xFF090616);
      final mtPath = Path()
        ..moveTo(w * 0.18, h * 0.55)
        ..quadraticBezierTo(w * 0.35, h * 0.44, w * 0.52, h * 0.49)
        ..quadraticBezierTo(w * 0.68, h * 0.42, w * 0.82, h * 0.55)
        ..close();
      canvas.drawPath(mtPath, mtPaint);

      final rainPaint = Paint()..color = const Color(0xFF6B7A99).withOpacity(0.20)..strokeWidth = 1.0;
      for (int i = 0; i < 20; i++) {
        final rx = w * 0.20 + (w * 0.60 * (i / 20));
        final ry = h * 0.16 + (35 * ((i * 7) % 5));
        canvas.drawLine(Offset(rx, ry), Offset(rx - 3, ry + 20), rainPaint);
      }
      
      canvas.restore();

      final woodFrame = Paint()
        ..color = const Color(0xFF1E1424)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(archPath, woodFrame);

      final panePaint = Paint()..color = const Color(0xFF1E1424)..strokeWidth = 2.0;
      canvas.drawLine(Offset(w / 2, h * 0.15), Offset(w / 2, h * 0.55), panePaint);
      canvas.drawLine(Offset(w * 0.18, h * 0.36), Offset(w * 0.82, h * 0.36), panePaint);

      final curtainBg = Paint()..color = const Color(0xFF2E1C2B);
      final curtainShadow = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      final leftCurtain = Path()
        ..moveTo(w * 0.18, h * 0.13)
        ..quadraticBezierTo(w * 0.26, h * 0.32, w * 0.23, h * 0.55)
        ..lineTo(w * 0.16, h * 0.55)
        ..close();
      canvas.drawPath(leftCurtain, curtainShadow);
      canvas.drawPath(leftCurtain, curtainBg);
      
      final rightCurtain = Path()
        ..moveTo(w * 0.82, h * 0.13)
        ..quadraticBezierTo(w * 0.74, h * 0.32, w * 0.77, h * 0.55)
        ..lineTo(w * 0.84, h * 0.55)
        ..close();
      canvas.drawPath(rightCurtain, curtainShadow);
      canvas.drawPath(rightCurtain, curtainBg);

      final wirePaint = Paint()
        ..color = const Color(0xFF1E1424)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      
      final wirePath = Path()
        ..moveTo(w * 0.15, h * 0.18)
        ..quadraticBezierTo(w * 0.32, h * 0.23, w * 0.50, h * 0.18)
        ..quadraticBezierTo(w * 0.68, h * 0.23, w * 0.85, h * 0.18);
      canvas.drawPath(wirePath, wirePaint);

      final bulbGlow = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final bulbPaint = Paint()..color = const Color(0xFFFFF9C4);
      
      final List<Offset> bulbOffsets = [
        Offset(w * 0.22, h * 0.198),
        Offset(w * 0.30, h * 0.212),
        Offset(w * 0.38, h * 0.226),
        Offset(w * 0.46, h * 0.186),
        Offset(w * 0.54, h * 0.186),
        Offset(w * 0.62, h * 0.226),
        Offset(w * 0.70, h * 0.212),
        Offset(w * 0.78, h * 0.198),
      ];
      for (final offset in bulbOffsets) {
        canvas.drawCircle(offset, 8, bulbGlow);
        canvas.drawCircle(offset, 3, bulbPaint);
      }

      final vineGreen = const Color(0xFF386641);
      final potPaintColor = const Color(0xFFC76B4E);
      
      canvas.drawRect(Rect.fromLTWH(w * 0.20, h * 0.14, 12, 8), Paint()..color = potPaintColor);
      canvas.drawCircle(Offset(w * 0.21, h * 0.19), 4, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.19, h * 0.22), 5, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.22, h * 0.26), 4, Paint()..color = vineGreen);
      
      canvas.drawRect(Rect.fromLTWH(w * 0.76, h * 0.14, 12, 8), Paint()..color = potPaintColor);
      canvas.drawCircle(Offset(w * 0.77, h * 0.19), 4, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.79, h * 0.22), 5, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.76, h * 0.26), 4, Paint()..color = vineGreen);

      final shelfPaint = Paint()..color = const Color(0xFF5A3625);
      final shelfBorder = Paint()
        ..color = const Color(0xFF82523B)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.24, w * 0.15, h * 0.44), shelfPaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.24, w * 0.15, h * 0.44), shelfBorder);
      
      final shelfLinePaint = Paint()..color = const Color(0xFF82523B)..strokeWidth = 2.0;
      canvas.drawLine(Offset(w * 0.05, h * 0.35), Offset(w * 0.20, h * 0.35), shelfLinePaint);
      canvas.drawLine(Offset(w * 0.05, h * 0.46), Offset(w * 0.20, h * 0.46), shelfLinePaint);
      canvas.drawLine(Offset(w * 0.05, h * 0.57), Offset(w * 0.20, h * 0.57), shelfLinePaint);

      final bRed = Paint()..color = const Color(0xFFBA5C44);
      final bGold = Paint()..color = const Color(0xFFD4864A);
      final bBlue = Paint()..color = const Color(0xFF4C6E8D);
      canvas.drawRect(Rect.fromLTWH(w * 0.07, h * 0.28, 5, 20), bRed);
      canvas.drawRect(Rect.fromLTWH(w * 0.09, h * 0.27, 6, 22), bGold);
      
      canvas.save();
      canvas.translate(w * 0.14, h * 0.35);
      canvas.rotate(0.25);
      canvas.drawRect(Rect.fromLTWH(-5, -18, 5, 18), bBlue);
      canvas.restore();

      final frameBg = Paint()..color = const Color(0xFFFFFDF9);
      final frameBorder = Paint()..color = const Color(0xFF8D6E63)..strokeWidth = 1.5..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromLTWH(w * 0.07, h * 0.39, 22, 16), frameBg);
      canvas.drawRect(Rect.fromLTWH(w * 0.07, h * 0.39, 22, 16), frameBorder);
      
      canvas.drawCircle(Offset(w * 0.07 + 7, h * 0.39 + 8), 3, Paint()..color = const Color(0xFFC85B65));
      canvas.drawCircle(Offset(w * 0.07 + 13, h * 0.39 + 8), 3, Paint()..color = const Color(0xFFC85B65));

      canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.41, 8, 12), Paint()..color = const Color(0xFFFFFDF9));
      final flamePath = Path()
        ..moveTo(w * 0.15 + 4, h * 0.41 - 5)
        ..quadraticBezierTo(w * 0.15 + 6, h * 0.41 - 2, w * 0.15 + 4, h * 0.41)
        ..quadraticBezierTo(w * 0.15 + 2, h * 0.41 - 2, w * 0.15 + 4, h * 0.41 - 5);
      canvas.drawPath(flamePath, Paint()..color = const Color(0xFFFFB74D));

      final jarBg = Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.6);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.07, h * 0.50, 14, 18), const Radius.circular(3)), jarBg);
      canvas.drawRect(Rect.fromLTWH(w * 0.07 + 2, h * 0.50 - 3, 10, 3), Paint()..color = const Color(0xFF8D6E63));
      
      canvas.drawRect(Rect.fromLTWH(w * 0.14, h * 0.52, 12, 8), Paint()..color = potPaintColor);
      canvas.drawCircle(Offset(w * 0.16, h * 0.50), 3, Paint()..color = vineGreen);

      canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.20, w * 0.08, h * 0.04), potPaint);
      canvas.drawCircle(Offset(w * 0.09, h * 0.25), 5, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.07, h * 0.28), 7, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.08, h * 0.32), 6, Paint()..color = vineGreen);
      canvas.drawCircle(Offset(w * 0.06, h * 0.36), 8, Paint()..color = vineGreen);

      final tableColor = const Color(0xFF221118);
      canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.68, w * 0.12, h * 0.16), Paint()..color = tableColor);
      canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.68, w * 0.12, h * 0.16), tableBorder);
      
      canvas.drawRect(Rect.fromLTWH(w * 0.82, h * 0.68, w * 0.12, h * 0.16), Paint()..color = tableColor);
      canvas.drawRect(Rect.fromLTWH(w * 0.82, h * 0.68, w * 0.12, h * 0.16), tableBorder);

      canvas.drawCircle(Offset(w * 0.12, h * 0.76), 3, goldHandle);
      canvas.drawCircle(Offset(w * 0.88, h * 0.76), 3, goldHandle);

      final mugColor = const Color(0xFFC76B4E);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.085, h * 0.64, 12, 11), const Radius.circular(2)), Paint()..color = mugColor);
      
      final steamPaint = Paint()..color = const Color(0xFFFFFDF9).withOpacity(0.35)..strokeWidth = 1.0..style = PaintingStyle.stroke;
      final steamPath = Path()
        ..moveTo(w * 0.085 + 6, h * 0.64)
        ..quadraticBezierTo(w * 0.085 + 4, h * 0.61, w * 0.085 + 6, h * 0.58);
      canvas.drawPath(steamPath, steamPaint);

      final lampBaseColor = const Color(0xFF4A1E30);
      canvas.drawOval(Rect.fromLTWH(w * 0.13, h * 0.64, w * 0.04, h * 0.04), Paint()..color = lampBaseColor);
      canvas.drawOval(Rect.fromLTWH(w * 0.83, h * 0.64, w * 0.04, h * 0.04), Paint()..color = lampBaseColor);
      
      final pathLeft = Path()
        ..moveTo(w * 0.13, h * 0.64)
        ..lineTo(w * 0.11, h * 0.59)
        ..lineTo(w * 0.19, h * 0.59)
        ..lineTo(w * 0.17, h * 0.64)
        ..close();
      canvas.drawPath(pathLeft, shadePaint);
      
      final pathRight = Path()
        ..moveTo(w * 0.83, h * 0.64)
        ..lineTo(w * 0.81, h * 0.59)
        ..lineTo(w * 0.89, h * 0.59)
        ..lineTo(w * 0.87, h * 0.64)
        ..close();
      canvas.drawPath(pathRight, shadePaint);

      final lampGlow = Paint()
        ..color = const Color(0xFFFFCC80).withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      canvas.drawCircle(Offset(w * 0.15, h * 0.61), 45, lampGlow);
      canvas.drawCircle(Offset(w * 0.85, h * 0.61), 45, lampGlow);
      
      canvas.drawCircle(Offset(w * 0.15, h * 0.61), 8, Paint()..color = const Color(0xFFFFB74D));
      canvas.drawCircle(Offset(w * 0.85, h * 0.61), 8, Paint()..color = const Color(0xFFFFB74D));

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.83, h * 0.74, w * 0.09, h * 0.08), const Radius.circular(4)), potPaint);
      final stalkPaint = Paint()..color = monsteraColor..strokeWidth = 2.0;
      canvas.drawLine(Offset(w * 0.87, h * 0.74), Offset(w * 0.87, h * 0.64), stalkPaint);
      canvas.drawLine(Offset(w * 0.85, h * 0.74), Offset(w * 0.81, h * 0.60), stalkPaint);
      canvas.drawLine(Offset(w * 0.89, h * 0.74), Offset(w * 0.92, h * 0.61), stalkPaint);
      
      canvas.drawCircle(Offset(w * 0.87, h * 0.64), 14, Paint()..color = monsteraColor);
      canvas.drawCircle(Offset(w * 0.81, h * 0.60), 11, Paint()..color = monsteraColor);
      canvas.drawCircle(Offset(w * 0.92, h * 0.61), 12, Paint()..color = monsteraColor);

      final headboardPaint = Paint()..color = const Color(0xFF2E1915);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.53, w * 0.60, h * 0.14), const Radius.circular(8)), headboardPaint);

      final neonGlow = Paint()
        ..color = const Color(0xFFFF8A80).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.46, w * 0.36, h * 0.05), const Radius.circular(8)), neonGlow);
      
      final barPaint = Paint()..color = const Color(0xFFC5828E)..strokeWidth = 1.0;
      canvas.drawLine(Offset(w * 0.34, h * 0.50), Offset(w * 0.66, h * 0.50), barPaint);

      final neonPainter = TextPainter(
        text: TextSpan(
          text: 'Bhagya & Alex',
          style: TextStyle(
            color: const Color(0xFFFFEBEE),
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
            fontFamily: 'Georgia',
            fontStyle: FontStyle.italic,
            shadows: [
              Shadow(
                color: const Color(0xFFFF5252).withOpacity(0.95),
                blurRadius: 12,
              ),
              Shadow(
                color: const Color(0xFFFF8A80).withOpacity(0.8),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      neonPainter.paint(canvas, Offset(w * 0.5 - neonPainter.width / 2, h * 0.48 - neonPainter.height / 2));

      final floorPaint = Paint()..color = const Color(0xFF140810);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.18), floorPaint);

      final rugPaint = Paint()..color = const Color(0xFF281822);
      canvas.drawOval(Rect.fromLTWH(w * 0.16, h * 0.83, w * 0.68, h * 0.15), rugPaint);
      
      final fringePaint = Paint()..color = const Color(0xFF3D2835)..strokeWidth = 1.5;
      for (int i = 0; i < 35; i++) {
        final angle = math.pi + (math.pi * i / 35);
        final rx = w * 0.5 + w * 0.34 * math.cos(angle);
        final ry = h * 0.905 + h * 0.075 * math.sin(angle);
        canvas.drawLine(Offset(rx, ry), Offset(rx + 4 * math.cos(angle), ry + 4 * math.sin(angle)), fringePaint);
      }

      final double pupAnchorX = w * 0.65;
      final pupBasketPaint = Paint()..color = const Color(0xFF3E2723);
      final pupBasketBorder = Paint()..color = const Color(0xFFD4864A)..strokeWidth = 1.5..style = PaintingStyle.stroke;
      canvas.drawOval(Rect.fromLTWH(pupAnchorX, h * 0.84, 55, 24), pupBasketPaint);
      canvas.drawOval(Rect.fromLTWH(pupAnchorX, h * 0.84, 55, 24), pupBasketBorder);

      final pupColor = const Color(0xFFE5A65E);
      final pupShadow = Paint()
        ..color = const Color(0xFF0F050A).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(Rect.fromLTWH(pupAnchorX + 12, h * 0.86, 38, 16), pupShadow);
      
      canvas.drawOval(Rect.fromLTWH(pupAnchorX + 12, h * 0.84, 32, 18), Paint()..color = pupColor);
      canvas.drawCircle(Offset(pupAnchorX + 35, h * 0.85), 8, Paint()..color = pupColor);
      canvas.drawOval(Rect.fromLTWH(pupAnchorX + 35, h * 0.86, 5, 9), Paint()..color = const Color(0xFFBD7C3F));
      canvas.drawCircle(Offset(pupAnchorX + 8, h * 0.86), 3, Paint()..color = pupColor);
      
      final eyePaint = Paint()
        ..color = const Color(0xFF4E2C16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawArc(Rect.fromLTWH(pupAnchorX + 35, h * 0.83, 3, 3), 0, math.pi, false, eyePaint);

      final bedPaint = Paint()..color = const Color(0xFFFFFDF9);
      final bedShadow = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.63, w * 0.60, h * 0.20), const Radius.circular(16)), bedShadow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.63, w * 0.60, h * 0.20), const Radius.circular(16)), bedPaint);

      final sheetCuffPaint = Paint()..color = const Color(0xFFF7F4EF);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.63, w * 0.60, h * 0.08), const Radius.circular(16)), sheetCuffPaint);
      
      final seamPaint = Paint()..color = const Color(0xFFE0D8CE)..strokeWidth = 1.0;
      canvas.drawLine(Offset(w * 0.20, h * 0.71), Offset(w * 0.80, h * 0.71), seamPaint);

      final pillowPaint = Paint()..color = const Color(0xFFFFFDF4);
      final pillowBorder = Paint()
        ..color = const Color(0xFFEBE0D2)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      final pillowShadow = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.save();
      canvas.translate(w * 0.34, h * 0.58);
      canvas.rotate(-0.06);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowShadow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowBorder);
      canvas.drawLine(Offset(-w * 0.04, 0), Offset(w * 0.04, 0), Paint()..color = const Color(0xFFEBE0D2)..strokeWidth = 1.5);
      canvas.restore();

      canvas.save();
      canvas.translate(w * 0.66, h * 0.58);
      canvas.rotate(0.06);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowShadow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.12, -h * 0.045, w * 0.24, h * 0.09), const Radius.circular(8)), pillowBorder);
      canvas.drawLine(Offset(-w * 0.04, 0), Offset(w * 0.04, 0), Paint()..color = const Color(0xFFEBE0D2)..strokeWidth = 1.5);
      canvas.restore();

      final blanketPaint = Paint()..color = const Color(0xFFBA5C44);
      final blanketShadow = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.71, w * 0.60, h * 0.13), const Radius.circular(12)), blanketShadow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.71, w * 0.60, h * 0.13), const Radius.circular(12)), blanketPaint);

      final ripplePaint = Paint()..color = const Color(0xFFC76B55);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.71, w * 0.60, h * 0.045), const Radius.circular(8)), ripplePaint);
      
      final shadingPaint = Paint()..color = const Color(0xFF8E3B29).withOpacity(0.35)..strokeWidth = 2;
      canvas.drawLine(Offset(w * 0.22, h * 0.755), Offset(w * 0.78, h * 0.755), shadingPaint);
      canvas.drawLine(Offset(w * 0.25, h * 0.80), Offset(w * 0.75, h * 0.80), shadingPaint);

    } else if (roomId == 'balcony') {
      final mistPaint = Paint()
        ..color = const Color(0xFF182230).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.3, w, h * 0.45), mistPaint);

      final floorPaint = Paint()..color = const Color(0xFF0D1420);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), floorPaint);
      
      final plankPaint = Paint()..color = const Color(0xFF1C2C40).withOpacity(0.3)..strokeWidth = 1.5;
      for (int i = 1; i < 6; i++) {
        canvas.drawLine(Offset(w * 0.2 * i, h * 0.72), Offset(w * 0.2 * i, h), plankPaint);
      }

      final railPaint = Paint()
        ..color = const Color(0xFF1A2636)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, h * 0.70), Offset(w, h * 0.70), railPaint);
      canvas.drawLine(Offset(0, h * 0.58), Offset(w, h * 0.58), railPaint);
      for (int i = 0; i <= 10; i++) {
        canvas.drawLine(Offset(w * 0.1 * i, h * 0.58), Offset(w * 0.1 * i, h * 0.72), railPaint);
      }

    } else if (roomId == 'kitchen') {
      final floorPaint = Paint()..color = const Color(0xFF0F0B08);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), floorPaint);

      final shelfPaint = Paint()..color = const Color(0xFF261912)..strokeWidth = 3;
      canvas.drawLine(Offset(w * 0.1, h * 0.24), Offset(w * 0.9, h * 0.24), shelfPaint);
      canvas.drawLine(Offset(w * 0.15, h * 0.42), Offset(w * 0.85, h * 0.42), shelfPaint);

      final objectPaint = Paint()..color = const Color(0xFF3B281E);
      canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.16, 20, 24), objectPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.65, h * 0.18, 16, 16), objectPaint);
      
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.64, w * 0.8, h * 0.11), const Radius.circular(4)), Paint()..color = const Color(0xFF1D120D));

    } else {
      final foliagePaint = Paint()
        ..color = const Color(0xFF0A1208).withOpacity(0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(w * 0.1, h * 0.3), 100, foliagePaint);
      canvas.drawCircle(Offset(w * 0.9, h * 0.25), 120, foliagePaint);

      final grassPaint = Paint()..color = const Color(0xFF060B05);
      final path = Path()
        ..moveTo(0, h * 0.72)
        ..quadraticBezierTo(w * 0.3, h * 0.68, w * 0.6, h * 0.75)
        ..quadraticBezierTo(w * 0.8, h * 0.78, w, h * 0.70)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(path, grassPaint);
    }

    final lightOverlay = Paint()
      ..color = accentColor.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    canvas.drawCircle(Offset(w / 2, h * 0.2), w * 0.8, lightOverlay);
  }

  @override
  bool shouldRepaint(_RoomPainter old) =>
      old.roomId != roomId || old.ambience != ambience;
}
