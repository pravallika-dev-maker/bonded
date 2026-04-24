import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeparationDetailScreen extends StatelessWidget {
  const SeparationDetailScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Expanded(
                        child: Text(
                          'MARCH 10 – 17',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF4A343D), // Faint purple/grey
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // Spacer to balance the back button
                    ],
                  ),
                  const SizedBox(height: 48),

                  // --- Hero Section ---
                  const Text(
                    '7 days of',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'space',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFDD8F9F), // Pink rose
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"To understand my feelings better"',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF866571),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Mood Journey Section ---
                  _SectionHeader(title: 'MOOD JOURNEY'),
                  const SizedBox(height: 24),
                  const _MoodJourneyTimeline(),
                  const SizedBox(height: 48),

                  // --- Reflection Insight Section ---
                  _SectionHeader(title: 'REFLECTION INSIGHT'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF160A0E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2D1C35), width: 1),
                    ),
                    child: const Text(
                      '"You learned to sit with your emotions without reacting."',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDD8F9F),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Writing Section ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF160A0E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF26151B), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Read what you wrote during this time',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF866571),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '4 letters · 7 days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4A343D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chat_bubble_outline, color: Color(0xFF4A343D), size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // --- Bottom Button ---
                  Center(
                    child: Text(
                      'Begin a new space',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFDD8F9F).withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: Color(0xFF5A3C47),
      ),
    );
  }
}

class _MoodJourneyTimeline extends StatelessWidget {
  const _MoodJourneyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF26151B), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MoodNode(
                icon: Icons.favorite,
                label: 'Con-\nfused',
                color: const Color(0xFF8A2E55),
              ),
              _TimelineConnector(),
              _MoodNode(
                icon: Icons.panorama_fish_eye,
                label: 'Be-\ncame calm',
                color: const Color(0xFF9E7E5A),
              ),
              _TimelineConnector(),
              _MoodNode(
                icon: Icons.eco,
                label: 'Ended\nclear',
                color: const Color(0xFF4A6A4E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MoodNode({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.8),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          height: 1,
          color: const Color(0xFF26151B),
        ),
      ),
    );
  }
}
