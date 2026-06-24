import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/app_event_bus.dart';
import 'reflections_history_screen.dart';
import 'history_screen.dart';
import 'onboarding_flow_screen.dart';
import 'main_dashboard_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String? partnerName;
  final VoidCallback? onProfileUpdated;
  const ProfileScreen({super.key, required this.userName, this.partnerName, this.onProfileUpdated});

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
  String? _phoneNumber;

  // Toggle states
  bool _notificationsEnabled = true;
  bool _locationAwarenessEnabled = false;
  bool _isPartnerConnected = false;

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

      bool isConnectedCached = false;
      if (profile == null) {
        isConnectedCached = await ApiService.getIsPartnerConnected();
      }

      if (mounted) {
        setState(() {
          _activeSeparation = sep;
          
          if (profile != null) {
            final pd = profile['data'] ?? profile;
            _currentUserName = pd['userName'] ?? pd['name'] ?? _currentUserName;
            _gender = pd['gender'];
            _relationshipDate = pd['relationshipDate'] ?? pd['activeRelationship']?['relationshipDate'];
            _phoneNumber = pd['phoneNumber'];
            
            // Prefer partner name from profile if available
            _partnerName = pd['partnerName'] ?? sep?['partnerName'] ?? cachedPartnerName ?? widget.partnerName;
            _isPartnerConnected = pd['isPartnerConnected'] == true;
            _notificationsEnabled = pd['notificationsEnabled'] ?? true;
          } else {
            _partnerName = sep?['partnerName'] ?? cachedPartnerName ?? widget.partnerName;
            _isPartnerConnected = isConnectedCached;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      final cachedPartnerName = await ApiService.getPartnerName();
      final isConnectedCached = await ApiService.getIsPartnerConnected();
      
      if (mounted) {
        setState(() {
          _partnerName ??= cachedPartnerName ?? widget.partnerName;
          if (!_isPartnerConnected) {
            _isPartnerConnected = isConnectedCached;
          }
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

  String _formatRelationshipDate(dynamic dateStr) {
    if (dateStr == null) return 'Journey begun';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return 'Since ${DateFormat('MMM yyyy').format(dt)}';
    } catch (_) {
      return 'Since $dateStr';
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
    final genderCtrl = TextEditingController(text: _gender ?? '');
    final relDateCtrl = TextEditingController(text: _relationshipDate ?? '');
    final phoneCtrl = TextEditingController(text: _phoneNumber ?? '');

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
                  'PHONE NUMBER',
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
                    controller: phoneCtrl,
                    enabled: false,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF866571)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'No phone number',
                      hintStyle: TextStyle(color: Color(0xFF5A3C47)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
              final newGender = genderCtrl.text.trim();
              final newRelDate = relDateCtrl.text.trim();
              
              if (newName.isNotEmpty) {
                try {
                  await ApiService.updateUserProfile(
                    name: newName,
                    gender: newGender.isNotEmpty ? newGender : null,
                    relationshipDate: newRelDate.isNotEmpty ? newRelDate : null,
                  );
                  
                  setState(() {
                    _currentUserName = newName;
                    _gender = newGender.isNotEmpty ? newGender : null;
                    _relationshipDate = newRelDate.isNotEmpty ? newRelDate : null;
                  });
                  widget.onProfileUpdated?.call();
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
  void _confirmDisconnectPartner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF160A0E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF3E1F2C), width: 1.5),
        ),
        title: const Text(
          'Disconnect Partner?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Are you sure you want to completely unlink from your partner? This will disconnect your shared spaces.',
          style: TextStyle(fontSize: 14, color: Color(0xFFD4C4CA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF866571))),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.disconnectPartner();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partner disconnected successfully.')),
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => MainDashboardScreen(
                        userName: _currentUserName,
                        isWaitingForPartner: false,
                      ),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to disconnect: $e')),
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
              try {
                // Show a loading indicator in the dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFDD8F9F)),
                  ),
                );

                await ApiService.deleteAccount();
                
                if (context.mounted) {
                  // Pop the loading dialog
                  Navigator.of(context).pop();
                  
                  // Navigate to Onboarding
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  // Pop the loading dialog
                  Navigator.of(context).pop();
                  
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090204),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFDD8F9F)),
        ),
      );
    }

    final bool hasPartner = _isPartnerConnected;
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ConstellationBackgroundPainter(animation: _pulseAnimation),
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
                              child: CustomPaint(
                                size: const Size(double.infinity, 30),
                                painter: _AliveConnectionLinePainter(
                                  animation: _pulseAnimation,
                                  isConnected: hasPartner,
                                ),
                              ),
                            ),
                            
                            // Partner Avatar
                            _buildAvatarCircle(
                              hasPartner ? _getInitials(_partnerName?.isNotEmpty == true ? _partnerName! : 'Partner') : '', 
                              hasPartner ? (_partnerName?.isNotEmpty == true ? _partnerName! : 'Partner') : 'Waiting...', 
                              isWaiting: !hasPartner
                            ),
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
                                          color: !hasPartner
                                              ? const Color(0xFFDD8F9F).withOpacity(_pulseAnimation.value * 0.7 + 0.3)
                                              : isSeparated
                                                  ? const Color(0xFFDD8F9F).withOpacity(_pulseAnimation.value * 0.7 + 0.3)
                                                  : const Color(0xFF4CAF50).withOpacity(_pulseAnimation.value * 0.7 + 0.3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: !hasPartner ? const Color(0xFFDD8F9F) : isSeparated ? const Color(0xFFDD8F9F) : const Color(0xFF4CAF50),
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
                                    !hasPartner ? 'Shared Space Preparing' : isSeparated ? 'In Separate Spaces' : 'Connected',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: !hasPartner ? const Color(0xFFDD8F9F) : isSeparated ? const Color(0xFFDD8F9F) : const Color(0xFF4CAF50),
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
                              : !hasPartner 
                                  ? "Your shared space is being created.\nInvite someone meaningful to begin the journey."
                                  : isSeparated
                                      ? (_activeSeparation!['reason']?.isNotEmpty == true
                                          ? '“${_activeSeparation!['reason']}”'
                                          : "Taking space to reflect and grow...")
                                      : "You're both here, sharing the sanctuary",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: !hasPartner ? const Color(0xFFD4C4CA) : const Color(0xFFDD8F9F),
                            height: 1.5,
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
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Text(
                            hasPartner 
                                ? _formatRelationshipDate(_relationshipDate)
                                : 'Awaiting Connection',
                            style: const TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasPartner 
                                ? 'Growing together since then'
                                : 'Ready to begin your story',
                            style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF866571)),
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
                                : !hasPartner
                                    ? 'Available'
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
                                : !hasPartner
                                    ? 'Waiting for partner'
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
                          onChanged: (v) async {
                            // Optimistically update UI
                            setState(() {
                              _notificationsEnabled = v;
                            });
                            
                            try {
                              await ApiService.updateUserProfile(notificationsEnabled: v);
                              
                              if (v && !kIsWeb) {
                                // They just turned it on, so request permission and generate token!
                                FirebaseMessaging messaging = FirebaseMessaging.instance;
                                await messaging.requestPermission(
                                  alert: true,
                                  badge: true,
                                  sound: true,
                                );
                                String? token = await messaging.getToken();
                                if (token != null) {
                                  await ApiService.registerFcmToken(token);
                                }
                              }
                            } catch (e) {
                              // Revert on error
                              if (mounted) {
                                setState(() {
                                  _notificationsEnabled = !v;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to update notification settings.')),
                                );
                              }
                            }
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
                        subtext: 'Coming soon',
                        trailing: const Text(
                          'Coming soon',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF6E4555),
                          ),
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
                      if (hasPartner || _partnerName != null)
                        _SettingItem(
                          icon: Icons.link_off,
                          title: 'Disconnect partner',
                          subtext: 'Unlink from your current partner',
                          onTap: () => _confirmDisconnectPartner(context),
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
              const SizedBox(height: 40),

              // --- 9. DEVELOPER TOOLS ---
              if (isSeparated)
                _ProfileSection(
                  title: 'Developer Tools (Testing)',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF140A10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF4A6572), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        _SettingItem(
                          icon: Icons.fast_forward,
                          title: 'Time Travel to End',
                          subtext: 'Instantly ends active separation today for testing',
                          isLast: true,
                          onTap: () async {
  if (!_isPartnerConnected) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❗ You must be connected with a partner to use Time Travel. Connect first.'),
          backgroundColor: Color(0xFF2A0D18),
          duration: Duration(seconds: 4),
        ),
      );
    }
    return;
  }
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDD8F9F))),
      ),
    );
    await ApiService.timeTravelSeparation();
    // Broadcast so dashboard + journey screen instantly refresh
    AppEventBus().emit(AppEvent.timeTravelCompleted);
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      // Navigate to dashboard home tab — this triggers _fetchDashboardData()
      // which will detect has_completed_separation == true and immediately
      // set _isCheckedIn = true, unlocking final insights for this user.
      // The partner's insights unlock the next time their app polls /home-hero.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainDashboardScreen(
            userName: _currentUserName,
            partnerName: _partnerName,
            initialIndex: 0,
          ),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      String message = 'Error: $e';
      if (e.toString().contains('No active separation found')) {
        message = 'Time travel already done - no active separation found.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF2A0D18),
        ),
      );
    }
  }
},
                        ),
                      ],
                    ),
                  ),
                ),
              if (isSeparated) const SizedBox(height: 64),

              // --- 10. CLOSING LINE ---
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

  Widget _buildAvatarCircle(String initial, String label, {bool isWaiting = false}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isWaiting ? const Color(0xFF1A0A11) : const Color(0xFF160A0E), // Slightly brighter background
            border: Border.all(
              color: isWaiting ? const Color(0xFF5A2C40).withOpacity(0.8) : const Color(0xFF3D1627), // Brighter border
              width: isWaiting ? 1.5 : 1.5
            ),
            boxShadow: isWaiting ? [
              BoxShadow(
                color: const Color(0xFFE0BFB8).withOpacity(0.05), // Subtle outer glow
                blurRadius: 10,
                spreadRadius: 1,
              )
            ] : [
              BoxShadow(
                color: const Color(0xFFDD8F9F).withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: isWaiting
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final size = 16.0 + (4.0 * _pulseAnimation.value);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0BFB8).withOpacity(0.5 + 0.3 * _pulseAnimation.value), // Rose gold orb
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE0BFB8).withOpacity(0.4 * _pulseAnimation.value),
                              blurRadius: 12 * _pulseAnimation.value,
                              spreadRadius: 3 * _pulseAnimation.value,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Text(
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
          style: TextStyle(
            fontSize: 11,
            color: isWaiting ? const Color(0xFF866571) : const Color(0xFF866571), // Brighter text color
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

class _ConstellationBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  _ConstellationBackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42); // Fixed seed for stable constellation
    final paint = Paint()
      ..color = const Color(0xFFDD8F9F).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    for (int i = 0; i < 15; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 2.0 + 1.0;
      
      // Twinkle effect based on animation and random offset
      final twinkle = (math.sin(animation.value * math.pi * 2 + rand.nextDouble() * 10) + 1) / 2;
      
      paint.color = const Color(0xFFDD8F9F).withOpacity(0.05 + 0.15 * twinkle);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ConstellationBackgroundPainter oldDelegate) => true;
}

class _AliveConnectionLinePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isConnected;
  
  _AliveConnectionLinePainter({required this.animation, required this.isConnected}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height / 2;

    // Base subtle line
    final baseLinePaint = Paint()
      ..color = const Color(0xFF3D1627)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(0, cy), Offset(w, cy), baseLinePaint);

    if (isConnected) {
      // Flowing energy line when connected
      final pulse = (math.sin(animation.value * math.pi * 2) + 1) / 2;
      final activeLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF911746).withOpacity(0.0),
            const Color(0xFFDD8F9F).withOpacity(0.8 * pulse + 0.2),
            const Color(0xFF911746).withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, w, size.height))
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(0, cy), Offset(w, cy), activeLinePaint);
      
      // Pulsing heart in center
      final heartIcon = Icons.favorite;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(heartIcon.codePoint),
          style: TextStyle(
            fontSize: 22 + (4 * pulse), // Increased size
            fontFamily: heartIcon.fontFamily,
            package: heartIcon.fontPackage,
            color: const Color(0xFFE0BFB8), // Rose gold
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      
      // Heart glow
      canvas.drawCircle(
        Offset(w/2, cy), 
        16, 
        Paint()
          ..color = const Color(0xFFE0BFB8).withOpacity(0.3 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
      );
      
      textPainter.paint(canvas, Offset(w / 2 - textPainter.width / 2, cy - textPainter.height / 2));
    } else {
      // Anticipation energy reaching out when not connected
      final progress = animation.value;
      
      // Draw a breathing glowing path
      final glowPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF911746).withOpacity(0.0),
            const Color(0xFFE0BFB8).withOpacity(0.3 * progress), // Rose gold glow
            const Color(0xFF911746).withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, w, size.height))
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
        ..style = PaintingStyle.stroke;
        
      canvas.drawLine(Offset(0, cy), Offset(w, cy), glowPaint);

      // Draw a tiny traveler particle showing anticipation
      final travelerX = w * progress;
      final travelerPaint = Paint()
        ..color = const Color(0xFFE0BFB8).withOpacity(1.0 - progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(Offset(travelerX, cy), 2.5, travelerPaint);
      
      // Soft breathing center orb/heart
      final orbPulse = (math.sin(animation.value * math.pi * 2) + 1) / 2;
      
      final heartIcon = Icons.favorite; // Changed to solid heart
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(heartIcon.codePoint),
          style: TextStyle(
            fontSize: 22 + (2 * orbPulse), // Larger solid heart
            fontFamily: heartIcon.fontFamily,
            package: heartIcon.fontPackage,
            color: const Color(0xFFE0BFB8), // Solid Rose gold
            shadows: [
              Shadow(
                color: const Color(0xFFE0BFB8).withOpacity(0.6 * orbPulse),
                blurRadius: 10.0,
              ),
            ],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      
      textPainter.paint(canvas, Offset(w / 2 - textPainter.width / 2, cy - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_AliveConnectionLinePainter oldDelegate) => true;
}
