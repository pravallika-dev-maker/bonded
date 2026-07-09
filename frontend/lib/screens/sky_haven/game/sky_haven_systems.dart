import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../models/sky_haven_models.dart';

// ─────────────────────────────────────────────
// DepthManager
// ─────────────────────────────────────────────
class DepthManager {
  static const int layerBackgroundClouds = 0;
  static const int layerIslandBase = 10;
  static const int layerGround = 20; // For flat decals like rocks/paths
  static const int layerObjects = 50; // Dynamic Y-Sorted layer for all placed items
  static const int layerParticles = 100;
  static const int layerForegroundClouds = 110;
  static const int layerDragPreview = 1000;

  static int getLayerForItem(SkyItem item) {
    if (item.category == SkyItemCategory.islandBase) return layerIslandBase;
    return layerObjects; // Everything else goes to the dynamic Y-Sorted layer
  }
}

// ─────────────────────────────────────────────
// AssetScaler
// ─────────────────────────────────────────────
class AssetScaler {
  static double getScaleForCategory(SkyItem item) {
    final n = item.name.toLowerCase();
    
    if (n.contains('tree')) return 0.6;
    if (n.contains('bush') || n.contains('shrub')) return 0.5;
    if (n.contains('flower') || n.contains('rose') || n.contains('lavendar') || n.contains('lilly') || n.contains('blossom')) return 0.35;
    if (n.contains('lantern') || n.contains('lamp') || n.contains('fireflies')) return 0.4;
    if (n.contains('bench') || n.contains('table') || n.contains('hammock') || n.contains('swing') || n.contains('arch')) return 0.5;
    if (n.contains('reading corner')) return 0.6;
    if (n.contains('tea table')) return 0.5;
    if (item.category == SkyItemCategory.living) return 0.35;
    if (item.category == SkyItemCategory.water || n.contains('pond') || n.contains('waterfall')) return 0.6;
    if (item.category == SkyItemCategory.islandBase) return 1.0;

    return item.baseScale * 1.5; // Fallback scaled down less globally
  }
}

// ─────────────────────────────────────────────
// AssetPlacementRules & Grid
// ─────────────────────────────────────────────
class IslandGrid {
  static const int columns = 20;
  static const int rows = 20;

  static Vector2 snapToGrid(Vector2 localPos, Vector2 islandSize) {
    final cellW = islandSize.x / columns;
    final cellH = islandSize.y / rows;
    
    // Calculate nearest cell center
    final col = (localPos.x / cellW).floor();
    final row = (localPos.y / cellH).floor();
    
    return Vector2((col + 0.5) * cellW, (row + 0.5) * cellH);
  }

  static bool isOccupied(PlacedItem newItem, Offset normalizedPos, List<PlacedItem> existingItems) {
    // Use the actual placed scale to determine the collision radius dynamically
    final newRadius = newItem.scale * newItem.item.baseScale * 0.3; // Multiplier adjusted for sensible bounds

    for (final item in existingItems) {
      if (item.instanceId == newItem.instanceId) continue;
      
      final existingRadius = item.scale * item.item.baseScale * 0.3;
      final minDistSq = math.pow(newRadius + existingRadius, 2);

      final dx = item.normalizedPosition.dx - normalizedPos.dx;
      final dy = item.normalizedPosition.dy - normalizedPos.dy;
      
      // We scale dy by 1.5 because isometric perspective makes Y distances appear shorter
      if ((dx * dx + (dy * 1.5) * (dy * 1.5)) < minDistSq) { 
        return true;
      }
    }
    return false;
  }
}

class AssetPlacementRules {
  /// Evaluates if the normalized coordinate (0.0 to 1.0) on the island is valid for placement.
  static bool isValidPlacement(PlacedItem item, Offset normalizedPos, List<PlacedItem> existingItems) {
    // 1. Check bounds (ellipse)
    final dx = normalizedPos.dx - 0.5;
    final dy = normalizedPos.dy - 0.5;
    final distSq = (dx * dx) / (0.45 * 0.45) + (dy * dy) / (0.3 * 0.3);

    if (distSq > 1.0) return false;

    // 2. Check occupancy
    if (IslandGrid.isOccupied(item, normalizedPos, existingItems)) {
      return false;
    }

    return true;
  }
}

// ─────────────────────────────────────────────
// WorldAnimationManager
// ─────────────────────────────────────────────
class WorldAnimationManager {
  static double getFloatingOffset(double time, {double speed = 0.4, double height = 6.0}) {
    return math.sin(time * speed) * height;
  }

  static double getSwayAngle(double time, int seedId, {double speed = 1.2, double amount = 0.025}) {
    return math.sin(time * speed + seedId * 0.1) * amount;
  }
  
  static double getPulseOpacity(double time, {double speed = 2.0, double base = 0.7, double range = 0.3}) {
    final pulse = (math.sin(time * speed) + 1) / 2;
    return base + (range * pulse);
  }
}

// ─────────────────────────────────────────────
// PlacementManager
// ─────────────────────────────────────────────
class PlacementManager {
  PlacedItem? previewItem;
  Vector2? previewPosition; // Not snapped
  Vector2? snappedPosition;
  bool isDragging = false;
  bool isValid = true;
  
  void beginDrag(PlacedItem item) {
    previewItem = item;
    isDragging = true;
    
    // Auto-calculate strict layering and scaling for the new item.
    item.scale = AssetScaler.getScaleForCategory(item.item);
    item.layer = DepthManager.getLayerForItem(item.item);
  }

  void updateDrag(Vector2 newLocalPos, Vector2 islandSize, List<PlacedItem> existingItems) {
    previewPosition = newLocalPos;
    final newPosition = newLocalPos; // Free placement, no snapping to grid!
    
    // Always recalculate if we moved to a new position
    if (snappedPosition == null || snappedPosition!.x != newPosition.x || snappedPosition!.y != newPosition.y) {
      snappedPosition = newPosition;
      recalculateValidity(islandSize, existingItems);
    }
  }

  void recalculateValidity(Vector2 islandSize, List<PlacedItem> existingItems) {
    if (previewItem == null || snappedPosition == null) return;
    
    final nx = snappedPosition!.x / islandSize.x;
    final ny = snappedPosition!.y / islandSize.y;
    isValid = AssetPlacementRules.isValidPlacement(
      previewItem!, 
      Offset(nx, ny), 
      existingItems,
    );
  }

  PlacedItem? finalizeDrag(Vector2 islandSize, List<PlacedItem> existingItems) {
    if (!isDragging || previewItem == null || snappedPosition == null) return null;
    if (!isValid) return null; // Reject completely if invalid
    
    final finalItem = previewItem!;
    
    // Normalize position relative to island size (use snapped!)
    final nx = snappedPosition!.x / islandSize.x;
    final ny = snappedPosition!.y / islandSize.y;
    finalItem.normalizedPosition = Offset(nx, ny);
    
    finalItem.isAnimating = true;
    
    isDragging = false;
    previewItem = null;
    previewPosition = null;
    snappedPosition = null;
    
    return finalItem;
  }
  
  void cancelDrag() {
    isDragging = false;
    previewItem = null;
    previewPosition = null;
    snappedPosition = null;
  }
}
