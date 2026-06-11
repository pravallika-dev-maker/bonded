import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_heart_icon.dart';
import '../services/api_service.dart';

class FeelScreen extends StatefulWidget {
  final VoidCallback onReturnHome;

  const FeelScreen({super.key, required this.onReturnHome});

  @override
  State<FeelScreen> createState() => _FeelScreenState();
}

class _FeelScreenState extends State<FeelScreen> with SingleTickerProviderStateMixin {
  String? _selectedMood;
  final TextEditingController _reflectionController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _breathingController;

  List<Map<String, dynamic>> _pastReflections = [];
  bool _isLoadingPastReflections = true;

  final List<Map<String, dynamic>> _moods = [
    {
      'id': 'longing',
      'label': 'Longing',
      'icon': Icons.favorite_border,
      'activeBg': const Color(0xFF3F1629),
      'activeBorder': const Color(0xFF93315C),
      'color': const Color(0xFFECAABB),
    },
    {
      'id': 'peaceful',
      'label': 'Peaceful',
      'icon': Icons.sentiment_satisfied_outlined,
      'activeBg': const Color(0xFF2E2713),
      'activeBorder': const Color(0xFF9E7E5A),
      'color': const Color(0xFF9E7E5A),
    },
    {
      'id': 'reflective',
      'label': 'Reflective',
      'icon': Icons.water_drop_outlined,
      'activeBg': const Color(0xFF1E1833),
      'activeBorder': const Color(0xFF6A5A8E),
      'color': const Color(0xFF6A5A8E),
    },
    {
      'id': 'growing',
      'label': 'Growing',
      'icon': Icons.nature,
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
    _fetchPastReflections();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPastReflections() async {
    try {
      final List<Map<String, dynamic>> fetched = await ApiService.getMoods();
      if (mounted) {
        setState(() {
          _pastReflections = fetched;
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

  void _submit() async {
    if (_selectedMood == null) return;
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Find selected mood label
      final selectedItem = _moods.firstWhere((e) => e['id'] == _selectedMood);
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE • MMMM d').format(now).toUpperCase();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 140.0),
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
                        hintText: 'Just a line or two — only you will see this. No judgement, only space.',
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
                              if (formattedDate.isNotEmpty)
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF7A5C67),
                                  ),
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
}
