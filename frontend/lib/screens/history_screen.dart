import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'separation_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isTimeline = true;

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
              // ── Header Section ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR HISTORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A), // Bronze/Gold
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Spaces you've",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'lived through',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDD8F9F), // Pink rose
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Segmented Toggle ──
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF160A0E),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isTimeline = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _isTimeline ? const Color(0xFF8A2E55) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Timeline',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _isTimeline ? FontWeight.w600 : FontWeight.normal,
                                    color: _isTimeline ? Colors.white : const Color(0xFF7A5C67),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isTimeline = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: !_isTimeline ? const Color(0xFF8A2E55) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Calendar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: !_isTimeline ? FontWeight.w600 : FontWeight.normal,
                                    color: !_isTimeline ? Colors.white : const Color(0xFF5A3C47),
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
              ),

              // ── List Section ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    // Card 1
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SeparationDetailScreen()),
                        );
                      },
                      child: _CompletedHistoryCard(
                        dateText: 'MARCH 10–17 • COMPLETED',
                        title: '7 days apart',
                        quote: '"You found clarity near the end"',
                        accentColor: const Color(0xFF8A2E55), // Magenta accent
                        tags: [
                          _Tag(label: 'Calm', bgColor: const Color(0xFF3F1629), textColor: const Color(0xFFECAABB)),
                          _Tag(label: 'Reflective', bgColor: const Color(0xFF2D1C35), textColor: const Color(0xFF9D7CAE)),
                          _Tag(label: '4 letters', bgColor: const Color(0xFF331521), textColor: const Color(0xFF864A5C)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card 2
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SeparationDetailScreen()),
                        );
                      },
                      child: _CompletedHistoryCard(
                        dateText: 'FEB 20–23 • COMPLETED',
                        title: '3 days apart',
                        quote: '"You missed them more than expected"',
                        accentColor: const Color(0xFF9E7E5A), // Gold accent
                        tags: [
                          _Tag(label: 'Longing', bgColor: const Color(0xFF3F1629), textColor: const Color(0xFFECAABB)),
                          _Tag(label: '2 letters', bgColor: const Color(0xFF331521), textColor: const Color(0xFF864A5C)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SeparationDetailScreen()),
                        );
                      },
                      child: const _ShortHistoryCard(
                        dateText: 'JAN 5–6 • SHORT',
                        title: '2 days apart',
                        quote: '"Still finding your footing"',
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

class _CompletedHistoryCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String quote;
  final Color accentColor;
  final List<_Tag> tags;

  const _CompletedHistoryCard({
    required this.dateText,
    required this.title,
    required this.quote,
    required this.accentColor,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A13), // Very dark maroon
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 4.0),
            ),
          ),
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF866747), // Dim gold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                quote,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortHistoryCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String quote;

  const _ShortHistoryCard({
    required this.dateText,
    required this.title,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFF3D242E), // Faint grey/brown
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E565E), // Faint greyish white
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFF4A343D), // Very faint quote
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// Custom painter for the dashed border of the Short History Card
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

    // Creating a dashed path
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
