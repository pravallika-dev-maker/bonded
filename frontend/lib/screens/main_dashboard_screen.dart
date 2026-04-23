import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../widgets/premium_nav_bar.dart';
import 'separation_step1_intention_screen.dart';
import 'history_screen.dart';
import 'feel_screen.dart';
import 'join_with_code_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final String userName;
  const MainDashboardScreen({super.key, required this.userName});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

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
        body: Stack(
          children: [
            Positioned.fill(
              child: _currentIndex == 1
                  ? FeelScreen(onReturnHome: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    })
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
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Today's Affirmation Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A0D18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3D1627),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -20,
                              child: Icon(
                                Icons.favorite,
                                size: 100,
                                color: const Color(0xFF3B1525).withOpacity(0.5),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "TODAY'S AFFIRMATION",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF7A4A5A),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '"The ache of missing someone is proof of how deeply they live in you."',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Separation & Past Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SeparationStep1IntentionScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'New separation',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A1B3D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF7A4A5A),
                              ),
                              label: const Text(
                                'View past',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A4A5A),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2E1620),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
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

                      // ── Stat Cards ──
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: '14',
                              label: 'DAY',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              value: '7',
                              label: 'STREAK',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              value: '83',
                              label: 'MOOD',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Activity Prompt ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160B0C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF33231D),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(0xFFC79A54),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: const Text(
                                'Write one thing you love about them — but keep it until you reunite.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFC8B3A8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Check in today Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 18,
                            color: Color(0xFF7A4A5A),
                          ),
                          label: const Text(
                            'Check in today',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A4A5A),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF260D1A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
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

