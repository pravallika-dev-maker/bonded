import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/primary_cta_button.dart';
import 'separation_step3_invite_code_screen.dart';
import '../services/api_service.dart';

class SeparationStep2AddPersonScreen extends StatefulWidget {
  const SeparationStep2AddPersonScreen({super.key});

  @override
  State<SeparationStep2AddPersonScreen> createState() => _SeparationStep2AddPersonScreenState();
}

class _SeparationStep2AddPersonScreenState extends State<SeparationStep2AddPersonScreen> {
  // Person fields
  final TextEditingController _nameController = TextEditingController();
  String _selectedConnection = 'Partner';
  String? _selectedGender;
  final List<String> _connections = ['Partner', 'Friend', 'Family', 'Other'];
  final List<Map<String, dynamic>> _genders = [
    {'label': 'He/Him', 'value': 'male'},
    {'label': 'She/Her', 'value': 'female'},
    {'label': 'They/Them', 'value': 'non-binary'},
  ];
  DateTime? _relationshipStartDate;

  // Separation fields
  String _selectedDuration = '1 Week';
  DateTime _separationStartDate = DateTime.now();
  DateTime? _customEndDate;
  bool _isAgreed = false;
  final TextEditingController _reasonController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _durations = ['1 Week', '2 Weeks', '1 Month', 'Custom'];

  Future<void> _selectRelationshipDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _relationshipStartDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8A2E55),
              onPrimary: Colors.white,
              surface: Color(0xFF160B10),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF090204),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _relationshipStartDate = date;
      });
    }
  }

  Future<void> _selectSeparationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _separationStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8A2E55),
              onPrimary: Colors.white,
              surface: Color(0xFF160B10),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF090204),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _separationStartDate) {
      setState(() {
        _separationStartDate = picked;
        if (_customEndDate != null && _customEndDate!.isBefore(_separationStartDate.add(const Duration(days: 1)))) {
          _customEndDate = _separationStartDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? _separationStartDate.add(const Duration(days: 7)),
      firstDate: _separationStartDate.add(const Duration(days: 1)),
      lastDate: _separationStartDate.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8A2E55),
              onPrimary: Colors.white,
              surface: Color(0xFF160B10),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF090204),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customEndDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedGender == null || _relationshipStartDate == null || !_isAgreed || _isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Save their info to our profile
      await ApiService.updateUserProfile(
        partnerName: name,
        relationType: _selectedConnection,
        relationshipDate: _relationshipStartDate?.toIso8601String().split('T')[0],
      );
      
      // Cache partner name locally
      await ApiService.setPartnerName(name);

      // 2. Create Separation
      String durationLabelToSubmit = _selectedDuration;
      if (_selectedDuration == 'Custom') {
        final end = _customEndDate ?? _separationStartDate.add(const Duration(days: 7));
        final diff = end.difference(_separationStartDate).inDays + 1;
        durationLabelToSubmit = '$diff Days';
      }

      await ApiService.createSeparation(
        durationLabel: durationLabelToSubmit,
        startDate: _separationStartDate.toIso8601String(),
        reason: _reasonController.text.trim(),
      );

      // 3. Fetch Invite Code
      final inviteRes = await ApiService.getInviteCode();
      if (inviteRes['success'] == true) {
        final inviteCode = inviteRes['code'];
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SeparationStep3InviteCodeScreen(
              personName: name,
              inviteCode: inviteCode,
            ),
          ),
        );
      } else {
        throw Exception("Failed to generate invite code");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Formatting dates
    final now = DateTime.now();
    final isToday = _separationStartDate.year == now.year &&
        _separationStartDate.month == now.month &&
        _separationStartDate.day == now.day;
    final sepDateStr = isToday
        ? 'Today — ${DateFormat('MMMM d').format(_separationStartDate)}'
        : DateFormat('MMMM d, yyyy').format(_separationStartDate);

    final endDateToUse = _customEndDate ?? _separationStartDate.add(const Duration(days: 7));
    final endStr = DateFormat('MMMM d, yyyy').format(endDateToUse);

    final bool isFormValid = _nameController.text.isNotEmpty && 
                             _selectedGender != null && 
                             _relationshipStartDate != null && 
                             _isAgreed;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF090204),
          body: Stack(
            children: [
              // Ambient glows
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
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF160A0E),
                                border: Border.all(color: const Color(0xFF2E1620), width: 1),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'STEP 2 OF 2',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF3D1627),
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
                            const Text(
                              'Create this',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'new space',
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
                              'Let\'s set the intention for your distance.',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF7A5C67),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // ── Person Details Section ──
                            const _SectionHeader(title: 'THEIR NAME'),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160A0E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF8A2E55), width: 1.5),
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
                                  hintText: 'e.g. Arjun',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF5A3C47),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            const _SectionHeader(title: 'YOUR CONNECTION'),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _connections.map((connection) {
                                final isSelected = _selectedConnection == connection;
                                final isDisabled = connection != 'Partner';
                                return GestureDetector(
                                  onTap: () {
                                    if (!isDisabled) {
                                      setState(() => _selectedConnection = connection);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Currently, spaces are designed specifically for romantic partnerships. Support for friends and family is coming soon!',
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFFDD8F9F),
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFF160A0E),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: const BorderSide(color: Color(0xFF2E1620), width: 1),
                                          ),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  },
                                  child: Opacity(
                                    opacity: isDisabled ? 0.5 : 1.0,
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
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),

                            const _SectionHeader(title: 'THEIR GENDER'),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _genders.map((gender) {
                                final isSelected = _selectedGender == gender['value'];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedGender = gender['value']),
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
                            const SizedBox(height: 32),

                            const _SectionHeader(title: 'WHEN DID YOU MEET?'),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _selectRelationshipDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF160A0E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _relationshipStartDate != null ? const Color(0xFF6E2843) : const Color(0xFF2E1620),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _relationshipStartDate == null 
                                          ? 'Select Date' 
                                          : '${_relationshipStartDate!.month.toString().padLeft(2, '0')}/${_relationshipStartDate!.day.toString().padLeft(2, '0')}/${_relationshipStartDate!.year}',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: _relationshipStartDate != null ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: _relationshipStartDate != null ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Divider(color: Color(0xFF2E1620), thickness: 1),
                            ),

                            // ── Separation Details Section ──
                            const _SectionHeader(title: 'HOW LONG DO YOU NEED THIS SPACE?'),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _durations.map((duration) {
                                final bool isSelected = _selectedDuration == duration;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDuration = duration;
                                      if (duration == 'Custom' && _customEndDate == null) {
                                        _customEndDate = _separationStartDate.add(const Duration(days: 7));
                                      }
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
                                      duration,
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? const Color(0xFFDD8F9F) : const Color(0xFF7A5C67),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),

                            const _SectionHeader(title: 'WHEN DOES THIS SEPARATION BEGIN?'),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _selectSeparationDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF160A0E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF2E1620), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sepDateStr,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 17,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFD4C4CA),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF7A5C67), size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            if (_selectedDuration == 'Custom') ...[
                              const _SectionHeader(title: 'WHEN DOES THIS SEPARATION END?'),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _selectEndDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF160A0E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF2E1620), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        endStr,
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 17,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFFD4C4CA),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF7A5C67), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            const _SectionHeader(title: 'WHY DOES THIS MATTER TO YOU?'),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160A0E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2E1620), width: 1.5),
                              ),
                              child: TextField(
                                controller: _reasonController,
                                maxLines: 4,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFD4C4CA),
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'To understand myself... to feel clearly...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF5A3C47),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Agreement
                            GestureDetector(
                              onTap: () => setState(() => _isAgreed = !_isAgreed),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: _isAgreed ? const Color(0xFF1A1214) : const Color(0xFF0D080A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isAgreed ? const Color(0xFF8A2E55).withOpacity(0.5) : const Color(0xFF2E1620),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isAgreed ? const Color(0xFF8A2E55) : Colors.transparent,
                                        border: Border.all(
                                          color: _isAgreed ? const Color(0xFF8A2E55) : const Color(0xFF3B1F2B),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _isAgreed ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        '"I choose to stay in this space fully"',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          color: _isAgreed ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            if (_errorMessage.isNotEmpty) ...[
                              _ErrorBanner(errorMessage: _errorMessage),
                              const SizedBox(height: 16),
                            ],

                            PrimaryCtaButton(
                              text: 'Begin this space',
                              onTap: (isFormValid && !_isLoading) ? _submit : null,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 48),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.8,
        color: Color(0xFF9E7E5A),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String errorMessage;
  const _ErrorBanner({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              errorMessage.isNotEmpty ? errorMessage : "Failed to create. Please try again.",
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
