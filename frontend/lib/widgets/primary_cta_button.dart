import 'package:flutter/material.dart';

class PrimaryCtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const PrimaryCtaButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon = Icons.favorite,
    this.isLoading = false,
    this.height = 54,
    this.width,
  });

  @override
  State<PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<PrimaryCtaButton> with SingleTickerProviderStateMixin {
  late AnimationController _sheenController;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (_isEnabled) {
      _sheenController.repeat(reverse: false);
    }
  }

  bool get _isEnabled => widget.onTap != null && !widget.isLoading;

  @override
  void didUpdateWidget(covariant PrimaryCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEnabled = oldWidget.onTap != null && !oldWidget.isLoading;
    if (_isEnabled && !wasEnabled) {
      _sheenController.repeat(reverse: false);
    } else if (!_isEnabled && wasEnabled) {
      _sheenController.stop();
      _sheenController.reset();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _isEnabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
          color: _isEnabled ? const Color(0xFF1A1214) : const Color(0xFF1B0F14),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isEnabled
                ? const Color(0xFF911746).withOpacity(0.5)
                : const Color(0xFF3B1525),
            width: 1.2,
          ),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF911746).withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
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
                              color: _isEnabled ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
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
                              color: _isEnabled ? const Color(0xFFDD8F9F) : const Color(0xFF7A4B5C),
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
                      left: -100 + (_sheenController.value * 500),
                      top: 0,
                      bottom: 0,
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.0),
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
    );
  }
}
