import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── DATA STRUCTURES ──

class StarModel {
  double x;
  double y;
  double size;
  double opacity;
  double twinkleSpeed;
  double offset;

  StarModel({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
    required this.offset,
  });
}

class CloudModel {
  double x;
  double y;
  double width;
  double height;
  double speed;
  double opacity;

  CloudModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.opacity,
  });
}

class DustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  DustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
}

class SteamParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  double life; // 0.0 to 1.0

  SteamParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.life,
  });
}

class BurstParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double life;

  BurstParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    required this.life,
  });
}

// Placable item class for rendering
class PlacedItemState {
  final String id;
  final bool isPlaced;
  final bool isNew; // Highlights with amber breathing glow if added today by partner
  final double scale; // For bounce-in materialization transition
  final Offset position; // Coordinate center on a 360 x 480 grid
  final String reaction; // The permanent floating reaction symbol (e.g., ♡, ✨)

  const PlacedItemState({
    required this.id,
    required this.isPlaced,
    this.isNew = false,
    this.scale = 1.0,
    this.position = Offset.zero,
    this.reaction = '',
  });

  PlacedItemState copyWith({
    bool? isPlaced,
    bool? isNew,
    double? scale,
    Offset? position,
    String? reaction,
  }) {
    return PlacedItemState(
      id: id,
      isPlaced: isPlaced ?? this.isPlaced,
      isNew: isNew ?? this.isNew,
      scale: scale ?? this.scale,
      position: position ?? this.position,
      reaction: reaction ?? this.reaction,
    );
  }
}

// ── MAIN AMBIENT WIDGET ──

class AmbientEnvironmentController extends StatefulWidget {
  final List<PlacedItemState> items;
  final bool isRainy;
  final bool isBlueprintMode; // Renders room as blue glowing neon lines
  final double blueprintProgress; // 0.0 to 1.0 for path growing animation
  final String? activeNewItemId; // ID of the item currently being placed
  final VoidCallback? onItemClicked; // Callback when a placed item is tapped
  final int currentDay;
  final String? chosenHouseType;

  const AmbientEnvironmentController({
    super.key,
    required this.items,
    this.isRainy = false,
    this.isBlueprintMode = false,
    this.blueprintProgress = 1.0,
    this.activeNewItemId,
    this.onItemClicked,
    this.currentDay = 1,
    this.chosenHouseType,
  });

  @override
  State<AmbientEnvironmentController> createState() => AmbientEnvironmentControllerState();
}

class AmbientEnvironmentControllerState extends State<AmbientEnvironmentController>
    with TickerProviderStateMixin {
  
  late AnimationController _timeController; // Drives continuous environment loops
  late AnimationController _windController; // Wind sway (curtains, monstera)
  late AnimationController _flickerController; // Cozy lights, coffee steam, candles
  
  // Star & Cloud Data
  final List<StarModel> _stars = [];
  final List<CloudModel> _clouds = [];
  final List<DustParticle> _dust = [];
  final List<SteamParticle> _steam = [];
  final List<BurstParticle> _bursts = [];

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Setup loops
    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Initialize static night sky background items
    for (int i = 0; i < 35; i++) {
      _stars.add(StarModel(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.45, // Only in top portion
        size: 0.5 + _random.nextDouble() * 1.5,
        opacity: 0.2 + _random.nextDouble() * 0.8,
        twinkleSpeed: 0.5 + _random.nextDouble() * 1.5,
        offset: _random.nextDouble() * math.pi * 2,
      ));
    }

    _clouds.add(CloudModel(x: 0.05, y: 0.05, width: 140, height: 40, speed: 0.005, opacity: 0.25));
    _clouds.add(CloudModel(x: 0.55, y: 0.12, width: 180, height: 50, speed: 0.003, opacity: 0.18));
    _clouds.add(CloudModel(x: 0.30, y: 0.02, width: 110, height: 35, speed: 0.008, opacity: 0.20));

    // Room dust
    for (int i = 0; i < 20; i++) {
      _dust.add(DustParticle(
        x: _random.nextDouble() * 360,
        y: 120 + _random.nextDouble() * 260,
        vx: (_random.nextDouble() - 0.5) * 0.2,
        vy: -0.1 - _random.nextDouble() * 0.2,
        size: 1.0 + _random.nextDouble() * 1.8,
        opacity: 0.1 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _windController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  // Trigger starburst particles when an item materializes
  void triggerPlacementBurst(Offset position) {
    setState(() {
      for (int i = 0; i < 30; i++) {
        final angle = _random.nextDouble() * math.pi * 2;
        final speed = 1.0 + _random.nextDouble() * 3.5;
        _bursts.add(BurstParticle(
          x: position.dx,
          y: position.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 0.5, // Float upwards slightly
          size: 2.0 + _random.nextDouble() * 4.0,
          color: i % 2 == 0 ? const Color(0xFFFFCC66) : const Color(0xFFDD8F9F),
          opacity: 1.0,
          life: 1.0,
        ));
      }
    });
  }

  // Continuous frame updates for custom particle physics
  void _updateParticles() {
    // 1. Skies clouds movement
    for (var cloud in _clouds) {
      cloud.x += cloud.speed;
      if (cloud.x > 1.2) {
        cloud.x = -0.4;
      }
    }

    // 2. Room floating dust
    for (var d in _dust) {
      d.y += d.vy;
      d.x += d.vx;
      if (d.y < 120) {
        d.y = 380;
        d.x = _random.nextDouble() * 360;
      }
      if (d.x < 0 || d.x > 360) {
        d.vx = -d.vx;
      }
    }

    // 3. Coffee steam particles (spawns dynamically if Coffee is placed)
    final coffeeState = widget.items.firstWhere((e) => e.id == 'coffee', orElse: () => const PlacedItemState(id: 'coffee', isPlaced: false));
    if (coffeeState.isPlaced) {
      if (_random.nextDouble() < 0.08 && _steam.length < 15) {
        _steam.add(SteamParticle(
          x: coffeeState.position.dx + (_random.nextDouble() - 0.5) * 8,
          y: coffeeState.position.dy - 12,
          vx: (_random.nextDouble() - 0.5) * 0.15,
          vy: -0.3 - _random.nextDouble() * 0.4,
          size: 1.5 + _random.nextDouble() * 2.5,
          opacity: 0.3 + _random.nextDouble() * 0.4,
          life: 1.0,
        ));
      }
    }

    for (int i = _steam.length - 1; i >= 0; i--) {
      var s = _steam[i];
      s.y += s.vy;
      s.x += s.vx;
      s.life -= 0.015;
      s.opacity = s.life * 0.6;
      if (s.life <= 0) {
        _steam.removeAt(i);
      }
    }

    // 4. Materialization burst particles
    for (int i = _bursts.length - 1; i >= 0; i--) {
      var b = _bursts[i];
      b.x += b.vx;
      b.y += b.vy;
      b.life -= 0.025;
      b.opacity = b.life;
      b.size *= 0.96;
      if (b.life <= 0) {
        _bursts.removeAt(i);
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
        final double maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 480.0;

        final scaleX = maxWidth / 360;
        final scaleY = maxHeight / 480;

        return AnimatedBuilder(
          animation: Listenable.merge([_timeController, _windController, _flickerController]),
          builder: (context, child) {
            _updateParticles();

            // Check active lighting sources to scale room colors
            final lampState = widget.items.firstWhere((e) => e.id == 'lamp', orElse: () => const PlacedItemState(id: 'lamp', isPlaced: false));
            final lightsState = widget.items.firstWhere((e) => e.id == 'fairy_lights', orElse: () => const PlacedItemState(id: 'fairy_lights', isPlaced: false));
            
            double lampIntensity = lampState.isPlaced ? (0.8 + 0.2 * math.sin(_flickerController.value * math.pi * 2)) : 0.0;
            double lightsIntensity = lightsState.isPlaced ? (0.7 + 0.3 * math.cos(_flickerController.value * math.pi * 2)) : 0.0;

            return Stack(
              children: [
                // Custom Paint for all elements
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoomWorldPainter(
                      stars: _stars,
                      clouds: _clouds,
                      dust: _dust,
                      steam: _steam,
                      bursts: _bursts,
                      items: widget.items,
                      isRainy: widget.isRainy || widget.currentDay == 2, // Day 2 is rain themed!
                      isBlueprintMode: widget.isBlueprintMode,
                      blueprintProgress: widget.blueprintProgress,
                      timeTick: _timeController.value,
                      windTick: _windController.value,
                      flickerTick: _flickerController.value,
                      lampIntensity: lampIntensity,
                      lightsIntensity: lightsIntensity,
                      currentDay: widget.currentDay,
                      chosenHouseType: widget.chosenHouseType,
                    ),
                  ),
                ),

                // Tap detector overlays mapped to coordinates
                if (!widget.isBlueprintMode)
                  ...widget.items.where((e) => e.isPlaced).map((item) {
                    // Approximate bounding boxes for each item on coordinate grid
                    double boxWidth = 50;
                    double boxHeight = 50;
                    Offset adjustedPos = item.position;

                    switch (item.id) {
                      case 'lamp':
                        boxWidth = 32; boxHeight = 100;
                        adjustedPos = Offset(item.position.dx - 16, item.position.dy - 90);
                        break;
                      case 'monstera':
                        boxWidth = 54; boxHeight = 60;
                        adjustedPos = Offset(item.position.dx - 27, item.position.dy - 50);
                        break;
                      case 'bookshelf':
                        boxWidth = 48; boxHeight = 110;
                        adjustedPos = Offset(item.position.dx - 24, item.position.dy - 100);
                        break;
                      case 'record_player':
                        boxWidth = 44; boxHeight = 44;
                        adjustedPos = Offset(item.position.dx - 22, item.position.dy - 34);
                        break;
                      case 'fairy_lights':
                        boxWidth = 140; boxHeight = 32;
                        adjustedPos = Offset(item.position.dx - 70, item.position.dy - 10);
                        break;
                      case 'memory_frame':
                        boxWidth = 32; boxHeight = 40;
                        adjustedPos = Offset(item.position.dx - 16, item.position.dy - 20);
                        break;
                      case 'coffee':
                        boxWidth = 40; boxHeight = 46;
                        adjustedPos = Offset(item.position.dx - 20, item.position.dy - 36);
                        break;
                      case 'window_rain':
                        boxWidth = 90; boxHeight = 110;
                        adjustedPos = Offset(item.position.dx - 45, item.position.dy - 55);
                        break;
                    }

                    // Render invisible tap zones
                    return Positioned(
                      left: adjustedPos.dx * scaleX,
                      top: adjustedPos.dy * scaleY,
                      width: boxWidth * scaleX,
                      height: boxHeight * scaleY,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onItemClicked != null) {
                            // Pass selected item ID through active state
                            widget.onItemClicked!();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: item.isNew 
                                  ? const Color(0xFFFFCC66).withOpacity(0.3 + 0.3 * math.sin(_flickerController.value * math.pi * 2))
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

// ── CUSTOM ROOM & OBJECT PAINTER ──

class _RoomWorldPainter extends CustomPainter {
  final List<StarModel> stars;
  final List<CloudModel> clouds;
  final List<DustParticle> dust;
  final List<SteamParticle> steam;
  final List<BurstParticle> bursts;
  final List<PlacedItemState> items;
  
  final bool isRainy;
  final bool isBlueprintMode;
  final double blueprintProgress;
  
  final double timeTick;
  final double windTick;
  final double flickerTick;
  
  final double lampIntensity;
  final double lightsIntensity;
  
  final int currentDay;
  final String? chosenHouseType;

  _RoomWorldPainter({
    required this.stars,
    required this.clouds,
    required this.dust,
    required this.steam,
    required this.bursts,
    required this.items,
    required this.isRainy,
    required this.isBlueprintMode,
    required this.blueprintProgress,
    required this.timeTick,
    required this.windTick,
    required this.flickerTick,
    required this.lampIntensity,
    required this.lightsIntensity,
    required this.currentDay,
    required this.chosenHouseType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Establish canvas scale to keep vector coordinates responsive
    final scaleX = size.width / 360;
    final scaleY = size.height / 480;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    if (isBlueprintMode) {
      _paintBlueprint(canvas, size);
    } else {
      _paintCozyReality(canvas, size);
    }

    canvas.restore();
  }

  // ── COZY ENVIRONMENT DRAWING ──

  void _paintCozyReality(Canvas canvas, Size size) {
    // Select atmospheric colors based on Day
    List<Color> skyColors = const [Color(0xFF0A030D), Color(0xFF16091A), Color(0xFF28112C)];
    Color hillColor = const Color(0xFF100416);
    Color wallColor = const Color(0xFF190D18);
    List<Color> floorColors = const [Color(0xFF23111E), Color(0xFF2E1927), Color(0xFF3B2032)];
    
    if (currentDay == 1) {
      skyColors = const [Color(0xFF0C1324), Color(0xFF1B243B)];
      hillColor = const Color(0xFF080D1A);
      wallColor = const Color(0xFF121B2D);
      floorColors = const [Color(0xFF1B263B), Color(0xFF24305E), Color(0xFF2B3A67)];
    } else if (currentDay == 2) {
      skyColors = const [Color(0xFF0F111E), Color(0xFF191F37)];
      hillColor = const Color(0xFF090A11);
      wallColor = const Color(0xFF161925);
      floorColors = const [Color(0xFF1F222F), Color(0xFF282C3D), Color(0xFF32374B)];
    } else if (currentDay == 3) {
      skyColors = const [Color(0xFFFED8B1), Color(0xFFFF9E80)];
      hillColor = const Color(0xFF6D4C41);
      wallColor = const Color(0xFFFFF8E7);
      floorColors = const [Color(0xFFD7CCC8), Color(0xFFEFEBE9), Color(0xFFFFFDF7)];
    } else if (currentDay == 4) {
      skyColors = const [Color(0xFF040209), Color(0xFF0A0518)];
      hillColor = const Color(0xFF05030A);
      wallColor = const Color(0xFF0D0A14);
      floorColors = const [Color(0xFF160F1F), Color(0xFF23182E), Color(0xFF2F213E)];
    } else if (currentDay == 5) {
      skyColors = const [Color(0xFFFF8C00), Color(0xFFFFD700)];
      hillColor = const Color(0xFF5D4037);
      wallColor = const Color(0xFF2B3D2F); // Sage green wall
      floorColors = const [Color(0xFF3E2723), Color(0xFF4E342E), Color(0xFF5D4037)];
    } else if (currentDay == 6) {
      skyColors = const [Color(0xFF4A154B), Color(0xFF9E1F63)];
      hillColor = const Color(0xFF300B2B);
      wallColor = const Color(0xFF1F081B);
      floorColors = const [Color(0xFF2B1028), Color(0xFF3D1939), Color(0xFF4E2649)];
    } else if (currentDay == 7) {
      skyColors = const [Color(0xFFFFCC66), Color(0xFFDD8F9F)];
      hillColor = const Color(0xFF4A1E30);
      wallColor = const Color(0xFFFFF0F5);
      floorColors = const [Color(0xFFE8C5C8), Color(0xFFF2D3D6), Color(0xFFFAEBEF)];
    }

    // A. Sky Background
    final Rect skyRect = const Rect.fromLTWH(0, 0, 360, 240);
    final skyGradient = LinearGradient(
      colors: skyColors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(skyRect, Paint()..shader = skyGradient.createShader(skyRect));

    // Twinkling stars
    if (currentDay != 2 && currentDay != 3) {
      for (var star in stars) {
        double currentOpacity = (star.opacity * (0.4 + 0.6 * math.sin(timeTick * math.pi * 2 * star.twinkleSpeed + star.offset))).clamp(0.0, 1.0);
        final starPaint = Paint()..color = Colors.white.withOpacity(currentOpacity);
        canvas.drawCircle(Offset(star.x * 360, star.y * 180), star.size, starPaint);
      }
    }

    // Drifting clouds
    for (var cloud in clouds) {
      final cloudPaint = Paint()..color = (currentDay == 2 ? const Color(0xFF131726) : const Color(0xFF331E3D)).withOpacity(cloud.opacity);
      canvas.drawOval(Rect.fromLTWH(cloud.x * 360, cloud.y * 160, cloud.width, cloud.height), cloudPaint);
    }

    // Distant soft mountains / hills silhouette
    final hillPath = Path()
      ..moveTo(0, 200)
      ..quadraticBezierTo(90, 180, 160, 195)
      ..quadraticBezierTo(260, 215, 360, 190)
      ..lineTo(360, 240)
      ..lineTo(0, 240)
      ..close();
    canvas.drawPath(hillPath, Paint()..color = hillColor);

    // B. Window View Backdrop Frame
    // Base room wall texture (wallpaper color)
    final wallPaint = Paint()..color = wallColor;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 380), wallPaint);

    // Warm radial glow behind the window frame (simulating warm interior baseline)
    final backGlow = RadialGradient(
      colors: [const Color(0xFF3D192C).withOpacity(0.3), Colors.transparent],
      radius: 1.2,
    );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 380), Paint()..shader = backGlow.createShader(const Rect.fromLTWH(0, 0, 360, 380)));

    // Window cutout (shows sky backdrop behind)
    final windowRect = const Rect.fromLTWH(110, 80, 140, 160);
    canvas.drawRect(windowRect, Paint()..color = Colors.transparent..blendMode = BlendMode.clear);

    // Re-paint backdrop inside window cutout by clearing the wall
    canvas.save();
    canvas.clipRect(windowRect);
    // Draw sky inside window again
    canvas.drawRect(const Rect.fromLTWH(110, 80, 140, 160), Paint()..shader = skyGradient.createShader(windowRect));
    if (!isRainy) {
      for (var star in stars) {
        double currentOpacity = (star.opacity * (0.3 + 0.7 * math.sin(timeTick * math.pi * 2 * star.twinkleSpeed + star.offset))).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(star.x * 360, star.y * 180), star.size, Paint()..color = Colors.white.withOpacity(currentOpacity));
      }
    }
    for (var cloud in clouds) {
      canvas.drawOval(Rect.fromLTWH(cloud.x * 360, cloud.y * 160, cloud.width, cloud.height), Paint()..color = (isRainy ? const Color(0xFF141829) : const Color(0xFF3A1F42)).withOpacity(cloud.opacity));
    }
    canvas.drawPath(hillPath, Paint()..color = isRainy ? const Color(0xFF090A11) : const Color(0xFF100416));

    // If Window Rain is placed, draw rain droplets sliding down the pane inside
    final rainState = items.firstWhere((e) => e.id == 'window_rain', orElse: () => const PlacedItemState(id: 'window_rain', isPlaced: false));
    if (rainState.isPlaced || isRainy) {
      _paintWindowRain(canvas, windowRect);
    }
    canvas.restore();

    // Window wooden frame grids
    final framePaint = Paint()
      ..color = const Color(0xFF281423)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(windowRect, framePaint);
    canvas.drawLine(const Offset(180, 80), const Offset(180, 240), framePaint..strokeWidth = 3);
    canvas.drawLine(const Offset(110, 160), const Offset(250, 160), framePaint..strokeWidth = 2);

    // C. Wooden Floor Perspective
    // Floor area: Y from 340 to 480
    final Path floorPath = Path()
      ..moveTo(0, 340)
      ..lineTo(360, 340)
      ..lineTo(360, 480)
      ..lineTo(0, 480)
      ..close();
    
    final floorGradient = LinearGradient(
      colors: floorColors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawPath(floorPath, Paint()..shader = floorGradient.createShader(const Rect.fromLTWH(0, 340, 360, 140)));

    // Floor base board outline
    final trimPaint = Paint()
      ..color = const Color(0xFF140813)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 340), const Offset(360, 340), trimPaint);
    canvas.drawLine(const Offset(0, 340), const Offset(360, 340), Paint()..color = const Color(0xFF3D2136)..strokeWidth = 2);

    // Wooden planks perspective lines converging at (180, 100) (virtual center of room)
    final plankPaint = Paint()
      ..color = const Color(0xFF130610).withOpacity(0.4)
      ..strokeWidth = 1.8;

    final List<double> floorStarts = [-120, -60, 0, 60, 120, 180, 240, 300, 360, 420, 480];
    for (var xStart in floorStarts) {
      // Perspective ray
      final start = Offset(xStart, 480);
      // Converge coordinate slope
      double xEnd = 180 + (xStart - 180) * 0.45;
      canvas.drawLine(start, Offset(xEnd, 340), plankPaint);
    }

    // Horizontal wooden boards offsets
    final boardPaint = Paint()
      ..color = const Color(0xFF130610).withOpacity(0.2)
      ..strokeWidth = 1.0;
    final List<double> boardY = [355, 375, 400, 430, 465];
    for (var y in boardY) {
      canvas.drawLine(Offset(0, y), Offset(360, y), boardPaint);
    }

    // D. Soft Swaying Curtains
    _paintSwayingCurtains(canvas, windTick);

    // E. Placed Furniture Items Rendering
    for (var item in items) {
      if (item.isPlaced) {
        canvas.save();
        // Translate and scale for pop-in bounce animation
        canvas.translate(item.position.dx, item.position.dy);
        canvas.scale(item.scale, item.scale);
        canvas.translate(-item.position.dx, -item.position.dy);

        _paintItem(canvas, item);
        canvas.restore();
      }
    }

    // F. Ambient Light Expansion Layers
    // 1. Lamp light warm bleed
    if (lampIntensity > 0) {
      final lampState = items.firstWhere((e) => e.id == 'lamp');
      final Rect lampGlowRect = Rect.fromCircle(center: Offset(lampState.position.dx - 12, lampState.position.dy - 68), radius: 190);
      final lampGlow = RadialGradient(
        colors: [
          const Color(0xFFFFB359).withOpacity(0.26 * lampIntensity),
          const Color(0xFFFF8000).withOpacity(0.08 * lampIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      );
      canvas.drawCircle(Offset(lampState.position.dx - 12, lampState.position.dy - 68), 190, Paint()..shader = lampGlow.createShader(lampGlowRect)..blendMode = BlendMode.screen);
    }

    // 2. Fairy lights twinkling overlay
    if (lightsIntensity > 0) {
      final lightsState = items.firstWhere((e) => e.id == 'fairy_lights');
      final lightsGlow = RadialGradient(
        colors: [
          const Color(0xFFFFE599).withOpacity(0.12 * lightsIntensity),
          Colors.transparent,
        ],
      );
      canvas.drawCircle(Offset(lightsState.position.dx, lightsState.position.dy + 8), 110, Paint()..shader = lightsGlow.createShader(Rect.fromCircle(center: Offset(lightsState.position.dx, lightsState.position.dy + 8), radius: 110))..blendMode = BlendMode.screen);
    }

    // G. Particles Overlay
    // 1. Floating room dust particles (golden sparks reflecting light)
    for (var d in dust) {
      final double reflectOpacity = d.opacity * (0.3 + 0.7 * (lampIntensity * 0.6 + lightsIntensity * 0.4 + 0.3));
      final dustPaint = Paint()..color = const Color(0xFFFFE8A1).withOpacity(reflectOpacity);
      canvas.drawCircle(Offset(d.x, d.y), d.size, dustPaint);
    }

    // 2. Steaming Coffee steam particles
    for (var s in steam) {
      final steamPaint = Paint()..color = Colors.white.withOpacity(s.opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.size, steamPaint);
    }

    // 3. starburst placement burst particles
    for (var b in bursts) {
      final burstPaint = Paint()..color = b.color.withOpacity(b.opacity);
      canvas.drawCircle(Offset(b.x, b.y), b.size, burstPaint);
    }

    // H. Day-specific Cozy Weather & Atmospheric Overlay Graphics
    if (currentDay == 2) {
      // Draw brick fireplace silhouette at Y: 300, X: 30
      final fireplacePaint = Paint()..color = const Color(0xFF140810);
      canvas.drawRect(const Rect.fromLTWH(20, 270, 48, 70), fireplacePaint);
      
      // Fire hearth cutout using a warm glow
      final fireCutout = Path()
        ..moveTo(26, 340)
        ..lineTo(26, 305)
        ..quadraticBezierTo(44, 290, 62, 305)
        ..lineTo(62, 340)
        ..close();
      
      final fireGlow = RadialGradient(
        colors: [
          const Color(0xFFFF5722).withOpacity(0.85 + 0.15 * math.sin(flickerTick * math.pi * 6)),
          const Color(0xFFFFCC66).withOpacity(0.35),
          Colors.transparent
        ],
      );
      canvas.drawPath(fireCutout, Paint()..shader = fireGlow.createShader(const Rect.fromLTWH(26, 290, 36, 50)));

      // Tiny dancing sparks
      for (int i = 0; i < 4; i++) {
        final sparkX = 35 + (i * 5) + math.sin(timeTick * 10 + i) * 3;
        final sparkY = 325 - (i * 4) - ((timeTick * 40) % 18);
        canvas.drawCircle(Offset(sparkX, sparkY), 1.4, Paint()..color = const Color(0xFFFFCC66));
      }
    }

    if (currentDay == 3) {
      // Ethereal morning sunlight beams sliding down from the top right
      final sunPath = Path()
        ..moveTo(360, 0)
        ..lineTo(220, 0)
        ..lineTo(60, 340)
        ..lineTo(180, 340)
        ..close();
      final sunGlow = LinearGradient(
        colors: [
          const Color(0xFFFFE599).withOpacity(0.14),
          Colors.transparent
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
      canvas.drawPath(sunPath, Paint()..shader = sunGlow.createShader(const Rect.fromLTWH(60, 0, 300, 340))..blendMode = BlendMode.screen);
    }

    if (currentDay == 5) {
      // Swaying hanging plant from ceiling
      final vineColor = const Color(0xFF2E4D36);
      final swayFactor = math.sin(windTick * math.pi * 2) * 5.0;
      
      canvas.drawLine(const Offset(300, 0), Offset(300 + swayFactor * 0.25, 45), Paint()..color = const Color(0xFF140813)..strokeWidth = 1.5);
      
      final plantGlow = Path()
        ..moveTo(290 + swayFactor, 45)
        ..quadraticBezierTo(270 + swayFactor * 1.5, 80, 275 + swayFactor, 110)
        ..moveTo(310 + swayFactor, 45)
        ..quadraticBezierTo(330 + swayFactor * 1.5, 85, 320 + swayFactor, 120);
      canvas.drawPath(plantGlow, Paint()..color = vineColor..strokeWidth = 2.2..style = PaintingStyle.stroke);
      
      canvas.drawCircle(Offset(280 + swayFactor, 65), 4.5, Paint()..color = const Color(0xFF385E42));
      canvas.drawCircle(Offset(320 + swayFactor, 75), 5.0, Paint()..color = const Color(0xFF477252));
      canvas.drawCircle(Offset(275 + swayFactor, 95), 4.0, Paint()..color = const Color(0xFF385E42));
    }

    if (currentDay == 6) {
      // Elegant travel coordinates map painted on the wall behind
      final mapPaint = Paint()
        ..color = const Color(0xFFFFCC66).withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(const Offset(70, 130), 20, mapPaint);
      canvas.drawCircle(const Offset(290, 130), 20, mapPaint);
      
      final mapPath = Path()
        ..moveTo(40, 110)
        ..quadraticBezierTo(60, 100, 80, 120)
        ..quadraticBezierTo(90, 140, 70, 150)
        ..quadraticBezierTo(50, 140, 40, 110)
        ..moveTo(270, 110)
        ..quadraticBezierTo(285, 95, 310, 120)
        ..quadraticBezierTo(320, 145, 295, 155)
        ..quadraticBezierTo(280, 140, 270, 110);
      canvas.drawPath(mapPath, mapPaint);
    }
  }

  // ── BLUEPRINT DRAWING ──

  void _paintBlueprint(Canvas canvas, Size size) {
    // Blueprint Background (cyan grid style)
    final bgPaint = Paint()..color = const Color(0xFF0F1C3F);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 480), bgPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1B326A).withOpacity(0.4)
      ..strokeWidth = 0.8;
    for (double x = 0; x < 360; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, 480), gridPaint);
    }
    for (double y = 0; y < 480; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(360, y), gridPaint);
    }

    // Renders the blueprint sketch of the room frame based on progress
    final sketchPaint = Paint()
      ..color = const Color(0xFF5CE1E6).withOpacity(0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Window blueprint
    final winRect = const Rect.fromLTWH(110, 80, 140, 160);
    _drawSketchedRect(canvas, winRect, sketchPaint, blueprintProgress);

    // Horizon line
    _drawSketchedLine(canvas, const Offset(0, 340), const Offset(360, 340), sketchPaint, blueprintProgress);

    // Floor lines perspective
    final List<double> xOffsets = [0, 90, 180, 270, 360];
    for (var x in xOffsets) {
      double xEnd = 180 + (x - 180) * 0.45;
      _drawSketchedLine(canvas, Offset(x, 480), Offset(xEnd, 340), sketchPaint, blueprintProgress);
    }

    // Soft sketch outline of a house shape behind the window
    final houseOutline = Path()
      ..moveTo(80, 260)
      ..lineTo(80, 180)
      ..lineTo(180, 110)
      ..lineTo(280, 180)
      ..lineTo(280, 260)
      ..close();
    
    // Animate blueprint house drawing path using path metrics
    if (blueprintProgress > 0) {
      final pathPaint = Paint()
        ..color = const Color(0xFF4EE2EC).withOpacity(0.45)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(houseOutline, pathPaint);
    }
  }

  // Draw lines with animated blueprint hand-drawn overlap
  void _drawSketchedLine(Canvas canvas, Offset start, Offset end, Paint paint, double progress) {
    if (progress <= 0) return;
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );
    canvas.drawLine(start, currentEnd, paint);
  }

  void _drawSketchedRect(Canvas canvas, Rect rect, Paint paint, double progress) {
    _drawSketchedLine(canvas, rect.topLeft, rect.topRight, paint, progress);
    _drawSketchedLine(canvas, rect.topRight, rect.bottomRight, paint, progress);
    _drawSketchedLine(canvas, rect.bottomRight, rect.bottomLeft, paint, progress);
    _drawSketchedLine(canvas, rect.bottomLeft, rect.topLeft, paint, progress);
  }

  // ── DETAILED COZY ROOM DETAILS ──

  // Soft curtains blowing in wind
  void _paintSwayingCurtains(Canvas canvas, double wind) {
    // Sway offset based on wind controller values
    double swayX = 4.0 * math.sin(wind * math.pi * 2);
    final curtainColor = const Color(0xFF4C273C).withOpacity(0.7);
    final drapeColor = const Color(0xFF381C2C);

    // Left Curtain: anchors from (90, 80) to (125, 250)
    final Path leftCurtain = Path()
      ..moveTo(90, 80)
      ..quadraticBezierTo(105 + swayX * 0.5, 140, 95 + swayX, 240)
      ..lineTo(125 + swayX, 245)
      ..quadraticBezierTo(115 + swayX * 0.5, 150, 110, 80)
      ..close();
    canvas.drawPath(leftCurtain, Paint()..color = curtainColor);
    canvas.drawPath(leftCurtain, Paint()..color = drapeColor..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // Right Curtain: anchors from (270, 80) to (235, 250)
    final Path rightCurtain = Path()
      ..moveTo(270, 80)
      ..quadraticBezierTo(255 - swayX * 0.5, 140, 265 - swayX, 240)
      ..lineTo(235 - swayX, 245)
      ..quadraticBezierTo(245 - swayX * 0.5, 150, 250, 80)
      ..close();
    canvas.drawPath(rightCurtain, Paint()..color = curtainColor);
    canvas.drawPath(rightCurtain, Paint()..color = drapeColor..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // Curtain rod
    final rodPaint = Paint()
      ..color = const Color(0xFF130710)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(85, 75), const Offset(275, 75), rodPaint);
  }

  // Window sliding rain drops
  void _paintWindowRain(Canvas canvas, Rect bounds) {
    final rainPaint = Paint()
      ..color = const Color(0xFF7FA2CE).withOpacity(0.28)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final random = math.Random(12345); // Consistent pseudo-random
    for (int i = 0; i < 22; i++) {
      double rx = bounds.left + random.nextDouble() * bounds.width;
      double ryStart = bounds.top + random.nextDouble() * bounds.height;
      // Animate sliding down
      double slideOffset = (timeTick * 160 * (0.8 + random.nextDouble() * 0.5)) % bounds.height;
      double y = ryStart + slideOffset;
      if (y > bounds.bottom) {
        y = bounds.top + (y - bounds.bottom);
      }
      // Droplet line
      canvas.drawLine(Offset(rx, y), Offset(rx, y + 4.5 + random.nextDouble() * 4), rainPaint);
    }
  }

  // ── DETAILED VECTOR FURNITURE PIECES ──

  void _paintItem(Canvas canvas, PlacedItemState item) {
    final pos = item.position;
    // If it's a new item, draw a gentle glowing halo behind it
    if (item.isNew) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFCC66).withOpacity(0.18 + 0.08 * math.sin(flickerTick * math.pi * 2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(pos.dx, pos.dy - 30), 28, glowPaint);
    }

    switch (item.id) {
      case 'lamp':
        _drawLamp(canvas, pos);
        break;
      case 'monstera':
        _drawMonstera(canvas, pos);
        break;
      case 'bookshelf':
        _drawBookshelf(canvas, pos);
        break;
      case 'record_player':
        _drawRecordPlayer(canvas, pos);
        break;
      case 'fairy_lights':
        _drawFairyLights(canvas, pos);
        break;
      case 'memory_frame':
        _drawMemoryFrame(canvas, pos);
        break;
      case 'coffee':
        _drawCoffeeCorner(canvas, pos);
        break;
    }

    // Draw floating reaction if present
    if (item.reaction.isNotEmpty) {
      final textSpan = TextSpan(
        text: item.reaction,
        style: TextStyle(fontSize: 16, shadows: [
          Shadow(color: const Color(0xFFFFCC66).withOpacity(0.4), blurRadius: 6)
        ]),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // Floating offset (bobbing slowly)
      final floatOffsetY = math.sin(timeTick * math.pi * 4) * 3.0;
      textPainter.paint(canvas, Offset(pos.dx + 12, pos.dy - 40 + floatOffsetY));
    }
  }

  // 1. Cozy Floor Lamp
  void _drawLamp(Canvas canvas, Offset pos) {
    // Stands at bottom-left corner
    final baseColor = const Color(0xFF140B13);
    final poleColor = const Color(0xFF2C1628);
    final brassColor = const Color(0xFFC09B60);
    final shadeColor = const Color(0xFFD3B78F);
    final activeWarmGlow = const Color(0xFFFFB359).withOpacity(0.55 + 0.1 * math.sin(flickerTick * math.pi * 2));

    // Base
    canvas.drawOval(Rect.fromCenter(center: pos, width: 28, height: 8), Paint()..color = baseColor);
    
    // Pole
    canvas.drawLine(pos, Offset(pos.dx - 12, pos.dy - 82), Paint()..color = poleColor..strokeWidth = 3.0);
    canvas.drawLine(pos, Offset(pos.dx - 12, pos.dy - 82), Paint()..color = brassColor..strokeWidth = 1.0);

    // Arm curve
    final Path arm = Path()
      ..moveTo(pos.dx - 12, pos.dy - 82)
      ..quadraticBezierTo(pos.dx - 15, pos.dy - 94, pos.dx - 22, pos.dy - 86);
    canvas.drawPath(arm, Paint()..color = brassColor..strokeWidth = 2.5..style = PaintingStyle.stroke);

    // Lamp shade bell shape
    final Path shade = Path()
      ..moveTo(pos.dx - 30, pos.dy - 74)
      ..lineTo(pos.dx - 14, pos.dy - 74)
      ..lineTo(pos.dx - 18, pos.dy - 86)
      ..lineTo(pos.dx - 26, pos.dy - 86)
      ..close();
    canvas.drawPath(shade, Paint()..color = shadeColor);

    // Light beam source triangle
    final Path beam = Path()
      ..moveTo(pos.dx - 28, pos.dy - 74)
      ..lineTo(pos.dx - 16, pos.dy - 74)
      ..lineTo(pos.dx + 4, pos.dy + 20)
      ..lineTo(pos.dx - 48, pos.dy + 20)
      ..close();
    
    final beamGradient = LinearGradient(
      colors: [activeWarmGlow, Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawPath(beam, Paint()..shader = beamGradient.createShader(Rect.fromLTWH(pos.dx - 48, pos.dy - 74, 52, 94)));

    // Glass bulb glow
    canvas.drawCircle(Offset(pos.dx - 22, pos.dy - 74), 4.5, Paint()..color = const Color(0xFFFFFFFF));
  }

  // 2. Monstera Cozy Plant
  void _drawMonstera(Canvas canvas, Offset pos) {
    // Sits at bottom-right corner
    final potColor = const Color(0xFF63303F);
    final potRim = const Color(0xFF4C202F);
    final plantStem = const Color(0xFF2E4D36);
    final leafColor1 = const Color(0xFF385E42);
    final leafColor2 = const Color(0xFF477252);

    // Pot
    final potPath = Path()
      ..moveTo(pos.dx - 14, pos.dy)
      ..lineTo(pos.dx + 14, pos.dy)
      ..lineTo(pos.dx + 10, pos.dy + 22)
      ..lineTo(pos.dx - 10, pos.dy + 22)
      ..close();
    canvas.drawPath(potPath, Paint()..color = potColor);
    canvas.drawOval(Rect.fromCenter(center: pos, width: 28, height: 6), Paint()..color = potRim);

    // Stems & Leaves
    // Wind factor drives gentle sway of leaves
    double sway = 2.0 * math.sin(windTick * math.pi * 2);

    // Leaves coordinates
    final List<Offset> stems = [
      Offset(pos.dx - 6, pos.dy - 4),
      Offset(pos.dx + 6, pos.dy - 4),
      Offset(pos.dx, pos.dy - 8),
    ];

    final List<Offset> leafEnds = [
      Offset(pos.dx - 22 + sway, pos.dy - 22),
      Offset(pos.dx + 24 + sway, pos.dy - 24),
      Offset(pos.dx + sway * 0.5, pos.dy - 34),
    ];

    // Stems drawing
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(stems[i], leafEnds[i], Paint()..color = plantStem..strokeWidth = 2.0);
    }

    // Leaf 1: Monstera silhouette left
    final leafLeft = Path()
      ..moveTo(leafEnds[0].dx, leafEnds[0].dy)
      ..quadraticBezierTo(leafEnds[0].dx - 12, leafEnds[0].dy - 10, leafEnds[0].dx - 14, leafEnds[0].dy + 4)
      ..quadraticBezierTo(leafEnds[0].dx - 4, leafEnds[0].dy + 12, leafEnds[0].dx, leafEnds[0].dy)
      ..close();
    canvas.drawPath(leafLeft, Paint()..color = leafColor1);

    // Leaf 2: Monstera right
    final leafRight = Path()
      ..moveTo(leafEnds[1].dx, leafEnds[1].dy)
      ..quadraticBezierTo(leafEnds[1].dx + 14, leafEnds[1].dy - 10, leafEnds[1].dx + 16, leafEnds[1].dy + 4)
      ..quadraticBezierTo(leafEnds[1].dx + 6, leafEnds[1].dy + 12, leafEnds[1].dx, leafEnds[1].dy)
      ..close();
    canvas.drawPath(leafRight, Paint()..color = leafColor2);

    // Leaf 3: Monstera top
    final leafTop = Path()
      ..moveTo(leafEnds[2].dx, leafEnds[2].dy)
      ..quadraticBezierTo(leafEnds[2].dx - 10, leafEnds[2].dy - 14, leafEnds[2].dx, leafEnds[2].dy - 18)
      ..quadraticBezierTo(leafEnds[2].dx + 10, leafEnds[2].dy - 14, leafEnds[2].dx, leafEnds[2].dy)
      ..close();
    canvas.drawPath(leafTop, Paint()..color = leafColor2);
  }

  // 3. Ghibli Bookshelf
  void _drawBookshelf(Canvas canvas, Offset pos) {
    // Sits back right corner
    final woodDark = const Color(0xFF210E17);
    final woodMedium = const Color(0xFF381E29);
    final woodAccent = const Color(0xFF5A3143);

    // Book Colors
    final bookColors = [
      const Color(0xFF8C3E54),
      const Color(0xFFCE9B4E),
      const Color(0xFF4A7A5A),
      const Color(0xFF4C5E8C),
    ];

    // Core shelves outline
    canvas.drawRect(Rect.fromLTWH(pos.dx - 22, pos.dy - 100, 44, 100), Paint()..color = woodDark);
    
    // Outer frame
    final framePaint = Paint()
      ..color = woodMedium
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(pos.dx - 22, pos.dy - 100, 44, 100), framePaint);

    // Shelves separators (3 horizontal shelves)
    canvas.drawLine(Offset(pos.dx - 22, pos.dy - 66), Offset(pos.dx + 22, pos.dy - 66), Paint()..color = woodMedium..strokeWidth = 3.0);
    canvas.drawLine(Offset(pos.dx - 22, pos.dy - 33), Offset(pos.dx + 22, pos.dy - 33), Paint()..color = woodMedium..strokeWidth = 3.0);

    // Decorative crown molding at top
    canvas.drawRect(Rect.fromLTWH(pos.dx - 24, pos.dy - 104, 48, 5), Paint()..color = woodAccent);

    // Shelf 1 Books (Top)
    for (int i = 0; i < 4; i++) {
      double bx = pos.dx - 18 + i * 9;
      double bh = 14 + i * 2;
      canvas.drawRect(Rect.fromLTWH(bx, pos.dy - 66 - bh, 6.5, bh), Paint()..color = bookColors[i % bookColors.length]);
    }

    // Shelf 2 Books (Middle) - Slanted book
    canvas.drawRect(Rect.fromLTWH(pos.dx - 18, pos.dy - 33 - 18, 6.5, 18), Paint()..color = bookColors[1]);
    canvas.drawRect(Rect.fromLTWH(pos.dx - 10, pos.dy - 33 - 16, 6.5, 16), Paint()..color = bookColors[2]);
    // Slanted book drawer
    canvas.save();
    canvas.translate(pos.dx + 2, pos.dy - 33);
    canvas.rotate(0.24);
    canvas.drawRect(const Rect.fromLTWH(0, -18, 6.5, 18), Paint()..color = bookColors[0]);
    canvas.restore();

    // Shelf 3 Plant overlay (Bottom)
    final potColor = const Color(0xFF7A513E);
    canvas.drawOval(Rect.fromCenter(center: Offset(pos.dx, pos.dy - 8), width: 12, height: 6), Paint()..color = potColor);
    final vineColor = const Color(0xFF4C8C5E);
    // Hanging foliage
    final vinePath = Path()
      ..moveTo(pos.dx - 4, pos.dy - 8)
      ..quadraticBezierTo(pos.dx - 8, pos.dy, pos.dx - 6, pos.dy + 8)
      ..moveTo(pos.dx + 4, pos.dy - 8)
      ..quadraticBezierTo(pos.dx + 8, pos.dy, pos.dx + 6, pos.dy + 12);
    canvas.drawPath(vinePath, Paint()..color = vineColor..strokeWidth = 1.8..style = PaintingStyle.stroke);
  }

  // 4. Vintage Record Player
  void _drawRecordPlayer(Canvas canvas, Offset pos) {
    // Placed bottom-left table top
    final tableTop = const Color(0xFF26101B);
    final playerBase = const Color(0xFF6E4E37);
    final discColor = const Color(0xFF140D18);
    final goldBrass = const Color(0xFFD4AF37);

    // Mini table
    canvas.drawOval(Rect.fromCenter(center: pos, width: 48, height: 8), Paint()..color = tableTop);
    canvas.drawLine(pos, Offset(pos.dx - 8, pos.dy + 24), Paint()..color = tableTop..strokeWidth = 2);
    canvas.drawLine(pos, Offset(pos.dx + 8, pos.dy + 24), Paint()..color = tableTop..strokeWidth = 2);

    // Player Box Base
    final baseRect = Rect.fromLTWH(pos.dx - 18, pos.dy - 12, 36, 12);
    canvas.drawRect(baseRect, Paint()..color = playerBase);

    // Vinyl Disc (Rotates continuously using timeTick)
    double angle = timeTick * math.pi * 2 * 6; // Spin records
    canvas.save();
    canvas.translate(pos.dx, pos.dy - 12);
    canvas.rotate(angle);
    // Outer disc
    canvas.drawCircle(Offset.zero, 13, Paint()..color = discColor);
    // Groove circle
    canvas.drawCircle(Offset.zero, 9, Paint()..color = Colors.white.withOpacity(0.12)..style = PaintingStyle.stroke..strokeWidth = 0.6);
    // Center label
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = goldBrass);
    canvas.restore();

    // Golden Gramophone Horn Arm
    final Path hornArm = Path()
      ..moveTo(pos.dx + 12, pos.dy - 10)
      ..quadraticBezierTo(pos.dx + 16, pos.dy - 26, pos.dx + 6, pos.dy - 32);
    canvas.drawPath(hornArm, Paint()..color = goldBrass..strokeWidth = 2.0..style = PaintingStyle.stroke);
    
    // Gramophone Bell opening
    canvas.drawCircle(Offset(pos.dx + 6, pos.dy - 32), 6.5, Paint()..color = goldBrass);

    // Draw little floating musical notes if rotating
    double noteOffset = (timeTick * 40) % 24;
    canvas.drawCircle(Offset(pos.dx - 8 - noteOffset * 0.4, pos.dy - 24 - noteOffset), 1.5, Paint()..color = goldBrass.withOpacity((24 - noteOffset) / 24));
    canvas.drawCircle(Offset(pos.dx + 2 + noteOffset * 0.2, pos.dy - 38 - noteOffset), 1.2, Paint()..color = const Color(0xFFDD8F9F).withOpacity((24 - noteOffset) / 24));
  }

  // 5. Hanging Fairy Lights
  void _drawFairyLights(Canvas canvas, Offset pos) {
    // Coordinates across top: left (90, 78) to right (270, 78)
    final wirePaint = Paint()
      ..color = const Color(0xFF130710).withOpacity(0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Drapes in curves
    final Path wire = Path()
      ..moveTo(90, 78)
      ..quadraticBezierTo(135, 96, 180, 80)
      ..quadraticBezierTo(225, 96, 270, 78);
    canvas.drawPath(wire, wirePaint);

    // Glowing fairy bulbs offsets
    final List<Offset> bulbPositions = [
      const Offset(105, 83),
      const Offset(125, 88),
      const Offset(145, 90),
      const Offset(165, 86),
      const Offset(195, 86),
      const Offset(215, 90),
      const Offset(235, 88),
      const Offset(255, 83),
    ];

    for (int i = 0; i < bulbPositions.length; i++) {
      var p = bulbPositions[i];
      // Twinkle bulbs alternatively using flickerTick
      double twinkle = (i % 2 == 0)
          ? (0.5 + 0.5 * math.sin(flickerTick * math.pi * 2))
          : (0.5 + 0.5 * math.cos(flickerTick * math.pi * 2));

      final bulbPaint = Paint()..color = const Color(0xFFFFE599).withOpacity(0.4 + 0.6 * twinkle);
      canvas.drawCircle(p, 2.5, bulbPaint);

      // Bulb halo glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFFB359).withOpacity(0.24 * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(p, 7.0, glowPaint);
    }
  }

  // 6. Tiny Memory Frame
  void _drawMemoryFrame(Canvas canvas, Offset pos) {
    // Sits in middle wall: (180, 110)
    final goldFrame = const Color(0xFFC5A059);
    final canvasBg = const Color(0xFF1E101D);
    final drawingColor = const Color(0xFFDD8F9F).withOpacity(0.7 + 0.3 * math.sin(flickerTick * math.pi * 2));

    // Outer wood frame
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 26, height: 32), const Radius.circular(3)), Paint()..color = goldFrame);
    
    // Canvas inner cutout
    canvas.drawRect(Rect.fromCenter(center: pos, width: 20, height: 26), Paint()..color = canvasBg);

    // Glowing handwritten vector heart outline sketch inside
    final Path miniHeart = Path()
      ..moveTo(pos.dx, pos.dy + 3)
      ..cubicTo(pos.dx - 6, pos.dy - 3, pos.dx - 6, pos.dy - 9, pos.dx, pos.dy - 5)
      ..cubicTo(pos.dx + 6, pos.dy - 9, pos.dx + 6, pos.dy - 3, pos.dx, pos.dy + 3)
      ..close();
    
    final heartPaint = Paint()
      ..color = drawingColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(miniHeart, heartPaint);
  }

  // 7. Coffee Corner with Steam
  void _drawCoffeeCorner(Canvas canvas, Offset pos) {
    // Placed left of window: pos at (100, 330)
    final tableWood = const Color(0xFF381928);
    final tableBorder = const Color(0xFF26101B);
    final mugColor = const Color(0xFFDD8F9F);
    final coffeeDark = const Color(0xFF3D1F23);

    // Coffee stool table
    canvas.drawOval(Rect.fromCenter(center: pos, width: 34, height: 6), Paint()..color = tableWood);
    canvas.drawOval(Rect.fromCenter(center: pos, width: 34, height: 6), Paint()..color = tableBorder..strokeWidth = 1.0..style = PaintingStyle.stroke);
    
    // Stool leg
    canvas.drawLine(pos, Offset(pos.dx, pos.dy + 24), Paint()..color = tableBorder..strokeWidth = 3.0);
    // Tripod feet
    canvas.drawLine(Offset(pos.dx, pos.dy + 24), Offset(pos.dx - 8, pos.dy + 34), Paint()..color = tableBorder..strokeWidth = 2.0);
    canvas.drawLine(Offset(pos.dx, pos.dy + 24), Offset(pos.dx + 8, pos.dy + 34), Paint()..color = tableBorder..strokeWidth = 2.0);

    // Ceramic Mug
    final mugPos = Offset(pos.dx, pos.dy - 6);
    final Path mug = Path()
      ..moveTo(mugPos.dx - 5, mugPos.dy)
      ..lineTo(mugPos.dx + 5, mugPos.dy)
      ..lineTo(mugPos.dx + 4.5, mugPos.dy + 10)
      ..lineTo(mugPos.dx - 4.5, mugPos.dy + 10)
      ..close();
    canvas.drawPath(mug, Paint()..color = mugColor);

    // Mug rim oval
    canvas.drawOval(Rect.fromCenter(center: mugPos, width: 10, height: 3), Paint()..color = mugColor);
    // Dark coffee inside mug
    canvas.drawOval(Rect.fromCenter(center: mugPos, width: 8, height: 2), Paint()..color = coffeeDark);

    // Mug handle
    final Path handle = Path()
      ..moveTo(mugPos.dx - 4.5, mugPos.dy + 2)
      ..quadraticBezierTo(mugPos.dx - 9, mugPos.dy + 5, mugPos.dx - 4.5, mugPos.dy + 8);
    canvas.drawPath(handle, Paint()..color = mugColor..strokeWidth = 1.5..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
