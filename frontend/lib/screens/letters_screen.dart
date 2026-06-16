import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'new_letter_screen.dart';
import 'letter_details_screen.dart';

import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class LettersScreen extends StatefulWidget {
  final int? separationId;
  const LettersScreen({super.key, this.separationId});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  List<Map<String, dynamic>> _letters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLetters();
  }

  Future<void> _fetchLetters() async {
    try {
      final fetched = widget.separationId != null
          ? await ApiService.getSeparationLetters(widget.separationId!)
          : await ApiService.getLetters();
      if (mounted) {
        setState(() {
          // Sort letters by ID descending so newest are at the top (optional but good practice)
          fetched.sort((a, b) => (b['id'] as int? ?? 0).compareTo((a['id'] as int? ?? 0)));
          _letters = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching letters: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getTagStyle(String? tag) {
    final t = (tag ?? 'Reflective').toLowerCase();
    if (t.contains('longing') || t.contains('heartfelt')) {
      return {
        'bg': const Color(0xFF3F1629),
        'text': const Color(0xFFECAABB),
        'accent': const Color(0xFF8A2E55),
      };
    } else if (t.contains('peaceful') || t.contains('deep')) {
      return {
        'bg': const Color(0xFF322315),
        'text': const Color(0xFFDCD2AE),
        'accent': const Color(0xFF9E7E5A),
      };
    } else if (t.contains('growing') || t.contains('funny')) {
      return {
        'bg': const Color(0xFF132A1E),
        'text': const Color(0xFF4A7A5A),
        'accent': const Color(0xFF4A7A5A),
      };
    } else {
      return {
        'bg': const Color(0xFF1E1833),
        'text': const Color(0xFF6A5A8E),
        'accent': const Color(0xFF6A5A8E),
      };
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return 'TODAY';
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('MMMM d').format(dt).toUpperCase();
    } catch (_) {
      return 'TODAY';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate the dynamic content list
    List<Widget> children = [];
    if (_isLoading) {
      children.add(
        const Padding(
          padding: EdgeInsets.only(top: 100),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9E7E5A)),
            ),
          ),
        ),
      );
    } else if (_letters.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              Icon(Icons.edit_note_outlined, size: 64, color: const Color(0xFFDD8F9F).withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text(
                'No letters written yet',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your letters are kept here safely.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF866571),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      for (int i = 0; i < _letters.length; i++) {
        final letter = _letters[i];
        final title = letter['title'] ?? 'Reflection';
        final style = _getTagStyle(title);
        final id = letter['id'] ?? 0;

        children.add(
          _LetterCard(
            id: id,
            date: _formatDate(letter['createdAt']),
            day: 'LETTER ${id != 0 ? id : (i + 1)}',
            tag: title,
            tagBg: style['bg'],
            tagText: style['text'],
            accentColor: style['accent'],
            prompt: 'Your thoughts & feelings',
            body: letter['content'] ?? '',
            onChanged: _fetchLetters,
          ),
        );
        children.add(const SizedBox(height: 16));
      }
    }

    children.add(const SizedBox(height: 120));

    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: Column(
          children: [
            // --- Back Button Row ---
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'LETTERS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                ],
              ),
            ),

            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 4.0, bottom: 16.0),
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
                  if (widget.separationId == null)
                    OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NewLetterScreen()),
                        );
                        if (result == true) {
                          _fetchLetters();
                        }
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
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final int id;
  final String date;
  final String day;
  final String tag;
  final Color tagBg;
  final Color tagText;
  final Color accentColor;
  final String prompt;
  final String body;
  final VoidCallback onChanged;

  const _LetterCard({
    required this.id,
    required this.date,
    required this.day,
    required this.tag,
    required this.tagBg,
    required this.tagText,
    required this.accentColor,
    required this.prompt,
    required this.body,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetterDetailsScreen(
              id: id,
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
        if (result == true) {
          onChanged();
        }
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
                  body.length > 100 ? '${body.substring(0, 100)}...' : body,
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

