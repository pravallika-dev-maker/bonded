import 'package:flutter/material.dart';
import 'dart:math' as math;

class MemoryFragment {
  final String id;
  final String text;
  final String author;
  final double xFraction;
  final double yFraction;

  const MemoryFragment({
    required this.id,
    required this.text,
    required this.author,
    required this.xFraction,
    required this.yFraction,
  });
}

class MemoryFragmentWidget extends StatefulWidget {
  final MemoryFragment fragment;

  const MemoryFragmentWidget({super.key, required this.fragment});

  @override
  State<MemoryFragmentWidget> createState() => _MemoryFragmentWidgetState();
}

class _MemoryFragmentWidgetState extends State<MemoryFragmentWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _appearController;
  late Animation<double> _floatY;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    )..repeat(reverse: true);

    _appearController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatY = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _appearController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    Future.delayed(
      Duration(milliseconds: math.Random().nextInt(600) + 200),
      () { if (mounted) _appearController.forward(); },
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _appearController]),
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _floatY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0C12).withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8C5A0).withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC97B3A).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD4864A)),
              ),
              const SizedBox(width: 8),
              Text(
                widget.fragment.author == 'partner' ? 'from them' : 'your thought',
                style: TextStyle(
                  fontSize: 9, letterSpacing: 1.5,
                  color: const Color(0xFF9E7E5A).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${widget.fragment.text}"',
            style: const TextStyle(
              fontFamily: 'Georgia', fontSize: 13, fontStyle: FontStyle.italic,
              color: Color(0xFFE8C5A0), height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
