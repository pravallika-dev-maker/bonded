import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum JoinCodeState { idle, error, success }

class JoinWithCodeScreen extends StatefulWidget {
  const JoinWithCodeScreen({super.key});

  @override
  State<JoinWithCodeScreen> createState() => _JoinWithCodeScreenState();
}

class _JoinWithCodeScreenState extends State<JoinWithCodeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  JoinCodeState _state = JoinCodeState.idle;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _shakeController.reset();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool get _hasInput => _codeController.text.trim().isNotEmpty;

  void _onConnect() {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim().toUpperCase();

    // Simulate validation: valid if matches WORD-N pattern (letters + dash/dot + digit)
    final valid = RegExp(r'^[A-Z]{3,6}[\s\-·]+\d$').hasMatch(code) ||
        code.length >= 5;

    if (!valid) {
      setState(() => _state = JoinCodeState.error);
      _shakeController.forward();
    } else {
      setState(() => _state = JoinCodeState.success);
    }
  }

  @override
  Widget build(BuildContext context) {

    // ── Dynamic colours based on state ──
    Color borderColor = const Color(0xFF3D1627);
    if (_state == JoinCodeState.error) {
      borderColor = const Color(0xFF7A1B29);
    } else if (_state == JoinCodeState.success) {
      borderColor = const Color(0xFF194D2C);
    } else if (_focusNode.hasFocus || _hasInput) {
      borderColor = const Color(0xFF911746);
    }

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
              radius: 0.95,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),

                    // ── Back button ──
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_new,
                              size: 14, color: Color(0xFF5E3A4B)),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF5E3A4B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Decorative Heart ──
                    Center(child: _TwoHearts()),

                    const Spacer(flex: 1),

                    // ── Emotional Header ──
                    const Text(
                      'Someone\'s waiting',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const Text(
                      'for you',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFE89FB8),
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Subtext ──
                    const Text(
                      'A small code… to begin something\nmeaningful together.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5E3A4B),
                        height: 1.6,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Input Label ──
                    const Text(
                      'THEIR CODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B1525),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Code Input Field (shake on error) ──
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final dx = _state == JoinCodeState.error
                            ? sin(_shakeAnim.value * pi * 4) * 8
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B0711),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.4),
                          boxShadow: _state == JoinCodeState.success
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF194D2C)
                                        .withOpacity(0.18),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                focusNode: _focusNode,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: _state == JoinCodeState.success
                                      ? const Color(0xFF5DB373)
                                      : Colors.white,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'e.g.  ROSE · 7',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF452B36),
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1,
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    _hasInput ? _onConnect() : null,
                              ),
                            ),
                            if (_state == JoinCodeState.success)
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF5DB373), size: 20)
                            else if (_state == JoinCodeState.error)
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF962335), size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── State feedback line ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _state == JoinCodeState.error
                          ? _ErrorBanner()
                          : _state == JoinCodeState.success
                              ? _SuccessBanner()
                              : const Text(
                                  'Make sure it\'s entered exactly as shared',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF3B1F2B),
                                  ),
                                ),
                    ),

                    const Spacer(flex: 1),

                    // ── Primary CTA Button ──
                    GestureDetector(
                      onTap: _hasInput && _state != JoinCodeState.success ? _onConnect : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _state == JoinCodeState.success
                              ? const Color(0xFF0C1F15)
                              : _hasInput 
                                  ? const Color(0xFF1A1214) 
                                  : const Color(0xFF0D080A),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: _state == JoinCodeState.success
                                ? const Color(0xFF194D2C)
                                : _hasInput 
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
                              color: _state == JoinCodeState.success
                                  ? const Color(0xFF5DB373)
                                  : _hasInput ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _state == JoinCodeState.success
                                  ? 'You\'re connected ✓'
                                  : 'Connect',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                                color: _state == JoinCodeState.success
                                    ? const Color(0xFF5DB373)
                                    : _hasInput ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Privacy line ──
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shield_outlined,
                              size: 13, color: Color(0xFF3B1F2B)),
                          SizedBox(width: 8),
                          Text(
                            'Your connection stays private and secure',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3B1F2B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Secondary Option ──
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Don't have a code?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E3A4B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Column(
                              children: [
                                const Text(
                                  'Create one instead',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A6530),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: 1,
                                  width: 120,
                                  color: const Color(0xFF5A3D1F),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Bottom emotional quote ──
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: const Text(
                          'Every connection begins with a small step',
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
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF260A10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A151D), width: 1.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF962335), size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "That code didn't match… check once?",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFFB55D6A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success Banner ────────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1F15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF194D2C), width: 1.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF5DB373), size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You found each other here.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF5DB373),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Two layered hearts decoration ────────────────────────────────────────────
class _TwoHearts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        children: [
          // Back heart (offset slightly)
          Positioned(
            left: 6,
            top: 4,
            child: _heartIcon(52, const Color(0xFF3D1020)),
          ),
          // Front heart
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1F0611),
                border: Border.all(color: const Color(0xFF5A1630), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF911746).withOpacity(0.2),
                    blurRadius: 28,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(child: _heartIcon(26, const Color(0xFF8F1643))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heartIcon(double size, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          String.fromCharCode(Icons.favorite.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: Icons.favorite.fontFamily,
            package: Icons.favorite.fontPackage,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8
              ..color = const Color(0xFFCA366C),
          ),
        ),
        Text(
          String.fromCharCode(Icons.favorite.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: Icons.favorite.fontFamily,
            package: Icons.favorite.fontPackage,
            color: color,
          ),
        ),
      ],
    );
  }
}


