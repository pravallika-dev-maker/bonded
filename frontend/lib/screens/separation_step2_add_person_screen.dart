import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'separation_step3_invite_code_screen.dart';

class SeparationStep2AddPersonScreen extends StatefulWidget {
  const SeparationStep2AddPersonScreen({super.key});

  @override
  State<SeparationStep2AddPersonScreen> createState() => _SeparationStep2AddPersonScreenState();
}

class _SeparationStep2AddPersonScreenState extends State<SeparationStep2AddPersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedConnection = 'Friend';
  String? _selectedGender;
  final List<String> _connections = ['Friend', 'Family', 'Other'];
  final List<Map<String, dynamic>> _genders = [
    {'label': 'He/Him', 'value': 'male'},
    {'label': 'She/Her', 'value': 'female'},
    {'label': 'They/Them', 'value': 'non-binary'},
  ];

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeparationStep3InviteCodeScreen(personName: name),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // ── AppBar / Back Button ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'SOMEONE ELSE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title Section ──
                      const Text(
                        'Add a',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'person',
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
                        'Who are you creating this space with?',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7A5C67),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Their Name ──
                      const Text(
                        'THEIR NAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF6A4A57),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8A2E55),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          onChanged: (val) => setState(() {}),
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Arjun',
                            hintStyle: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF5A3C47),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Your Connection ──
                      const Text(
                        'YOUR CONNECTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF6A4A57),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _connections.map((connection) {
                          final isSelected = _selectedConnection == connection;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedConnection = connection;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2A0D18) : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6E2843) : const Color(0xFF2E1620),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                connection,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // ── Their Gender ──
                      const Text(
                        'THEIR GENDER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF6A4A57),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _genders.map((gender) {
                          final isSelected = _selectedGender == gender['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGender = gender['value'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2A0D18) : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6E2843) : const Color(0xFF2E1620),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                gender['label'],
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // ── Invite Them ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF26181E),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'INVITE THEM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Color(0xFF7A5C67),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "They'll get a bond code to join the full experience",
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFD4C4CA),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Submit Button ──
                      GestureDetector(
                        onTap: (_nameController.text.isNotEmpty && _selectedGender != null) ? _submit : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: (_nameController.text.isNotEmpty && _selectedGender != null) 
                                ? const Color(0xFF1A1214) 
                                : const Color(0xFF0D080A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: (_nameController.text.isNotEmpty && _selectedGender != null) 
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
                                color: (_nameController.text.isNotEmpty && _selectedGender != null) 
                                    ? const Color(0xFFDD8F9F) 
                                    : const Color(0xFF5A3C47),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _nameController.text.isEmpty
                                    ? 'Continue'
                                    : 'Continue with ${_nameController.text}',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: (_nameController.text.isNotEmpty && _selectedGender != null) 
                                      ? const Color(0xFFDD8F9F) 
                                      : const Color(0xFF5A3C47),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                    ],
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

