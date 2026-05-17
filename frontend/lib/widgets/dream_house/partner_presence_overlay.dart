import 'package:flutter/material.dart';
import 'dart:math' as math;

class PartnerPresenceOverlay extends StatefulWidget {
  final bool hasUpdate;
  final String updateMessage;

  const PartnerPresenceOverlay({
    super.key,
    this.hasUpdate = false,
    this.updateMessage = 'Something feels warmer here tonight.',
  });

  @override
  State<PartnerPresenceOverlay> createState() => _PartnerPresenceOverlayState();
}

class _PartnerPresenceOverlayState extends State<PartnerPresenceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _traceController;
  late AnimationController _messageController;
  late Animation<double> _pulse;
  late Animation<double> _traceFade;
  late Animation<double> _messageFade;
  late Animation<Offset> _messageSlide;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _traceController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _messageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _traceFade = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _traceController, curve: Curves.easeInOut),
    );
    _messageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _messageController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _messageSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.easeOutCubic),
    );

    if (widget.hasUpdate) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _messageController.forward();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _traceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasUpdate) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _traceController, _messageController]),
      builder: (context, _) {
        return Stack(
          children: [
            // Glowing footprint traces
            ..._buildGlowTraces(),
            // Partner discovery message
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _messageFade,
                child: SlideTransition(
                  position: _messageSlide,
                  child: Center(child: _buildMessage()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildGlowTraces() {
    final rand = math.Random(99);
    final traces = <Widget>[];
    for (int i = 0; i < 4; i++) {
      final x = 60.0 + rand.nextDouble() * 220;
      final y = 200.0 + rand.nextDouble() * 300;
      traces.add(Positioned(
        left: x,
        top: y,
        child: Opacity(
          opacity: _traceFade.value * _pulse.value * 0.5,
          child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4864A).withOpacity(0.55),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return traces;
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E).withOpacity(0.88),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFD4864A).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4864A).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: _pulse.value,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4864A),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4864A).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.updateMessage,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFFE8C5A0),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
