import 'package:flutter/material.dart';
import '../../services/sky_haven_service.dart';

class ItemDetailCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function() onReactionAdded;

  const ItemDetailCard({
    Key? key,
    required this.item,
    required this.onReactionAdded,
  }) : super(key: key);

  @override
  State<ItemDetailCard> createState() => _ItemDetailCardState();
}

class _ItemDetailCardState extends State<ItemDetailCard> {
  bool isReacting = false;
  String? errorMessage;

  Future<void> _addReaction(String emoji) async {
    setState(() {
      isReacting = true;
      errorMessage = null;
    });
    try {
      await SkyHavenService.reactToObject(widget.item['id'], emoji);
      widget.onReactionAdded();
      if (mounted) {
        Navigator.pop(context); // Close the card on success
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isReacting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String whisper = widget.item['whisper'] ?? "";
    final List reactions = widget.item['reactions'] ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.9), // Frosted glass look
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon / Asset representation
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.purpleAccent,
                size: 50,
              ),
            ),
            const SizedBox(height: 15),

            // Whisper Text
            if (whisper.isNotEmpty) ...[
              const Text(
                "A Whisper for you...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                ),
                child: Text(
                  whisper,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Show existing reactions
            if (reactions.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                children: reactions.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r['reaction'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),

            // Reaction Buttons
            const Text(
              "How does this make you feel?",
              style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 10),
            isReacting
                ? const CircularProgressIndicator(color: Colors.purpleAccent)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ReactionButton(emoji: "🥺", onTap: () => _addReaction("🥺")),
                      _ReactionButton(emoji: "✨", onTap: () => _addReaction("✨")),
                      _ReactionButton(emoji: "💖", onTap: () => _addReaction("💖")),
                    ],
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
