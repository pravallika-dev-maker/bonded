import 'package:flutter/foundation.dart';

class ApiConfig {
  // Use local server for debug mode, real server for production
  static const String baseUrl = kDebugMode
      ? (kIsWeb ? 'http://localhost:8000/api/v1' : 'http://10.0.2.2:8000/api/v1')
      : 'http://3.110.252.52:8001/api/v1';

  // Home Endpoints
  static const String homeHero = '$baseUrl/home/hero';
  static const String homeOffline = '$baseUrl/home/offline';
  static const String acknowledgeCompletion = '$baseUrl/home/acknowledge-completion';

  // Auth Endpoints
  static const String sendCode = '$baseUrl/auth/send-code';
  static const String verifyCode = '$baseUrl/auth/verify-code';

  // Onboarding Endpoints
  static const String onboardingConfig = '$baseUrl/onboarding/config';

  // Moods Endpoints
  static const String moods = '$baseUrl/moods/';

  // Partners Endpoints
  static const String inviteCode = '$baseUrl/partners/invite-code';
  static const String joinPartner = '$baseUrl/partners/join';
  static const String disconnectPartner = '$baseUrl/partners/disconnect';
  static const String sendPoke = '$baseUrl/partners/poke';
  static String acknowledgePoke(int pokeId) => '$baseUrl/partners/poke/$pokeId/acknowledge';

  // Separations Endpoints
  static const String separations = '$baseUrl/separations/';
  static const String activeSeparation = '$baseUrl/separations/active';

  // Reflections Endpoints
  static const String reflectionQuestionToday = '$baseUrl/reflections/questions/today';
  static const String reflectionAnswer = '$baseUrl/reflections/answer';
  static const String reflectionTodayStatus = '$baseUrl/reflections/today/status';

  // Letters Endpoints
  static const String letters = '$baseUrl/letters/';

  // Journey Endpoints
  static const String journeyScore = '$baseUrl/journey/score';
  static const String journeyInsights = '$baseUrl/journey/insights';

  // User Endpoints
  static const String userMe = '$baseUrl/users/me';
  static const String userProfile = '$baseUrl/users/profile';
  static const String fcmToken = '$baseUrl/users/fcm-token';

  // Notifications Endpoints
  static const String notifications = '$baseUrl/notifications/';
  static const String notificationsUnreadCount = '$baseUrl/notifications/unread-count';
  static const String notificationsReadAll = '$baseUrl/notifications/read-all';

  // Daily Content Endpoints
  static const String dailyAffirmation = '$baseUrl/daily/affirmation';
  static const String dailyInsight = '$baseUrl/daily/insight';
  static const String dailyInsightMarkViewed = '$baseUrl/daily/insight/mark-viewed';

  // Relationships Endpoints
  static const String relationshipsBase = '$baseUrl/relationships/';
  static const String relationshipsHistory = '$baseUrl/relationships/history';

  // Drift Bottle Endpoints
  static const String driftBottleStatus = '$baseUrl/drift-bottle/status';
  static const String driftBottleRewards = '$baseUrl/drift-bottle/rewards';
  static const String driftBottleOpen = '$baseUrl/drift-bottle/open';

  // Sky Haven Endpoints
  static const String skyHavenBase = '$baseUrl/skyhaven/';
  static const String skyHavenIsland = '$baseUrl/skyhaven/island';
  static const String skyHavenStatus = '$baseUrl/skyhaven/status';
  static const String skyHavenAssets = '$baseUrl/skyhaven/assets';
  static const String skyHavenPlaceObject = '$baseUrl/skyhaven/place-object';
  static const String skyHavenReadWhisper = '$baseUrl/skyhaven/object';
  static const String skyHavenReactObject = '$baseUrl/skyhaven/object';
}
