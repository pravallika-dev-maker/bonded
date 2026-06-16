import 'package:flutter/material.dart';
import '../screens/separation_step1_intention_screen.dart';
import '../screens/history_screen.dart';
import '../services/api_service.dart';

class LivingSanctuarySection extends StatefulWidget {
  final bool isActiveSeparation;
  const LivingSanctuarySection({super.key, required this.isActiveSeparation});

  @override
  State<LivingSanctuarySection> createState() => _LivingSanctuarySectionState();
}

class _LivingSanctuarySectionState extends State<LivingSanctuarySection>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _ambientDriftController;
  late AnimationController _entryController;

  late Animation<double> _entryOpacity;
  late Animation<Offset> _entryOffset;

  @override
  void initState() {
    super.initState();

    // Breathing (glows, gentle scales)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Continuous slow shimmer, border glow, particles
    _ambientDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );
    _entryOffset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _ambientDriftController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entryOffset,
        child: Column(
          children: [


            // ── THE QUOTE CARD SANCTUARY ──
            _EmotionalSanctuaryCard(
              breathingController: _breathingController,
              driftController: _ambientDriftController,
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// The Gentle Reminder Quote Card (minimal)
// ─────────────────────────────────────────────────────────────────────────────
class _EmotionalSanctuaryCard extends StatefulWidget {
  final AnimationController breathingController;
  final AnimationController driftController;

  const _EmotionalSanctuaryCard({
    required this.breathingController,
    required this.driftController,
  });

  @override
  State<_EmotionalSanctuaryCard> createState() => _EmotionalSanctuaryCardState();
}

class _EmotionalSanctuaryCardState extends State<_EmotionalSanctuaryCard> {
  String _affirmation = '"The space between you is not a void,\nbut a garden growing in silence."';

  @override
  void initState() {
    super.initState();
    _fetchAffirmation();
  }

  Future<void> _fetchAffirmation() async {
    final data = await ApiService.getTodayAffirmation();
    if (data != null && mounted) {
      final text = data['text'] ?? data['content'] ?? data['quote'] ?? data['message'] ?? data['affirmation'];
      if (text != null && text.toString().isNotEmpty) {
        setState(() {
          _affirmation = '"$text"';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.breathingController,
      builder: (context, child) {
        final breathe = widget.breathingController.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E1020).withOpacity(0.15 + (breathe * 0.05)),
                const Color(0xFF180710).withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            border: Border.all(
              color: const Color(0xFFFF8BC2).withOpacity(0.08 + (breathe * 0.07)),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8BC2).withOpacity(0.02 + (breathe * 0.03)),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -1.0 + (breathe * 2.0)),
                child: Icon(
                  Icons.local_florist_outlined,
                  size: 20,
                  color: const Color(0xFFFF8BC2).withOpacity(0.6 + (breathe * 0.2)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GENTLE REMINDER",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: const Color(0xFFFF8BC2).withOpacity(0.5 + (breathe * 0.2)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _affirmation,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4B1C1),
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
