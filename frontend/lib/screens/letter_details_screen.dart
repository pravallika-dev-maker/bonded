import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_letter_screen.dart';
import '../services/api_service.dart';
import '../utils/letter_share_service.dart';

class LetterDetailsScreen extends StatefulWidget {
  final int id;
  final String date;
  final String day;
  final String tag;
  final Color tagBg;
  final Color tagText;
  final Color accentColor;
  final String prompt;
  final String body;

  const LetterDetailsScreen({
    super.key,
    required this.id,
    required this.date,
    required this.day,
    required this.tag,
    required this.tagBg,
    required this.tagText,
    required this.accentColor,
    required this.prompt,
    required this.body,
  });

  @override
  State<LetterDetailsScreen> createState() => _LetterDetailsScreenState();
}

class _LetterDetailsScreenState extends State<LetterDetailsScreen> {
  late String currentBody;
  late String currentTag;
  bool isDeleting = false;
  bool _isSharing = false;
  final GlobalKey _cardRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    currentBody = widget.body;
    currentTag = widget.tag;
  }
  void _editLetter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewLetterScreen(
          letterId: widget.id,
          initialText: currentBody,
          initialTitle: currentTag,
          initialType: currentTag,
        ),
      ),
    );

    if (result == true && mounted) {
      // Reload this screen or let LettersScreen handle reload. We can pop to refresh list.
      Navigator.pop(context, true);
    }
  }

  void _deleteLetter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1833),
        title: const Text('Delete Letter?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to let this go? This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFDD8F9F))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isDeleting = true);
      try {
        await ApiService.deleteLetter(widget.id);
        if (mounted) Navigator.pop(context, true); // Pop to trigger refresh
      } catch (e) {
        if (mounted) {
          setState(() => isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _shareToWhatsApp() async {
    setState(() => _isSharing = true);

    // Wait one frame so the offstage card is fully laid out before capturing
    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;
    await LetterShareService.shareLetterAsCard(
      repaintKey: _cardRepaintKey,
      context: context,
    );
    if (mounted) setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return const Scaffold(
        backgroundColor: Color(0xFF090204),
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9E7E5A))),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        children: [
          // ── MAIN SCAFFOLD ──
          Scaffold(
            backgroundColor: const Color(0xFF090204),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar ──
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7A5C67), size: 16),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'UNSENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF9E7E5A),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF7A5C67), size: 24),
                      color: const Color(0xFF160A0E),
                      onSelected: (value) {
                        if (value == 'edit') _editLetter();
                        if (value == 'delete') _deleteLetter();
                        if (value == 'share') _shareToWhatsApp();
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit', style: TextStyle(color: Colors.white)),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Color(0xFFDD8F9F))),
                        ),
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share_outlined, color: Color(0xFF9E7E5A), size: 18),
                              SizedBox(width: 10),
                              Text('Share to WhatsApp', style: TextStyle(color: Color(0xFF9E7E5A))),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header (Date & Tag) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.date} · ${widget.day}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF6E565E),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.tagBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.tagText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currentTag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: widget.tagText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // ── Prompt ──
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: widget.accentColor, width: 4),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          '"${widget.prompt}"',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Body ──
                      Text(
                        currentBody,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          color: Color(0xFFD4C4CA),
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 64),
                      
                      // Bottom Decoration
                      Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF3D1627),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'LETTER DETAIL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
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

          // ── OFFSCREEN GREETING CARD (for image capture) ──
          Transform.translate(
            offset: const Offset(-9999, -9999),
            child: RepaintBoundary(
              key: _cardRepaintKey,
              child: MediaQuery(
                // Fix text scale so card renders consistently
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: LetterGreetingCard(
                    date: widget.date,
                    day: widget.day,
                    tag: currentTag,
                    accentColor: widget.accentColor,
                    prompt: widget.prompt,
                    body: currentBody,
                  ),
                ),
              ),
            ),
          ),


          // ── SHARING LOADER OVERLAY ──
          if (_isSharing)
            Container(
              color: Colors.black.withAlpha(140),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Creating your card…',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
