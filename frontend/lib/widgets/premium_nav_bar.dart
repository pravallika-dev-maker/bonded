import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_heart_icon.dart';

class PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasUnsentLetter;
  final bool hasNewInsight;

  const PremiumNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.hasUnsentLetter = true, // Example hardcoded, can be dynamic later
    this.hasNewInsight = true,   // Example hardcoded, can be dynamic later
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF090204).withOpacity(0.75),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.04),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 14,
            bottom: 14 + MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnimatedNavBarItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _AnimatedNavBarItem(
                icon: Icons.sentiment_satisfied_outlined,
                label: 'Feel',
                isActive: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _CenterHeartTab(
                isActive: currentIndex == 2,
                hasNotification: hasUnsentLetter,
                onTap: () => onTabSelected(2),
              ),
              _AnimatedNavBarItem(
                icon: Icons.insights_outlined,
                label: 'Journey',
                isActive: currentIndex == 3,
                hasNotification: hasNewInsight,
                notificationColor: const Color(0xFFCE9B4E), // Gold spark
                onTap: () => onTabSelected(3),
              ),
              _AnimatedNavBarItem(
                icon: Icons.person_outline,
                label: 'You',
                isActive: currentIndex == 4,
                onTap: () => onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool hasNotification;
  final Color notificationColor;

  const _AnimatedNavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasNotification = false,
    this.notificationColor = const Color(0xFF911746),
  });

  @override
  State<_AnimatedNavBarItem> createState() => _AnimatedNavBarItemState();
}

class _AnimatedNavBarItemState extends State<_AnimatedNavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFDCD2AE); // Warm gold/white text for active
    final inactiveColor = const Color(0xFF5E3A4B); // Dim maroon for inactive

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.icon,
                    size: 26, 
                    color: widget.isActive ? activeColor : inactiveColor,
                  ),
                  if (widget.hasNotification)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.notificationColor,
                          border: Border.all(color: const Color(0xFF090204), width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isActive ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 8),
              // Soft active line
              AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 24, // Slightly wider than icon
                  height: 2,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterHeartTab extends StatefulWidget {
  final bool isActive;
  final bool hasNotification;
  final VoidCallback onTap;

  const _CenterHeartTab({
    required this.isActive,
    required this.hasNotification,
    required this.onTap,
  });

  @override
  State<_CenterHeartTab> createState() => _CenterHeartTabState();
}

class _CenterHeartTabState extends State<_CenterHeartTab>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tapController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    // Very slow breathing
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = widget.isActive ? const Color(0xFFDCD2AE) : const Color(0xFF5E3A4B);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _tapAnimation,
        child: ScaleTransition(
          scale: _breatheAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slightly floating icon
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Base glow that is stronger when active
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF911746).withOpacity(widget.isActive ? 0.45 : 0.15),
                              blurRadius: widget.isActive ? 28 : 16,
                              spreadRadius: widget.isActive ? 6 : 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // The AppHeartIcon
                    const AppHeartIcon(size: 48), // Scaled down but still prominent
                    
                    // Notification Dot
                    if (widget.hasNotification)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFCA366C),
                            border: Border.all(color: const Color(0xFF090204), width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Text(
                'Unsent',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 8),
              // Soft active line
              AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 32, // Slightly wider for center tab
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD2AE),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDCD2AE).withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
