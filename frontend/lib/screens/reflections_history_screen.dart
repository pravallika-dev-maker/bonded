import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ReflectionsHistoryScreen extends StatefulWidget {
  const ReflectionsHistoryScreen({super.key});

  @override
  State<ReflectionsHistoryScreen> createState() => _ReflectionsHistoryScreenState();
}

class _ReflectionsHistoryScreenState extends State<ReflectionsHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reflections = [];
  String? _errorMessage;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Longing', 'Peaceful', 'Reflective', 'Growing'];

  @override
  void initState() {
    super.initState();
    _fetchReflections();
  }

  Future<void> _fetchReflections() async {
    try {
      final data = await ApiService.getMoods();
      if (mounted) {
        setState(() {
          // Sort reflections by date descending (newest first)
          _reflections = data;
          _reflections.sort((a, b) {
            final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
            final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
            return bDate.compareTo(aDate);
          });
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMoodDetails(String mood) {
    final lower = mood.toLowerCase();
    if (lower.contains('longing')) {
      return {
        'icon': Icons.favorite_border,
        'color': const Color(0xFFECAABB),
        'bg': const Color(0xFF3F1629),
      };
    } else if (lower.contains('peaceful')) {
      return {
        'icon': Icons.sentiment_satisfied_outlined,
        'color': const Color(0xFF9E7E5A),
        'bg': const Color(0xFF2E2713),
      };
    } else if (lower.contains('reflective')) {
      return {
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF6A5A8E),
        'bg': const Color(0xFF1E1833),
      };
    } else if (lower.contains('growing')) {
      return {
        'icon': Icons.nature,
        'color': const Color(0xFF4A7A5A),
        'bg': const Color(0xFF132A1E),
      };
    } else {
      return {
        'icon': Icons.favorite,
        'color': const Color(0xFFDD8F9F),
        'bg': const Color(0xFF260D1A),
      };
    }
  }

  String _getDominantMood() {
    if (_reflections.isEmpty) return 'None';
    final Map<String, int> counts = {};
    for (var r in _reflections) {
      final mood = r['mood'] ?? 'Feeling';
      counts[mood] = (counts[mood] ?? 0) + 1;
    }
    String dominant = '';
    int maxCount = 0;
    counts.forEach((key, val) {
      if (val > maxCount) {
        maxCount = val;
        dominant = key;
      }
    });
    return dominant;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == 'All'
        ? _reflections
        : _reflections.where((r) => (r['mood'] ?? '').toString().toLowerCase().contains(_selectedFilter.toLowerCase())).toList();

    final dominantMood = _getDominantMood();
    final dominantDetails = _getMoodDetails(dominantMood);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Back Button Header ---
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // --- Screen Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR REFLECTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A diary of your',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'inner world',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDD8F9F),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Content State ---
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Summary Stats Card ---
                              if (_reflections.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1F0A13), Color(0xFF13060C)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: const Color(0xFF3E1F2C), width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF911746).withOpacity(0.04),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'TOTAL REFLECTIONS',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5A3C47),
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_reflections.length} Entries',
                                                style: const TextStyle(
                                                  fontFamily: 'Georgia',
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                _reflections.length >= 5
                                                    ? 'You are consistently building emotional awareness.'
                                                    : 'Every check-in is a step toward understanding.',
                                                style: const TextStyle(
                                                  fontFamily: 'Georgia',
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: Color(0xFF866571),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: dominantDetails['bg'],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: dominantDetails['color'].withOpacity(0.2)),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(dominantDetails['icon'], color: dominantDetails['color'], size: 24),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'DOMINANT',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF866571),
                                                ),
                                              ),
                                              Text(
                                                dominantMood,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: dominantDetails['color'],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // --- Filter Horizontal Scroll list ---
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Row(
                                  children: _filters.map((filter) {
                                    final isSelected = _selectedFilter == filter;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: ChoiceChip(
                                        label: Text(
                                          filter,
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: isSelected ? Colors.white : const Color(0xFF7A5C67),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedFilter = filter;
                                            });
                                          }
                                        },
                                        selectedColor: const Color(0xFF8A2E55),
                                        backgroundColor: const Color(0xFF160A0E),
                                        side: BorderSide(
                                          color: isSelected ? const Color(0xFFDD8F9F).withOpacity(0.4) : const Color(0xFF26181E),
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        showCheckmark: false,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // --- Reflections List ---
                              Expanded(
                                child: filteredList.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 40.0),
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredList[index];
                                          final mood = item['mood'] ?? 'Feeling';
                                          final reflection = item['reflection'] ?? '';
                                          final dateStr = item['createdAt'] ?? '';

                                          String dateFormatted = 'Today';
                                          String timeFormatted = '';
                                          if (dateStr.isNotEmpty) {
                                            try {
                                              final dt = DateTime.parse(dateStr).toLocal();
                                              dateFormatted = DateFormat('MMMM d, yyyy').format(dt);
                                              timeFormatted = DateFormat('h:mm a').format(dt);
                                            } catch (_) {}
                                          }

                                          final details = _getMoodDetails(mood);

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF160A0E),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFF26151B), width: 1.2),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: details['bg'],
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(color: details['color'].withOpacity(0.2)),
                                                        ),
                                                        child: Icon(details['icon'], color: details['color'], size: 16),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            mood,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: details['color'],
                                                            ),
                                                          ),
                                                          if (timeFormatted.isNotEmpty)
                                                            Text(
                                                              timeFormatted,
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                color: Color(0xFF5A3C47),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        dateFormatted,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(0xFF866571),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (reflection.isNotEmpty) ...[
                                                    const SizedBox(height: 16),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1F0A13).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: const Color(0xFF26181E).withOpacity(0.5)),
                                                      ),
                                                      child: Text(
                                                        '"$reflection"',
                                                        style: const TextStyle(
                                                          fontFamily: 'Georgia',
                                                          fontSize: 14,
                                                          fontStyle: FontStyle.italic,
                                                          color: Color(0xFFD4C4CA),
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDD8F9F), size: 36),
            const SizedBox(height: 16),
            Text(
              'Unable to fetch past reflections.\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF866571), height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchReflections();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3F1629)),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1F0A13).withOpacity(0.3),
                border: Border.all(color: const Color(0xFF3F1629), width: 1.5),
              ),
              child: const Icon(Icons.water_drop_outlined, color: Color(0xFFDD8F9F), size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'All'
                  ? 'Your reflection log is quiet.'
                  : 'No reflections marked as $_selectedFilter yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you sit with your feelings on the dashboard, your reflection history will gather here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF866571),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
