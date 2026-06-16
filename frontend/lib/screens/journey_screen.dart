import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // For ImageFilter
import '../widgets/premium_sheen.dart';
import '../services/api_service.dart';
import '../services/app_event_bus.dart';
import 'package:flutter/foundation.dart';


class JourneyScreen extends StatefulWidget {
  final String userName;
  final String? partnerName;
  final bool isWaitingForPartner;

  const JourneyScreen({
    super.key,
    required this.userName,
    this.partnerName,
    this.isWaitingForPartner = false,
  });

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  String? _partnerName;
  Map<String, dynamic>? _journeyScore;
  Map<String, dynamic>? _journeyInsights;

  bool _isLastDay = false;
  bool _isInsightUnlocked = false;
  bool _isLoading = true;

  // Polls /journey/insights every 15 s while the vault is still locked.
  // This ensures that when the partner uses Time Travel (which marks the
  // separation as "completed" on the backend), this user's vault flips to
  // unlocked within 15 seconds — even though the widget is kept alive
  // inside the IndexedStack and initState() never re-runs.
  Timer? _refreshTimer;
  StreamSubscription<AppEvent>? _eventBusSubscription;

  @override
  void initState() {
    super.initState();
    _fetchJourneyData();
    _startRefreshTimer();

    // Instantly re-fetch when time-travel or partner connects — no waiting for timer
    _eventBusSubscription = AppEventBus().stream.listen((event) {
      if (!mounted) return;
      if (event == AppEvent.timeTravelCompleted ||
          event == AppEvent.partnerConnected ||
          event == AppEvent.heroDataChanged) {
        _fetchJourneyData();
      }
    });
  }

  @override
  void didUpdateWidget(JourneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Partner just joined (waiting state cleared) — re-fetch journey data
    // so the correct scores and vault state are shown immediately.
    if (oldWidget.isWaitingForPartner && !widget.isWaitingForPartner) {
      _fetchJourneyData();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _eventBusSubscription?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      // Stop polling once insights are unlocked — no need to keep hitting the API.
      if (_isInsightUnlocked) {
        _refreshTimer?.cancel();
        _refreshTimer = null;
        return;
      }
      // Don't re-fetch while the waiting state is active (no separation yet).
      if (widget.isWaitingForPartner) return;
      _fetchJourneyData();
    });
  }

  Future<void> _fetchJourneyData() async {
    try {
      final results = await Future.wait([
        ApiService.getJourneyScore().catchError((_) => <String, dynamic>{}),
        ApiService.getJourneyInsights().catchError((_) => <String, dynamic>{}),
        ApiService.getActiveSeparation().catchError((_) => <String, dynamic>{}),
      ]);

      final score = results[0];
      final insights = results[1];
      final sep = results[2];

      if (score != null && score.isNotEmpty) {
        debugPrint('Journey Score Response: $score');
        debugPrint('loveWord: ${score['loveWord']}');
        debugPrint('coupleScore: ${score['coupleScore']}');
        debugPrint('statusChips: ${score['statusChips']}');
      }

      final cachedPartnerName = await ApiService.getPartnerName();

      if (mounted) {
        setState(() {
          _journeyScore = score != null && score.isNotEmpty ? score : null;
          _journeyInsights = insights != null && insights.isNotEmpty ? insights : null;
          
          _partnerName = _journeyScore?['partnerName'] ?? sep?['partnerName'] ?? sep?['partner_name'] ?? cachedPartnerName;
          if (_partnerName != null && _partnerName!.trim().isEmpty) {
            _partnerName = null;
          }

          _isInsightUnlocked = _journeyInsights?['isUnlocked'] == true;
          _isLastDay = _journeyInsights?['daysRemaining'] == 0 || _isInsightUnlocked;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _unlockInsights() {
    setState(() {
      _isInsightUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090204),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFDD8F9F)),
        ),
      );
    }

    // ── Waiting for partner: show a distinct pending state ──
    if (widget.isWaitingForPartner) {
      return _buildWaitingForPartnerView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              const Text(
                'YOUR BOND',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF9E7E5A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.userName} & ${_partnerName ?? "Partner"}',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '“This is where you both are right now”',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
              const SizedBox(height: 32),

              // --- Bond Progress Card ---
              _BondProgressCard(
                emoji: _journeyScore?['emoji'] ?? '🌸',
                loveWord: _journeyScore?['loveWord'] ?? 'Growing',
                message: _journeyScore?['message'] ?? 'steadily',
                coupleScore: _journeyScore?['coupleScore'] ?? 0,
                myScore: _journeyScore?['myScore'] ?? 0,
                checkInsProgress: (_journeyScore?['checkInsProgress'] ?? 0.0).toDouble(),
                opennessProgress: (_journeyScore?['opennessProgress'] ?? 0.0).toDouble(),
                presenceProgress: (_journeyScore?['presenceProgress'] ?? 0.0).toDouble(),
              ),
              const SizedBox(height: 16),

              // --- Status Chips ---
              if (_journeyScore != null && _journeyScore!['statusChips'] != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: (_journeyScore!['statusChips'] as List).map<Widget>((chip) {
                    return _StatusChip(
                      label: chip.toString(),
                      bgColor: const Color(0xFF8A2E55).withOpacity(0.12),
                      textColor: const Color(0xFFDD8F9F),
                      borderColor: const Color(0xFF8A2E55).withOpacity(0.3),
                      isItalic: true,
                    );
                  }).toList(),
                )
              else
                Row(
                  children: [
                    _StatusChip(
                      label: 'Quietly growing',
                      bgColor: const Color(0xFF8A2E55).withOpacity(0.12),
                      textColor: const Color(0xFFDD8F9F),
                      borderColor: const Color(0xFF8A2E55).withOpacity(0.3),
                      isItalic: true,
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // --- Last Day Banner (Notification style) ---
              if (_isLastDay && !_isInsightUnlocked) ...[
                GestureDetector(
                  onTap: _unlockInsights, // Banner tap also unlocks
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1F0A13),
                          Color(0xFF110309),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF8A2E55).withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A2E55).withOpacity(0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Color(0xFFDD8F9F), size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Your insights are ready",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Something beautiful was noticed.",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFDD8F9F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- Locked Insights Vault ---
              _LockedInsightsVault(
                isLastDay: _isLastDay,
                isUnlocked: _isInsightUnlocked,
                daysRemaining: _journeyInsights?['daysRemaining'] ?? 99,
                insights: _journeyInsights?['insights'] as Map<String, dynamic>?,
                onUnlock: _unlockInsights,
                emoji: _journeyScore?['emoji'] ?? '🌸',
              ),
              
              const SizedBox(height: 16),

              // --- Bottom Quote ---
              const Center(
                child: Text(
                  '“You’re not the same as when you started… even if it feels quiet.”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF866571),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Final Line ---
              const Center(
                child: Text(
                  '“This connection still has space to grow”',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF5A3C47),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Waiting-for-partner view
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWaitingForPartnerView() {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header label
              const Text(
                'YOUR BOND',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF9E7E5A),
                ),
              ),
              const SizedBox(height: 8),
              // Title — no partner name yet
              Text(
                '${widget.userName} & …',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '"Waiting for your partner to join"',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
              const SizedBox(height: 40),

              // Pending invitation card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C0A11), Color(0xFF0D0206)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF3D1627).withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2E55).withValues(alpha: 0.08),
                      blurRadius: 32,
                      spreadRadius: -4,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8A2E55).withValues(alpha: 0.10),
                        border: Border.all(
                          color: const Color(0xFFDD8F9F).withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFDD8F9F),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Invitation Pending',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Body
                    const Text(
                      'Your journey space has been created. Share your invite code with your partner — once they join, this space will come alive for both of you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4C4CA),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A2E55).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8A2E55).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFDD8F9F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'WAITING FOR PARTNER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.6,
                              color: Color(0xFFDD8F9F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Reassuring note
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0206),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF26151B).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF866571),
                      size: 18,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Bond progress, reflections, and insights will appear here once your partner accepts the invitation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF866571),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedInsightsVault extends StatefulWidget {
  final bool isLastDay;
  final bool isUnlocked;
  final int daysRemaining;
  final Map<String, dynamic>? insights;
  final VoidCallback onUnlock;
  final String emoji;

  const _LockedInsightsVault({
    required this.isLastDay,
    required this.isUnlocked,
    required this.daysRemaining,
    this.insights,
    required this.onUnlock,
    this.emoji = '🌸',
  });

  @override
  State<_LockedInsightsVault> createState() => _LockedInsightsVaultState();
}

class _LockedInsightsVaultState extends State<_LockedInsightsVault> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _teaserController;
  int _currentTeaserIndex = 0;
  final List<String> _teasers = [
    "Something important is forming…",
    "Small steps create deep shifts…",
    "Your honest reflections are taking root…",
  ];

  late AnimationController _unlockController;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _shatterAnimation;
  late Animation<double> _blurLiftAnimation;
  
  // Staggered slide up animations for content
  late Animation<Offset> _slideSection1;
  late Animation<Offset> _slideSection2;
  late Animation<Offset> _slideSection3;
  late Animation<double> _fadeSection1;
  late Animation<double> _fadeSection2;
  late Animation<double> _fadeSection3;

  late Animation<double> _celebrationAnimation;

  bool _isAnimatingUnlock = false;
  bool _fullyUnlocked = false;

  @override
  void initState() {
    super.initState();
    _fullyUnlocked = widget.isUnlocked;

    // Pulse animation for the locked state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Teaser text crossfade
    _teaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Every 4 seconds
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentTeaserIndex = (_currentTeaserIndex + 1) % _teasers.length;
          });
          _teaserController.forward(from: 0.0);
        }
      });
    _teaserController.forward();

    // Master unlock sequence controller
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _fullyUnlocked = true;
          });
        }
      });

    // Sequence timing:
    // 0.0 - 0.2: Heartbeat 1 (Scale up)
    // 0.2 - 0.4: Heartbeat 2
    // 0.4 - 0.6: Lock shatter / fade out
    // 0.5 - 0.8: Blur lifting
    // 0.6 - 1.0: Staggered reveal of content
    
    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 20), // shrink away smoothly
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 40),
    ]).animate(_unlockController);

    _shatterAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _unlockController, curve: const Interval(0.4, 0.6, curve: Curves.easeOut)),
    );

    _blurLiftAnimation = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _unlockController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );

    final slideBegin = const Offset(0, 0.2);
    _slideSection1 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic)));
    _fadeSection1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.55, 0.75, curve: Curves.easeIn)));

    _slideSection2 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic)));
    _fadeSection2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.65, 0.85, curve: Curves.easeIn)));

    _slideSection3 = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.75, 0.95, curve: Curves.easeOutCubic)));
    _fadeSection3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.75, 0.95, curve: Curves.easeIn)));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _unlockController, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)));
  }

  @override
  void didUpdateWidget(_LockedInsightsVault oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked && !_isAnimatingUnlock && !_fullyUnlocked) {
      _startUnlockSequence();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _teaserController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  void _startUnlockSequence() {
    setState(() {
      _isAnimatingUnlock = true;
    });
    _pulseController.stop();
    _teaserController.stop();
    _unlockController.forward().then((_) {
      if (mounted) {
        _showInsightModal(context);
        setState(() {
          _fullyUnlocked = true;
        });
      }
    });
    
    // Call parent unlock if it wasn't triggered by parent
    if (!widget.isUnlocked) {
      widget.onUnlock();
    }
  }

  void _showInsightModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF090204),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F1629),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildUnlockedContent(isRevealing: false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fullyUnlocked) {
      return GestureDetector(
        onTap: () => _showInsightModal(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF160A0E),
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
          child: Column(
            children: [
               const Icon(Icons.lock_open_rounded, color: Color(0xFFD4C4CA), size: 36),
               const SizedBox(height: 16),
               const Text(
                 '✨ Insights Unlocked',
                 style: TextStyle(
                   fontFamily: 'Georgia',
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: Color(0xFFDD8F9F),
                 ),
               ),
               const SizedBox(height: 8),
               const Text(
                 'Tap to view what we noticed',
                 style: TextStyle(
                   fontSize: 14,
                   color: Color(0xFF866571),
                 ),
               ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _unlockController,
      builder: (context, child) {
        final blurValue = _isAnimatingUnlock ? _blurLiftAnimation.value : 12.0;
        final lockOpacity = _isAnimatingUnlock ? _shatterAnimation.value : 1.0;
        
        return GestureDetector(
          onTap: () {
            if (widget.isLastDay && !_isAnimatingUnlock) {
              _startUnlockSequence();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The underlying content, blurred out
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                    child: Opacity(
                      opacity: _isAnimatingUnlock ? 1.0 : 0.15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF322315).withOpacity(0.3)),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: _buildUnlockedContent(isRevealing: _isAnimatingUnlock),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // The Lock UI overlay (fades out during unlock)
                Opacity(
                  opacity: lockOpacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      // Subtle gradient overlay for the locked state
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF090204).withOpacity(0.4),
                          const Color(0xFF1F0A13).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Elegant lock icon
                        AnimatedBuilder(
                          animation: _isAnimatingUnlock ? _unlockController : _pulseController,
                          builder: (context, child) {
                            // Only scale during the unlock sequence, NOT during idle state
                            final scale = _isAnimatingUnlock ? _heartbeatAnimation.value : 1.0;
                            // Use pulse for a soft glowing aura when idle
                            final glowIntensity = _isAnimatingUnlock ? 0.0 : (_pulseAnimation.value - 0.8) / 0.4; // 0.0 to 1.0

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (!_isAnimatingUnlock)
                                      BoxShadow(
                                        color: const Color(0xFF9E7E5A).withOpacity(0.15 * glowIntensity),
                                        blurRadius: 30,
                                        spreadRadius: 5 * glowIntensity,
                                      ),
                                    if (_isAnimatingUnlock)
                                      BoxShadow(
                                        color: const Color(0xFF9E7E5A).withOpacity(0.3),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(36),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF9E7E5A).withOpacity(0.05),
                                        border: Border.all(
                                          color: const Color(0xFF9E7E5A).withOpacity(0.2 + (0.1 * glowIntensity)),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _isAnimatingUnlock ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                          color: const Color(0xFFD4C4CA).withOpacity(0.9),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.isLastDay 
                              ? "Tap to reveal your insights" 
                              : (widget.daysRemaining == 99 
                                  ? "Your insights unlock at the end of your space" 
                                  : "Your insights unlock in ${widget.daysRemaining} ${widget.daysRemaining == 1 ? 'day' : 'days'}"),
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isLastDay ? Colors.white : const Color(0xFF866571),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Teaser crossfade
                        SizedBox(
                          height: 40, // Fixed height to prevent jumping
                          child: AnimatedBuilder(
                            animation: _teaserController,
                            builder: (context, child) {
                              // Simple sine wave fade: 0 to 1 and back to 0
                              final fade = math.sin(_teaserController.value * math.pi);
                              return Opacity(
                                opacity: fade,
                                child: Text(
                                  _teasers[_currentTeaserIndex],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFDD8F9F),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              // Particles effect during shatter (optional, simple burst)
              if (_isAnimatingUnlock && _unlockController.value > 0.4 && _unlockController.value < 0.7)
                 _buildShatterParticles(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShatterParticles() {
    // A very simple particle burst effect using the shatter animation progress
    final progress = (_unlockController.value - 0.4) / 0.3; // 0.0 to 1.0
    final particleOpacity = 1.0 - progress;
    final radius = progress * 100.0;
    
    return Stack(
      children: List.generate(8, (index) {
        final angle = (index / 8) * math.pi * 2;
        return Transform.translate(
          offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
          child: Opacity(
            opacity: particleOpacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF9E7E5A),
                boxShadow: [
                  BoxShadow(color: Color(0xFFDD8F9F), blurRadius: 4, spreadRadius: 1),
                ]
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTempleDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, const Color(0xFF9E7E5A).withValues(alpha: 0.3)],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.spa_rounded, color: Color(0xFF9E7E5A), size: 16),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF9E7E5A).withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedContent({bool isRevealing = false}) {
    // 1. Bond Score
    final bondScoreData = widget.insights?['bondScore'];
    final String bondScore = bondScoreData != null ? '${bondScoreData['score'] ?? ''}' : '85';
    final String bondScoreExplanation = bondScoreData != null ? '${bondScoreData['explanation'] ?? ''}' : 'You both showed quiet courage and honesty.';

    // 2. What Holds You Together
    final holdsTogetherData = widget.insights?['holdsTogether'];
    final List<String> holdsStrengths = (holdsTogetherData?['strengths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Deep emotional care', 'Willingness to try'];
    final String holdsExplanation = holdsTogetherData != null ? '${holdsTogetherData['explanation'] ?? ''}' : 'Your foundation remains strong.';

    // 3. What You Truly Missed
    final missedData = widget.insights?['trulyMissed'];
    final List<String> missedItems = (missedData?['missed'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Daily presence', 'Quiet moments'];
    final String missedInterpretation = missedData != null ? '${missedData['interpretation'] ?? ''}' : 'Absence highlighted your deep bond.';

    // 4. Unspoken Needs
    final needsData = widget.insights?['unspokenNeeds'];
    final List<String> indivNeeds = (needsData?['individual'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Reassurance'];
    final List<String> sharedNeeds = (needsData?['shared'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Emotional safety'];
    final String needsExplanation = needsData != null ? '${needsData['explanation'] ?? ''}' : 'Both of you seek gentle understanding.';

    // 5. How You've Grown
    final grownData = widget.insights?['howYouGrown'];
    final List<String> grownAreas = (grownData?['areas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Patience', 'Self-awareness'];
    final String grownExamples = grownData != null ? '${grownData['examples'] ?? ''}' : 'You chose reflection over reaction.';

    // 6. Patterns Noticed
    final patternsData = widget.insights?['patternsNoticed'];
    final List<String> patternsItems = (patternsData?['patterns'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Holding back fears'];
    final String patternsWhy = patternsData != null ? '${patternsData['whyItMatters'] ?? ''}' : 'Vulnerability brings you closer.';

    // 7. The Love They Show Quietly
    final quietData = widget.insights?['quietLove'];
    final List<String> quietBehaviors = (quietData?['behaviors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Showing up daily', 'Writing letters'];
    final String quietSummary = quietData != null ? '${quietData['summary'] ?? ''}' : 'Love was present in the effort.';

    // 8. What Was Left Unsaid
    final unsaidData = widget.insights?['leftUnsaid'];
    final List<String> unsaidThemes = (unsaidData?['themes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Fear of disconnect'];
    final String unsaidSummary = unsaidData != null ? '${unsaidData['summary'] ?? ''}' : 'It\'s safe to share these now.';

    // 9. Relationship Blind Spots
    final blindSpotsData = widget.insights?['blindSpots'];
    final List<String> blindOpportunities = (blindSpotsData?['opportunities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Expressing needs sooner'];
    final String blindExplanation = blindSpotsData != null ? '${blindSpotsData['explanation'] ?? ''}' : 'Don\'t wait for the perfect moment.';

    // 10. What Future You Both Want
    final futureData = widget.insights?['futureWant'];
    final List<String> futureAlignment = (futureData?['alignment'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['A peaceful reconnection'];
    final String futureSummary = futureData != null ? '${futureData['summary'] ?? ''}' : 'You both want the same thing.';

    // 11. Bonded AI Letter
    final String aiLetter = widget.insights?['aiLetter'] ?? 'Dear You,\n\nThroughout this separation, you have both shown courage.\n\nWith warmth,\nBonded AI';

    Widget buildSection({
      required String title,
      String? explanation,
      List<String>? bulletPoints,
      List<String>? secondaryBulletPoints, // For shared needs
      String? summary,
      required Animation<Offset> slideAnim,
      required Animation<double> fadeAnim,
      bool isLetter = false,
      String? scoreStr,
    }) {
      return _buildRevealWrapper(
        isRevealing: isRevealing,
        slideAnim: slideAnim,
        fadeAnim: fadeAnim,
        child: Column(
          children: [
            if (scoreStr != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F0A13),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('BOND SCORE', style: TextStyle(fontSize: 10, color: Color(0xFF866571), letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$scoreStr/100', style: const TextStyle(fontFamily: 'Georgia', fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFDD8F9F))),
                    if (explanation != null && explanation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(explanation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFFE8D5DD), height: 1.4)),
                    ]
                  ],
                ),
              )
            else if (isLetter)
              _ReflectionCard(
                title: title,
                content: explanation ?? summary ?? '',
                isVaultContent: true,
              )
            else
              _ListCard(
                title: title,
                items: [
                  if (explanation != null && explanation.isNotEmpty)
                    _ListItem(text: explanation, dotColor: Colors.transparent),
                  if (bulletPoints != null)
                    ...bulletPoints.map((item) => _ListItem(text: item, dotColor: const Color(0xFF8A2E55))),
                  if (secondaryBulletPoints != null)
                    ...secondaryBulletPoints.map((item) => _ListItem(text: 'Shared: $item', dotColor: const Color(0xFF9E7E5A))),
                  if (summary != null && summary.isNotEmpty)
                    _ListItem(text: summary, dotColor: Colors.transparent),
                ],
                isVaultContent: true,
              ),
            _buildTempleDivider(),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0509), // Deep temple interior
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFF9E7E5A).withOpacity(0.8), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E7E5A).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF8A2E55).withOpacity(0.1),
            blurRadius: 80,
            spreadRadius: -10,
          )
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        children: [
          // Temple background texture / glow
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF8A2E55).withOpacity(0.15),
                      const Color(0xFF0F0509),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Inner border (double border effect)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF9E7E5A).withOpacity(0.3), width: 1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Temple Header Arch / Logo
              _buildRevealWrapper(
                isRevealing: isRevealing,
                slideAnim: _slideSection1,
                fadeAnim: _fadeSection1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                  child: Column(
                    children: [
                      // Elegant Temple Logo/Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9E7E5A).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFF9E7E5A).withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.wb_twilight_rounded, color: Color(0xFF9E7E5A), size: 36),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'THE SANCTUARY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                          color: Color(0xFFDD8F9F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Bonded Insights',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFE8D5DD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              buildSection(
                title: 'BOND SCORE',
                scoreStr: bondScore,
                explanation: bondScoreExplanation,
                slideAnim: _slideSection1,
                fadeAnim: _fadeSection1,
              ),

              buildSection(
                title: '❤️ WHAT HOLDS YOU TOGETHER',
                bulletPoints: holdsStrengths,
                summary: holdsExplanation,
                slideAnim: _slideSection2,
                fadeAnim: _fadeSection2,
              ),

              buildSection(
                title: '🌸 WHAT YOU TRULY MISSED',
                bulletPoints: missedItems,
                summary: missedInterpretation,
                slideAnim: _slideSection2,
                fadeAnim: _fadeSection2,
              ),

              buildSection(
                title: '💌 UNSPOKEN NEEDS',
                bulletPoints: indivNeeds,
                secondaryBulletPoints: sharedNeeds,
                summary: needsExplanation,
                slideAnim: _slideSection2,
                fadeAnim: _fadeSection2,
              ),

              buildSection(
                title: '🌱 HOW YOU\'VE GROWN',
                bulletPoints: grownAreas,
                summary: grownExamples,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '🌊 PATTERNS NOTICED',
                bulletPoints: patternsItems,
                summary: patternsWhy,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '🌟 LOVE SHOWN QUIETLY',
                bulletPoints: quietBehaviors,
                summary: quietSummary,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '💭 WHAT WAS LEFT UNSAID',
                bulletPoints: unsaidThemes,
                summary: unsaidSummary,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '🤝 AREAS TO EXPLORE',
                bulletPoints: blindOpportunities,
                summary: blindExplanation,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '🎯 THE FUTURE YOU WANT',
                bulletPoints: futureAlignment,
                summary: futureSummary,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              buildSection(
                title: '💕 A LETTER FROM BONDED AI',
                explanation: aiLetter,
                isLetter: true,
                slideAnim: _slideSection3,
                fadeAnim: _fadeSection3,
              ),

              // Celebration line at the bottom
              if (isRevealing || _fullyUnlocked)
                Opacity(
                  opacity: isRevealing ? _celebrationAnimation.value : 1.0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 4),
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF160A0E).withOpacity(0.0),
                          const Color(0xFF8A2E55).withOpacity(0.15),
                        ]
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(34), bottomRight: Radius.circular(34)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF9E7E5A), size: 24),
                        const SizedBox(height: 16),
                        const Text(
                          'You showed up — and it shaped something beautiful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFE8D5DD),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 1,
                          color: const Color(0xFF9E7E5A).withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevealWrapper({
    required bool isRevealing,
    required Animation<Offset> slideAnim,
    required Animation<double> fadeAnim,
    required Widget child,
  }) {
    if (!isRevealing) return child;
    return Transform.translate(
      offset: slideAnim.value * 50, // 50 pixels slide
      child: Opacity(
        opacity: fadeAnim.value,
        child: child,
      ),
    );
  }
}

class _BondProgressCard extends StatefulWidget {
  final String emoji;
  final String loveWord;
  final String message;
  final int coupleScore;
  final int myScore;
  final double checkInsProgress;
  final double opennessProgress;
  final double presenceProgress;

  const _BondProgressCard({
    required this.emoji,
    required this.loveWord,
    required this.message,
    required this.coupleScore,
    required this.myScore,
    required this.checkInsProgress,
    required this.opennessProgress,
    required this.presenceProgress,
  });

  @override
  State<_BondProgressCard> createState() => _BondProgressCardState();
}
class _BondProgressCardState extends State<_BondProgressCard> with SingleTickerProviderStateMixin {
  late AnimationController _emojiController;
  late Animation<double> _emojiPulse;

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _emojiPulse = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getStageVisuals(int score) {
    if (score <= 50) {
      return {
        'icon': Icons.eco_rounded,
        'color': const Color(0xFF81C784),
        'glow': const Color(0xFF388E3C),
        'nextStage': 'Blooming (51)',
      };
    } else if (score <= 150) {
      return {
        'icon': Icons.local_florist_rounded,
        'color': const Color(0xFFF06292),
        'glow': const Color(0xFFD81B60),
        'nextStage': 'Passionate (151)',
      };
    } else if (score <= 300) {
      return {
        'icon': Icons.whatshot_rounded,
        'color': const Color(0xFFFFB74D),
        'glow': const Color(0xFFF57C00),
        'nextStage': 'Devoted (301)',
      };
    } else if (score < 500) {
      return {
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFFCE93D8),
        'glow': const Color(0xFF8E24AA),
        'nextStage': 'Soulbound (500+)',
      };
    } else {
      return {
        'icon': Icons.auto_awesome_rounded,
        'color': const Color(0xFFFFD54F),
        'glow': const Color(0xFFFFA000),
        'nextStage': 'Max Stage Reached',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final stageVisuals = _getStageVisuals(widget.coupleScore);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F0A13),
            Color(0xFF110309),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF3E1F2C).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2E55).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          PremiumSheen(
            animationDuration: const Duration(milliseconds: 2500),
            pauseDuration: const Duration(seconds: 10),
            sheenOpacity: 0.15,
            child: Column(
              children: [
                // ── Arc Gauge ──
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(220, 110),
              painter: _ArcPainter(widget.coupleScore),
            ),
          ),
          const SizedBox(height: 12),
          // ── Stage Visualization (below gauge, no overlap) ──
          AnimatedBuilder(
            animation: _emojiPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _emojiPulse.value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (stageVisuals['color'] as Color).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: (stageVisuals['glow'] as Color).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: (stageVisuals['color'] as Color).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                stageVisuals['icon'],
                color: stageVisuals['color'],
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF9E7E5A),
            ),
          ),
          const SizedBox(height: 24),
          
          // ── Stage Explanation Details ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF160A0E).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Stage', style: TextStyle(fontSize: 10, color: Color(0xFF866571), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(widget.loveWord, style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: stageVisuals['color'])),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Next Stage', style: TextStyle(fontSize: 10, color: Color(0xFF866571), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(stageVisuals['nextStage'], style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDD8F9F))),
                  ],
                ),
              ],
            ),
          ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'My Score: ${widget.myScore}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF866571)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniProgressBar(label: 'Check-ins', progress: widget.checkInsProgress, gradientColors: [const Color(0xFFD81B60), const Color(0xFFF06292)]),
              const SizedBox(width: 8),
              _MiniProgressBar(label: 'Openness', progress: widget.opennessProgress, gradientColors: [const Color(0xFF8E24AA), const Color(0xFFBA68C8)]),
              const SizedBox(width: 8),
              _MiniProgressBar(label: 'Presence', progress: widget.presenceProgress, gradientColors: [const Color(0xFFFFB300), const Color(0xFFFFD54F)]),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final int coupleScore;

  _ArcPainter(this.coupleScore);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E1020).withOpacity(0.5)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    final shader = const LinearGradient(
      colors: [Color(0xFF8A2E55), Color(0xFFDD8F9F)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw glow behind progress arc
    final glowPaint = Paint()
      ..shader = shader
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final double sweepAngle = math.pi * (coupleScore / 500.0).clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      glowPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = shader
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw indicator dot shadow / glow
    final dotAngle = math.pi + sweepAngle;
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );

    final dotGlowPaint = Paint()
      ..color = const Color(0xFFDD8F9F).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(dotOffset, 12, dotGlowPaint);

    // Draw indicator dot
    final dotPaint = Paint()..color = const Color(0xFFDD8F9F);
    canvas.drawCircle(dotOffset, 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final List<Color> gradientColors;

  const _MiniProgressBar({required this.label, required this.progress, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6E565E))),
                Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 9, color: gradientColors.last, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26151B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final bool isItalic;

  const _StatusChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    this.isItalic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: borderColor?.withOpacity(0.2) ?? Colors.transparent,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final bool isVaultContent;

  const _InsightCard({
    required this.title,
    required this.content,
    required this.titleColor,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF1F0A13),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: isVaultContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isVaultContent ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            content,
            textAlign: isVaultContent ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Color(0xFFE8D5DD),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<_ListItem> items;
  final bool isVaultContent;

  const _ListCard({
    required this.title,
    required this.items,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF160A0E),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
        border: isVaultContent ? null : Border.all(color: const Color(0xFF1F0A13)),
      ),
      child: Column(
        crossAxisAlignment: isVaultContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isVaultContent ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF9E7E5A),
            ),
          ),
          const SizedBox(height: 24),
          ...items,
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;
  final Color dotColor;

  const _ListItem({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 16.0),
            child: Icon(Icons.flare, size: 10, color: dotColor.withValues(alpha: 0.8)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFFD4C4CA),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isVaultContent;

  const _ReflectionCard({
    required this.title,
    required this.content,
    this.isVaultContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        color: isVaultContent ? Colors.transparent : const Color(0xFF160A0E),
        borderRadius: isVaultContent ? BorderRadius.zero : BorderRadius.circular(28),
        border: isVaultContent ? null : Border.all(color: const Color(0xFF322315).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: isVaultContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isVaultContent ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF8A2E55),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            content,
            textAlign: isVaultContent ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Color(0xFF9E7E5A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

