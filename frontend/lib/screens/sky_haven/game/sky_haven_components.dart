import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../models/sky_haven_models.dart';
import 'sky_haven_game.dart';
import 'sky_haven_systems.dart';

// ─────────────────────────────────────────────
// IslandComponent
// ─────────────────────────────────────────────
class IslandComponent extends PositionComponent with HasGameReference<SkyHavenGame> {
  final VoidCallback? onTapEmpty;
  
  SpriteComponent? baseComp;
  
  // Layer components to guarantee correct rendering order
  final PositionComponent groundLayer = PositionComponent();
  final PositionComponent objectsLayer = PositionComponent(); // Dynamic Y-Sorted layer
  final PositionComponent particlesLayer = PositionComponent();
  
  IslandComponent({this.onTapEmpty}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set layer priorities
    groundLayer.priority = DepthManager.layerGround;
    objectsLayer.priority = DepthManager.layerObjects;
    particlesLayer.priority = DepthManager.layerParticles;
    
    // Ensure layers size perfectly matches IslandComponent size so relative positions work
    groundLayer.size = size;
    objectsLayer.size = size;
    particlesLayer.size = size;
    
    add(groundLayer);
    add(objectsLayer);
    add(particlesLayer);
  }
  
  void addPlacedObject(PlacedObjectComponent obj) {
    if (obj.item.layer == DepthManager.layerIslandBase) {
      groundLayer.add(obj);
    } else {
      objectsLayer.add(obj);
    }
  }

  void removePlacedObject(String instanceId) {
    for (final layer in [groundLayer, objectsLayer, particlesLayer]) {
      final comp = layer.children.whereType<PlacedObjectComponent>().cast<PlacedObjectComponent?>().firstWhere(
        (c) => c!.item.instanceId == instanceId,
        orElse: () => null,
      );
      if (comp != null) {
        comp.removeFromParent();
        break;
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    groundLayer.size = size;
    objectsLayer.size = size;
    particlesLayer.size = size;
    
    // Also need to resize and re-center baseComp
    if (baseComp != null && baseComp!.sprite != null) {
      final ratio = baseComp!.sprite!.srcSize.x / baseComp!.sprite!.srcSize.y;
      final targetHeight = size.y * 0.85;
      baseComp!.size = Vector2(targetHeight * ratio, targetHeight);
      baseComp!.position = Vector2(size.x / 2, size.y / 2);
    }
  }
}

// ─────────────────────────────────────────────
// PlacedObjectComponent
// ─────────────────────────────────────────────
class PlacedObjectComponent extends PositionComponent with HasGameReference<SkyHavenGame> {
  final PlacedItem item;
  final void Function(PlacedItem)? onTapped;
  bool nightMode;

  SpriteComponent? _spriteComp;
  bool _loaded = false;
  double _animTime = 0;

  PlacedObjectComponent({
    required this.item,
    this.onTapped,
    this.nightMode = false,
  }) : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Position is already calculated relative to the parent layer (which matches Island size)
    position = Vector2(
      item.normalizedPosition.dx * (parent as PositionComponent).size.x,
      item.normalizedPosition.dy * (parent as PositionComponent).size.y,
    );

    try {
      final flamePath = item.item.assetPath.replaceFirst('assets/', '');
      final sprite = await game.loadSprite(flamePath);
      
      final baseSize = game.size.x * item.scale;
      final ratio = sprite.srcSize.y / sprite.srcSize.x;
      
      // 1. Add Ambient Occlusion (tight, dark shadow) + Soft Drop Shadow
      final shadowW = baseSize * 0.65;
      
      final dropShadow = CircleComponent(
        radius: shadowW / 2,
        paint: Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
        anchor: Anchor.center,
        position: Vector2(0, -5), // Slightly offset
      );
      dropShadow.scale = Vector2(1.0, 0.4);
      add(dropShadow);

      final aoShadow = CircleComponent(
        radius: shadowW * 0.35,
        paint: Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        anchor: Anchor.center,
        position: Vector2(0, 0),
      );
      aoShadow.scale = Vector2(1.0, 0.3);
      add(aoShadow);

      // 2. Add Sprite
      final sc = SpriteComponent(
        sprite: sprite,
        size: Vector2(baseSize, baseSize * ratio),
        anchor: Anchor.bottomCenter,
      );
      sc.opacity = 0;
      _spriteComp = sc;
      add(sc);

      // 3. Environmental Animations & Terrain Blending
      final n = item.item.name.toLowerCase();
      if (item.item.category == SkyItemCategory.nature) {
        // Procedural terrain blending: Soft moss/grass shadow around base to eliminate hard PNG edges
        final blendBase = CircleComponent(
          radius: shadowW * 0.45,
          paint: Paint()
            ..color = const Color(0xFF558B2F).withOpacity(0.4) // Deep green moss
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          anchor: Anchor.center,
          position: Vector2(0, -2),
        );
        blendBase.scale = Vector2(1.0, 0.4);
        add(blendBase);
      }

      if (item.item.category == SkyItemCategory.nature && n.contains('tree')) {
        // Swaying in the wind
        sc.add(RotateEffect.by(
          0.04,
          EffectController(
            duration: 2.0 + math.Random().nextDouble(),
            curve: Curves.easeInOut,
            alternate: true,
            infinite: true,
          ),
        ));
      } else if (item.item.category == SkyItemCategory.water) {
        // Breathing/Rippling water
        sc.add(ScaleEffect.by(
          Vector2(1.02, 1.01),
          EffectController(
            duration: 1.5 + math.Random().nextDouble(),
            curve: Curves.easeInOut,
            alternate: true,
            infinite: true,
          ),
        ));
      } else if (item.item.category == SkyItemCategory.wonder) {
        // Subtle floating
        sc.add(MoveEffect.by(
          Vector2(0, -4),
          EffectController(
            duration: 1.5 + math.Random().nextDouble(),
            curve: Curves.easeInOutSine,
            alternate: true,
            infinite: true,
          ),
        ));
      }

      // Apply saved rotation (using horizontal flip is just scale.x = -scale.x, but rotation is requested)
      _spriteComp!.angle = item.rotation;

      // Fade in
      sc.add(OpacityEffect.to(1.0, EffectController(duration: 0.4)));

      // Drop & bounce on placement
      if (item.isAnimating) {
        sc.scale = Vector2.all(0.8);
        sc.position = Vector2(0, -60); // lifted up
        
        sc.add(ScaleEffect.to(
          Vector2.all(1.05),
          EffectController(duration: 0.25, curve: Curves.easeOut),
          onComplete: () => sc.add(ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: 0.15),
          )),
        ));
        
        sc.add(MoveEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.4, curve: Curves.bounceOut),
          onComplete: () {
            // Magical dust burst on landing
            // Huge Magical dust burst on landing
            for (int i = 0; i < 12; i++) {
              final angle = (i / 12) * math.pi * 2;
              final dist = 40.0 + math.Random().nextDouble() * 30.0;
              final dx = math.cos(angle) * dist;
              final dy = math.sin(angle) * dist;
              
              final dust = CircleComponent(
                radius: 4 + math.Random().nextDouble() * 4,
                paint: Paint()..color = Colors.white.withOpacity(0.9),
                position: Vector2.zero(),
                anchor: Anchor.center,
              );
              add(dust);
              dust.add(MoveEffect.by(Vector2(dx, dy), EffectController(duration: 0.6, curve: Curves.easeOut)));
              dust.add(OpacityEffect.to(0.0, EffectController(duration: 0.6, curve: Curves.easeOut)));
              Future.delayed(const Duration(milliseconds: 600), () {
                if (dust.isMounted) dust.removeFromParent();
              });
            }
          }
        ));

      }
      _loaded = true;
    } catch (e) {
      debugPrint('SkyHaven: cannot load ${item.item.assetPath}: $e');
    }
  }

  // Removed missing magic dust asset logic

  @override
  void update(double dt) {
    super.update(dt);
    if (!_loaded || _spriteComp == null) return;
    _animTime += dt;
    
    // Update position dynamically based on parent size (responsive)
    final parentSize = (parent as PositionComponent).size;
    position = Vector2(
      item.normalizedPosition.dx * parentSize.x,
      item.normalizedPosition.dy * parentSize.y,
    );

    // Dynamic Y-Sorting + Manual zOffset
    priority = position.y.toInt() + item.zOffset;

    // Scale updates dynamically (from edit mode slider)
    final baseSize = game.size.x * item.scale;
    final ratio = _spriteComp!.sprite!.srcSize.y / _spriteComp!.sprite!.srcSize.x;
    _spriteComp!.size = Vector2(baseSize, baseSize * ratio);
    _spriteComp!.angle = item.rotation;

    // Glow pulse for lights
    if (item.item.category == SkyItemCategory.lights) {
      _spriteComp!.opacity = nightMode ? WorldAnimationManager.getPulseOpacity(_animTime) : 1.0;
    }
  }

  void setNightMode(bool night) => nightMode = night;

  void setSelected(bool selected) {
    if (!_loaded || _spriteComp == null) return;
    if (selected) {
      _spriteComp!.paint.colorFilter = const ColorFilter.mode(
        Colors.white30, BlendMode.srcATop
      );
      // Adding a subtle bounding box indicator is tricky without a separate rect component.
      // So we'll tint it white slightly, and scale up slightly.
      _spriteComp!.add(ScaleEffect.to(Vector2.all(1.05), EffectController(duration: 0.2)));
    } else {
      _spriteComp!.paint.colorFilter = null;
      _spriteComp!.add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2)));
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (_spriteComp == null) return super.containsLocalPoint(point);
    // Since we anchor at bottomCenter, adjust point check
    final rect = Rect.fromLTWH(
      - _spriteComp!.size.x / 2,
      - _spriteComp!.size.y,
      _spriteComp!.size.x,
      _spriteComp!.size.y,
    );
    return rect.contains(point.toOffset());
  }
}

// ─────────────────────────────────────────────
// DragPreviewComponent
// ─────────────────────────────────────────────
class DragPreviewComponent extends PositionComponent with HasGameReference<SkyHavenGame> {
  final PlacedItem previewItem;
  SpriteComponent? _spriteComp;
  bool _loaded = false;
  
  DragPreviewComponent(this.previewItem) : super(anchor: Anchor.bottomCenter);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = DepthManager.layerDragPreview;
    
    try {
      final flamePath = previewItem.item.assetPath.replaceFirst('assets/', '');
      final sprite = await game.loadSprite(flamePath);
      
      final baseSize = game.size.x * previewItem.scale;
      final ratio = sprite.srcSize.y / sprite.srcSize.x;
      
      _spriteComp = SpriteComponent(
        sprite: sprite,
        size: Vector2(baseSize, baseSize * ratio),
        anchor: Anchor.bottomCenter,
      );
      
      // 70% opacity for preview
      _spriteComp!.opacity = 0.7;
      
      add(_spriteComp!);
      _loaded = true;
    } catch (e) {}
  }

  void setValid(bool valid) {
    if (!_loaded || _spriteComp == null) return;
    if (valid) {
      // Green tint for valid placement
      _spriteComp!.paint.colorFilter = const ColorFilter.mode(
        Color(0x884CAF50), BlendMode.srcATop
      );
    } else {
      // Red tint for invalid placement
      _spriteComp!.paint.colorFilter = const ColorFilter.mode(
        Color(0x88F44336), BlendMode.srcATop
      );
    }
  }

  void updateVisuals() {
    if (!_loaded || _spriteComp == null) return;
    final baseSize = game.size.x * previewItem.scale;
    final ratio = _spriteComp!.sprite!.srcSize.y / _spriteComp!.sprite!.srcSize.x;
    _spriteComp!.size = Vector2(baseSize, baseSize * ratio);
    _spriteComp!.angle = previewItem.rotation;
  }
}
