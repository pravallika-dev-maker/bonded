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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _separations = [];
  Map<String, dynamic>? _activeSeparation;
  String? _partnerName;
  String? _relationType;
  String? _gender;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchHistory();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    try {
      final results = await Future.wait([
        ApiService.getRelationshipsHistory(),
        ApiService.getActiveSeparation(),
      ]);
      
      final history = results[0] as List<Map<String, dynamic>>;
      final activeSep = results[1] as Map<String, dynamic>?;

      List<Map<String, dynamic>> allSeparations = [];
      String? parsedPartnerName;
      String? parsedRelationType;
      String? parsedGender;

      if (history.isNotEmpty) {
        final referenceRel = history.first;
        parsedPartnerName = referenceRel['partner_name'] ?? referenceRel['partnerName'] ?? referenceRel['partner'];
        parsedRelationType = (referenceRel['relationship_type'] ?? referenceRel['relationType'])?.toString().toLowerCase();
        parsedGender = referenceRel['partner_gender'] ?? referenceRel['gender'] ?? referenceRel['partnerGender'];
        
        final currentRelId = referenceRel['relationship_id'] ?? referenceRel['id'] ?? referenceRel['_id'];
        if (activeSep != null) {
          activeSep['relationship_id'] = currentRelId;
        }

        for (final rel in history) {
          final relId = rel['relationship_id'] ?? rel['id'];
          final relPartnerName = rel['partner_name'] ?? rel['partnerName'] ?? rel['partner'] ?? parsedPartnerName;
          final relRelationType = rel['relationship_type'] ?? rel['relationType'] ?? parsedRelationType;
          final relGender = rel['partner_gender'] ?? rel['gender'] ?? rel['partnerGender'] ?? parsedGender;

          if (relId != null) {
            final seps = await ApiService.getRelationshipSeparations(int.parse(relId.toString()));
            for (var sep in seps) {
              sep['partner_name'] = sep['partner_name'] ?? sep['partnerName'] ?? sep['partner'] ?? relPartnerName ?? 'your partner';
              sep['relationship_type'] = sep['relationship_type'] ?? sep['relationType'] ?? relRelationType;
              sep['partner_gender'] = sep['partner_gender'] ?? sep['partnerGender'] ?? relGender;
              sep['relationship_id'] = relId;

              final sepStatus = (sep['status'] ?? 'COMPLETED').toString().toLowerCase();
              if (sepStatus == 'active' || sepStatus == 'in_progress') {
                continue; // Never show active separations in Past Spaces
              }

              // Validate required fields (Removed daysElapsed as it's not always in completed response)
              final durationLabel = sep['durationLabel'] ?? sep['duration_label'];
              final description = sep['reason'] ?? sep['description'] ?? sep['title'];

              if (durationLabel != null && description != null) {
                allSeparations.add(sep);
              }
            }
          }
        }
      }

      allSeparations.sort((a, b) {
        final startA = a['started_at'] ?? a['startDate'] ?? '';
        final startB = b['started_at'] ?? b['startDate'] ?? '';
        return startB.toString().compareTo(startA.toString());
      });

      if (mounted) {
        setState(() {
          _activeSeparation = activeSep;
          _separations = allSeparations;
          _partnerName = parsedPartnerName;
          _relationType = parsedRelationType;
          _gender = parsedGender;
          
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
    if (start != null) {
      try {
        final s = DateTime.parse(start.toString());
        final e = end != null ? DateTime.parse(end.toString()) : DateTime.now();
        final days = e.difference(s).inDays;
        return '$days ${days == 1 ? 'day' : 'days'} apart';
      } catch (_) {}
    }
    return '';
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
              Container(
                width: double.infinity,
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
                        : _buildTimeline(),
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

  /// Returns true only when the backend confirms an active separation.
  bool get _isActiveSeparation {
    if (_activeSeparation == null) return false;
    final v = _activeSeparation!['isActive'] ?? _activeSeparation!['is_active'];
    if (v == null) return false;
    return v == true;
  }

  Widget _buildTimeline() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        if (_isActiveSeparation || _separations.isNotEmpty) ...[
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
          _buildActiveSeparationCard(_activeSeparation),
          const SizedBox(height: 32),
        ],
        if (_separations.isNotEmpty) ...[
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
        if (_separations.isEmpty)
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
                Icon(!_isActiveSeparation ? Icons.auto_awesome : Icons.history,
                    color: const Color(0xFF9E7E5A), size: 36),
                const SizedBox(height: 16),
                Text(
                  !_isActiveSeparation 
                      ? 'Your shared space timeline is clear.' 
                      : 'No past spaces yet.',
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

          String partnerInfo = pName != null ? 'With $pName' : '';
          if (partnerInfo.isNotEmpty && pGen != null && pGen.isNotEmpty) {
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

  Widget _buildActiveSeparationCard(Map<String, dynamic>? activeSep) {
    final durationLabel = activeSep?['durationLabel'] ?? activeSep?['duration_label'];
    final description = activeSep?['reason'] ?? activeSep?['description'] ?? activeSep?['title'];
    final daysElapsed = activeSep?['days_elapsed'] ?? activeSep?['daysElapsed'];
    final pName = activeSep?['partner_name'] ?? activeSep?['partnerName'] ?? activeSep?['partner'] ?? _partnerName;
    
    final bool hasNullValues = activeSep != null && (durationLabel == null || description == null || daysElapsed == null || pName == null);

    if (activeSep == null || activeSep['isActive'] == false || activeSep['is_active'] == false || hasNullValues) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF26151B), width: 1),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF9E7E5A), size: 36),
            const SizedBox(height: 16),
            const Text(
              '🌱 No active space yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Every meaningful connection grows through patience and understanding.\n\nStart a separation journey whenever you're ready to create space for reflection, growth, and deeper connection.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF866571),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final titleStr = activeSep['title'] ?? activeSep['name'] ?? _getDurationText(activeSep);
    final quoteStr = activeSep['reason'] != null ? '"${activeSep['reason']}"' : null;
    final status = (activeSep['status'] ?? 'IN PROGRESS').toString().toUpperCase();
    final startKey = activeSep['started_at'] ?? activeSep['startDate'];
    final endKey = activeSep['ended_at'] ?? activeSep['endDate'];
    final dateStr = startKey != null ? '${_formatDateRange(startKey, endKey)} • $status' : status;

    final sepCount = activeSep['separation_count'] ?? (_separations.length + 1);
    final relationshipId = activeSep['relationship_id'] ?? activeSep['id'] ?? activeSep['_id'];

    final pGen = activeSep['partner_gender'] ?? activeSep['partnerGender'] ?? activeSep['gender'] ?? _gender;
    final pRel = (activeSep['relationship_type'] ?? activeSep['relationType'])?.toString().toLowerCase() ?? _relationType;
    String partnerInfo = pName != null ? 'With $pName' : '';
    if (partnerInfo.isNotEmpty && pGen != null && pGen.isNotEmpty) {
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
            if (partnerInfo.isNotEmpty) ...[
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
            ],
            if (titleStr.isNotEmpty) ...[
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
            ],
            if (quoteStr != null && quoteStr.isNotEmpty) ...[
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
            ],
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
