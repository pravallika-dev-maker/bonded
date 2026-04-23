import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'join_with_code_screen.dart';
import 'promise_screen.dart';

class PartnerInviteScreen extends StatefulWidget {
  final String userName;
  final String partnerName;
  const PartnerInviteScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<PartnerInviteScreen> createState() => _PartnerInviteScreenState();
}

class _PartnerInviteScreenState extends State<PartnerInviteScreen> {
  late final String _bondCode;
  bool _shared = false; // inline confirmation flag

  static const List<String> _words = [
    'ROSE', 'LUNA', 'NOVA', 'EDEN', 'SAGE',
    'IRIS', 'DAWN', 'STAR', 'VEIL', 'MIST',
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final word = _words[rng.nextInt(_words.length)];
    final number = rng.nextInt(9) + 1;
    _bondCode = '$word · $number';
  }

  Future<void> _shareCode() async {
    final rawCode = _bondCode.replaceAll(' · ', '-');
    final message =
        "I'm using this app called Bonded to take a small space and understand things better.\n\n"
        "I'd like you to join me.\n\n"
        "Here's my code: $rawCode";

    await Share.share(message);

    // Show inline confirmation & transition after return
    if (!mounted) return;
    setState(() => _shared = true);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => PromiseScreen(
          userName: widget.userName,
          partnerName: widget.partnerName,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
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
              center: Alignment(0.0, -0.4),
              radius: 1.0,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // ── Step Label ──
                  const Text(
                    'STEP 5 OF 5 — THE INVITATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF8A6530),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Title ──
                  const Text(
                    'Invite your',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'person',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFE89FB8),
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Subtitle ──
                  const Text(
                    'Share this code. When they enter it,\nyou\'re quietly, privately connected.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5E3A4B),
                      height: 1.55,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Bond Code Box ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF180710),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF3D1627),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF911746).withOpacity(0.08),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // The code in big spaced letters
                        Text(
                          _bondCode,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE89FB8),
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Sub-label
                        const Text(
                          'YOUR BOND CODE  ·  24 HOURS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF5E3A4B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Share Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _shareCode,
                      icon: Icon(
                        _shared ? Icons.check : Icons.ios_share_outlined,
                        size: 18,
                        color: _shared
                            ? const Color(0xFF5DB373)
                            : const Color(0xFF8A6530),
                      ),
                      label: Text(
                        _shared ? 'Sent… waiting for them' : 'Share this code',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: _shared
                              ? const Color(0xFF5DB373)
                              : const Color(0xFF8A6530),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _shared
                              ? const Color(0xFF194D2C)
                              : const Color(0xFF3D1627),
                          width: 1.2,
                        ),
                        backgroundColor: _shared
                            ? const Color(0xFF0C1F15)
                            : const Color(0xFF130610),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Have a Code Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const JoinWithCodeScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E1620), width: 1.2),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'I have a code to enter',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF634151),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Three Decorative Hearts ──
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _heartIcon(28),
                        const SizedBox(width: 10),
                        _heartIcon(22),
                        const SizedBox(width: 10),
                        _heartIcon(18),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Bottom Label ──
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'PARTNER INVITE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Color(0xFF3B1F2B),
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
  }

  Widget _heartIcon(double size) {
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
              ..strokeWidth = 1.5
              ..color = const Color(0xFFCA366C),
          ),
        ),
        Text(
          String.fromCharCode(Icons.favorite.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: Icons.favorite.fontFamily,
            package: Icons.favorite.fontPackage,
            color: const Color(0xFF8F1643),
          ),
        ),
      ],
    );
  }
}
