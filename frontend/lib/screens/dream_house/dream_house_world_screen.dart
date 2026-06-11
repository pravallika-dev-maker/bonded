import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/dream_house/ambient_environment_controller.dart';
import 'dream_house_bottom_sheet.dart';

// Daily capsule information
class DailyCapsule {
  final int day;
  final String itemId;
  final String itemName;
  final String author;
  final String note;
  String reaction; // Can be updated by the partner

  DailyCapsule({
    required this.day,
    required this.itemId,
    required this.itemName,
    required this.author,
    required this.note,
    this.reaction = "",
  });
}

class DreamHouseWorldScreen extends StatefulWidget {
  final int initialDay;
  final String userName;
  final String partnerName;

  const DreamHouseWorldScreen({
    super.key,
    this.initialDay = 4, // Default to separation Day 4 demonstration
    required this.userName,
    required this.partnerName,
  });

  @override
  State<DreamHouseWorldScreen> createState() => _DreamHouseWorldScreenState();
}

class _DreamHouseWorldScreenState extends State<DreamHouseWorldScreen>
    with TickerProviderStateMixin {
  
  // State variables
  String _activePhase = 'intro'; // 'intro', 'house_selection', 'house_materializing', 'hub', 'lock', 'scrapbook', 'day7_walkthrough', 'day7_reveal'
  int _currentDay = 1; // Default to Day 1 so they can build up the house!
  String _activeRole = 'A'; // 'A' (User) or 'B' (Partner) for pass-and-play simulation
  
  // Placed item coordinates mapping on 360 x 480 grid
  final Map<String, Offset> _itemPositions = const {
    'lamp': Offset(55, 360),
    'monstera': Offset(295, 360),
    'bookshelf': Offset(310, 280),
    'record_player': Offset(75, 410),
    'fairy_lights': Offset(180, 80),
    'memory_frame': Offset(180, 140),
    'coffee': Offset(125, 410),
    'window_rain': Offset(180, 160),
  };

  // State of placed items
  final List<PlacedItemState> _placedItems = [];

  // Notes history scrapbook
  final List<DailyCapsule> _scrapbookCapsules = [];

  // Floating Reaction Overlay State
  bool _showFloatingReactions = false;
  DailyCapsule? _activeReactionCapsule;
  bool _showPartnerHandoverOverlay = false;

  // Materialization cinematic state
  bool _isShowingMaterializationCinematic = false;
  String _lastPlacedItemName = '';
  final GlobalKey<AmbientEnvironmentControllerState> _ambientKey = GlobalKey();

  // House selection & materialization fields
  String? _chosenHouseType;
  double _houseMaterializationProgress = 0.0;
  int _materializationStep = 0;
  bool _isPartnerResponseSimulated = false;

  // Cinematic house carousel variables
  late PageController _housePageController;
  double _houseCurrentPage = 0.0;
  late AnimationController _zoomExpandController;
  late Animation<double> _zoomExpandAnimation;
  final ScrollController _navScrollController = ScrollController();

  // Custom objects created by user
  final List<Map<String, String>> _customUserObjects = [];

  // Note Reveal / Unfolding letter state
  bool _showFolderLetter = false;
  DailyCapsule? _selectedMemoryForUnfold;

  // Day 7 walkthrough index
  int _day7WalkthroughRoomIndex = 0;
  String _day7WalkthroughPhase = 'walkthrough';
  
  // Controllers for cinematic transitions
  late AnimationController _blueprintController;
  late AnimationController _realityFadeController;
  late AnimationController _phaseTransitionController; // replaces zoom — smooth fade
  late AnimationController _soundwaveController;
  late AnimationController _materializationController;
  late AnimationController _journeyTimelineController;
  late AnimationController _journeyFocusController;
  // Dream transition controllers (cinematic overlays)
  late AnimationController _dreamTransitionController;
  late AnimationController _portalTransitionController;
  bool _isDreamTransitioning = false;
  bool _isPortalTransitioning = false;
  // Star & Cloud Data for Cinematic Intro
  final List<StarModel> _stars = [];
  final List<CloudModel> _clouds = [];
  final math.Random _random = math.Random();

  // Dialog / Intro Cinematic Text Fading states
  int _introTextStep = 0;
  bool _introTextVisible = true;
  int _step2LineCount = 1; // staggered lines for Step 2 poetry

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay;
    _initializeForDay(_currentDay);

    // Setup visual controllers
    _blueprintController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _realityFadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _phaseTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _soundwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _materializationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _journeyTimelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _journeyFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _dreamTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _portalTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _housePageController = PageController(viewportFraction: 0.76, initialPage: 0);
    _housePageController.addListener(() {
      setState(() {
        _houseCurrentPage = _housePageController.page ?? 0.0;
      });
    });

    _zoomExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _zoomExpandAnimation = Tween<double>(begin: 1.0, end: 4.5).animate(
      CurvedAnimation(
        parent: _zoomExpandController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // Skies for intro screen
    for (int i = 0; i < 25; i++) {
      _stars.add(StarModel(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.5,
        size: 0.5 + _random.nextDouble() * 1.5,
        opacity: 0.2 + _random.nextDouble() * 0.8,
        twinkleSpeed: 0.5 + _random.nextDouble() * 1.5,
        offset: _random.nextDouble() * math.pi * 2,
      ));
    }
    _clouds.add(CloudModel(x: 0.1, y: 0.08, width: 140, height: 40, speed: 0.001, opacity: 0.2));
    _clouds.add(CloudModel(x: 0.6, y: 0.18, width: 180, height: 50, speed: 0.0008, opacity: 0.15));

    // Start intro text timer
    _startIntroCinematicTimeline();
  }

  @override
  void dispose() {
    _housePageController.dispose();
    _zoomExpandController.dispose();
    _blueprintController.dispose();
    _realityFadeController.dispose();
    _phaseTransitionController.dispose();
    _soundwaveController.dispose();
    _materializationController.dispose();
    _navScrollController.dispose();
    _journeyTimelineController.dispose();
    _journeyFocusController.dispose();
    _dreamTransitionController.dispose();
    _portalTransitionController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (!_navScrollController.hasClients) return;
    
    double targetOffset = 0.0;
    if (index == 0) {
      targetOffset = 0.0;
    } else if (index == 1) {
      targetOffset = 30.0;
    } else if (index == 2) {
      targetOffset = 110.0;
    } else if (index == 3) {
      targetOffset = 190.0;
    } else {
      targetOffset = _navScrollController.position.maxScrollExtent;
    }
    
    _navScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  // ── CINEMATIC TIMELINE COORDINATION ──

  void _startIntroCinematicTimeline() {
    // Step 0: "Some homes are built with bricks..."
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _introTextVisible = false;
        });
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _introTextStep = 1;
              _introTextVisible = true;
            });
            // Start sketching blueprint line by line and loop it
            _blueprintController.repeat(reverse: true);
          }
        });
      }
    });

    // Step 1: "...Yours will be built with little moments."
    Timer(const Duration(seconds: 11), () {
      if (mounted) {
        setState(() {
          _introTextVisible = false;
        });
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _introTextStep = 2;
              _introTextVisible = true;
              _step2LineCount = 1;
            });
            // Gradually transition from blueprint sketch to reality (in terms of showing button)
            _realityFadeController.forward();

            // Stagger line 2
            Timer(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _step2LineCount = 2;
                });
              }
            });

            // Stagger line 3
            Timer(const Duration(seconds: 4), () {
              if (mounted) {
                setState(() {
                  _step2LineCount = 3;
                });
              }
            });
          }
        });
      }
    });
  }

  // Action when user clicks "Begin Building Together" — dreamy layered transition
  void _transitionToDayHub() {
    setState(() {
      _isDreamTransitioning = true;
    });

    // Start journey timeline at ~70% so nodes animate while materializing
    Future.delayed(const Duration(milliseconds: 2450), () {
      if (mounted && _isDreamTransitioning) {
        _journeyTimelineController.forward().then((_) {
          if (mounted) {
            _journeyFocusController.forward();
          }
        });
      }
    });

    _dreamTransitionController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _activePhase = _chosenHouseType == null ? 'journey_intro' : 'hub';
          _isDreamTransitioning = false;
        });
        _dreamTransitionController.reset();
      }
    });
  }

  // Final transition from 7-Day Journey to House Selection — golden portal bloom
  void _transitionFromJourneyToSelection() {
    setState(() {
      _isPortalTransitioning = true;
    });

    _portalTransitionController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _activePhase = 'house_selection';
          _isPortalTransitioning = false;
        });
        _portalTransitionController.reset();
      }
    });
  }

  void _initializeForDay(int day) {
    _placedItems.clear();
    _scrapbookCapsules.clear();
    
    final List<String> itemsList = [
      'lamp',
      'monstera',
      'bookshelf',
      'record_player',
      'fairy_lights',
      'memory_frame',
      'coffee',
      'window_rain',
    ];
    
    for (var itemId in itemsList) {
      bool isPlaced = false;
      if (day >= 2 && itemId == 'lamp') isPlaced = true;
      if (day >= 3 && itemId == 'monstera') isPlaced = true;
      if (day >= 4 && itemId == 'bookshelf') isPlaced = true;
      if (day >= 5 && itemId == 'record_player') isPlaced = true;
      if (day >= 6 && itemId == 'fairy_lights') isPlaced = true;
      if (day >= 7) isPlaced = true;
      
      _placedItems.add(PlacedItemState(
        id: itemId,
        isPlaced: isPlaced,
        position: _itemPositions[itemId] ?? Offset.zero,
        scale: isPlaced ? 1.0 : 0.0,
      ));
    }
    
    if (day >= 2) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 1,
        itemId: 'lamp',
        itemName: 'Warm Floor Lamp',
        author: widget.partnerName,
        note: "I thought this lamp would make our nights feel softer.",
        reaction: "❤️",
      ));
    }
    if (day >= 3) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 2,
        itemId: 'monstera',
        itemName: 'Cozy Monstera Plant',
        author: widget.userName,
        note: "Added this cute green monstera leaf! It sways like our garden.",
        reaction: "✨",
      ));
    }
    if (day >= 4) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 3,
        itemId: 'bookshelf',
        itemName: 'Wooden Bookshelf',
        author: widget.partnerName,
        note: "I imagined us reading here together during quiet evenings.",
        reaction: "🫂",
      ));
    }
    if (day >= 5) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 4,
        itemId: 'record_player',
        itemName: 'Vintage Record Player',
        author: widget.userName,
        note: "For late nights listening to our favorite vinyl tunes.",
        reaction: "🌸",
      ));
    }
    if (day >= 6) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 5,
        itemId: 'fairy_lights',
        itemName: 'Twinkling Fairy Lights',
        author: widget.partnerName,
        note: "Brings a tiny spark of starlight to our bedroom walls.",
        reaction: "✨",
      ));
    }
    if (day >= 7) {
      _scrapbookCapsules.add(DailyCapsule(
        day: 6,
        itemId: 'window_rain',
        itemName: 'Rainy Window View',
        author: widget.userName,
        note: "Because rain sounds better when we listen together.",
        reaction: "☾",
      ));
    }
  }

  // Placed a new item — full cinematic materialization pipeline
  void _onItemPlaced(String id, String noteText) {
    // Find item; guard against item not in list (e.g. custom items)
    final int idx = _placedItems.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final itemInfo = _placedItems[idx];
    final friendlyName = _getItemFriendlyName(id);

    // Step 1 — Place item into room at scale 0 (invisible, about to materialize)
    setState(() {
      _placedItems[idx] = itemInfo.copyWith(
        isPlaced: true,
        isNew: true,
        scale: 0.0,
      );
      _scrapbookCapsules.add(DailyCapsule(
        day: _currentDay,
        itemId: id,
        itemName: friendlyName,
        author: _activeRole == 'A' ? widget.userName : widget.partnerName,
        note: noteText,
      ));
    });

    // Step 2 — After a tiny breath pause, begin the bounce-in scale animation
    Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      // Overshoot to 115% then settle at 100%
      setState(() {
        final s = _placedItems.firstWhere((e) => e.id == id);
        _placedItems[_placedItems.indexOf(s)] = s.copyWith(scale: 1.15);
      });
      Timer(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          final s = _placedItems.firstWhere((e) => e.id == id);
          _placedItems[_placedItems.indexOf(s)] = s.copyWith(scale: 0.95);
        });
        Timer(const Duration(milliseconds: 120), () {
          if (!mounted) return;
          setState(() {
            final s = _placedItems.firstWhere((e) => e.id == id);
            _placedItems[_placedItems.indexOf(s)] = s.copyWith(scale: 1.0);
          });
        });
      });
    });

    // Step 3 — Trigger starburst particle explosion at item position
    Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      final position = _itemPositions[id];
      if (position != null) {
        _ambientKey.currentState?.triggerPlacementBurst(position);
      }
    });

    // Step 4 — Show cinematic materialization overlay (warm glow + text)
    Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _lastPlacedItemName = friendlyName;
        _isShowingMaterializationCinematic = true;
      });
      _materializationController.forward(from: 0.0);

      // Dismiss cinematic after 3.5 seconds, then go to turn lock
      Timer(const Duration(milliseconds: 3500), () {
        if (!mounted) return;
        _materializationController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            _isShowingMaterializationCinematic = false;
          });
          // Now transition to the turn lock screen
          Timer(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _activePhase = 'lock';
              });
            }
          });
        });
      });
    });
  }

  String _getItemFriendlyName(String id) {
    switch (id) {
      case 'lamp': return 'Warm Floor Lamp';
      case 'monstera': return 'Cozy Monstera Plant';
      case 'bookshelf': return 'Wooden Bookshelf';
      case 'record_player': return 'Vintage Record Player';
      case 'fairy_lights': return 'Twinkling Fairy Lights';
      case 'memory_frame': return 'Tiny Memory Frame';
      case 'coffee': return 'Cozy Coffee Stool';
      case 'window_rain': return 'Rainy Window View';
      default: return 'Cozy Touch';
    }
  }

  // ── BUILD SCENE PHASES ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight < 150 || constraints.maxWidth < 150) {
            return const SizedBox.shrink();
          }
          return AnimatedBuilder(
            animation: Listenable.merge([
              _dreamTransitionController,
              _portalTransitionController,
            ]),
            builder: (context, _) {
              final dt = _dreamTransitionController.value;
              final pt = _portalTransitionController.value;

              return Stack(
                children: [
                  // Base phase (always rendered)
                  SizedBox.expand(child: _buildActivePhase()),

                  // ── DREAM TRANSITION: Intro → Journey ──
                  if (_isDreamTransitioning) ...[
                    // Warm radial glow bloom (NO black)
                    if (dt > 0.25)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _dreamBloomOpacity(dt),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.6 + dt * 0.8,
                                  colors: [
                                    Color.lerp(const Color(0xFF3D1530), const Color(0xFF2A0E20), dt)!,
                                    Color.lerp(const Color(0xFF1A0818), const Color(0xFF120610), dt)!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Sparkle particles burst
                    if (dt > 0.0 && dt < 0.7)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _SparkleParticlePainter(
                              progress: (dt / 0.7).clamp(0.0, 1.0),
                              centerX: 0.5,
                              centerY: 0.78,
                            ),
                          ),
                        ),
                      ),
                    // Dreamy fog sweep
                    if (dt > 0.3 && dt < 0.95)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DreamyFogPainter(
                              progress: ((dt - 0.3) / 0.65).clamp(0.0, 1.0),
                              warmth: 0.7,
                            ),
                          ),
                        ),
                      ),
                    // Journey screen materializing from warm glow
                    if (dt > 0.65)
                      Positioned.fill(
                        child: Opacity(
                          opacity: ((dt - 0.65) / 0.35).clamp(0.0, 1.0),
                          child: SizedBox.expand(child: _buildJourneyIntroScreen()),
                        ),
                      ),
                  ],

                  // ── PORTAL TRANSITION: Journey → House Selection ──
                  if (_isPortalTransitioning) ...[
                    // Golden glow bloom from Day 1 position
                    if (pt > 0.15)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _portalBloomOpacity(pt),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(-0.82, -0.08),
                                  radius: 0.3 + pt * 1.8,
                                  colors: [
                                    Color.lerp(const Color(0xFF3D2A10), const Color(0xFF2A1A08), pt)!,
                                    Color.lerp(const Color(0xFF180C16), const Color(0xFF100610), pt)!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Sparkle particles around Day 1
                    if (pt > 0.0 && pt < 0.6)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _SparkleParticlePainter(
                              progress: (pt / 0.6).clamp(0.0, 1.0),
                              centerX: 0.08,
                              centerY: 0.45,
                            ),
                          ),
                        ),
                      ),
                    // Golden fog sweep
                    if (pt > 0.25 && pt < 0.9)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DreamyFogPainter(
                              progress: ((pt - 0.25) / 0.65).clamp(0.0, 1.0),
                              warmth: 1.0,
                            ),
                          ),
                        ),
                      ),
                    // House selection materializing from golden glow
                    if (pt > 0.6)
                      Positioned.fill(
                        child: Opacity(
                          opacity: ((pt - 0.6) / 0.4).clamp(0.0, 1.0),
                          child: SizedBox.expand(child: _buildHouseSelectionScreen()),
                        ),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Bloom opacity curves — rise to full, then fade as new screen materializes
  double _dreamBloomOpacity(double t) {
    if (t < 0.5) return ((t - 0.25) / 0.25).clamp(0.0, 1.0);
    if (t < 0.75) return 1.0;
    return (1.0 - ((t - 0.75) / 0.25)).clamp(0.0, 1.0);
  }

  double _portalBloomOpacity(double t) {
    if (t < 0.45) return ((t - 0.15) / 0.3).clamp(0.0, 1.0);
    if (t < 0.7) return 1.0;
    return (1.0 - ((t - 0.7) / 0.3)).clamp(0.0, 1.0);
  }

  Widget _buildActivePhase() {
    switch (_activePhase) {
      case 'intro':               return _buildIntroCinematic();
      case 'journey_intro':       return _buildJourneyIntroScreen();
      case 'house_selection':     return _buildHouseSelectionScreen();
      case 'house_materializing': return _buildHouseMaterializingScreen();
      case 'hub':                 return _buildDayHubScreen();
      case 'lock':                return _buildTurnLockScreen();
      case 'scrapbook':           return _buildScrapbookScreen();
      case 'day7_walkthrough':    return _buildDay7WalkthroughScreen();
      case 'day7_reveal':         return _buildDay7RevealScreen();
      default:                    return _buildDayHubScreen();
    }
  }

  // ── DAY 1: HOUSE SELECTION SCREEN ──
            Widget _buildHouseSelectionScreen() {
    final List<Map<String, dynamic>> houseOptions = [
      {
        'type': 'Beach House',
        'desc': 'Ocean breeze, warm sunsets, and peaceful waves around us',
        'color': const Color(0xFF7FA2CE),
      },
      {
        'type': 'Cozy Apartment',
        'desc': 'Soft city lights, rainy evenings, warm coffee nights',
        'color': const Color(0xFFDD8F9F),
      },
      {
        'type': 'Modern Villa',
        'desc': 'Luxury simplicity, glass walls and golden sunsets',
        'color': const Color(0xFFFFCC66),
      },
      {
        'type': 'Cabin Retreat',
        'desc': 'Hidden in nature, surrounded by forests and calm skies',
        'color': const Color(0xFF9E7E5A),
      },
      {
        'type': 'Futuristic Sky Home',
        'desc': 'A dreamy world above the clouds, filled with lights and wonder',
        'color': const Color(0xFFB388FF),
      },
    ];

    // Find index of currently selected option to keep dot indicators in sync
    final activeIndex = houseOptions.indexWhere((e) => e['type'] == _chosenHouseType).clamp(0, houseOptions.length - 1);
    final activeItem = houseOptions[activeIndex];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C010D), Color(0xFF190924), Color(0xFF08010A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Floating Glow Blob 1 (Soft pink highlight)
            AnimatedBuilder(
              animation: _soundwaveController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -120 + 35 * math.sin(_soundwaveController.value * math.pi * 2),
                      left: -60 + 25 * math.cos(_soundwaveController.value * math.pi * 2),
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFF7D6FF).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100 + 25 * math.cos(_soundwaveController.value * math.pi * 2),
                      right: -60 + 35 * math.sin(_soundwaveController.value * math.pi * 2),
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD89B).withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Drifting stars and cloud outlines in the background
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WarmSkyPainter(
                    stars: _stars,
                    clouds: _clouds,
                    tick: DateTime.now().millisecondsSinceEpoch / 5000.0,
                  ),
                ),
              ),
            ),

            // Main vertical layout containing all content (Single Column prevents overlap!)
            AnimatedBuilder(
              animation: _zoomExpandController,
              builder: (context, child) {
                final double uiOpacity = (1.0 - _zoomExpandController.value * 1.5).clamp(0.0, 1.0);
                return Opacity(
                  opacity: uiOpacity,
                  child: child,
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // 1. TOP HEADER SECTION (Disney / Journey style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border_purple500_rounded, size: 10, color: const Color(0xFFFFD89B).withOpacity(0.7)),
                            const SizedBox(width: 6),
                            const Text(
                              'DAY 1 — OUR DREAM',
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.5,
                                color: Color(0xFFFFD89B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.star_border_purple500_rounded, size: 10, color: const Color(0xFFFFD89B).withOpacity(0.7)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose your dream world',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Every world carries a feeling, a future, and memories to build',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFC5B4D0),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 2. MIDDLE AREA: LARGE IMMERSIVE FLOATING ENVIRONMENT (No borders, 65% width)
                  // Placed inside Column directly so it can never overlap with headers or footer!
                  SizedBox(
                    height: 310,
                    child: PageView.builder(
                      controller: _housePageController,
                      itemCount: houseOptions.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _chosenHouseType = houseOptions[idx]['type'];
                        });
                        _scrollToIndex(idx);
                      },
                      itemBuilder: (context, index) {
                        final item = houseOptions[index];
                        final isSelected = _chosenHouseType == item['type'];

                        return AnimatedBuilder(
                          animation: Listenable.merge([_housePageController, _soundwaveController, _zoomExpandController]),
                          builder: (context, child) {
                            double pageOffset = 0.0;
                            if (_housePageController.position.haveDimensions) {
                              pageOffset = _housePageController.page! - index;
                            } else {
                              pageOffset = (index - _houseCurrentPage).toDouble();
                            }

                            // bobbing — completely removed tilting/floating motion to keep layout perfectly stable and aesthetic
                            final double bobOffset = 0.0;
                            // parallax
                            final double slideOffset = pageOffset * 65.0;
                            // transitions
                            final double scaleVal = (1.0 - (pageOffset.abs() * 0.15)).clamp(0.8, 1.0);
                            final double opacityVal = (1.0 - (pageOffset.abs() * 0.75)).clamp(0.0, 1.0);
                            // selection rise
                            final double riseOffset = _zoomExpandController.value * -40.0;
                            final double driftScale = 1.0 + (_zoomExpandController.value * 0.04);

                            return Opacity(
                              opacity: opacityVal,
                              child: Transform.translate(
                                offset: Offset(slideOffset, bobOffset + riseOffset),
                                child: Transform.scale(
                                  scale: scaleVal * driftScale,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: SizedBox(
                              width: 320,
                              height: 310,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: item['color'].withOpacity(0.18),
                                          blurRadius: isSelected ? 48 : 28,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 280,
                                    height: 280,
                                    child: CustomPaint(
                                      painter: _GhibliPreviewPainter(
                                        houseType: item['type'],
                                        animationTime: _soundwaveController.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // 3. TITLE OF CHOSEN WORLD & DESCRIPTIVE SUBTITLE (Directly below images!)
                  SizedBox(
                    height: 72,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        key: ValueKey(_chosenHouseType),
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activeItem['type'],
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeItem['desc'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFF7D6FF),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. FLOATING WORLD NAVIGATION (REEL)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _navScrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(houseOptions.length, (index) {
                          final isSel = _chosenHouseType == houseOptions[index]['type'];
                          return GestureDetector(
                            onTap: () {
                              _housePageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutQuad,
                              );
                              setState(() {
                                _chosenHouseType = houseOptions[index]['type'];
                              });
                              _scrollToIndex(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: isSel 
                                    ? const Color(0xFFFFD89B).withOpacity(0.12)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSel 
                                      ? const Color(0xFFFFD89B).withOpacity(0.4)
                                      : Colors.transparent,
                                  width: 1.0,
                                ),
                                boxShadow: isSel ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD89B).withOpacity(0.08),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ] : [],
                              ),
                              child: Text(
                                houseOptions[index]['type'],
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? const Color(0xFFFFD89B) : Colors.white.withOpacity(0.45),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 5. SHIMMERING FLOATING CTA (Breathing text shimmer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GestureDetector(
                      onTap: _startHouseMaterialization,
                      child: AnimatedBuilder(
                        animation: _soundwaveController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 13,
                                  color: const Color(0xFFFFD89B).withOpacity(0.55 + 0.45 * math.sin(_soundwaveController.value * math.pi)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Continue Dreaming",
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 1.5,
                                    color: const Color(0xFFFFECCC),
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFFFFD89B).withOpacity(0.4 * math.sin(_soundwaveController.value * math.pi)),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 13,
                                  color: const Color(0xFFFFD89B).withOpacity(0.55 + 0.45 * math.sin(_soundwaveController.value * math.pi)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection screen-wide warm stardust mist transition overlay
            if (_zoomExpandController.value > 0.0)
              IgnorePointer(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF0C010D).withOpacity((_zoomExpandController.value * 1.25).clamp(0.0, 1.0)),
                  child: Center(
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFD89B).withOpacity(0.35 * _zoomExpandController.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  
  // ── HOUSE MATERIALIZATION SEQUENTIAL BUILDER ──
  void _startHouseMaterialization() {
    _zoomExpandController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _activePhase = 'house_materializing';
          _houseMaterializationProgress = 0.0;
          _materializationStep = 0;
        });

        // Animate steps sequentially every 600ms
        Timer.periodic(const Duration(milliseconds: 600), (timer) {
          if (!mounted || _activePhase != 'house_materializing') {
            timer.cancel();
            return;
          }
          setState(() {
            _materializationStep++;
            _houseMaterializationProgress = (_materializationStep / 8).clamp(0.0, 1.0);
          });

          if (_materializationStep >= 8) {
            timer.cancel();
            // Fully loaded: pause for 1.2 seconds, then go to Hub!
            Timer(const Duration(milliseconds: 1200), () {
              if (mounted) {
                setState(() {
                  _activePhase = 'hub';
                  // reset zoom
                  _zoomExpandController.reset();
                });
              }
            });
          }
        });
      }
    });
  }

  Widget _buildHouseMaterializingScreen() {
    final List<String> buildSteps = [
      'Soft blueprint lines appearing...',
      'Wood floor textures slowly sketching...',
      'Cozy plaster walls rising upward...',
      'Windows locking in position...',
      'Soft amber lighting breathing life inside...',
      'Cozy handcrafted curtains draping gently...',
      'Glowing twilight dust floating upward...',
      'Setting room atmosphere & depth...'
    ];

    final activeText = _materializationStep < buildSteps.length
        ? buildSteps[_materializationStep]
        : 'Welcome home...';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF070205),
      child: Stack(
        children: [
          // Render blueprint environment building itself in background
          Positioned.fill(
            child: AmbientEnvironmentController(
              items: const [],
              isBlueprintMode: true,
              blueprintProgress: _houseMaterializationProgress,
            ),
          ),

          // Central status modal
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F050A).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFFFCC66).withOpacity(0.15),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFCC66).withOpacity(0.04),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spinning glowing indicator
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: _houseMaterializationProgress,
                        color: const Color(0xFFFFCC66),
                        strokeWidth: 3,
                        backgroundColor: const Color(0xFF381928),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'MATERIALIZING SHARED DREAM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _chosenHouseType ?? 'Shared House',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        activeText,
                        key: ValueKey(activeText),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFDD8F9F),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _houseMaterializationProgress,
                        color: const Color(0xFFFFCC66),
                        backgroundColor: const Color(0xFF1E0B16),
                        minHeight: 4,
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

  // ── 0. INTRO CINEMATIC GRAPHICS — warm dark-sky aesthetic ──

  Widget _buildIntroCinematic() {
    // Use LayoutBuilder to get real bounded constraints before building
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final availH = outerConstraints.maxHeight.isFinite
            ? outerConstraints.maxHeight
            : MediaQuery.of(context).size.height;
        final availW = outerConstraints.maxWidth.isFinite
            ? outerConstraints.maxWidth
            : MediaQuery.of(context).size.width;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _blueprintController,
            _realityFadeController,
            _soundwaveController,
            _dreamTransitionController,
          ]),
          builder: (context, child) {
            // Safe padding insets
            final mq = MediaQuery.of(context);
            final topPad = mq.padding.top + 24.0;
            final bottomPad = mq.padding.bottom + 24.0;
            final innerH = (availH - topPad - bottomPad).clamp(100.0, double.infinity);

            // SizedBox.expand guarantees the inner Stack always gets
            // tight constraints, preventing Positioned.fill from
            // inheriting a zero-height Stack.
            return SizedBox(
              width: availW,
              height: availH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer A: Deep dreamy gradient sky with floating particles, fog and stars
                  CustomPaint(
                    painter: _WarmSkyPainter(
                      stars: _stars,
                      clouds: _clouds,
                      tick: DateTime.now().millisecondsSinceEpoch / 5000.0,
                    ),
                  ),

                  // Layer B: Magical floating glowing house outline with breathing glow and tiny sketched memories
                  Opacity(
                    opacity: ((_blueprintController.value * 2) + _dreamTransitionController.value * 0.5).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.0 + 4.0 * Curves.easeInOutCubic.transform(_dreamTransitionController.value),
                      child: Transform.rotate(
                        angle: _dreamTransitionController.value * 0.08,
                        child: CustomPaint(
                          painter: _WarmHouseSilhouettePainter(
                            progress: _blueprintController.value,
                            breathe: 0.85 + 0.15 * math.sin(_soundwaveController.value * math.pi * 2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // (Black overlay removed — warm glow bloom is rendered by build())

                  // Layer D: UI overlay — uses explicit heights, no Spacer, fades out quickly when button is clicked
                  Positioned(
                    left: 32,
                    right: 32,
                    top: topPad,
                    bottom: bottomPad,
                    child: IgnorePointer(
                      ignoring: _dreamTransitionController.value > 0.0,
                      child: Opacity(
                        opacity: (1.0 - (_dreamTransitionController.value / 0.35)).clamp(0.0, 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Soundwave indicator
                          Row(
                            children: [
                              const Text(
                                "♫ SOFT AMBIENT PIANO & RAIN",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E4E5A),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ...List.generate(5, (index) {
                                final barH = (4.0 +
                                        8.0 *
                                            math.sin(
                                                _soundwaveController.value *
                                                        math.pi +
                                                    index))
                                    .clamp(2.0, 16.0);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5),
                                  width: 2,
                                  height: barH,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDD8F9F)
                                        .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                );
                              }),
                            ],
                          ),

                          // Explicit gap shifted upward (≈ 12 % of available inner height)
                          SizedBox(height: innerH * 0.12),

                          // Cinematic text
                          AnimatedOpacity(
                            opacity: _introTextVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            child: _buildIntroCalligraphyText(),
                          ),

                          // Explicit gap (≈ 48 % of inner height to complement the centered upward text)
                          SizedBox(height: innerH * 0.48),

                          // "✨ Begin Building Together" glassmorphic button with floating motion
                          if (_realityFadeController.value > 0.4)
                            Center(
                              child: AnimatedOpacity(
                                opacity: ((_realityFadeController.value -
                                            0.4) *
                                        2)
                                    .clamp(0.0, 1.0),
                                duration: const Duration(milliseconds: 500),
                                child: AnimatedBuilder(
                                  animation: _soundwaveController,
                                  builder: (context, child) {
                                    final double floatVal = math.sin(_soundwaveController.value * math.pi * 2);
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(32),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDD8F9F).withOpacity(0.15 + 0.08 * floatVal.abs()),
                                            blurRadius: 20 + 8 * floatVal.abs(),
                                            spreadRadius: 2 + 1.5 * floatVal.abs(),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                          child: ElevatedButton(
                                            onPressed: _transitionToDayHub,
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                              backgroundColor: const Color(0xFF220A1E).withOpacity(0.45),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32),
                                                side: BorderSide(
                                                  color: const Color(0xFFFFCC66).withOpacity(0.6 + 0.2 * floatVal),
                                                  width: 1.2,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              "✨ Begin Building Together",
                                              style: TextStyle(
                                                fontFamily: 'Georgia',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFFFFCC66),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ), // Closes Positioned
              ],
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildIntroCalligraphyText() {
    if (_introTextStep == 0) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: double.infinity),
          Text(
            "Some homes are built",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          Text(
            "with bricks...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xFFDD8F9F),
              height: 1.2,
            ),
          ),
        ],
      );
    } else if (_introTextStep == 1) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: double.infinity),
          Text(
            "Yours will be built",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          Text(
            "with little moments.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xFFFFCC66),
              height: 1.2,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          const Text(
            "For the next 7 days...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _step2LineCount >= 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1200),
            child: const Text(
              "leave little pieces of love...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color(0xFFFFCC66),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _step2LineCount >= 3 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1200),
            child: const Text(
              "for each other here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color(0xFFDD8F9F),
                height: 1.3,
              ),
            ),
          ),
        ],
      );
    }
  }

  // ── JOURNEY INTRO CINEMATIC (7-DAY TRANSITION) ──
  Widget _buildJourneyIntroScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availH = constraints.maxHeight.isFinite ? constraints.maxHeight : MediaQuery.of(context).size.height;
        final availW = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _journeyTimelineController,
            _journeyFocusController,
            _soundwaveController,
            _portalTransitionController,
          ]),
          builder: (context, child) {
            final t = _journeyTimelineController.value;
            final f = _journeyFocusController.value;
            final floatVal = math.sin(_soundwaveController.value * math.pi * 2);

            return SizedBox(
              width: availW,
              height: availH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer A: Dreamy dark sky with particles
                  CustomPaint(
                    painter: _WarmSkyPainter(
                      stars: _stars,
                      clouds: _clouds,
                      tick: DateTime.now().millisecondsSinceEpoch / 5000.0,
                    ),
                  ),

                  // Layer B: The Glowing Horizontal Timeline and Nodes (fades during portal transition)
                  Opacity(
                    opacity: (1.0 - (_portalTransitionController.value / 0.5)).clamp(0.0, 1.0),
                    child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Journey Line & Nodes
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // The connecting line
                              Positioned(
                                left: 14,
                                right: 14,
                                top: 6, // center of the 14px dot
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: t.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFFFCC66).withOpacity(0.6),
                                            const Color(0xFFFFCC66).withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // The 7 nodes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  // Staggered appearance based on t
                                  final staggerStart = index * 0.12;
                                  final nodeOpacity = ((t - staggerStart) / 0.25).clamp(0.0, 1.0);
                                  
                                  // For Day 1 (index == 0), apply the focus bloom based on f
                                  final isDay1 = index == 0;
                                  final bloomOpacity = isDay1 ? 1.0 : (1.0 - (f * 0.7)); // other days dim slightly
                                  final nodeScale = isDay1 ? (1.0 + f * 0.3) : 1.0;
                                  
                                  return Opacity(
                                    opacity: nodeOpacity * bloomOpacity,
                                    child: Transform.scale(
                                      scale: nodeScale,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDay1 
                                                ? const Color(0xFFFFD89B).withOpacity(0.8 + 0.2 * floatVal)
                                                : const Color(0xFFDD8F9F).withOpacity(0.6),
                                              boxShadow: isDay1 ? [
                                                BoxShadow(
                                                  color: const Color(0xFFFFD89B).withOpacity(0.5 * f),
                                                  blurRadius: 16 * f,
                                                  spreadRadius: 4 * f,
                                                )
                                              ] : [],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Day ${index + 1}",
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: isDay1 ? 14 : 11,
                                              fontWeight: isDay1 ? FontWeight.bold : FontWeight.normal,
                                              color: isDay1 
                                                  ? const Color(0xFFFFD89B)
                                                  : Colors.white.withOpacity(0.6),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          
                          // Focus Text for Day 1
                          AnimatedOpacity(
                            opacity: f,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                const SizedBox(height: 70),
                                const Text(
                                  "Day 1 — Choose Your Dream World",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Every world carries a feeling, a future, and memories to build",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFFFFCC66).withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 70),
                                
                                // Premium Continue Button
                                GestureDetector(
                                  onTap: _transitionFromJourneyToSelection,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      color: const Color(0xFF220A1E).withOpacity(0.5),
                                      border: Border.all(
                                        color: const Color(0xFFFFCC66).withOpacity(0.6 + 0.2 * floatVal),
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFCC66).withOpacity(0.15 + 0.05 * floatVal),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 16,
                                          color: const Color(0xFFFFCC66).withOpacity(0.8 + 0.2 * floatVal),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          "Continue",
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFCC66),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  // (Black overlay removed — golden glow bloom handled by Stack build())
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── 1. MAIN ROOM AND TIMELINE DISPLAY (DAY HUB) ──

  Widget _buildDayHubScreen() {
    // Check if Partner has added something glowing today (Day 4)
    final partnerAddedItem = _scrapbookCapsules.firstWhere(
      (e) => e.day == _currentDay - 1 && e.author == widget.partnerName,
      orElse: () => DailyCapsule(day: 0, itemId: '', itemName: '', author: '', note: ''),
    );
    
    // Find item state
    final glowItemState = partnerAddedItem.day > 0 
        ? _placedItems.firstWhere((e) => e.id == partnerAddedItem.itemId)
        : null;

    final hasGlowingUnreactedItem = glowItemState != null && partnerAddedItem.reaction.isEmpty;

    return Stack(
      children: [
        // Ghibli cozy reality illustrated environment
        Positioned.fill(
          child: AmbientEnvironmentController(
            key: _ambientKey,
            items: _placedItems,
            currentDay: _currentDay,
            chosenHouseType: _chosenHouseType,
            onItemClicked: () {
              if (hasGlowingUnreactedItem) {
                // Partner B taps glowing item Partner A left -> view and react!
                _showFloatingReactionOverlay(partnerAddedItem);
              } else {
                // Tapping items displays their historic note card in a small popup!
                _showMemoryCapsuleDrawer();
              }
            },
          ),
        ),

        // ── MATERIALIZATION CINEMATIC OVERLAY ──
        if (_isShowingMaterializationCinematic)
          Positioned.fill(
            child: _buildMaterializationOverlay(),
          ),

        if (_showFloatingReactions && _activeReactionCapsule != null)
          Positioned.fill(
            child: _FloatingReactionOverlay(
              capsule: _activeReactionCapsule!,
              onReactionSelected: (emoji) {
                setState(() {
                  // Save reaction
                  _activeReactionCapsule!.reaction = emoji;
                  // Clear glowing highlight state and update reaction string
                  final item = _placedItems.firstWhere((e) => e.id == _activeReactionCapsule!.itemId);
                  _placedItems[_placedItems.indexOf(item)] = item.copyWith(isNew: false, reaction: emoji);
                  _showFloatingReactions = false;
                  _activeReactionCapsule = null;
                });
              },
            ),
          ),

        // Timeline Header overlay
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Timeline bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF866571)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    // Simulation mode switcher
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F0A13).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF381928)),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeRole = _activeRole == 'A' ? 'B' : 'A';
                          });
                          // Reset temporary highlights
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horizontal_circle_outlined, size: 14, color: Color(0xFFFFCC66)),
                            const SizedBox(width: 6),
                            Text(
                              "Role: ${_activeRole == 'A' ? widget.userName : widget.partnerName}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFCC66),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Polaroid Scrapbook button
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined, size: 22, color: Color(0xFFFFCC66)),
                      onPressed: () {
                        setState(() {
                          _activePhase = 'scrapbook';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Elegant Days Timeline
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F050A).withOpacity(0.65),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final isCurrent = day == _currentDay;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentDay = day;
                          _initializeForDay(day);
                          if (day == 7) {
                            _activePhase = 'day7_walkthrough';
                            _day7WalkthroughRoomIndex = 0;
                          } else if (day == 1 && _chosenHouseType == null) {
                            _activePhase = 'house_selection';
                          } else {
                            _activePhase = 'hub';
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF8A2E55) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "D$day",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            fontStyle: isCurrent ? FontStyle.italic : FontStyle.normal,
                            color: isCurrent ? Colors.white : const Color(0xFFDD8F9F),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Glowing Banner notification if partner left a glowing touch
        if (hasGlowingUnreactedItem)
          Positioned(
            left: 24,
            right: 24,
            top: 154,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1927).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCC66).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFCC66).withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_twilight, color: Color(0xFFFFCC66), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.partnerName} left a warm touch!",
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Tap their glowing item in the room to view.",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFFCC66),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bottom CTA drawer trigger
        if (!hasGlowingUnreactedItem)
          Positioned(
            left: 32,
            right: 32,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentDay == 1 && !_isPartnerResponseSimulated)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFCC66).withOpacity(0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showPartnerHandoverOverlay = true;
                                _isPartnerResponseSimulated = true;
                              });
                            },
                            icon: const Icon(Icons.favorite_outline, size: 18, color: Color(0xFFDD8F9F)),
                            label: const Text(
                              "Simulate Partner Choice",
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDD8F9F),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B0712).withOpacity(0.85),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFDD8F9F), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF911746).withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: ElevatedButton.icon(
                        onPressed: _showDecorTrayBottomSheet,
                        icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFFFFCC66)),
                        label: const Text(
                          "Add today's quiet touch",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F0A13).withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Color(0xFF381928), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Fullscreen Partner Handover Cinematic Overlay
        if (_showPartnerHandoverOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showPartnerHandoverOverlay = false;
                });
              },
              child: Container(
                color: const Color(0xFF0F050A).withOpacity(0.93),
                child: Stack(
                  children: [
                    // Moving heart particles background
                    Positioned.fill(
                      child: _PartnerHeartParticlesOverlay(),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "❤️",
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B0712).withOpacity(0.75),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFDD8F9F).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "${widget.partnerName} imagined a peaceful future with you.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Tap anywhere to view our house",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB18E9B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  // Opens decor tray
  void _showDecorTrayBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DreamHouseBottomSheet(
        initialTab: DreamHouseSheetTab.decor,
        placedItemIds: _placedItems.where((e) => e.isPlaced).map((e) => e.id).toList(),
        onNoteSubmitted: (itemId, text) {
          Navigator.pop(context);
          _onItemPlaced(itemId, text);
        },
        onCustomSubmitted: (customDesc, text) {
          Navigator.pop(context);
          _onCustomItemPlaced(customDesc, text);
        },
      ),
    );
  }

  void _onCustomItemPlaced(String customDesc, String text) {
    setState(() {
      _customUserObjects.add({
        'title': customDesc,
        'note': text,
        'day': _currentDay.toString(),
        'x': '180',
        'y': '260',
      });
      
      // Also register custom capsule for scrapbook
      _scrapbookCapsules.add(DailyCapsule(
        day: _currentDay,
        itemId: 'custom_item_${_customUserObjects.length}',
        itemName: customDesc,
        author: widget.userName,
        note: text,
      ));
    });
    
    // Trigger standard materialization cinematic showing our personalized touch!
    _onItemPlaced('memory_frame', "Personal Touch: $customDesc\n\n$text");
  }

  // Opens glowing floating reaction overlay
  void _showFloatingReactionOverlay(DailyCapsule capsule) {
    setState(() {
      _activeReactionCapsule = capsule;
      _showFloatingReactions = true;
    });
  }

  // Show previous memory details in a clean card popup
  void _showMemoryCapsuleDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F050A).withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF381928),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "SHARED MEMORY CAPSULES",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Our Co-Creation History",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Print list
                  ..._scrapbookCapsules.reversed.map((capsule) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F0A13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF381928)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Day ${capsule.day}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFCC66),
                                ),
                              ),
                              const Spacer(),
                              if (capsule.reaction.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14080E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(capsule.reaction, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      const Text("Glow", style: TextStyle(fontSize: 9, color: Color(0xFF866571))),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.wb_twilight, color: Color(0xFFDD8F9F), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                capsule.itemName,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${capsule.note}"',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFD4C4CA),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "— by ${capsule.author}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF5A3C47),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── MATERIALIZATION CINEMATIC OVERLAY ──
  // Shown in the room immediately after an item is placed.
  // It lets the user *feel* the room change before the lock screen appears.

  Widget _buildMaterializationOverlay() {
    return AnimatedBuilder(
      animation: _materializationController,
      builder: (context, child) {
        final opacity = _materializationController.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Stack(
            children: [
              // Warm amber room-wide pulse layer
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _MaterializationAuraPainter(
                      progress: _materializationController.value,
                    ),
                  ),
                ),
              ),

              // Bottom text card — emotional confirmation
              Positioned(
                left: 32,
                right: 32,
                bottom: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F050A).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFFCC66).withOpacity(0.22),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB359).withOpacity(0.10),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing dot indicator
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFCC66).withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFCC66).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'THE ROOM FEELS IT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Color(0xFF9E7E5A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _lastPlacedItemName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'has found its home in your shared space.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF866571),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Your partner will feel this warmth\nwhen they enter tomorrow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5A3C47),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 2. DAY LOCK / TURN LOCK SCREEN ──


  Widget _buildTurnLockScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF070205), Color(0xFF160611), Color(0xFF0F030A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Sleeping glowing house illustration frame
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1F0A13),
                  border: Border.all(color: const Color(0xFF381928), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF911746).withOpacity(0.08),
                      blurRadius: 36,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.nights_stay_outlined,
                        size: 72,
                        color: const Color(0xFFFFCC66).withOpacity(0.12),
                      ),
                      // Animated breathing glowing dot
                      _GlowingHeartIndicator(),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              const Text(
                "YOUR TURN HAS CLOSED SOFTLY",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF9E7E5A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your dream house remembers everything.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Pass the device to your partner, or return tomorrow to see how they quietly co-create your shared world in silence.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF866571),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Navigation button back to dashboard
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Simulate next day progression upon leaving screen
                    setState(() {
                      if (_currentDay < 7) {
                        _currentDay++;
                      }
                      _activeRole = _activeRole == 'A' ? 'B' : 'A';
                      _activePhase = 'hub';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2E55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Return to Dashboard (Simulate Next Day)",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. MEMORY SCRAPBOOK SCREEN (POLAROID) ──

  Widget _buildScrapbookScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF090204),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFFFCC66)),
                    onPressed: () {
                      setState(() {
                        _activePhase = 'hub';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "OUR DREAM MEMORIES",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Polaroids Collage
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                itemCount: _scrapbookCapsules.length,
                itemBuilder: (context, index) {
                  final capsule = _scrapbookCapsules[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 28),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // Polaroid White Card frame!
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Picture Area
                        AspectRatio(
                          aspectRatio: 1.25,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF140A0E), // Ghibli background
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Draw a mini visual vector representation of the item placed!
                                CustomPaint(
                                  painter: _MiniItemPainter(itemId: capsule.itemId),
                                  size: const Size(120, 120),
                                ),
                                // Glowing Reaction
                                if (capsule.reaction.isNotEmpty)
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      child: Text(
                                        capsule.reaction,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 18),

                        // Writing Area
                        Text(
                          "Day ${capsule.day} • ${capsule.itemName}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Color(0xFF6E4E5A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${capsule.note}"',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF1E101D), // Dark text on Polaroid white
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "— ${capsule.author}",
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8A2E55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. DAY 7 CINEMATIC REVEAL & WALKTHROUGH ──

  Widget _buildDay7WalkthroughScreen() {
    if (_day7WalkthroughPhase == 'walkthrough') {
      final highlightDay = _day7WalkthroughRoomIndex + 1;
      
      // Pull capsule details for day
      final capsule = _scrapbookCapsules.firstWhere(
        (e) => e.day == highlightDay,
        orElse: () => DailyCapsule(
          day: highlightDay,
          itemId: 'memory_frame',
          itemName: 'Quiet Touch',
          author: widget.userName,
          note: "A quiet moment we placed together in our dream house.",
        ),
      );

      return Container(
        color: const Color(0xFF0C070D),
        child: Stack(
          children: [
            // Cozy animated backdrop
            Positioned.fill(
              child: AmbientEnvironmentController(
                items: _placedItems,
                currentDay: highlightDay,
                chosenHouseType: _chosenHouseType,
              ),
            ),

            // Heart bursts floating in from bottom
            Positioned.fill(
              child: _PartnerHeartParticlesOverlay(),
            ),

            // Top Progress bar
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: List.generate(6, (index) {
                        final isPast = index < _day7WalkthroughRoomIndex;
                        final isCurrent = index == _day7WalkthroughRoomIndex;
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isPast
                                  ? const Color(0xFFFFCC66)
                                  : isCurrent
                                      ? const Color(0xFFDD8F9F)
                                      : Colors.white24,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Glassmorphic blurred memory card
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 48),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0712).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF911746).withOpacity(0.15),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "DAY $highlightDay — THEME OF ${_getThemeNameForDay(highlightDay)}",
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFFFFCC66),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        capsule.itemName,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"${capsule.note}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFE5D4DC),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "— lovingly placed by ${capsule.author}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD8F9F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_day7WalkthroughRoomIndex < 5) {
                                _day7WalkthroughRoomIndex++;
                              } else {
                                _day7WalkthroughPhase = 'environmental_shift';
                                _startAtmosphereCycleTimer();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2E55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            _day7WalkthroughRoomIndex < 5 ? "Next Quiet Touch ➔" : "View Shifting Skies ➔",
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
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
    } else if (_day7WalkthroughPhase == 'environmental_shift') {
      return Container(
        color: const Color(0xFF0F050A),
        child: Stack(
          children: [
            Positioned.fill(
              child: AmbientEnvironmentController(
                items: _placedItems,
                currentDay: _currentDay,
                chosenHouseType: _chosenHouseType,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F050A).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFFCC66).withOpacity(0.18)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "🌄",
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Not Just a House. A Feeling.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "You spent 7 days building a future together — one quiet moment at a time. Watch the light change as your space lives.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFDD8F9F),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _day7WalkthroughPhase = 'relationship_card';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2E55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text(
                            "See Our Bond Card ➔",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
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
    } else if (_day7WalkthroughPhase == 'relationship_card') {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0C070D), Color(0xFF1E0A13), Color(0xFF0C070D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _PartnerHeartParticlesOverlay(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF911746).withOpacity(0.1),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "EDITORIAL RELATIONSHIP CARD",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                          color: Color(0xFFFFCC66),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "COZY SOULS",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),
                      const Text(
                        "Yours is a bond built slowly, crafted from morning coffee steam, rain listened to together, and floor lamps glowing late into the night. You create space for comfort and quiet connection.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFE0C9D3),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _day7WalkthroughPhase = 'scrapbook_timeline';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2E55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: const Text(
                            "Open Scrapbook Timeline ➔",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
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
    } else {
      // 'scrapbook_timeline'
      return Container(
        color: const Color(0xFF0F050A),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "OUR MEMORY TIMELINE",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;
                    
                    // Pull item details
                    final capsule = _scrapbookCapsules.firstWhere(
                      (e) => e.day == dayNum,
                      orElse: () => DailyCapsule(
                        day: dayNum,
                        itemId: 'memory_frame',
                        itemName: 'Dream House Selection',
                        author: widget.userName,
                        note: "Our journey began. We started choosing the feeling of our dream house together.",
                      ),
                    );

                    final rotAngle = index % 2 == 0 ? -0.03 : 0.04;

                    return Column(
                      children: [
                        Transform.rotate(
                          angle: rotAngle,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF140A0E),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        painter: _MiniItemPainter(itemId: capsule.itemId),
                                        size: const Size(80, 80),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "DAY $dayNum — ${capsule.itemName}",
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A2E55),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '"${capsule.note}"',
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (dayNum < 7)
                          Container(
                            width: 2,
                            height: 32,
                            color: const Color(0xFFFFCC66).withOpacity(0.3),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _activePhase = 'hub';
                        _currentDay = 7;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2E55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      "Return to Dream House ➔",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDay7RevealScreen() {
    return _buildDay7WalkthroughScreen();
  }

  String _getThemeNameForDay(int day) {
    switch (day) {
      case 1: return "DREAM FUTURE";
      case 2: return "COMFORT";
      case 3: return "CARE";
      case 4: return "INTIMACY";
      case 5: return "GROWTH";
      case 6: return "FOREVER";
      default: return "HOME";
    }
  }

  void _startAtmosphereCycleTimer() {
    int count = 2;
    Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (!mounted || _day7WalkthroughPhase != 'environmental_shift') {
        timer.cancel();
        return;
      }
      setState(() {
        _currentDay = count;
        count = count < 7 ? count + 1 : 2;
      });
    });
  }
}

// ── HEART PARTICLES WIDGETS ──

class _PartnerHeartParticlesOverlay extends StatefulWidget {
  @override
  State<_PartnerHeartParticlesOverlay> createState() => _PartnerHeartParticlesOverlayState();
}

class _PartnerHeartParticlesOverlayState extends State<_PartnerHeartParticlesOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_HeartParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < 20; i++) {
      _particles.add(_HeartParticle(
        x: _random.nextDouble() * 360,
        y: 480 + _random.nextDouble() * 200,
        speed: 0.8 + _random.nextDouble() * 1.5,
        size: 8.0 + _random.nextDouble() * 12.0,
        swaySpeed: 1.0 + _random.nextDouble() * 2.0,
        swayWidth: 4.0 + _random.nextDouble() * 8.0,
        color: i % 2 == 0 ? const Color(0xFFDD8F9F) : const Color(0xFFFF8B94),
      ));
    }
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
          painter: _HeartParticlesPainter(_particles, _controller.value),
        );
      },
    );
  }
}

class _HeartParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final double swaySpeed;
  final double swayWidth;
  final Color color;

  _HeartParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.swaySpeed,
    required this.swayWidth,
    required this.color,
  });
}

class _HeartParticlesPainter extends CustomPainter {
  final List<_HeartParticle> particles;
  final double progress;

  _HeartParticlesPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 360;
    final scaleY = size.height / 480;
    
    for (var p in particles) {
      // Float up
      p.y -= p.speed * scaleY;
      if (p.y < -20) {
        p.y = size.height + 20;
      }
      
      // Sway left-right
      final sway = math.sin(progress * p.swaySpeed * math.pi * 2) * p.swayWidth * scaleX;
      final currentX = (p.x + sway).clamp(0.0, size.width);
      
      final paint = Paint()..color = p.color.withOpacity(0.55);
      
      // Draw a simple heart path
      final heartPath = Path();
      final double width = p.size;
      final double height = p.size;
      heartPath.moveTo(currentX, p.y);
      heartPath.cubicTo(currentX - width / 2, p.y - height / 2, currentX - width, p.y + height / 3, currentX, p.y + height);
      heartPath.cubicTo(currentX + width, p.y + height / 3, currentX + width / 2, p.y - height / 2, currentX, p.y);
      heartPath.close();
      
      canvas.drawPath(heartPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartParticlesPainter oldDelegate) => true;
}

// ── CUSTOM CINEMATIC PAINTERS ──

// Warm ambient pulse that fills the room when an item materializes
class _MaterializationAuraPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _MaterializationAuraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // Ease: rise fast, hold, fade slowly
    final fadeOpacity = progress < 0.15
        ? progress / 0.15 // fade in quickly
        : progress > 0.75
            ? (1.0 - (progress - 0.75) / 0.25).clamp(0.0, 1.0) // fade out
            : 1.0;

    // Expanding warm radial glow from center of room (slightly above center)
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final maxRadius = size.longestSide * 1.2;
    final currentRadius = maxRadius * (0.2 + 0.8 * progress);

    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFB359).withOpacity(0.18 * fadeOpacity),
        const Color(0xFFDD8F9F).withOpacity(0.08 * fadeOpacity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    canvas.drawCircle(
      center,
      currentRadius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: currentRadius),
        )
        ..blendMode = BlendMode.screen,
    );

    // Soft vignette darkening at the edges to make center pop
    final vignetteGradient = RadialGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF050205).withOpacity(0.3 * fadeOpacity),
      ],
      stops: const [0.5, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = vignetteGradient.createShader(
          Rect.fromCircle(center: center, radius: size.longestSide),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _MaterializationAuraPainter old) =>
      old.progress != progress;
}

// Warm romantic dark sky for the intro cinematic
class _WarmSkyPainter extends CustomPainter {

  final List<StarModel> stars;
  final List<CloudModel> clouds;
  final double tick;

  _WarmSkyPainter({
    required this.stars,
    required this.clouds,
    required this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Deep dreamy gradient: midnight blue, dusty purple, deep lavender, warm soft pink glow
    final skyGradient = LinearGradient(
      colors: const [
        Color(0xFF0A0B1E), // midnight blue top
        Color(0xFF221136), // dusty purple mid-top
        Color(0xFF3B1E4A), // deep lavender mid-bottom
        Color(0xFF5E2D4E), // warm soft pink-rose bottom
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawPaint(Paint()..shader = skyGradient.createShader(rect));

    // Warm amber/rose stars — not cold white
    for (var star in stars) {
      final twinkle = (0.3 + 0.7 * math.sin(tick * math.pi * 2 * star.twinkleSpeed + star.offset)).clamp(0.0, 1.0);
      final opacity = (star.opacity * twinkle).clamp(0.0, 1.0);
      final starColor = star.offset > math.pi
          ? const Color(0xFFFFE4C4).withOpacity(opacity) // warm amber
          : const Color(0xFFFFCCDD).withOpacity(opacity); // soft rose
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        Paint()..color = starColor,
      );
    }

    // Soft rose-violet clouds
    for (var cloud in clouds) {
      final cloudPaint = Paint()
        ..color = const Color(0xFF4A1E38).withOpacity(cloud.opacity * 0.8);
      canvas.drawOval(
        Rect.fromLTWH(cloud.x * size.width, cloud.y * size.height, cloud.width, cloud.height),
        cloudPaint,
      );
    }

    // Draw 15 slow-drifting floating soft light particles (dreamy void/fog effect)
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 15; i++) {
      // Proportional placement based on seed
      final double seedX = (0.15 * i + 0.2) % 1.0;
      final double seedY = (0.25 * i + 0.3) % 1.0;
      
      // Gentle floating motion using tick
      final double driftX = 12 * math.sin(tick * math.pi * 2 + i);
      final double driftY = -40 * (tick + i * 0.05) % size.height; // floating upward slowly
      
      final double px = (seedX * size.width + driftX) % size.width;
      final double py = (seedY * size.height + driftY) % size.height;
      final double pSize = 1.5 + 1.5 * math.sin(tick * math.pi * 2 + i * 1.5);
      
      particlePaint.color = const Color(0xFFFFCCDD).withOpacity(0.25 + 0.2 * math.sin(tick * math.pi * 1.5 + i));
      canvas.drawCircle(Offset(px, py), pSize, particlePaint);
    }

    // Warm bottom vignette for depth
    final vignetteGradient = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF150610).withOpacity(0.6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(
      rect,
      Paint()..shader = vignetteGradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Warm amber/rose house silhouette — replaces the harsh cyan blueprint
class _WarmHouseSilhouettePainter extends CustomPainter {
  final double progress;
  final double breathe;

  _WarmHouseSilhouettePainter({
    required this.progress,
    required this.breathe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx = size.width * 0.5;
    final cy = size.height * 0.55;
    final scale = size.width / 360;

    // Warm amber glow line style
    final glowPaint = Paint()
      ..color = const Color(0xFFFFB359).withOpacity(0.18 * progress.clamp(0.0, 1.0) * breathe)
      ..strokeWidth = 8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final linePaint = Paint()
      ..color = const Color(0xFFDD8F9F).withOpacity(0.55 * progress.clamp(0.0, 1.0) * breathe)
      ..strokeWidth = 1.4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // House silhouette path centered on screen
    final houseW = 160 * scale;
    final houseH = 140 * scale;
    final roofH = 70 * scale;

    // Roof triangle
    final roofPath = Path()
      ..moveTo(cx - houseW / 2, cy - houseH / 2 + roofH)
      ..lineTo(cx, cy - houseH / 2 - roofH * 0.4)
      ..lineTo(cx + houseW / 2, cy - houseH / 2 + roofH);

    // Body rectangle
    final bodyPath = Path()
      ..addRect(Rect.fromCenter(
        center: Offset(cx, cy + roofH * 0.2),
        width: houseW,
        height: houseH,
      ));

    // Window
    final winPath = Path()
      ..addRect(Rect.fromCenter(
        center: Offset(cx, cy - roofH * 0.1),
        width: houseW * 0.3,
        height: houseH * 0.3,
      ));

    // Door
    final doorPath = Path()
      ..addRect(Rect.fromCenter(
        center: Offset(cx, cy + houseH * 0.35),
        width: houseW * 0.22,
        height: houseH * 0.42,
      ));

    // Animate progress along paths
    final p = progress.clamp(0.0, 1.0);
    void drawAnimatedPath(Path path) {
      final metrics = path.computeMetrics().toList();
      for (final metric in metrics) {
        final extract = metric.extractPath(0, metric.length * p);
        canvas.drawPath(extract, glowPaint);
        canvas.drawPath(extract, linePaint);
      }
    }

    drawAnimatedPath(roofPath);
    drawAnimatedPath(bodyPath);
    if (progress > 0.5) {
      final innerP = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final winPaint = linePaint..color = const Color(0xFFFFCC66).withOpacity(0.5 * innerP * breathe);
      final metrics = winPath.computeMetrics().toList();
      for (final m in metrics) {
        canvas.drawPath(m.extractPath(0, m.length * innerP), winPaint);
        canvas.drawPath(doorPath, linePaint..color = const Color(0xFFDD8F9F).withOpacity(0.4 * innerP * breathe));
      }
    }

    // Draw tiny transparent sketches of future memories inside the house outline
    final sketchPaint = Paint()
      ..color = const Color(0xFFDD8F9F).withOpacity(0.25 * progress.clamp(0.0, 1.0) * breathe)
      ..strokeWidth = 1.2 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Tiny Heart (left side of doorway)
    final heartPath = Path();
    final hx = cx - 24 * scale;
    final hy = cy + 12 * scale;
    heartPath.moveTo(hx, hy + 4 * scale);
    heartPath.cubicTo(hx - 5 * scale, hy - 2 * scale, hx - 10 * scale, hy + 3 * scale, hx, hy + 10 * scale);
    heartPath.cubicTo(hx + 10 * scale, hy + 3 * scale, hx + 5 * scale, hy - 2 * scale, hx, hy + 4 * scale);
    canvas.drawPath(heartPath, sketchPaint);

    // 2. Tiny Crescent Moon (high left inside)
    final moonPath = Path();
    final mx = cx - 20 * scale;
    final my = cy - 20 * scale;
    moonPath.moveTo(mx, my - 5 * scale);
    moonPath.quadraticBezierTo(mx + 5 * scale, my, mx, my + 5 * scale);
    moonPath.quadraticBezierTo(mx + 2 * scale, my, mx, my - 5 * scale);
    canvas.drawPath(moonPath, sketchPaint);

    // 3. Tiny Cozy Lamp (right side of doorway)
    final lx = cx + 24 * scale;
    final ly = cy + 12 * scale;
    final lampPath = Path()
      ..moveTo(lx - 4 * scale, ly + 8 * scale)
      ..lineTo(lx + 4 * scale, ly + 8 * scale)
      ..moveTo(lx, ly + 8 * scale)
      ..lineTo(lx, ly - 1 * scale)
      ..moveTo(lx - 5 * scale, ly - 1 * scale)
      ..lineTo(lx + 5 * scale, ly - 1 * scale)
      ..lineTo(lx + 3 * scale, ly - 6 * scale)
      ..lineTo(lx - 3 * scale, ly - 6 * scale)
      ..close();
    canvas.drawPath(lampPath, sketchPaint);

    // 4. Tiny Plant Pot (lower right corner inside)
    final px = cx + 24 * scale;
    final py = cy + 32 * scale;
    final plantPath = Path()
      ..moveTo(px - 3 * scale, py + 6 * scale)
      ..lineTo(px + 3 * scale, py + 6 * scale)
      ..lineTo(px + 2.5 * scale, py)
      ..lineTo(px - 2.5 * scale, py)
      ..close()
      ..moveTo(px, py)
      ..quadraticBezierTo(px - 3 * scale, py - 4 * scale, px - 5 * scale, py - 3 * scale)
      ..moveTo(px, py)
      ..quadraticBezierTo(px + 3 * scale, py - 4 * scale, px + 5 * scale, py - 3 * scale);
    canvas.drawPath(plantPath, sketchPaint);

    // 5. Tiny Polaroid Photo Frame (lower left corner inside)
    final ox = cx - 24 * scale;
    final oy = cy + 32 * scale;
    final polaroidPath = Path()
      ..addRect(Rect.fromCenter(center: Offset(ox, oy), width: 12 * scale, height: 14 * scale))
      ..addRect(Rect.fromCenter(center: Offset(ox, oy - 2 * scale), width: 9 * scale, height: 8 * scale));
    canvas.drawPath(polaroidPath, sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _WarmHouseSilhouettePainter old) =>
      old.progress != progress || old.breathe != breathe;
}


class _GlowingHeartIndicator extends StatefulWidget {
  @override
  State<_GlowingHeartIndicator> createState() => _GlowingHeartIndicatorState();
}

class _GlowingHeartIndicatorState extends State<_GlowingHeartIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFCC66),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC66).withOpacity(0.6),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ── MINI POLAROID ITEM DRAWERS ──
class _MiniItemPainter extends CustomPainter {
  final String itemId;

  _MiniItemPainter({required this.itemId});

  @override
  void paint(Canvas canvas, Size size) {
    // Paints a simplified version of the placed vector items inside polaroids
    canvas.save();
    // Center inside 120 x 120 square box
    canvas.translate(size.width / 2, size.height * 0.7);

    final brass = Paint()..color = const Color(0xFFC5A059);
    final pink = Paint()..color = const Color(0xFFDD8F9F);
    final wood = Paint()..color = const Color(0xFF6E4E37);
    final dark = Paint()..color = const Color(0xFF140D18);
    final green = Paint()..color = const Color(0xFF477252);

    switch (itemId) {
      case 'lamp':
        // Draws floor lamp
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 6), dark);
        canvas.drawLine(Offset.zero, const Offset(0, -60), brass..strokeWidth = 2);
        canvas.drawPath(
          Path()
            ..moveTo(-12, -45)
            ..lineTo(12, -45)
            ..lineTo(8, -60)
            ..lineTo(-8, -60)
            ..close(),
          brass,
        );
        break;
      case 'monstera':
        // Draws potted plant
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -5), width: 16, height: 12), pink);
        canvas.drawLine(const Offset(0, -10), const Offset(-10, -26), green..strokeWidth = 1.5);
        canvas.drawLine(const Offset(0, -10), const Offset(10, -28), green..strokeWidth = 1.5);
        canvas.drawCircle(const Offset(-10, -26), 7, green);
        canvas.drawCircle(const Offset(10, -28), 6.5, green);
        break;
      case 'bookshelf':
        // Bookshelf box
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -30), width: 24, height: 60), wood);
        canvas.drawLine(const Offset(-12, -30), const Offset(12, -30), dark..strokeWidth = 2.0);
        // Miniature book blocks
        canvas.drawRect(const Rect.fromLTWH(-8, -48, 4.5, 14), brass);
        canvas.drawRect(const Rect.fromLTWH(-2, -46, 4.5, 12), pink);
        canvas.drawRect(const Rect.fromLTWH(-8, -26, 4.5, 14), green);
        break;
      case 'record_player':
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -8), width: 26, height: 10), wood);
        canvas.drawCircle(const Offset(0, -12), 10, dark);
        canvas.drawCircle(const Offset(0, -12), 2.5, brass);
        canvas.drawCircle(const Offset(8, -18), 3.5, brass);
        break;
      case 'fairy_lights':
        final Path wire = Path()
          ..moveTo(-40, -45)
          ..quadraticBezierTo(0, -30, 40, -45);
        canvas.drawPath(wire, brass..strokeWidth = 1.0..style = PaintingStyle.stroke);
        canvas.drawCircle(const Offset(-20, -38), 3, brass);
        canvas.drawCircle(const Offset(0, -36), 3, brass);
        canvas.drawCircle(const Offset(20, -38), 3, brass);
        break;
      case 'memory_frame':
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -30), width: 20, height: 26), brass);
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -30), width: 14, height: 20), dark);
        canvas.drawCircle(const Offset(0, -30), 3.5, pink);
        break;
      case 'coffee':
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -5), width: 22, height: 10), wood);
        canvas.drawLine(const Offset(0, -5), const Offset(0, 10), wood..strokeWidth = 2.5);
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -14), width: 8, height: 8), pink);
        break;
      case 'window_rain':
        canvas.drawRect(Rect.fromCenter(center: const Offset(0, -30), width: 34, height: 44), dark..style = PaintingStyle.stroke..strokeWidth = 2.0);
        canvas.drawLine(const Offset(-10, -15), const Offset(-10, -22), brass..strokeWidth = 1.0);
        canvas.drawLine(const Offset(10, -35), const Offset(10, -41), brass..strokeWidth = 1.0);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── FLOATING REACTION OVERLAY ──

class _FloatingReactionOverlay extends StatefulWidget {
  final DailyCapsule capsule;
  final ValueChanged<String> onReactionSelected;

  const _FloatingReactionOverlay({
    required this.capsule,
    required this.onReactionSelected,
  });

  @override
  State<_FloatingReactionOverlay> createState() => _FloatingReactionOverlayState();
}

class _FloatingReactionOverlayState extends State<_FloatingReactionOverlay> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breatheController;
  
  bool _isDissolving = false;
  String? _selectedEmoji;

  final List<Map<String, String>> _reactions = [
    {'emoji': '❤️', 'text': 'This feels like us'},
    {'emoji': '✨', 'text': 'I smiled at this'},
    {'emoji': '☾', 'text': 'You know me well'},
    {'emoji': '🌸', 'text': 'This made me emotional'},
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _handleReaction(String emoji) {
    if (_isDissolving) return;
    setState(() {
      _selectedEmoji = emoji;
      _isDissolving = true;
    });
    
    // Dissolve and callback after particle animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        widget.onReactionSelected(emoji);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine overall opacity
    final double overallOpacity = _isDissolving ? 0.0 : 1.0;

    return AnimatedOpacity(
      opacity: overallOpacity,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: const Color(0xFF0F050A).withOpacity(0.5), // Room softly darkens
          child: Stack(
            children: [
              // Draw scattered chips
              ..._buildScatteredChips(),
              
              // Particle overlay if selected
              if (_isDissolving && _selectedEmoji != null)
                Positioned.fill(
                  child: _ParticleEffectOverlay(emoji: _selectedEmoji!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScatteredChips() {
    // Hardcoded scattered positions near the center/object area
    final List<Offset> positions = [
      const Offset(60, 260),
      const Offset(190, 310),
      const Offset(200, 180),
      const Offset(40, 360),
    ];

    return List.generate(_reactions.length, (index) {
      final reaction = _reactions[index];
      final pos = positions[index];
      
      // Staggered entrance
      final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(index * 0.15, 1.0, curve: Curves.easeOutCubic),
        ),
      );
      
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(index * 0.15, 1.0, curve: Curves.easeOut),
        ),
      );

      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                // Soft breathing drift
                final driftY = math.sin((_breatheController.value * math.pi * 2) + index) * 4.0;
                // If this is the selected one, expand and glow
                final isSelected = _selectedEmoji == reaction['emoji'];
                final scale = isSelected ? 1.08 : 1.0 + (_breatheController.value * 0.015);

                return Transform.translate(
                  offset: Offset(0, driftY),
                  child: Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () => _handleReaction(reaction['emoji']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140A0E).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFFB359).withOpacity(0.8) 
                                : const Color(0xFF381928).withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? const Color(0xFFFFB359).withOpacity(0.4) 
                                  : const Color(0xFFFFE4C4).withOpacity(0.05),
                              blurRadius: isSelected ? 20 : 10,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(reaction['emoji']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              reaction['text']!,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: Color(0xFFFFE4C4),
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
      );
    });
  }
}

class _ParticleEffectOverlay extends StatefulWidget {
  final String emoji;
  const _ParticleEffectOverlay({required this.emoji});

  @override
  State<_ParticleEffectOverlay> createState() => _ParticleEffectOverlayState();
}

class _ParticleEffectOverlayState extends State<_ParticleEffectOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();
  final List<_FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {});
      })..forward();

    // Generate particles based on emoji
    for (int i = 0; i < 20; i++) {
      _particles.add(_FloatingParticle(
        x: 100 + _random.nextDouble() * 160,
        y: 200 + _random.nextDouble() * 100,
        vx: (_random.nextDouble() - 0.5) * 2,
        vy: -1.0 - _random.nextDouble() * 2,
        size: 10 + _random.nextDouble() * 10,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        emoji: widget.emoji,
        progress: _controller.value,
      ),
    );
  }
}

class _FloatingParticle {
  double x, y, vx, vy, size;
  _FloatingParticle({required this.x, required this.y, required this.vx, required this.vy, required this.size});
}

class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final String emoji;
  final double progress;

  _ParticlePainter({required this.particles, required this.emoji, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;
    
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    
    // Determine particle color/style based on emoji
    Color pColor;
    if (emoji == '❤️') pColor = const Color(0xFFDD8F9F);
    else if (emoji == '✨') pColor = const Color(0xFFFFCC66);
    else if (emoji == '☾') pColor = const Color(0xFF7FA2CE);
    else pColor = const Color(0xFFFFB3C6);

    final paint = Paint()
      ..color = pColor.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var p in particles) {
      final currentX = p.x + (p.vx * progress * 60);
      final currentY = p.y + (p.vy * progress * 60);
      
      if (emoji == '✨') {
        canvas.drawCircle(Offset(currentX, currentY), p.size * 0.3, paint);
      } else {
        // Draw simple emoji text as particle
        final span = TextSpan(text: emoji, style: TextStyle(fontSize: p.size, color: pColor.withOpacity(opacity)));
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(currentX, currentY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}

class _GhibliPreviewPainter extends CustomPainter {
  final String houseType;
  final double animationTime; // Driven by _soundwaveController or tick

  _GhibliPreviewPainter({
    required this.houseType,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width * 0.5, size.height * 0.5);

    final Paint bgPaint = Paint();

    if (houseType == 'Beach House') {
      // 1. Beach House Immersive Sunset Background Glow
      final sunGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFA05C).withOpacity(0.35),
            const Color(0xFFC86B7F).withOpacity(0.08),
            Colors.transparent,
          ],
          center: const Alignment(0.0, 0.1),
          radius: 0.65,
        ).createShader(rect);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), size.width * 0.42, sunGlow);

      // Large warm glowing sun (Background)
      final sunPaint = Paint()..color = const Color(0xFFFFD54F).withOpacity(0.75);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), 24, sunPaint);

      // Floating sand island 3D land block (Midground - Sand top, brown rocky base)
      final rockPaint = Paint()..color = const Color(0xFF8D6E63);
      final rockPath = Path()
        ..moveTo(size.width * 0.16, size.height * 0.66)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.56, size.width * 0.84, size.height * 0.66)
        ..quadraticBezierTo(size.width * 0.72, size.height * 0.82, size.width * 0.5, size.height * 0.85)
        ..quadraticBezierTo(size.width * 0.28, size.height * 0.82, size.width * 0.16, size.height * 0.66)
        ..close();
      canvas.drawPath(rockPath, rockPaint);

      final islandPaint = Paint()..color = const Color(0xFFD7CCC8);
      final islandPath = Path()
        ..moveTo(size.width * 0.16, size.height * 0.66)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.56, size.width * 0.84, size.height * 0.66)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.76, size.width * 0.5, size.height * 0.78)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.76, size.width * 0.16, size.height * 0.66)
        ..close();
      canvas.drawPath(islandPath, islandPaint);

      // Swaying palm trees & cozy beach cabin on island
      final cabinPaint = Paint()..color = const Color(0xFF3E2723);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.42, size.height * 0.46, 32, 22), cabinPaint);
      
      final roofPaint = Paint()..color = const Color(0xFF8D6E63);
      final roofPath = Path()
        ..moveTo(size.width * 0.38, size.height * 0.46)
        ..lineTo(size.width * 0.52, size.height * 0.34)
        ..lineTo(size.width * 0.66, size.height * 0.46)
        ..close();
      canvas.drawPath(roofPath, roofPaint);

      // Cabin warm yellow window light
      final windowGlow = Paint()..color = const Color(0xFFFFD54F).withOpacity(0.85 * (0.8 + 0.2 * math.sin(animationTime * math.pi * 2)));
      canvas.drawRect(Rect.fromLTWH(size.width * 0.48, size.height * 0.52, 6, 8), windowGlow);

      // Swaying palm trunk & leaves
      final woodPaint = Paint()..color = const Color(0xFF4E342E)..style = PaintingStyle.stroke..strokeWidth = 3.5;
      final double lSway = 2.5 * math.sin(animationTime * math.pi);
      
      final palmTrunk = Path()
        ..moveTo(size.width * 0.26, size.height * 0.64)
        ..quadraticBezierTo(size.width * 0.22, size.height * 0.48, size.width * 0.24 + lSway * 0.8, size.height * 0.36);
      canvas.drawPath(palmTrunk, woodPaint);

      final leafPaint = Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = 1.8;
      _drawPalmLeaf(canvas, Offset(size.width * 0.24 + lSway * 0.8, size.height * 0.36), -20 + lSway, leafPaint);
      _drawPalmLeaf(canvas, Offset(size.width * 0.24 + lSway * 0.8, size.height * 0.36), 15 - lSway, leafPaint);
      _drawPalmLeaf(canvas, Offset(size.width * 0.24 + lSway * 0.8, size.height * 0.36), 65 + lSway, leafPaint);

      // Animated ocean waves cascading around the island base (Foreground)
      final wavePaint = Paint()..color = const Color(0xFF4A90E2).withOpacity(0.75);
      final wavePath = Path();
      wavePath.moveTo(size.width * 0.12, size.height * 0.68);
      for (double x = size.width * 0.12; x <= size.width * 0.88; x += 1) {
        final double y = size.height * 0.68 +
            4 * math.sin((x / 12) + (animationTime * math.pi * 2.0));
        wavePath.lineTo(x, y);
      }
      wavePath.quadraticBezierTo(size.width * 0.7, size.height * 0.82, size.width * 0.5, size.height * 0.84);
      wavePath.quadraticBezierTo(size.width * 0.3, size.height * 0.82, size.width * 0.12, size.height * 0.68);
      wavePath.close();
      canvas.drawPath(wavePath, wavePaint);

      // Flying birds in twilight sky
      final birdPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      _drawBird(canvas, Offset(size.width * 0.34, size.height * 0.24 + 2 * math.sin(animationTime * math.pi)), birdPaint);
      _drawBird(canvas, Offset(size.width * 0.68, size.height * 0.18 - 2 * math.sin(animationTime * math.pi)), birdPaint);

    } else if (houseType == 'Cozy Apartment') {
      // 2. Cozy Apartment Immersive Rain & Warm Ambience
      final roomGlowGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB74D).withOpacity(0.24),
            const Color(0xFF4C2066).withOpacity(0.05),
            Colors.transparent,
          ],
          center: const Alignment(0.4, 0.2),
          radius: 0.6,
        ).createShader(rect);
      canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.58), size.width * 0.35, roomGlowGlow);

      // Soft silhouette city skyscrapers in back (Background - blurred/faded)
      final bldgPaint = Paint()..color = const Color(0xFF160B24).withOpacity(0.6);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.08, size.height * 0.44, size.width * 0.20, size.height * 0.56), bldgPaint);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.30, size.height * 0.32, size.width * 0.26, size.height * 0.68), bldgPaint);

      // Glowing blinking city windows
      final cityWinPaint = Paint()..color = const Color(0xFFFFD54F).withOpacity(0.3 * (0.6 + 0.4 * math.sin(animationTime * math.pi * 2.5)));
      canvas.drawRect(Rect.fromLTWH(size.width * 0.34, size.height * 0.40, 4, 6), cityWinPaint);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.42, size.height * 0.50, 4, 6), cityWinPaint);

      // Floating apartment room block suspended in space (Midground)
      final wallPaint = Paint()..color = const Color(0xFF2D1E3D);
      final roomPath = Path()
        ..moveTo(size.width * 0.50, size.height * 0.42)
        ..lineTo(size.width * 0.88, size.height * 0.36)
        ..lineTo(size.width * 0.88, size.height * 0.78)
        ..lineTo(size.width * 0.50, size.height * 0.84)
        ..close();
      canvas.drawPath(roomPath, wallPaint);

      final panePaint = Paint()..color = const Color(0xFFFFB74D).withOpacity(0.32 + 0.1 * math.sin(animationTime * math.pi));
      canvas.drawRect(Rect.fromLTWH(size.width * 0.56, size.height * 0.46, size.width * 0.26, size.height * 0.30), panePaint);

      final framePaint = Paint()..color = const Color(0xFF1A0E2A)..style = PaintingStyle.stroke..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(size.width * 0.56, size.height * 0.46, size.width * 0.26, size.height * 0.30), framePaint);
      canvas.drawLine(Offset(size.width * 0.69, size.height * 0.46), Offset(size.width * 0.69, size.height * 0.76), framePaint);

      // Volumetric cozy room window glow spilling out (Foreground glow)
      final roomGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB74D).withOpacity(0.48 * (0.85 + 0.15 * math.sin(animationTime * math.pi * 2))),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.68, size.height * 0.6), radius: 36));
      canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.6), 36, roomGlow);

      // Steam rising from warm coffee mug window ledge silhouette
      final steamPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 + 0.15 * math.sin(animationTime * math.pi * 4.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      final double steamSway = 1.5 * math.sin(animationTime * math.pi * 3);
      final steamPath = Path()
        ..moveTo(size.width * 0.72, size.height * 0.74)
        ..quadraticBezierTo(size.width * 0.72 - 2 + steamSway, size.height * 0.68, size.width * 0.72 + steamSway, size.height * 0.64);
      canvas.drawPath(steamPath, steamPaint);

      // Moving rain streaks crossing in front of scene (Foreground)
      final rainPaint = Paint()
        ..color = Colors.white.withOpacity(0.26)
        ..strokeWidth = 1.0;
      for (int i = 0; i < 6; i++) {
        final double rx = (size.width * (i / 5.0) + (animationTime * 45)) % size.width;
        final double ry = (size.height * 0.12 + (i * 12) + (animationTime * 95)) % (size.height * 0.88);
        canvas.drawLine(Offset(rx, ry), Offset(rx - 3, ry + 9), rainPaint);
      }

    } else if (houseType == 'Modern Villa') {
      // 3. Modern Villa Luxury Concrete Pool Slab
      final sunsetGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE5694A).withOpacity(0.35),
            const Color(0xFF520B29).withOpacity(0.06),
            Colors.transparent,
          ],
          center: const Alignment(-0.2, 0.0),
          radius: 0.65,
        ).createShader(rect);
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.5), size.width * 0.4, sunsetGlow);

      // Sleek floating minimal concrete-glass deck (Midground)
      final slabPaint = Paint()..color = const Color(0xFF1E1122);
      final deckPath = Path()
        ..moveTo(size.width * 0.12, size.height * 0.58)
        ..lineTo(size.width * 0.88, size.height * 0.52)
        ..lineTo(size.width * 0.78, size.height * 0.82)
        ..lineTo(size.width * 0.22, size.height * 0.86)
        ..close();
      canvas.drawPath(deckPath, slabPaint);

      // Sleek glass frames rising from the deck
      final glassPaint = Paint()..color = const Color(0xFFFFCC66).withOpacity(0.18);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.25, size.height * 0.32, size.width * 0.5, size.height * 0.22), glassPaint);

      final framePaint = Paint()..color = const Color(0xFF0F0712)..style = PaintingStyle.stroke..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(size.width * 0.25, size.height * 0.32, size.width * 0.5, size.height * 0.22), framePaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.32), Offset(size.width * 0.5, size.height * 0.54), framePaint);

      // Room warm sunset light spilling outward
      final roomGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD54F).withOpacity(0.55 * (0.8 + 0.2 * math.sin(animationTime * math.pi))),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.4, size.height * 0.44), radius: 24));
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.44), 24, roomGlow);

      // Infinity pool reflection with warm gold ripples (Foreground)
      final poolPaint = Paint()..color = const Color(0xFF16526E).withOpacity(0.5);
      final poolPath = Path()
        ..moveTo(size.width * 0.32, size.height * 0.62)
        ..lineTo(size.width * 0.78, size.height * 0.58)
        ..lineTo(size.width * 0.72, size.height * 0.76)
        ..lineTo(size.width * 0.36, size.height * 0.79)
        ..close();
      canvas.drawPath(poolPath, poolPaint);

      final ripplePaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.35 * (0.7 + 0.3 * math.sin(animationTime * math.pi * 2)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(size.width * 0.42, size.height * 0.66), Offset(size.width * 0.68, size.height * 0.66), ripplePaint);
      canvas.drawLine(Offset(size.width * 0.48, size.height * 0.72), Offset(size.width * 0.62, size.height * 0.72), ripplePaint);

    } else if (houseType == 'Cabin Retreat') {
      // 4. Cabin Retreat misty deep forest
      final forestGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF33573E).withOpacity(0.3),
            const Color(0xFF152A1E).withOpacity(0.05),
            Colors.transparent,
          ],
          center: const Alignment(0.0, 0.0),
          radius: 0.6,
        ).createShader(rect);
      canvas.drawCircle(center, size.width * 0.42, forestGlow);

      // Pine tree silhouettes framing back (Background)
      final treePaint = Paint()..color = const Color(0xFF06120C);
      _drawPineTree(canvas, Offset(size.width * 0.20, size.height * 0.64), 26, treePaint);
      _drawPineTree(canvas, Offset(size.width * 0.78, size.height * 0.68), 32, treePaint);

      // Floating forest mossy island chunk (Midground)
      final rockPaint = Paint()..color = const Color(0xFF3D271D);
      final rockPath = Path()
        ..moveTo(size.width * 0.15, size.height * 0.64)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.54, size.width * 0.85, size.height * 0.64)
        ..lineTo(size.width * 0.76, size.height * 0.80)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.84, size.width * 0.24, size.height * 0.80)
        ..close();
      canvas.drawPath(rockPath, rockPaint);

      final groundPaint = Paint()..color = const Color(0xFF1F3A2A);
      final groundPath = Path()
        ..moveTo(size.width * 0.15, size.height * 0.64)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.54, size.width * 0.85, size.height * 0.64)
        ..quadraticBezierTo(size.width * 0.74, size.height * 0.74, size.width * 0.5, size.height * 0.76)
        ..quadraticBezierTo(size.width * 0.26, size.height * 0.74, size.width * 0.15, size.height * 0.64)
        ..close();
      canvas.drawPath(groundPath, groundPaint);

      // Cozy wooden cabin on top of the island block
      final cabinPaint = Paint()..color = const Color(0xFF140F08);
      final cabinPath = Path()
        ..moveTo(size.width * 0.36, size.height * 0.66)
        ..lineTo(size.width * 0.36, size.height * 0.48)
        ..lineTo(size.width * 0.5, size.height * 0.36)
        ..lineTo(size.width * 0.64, size.height * 0.48)
        ..lineTo(size.width * 0.64, size.height * 0.66)
        ..close();
      canvas.drawPath(cabinPath, cabinPaint);

      // Glowing fireplace window flickering warm light (Foreground glow)
      final fireplaceGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF5722).withOpacity(0.9 * (0.8 + 0.2 * math.sin(animationTime * math.pi * 3.5))),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.53), radius: 10));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.53), 10, fireplaceGlow);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.46, size.height * 0.50, 8, 8), Paint()..color = const Color(0xFFFFB74D));

      // Cozy fireplace chimney smoke curling softly upward
      final smokePaint = Paint()
        ..color = Colors.white.withOpacity(0.24 + 0.12 * math.sin(animationTime * math.pi * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final double smokeSway = 2.0 * math.sin(animationTime * math.pi * 2);
      final smokePath = Path()
        ..moveTo(size.width * 0.58, size.height * 0.40)
        ..quadraticBezierTo(size.width * 0.58 - 3 + smokeSway, size.height * 0.32, size.width * 0.58 + smokeSway, size.height * 0.24);
      canvas.drawPath(smokePath, smokePaint);

      // Glowing forest fireflies swirling softly (Foreground)
      final fireflyPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 5; i++) {
        final double t = (animationTime + (i * 0.2)) % 1.0;
        final double fx = size.width * (0.22 + 0.56 * t) + 8 * math.sin(t * math.pi * 2.0 + i);
        final double fy = size.height * 0.64 - (42 * t);
        fireflyPaint.color = const Color(0xFFFFE082).withOpacity((1.0 - t) * 0.85);
        canvas.drawCircle(Offset(fx, fy), 1.6, fireflyPaint);
      }

    } else if (houseType == 'Futuristic Sky Home') {
      // 5. Futuristic Sky Home cyber cloud
      final skyGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF3F0F80).withOpacity(0.35),
            const Color(0xFF1A0A38).withOpacity(0.06),
            Colors.transparent,
          ],
          radius: 0.65,
        ).createShader(rect);
      canvas.drawCircle(center, size.width * 0.42, skyGlow);

      // Starry sky sparkles
      final starPaint = Paint()..color = Colors.white.withOpacity(0.7);
      canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.20), 1.0, starPaint);
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.24), 1.2, starPaint);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), 0.8, starPaint);

      // Floating cyber disk architecture platform (Midground)
      final platformPaint = Paint()..color = const Color(0xFF0F041F);
      final diskPath = Path()
        ..moveTo(size.width * 0.20, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.53, size.width * 0.8, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.67, size.width * 0.2, size.height * 0.6)
        ..close();
      canvas.drawPath(diskPath, platformPaint);

      // Glowing hologram light and cyber ring glows (Foreground)
      final neonGlow = Paint()
        ..color = const Color(0xFFB388FF).withOpacity(0.32 + 0.12 * math.sin(animationTime * math.pi * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawOval(Rect.fromLTWH(size.width * 0.16, size.height * 0.58, size.width * 0.68, 20), neonGlow);

      final centralGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFEA80FC).withOpacity(0.68),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.5), radius: 16));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 16, centralGlow);
    }
  }

  void _drawBird(Canvas canvas, Offset pos, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx - 3, pos.dy + 1)
      ..quadraticBezierTo(pos.dx - 1.5, pos.dy - 2, pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + 1.5, pos.dy - 2, pos.dx + 3, pos.dy + 1);
    canvas.drawPath(path, paint);
  }

  void _drawPalmLeaf(Canvas canvas, Offset origin, double angleDegrees, Paint paint) {
    final rad = angleDegrees * math.pi / 180.0;
    final endX = origin.dx + 15 * math.cos(rad);
    final endY = origin.dy + 15 * math.sin(rad);
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(origin.dx + 8 * math.cos(rad - 0.2), origin.dy + 8 * math.sin(rad - 0.2), endX, endY);
    canvas.drawPath(path, paint);
  }

  void _drawPineTree(Canvas canvas, Offset bottomCenter, double height, Paint paint) {
    final path = Path()
      ..moveTo(bottomCenter.dx, bottomCenter.dy - height)
      ..lineTo(bottomCenter.dx - height * 0.28, bottomCenter.dy - height * 0.38)
      ..lineTo(bottomCenter.dx - height * 0.14, bottomCenter.dy - height * 0.38)
      ..lineTo(bottomCenter.dx - height * 0.35, bottomCenter.dy)
      ..lineTo(bottomCenter.dx + height * 0.35, bottomCenter.dy)
      ..lineTo(bottomCenter.dx + height * 0.14, bottomCenter.dy - height * 0.38)
      ..lineTo(bottomCenter.dx + height * 0.28, bottomCenter.dy - height * 0.38)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── CUSTOM PAINTERS FOR DREAMY TRANSITIONS ──

class _SparkleParticlePainter extends CustomPainter {
  final double progress;
  final double centerX;
  final double centerY;

  _SparkleParticlePainter({
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width * centerX, size.height * centerY);
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Deterministic seed for stable particles

    // Easing curves
    final outwardEase = Curves.easeOutCubic.transform(progress);
    final fadeEase = progress < 0.6 
        ? (progress / 0.6) // Fade in
        : 1.0 - ((progress - 0.6) / 0.4); // Fade out

    // Draw 16 bursting sparkles
    for (int i = 0; i < 16; i++) {
      final angle = (i * (math.pi * 2 / 16)) + random.nextDouble() * 0.5;
      final distance = 20.0 + random.nextDouble() * 120.0 * outwardEase;
      
      final dx = center.dx + math.cos(angle) * distance;
      final dy = center.dy + math.sin(angle) * distance - (progress * 40); // Float up slightly

      final sizeOffset = random.nextDouble();
      final radius = (1.5 + sizeOffset * 2.0) * fadeEase;
      
      final colorPhase = random.nextDouble();
      final color = colorPhase > 0.5 
          ? const Color(0xFFFFCC66) // Gold
          : const Color(0xFFFF99CC); // Soft pink

      paint.color = color.withOpacity(0.6 * fadeEase);
      
      // Add a slight glow
      canvas.drawCircle(Offset(dx, dy), radius * 2.5, paint..color = color.withOpacity(0.2 * fadeEase));
      // Core sparkle
      canvas.drawCircle(Offset(dx, dy), radius, paint..color = color.withOpacity(0.8 * fadeEase));
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DreamyFogPainter extends CustomPainter {
  final double progress;
  final double warmth; // 0.0 = cooler purple, 1.0 = warm gold

  _DreamyFogPainter({required this.progress, required this.warmth});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final fadeEase = progress < 0.3 
        ? (progress / 0.3) 
        : 1.0 - ((progress - 0.3) / 0.7);

    final color1 = Color.lerp(const Color(0xFF4A1A3B), const Color(0xFF6E3A20), warmth)!.withOpacity(0.15 * fadeEase);
    final color2 = Color.lerp(const Color(0xFF2A0E2A), const Color(0xFF4A2010), warmth)!.withOpacity(0.1 * fadeEase);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Cloud band 1 (moving right)
    final offset1 = size.width * (progress * 0.8 - 0.2);
    final rect1 = Rect.fromCenter(
      center: Offset(offset1, size.height * 0.4),
      width: size.width * 1.5,
      height: size.height * 0.6,
    );
    paint.color = color1;
    canvas.drawOval(rect1, paint);

    // Cloud band 2 (moving left, lower)
    final offset2 = size.width * (1.2 - progress * 0.6);
    final rect2 = Rect.fromCenter(
      center: Offset(offset2, size.height * 0.7),
      width: size.width * 1.8,
      height: size.height * 0.5,
    );
    paint.color = color2;
    canvas.drawOval(rect2, paint);
  }

  @override
  bool shouldRepaint(covariant _DreamyFogPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

