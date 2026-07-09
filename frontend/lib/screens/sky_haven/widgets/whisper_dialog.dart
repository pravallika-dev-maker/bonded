import 'dart:ui';
import 'package:flutter/material.dart';

class WhisperDialog extends StatefulWidget {
  final Function(String?) onSubmit;

  const WhisperDialog({super.key, required this.onSubmit});

  static void show(BuildContext context, Function(String?) onSubmit) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => WhisperDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<WhisperDialog> createState() => _WhisperDialogState();
}

class _WhisperDialogState extends State<WhisperDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF180710).withOpacity(0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8BC2).withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add a Whisper?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Leave a small thought for them to discover. (Optional)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontStyle: FontStyle.italic),
                maxLines: 3,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'e.g., "This reminded me of our evening walks..."',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF2E1020).withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFFF8BC2).withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFFF8BC2).withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFFF8BC2).withOpacity(0.6)),
                  ),
                  counterStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onSubmit(null);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onSubmit(_controller.text.trim().isEmpty ? null : _controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF911746).withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Share Spark', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
