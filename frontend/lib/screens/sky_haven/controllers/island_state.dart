import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sky_haven_models.dart';

// ─────────────────────────────────────────────
// Island State — single source of truth for V1
// ─────────────────────────────────────────────
class IslandState extends ChangeNotifier {
  // ── User Information
  String myName = 'You';
  String partnerName = 'Partner';

  IslandState() {
    _loadState();
  }

  // Placed items
  final List<PlacedItem> placedItems = [];

  // Island state
  SkyItem? islandBaseItem;
  bool isAwakening = false;
  bool get hasIslandBase => islandBaseItem != null;
  int landChunks = 0; // 0 = base only, increments on expand

  // Night mode (unlocked after first lantern)
  bool nightModeUnlocked = false;
  bool isNightMode = false;

  // Active milestones triggered
  final Set<SkyMilestone> triggeredMilestones = {};

  // Selected item for edit mode
  PlacedItem? selectedItem;
  
  // Selected item during drag
  SkyItem? draggingItem;
  Offset? draggingPosition; // global screen position

  // Camera
  double cameraZoom = 1.0;
  Offset cameraPan = Offset.zero;

  // ── Place Island Base (Cinematic Start)
  void placeIslandBase(SkyItem baseItem) {
    islandBaseItem = baseItem;
    isAwakening = true;
    notifyListeners();
  }

  // ── Finish Awakening Cinematic
  void finishAwakening() {
    isAwakening = false;
    notifyListeners();
  }
  
  void selectItem(PlacedItem? item) {
    selectedItem = item;
    notifyListeners();
  }

  void removeItem(PlacedItem item) {
    placedItems.removeWhere((i) => i.instanceId == item.instanceId);
    if (selectedItem?.instanceId == item.instanceId) selectedItem = null;
    _saveState();
    notifyListeners();
  }

  // ── Place an item on the island
  void placeItem(SkyItem item, Offset normalizedPos, {String? whisper}) {
    final placed = PlacedItem(
      instanceId: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      item: item,
      normalizedPosition: normalizedPos,
      whisper: whisper,
      isNew: false,
      isAnimating: true,
    );
    // If item already exists (repositioned), just update it
    final existingIdx = placedItems.indexWhere((i) => i.instanceId == placed.instanceId);
    if (existingIdx != -1) {
      placedItems[existingIdx] = placed;
    } else {
      placedItems.add(placed);
      // check milestones only on new
      _checkMilestones(placed);
    }

    _saveState();
    notifyListeners();
  }

  void _checkMilestones(PlacedItem placed) {
    final cat = placed.item.category;

    if (cat == SkyItemCategory.nature &&
        !triggeredMilestones.contains(SkyMilestone.firstBloom)) {
      triggeredMilestones.add(SkyMilestone.firstBloom);
    }
    if (cat == SkyItemCategory.lights &&
        !triggeredMilestones.contains(SkyMilestone.firstLight)) {
      triggeredMilestones.add(SkyMilestone.firstLight);
      nightModeUnlocked = true;
    }
    if (cat == SkyItemCategory.living &&
        !triggeredMilestones.contains(SkyMilestone.firstVisitor)) {
      triggeredMilestones.add(SkyMilestone.firstVisitor);
    }
    if (placedItems.length >= 10 &&
        !triggeredMilestones.contains(SkyMilestone.islandAwakens)) {
      triggeredMilestones.add(SkyMilestone.islandAwakens);
    }
  }

  // ── Island expansion
  void expandIsland() {
    landChunks++;
    notifyListeners();
  }

  // ── Camera
  void updateZoom(double delta) {
    cameraZoom = (cameraZoom + delta).clamp(0.5, 3.0);
    notifyListeners();
  }

  void updatePan(Offset delta) {
    cameraPan += delta;
    notifyListeners();
  }

  void resetCamera() {
    cameraZoom = 1.0;
    cameraPan = Offset.zero;
    notifyListeners();
  }

  // ── Night mode toggle
  void toggleNight() {
    if (!nightModeUnlocked) return;
    isNightMode = !isNightMode;
    notifyListeners();
  }

  // ── Clear for testing
  void clearAll() {
    islandBaseItem = null;
    isAwakening = false;
    placedItems.clear();
    triggeredMilestones.clear();
    nightModeUnlocked = false;
    isNightMode = false;
    _saveState();
    notifyListeners();
  }

  // ── Persistence ──
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final baseId = prefs.getString('skyhaven_island_base');
      if (baseId != null) {
        islandBaseItem = SkyHavenCatalog.all.firstWhere(
          (i) => i.id == baseId,
          orElse: () => SkyHavenCatalog.all.first,
        );
      }
      
      final itemsJson = prefs.getStringList('skyhaven_items');
      if (itemsJson != null) {
        placedItems.clear();
        for (final jsonStr in itemsJson) {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          placedItems.add(PlacedItem.fromJson(map));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading island state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (islandBaseItem != null) {
        await prefs.setString('skyhaven_island_base', islandBaseItem!.id);
      } else {
        await prefs.remove('skyhaven_island_base');
      }
      
      final itemsJson = placedItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('skyhaven_items', itemsJson);
    } catch (e) {
      debugPrint('Error saving island state: $e');
    }
  }
}
