import 'package:flutter/material.dart';
import 'dart:ui';

class DailyActivityUnlockCard extends StatefulWidget {
  final int day;
  final String title;
  final String description;
  final String teaserText;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const DailyActivityUnlockCard({
    super.key,
    required this.day,
    required this.title,
    required this.description,
    required this.teaserText,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<DailyActivityUnlockCard> createState() => _DailyActivityUnlockCardState();
}

class _DailyActivityUnlockCardState extends State<DailyActivityUnlockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.isUnlocked ? widget.onTap : null,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF130810),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isUnlocked
                    ? const Color(0xFFD4864A).withOpacity(0.25 * _glow.value)
                    : const Color(0xFF2A1520).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4864A).withOpacity(0.06 * _glow.value),
                        blurRadius: 30,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: widget.isUnlocked ? _buildUnlocked() : _buildLocked(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnlocked() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4864A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFD4864A).withOpacity(0.3), width: 1),
                ),
                child: Text(
                  'DAY ${widget.day}',
                  style: const TextStyle(
                    fontSize: 9, letterSpacing: 2,
                    color: Color(0xFFD4864A), fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFD4864A)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.bold,
              color: Color(0xFFE8C5A0), height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 13, color: const Color(0xFF9E7E5A).withOpacity(0.9), height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A1E0F), Color(0xFF1A0C12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4864A).withOpacity(0.25), width: 1),
            ),
            child: const Center(
              child: Text(
                'Begin today\'s experience',
                style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 14, fontStyle: FontStyle.italic,
                  color: Color(0xFFE8C5A0), letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocked() {
    return Stack(
      children: [
        // Blurred background content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1520).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'DAY ${widget.day}',
                      style: const TextStyle(fontSize: 9, letterSpacing: 2, color: Color(0xFF5A3C47)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 14, width: 180, color: const Color(0xFF1F1018)),
              const SizedBox(height: 8),
              Container(height: 10, width: 240, color: const Color(0xFF1A0E13)),
              const SizedBox(height: 4),
              Container(height: 10, width: 200, color: const Color(0xFF1A0E13)),
              const SizedBox(height: 20),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF160A10),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: const Color(0xFF0D0610).withOpacity(0.6)),
          ),
        ),
        // Teaser text on top
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 20, color: const Color(0xFF5A3C47).withOpacity(0.6)),
                  const SizedBox(height: 14),
                  Text(
                    widget.teaserText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia', fontSize: 14, fontStyle: FontStyle.italic,
                      color: Color(0xFF9E7E5A), height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
