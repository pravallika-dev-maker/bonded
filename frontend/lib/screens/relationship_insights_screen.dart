import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class RelationshipInsightsScreen extends StatefulWidget {
  const RelationshipInsightsScreen({super.key});

  @override
  State<RelationshipInsightsScreen> createState() => _RelationshipInsightsScreenState();
}

class _RelationshipInsightsScreenState extends State<RelationshipInsightsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Back Button ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Title Section ---
                    const Text(
                      'INSIGHTS & ALIGNMENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Relationship',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDD8F9F),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- 1. Alignment Sync Ring ---
                    _buildSyncMeter(),

                    const SizedBox(height: 32),

                    // --- 2. Mood Breakdown / Emotional Pattern ---
                    _buildMoodPatterns(),

                    const SizedBox(height: 32),

                    // --- 3. Relationship Milestones (Badges) ---
                    _buildMilestones(),

                    const SizedBox(height: 32),

                    // --- 4. Insights of the Week (Poetic advice) ---
                    _buildWeeklyTips(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncMeter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF26151B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDD8F9F).withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular custom painted sync meter
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _SyncMeterPainter(syncRate: 0.94),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '94%',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'SYNC',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Color(0xFFDD8F9F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'SYNC STATUS: HIGH ALIGNMENT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E7E5A),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Deep Empathy',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "You both checked in regularly this week, expressing honest emotions and holding space for each other.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF866571),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPatterns() {
    final moods = [
      {'mood': 'Peaceful', 'percentage': 0.35, 'color': const Color(0xFF9E7E5A), 'bg': const Color(0xFF2E2713)},
      {'mood': 'Growing', 'percentage': 0.25, 'color': const Color(0xFF4A7A5A), 'bg': const Color(0xFF132A1E)},
      {'mood': 'Longing', 'percentage': 0.25, 'color': const Color(0xFFECAABB), 'bg': const Color(0xFF3F1629)},
      {'mood': 'Reflective', 'percentage': 0.15, 'color': const Color(0xFF6A5A8E), 'bg': const Color(0xFF1E1833)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WEEKLY EMOTIONAL PATTERN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF5A3C47),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF160A0E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF26151B), width: 1.2),
          ),
          child: Column(
            children: moods.map((m) {
              final pct = m['percentage'] as double;
              final color = m['color'] as Color;
              final moodName = m['mood'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          moodName,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(pct * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF090204),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestones() {
    final badges = [
      {
        'title': 'First Reflection',
        'desc': 'You took a step to identify and share your feeling.',
        'icon': Icons.favorite,
        'color': const Color(0xFF9E7E5A),
        'unlocked': true,
        'date': 'Jun 1, 2026',
      },
      {
        'title': 'Active Listener',
        'desc': 'Exchanged letters during space, building understanding.',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFFDD8F9F),
        'unlocked': true,
        'date': 'Jun 3, 2026',
      },
      {
        'title': 'Intimacy Builder',
        'desc': 'Lived through a full 3-day space cycle.',
        'icon': Icons.hourglass_empty,
        'color': const Color(0xFF6A5A8E),
        'unlocked': true,
        'date': 'Jun 4, 2026',
      },
      {
        'title': 'Anchor of Calm',
        'desc': 'Log 7 peaceful checks in a row.',
        'icon': Icons.anchor,
        'color': const Color(0xFF4A7A5A),
        'unlocked': false,
        'date': 'Locked',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RELATIONSHIP MILESTONES',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF5A3C47),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final b = badges[index];
            final unlocked = b['unlocked'] as bool;
            final color = b['color'] as Color;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF160A0E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: unlocked ? color.withOpacity(0.3) : const Color(0xFF26151B),
                  width: 1.2,
                ),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.04),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked ? color.withOpacity(0.1) : const Color(0xFF260D1A),
                      border: Border.all(
                        color: unlocked ? color.withOpacity(0.5) : const Color(0xFF3D1627),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      unlocked ? (b['icon'] as IconData) : Icons.lock_outline,
                      color: unlocked ? color : const Color(0xFF5A3C47),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    b['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.white : const Color(0xFF5A3C47),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      b['desc'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF866571),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b['date'] as String,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: unlocked ? color : const Color(0xFF5A3C47),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyTips() {
    final insights = [
      {
        'title': 'Space creates a safe container',
        'desc': 'You have been learning to pause before reacting. This gives both of you the breathing room to align before speaking.',
      },
      {
        'title': 'Longing is a positive sign',
        'desc': 'Expressing longing this week shows that the physical distance is drawing you emotionally closer. Keep writing letters.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SOMETHING WE'VE NOTICED",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF5A3C47),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: insights.map((i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F0A13).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3F1629).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Color(0xFF9E7E5A), size: 14),
                        SizedBox(width: 8),
                        Text(
                          'MINDFUL INSIGHT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      i['title']!,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i['desc']!,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4C4CA),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SyncMeterPainter extends CustomPainter {
  final double syncRate;

  _SyncMeterPainter({required this.syncRate});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background track circle
    final trackPaint = Paint()
      ..color = const Color(0xFF26151B)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // Glowing progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFFDD8F9F)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-pi / 2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * syncRate,
      false,
      progressPaint,
    );

    // Inner glowing ring decoration
    final innerPaint = Paint()
      ..color = const Color(0xFF8A2E55).withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
