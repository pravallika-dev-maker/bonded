import 'dart:ui';
import 'package:flutter/material.dart';

class DiscoveryPopup extends StatefulWidget {
  final Map<String, dynamic> objectData;
  final Function(String) onReact;

  const DiscoveryPopup({
    super.key,
    required this.objectData,
    required this.onReact,
  });

  static void show(BuildContext context, Map<String, dynamic> objectData, Function(String) onReact) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => DiscoveryPopup(objectData: objectData, onReact: onReact),
    );
  }

  @override
  State<DiscoveryPopup> createState() => _DiscoveryPopupState();
}

class _DiscoveryPopupState extends State<DiscoveryPopup> with SingleTickerProviderStateMixin {
  final List<String> _reactions = ['❤️', '🥹', '🌿', '✨', '🤍'];
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleReaction(String reaction) {
    widget.onReact(reaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasWhisper = widget.objectData['whisper'] != null && widget.objectData['whisper'].toString().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF180710).withOpacity(0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8BC2).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF911746).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Added by ${widget.objectData['placed_by_user_id'] == 1 ? 'Maya' : 'Your Partner'}', // Placeholder logic
                    style: const TextStyle(
                      color: Color(0xFFDD8F9F),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.objectData['asset_name'] ?? 'New Spark',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (hasWhisper) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1020).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.format_quote, color: const Color(0xFFFF8BC2).withOpacity(0.5), size: 24),
                        const SizedBox(height: 8),
                        Text(
                          '"${widget.objectData['whisper']}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD4B1C1),
                            fontSize: 16,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                const Text(
                  'React',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _reactions.map((r) => GestureDetector(
                    onTap: () => _handleReaction(r),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(r, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
