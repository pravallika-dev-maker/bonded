import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/sky_haven_service.dart';
import 'spark_selection_sheet.dart';
import 'add_whisper_dialog.dart';
import 'item_detail_card.dart';

class SkyHavenScreen extends StatefulWidget {
  const SkyHavenScreen({Key? key}) : super(key: key);

  @override
  State<SkyHavenScreen> createState() => _SkyHavenScreenState();
}

class _SkyHavenScreenState extends State<SkyHavenScreen> {
  Map<String, dynamic>? islandData;
  bool isLoading = true;
  String? errorMessage;
  Timer? _pollingTimer;

  // Placement State
  Map<String, dynamic>? _selectedAsset;
  Offset _placementOffset = const Offset(150, 150); // Default center-ish of the 400x400 island

  @override
  void initState() {
    super.initState();
    _loadIsland();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_selectedAsset != null) return; // Don't interrupt placement
      
      try {
        final status = await SkyHavenService.getStatus();
        final newVersion = status['island_version'];
        final currentVersion = islandData?['island_version'] ?? 0;
        
        if (newVersion > currentVersion) {
          await _loadIsland();
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  Future<void> _loadIsland() async {
    try {
      final data = await SkyHavenService.getIsland();
      setState(() {
        islandData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _startPlacement(Map<String, dynamic> asset) {
    setState(() {
      _selectedAsset = asset;
      _placementOffset = const Offset(150, 150); // Reset to center
    });
  }

  void _confirmPlacement() {
    if (_selectedAsset == null) return;

    showDialog(
      context: context,
      builder: (context) => AddWhisperDialog(
        onSubmit: (whisper) async {
          setState(() { isLoading = true; });
          try {
            await SkyHavenService.placeObject(
              assetId: _selectedAsset!['id'],
              x: _placementOffset.dx,
              y: _placementOffset.dy,
              whisper: whisper,
            );
            // Clear placement state and reload island
            setState(() { _selectedAsset = null; });
            await _loadIsland();
          } catch (e) {
            setState(() { isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error placing object: $e')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Sky Haven", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedAsset != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedAsset = null),
            )
        ],
      ),
      body: Stack(
        children: [
          // The Interactive Canvas
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(1000.0),
            child: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base Island
                    const _PlaceholderIsland(),
                    
                    // Render Placed Objects
                    if (islandData != null && islandData!['objects'] != null)
                      ...((islandData!['objects'] as List).map((obj) {
                        final bool hasWhisper = obj['has_unread_whisper'] == true;
                        return Positioned(
                          left: (obj['position_x'] as num).toDouble(),
                          top: (obj['position_y'] as num).toDouble(),
                          child: GestureDetector(
                            onTap: () async {
                              // If there's an unread whisper, mark it read
                              if (hasWhisper) {
                                try {
                                  await SkyHavenService.readWhisper(obj['id']);
                                  // Update local state so glow disappears immediately
                                  setState(() { obj['has_unread_whisper'] = false; });
                                } catch (e) {
                                  debugPrint("Failed to read whisper: $e");
                                }
                              }
                              
                              // Show Detail Card
                              showDialog(
                                context: context,
                                builder: (context) => ItemDetailCard(
                                  item: obj,
                                  onReactionAdded: () {
                                    _loadIsland(); // Reload to show new reactions
                                  },
                                ),
                              );
                            },
                            child: _RenderIslandObject(assetId: obj['asset_id'], isGlowing: hasWhisper),
                          ),
                        );
                      }).toList()),

                    // Render Dragging Object
                    if (_selectedAsset != null)
                      Positioned(
                        left: _placementOffset.dx,
                        top: _placementOffset.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _placementOffset += details.delta;
                            });
                          },
                          child: _RenderIslandObject(assetId: _selectedAsset!['id'], isPreview: true),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Status Indicator
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  isLoading
                      ? "✨ Syncing Island..."
                      : errorMessage != null
                          ? "⚠️ Error syncing island"
                          : _selectedAsset != null
                              ? "Drag to position, then confirm"
                              : "Island Synced",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
                ),
              ),
            ),
          ),

          // Confirm Placement Button
          if (_selectedAsset != null && !isLoading)
            Positioned(
              bottom: 40,
              left: 50,
              right: 50,
              child: ElevatedButton.icon(
                onPressed: _confirmPlacement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Confirm Placement", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedAsset == null
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => SparkSelectionSheet(
                    onItemSelected: (asset) {
                      _startPlacement(asset);
                    },
                  ),
                );
              },
              backgroundColor: Colors.purple.shade300,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Use Spark", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null, // Hide FAB when placing
    );
  }
}

class _PlaceholderIsland extends StatefulWidget {
  const _PlaceholderIsland({Key? key}) : super(key: key);

  @override
  State<_PlaceholderIsland> createState() => _PlaceholderIslandState();
}

class _PlaceholderIslandState extends State<_PlaceholderIsland> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.green.shade800.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade400.withOpacity(0.2),
                  blurRadius: 50,
                  spreadRadius: 20,
                )
              ]
            ),
            child: const Center(
              child: Text(
                "Floating Island Base",
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RenderIslandObject extends StatelessWidget {
  final String assetId;
  final bool isPreview;
  final bool isGlowing;

  const _RenderIslandObject({
    Key? key,
    required this.assetId,
    this.isPreview = false,
    this.isGlowing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = Icon(
      Icons.auto_awesome,
      size: 60,
      color: isPreview ? Colors.white.withOpacity(0.7) : Colors.purpleAccent,
    );

    if (isGlowing) {
      child = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 10,
            )
          ]
        ),
        child: child,
      );
    }

    return child;
  }
}
