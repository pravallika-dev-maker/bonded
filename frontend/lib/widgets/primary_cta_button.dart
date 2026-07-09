import 'package:flutter/material.dart';

class PrimaryCtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final Gradient? gradient;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const PrimaryCtaButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.favorite,
    this.isLoading = false,
    this.height = 54,
    this.width,
    this.gradient,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  State<PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<PrimaryCtaButton> with TickerProviderStateMixin {
  late AnimationController _sheenController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (_isEnabled) {
      _sheenController.repeat();
    }

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  bool get _isEnabled => widget.onTap != null && !widget.isLoading;

  @override
  void didUpdateWidget(covariant PrimaryCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEnabled = oldWidget.onTap != null && !oldWidget.isLoading;
    if (_isEnabled && !wasEnabled) {
      _sheenController.repeat();
    } else if (!_isEnabled && wasEnabled) {
      _sheenController.stop();
      _sheenController.reset();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = _isEnabled
        ? const LinearGradient(
            colors: [
              Color(0xFFBD386A),
              Color(0xFF781E43),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF160E12),
              Color(0xFF160E12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final defaultBorderColor = _isEnabled
        ? const Color(0xFFE89FB8).withValues(alpha: 0.45)
        : const Color(0xFF2A161E);

    final defaultBoxShadow = _isEnabled
        ? [
            BoxShadow(
              color: const Color(0xFFBD386A).withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF781E43).withValues(alpha: 0.20),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ]
        : <BoxShadow>[];

    final defaultTextColor = _isEnabled ? const Color(0xFFFFF0F3) : const Color(0xFF5C3C48);
    final defaultIconColor = _isEnabled ? const Color(0xFFFFF0F3) : const Color(0xFF4C303B);

    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTapDown: (_) {
          if (_isEnabled) _pressController.forward();
        },
        onTapUp: (_) {
          if (_isEnabled) {
            _pressController.reverse();
            widget.onTap!();
          }
        },
        onTapCancel: () {
          if (_isEnabled) _pressController.reverse();
        },
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: widget.gradient ?? defaultGradient,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: widget.borderColor ?? defaultBorderColor,
                width: 1.2,
              ),
              boxShadow: widget.boxShadow ?? defaultBoxShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: widget.textColor ?? defaultTextColor,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  size: 18,
                                  color: widget.iconColor ?? defaultIconColor,
                                ),
                                const SizedBox(width: 14),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.3,
                                  color: widget.textColor ?? defaultTextColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (_isEnabled)
                    AnimatedBuilder(
                      animation: _sheenController,
                      builder: (context, child) {
                        return Positioned(
                          left: -150 + (_sheenController.value * 650),
                          top: 0,
                          bottom: 0,
                          child: Transform.rotate(
                            angle: 0.3,
                            child: Container(
                              width: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.06),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
