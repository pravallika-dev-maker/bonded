import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'new_letter_screen.dart';
import 'letter_details_screen.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Your ',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'letters',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewLetterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF9E7E5A), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      '+ New entry',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Scrollable List ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: const [
                  _LetterCard(
                    date: 'MARCH 25',
                    day: 'DAY 14',
                    tag: 'Longing',
                    tagBg: Color(0xFF3F1629),
                    tagText: Color(0xFFECAABB),
                    accentColor: Color(0xFF8A2E55),
                    prompt: 'What do you miss most about them today?',
                    body: "The way she laughs at her own jokes before finishing them. I catch myself smiling at nothing and realise it's because I'm thinking of her.",
                  ),
                  SizedBox(height: 16),
                  _LetterCard(
                    date: 'MARCH 23',
                    day: 'DAY 12',
                    tag: 'Peaceful',
                    tagBg: Color(0xFF322315),
                    tagText: Color(0xFFDCD2AE),
                    accentColor: Color(0xFF9E7E5A),
                    prompt: 'What are you grateful for in this space?',
                    body: "I've had more time with myself. Found that I'm still interesting alone — that feels important.",
                  ),
                  SizedBox(height: 16),
                  _LockedLetterCard(),
                  SizedBox(height: 24),
                  _WriteTodayEntryPrompt(),
                  SizedBox(height: 120), // Spacer for navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final String date;
  final String day;
  final String tag;
  final Color tagBg;
  final Color tagText;
  final Color accentColor;
  final String prompt;
  final String body;

  const _LetterCard({
    required this.date,
    required this.day,
    required this.tag,
    required this.tagBg,
    required this.tagText,
    required this.accentColor,
    required this.prompt,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetterDetailsScreen(
              date: date,
              day: day,
              tag: tag,
              tagBg: tagBg,
              tagText: tagText,
              accentColor: accentColor,
              prompt: prompt,
              body: body,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: accentColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$date · $day',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF6E565E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tagText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"$prompt"',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF866571),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFC8B3A8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedLetterCard extends StatelessWidget {
  const _LockedLetterCard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: const Color(0xFF4A343D).withOpacity(0.5), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"You wrote this when it hurt more..."',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF866571).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check in to unlock · Day 2',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF4A343D).withOpacity(0.5),
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

class _WriteTodayEntryPrompt extends StatelessWidget {
  const _WriteTodayEntryPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26151B), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline, color: Color(0xFF4A343D), size: 18),
          SizedBox(width: 12),
          Text(
            "Write today's entry",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Color(0xFF4A343D),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26151B)
      ..strokeWidth = 1.5
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
