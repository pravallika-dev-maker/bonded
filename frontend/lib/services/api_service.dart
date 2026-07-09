import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';
  static const String _partnerNameKey = 'partner_name';
  static const String _userNameKey = 'user_name';
  static const String _isPartnerConnectedKey = 'is_partner_connected';

  /// Gets the stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Sets the auth token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_partnerNameKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_isPartnerConnectedKey);
  }

  /// Gets the cached partner name
  static Future<String?> getPartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_partnerNameKey);
  }

  /// Caches the partner name
  static Future<void> setPartnerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_partnerNameKey, name);
  }

  /// Gets the cached user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Caches the user name
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Gets the cached connection status
  static Future<bool> getIsPartnerConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPartnerConnectedKey) ?? false;
  }

  /// Caches the connection status
  static Future<void> setIsPartnerConnected(bool isConnected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPartnerConnectedKey, isConnected);
  }

  /// Sends a verification code to the provided country code and phone number.
  /// Returns the parsed JSON response on success, or throws an Exception on failure.
  static Future<Map<String, dynamic>> sendCode({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendCode),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to send verification code');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Verifies the OTP code for the provided country code and phone number.
  /// Returns the parsed JSON response on success, or throws an Exception on failure.
  static Future<Map<String, dynamic>> verifyCode({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyCode),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Try to find token in response and save it
        debugPrint('API_DEBUG verifyCode - Response data: $responseData');
        final token = responseData['token'] ?? responseData['accessToken'] ?? responseData['access_token'];
        debugPrint('API_DEBUG verifyCode - Extracted token: $token');
        if (token != null && token is String) {
          await setToken(token);
          debugPrint('API_DEBUG verifyCode - Token saved successfully');
        } else {
          debugPrint('API_DEBUG verifyCode - Warning: Token was null or not a String!');
        }
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to verify code');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches the user's past moods and reflections from the backend server.
  static Future<List<Map<String, dynamic>>> getMoods() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiConfig.moods),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load past reflections');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches the user's mood history for the calendar view.
  static Future<List<Map<String, dynamic>>> getMoodHistory() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.moods}history'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load mood history');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Logs a new mood and reflection to the backend server.
  static Future<Map<String, dynamic>> postMood({
    required String mood,
    required String reflection,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(ApiConfig.moods),
        headers: headers,
        body: jsonEncode({
          'mood': mood,
          'reflection': reflection,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to save reflection');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches a partner invite code from the backend server.
  static Future<Map<String, dynamic>> getInviteCode() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiConfig.inviteCode),
        headers: headers,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get invite code');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Joins a partner through their invite code.
  static Future<Map<String, dynamic>> joinPartner({
    required String code,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(ApiConfig.joinPartner),
        headers: headers,
        body: jsonEncode({
          'code': code,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to join partner');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Disconnects from the current partner.
  static Future<void> disconnectPartner() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse(ApiConfig.disconnectPartner),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to disconnect partner');
      }

      // Clear local partner caching
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_partnerNameKey);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Deletes the user account permanently.
  static Future<void> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse(ApiConfig.userMe),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['detail'] ?? decoded['message'] ?? 'Failed to delete account');
      }

      // Clear local token and partner caching
      await clearToken();
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Creates a new separation.
  static Future<Map<String, dynamic>> createSeparation({
    required String durationLabel,
    required String startDate,
    required String reason,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(ApiConfig.separations),
        headers: headers,
        body: jsonEncode({
          'durationLabel': durationLabel,
          'startDate': startDate,
          'reason': reason,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create separation');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets the active separation status.
  static Future<Map<String, dynamic>?> getActiveSeparation() async {
    try {
      final token = await getToken();
      debugPrint('API_DEBUG getActiveSeparation - Retrieved token: $token');
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      debugPrint('API_DEBUG getActiveSeparation - Headers: $headers');

      final response = await http.get(
        Uri.parse(ApiConfig.activeSeparation),
        headers: headers,
      );

      // Handle 404 case if there is no active separation
      if (response.statusCode == 404) {
        return null;
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = responseData['data'] ?? responseData;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_active_separation', jsonEncode(data));
        return data;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to check active separation status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Ends the specified separation.
  static Future<Map<String, dynamic>> endSeparation(int separationId) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.separations}$separationId/end'),
        headers: headers,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to end separation');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Secret Developer Tool: Time travels the active separation to end today
  static Future<Map<String, dynamic>> timeTravelSeparation() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.separations}time-travel'),
        headers: headers,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['detail'] ?? responseData['message'] ?? 'Failed to time travel');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches the user's past separations (relationships history).
  static Future<List<Map<String, dynamic>>> getSeparationsHistory() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiConfig.relationshipsHistory),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          if (decoded['data'] is List) {
            return (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to load past separations');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches the summary for a specific archived relationship.
  /// GET /api/v1/relationships/{relationship_id}/summary
  static Future<Map<String, dynamic>> getRelationshipSummary(int relationshipId) async {
    try {
      final token = await getToken();
      final headers = {'accept': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(
        Uri.parse('${ApiConfig.relationshipsBase}$relationshipId/summary'),
        headers: headers,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get relationship summary');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Keep old name as alias for backwards compatibility
  static Future<Map<String, dynamic>> getSeparationSummary(int relationshipId) =>
      getRelationshipSummary(relationshipId);

  /// Fetches letters for a specific archived relationship.
  /// GET /api/v1/relationships/{relationship_id}/letters
  static Future<List<Map<String, dynamic>>> getRelationshipLetters(int relationshipId) async {
    try {
      final token = await getToken();
      final headers = {'accept': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(
        Uri.parse('${ApiConfig.relationshipsBase}$relationshipId/letters'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          if (decoded['data'] is List) {
            return (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to load relationship letters');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Keep old name as alias for backwards compatibility
  static Future<List<Map<String, dynamic>>> getSeparationLetters(int relationshipId) =>
      getRelationshipLetters(relationshipId);

  /// Fetches separations for a specific archived relationship.
  /// GET /api/v1/relationships/{relationship_id}/separations
  static Future<List<Map<String, dynamic>>> getRelationshipSeparations(int relationshipId) async {
    try {
      final token = await getToken();
      final headers = {'accept': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(
        Uri.parse('${ApiConfig.relationshipsBase}$relationshipId/separations'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          if (decoded['data'] is List) {
            return (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to load relationship separations');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Reflections Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetches today's reflection question.
  static Future<Map<String, dynamic>> getTodayQuestion() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.reflectionQuestionToday),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['detail'] ?? responseData['message'] ?? 'Failed to get today question');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetches today's reflection status.
  /// GET /api/v1/reflections/today/status
  /// Returns fields including: is_completed, user_total_completed, partner_total_completed
  static Future<Map<String, dynamic>?> getReflectionTodayStatus() async {
    try {
      final token = await getToken();
      final headers = {'accept': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await http.get(
        Uri.parse(ApiConfig.reflectionTodayStatus),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('getReflectionTodayStatus error: $e');
      return null;
    }
  }

  /// Submits an answer to the reflection question.
  static Future<Map<String, dynamic>> submitReflectionAnswer({
    required int sessionId,
    required int questionId,
    required String textAnswer,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse(ApiConfig.reflectionAnswer),
        headers: headers,
        body: jsonEncode({
          'sessionId': sessionId,
          'questionId': questionId,
          'textAnswer': textAnswer,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMsg = responseData['detail'] ?? responseData['message'] ?? 'Failed to submit answer';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets the status of today's reflection.
  static Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.reflectionTodayStatus),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get today status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Letters Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Creates a new letter.
  static Future<Map<String, dynamic>> createLetter({
    required String content,
    String? title,
    String? letterType,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse(ApiConfig.letters),
        headers: headers,
        body: jsonEncode({
          'content': content,
          if (title != null) 'title': title,
          if (letterType != null) 'letterType': letterType,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create letter');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets all letters written by the user.
  static Future<List<Map<String, dynamic>>> getLetters() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.letters),
        headers: headers,
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception('Failed to load letters');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }


  /// Updates a specific letter by ID.
  static Future<Map<String, dynamic>> updateLetter(int letterId, {String? title, String? content, String? letterType}) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.patch(
        Uri.parse('${ApiConfig.letters}$letterId'),
        headers: headers,
        body: jsonEncode({
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (letterType != null) 'letterType': letterType,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update letter');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Deletes a specific letter by ID.
  static Future<Map<String, dynamic>> deleteLetter(int letterId) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.delete(
        Uri.parse('${ApiConfig.letters}$letterId'),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete letter');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Journey Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets the journey score / status.
  static Future<Map<String, dynamic>> getJourneyScore() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.journeyScore),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get journey score');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets journey insights.
  static Future<Map<String, dynamic>> getJourneyInsights() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.journeyInsights),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get journey insights');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // User Profile Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets current user details (/users/me).
  static Future<Map<String, dynamic>> getUserMe() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.userMe),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // Cache user_name and isPartnerConnected
        final pd = data['data'] ?? data;
        final rawUserName = pd['userName'] ?? pd['name'];
        if (rawUserName != null && rawUserName.toString().trim().isNotEmpty) {
          await setUserName(rawUserName.toString().trim());
        }
        
        final isConnected = pd['isPartnerConnected'] == true || 
                            pd['is_partner_connected'] == true || 
                            pd['partner_connected'] == true;
        await setIsPartnerConnected(isConnected);
        
        return data;
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets current user profile details.
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.userMe),
        headers: headers,
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final pd = responseData['data'] ?? responseData;
        final isConnected = pd['isPartnerConnected'] == true || 
                            pd['is_partner_connected'] == true || 
                            pd['partner_connected'] == true;
        await setIsPartnerConnected(isConnected);
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Updates user profile details.
  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? partnerName,
    String? gender,
    String? relationType,
    String? relationshipDate,
    String? dob,
    bool? notificationsEnabled,
  }) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.patch(
        Uri.parse(ApiConfig.userProfile),
        headers: headers,
        body: jsonEncode({
          if (name != null) 'userName': name,
          if (relationType != null) 'relationType': relationType,
          if (partnerName != null) 'partnerName': partnerName,
          if (relationshipDate != null) 'relationshipDate': relationshipDate,
          if (dob != null) 'dob': dob,
          if (gender != null) 'gender': gender,
          if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Registers the FCM token for push notifications.
  static Future<void> registerFcmToken(String fcmToken) async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse(ApiConfig.fcmToken),
        headers: headers,
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('API_DEBUG registerFcmToken - Success');
      }
    } catch (e) {
      debugPrint('API_ERROR registerFcmToken: $e');
    }
  }

  static Future<void> sendWelcomePush() async {
    final token = await getToken();
    if (token == null) return;
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/welcome-push'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        debugPrint('Failed to send welcome push: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending welcome push: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Notifications Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets the current user's notifications.
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.notifications),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Gets the count of unread notifications.
  static Future<int> getUnreadNotificationsCount() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.notificationsUnreadCount),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return decoded['unreadCount'] ?? 0;
      } else {
        throw Exception('Failed to load unread notifications count');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Marks all notifications as read.
  static Future<void> markAllNotificationsAsRead() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.patch(
        Uri.parse(ApiConfig.notificationsReadAll),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Affirmations Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets today's affirmation.
  static Future<Map<String, dynamic>?> getTodayAffirmation() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.dailyAffirmation),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets today's insight.
  static Future<Map<String, dynamic>?> getDailyInsight() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'X-Timezone-Offset': DateTime.now().timeZoneOffset.inMinutes.toString(),
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.dailyInsight),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Marks today's insight as viewed. Idempotent — safe to call multiple times.
  static Future<void> markInsightViewed() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      await http.post(
        Uri.parse(ApiConfig.dailyInsightMarkViewed),
        headers: headers,
      );
    } catch (_) {
      // Best-effort — ignore failures silently
    }
  }
  // ────────────────────────────────────────────────────────────────────────────
  // Relationships Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets the history of all relationships/separations.
  static Future<List<Map<String, dynamic>>> getRelationshipsHistory() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.relationshipsHistory),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final data = decoded['data'];
          if (data is List) {
            return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        }
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load relationships history');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Home Endpoints
  // ────────────────────────────────────────────────────────────────────────────

  /// Gets the home hero data.
  static Future<Map<String, dynamic>> getHomeHero() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(
        Uri.parse(ApiConfig.homeHero),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        Map<String, dynamic> data;
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          data = decoded['data'] as Map<String, dynamic>;
        } else {
          data = decoded as Map<String, dynamic>;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_home_hero', jsonEncode(data));
        return data;
      } else {
        throw Exception('Failed to load home hero data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Acknowledges the completion of the journey.
  static Future<void> acknowledgeJourneyCompletion() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse(ApiConfig.acknowledgeCompletion),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Exception('Failed to acknowledge completion');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Immediately clear the user's presence signal when the app backgrounds
  static Future<void> setOffline() async {
    try {
      final token = await getToken();
      final headers = {
        'accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      await http.post(
        Uri.parse(ApiConfig.homeOffline),
        headers: headers,
      );
    } catch (_) {
      // Best-effort
    }
  }
}
