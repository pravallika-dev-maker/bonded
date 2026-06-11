import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'separation_transition_screen.dart';
import '../services/api_service.dart';

class NewSeparationScreen extends StatefulWidget {
  final String? partnerName;
  const NewSeparationScreen({super.key, this.partnerName});

  @override
  State<NewSeparationScreen> createState() => _NewSeparationScreenState();
}

class _NewSeparationScreenState extends State<NewSeparationScreen> {
  String _selectedDuration = 'A few days';
  DateTime _selectedDate = DateTime.now();
  bool _isAgreed = false;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _durations = ['A few days', 'A week', 'Longer', 'Custom'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_isAgreed || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.createSeparation(
        durationLabel: _selectedDuration,
        startDate: _selectedDate.toIso8601String(),
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SeparationTransitionScreen(
              partnerName: widget.partnerName ?? 'Your partner',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final dateStr = isToday
        ? 'Today — ${DateFormat('MMMM d').format(_selectedDate)}'
        : DateFormat('MMMM d, yyyy').format(_selectedDate);

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
              // ── Ambient glow top-left ──
              Positioned(
                top: -100,
                left: -80,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDD8F9F).withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // ── Ambient glow bottom-right ──
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9E7E5A).withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back + step indicator row
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
                          const SizedBox(height: 16),

                          // Partner badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A0D18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF3D1627),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, size: 12, color: Color(0xFF8A2E55)),
                                    const SizedBox(width: 7),
                                    Text(
                                      'with ${widget.partnerName ?? "your partner"}',
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFD4C4CA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                              'A RITUAL, NOT A FORM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Color(0xFF9E7E5A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Set your distance',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'with intention',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFDD8F9F),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // ── Duration Section ──
                            const _SectionHeader(title: 'HOW LONG DO YOU NEED THIS SPACE?'),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _durations.map((duration) {
                                final isSelected = _selectedDuration == duration;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDuration = duration;
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
                            const SizedBox(height: 40),

                            // ── Date Section ──
                            const _SectionHeader(title: 'WHEN DOES THIS BEGIN?'),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF160A0E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF2E1620),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 17,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFD4C4CA),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      color: Color(0xFF7A5C67),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // ── Reason Section ──
                            const _SectionHeader(title: 'WHY DOES THIS MATTER TO YOU?'),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160A0E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2E1620),
                                  width: 1.5,
                                ),
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

                            // ── Agreement Section ──
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAgreed = !_isAgreed;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: _isAgreed ? const Color(0xFF1A1214) : const Color(0xFF0D080A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isAgreed
                                        ? const Color(0xFF8A2E55).withOpacity(0.5)
                                        : const Color(0xFF2E1620),
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
                                      child: _isAgreed
                                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                                          : null,
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

                            // ── Submit Button ──
                            GestureDetector(
                              onTap: _isAgreed && !_isLoading ? _submit : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _isAgreed ? const Color(0xFF1A1214) : const Color(0xFF0D080A),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: _isAgreed
                                        ? const Color(0xFF911746).withOpacity(0.5)
                                        : const Color(0xFF26151B),
                                    width: 1.2,
                                  ),
                                  boxShadow: _isAgreed
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF911746).withOpacity(0.12),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 18,
                                            color: _isAgreed ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Begin this space',
                                            style: TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 0.5,
                                              color: _isAgreed ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
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
              errorMessage.isNotEmpty ? errorMessage : "Failed to create separation. Please try again.",
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
