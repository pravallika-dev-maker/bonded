import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/separation_step1_intention_screen.dart';
import '../screens/history_screen.dart';
import '../screens/join_with_code_screen.dart';
import '../services/api_service.dart';

class LivingSanctuarySection extends StatefulWidget {
  const LivingSanctuarySection({super.key});

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
            // ── TOP BUTTONS ──
            Row(
              children: [
                Expanded(
                  child: _FloatingPillButton(
                    title: "Begin a New Journey",
                    icon: Icons.add,
                    isPrimary: true,
                    breathingController: _breathingController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SeparationStep1IntentionScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FloatingPillButton(
                    title: "Shared Memories",
                    icon: Icons.history,
                    isPrimary: false,
                    breathingController: _breathingController,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── CONNECTION PORTAL (Join) ──
            _ConnectionPortalBar(
              driftController: _ambientDriftController,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinWithCodeScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

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
// Floating Pill Button
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingPillButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final AnimationController breathingController;
  final VoidCallback onTap;

  const _FloatingPillButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.breathingController,
    required this.onTap,
  });

  @override
  State<_FloatingPillButton> createState() => _FloatingPillButtonState();
}

class _FloatingPillButtonState extends State<_FloatingPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tapController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: const Color(0xFF180710).withOpacity(0.5),
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFF911746).withOpacity(0.35)
                  : const Color(0xFF3D1627).withOpacity(0.6),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: const Color(0xFFDD8F9F).withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDD8F9F),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Connection Portal Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ConnectionPortalBar extends StatefulWidget {
  final AnimationController driftController;
  final VoidCallback onTap;

  const _ConnectionPortalBar({
    required this.driftController,
    required this.onTap,
  });

  @override
  State<_ConnectionPortalBar> createState() => _ConnectionPortalBarState();
}

class _ConnectionPortalBarState extends State<_ConnectionPortalBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tapController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 44,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: const Color(0xFF180710).withOpacity(0.5),
            border: Border.all(
              color: const Color(0xFF911746).withOpacity(0.4),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "✦",
                  style: TextStyle(
                    color: Color(0xFFDD8F9F),
                    fontSize: 10,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Enter a Shared Space",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD8F9F),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "✦",
                  style: TextStyle(
                    color: Color(0xFFDD8F9F),
                    fontSize: 10,
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
