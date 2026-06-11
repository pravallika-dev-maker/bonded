import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'join_with_code_screen.dart';
import 'promise_screen.dart';
import '../services/api_service.dart';

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
  String? _bondCode;
  bool _shared = false; // inline confirmation flag
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInviteCode();
  }

  Future<void> _fetchInviteCode() async {
    try {
      final res = await ApiService.getInviteCode();
      if (mounted) {
        setState(() {
          _bondCode = res['code'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareCode() async {
    if (_bondCode == null) return;
    final rawCode = _bondCode!.replaceAll(' · ', '-');
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
                    'STEP 7 OF 7 — THE INVITATION',
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
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE89FB8)),
                              ),
                            ),
                          )
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFB55D6A),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // The code in big spaced letters
                                  Text(
                                    _bondCode ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE89FB8),
                                      letterSpacing: 4,
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
                  GestureDetector(
                    onTap: (_isLoading || _bondCode == null) ? null : _shareCode,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _shared ? const Color(0xFF0C1F15) : const Color(0xFF1A1214).withOpacity((_isLoading || _bondCode == null) ? 0.5 : 1.0),
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(
                          color: _shared 
                              ? const Color(0xFF194D2C) 
                              : const Color(0xFF911746).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _shared ? Icons.check : Icons.ios_share_outlined,
                            size: 18,
                            color: _shared ? const Color(0xFF5DB373) : const Color(0xFFDD8F9F),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _shared ? 'Sent… waiting for them' : 'Share this code',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                              color: _shared ? const Color(0xFF5DB373) : const Color(0xFFDD8F9F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Have a Code Button ──
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JoinWithCodeScreen(userName: widget.userName),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(color: const Color(0xFF2E1620), width: 1.2),
                      ),
                      child: const Center(
                        child: Text(
                          'I have a code to enter',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: Color(0xFF634151),
                          ),
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
