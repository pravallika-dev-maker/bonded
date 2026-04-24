import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gender_selection_screen.dart';
import 'partner_invite_screen.dart';
import 'beginning_date_screen.dart';

class PartnerNameEntryScreen extends StatefulWidget {
  final String userName;
  const PartnerNameEntryScreen({super.key, required this.userName});

  @override
  State<PartnerNameEntryScreen> createState() => _PartnerNameEntryScreenState();
}

class _PartnerNameEntryScreenState extends State<PartnerNameEntryScreen> {
  final TextEditingController _partnerNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _partnerNameController.addListener(() {
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
    _partnerNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partnerName = _partnerNameController.text.trim().isEmpty 
        ? '...' 
        : _partnerNameController.text.trim();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0408),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0408),
        resizeToAvoidBottomInset: false,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 2),
                            
                            // ── Top Label ──
                            Text(
                              'STEP 4 OF 7 — THEIR NAME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFFAC7827).withOpacity(0.9),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // ── Title ──
                            const Text(
                              'And what do you\n',
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
                                'call them?',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFDD8F9F),
                                  height: 1.0,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ── Subtitle ──
                            const Text(
                              'Their real name, a nickname, or whatever feels most natural to you.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E7A85),
                                height: 1.5,
                              ),
                            ),
                            
                            const Spacer(flex: 2),
                            
                            // ── Input Field ──
                            IntrinsicWidth(
                              child: TextField(
                                controller: _partnerNameController,
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
                                  hintText: 'e.g., Alex',
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
                            
                            const Spacer(flex: 3),
                            
                            // ── Quotes & Data Preview Card ──
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.format_quote_rounded,
                                        color: const Color(0xFFAC7827).withOpacity(0.9),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'A GLIMPSE OF YOUR BOND',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: const Color(0xFFAC7827).withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '"Some of the best memories are the ones you haven\'t yet made with $partnerName."',
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
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                    
                    // ── Bottom Button ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: GestureDetector(
                        onTap: _partnerNameController.text.trim().isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GenderSelectionScreen(
                                      userName: widget.userName,
                                      targetName: _partnerNameController.text.trim(),
                                      currentStep: 5,
                                      totalSteps: 7,
                                      nextScreen: BeginningDateScreen(
                                        userName: widget.userName,
                                        partnerName: _partnerNameController.text.trim(),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _partnerNameController.text.trim().isNotEmpty 
                                ? const Color(0xFF1A1214) 
                                : const Color(0xFF0D080A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _partnerNameController.text.trim().isNotEmpty 
                                  ? const Color(0xFF911746).withOpacity(0.5) 
                                  : const Color(0xFF26151B),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_outline,
                                size: 18,
                                color: _partnerNameController.text.trim().isNotEmpty
                                    ? const Color(0xFFDD8F9F)
                                    : const Color(0xFF5A3C47),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Next, the details",
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: _partnerNameController.text.trim().isNotEmpty
                                      ? const Color(0xFFDD8F9F)
                                      : const Color(0xFF5A3C47),
                                ),
                              ),
                            ],
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
