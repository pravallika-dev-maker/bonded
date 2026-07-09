import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

/// Generates a beautiful Bonded-branded greeting card image from a letter
/// and opens the native share sheet so the user can share to WhatsApp etc.
class LetterShareService {
  /// [repaintKey] must wrap the `_LetterGreetingCard` widget placed offstage.
  static Future<void> shareLetterAsCard({
    required GlobalKey repaintKey,
    required BuildContext context,
  }) async {
    // Capture messenger before any async gap
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Find the render boundary
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showError(messenger, 'Could not capture letter card.');
        return;
      }

      // 2. Convert to hi-res image (pixel ratio 3 = ~300dpi)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showError(messenger, 'Failed to encode card image.');
        return;
      }

      // 3. Create XFile directly from bytes (Supports Web, iOS, Android)
      final bytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'bonded_letter_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // 4. Share via native sheet / Web Share API
      await Share.shareXFiles(
        [xFile],
        text: 'Shared from Bonded 💌',
        subject: 'A letter for you',
      );
    } catch (e) {
      _showError(messenger, 'Something went wrong: $e');
    }
  }

  static void _showError(ScaffoldMessengerState messenger, String msg) {
    messenger.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GREETING CARD WIDGET (rendered offscreen via RepaintBoundary)
// ─────────────────────────────────────────────────────────────────────────────

class LetterGreetingCard extends StatelessWidget {
  final String date;
  final String day;
  final String tag;
  final Color accentColor;
  final String prompt;
  final String body;

  const LetterGreetingCard({
    super.key,
    required this.date,
    required this.day,
    required this.tag,
    required this.accentColor,
    required this.prompt,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F1A), // Deep midnight blue base
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2136), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF140D1E).withAlpha(150),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── SUBTLE GLOWING ORBS (Background) ──
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A2B42).withAlpha(40),
                ),
                // Using BackdropFilter is not supported well in RepaintBoundary for image capture on some platforms,
                // so we use a simple blurred box shadow to create the glow effect instead.
              ),
            ),
            Positioned(
              bottom: 100,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E284A).withAlpha(40),
                ),
              ),
            ),

            // ── MAIN CONTENT ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── DATE & METADATA ──
                  Text(
                    '$date  ·  $day'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: Color(0xFF6B728E),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // ── TITLE (Elegant Serif/Calligraphy feel) ──
                  Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFE2C9D8),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── BODY CONTENT ──
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      color: Color(0xFFA5ABC4),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── MINIMALIST DIVIDER ──
                  Container(
                    height: 1,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF6B728E).withAlpha(150),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── FOOTER BRANDING ──
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFF915C73), size: 10),
                      const SizedBox(width: 8),
                      Text(
                        'Shared from Bonded',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF915C73).withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

