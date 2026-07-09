import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_heart_icon.dart';
import '../widgets/primary_cta_button.dart';
import 'name_entry_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Slight delay so the screen settles before animating in
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 1.0,
              colors: [Color(0xFF2A0814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),

                      // ── Soft Entry Icon ──
                      const Center(child: AppHeartIcon(size: 80)),

                      const SizedBox(height: 36),

                      // ── Soft Entry Line ──
                      Center(
                        child: Text(
                          'You\'re here…',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF8B6774),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Main Welcome Message ──
                      const Text(
                        'Sometimes, stepping back\nis how we move',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const Text(
                        'closer.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFE89FB8),
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Divider glow line ──
                      Container(
                        height: 1,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF911746).withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Consolidated Poetic & Purpose Quote ──
                      const Text(
                        'Bonded is a quiet space to understand what you feel, reflect on your connection, and grow closer at your own pace.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF8B6774),
                          height: 1.6,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ── Reassurance ──
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: Color(0xFF3B1F2B),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nothing you write here is shared\nwithout your choice.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF5E3A4B),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── CTA Button ──
                      PrimaryCtaButton(
                        text: 'Begin your journey',
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const NameEntryScreen(),
                            ),
                          );
                        },
                      ),
                      

                      const Spacer(flex: 1),

                      // ── Secondary Bottom Line ──
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'Every strong bond begins with understanding',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF2E1922),
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
        ),
      ),
    );
  }
}

