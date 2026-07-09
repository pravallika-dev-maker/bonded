import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/primary_cta_button.dart';
import 'partner_invite_screen.dart';
import '../services/api_service.dart';

enum BeginningState { calendar, dateSelected, notSure }

enum NotSureReason { feeling, gradually, letMeTry }

class BeginningDateScreen extends StatefulWidget {
  final String userName;
  final String partnerName;
  final String? gender;
  final String? relationType;

  const BeginningDateScreen({
    super.key,
    required this.userName,
    required this.partnerName,
    this.gender,
    this.relationType,
  });

  @override
  State<BeginningDateScreen> createState() => _BeginningDateScreenState();
}

class _BeginningDateScreenState extends State<BeginningDateScreen>
    with SingleTickerProviderStateMixin {
  BeginningState _currentState = BeginningState.calendar;
  NotSureReason? _selectedReason;

  // Calendar state
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  late AnimationController _monthAnimController;
  late Animation<double> _monthFade;
  int _slideDir = 1;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _monthAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _monthFade = CurvedAnimation(
      parent: _monthAnimController,
      curve: Curves.easeInOut,
    );
    _monthAnimController.forward();
  }

  @override
  void dispose() {
    _monthAnimController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    _slideDir = delta;
    _monthAnimController.reverse().then((_) {
      setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      });
      _monthAnimController.forward();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentState = BeginningState.dateSelected;
    });
  }

  Future<void> _showYearPicker() async {
    final int currentYear = DateTime.now().year;
    final int minYear = 1990;
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (ctx) => _YearPickerDialog(
        currentYear: _focusedMonth.year,
        minYear: minYear,
        maxYear: currentYear,
      ),
    );
    if (selectedYear != null) {
      _monthAnimController.reverse().then((_) {
        setState(() {
          _focusedMonth = DateTime(selectedYear, _focusedMonth.month);
        });
        _monthAnimController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0408),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.0,
              colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Back button
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white70, size: 20),
                    onPressed: () {
                      if (_currentState == BeginningState.notSure) {
                        setState(
                            () => _currentState = BeginningState.calendar);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _currentState == BeginningState.notSure
                        ? _buildNotSureView()
                        : _buildCalendarView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CALENDAR VIEW ───────────────────────────────────────────────────────
  Widget _buildCalendarView() {
    final bool isSelected = _currentState == BeginningState.dateSelected;

    return Column(
      key: const ValueKey('calendar_view'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 3),

        // Step Header
        Text(
          'STEP 6 OF 7 — YOUR BEGINNING',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: const Color(0xFFAC7827).withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        const Text(
          'When did it',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const Text(
          'all begin?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color(0xFFE89FB8),
            height: 1.1,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          '"It doesn\'t have to be perfect...\njust what feels right to you"',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Color(0xFF6B4B55),
            height: 1.4,
          ),
        ),

        const Spacer(flex: 3),

        // Calendar Container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E0A12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF381524), width: 1.5),
          ),
          child: Column(
            children: [
              // ── Month/Year Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _changeMonth(-1),
                  ),
                  GestureDetector(
                    onTap: _showYearPicker,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_focusedMonth),
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more,
                            color: Color(0xFF6B4B55), size: 18),
                      ],
                    ),
                  ),
                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _changeMonth(1),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Weekday Labels ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                    .map((d) => SizedBox(
                          width: 32,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4C2735),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),

              // ── Days Grid ──
              FadeTransition(
                opacity: _monthFade,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(_slideDir * 0.06, 0),
                    end: Offset.zero,
                  ).animate(_monthFade),
                  child: _buildDaysGrid(),
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 2),

        // Selected date card
        if (isSelected && _selectedDate != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A130C),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF3A2D1B), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite,
                    color: Color(0xFF8C6D40), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate!),
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAC884B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'That moment still lives somewhere in you',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7A5C35),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],

        const Text(
          'Even an approximate date is okay. You can change this later',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Color(0xFF4C2735),
            height: 1.3,
          ),
        ),

        const Spacer(flex: 2),

        // Save button
        PrimaryCtaButton(
          text: 'Save and continue',
          onTap: isSelected ? _onSaveAndContinue : null,
          isLoading: _isSaving,
        ),

        const SizedBox(height: 16),

        // Skip link
        GestureDetector(
          onTap: () =>
              setState(() => _currentState = BeginningState.notSure),
          child: const Text(
            "I'm not sure — skip for now",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF6B4B55),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF4C2735),
            ),
          ),
        ),

        const Spacer(flex: 3),
        const Text(
          'Every connection starts with a single moment',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Color(0xFF2C141D),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final int year = _focusedMonth.year;
    final int month = _focusedMonth.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int startWeekday = DateTime(year, month, 1).weekday % 7; // Sun=0
    final today = DateTime.now();

    final List<DateTime?> cells = [
      ...List<DateTime?>.filled(startWeekday, null),
      ...List.generate(daysInMonth, (i) => DateTime(year, month, i + 1)),
    ];

    // Pad to fill last row
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: List.generate(cells.length ~/ 7, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (col) {
              final date = cells[row * 7 + col];
              if (date == null) {
                return const SizedBox(width: 32, height: 32);
              }

              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: isFuture ? null : () => _selectDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF8A2E55)
                        : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(
                            color: const Color(0xFFAC7827), width: 1.2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFFAC7827)
                              : isFuture
                                  ? const Color(0xFF2C141D)
                                  : const Color(0xFF9E7880),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ─── NOT SURE VIEW ────────────────────────────────────────────────────────
  Widget _buildNotSureView() {
    return Column(
      key: const ValueKey('notsure_view'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3A1525),
            border: Border.all(color: const Color(0xFF6A1A3C), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.favorite, color: Color(0xFFE89FB8), size: 30),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "That's okay",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Some beginnings don't have\na date — they just have a feeling",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Color(0xFF6B4B55),
            height: 1.4,
          ),
        ),

        const Spacer(flex: 2),

        _buildPillButton(
          title: "I remember the feeling, not the\ndate",
          reason: NotSureReason.feeling,
          isSelected: _selectedReason == NotSureReason.feeling,
          activeColor: const Color(0xFF6A1A3C),
        ),
        const SizedBox(height: 10),

        _buildPillButton(
          title: "It started gradually — no\nclear moment",
          reason: NotSureReason.gradually,
          isSelected: _selectedReason == NotSureReason.gradually,
          activeColor: const Color(0xFF3A2D1B),
        ),
        const SizedBox(height: 10),

        _buildPillButton(
          title: "Let me try to remember first",
          reason: NotSureReason.letMeTry,
          isSelected: _selectedReason == NotSureReason.letMeTry,
          activeColor: const Color(0xFF381524),
          isDashed: true,
        ),

        const Spacer(flex: 3),

        PrimaryCtaButton(
          text: 'Continue without a date',
          onTap: _selectedReason != null ? _onSaveAndContinue : null,
          isLoading: _isSaving,
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () =>
              setState(() => _currentState = BeginningState.calendar),
          child: const Text(
            'Take me back to the calendar',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF8A6530),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF4C3011),
            ),
          ),
        ),

        const Spacer(flex: 3),
        const Text(
          'Every connection starts with a single moment',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Color(0xFF2C141D),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPillButton({
    required String title,
    required NotSureReason reason,
    required bool isSelected,
    required Color activeColor,
    bool isDashed = false,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.3)
              : const Color(0xFF16060D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFF261019),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? activeColor.withValues(alpha: 0.8)
                    : const Color(0xFF261019),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF6B4B55),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSaving = false;

  Future<void> _onSaveAndContinue() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      String? formattedDate;
      if (_currentState == BeginningState.dateSelected && _selectedDate != null) {
        formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      // Retrieve cached values
      final prefs = await SharedPreferences.getInstance();
      final cachedUserName = prefs.getString('onboarding_userName') ?? widget.userName;
      final cachedGender = prefs.getString('onboarding_gender') ?? widget.gender;
      final cachedRelationType = prefs.getString('onboarding_relationType') ?? widget.relationType;
      final cachedPartnerName = prefs.getString('onboarding_partnerName') ?? widget.partnerName;

      final nameToSave = cachedUserName.trim().isNotEmpty ? cachedUserName.trim() : null;
      final partnerNameToSave = cachedPartnerName.trim().isNotEmpty ? cachedPartnerName.trim() : null;

      await ApiService.updateUserProfile(
        name: nameToSave,
        gender: cachedGender,
        relationType: cachedRelationType,
        partnerName: partnerNameToSave,
        relationshipDate: formattedDate,
      );

      // Clean up cache
      await prefs.remove('onboarding_userName');
      await prefs.remove('onboarding_gender');
      await prefs.remove('onboarding_relationType');
      await prefs.remove('onboarding_partnerName');

      // Also cache partnerName locally as fallback for offline reads
      if (partnerNameToSave != null) {
        await ApiService.setPartnerName(partnerNameToSave);
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PartnerInviteScreen(
            userName: widget.userName,
            partnerName: widget.partnerName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF911746),
        ));
      }

    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button
// ─────────────────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF381524), width: 1.5),
        ),
        child: Icon(icon, color: const Color(0xFF8A4A62), size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Year Picker Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _YearPickerDialog extends StatefulWidget {
  final int currentYear;
  final int minYear;
  final int maxYear;

  const _YearPickerDialog({
    required this.currentYear,
    required this.minYear,
    required this.maxYear,
  });

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late ScrollController _scrollController;
  late int _highlighted;

  @override
  void initState() {
    super.initState();
    _highlighted = widget.currentYear;
    final offset =
        (widget.currentYear - widget.minYear - 2).clamp(0, double.maxFinite.toInt()) * 48.0;
    _scrollController = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
        widget.maxYear - widget.minYear + 1,
        (i) => widget.maxYear - i); // newest first

    return Dialog(
      backgroundColor: const Color(0xFF1E0A12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SELECT YEAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
                color: Color(0xFF9E7E5A),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: years.length,
                itemExtent: 48,
                itemBuilder: (ctx, i) {
                  final year = years[i];
                  final isSelected = year == _highlighted;
                  return GestureDetector(
                    onTap: () => setState(() => _highlighted = year),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8A2E55)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B4B55),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF5A3C47)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, _highlighted),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2E55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
