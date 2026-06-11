class ApiConfig {
  static const String baseUrl = 'https://bonded-ul4n.onrender.com/api/v1';

  // Auth Endpoints
  static const String sendCode = '$baseUrl/auth/send-code';
  static const String verifyCode = '$baseUrl/auth/verify-code';

  // Moods Endpoints
  static const String moods = '$baseUrl/moods/';

  // Partners Endpoints
  static const String inviteCode = '$baseUrl/partners/invite-code';
  static const String joinPartner = '$baseUrl/partners/join';

  // Separations Endpoints
  static const String separations = '$baseUrl/separations/';
  static const String activeSeparation = '$baseUrl/separations/active';
  static const String separationsHistory = '$baseUrl/separations/history';

  // Reflections Endpoints
  static const String reflectionQuestionToday = '$baseUrl/reflections/questions/today';
  static const String reflectionAnswer = '$baseUrl/reflections/answer';
  static const String reflectionSubmit = '$baseUrl/reflections/submit';
  static const String reflectionTodayStatus = '$baseUrl/reflections/today/status';
  static const String reflectionComparison = '$baseUrl/reflections/comparison/today';

  // Letters Endpoints
  static const String letters = '$baseUrl/letters/';
  static const String lettersMy = '$baseUrl/letters/my';
  static const String lettersPartnerRevealed = '$baseUrl/letters/partner/revealed';

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

  // Affirmations Endpoints
  static const String affirmationToday = '$baseUrl/affirmations/today';

  // Relationships Endpoints
  static const String relationshipsBase = '$baseUrl/relationships/';
  static const String relationshipsHistory = '$baseUrl/relationships/history';
}
