import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Item Category
// ─────────────────────────────────────────────
enum SkyItemCategory {
  islandBase,
  nature,
  water,
  cozy,
  lights,
  living,
  wonder,
}

extension SkyItemCategoryExt on SkyItemCategory {
  String get label {
    switch (this) {
      case SkyItemCategory.islandBase: return 'Island Base';
      case SkyItemCategory.nature: return 'Nature';
      case SkyItemCategory.water:  return 'Water';
      case SkyItemCategory.cozy:   return 'Cozy';
      case SkyItemCategory.lights: return 'Lights';
      case SkyItemCategory.living: return 'Living';
      case SkyItemCategory.wonder: return 'Wonder';
    }
  }

  String get emoji {
    switch (this) {
      case SkyItemCategory.islandBase: return '☁️';
      case SkyItemCategory.nature: return '🌿';
      case SkyItemCategory.water:  return '💧';
      case SkyItemCategory.cozy:   return '🏡';
      case SkyItemCategory.lights: return '🏮';
      case SkyItemCategory.living: return '🦋';
      case SkyItemCategory.wonder: return '✨';
    }
  }

  Color get color {
    switch (this) {
      case SkyItemCategory.islandBase: return const Color(0xFFB0BEC5);
      case SkyItemCategory.nature: return const Color(0xFF4CAF50);
      case SkyItemCategory.water:  return const Color(0xFF29B6F6);
      case SkyItemCategory.cozy:   return const Color(0xFFFF8A65);
      case SkyItemCategory.lights: return const Color(0xFFFFD54F);
      case SkyItemCategory.living: return const Color(0xFFCE93D8);
      case SkyItemCategory.wonder: return const Color(0xFFF06292);
    }
  }
}

// ─────────────────────────────────────────────
// SkyItem — Catalog entry
// ─────────────────────────────────────────────
class SkyItem {
  final String id;
  final String name;
  final String assetPath;
  final SkyItemCategory category;
  final double baseScale;
  final int zLayer; // render order

  const SkyItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.category,
    this.baseScale = 0.18,
    this.zLayer = 5,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
  };

  factory SkyItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return SkyHavenCatalog.all.firstWhere((item) => item.id == id, orElse: () => SkyHavenCatalog.all.first);
  }
}

// ─────────────────────────────────────────────
// PlacedItem — An item placed on the island
// ─────────────────────────────────────────────
class PlacedItem {
  final String instanceId;
  final SkyItem item;
  Offset normalizedPosition; // 0.0–1.0 relative to island canvas
  double scale;
  double rotation;
  int layer;
  int timestamp;
  int zOffset;
  String? whisper;
  String? reaction;
  bool isNew;       // glows until tapped
  bool isAnimating; // placement bounce

  PlacedItem({
    required this.instanceId,
    required this.item,
    required this.normalizedPosition,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.layer = 5,
    int? timestamp,
    this.zOffset = 0,
    this.whisper,
    this.reaction,
    this.isNew = true,
    this.isAnimating = false,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'item': item.toJson(),
    'normalizedPosition': {'dx': normalizedPosition.dx, 'dy': normalizedPosition.dy},
    'scale': scale,
    'rotation': rotation,
    'layer': layer,
    'timestamp': timestamp,
    'zOffset': zOffset,
    'whisper': whisper,
    'reaction': reaction,
  };

  factory PlacedItem.fromJson(Map<String, dynamic> json) {
    return PlacedItem(
      instanceId: json['instanceId'] as String,
      item: SkyItem.fromJson(json['item'] as Map<String, dynamic>),
      normalizedPosition: Offset(
        (json['normalizedPosition']['dx'] as num).toDouble(),
        (json['normalizedPosition']['dy'] as num).toDouble(),
      ),
      scale: (json['scale'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      layer: json['layer'] as int,
      timestamp: json['timestamp'] as int?,
      zOffset: (json['zOffset'] as int?) ?? 0,
      whisper: json['whisper'] as String?,
      reaction: json['reaction'] as String?,
      isNew: false,
      isAnimating: false,
    );
  }
}

// ─────────────────────────────────────────────
// Island Expansion
// ─────────────────────────────────────────────
class LandChunk {
  final Offset offset;   // pixel offset from island centre
  final double opacity;
  final bool revealed;

  const LandChunk({
    required this.offset,
    this.opacity = 0.0,
    this.revealed = false,
  });
}

// ─────────────────────────────────────────────
// Milestone definitions
// ─────────────────────────────────────────────
enum SkyMilestone {
  firstBloom,
  firstLight,
  firstVisitor,
  islandAwakens,
}

extension SkyMilestoneExt on SkyMilestone {
  String get title {
    switch (this) {
      case SkyMilestone.firstBloom:    return '🌸 First Bloom';
      case SkyMilestone.firstLight:    return '🏮 First Light';
      case SkyMilestone.firstVisitor:  return '🦌 First Visitor';
      case SkyMilestone.islandAwakens: return '🌍 Island Awakens';
    }
  }

  String get subtitle {
    switch (this) {
      case SkyMilestone.firstBloom:    return "Your island's first flower has opened its petals.";
      case SkyMilestone.firstLight:    return 'A gentle light now guides the night.';
      case SkyMilestone.firstVisitor:  return 'A creature found its way to your world.';
      case SkyMilestone.islandAwakens: return 'The island breathes. It is alive.';
    }
  }

  String get effectAsset {
    switch (this) {
      case SkyMilestone.firstBloom:    return 'assets/island/first_bloom_effect.jpg';
      case SkyMilestone.firstLight:    return 'assets/island/fireflies.png';
      case SkyMilestone.firstVisitor:  return 'assets/island/first_visitor_effect.png';
      case SkyMilestone.islandAwakens: return 'assets/island/island_awakeness_effect.png';
    }
  }
}

// ─────────────────────────────────────────────
// Full item catalog
// ─────────────────────────────────────────────
class SkyHavenCatalog {
  static const List<SkyItem> all = [
    // ── ISLAND BASE ──
    SkyItem(id: 'island_base_small',  name: 'Small Island',    assetPath: 'assets/island/island_base_small.png',   category: SkyItemCategory.islandBase, baseScale: 0.5, zLayer: 0),
    SkyItem(id: 'island_base_med',    name: 'Medium Island',   assetPath: 'assets/island/island_base_medium.png',   category: SkyItemCategory.islandBase, baseScale: 0.7, zLayer: 0),
    SkyItem(id: 'island_base_large',  name: 'Large Island',    assetPath: 'assets/island/island_base_large.png',   category: SkyItemCategory.islandBase, baseScale: 0.9, zLayer: 0),

    // ── NATURE ──
    SkyItem(id: 'blossom_tree',   name: 'Blossom Tree',    assetPath: 'assets/island/blossom_tree.png',   category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'cherry_tree',    name: 'Cherry Tree',     assetPath: 'assets/island/cherry_tree.png',    category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'pink_tree',      name: 'Pink Tree',       assetPath: 'assets/island/pink_tree.png',      category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'pine_tree',      name: 'Pine Tree',       assetPath: 'assets/island/pine_tree.png',      category: SkyItemCategory.nature, baseScale: 0.20, zLayer: 7),
    SkyItem(id: 'willow_tree',    name: 'Willow Tree',     assetPath: 'assets/island/willow tree.png',    category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'crystal_tree',   name: 'Crystal Tree',    assetPath: 'assets/island/crystal_tree.png',   category: SkyItemCategory.nature, baseScale: 0.20, zLayer: 7),
    SkyItem(id: 'starlight_tree', name: 'Starlight Tree',  assetPath: 'assets/island/starlight_tree.png', category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'white_blossom',  name: 'White Blossom',   assetPath: 'assets/island/white_blossom.png',  category: SkyItemCategory.nature, baseScale: 0.18, zLayer: 5),
    SkyItem(id: 'blue_flowers',   name: 'Blue Flowers',    assetPath: 'assets/island/blue_flowers.png',   category: SkyItemCategory.nature, baseScale: 0.14, zLayer: 4),
    SkyItem(id: 'roses',          name: 'Roses',           assetPath: 'assets/island/roses.png',          category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 4),
    SkyItem(id: 'wildflowers',    name: 'Wildflowers',     assetPath: 'assets/island/wildflowers.png',    category: SkyItemCategory.nature, baseScale: 0.16, zLayer: 4),
    SkyItem(id: 'lavendar_patch', name: 'Lavender Patch',  assetPath: 'assets/island/lavendar_patch.png', category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 4),
    SkyItem(id: 'sunflowers',     name: 'Sunflowers',      assetPath: 'assets/island/sunflowers.png',     category: SkyItemCategory.nature, baseScale: 0.18, zLayer: 5),
    SkyItem(id: 'berry_bush',     name: 'Berry Bush',      assetPath: 'assets/island/berry_bush.png',     category: SkyItemCategory.nature, baseScale: 0.14, zLayer: 4),
    SkyItem(id: 'crystal_bush',   name: 'Crystal Bush',    assetPath: 'assets/island/crystal_bush.png',   category: SkyItemCategory.nature, baseScale: 0.14, zLayer: 4),
    SkyItem(id: 'green_bush',     name: 'Green Bush',      assetPath: 'assets/island/green_bush.png',     category: SkyItemCategory.nature, baseScale: 0.13, zLayer: 4),
    SkyItem(id: 'rocks',          name: 'Rocks',           assetPath: 'assets/island/rocks.png',          category: SkyItemCategory.nature, baseScale: 0.12, zLayer: 3),
    SkyItem(id: 'fallen_log',     name: 'Fallen Log',      assetPath: 'assets/island/fallen_log.png',     category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 3),
    SkyItem(id: 'vine_arch',      name: 'Vine Arch',       assetPath: 'assets/island/vine_arch.png',      category: SkyItemCategory.nature, baseScale: 0.20, zLayer: 6),
    SkyItem(id: 'mushroom_cluster',name:'Mushroom Cluster', assetPath: 'assets/island/mushroom_cluster.png',category: SkyItemCategory.nature, baseScale: 0.13, zLayer: 4),
    SkyItem(id: 'grass_patch',    name: 'Grass Patch',     assetPath: 'assets/island/grass_patch1.png',   category: SkyItemCategory.nature, baseScale: 0.16, zLayer: 3),
    SkyItem(id: 'tiny_tree',      name: 'Tiny Tree',       assetPath: 'assets/island/tiny_tree.png',      category: SkyItemCategory.nature, baseScale: 0.16, zLayer: 5),
    SkyItem(id: 'flower_ground',  name: 'Flower Ground',   assetPath: 'assets/island/flower_ground.png',  category: SkyItemCategory.nature, baseScale: 0.16, zLayer: 3),
    SkyItem(id: 'roseplant',      name: 'Rose Plant',      assetPath: 'assets/island/roseplant.png',      category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 4),
    SkyItem(id: 'single_vine',    name: 'Single Vine',     assetPath: 'assets/island/single_vine.png',    category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 5),
    SkyItem(id: 'vines',          name: 'Vines',           assetPath: 'assets/island/vines.png',          category: SkyItemCategory.nature, baseScale: 0.15, zLayer: 5),
    SkyItem(id: 'tree',           name: 'Tree',            assetPath: 'assets/island/tree.png',           category: SkyItemCategory.nature, baseScale: 0.22, zLayer: 7),
    SkyItem(id: 'blueflowers2',   name: 'Blue Flowers 2',  assetPath: 'assets/island/blueflowers.png',    category: SkyItemCategory.nature, baseScale: 0.14, zLayer: 4),

    // ── WATER ──
    SkyItem(id: 'tiny_pond',      name: 'Tiny Pond',       assetPath: 'assets/island/tiny_pond.png',      category: SkyItemCategory.water, baseScale: 0.18, zLayer: 2),
    SkyItem(id: 'lilly_pond',     name: 'Lily Pond',       assetPath: 'assets/island/lilly_pond.png',     category: SkyItemCategory.water, baseScale: 0.20, zLayer: 2),
    SkyItem(id: 'lotus_pond',     name: 'Lotus Pond',      assetPath: 'assets/island/lotus_pond.png',     category: SkyItemCategory.water, baseScale: 0.20, zLayer: 2),
    SkyItem(id: 'waterfall',      name: 'Waterfall',       assetPath: 'assets/island/waterfall.png',      category: SkyItemCategory.water, baseScale: 0.22, zLayer: 6),
    SkyItem(id: 'stream',         name: 'Stream',          assetPath: 'assets/island/stream.png',         category: SkyItemCategory.water, baseScale: 0.22, zLayer: 2),
    SkyItem(id: 'crystal_spring', name: 'Crystal Spring',  assetPath: 'assets/island/crystal_spring.png', category: SkyItemCategory.water, baseScale: 0.18, zLayer: 2),
    SkyItem(id: 'water_lillies',  name: 'Water Lilies',    assetPath: 'assets/island/water_lillies.png',  category: SkyItemCategory.water, baseScale: 0.15, zLayer: 2),
    SkyItem(id: 'stone_circle',   name: 'Stone Circle',    assetPath: 'assets/island/stone_circle.png',   category: SkyItemCategory.water, baseScale: 0.16, zLayer: 2),

    // ── COZY ──
    SkyItem(id: 'wooden_bench',   name: 'Wooden Bench',    assetPath: 'assets/island/wooden_bench.png',   category: SkyItemCategory.cozy, baseScale: 0.16, zLayer: 5),
    SkyItem(id: 'stone_bench',    name: 'Stone Bench',     assetPath: 'assets/island/stone_bench.png',    category: SkyItemCategory.cozy, baseScale: 0.16, zLayer: 5),
    SkyItem(id: 'cozy_bench',     name: 'Cozy Bench',      assetPath: 'assets/island/cozy_bench.png',     category: SkyItemCategory.cozy, baseScale: 0.16, zLayer: 5),
    SkyItem(id: 'swing',          name: 'Swing',           assetPath: 'assets/island/swing.png',          category: SkyItemCategory.cozy, baseScale: 0.18, zLayer: 6),
    SkyItem(id: 'double_swing',   name: 'Double Swing',    assetPath: 'assets/island/double_swing.png',   category: SkyItemCategory.cozy, baseScale: 0.20, zLayer: 6),
    SkyItem(id: 'hammock',        name: 'Hammock',         assetPath: 'assets/island/hammock.png',        category: SkyItemCategory.cozy, baseScale: 0.18, zLayer: 5),
    SkyItem(id: 'campfire',       name: 'Campfire',        assetPath: 'assets/island/campfire.png',       category: SkyItemCategory.cozy, baseScale: 0.15, zLayer: 5),
    SkyItem(id: 'picnic_blanket', name: 'Picnic Blanket',  assetPath: 'assets/island/picnic_blanket.png', category: SkyItemCategory.cozy, baseScale: 0.18, zLayer: 4),
    SkyItem(id: 'reading_corner', name: 'Reading Corner',  assetPath: 'assets/island/reading_corner.png', category: SkyItemCategory.cozy, baseScale: 0.18, zLayer: 5),
    SkyItem(id: 'tea_table',      name: 'Tea Table',       assetPath: 'assets/island/tea_table.png',      category: SkyItemCategory.cozy, baseScale: 0.16, zLayer: 5),
    SkyItem(id: 'fencing',        name: 'Fencing',         assetPath: 'assets/island/fencing.png',        category: SkyItemCategory.cozy, baseScale: 0.15, zLayer: 4),
    SkyItem(id: 'stone_path',     name: 'Stone Path',      assetPath: 'assets/island/stone_path.png',     category: SkyItemCategory.cozy, baseScale: 0.15, zLayer: 3),
    SkyItem(id: 'stonesteps',     name: 'Stone Steps',     assetPath: 'assets/island/stonesteps.png',     category: SkyItemCategory.cozy, baseScale: 0.15, zLayer: 3),

    // ── LIGHTS ──
    SkyItem(id: 'garden_lantern', name: 'Garden Lantern',  assetPath: 'assets/island/garden_lantern.png', category: SkyItemCategory.lights, baseScale: 0.16, zLayer: 6),
    SkyItem(id: 'moon_lantern',   name: 'Moon Lantern',    assetPath: 'assets/island/moon lantern.png',   category: SkyItemCategory.lights, baseScale: 0.18, zLayer: 6),
    SkyItem(id: 'moon_lamp',      name: 'Moon Lamp',       assetPath: 'assets/island/Moon_lamp.png',      category: SkyItemCategory.lights, baseScale: 0.20, zLayer: 6),
    SkyItem(id: 'star_lamp',      name: 'Star Lamp',       assetPath: 'assets/island/star_lamp.png',      category: SkyItemCategory.lights, baseScale: 0.18, zLayer: 6),
    SkyItem(id: 'hanging_light',  name: 'Hanging Lights',  assetPath: 'assets/island/hanging light.png',  category: SkyItemCategory.lights, baseScale: 0.20, zLayer: 6),
    SkyItem(id: 'firefly_jar',    name: 'Firefly Jar',     assetPath: 'assets/island/firefly_jar.png',    category: SkyItemCategory.lights, baseScale: 0.14, zLayer: 6),
    SkyItem(id: 'moon_gate',      name: 'Moon Gate',       assetPath: 'assets/island/moon_gate.png',      category: SkyItemCategory.lights, baseScale: 0.22, zLayer: 7),

    // ── LIVING ──
    SkyItem(id: 'butterflies',    name: 'Butterflies',     assetPath: 'assets/island/butterflies.png',    category: SkyItemCategory.living, baseScale: 0.16, zLayer: 8),
    SkyItem(id: 'birds',          name: 'Birds',           assetPath: 'assets/island/Birds.png',          category: SkyItemCategory.living, baseScale: 0.14, zLayer: 9),
    SkyItem(id: 'swans',          name: 'Swans',           assetPath: 'assets/island/Swans.png',          category: SkyItemCategory.living, baseScale: 0.18, zLayer: 8),
    SkyItem(id: 'deer',           name: 'Deer',            assetPath: 'assets/island/Deer.png',           category: SkyItemCategory.living, baseScale: 0.18, zLayer: 8),
    SkyItem(id: 'fox',            name: 'Fox',             assetPath: 'assets/island/fox.png',            category: SkyItemCategory.living, baseScale: 0.15, zLayer: 8),
    SkyItem(id: 'floating_dolphin',name:'Dolphin',         assetPath: 'assets/island/floating_dolphin.png',category:SkyItemCategory.living, baseScale: 0.20, zLayer: 9),

    // ── WONDER ──
    SkyItem(id: 'rainbow_arch',   name: 'Rainbow Arch',    assetPath: 'assets/island/rainbow_arch.png',       category: SkyItemCategory.wonder, baseScale: 0.28, zLayer: 10),
    SkyItem(id: 'clouds_fountain',name: 'Cloud Fountain',  assetPath: 'assets/island/clouds_fountain.png',    category: SkyItemCategory.wonder, baseScale: 0.22, zLayer: 9),
    SkyItem(id: 'giaant_mushroom',name: 'Giant Mushroom',  assetPath: 'assets/island/giaant_mushroom.png',    category: SkyItemCategory.wonder, baseScale: 0.24, zLayer: 8),
    SkyItem(id: 'aurora_portal',  name: 'Aurora Portal',   assetPath: 'assets/island/aurora_portal.png',      category: SkyItemCategory.wonder, baseScale: 0.26, zLayer: 10),
    SkyItem(id: 'magic_dust',     name: 'Magic Dust',      assetPath: 'assets/island/magic_dust.png',         category: SkyItemCategory.wonder, baseScale: 0.20, zLayer: 9),
    SkyItem(id: 'floating_leaves',name: 'Floating Leaves', assetPath: 'assets/island/floating_leaves.png',    category: SkyItemCategory.wonder, baseScale: 0.18, zLayer: 9),
    SkyItem(id: 'floating_petals',name: 'Floating Petals', assetPath: 'assets/island/floating_petals.png',    category: SkyItemCategory.wonder, baseScale: 0.18, zLayer: 9),
    SkyItem(id: 'floating_birds', name: 'Floating Birds',  assetPath: 'assets/island/floating birds.png',     category: SkyItemCategory.wonder, baseScale: 0.22, zLayer: 10),
    SkyItem(id: 'glow_ring',      name: 'Glow Ring',       assetPath: 'assets/island/glow_ring.png',          category: SkyItemCategory.wonder, baseScale: 0.20, zLayer: 9),
    SkyItem(id: 'cloud_cluster',  name: 'Cloud Cluster',   assetPath: 'assets/island/cloud cluster.png',      category: SkyItemCategory.wonder, baseScale: 0.20, zLayer: 8),
    SkyItem(id: 'cloud_swirl',    name: 'Cloud Swirl',     assetPath: 'assets/island/cloud_swirl.png',        category: SkyItemCategory.wonder, baseScale: 0.20, zLayer: 8),
    SkyItem(id: 'large_cloud',    name: 'Large Cloud',     assetPath: 'assets/island/large cloud.png',        category: SkyItemCategory.wonder, baseScale: 0.24, zLayer: 8),
    SkyItem(id: 'medium_cloud',   name: 'Medium Cloud',    assetPath: 'assets/island/medium cloud.png',       category: SkyItemCategory.wonder, baseScale: 0.20, zLayer: 8),
    SkyItem(id: 'moving_cloud',   name: 'Moving Cloud',    assetPath: 'assets/island/moving cloud.png',       category: SkyItemCategory.wonder, baseScale: 0.22, zLayer: 8),
  ];

  static List<SkyItem> byCategory(SkyItemCategory cat) =>
      all.where((e) => e.category == cat).toList();
}
