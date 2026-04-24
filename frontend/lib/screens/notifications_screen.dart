import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  final List<NotificationItem> _todayItems = [
    NotificationItem(
      title: "It's time to sit with your feelings today",
      time: "2h ago",
      subtext: "Take a moment for yourself",
    ),
    NotificationItem(
      title: "Your next step is ready",
      time: "4h ago",
    ),
    NotificationItem(
      title: "Something small is waiting for you",
      time: "5h ago",
      subtext: "A new reflection is available",
    ),
  ];

  final List<NotificationItem> _earlierItems = [
    NotificationItem(
      title: "You’ve been showing up consistently",
      time: "Yesterday",
      subtext: "7 days in a row",
    ),
    NotificationItem(
      title: "You paused instead of reacting yesterday",
      time: "Yesterday",
    ),
    NotificationItem(
      title: "Your space is still waiting for you",
      time: "2 days ago",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.5),
              radius: 1.2,
              colors: [
                Color(0xFF260814),
                Color(0xFF090204),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1214),
                            border: Border.all(color: const Color(0xFF3D1627), width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFFDD8F9F)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Moments',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '“We don’t notify often… only when it matters.”',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8A6530),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: _todayItems.isEmpty && _earlierItems.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          children: [
                            if (_todayItems.isNotEmpty) ...[
                              _buildSectionTitle("Today"),
                              const SizedBox(height: 16),
                              ...List.generate(_todayItems.length, (index) {
                                return _buildNotificationTile(_todayItems[index], index);
                              }),
                              const SizedBox(height: 32),
                            ],
                            if (_earlierItems.isNotEmpty) ...[
                              _buildSectionTitle("Earlier"),
                              const SizedBox(height: 16),
                              ...List.generate(_earlierItems.length, (index) {
                                return _buildNotificationTile(
                                  _earlierItems[index],
                                  index + _todayItems.length,
                                );
                              }),
                            ],
                            const SizedBox(height: 40),
                            _buildManageSettings(),
                            const SizedBox(height: 40),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: Color(0xFF6E4555),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item, int index) {
    // stagger animation
    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF160A0E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF26181E), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5A3C47),
                  ),
                ),
              ],
            ),
            if (item.subtext != null) ...[
              const SizedBox(height: 6),
              Text(
                item.subtext!,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFDD8F9F),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border, color: Color(0xFF3D1627), size: 48),
          SizedBox(height: 24),
          Text(
            'It’s quiet here for now',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFFDD8F9F),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We’ll reach you when something matters',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5A3C47),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSettings() {
    return Center(
      child: GestureDetector(
        onTap: () => _showManageMomentsSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2E1620), width: 1),
          ),
          child: const Text(
            "Manage notifications",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Color(0xFF6E4555),
            ),
          ),
        ),
      ),
    );
  }

  void _showManageMomentsSheet(BuildContext context) {
    bool dailyReminders = true;
    bool insightAlerts = false;
    bool gentleNudges = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF090204),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26151B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main settings card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF140A10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2E1020), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Text(
                            'MANAGE MOMENTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Color(0xFF6E4555),
                            ),
                          ),
                        ),
                        _buildToggleItem(
                          title: "Daily check-in reminders",
                          value: dailyReminders,
                          onChanged: (val) {
                            setModalState(() => dailyReminders = val);
                          },
                          isLast: false,
                        ),
                        _buildToggleItem(
                          title: "Insight alerts",
                          value: insightAlerts,
                          onChanged: (val) {
                            setModalState(() => insightAlerts = val);
                          },
                          isLast: false,
                        ),
                        _buildToggleItem(
                          title: "Gentle nudges",
                          value: gentleNudges,
                          onChanged: (val) {
                            setModalState(() => gentleNudges = val);
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text(
                    'This space will be here when you need it',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3B252E),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Adjusted vertical for switch sizing
      decoration: BoxDecoration(
        border: isLast ? null : const Border(
          bottom: BorderSide(color: Color(0xFF26151B), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value ? const Color(0xFF911746) : const Color(0xFF0D080A),
                border: Border.all(
                  color: value ? const Color(0xFFDD8F9F).withOpacity(0.3) : const Color(0xFF26151B),
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
                    color: value ? Colors.white : const Color(0xFF26151B),
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
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String time;
  final String? subtext;

  NotificationItem({
    required this.title,
    required this.time,
    this.subtext,
  });
}
