import 'dart:ui';
import 'package:flutter/material.dart';

class SparkSelectionSheet extends StatefulWidget {
  final List<dynamic> options;
  final Function(dynamic) onSelected;

  const SparkSelectionSheet({
    super.key,
    required this.options,
    required this.onSelected,
  });

  static void show(BuildContext context, List<dynamic> options, Function(dynamic) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SparkSelectionSheet(
        options: options,
        onSelected: (asset) {
          Navigator.pop(context);
          onSelected(asset);
        },
      ),
    );
  }

  @override
  State<SparkSelectionSheet> createState() => _SparkSelectionSheetState();
}

class _SparkSelectionSheetState extends State<SparkSelectionSheet> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Nature',
    'Cozy',
    'Lights',
    'Water',
    'Living',
    'Wonder'
  ];

  Color _getRarityColor(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'legendary': return const Color(0xFFFFD700);
      case 'epic': return const Color(0xFFD500F9);
      case 'rare': return const Color(0xFF00E5FF);
      case 'uncommon': return const Color(0xFF00E676);
      default: return Colors.white60;
    }
  }

  String _getEmojiForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'nature': return '🌸';
      case 'water': return '💧';
      case 'cozy': return '🏡';
      case 'lights': return '🏮';
      case 'living': return '🦋';
      case 'wonder': return '✨';
      default: return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = _selectedCategory == 'All'
        ? widget.options
        : widget.options.where((asset) {
            final cat = asset['category']?.toString().toLowerCase();
            return cat == _selectedCategory.toLowerCase();
          }).toList();

    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 0.72;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        height: sheetHeight,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF14050D).withOpacity(0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          border: Border.all(color: const Color(0xFFFF8BC2).withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '✨ Choose Your Spark',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontFamily: 'Georgia',
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF8BC2).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Add something beautiful to your floating sanctuary.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category.toLowerCase() == _selectedCategory.toLowerCase();
                    final emoji = _getEmojiForCategory(category);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8BC2).withOpacity(0.2)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8BC2)
                                : Colors.white12,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFF8BC2).withOpacity(0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (category != 'All') ...[
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: filteredOptions.isEmpty
                    ? Center(
                        child: Text(
                          'No items in this category yet.',
                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: filteredOptions.length,
                        itemBuilder: (context, index) {
                          final asset = filteredOptions[index];
                          final rarity = asset['rarity']?.toString() ?? 'Common';
                          final rarityColor = _getRarityColor(rarity);
                          final displayName = asset['display_name'] ?? asset['name'] ?? 'Unknown Item';
                          final category = asset['category']?.toString() ?? 'Nature';

                          return GestureDetector(
                            onTap: () => widget.onSelected(asset),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E1020).withOpacity(0.35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: rarityColor.withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -20,
                                    right: -20,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            rarityColor.withOpacity(0.15),
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF160A0E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: rarityColor.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: rarityColor.withOpacity(0.2),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getEmojiForCategory(category),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: rarityColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: rarityColor.withOpacity(0.3),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                rarity.toUpperCase(),
                                                style: TextStyle(
                                                  color: rarityColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.6,
                                                ),
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
