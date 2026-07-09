import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/sky_haven_service.dart';
import 'engine/sky_haven_3d_engine.dart';
import 'widgets/spark_selection_sheet.dart';
import 'widgets/whisper_dialog.dart';
import 'widgets/discovery_popup.dart';

class SkyHavenScreen extends StatefulWidget {
  const SkyHavenScreen({super.key});

  @override
  State<SkyHavenScreen> createState() => _SkyHavenScreenState();
}

class _SkyHavenScreenState extends State<SkyHavenScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _islandData;
  List<dynamic> _assets = [];
  bool _isMyTurn = false;
  late final WebViewController _webViewController;

  // Selection & Adjustments state
  Map<String, dynamic>? _selectedObject;
  double _currentScale = 1.0;
  double _currentRotation = 0.0;
  bool _isRepositioning = false;
  double _currentX = 0.0;
  double _currentY = 0.0;
  Map<String, dynamic>? _selectedPlacementAsset;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
    if (!kIsWeb) {
      _webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent);
    }
      
    // Set up message handler after a slight delay or directly, engine handles it 
    // We pass it to the engine, which will add the channel and load the HTML.
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Fetch island and assets
    final islandRes = await SkyHavenService.getIsland();
    final assetsRes = await SkyHavenService.getAssets();
    
    // Determine turn (mock user_id = 1 for Maya context, or based on real auth)
    // For now, if current_turn_user_id == my user_id (needs backend context).
    // Let's assume the API or some logic tells us if it's our turn.
    // If not provided directly, we mock it based on island data.
    bool myTurn = false;
    if (islandRes != null) {
      // Typically you'd compare current_turn_user_id to your own user ID.
      // Let's just default to true for demonstration or use the raw id if known.
      myTurn = true; // In a real app: islandRes['current_turn_user_id'] == myUserId
    }

    if (mounted) {
      setState(() {
        _islandData = islandRes;
        _assets = assetsRes ?? [];
        _isMyTurn = myTurn;
        _isLoading = false;
      });
    }
  }

  void _handleUseSpark() {
    SparkSelectionSheet.show(context, _assets, (selectedAsset) {
      setState(() {
        _selectedPlacementAsset = selectedAsset;
      });
      final jsonAsset = jsonEncode({'id': selectedAsset['id'], 'scale': 1.0});
      _webViewController.runJavaScript("window.enterPlacementMode('$jsonAsset');");
    });
  }

  void _onPlacementConfirmed(Map<String, dynamic> placementData) {
    WhisperDialog.show(context, (whisper) async {
      final assetIdInt = int.tryParse(_selectedPlacementAsset?['id']?.toString() ?? '1') ?? 1;
      final success = await SkyHavenService.placeObject(
        assetId: assetIdInt,
        positionX: placementData['x'],
        positionY: placementData['y'],
        rotation: placementData['rotation'],
        scale: placementData['scale'],
        whisper: whisper,
      );

      if (success) {
        _loadData();
      }
    });
  }

  void _onObjectTapped(String objectId) {
    final obj = (_islandData?['objects'] as List?)?.firstWhere((o) => o['id'].toString() == objectId, orElse: () => null);
    if (obj != null && obj['has_unread_whisper'] == true) {
      DiscoveryPopup.show(context, obj, (reaction) async {
        await SkyHavenService.reactToObject(objectId, reaction);
        await SkyHavenService.readWhisper(objectId);
        _loadData();
      });
    }
  }

  void _onObjectSelected(Map<String, dynamic> data) {
    setState(() {
      _selectedObject = data;
      _currentScale = data['scale'];
      _currentRotation = data['rotation'];
      _currentX = data['x'];
      _currentY = data['y'];
      _isRepositioning = false;
    });
  }

  void _onObjectRepositioned(Map<String, dynamic> data) {
    setState(() {
      _currentX = data['x'];
      _currentY = data['y'];
      _isRepositioning = false;
    });
  }

  void _updateScale(double value) {
    setState(() {
      _currentScale = value;
    });
    _webViewController.runJavaScript("window.setSelectedObjectScale($value);");
  }

  void _updateRotation(double value) {
    setState(() {
      _currentRotation = value;
    });
    _webViewController.runJavaScript("window.setSelectedObjectRotation($value);");
  }

  void _toggleRepositioning() {
    setState(() {
      _isRepositioning = !_isRepositioning;
    });
    if (_isRepositioning) {
      _webViewController.runJavaScript("window.startRepositionMode();");
    } else {
      _webViewController.runJavaScript("window.stopRepositionMode();");
    }
  }

  Future<void> _saveObjectAdjustments() async {
    if (_selectedObject == null) return;
    setState(() => _isLoading = true);

    final objectId = _selectedObject!['objectId'];
    final obj = (_islandData?['objects'] as List?)?.firstWhere((o) => o['id'].toString() == objectId, orElse: () => null);
    final assetId = obj?['asset_id'] ?? '1';

    final success = await SkyHavenService.updateObject(
      objectId: objectId,
      assetId: assetId,
      positionX: _currentX,
      positionY: _currentY,
      rotation: _currentRotation,
      scale: _currentScale,
    );

    if (success) {
      _webViewController.runJavaScript("window.deselectObject();");
      setState(() {
        _selectedObject = null;
      });
      await _loadData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update object placement.')),
      );
    }
  }

  Future<void> _deleteObject() async {
    if (_selectedObject == null) return;
    setState(() => _isLoading = true);

    final objectId = _selectedObject!['objectId'];
    final success = await SkyHavenService.deleteObject(objectId);

    if (success) {
      _webViewController.runJavaScript("window.deselectObject();");
      setState(() {
        _selectedObject = null;
      });
      await _loadData();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete object.')),
      );
    }
  }

  void _cancelSelection() {
    _webViewController.runJavaScript("window.deselectObject();");
    setState(() {
      _selectedObject = null;
    });
    _loadData();
  }

  Widget _buildAdjustmentDrawer() {
    if (_selectedObject == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF180710).withOpacity(0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFF8BC2).withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Adjust Object',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelSelection,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white70, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Text(
                      'Size',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFF8BC2),
                        inactiveTrackColor: Colors.white10,
                        thumbColor: const Color(0xFFFF8BC2),
                        overlayColor: const Color(0xFFFF8BC2).withOpacity(0.2),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _currentScale.clamp(0.4, 2.5),
                        min: 0.4,
                        max: 2.5,
                        onChanged: _updateScale,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentScale.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Text(
                      'Rotation',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF00E5FF),
                        inactiveTrackColor: Colors.white10,
                        thumbColor: const Color(0xFF00E5FF),
                        overlayColor: const Color(0xFF00E5FF).withOpacity(0.2),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _currentRotation,
                        min: 0.0,
                        max: 6.28,
                        onChanged: _updateRotation,
                      ),
                    ),
                  ),
                  Text(
                    '${((_currentRotation * 180) / 3.14159).toStringAsFixed(0)}°',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleRepositioning,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isRepositioning 
                            ? const Color(0xFFFF8BC2).withOpacity(0.4) 
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isRepositioning 
                              ? const Color(0xFFFF8BC2) 
                              : Colors.white12,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRepositioning ? Icons.gps_fixed : Icons.open_with,
                            color: _isRepositioning ? const Color(0xFFFF8BC2) : Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRepositioning ? 'Tap ground' : 'Move',
                            style: TextStyle(
                              color: _isRepositioning ? const Color(0xFFFF8BC2) : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _deleteObject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B4B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF4B4B).withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: Color(0xFFFF4B4B), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xFFFF4B4B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _saveObjectAdjustments,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF00A2FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF180710), Color(0xFF090204)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          if (!_isLoading)
            Positioned.fill(
              child: SkyHaven3DEngine(
                objects: _islandData?['objects'] ?? [],
                onPlacementConfirmed: _onPlacementConfirmed,
                onObjectTapped: _onObjectTapped,
                onObjectSelected: _onObjectSelected,
                onObjectRepositioned: _onObjectRepositioned,
                externalController: _webViewController,
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF090204).withOpacity(0.8),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Sky Haven',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                if (!_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
                    child: _selectedObject != null
                        ? _buildAdjustmentDrawer()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isMyTurn ? '✨ Your Spark is Ready' : '🌙 Waiting for Partner',
                                style: TextStyle(
                                  color: _isMyTurn ? const Color(0xFFFF8BC2) : Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_isMyTurn)
                                GestureDetector(
                                  onTap: _handleUseSpark,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF180710).withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF8BC2).withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Use My Spark',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
              ],
            ),
          ),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8BC2)),
            ),
        ],
      ),
    );
  }
}
