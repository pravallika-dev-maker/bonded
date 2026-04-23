import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'partner_invite_screen.dart';

enum BeginningState { calendar, dateSelected, notSure }
enum NotSureReason { feeling, gradually, letMeTry }

class BeginningDateScreen extends StatefulWidget {
  final String userName;
  final String partnerName;

  const BeginningDateScreen({
    super.key,
    required this.userName,
    required this.partnerName,
  });

  @override
  State<BeginningDateScreen> createState() => _BeginningDateScreenState();
}

class _BeginningDateScreenState extends State<BeginningDateScreen> {
  BeginningState _currentState = BeginningState.calendar;
  NotSureReason? _selectedReason;

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
                // Global Back Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                    onPressed: () {
                      if (_currentState == BeginningState.notSure) {
                        setState(() {
                          _currentState = BeginningState.calendar;
                        });
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

  // ─── VIEW 1 & 2: CALENDAR (DEFAULT & SELECTED) ───
  Widget _buildCalendarView() {
    final bool isSelected = _currentState == BeginningState.dateSelected;

    return Column(
      key: const ValueKey('calendar_view'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 3),
        
        // Step Header
        Text(
          'STEP 4 OF 5 — YOUR BEGINNING',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: const Color(0xFFAC7827).withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        
        // Titles
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
        
        // Calendar UI
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E0A12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF381524), width: 1.5),
          ),
          child: Column(
            children: [
              // Calendar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF381524), width: 1.5),
                    ),
                    child: const Icon(Icons.chevron_left, color: Color(0xFF4C2735), size: 18),
                  ),
                  const Text(
                    'June 2023',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF381524), width: 1.5),
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF4C2735), size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Weekdays
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                  return SizedBox(
                    width: 32,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4C2735),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              
              // Days Grid
              _buildDaysGrid(),
            ],
          ),
        ),
        
        const Spacer(flex: 2),
        
        // Selected Date Card (Only visible when selected)
        if (isSelected) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A130C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3A2D1B), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFF8C6D40), size: 16),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'That moment still lives\nsomewhere in you',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFAC884B),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],

        const Text(
          'Even an approximate date is okay You can change this\nlater',
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
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isSelected ? _onSaveAndContinue : null,
            icon: Icon(
              Icons.favorite_outline,
              size: 18,
              color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF4C2735),
            ),
            label: Text(
              "Save and continue",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF4C2735),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1A3C),
              disabledBackgroundColor: const Color(0xFF260D17),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Skip link
        GestureDetector(
          onTap: () {
            setState(() {
              _currentState = BeginningState.notSure;
            });
          },
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
    final List<int?> days = [
      null, null, null, null, 1, 2, 3,
      4, 5, 6, 7, 8, 9, 10,
      11, 12, 13, 14, 15, 16, 17,
      18, 19, 20, 21, 22, 23, 24,
      25, 26, 27, 28, 29, 30, null
    ];

    return Wrap(
      spacing: 0,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: days.map((day) {
        if (day == null) {
          return const SizedBox(width: 32, height: 32);
        }
        
        final is14 = day == 14;
        final isSelected = is14 && _currentState == BeginningState.dateSelected;

        return GestureDetector(
          onTap: () {
            if (is14) {
              setState(() {
                // Toggle selection
                _currentState = isSelected ? BeginningState.calendar : BeginningState.dateSelected;
              });
            }
          },
          child: SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8A2E55),
                    ),
                  ),
                Text(
                  day.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected 
                        ? Colors.white 
                        : (is14 ? const Color(0xFFE89FB8) : const Color(0xFF6B4B55)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: -6,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── VIEW 3: I'M NOT SURE ───
  Widget _buildNotSureView() {
    return Column(
      key: const ValueKey('notsure_view'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        
        // Heart Icon
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
        
        // Option Pills
        _buildPillButton(
          title: "I remember the feeling, not the\ndate",
          reason: NotSureReason.feeling,
          isSelected: _selectedReason == NotSureReason.feeling,
          activeColor: const Color(0xFF6A1A3C), // Maroon
        ),
        const SizedBox(height: 10),
        
        _buildPillButton(
          title: "It started gradually — no\nclear moment",
          reason: NotSureReason.gradually,
          isSelected: _selectedReason == NotSureReason.gradually,
          activeColor: const Color(0xFF3A2D1B), // Olive
        ),
        const SizedBox(height: 10),
        
        _buildPillButton(
          title: "Let me try to remember first",
          reason: NotSureReason.letMeTry,
          isSelected: _selectedReason == NotSureReason.letMeTry,
          activeColor: const Color(0xFF381524), // Dim
          isDashed: true,
        ),
        
        const Spacer(flex: 3),
        
        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _selectedReason != null ? _onSaveAndContinue : null,
            icon: Icon(
              Icons.favorite_outline,
              size: 18,
              color: _selectedReason != null ? Colors.white.withOpacity(0.9) : const Color(0xFF4C2735),
            ),
            label: Text(
              "Continue without a date",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: _selectedReason != null ? Colors.white.withOpacity(0.9) : const Color(0xFF4C2735),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1A3C),
              disabledBackgroundColor: const Color(0xFF1E0A12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: () {
            setState(() {
              _currentState = BeginningState.calendar;
            });
          },
          child: const Text(
            "Take me back to the calendar",
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
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.3) : const Color(0xFF16060D),
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
                color: isSelected ? activeColor.withOpacity(0.8) : const Color(0xFF261019),
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
                  color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF6B4B55),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSaveAndContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerInviteScreen(
          userName: widget.userName,
          partnerName: widget.partnerName,
        ),
      ),
    );
  }
}
