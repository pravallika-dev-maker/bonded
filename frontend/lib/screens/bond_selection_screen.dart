import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'partner_name_entry_screen.dart';

class BondSelectionScreen extends StatefulWidget {
  const BondSelectionScreen({super.key});

  @override
  State<BondSelectionScreen> createState() => _BondSelectionScreenState();
}

class _BondSelectionScreenState extends State<BondSelectionScreen> {
  int _selectedIndex = 0; // 0: My partner, 1: Close friends, 2: Family

  @override
  Widget build(BuildContext context) {
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
                              'STEP 2 OF 4 — YOUR BOND',
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
                              'Who holds\n',
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
                                'your heart?',
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
                              'This shapes everything — how we\nspeak to you, what we ask, how we\nhelp.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9E7A85),
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // ── Option 1: My partner ──
                            _buildOption(
                              index: 0,
                              title: 'My partner',
                              subtitle: 'Romantic · pre-marital · ',
                              icon: Icons.favorite_outline,
                              baseColor: const Color(0xFFD94480),
                              titleColor: Colors.white,
                              subtitleColor: const Color(0xFF9E7A85),
                            ),
                            const SizedBox(height: 16),
                            
                            // ── Option 2: Close friends ──
                            _buildOption(
                              index: 1,
                              title: 'Close friends',
                              subtitle: 'Deep, chosen family',
                              icon: Icons.people_outline,
                              baseColor: const Color(0xFFAC7827),
                              titleColor: const Color(0xFFF0E0B8),
                              subtitleColor: const Color(0xFFAC7827).withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            
                            // ── Option 3: Family ──
                            _buildOption(
                              index: 2,
                              title: 'Family',
                              subtitle: 'Siblings · parents · kin',
                              icon: Icons.water_drop_outlined,
                              baseColor: const Color(0xFF8B78AC),
                              titleColor: const Color(0xFFD0C4E8),
                              subtitleColor: const Color(0xFF8B78AC).withOpacity(0.7),
                            ),
                            
                            const SizedBox(height: 40),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PartnerNameEntryScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.favorite_outline,
                            size: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          label: Text(
                            "This is my bond",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1A3C),
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

  Widget _buildOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color baseColor,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? baseColor.withOpacity(0.15) 
              : const Color(0xFF140A10), // slightly different background for unselected
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? baseColor.withOpacity(0.5) : baseColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Left Icon Box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: baseColor.withOpacity(0.9),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right Check / Circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? baseColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? baseColor : baseColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
