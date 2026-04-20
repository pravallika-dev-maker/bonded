import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_screen.dart';

class SendingCodeScreen extends StatefulWidget {
  final String phoneNumber;
  const SendingCodeScreen({super.key, required this.phoneNumber});

  @override
  State<SendingCodeScreen> createState() => _SendingCodeScreenState();
}

class _SendingCodeScreenState extends State<SendingCodeScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate sending delay then push to OTP
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OTPScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0408),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 0.95,
              colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // ── Glowing Heart Logo ──
                const Center(child: _GlowingHeart()),
                
                const SizedBox(height: 48),
                
                // ── Title ──
                const Text(
                  'Just a moment',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // ── Subtitle ──
                const Text(
                  'Sending a code your way...',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9E7A85),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // ── Number Display Box with Pencil Icon ──
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0810),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3D1A25), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('IN', style: TextStyle(fontSize: 10, color: Color(0xFF3A1525))),
                        const SizedBox(width: 8),
                        Text(
                          '+91 ${widget.phoneNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAC7827),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Color(0xFFAC7827),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ── Animated Dots ──
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PulseDot(delay: 0),
                    SizedBox(width: 8),
                    _PulseDot(delay: 1),
                    SizedBox(width: 8),
                    _PulseDot(delay: 2),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // ── Back Link ──
                
                
                const Spacer(),
                
                // ── Bottom Quote ──
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Every connection starts with a small step',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF1A0810),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowingHeart extends StatelessWidget {
  const _GlowingHeart();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFFB52B6E).withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
            ],
          ),
        ),
        const Icon(Icons.favorite, color: Color(0xFFD94480), size: 48),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  final int delay;
  const _PulseDot({required this.delay});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay * 300), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: FadeTransition(
        opacity: _anim,
        child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD94480))),
      ),
    );
  }
}
