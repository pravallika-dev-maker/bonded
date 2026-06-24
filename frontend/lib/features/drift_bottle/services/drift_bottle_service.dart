import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/api_service.dart';
import '../models/drift_bottle_reward.dart';

class DriftBottleService {
  static Future<DriftBottleStatus> getStatus() async {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(ApiConfig.driftBottleStatus),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DriftBottleStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get drift bottle status');
    }
  }

  static Future<UserRewards> getRewards() async {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(ApiConfig.driftBottleRewards),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserRewards.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user rewards');
    }
  }

  static Future<DriftBottleOpenResult> openBottle() async {
    final token = await ApiService.getToken();
    final response = await http.post(
      Uri.parse(ApiConfig.driftBottleOpen),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DriftBottleOpenResult.fromJson(data);
    } else {
      return DriftBottleOpenResult(
        success: false,
        message: data['detail'] ?? 'Failed to open bottle',
      );
    }
  }
}
