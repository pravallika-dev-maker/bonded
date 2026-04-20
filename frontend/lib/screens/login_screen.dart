import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sending_code_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFF0A0408),
        body: LoginContent(),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 0.95,
          colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // ── Top Icon ──
              const Center(
                child: _ReferenceHeartLogo(),
              ),
              
              const SizedBox(height: 48),
              
              const Text(
                'WELCOME TO BONDED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFAC7827),
                  letterSpacing: 1.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'Before\nanything...',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              
              const Text(
                'tell us where\nto reach you',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFD94480),
                  height: 1.3,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Just a small step to make this\nspace truly yours',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF9E7A85),
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Text(
                'YOUR NUMBER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A1525),
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Container(
                    width: 90,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0810),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3D1A25), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('IN', style: TextStyle(fontSize: 10, color: Color(0xFF3A1525))),
                        SizedBox(width: 4),
                        Text('+91', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF3A1525)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0810),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF3D1A25), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAC7827),
                            letterSpacing: 1.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '9876543210',
                            hintStyle: TextStyle(color: Color(0xFF2A0C14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'We\'ll send a quiet code to verify',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF3A1525),
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SendingCodeScreen(
                          phoneNumber: _phoneController.text.isEmpty 
                            ? '98765 43210' 
                            : _phoneController.text,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text(
                    'Send the code',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A1530).withOpacity(0.85),
                    foregroundColor: Colors.white.withOpacity(0.9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: Color(0xFF3A1525)),
                  SizedBox(width: 8),
                  Text(
                    'Your connection stays private and secure',
                    style: TextStyle(fontSize: 11, color: Color(0xFF3A1525)),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              const Center(
                child: Text(
                  'This is where your journey begins',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1A0810),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceHeartLogo extends StatelessWidget {
  const _ReferenceHeartLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB52B6E).withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        const Icon(
          Icons.favorite_outline,
          size: 48,
          color: Color(0xFFD94480),
        ),
        Icon(
          Icons.favorite_rounded,
          size: 44,
          color: const Color(0xFFD94480).withOpacity(0.1),
        ),
      ],
    );
  }
}
