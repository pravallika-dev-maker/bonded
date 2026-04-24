import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_separation_screen.dart';

class SeparationStep3InviteCodeScreen extends StatelessWidget {
  final String personName;

  const SeparationStep3InviteCodeScreen({super.key, required this.personName});

  void _skipOrNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSeparationScreen(partnerName: personName),
      ),
    );
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
          child: Column(
            children: [
              // ── AppBar / Back Button ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'INVITE ${personName.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title Section ──
                      const Text(
                        'Share this with',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        personName,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFDD8F9F),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "When he enters this code, you'll be connected — privately, gently.",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7A5C67),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Person Card ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF2E1620),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2A0D18),
                                border: Border.all(
                                  color: const Color(0xFF3D1627),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF7A5C67),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    personName,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Friend · Waiting to connect',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A5C67),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF26181E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9E7E5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Bond Code Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A0D18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF3D1627),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'BOND CODE — EXPIRES IN 24H',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Color(0xFF7A4A5A),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'J A D E · 4',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8.0,
                                color: Color(0xFFE89FB8), // Soft pink instead of white
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Only one person can use this code',
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
                      const SizedBox(height: 40),

                      // ── Share Button ──
                      GestureDetector(
                        onTap: () => _skipOrNext(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1214),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF911746).withOpacity(0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: Color(0xFFDD8F9F),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Share this code',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFDD8F9F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Skip Link ──
                      Center(
                        child: GestureDetector(
                          onTap: () => _skipOrNext(context),
                          child: const Text(
                            "Skip — I'll share it myself later",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF7A5C67),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF7A5C67),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 64),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
