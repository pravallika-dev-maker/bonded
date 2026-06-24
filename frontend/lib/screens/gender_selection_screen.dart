import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/primary_cta_button.dart';
import 'bond_selection_screen.dart';
import '../services/api_service.dart';

class GenderSelectionScreen extends StatefulWidget {
  final String userName;
  final String? targetName; // If null, it's for the user themselves
  final int currentStep;
  final int totalSteps;
  final Widget? nextScreen; // Optional next screen override

  const GenderSelectionScreen({
    super.key,
    required this.userName,
    this.targetName,
    this.currentStep = 2,
    this.totalSteps = 6,
    this.nextScreen,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  final List<Map<String, dynamic>> _genderOptions = [
    {
      'label': 'She / Her',
      'value': 'female',
      'icon': Icons.female,
      'color': const Color(0xFFDD8F9F),
    },
    {
      'label': 'He / Him',
      'value': 'male',
      'icon': Icons.male,
      'color': const Color(0xFF9E7E5A),
    },
    {
      'label': 'They / Them',
      'value': 'non-binary',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF7A5C67),
    },
  ];

  Future<void> _onNext() async {
    if (_selectedGender == null) return;

    if (widget.nextScreen != null) {
      // This is the partner-gender step (targetName != null).
      // The backend has no partnerGender field on the user profile,
      // so we just navigate without an API call.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen!),
      );
    } else {
      // Capture navigator before async gap to satisfy use_build_context_synchronously lint.
      final navigator = Navigator.of(context);
      // This is the user's own gender step — persist it locally.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_gender', _selectedGender!);
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute(
          builder: (context) => BondSelectionScreen(
            userName: widget.userName,
            gender: _selectedGender,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isForUser = widget.targetName == null;
    final String displayName = isForUser ? 'you' : widget.targetName!;
    
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
              center: Alignment(0.0, -0.4),
              radius: 1.0,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 2),
                        
                        // ── Top Label ──
                        Text(
                          'STEP ${widget.currentStep} OF ${widget.totalSteps} — IDENTITY',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF8A6530),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // ── Title ──
                        const Text(
                          'How do',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '$displayName identify?',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                            height: 1.1,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ── Subtitle ──
                        Text(
                          isForUser 
                            ? 'This helps us tailor your experience and the language we use.'
                            : 'This helps us customize how we refer to them in your space.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5E3A4B),
                            height: 1.5,
                          ),
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // ── Gender Options ──
                        ..._genderOptions.map((option) {
                          final isSelected = _selectedGender == option['value'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGender = option['value']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF1B0711) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF911746) : const Color(0xFF3D1627),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? const Color(0xFF3D1627) : const Color(0xFF160A0E),
                                      ),
                                      child: Icon(
                                        option['icon'],
                                        color: isSelected ? option['color'] : const Color(0xFF5E3A4B),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      option['label'],
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : const Color(0xFF5E3A4B),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: Color(0xFF911746), size: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
                
                // ── Bottom Button ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                  child: PrimaryCtaButton(
                    text: "Continue",
                    onTap: _selectedGender != null ? _onNext : null,
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
