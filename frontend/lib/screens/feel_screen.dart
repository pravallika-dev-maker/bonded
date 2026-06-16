import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_heart_icon.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class FeelScreen extends StatefulWidget {
  final VoidCallback onReturnHome;
  final String? insightText;
  final String? awarenessText;
  final String? bottomQuote;
  final String? finalLine;
  final VoidCallback? onInsightViewed;

  const FeelScreen({
    super.key, 
    required this.onReturnHome,
    this.insightText,
    this.awarenessText,
    this.bottomQuote,
    this.finalLine,
    this.onInsightViewed,
  });

  @override
  State<FeelScreen> createState() => _FeelScreenState();
}

class _FeelScreenState extends State<FeelScreen> with TickerProviderStateMixin {
  String? _selectedMood;
  final TextEditingController _reflectionController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _breathingController;

  List<Map<String, dynamic>> _pastReflections = [];
  List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoadingPastReflections = true;
  String? _currentPartnerName;

  bool _isCheckIn = true;
  late AnimationController _switchController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _moods = [
    {
      'id': 'longing',
      'label': 'Longing',
      'icon': Icons.favorite_border,
      'emoji': '❤️',
      'activeBg': const Color(0xFF3F1629),
      'activeBorder': const Color(0xFF93315C),
      'color': const Color(0xFFECAABB),
    },
    {
      'id': 'peaceful',
      'label': 'Peaceful',
      'icon': Icons.sentiment_satisfied_outlined,
      'emoji': '😌',
      'activeBg': const Color(0xFF2E2713),
      'activeBorder': const Color(0xFF9E7E5A),
      'color': const Color(0xFF9E7E5A),
    },
    {
      'id': 'reflective',
      'label': 'Reflective',
      'icon': Icons.water_drop_outlined,
      'emoji': '💭',
      'activeBg': const Color(0xFF1E1833),
      'activeBorder': const Color(0xFF6A5A8E),
      'color': const Color(0xFF6A5A8E),
    },
    {
      'id': 'growing',
      'label': 'Growing',
      'icon': Icons.nature,
      'emoji': '🌱',
      'activeBg': const Color(0xFF132A1E),
      'activeBorder': const Color(0xFF4A7A5A),
      'color': const Color(0xFF4A7A5A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    );
    _switchController.forward();
    
    _fetchPastReflections();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _breathingController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPastReflections() async {
    try {
      final results = await Future.wait([
        ApiService.getMoods(),
        ApiService.getMoodHistory(),
        ApiService.getUserProfile(),
      ]);
      if (mounted) {
        setState(() {
          final profile = results[2] as Map<String, dynamic>;
          _currentPartnerName = profile['partner_name'];
          
          final allMoods = results[0] as List<dynamic>;
          final allHistory = results[1] as List<dynamic>;

          _pastReflections = allMoods.cast<Map<String, dynamic>>();
          _moodHistory = allHistory.cast<Map<String, dynamic>>();

          _isLoadingPastReflections = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPastReflections = false;
        });
      }
    }
  }

  bool get _hasLoggedMoodToday {
    if (_pastReflections.isEmpty) return false;
    final now = DateTime.now();
    for (final item in _pastReflections) {
      final rawDate = item['createdAt'] ?? item['created_at'] ?? '';
      if (rawDate.isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawDate);
          final dt = parsed.toLocal();
          
          debugPrint('DEBUG - Current Local DateTime: $now');
          debugPrint('DEBUG - Current Local Date: ${now.year}-${now.month}-${now.day}');
          debugPrint('DEBUG - Mood createdAt Raw: $rawDate');
          debugPrint('DEBUG - Mood createdAt Local: $dt');
          debugPrint('DEBUG - Computed Mood Date: ${dt.year}-${dt.month}-${dt.day}');
          
          if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
            debugPrint('DEBUG - hasMoodToday: true');
            debugPrint('DEBUG - canSubmitMood: false');
            return true;
          }
        } catch (_) {}
      }
    }
    debugPrint('DEBUG - hasMoodToday: false');
    debugPrint('DEBUG - canSubmitMood: true');
    return false;
  }

  void _submit() async {
    if (_selectedMood == null) return;
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic>? selectedItem;
      for (final e in _moods) {
        if (e['id'] == _selectedMood) {
          selectedItem = e;
          break;
        }
      }
      if (selectedItem == null) throw Exception('Mood not found');
      final String moodLabel = selectedItem['label'] ?? _selectedMood!;

      await ApiService.postMood(
        mood: moodLabel,
        reflection: _reflectionController.text.trim(),
      );

      // Re-fetch past reflections in background so the list is fresh!
      _fetchPastReflections();

      if (mounted) {
        widget.onReturnHome();
        setState(() {
          _isSubmitting = false;
          _selectedMood = null;
          _reflectionController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oops! ${e.toString().replaceAll('Exception:', '').trim()}',
              style: const TextStyle(fontFamily: 'Georgia'),
            ),
            backgroundColor: const Color(0xFF911746),
          ),
        );
      }
    }
  }

  void _switchTab(bool toCheckIn) {
    if (_isCheckIn == toCheckIn) return;
    _switchController.reverse().then((_) {
      setState(() => _isCheckIn = toCheckIn);
      _switchController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insightText != null) {
      return _buildInsightView();
    }

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 48), // Increased top padding to avoid status bar overlap
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.0),
              child: Row(
                children: [
                  Icon(Icons.favorite_border, size: 16, color: Color(0xFF9E7E5A)), // Increased icon size
                  SizedBox(width: 8),
                  Text(
                    'MOOD JOURNEY',
                    style: TextStyle(
                      fontSize: 13, // Increased font size
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Segmented Toggle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF160A0E),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFF26151B), width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _isCheckIn
                                ? const Color(0xFFDD8F9F).withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: _isCheckIn
                                ? Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.3), width: 1)
                                : Border.all(color: Colors.transparent, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Check-in',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: _isCheckIn ? FontStyle.italic : FontStyle.normal,
                              fontWeight: _isCheckIn ? FontWeight.bold : FontWeight.normal,
                              color: _isCheckIn ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: !_isCheckIn
                                ? const Color(0xFFDD8F9F).withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: !_isCheckIn
                                ? Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.3), width: 1)
                                : Border.all(color: Colors.transparent, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Calendar',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              fontStyle: !_isCheckIn ? FontStyle.italic : FontStyle.normal,
                              fontWeight: !_isCheckIn ? FontWeight.bold : FontWeight.normal,
                              color: !_isCheckIn ? const Color(0xFFDD8F9F) : const Color(0xFF5A3C47),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isCheckIn ? _buildCheckInView() : _buildCalendarView(),
              ),
            ),
          ],
        ),

        // ── Submission Success Overlay ──
        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF090204).withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
                      ),
                      child: const AppHeartIcon(size: 80),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Holding this space...',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckInView() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE • MMMM d').format(now).toUpperCase();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 140.0 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF9E7E5A), // Bronze/Gold
                ),
              ),
              const SizedBox(height: 12),
              
              if (_isLoadingPastReflections)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.0),
                    child: CircularProgressIndicator(color: Color(0xFFDD8F9F)),
                  ),
                )
              else if (_hasLoggedMoodToday) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF160A0E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF26181E), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFF8A2E55), size: 40),
                      const SizedBox(height: 16),
                      const Text(
                        'You\'ve already held space\nfor your feelings today.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Patience is part of the journey.\nCome back tomorrow to reflect again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF866571),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: widget.onReturnHome,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3F1629), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'return to home',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFDD8F9F),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  'Right now,',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'your heart feels',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFDD8F9F), // Pink rose
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Mood Selector ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moods.map((mood) {
                    final isSelected = _selectedMood == mood['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = mood['id'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 76,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isSelected ? mood['activeBg'] : const Color(0xFF160A0E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? mood['activeBorder'] : const Color(0xFF26181E),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mood['icon'],
                              color: mood['color'],
                              size: 28,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: mood['color'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // ── Reflection Area ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0A13), // Dark Maroon
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF3F1629), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '"What\'s beneath this feeling today?"',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFD4C4CA),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reflectionController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tap here to type a line or two — only you will see this. No judgement, only space.',
                          hintMaxLines: 2,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7A5C67),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Buttons ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _selectedMood != null ? _submit : null,
                    icon: Icon(
                      Icons.favorite,
                      size: 18,
                      color: _selectedMood != null ? Colors.white : const Color(0xFF3D242E),
                    ),
                    label: Text(
                      'Hold this feeling',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: _selectedMood != null ? Colors.white : const Color(0xFF3D242E),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: widget.onReturnHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF26181E), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: const Text(
                      'not today',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF7A5C67),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              
              // ── Past Reflections Section ──
              const Row(
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 14, color: Color(0xFF9E7E5A)),
                  SizedBox(width: 8),
                  Text(
                    'YOUR PAST REFLECTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF9E7E5A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_isLoadingPastReflections)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                      ),
                    ),
                  ),
                )
              else if (_pastReflections.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF160A0E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26181E), width: 1.0),
                  ),
                  child: const Text(
                    'No reflections recorded yet. Your expressions will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF7A5C67),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pastReflections.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _pastReflections[index];
                    final String mood = item['mood'] ?? 'Feeling';
                    final String reflection = item['reflection'] ?? '';
                    final String rawDate = item['createdAt'] ?? '';
                    
                    String formattedDate = '';
                    if (rawDate.isNotEmpty) {
                      try {
                        final dt = DateTime.parse(rawDate).toLocal();
                        formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(dt);
                      } catch (_) {}
                    }

                    // Map string to our cute icons/colors
                    IconData moodIcon = Icons.favorite_border;
                    Color moodColor = const Color(0xFFECAABB);
                    if (mood.toLowerCase().contains('peaceful')) {
                      moodIcon = Icons.sentiment_satisfied_outlined;
                      moodColor = const Color(0xFF9E7E5A);
                    } else if (mood.toLowerCase().contains('reflective')) {
                      moodIcon = Icons.water_drop_outlined;
                      moodColor = const Color(0xFF6A5A8E);
                    } else if (mood.toLowerCase().contains('growing')) {
                      moodIcon = Icons.nature;
                      moodColor = const Color(0xFF4A7A5A);
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F0A13).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF26181E), width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(moodIcon, size: 16, color: moodColor),
                              const SizedBox(width: 8),
                              Text(
                                mood,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: moodColor,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (formattedDate.isNotEmpty)
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF7A5C67),
                                      ),
                                    ),
                                  if (item['partner_name'] != null && item['partner_name'] != _currentPartnerName && item['partner_name'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3F1629),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Past Separation: With ${item['partner_name']}',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDD8F9F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          if (reflection.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"$reflection"',
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFD4C4CA),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
  }

  Widget _buildCalendarView() {
    if (_isLoadingPastReflections) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F))),
      );
    }
    return _MoodCalendarWidget(
      moodHistory: _moodHistory,
      moodDefinitions: _moods,
    );
  }

  Widget _buildInsightView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 40.0, bottom: 140.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "A SMALL REFLECTION FOR YOU",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF8A6530),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "\"Today's Insight\"",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            widget.insightText!,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: Color(0xFFD4C4CA),
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 40),
          
          const Text(
            "GENTLE AWARENESS",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF9E7E5A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "\"${widget.awarenessText}\"",
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFFCE9B4E),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 60),
          
          Center(
            child: Column(
              children: [
                Text(
                  "\"${widget.bottomQuote}\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF5A3C47),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.finalLine ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3D242E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onInsightViewed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2E55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF8A2E55).withOpacity(0.4),
              ),
              child: const Text(
                "I'll reflect on this",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood Calendar Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MoodCalendarWidget extends StatefulWidget {
  final List<Map<String, dynamic>> moodHistory;
  final List<Map<String, dynamic>> moodDefinitions;

  const _MoodCalendarWidget({
    required this.moodHistory,
    required this.moodDefinitions,
  });

  @override
  State<_MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<_MoodCalendarWidget> with SingleTickerProviderStateMixin {
  late DateTime _focusedMonth;
  Map<String, dynamic>? _selectedMoodEntry;
  DateTime? _selectedDay;

  late AnimationController _monthController;
  late Animation<double> _monthFade;
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _monthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _monthFade = CurvedAnimation(parent: _monthController, curve: Curves.easeInOut);
    _monthController.forward();
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    _slideDirection = delta;
    _monthController.reverse().then((_) {
      setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
        _selectedDay = null;
        _selectedMoodEntry = null;
      });
      _monthController.forward();
    });
  }

  Map<String, dynamic>? _moodForDay(DateTime day) {
    final dStr = DateFormat('yyyy-MM-dd').format(day);
    for (final m in widget.moodHistory) {
      if (m['date'] == dStr) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final today = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Month Navigator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MonthNavButton(icon: Icons.chevron_left, onTap: () => _changeMonth(-1)),
                Column(
                  children: [
                    Text(
                      DateFormat('MMMM').format(_focusedMonth).toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      _focusedMonth.year.toString(),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9E7E5A), letterSpacing: 2.0),
                    ),
                  ],
                ),
                _MonthNavButton(icon: Icons.chevron_right, onTap: () => _changeMonth(1)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Weekday Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Color(0xFF5A3C47),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FadeTransition(
              opacity: _monthFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(_slideDirection * 0.08, 0),
                  end: Offset.zero,
                ).animate(_monthFade),
                child: _buildGrid(startWeekday, daysInMonth, firstDay, today),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthSummary(),
          const SizedBox(height: 12),
          if (_selectedMoodEntry != null)
            _buildSelectedCard(_selectedMoodEntry!)
          else
            _buildEmptyHint(),
        ],
      ),
    );
  }

  Widget _buildGrid(int startWeekday, int daysInMonth, DateTime firstDay, DateTime today) {
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (int row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: List.generate(7, (int col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startWeekday + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final moodEntry = _moodForDay(day);
              final isHighlighted = moodEntry != null;
              final isSelected = _selectedDay != null &&
                  _selectedDay!.year == day.year &&
                  _selectedDay!.month == day.month &&
                  _selectedDay!.day == day.day;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              Map<String, dynamic>? moodDef;
              if (moodEntry != null) {
                final mType = (moodEntry['mood'] ?? '').toString().toLowerCase();
                for (final def in widget.moodDefinitions) {
                  if (def['id'] == mType) {
                    moodDef = def;
                    break;
                  }
                }
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isHighlighted) {
                      setState(() {
                        _selectedDay = day;
                        _selectedMoodEntry = moodEntry;
                      });
                    }
                  },
                  child: _MoodDayCell(
                    day: dayNum,
                    isHighlighted: isHighlighted,
                    isSelected: isSelected,
                    isToday: isToday,
                    moodDef: moodDef,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildMonthSummary() {
    int count = 0;
    for (final m in widget.moodHistory) {
      if (m['date'] != null && m['date'].toString().startsWith(DateFormat('yyyy-MM').format(_focusedMonth))) {
        count++;
      }
    }
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3F1629), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Color(0xFF8A2E55), size: 12),
          const SizedBox(width: 8),
          Text(
            '$count check-in${count == 1 ? '' : 's'} this month',
            style: const TextStyle(fontSize: 11, color: Color(0xFF866571), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(Map<String, dynamic> entry) {
    final mType = (entry['mood'] ?? '').toString().toLowerCase();
    Map<String, dynamic>? moodDef;
    for (final def in widget.moodDefinitions) {
      if (def['id'] == mType) {
        moodDef = def;
        break;
      }
    }

    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.parse(entry['date']));
    final icon = moodDef?['icon'] ?? Icons.favorite_border;
    final color = moodDef?['color'] ?? const Color(0xFFDD8F9F);
    final label = moodDef?['label'] ?? mType;
    final note = entry['note'] ?? '';
    final partnerName = entry['partner_name'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1F0A13),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF866747),
                      ),
                    ),
                    if (partnerName != null && partnerName.toString().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F1629),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'With $partnerName',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Color(0xFFDD8F9F),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (note.toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '"$note"',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFD4C4CA),
                      height: 1.4,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Just held space for this feeling.',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF866571),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app_outlined, color: Color(0xFF3F1629), size: 28),
          const SizedBox(height: 10),
          const Text(
            'Tap a checked-in date\nto see how you felt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF5A3C47),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodDayCell extends StatelessWidget {
  final int day;
  final bool isHighlighted;
  final bool isSelected;
  final bool isToday;
  final Map<String, dynamic>? moodDef;

  const _MoodDayCell({
    required this.day,
    required this.isHighlighted,
    required this.isSelected,
    required this.isToday,
    this.moodDef,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor = const Color(0xFF5A3C47);
    Color? borderColor;
    
    if (isSelected && isHighlighted) {
      bgColor = const Color(0xFF3F1629);
      textColor = moodDef?['color'] ?? const Color(0xFFECAABB);
      borderColor = moodDef?['color'] ?? const Color(0xFFECAABB);
    } else if (isHighlighted) {
      bgColor = const Color(0xFF160A0E);
      textColor = moodDef?['color'] ?? const Color(0xFFECAABB);
    } else if (isToday) {
      borderColor = const Color(0xFF9E7E5A);
      textColor = const Color(0xFF9E7E5A);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(2),
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor, width: 1.2) : null,
      ),
      alignment: Alignment.center,
      child: isHighlighted && moodDef != null && moodDef!['emoji'] != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  moodDef!['emoji'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            )
          : Text(
              day.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: (isHighlighted || isToday) ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF26151B), width: 1),
        ),
        child: Icon(icon, color: const Color(0xFF7A5C67), size: 20),
      ),
    );
  }
}
