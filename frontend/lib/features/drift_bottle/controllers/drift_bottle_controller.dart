import 'package:flutter/material.dart';
import '../models/drift_bottle_reward.dart';
import '../services/drift_bottle_service.dart';

class DriftBottleController extends ChangeNotifier {
  bool _isLoading = false;
  bool _canOpen = false;
  int _loveTokens = 0;
  int _auraFragments = 0;

  bool get isLoading => _isLoading;
  bool get canOpen => _canOpen;
  int get loveTokens => _loveTokens;
  int get auraFragments => _auraFragments;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final status = await DriftBottleService.getStatus();
      final rewards = await DriftBottleService.getRewards();

      _canOpen = true; // FOR TESTING: Always keep it true instead of status.canOpen;
      _loveTokens = rewards.loveTokens;
      _auraFragments = rewards.auraFragments;
    } catch (e) {
      debugPrint('Error initializing drift bottle: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DriftBottleOpenResult?> openBottle() async {
    if (!_canOpen) return null;

    _isLoading = true;
    notifyListeners();

    try {
      // FOR TESTING: Mock the API response so it always succeeds
      await Future.delayed(const Duration(seconds: 1));
      final result = DriftBottleOpenResult(
        success: true,
        message: "You found a drift bottle!",
        rewardType: "love_token",
        rewardValue: 5,
        totalLoveTokens: _loveTokens + 5,
        totalAuraFragments: _auraFragments + 2,
      );
      // final result = await DriftBottleService.openBottle();
      
      if (result.success) {
        _canOpen = true; // FOR TESTING: Keep it true instead of false;
        if (result.totalLoveTokens != null) {
          _loveTokens = result.totalLoveTokens!;
        }
        if (result.totalAuraFragments != null) {
          _auraFragments = result.totalAuraFragments!;
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error opening drift bottle: $e');
      return DriftBottleOpenResult(success: false, message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
