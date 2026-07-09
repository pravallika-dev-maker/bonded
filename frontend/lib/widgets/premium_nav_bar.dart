import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_heart_icon.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PremiumNavBar — Elegant, minimal bottom navigation with a sliding thread indicator
// ─────────────────────────────────────────────────────────────────────────────

class PremiumNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasUnsentLetter;
  final bool hasNewInsight;

  const PremiumNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.hasUnsentLetter = true,
    this.hasNewInsight = true,
  });

  @override
  State<PremiumNavBar> createState() => _PremiumNavBarState();
}

class _PremiumNavBarState extends State<PremiumNavBar>
    with TickerProviderStateMixin {
  // Smooth sliding indicator animation
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;
  late List<AnimationController> _glowCtrls;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInOutCubic));

    _glowCtrls = List.generate(5, (_) =>
        AnimationController(vsync: this, duration: const Duration(milliseconds: 550)));
    _glowCtrls[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(PremiumNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _slideAnim.value;
      _slideAnim = Tween<double>(
        begin: from,
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInOutCubic));
      _slideCtrl.forward(from: 0);
      _glowCtrls[widget.currentIndex].forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    for (final c in _glowCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0307).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFDD8F9F).withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12 + bottomPad),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabW = constraints.maxWidth / 5;
                    const indicatorW = 16.0;

                    return AnimatedBuilder(
                      animation: _slideAnim,
                      builder: (context, _) {
                        final cx = _slideAnim.value * tabW + tabW / 2;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ── Sliding elegant underline thread ──
                            Positioned(
                              left: cx - indicatorW / 2,
                              bottom: 0,
                              child: Container(
                                width: indicatorW,
                                height: 2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEEDFC8), // Champagne
                                      Color(0xFFDD8F9F), // Rose/Pink
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDD8F9F).withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ── Tab items ──
                            Row(
                              children: [
                                _TabItem(
                                  width: tabW,
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  isActive: widget.currentIndex == 0,
                                  onTap: () => widget.onTabSelected(0),
                                  glowCtrl: _glowCtrls[0],
                                ),
                                _TabItem(
                                  width: tabW,
                                  icon: Icons.sentiment_satisfied_rounded,
                                  label: 'Feel',
                                  isActive: widget.currentIndex == 1,
                                  onTap: () => widget.onTabSelected(1),
                                  glowCtrl: _glowCtrls[1],
                                ),
                                _CenterHeartTab(
                                  width: tabW,
                                  isActive: widget.currentIndex == 2,
                                  hasNotification: widget.hasUnsentLetter,
                                  onTap: () => widget.onTabSelected(2),
                                  glowCtrl: _glowCtrls[2],
                                ),
                                _TabItem(
                                  width: tabW,
                                  icon: Icons.insights_rounded,
                                  label: 'Journey',
                                  isActive: widget.currentIndex == 3,
                                  hasNotification: widget.hasNewInsight,
                                  notificationColor: const Color(0xFFCE9B4E),
                                  onTap: () => widget.onTabSelected(3),
                                  glowCtrl: _glowCtrls[3],
                                ),
                                _TabItem(
                                  width: tabW,
                                  icon: Icons.person_rounded,
                                  label: 'You',
                                  isActive: widget.currentIndex == 4,
                                  onTap: () => widget.onTabSelected(4),
                                  glowCtrl: _glowCtrls[4],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Regular Tab Item ────────────────────────────────────────────────────────

class _TabItem extends StatefulWidget {
  final double width;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AnimationController glowCtrl;
  final bool hasNotification;
  final Color notificationColor;

  const _TabItem({
    required this.width,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.glowCtrl,
    this.hasNotification = false,
    this.notificationColor = const Color(0xFF911746),
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  static const _active = Color(0xFFEEDFC8);
  static const _inactive = Color(0xFF5A3E4D);

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.glowCtrl.forward(from: 0);
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _pressAnim,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ultra-subtle sparkles on tap
                    AnimatedBuilder(
                      animation: widget.glowCtrl,
                      builder: (context, _) => CustomPaint(
                        size: const Size(40, 40),
                        painter: _MicroSparklesPainter(progress: widget.glowCtrl.value),
                      ),
                    ),
                    // Icon scaling
                    AnimatedScale(
                      scale: widget.isActive ? 1.10 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedOpacity(
                            opacity: widget.isActive ? 1.0 : 0.48,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              widget.icon,
                              size: 22,
                              color: widget.isActive ? _active : _inactive,
                            ),
                          ),
                          if (widget.hasNotification)
                            Positioned(
                              top: -1,
                              right: -2,
                              child: Container(
                                width: 6.5,
                                height: 6.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.notificationColor,
                                  border: Border.all(
                                    color: const Color(0xFF0A0307),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontFamily: 'Georgia',
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                    color: widget.isActive ? _active : _inactive,
                    letterSpacing: widget.isActive ? 0.1 : 0.0,
                  ),
                ),
              ),
              const SizedBox(height: 7), // Spacing for sliding underline at bottom of layout
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Center Heart Tab ────────────────────────────────────────────────────────

class _CenterHeartTab extends StatefulWidget {
  final double width;
  final bool isActive;
  final bool hasNotification;
  final VoidCallback onTap;
  final AnimationController glowCtrl;

  const _CenterHeartTab({
    required this.width,
    required this.isActive,
    required this.hasNotification,
    required this.onTap,
    required this.glowCtrl,
  });

  @override
  State<_CenterHeartTab> createState() => _CenterHeartTabState();
}

class _CenterHeartTabState extends State<_CenterHeartTab>
    with TickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  static const _active = Color(0xFFEEDFC8);
  static const _inactive = Color(0xFF5A3E4D);

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.98, end: 1.03).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOutSine));

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.glowCtrl.forward(from: 0);
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _pressAnim,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ultra-subtle sparkles on tap
                    AnimatedBuilder(
                      animation: widget.glowCtrl,
                      builder: (context, _) => CustomPaint(
                        size: const Size(44, 40),
                        painter: _MicroSparklesPainter(
                          progress: widget.glowCtrl.value,
                          count: 6,
                        ),
                      ),
                    ),
                    // Breathing active/inactive heart
                    ScaleTransition(
                      scale: _breatheAnim,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            opacity: widget.isActive ? 1.0 : 0.55,
                            duration: const Duration(milliseconds: 200),
                            child: const AppHeartIcon(size: 38),
                          ),
                          if (widget.hasNotification)
                            Positioned(
                              top: 1,
                              right: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFCA366C),
                                  border: Border.all(
                                    color: const Color(0xFF0A0307),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Unsent',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontFamily: 'Georgia',
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                    color: widget.isActive ? _active : _inactive,
                    letterSpacing: widget.isActive ? 0.1 : 0.0,
                  ),
                ),
              ),
              const SizedBox(height: 7), // Spacing matching regular items
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Micro Sparkle Painter ───────────────────────────────────────────────────

class _MicroSparklesPainter extends CustomPainter {
  final double progress;
  final int count;

  const _MicroSparklesPainter({
    required this.progress,
    this.count = 6, // Refined count for clean subtleness
  });

  // Balanced pastel pinks and champagne golds
  static const _palette = [
    Color(0xFFFFC2D1), // Subtle fairy pink
    Color(0xFFFFE69F), // Soft warm gold spark
    Color(0xFFFCA5C2), // Gentle rose blush
    Color(0xFFEDD9C0), // Elegant champagne gold
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 0.80) return;

    final center = Offset(size.width / 2, size.height / 2);
    final rng = math.Random(42);
    final norm = progress / 0.80;
    
    // Decelerating outward travel
    final ease = Curves.easeOutCubic.transform(norm);
    
    // Smooth fade: quick rise, gradual fade
    final opacity = norm < 0.15 ? norm / 0.15 : 1.0 - ((norm - 0.15) / 0.85);

    for (int i = 0; i < count; i++) {
      final color = _palette[i % _palette.length];
      
      // Arc angle: upward vertical fan
      final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * math.pi * 0.75;
      
      // Short travel distance (9 - 18px)
      final dist = ease * (9 + rng.nextDouble() * 9);
      
      // Delicate, subtle particle sizes (1.0 - 2.4 px)
      final pSize = (1.0 + rng.nextDouble() * 1.4) * (1.0 - ease * 0.4);

      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );

      // Soft, subtle alpha max
      final alpha = (opacity * 0.80).clamp(0.0, 1.0);
      
      // Soft glow aura around the particles
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

      // Mix in some tiny sparkling star crosses
      if (i % 3 == 0) {
        final starPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.85)
          ..strokeWidth = 0.85
          ..style = PaintingStyle.stroke;
        final r = pSize * 1.2;
        canvas.drawLine(Offset(pos.dx - r, pos.dy), Offset(pos.dx + r, pos.dy), starPaint);
        canvas.drawLine(Offset(pos.dx, pos.dy - r), Offset(pos.dx, pos.dy + r), starPaint);
      } else {
        canvas.drawCircle(pos, pSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MicroSparklesPainter old) => old.progress != progress;
}
