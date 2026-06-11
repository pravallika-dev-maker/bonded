import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum DreamHouseSheetTab {
  decor,
  note,
  customCreation,
  viewAndReact,
}

class DecorItemInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String promptIdea;
  final String microText;
  final List<String> categories;

  const DecorItemInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.promptIdea,
    required this.microText,
    required this.categories,
  });
}

class DreamHouseBottomSheet extends StatefulWidget {
  final DreamHouseSheetTab initialTab;
  final List<String> placedItemIds;
  final ValueChanged<DecorItemInfo>? onItemSelected;
  final void Function(String itemCode, String noteText)? onNoteSubmitted;
  final void Function(String customDesc, String noteText)? onCustomSubmitted;
  final ValueChanged<String>? onReactionSelected;
  
  final String? partnerName;
  final String? partnerNote;
  final String? partnerItemName;
  final String? partnerItemCode;

  const DreamHouseBottomSheet({
    super.key,
    required this.initialTab,
    required this.placedItemIds,
    this.onItemSelected,
    this.onNoteSubmitted,
    this.onCustomSubmitted,
    this.onReactionSelected,
    this.partnerName,
    this.partnerNote,
    this.partnerItemName,
    this.partnerItemCode,
  });

  @override
  State<DreamHouseBottomSheet> createState() => _DreamHouseBottomSheetState();
}

class _DreamHouseBottomSheetState extends State<DreamHouseBottomSheet> with TickerProviderStateMixin {
  late DreamHouseSheetTab _currentTab;
  DecorItemInfo? _selectedDecorItem;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  
  final TextEditingController _customDescController = TextEditingController();
  final FocusNode _customDescFocusNode = FocusNode();
  String _selectedMood = 'Warm';

  String _activeCategory = 'Warm Corners';
  
  final List<String> _categories = [
    'Warm Corners',
    'Little Comforts',
    'Quiet Memories',
    'Cozy Lights',
    'Future Dreams',
    'Tiny Joys',
    'Pieces of Us',
  ];

  final List<String> _moods = ['Warm', 'Peaceful', 'Romantic', 'Cozy', 'Playful'];

  final List<DecorItemInfo> _availableItems = const [
    DecorItemInfo(
      id: 'lamp',
      name: 'Warm Floor Lamp',
      description: 'Casts a soft golden amber light.',
      icon: Icons.lightbulb_outline,
      promptIdea: 'You\'d love this cozy light in the evenings.',
      microText: 'For soft late-night conversations.',
      categories: ['Warm Corners', 'Cozy Lights'],
    ),
    DecorItemInfo(
      id: 'monstera',
      name: 'Cozy Monstera Plant',
      description: 'Textured leaves that sway gently.',
      icon: Icons.nature_people_outlined,
      promptIdea: 'I thought about how you love green spaces.',
      microText: 'For a breath of fresh air.',
      categories: ['Little Comforts', 'Tiny Joys'],
    ),
    DecorItemInfo(
      id: 'bookshelf',
      name: 'Wooden Bookshelf',
      description: 'A Pinterest bookshelf with colorful books.',
      icon: Icons.menu_book_outlined,
      promptIdea: 'I imagined us reading here together.',
      microText: 'For stories our home will remember.',
      categories: ['Quiet Memories', 'Warm Corners'],
    ),
    DecorItemInfo(
      id: 'record_player',
      name: 'Vintage Record Player',
      description: 'A golden vinyl player spinning sweet tunes.',
      icon: Icons.album_outlined,
      promptIdea: 'This song instantly made me think of you.',
      microText: 'For sweet slow tunes.',
      categories: ['Future Dreams', 'Pieces of Us'],
    ),
    DecorItemInfo(
      id: 'fairy_lights',
      name: 'Twinkling Fairy Lights',
      description: 'Warm golden bulbs draped across.',
      icon: Icons.blur_on_outlined,
      promptIdea: 'Brings a tiny spark of starlight to our walls.',
      microText: 'For magical nights.',
      categories: ['Cozy Lights', 'Tiny Joys'],
    ),
    DecorItemInfo(
      id: 'memory_frame',
      name: 'Tiny Memory Frame',
      description: 'A small frame with a glowing heart.',
      icon: Icons.crop_portrait_outlined,
      promptIdea: 'A tiny capsule for our favorite shared moments.',
      microText: 'For our favorite shared moments.',
      categories: ['Quiet Memories', 'Pieces of Us'],
    ),
    DecorItemInfo(
      id: 'coffee',
      name: 'Cozy Coffee Stool',
      description: 'A small wooden stool with a warm cup.',
      icon: Icons.coffee_outlined,
      promptIdea: 'I imagined us sharing a quiet morning coffee.',
      microText: 'For quiet mornings together.',
      categories: ['Warm Corners', 'Little Comforts'],
    ),
    DecorItemInfo(
      id: 'window_rain',
      name: 'Rainy Window View',
      description: 'Soft raindrops sliding down the glass.',
      icon: Icons.umbrella_outlined,
      promptIdea: 'The perfect sound for a quiet day apart.',
      microText: 'For rainy day comforts.',
      categories: ['Future Dreams', 'Little Comforts'],
    ),
  ];

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    _customDescController.dispose();
    _customDescFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategoryItems = _availableItems.where((item) => item.categories.contains(_activeCategory)).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F050A).withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    border: Border.all(
                      color: const Color(0xFFFFE4C4).withOpacity(0.1),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF911746).withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: -10,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF381928),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                          ),
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: _buildCurrentTabContent(currentCategoryItems),
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
      ),
    );
  }

  Widget _buildCurrentTabContent(List<DecorItemInfo> currentCategoryItems) {
    if (_currentTab == DreamHouseSheetTab.decor) {
      return _buildDecorMoodboard(currentCategoryItems);
    } else if (_currentTab == DreamHouseSheetTab.note) {
      return _buildCalligraphyNotePad();
    } else if (_currentTab == DreamHouseSheetTab.customCreation) {
      return _buildCustomCreationView();
    } else if (_currentTab == DreamHouseSheetTab.viewAndReact) {
      return _buildViewAndReactSheet();
    }
    return const SizedBox();
  }

  // ── 1. DECOR MOODBOARD TRAY ──
  
  Widget _buildDecorMoodboard(List<DecorItemInfo> currentCategoryItems) {
    return Column(
      key: const ValueKey('decor_moodboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Shape your future home",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color(0xFFFFE4C4),
            shadows: [
              Shadow(
                color: Color(0xFF911746),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Leave something meaningful for your person.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9E7E5A),
          ),
        ),
        const SizedBox(height: 24),

        // Emotional Categories Row
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = cat == _activeCategory;
              return GestureDetector(
                onTap: () {
                  setState(() => _activeCategory = cat);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3F192C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? const Color(0xFFFFB359).withOpacity(0.5) : const Color(0xFF381928),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      color: isActive ? const Color(0xFFFFE4C4) : const Color(0xFF866571),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 32),

        // Moodboard Items (Horizontal Scroll)
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: currentCategoryItems.length,
            itemBuilder: (context, index) {
              final item = currentCategoryItems[index];
              final isPlaced = widget.placedItemIds.contains(item.id);
              return _DreamyItemCard(
                item: item,
                isPlaced: isPlaced,
                onTap: isPlaced ? null : () {
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!(item);
                  }
                  setState(() {
                    _selectedDecorItem = item;
                    _currentTab = DreamHouseSheetTab.note;
                  });
                },
              );
            },
          ),
        ),

        const SizedBox(height: 40),

        // Create Something Personal Button
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentTab = DreamHouseSheetTab.customCreation;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3F192C).withOpacity(0.8),
                    const Color(0xFF1F0A13).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFFFE4C4).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB359).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create Something Personal ✨",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFFE4C4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── 2. CALLIGRAPHY NOTE PAD ──
  
  Widget _buildCalligraphyNotePad() {
    if (_selectedDecorItem == null) return const SizedBox();

    return Column(
      key: const ValueKey('note_pad'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _currentTab = DreamHouseSheetTab.decor);
          },
          child: const Row(
            children: [
              Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF9E7E5A)),
              SizedBox(width: 4),
              Text(
                "Back to Tray",
                style: TextStyle(color: Color(0xFF9E7E5A), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Leave a heart message",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color(0xFFFFE4C4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "For the ${_selectedDecorItem!.name.toLowerCase()}",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9E7E5A),
          ),
        ),
        const SizedBox(height: 24),

        // Calligraphy Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBE1), // Warm parchment
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE4C4).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_selectedDecorItem!.icon, color: const Color(0xFF5A3C47), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDecorItem!.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5A3C47),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                focusNode: _noteFocusNode,
                maxLines: 4,
                maxLength: 120,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF381928),
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'A quiet line or two...',
                  hintStyle: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF8A6E7B),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Prompt
        GestureDetector(
          onTap: () {
            setState(() {
              _noteController.text = _selectedDecorItem!.promptIdea;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F0A13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF381928)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFFB359)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '"${_selectedDecorItem!.promptIdea}"',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFDD8F9F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_noteController.text.trim().isNotEmpty && widget.onNoteSubmitted != null) {
                widget.onNoteSubmitted!(_selectedDecorItem!.id, _noteController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2E55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text(
              "Place in Dream House ✨",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. CUSTOM CREATION VIEW ──
  
  Widget _buildCustomCreationView() {
    return Column(
      key: const ValueKey('custom_creation'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _currentTab = DreamHouseSheetTab.decor);
          },
          child: const Row(
            children: [
              Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF9E7E5A)),
              SizedBox(width: 4),
              Text(
                "Back to Tray",
                style: TextStyle(color: Color(0xFF9E7E5A), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "What would you like to leave?",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Color(0xFFFFE4C4),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Describe any object or feeling.",
          style: TextStyle(fontSize: 14, color: Color(0xFF9E7E5A)),
        ),
        const SizedBox(height: 24),

        // Description Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F0A13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3F192C)),
          ),
          child: TextField(
            controller: _customDescController,
            focusNode: _customDescFocusNode,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. A tiny balcony with yellow fairy lights...',
              hintStyle: TextStyle(color: Color(0xFF5A3C47), fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Mood Selection
        const Text(
          "Vibe & Atmosphere",
          style: TextStyle(fontSize: 14, color: Color(0xFF9E7E5A), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3F192C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFFFFB359) : const Color(0xFF381928)),
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFE4C4) : const Color(0xFF866571),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Note for custom item
        const Text(
          "Add a heart message",
          style: TextStyle(fontSize: 14, color: Color(0xFF9E7E5A), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF140A0E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF26101B)),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontStyle: FontStyle.italic),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'I imagined us sitting here...',
              hintStyle: TextStyle(color: Color(0xFF5A3C47), fontStyle: FontStyle.italic),
            ),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_customDescController.text.trim().isNotEmpty && widget.onCustomSubmitted != null) {
                widget.onCustomSubmitted!(
                  _customDescController.text.trim() + " (Mood: $_selectedMood)", 
                  _noteController.text.trim()
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2E55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              "Materialize ✨",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. VIEW AND REACT SHEET ──
  
  Widget _buildViewAndReactSheet() {
    return Column(
      key: const ValueKey('view_react'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "THEY PLACED A TOUCH",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFFFFCC66),
              ),
            ),
            const Spacer(),
            const Icon(Icons.auto_awesome, color: Color(0xFFFFCC66), size: 14),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${widget.partnerName} shared their dream",
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),

        // Note Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1F0F16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF381928),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFDD8F9F), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.partnerItemName ?? "Cozy Addition",
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDD8F9F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"${widget.partnerNote}"',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "— Love, ${widget.partnerName}",
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9E7E5A),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Reactions list
        const Text(
          "SEND A QUIET RESPONSE",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF5A3C47),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildReactionButton("❤️", "Glowing Heart"),
            _buildReactionButton("✨", "Warm Spark"),
            _buildReactionButton("🫂", "Gentle Hug"),
            _buildReactionButton("☕", "Warm Mug"),
          ],
        ),
      ],
    );
  }

  Widget _buildReactionButton(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        if (widget.onReactionSelected != null) {
          widget.onReactionSelected!(emoji);
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF140A0E),
              border: Border.all(
                color: const Color(0xFF381928),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF911746).withOpacity(0.04),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF866571),
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamyItemCard extends StatefulWidget {
  final DecorItemInfo item;
  final bool isPlaced;
  final VoidCallback? onTap;

  const _DreamyItemCard({
    required this.item,
    required this.isPlaced,
    this.onTap,
  });

  @override
  State<_DreamyItemCard> createState() => _DreamyItemCardState();
}

class _DreamyItemCardState extends State<_DreamyItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _breatheController,
        builder: (context, child) {
          final glowOpacity = widget.isPlaced ? 0.0 : 0.1 + (_breatheController.value * 0.15);
          
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isPlaced ? const Color(0xFF140A0E) : const Color(0xFF1F0A13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isPlaced ? const Color(0xFF26101B) : const Color(0xFF381928),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB359).withOpacity(glowOpacity),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F192C).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: widget.isPlaced ? const Color(0xFF5A3C47) : const Color(0xFFFFE4C4),
                        size: 20,
                      ),
                    ),
                    if (widget.isPlaced)
                      const Icon(Icons.check_circle, color: Color(0xFF4C8C5E), size: 16)
                    else
                      const Icon(Icons.auto_awesome, color: Color(0xFFDD8F9F), size: 14),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.item.name,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: widget.isPlaced ? const Color(0xFF5A3C47) : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isPlaced ? "Placed inside" : widget.item.microText,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isPlaced ? const Color(0xFF381928) : const Color(0xFF9E7E5A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
