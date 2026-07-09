import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_service.dart';

class SkyHavenService {
  static Future<Map<String, dynamic>?> getIsland() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenIsland),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting Sky Haven island: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getStatus() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenStatus),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting Sky Haven status: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getAssets() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.skyHavenAssets),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map && data.containsKey('assets')) {
          return List<dynamic>.from(data['assets']);
        } else if (data is List) {
          return List<dynamic>.from(data);
        }
        return [];
      }
      return null;
    } catch (e) {
      print('Error getting Sky Haven assets: $e');
      return null;
    }
  }

  static Future<bool> placeObject({
    required int assetId,
    required double positionX,
    required double positionY,
    required double rotation,
    required double scale,
    String? whisper,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final body = {
        'asset_id': assetId,
        'position_x': positionX,
        'position_y': positionY,
        'rotation': rotation,
        'scale': scale,
        'optional_whisper': whisper,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.skyHavenPlaceObject),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error placing Sky Haven object: $e');
      return false;
    }
  }

  static Future<bool> readWhisper(String objectId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.skyHavenReadWhisper}/$objectId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error reading Sky Haven whisper: $e');
      return false;
    }
  }

  static Future<bool> reactToObject(String objectId, String reaction) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.skyHavenReactObject}/$objectId/react'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reaction': reaction}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error reacting to Sky Haven object: $e');
      return false;
    }
  }

  static Future<bool> updateObject({
    required String objectId,
    required dynamic assetId,
    required double positionX,
    required double positionY,
    required double rotation,
    required double scale,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final body = {
        'asset_id': assetId.toString(),
        'position_x': positionX,
        'position_y': positionY,
        'rotation': rotation,
        'scale': scale,
      };

      final response = await http.patch(
        Uri.parse('${ApiConfig.skyHavenReactObject}/$objectId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating Sky Haven object: $e');
      return false;
    }
  }

  static Future<bool> deleteObject(String objectId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.skyHavenReactObject}/$objectId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting Sky Haven object: $e');
      return false;
    }
  }
}
