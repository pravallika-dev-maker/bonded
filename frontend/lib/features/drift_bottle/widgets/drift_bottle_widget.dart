import 'dart:math';
import 'package:flutter/material.dart';

class DriftBottleWidget extends StatefulWidget {
  final Future<void> Function() onTap;

  const DriftBottleWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  State<DriftBottleWidget> createState() => _DriftBottleWidgetState();
}

class _DriftBottleWidgetState extends State<DriftBottleWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  bool _isOpening = false;
  late Animation<double> _upDownAnimation;
  late Animation<double> _leftRightAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Faster loop
    )..repeat(reverse: true);

    _upDownAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _leftRightAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpening) {
      return const SizedBox(width: 140, height: 180);
    }
    
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isOpening = true;
        });
        await widget.onTap();
        if (mounted) {
          setState(() {
            _isOpening = false;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // High-performance glow using RadialGradient instead of expensive BoxShadow blur
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.4),
                    Colors.pinkAccent.withOpacity(0.0),
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
            Image.asset(
              'assets/drift_bottle/v5_drift_bottle_idle.png',
              width: 140,
              height: 180,
              fit: BoxFit.contain,
              cacheWidth: 300, // Optimize memory for the image
            ),
          ],
        ),
        builder: (context, child) {
          final currentOffset = Offset(_leftRightAnimation.value, _upDownAnimation.value);

          return Transform.translate(
            offset: currentOffset,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
