import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import 'letters_screen.dart';

class SeparationDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? separationData;
  final bool isActive;
  final int? separationCount;
  final String? relationType;
  final String? gender;
  /// The relationship_id from GET /api/v1/relationships/history.
  /// Used to call the archive-specific endpoints:
  ///   GET /api/v1/relationships/{relationship_id}/summary
  ///   GET /api/v1/relationships/{relationship_id}/letters
  ///   GET /api/v1/relationships/{relationship_id}/separations
  final int? relationshipId;

  const SeparationDetailScreen({
    super.key,
    this.separationData,
    this.isActive = false,
    this.separationCount,
    this.relationType,
    this.gender,
    this.relationshipId,
  });

  @override
  State<SeparationDetailScreen> createState() => _SeparationDetailScreenState();
}

class _SeparationDetailScreenState extends State<SeparationDetailScreen> {
  String _partnerName = 'your connection';
  Map<String, dynamic>? _summary;
  int? _fetchedLettersCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArchiveDetails();
  }

  /// Fetches data exclusively from the archive/relationship history APIs.
  /// Never calls /users/me, /journey/score, /journey/insights, or /partners/me.
  Future<void> _fetchArchiveDetails() async {
    // Partner name comes from local cache (SharedPreferences) — no network call needed.
    final cachedName = await ApiService.getPartnerName();

    Map<String, dynamic>? summary;

    if (!widget.isActive && widget.relationshipId != null) {
      // Archive path: use relationship-history API
      try {
        summary = await ApiService.getRelationshipSummary(widget.relationshipId!);
      } catch (e) {
        debugPrint('SeparationDetailScreen: failed to fetch summary for '
            'relationship_id=${widget.relationshipId}: $e');
      }
    }

    int? fetchedLettersCount;
    if (widget.relationshipId != null) {
      try {
        final letters = await ApiService.getRelationshipLetters(widget.relationshipId!);
        fetchedLettersCount = letters.length;
      } catch (e) {
        debugPrint('SeparationDetailScreen: failed to fetch letters count: $e');
      }
    }
    // For active separations we show only the data already in separationData —
    // no additional network calls are made here, except letters count.

    if (mounted) {
      setState(() {
        _partnerName = cachedName ??
            widget.separationData?['partner_name'] ??
            widget.separationData?['partnerName'] ??
            'your connection';
        _summary = summary;
        _fetchedLettersCount = fetchedLettersCount;
        _isLoading = false;
      });
    }
  }

  String _formatDateRange(dynamic start, dynamic end) {
    if (start == null) return 'MARCH 10 – 17';
    try {
      final startDt = DateTime.parse(start.toString());
      final String startStr = DateFormat('MMMM d').format(startDt).toUpperCase();
      if (end != null) {
        final endDt = DateTime.parse(end.toString());
        final String endStr = DateFormat('d').format(endDt).toUpperCase();
        if (startDt.month != endDt.month) {
          return '$startStr – ${DateFormat('MMMM d').format(endDt).toUpperCase()}';
        }
        return '$startStr – $endStr';
      }
      return startStr;
    } catch (_) {
      return start.toString().toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.separationData ?? {
      'startDate': '2026-03-10',
      'endDate': '2026-03-17',
      'durationLabel': '7 days',
      'reason': 'To understand my feelings better',
      'reflection': 'You learned to sit with your emotions without reacting.',
      'letters_count': 4,
    };

    final String dateRange = _formatDateRange(
      data['started_at'] ?? data['startDate'],
      data['ended_at'] ?? data['endDate'],
    );
    final String duration = data['durationLabel'] ?? data['duration_label'] ?? '7 days';
    final String reason = data['reason'] ?? '';
    final String reflection = data['reflection'] ?? '';

    // letters_count comes from the fetched API call, fallback to history item itself
    final int lettersCount = _fetchedLettersCount ??
        data['letters_count'] ?? data['lettersCount'] ?? data['letter_count'] ?? 0;

    // Bond Resonance score — sourced ONLY from /relationships/{id}/summary.
    // Use journey_score field as specified in the backend docs.
    // Falls back to the journey_score field embedded in the history item itself.
    final dynamic rawScore = _summary?['journey_score'] ??
        _summary?['bond_score'] ??
        _summary?['score'] ??
        _summary?['totalPoints'] ??
        data['journey_score'] ??
        data['score'];

    final int bondScore = rawScore is num ? rawScore.toInt() : 0;
    final String bondLevel = _summary?['level'] ??
        _summary?['aura'] ??
        data['level'] ??
        (bondScore > 200 ? 'Luminous' : bondScore > 100 ? 'Growing' : 'Budding');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.6),
              radius: 1.5,
              colors: [Color(0xFF2E1020), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Header ─────────────────────────────────────────
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF160A0E),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF3F1629)),
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new,
                                      color: Color(0xFFDD8F9F), size: 14),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    if (widget.separationCount != null)
                                      Text(
                                        'SPACE #${widget.separationCount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                          color: Color(0xFF8A2E55),
                                        ),
                                      ),
                                    if (widget.separationCount != null)
                                      const SizedBox(height: 4),
                                    Text(
                                      widget.isActive
                                          ? '$dateRange • IN PROGRESS'
                                          : '$dateRange • COMPLETED',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                        color: widget.isActive
                                            ? const Color(0xFFDD8F9F)
                                            : const Color(0xFF866571),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 34),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // ── Hero Card ───────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF160A0E).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                  color: const Color(0xFF3F1629).withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF000000).withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  duration.toLowerCase().contains('days') ||
                                          duration.toLowerCase().contains('apart')
                                      ? (duration.toLowerCase().contains('apart')
                                          ? duration
                                          : '$duration of')
                                      : '$duration of',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const Text(
                                  'space',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFDD8F9F),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Builder(builder: (context) {
                                  final relType = widget.relationType;
                                  final gen = widget.gender;
                                  String withText = 'with $_partnerName';
                                  if (relType == 'lovers' &&
                                      gen != null &&
                                      gen.isNotEmpty) {
                                    withText += ' • $gen';
                                  }
                                  return Text(
                                    withText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF9E7E5A),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // ── At a Glance ─────────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'DAYS',
                                  value: duration
                                          .replaceAll(RegExp(r'[^0-9]'), '')
                                          .isNotEmpty
                                      ? duration.replaceAll(RegExp(r'[^0-9]'), '')
                                      : '7',
                                  icon: Icons.timelapse,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'LETTERS',
                                  value: lettersCount.toString(),
                                  icon: Icons.mark_email_unread_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),

                          // ── The Story ───────────────────────────────────────
                          if (reason.isNotEmpty || reflection.isNotEmpty) ...[
                            _SectionHeader(title: 'THE STORY'),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160A0E),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                    color: const Color(0xFF3F1629), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (reason.isNotEmpty) ...[
                                    Row(
                                      children: const [
                                        Icon(Icons.format_quote,
                                            color: Color(0xFFDD8F9F), size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Intention',
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '"$reason"',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFD4B1C1),
                                        height: 1.5,
                                      ),
                                    ),
                                    if (reflection.isNotEmpty)
                                      const SizedBox(height: 32),
                                  ],
                                  if (reflection.isNotEmpty) ...[
                                    Row(
                                      children: const [
                                        Icon(Icons.auto_awesome,
                                            color: Color(0xFF9E7E5A), size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'Revelation',
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '"$reflection"',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFDCD2AE),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],

                          // ── Bond Resonance ──────────────────────────────────
                          // Score is sourced from GET /relationships/{id}/summary only.
                          // Not shown for active separations unless summary is available.
                          if (!widget.isActive || _summary != null) ...[
                            _SectionHeader(title: 'BOND RESONANCE'),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2A1525), Color(0xFF160A0E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                    color: const Color(0xFFDD8F9F).withOpacity(0.4),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDD8F9F).withOpacity(0.15),
                                    blurRadius: 40,
                                    spreadRadius: -10,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDD8F9F).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFFDD8F9F)
                                              .withOpacity(0.5),
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFDD8F9F)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                    child: const Icon(Icons.favorite,
                                        color: Color(0xFFDD8F9F), size: 36),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    bondScore > 0
                                        ? '$bondScore Resonance'
                                        : 'Resonance',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDD8F9F).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Aura: $bondLevel',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Color(0xFFDD8F9F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],

                          // ── Letters ─────────────────────────────────────────
                          _SectionHeader(title: 'YOUR LETTERS'),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LettersScreen(
                                    // Pass relationship_id so LettersScreen calls
                                    // GET /api/v1/relationships/{id}/letters
                                    separationId: widget.relationshipId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160A0E),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: const Color(0xFF3F1629), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF000000).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDD8F9F).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.menu_book,
                                        color: Color(0xFFDD8F9F), size: 32),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Revisit Letters',
                                          style: TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 22,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          lettersCount > 0
                                              ? '$lettersCount letters written during this time'
                                              : 'See letters written during this time',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF866571),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Color(0xFFDD8F9F), size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF160A0E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF26151B), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF866571), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF866571),
            ),
          ),
        ],
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
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 3.0,
        color: Color(0xFF6E4555),
      ),
    );
  }
}
