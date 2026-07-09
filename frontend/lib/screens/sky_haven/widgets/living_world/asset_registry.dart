import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PlacementZone { generic }
enum RenderLayer { background, island, nature, decor }

abstract class SpriteAnimation {
  Offset getTranslation(double time, int seed);
  double getRotation(double time, int seed);
  double getScale(double time, int seed);
  double getOpacity(double time, int seed);
}

class IdleBreathingAnimation extends SpriteAnimation {
  @override
  Offset getTranslation(double time, int seed) => Offset(0, math.sin(time * 0.5 + seed) * 3);
  @override
  double getRotation(double time, int seed) => 0;
  @override
  double getScale(double time, int seed) => 1.0;
  @override
  double getOpacity(double time, int seed) => 1.0;
}

class TreeSwayAnimation extends SpriteAnimation {
  @override
  Offset getTranslation(double time, int seed) => Offset.zero;
  @override
  double getRotation(double time, int seed) => math.sin(time * 0.8 + seed) * 0.026;
  @override
  double getScale(double time, int seed) => 1.0;
  @override
  double getOpacity(double time, int seed) => 1.0;
}

class LanternGlowAnimation extends SpriteAnimation {
  @override
  Offset getTranslation(double time, int seed) => Offset.zero;
  @override
  double getRotation(double time, int seed) => 0;
  @override
  double getScale(double time, int seed) => 1.0;
  @override
  double getOpacity(double time, int seed) => 0.7 + (math.sin(time * 1.5 + seed) + 1) * 0.15;
}

class SkyObjectDefinition {
  final String assetName;
  final RenderLayer layer;
  final SpriteAnimation? animation;
  final int previewPriority;

  const SkyObjectDefinition({
    required this.assetName,
    this.layer = RenderLayer.nature,
    this.animation,
    this.previewPriority = 0,
  });
}

class AssetRegistry {
  static final Map<String, SkyObjectDefinition> registry = {
    'island_base': SkyObjectDefinition(
      assetName: 'island_base.png',
      layer: RenderLayer.island,
      animation: IdleBreathingAnimation(),
    ),
    'cherry_tree': SkyObjectDefinition(
      assetName: 'cherry_tree.png',
      layer: RenderLayer.nature,
      animation: TreeSwayAnimation(),
      previewPriority: 10,
    ),
    'lantern': SkyObjectDefinition(
      assetName: 'lantern.png',
      layer: RenderLayer.decor,
      animation: LanternGlowAnimation(),
      previewPriority: 9,
    ),
  };

  static SkyObjectDefinition get(String id) {
    return registry[id] ?? SkyObjectDefinition(
      assetName: 'island_base.png', // Fallback to island base for safety
    );
  }
}
