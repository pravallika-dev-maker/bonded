import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_heart_icon.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class SendingCodeScreen extends StatefulWidget {
  final String phoneNumber;
  const SendingCodeScreen({super.key, required this.phoneNumber});

  @override
  State<SendingCodeScreen> createState() => _SendingCodeScreenState();
}

class _SendingCodeScreenState extends State<SendingCodeScreen> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _performSendCode();
  }

  Future<void> _performSendCode() async {
    try {
      // Trigger the real ApiService call
      await ApiService.sendCode(
        countryCode: '+91',
        phoneNumber: widget.phoneNumber,
      );

      // On successful send, push OTP screen replacement
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OTPScreen(
            phoneNumber: widget.phoneNumber,
            countryCode: '+91', // Hardcoded as per the current sendCode implementation
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090204),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.25),
              radius: 0.9,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // ── Glowing Heart Logo ──
                const Center(child: AppHeartIcon(size: 104)),
                
                const Spacer(flex: 2),
                
                // ── Title ──
                Text(
                  _hasError ? 'Oops, sorry!' : 'Just a moment',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                // ── Subtitle ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _hasError ? _errorMessage : 'Sending a code your way...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: _hasError ? const Color(0xFFDD8F9F) : const Color(0xFF8B6774),
                      height: 1.4,
                    ),
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // ── Number Display Box ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0711),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF3D1627), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'IN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A1A2C),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '+91 ${widget.phoneNumber.isNotEmpty ? widget.phoneNumber : '98765 43210'}',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6D0D8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // ── Animated Dots / Retry ──
                if (_hasError)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hasError = false;
                        _errorMessage = '';
                      });
                      _performSendCode();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B0711),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF911746).withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFDD8F9F)),
                          SizedBox(width: 8),
                          Text(
                            'Tap to Retry',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDD8F9F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PulseDot(delay: 0),
                      SizedBox(width: 12),
                      _PulseDot(delay: 1),
                      SizedBox(width: 12),
                      _PulseDot(delay: 2),
                    ],
                  ),
                
                const Spacer(flex: 2),
                
                // ── Back Link ──
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Column(
                    children: [
                      const Text(
                        "That's not the right number",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF634151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 1,
                        width: 170,
                        color: const Color(0xFF3D1F2D),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // ── Bottom Quote ──
                const Padding(
                  padding: EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Every connection starts with a small step',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF452B36),
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
        child: Container(width: 9, height: 9, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFBA225B))),
      ),
    );
  }
}
