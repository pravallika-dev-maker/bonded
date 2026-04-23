import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'separation_transition_screen.dart';

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

  void _submit() {
    if (!_isAgreed) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SeparationTransitionScreen(
          partnerName: widget.partnerName ?? 'Mihail',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format date specifically as requested e.g., "Today — March 26" or "March 27"
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
        body: SafeArea(
          child: Column(
            children: [
              // ── Progress Bar & Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Container(height: 2, color: const Color(0xFF8A2E55))),
                        const SizedBox(width: 8),
                        Expanded(child: Container(height: 2, color: const Color(0xFF8A2E55))),
                        const SizedBox(width: 8),
                        Expanded(child: Container(height: 2, color: const Color(0xFF8A2E55))),
                        const SizedBox(width: 8),
                        Expanded(child: Container(height: 2, color: const Color(0xFF8A2E55))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A0D18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF3D1627),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Color(0xFF8A2E55)),
                              const SizedBox(width: 8),
                              Text(
                                'with ${widget.partnerName ?? "Mihail"}',
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFD4C4CA),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'tap to change',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5A3C47),
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
                          color: Color(0xFF9E7E5A), // Bronze/Gold
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
                          color: Color(0xFFDD8F9F), // Pink rose
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Duration Section ──
                      _SectionHeader(title: 'HOW LONG DO YOU NEED THIS SPACE?'),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? const Color(0xFFE27E9F) : const Color(0xFF7A5C67),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // ── Date Section ──
                      _SectionHeader(title: 'WHEN DOES THIS BEGIN?'),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF160A0E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF26181E),
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
                      _SectionHeader(title: 'WHY DOES THIS MATTER TO YOU?'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF26181E),
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
                            color: _isAgreed ? const Color(0xFF2A0D18) : const Color(0xFF160A0E), 
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isAgreed ? const Color(0xFF6E2843) : const Color(0xFF26181E),
                              width: 1.5,
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
                                    color: _isAgreed ? const Color(0xFF8A2E55) : const Color(0xFF4A2A35),
                                    width: 1.5,
                                  ),
                                ),
                                child: _isAgreed
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  '"I choose to stay in this space fully"',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFD4C4CA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Submit Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isAgreed ? _submit : null,
                          icon: Icon(
                            Icons.favorite,
                            size: 18,
                            color: _isAgreed ? Colors.white : const Color(0xFF261019),
                          ),
                          label: Text(
                            'Begin this space',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: _isAgreed ? Colors.white : const Color(0xFF261019),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2E55),
                            disabledBackgroundColor: const Color(0xFF160A0E),
                            splashFactory: NoSplash.splashFactory,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Bottom Text Indicator
                      const Center(
                        child: Text(
                          'STEP 4 — SET INTENTION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF3D1627),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Color(0xFF6A4A57),
      ),
    );
  }
}
