import 'package:flutter/material.dart';
import 'dart:ui';
import '../../providers/dream_house_providers.dart';

class DreamHouseBottomSheet extends StatefulWidget {
  const DreamHouseBottomSheet({super.key});

  @override
  State<DreamHouseBottomSheet> createState() => _DreamHouseBottomSheetState();
}

class _DreamHouseBottomSheetState extends State<DreamHouseBottomSheet>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  int _selectedTab = 0; // 0: Warm Corners, 1: Little Comforts, 2: Pieces of Us
  int _selectedQuickItem = -1;
  
  // Note composer step state
  bool _isWritingNote = false;
  String _chosenName = '';
  IconData _chosenIcon = Icons.favorite_border;

  final _noteTextController = TextEditingController();

  // 1. Warm Corners (Day 2 fireplace theme)
  final List<Map<String, dynamic>> _warmCorners = [
    {'name': 'Fireplace Logs', 'icon': Icons.local_fire_department, 'desc': 'Flickering warm logs'},
    {'name': 'Bookshelf', 'icon': Icons.menu_book, 'desc': 'Quiet stories for late nights'},
    {'name': 'Vinyl Player', 'icon': Icons.album_outlined, 'desc': 'Spinning our classic playlist'},
    {'name': 'Cozy Armchair', 'icon': Icons.weekend, 'desc': 'A soft spot built for two'},
  ];

  // 2. Little Comforts (Day 3 coffee theme)
  final List<Map<String, dynamic>> _littleComforts = [
    {'name': 'Coffee Table', 'icon': Icons.local_cafe, 'desc': 'Fresh morning mugs & aroma'},
    {'name': 'Monsteras', 'icon': Icons.local_florist, 'desc': 'Lush greenery sway corner'},
    {'name': 'Fairy Lights', 'icon': Icons.lightbulb_outline, 'desc': 'Soft swooping lights overhead'},
    {'name': 'Polaroid Wall', 'icon': Icons.photo_camera_back, 'desc': 'Hanging snaps of our travels'},
  ];

  // 3. Pieces of Us (Day 4/5 intimacy theme)
  final List<Map<String, dynamic>> _piecesOfUs = [
    {'name': 'Hidden Promise', 'icon': Icons.star_border, 'desc': 'A gentle hope for future days'},
    {'name': 'Shared Memory', 'icon': Icons.favorite_border, 'desc': 'A reminder of our sweetest day'},
    {'name': 'Dream Map', 'icon': Icons.map_outlined, 'desc': 'Pins on places we will go'},
    {'name': 'Cozy Rug', 'icon': Icons.grid_on_outlined, 'desc': 'A thick woven circular rug'},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideController.forward();

    _noteTextController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _noteTextController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getActiveList() {
    if (_selectedTab == 0) return _warmCorners;
    if (_selectedTab == 1) return _littleComforts;
    return _piecesOfUs;
  }

  void _proceedToComposer() {
    final list = _getActiveList();
    if (_selectedQuickItem == -1) {
      _showWarning('Please select a piece for your home first.');
      return;
    }

    setState(() {
      _chosenName = list[_selectedQuickItem]['name'];
      _chosenIcon = list[_selectedQuickItem]['icon'];
      _isWritingNote = true;
    });
  }

  void _finishSelection() {
    final note = _noteTextController.text.trim();
    if (note.isEmpty) {
      _showWarning('Please write down what this piece means to you.');
      return;
    }
    if (note.length > 100) {
      _showWarning('Please keep your message within 100 characters.');
      return;
    }

    Navigator.pop(context, {
      'name': _chosenName,
      'icon': _chosenIcon,
      'meaning': note,
    });
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Georgia', fontStyle: FontStyle.italic, color: Color(0xFFE8C5A0))),
        backgroundColor: const Color(0xFF1A0A10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0810).withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 35, offset: const Offset(0, 12)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20, right: 20, top: 18,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 18),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isWritingNote ? _buildComposerStep() : _buildSelectionStep(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionStep() {
    final activeList = _getActiveList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Decor Tray moodboard ✨',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 19,
              fontStyle: FontStyle.italic,
              color: Color(0xFFE8C5A0),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tabs
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF160810),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildTabSelector(0, 'Warm Corners'),
              _buildTabSelector(1, 'Comforts'),
              _buildTabSelector(2, 'Pieces of Us'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Grid items (Pinterest feel)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, i) {
            final item = activeList[i];
            final isSel = _selectedQuickItem == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedQuickItem = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFFFB366).withOpacity(0.08) : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? const Color(0xFFFFB366).withOpacity(0.4) : Colors.white.withOpacity(0.06),
                    width: isSel ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel ? const Color(0xFFFFB366).withOpacity(0.12) : Colors.white.withOpacity(0.03),
                      ),
                      child: Icon(item['icon'], size: 16, color: isSel ? const Color(0xFFFFB366) : const Color(0xFFE8C5A0)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSel ? const Color(0xFFFFE3C2) : const Color(0xFFE8C5A0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc'],
                            style: const TextStyle(fontSize: 8, color: Color(0xFF9E7E5A)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
        const SizedBox(height: 20),

        // Moonlight glass CTA to compose
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _proceedToComposer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: Colors.white12, width: 1.2),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Tap to Write Memory ✉️',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFFFFE3C2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(int index, String title) {
    final isSel = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _selectedQuickItem = -1;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFFFB366).withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? const Color(0xFFFFB366) : const Color(0xFF6E4555),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposerStep() {
    int length = _noteTextController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isWritingNote = false),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFFE8C5A0)),
            ),
            const Spacer(),
            const Text(
              'Write Down Your Quiet Touch',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color(0xFFFFE3C2),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 14),
          ],
        ),
        const SizedBox(height: 18),

        // Beautiful beige paper container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_chosenIcon, size: 18, color: const Color(0xFF6E4555)),
                  const SizedBox(width: 8),
                  Text(
                    _chosenName,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3C232B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Handwriting text field
              TextField(
                controller: _noteTextController,
                maxLength: 100,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14.5,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF6E4555),
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '“I imagined rainy evenings with you here...”',
                  hintStyle: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6E4555).withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 10),

              // Enforced 100 character counter limit
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$length / 100',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: length > 100 ? Colors.red : const Color(0xFF9E7E5A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Moonlight CTA to save note
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _finishSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: Colors.white12, width: 1.2),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Leave this quiet trace in our home',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFFFFE3C2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
