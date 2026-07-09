import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/sky_haven_models.dart';

class SkyHavenIslandSelector extends StatelessWidget {
  final Function(SkyItem item) onSelected;

  const SkyHavenIslandSelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Get all island bases from catalog
    final bases = SkyHavenCatalog.all.where((i) => i.category == SkyItemCategory.islandBase).toList();

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blur background slightly to make cards pop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ).animate().fadeIn(duration: 400.ms),

          Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Choose your Haven',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 12),
              const Text(
                'Select a floating island to begin.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.2),
              const SizedBox(height: 40),

              // Carousel
              Expanded(
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.75),
                  physics: const BouncingScrollPhysics(),
                  itemCount: bases.length,
                  itemBuilder: (context, index) {
                    final item = bases[index];
                    return AnimatedBuilder(
                      animation: PageController(viewportFraction: 0.75),
                      builder: (context, child) {
                        return Center(
                          child: _IslandCard(
                            item: item,
                            onTap: () => onSelected(item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class _IslandCard extends StatefulWidget {
  final SkyItem item;
  final VoidCallback onTap;

  const _IslandCard({required this.item, required this.onTap});

  @override
  State<_IslandCard> createState() => _IslandCardState();
}

class _IslandCardState extends State<_IslandCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.95 : 1.0,
        duration: 200.ms,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Soft shadow behind the island image (simulated with a blurred black copy)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Image.asset(
                    widget.item.assetPath,
                    fit: BoxFit.contain,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1500.ms),
              ),

              // Island Image Floating
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset(
                  widget.item.assetPath,
                  fit: BoxFit.contain,
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1500.ms),
              ),

              // Title at bottom (floating text without a hard box)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.name.contains('Large') ? '✨ Premium Base' : '🌿 Starting Base',
                      style: TextStyle(
                        color: widget.item.name.contains('Large') ? Colors.amber[300] : Colors.white70,
                        fontSize: 16,
                        shadows: const [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
