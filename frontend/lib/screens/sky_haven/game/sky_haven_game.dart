import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import '../models/sky_haven_models.dart';
import 'sky_haven_components.dart';
import 'sky_haven_systems.dart';

// ─────────────────────────────────────────────
// SkyHavenGame — Flame Game
// ─────────────────────────────────────────────
class SkyHavenGame extends FlameGame with ScaleDetector, DoubleTapDetector, TapCallbacks {
  final VoidCallback? onTapEmptyIsland;
  final void Function(PlacedItem item)? onItemTapped;
  final void Function(List<PlacedItem> items)? onMultipleItemsTapped;

  SkyHavenGame({this.onTapEmptyIsland, this.onItemTapped, this.onMultipleItemsTapped});

  late IslandComponent _islandWorld;
  final PlacementManager placementManager = PlacementManager();
  
  DragPreviewComponent? _dragPreview;
  List<PlacedItem>? _cachedDragItems;
  bool _nightMode = false;
  double _floatTime = 0;
  bool itemsLoaded = false;
  
  @override
  Color backgroundColor() => Colors.transparent;



  void focusOnPlacement(Vector2 pos) {
    // Subtle zoom in
    final currentZoom = camera.viewfinder.zoom;
    camera.viewfinder.add(
      ScaleEffect.to(Vector2.all(currentZoom * 1.05), EffectController(duration: 0.3, curve: Curves.easeOut, alternate: true)),
    );
    // Start camera zoomed out to show the whole island
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.position = Vector2.zero();
  }

  void clampCameraPan() {
    // With targetHeight 0.85, the island occupies most of the screen.
    // Allow panning up to the full screen size to inspect edges.
    final maxX = size.x;
    final maxY = size.y;
    
    final p = camera.viewfinder.position;
    if (p.x > maxX) p.x = maxX;
    if (p.x < -maxX) p.x = -maxX;
    if (p.y > maxY) p.y = maxY;
    if (p.y < -maxY) p.y = -maxY;
  }

  void resetCamera() {
    camera.viewfinder.add(
      ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.easeInOut)),
    );
    camera.viewfinder.add(
      MoveEffect.to(Vector2.zero(), EffectController(duration: 0.5, curve: Curves.easeInOut)),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Flame.images.prefix = 'assets/';

    _islandWorld = IslandComponent(
      onTapEmpty: onTapEmptyIsland,
    );
    // Position at 0,0 and anchor center so the world aligns with the camera.
    _islandWorld.position = Vector2.zero();
    // Default size to center perfectly on the screen without cropping
    _islandWorld.size = size;
    
    world.add(_islandWorld);

    // Decorative clouds and particles temporarily disabled for cleaner presentation
    // _spawnClouds();
    // _spawnParticles();
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _islandWorld.size = size;
      _islandWorld.onGameResize(size);
    }
  }

  // ─────────────────────────────────────────────
  // Native Flame Camera Controls
  // ─────────────────────────────────────────────
  
  double _initialZoom = 1.0;
  
  @override
  void onScaleStart(ScaleStartInfo info) {
    _initialZoom = camera.viewfinder.zoom;
    if (placementManager.isDragging) {
      updateItemDrag(Vector2(info.raw.localFocalPoint.dx, info.raw.localFocalPoint.dy));
    }
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final details = info.raw;
    // In placement mode, ANY drag should move the item, and camera should be locked.
    if (placementManager.isDragging) {
      updateItemDrag(Vector2(details.localFocalPoint.dx, details.localFocalPoint.dy));
      return; 
    }

    // Normal Mode: Zoom and Two-finger Pan only
    if (details.pointerCount >= 2) {
      if (details.scale != 1.0) {
        final newZoom = (_initialZoom * details.scale).clamp(0.8, 3.0);
        camera.viewfinder.zoom = newZoom;
      }
      
      final delta = details.focalPointDelta;
      camera.viewfinder.position -= Vector2(delta.dx, delta.dy) / camera.viewfinder.zoom;
      clampCameraPan();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    
    // 1. Get world coordinate of tap
    final globalPos = event.canvasPosition;
    
    // 2. Find all components at this point
    final components = componentsAtPoint(globalPos).whereType<PlacedObjectComponent>().toList();
    
    if (components.isNotEmpty) {
      if (components.length == 1) {
        onItemTapped?.call(components.first.item);
      } else {
        // If multiple items are overlapping, trigger the disambiguation popup
        onMultipleItemsTapped?.call(components.map((c) => c.item).toList());
      }
    } else {
      onTapEmptyIsland?.call();
    }
  }

  @override
  void onDoubleTap() {
    resetCamera();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Island floating animation has been removed to keep the base fixed.
  }

  void _spawnClouds() {
    final rng = math.Random();
    final cloudPaths = [
      'island/moving cloud.png',
      'island/large cloud.png',
      'island/cloud cluster.png',
    ];
    for (int i = 0; i < 5; i++) {
      world.add(CloudComponent(
        assetPath: cloudPaths[i % cloudPaths.length],
        startX: rng.nextDouble() * size.x,
        startY: 40.0 + rng.nextDouble() * (size.y * 0.32),
        driftSpeed: 12.0 + rng.nextDouble() * 18.0,
        displayScale: 0.2 + rng.nextDouble() * 0.3,
        screenWidth: size.x,
      ));
    }
  }

  void _spawnParticles() {
    // Ambient floating particles removed per user request
  }

  IslandComponent get worldIsland => _islandWorld;

  // ─────────────────────────────────────────────
  // Drag & Placement Public API
  // ─────────────────────────────────────────────
  List<PlacedItem> get _allPlacedItems {
    final items = <PlacedItem>[];
    for (final layer in [_islandWorld.groundLayer, _islandWorld.objectsLayer, _islandWorld.particlesLayer]) {
      items.addAll(layer.children.whereType<PlacedObjectComponent>().map((c) => c.item));
    }
    return items;
  }
  
  void loadInitialItems(List<PlacedItem> items) {
    if (itemsLoaded) return;
    for (final item in items) {
      if (item.item.category == SkyItemCategory.islandBase) continue;
      final comp = PlacedObjectComponent(
        item: item,
        onTapped: onItemTapped,
        nightMode: _nightMode,
      );
      // Fast load (no drop animation for initial load)
      item.isAnimating = false;
      _islandWorld.addPlacedObject(comp);
    }
    itemsLoaded = true;
  }

  void setSelectedItem(String? instanceId) {
    for (final layer in [_islandWorld.groundLayer, _islandWorld.objectsLayer, _islandWorld.particlesLayer]) {
      for (final comp in layer.children.whereType<PlacedObjectComponent>()) {
        comp.setSelected(comp.item.instanceId == instanceId);
      }
    }
  }

  void removeItem(String instanceId) {
    _islandWorld.removePlacedObject(instanceId);
  }

  void beginItemDrag(PlacedItem item) {
    _cachedDragItems = _allPlacedItems;
    placementManager.beginDrag(item);
    _dragPreview = DragPreviewComponent(placementManager.previewItem!);
    world.add(_dragPreview!);
  }
  
  void updateItemDrag(Vector2 canvasPos) {
    if (placementManager.isDragging && _dragPreview != null && _cachedDragItems != null) {
      // Convert screen coordinate to Flame world coordinate taking zoom and pan into account!
      final worldPos = camera.globalToLocal(canvasPos);

      // Calculate island-relative position
      final islandLocalPos = worldPos - _islandWorld.position + (_islandWorld.size / 2);
      placementManager.updateDrag(islandLocalPos, _islandWorld.size, _cachedDragItems!);
      
      // Update preview visual position to the snapped canvas position
      final snappedCanvasPos = placementManager.snappedPosition! + _islandWorld.position - (_islandWorld.size / 2);
      _dragPreview!.position = snappedCanvasPos;
      _dragPreview!.setValid(placementManager.isValid);
    }
  }

  void updateDragPreviewVisuals() {
    _dragPreview?.updateVisuals();
    updateDragValidity();
  }

  void updateDragValidity() {
    if (placementManager.isDragging) {
      placementManager.recalculateValidity(_islandWorld.size, _cachedDragItems ?? []);
      _dragPreview?.setValid(placementManager.isValid);
    }
  }
  
  PlacedItem? finalizeItemDrag() {
    if (_dragPreview != null) {
      _dragPreview!.removeFromParent();
      _dragPreview = null;
    }
    
    if (placementManager.isDragging) {
      final finalItem = placementManager.finalizeDrag(_islandWorld.size, _cachedDragItems ?? _allPlacedItems);
      _cachedDragItems = null;
      if (finalItem != null) {
        // Validation already happened in finalizeDrag
        final comp = PlacedObjectComponent(
          item: finalItem,
          onTapped: onItemTapped,
          nightMode: _nightMode,
        );
        _islandWorld.addPlacedObject(comp);
        // Subtle focus
        focusOnPlacement(comp.position);
        
        return finalItem;
      }
    }
    _cachedDragItems = null;
    return null;
  }
  
  void cancelItemDrag() {
    if (_dragPreview != null) {
      _dragPreview!.removeFromParent();
      _dragPreview = null;
    }
    placementManager.cancelDrag();
    _cachedDragItems = null;
  }

  // ─────────────────────────────────────────────
  // Cinematics & Expansion
  // ─────────────────────────────────────────────
  
  Future<void> playExpansion(VoidCallback onDone) async {
    final rng = math.Random();
    try {
      final chunkSprite = await loadSprite('island/new_land_chunk.png');
      final swirlSprite = await loadSprite('island/cloud_swirl.png');

      final swirl = SpriteComponent(
        sprite: swirlSprite,
        size: size * 1.2,
        anchor: Anchor.center,
        priority: DepthManager.layerForegroundClouds,
      );
      swirl.opacity = 0;
      world.add(swirl);
      swirl.add(OpacityEffect.to(0.85, EffectController(duration: 0.6)));
      await Future.delayed(const Duration(milliseconds: 700));

      final chunk = SpriteComponent(
        sprite: chunkSprite,
        size: size * 0.38,
        anchor: Anchor.center,
        position: Vector2(
          (rng.nextDouble() - 0.5) * size.x * 0.6,
          size.y * 0.25 + rng.nextDouble() * 50,
        ),
      );
      chunk.opacity = 0;
      _islandWorld.groundLayer.add(chunk); // Add to ground layer
      chunk.add(OpacityEffect.to(1.0, EffectController(duration: 0.8)));

      await Future.delayed(const Duration(milliseconds: 900));
      swirl.add(OpacityEffect.to(0.0, EffectController(duration: 0.5)));
      await Future.delayed(const Duration(milliseconds: 600));
      swirl.removeFromParent();
    } catch (e) {
      debugPrint('SkyHaven: expansion error: $e');
    }
    onDone();
  }

  Future<void> playIslandAwakeningCinematic(SkyItem baseItem, VoidCallback onComplete) async {
    final flamePath = baseItem.assetPath.replaceFirst('assets/', '');
    SpriteComponent? baseComp;
    try {
      final baseSprite = await loadSprite(flamePath);
      final ratio = baseSprite.srcSize.x / baseSprite.srcSize.y;
      
      // Target height is 85% of the screen height, width derived from ratio
      final targetHeight = size.y * 0.85;
      final targetWidth = targetHeight * ratio;
      final targetSize = Vector2(targetWidth, targetHeight);
      
      baseComp = SpriteComponent(
        sprite: baseSprite,
        size: targetSize,
        anchor: Anchor.center,
        position: Vector2(_islandWorld.size.x / 2, _islandWorld.size.y / 2 + 150), // Start from slightly below
      );
      baseComp.scale = Vector2.all(0.9);
      baseComp.opacity = 0;
      _islandWorld.baseComp = baseComp;
      _islandWorld.groundLayer.add(baseComp);
      
      // Move up and fade in
      baseComp.add(OpacityEffect.to(1.0, EffectController(duration: 1.5)));
      baseComp.add(MoveEffect.to(
        Vector2(_islandWorld.size.x / 2, _islandWorld.size.y / 2),
        EffectController(duration: 2.5, curve: Curves.easeOutCubic),
      ));
      
      // Scale up
      baseComp.add(ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 2.5, curve: Curves.easeOutCubic),
      ));
      
      // Camera zoom cinematic (zoom in to 1.15x, then settle back to 1.0)
      camera.viewfinder.add(
        ScaleEffect.to(Vector2.all(1.15), EffectController(duration: 1.5, curve: Curves.easeInOut)),
      );
      
    } catch (e) {
      debugPrint('SkyHaven: island base load error: $e');
    }

    // Swirling magic particles and glow around the awakening island
    final particles = <SpriteComponent>[];
    try {
      final swirlSprite = await loadSprite('island/cloud_swirl.png');
      
      final swirl = SpriteComponent(
        sprite: swirlSprite,
        size: Vector2(size.x * 0.6, size.x * 0.6),
        anchor: Anchor.center,
        position: baseComp!.position,
        priority: DepthManager.layerForegroundClouds,
      );
      _islandWorld.particlesLayer.add(swirl);
      swirl.add(OpacityEffect.to(0.6, EffectController(duration: 1.0)));
      swirl.add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 2.5, curve: Curves.easeOut)));
      particles.add(swirl);
      
      // Subtle light beam/glow
      final beam = SpriteComponent(
        sprite: swirlSprite, // re-using swirl as a generic glow with color filter
        size: Vector2(size.x * 0.8, size.x * 0.8),
        anchor: Anchor.center,
        position: baseComp.position,
        priority: DepthManager.layerBackgroundClouds,
      );
      beam.paint.colorFilter = const ColorFilter.mode(Colors.yellowAccent, BlendMode.srcIn);
      beam.opacity = 0;
      _islandWorld.particlesLayer.add(beam);
      beam.add(OpacityEffect.to(0.3, EffectController(duration: 1.5, alternate: true)));
      particles.add(beam);

    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 2500));

    // Fade out particles
    for (final p in particles) {
      p.add(OpacityEffect.to(0.0, EffectController(duration: 1.0)));
    }
    
    // Reset camera zoom and position to frame the whole island beautifully
    camera.viewfinder.add(
      ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 1.0, curve: Curves.easeInOut)),
    );
    camera.viewfinder.add(
      MoveEffect.to(Vector2.zero(), EffectController(duration: 1.0, curve: Curves.easeInOut)),
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    for (final p in particles) {
      p.removeFromParent();
    }
    onComplete();
  }

  Future<void> loadIslandBase(SkyItem baseItem) async {
    if (_islandWorld.baseComp != null) return;
    try {
      final flamePath = baseItem.assetPath.replaceFirst('assets/', '');
      final baseSprite = await loadSprite(flamePath);
      final ratio = baseSprite.srcSize.x / baseSprite.srcSize.y;
      
      final targetHeight = size.y * 0.85;
      final targetWidth = targetHeight * ratio;
      final targetSize = Vector2(targetWidth, targetHeight);
      
      final baseComp = SpriteComponent(
        sprite: baseSprite,
        size: targetSize,
        anchor: Anchor.center,
        position: Vector2(_islandWorld.size.x / 2, _islandWorld.size.y / 2),
      );
      
      _islandWorld.baseComp = baseComp;
      _islandWorld.groundLayer.add(baseComp);
    } catch (e) {
      debugPrint('SkyHaven: loadIslandBase error: $e');
    }
  }

  void setNightMode(bool night) {
    _nightMode = night;
    // Notify placed objects if needed...
    // The PlacedObjectComponent checks nightMode on its own if it had a reference. 
    // We could iterate children, but for now we set a flag.
  }
}

// ─────────────────────────────────────────────
// CloudComponent — ambient drifting cloud
// ─────────────────────────────────────────────
class CloudComponent extends PositionComponent with HasGameReference<SkyHavenGame> {
  final String assetPath;
  final double startX;
  final double startY;
  final double driftSpeed;
  final double displayScale;
  final double screenWidth;

  CloudComponent({
    required this.assetPath,
    required this.startX,
    required this.startY,
    required this.driftSpeed,
    required this.displayScale,
    required this.screenWidth,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(startX, startY);
    // Background clouds behind island
    priority = DepthManager.layerBackgroundClouds;
    
    try {
      final sprite = await game.loadSprite(assetPath);
      final w = screenWidth * displayScale;
      final ratio = sprite.srcSize.y / sprite.srcSize.x;
      final sc = SpriteComponent(
        sprite: sprite,
        size: Vector2(w, w * ratio),
        anchor: Anchor.center,
      );
      sc.opacity = 0.7;
      add(sc);
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += driftSpeed * dt;
    if (position.x > screenWidth + 200) position.x = -200;
  }
}

// ─────────────────────────────────────────────
// AmbientParticle — floating petals/leaves
// ─────────────────────────────────────────────
class AmbientParticle extends PositionComponent with HasGameReference<SkyHavenGame> {
  double startX;
  double startY;
  final double screenWidth;
  final double screenHeight;
  double _t = 0;
  final double _speed;
  final double _drift;
  final math.Random _rng = math.Random();

  AmbientParticle({
    required this.startX,
    required this.startY,
    required this.screenWidth,
    required this.screenHeight,
  })  : _speed = 15 + math.Random().nextDouble() * 20,
        _drift = math.Random().nextDouble() * 2 - 1,
        super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(startX, startY);
    priority = DepthManager.layerForegroundClouds; // Render over island
    
    final paths = [
      'island/floating_petals.png',
      'island/floating_leaves.png',
      'island/magic_dust.png',
    ];
    try {
      final sprite = await game.loadSprite(paths[_rng.nextInt(paths.length)]);
      final w = 24.0 + _rng.nextDouble() * 20;
      final ratio = sprite.srcSize.y / sprite.srcSize.x;
      final sc = SpriteComponent(
        sprite: sprite,
        size: Vector2(w, w * ratio),
        anchor: Anchor.center,
      );
      sc.opacity = 0.4 + _rng.nextDouble() * 0.4;
      add(sc);
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    position.y -= _speed * dt;
    position.x += math.sin(_t * 0.8) * _drift;
    angle += dt * 0.5;
    if (position.y < -40) {
      position.y = screenHeight + 20;
      position.x = 40 + _rng.nextDouble() * (screenWidth - 80);
    }
  }
}
