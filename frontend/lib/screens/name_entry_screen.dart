import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bond_selection_screen.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
    // Request focus after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim().isEmpty ? '...' : _nameController.text.trim();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0408),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 0.95,
              colors: [Color(0xFF2A0614), Color(0xFF0A0408)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Faint Background Heart
                Positioned(
                  top: 60,
                  right: -40,
                  child: Icon(
                    Icons.favorite,
                    size: 280,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
                
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            
                            // ── Top Label ──
                            Text(
                              'A GENTLE QUESTION — STEP 1 OF 4',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFFAC7827).withOpacity(0.9),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // ── Title ──
                            const Text(
                              'What name\nfeels\n',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: const Text(
                                'most like you?',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFD94480),
                                  height: 1.0,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ── Subtitle ──
                            const Text(
                              'Not your official name — the one\npeople who love you use',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E7A85),
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // ── Input Field ──
                            IntrinsicWidth(
                              child: TextField(
                                controller: _nameController,
                                focusNode: _focusNode,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                                cursorColor: const Color(0xFFD94480),
                                decoration: const InputDecoration(
                                  hintText: 'Sofia',
                                  hintStyle: TextStyle(
                                    color: Colors.white24,
                                    fontFamily: 'Georgia',
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF5A1530),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF3D1A25),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF5A1530),
                                      width: 2,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(bottom: 8),
                                ),
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            
                            const SizedBox(height: 60),
                            
                            // ── Preview Card ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F0712),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF3D1A25).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A LITTLE PREVIEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: const Color(0xFFAC7827).withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '"Welcome back, $name. Your bond continues here."',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40), // Spacing for scroll if keyboard open
                          ],
                        ),
                      ),
                    ),
                    
                    // ── Bottom Button ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _nameController.text.trim().isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const BondSelectionScreen()),
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.favorite_outline,
                            size: 18,
                            color: _nameController.text.trim().isNotEmpty
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white24,
                          ),
                          label: Text(
                            "Yes, that's me",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: _nameController.text.trim().isNotEmpty
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white24,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1A3C),
                            disabledBackgroundColor: const Color(0xFF3D1A25),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // ── Back Button ──
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                    splashRadius: 24,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
