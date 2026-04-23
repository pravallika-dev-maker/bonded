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
    final name = _nameController.text.trim().isEmpty ? 'Sofia' : _nameController.text.trim();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090204),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090204),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.0,
              colors: [Color(0xFF260814), Color(0xFF090204)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Huge Background Heart Watermark
                Positioned(
                  top: 30,
                  right: -60,
                  child: Icon(
                    Icons.favorite,
                    size: 320,
                    color: const Color(0xFF3B1525).withOpacity(0.4),
                  ),
                ),
                
                Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 2),
                            
                            // ── Top Label ──
                            const Text(
                              'A GENTLE QUESTION — STEP 1 OF 5',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Color(0xFF8A6530),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // ── Title ──
                            const Text(
                              'What name\nfeels',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'most like you?',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFFE89FB8),
                                height: 1.1,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ── Subtitle ──
                            const Text(
                              'Not your official name — the one\npeople who love you use',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5E3A4B),
                                height: 1.5,
                              ),
                            ),
                            
                            const Spacer(flex: 2),
                            
                            // ── Input Field ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: _focusNode,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 44,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                    cursorColor: const Color(0xFF911746),
                                    decoration: const InputDecoration(
                                      hintText: 'Sofia',
                                      hintStyle: TextStyle(
                                        color: Colors.white24,
                                        fontFamily: 'Georgia',
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF911746), width: 2),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF911746), width: 2),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF911746), width: 2),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(bottom: 8),
                                    ),
                                    keyboardType: TextInputType.name,
                                    textCapitalization: TextCapitalization.words,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: const EdgeInsets.only(bottom: 0),
                                    color: const Color(0xFF3D1627),
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(flex: 2),
                            
                            // ── Preview Card ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B0711),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF3D1627),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'A LITTLE PREVIEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      color: Color(0xFF8A6530),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '"Welcome back, $name. Your bond\ncontinues here."',
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFFE6D0D8),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                    
                    // ── Bottom Button ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _nameController.text.trim().isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BondSelectionScreen(
                                      userName: _nameController.text.trim(),
                                    )),
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.favorite,
                            size: 18,
                            color: _nameController.text.trim().isNotEmpty
                                ? Colors.white
                                : const Color(0xFF3D1B28),
                          ),
                          label: Text(
                            "Yes, that's me",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: _nameController.text.trim().isNotEmpty
                                  ? Colors.white
                                  : const Color(0xFF3D1B28),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF911746),
                            disabledBackgroundColor: const Color(0xFF1B0711),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
