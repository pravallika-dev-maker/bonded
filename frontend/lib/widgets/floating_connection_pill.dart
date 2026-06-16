import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class FloatingConnectionPill extends StatefulWidget {
  final String partnerName;
  final String inviteCode;
  final VoidCallback? onJoinPressed;

  const FloatingConnectionPill({
    super.key,
    required this.partnerName,
    this.inviteCode = "JADE4", // Default onboarding matching mock
    this.onJoinPressed,
  });

  @override
  State<FloatingConnectionPill> createState() => _FloatingConnectionPillState();
}

class _FloatingConnectionPillState extends State<FloatingConnectionPill>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _expandController;

  bool _isExpanded = false;
  String _inviteCode = "JADE4";
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _inviteCode = widget.inviteCode;

    // Idle floating, breathing glow
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Expand/Collapse animation
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fetchInviteCode();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _fetchInviteCode() async {
    try {
      final res = await ApiService.getInviteCode();
      if (mounted && res['code'] != null) {
        setState(() {
          // Clean the code representation from spaces/dots for robust copy/share
          _inviteCode = res['code']
              .toString()
              .replaceAll(' · ', '')
              .replaceAll(' ', '')
              .trim();
        });
      }
    } catch (_) {
      // Fallback to widget default (JADE4) if offline/error
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Code '$_inviteCode' copied to clipboard ✨"),
        backgroundColor: const Color(0xFF280014),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _shareCode() {
    Share.share(
      "I'm using Bonded to take a small space and understand things better. Join me using my code: $_inviteCode"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _expandController]),
        builder: (context, child) {
          final breathe = _idleController.value;
          final expandProgress = Curves.easeOutCubic.transform(_expandController.value);

          // Highly compact card heights: 42px collapsed, 108px expanded
          // Added extra height for 'enter code' button
          final pillHeight = 42.0 + (expandProgress * (widget.onJoinPressed != null ? 82.0 : 66.0)); 
          final pillWidth = MediaQuery.of(context).size.width * 0.76 + (expandProgress * (MediaQuery.of(context).size.width * 0.12));

          const double borderRadius = 24.0;

          return GestureDetector(
            onTap: _toggleExpand,
            child: Transform.translate(
              offset: Offset(0, math.sin(breathe * math.pi) * 3 * (1 - expandProgress)),
              child: Container(
                width: pillWidth,
                height: pillHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: const Color(0xFF280014).withValues(alpha: 0.70 + (expandProgress * 0.15)),
                  border: Border.all(
                    color: const Color(0xFF8A2E55).withValues(alpha: 0.25 + (breathe * 0.10)),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2E55).withValues(alpha: 0.10 + (breathe * 0.06)),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Stack(
                      clipBehavior: Clip.hardEdge, // Prevents layout/render glitches
                      children: [
                        // Soft glow wave on expand
                        Positioned(
                          top: -40,
                          left: -40,
                          child: Opacity(
                            opacity: expandProgress * 0.4,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFDD8F9F).withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Collapsed state — centered row ──
                        Positioned.fill(
                          child: Opacity(
                            opacity: (1.0 - expandProgress).clamp(0.0, 1.0),
                            child: IgnorePointer(
                              ignoring: _isExpanded,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: _OrbitingHearts(animationValue: breathe),
                                      ),
                                      Text(
                                        "Waiting for ${widget.partnerName}",
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFF6FB),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFF9E7E5A),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Expanded state — centered Column ──
                        Positioned.fill(
                          child: Opacity(
                            opacity: expandProgress.clamp(0.0, 1.0),
                            child: IgnorePointer(
                              ignoring: !_isExpanded,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Share this code with ${widget.partnerName} to enter your shared space.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: const Color(0xFFCFA7BA).withValues(alpha: 0.8),
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Glowing Invite Code Capsule
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF8A2E55).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(0xFFDD8F9F).withValues(alpha: 0.35),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                   const Icon(Icons.radio_button_unchecked, size: 8, color: Color(0xFF9E7E5A)),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _inviteCode,
                                                    style: const TextStyle(
                                                      fontFamily: 'Georgia',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 2.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Copy button inside the code box
                                                  GestureDetector(
                                                    onTap: _copyCode,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        _copied ? Icons.check : Icons.copy,
                                                        size: 10,
                                                        color: _copied ? const Color(0xFF5DB373) : const Color(0xFF9E7E5A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Share button outside-right side of the code box
                                            GestureDetector(
                                              onTap: _shareCode,
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF8A2E55).withValues(alpha: 0.12),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFFDD8F9F).withValues(alpha: 0.35),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.share,
                                                  size: 12,
                                                  color: Color(0xFF9E7E5A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        if (widget.onJoinPressed != null) ...[
                                          const SizedBox(height: 12),
                                          GestureDetector(
                                            onTap: widget.onJoinPressed,
                                            child: Text(
                                              "Have a code instead? Enter it here",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFE89FB8).withValues(alpha: 0.9),
                                                decoration: TextDecoration.underline,
                                                decorationColor: const Color(0xFFE89FB8).withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbitingHearts extends StatelessWidget {
  final double animationValue;

  const _OrbitingHearts({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(-3 + animationValue * 2, -1 + animationValue * 2),
          child: Transform.scale(
            scale: 0.8 + animationValue * 0.2,
            child: const Icon(Icons.favorite, size: 9, color: Color(0xFF8A2E55)),
          ),
        ),
        Transform.translate(
          offset: Offset(3 - animationValue * 2, 1 - animationValue * 2),
          child: Transform.scale(
            scale: 1.0 - animationValue * 0.2,
            child: const Icon(Icons.favorite, size: 10, color: Color(0xFFDD8F9F)),
          ),
        ),
      ],
    );
  }
}
