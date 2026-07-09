import 'package:flutter/material.dart';

class Onboarding2Content extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding2Content({super.key, this.onNext, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16), // SafeArea top padding

                  const Spacer(flex: 2),

                  // ── Graphic: Journal Card with Clock ──
                  const Center(child: _JournalGraphic()),

                  const Spacer(flex: 1),

                  // ── Typography ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Honest check-ins,',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'not surveillance',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFCE9B4E),
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Your moods, your reflections —\nprivate as a journal, gentle as a\nnudge. We ask because we care.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Color(0xFF867279),
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Buttons ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      height: 140, // Fixed height for consistent CTA placement across screens
                      child: Column(
                        children: [
                          // Primary Button
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8E6E24), // Gold/Olive
                                foregroundColor: const Color(0xFF30240E),
                                elevation: 0,
                                minimumSize: const Size(0, 58),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFDCD2AE), size: 18),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'That resonates with me',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF30240E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JournalGraphic extends StatelessWidget {
  const _JournalGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Main Rectangle ──
          Container(
            width: 155,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF1E0E14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF331C24), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _line(52, const Color(0xFF6B4B32)),
                const SizedBox(height: 10),
                _line(78, const Color(0xFF382329)),
                const SizedBox(height: 10),
                _line(60, const Color(0xFF382329)),
                const SizedBox(height: 10),
                _line(38, const Color(0xFF382329)),
              ],
            ),
          ),

          // ── Clock Icon Overlap ──
          Positioned(
            top: 15,
            right: 8,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF41182B),
                border: Border.all(color: const Color(0xFF6B2B43), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Clock Hands Custom Drawn
                  Positioned(
                    top: 12,
                    child: Container(width: 1.5, height: 10, color: const Color(0xFFAD6074)),
                  ),
                  Positioned(
                    top: 20,
                    left: 21,
                    child: Transform.rotate(
                      angle: 2.0, // Rotate hand to roughly 4 o'clock
                      child: Container(width: 1.5, height: 8, color: const Color(0xFFAD6074)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hanging Dot ──
          Positioned(
            bottom: 15,
            child: Column(
              children: [
                // Faint dashed line down
                Container(width: 1.5, height: 3, color: const Color(0xFF402B1D)),
                const SizedBox(height: 2),
                Container(width: 1.5, height: 3, color: const Color(0xFF402B1D)),
                const SizedBox(height: 4),
                // Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF765538),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double width, Color color) {
    return Container(
      width: width,
      height: 4.5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
