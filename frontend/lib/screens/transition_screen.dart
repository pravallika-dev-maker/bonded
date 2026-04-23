import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_heart_icon.dart';
import 'home_screen.dart';

class TransitionScreen extends StatefulWidget {
  final String userName;
  final String partnerName;
  const TransitionScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInCtrl;
  late AnimationController _fadeOutCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  int _messageIndex = 0;
  static const List<String> _messages = [
    "This is not about being apart...\nIt's about seeing each other more clearly.",
    "Take a deep breath.\nThis time is a gift, not a gap.",
    "Your space is ready.\nWe'll be here whenever you need.",
  ];

  @override
  void initState() {
    super.initState();

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeOutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);
    _fadeOut = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) return;
      setState(() => _messageIndex = i);
      
      _fadeOutCtrl.reset();
      await _fadeInCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (i < _messages.length - 1) {
        await _fadeOutCtrl.forward();
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => HomeScreen(
          userName: widget.userName,
          partnerName: widget.partnerName,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
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

                  // Heart Icon
                  const AppHeartIcon(size: 80),

                  const Spacer(flex: 1),

                  // Titles
                  const Text(
                    'Take this time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'gently',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFE89FB8),
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'This space is yours now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6B4B55),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Pagination Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_messages.length, (index) {
                      final isActive = index == _messageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? const Color(0xFFE89FB8) : const Color(0xFF4D1C2D),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Fading Quote Card
                  AnimatedBuilder(
                    animation: Listenable.merge([_fadeIn, _fadeOut]),
                    builder: (context, _) {
                      final opacity = (_fadeIn.value * (1.0 - _fadeOut.value)).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF260D17),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _messages[_messageIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFE8C6D3),
                              height: 1.6,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  const Text(
                    '"Distance only works when it\'s respected"',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3A1E28),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
