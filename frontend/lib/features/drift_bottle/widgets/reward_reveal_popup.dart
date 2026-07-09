import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/drift_bottle_reward.dart';

class RewardRevealPopup extends StatelessWidget {
  final DriftBottleOpenResult rewardResult;
  final VoidCallback onCollect;

  const RewardRevealPopup({
    Key? key,
    required this.rewardResult,
    required this.onCollect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAura = rewardResult.rewardType == 'aura_fragment';
    final rewardAmountText = '+${rewardResult.rewardValue}';
    final glowColor = isAura ? Colors.purpleAccent : Colors.pinkAccent;
    final secondaryColor = isAura ? Colors.cyanAccent : Colors.orangeAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF381028).withOpacity(0.45), // Midnight pink translucent glass
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A0515).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top decorations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isAura ? Icons.diamond_outlined : Icons.favorite_border, color: glowColor, size: 24),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      children: [
                        const TextSpan(text: 'Reward ', style: TextStyle(color: Colors.white)),
                        TextSpan(
                          text: 'Unlocked', 
                          style: TextStyle(
                            color: glowColor,
                            shadows: [Shadow(color: glowColor.withOpacity(0.5), blurRadius: 10)],
                          )
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 4),
                  Icon(Icons.favorite, size: 10, color: glowColor.withOpacity(0.5)),
                  
                  const SizedBox(height: 8),
                  
                  // The Tokens "Pile"
                  SizedBox(
                    height: 110,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Soft glowing aura perfectly placed behind the pile
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 40)],
                          ),
                        ),
                        ...(() {
                          final count = (rewardResult.rewardValue ?? 1).clamp(1, 5).toInt();
                          // Precise offsets to form the overlapping pyramid stack
                          final positions = [
                            {'dx': -35.0, 'dy': -20.0, 's': 55.0}, // Back left
                            {'dx': 35.0, 'dy': -10.0, 's': 55.0},  // Back right
                            {'dx': -20.0, 'dy': 5.0, 's': 70.0},   // Mid left
                            {'dx': 25.0, 'dy': 0.0, 's': 70.0},    // Mid right
                            {'dx': 0.0, 'dy': 15.0, 's': 90.0},    // Front center
                          ];
                          
                          List<Map<String, double>> active = [];
                          if (count == 1) active = [positions[4]];
                          else if (count == 2) active = [positions[2], positions[4]];
                          else if (count == 3) active = [positions[2], positions[3], positions[4]];
                          else if (count == 4) active = [positions[0], positions[2], positions[3], positions[4]];
                          else active = positions;
                          
                          return List.generate(active.length, (index) {
                            final pos = active[index];
                            final icon = isAura ? Icons.diamond_rounded : Icons.favorite_rounded;
                            return Transform.translate(
                              offset: Offset(pos['dx']!, pos['dy']!),
                              child: (isAura
                                ? ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [glowColor, secondaryColor],
                                    ).createShader(bounds),
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: pos['s']! * 0.8,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/drift_bottle/v10_reward_love_token.png',
                                    width: pos['s']!, 
                                    height: pos['s']!,
                                  ))
                              .animate(delay: (index * 100).ms)
                              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
                              .fadeIn(duration: 300.ms),
                            );
                          });
                        })(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Inner Container for Amount
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: glowColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: glowColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              rewardAmountText,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'serif',
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: [Colors.white, glowColor.withOpacity(0.8)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(const Rect.fromLTWH(0, 0, 100, 50)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAura ? 'Aura Fragments' : 'Love Tokens',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 12),
                  
                  // Collect Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onCollect,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: glowColor.withOpacity(0.5)),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              glowColor.withOpacity(0.9),
                              glowColor.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isAura ? Icons.diamond : Icons.favorite, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Collect',
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 1500.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.pinkAccent.withOpacity(0.8), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${rewardResult.totalLoveTokens ?? 0}', 
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)
                      ),
                      const SizedBox(width: 20),
                      Container(width: 1, height: 12, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 20),
                      Icon(Icons.diamond, color: Colors.purpleAccent.withOpacity(0.8), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${rewardResult.totalAuraFragments ?? 0}', 
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ).animate()
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack)
        .fade(duration: 400.ms),
    );
  }

  Widget _buildTotalRow(String label, int amount, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 4, spreadRadius: 2)
                ]
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Total $label',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Text(
          amount.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
