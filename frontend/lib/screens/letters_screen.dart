import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'new_letter_screen.dart';
import 'letter_details_screen.dart';
import 'separation_step1_intention_screen.dart';
import '../widgets/primary_cta_button.dart';

import '../services/api_service.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/foundation.dart';

class LettersScreen extends StatefulWidget {
  final bool isActiveSeparation;
  final int? relationshipId;
  const LettersScreen({super.key, this.isActiveSeparation = false, this.relationshipId});

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
      final fetched = widget.relationshipId != null
          ? await ApiService.getSeparationLetters(widget.relationshipId!)
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
    if (!widget.isActiveSeparation && widget.relationshipId == null) {
      return const _LockedLettersView();
    }

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
                  if (widget.isActiveSeparation || widget.relationshipId != null)
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

class _LockedLettersView extends StatefulWidget {
  const _LockedLettersView();

  @override
  State<_LockedLettersView> createState() => _LockedLettersViewState();
}

class _LockedLettersViewState extends State<_LockedLettersView> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _shimmerController;
  late AnimationController _entryController;
  
  late Animation<double> _envelopeOpacity;
  late Animation<Offset> _envelopeOffset;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();
    
    // Entry animations
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _envelopeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _envelopeOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );
    
    _entryController.forward();
    
    // 8-second loop for floating and breathing (4s forward, 4s reverse)
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Occasional shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startShimmerLoop();
  }

  void _startShimmerLoop() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 4 + math.Random().nextInt(6)));
      if (!mounted) break;
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: Stack(
        children: [
          // Background Atmosphere
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AtmospherePainter(animationValue: _floatingController.value),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 16.0),
                  child: Row(
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
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Envelope Visual
                          FadeTransition(
                            opacity: _envelopeOpacity,
                            child: SlideTransition(
                              position: _envelopeOffset,
                              child: AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, child) {
                                  // 4px vertical movement
                                  final dy = math.sin(_floatingController.value * math.pi) * 4.0;
                                  return Transform.translate(
                                    offset: Offset(0, dy),
                                    child: child,
                                  );
                                },
                                child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4A1C31).withValues(alpha: 0.2), // Soft burgundy glass
                                border: Border.all(
                                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.15), // Subtle blush border
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.05), // Soft blush pink glow
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _shimmerController,
                                  builder: (context, child) {
                                    return ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: const Alignment(-1.0, -1.0),
                                          end: const Alignment(2.0, 2.0),
                                          stops: [
                                            _shimmerController.value - 0.2,
                                            _shimmerController.value,
                                            _shimmerController.value + 0.2,
                                          ],
                                          colors: [
                                            const Color(0xFFDD8F9F).withValues(alpha: 0.6),
                                            Colors.white.withValues(alpha: 0.9),
                                            const Color(0xFFDD8F9F).withValues(alpha: 0.6),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.srcATop,
                                      child: Icon(
                                        Icons.mail_outline,
                                        size: 28,
                                        color: const Color(0xFFDD8F9F).withValues(alpha: 0.6),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Text and CTA group
                          FadeTransition(
                            opacity: _textOpacity,
                            child: SlideTransition(
                              position: _textOffset,
                              child: Column(
                                children: [
                                  // Headline
                                  const Text(
                                    'A space for the things left unsaid',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFFFFF0), // Premium ivory
                                      height: 1.3,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Supporting Copy
                                  const Text(
                                    'Letters unlock during your separation journey, giving you a private place to hold thoughts, memories, and feelings that matter.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFD4C4C7), // Soft blush-gray
                                      height: 1.6,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 48),
                                  
                                  // CTA
                                  PrimaryCtaButton(
                                    text: 'Begin a Journey Together',
                                    icon: null,
                                    height: 52,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SeparationStep1IntentionScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Offset from center slightly upwards
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final double animationValue;

  _AtmospherePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient Glows
    final paintGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3F1629).withValues(alpha: 0.25),
          const Color(0xFF090204).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.2), radius: size.width * 0.6))
      ..blendMode = BlendMode.screen;
      
    canvas.drawRect(Offset.zero & size, paintGlow);
    
    // 2. Floating Particles
    final random = math.Random(42); // fixed seed for consistent layout
    final particlePaint = Paint()..color = const Color(0xFFDD8F9F).withValues(alpha: 0.2);
    
    for (int i = 0; i < 15; i++) {
      final xBase = random.nextDouble() * size.width;
      final yBase = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      // subtle movement based on animation
      final dx = math.sin(animationValue * math.pi * 2 + i) * 10;
      final dy = math.cos(animationValue * math.pi * 2 + i) * 10;
      
      canvas.drawCircle(Offset(xBase + dx, yBase + dy), radius, particlePaint);
    }
    
    // 3. Faint Script Textures
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    void drawFaintText(String text, Offset pos, double rotation, double opacity) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontSize: 24,
          color: const Color(0xFFC8B3A8).withValues(alpha: opacity),
          letterSpacing: 2.0,
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
    
    drawFaintText("dear one...", Offset(size.width * 0.1, size.height * 0.25), -0.1, 0.06);
    drawFaintText("waiting for the right moment", Offset(size.width * 0.45, size.height * 0.65), 0.05, 0.04);
    drawFaintText("memories we hold", Offset(size.width * 0.15, size.height * 0.8), -0.05, 0.06);
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
