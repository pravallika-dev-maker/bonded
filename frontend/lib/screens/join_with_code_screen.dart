import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'promise_screen.dart';
import 'partner_invite_screen.dart';
import '../services/api_service.dart';
import '../services/app_event_bus.dart';

enum JoinCodeState { idle, loading, error, success }

class JoinWithCodeScreen extends StatefulWidget {
  final String? userName;
  final bool fromDashboard;
  const JoinWithCodeScreen({super.key, this.userName, this.fromDashboard = false});

  @override
  State<JoinWithCodeScreen> createState() => _JoinWithCodeScreenState();
}

class _JoinWithCodeScreenState extends State<JoinWithCodeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  JoinCodeState _state = JoinCodeState.idle;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnim1;
  late Animation<double> _fadeAnim2;
  late Animation<double> _fadeAnim3;
  late Animation<double> _slideAnim1;
  late Animation<double> _slideAnim2;

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

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
    );
    _fadeAnim2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _fadeAnim3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _slideAnim1 = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic)),
    );
    _slideAnim2 = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  bool get _hasInput => _codeController.text.trim().isNotEmpty;

  Future<void> _onConnect() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) return;

    setState(() {
      _state = JoinCodeState.loading;
      _errorMessage = '';
    });

    try {
      final res = await ApiService.joinPartner(code: code);
      if (res['success'] == true && mounted) {
        final pName = res['partnerName'] ?? 'Partner';
        await ApiService.setPartnerName(pName);

        // Broadcast so dashboard + journey screens refresh instantly
        AppEventBus().emit(AppEvent.partnerConnected);

        setState(() {
          _state = JoinCodeState.success;
        });

        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        if (widget.fromDashboard) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, __, ___) => PromiseScreen(
                userName: widget.userName ?? 'You',
                partnerName: res['partnerName'] ?? 'Partner',
              ),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _state = JoinCodeState.error;
            _errorMessage = res['message'] ?? "That code didn't match… check once?";
          });
          _shakeController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = JoinCodeState.error;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
        _shakeController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // ── Dynamic colours based on state ──
    Color borderColor = const Color(0xFF3D1627);
    if (_state == JoinCodeState.error) {
      borderColor = const Color(0xFF7A1B29);
    } else if (_state == JoinCodeState.success) {
      borderColor = const Color(0xFF8A2E55); // app rose
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
                              size: 14, color: Color(0xFF8C5C74)),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8C5C74),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Decorative Heart ──
                    Center(child: _TwoHearts()),

                    const Spacer(flex: 1),

                    // ── Emotional Header & Subtext ──
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) => Opacity(
                        opacity: _fadeAnim1.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim1.value),
                          child: child,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fromDashboard ? 'Join their' : 'Someone\'s waiting',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            widget.fromDashboard ? 'space' : 'for you',
                            style: const TextStyle(
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
                          Text(
                            widget.fromDashboard 
                                ? 'Enter the code they shared with you to connect and begin your shared journey.'
                                : 'A small code… to begin something\nmeaningful together.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFB58A9F),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Input Label ──
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) => Opacity(
                        opacity: _fadeAnim2.value,
                        child: child,
                      ),
                      child: const Text(
                        'THEIR CODE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF914B68),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Code Input Field (shake on error & entrance slide) ──
                    AnimatedBuilder(
                      animation: Listenable.merge([_shakeAnim, _entranceController]),
                      builder: (context, child) {
                        final dx = _state == JoinCodeState.error
                            ? sin(_shakeAnim.value * pi * 4) * 8
                            : 0.0;
                        return Opacity(
                          opacity: _fadeAnim2.value,
                          child: Transform.translate(
                            offset: Offset(dx, _slideAnim2.value),
                            child: child,
                          ),
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
                                    color: const Color(0xFF8A2E55)
                                        .withOpacity(0.15),
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
                                      ? const Color(0xFFDD8F9F) // rose pink on success
                                      : Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'e.g.  ROSE · 7',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF855A6D),
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
                                  color: Color(0xFFDD8F9F), size: 20)
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
                          ? _ErrorBanner(errorMessage: _errorMessage)
                          : _state == JoinCodeState.success
                              ? _SuccessBanner()
                              : const Text(
                                  'Make sure it\'s entered exactly as shared',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF8C5C74),
                                  ),
                                ),
                    ),

                    const Spacer(flex: 1),

                    // ── Primary CTA Button ──
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) => Opacity(
                        opacity: _fadeAnim3.value,
                        child: child,
                      ),
                      child: GestureDetector(
                        onTap: _hasInput && _state != JoinCodeState.success && _state != JoinCodeState.loading ? _onConnect : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _state == JoinCodeState.success
                                ? const Color(0xFF1C0A11) // app dark rose
                                : _hasInput 
                                    ? const Color(0xFF1A1214) 
                                    : const Color(0xFF0D080A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _state == JoinCodeState.success
                                  ? const Color(0xFF8A2E55) // app rose
                                  : _hasInput 
                                      ? const Color(0xFF911746).withOpacity(0.5) 
                                      : const Color(0xFF26151B),
                              width: 1.2,
                            ),
                          ),
                          child: _state == JoinCodeState.loading
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 18,
                                      color: _state == JoinCodeState.success
                                          ? const Color(0xFFDD8F9F)
                                          : _hasInput ? const Color(0xFFDD8F9F) : const Color(0xFF7A4A5D),
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
                                            ? const Color(0xFFDD8F9F)
                                            : _hasInput ? const Color(0xFFDD8F9F) : const Color(0xFF7A4A5D),
                                      ),
                                    ),
                                  ],
                                ),
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
                              size: 13, color: Color(0xFF7A4A5D)),
                          SizedBox(width: 8),
                          Text(
                            'Your connection stays private and secure',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7A4A5D),
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
                              color: Color(0xFF9C6A81),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => PartnerInviteScreen(
                                    userName: widget.userName ?? 'You',
                                    partnerName: 'Your Partner',
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                const Text(
                                  'Create one instead',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC99852),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: 1,
                                  width: 120,
                                  color: const Color(0xFF8C6430),
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
                        child: Text(
                          widget.fromDashboard ? 'Ready when you are' : 'Every connection begins with a small step',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF7A4A5D),
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
  final String errorMessage;
  const _ErrorBanner({required this.errorMessage});

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
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF962335), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage.isNotEmpty ? errorMessage : "That code didn't match… check once?",
              style: const TextStyle(
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
        color: const Color(0xFF1C0A11), // app dark rose
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8A2E55).withOpacity(0.4), width: 1.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFFDD8F9F), size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You found each other here.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFFDD8F9F),
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


