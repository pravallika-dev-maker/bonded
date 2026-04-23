import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String partnerName;
  const HomeScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _glowAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
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
        body: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.5),
                  radius: 1.1 * _glowAnim.value, // Animated glow radius
                  colors: const [
                    Color(0xFF330C1C), // Slightly brighter warm core
                    Color(0xFF090204),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 3),

                      // ── Top greeting ──
                      Text(
                        'Hello, ${widget.userName}.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF8A6530),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Heart ──
                      Center(child: _PulsingHeart()),

                      const SizedBox(height: 36),

                      // ── Main Title ──
                      const Center(
                        child: Text(
                          'Your space',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'is ready.',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFE89FB8),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── Waiting card ──
                      _WaitingCard(partnerName: widget.partnerName),

                      const SizedBox(height: 16),

                      // ── Reflection section ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF140A10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2E1020),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'WHILE YOU WAIT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Color(0xFF8A6530),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '"Take this time for clarity.\nYour reflection matters too."',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF7A5060),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => MainDashboardScreen(
                                        userName: widget.userName,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.self_improvement_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Begin your reflection',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF911746),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── Bottom quote ──
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: const Text(
                            'Some connections are worth pausing for.',
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

// ── Waiting Card ──────────────────────────────────────────────────────────────
class _WaitingCard extends StatelessWidget {
  final String partnerName;
  const _WaitingCard({required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0711),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3D1627), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF911746).withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF260814),
              border: Border.all(color: const Color(0xFF5A1630), width: 1),
            ),
            child: const Center(
              child: Icon(Icons.hourglass_top_outlined,
                  size: 20, color: Color(0xFF8A6530)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waiting for $partnerName to join',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'They\'ll connect once they enter your code',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5E3A4B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing Heart ─────────────────────────────────────────────────────────────
class _PulsingHeart extends StatefulWidget {
  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1F0611),
          border: Border.all(color: const Color(0xFF5A1630), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF911746).withOpacity(0.22),
              blurRadius: 36,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                String.fromCharCode(Icons.favorite.codePoint),
                style: TextStyle(
                  fontSize: 38,
                  fontFamily: Icons.favorite.fontFamily,
                  package: Icons.favorite.fontPackage,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.0
                    ..color = const Color(0xFFCA366C),
                ),
              ),
              Text(
                String.fromCharCode(Icons.favorite.codePoint),
                style: TextStyle(
                  fontSize: 38,
                  fontFamily: Icons.favorite.fontFamily,
                  package: Icons.favorite.fontPackage,
                  color: const Color(0xFF8F1643),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
