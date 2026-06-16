import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'separation_step2_add_person_screen.dart';
import 'new_separation_screen.dart';
import '../services/api_service.dart';

class SeparationStep1IntentionScreen extends StatefulWidget {
  const SeparationStep1IntentionScreen({super.key});

  @override
  State<SeparationStep1IntentionScreen> createState() => _SeparationStep1IntentionScreenState();
}

class _SeparationStep1IntentionScreenState extends State<SeparationStep1IntentionScreen> {
  int _selectedOption = 1;
  String? _partnerName;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isPartnerConnected = false;

  @override
  void initState() {
    super.initState();
    _fetchPartnerName();
  }

  Future<void> _fetchPartnerName() async {
    try {
      final cachedPartnerName = await ApiService.getPartnerName();
      bool isConnected = false;
      String? backendPartnerName;
      try {
        final profile = await ApiService.getUserProfile();
        if (profile['success'] == true && profile['data'] != null) {
          isConnected = profile['data']['isPartnerConnected'] == true;
          backendPartnerName = profile['data']['partnerName'];
        }
      } catch (e) {
        // Silently ignore profile fetch errors if any
      }
      
      if (mounted) {
        setState(() {
          _isPartnerConnected = isConnected;
          if (cachedPartnerName != null && cachedPartnerName.isNotEmpty) {
            _partnerName = cachedPartnerName;
          } else if (backendPartnerName != null && backendPartnerName.isNotEmpty) {
            _partnerName = backendPartnerName;
          }
          _isLoading = false;
          if (_partnerName == null || _partnerName!.isEmpty) {
            _selectedOption = 2;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedOption = 2;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedOption == 1 && _partnerName != null && _partnerName!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewSeparationScreen(partnerName: _partnerName!),
        ),
      );
    } else if (_selectedOption == 2) {
      if (_isPartnerConnected) {
        _showDisconnectWarning();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SeparationStep2AddPersonScreen()),
        );
      }
    }
  }

  void _showDisconnectWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF160A0E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF3D1627), width: 1.5),
          ),
          title: const Text(
            'Disconnect Required',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'You are currently connected to ${_partnerName ?? 'your partner'}. You must disconnect your current bond before inviting someone else.',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFD4C4CA),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF7A5C67), fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                setState(() {
                  _isSubmitting = true;
                });
                try {
                  await ApiService.disconnectPartner();
                  setState(() {
                    _isPartnerConnected = false;
                  });
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SeparationStep2AddPersonScreen()),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to disconnect: ${e.toString()}'),
                        backgroundColor: const Color(0xFF8A2E55),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2E55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Disconnect & Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF090204),
          body: Stack(
            children: [
              // ── Ambient glow ──
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDD8F9F).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                  child: _isLoading 
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFFDD8F9F)),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                      // ── Top Row: back + step indicator ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF160A0E),
                                border: Border.all(
                                  color: const Color(0xFF2E1620),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF7A5C67),
                                size: 16,
                              ),
                            ),
                          ),
                          const Text(
                            'STEP 1 OF 2',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF3D1627),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Gold label ──
                      const Text(
                        'NEW SEPARATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF9E7E5A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Title ──
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
                      const SizedBox(height: 12),
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
                      if (_partnerName != null && _partnerName!.isNotEmpty) ...[
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
                                      _partnerName ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.circle, size: 8, color: _isPartnerConnected ? const Color(0xFF4CAF50) : const Color(0xFF7A5C67)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _isPartnerConnected ? 'Connected · Your partner' : 'Not connected yet · Your partner',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF7A5C67),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedOption == 1 ? const Color(0xFF8A2E55) : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedOption == 1 ? const Color(0xFF8A2E55) : const Color(0xFF2E1620),
                                    width: 1.5,
                                  ),
                                ),
                                child: _selectedOption == 1
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ],

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
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedOption == 2 ? const Color(0xFF8A2E55) : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedOption == 2 ? const Color(0xFF8A2E55) : const Color(0xFF2E1620),
                                    width: 1.5,
                                  ),
                                ),
                                child: _selectedOption == 2
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
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
                        onTap: (_selectedOption != 0 && !_isSubmitting) ? _submit : null,
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
                          child: _isSubmitting 
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFDD8F9F),
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: _selectedOption != 0 ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedOption == 1 ? 'Continue with $_partnerName' : 'Continue',
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
