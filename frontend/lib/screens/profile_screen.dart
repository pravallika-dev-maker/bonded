import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090204),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (IDENTITY) ---
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR SPACE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Color(0xFF9E7E5A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your journey, your pace',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6E4555),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF260D1A),
                      border: Border.all(
                        color: const Color(0xFF3D1627),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF911746).withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFDD8F9F),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- 2. YOUR CONNECTION ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F0A13),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Icon(
                        Icons.favorite,
                        size: 120,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "YOUR CONNECTION",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF5A3C47),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "$userName & Mihail",
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Connected',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "You're both here, trying to understand",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. TWO COLUMN CARDS ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF160A0E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF26151B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR STORY',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF5A3C47)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Since Jun 2023',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Growing together since then',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF5A3C47)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF160A0E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF26151B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT SPACE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFF9E7E5A).withOpacity(0.5)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'In a space',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E7E5A)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Taking time to understand more',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF5A3C47)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 4. YOUR JOURNEY ---
              _ProfileSection(
                title: 'Your journey',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF140A10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E1020), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: Icons.history,
                        title: 'View past spaces',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Your reflections',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.star_outline,
                        title: 'Relationship insights',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- 5. SOMETHING WE'VE NOTICED ---
              _ProfileSection(
                title: "Something we've noticed",
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0A13),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Icon(
                          Icons.favorite,
                          size: 80,
                          color: Colors.white.withOpacity(0.02),
                        ),
                      ),
                      Column(
                        children: const [
                          _InsightBullet(
                            text: "You've been showing up, even on difficult days",
                            dotColor: Color(0xFFDD8F9F),
                          ),
                          SizedBox(height: 16),
                          _InsightBullet(
                            text: "You're learning to pause before reacting",
                            dotColor: Color(0xFF9E7E5A),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 7. PREFERENCES ---
              _ProfileSection(
                title: 'Preferences',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF140A10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E1020), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        trailing: _CustomToggle(value: true, onChanged: (v){}),
                      ),
                      _SettingItem(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.location_on_outlined,
                        title: 'Location awareness',
                        subtext: 'Gentle nudge only',
                        trailing: _CustomToggle(value: false, onChanged: (v){}),
                      ),
                      _SettingItem(
                        icon: Icons.wb_sunny_outlined,
                        title: 'Account settings',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 8. ACCOUNT ---
              _ProfileSection(
                title: 'Account',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF140A10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E1020), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: Icons.logout,
                        title: 'Log out',
                        subtext: 'You can come back anytime',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.delete_outline,
                        title: 'Delete account',
                        subtext: 'Removes your journey and reflections',
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 64),

              // --- 9. CLOSING LINE ---
              const Center(
                child: Text(
                  '“This space will be here when you need it”',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4A343D),
                  ),
                ),
              ),
              const SizedBox(height: 120), // Spacer for navbar
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _ProfileSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Color(0xFF5A3C47),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _InsightBullet extends StatelessWidget {
  final String text;
  final Color dotColor;
  const _InsightBullet({required this.text, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFFD4C4CA),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtext;
  final Widget? trailing;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtext,
    this.trailing,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast 
          ? const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
          : title == 'Notifications' || title == 'Log out'
              ? const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(color: Color(0xFF26151B), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF260D1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF914660)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  if (subtext != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtext!,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6E4555),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing! 
            else const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3D1627)),
          ],
        ),
      ),
    );
  }
}

class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFF911746) : const Color(0xFF1A1214),
          border: Border.all(
            color: value ? const Color(0xFFDD8F9F).withOpacity(0.3) : const Color(0xFF3D1F2B),
            width: 1,
          ),
          boxShadow: value ? [
            BoxShadow(
              color: const Color(0xFF911746).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.white : const Color(0xFF3D1F2B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
