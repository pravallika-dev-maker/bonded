import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'partner_name_entry_screen.dart';
import '../services/api_service.dart';

class BondSelectionScreen extends StatefulWidget {
  final String userName;
  final String? gender;
  const BondSelectionScreen({super.key, required this.userName, this.gender});

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
            child: Column(
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
                          'STEP 3 OF 7 — YOUR BOND',
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
                          'Who holds',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'your heart?',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                            height: 1.1,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ── Subtitle ──
                        const Text(
                          'This shapes everything — how we\nspeak to you, what we ask, how we\nhelp.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5E3A4B),
                            height: 1.5,
                          ),
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // ── Option 1: My partner ──
                        _buildOption(
                          index: 0,
                          title: 'My partner',
                          subtitle: 'Romantic · pre-marital · ',
                          icon: Icons.favorite_border,
                          bgColor: const Color(0xFF2A0C16),
                          borderColor: const Color(0xFF5A1630),
                          iconBgColor: const Color(0xFF3D101E),
                          iconColor: const Color(0xFFD94480),
                          titleColor: Colors.white,
                          subtitleColor: const Color(0xFF8B576C),
                        ),
                        const SizedBox(height: 16),
                        
                        // ── Option 2: Close friends ──
                        _buildOption(
                          index: 1,
                          title: 'Close friends',
                          subtitle: 'Deep, chosen family',
                          icon: Icons.people_outline,
                          bgColor: const Color(0xFF1C150A),
                          borderColor: const Color(0xFF423214),
                          iconBgColor: const Color(0xFF2E2211),
                          iconColor: const Color(0xFFAC7827),
                          titleColor: const Color(0xFFE8D19F),
                          subtitleColor: const Color(0xFF8F7E5D),
                        ),
                        const SizedBox(height: 16),
                        
                        // ── Option 3: Family ──
                        _buildOption(
                          index: 2,
                          title: 'Family',
                          subtitle: 'Siblings · parents · kin',
                          icon: Icons.water_drop_outlined,
                          bgColor: const Color(0xFF0C0A1A),
                          borderColor: const Color(0xFF1A1638),
                          iconBgColor: const Color(0xFF16132E),
                          iconColor: const Color(0xFF8B78AC),
                          titleColor: const Color(0xFFD0C4E8),
                          subtitleColor: const Color(0xFF6D6496),
                        ),
                        
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
                
                // ── Bottom Button ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                  child: GestureDetector(
                    onTap: () async {
                      final relationType = _selectedIndex == 0
                          ? 'partner'
                          : (_selectedIndex == 1 ? 'friend' : 'family');
                      // Persist relationType to local cache
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('onboarding_relationType', relationType);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PartnerNameEntryScreen(
                              userName: widget.userName,
                              gender: widget.gender,
                              relationType: relationType,
                            )),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1214),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF911746).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: Color(0xFFDD8F9F),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "This is my bond",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                              color: Color(0xFFDD8F9F),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    required Color bgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          setState(() {
            _selectedIndex = index;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Currently, Bonding is designed specifically for romantic partnerships. Support for friends and family is coming soon!',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFDD8F9F),
                ),
              ),
              backgroundColor: const Color(0xFF160A0E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2E1620), width: 1),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Opacity(
        opacity: index == 0 ? 1.0 : 0.5,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : const Color(0xFF140A10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? borderColor : borderColor.withOpacity(0.3),
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
                color: isSelected ? iconBgColor : const Color(0xFF1B0B11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
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
                      color: isSelected ? titleColor : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? subtitleColor : const Color(0xFF5E3A4B),
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
                color: isSelected ? const Color(0xFF911746) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF911746) : borderColor,
                  width: 1.5,
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
      ),
    );
  }
}
