import 'package:flutter/material.dart';

class PremiumSheen extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Duration pauseDuration;
  final Color sheenColor;
  final double sheenOpacity;
  final BlendMode blendMode;
  final bool continuous;

  const PremiumSheen({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.pauseDuration = const Duration(seconds: 8),
    this.sheenColor = const Color(0xFFE89FB8), // Rose/pink highlight
    this.sheenOpacity = 0.25,
    this.blendMode = BlendMode.srcATop,
    this.continuous = false,
  });

  @override
  State<PremiumSheen> createState() => _PremiumSheenState();
}

class _PremiumSheenState extends State<PremiumSheen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      if (widget.continuous) {
        await _controller.forward(from: 0.0);
        if (!mounted) break;
        await Future.delayed(widget.pauseDuration);
      } else {
        await Future.delayed(widget.pauseDuration);
        if (!mounted) break;
        // The ticker is muted automatically when not visible
        await _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0.0) return widget.child;

        final t = _controller.value;
        // Sweep from left to right diagonally
        final startX = -2.0 + (t * 4.0); // -2.0 to 2.0
        final endX = startX + 1.0;

        return ShaderMask(
          blendMode: widget.blendMode,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(startX, -1.0),
              end: Alignment(endX, 1.0),
              colors: [
                Colors.transparent,
                widget.sheenColor.withValues(alpha: widget.sheenOpacity),
                Colors.transparent,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
