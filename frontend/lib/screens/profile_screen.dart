import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'reflections_history_screen.dart';
import 'relationship_insights_screen.dart';
import 'history_screen.dart';
import 'onboarding_flow_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String? partnerName;
  const ProfileScreen({super.key, required this.userName, this.partnerName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _activeSeparation;
  String? _partnerName;
  late String _currentUserName;
  String? _gender;
  String? _relationshipDate;

  // Toggle states
  bool _notificationsEnabled = true;
  bool _locationAwarenessEnabled = false;

  // Pulse animation for connection
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fetchActiveSeparation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchActiveSeparation() async {
    try {
      final sep = await ApiService.getActiveSeparation();
      final cachedPartnerName = await ApiService.getPartnerName();
      
      Map<String, dynamic>? profile;
      try {
        profile = await ApiService.getUserProfile();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _activeSeparation = sep;
          
          if (profile != null) {
            _currentUserName = profile['name'] ?? _currentUserName;
            _gender = profile['gender'];
            _relationshipDate = profile['relationshipDate'];
          }
          
          _partnerName = sep?['partnerName'] ?? profile?['partnerName'] ?? cachedPartnerName ?? widget.partnerName;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatStartDate(dynamic startDateStr) {
    if (startDateStr == null) return 'Taking time to understand more';
    try {
      final dt = DateTime.parse(startDateStr.toString());
      return 'Began on ${DateFormat('MMM d, yyyy').format(dt)}';
    } catch (_) {
      return 'Began: $startDateStr';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  // --- Show Privacy Sheet ---
  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Color(0xFF160A0E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border(
            top: BorderSide(color: Color(0xFF3E1F2C), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E1F2C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFFDD8F9F), size: 24),
                SizedBox(width: 12),
                Text(
                  'Privacy & Security',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your space is fully yours. We believe that emotional safety is built on absolute privacy. Here is how Bonded keeps your data safe:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFD4C4CA),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildPrivacyBullet(
              Icons.lock_open,
              'End-to-End Encryption',
              'All reflections, checks, and letters are encrypted. Nobody but you and your partner can read them.',
            ),
            const SizedBox(height: 14),
            _buildPrivacyBullet(
              Icons.storage,
              'Local-First Storage',
              'We cache your notes locally on your device. Your reflection history can be cleared at any time.',
            ),
            const SizedBox(height: 14),
            _buildPrivacyBullet(
              Icons.visibility_off,
              'No Analytics Tracking',
              'We never track your text, reactions, or emotional data for advertisement. No selling, no tracking.',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2E55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'I understand',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBullet(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF260D1A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFDD8F9F), size: 16),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF866571),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Show Account Settings Dialog ---
  void _showAccountSettings(BuildContext context) {
    final nameCtrl = TextEditingController(text: _currentUserName);
    final partnerCtrl = TextEditingController(text: _partnerName ?? '');
    final genderCtrl = TextEditingController(text: _gender ?? '');
    final relDateCtrl = TextEditingController(text: _relationshipDate ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF160A0E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF3E1F2C), width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.wb_sunny_outlined, color: Color(0xFF9E7E5A), size: 20),
            SizedBox(width: 10),
            Text(
              'Profile Settings',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update details:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF866571)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'YOUR NAME',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A3C47), letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090204),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26151B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Color(0xFF5A3C47)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PARTNER NAME',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A3C47), letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090204),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26151B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: partnerCtrl,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter partner name',
                      hintStyle: TextStyle(color: Color(0xFF5A3C47)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GENDER',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A3C47), letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090204),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26151B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: genderCtrl,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'e.g., Male, Female, Non-binary',
                      hintStyle: TextStyle(color: Color(0xFF5A3C47)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ANNIVERSARY DATE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5A3C47), letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090204),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26151B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: relDateCtrl,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'YYYY-MM-DD',
                      hintStyle: TextStyle(color: Color(0xFF5A3C47)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF866571))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newPartner = partnerCtrl.text.trim();
              final newGender = genderCtrl.text.trim();
              final newRelDate = relDateCtrl.text.trim();
              
              if (newName.isNotEmpty) {
                try {
                  await ApiService.updateUserProfile(
                    name: newName,
                    partnerName: newPartner.isNotEmpty ? newPartner : null,
                    gender: newGender.isNotEmpty ? newGender : null,
                    relationshipDate: newRelDate.isNotEmpty ? newRelDate : null,
                  );
                  
                  if (newPartner.isNotEmpty) {
                    await ApiService.setPartnerName(newPartner);
                  }
                  setState(() {
                    _currentUserName = newName;
                    if (newPartner.isNotEmpty) {
                      _partnerName = newPartner;
                    }
                    _gender = newGender.isNotEmpty ? newGender : null;
                    _relationshipDate = newRelDate.isNotEmpty ? newRelDate : null;
                  });
                } catch (_) {}
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2E55),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Confirm Logout Dialog ---
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF160A0E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF3E1F2C), width: 1.5),
        ),
        title: const Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'You can sign back in at any time. Your reflections and timeline will be preserved.',
          style: TextStyle(fontSize: 14, color: Color(0xFFD4C4CA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep space', style: TextStyle(color: Color(0xFF866571))),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.clearToken();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2E55),
            ),
            child: const Text('Log out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Confirm Disconnect Space Dialog ---
  void _confirmDisconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF160A0E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF3E1F2C), width: 1.5),
        ),
        title: const Text(
          'Disconnect Space?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Are you sure you want to pause or end the current separation flow? This will stop current journey progress.',
          style: TextStyle(fontSize: 14, color: Color(0xFFD4C4CA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF866571))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_activeSeparation != null && _activeSeparation!['id'] != null) {
                try {
                  await ApiService.endSeparation(_activeSeparation!['id']);
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Space disconnected successfully.')),
                    );
                    // Force a reload of the profile to reflect the changes
                    _fetchActiveSeparation();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to disconnect: $e')),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No active separation found to disconnect.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2E55),
            ),
            child: const Text('Disconnect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Confirm Delete Account Dialog ---
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF160A0E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF7A1B29), width: 1.5),
        ),
        title: const Text(
          'Delete account?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'This action is irreversible. All of your shared spaces, letters, and reflections will be deleted immediately.',
          style: TextStyle(fontSize: 14, color: Color(0xFFD4C4CA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF866571))),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.clearToken();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1B29),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalPartner = _partnerName ?? widget.partnerName ?? 'Partner';
    final isSeparated = _activeSeparation != null;

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        _currentUserName,
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF260D1A),
                      border: Border.all(
                        color: const Color(0xFF3D1627),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF911746).withOpacity(0.12),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(_currentUserName),
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD8F9F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // --- 2. YOUR CONNECTION (UPGRADED PRETTY BANNER) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F0A13), Color(0xFF13060C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF3E1F2C), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF911746).withOpacity(0.06),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -15,
                      right: -15,
                      child: Icon(
                        Icons.favorite,
                        size: 110,
                        color: Colors.white.withOpacity(0.015),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "YOUR CONNECTION",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Color(0xFF5A3C47),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Animated connection avatars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // You Avatar
                            _buildAvatarCircle(_getInitials(_currentUserName), 'You'),
                            
                            // Connected bridge line
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 1.5,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFDD8F9F).withOpacity(0.6),
                                          const Color(0xFF9E7E5A).withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Pulsing Heart in the middle
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF1F0A13),
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            size: 14,
                                            color: Color(0xFFDD8F9F),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            // Partner Avatar
                            _buildAvatarCircle(_getInitials(finalPartner), finalPartner),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F)),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Pulsing green or pink indicator
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSeparated
                                              ? const Color(0xFFDD8F9F).withOpacity(_pulseAnimation.value * 0.7 + 0.3)
                                              : const Color(0xFF4CAF50).withOpacity(_pulseAnimation.value * 0.7 + 0.3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSeparated ? const Color(0xFFDD8F9F) : const Color(0xFF4CAF50),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSeparated ? 'In Separate Spaces' : 'Connected',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSeparated ? const Color(0xFFDD8F9F) : const Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading
                              ? "Checking connection status..."
                              : isSeparated
                                  ? (_activeSeparation!['reason']?.isNotEmpty == true
                                      ? '“${_activeSeparation!['reason']}”'
                                      : "Taking space to reflect and grow...")
                                  : "You're both here, sharing the sanctuary",
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFDD8F9F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. TWO COLUMN CARDS (STYLIZED GLASS EFFECTS) ---
              Row(
                children: [
                  // Story Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF160A0E), Color(0xFF261019)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF381A25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'YOUR STORY',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF5A3C47)),
                              ),
                              Icon(Icons.all_inclusive, color: Color(0xFF8A2E55), size: 14),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Since Jun 2023',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Growing together since then',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF866571)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Space Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSeparated
                              ? [const Color(0xFF1B140F), const Color(0xFF2E2218)]
                              : [const Color(0xFF160A0E), const Color(0xFF261019)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSeparated ? const Color(0xFF4C3827) : const Color(0xFF381A25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT SPACE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: isSeparated ? const Color(0xFF9E7E5A) : const Color(0xFF5A3C47),
                                ),
                              ),
                              Icon(
                                isSeparated ? Icons.wb_twilight : Icons.favorite_border,
                                color: isSeparated ? const Color(0xFF9E7E5A) : const Color(0xFF8A2E55),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isLoading
                                ? 'Checking...'
                                : isSeparated
                                    ? (_activeSeparation!['durationLabel'] ?? 'In a space')
                                    : 'Connected',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSeparated ? const Color(0xFF9E7E5A) : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isLoading
                                ? 'Checking space status'
                                : isSeparated
                                    ? _formatStartDate(_activeSeparation!['startDate'])
                                    : 'No active separation',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isSeparated ? const Color(0xFF866571) : const Color(0xFF5A3C47),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 4. YOUR JOURNEY (NAV LINKS CONNECTED) ---
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Your reflections',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReflectionsHistoryScreen()),
                          );
                        },
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

              // --- 7. PREFERENCES (TOGGLES WORKING, PRIVACY SHEET & ACCOUNT SETTINGS OPEN) ---
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
                        trailing: _CustomToggle(
                          value: _notificationsEnabled,
                          onChanged: (v) {
                            setState(() {
                              _notificationsEnabled = v;
                            });
                          },
                        ),
                      ),
                      _SettingItem(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        onTap: () => _showPrivacySheet(context),
                      ),
                      _SettingItem(
                        icon: Icons.location_on_outlined,
                        title: 'Location awareness',
                        subtext: 'Gentle nudge only',
                        trailing: _CustomToggle(
                          value: _locationAwarenessEnabled,
                          onChanged: (v) {
                            setState(() {
                              _locationAwarenessEnabled = v;
                            });
                          },
                        ),
                      ),
                      _SettingItem(
                        icon: Icons.person_outline,
                        title: 'Profile settings',
                        onTap: () => _showAccountSettings(context),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 8. ACCOUNT (LOGOUT & DELETION DISMISS AND ROUTE HOME) ---
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
                        onTap: () => _confirmLogout(context),
                      ),
                      _SettingItem(
                        icon: Icons.link_off,
                        title: 'Disconnect space',
                        subtext: 'End or pause the separation flow',
                        onTap: () => _confirmDisconnect(context),
                      ),
                      _SettingItem(
                        icon: Icons.delete_outline,
                        title: 'Delete account',
                        subtext: 'Removes your journey and reflections',
                        onTap: () => _confirmDeleteAccount(context),
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

  Widget _buildAvatarCircle(String initial, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF160A0E),
            border: Border.all(color: const Color(0xFF3D1627), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDD8F9F).withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF866571),
          ),
        ),
      ],
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
