import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Splash Content — for use within PageView
// ─────────────────────────────────────────────────────────────────────────────

class SplashContent extends StatefulWidget {
  const SplashContent({super.key});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> with TickerProviderStateMixin {
  late AnimationController _beatController;
  late Animation<double> _beatAnim;
  late AnimationController _waveController;
  late Animation<double> _wave1, _wave2, _wave3;

  @override
  void initState() {
    super.initState();
    _beatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _beatAnim = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _beatController, curve: Curves.easeInOutQuad));
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _wave1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _waveController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutSine)));
    _wave2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _waveController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutSine)));
    _wave3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _waveController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutSine)));
  }

  @override
  void dispose() {
    _beatController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: Listenable.merge([_beatController, _waveController]),
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(220, 220), painter: _WaveRingsPainter(wave1: _wave1.value, wave2: _wave2.value, wave3: _wave3.value)),
                Transform.scale(scale: _beatAnim.value, child: const _HeartStack()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 44),
        const Text('Bonded', style: TextStyle(fontFamily: 'Georgia', fontSize: 52, color: Colors.white, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        const Text('CLOSENESS THROUGH\n SPACE', textAlign: TextAlign.left, style: TextStyle(fontSize: 10.5, color: Color(0xFF9E7A85), letterSpacing: 2.8, height: 1.8)),
        const Spacer(flex: 6),
      ],
    );
  }
}

class _HeartStack extends StatelessWidget {
  const _HeartStack();
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFB52B6E).withOpacity(0.35), blurRadius: 55, spreadRadius: 10)])),
      const Icon(Icons.favorite_rounded, size: 140, color: Color(0xFF3A0C1A)),
      const Icon(Icons.favorite_rounded, size: 112, color: Color(0xFF5A1530)),
      const Icon(Icons.favorite_rounded, size: 86, color: Color(0xFF7A1E40)),
      ShaderMask(blendMode: BlendMode.srcIn, shaderCallback: (bounds) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8508A), Color(0xFF9B2255)]).createShader(bounds), child: const Icon(Icons.favorite_rounded, size: 62, color: Colors.white)),
    ]);
  }
}

class _WaveRingsPainter extends CustomPainter {
  final double wave1, wave2, wave3;
  _WaveRingsPainter({required this.wave1, required this.wave2, required this.wave3});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    _drawRing(canvas, cx, cy, wave1); _drawRing(canvas, cx, cy, wave2); _drawRing(canvas, cx, cy, wave3);
  }
  void _drawRing(Canvas canvas, double cx, double cy, double t) {
    if (t <= 0) return;
    final r = 50.0 + t * 60.0;
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFB52B6E).withOpacity((1.0 - t) * 0.20)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }
  @override
  bool shouldRepaint(covariant _WaveRingsPainter old) => true;
}
