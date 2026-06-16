import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/premium_nav_bar.dart';
import '../widgets/premium_sheen.dart';
import 'separation_step1_intention_screen.dart';
import 'history_screen.dart';
import 'feel_screen.dart';
import 'join_with_code_screen.dart';
import 'letters_screen.dart';
import 'journey_screen.dart';
import 'profile_screen.dart';
import 'reflection_flow_screen.dart';
import 'reflection_completion_screen.dart';
import '../widgets/post_journey_sanctuary_card.dart';
import '../widgets/connected_ready_hero_card.dart';
import 'notifications_screen.dart';
import 'dream_house/dream_house_world_screen.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../services/api_service.dart';
import '../services/app_event_bus.dart';
import '../widgets/living_journey_card.dart';
import '../widgets/unconnected_hero_card.dart';
import '../widgets/living_sanctuary_section.dart';
import '../widgets/floating_connection_pill.dart';
import 'partner_invite_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final String userName;
  final String? partnerName;
  final int initialIndex;
  final bool isWaitingForPartner;
  const MainDashboardScreen({super.key, required this.userName, this.partnerName, this.initialIndex = 0, this.isWaitingForPartner = false});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with WidgetsBindingObserver {
  late int _currentIndex;
  // _isCheckedIn is derived from the backend on load (not session-only).
  // true when: daily insight API says is_locked==false, OR user has a mood entry today.
  bool _isCheckedIn = false;
  bool _insightViewed = false;
  String? _todayInsightDate;
  bool _reflectionCompletedToday = false;
  // true when backend confirms partner completed today's reflection.
  bool _partnerCompletedToday = false;
  // true ONLY when active journey day < calendar day (genuine missed-day scenario)
  bool _isMissedDayFlow = false;

  bool _isLoadingSeparation = true;
  bool _hasAcknowledgedCompletion = false;
  Map<String, dynamic>? _activeSeparation;
  Map<String, dynamic>? _reflectionStatus;
  
  bool _sharedPresence = false; // fires animation each time backend returns true
  Timer? _presenceTimer;
  StreamSubscription<AppEvent>? _eventBusSubscription;
  String? _partnerName;
  bool _isPartnerConnected = false;
  bool _hasPastRelationship = false;
  bool _hasCompletedSeparation = false;
  bool _showConnectedPill = false;
  bool _isHeroEmpty = true;
  late String _currentUserName;
  late bool _localIsWaitingForPartner;
  int _unreadCount = 0;

  // Derived from active separation API — no hardcoded values
  int? _currentDay;
  int? _totalDays;
  String? _moodPhrase;
  int? _completedReflections;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _currentUserName = widget.userName;
    _localIsWaitingForPartner = widget.isWaitingForPartner;
    _partnerName = null; // Clear stale state initially
    _isLoadingSeparation = true;
    _setupPushNotifications();
    _fetchDashboardData();
    
    // Poll for shared presence every 15 seconds to keep both users active and detect each other
    _presenceTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollSharedPresence();
    });

    // Subscribe to global app events — instantly refresh on partner connect/disconnect/time-travel
    _eventBusSubscription = AppEventBus().stream.listen((event) {
      if (!mounted) return;
      if (event == AppEvent.partnerDisconnected) {
        _localIsWaitingForPartner = false;
      }
      _fetchDashboardData();
    });
  }

  Future<void> _acknowledgeCompletion() async {
    try {
      await ApiService.acknowledgeJourneyCompletion();
      if (mounted) {
        setState(() {
          _hasAcknowledgedCompletion = true;
        });
      }
    } catch (e) {
      debugPrint("Failed to acknowledge completion: $e");
    }
  }

  Future<void> _setupPushNotifications() async {
    if (!kIsWeb) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Request permission for push notifications (Shows Android 13 prompt since UI is now mounted)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get the token each time the application loads
      String? token = await messaging.getToken();
      if (token != null) {
        ApiService.registerFcmToken(token).catchError((_) {});
      }

      // Any time the token refreshes, store this in the database too.
      messaging.onTokenRefresh.listen((newToken) {
        ApiService.registerFcmToken(newToken).catchError((_) {});
      });
    }
  }

  Future<void> _pollSharedPresence() async {
    if (!mounted) return;
    try {
      final homeHero = await ApiService.getHomeHero();
      final bool presence = homeHero['shared_presence'] == true;
      final bool partnerConnected = homeHero['partner_connected'] == true || 
                                    homeHero['partnerConnected'] == true;
                                    
      bool needsSetState = false;
      if (presence != _sharedPresence) {
        _sharedPresence = presence;
        needsSetState = true;
      }
      
      // Dynamically detect if partner connected while app is open!
      if (!_isPartnerConnected && partnerConnected) {
        _fetchDashboardData();
        return; // _fetchDashboardData calls setState itself
      }

      // Dynamically detect if partner DISCONNECTED while app is open
      if (_isPartnerConnected && !partnerConnected) {
        _localIsWaitingForPartner = false;
        _fetchDashboardData();
        return;
      }

      if (mounted && needsSetState) {
        setState(() {});
      }
    } catch (_) {
      // Ignore background errors
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchDashboardData();
    }
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _eventBusSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Fetches all dashboard data in parallel and derives UI state from backend responses.
  /// _isCheckedIn and _partnerCompletedToday are always derived from the API,
  /// never from ephemeral session state — ensuring persistence across refreshes.
  Future<void> _fetchDashboardData() async {
    // Also fetch moods list to detect if user submitted a check-in today
    final results = await Future.wait([
      ApiService.getActiveSeparation().catchError((_) => null),
      ApiService.getReflectionTodayStatus().catchError((_) => null),
      ApiService.getHomeHero().catchError((_) => null),
      ApiService.getDailyInsight().catchError((_) => null),
      ApiService.getMoods().catchError((_) => <Map<String, dynamic>>[]),
      ApiService.getUserProfile().catchError((_) => null),
      ApiService.getUnreadNotificationsCount().catchError((_) => 0),
    ]);

    final sep = results[0] as Map<String, dynamic>?;
    final reflStatus = results[1] as Map<String, dynamic>?;
    final homeHero = results[2] as Map<String, dynamic>?;
    final dailyInsight = results[3] as Map<String, dynamic>?;
    final moodsList = results[4] as List<Map<String, dynamic>>? ?? [];
    final profileData = results[5] as Map<String, dynamic>?;
    final unreadCount = results[6] as int? ?? 0;

    final cachedPartnerName = await ApiService.getPartnerName();
    final cachedIsConnected = await ApiService.getIsPartnerConnected();
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _unreadCount = unreadCount;
      _activeSeparation = sep;
      _reflectionStatus = reflStatus;
      
      if (profileData != null) {
        final pd = profileData['data'] ?? profileData;
        if (pd['userName'] != null || pd['name'] != null) {
          _currentUserName = pd['userName'] ?? pd['name'];
        }
        
        // Extract partner name from profile if available
        if (pd['partnerName'] != null && pd['partnerName'].toString().trim().isNotEmpty) {
          _partnerName = pd['partnerName'];
        }
      }

      // ── Partner name from Home Hero or cached — and fall back to widget.partnerName
      // if all else fails (e.g. they just entered it during solo separation creation).
      _partnerName ??= homeHero?['partner_name'] ?? homeHero?['partnerName'] ??
          sep?['partner_name'] ?? sep?['partnerName'] ??
          cachedPartnerName ?? widget.partnerName;
          
      // If all API sources returned null (e.g. after disconnect) explicitly clear name.
      if (_partnerName == null || _partnerName!.trim().isEmpty || _partnerName == 'null') {
        _partnerName = null;
      }

      // Helper function to extract days from durationLabel to fix hardcoded values
      int _extractDaysFromLabel(String label) {
        final lower = label.toLowerCase();
        final match = RegExp(r'(\d+)').firstMatch(lower);
        if (match != null) {
          int value = int.tryParse(match.group(1)!) ?? 21;
          if (lower.contains('week')) return value * 7;
          if (lower.contains('month')) return value * 30;
          return value;
        }
        if (lower.contains('one week') || lower.contains('a week')) return 7;
        if (lower.contains('two week')) return 14;
        if (lower.contains('three week')) return 21;
        if (lower.contains('one month') || lower.contains('a month')) return 30;
        return 21; // fallback
      }

      int parsedTotalDays = 21;
      if (sep != null) {
        if (sep['start_date'] != null && sep['expected_end_date'] != null) {
          try {
            final start = DateTime.parse(sep['start_date'].toString());
            final end = DateTime.parse(sep['expected_end_date'].toString());
            parsedTotalDays = end.difference(start).inDays;
            if (parsedTotalDays <= 0) parsedTotalDays = 1;
          } catch (_) {
            final label = sep['duration_label'] ?? sep['durationLabel'] ?? '';
            parsedTotalDays = _extractDaysFromLabel(label.toString());
          }
        } else {
          final label = sep['duration_label'] ?? sep['durationLabel'] ?? '';
          parsedTotalDays = _extractDaysFromLabel(label.toString());
        }
      }

      // ── Home Hero Data ──
      bool hasHeroData = false;
      if (homeHero != null) {
        // Extract comfort message and total duration unconditionally if present
        final heroPhrase = homeHero['comfort_message'] ?? homeHero['comfortMessage'];
        if (heroPhrase != null && heroPhrase.toString().trim().isNotEmpty) {
          _moodPhrase = heroPhrase.toString();
        }
        
        if (homeHero['total_duration_days'] != null || homeHero['totalDurationDays'] != null) {
          _totalDays = homeHero['total_duration_days'] ?? homeHero['totalDurationDays'];
        } else {
          _totalDays = parsedTotalDays;
        }

        if (homeHero['current_day'] != null || homeHero['currentDay'] != null) {
          hasHeroData = true;
          _currentDay = homeHero['current_day'] ?? homeHero['currentDay'] ?? 1;
        }
        
        // Backend signals missed-day flow: active journey day < calendar day
        _isMissedDayFlow = homeHero['is_missed_day_flow'] == true || homeHero['isMissedDayFlow'] == true;
      } 
      
      bool isSepActive = sep != null && (sep['is_active'] == true || sep['isActive'] == true || sep['status'] == 'active');

      // ── Determine waiting state early so we can suppress day data below ──
      final bool isWaitingFromHero = homeHero?['is_waiting_for_partner'] == true || homeHero?['isWaitingForPartner'] == true;
      final bool effectivelyWaiting = widget.isWaitingForPartner || isWaitingFromHero;

      if (!hasHeroData && isSepActive && !effectivelyWaiting) {
        // Fallback to active separation
        final rawElapsed = sep['days_elapsed'] ?? sep['daysElapsed'] ?? sep['day'];
        _currentDay = rawElapsed is int ? rawElapsed : int.tryParse(rawElapsed?.toString() ?? '') ?? 1;
        if (_totalDays == null) {
          _totalDays = parsedTotalDays; // Use parsed duration instead of simplified 21 fallback
        }
      }

      // ── Daily Insight — derive _isCheckedIn from API, not from session ──
      if (dailyInsight != null) {
        final isLocked = dailyInsight['is_locked'] == true || dailyInsight['isLocked'] == true;
        if (!isLocked) {
          // Backend says insight is unlocked → user has checked in, persist this across refreshes
          _isCheckedIn = true;
          
          _todayInsightDate = dailyInsight['date']?.toString();
          // Use backend is_viewed as source of truth (persists across devices/restarts)
          _insightViewed = dailyInsight['is_viewed'] == true || dailyInsight['isViewed'] == true;

          if (dailyInsight['insight'] != null) {
            final text = dailyInsight['insight'].toString();
            final currentStatic = _dailyInsights[_currentDay ?? 1] ?? _dailyInsights.values.first;
            _dailyInsights[_currentDay ?? 1] = InsightData(
              lockedTitle: currentStatic.lockedTitle,
              reflectionHeader: currentStatic.reflectionHeader,
              reflectionMain: "Today's Insight",
              reflectionMiddle: text,
              awarenessTitle: currentStatic.awarenessTitle,
              awarenessText: currentStatic.awarenessText,
              bottomQuote: currentStatic.bottomQuote,
              finalLine: currentStatic.finalLine,
            );
          }
        } else {
          _insightViewed = false;
          _isCheckedIn = false;
          // Backend says insight is still locked
          if (dailyInsight['lock_reason'] != null) {
            final currentStatic = _dailyInsights[_currentDay ?? 1] ?? _dailyInsights.values.first;
            _dailyInsights[_currentDay ?? 1] = InsightData(
              lockedTitle: dailyInsight['lock_reason'].toString(),
              reflectionHeader: currentStatic.reflectionHeader,
              reflectionMain: currentStatic.reflectionMain,
              reflectionMiddle: currentStatic.reflectionMiddle,
              awarenessTitle: currentStatic.awarenessTitle,
              awarenessText: currentStatic.awarenessText,
              bottomQuote: currentStatic.bottomQuote,
              finalLine: currentStatic.finalLine,
            );
          }
        }
      }

      // ── Fallback removed: Always trust the backend insight response for unlock status ──

      // ── Completed reflections: user_total_completed from /reflections/today/status ──
      final rawCompleted = reflStatus?['user_total_completed'] ??
          reflStatus?['userTotalCompleted'] ??
          reflStatus?['total_completed'];
      _completedReflections = rawCompleted is int
          ? rawCompleted
          : int.tryParse(rawCompleted?.toString() ?? '') ?? 0;

      // ── Reflection completed today (exact field: user_completed) ──
      _reflectionCompletedToday = reflStatus?['userCompleted'] == true || reflStatus?['user_completed'] == true;

      // ── Partner completed today (exact field: partner_completed) ──
      _partnerCompletedToday = reflStatus?['partnerCompleted'] == true || reflStatus?['partner_completed'] == true;

      _isLoadingSeparation = false;

      // ── Connected Pill & Hero State ──
      if (homeHero != null) {
        _isPartnerConnected = homeHero['partner_connected'] == true ||
            homeHero['partnerConnected'] == true ||
            homeHero['is_partner_connected'] == true;
        _hasPastRelationship = homeHero['has_past_relationship'] == true;
        _hasCompletedSeparation = homeHero['has_completed_separation'] == true || homeHero['hasCompletedSeparation'] == true;
        _hasAcknowledgedCompletion = homeHero['has_acknowledged_completion'] == true || homeHero['hasAcknowledgedCompletion'] == true;
      } else {
        // Fall back to cached connection state if API fails
        _isPartnerConnected = profileData != null 
            ? (profileData['data'] ?? profileData)['isPartnerConnected'] == true
            : cachedIsConnected;
        _hasCompletedSeparation = false;
      }

      // ── When journey is completed (e.g. via Time Travel), immediately unlock final
      // insights for both partners — don't wait for a mood check-in.
      if (_hasCompletedSeparation) {
        _isCheckedIn = true;
      }

      if (_isPartnerConnected) {
        final bool bannerShown = prefs.getBool('partner_connected_banner_shown') ?? false;
        if (!bannerShown) {
          _showConnectedPill = true;
          prefs.setBool('partner_connected_banner_shown', true);
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) setState(() => _showConnectedPill = false);
          });
        } else {
          _showConnectedPill = false;
        }
      } else {
        _showConnectedPill = false;
        prefs.setBool('partner_connected_banner_shown', false);
        
        final isWaiting = homeHero?['is_waiting_for_partner'] == true || homeHero?['isWaitingForPartner'] == true;
        
        // If widget said we are waiting, keep it true for this session, otherwise use backend.
        _localIsWaitingForPartner = widget.isWaitingForPartner || isWaiting;

        // If the backend says we're completely disconnected and not waiting, clear partner state
        if (!_localIsWaitingForPartner) {
          if (cachedPartnerName != null) {
            prefs.remove('partner_name');
          }
          _partnerName = null;
        }
      }

      // Only assign if it's actually active, otherwise let it be null so waiting pill stays hidden
      _activeSeparation = isSepActive ? sep : null;

      // Hero is empty if there are no hero values and no active separation
      _isHeroEmpty = !hasHeroData && !isSepActive;

      // ── Shared Presence: play animation every time backend says both are active ──
      final bool presence = homeHero?['shared_presence'] == true;
      _sharedPresence = presence;
    });
  }

  String _formatStartDate(dynamic startDateStr) {
    if (startDateStr == null) return 'Taking time to understand more';
    try {
      final dt = DateTime.parse(startDateStr.toString());
      return 'Began on ${DateFormat('MMM d, yyyy').format(dt)}';
    } catch (_) {
      return 'Began: $startDateStr';
    }
  }

  final Map<int, InsightData> _dailyInsights = {
    1: const InsightData(
      lockedTitle: "There’s something we noticed about you…",
      reflectionMain: "You're beginning to open up.",
      reflectionMiddle: "Your first steps show a willingness to explore what's hidden. This curiosity is the foundation of growth.",
      awarenessText: "Observe your thoughts today without trying to change them.",
      bottomQuote: "Growth begins where comfort ends.",
      finalLine: "Every small awareness counts.",
    ),
    2: const InsightData(
      lockedTitle: "You might be repeating something without noticing…",
      reflectionMain: "Patterns are becoming visible.",
      reflectionMiddle: "Some reactions seem automatic. They might be old survival strategies that you don't need anymore.",
      awarenessText: "Notice if you react the same way to different situations today.",
      bottomQuote: "Breaking the cycle starts with seeing it.",
      finalLine: "Consciousness is the first step to freedom.",
    ),
    3: const InsightData(
      lockedTitle: "Something about how you feel is becoming clearer…",
      reflectionMain: "Clarity is emerging.",
      reflectionMiddle: "The fog is lifting. You're starting to name emotions that were previously just 'noise'.",
      awarenessText: "Try to put a specific name to your strongest feeling today.",
      bottomQuote: "To name it is to tame it.",
      finalLine: "Clarity comes in waves, stay with it.",
    ),
    4: const InsightData(
      lockedTitle: "There’s a pattern in what hurts you…",
      reflectionMain: "You care deeply, but struggle to express it in the moment.",
      reflectionMiddle: "In moments that matter most, you often hold things inside. This can create distance — even when you don't want it to.",
      awarenessText: "Next time, try noticing this moment before it builds up.",
      bottomQuote: "This is not a flaw... it's something you can gently work on.",
      finalLine: "Sometimes, what we don't notice... shapes everything.",
    ),
    5: const InsightData(
      lockedTitle: "You’re starting to see something differently…",
      reflectionMain: "Perspective is shifting.",
      reflectionMiddle: "You're seeing their actions through a lens of empathy rather than just reaction.",
      awarenessText: "Pause before assuming intent in a difficult interaction.",
      bottomQuote: "Compassion is a choice we make every day.",
      finalLine: "New eyes see new worlds.",
    ),
    6: const InsightData(
      lockedTitle: "There’s a shift happening in you…",
      reflectionMain: "Internal transformation.",
      reflectionMiddle: "The way you hold space for yourself is changing. You're becoming your own safe harbor.",
      awarenessText: "Treat yourself with the same kindness you'd offer a dear friend.",
      bottomQuote: "The relationship with yourself sets the tone for all others.",
      finalLine: "You are your own most important connection.",
    ),
    7: const InsightData(
      lockedTitle: "We’ve understood something important about your relationship…",
      reflectionMain: "Your pattern summary",
      reflectionMiddle: "Over the last week, we've seen you move from avoidance to awareness. You are learning that your silence is often a shield, but your words are the bridge.",
      awarenessText: "What would happen if you shared your biggest fear today?",
      bottomQuote: "Vulnerability is the only bridge to true intimacy.",
      finalLine: "You've completed your first week of reflection.",
    ),
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090204),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: _currentIndex == 1
                  ? FeelScreen(
                      onReturnHome: () {
                        setState(() {
                          _currentIndex = 0;
                          _isCheckedIn = true;
                        });
                        _fetchDashboardData();
                      },
                      insightText: (_isCheckedIn && !_insightViewed) ? (_dailyInsights[_currentDay]?.reflectionMiddle ?? _dailyInsights.values.first.reflectionMiddle) : null,
                      awarenessText: (_isCheckedIn && !_insightViewed) ? (_dailyInsights[_currentDay]?.awarenessText ?? _dailyInsights.values.first.awarenessText) : null,
                      bottomQuote: (_isCheckedIn && !_insightViewed) ? (_dailyInsights[_currentDay]?.bottomQuote ?? _dailyInsights.values.first.bottomQuote) : null,
                      finalLine: (_isCheckedIn && !_insightViewed) ? (_dailyInsights[_currentDay]?.finalLine ?? _dailyInsights.values.first.finalLine) : null,
                      onInsightViewed: () {
                        setState(() { _insightViewed = true; });
                        ApiService.markInsightViewed();
                      },
                    )
                  : _currentIndex == 2
                      ? LettersScreen(separationId: _activeSeparation?['relationship_id'] ?? _activeSeparation?['relationshipId'])
                      : _currentIndex == 3
                          ? JourneyScreen(
                              userName: _currentUserName,
                              partnerName: _partnerName,
                              isWaitingForPartner: _localIsWaitingForPartner,
                            )
                          : _currentIndex == 4
                              ? ProfileScreen(
                                  userName: _currentUserName,
                                  partnerName: _partnerName,
                                  onProfileUpdated: _fetchDashboardData,
                                )
                              : _isLoadingSeparation
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFDD8F9F),
                                      ),
                                    )
                                  : SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0), // Padding to clear navbar
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── Header ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _DashboardAnimatedGreeting(userName: _currentUserName),
                          Row(
                            children: [
                              if (_sharedPresence)
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: _sharedPresence ? 1.0 : 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ADE80),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF4ADE80).withOpacity(0.4),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_partnerName ?? "Partner"} Online',
                                          style: const TextStyle(
                                            color: Color(0xFFDD8F9F),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              _PresencePulseHeart(
                                key: const ValueKey('presence_heart'),
                                triggerPulse: _sharedPresence,
                                unreadCount: _unreadCount,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Active Separation Card (HERO) ──
                      // Priority order:
                      // 1. No partner, not waiting         → UnconnectedHeroCard (create/join)
                      // 2. No partner, WAITING for partner → UnconnectedHeroCard (waiting state)
                      // 3. Journey completed, unacknowledged → completion card
                      // 4. Journey completed, acknowledged → PostJourneySanctuary
                      // 5. Hero empty (no data)            → empty card
                      // 6. Active separation + partner joined → LivingJourneyCard
                      if (_isHeroEmpty && !_isPartnerConnected && !_localIsWaitingForPartner && !(_activeSeparation != null && (_activeSeparation!['is_active'] == true || _activeSeparation!['isActive'] == true || _activeSeparation!['status'] == 'active')))
                        UnconnectedHeroCard(
                          isWaitingState: false,
                          onCreateInvite: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartnerInviteScreen(
                                  userName: _currentUserName,
                                  partnerName: 'Your Partner',
                                  fromDashboard: true,
                                ),
                              ),
                            );
                          },
                          onJoinInvite: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const JoinWithCodeScreen(fromDashboard: true)),
                            );
                          },
                        )
                      // ── WAITING FOR PARTNER: separation created, partner not yet joined ──
                      else if (!_isPartnerConnected && _localIsWaitingForPartner)
                        UnconnectedHeroCard(
                          isWaitingState: true,
                          onCreateInvite: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartnerInviteScreen(
                                  userName: _currentUserName,
                                  partnerName: 'Your Partner',
                                  fromDashboard: true,
                                ),
                              ),
                            );
                          },
                          onJoinInvite: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const JoinWithCodeScreen(fromDashboard: true)),
                            );
                          },
                        )
                      else if (_isHeroEmpty && _hasCompletedSeparation && !_hasAcknowledgedCompletion)
                        LivingJourneyCard(
                          currentDay: _totalDays ?? 21,
                          totalDays: _totalDays ?? 21,
                          moodPhrase: 'You did it!',
                          statusLine: 'Congratulations, your journey is complete!',
                          isEmpty: false,
                          isCompleted: true,
                          partnerName: _partnerName,
                          onClose: () => _acknowledgeCompletion(),
                        )
                      else if (_isHeroEmpty && _hasCompletedSeparation && _hasAcknowledgedCompletion)
                        PostJourneySanctuaryCard(
                          partnerName: _partnerName ?? 'your partner',
                          onBeginNewJourney: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SeparationStep1IntentionScreen()),
                            );
                          },
                          onSharedMemories: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            );
                          },
                        )
                      // Scenario 2: Partner connected, no active separation yet
                      else if (_isHeroEmpty)
                        ConnectedReadyHeroCard(
                          partnerName: _partnerName ?? 'your partner',
                          onBeginSeparation: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SeparationStep1IntentionScreen()),
                            );
                          },
                          onSharedMemories: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            );
                          },
                        )
                      else if (_activeSeparation != null || (_currentDay ?? 0) > 0)
                        LivingJourneyCard(
                          currentDay: _currentDay ?? 1,
                          totalDays: _totalDays ?? 21,
                          moodPhrase: _moodPhrase ?? '',
                          partnerName: _partnerName,
                          statusLine: (_completedReflections ?? 0) > 0
                              ? '$_completedReflections of $_totalDays reflections done'
                              : _formatStartDate(
                                  _activeSeparation?['start_date'] ??
                                  _activeSeparation?['startDate'] ?? DateTime.now().toIso8601String()),
                        )
                      else
                        const SizedBox.shrink(),

                      const SizedBox(height: 28),

                      if (_showConnectedPill)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: _showConnectedPill ? 1.0 : 0.0,
                          child: Center(
                            child: _ShimmeringConnectedPill(partnerName: _partnerName ?? 'your partner'),
                          ),
                        ),

                      const SizedBox(height: 36),

                      // ── Magical Emotional Sanctuary ──
                      LivingSanctuarySection(
                        isActiveSeparation: _activeSeparation != null && 
                            (_activeSeparation!['is_active'] == true || 
                             _activeSeparation!['isActive'] == true || 
                             _activeSeparation!['status'] == 'active'),
                      ),

                      const SizedBox(height: 36),

                      // ── Insight Card ──
                      _InsightCard(
                        day: _currentDay ?? 1,
                        insight: _dailyInsights[_currentDay ?? 1] ?? _dailyInsights.values.first,
                        isCheckedIn: _isCheckedIn,
                        isViewed: _insightViewed,
                        onTap: () {
                          if (_isCheckedIn) {
                            setState(() {
                              _currentIndex = 1;
                            });
                          }
                        },
                        onLockedTap: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Sit with your feelings Button ──
                      GestureDetector(
                        onTap: _reflectionCompletedToday
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You have already completed today\'s reflection.', style: TextStyle(color: Colors.white)),
                                    backgroundColor: Color(0xFF8A2E55),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReflectionFlowScreen(day: _currentDay ?? 1),
                                  ),
                                ).then((completed) {
                                  if (completed == true) {
                                    setState(() {
                                      _reflectionCompletedToday = true;
                                    });
                                    _fetchDashboardData();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ReflectionCompletionScreen(),
                                      ),
                                    );
                                  }
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: _reflectionCompletedToday
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFF3F0B1E), Color(0xFF1A0A10)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: _reflectionCompletedToday ? const Color(0xFF14080D) : null,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: _reflectionCompletedToday 
                                  ? const Color(0xFF3D1F2B) 
                                  : const Color(0xFF911746).withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: _reflectionCompletedToday
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF911746).withOpacity(0.15),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                          ),
                          child: Stack(
                            children: [
                              // Subtle inner glow
                              if (!_reflectionCompletedToday)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      gradient: RadialGradient(
                                        center: const Alignment(-0.6, -0.4),
                                        radius: 1.2,
                                        colors: [
                                          const Color(0xFFDD8F9F).withOpacity(0.08),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _reflectionCompletedToday ? Icons.check_circle : Icons.favorite,
                                      size: 18,
                                      color: _reflectionCompletedToday ? const Color(0xFF5A3C47) : const Color(0xFFDD8F9F),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      _reflectionCompletedToday
                                          ? 'See you tomorrow'
                                          : _isMissedDayFlow
                                              ? 'Continue Day ${_currentDay ?? 1}'
                                              : 'Sit with your feelings',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 0.3,
                                        color: _reflectionCompletedToday ? const Color(0xFF5A3C47) : const Color(0xFFDD8F9F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ── Premium Glassmorphic Bottom Navigation Bar ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PremiumNavBar(
                currentIndex: _currentIndex,
                onTabSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                hasNewInsight: _isCheckedIn && !_insightViewed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF241016),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF6E3A4B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26151B)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = const Color(0xFF8A2E55)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * (4 / 21),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeDashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D1627)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _createDashedPath(path, 8, 6);
    
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashSpace) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = math.min(dashLength, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + length), Offset.zero);
        distance += dashLength + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InsightData {
  final String lockedTitle;
  final String reflectionHeader;
  final String reflectionMain;
  final String reflectionMiddle;
  final String awarenessTitle;
  final String awarenessText;
  final String bottomQuote;
  final String finalLine;

  const InsightData({
    required this.lockedTitle,
    this.reflectionHeader = "A SMALL REFLECTION FOR YOU",
    required this.reflectionMain,
    required this.reflectionMiddle,
    this.awarenessTitle = "GENTLE AWARENESS",
    required this.awarenessText,
    required this.bottomQuote,
    required this.finalLine,
  });
}

class _InsightCard extends StatelessWidget {
  final int day;
  final InsightData insight;
  final bool isCheckedIn;
  final bool isViewed;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;

  const _InsightCard({
    required this.day,
    required this.insight,
    required this.isCheckedIn,
    required this.isViewed,
    required this.onTap,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCheckedIn) {
      return GestureDetector(
        onTap: onLockedTap,
        child: CustomPaint(
          painter: _HomeDashedBorderPainter(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3D1627).withOpacity(0.3),
                  ),
                  child: const Icon(Icons.lock, color: Color(0xFF5A3C47), size: 20),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${insight.lockedTitle}"',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF5A3C47),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF9E7E5A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Unlock after today’s check-in',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E7E5A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isViewed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0B12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3D1627), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ Today\'s Insight Unlocked',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDD8F9F),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You\'ve already explored today\'s insight.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFF866571),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Unlocked but not viewed state
    return GestureDetector(
      onTap: onTap,
      child: PremiumSheen(
        animationDuration: const Duration(milliseconds: 1800),
        pauseDuration: const Duration(seconds: 4),
        sheenOpacity: 0.15,
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1214),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF9E7E5A).withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9E7E5A).withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF322315).withOpacity(0.4),
                border: Border.all(color: const Color(0xFF9E7E5A).withOpacity(0.3)),
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E7E5A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR INSIGHT IS READY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '"Tap to see what we noticed about you"',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF9E7E5A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261A1C),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3D242E)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Read now',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Georgia',
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14, color: Color(0xFF9E7E5A)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}


class _DreamHouseEntryCardWidget extends StatefulWidget {
  final int currentDay;
  final String userName;
  final String? partnerName;

  const _DreamHouseEntryCardWidget({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.userName,
    this.partnerName,
  });

  final int totalDays;

  @override
  State<_DreamHouseEntryCardWidget> createState() => _DreamHouseEntryCardWidgetState();
}

class _DreamHouseEntryCardWidgetState extends State<_DreamHouseEntryCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _buttonScaleController;

  @override
  void initState() {
    super.initState();
    // Gentle vertical hover breathing motion
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutQuad,
      ),
    );

    // Warm lantern window breathing glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Bouncy scale controller for interactive buttons
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine dynamic emotional copy and CTAs based on currentDay
    String titleText;
    String subtitleText;
    String ctaText;
    IconData ctaIcon;

    if (widget.currentDay == 7) {
      titleText = "Your home is ready 🏡";
      subtitleText = "A tiny surprise is glowing inside your home.";
      ctaText = "Enter Home";
      ctaIcon = Icons.home_rounded;
    } else if (widget.currentDay % 2 == 0) {
      titleText = "Someone added a little feeling to your home ✨";
      subtitleText = "There’s something waiting for you 🥺";
      ctaText = "See What Changed";
      ctaIcon = Icons.mail_outline_rounded;
    } else if (widget.currentDay == 1) {
      titleText = "Build your dream home together ✨";
      subtitleText = "7 days • tiny moments • shared future";
      ctaText = "Step Inside";
      ctaIcon = Icons.auto_awesome;
    } else {
      titleText = "Waiting for your partner’s touch ✨";
      subtitleText = "Your living room feels warmer today.";
      ctaText = "Continue Building";
      ctaIcon = Icons.brush_outlined;
    }

    // Determine partner avatar active pulse state
    final bool isPartnerActive = (widget.currentDay % 2 == 0);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        // Large rounded card with ultra soft corners (32px) and premium twilight Dark Ghibli Gradient
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1D0E16), // Very deep warm burgundy-violet
              Color(0xFF140A10), // Sleek midnight plum
              Color(0xFF1E0E12), // Deep velvet night glow
              Color(0xFF2A1522), // Soft glowing twilight plum
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB5456E).withOpacity(0.08), // Soft glowing pinkish glow
              blurRadius: 36,
              spreadRadius: -2,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFFFFB85C).withOpacity(0.06), // Cozy warm golden light glow
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFFD59A).withOpacity(0.15),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.22),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. TOP ROW: Progress Badge & Partner Avatars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Left: Soft glowing Day Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1A22), // Translucent deep rose
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFB85C).withOpacity(0.35),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFCC66).withOpacity(0.08),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: Color(0xFFFFD573),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "DAY CO-CREATION",
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Color(0xFFFFD573),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Top Right: Avatars & Pulses
                      _PartnerAvatarsWidget(
                        pulse: _pulseAnimation.value,
                        isPartnerActive: isPartnerActive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // B. ROW BODY: Dynamic Ghibli Evolving Cottage & Emotional copy
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Dynamic Cottage Center Visual Preview
                      SizedBox(
                        width: 106,
                        height: 106,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return _DreamHouseVisualWidget(
                              pulseValue: _pulseAnimation.value,
                              currentDay: widget.currentDay,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 2. Emotional Copy & Capsule CTA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Soft floating "Day X of Total" header text
                            Text(
                              "Day ${widget.currentDay} of ${widget.totalDays} • Home Haven",
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Color(0xFFDCC8B8),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Dynamic Title State
                            Text(
                              titleText,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Dynamic Subtitle State
                            Text(
                              subtitleText,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFFFA8B8),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Floating Capsule CTA Button
                            GestureDetector(
                              onTapDown: (_) => _buttonScaleController.reverse(),
                              onTapUp: (_) {
                                _buttonScaleController.forward();
                                // Enter Dream House World
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DreamHouseWorldScreen(
                                      userName: widget.userName,
                                      partnerName: widget.partnerName ?? "Partner",
                                    ),
                                  ),
                                );
                              },
                              onTapCancel: () => _buttonScaleController.forward(),
                              child: ScaleTransition(
                                scale: _buttonScaleController,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8A334E),
                                        Color(0xFFB5456E),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB5456E).withOpacity(0.25),
                                        blurRadius: 12,
                                        spreadRadius: -1,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFFFD28E).withOpacity(0.55),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        ctaIcon,
                                        size: 11,
                                        color: const Color(0xFFFFECCC),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        ctaText,
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFFFFECCC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // C. Minimal Elegant Footer Stats
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFD59A).withOpacity(0.08),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FooterStatItem(
                          icon: Icons.mail_outline_rounded,
                          label: "Notes exchanged",
                          value: "12",
                        ),
                        _FooterStatItem(
                          icon: Icons.auto_awesome,
                          label: "Memories added",
                          value: "5",
                        ),
                        _FooterStatItem(
                          icon: Icons.favorite_border_rounded,
                          label: "Reactions today",
                          value: "3",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnerAvatarsWidget extends StatefulWidget {
  final double pulse;
  final bool isPartnerActive;

  const _PartnerAvatarsWidget({
    required this.pulse,
    required this.isPartnerActive,
  });

  @override
  State<_PartnerAvatarsWidget> createState() => _PartnerAvatarsWidgetState();
}

class _PartnerAvatarsWidgetState extends State<_PartnerAvatarsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    // Heart particles drift animation
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Avatar (User)
          Positioned(
            left: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A334E), Color(0xFF6B2238)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFFFD59A),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "P",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFECCC),
                  ),
                ),
              ),
            ),
          ),

          // Right Avatar (Partner) with pulsing halo and particles
          Positioned(
            left: 20,
            child: AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Glowing Pulse Halo
                    if (widget.isPartnerActive)
                      Positioned(
                        left: -4,
                        top: -4,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF8E7A).withOpacity((1.2 - widget.pulse).clamp(0.0, 1.0)),
                              width: 1.5 + (widget.pulse * 2.0),
                            ),
                          ),
                        ),
                      ),

                    // Partner Avatar Base
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB5456E), Color(0xFF8A334E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: widget.isPartnerActive
                              ? const Color(0xFFFFB85C)
                              : const Color(0xFFFFD59A),
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (widget.isPartnerActive)
                            BoxShadow(
                              color: const Color(0xFFFF8E7A).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "N",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFECCC),
                          ),
                        ),
                      ),
                    ),

                    // Tiny Floating Hearts
                    if (widget.isPartnerActive)
                      Positioned(
                        right: -10,
                        top: -12 - (10 * _heartController.value),
                        child: Opacity(
                          opacity: (1.0 - _heartController.value).clamp(0.0, 1.0),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 10,
                            color: Color(0xFFFF5C75),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FooterStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color: const Color(0xFFFFA8B8),
        ),
        const SizedBox(width: 4),
        Text(
          "$value ",
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFF0EC),
          ),
        ),
        Text(
          label.split(' ')[0], // Keep it minimal e.g. "Notes"
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFFC5A8B4),
          ),
        ),
      ],
    );
  }
}

class _DreamHouseVisualWidget extends StatefulWidget {
  final double pulseValue;
  final int currentDay;

  const _DreamHouseVisualWidget({
    required this.pulseValue,
    required this.currentDay,
  });

  @override
  State<_DreamHouseVisualWidget> createState() => _DreamHouseVisualWidgetState();
}

class _DreamHouseVisualWidgetState extends State<_DreamHouseVisualWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _chimneyController;

  @override
  void initState() {
    super.initState();
    // ongoing chimney smoke particle system animation
    _chimneyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _chimneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chimneyController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GhibliDreamHousePainter(
            progress: _chimneyController.value,
            pulse: widget.pulseValue,
            currentDay: widget.currentDay,
          ),
        );
      },
    );
  }
}

class _GhibliDreamHousePainter extends CustomPainter {
  final double progress;
  final double pulse;
  final int currentDay;

  _GhibliDreamHousePainter({
    required this.progress,
    required this.pulse,
    required this.currentDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw glowing outer dual progress ring
    final double dayProgress = (currentDay / 7.0).clamp(0.0, 1.0);

    // A. Base ring (soft warm background circle)
    final basePaint = Paint()
      ..color = const Color(0xFFC4A297).withOpacity(0.18)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 2, basePaint);

    // B. Progress outer glow ring (cozy gold glow)
    final glowPaint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - 2);
    glowPaint.shader = const LinearGradient(
      colors: [Color(0xFFB5456E), Color(0xFFFFB85C)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(rect);

    // Draw blurred backing bloom
    canvas.save();
    glowPaint.color = const Color(0xFFFFB85C).withOpacity(0.15 * pulse);
    glowPaint.imageFilter = ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0, tileMode: TileMode.decal);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * dayProgress,
      false,
      glowPaint,
    );
    canvas.restore();

    // Draw sharp solid foreground progress arc
    final progressPaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    progressPaint.shader = const LinearGradient(
      colors: [Color(0xFFE27C94), Color(0xFFFFB85C)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(rect);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * dayProgress,
      false,
      progressPaint,
    );

    // C. Draw a beautiful tiny sparkling star at the tip of the progress arc
    final double endAngle = -math.pi / 2 + (math.pi * 2 * dayProgress);
    final Offset tipOffset = Offset(
      center.dx + (radius - 2) * math.cos(endAngle),
      center.dy + (radius - 2) * math.sin(endAngle),
    );
    _drawSparklingStar(canvas, tipOffset, 4.0, const Color(0xFFFFCA28));
    _drawSparklingStar(canvas, tipOffset, 2.0, Colors.white);

    // 2. Draw Decorative Elements (Cute golden crescent moon in top-left)
    final Offset moonCenter = Offset(center.dx - radius * 0.46, center.dy - radius * 0.46);
    _drawCrescentMoon(canvas, moonCenter, 7.0, const Color(0xFFFFB85C).withOpacity(0.85));

    // 3. Coordinate translation for cottage at the bottom center of the circle
    canvas.save();
    canvas.translate(center.dx, center.dy + radius * 0.42);

    // A. Cobblestones pathway base
    final stonePaint = Paint()..color = const Color(0xFF8C7369).withOpacity(0.24);
    canvas.drawOval(const Rect.fromLTWH(-20, 0, 40, 7), stonePaint);
    canvas.drawOval(const Rect.fromLTWH(-12, 5, 24, 4), stonePaint);

    // B. Day 1: Arched Entrance Door (Always visible)
    final doorFramePaint = Paint()..color = const Color(0xFF6B443B);
    final doorPaint = Paint()..color = const Color(0xFFB8785E);

    final doorPath = Path()
      ..moveTo(-8, 0)
      ..lineTo(-8, -16)
      ..arcToPoint(const Offset(8, -16), radius: const Radius.circular(8))
      ..lineTo(8, 0)
      ..close();
    canvas.drawPath(doorPath, doorFramePaint);

    final innerDoorPath = Path()
      ..moveTo(-6, 0)
      ..lineTo(-6, -15)
      ..arcToPoint(const Offset(6, -15), radius: const Radius.circular(6))
      ..lineTo(6, 0)
      ..close();
    canvas.drawPath(innerDoorPath, doorPaint);

    // Door knob
    canvas.drawCircle(const Offset(3.5, -7.5), 0.8, Paint()..color = const Color(0xFFFFCA28));

    // Porch light glow always lit
    final porchLightGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD991).withOpacity(0.7 * pulse),
          const Color(0xFFFFB85C).withOpacity(0.15 * pulse),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: const Offset(0, -22), radius: 12));
    canvas.drawCircle(const Offset(0, -22), 12, porchLightGlow);
    canvas.drawCircle(const Offset(0, -22), 2.5, Paint()..color = const Color(0xFFFFD991));

    // C. Day 2+: Living Room Window (Left Ground window)
    if (currentDay >= 2) {
      final wallPaint = Paint()..color = const Color(0xFFDCC8B8);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -26, 20, 26), const Radius.circular(3)), wallPaint);

      final windowFrame = Paint()..color = const Color(0xFF53302B)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      final windowBg = Paint()
        ..color = const Color(0xFFFFEFA6).withOpacity(0.55 + 0.3 * math.sin(pulse * math.pi));
      final windowRect = const Rect.fromLTWH(-28, -20, 12, 14);

      // Radial living room lamp glow
      final roomGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE082).withOpacity(0.8 * pulse),
            const Color(0xFFFFB300).withOpacity(0.15 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(-22, -13), radius: 8));

      canvas.drawRect(windowRect, windowBg);
      canvas.drawCircle(const Offset(-22, -13), 8, roomGlow);
      canvas.drawRect(windowRect, windowFrame);
      canvas.drawLine(const Offset(-22, -20), const Offset(-22, -6), windowFrame);
      canvas.drawLine(const Offset(-28, -13), const Offset(-16, -13), windowFrame);
    }

    // D. Day 3+: Kitchen Window (Right Ground window)
    if (currentDay >= 3) {
      final wallPaint = Paint()..color = const Color(0xFFDCC8B8);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(12, -26, 20, 26), const Radius.circular(3)), wallPaint);

      final windowFrame = Paint()..color = const Color(0xFF53302B)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      final windowBg = Paint()
        ..color = const Color(0xFFFFDF7D).withOpacity(0.55 + 0.35 * math.sin(pulse * math.pi + 1.0));
      final windowRect = const Rect.fromLTWH(16, -20, 12, 14);

      // Warm orange kitchen hearth firelit glow
      final stoveGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF7043).withOpacity(0.75 * pulse),
            const Color(0xFFFFB300).withOpacity(0.15 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(22, -13), radius: 7));

      canvas.drawRect(windowRect, windowBg);
      canvas.drawCircle(const Offset(22, -13), 7, stoveGlow);
      canvas.drawRect(windowRect, windowFrame);
      canvas.drawLine(const Offset(22, -20), const Offset(22, -6), windowFrame);
      canvas.drawLine(const Offset(16, -13), const Offset(28, -13), windowFrame);
    }

    // E. Day 4+: Upstairs Bedroom Glow (First Floor Structure)
    if (currentDay >= 4) {
      final wallPaint = Paint()..color = const Color(0xFFD6C5BC);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-24, -50, 48, 24), const Radius.circular(2)), wallPaint);

      final roofPath = Path()
        ..moveTo(-30, -50)
        ..lineTo(0, -68)
        ..lineTo(30, -50)
        ..close();
      final roofPaint = Paint()..color = const Color(0xFF7A4E46);
      canvas.drawPath(roofPath, roofPaint);

      // Window glow
      final windowBg = Paint()..color = const Color(0xFFFFECA3).withOpacity(0.65 * pulse);
      final winPath = Path()
        ..moveTo(-8, -34)
        ..lineTo(-8, -44)
        ..arcToPoint(const Offset(8, -44), radius: const Radius.circular(8))
        ..lineTo(8, -34)
        ..close();
      canvas.drawPath(winPath, windowBg);

      // Translucent waving Ghibli curtains
      final curtainPaint = Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.fill;
      final leftCurtain = Path()
        ..moveTo(-8, -44)
        ..cubicTo(-8, -40, -4, -38, -6, -34)
        ..lineTo(-8, -34)
        ..close();
      final rightCurtain = Path()
        ..moveTo(8, -44)
        ..cubicTo(8, -40, 4, -38, 6, -34)
        ..lineTo(8, -34)
        ..close();
      canvas.drawPath(leftCurtain, curtainPaint);
      canvas.drawPath(rightCurtain, curtainPaint);

      final windowFrame = Paint()..color = const Color(0xFF53302B)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawPath(winPath, windowFrame);
      canvas.drawLine(const Offset(0, -48), const Offset(0, -34), windowFrame);
    }

    // F. Day 5+: Personal Study Corner Window
    if (currentDay >= 5) {
      final chimneyPaint = Paint()..color = const Color(0xFF5A3C35);
      canvas.drawRect(const Rect.fromLTWH(18, -66, 6, 16), chimneyPaint);
      canvas.drawRect(const Rect.fromLTWH(17, -68, 8, 3), Paint()..color = const Color(0xFF3E2723));

      // Small upstairs reading window
      final windowBg = Paint()..color = const Color(0xFFFFF1C2).withOpacity(0.72 * pulse);
      final windowRect = const Rect.fromLTWH(14, -42, 8, 10);
      canvas.drawRect(windowRect, windowBg);

      // Desk lamp warm spot glow
      final lampGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD54F).withOpacity(0.85 * pulse),
            const Color(0xFFFFCA28).withOpacity(0.15 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(18, -37), radius: 5));
      canvas.drawCircle(const Offset(18, -37), 5, lampGlow);
      canvas.drawRect(windowRect, Paint()..color = const Color(0xFF53302B)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      // Draw chimney smoke stardust particles
      _drawChimneySmokeParticles(canvas, const Offset(21, -68));
    }

    // G. Day 6+: Balcony Garden
    if (currentDay >= 6) {
      final woodPaint = Paint()..color = const Color(0xFF8D6E63);
      canvas.drawRect(const Rect.fromLTWH(-18, -29, 36, 3), woodPaint);

      final railingPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 0.8;
      for (double x = -16; x <= 16; x += 4) {
        canvas.drawLine(Offset(x, -29), Offset(x, -24), railingPaint);
      }
      canvas.drawLine(const Offset(-18, -24), const Offset(18, -24), railingPaint);

      // Green leafy planter flowers
      final leafPaint = Paint()..color = const Color(0xFF388E3C);
      final bloomPaint = Paint()..color = const Color(0xFFEC407A);

      canvas.drawCircle(const Offset(-14, -27), 1.5, leafPaint);
      canvas.drawCircle(const Offset(-12, -26), 1.2, leafPaint);
      canvas.drawCircle(const Offset(-13, -28), 1.0, bloomPaint);

      canvas.drawCircle(const Offset(14, -27), 1.5, leafPaint);
      canvas.drawCircle(const Offset(12, -26), 1.2, leafPaint);
      canvas.drawCircle(const Offset(13, -28), 1.0, bloomPaint);
    }

    // H. Day 7: Glowing Garden Lantern overlay
    if (currentDay >= 7) {
      final gardenGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD54F).withOpacity(0.85 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(-24, 4), radius: 6));
      canvas.drawCircle(const Offset(-24, 4), 6, gardenGlow);
      canvas.drawCircle(const Offset(-24, 4), 1.5, Paint()..color = Colors.white);
    }

    // I. Partner surprise bubble gold glows and orbits (Active surprise state)
    if (currentDay % 2 == 0) {
      final Offset bubblePos = const Offset(-22, -13);
      // Golden halo glow
      final goldHalo = Paint()
        ..color = const Color(0xFFFFCA28).withOpacity(0.3 * pulse)
        ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2);
      canvas.drawCircle(bubblePos, 6.0, goldHalo);

      // Gold outline bubble
      final bubblePaint = Paint()
        ..color = const Color(0xFFFFCA28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(bubblePos, 4.0, bubblePaint);

      // Orbiting sparkle stars
      final double orbitAngle = progress * math.pi * 2;
      final Offset sparkleOffset = Offset(
        bubblePos.dx + 8 * math.cos(orbitAngle),
        bubblePos.dy + 8 * math.sin(orbitAngle),
      );
      _drawSparklingStar(canvas, sparkleOffset, 2.0, const Color(0xFFFFD54F));
    }

    // J. Ambient Floating Fireflies
    final fireflyPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final double t = (progress + (i * 0.2)) % 1.0;
      final double angle = t * math.pi * 2;
      final double dist = 26 + 10 * math.sin(angle * 2);
      final double fx = dist * math.cos(angle + i);
      final double fy = -25 + 14 * math.sin(angle) - (15 * t);

      final double alpha = (1.0 - t).clamp(0.0, 1.0);
      final double size = 1.0 + (1.2 * t);

      fireflyPaint.color = const Color(0xFFFFD97D).withOpacity(alpha * 0.85);
      canvas.drawCircle(Offset(fx, fy), size, fireflyPaint);
    }

    canvas.restore();
  }

  void _drawSparklingStar(Canvas canvas, Offset position, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(position.dx, position.dy - size)
      ..quadraticBezierTo(position.dx, position.dy, position.dx + size, position.dy)
      ..quadraticBezierTo(position.dx, position.dy, position.dx, position.dy + size)
      ..quadraticBezierTo(position.dx, position.dy, position.dx - size, position.dy)
      ..quadraticBezierTo(position.dx, position.dy, position.dx, position.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCrescentMoon(Canvas canvas, Offset pos, double size, Color color) {
    final moonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..addOval(Rect.fromCircle(center: pos, radius: size));

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(pos.dx + size * 0.45, pos.dy - size * 0.2), radius: size * 0.95));

    final crescentPath = Path.combine(PathOperation.difference, path, shadowPath);
    canvas.drawPath(crescentPath, moonPaint);
  }

  void _drawChimneySmokeParticles(Canvas canvas, Offset start) {
    for (int i = 0; i < 2; i++) {
      final double t = (progress + i / 2.0) % 1.0;
      final double x = start.dx + 12 * math.sin(t * math.pi * 1.5) + (t * 5);
      final double y = start.dy - (32 * t);

      final double alpha = (1.0 - t).clamp(0.0, 1.0);
      final double size = 2.0 + (4.0 * t);
      final Offset p = Offset(x, y);

      if (i == 0) {
        canvas.drawCircle(p, size * 0.5, Paint()..color = const Color(0xFFFFD571).withOpacity(alpha * 0.65));
      } else {
        _drawSparklingStar(canvas, p, size * 0.7, const Color(0xFFFFB88E).withOpacity(alpha * 0.7));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Live Connection Presence ──────────────────────────────────────────────────
class _LiveConnectionPresence extends StatefulWidget {
  final String partnerName;
  const _LiveConnectionPresence({required this.partnerName});

  @override
  State<_LiveConnectionPresence> createState() => _LiveConnectionPresenceState();
}

class _LiveConnectionPresenceState extends State<_LiveConnectionPresence>
    with TickerProviderStateMixin {
  bool _isConnected = false;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;

  int _textIndex = 0;
  late Timer _textTimer;
  final List<String> _connectedTexts = [
    "Your safe space is active",
    "Together in reflection",
    "Two hearts connected beautifully",
    "Your emotional journey continues",
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _textTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isConnected && mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _connectedTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _textIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleConnection,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _pulseController]),
        builder: (context, child) {
          final floatY = math.sin(_floatController.value * math.pi) * 6.0;
          final pulse = _pulseController.value;

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: _isConnected
                        ? const Color(0xFFCA366C).withOpacity(0.1 + 0.1 * pulse)
                        : const Color(0xFF911746).withOpacity(0.05 + 0.05 * pulse),
                    blurRadius: 20 + 10 * pulse,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isConnected
                            ? [
                                const Color(0xFF911746).withOpacity(0.2),
                                const Color(0xFFCA366C).withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ]
                            : [
                                const Color(0xFFCA366C).withOpacity(0.08),
                                const Color(0xFF911746).withOpacity(0.03),
                                Colors.white.withOpacity(0.02),
                              ],
                      ),
                      border: Border.all(
                        color: _isConnected
                            ? const Color(0xFFE89FB8).withOpacity(0.3)
                            : const Color(0xFFCA366C).withOpacity(0.15),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        // Left Side Visual
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ambient glow
                              Container(
                                width: 50 + 10 * pulse,
                                height: 50 + 10 * pulse,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isConnected
                                      ? const Color(0xFFCA366C).withOpacity(0.2)
                                      : const Color(0xFF911746).withOpacity(0.15),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 1200),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: _isConnected
                                    ? _ConnectedOrb(orbitController: _orbitController, pulse: pulse)
                                    : _WaitingHearts(orbitController: _orbitController, pulse: pulse),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Side Text
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: _isConnected
                                ? Column(
                                    key: const ValueKey('connected'),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Connected with ${widget.partnerName} ✨',
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 800),
                                        child: Text(
                                          _connectedTexts[_textIndex],
                                          key: ValueKey<int>(_textIndex),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color(0xFFE89FB8).withOpacity(0.9),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('waiting'),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFE89FB8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFE89FB8).withOpacity(0.6),
                                                  blurRadius: 4 + 2 * pulse,
                                                  spreadRadius: 1 * pulse,
                                                ),
                                              ],
                                            ),
                                            transform: Matrix4.identity()..scale(1.0 + 0.15 * pulse),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Waiting for ${widget.partnerName} to enter',
                                            style: const TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Your connection is gently forming ✨',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: const Color(0xFFF7D6E4).withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaitingHearts extends StatelessWidget {
  final AnimationController orbitController;
  final double pulse;

  const _WaitingHearts({required this.orbitController, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: orbitController,
      builder: (context, child) {
        final theta = orbitController.value * 2 * math.pi;
        final h1x = math.cos(theta) * 12;
        final h1y = math.sin(theta) * 12;
        final h2x = -math.cos(theta) * 12;
        final h2y = -math.sin(theta) * 12;

        return SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 32 + h1x - 12,
                top: 32 + h1y - 12,
                child: const Icon(
                  Icons.favorite,
                  size: 24,
                  color: Color(0xFFCA366C),
                  shadows: [
                    Shadow(color: Color(0xFFCA366C), blurRadius: 8),
                  ],
                ),
              ),
              Positioned(
                left: 32 + h2x - 12,
                top: 32 + h2y - 12,
                child: Opacity(
                  opacity: 0.5 + 0.3 * pulse,
                  child: Text(
                    String.fromCharCode(Icons.favorite.codePoint),
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: Icons.favorite.fontFamily,
                      package: Icons.favorite.fontPackage,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.5
                        ..color = const Color(0xFFE89FB8),
                      shadows: const [
                        Shadow(color: Color(0xFFE89FB8), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectedOrb extends StatelessWidget {
  final AnimationController orbitController;
  final double pulse;

  const _ConnectedOrb({required this.orbitController, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48 + 4 * pulse,
      height: 48 + 4 * pulse,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFE89FB8).withOpacity(0.8),
            const Color(0xFFCA366C).withOpacity(0.5),
            const Color(0xFF911746).withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCA366C).withOpacity(0.4),
            blurRadius: 12 + 6 * pulse,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: orbitController,
        builder: (context, child) {
          final theta = orbitController.value * 4 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(math.cos(theta) * 10, math.sin(theta) * 10),
                child: const Icon(Icons.favorite, size: 10, color: Colors.white),
              ),
              Transform.translate(
                offset: Offset(-math.cos(theta) * 10, -math.sin(theta) * 10),
                child: const Icon(Icons.favorite, size: 10, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Dashboard Animated Greeting ────────────────────────────────────────────────
class _DashboardAnimatedGreeting extends StatefulWidget {
  final String userName;
  const _DashboardAnimatedGreeting({required this.userName});

  @override
  State<_DashboardAnimatedGreeting> createState() => _DashboardAnimatedGreetingState();
}

class _DashboardAnimatedGreetingState extends State<_DashboardAnimatedGreeting>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Color(0xFF866571),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8A2E55).withValues(alpha: 0.05 + 0.05 * _pulseController.value),
                                blurRadius: 15 + 5 * _pulseController.value,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 24, // Reduced from 32
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE0D4D8), // Softer color
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.1 * _pulseController.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFB06E82), // Softer heart
                        size: 14, // Smaller heart
                        shadows: [
                          Shadow(
                            color: Color(0xFF8A2E55),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRESENCE PULSE HEART WIDGET
// Wraps the existing heart button. When triggerPulse=true it plays a 3-second
// ambient animation (scale + glow + particles) then returns to normal.
// No new UI elements; identical resting appearance to the original.
// ─────────────────────────────────────────────────────────────────────────────

class _PresencePulseHeart extends StatefulWidget {
  final bool triggerPulse;
  final int unreadCount;
  final VoidCallback onTap;

  const _PresencePulseHeart({
    super.key,
    required this.triggerPulse,
    this.unreadCount = 0,
    required this.onTap,
  });

  @override
  State<_PresencePulseHeart> createState() => _PresencePulseHeartState();
}

class _PresencePulseHeartState extends State<_PresencePulseHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Heart scale: 1.0 → 1.08 → 1.0
  late final Animation<double> _scaleAnim;
  // Ring glow: 1.0 → 1.6 → 1.0
  late final Animation<double> _glowAnim;
  // Particles: 0.0 → 1.0 (drives both position and opacity)
  late final Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 35),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    ]).animate(_ctrl);

    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 2.2).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 2.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 60),
    ]).animate(_ctrl);

    _particleAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.1, 0.85, curve: Curves.easeOut));

    if (widget.triggerPulse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.repeat(); // Loop infinitely
      });
    }
  }

  @override
  void didUpdateWidget(_PresencePulseHeart old) {
    super.didUpdateWidget(old);
    if (widget.triggerPulse && !old.triggerPulse) {
      _ctrl.repeat(); // Loop continuously while active
    } else if (!widget.triggerPulse && old.triggerPulse) {
      _ctrl.forward(); // Let the current cycle finish and stop
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            // Particles are painted BEHIND the heart button
            foregroundPainter: _PresenceParticlePainter(progress: _particleAnim.value),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Heart circle (same as original) ──
                Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF260D1A),
                      border: Border.all(
                        color: const Color(0xFF3D1627),
                        width: 1,
                      ),
                      boxShadow: _ctrl.value > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFF914660).withAlpha(
                                  (60 * (_glowAnim.value - 1.0)).clamp(0, 120).toInt(),
                                ),
                                blurRadius: 12 * (_glowAnim.value - 1.0).clamp(0, 1) + 4,
                                spreadRadius: 2 * (_glowAnim.value - 1.0).clamp(0, 1),
                              )
                            ]
                          : [],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFF914660),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // ── Notification badge (same as original) ──
                if (widget.unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF090204),
                        border: Border.all(
                          color: const Color(0xFFDD8F9F).withAlpha(204),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDD8F9F).withAlpha(51),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${widget.unreadCount}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD8F9F),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRESENCE PARTICLE PAINTER
// Draws 4 soft particles that drift outward and fade as progress goes 0→1.
// ─────────────────────────────────────────────────────────────────────────────

class _PresenceParticlePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _PresenceParticlePainter({required this.progress});

  static const List<_Particle> _particles = [
    _Particle(angle: -45, startRadius: 24, endRadius: 40, size: 2.5),
    _Particle(angle: 45,  startRadius: 24, endRadius: 44, size: 2.0),
    _Particle(angle: 135, startRadius: 24, endRadius: 38, size: 2.2),
    _Particle(angle: 200, startRadius: 24, endRadius: 42, size: 1.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (final p in _particles) {
      final rad = p.angle * (math.pi / 180);
      final r = p.startRadius + (p.endRadius - p.startRadius) * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final pos = center + Offset(math.cos(rad) * r, math.sin(rad) * r);

      final paint = Paint()
        ..color = const Color(0xFFDD8F9F).withAlpha((opacity * 180).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(pos, p.size * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(_PresenceParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double angle;
  final double startRadius;
  final double endRadius;
  final double size;
  const _Particle({
    required this.angle,
    required this.startRadius,
    required this.endRadius,
    required this.size,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMERING CONNECTED PILL
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmeringConnectedPill extends StatefulWidget {
  final String partnerName;
  const _ShimmeringConnectedPill({required this.partnerName});

  @override
  State<_ShimmeringConnectedPill> createState() => _ShimmeringConnectedPillState();
}

class _ShimmeringConnectedPillState extends State<_ShimmeringConnectedPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerValue = _controller.value;
        final pulse = math.sin(shimmerValue * math.pi * 2);

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B2E1D).withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.2 + 0.1 * pulse),
                blurRadius: 15 + 5 * pulse,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "${widget.partnerName} connected",
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Shimmer overlay
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: Offset(shimmerValue * 2.5 - 1.25, 0), 
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.6),
                            const Color(0xFF4CAF50).withOpacity(0.5),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.4, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
