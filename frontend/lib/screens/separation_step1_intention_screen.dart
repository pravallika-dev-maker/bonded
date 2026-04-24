import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'separation_step2_add_person_screen.dart';
import 'new_separation_screen.dart';

class SeparationStep1IntentionScreen extends StatefulWidget {
  const SeparationStep1IntentionScreen({super.key});

  @override
  State<SeparationStep1IntentionScreen> createState() => _SeparationStep1IntentionScreenState();
}

class _SeparationStep1IntentionScreenState extends State<SeparationStep1IntentionScreen> {
  // 0 for none, 1 for Partner, 2 for Someone Else
  int _selectedOption = 1; 
  final String partnerName = "Mihail";

  void _submit() {
    if (_selectedOption == 1) {
      // Go directly to NewSeparationScreen for partner
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NewSeparationScreen(partnerName: "Mihail"),
        ),
      );
    } else if (_selectedOption == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SeparationStep2AddPersonScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [



                const Text(
                  'Who is this',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'space for?',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFDD8F9F),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Separation is always between two people',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF7A5C67),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Option 1: Partner ──
                GestureDetector(
                  onTap: () => setState(() => _selectedOption = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _selectedOption == 1 ? const Color(0xFF2A0D18) : const Color(0xFF090204),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _selectedOption == 1 ? const Color(0xFF8A2E55) : const Color(0xFF2E1620),
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
                            color: _selectedOption == 1 ? const Color(0xFF3D1627) : const Color(0xFF160A0E),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: _selectedOption == 1 ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partnerName,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Connected · Your partner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A5C67),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_selectedOption == 1)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF8A2E55),
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Option 2: Someone Else ──
                GestureDetector(
                  onTap: () => setState(() => _selectedOption = 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _selectedOption == 2 ? const Color(0xFF2A0D18) : const Color(0xFF090204),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _selectedOption == 2 ? const Color(0xFF8A2E55) : const Color(0xFF2E1620),
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
                            color: _selectedOption == 2 ? const Color(0xFF3D1627) : const Color(0xFF160A0E),
                            border: Border.all(
                              color: const Color(0xFF2E1620),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: _selectedOption == 2 ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Someone else',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Friend · Family · Other',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7A5C67),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedOption == 2)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF8A2E55),
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          )
                        else
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2E1620), width: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Info Box ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF160A0E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF26181E),
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    '"Space only works when both people choose it"',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF9E7E5A),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // ── Submit Button ──
                GestureDetector(
                  onTap: _selectedOption != 0 ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _selectedOption != 0 
                          ? const Color(0xFF1A1214) 
                          : const Color(0xFF0D080A),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _selectedOption != 0 
                            ? const Color(0xFF911746).withOpacity(0.5) 
                            : const Color(0xFF26151B),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: _selectedOption != 0 ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedOption == 1 ? 'Continue with $partnerName' : 'Continue',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: _selectedOption != 0 ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bottom Text Indicator
                const Center(
                  child: Text(
                    'STEP 1 — PARTNER SELECTED',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF3D1627),
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
