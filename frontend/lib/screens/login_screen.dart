import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sending_code_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF090204),
      resizeToAvoidBottomInset: false,
      body: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onTextChanged);
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _phoneController.text;
    setState(() {
      // Simulate an error if they literally type '9876' or if it's an invalid length when unfocused.
      if (text == '9876' || (text.isNotEmpty && text.length < 10 && !_phoneFocusNode.hasFocus)) {
        _isError = true;
      } else {
        _isError = false;
      }
    });
  }

  bool get _isFilled => _phoneController.text.length >= 10 && !_isError;
  bool get _isEmpty => _phoneController.text.isEmpty;

  void _onSendCode() {
    if (_isFilled) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SendingCodeScreen(
            phoneNumber: _phoneController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color inputBorderColor = const Color(0xFF3D1627);
    if (_isError) {
      inputBorderColor = const Color(0xFF7A1B29); // Dark red border for error
    } else if (_isFilled || _phoneFocusNode.hasFocus) {
      inputBorderColor = const Color(0xFF911746); // Magenta border for active/filled
    }

    Color buttonBgColor = const Color(0xFF1B0711);
    Color buttonFgColor = const Color(0xFF3D1B28);
    if (_isFilled) {
      buttonBgColor = const Color(0xFF911746);
      buttonFgColor = Colors.white;
    }

    final screenH = MediaQuery.of(context).size.height;

    return Container(
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
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenH * 0.07),

                // ── Glowing Heart Logo ──
                const Center(child: _SmallGlowingHeart()),

                SizedBox(height: screenH * 0.06),

                const Text(
                  'WELCOME TO BONDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8A6530),
                    letterSpacing: 2.0,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Before\nanything...',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),

                const Text(
                  'tell us where\nto reach you',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE89FB8),
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Just a small step to make this\nspace truly yours',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E3A4B),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: screenH * 0.05),

                const Text(
                  'YOUR NUMBER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B1525),
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Country Code Box
                    Container(
                      width: 86,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B0711),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF3D1627), width: 1.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4A1A2C))),
                          SizedBox(width: 6),
                          Text('+91', style: TextStyle(fontSize: 15, color: Color(0xFFE6D0D8), fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF4A1A2C)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Input Box
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B0711),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: inputBorderColor, width: 1.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocusNode,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Your phone number',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF452B36),
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isError)
                                  const Icon(Icons.info_outline, color: Color(0xFF962335), size: 20),
                              ],
                            ),
                          ),

                          // Error Banner
                          if (_isError) ...[
                            const SizedBox(height: 12),
                            Container(
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
                                      "That doesn't look right... check once?",
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
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (!_isError)
                  const Text(
                    'We\'ll send a quick code to verify',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3B1F2B),
                    ),
                  ),

                SizedBox(height: screenH * 0.05),

                GestureDetector(
                  onTap: _isFilled ? _onSendCode : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isFilled 
                          ? const Color(0xFF1A1214) 
                          : const Color(0xFF0D080A),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _isFilled 
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
                          color: _isFilled ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Send the code',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: _isFilled ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF3B1F2B)),
                    SizedBox(width: 8),
                    Text(
                      'Your number stays private and secure',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3B1F2B),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenH * 0.06),

                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: Text(
                      'This is where your journey begins',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 12,
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
    );
  }
}

class _SmallGlowingHeart extends StatelessWidget {
  const _SmallGlowingHeart();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1F0611),
        border: Border.all(
          color: const Color(0xFF5A1630),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF911746).withOpacity(0.18),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              String.fromCharCode(Icons.favorite.codePoint),
              style: TextStyle(
                fontSize: 30,
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
                fontSize: 30,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                color: const Color(0xFF8F1643),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
