import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_heart_icon.dart';
import 'transition_screen.dart';

class PromiseScreen extends StatefulWidget {
  final String userName;
  final String partnerName;

  const PromiseScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<PromiseScreen> createState() => _PromiseScreenState();
}

class _PromiseScreenState extends State<PromiseScreen> {
  bool _isChecked = false;

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
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.0,
              colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Header
                  Text(
                    'BEFORE WE BEGIN...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: const Color(0xFFAC7827).withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Heart Icon
                  const AppHeartIcon(size: 80),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle
                  const Text(
                    'Just one small promise',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8A6530),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Main Quote
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: '" A little distance can\nbring\na lot of clarity...\n'),
                        TextSpan(
                          text: 'if you allow it. "',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFE89FB8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // The Promise Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D1524),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Watermark Heart
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Icon(
                            Icons.favorite,
                            size: 60,
                            color: const Color(0xFF4D1C2D),
                          ),
                        ),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MY DAILY PROMISE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFFAC7827).withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPromiseLine("I will respect this space."),
                            const SizedBox(height: 8),
                            _buildPromiseLine("I will take this time to reflect,\nnot react."),
                            const SizedBox(height: 8),
                            _buildPromiseLine("I will allow distance to help me\nunderstand, not avoid."),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Text Above Button
                  const Text(
                    '"Distance only works when it\'s respected"',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6B4B55),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Interactive Checkbox Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isChecked ? const Color(0xFF1A1214) : const Color(0xFF0D080A),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _isChecked 
                              ? const Color(0xFF911746).withOpacity(0.5) 
                              : const Color(0xFF26151B),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isChecked ? const Color(0xFFDD8F9F) : Colors.transparent,
                              border: Border.all(
                                color: _isChecked ? const Color(0xFFDD8F9F) : const Color(0xFF3B1F2B),
                                width: 1.5,
                              ),
                            ),
                            child: _isChecked
                                ? const Icon(Icons.check, size: 16, color: Color(0xFF1A1214))
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "I understand and I'm ready",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: _isChecked ? FontWeight.w600 : FontWeight.normal,
                              color: _isChecked ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Step into the space Button
                  GestureDetector(
                    onTap: _isChecked ? _proceedToTransition : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _isChecked 
                            ? const Color(0xFF1A1214) 
                            : const Color(0xFF0D080A),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _isChecked 
                              ? const Color(0xFF911746).withOpacity(0.5) 
                              : const Color(0xFF26151B),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: _isChecked ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Step into the space",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                              color: _isChecked ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // I'll read this later link
                  GestureDetector(
                    onTap: _proceedToTransition, // Allows skipping to transition too
                    child: const Text(
                      "I'll read this later",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6B4B55),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF4C2735),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  const Text(
                    'What is this space for?',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2C141D),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromiseLine(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFE89FB8),
            height: 1.4,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFFE8C6D3),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _proceedToTransition() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransitionScreen(
          userName: widget.userName,
          partnerName: widget.partnerName,
        ),
      ),
    );
  }
}
