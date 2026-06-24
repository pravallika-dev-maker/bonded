import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/drift_bottle_reward.dart';
import 'reward_reveal_popup.dart';

class DriftBottleOpeningOverlay extends StatefulWidget {
  final DriftBottleOpenResult rewardResult;

  const DriftBottleOpeningOverlay({Key? key, required this.rewardResult})
      : super(key: key);

  static Future<void> show(BuildContext context, DriftBottleOpenResult rewardResult) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DriftBottleOpeningOverlay(rewardResult: rewardResult);
      },
    );
  }

  @override
  State<DriftBottleOpeningOverlay> createState() =>
      _DriftBottleOpeningOverlayState();
}

class _DriftBottleOpeningOverlayState extends State<DriftBottleOpeningOverlay> {
  int _currentStep = 0; 
  /* 
   Steps:
   0: Initial State
   1: Scale Bottle (0.95 -> 1.05)
   2: Fly to Center
   3: Dim & Blur Background
   4: Scale up (1.0 -> 1.15)
   5: Shake
   6: Opening animation (swap image)
   7: Cork pops out
   8: Magical burst
   9: Reward emerges
   10: Reward hover
   11: Show reward card
  */

  @override
  void initState() {
    super.initState();
    _startPremiumSequence();
  }

  void _startPremiumSequence() async {
    // Step 1: Tap scale
    setState(() => _currentStep = 1);
    await Future.delayed(const Duration(milliseconds: 200 + 200));
    if (!mounted) return;

    // Step 2: Fly to center
    setState(() => _currentStep = 2);
    await Future.delayed(const Duration(milliseconds: 700 + 300));
    if (!mounted) return;

    // Step 3: Dim & Blur
    setState(() => _currentStep = 3);
    await Future.delayed(const Duration(milliseconds: 400 + 300));
    if (!mounted) return;

    // Step 4: Scale up
    setState(() => _currentStep = 4);
    await Future.delayed(const Duration(milliseconds: 400 + 300));
    if (!mounted) return;

    // Step 5: Shake
    setState(() => _currentStep = 5);
    await Future.delayed(const Duration(milliseconds: 300 + 200));
    if (!mounted) return;

    // Step 6: Opening animation
    setState(() => _currentStep = 6);
    await Future.delayed(const Duration(milliseconds: 800 + 300));
    if (!mounted) return;

    // Step 7: Cork pops
    setState(() => _currentStep = 7);
    await Future.delayed(const Duration(milliseconds: 400 + 300));
    if (!mounted) return;

    // Step 8: Magical burst
    setState(() => _currentStep = 8);
    await Future.delayed(const Duration(milliseconds: 700 + 300));
    if (!mounted) return;

    // Step 9: Reward emerges
    setState(() => _currentStep = 9);
    await Future.delayed(const Duration(milliseconds: 800 + 1000));
    if (!mounted) return;

    // Step 10: Hover
    setState(() => _currentStep = 10);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 11: Show card
    setState(() => _currentStep = 11);
    _showRewardPopup();
  }

  void _showRewardPopup() {
    final overlayContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Keep our own background blur
      builder: (dialogContext) => RewardRevealPopup(
        rewardResult: widget.rewardResult,
        onCollect: () {
          Navigator.of(dialogContext).pop(); 
          Navigator.of(overlayContext).pop(); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final startOffset = Offset(size.width / 2 - 40, size.height / 2 - 150);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Step 3: Dimmed Background
          if (_currentStep >= 3)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: 400.ms,
                builder: (context, value, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0 * value, sigmaY: 8.0 * value),
                    child: Container(
                      color: Colors.black.withOpacity(0.7 * value),
                    ),
                  );
                },
              ),
            ),
          
          // Step 8: Particles Burst
          if (_currentStep >= 8)
             _buildParticles(),

          // The Tokens Bursting Out (Exact count, only once!)
          if (_currentStep >= 6)
             _buildBurstingTokens(),

          // The Bottle (Visible until end of sequence or depending on design)
          if (_currentStep < 11)
            Center(
              child: _buildBottle(startOffset)
            ),

          // Step 9 & 10: Reward Emerges and Hovers
          if (_currentStep >= 9)
            Center(
              child: _buildRewardToken(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottle(Offset startOffset) {
    Widget bottleImg = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _currentStep >= 6
            ? Container(
                width: 150,
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(35), // Shrink to match the idle bottle's visual size
                child: Image.asset(
                  'assets/drift_bottle/v9_drift_bottle_empty.png',
                  fit: BoxFit.contain,
                ),
              )
            : Image.asset(
                'assets/drift_bottle/v5_drift_bottle_idle.png',
                width: 150,
                height: 200,
                fit: BoxFit.contain,
              ),
      ],
    );

    // Apply specific effect animations based on the current step
    if (_currentStep == 5) {
      bottleImg = bottleImg.animate().shake(hz: 8, curve: Curves.easeInOutCubic, duration: 300.ms);
    } else if (_currentStep == 7) {
      bottleImg = bottleImg.animate().moveY(begin: 0, end: 10, duration: 100.ms).then().moveY(begin: 10, end: 0, duration: 300.ms, curve: Curves.bounceOut);
    }

    double targetScale = 1.0;
    if (_currentStep == 1) targetScale = 1.05;
    if (_currentStep >= 4) targetScale = 1.15;
    
    Offset targetOffset = startOffset;
    if (_currentStep >= 2) targetOffset = Offset.zero;

    return AnimatedContainer(
      duration: _currentStep == 1 ? 200.ms : (_currentStep == 2 ? 700.ms : 400.ms),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(targetOffset.dx, targetOffset.dy)
        ..scale(targetScale, targetScale),
      transformAlignment: Alignment.center,
      child: bottleImg,
    );
  }

  Widget _buildBurstingTokens() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: List.generate((widget.rewardResult.rewardValue ?? 1).toInt(), (index) {
          final isAura = widget.rewardResult.rewardType == 'aura_fragment';
          final icon = isAura ? Icons.diamond_rounded : Icons.favorite_rounded;
          final color1 = isAura ? Colors.purpleAccent : Colors.pinkAccent;
          final color2 = isAura ? Colors.cyanAccent : Colors.orangeAccent;
          
          return Positioned(
            key: ValueKey('burst_token_$index'),
            child: (isAura
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color1, color2],
                  ).createShader(bounds),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 30 + (index % 3) * 5.0,
                  ),
                )
              : Image.asset(
                  'assets/drift_bottle/v10_reward_love_token.png',
                  width: 35 + (index % 3) * 5.0,
                  height: 35 + (index % 3) * 5.0,
                  cacheWidth: 150,
                ))
            .animate(target: _currentStep >= 6 ? 1 : 0) // Explicit target ensures it runs only ONCE
            .then(delay: (index * 150).ms)
            .moveY(
              begin: 0, 
              end: -150 - (index * 15.0), 
              duration: 1800.ms, 
              curve: Curves.easeOutCirc
            )
            .moveX(
              begin: 0, 
              end: (index % 2 == 0 ? 1 : -1) * (30.0 + index * 8.0), 
              duration: 1800.ms, 
              curve: Curves.easeInOutSine
            )
            .fadeOut(delay: 1400.ms, duration: 400.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5), duration: 1800.ms),
          );
        }),
      ),
    );
  }

  Widget _buildRewardToken() {
    final rewardValue = widget.rewardResult.rewardValue;
    final isAura = widget.rewardResult.rewardType == 'aura_fragment';
    final glowColor = isAura ? Colors.purpleAccent : Colors.pinkAccent;

    // Emerge animation (Step 9) and Hover (Step 10)
    return Transform.translate(
      offset: const Offset(0, -150), // Position exactly where tokens gather
      child: Container(
        width: 140,
        height: 140,
        alignment: Alignment.center,
        child: Text(
          '+$rewardValue',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(color: glowColor, blurRadius: 20),
              Shadow(color: glowColor, blurRadius: 10),
            ],
          ),
        ),
      )
      .animate(target: _currentStep >= 9 ? 1 : 0)
      .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.elasticOut)
      .fade(begin: 0, end: 1, duration: 500.ms)
      // Step 10: Hover
      .then(delay: 200.ms)
      .moveY(begin: 0, end: -15, duration: 1000.ms, curve: Curves.easeInOutSine)
      .then()
      .moveY(begin: -15, end: 0, duration: 1000.ms, curve: Curves.easeInOutSine),
    );
  }

  Widget _buildParticles() {
    return Stack(
      children: List.generate(20, (index) {
        final angle = (index * 18) * 3.14159 / 180;
        final dx = 200 * math.cos(angle);
        final dy = 200 * math.sin(angle);
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 - 5,
          top: MediaQuery.of(context).size.height / 2 - 5,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.pinkAccent, blurRadius: 15, spreadRadius: 5)],
            ),
          ).animate()
            .move(begin: Offset.zero, end: Offset(dx, dy), duration: 700.ms, curve: Curves.easeOutExpo)
            .scale(begin: const Offset(1, 1), end: Offset.zero, duration: 700.ms)
            .fade(end: 0, duration: 700.ms),
        );
      }),
    );
  }
}
