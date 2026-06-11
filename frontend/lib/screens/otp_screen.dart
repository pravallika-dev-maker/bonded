import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../widgets/app_heart_icon.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';

enum OtpState { entering, loading, error }

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  OtpState _state = OtpState.entering;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(_onTextChanged);
    }
    // Simulate auto-focus on 4th field for the default state representation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  Future<void> _onTextChanged() async {
    String otp = _controllers.map((c) => c.text).join();
    
    if (otp.length == 6) {
      if (_state == OtpState.loading) return;
      
      setState(() {
        _state = OtpState.loading;
        _errorMessage = '';
      });
      
      try {
        await ApiService.verifyCode(
          countryCode: widget.countryCode,
          phoneNumber: widget.phoneNumber,
          otp: otp,
        );

        // Register FCM token upon successful login
        try {
          final messaging = FirebaseMessaging.instance;
          final token = await messaging.getToken();
          if (token != null) {
            await ApiService.registerFcmToken(token);
          }
        } catch (_) {}
        
        if (mounted) {
          // Navigate to Welcome screen immediately
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _state = OtpState.error;
            _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          });
        }
      }
    } else {
      if (_state != OtpState.entering) {
        setState(() => _state = OtpState.entering);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
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
              child: _buildEntryState(),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildGreenBox(String digit) {
    return Container(
      width: 44,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1F15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF194D2C), width: 1.5),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5DB373),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryState() {
    bool isError = _state == OtpState.error;
    bool isLoading = _state == OtpState.loading;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          const Center(child: AppHeartIcon(size: 64)),
          
          const Spacer(flex: 2),
          
          const Text(
            'Just making sure',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          
          const Text(
            "it's you",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color(0xFFE89FB8),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'We sent you a quiet little code...\nenter it below to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5E3A4B),
              height: 1.5,
            ),
          ),
          
          const Spacer(flex: 2),
          
          // 6 OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _otpBox(index, isError)),
          ),
          
          const SizedBox(height: 16),
          
          if (isError) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF260A10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4A151D), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF962335), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _errorMessage.isNotEmpty ? _errorMessage : "That didn't feel right... try again",
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFB55D6A),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Take your time... It will fill automatically if detected',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFF3B1F2B),
              ),
            ),
          ],
          
          const Spacer(flex: 2),
          
          // CTA Button
          GestureDetector(
            onTap: () {
              // Submit action or manual verify logic
              String otp = _controllers.map((c) => c.text).join();
              if (otp.length == 6) {
                _onTextChanged();
              }
            },
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: isLoading ? 56.0 : (MediaQuery.of(context).size.width - 56.0),
                height: 56,
                decoration: BoxDecoration(
                  color: isError 
                      ? const Color(0xFF1A1214) 
                      : (isLoading ? const Color(0xFF1F0A13) : const Color(0xFF0D080A)),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isError 
                        ? const Color(0xFF911746).withOpacity(0.5) 
                        : (isLoading ? const Color(0xFF8A2E55).withOpacity(0.6) : const Color(0xFF26151B)),
                    width: 1.2,
                  ),
                  boxShadow: isLoading ? [
                    BoxShadow(
                      color: const Color(0xFF8A2E55).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoading
                        ? const SizedBox(
                            key: ValueKey('loader'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                            ),
                          )
                        : Row(
                            key: const ValueKey('text'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 18,
                                color: isError ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isError ? "Let's try once more" : "I'm here",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: isError ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(flex: 2),
          
          const Text(
            "Didn't get it yet?",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5E3A4B),
            ),
          ),
          
          const SizedBox(height: 8),
          
          if (isError)
            const Text(
              'We can send it again',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8A6530), // Gold
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF8A6530),
              ),
            )
          else
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5E3A4B),
                ),
                children: [
                  TextSpan(text: 'You can request a new code in '),
                  TextSpan(
                    text: '20s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A6530), // Gold
                    ),
                  ),
                ],
              ),
            ),
            
          const Spacer(flex: 3),
          
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: Text(
                'Every journey begins with a small step',
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
    );
  }

  Widget _otpBox(int index, bool isError) {
    Color borderColor = const Color(0xFF3D1627);
    if (isError) {
      borderColor = const Color(0xFF7A1B29);
    } else if (_controllers[index].text.isNotEmpty) {
      borderColor = const Color(0xFF911746);
    }

    return Container(
      width: 44,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1B0711),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE6D0D8),
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            // Trigger state check
            _onTextChanged();
          },
        ),
      ),
    );
  }
}

class _SuccessHeart extends StatelessWidget {
  const _SuccessHeart();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1F0611),
        border: Border.all(
          color: const Color(0xFF5A1630),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF911746).withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: 15,
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
                fontSize: 46,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.5
                  ..color = const Color(0xFFCA366C),
              ),
            ),
            Text(
              String.fromCharCode(Icons.favorite.codePoint),
              style: TextStyle(
                fontSize: 46,
                fontFamily: Icons.favorite.fontFamily,
                package: Icons.favorite.fontPackage,
                color: const Color(0xFF8F1643),
              ),
            ),
            // White Checkmark inside
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
