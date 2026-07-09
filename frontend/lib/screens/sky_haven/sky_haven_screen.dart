import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'controllers/island_state.dart';
import 'game/sky_haven_game.dart';
import 'models/sky_haven_models.dart';
import 'widgets/sky_haven_asset_browser.dart';
import 'widgets/sky_haven_island_selector.dart';
import 'widgets/sky_haven_ui.dart';
import 'widgets/edit_toolbar_widget.dart';

// ─────────────────────────────────────────────
// SkyHavenScreen — top-level Flutter screen
// ─────────────────────────────────────────────
class SkyHavenScreen extends StatefulWidget {
  final String userName;
  final String partnerName;

  const SkyHavenScreen({
    super.key,
    this.userName = 'You',
    this.partnerName = 'Partner',
  });

  @override
  State<SkyHavenScreen> createState() => _SkyHavenScreenState();
}

class _SkyHavenScreenState extends State<SkyHavenScreen>
    with TickerProviderStateMixin {
  late IslandState _islandState;
  late SkyHavenGame _game;

  // State for drag & drop
  SkyItem? _pendingPlacement;
  PlacedItem? _placementItem;
  final GlobalKey _islandKey = GlobalKey();
  Rect? _islandRect;
  Offset _dragPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _islandState = IslandState()
      ..myName = widget.userName
      ..partnerName = widget.partnerName;

    _initGame();

    _islandState.addListener(_onStateChanged);
  }

  void _initGame() {
    _game = SkyHavenGame(
      onTapEmptyIsland: () {
        if (_islandState.selectedItem != null) {
          _islandState.selectItem(null);
        }
      },
      onItemTapped: (item) {
        if (_pendingPlacement == null) {
          _islandState.selectItem(item);
        }
      },
      onMultipleItemsTapped: (items) {
        if (_pendingPlacement == null) {
          _showSelectionPopup(items);
        }
      },
    );
  }

  void _showSelectionPopup(List<PlacedItem> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Object', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return ListTile(
                      leading: SizedBox(
                        width: 40, height: 40,
                        child: Image.asset(item.item.assetPath, fit: BoxFit.contain),
                      ),
                      title: Text(item.item.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Layer: ${item.zOffset >= 0 ? '+' : ''}${item.zOffset ~/ 1000}', style: const TextStyle(color: Colors.white54)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _islandState.selectItem(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _islandState.removeListener(_onStateChanged);
    _islandState.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      _game.setSelectedItem(_islandState.selectedItem?.instanceId);
      
      // Load initial state if not yet loaded
      if (!_game.itemsLoaded && _islandState.placedItems.isNotEmpty) {
        // Find the island base
        final baseItem = _islandState.placedItems.firstWhere(
          (item) => item.item.category == SkyItemCategory.islandBase,
          orElse: () => _islandState.placedItems.first,
        );
        if (baseItem.item.category == SkyItemCategory.islandBase) {
          _game.loadIslandBase(baseItem.item);
        }
        _game.loadInitialItems(_islandState.placedItems);
      }
      
      setState(() {});
    }
  }

  // ── Measure island rect for drop zone
  void _measureIslandRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _islandKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      final pos = box.localToGlobal(Offset.zero);
      setState(() => _islandRect = pos & box.size);
    });
  }

  void _openIslandSelector() {
    setState(() => _pendingPlacement = null); // safety
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => SkyHavenIslandSelector(
        onSelected: (item) {
          Navigator.of(context).pop();
          _startAwakening(item);
        },
      ),
    );
  }

  void _startAwakening(SkyItem item) {
    _islandState.placeIslandBase(item);
    _game.playIslandAwakeningCinematic(item, () {
      if (mounted) {
        _islandState.finishAwakening();
      }
    });
  }

  void _openAssetBrowser() {
    SkyHavenAssetBrowser.show(
      context,
      state: _islandState,
      onItemSelected: (item) {
        if (item.category == SkyItemCategory.islandBase) return; // safety
        _measureIslandRect();
        // Initialize drag in Flame
        final placed = PlacedItem(
          instanceId: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
          item: item,
          normalizedPosition: const Offset(0.5, 0.5),
          isNew: false,
          isAnimating: true,
        );

        setState(() {
          _pendingPlacement = item;
          _placementItem = placed;
          // default center screen
          final size = MediaQuery.of(context).size;
          _dragPosition = Offset(size.width / 2, size.height / 2);
        });

        _game.beginItemDrag(placed);
        _game.updateItemDrag(Vector2(_dragPosition.dx, _dragPosition.dy));
      },
    );
  }

  // Old Flutter onScale methods removed because Flame handles them natively now

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isNight = _islandState.isNightMode;
    final hasBase = _islandState.hasIslandBase;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Sky background
            SkyBackground(isNight: isNight),

            // ── 2. Glow ring below island
            if (hasBase) IslandGlowRing(isNight: isNight),

            // ── 3. Flame game
            GameWidget<SkyHavenGame>(
              game: _game,
              backgroundBuilder: (_) => const SizedBox.shrink(),
            ),

            // ── 3.5. Ambient Lighting Overlay
            if (hasBase)
              IgnorePointer(
                child: Container(
                  color: isNight 
                      ? const Color(0x33000044) // Deep blue tint at night
                      : const Color(0x15FFB347), // Warm golden sun during the day
                ),
              ),

            // ── 4. Invisible island rect detector
            if (hasBase)
              Positioned(
                left: size.width * 0.04,
                top: size.height * 0.25,
                right: size.width * 0.04,
                height: size.height * 0.55,
                child: GestureDetector(
                  key: _islandKey,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),

            // ── 5. Top Navigation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const SkyHavenTopNav().animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
            ),

            // ── 6. Main UI / Onboarding
            if (!hasBase)
              Positioned.fill(
                child: SkyHavenOnboardingCard(
                  onChooseIsland: _openIslandSelector,
                ).animate().fadeIn(duration: 1000.ms, curve: Curves.easeOutCubic),
              )
            else if (_islandState.isAwakening)
              Positioned(
                top: size.height * 0.2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✨ Your Sky Haven has awakened.',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ).animate(delay: 2000.ms).fadeIn(duration: 800.ms).slideY(begin: -0.2).then(delay: 2000.ms).fadeOut()
            else if (_pendingPlacement == null && _islandState.selectedItem == null)
              Positioned(
                bottom: padding.bottom + 32,
                left: 0,
                right: 0,
                child: Center(
                  child: SkyHavenFloatingButton(
                    onTap: _openAssetBrowser,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5),
              ),

            // ── 7. Drag & Drop placement overlay
            if (_pendingPlacement != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Instructions
                      Positioned(
                        top: size.height * 0.15,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Drag to place',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: -0.2),

                      // Flame handles the drag preview rendering now, no Image.asset here!
                    ],
                  ),
                ),
              ),

            // ── 8. Edit & Placement Toolbar
            if (_placementItem != null)
              Positioned(
                bottom: padding.bottom + 120,
                left: 0,
                right: 0,
                child: Center(
                  child: EditToolbarWidget(
                    item: _placementItem!,
                    isPlacementMode: true,
                    onScaleUp: () {
                      _placementItem!.scale = (_placementItem!.scale + 0.05).clamp(0.1, 3.0);
                      _game.updateDragPreviewVisuals();
                      setState(() {});
                    },
                    onScaleDown: () {
                      _placementItem!.scale = (_placementItem!.scale - 0.05).clamp(0.1, 3.0);
                      _game.updateDragPreviewVisuals();
                      setState(() {});
                    },
                    onRotateLeft: () {
                      _placementItem!.rotation -= 0.2;
                      _game.updateDragPreviewVisuals();
                      setState(() {});
                    },
                    onRotateRight: () {
                      _placementItem!.rotation += 0.2;
                      _game.updateDragPreviewVisuals();
                      setState(() {});
                    },
                    onRotationChanged: (val) {
                      _placementItem!.rotation = val;
                      _game.updateDragPreviewVisuals();
                      setState(() {});
                    },
                    onConfirm: () {
                      if (_game.placementManager.isValid) {
                        final placed = _game.finalizeItemDrag();
                        if (placed != null) {
                          _islandState.placeItem(placed.item, placed.normalizedPosition);
                          _game.resetCamera();
                          setState(() {
                             _pendingPlacement = null;
                             _placementItem = null;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid placement area (red).')));
                      }
                    },
                    onCancel: () {
                      _game.cancelItemDrag();
                      _game.resetCamera();
                      setState(() {
                         _pendingPlacement = null;
                         _placementItem = null;
                      });
                    }
                  ).animate().fadeIn().slideY(begin: 0.5),
                ),
              )
            else if (_islandState.selectedItem != null)
              Positioned(
                bottom: padding.bottom + 120,
                left: 0,
                right: 0,
                child: Center(
                  child: EditToolbarWidget(
                    item: _islandState.selectedItem!,
                    onMove: () {
                      _measureIslandRect();
                      final itemToMove = _islandState.selectedItem!;
                      
                      // Enter placement mode for this item
                      setState(() {
                        _pendingPlacement = itemToMove.item;
                        _placementItem = itemToMove;
                        final size = MediaQuery.of(context).size;
                        _dragPosition = Offset(size.width / 2, size.height / 2);
                      });
                      
                      _game.beginItemDrag(itemToMove);
                      _islandState.selectItem(null); 
                      _game.removeItem(itemToMove.instanceId);
                      _game.updateItemDrag(Vector2(_dragPosition.dx, _dragPosition.dy));
                    },
                    onRemove: () {
                      final item = _islandState.selectedItem!;
                      _game.removeItem(item.instanceId);
                      _islandState.removeItem(item);
                    },
                    onWhisper: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Whisper feature coming soon!')));
                    },
                    onScaleUp: () {
                      final item = _islandState.selectedItem!;
                      item.scale = (item.scale + 0.05).clamp(0.1, 3.0);
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onScaleDown: () {
                      final item = _islandState.selectedItem!;
                      item.scale = (item.scale - 0.05).clamp(0.1, 3.0);
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onRotateLeft: () {
                      final item = _islandState.selectedItem!;
                      item.rotation -= 0.2;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onRotateRight: () {
                      final item = _islandState.selectedItem!;
                      item.rotation += 0.2;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onRotationChanged: (val) {
                      final item = _islandState.selectedItem!;
                      item.rotation = val;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onBringForward: () {
                      final item = _islandState.selectedItem!;
                      item.zOffset += 1000;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onSendBackward: () {
                      final item = _islandState.selectedItem!;
                      item.zOffset -= 1000;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onReset: () {
                      final item = _islandState.selectedItem!;
                      item.scale = 1.0;
                      item.rotation = 0.0;
                      _islandState.placeItem(item.item, item.normalizedPosition);
                    },
                    onDuplicate: () {
                      final item = _islandState.selectedItem!;
                      _islandState.selectItem(null);
                      
                      _measureIslandRect();
                      final placed = PlacedItem(
                        instanceId: '${item.item.id}_${DateTime.now().millisecondsSinceEpoch}',
                        item: item.item,
                        normalizedPosition: const Offset(0.5, 0.5),
                        isNew: false,
                        isAnimating: true,
                        scale: item.scale,
                        rotation: item.rotation,
                        zOffset: item.zOffset,
                      );
                      setState(() {
                        _pendingPlacement = item.item;
                        _placementItem = placed;
                        final size = MediaQuery.of(context).size;
                        _dragPosition = Offset(size.width / 2, size.height / 2);
                      });
                      _game.beginItemDrag(placed);
                      _game.updateItemDrag(Vector2(_dragPosition.dx, _dragPosition.dy));
                    },
                    onDone: () {
                      _islandState.selectItem(null);
                    },
                  ).animate().fadeIn().slideY(begin: 0.5),
                ),
              ),
          ],
        ),
      );
  }
}
