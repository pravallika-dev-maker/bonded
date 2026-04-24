import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../widgets/premium_nav_bar.dart';
import 'separation_step1_intention_screen.dart';
import 'history_screen.dart';
import 'feel_screen.dart';
import 'join_with_code_screen.dart';
import 'letters_screen.dart';
import 'journey_screen.dart';
import 'profile_screen.dart';
import 'reflection_flow_screen.dart';
import 'reflection_completion_screen.dart';
import 'notifications_screen.dart';
import 'dart:math' as math;
import 'dart:ui';

class MainDashboardScreen extends StatefulWidget {
  final String userName;
  const MainDashboardScreen({super.key, required this.userName});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;
  bool _isCheckedIn = false;
  bool _insightViewed = false;
  int _currentDay = 4; // Matching mockup day 4 for demonstration
  int _reflectionDay = 1;
  bool _reflectionCompletedToday = false;

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
                  ? FeelScreen(onReturnHome: () {
                      setState(() {
                        _currentIndex = 0;
                        _isCheckedIn = true;
                      });
                    })
                  : _currentIndex == 2
                      ? const LettersScreen()
                      : _currentIndex == 3
                          ? const JourneyScreen()
                          : _currentIndex == 4
                              ? ProfileScreen(userName: widget.userName)
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GOOD MORNING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: Color(0xFF6E4555),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    widget.userName,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.favorite,
                                    color: Color(0xFF5A3040),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                ),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF260D1A),
                                    border: Border.all(
                                      color: const Color(0xFF3D1627),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.favorite,
                                      color: Color(0xFF914660),
                                      size: 18,
                                    ),
                                  ),
                                ),
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
                                        color: const Color(0xFFDD8F9F).withOpacity(0.8),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFDD8F9F).withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '3',
                                        style: TextStyle(
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Active Separation Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F0A13),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ACTIVE SEPARATION",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    color: Color(0xFF5A3C47),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Day 4",
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "Quietly growing",
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFDD8F9F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "19 hours of choosing space",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5A3C47),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 100,
                                    color: Colors.white.withOpacity(0.03),
                                  ),
                                  SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: CustomPaint(
                                      painter: _HomeProgressPainter(),
                                    ),
                                  ),
                                  const Text(
                                    "4/21",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Separation & Past Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SeparationStep1IntentionScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF26151B), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Text(
                                '+ New\nseparation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF866571),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF26151B), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Text(
                                'View past',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF866571),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Join Existing Separation Button ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const JoinWithCodeScreen()),
                            );
                          },
                          icon: const Icon(
                            Icons.link,
                            size: 16,
                            color: Color(0xFF9E7E5A),
                          ),
                          label: const Text(
                            'Join existing separation',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E7E5A),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF4A3A2A),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Relationship Affirmation Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF322315).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDD8F9F).withOpacity(0.03),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "A GENTLE REMINDER",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF9E7E5A),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: const Color(0xFF9E7E5A).withOpacity(0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '"The space between you is not a void, but a garden growing in silence."',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFDD8F9F),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Insight Card ──
                      _InsightCard(
                        day: _currentDay,
                        insight: _dailyInsights[_currentDay]!,
                        isCheckedIn: _isCheckedIn,
                        isViewed: _insightViewed,
                        onTap: () {
                          if (_isCheckedIn) {
                            _showReflectionModal(context, _dailyInsights[_currentDay]!);
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Sit with your feelings Button ──
                      GestureDetector(
                        onTap: _reflectionCompletedToday
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReflectionFlowScreen(day: _reflectionDay),
                                  ),
                                ).then((completed) {
                                  if (completed == true) {
                                    setState(() {
                                      _reflectionCompletedToday = true;
                                    });
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

  void _showReflectionModal(BuildContext context, InsightData insight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReflectionView(
        insight: insight,
        onComplete: () {
          setState(() {
            _insightViewed = true;
          });
          Navigator.pop(context);
        },
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

  const _InsightCard({
    required this.day,
    required this.insight,
    required this.isCheckedIn,
    required this.isViewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCheckedIn) {
      return CustomPaint(
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
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF8A6530), size: 24),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'You unlocked today’s reflection',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Unlocked but not viewed state
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _ReflectionView extends StatelessWidget {
  final InsightData insight;
  final VoidCallback onComplete;

  const _ReflectionView({required this.insight, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF090204),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          // Content
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    insight.reflectionHeader,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF8A6530),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"${insight.reflectionMain}"',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F0A13),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      insight.reflectionMiddle,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4C4CA),
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF160A0E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF322315).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.awarenessTitle,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"${insight.awarenessText}"',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFCE9B4E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '"${insight.bottomQuote}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF5A3C47),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          insight.finalLine,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF3D242E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2E55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'I\'ll reflect on this',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A343D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button - kept on top
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


