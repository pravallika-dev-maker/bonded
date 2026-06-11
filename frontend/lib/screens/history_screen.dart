import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'separation_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isTimeline = true;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _separations = [];
  Map<String, dynamic>? _activeSeparation;
  String? _partnerName;
  String? _relationType;
  String? _gender;

  late AnimationController _switchController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    );
    _switchController.forward();
    _fetchHistory();
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    try {
      final history = await ApiService.getRelationshipsHistory();
      
      if (mounted) {
        setState(() {
          final pastSeps = <Map<String, dynamic>>[];
          Map<String, dynamic>? activeSep;
          
          for (final sep in history) {
            final status = (sep['status'] ?? '').toString().toLowerCase();
            if (status == 'active' || status == 'in_progress' || status == 'in progress') {
              activeSep = sep;
            } else {
              pastSeps.add(sep);
            }
          }
          
          _activeSeparation = activeSep;
          _separations = pastSeps;
          
          // Use verified backend field names from GET /api/v1/relationships/history:
          // relationship_id, partner_name, partner_gender, relationship_type
          final referenceSep = _activeSeparation ?? (_separations.isNotEmpty ? _separations.first : null);
          if (referenceSep != null) {
            _partnerName = referenceSep['partner_name'] ?? referenceSep['partnerName'] ?? referenceSep['partner'];
            _relationType = (referenceSep['relationship_type'] ?? referenceSep['relationType'])?.toString().toLowerCase();
            _gender = referenceSep['partner_gender'] ?? referenceSep['gender'] ?? referenceSep['partnerGender'];
          }
          
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _switchTab(bool toTimeline) {
    if (_isTimeline == toTimeline) return;
    _switchController.reverse().then((_) {
      setState(() => _isTimeline = toTimeline);
      _switchController.forward();
    });
  }

  String _formatDateRange(dynamic start, dynamic end) {
    if (start == null) return 'UNKNOWN DATES';
    try {
      final startDt = DateTime.parse(start.toString());
      final String startStr = DateFormat('MMMM d').format(startDt).toUpperCase();
      if (end != null) {
        final endDt = DateTime.parse(end.toString());
        if (startDt.month != endDt.month) {
          return '$startStr–${DateFormat('MMMM d').format(endDt).toUpperCase()}';
        }
        return '$startStr–${DateFormat('d').format(endDt).toUpperCase()}';
      }
      return startStr;
    } catch (_) {
      return start.toString().toUpperCase();
    }
  }

  String _getDurationText(Map<String, dynamic> item) {
    final label = item['durationLabel'] ?? item['duration_label'];
    if (label != null && label.toString().isNotEmpty) {
      if (label.toString().toLowerCase().contains('apart')) return label.toString();
      return '$label apart';
    }
    final start = item['started_at'] ?? item['startDate'];
    final end = item['ended_at'] ?? item['endDate'];
    if (start != null && end != null) {
      try {
        final s = DateTime.parse(start.toString());
        final e = DateTime.parse(end.toString());
        final days = e.difference(s).inDays;
        return '$days ${days == 1 ? 'day' : 'days'} apart';
      } catch (_) {}
    }
    return '3 days apart';
  }

  List<_Tag> _buildTags(Map<String, dynamic> item) {
    final List<_Tag> tagWidgets = [];
    final String reason = (item['reason'] ?? '').toString().toLowerCase();

    if (item['durationLabel'] != null) {
      final String dur = item['durationLabel'].toString();
      if (dur.contains('7') || dur.contains('7 days')) {
        tagWidgets.add(const _Tag(
            label: 'Reflective',
            bgColor: Color(0xFF2D1C35),
            textColor: Color(0xFF9D7CAE)));
      } else {
        tagWidgets.add(const _Tag(
            label: 'Calm',
            bgColor: Color(0xFF3F1629),
            textColor: Color(0xFFECAABB)));
      }
    } else {
      tagWidgets.add(const _Tag(
          label: 'Calm',
          bgColor: Color(0xFF3F1629),
          textColor: Color(0xFFECAABB)));
    }

    if (reason.contains('clarity') || reason.contains('understand')) {
      tagWidgets.add(const _Tag(
          label: 'Insightful',
          bgColor: Color(0xFF1E3A2F),
          textColor: Color(0xFF8CD8B4)));
    } else if (reason.contains('miss') || reason.contains('longing')) {
      tagWidgets.add(const _Tag(
          label: 'Longing',
          bgColor: Color(0xFF331521),
          textColor: Color(0xFF864A5C)));
    } else {
      tagWidgets.add(const _Tag(
          label: 'Growth',
          bgColor: Color(0xFF322315),
          textColor: Color(0xFF9E7E5A)));
    }

    final lettersCount = item['lettersCount'] ?? item['letters_count'];
    if (lettersCount != null && lettersCount > 0) {
      tagWidgets.add(_Tag(
          label: '$lettersCount letters',
          bgColor: const Color(0xFF331521),
          textColor: const Color(0xFF864A5C)));
    }

    final score = item['journey_score'] ?? item['score'];
    if (score != null) {
      tagWidgets.add(_Tag(
          label: 'Score: $score',
          bgColor: const Color(0xFF16253F),
          textColor: const Color(0xFF8CA5D8)));
    }
    if (item['insightsCount'] != null || (item['insights'] is List)) {
      final insightsCount = item['insightsCount'] ?? (item['insights'] as List).length;
      if (insightsCount > 0) {
        tagWidgets.add(_Tag(
            label: '$insightsCount insights',
            bgColor: const Color(0xFF3F3516),
            textColor: const Color(0xFFD8CA8C)));
      }
    }

    return tagWidgets;
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
              // ── Back button ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // ── Header ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR HISTORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Color(0xFF9E7E5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Spaces you've",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'lived through',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDD8F9F),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Segmented Toggle ──
                    Container(
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
                                  color: _isTimeline
                                      ? const Color(0xFFDD8F9F).withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: _isTimeline
                                      ? Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.3), width: 1)
                                      : Border.all(color: Colors.transparent, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Timeline',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 14,
                                    fontStyle: _isTimeline ? FontStyle.italic : FontStyle.normal,
                                    fontWeight: _isTimeline
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _isTimeline
                                        ? const Color(0xFFDD8F9F)
                                        : const Color(0xFF5A3C47),
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
                                  color: !_isTimeline
                                      ? const Color(0xFFDD8F9F).withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: !_isTimeline
                                      ? Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.3), width: 1)
                                      : Border.all(color: Colors.transparent, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Calendar',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 14,
                                    fontStyle: !_isTimeline ? FontStyle.italic : FontStyle.normal,
                                    fontWeight: !_isTimeline
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !_isTimeline
                                        ? const Color(0xFFDD8F9F)
                                        : const Color(0xFF5A3C47),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFDD8F9F)),
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: _isTimeline
                                ? _buildTimeline()
                                : _buildCalendar(),
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
            const Icon(Icons.error_outline,
                color: Color(0xFFDD8F9F), size: 36),
            const SizedBox(height: 16),
            Text(
              'Unable to connect to the space history.\n$_errorMessage',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Color(0xFF866571), height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchHistory();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3F1629)),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        if (_activeSeparation != null) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0, left: 4.0),
            child: Text(
              'CURRENT SPACE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFFDD8F9F),
              ),
            ),
          ),
          _buildActiveSeparationCard(_activeSeparation!),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
            child: Text(
              'PAST SPACES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFF9E7E5A),
              ),
            ),
          ),
        ],
        if (_separations.isEmpty && _activeSeparation == null)
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF160A0E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFF26151B), width: 1),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome,
                    color: Color(0xFF9E7E5A), size: 36),
                const SizedBox(height: 16),
                const Text(
                  'Your shared space timeline is clear.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'When you complete a separation, your reflection history will appear here.',
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

        ..._separations.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          final separationCount = item['separation_count'] ?? (_separations.length - index);

          // Use verified backend field names
          final relationshipId = item['relationship_id'] ?? item['id'] ?? item['_id'];

          final status = (item['status'] ?? 'COMPLETED').toString().toUpperCase();
          final startKey = item['started_at'] ?? item['startDate'];
          final endKey = item['ended_at'] ?? item['endDate'];
          final dateStr = '${_formatDateRange(startKey, endKey)} • $status';
          
          final titleStr = item['title'] ?? item['name'] ?? _getDurationText(item);
          final quoteStr = item['reason'] != null
              ? '"${item['reason']}"'
              : '"Quietly growing"';
          
          final durationLabel = item['durationLabel'] ?? item['duration_label'] ?? '';
          final durationDays = durationLabel.toString().contains('2') ? 2 : 7;

          // Use verified backend field names for partner data
          final pName = item['partner_name'] ?? item['partnerName'] ?? item['partner'] ?? _partnerName;
          final pGen = item['partner_gender'] ?? item['partnerGender'] ?? item['gender'] ?? _gender;
          final pRel = (item['relationship_type'] ?? item['relationType'])?.toString().toLowerCase() ?? _relationType;

          String partnerInfo = pName != null ? 'With $pName' : 'Shared Space';
          if (pGen != null && pGen.isNotEmpty) {
            partnerInfo += ' • $pGen';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SeparationDetailScreen(
                    separationData: item,
                    separationCount: separationCount,
                    relationshipId: relationshipId != null ? int.tryParse(relationshipId.toString()) : null,
                    relationType: pRel ?? _relationType,
                    gender: pGen ?? _gender,
                  ),
                ),
              ),
              child: durationDays <= 2
                  ? _ShortHistoryCard(
                      dateText:
                          dateStr.replaceFirst(' • COMPLETED', ' • SHORT'),
                      title: titleStr,
                      quote: quoteStr,
                      partnerInfo: partnerInfo,
                      separationCount: separationCount,
                    )
                  : _CompletedHistoryCard(
                      dateText: dateStr,
                      title: titleStr,
                      quote: quoteStr,
                      accentColor: const Color(0xFF8A2E55),
                      tags: _buildTags(item),
                      partnerInfo: partnerInfo,
                      separationCount: separationCount,
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActiveSeparationCard(Map<String, dynamic> activeSep) {
    final titleStr = activeSep['title'] ?? activeSep['name'] ?? _getDurationText(activeSep);
    final quoteStr = activeSep['reason'] != null ? '"${activeSep['reason']}"' : '"Growing through space"';
    final status = (activeSep['status'] ?? 'IN PROGRESS').toString().toUpperCase();
    final startKey = activeSep['started_at'] ?? activeSep['startDate'];
    final endKey = activeSep['ended_at'] ?? activeSep['endDate'];
    final dateStr = '${_formatDateRange(startKey, endKey)} • $status';

    final sepCount = activeSep['separation_count'] ?? (_separations.length + 1);
    final relationshipId = activeSep['relationship_id'] ?? activeSep['id'] ?? activeSep['_id'];

    final pName = activeSep['partner_name'] ?? activeSep['partnerName'] ?? activeSep['partner'] ?? _partnerName;
    final pGen = activeSep['partner_gender'] ?? activeSep['partnerGender'] ?? activeSep['gender'] ?? _gender;
    final pRel = (activeSep['relationship_type'] ?? activeSep['relationType'])?.toString().toLowerCase() ?? _relationType;
    String partnerInfo = pName != null ? 'With $pName' : 'Shared Space';
    if (pGen != null && pGen.isNotEmpty) {
      partnerInfo += ' • $pGen';
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeparationDetailScreen(
            separationData: activeSep, 
            isActive: true,
            separationCount: sepCount,
            relationshipId: relationshipId != null ? int.tryParse(relationshipId.toString()) : null,
            relationType: pRel,
            gender: pGen,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F1629), Color(0xFF160A0E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDD8F9F).withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDD8F9F).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDD8F9F).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDD8F9F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ACTIVE SPACE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Color(0xFFDD8F9F),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  dateStr.split(' • ').first,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFFD4B1C1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, color: Color(0xFFDD8F9F), size: 16),
                const SizedBox(width: 8),
                Text(
                  partnerInfo,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFDD8F9F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              titleStr,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              quoteStr,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xFFECAABB),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Text(
                  'Tap to enter space',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Color(0xFFD4B1C1),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDD8F9F).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Color(0xFFDD8F9F), size: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return _CalendarView(
      separations: _separations,
      onSeparationTap: (item) {
        final totalSeps = _separations.length;
        final index = _separations.indexOf(item);
        final separationCount = index != -1 ? totalSeps - index : null;
        final relationshipId = item['relationship_id'] ?? item['id'] ?? item['_id'];
        final pGen = item['partner_gender'] ?? item['partnerGender'] ?? item['gender'] ?? _gender;
        final pRel = (item['relationship_type'] ?? item['relationType'])?.toString().toLowerCase() ?? _relationType;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeparationDetailScreen(
              separationData: item,
              separationCount: separationCount,
              relationshipId: relationshipId != null ? int.tryParse(relationshipId.toString()) : null,
              relationType: pRel,
              gender: pGen,
            ),
          ),
        );
      },
      formatDateRange: _formatDateRange,
      getDurationText: _getDurationText,
      partnerName: _partnerName,
      relationType: _relationType,
      gender: _gender,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar View
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarView extends StatefulWidget {
  final List<Map<String, dynamic>> separations;
  final void Function(Map<String, dynamic>) onSeparationTap;
  final String Function(dynamic, dynamic) formatDateRange;
  final String Function(Map<String, dynamic>) getDurationText;
  final String? partnerName;
  final String? relationType;
  final String? gender;

  const _CalendarView({
    required this.separations,
    required this.onSeparationTap,
    required this.formatDateRange,
    required this.getDurationText,
    this.partnerName,
    this.relationType,
    this.gender,
  });

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedMonth;
  Map<String, dynamic>? _selectedSeparation;
  DateTime? _selectedDay;

  late AnimationController _monthController;
  late Animation<double> _monthFade;
  int _slideDirection = 1; // 1 = forward, -1 = backward

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _monthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _monthFade = CurvedAnimation(
      parent: _monthController,
      curve: Curves.easeInOut,
    );
    _monthController.forward();

    // Default focus on the most recent separation's month
    if (widget.separations.isNotEmpty) {
      try {
        final recent = widget.separations.last;
        final dt = DateTime.parse(recent['startDate'].toString());
        _focusedMonth = DateTime(dt.year, dt.month);
      } catch (_) {}
    }
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
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + delta);
        _selectedDay = null;
        _selectedSeparation = null;
      });
      _monthController.forward();
    });
  }

  /// Returns the separation that contains this date, or null.
  Map<String, dynamic>? _separationForDay(DateTime day) {
    for (final sep in widget.separations) {
      try {
        final start =
            DateTime.parse(sep['startDate'].toString()).toLocal();
        final end =
            DateTime.parse(sep['endDate'].toString()).toLocal();
        final d = DateTime(day.year, day.month, day.day);
        final s = DateTime(start.year, start.month, start.day);
        final e = DateTime(end.year, end.month, end.day);
        if (!d.isBefore(s) && !d.isAfter(e)) return sep;
      } catch (_) {}
    }
    return null;
  }

  bool _isRangeStart(DateTime day) {
    for (final sep in widget.separations) {
      try {
        final start =
            DateTime.parse(sep['startDate'].toString()).toLocal();
        if (DateTime(day.year, day.month, day.day) ==
            DateTime(start.year, start.month, start.day)) { return true; }
      } catch (_) {}
    }
    return false;
  }

  bool _isRangeEnd(DateTime day) {
    for (final sep in widget.separations) {
      try {
        final end =
            DateTime.parse(sep['endDate'].toString()).toLocal();
        if (DateTime(day.year, day.month, day.day) ==
            DateTime(end.year, end.month, end.day)) { return true; }
      } catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0 ... Sat=6

    final today = DateTime.now();

    return Column(
      children: [
        // ── Month Navigator ──
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MonthNavButton(
                icon: Icons.chevron_left,
                onTap: () => _changeMonth(-1),
              ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E7E5A),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              _MonthNavButton(
                icon: Icons.chevron_right,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Weekday Labels ──
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

        // ── Calendar Grid ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FadeTransition(
            opacity: _monthFade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_slideDirection * 0.08, 0),
                end: Offset.zero,
              ).animate(_monthFade),
              child: _buildGrid(
                  startWeekday, daysInMonth, firstDay, today),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Separation Count Pill ──
        _buildMonthSummary(),

        const SizedBox(height: 12),

        // ── Selected Card ──
        if (_selectedSeparation != null)
          Expanded(child: _buildSelectedCard(_selectedSeparation!))
        else
          Expanded(child: _buildCalendarEmptyHint()),
      ],
    );
  }

  Widget _buildGrid(
      int startWeekday, int daysInMonth, DateTime firstDay, DateTime today) {
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startWeekday + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final day = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayNum);
              final sep = _separationForDay(day);
              final isHighlighted = sep != null;
              final isStart = _isRangeStart(day);
              final isEnd = _isRangeEnd(day);
              final isSelected = _selectedDay != null &&
                  _selectedDay!.year == day.year &&
                  _selectedDay!.month == day.month &&
                  _selectedDay!.day == day.day;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              return Expanded(
                child: GestureDetector(
                  onTap: isHighlighted
                      ? () {
                          setState(() {
                            _selectedDay = day;
                            _selectedSeparation = sep;
                          });
                        }
                      : null,
                  child: _DayCell(
                    day: dayNum,
                    isHighlighted: isHighlighted,
                    isStart: isStart,
                    isEnd: isEnd,
                    isSelected: isSelected,
                    isToday: isToday,
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
    for (final sep in widget.separations) {
      try {
        final start =
            DateTime.parse(sep['startDate'].toString()).toLocal();
        final end =
            DateTime.parse(sep['endDate'].toString()).toLocal();
        // Check if any part of this separation overlaps with the focused month
        final monthStart =
            DateTime(_focusedMonth.year, _focusedMonth.month, 1);
        final monthEnd =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
        if (!start.isAfter(monthEnd) && !end.isBefore(monthStart)) {
          count++;
        }
      } catch (_) {}
    }

    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3F1629), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite,
              color: Color(0xFF8A2E55), size: 12),
          const SizedBox(width: 8),
          Text(
            '$count separation${count == 1 ? '' : 's'} this month',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF866571),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCard(Map<String, dynamic> sep) {
    final dateStr =
        widget.formatDateRange(sep['startDate'], sep['endDate']);
    final duration = widget.getDurationText(sep);
    final reason = sep['reason'] ?? 'A space of quiet growth';

    final totalSeps = widget.separations.length;
    final index = widget.separations.indexOf(sep);
    final separationCount = index != -1 ? totalSeps - index : null;

    String partnerInfo = widget.partnerName != null ? 'With ${widget.partnerName}' : 'Shared Space';
    if (widget.relationType == 'lovers' && widget.gender != null && widget.gender!.isNotEmpty) {
      partnerInfo += ' • ${widget.gender!}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: GestureDetector(
        onTap: () => widget.onSeparationTap(sep),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1F0A13),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFF8A2E55), width: 4),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (separationCount != null)
                        Text(
                          'SEPARATION #$separationCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF8A2E55),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F1629),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TAP TO VIEW',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF864A5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF866747),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: Color(0xFFDD8F9F), size: 14),
                      const SizedBox(width: 8),
                      Text(
                        partnerInfo,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFDD8F9F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"$reason"',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF866571),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.arrow_forward_ios,
                          color: Color(0xFF4A343D), size: 12),
                      SizedBox(width: 6),
                      Text(
                        'View full reflection',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A343D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarEmptyHint() {
    if (widget.separations.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF160A0E),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: const Color(0xFF26151B), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF9E7E5A), size: 32),
              const SizedBox(height: 14),
              const Text(
                'No separations recorded yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completed separations will be highlighted on the calendar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF866571),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app_outlined,
              color: Color(0xFF3F1629), size: 28),
          const SizedBox(height: 10),
          const Text(
            'Tap a highlighted date\nto see its reflection',
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

// ─────────────────────────────────────────────────────────────────────────────
// Day Cell
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isHighlighted;
  final bool isStart;
  final bool isEnd;
  final bool isSelected;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.isHighlighted,
    required this.isStart,
    required this.isEnd,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor = const Color(0xFF5A3C47);
    Color? borderColor;

    if (isSelected && isHighlighted) {
      bgColor = const Color(0xFFDD8F9F);
      textColor = Colors.white;
    } else if (isStart || isEnd) {
      bgColor = const Color(0xFF8A2E55);
      textColor = Colors.white;
    } else if (isHighlighted) {
      bgColor = const Color(0xFF3F1629);
      textColor = const Color(0xFFECAABB);
    } else if (isToday) {
      borderColor = const Color(0xFF9E7E5A);
      textColor = const Color(0xFF9E7E5A);
    } else {
      textColor = const Color(0xFF5A3C47);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(2),
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: TextStyle(
          fontSize: 13,
          fontWeight:
              (isHighlighted || isToday) ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month Navigation Button
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Existing card / tag / painter widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedHistoryCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String quote;
  final Color accentColor;
  final List<_Tag> tags;
  final String partnerInfo;
  final int separationCount;

  const _CompletedHistoryCard({
    required this.dateText,
    required this.title,
    required this.quote,
    required this.accentColor,
    required this.tags,
    required this.partnerInfo,
    required this.separationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A13),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 4.0),
            ),
          ),
          padding: const EdgeInsets.only(
              left: 20, top: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SEPARATION #$separationCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF8A2E55),
                    ),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF866747),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people_outline, color: Color(0xFFDD8F9F), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    partnerInfo,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFDD8F9F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                quote,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF866571),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortHistoryCard extends StatelessWidget {
  final String dateText;
  final String title;
  final String quote;
  final String partnerInfo;
  final int separationCount;

  const _ShortHistoryCard({
    required this.dateText,
    required this.title,
    required this.quote,
    required this.partnerInfo,
    required this.separationCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SEPARATION #$separationCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Color(0xFF6E565E),
                  ),
                ),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Color(0xFF3D242E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people_outline, color: Color(0xFF6E565E), size: 14),
                const SizedBox(width: 8),
                Text(
                  partnerInfo,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6E565E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E565E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFF4A343D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26151B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _createDashedPath(path, 8, 6);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashSpace) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length =
            math.min(dashLength, metric.length - distance);
        dest.addPath(
            metric.extractPath(distance, distance + length), Offset.zero);
        distance += dashLength + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
