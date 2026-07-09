import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SkyHaven3DEngine extends StatefulWidget {
  final List<dynamic> objects;
  final Function(Map<String, dynamic>) onPlacementConfirmed;
  final Function(String) onObjectTapped;
  final Function(Map<String, dynamic>)? onObjectSelected;
  final Function(Map<String, dynamic>)? onObjectRepositioned;
  final WebViewController? externalController;

  const SkyHaven3DEngine({
    super.key,
    required this.objects,
    required this.onPlacementConfirmed,
    required this.onObjectTapped,
    this.onObjectSelected,
    this.onObjectRepositioned,
    this.externalController,
  });

  @override
  State<SkyHaven3DEngine> createState() => _SkyHaven3DEngineState();
}

class _SkyHaven3DEngineState extends State<SkyHaven3DEngine> {
  late final WebViewController _controller;
  bool _isReady = false;
  final Map<String, String> _loadedModelsBase64 = {};

  @override
  void initState() {
    super.initState();
    _controller = widget.externalController ?? WebViewController();

    // Configure the controller (transparency, javascript, native channel, and load page)
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            _handleMessage(message.message);
          },
        )
        ..loadFlutterAsset('assets/web/sky_haven_engine.html');
    } else {
      _controller.loadRequest(Uri.parse('assets/web/sky_haven_engine.html'));
    }

    // Load 3D model assets asynchronously as base64 to bypass webview file:// CORS restrictions
    _load3DModels();
  }

  Future<void> _load3DModels() async {
    try {
      final assetsToLoad = {
        'tree': 'assets/models/tree.glb',
        'lantern': 'assets/models/japanese_stone_lantern.glb',
        'bench': 'assets/models/simple_park_bench.glb',
      };

      for (var entry in assetsToLoad.entries) {
        final byteData = await rootBundle.load(entry.value);
        final base64String = base64Encode(byteData.buffer.asUint8List());
        _loadedModelsBase64[entry.key] = base64String;
      }

      if (_isReady && mounted) {
        _sendModelsToWebview();
      }
    } catch (e) {
      debugPrint("Error loading 3D asset bytes: $e");
    }
  }

  void _sendModelsToWebview() {
    if (_loadedModelsBase64.isEmpty) return;
    
    // Inject loaded base64 data into JavaScript cache
    _loadedModelsBase64.forEach((key, base64) {
      _controller.runJavaScript("window.set3DModel('$key', '$base64');");
    });
    
    // Trigger loading of objects once models are cached
    _loadObjectsIntoEngine();
  }

  @override
  void didUpdateWidget(SkyHaven3DEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isReady && oldWidget.objects != widget.objects) {
      _loadObjectsIntoEngine();
    }
  }

  void _handleMessage(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr);
      if (data['type'] == 'ready') {
        setState(() {
          _isReady = true;
        });
        _sendModelsToWebview();
      } else if (data['type'] == 'placement_confirmed') {
        widget.onPlacementConfirmed({
          'x': data['x'],
          'y': data['y'],
          'rotation': data['rotation'],
          'scale': data['scale'],
        });
      } else if (data['type'] == 'object_tapped') {
        widget.onObjectTapped(data['objectId'].toString());
      } else if (data['type'] == 'object_selected') {
        if (widget.onObjectSelected != null) {
          widget.onObjectSelected!({
            'objectId': data['objectId'].toString(),
            'scale': (data['scale'] as num).toDouble(),
            'rotation': (data['rotation'] as num).toDouble(),
            'x': (data['x'] as num).toDouble(),
            'y': (data['y'] as num).toDouble(),
          });
        }
      } else if (data['type'] == 'object_repositioned') {
        if (widget.onObjectRepositioned != null) {
          widget.onObjectRepositioned!({
            'objectId': data['objectId'].toString(),
            'x': (data['x'] as num).toDouble(),
            'y': (data['y'] as num).toDouble(),
          });
        }
      }
    } catch (e) {
      debugPrint("Error parsing 3D Engine message: $e");
    }
  }

  void _loadObjectsIntoEngine() {
    final jsonStr = jsonEncode(widget.objects.map((obj) => {
      'id': obj['id'],
      'assetId': obj['asset_id'],
      'x': obj['position_x'] ?? 0.0,
      'y': obj['position_y'] ?? 0.0,
      'rotation': obj['rotation'] ?? 0.0,
      'scale': obj['scale'] ?? 1.0,
      'isNew': obj['has_unread_whisper'] == true,
    }).toList());
    
    _controller.runJavaScript("window.loadObjects('$jsonStr');");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
