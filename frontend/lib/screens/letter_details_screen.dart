import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LetterDetailsScreen extends StatelessWidget {
  final String date;
  final String day;
  final String tag;
  final Color tagBg;
  final Color tagText;
  final Color accentColor;
  final String prompt;
  final String body;

  const LetterDetailsScreen({
    super.key,
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'UNSENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.more_horiz, color: Color(0xFF7A5C67), size: 24),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header (Date & Tag) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$date · $day',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF6E565E),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(16),
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
                                const SizedBox(width: 8),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: tagText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // ── Prompt ──
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: accentColor, width: 4),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          '"$prompt"',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Body ──
                      Text(
                        body,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          color: Color(0xFFD4C4CA),
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 64),
                      
                      // Bottom Decoration
                      Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF3D1627),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'LETTER DETAIL — READ ONLY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF3D1627),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
