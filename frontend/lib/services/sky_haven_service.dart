import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_service.dart';

class SkyHavenService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await ApiService.getToken();
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetch the full island state
  static Future<Map<String, dynamic>> getIsland() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenIsland),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to get island');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetch the island status for polling
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenStatus),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to get island status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetch all unlocked assets
  static Future<Map<String, dynamic>> getAssets() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenAssets),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to get assets');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Place an object on the island
  static Future<Map<String, dynamic>> placeObject({
    required String assetId,
    required double x,
    required double y,
    double rotation = 0.0,
    double scale = 1.0,
    String? whisper,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.skyHavenPlaceObject),
        headers: headers,
        body: jsonEncode({
          'asset_id': assetId,
          'position_x': x,
          'position_y': y,
          'rotation': rotation,
          'scale': scale,
          if (whisper != null && whisper.isNotEmpty) 'optional_whisper': whisper,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to place object');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// React to an object
  static Future<Map<String, dynamic>> reactToObject(String objectId, String reaction) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.skyHavenBase}object/$objectId/react'),
        headers: headers,
        body: jsonEncode({'reaction': reaction}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to react to object');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Mark a whisper as read
  static Future<Map<String, dynamic>> readWhisper(String objectId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.skyHavenBase}object/$objectId/read-whisper'),
        headers: headers,
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to mark whisper read');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
