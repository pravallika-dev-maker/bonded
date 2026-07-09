class DriftBottleStatus {
  final bool canOpen;
  final DateTime? lastOpened;

  DriftBottleStatus({required this.canOpen, this.lastOpened});

  factory DriftBottleStatus.fromJson(Map<String, dynamic> json) {
    return DriftBottleStatus(
      canOpen: json['can_open'] ?? false,
      lastOpened: json['last_opened'] != null
          ? DateTime.parse(json['last_opened'])
          : null,
    );
  }
}

class UserRewards {
  final int loveTokens;
  final int auraFragments;

  UserRewards({required this.loveTokens, required this.auraFragments});

  factory UserRewards.fromJson(Map<String, dynamic> json) {
    return UserRewards(
      loveTokens: json['love_tokens'] ?? 0,
      auraFragments: json['aura_fragments'] ?? 0,
    );
  }
}

class DriftBottleOpenResult {
  final bool success;
  final String? message;
  final String? rewardType;
  final int? rewardValue;
  final int? totalLoveTokens;
  final int? totalAuraFragments;

  DriftBottleOpenResult({
    required this.success,
    this.message,
    this.rewardType,
    this.rewardValue,
    this.totalLoveTokens,
    this.totalAuraFragments,
  });

  factory DriftBottleOpenResult.fromJson(Map<String, dynamic> json) {
    return DriftBottleOpenResult(
      success: json['success'] ?? false,
      message: json['message'],
      rewardType: json['reward_type'],
      rewardValue: json['reward_value'],
      totalLoveTokens: json['total_love_tokens'],
      totalAuraFragments: json['total_aura_fragments'],
    );
  }
}
